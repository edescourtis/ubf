%% @doc Implement the plugin server, an intermediate process between
%%      the contract manager process and the server application.
%%
%% The server application may or may not have a separate process (see
%% the diagram below).  The there is no application process(es), then
%% the remote procedure call will be executed by the process executing
%% this module's `loop()' function.
%%
%% This module also implements the plugin manager loop.
%% TODO More detail, please.
%%
%% <img src="../priv/doc/ubf-flow-01.png"></img>

-module(ubf_plugin_handler).

-export([start_handler/0, start_manager/2, manager/2]).

%%----------------------------------------------------------------------
%% Handler stuff

start_handler() ->
    proc_utils:spawn_link_debug(fun() -> wait() end, ?MODULE).

wait() ->
    receive
        {start, Contract, Server, Mod} ->
            loop(Contract, start, [], Server, Mod);
        stop ->
            exit({serverPluginHandler, stop})
    end.

loop(Client, State1, Data, Manager, Mod) ->
    receive
        {_Pid, {rpc, Q}} ->
            if Manager /= undefined ->
                    case (catch Mod:handlerRpc(State1, Q, Data, Manager)) of
                        {Reply, State2, Data2} ->
                            Client ! {self(), {rpcReply, Reply, State2, same}},
                            loop(Client, State2, Data2, Manager, Mod);
                        {changeContract, Reply, State1, HandlerMod, State2, Data2, ManPid} ->
                            Client ! {self(), {rpcReply, Reply, State1,
                                               {new, HandlerMod, State2}}},
                            loop(Client, State2, Data2, ManPid, HandlerMod);
                        {'EXIT', Reason} ->
                            contract_manager_tlog:checkOutError(Q, State1, Mod, Reason),
                            exit({serverPluginHandler, Reason})
                    end;
               true ->
                    case (catch Mod:handlerRpc(State1, Q, Data)) of
                        {Reply, State2, Data2} ->
                            Client ! {self(), {rpcReply, Reply, State2, same}},
                            loop(Client, State2, Data2, Manager, Mod);
                        {changeContract, Reply, State1, HandlerMod, State2, Data2} ->
                            Client ! {self(), {rpcReply, Reply, State1,
                                               {new, HandlerMod, State2}}},
                            loop(Client, State2, Data2, Manager, HandlerMod);
                        {'EXIT', Reason} ->
                            contract_manager_tlog:checkOutError(Q, State1, Mod, Reason),
                            exit({serverPluginHandler, Reason})
                    end
            end;
        {event, X} ->
            Client ! {event, X},
            loop(Client, State1, Data, Manager, Mod);
        stop ->
            if Manager /= undefined ->
                    Manager ! {client_has_stopped, self()};
               true ->
                    case (catch Mod:handlerStop(undefined, normal, Data)) of
                        {'EXIT', OOps} ->
                            io:format("plug in error:~p~n",[OOps]);
                        _ ->
                            noop
                    end
            end;
        Other ->
            io:format("**** OOOPYikes ...~p (Client=~p)~n",[Other,Client]),
            loop(Client, State1, Data, Manager, Mod)
    end.


%%----------------------------------------------------------------------

start_manager(Mod, Args) ->
    proc_utils:spawn_link_debug(fun() -> manager(Mod, Args) end, ?MODULE).

manager(Mod, Args) ->
    process_flag(trap_exit, true),
    {ok, State} = Mod:managerStart(Args),
    manager_loop(Mod, State).

manager_loop(Mod, State) ->
    receive
        {From, {startSession, Service}} ->
            case (catch Mod:startSession(Service, State)) of
                {accept, HandlerMod, ModManagerPid, State2} ->
                    From ! {self(), {accept,HandlerMod, ModManagerPid}},
                    manager_loop(Mod, State2);
                {reject, Reason, _State1} ->
                    From ! {self(), {reject, Reason}},
                    manager_loop(Mod, State)
            end;
        {client_has_stopped, Pid} ->
            case (catch Mod:handlerStop(Pid, normal, State)) of
                {'EXIT', OOps} ->
                    io:format("plug in error:~p~n",[OOps]),
                    manager_loop(Mod, State);
                State1 ->
                    manager_loop(Mod, State1)
            end;
        {'EXIT', Pid, Reason} ->
            case (catch Mod:handlerStop(Pid, Reason, State)) of
                {'EXIT', OOps} ->
                    io:format("plug in error:~p~n",[OOps]),
                    manager_loop(Mod, State);
                State1 ->
                    manager_loop(Mod, State1)
            end;
        {From, {handler_rpc, Q}} ->
            case (catch Mod:managerRpc(Q, State)) of
                {'EXIT', OOps} ->
                    io:format("plug in error:~p~n",[OOps]),
                    exit(From, bad_ask_manager),
                    manager_loop(Mod, State);
                {Reply, State1} ->
                    From ! {handler_rpc_reply, Reply},
                    manager_loop(Mod, State1)
            end;
        X ->
            io:format("******Dropping (service manager ~p) self=~p ~p~n",
                      [Mod,self(), X]),
            manager_loop(Mod, State)
    end.
