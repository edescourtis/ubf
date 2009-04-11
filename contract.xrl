%% Token Definitions for UBF(2)
%% Joe Armstrong (joe@sics.se) 2002-02-22
%% Derived from nex.xrl by Robert Virding

Definitions.
O	= [0-7]
D	= [0-9]
H	= [0-9a-fA-F]
A	= [a-z_A-Z@0-9]
WS	= [\000-\s]    

Rules.
{D}+		:	{token,{integer,YYline,list_to_integer(YYtext)}}.
[a-z]{A}*	:	Atom = list_to_atom(YYtext),
			{token,case reserved_word(Atom) of
				   true -> {Atom,YYline};
				   false -> {atom,YYline,Atom}
			       end}.
VSN             :       {token,{vsn, YYline}}.
TYPE            :       {token,{typeKwd,YYline}}.
STATE           :       {token,{state,YYline}}.
EVENT           :       {token,{event,YYline}}.
NAME            :       {token,{name,YYline}}.
INFO            :       {token,{info,YYline}}.
DESCRIPTION     :       {token,{description,YYline}}.
"[^"]*"         :	S = lists:sublist(YYtext, 2, length(YYtext) - 2),
			{token,{string,YYline,S}}.
=>		:	{token,{'=>',YYline}}.
[;&,=+()[\]|<>{}] :
			{token,{list_to_atom(YYtext),YYline}}.
\.{WS}		:	{end_token,{dot,YYline}}.
\.%.*		:	{end_token,{dot,YYline}}. % Must special case this
{WS}+		:	.			  % No token returned,eqivalent
\%.*		:	skip_token.		  % to 'skip_token'
[A-Z]+          :       skip_token.

Erlang code.

-author('joe@sics.se').
-copyright('Copyright (c) 2001 SICS').

-export([reserved_word/1]).

reserved_word(_) -> false.






