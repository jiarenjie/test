%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2017 9:03
%%%-------------------------------------------------------------------
-module(mafiapp).
-author("jiarj").
-behavior(application).
-include_lib("stdlib/include/qlc.hrl").

-record(mafiapp_friends,{name,
  count=[],inf0=[],expertise
  }).
%% API
-export([install/0, start/2, stop/1,add/0,find/0,find2/0]).


install() ->
  mnesia:delete_schema([node()]),
  mnesia:create_schema([node()]),
  application:start(mnesia),
  mnesia:create_table(mafiapp_friends, [{attributes,record_info(fields,mafiapp_friends)}, {disc_copies,[node()]}]),
  application:stop(mnesia).

start(normal, []) ->
  mnesia:wait_for_tables([mafiapp_friends],5000),
  test_sup:start_link().

add()->
  F=fun()->
  mnesia:write(#mafiapp_friends{name="tom",count = "sda",inf0 = {1994,02,05},expertise = "hehe"})
  end,
  mnesia:activity(transaction,F)
.
find()->

  do(qlc:q([ X || X <- mnesia:table(mafiapp_friends)])).

find2()->
  F=fun()->
    mnesia:read({mafiapp_friends, "tom"})
    end,
  mnesia:activity(transaction,F).

do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.


stop(_) ->
  ok.