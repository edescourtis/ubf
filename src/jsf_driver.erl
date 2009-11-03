%% @doc Server-side protocol driver process for JSF (JavaScript
%% Format) protocol sessions.
%%
%% The process executing `loop()' in this module is represented in the
%% diagram below by the "UBF Driver" circle.
%% <img src="../priv/doc/ubf-flow-01.png"></img>

-module(jsf_driver).

-export([start/0, loop/2, loop/3, relay/2]).

start() ->
    proc_utils:spawn_link_debug(fun() -> start1() end, jsf_client_driver).

start1() ->
    receive
        {start, Socket, Pid} ->
            loop(Socket, Pid);
        stop ->
            exit(start)
    end.

loop(Socket, Pid) ->
    loop(Socket, Pid, 16#ffffffff).

loop(Socket, Pid, Timeout) ->
    put('ubf_socket', Socket),
    Cont = [],
    loop(Socket, Pid, Timeout, Cont, jsf).

relay(Pid, Pid1) ->
    put('ubf_info', ?MODULE),
    Pid ! {relay, self(), Pid1}.

%% @doc Driver main loop.
%%
%% <ul>
%% <li> A driver sits between a socket and a Pid </li>
%% <li> Stuff on the socket is send to the Pid </li>
%% <li> Stuff from the Pid is send to the socket </li>
%% <li> When it is called the Socket has been
%% set to send messages to the driver
%% and the Pid exists  </li>
%% <li> If one side dies the process dies </li>
%% </ul>

loop(Socket, Pid, Timeout, Cont, HandlerMod) ->
    receive
        {Pid, Term} ->
            Data = jsf:encode(Term, HandlerMod),
            ok = gen_tcp:send(Socket, [Data,"\n"]),
            loop(Socket, Pid, Timeout, Cont, HandlerMod);
        stop ->
            Pid ! stop,
            gen_tcp:close(Socket),
            exit(normal);
        {changeContract, HandlerMod1} ->
            loop(Socket, Pid, Timeout, Cont, HandlerMod1);
        {relay, _From, Pid1} ->
            loop(Socket, Pid1, Timeout, Cont, HandlerMod);
        {tcp_closed, Socket} ->
            Pid ! stop,
            exit(socket_closed);
        {tcp_error, Socket, Reason} ->
            gen_tcp:close(Socket),
            exit({socket_error,Reason});
        {tcp, Socket, Data} ->
            T = binary_to_list(Data),
            Cont1 = jsf:decode(lists:append(Cont, T), HandlerMod),
            handle_data(Socket, Pid, Timeout, Cont1, HandlerMod);
        Any ->
            io:format("~p:~p *** ~p dropping:~p~n",[?FILE, self(), Pid, Any]),
            loop(Socket, Pid, Timeout, Cont, HandlerMod)
    after Timeout ->
            gen_tcp:close(Socket),
            exit(timeout)
    end.

handle_data(Socket, Pid, Timeout, {ok, Term, []}, HandlerMod) ->
    Pid ! {self(), Term},
    loop(Socket, Pid, Timeout, [], HandlerMod);
handle_data(Socket, Pid, Timeout, {ok, Term, Str}, HandlerMod) ->
    Pid ! {self(), Term},
    Cont = jsf:decode(Str, HandlerMod),
    handle_data(Socket, Pid, Timeout, Cont, HandlerMod);
handle_data(_Socket, _Pid, _Timeout, XX, _HandlerMod) ->
    io:format("~p:~p uugn:~p~n",[?FILE, self(), XX]).
