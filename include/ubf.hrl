%%%----------------------------------------------------------------------
%%% Description: UBF Utilities
%%%----------------------------------------------------------------------

-ifndef(ubf).
-define(ubf, true).

%%%-------------------------------------------------------------------
%%% Macros
%%%-------------------------------------------------------------------

%% ubf string helper
-define(S(X),
        #'#S'{value=X}).

%% ubf proplist helper
-define(P(X),
        #'#P'{value=X}).

%%%-------------------------------------------------------------------
%%% Records
%%%-------------------------------------------------------------------

%% ubf string record
-record('#S',
        {value=""}).

%% ubf proplist record
-record('#P',
        {value=[]}).

-endif. % -ifndef(ubf)