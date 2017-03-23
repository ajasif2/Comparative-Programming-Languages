-module(assign9_tests).

-include_lib("eunit/include/eunit.hrl").

% Asif Jamal
% 3/9/2017
% Assignment 9 - Expressions Tests
% Tests for parse, eval and execute functions. 

parse_1_test() ->
	true = {{num, 9}, ""} == assign9:parse("9").

parse_2_test() ->
	true = {{var, b}, ""} == assign9:parse("b").
	
parse_3_test() ->
	true = {{num, 77}, ""} == assign9:parse("77").
	
parse_4_test() ->
	true = {{var, aa}, ""} == assign9:parse("aa").

parse_5_test() ->
	true = {{add, {num, 3}, {num, 4}},""} == assign9:parse("(3+4)").
	
parse_6_test() ->
	true = {{sub, {num, 8}, {num, 2}}, ""} == assign9:parse("(8-2)").
	
parse_7_test() ->
	true = {{mul, {num, 3}, {num, 2}}, ""} == assign9:parse("(3*2)").

parse_8_test() ->
	true = {{divide, {num, 10}, {num, 5}}, ""} == assign9:parse("(10/5)").
	
parse_9_test() ->
	true = {{mul, {add, {num, 3}, {num, 1}}, {num, 3}}, ""} == assign9:parse("((3+1)*3)").

parse_10_test() ->
	true = {{divide, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {num, 3}}, ""} == assign9:parse("(((3+1)*3)/3)").
	
parse_11_test() ->
	true = {{sub, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {divide, {num, 6}, {num, 3}}}, ""} == assign9:parse("(((3+1)*3)-(6/3))").

parse_12_test() ->
	true = {{mul,{num,-55},{var,eeee}} , "+1111)"} == assign9:parse("(-55*eeee)+1111)").
	
parse_13_test() ->
	true = {{add, {num, 2}, {add, {var, a}, {var, b}}}, ""} == assign9:parse("(2+(a+b))").

parse_14_test() ->
	true = {{add, {add, {num, 1}, {num, 2}},{num, 3}}, ""} == assign9:parse2("(1+2+3)").
	
parse_15_test() ->
	true = {{mul, {add, {num, 3}, {num, 1}}, 3}, ""} == assign9:parse2("(3+1*3)").

parse_16_test() ->
	true = {{mul, {add, {num, 3}, {num, 1}}, {divide, {num, 3}, {num, 3}}}, ""} == assign9:parse2("(3+1*3/3)").
	
parse_17_test() ->
	true = {{sub, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {divide, {num, 6}, {num, 3}}}, ""} == assign9:parse2("(3+1*3-6/3)").
	
parse_18_test() ->
	true = {{add, {add, {num, 2}, {var, a}}, {var, b}}, ""} == assign9:parse2("(2+a+b)").

eval_1_test() ->
	true = 9 == assign9:eval({num, 9}).

eval_2_test() ->
	true = 5 == assign9:eval([{b, 5}], {var, b}).	
	
eval_3_test() ->
	true = 77 == assign9:eval({num, 77}).
	
eval_4_test() ->
	true = 4 == assign9:eval([{aa, 4}], {var, aa}).

eval_5_test() ->
	true = 7 == assign9:eval({add, {num, 3}, {num, 4}}).
	
eval_6_test() ->
	true = 6 == assign9:eval({sub, {num, 8}, {num, 2}}).
	
eval_7_test() ->
	true = 6 == assign9:eval({mul, {num, 3}, {num, 2}}).

eval_8_test() ->
	true = 2 == assign9:eval({divide, {num, 10}, {num, 5}}).
	
eval_9_test() ->
	true = 12 == assign9:eval({mul, {add, {num, 3}, {num, 1}}, {num, 3}}).

eval_10_test() ->
	true = 4 == assign9:eval({divide, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {num, 3}}).
	
eval_11_test() ->
	true = 10 == assign9:eval({sub, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {divide, {num, 6}, {num, 3}}}).

eval_12_test() ->
	true = -55 == assign9:eval([{eeee, 1}], {mul,{num,-55},{var,eeee}}).
	
eval_13_test() ->
	true = 8 == assign9:eval([{a,2}, {b,3}], {add, {num, 2}, {add, {var, a}, {var, b}}}).

eval_14_test() ->
	true = 6 == assign9:eval({add, {add, {num, 1}, {num, 2}},{num, 3}}).
	
eval_15_test() ->
	true = 9 == assign9:eval({mul, {add, {num, 3}, {num, 1}}, 3}).

eval_16_test() ->
	true = 4 == assign9:eval({mul, {add, {num, 3}, {num, 1}}, {divide, {num, 3}, {num, 3}}}).
	
eval_17_test() ->
	true = 4 == assign9:eval({sub, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {divide, {num, 6}, {num, 3}}}).
	
eval_18_test() ->
	true = 4 == assign9:eval([{a,-1},{b, 3}], {add, {add, {num, 2}, {var, a}}, {var, b}}).

execute_1_test() ->
	true = 9 == assign9:execute([{a, 1}], {num, 9}).

execute_2_test() ->
	true = 5 == assign9:execute([{b, 5}], {var, b}).	
	
execute_3_test() ->
	true = 77 == assign9:execute([{a, 1}], {num, 77}).
	
execute_4_test() ->
	true = 4 == assign9:execute([{aa, 4}], {var, aa}).

execute_5_test() ->
	true = 7 == assign9:execute([{a, 1}], {add, {num, 3}, {num, 4}}).
	
execute_6_test() ->
	true = 6 == assign9:execute([{a, 1}], {sub, {num, 8}, {num, 2}}).
	
execute_7_test() ->
	true = 6 == assign9:execute([{a, 1}], {mul, {num, 3}, {num, 2}}).

execute_8_test() ->
	true = 2 == assign9:execute([{a, 1}], {divide, {num, 10}, {num, 5}}).
	
execute_9_test() ->
	true = 12 == assign9:execute([{a, 1}], {mul, {add, {num, 3}, {num, 1}}, {num, 3}}).

execute_10_test() ->
	true = 4 == assign9:execute([{a, 1}], {divide, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {num, 3}}).
	
execute_11_test() ->
	true = 10 == assign9:execute([{a, 1}], {sub, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {divide, {num, 6}, {num, 3}}}).

execute_12_test() ->
	true = -55 == assign9:execute([{eeee, 1}], {mul,{num,-55},{var,eeee}}).
	
execute_13_test() ->
	true = 8 == assign9:execute([{a,2}, {b,3}], {add, {num, 2}, {add, {var, a}, {var, b}}}).

execute_14_test() ->
	true = 6 == assign9:execute([{a, 1}], {add, {add, {num, 1}, {num, 2}},{num, 3}}).
	
execute_15_test() ->
	true = 9 == assign9:execute([{a, 1}], {mul, {add, {num, 3}, {num, 1}}, 3}).

execute_16_test() ->
	true = 4 == assign9:execute([{a, 1}], {mul, {add, {num, 3}, {num, 1}}, {divide, {num, 3}, {num, 3}}}).
	
execute_17_test() ->
	true = 4 == assign9:execute([{a, 1}], {sub, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {divide, {num, 6}, {num, 3}}}).
	
execute_18_test() ->
	true = 4 == assign9:execute([{a,-1},{b, 3}], {add, {add, {num, 2}, {var, a}}, {var, b}}).
