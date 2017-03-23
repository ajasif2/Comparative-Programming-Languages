-module(assign9).
-compile(export_all).

% Asif Jamal
% Assignment 9 - Expressions
% 3/9/2017

%
% A suite of functions for handling arithmetical expressions
%

% Expressions are represented like this
%
%     {num, N}
%     {var, A}
%     {add, E1, E2}
%     {mul, E1, E2}
%
% where N is a number, A is an atom,
% and E1, E2 are themselves expressions,

-type expr() :: {'num',integer()}
             |  {'var',atom()}
             |  {'add',expr(),expr()}
             |  {'mul',expr(),expr()}
			 |	{'sub',expr(),expr()}
			 |	{'divide',expr(),expr()}.

% For example,
%   {add,{var,a},{mul,{num,2},{var,b}}
% represents the mathematical expression
%   (a+(2*b))

%
% Printing
%

% Turn an expression into a string, so that
%   {add,{var,a},{mul,{num,2},{var,b}}
% is turned into
%   "(a+(2*b))"

-spec print(expr()) -> string().

print({num,N}) ->
    integer_to_list(N);
print({var,A}) ->
    atom_to_list(A);
print({add,E1,E2}) ->
    "("++ print(E1) ++ "+" ++ print(E2) ++")";
print({mul,E1,E2}) ->
    "("++ print(E1) ++ "*" ++ print(E2) ++")".

%
% parsing
%

% recognise expressions
% deterministic, recursive descent, parser.

% the function returns two things
%   - an expression recognised at the beginning of the string
%     (in fact, the longers such expression)
%   - whatever of the string is left
%
% for example, parse("(-55*eeee)+1111)") is             
%   {{mul,{num,-55},{var,eeee}} , "+1111)"}


% recognise a fully-bracketed expression, with no spaces etc.

-spec parse(string()) -> {expr(), string()}.

parse([$(|Rest]) ->                            % starts with a '('
      {E1,Rest1}     = parse(Rest),            % then an expression
      [Op|Rest2]     = Rest1,                  % then an operator, '+' or '*'
      {E2,Rest3}     = parse(Rest2),           % then another expression
      [$)|RestFinal] = Rest3,                  % starts with a ')'
      {case Op of
	  $+ -> {add,E1,E2};
	  $* -> {mul,E1,E2};
	  $- -> {sub,E1,E2};
	  $/ -> {divide,E1,E2}
        end,
       RestFinal};

% recognise an integer, a sequence of digits
% with an optional '-' sign at the start

parse([Ch|Rest]) when ($0 =< Ch andalso Ch =< $9) orelse Ch==$- ->
    {Succeeds,Remainder} = get_while(fun is_digit/1,Rest),
    {{num, list_to_integer([Ch|Succeeds])}, Remainder};


% recognise a variable: an atom built of small letters only.

parse([Ch|Rest])  when $a =< Ch andalso Ch =< $z ->
    {Succeeds,Remainder} = get_while(fun is_alpha/1,Rest),
    {{var, list_to_atom([Ch|Succeeds])}, Remainder}.
	   
% Takes a line without parenthesis except for ')' at the end.
% Parses the line and returns an expression. 
parse2(Rest) ->
	{E1, Rest1} = parse(Rest),
	NumStack = [E1],
	parse5(Rest1, [], NumStack).


% Base case. Matches when no operators are left in the operator stack and returns
% the single expression which is left in the number stack. 
parse5([$)|T], [], [Result|T]) -> {Result,T};

% Matches when the line has been iterated through and matches on ')'. Uses an 
% operator stack and number stack of expressions to build a single expression.
parse5([$)|T], [Op|OpRest], [E1, E2|NumRest]) -> 
	if
		Op == $+ ->
			NumStack = [{add, E1, E2}|NumRest],
			parse5([$)|T], OpRest, NumStack);
		true -> % Op == $-
			NumStack = [{sub, E2, E1}|NumRest],
			parse5([$)|T], OpRest, NumStack)
	end;
	
	
% Takes in an expression string without parenthesis in the middle and 
% parses it into a stack of operators and stack of expressions. 
parse5([Op|Rest], OpStack, NumStack) ->
	{E2, Rest1} = parse(Rest),
	if 
		Op == $* ->
			[E1|RestNum] = NumStack,
			NumStack2 = [{mul, E1, E2}|RestNum],
			parse5(Rest1, OpStack, NumStack2);
		Op == $/ ->
			[E1|RestNum] = NumStack,
			NumStack2 = [{divide, E1, E2}|RestNum],
			parse5(Rest1, OpStack, NumStack2);
		true -> % Op is addition or substraction
			OpStack2 = [Op|OpStack],
			NumStack2 = [E2|NumStack],
			parse5(Rest1, OpStack2, NumStack2)
	end.
	
% auxiliary functions

% recognise a digit

-spec is_digit(integer()) -> boolean().

is_digit(Ch) ->
    $0 =< Ch andalso Ch =< $9.

% recognise a small letter

-spec is_alpha(integer()) -> boolean().

is_alpha(Ch) ->
    $a =< Ch andalso Ch =< $z.

% the longest initial segment of a list in which all
% elements have property P. Used in parsing integers
% and variables

-spec get_while(fun((T) -> boolean()),[T]) -> {[T],[T]}.    
%-spec get_while(fun((T) -> boolean()),[T]) -> [T].    
			 
get_while(P,[Ch|Rest]) ->
    case P(Ch) of
	true ->
	    {Succeeds,Remainder} = get_while(P,Rest),
	    {[Ch|Succeeds],Remainder};
	false ->
	    {[],[Ch|Rest]}
    end;
get_while(_P,[]) ->
    {[],[]}.

%
% Evaluate an expression
%

% First version commented out.

-spec eval(expr()) -> integer().

eval({num,N}) ->
    N;
eval({add,E1,E2}) ->
    eval(E1) + eval(E2);
eval({mul,E1,E2}) ->
    eval(E1) * eval(E2);
eval({sub,E1,E2}) ->
	eval(E1) - eval(E2);
eval({divide,E1,E2}) ->
	eval(E1) div eval(E2).

-type env() :: [{atom(),integer()}].

-spec eval(env(),expr()) -> integer().

eval(_Env,{num,N}) ->
    N;
eval(Env,{var,A}) ->
    lookup(A,Env);
eval(Env,{add,E1,E2}) ->
    eval(Env,E1) + eval(Env,E2);
eval(Env,{mul,E1,E2}) ->
    eval(Env,E1) * eval(Env,E2);
eval(Env, {sub, E1, E2}) ->
	eval(Env, E1) - eval(Env, E2);
eval(Env, {divide, E1, E2}) ->
	eval(Env, E1) div eval(Env, E2).

%
% Compiler and virtual machine
%
% Instructions
%    {push, N} - push integer N onto the stack
%    {fetch, A} - lookup value of variable a and push the result onto the stack
%    {add2} - pop the top two elements of the stack, add, and push the result
%    {mul2} - pop the top two elements of the stack, multiply, and push the result
%	 [sub2} - pop the top two elements of the stack, subtract, and push the result
%	 {divide2} - pop the top two elements of the stack, divide, and push the result	 

-type instr() :: {'push',integer()}
              |  {'fetch',atom()}
              |  {'add2'}
              |  {'mul2'}
			  |	 {'sub2'}
			  |  {'divide2'}.

-type program() :: [instr()].

% compiler

-spec compile(expr()) -> program().

compile({num,N}) ->
    [{push, N}];
compile({var,A}) ->
    [{fetch, A}];
compile({add,E1,E2}) ->
    compile(E1) ++ compile(E2) ++ [{add2}];
compile({mul,E1,E2}) ->
    compile(E1) ++ compile(E2) ++ [{mul2}];
compile({sub,E1,E2}) ->
	compile(E2) ++ compile(E1) ++ [{sub2}];
compile({divide,E1,E2}) ->
	compile(E2) ++ compile(E1) ++ [{divide2}].

% run a code sequence in given environment and empty stack

-spec run(program(),env()) -> integer().
   
run(Code,Env) ->
    run(Code,Env,[]).

% execute an instruction, and when the code is exhausted,
% return the top of the stack as result.
% classic tail recursion

-type stack() :: [integer()].

-spec run(program(),env(),stack()) -> integer().

run([{push, N} | Continue], Env, Stack) ->
    run(Continue, Env, [N | Stack]);
run([{fetch, A} | Continue], Env, Stack) ->
    run(Continue, Env, [lookup(A,Env) | Stack]);
run([{add2} | Continue], Env, [N1,N2|Stack]) ->
    run(Continue, Env, [(N1+N2) | Stack]);
run([{sub2} | Continue], Env, [N1,N2|Stack]) ->
	run(Continue, Env, [(N1-N2) | Stack]);
run([{mul2} | Continue], Env ,[N1,N2|Stack]) ->
    run(Continue, Env, [(N1*N2) | Stack]);
run([{divide2} | Continue], Env ,[N1,N2|Stack]) ->
	run(Continue, Env, [(N1 div N2) | Stack]);
run([],_Env,[N]) ->
    N.

% compile and run ...
% should be identical to eval(Env,Expr)

-spec execute(env(),expr()) -> integer().
     
execute(Env,Expr) ->
    run(compile(Expr),Env).

%
% Simplify an expression
%

% first version commented out

% simplify({add,E1,{num,0}}) ->
%     E1;
% simplify({add,{num,0},E2}) ->
%     E2;
% simplify({mul,E1,{num,1}}) ->
%     E1;
% simplify({mul,{num,1},E2}) ->
%     E2;
% simplify({mul,_,{num,0}}) ->
%     {num,0};
% simplify({mul,{num,0},_}) ->
%     {num,0}.

% second version commented out

% simplify({add,E1,{num,0}}) ->
%     simplify(E1);
% simplify({add,{num,0},E2}) ->
%     simplify(E2);
% simplify({mul,E1,{num,1}}) ->
%     simplify(E1);
% simplify({mul,{num,1},E2}) ->
%     simplify(E2);
% simplify({mul,_,{num,0}}) ->
%     {num,0};
% simplify({mul,{num,0},_}) ->
%     {num,0};
% simplify(E) ->
%     E.

% -spec simplify(expr()) -> expr().

% simplify({add,E1,{num,0}}) ->
%     simplify(E1);
% simplify({add,{num,0},E2}) ->
%     simplify(E2);
% simplify({mul,E1,{num,1}}) ->
%     simplify(E1);
% simplify({mul,{num,1},E2}) ->
%     simplify(E2);
% simplify({mul,_,{num,0}}) ->
%     {num,0};
% simplify({mul,{num,0},_}) ->
%     {num,0};
% simplify({add,E1,E2}) ->
%     {add,simplify(E1),simplify(E2)};
% simplify({mul,E1,E2}) ->
%     {mul,simplify(E1),simplify(E2)};
% simplify(E) ->
%     E.

% -spec simplify(expr()) -> expr().

% zeroA({add,E1,{num,0}}) ->
%     E1;
% zeroA({add,{num,0},E2}) ->
%     E2;
% zeroA(E) ->
%     E.

% oneM({mul,E1,{num,1}}) ->
%     E1;
% oneM({mul,{num,1},E2}) ->
%     E2;
% oneM(E) ->
%     E.

% zeroM({mul,_,{num,0}}) ->
%     {num,0};
% zeroM({mul,{num,0},_}) ->
%     {num,0};
% zeroM(E) ->
%     E.

% combine([]) ->
%     fun (E) -> E end;
% combine([Rule|Rules]) ->
%     fun (E) -> (combine(Rules))(Rule(E)) end.
 
% rules() ->
%     combine([fun zeroA/1, fun oneM/1, fun zeroM/1]).

% simp(F,{add,E1,E2}) ->
%     F({add,simp(F,E1),simp(F,E2)});
% simp(F,{mul,E1,E2}) ->
%     F({mul,simp(F,E1),simp(F,E2)});
% simp(_F,E) ->
%     E.

% simplify(E) ->
%     simp(rules(),E).



% Auxiliary function: lookup a
% key in a list of key-value pairs.
% Fails if the key not present.

-spec lookup(atom(),env()) -> integer().

lookup(A,[{A,V}|_]) ->
    V;
lookup(A,[_|Rest]) ->
    lookup(A,Rest).

% Test data.

-spec env1() -> env().    
env1() ->
    [{a,23},{b,-12}].

-spec expr1() -> expr().    
expr1() ->
    {add,{var,a},{mul,{num,2},{var,b}}}.

-spec test1() -> integer().    
test1() ->
    eval(env1(),expr1()).

-spec expr2() -> expr().    
expr2() ->
    {add,{mul,{num,1},{var,b}},{mul,{add,{mul,{num,2},{var,b}},{mul,{num,1},{var,b}}},{num,0}}}.

% simplification ...

zeroA({add,E,{num,0}}) ->
    E;
zeroA({add,{num,0},E}) ->
    E;
zeroA(E) ->
    E.

mulO({mul,E,{num,1}}) ->
    E;
mulO({mul,{num,1},E}) ->
    E;
mulO(E) ->
    E.

mulZ({mul,_,{num,0}}) ->
    {num,0};
mulZ({mul,{num,0},_}) ->
    {num,0};
mulZ(E) ->
    E.

compose([]) ->
    fun (E) -> E end;
compose([Rule|Rules]) ->
    fun (E) -> (compose(Rules))(Rule(E)) end.

rules() ->
    [ fun zeroA/1, fun mulO/1, fun mulZ/1].

simp(F,{add,E1,E2}) ->
    F({add,simp(F,E1),simp(F,E2)});
simp(F,{mul,E1,E2}) ->
    F({mul,simp(F,E1),simp(F,E2)});
simp(_F,E) -> E.

simplify(E) ->
    simp(compose(rules()),E).

% Uses evaluation function to process expressions.txt and outputs
% the result to output1.txt file. 
mymain1() ->
	read_text_file("expressions.txt", "output1.txt", 1).
	
% Uses compile-execute to process expressions.txt and outputs 
% the result to output2.txt file. 
mymain2() ->
	read_text_file("expressions.txt", "output2.txt", 2).
	
% Takes in the name of the file to read, output file and a choice
% 1/2 to decide which processing method to use. Opens a connection
% to read a file. 
read_text_file(Filename, OutFilename, Num) ->
    {ok, IoDevice} = file:open(Filename, [read]),
    read_text(IoDevice, OutFilename, Num),
    file:close(IoDevice).

% Takes IoDevice output filename and Num (1/2). Reads a line from a text file,
% processes the line and repeats. 
read_text(IoDevice, OutFilename, Num) ->
    case file:read_line(IoDevice) of
        {ok, Data} -> Data2 = re:replace(Data, "\\s+", "", [global,{return,list}]),
					  write_text_file(OutFilename, Data2, Num),
                      read_text(IoDevice, OutFilename, Num);
        eof        -> ok
    end.
	
% Opens a connection to an output file. Takes in a line to process. Takes
% in a num (1/2). 
write_text_file(OutFilename, Line, Num) ->
	{ok, IoDevice} = file:open(OutFilename, [append]),
	write_text(IoDevice, Line, Num),
	file:close(IoDevice).

% Takes in a line. Processes it and writes the result to a text file. 
write_text(IoDevice, Line, Num) ->
	[$(|T] = Line,
	Choice = choose(T),
	if 
		Choice == 1 ->
			{Ex, _} = parse(Line);
		true -> % Else Choice = 2 
			{Ex, _} = parse2(T)
	end,
	Env = [{a, 5}, {b, 7}], 
	if 
		Num == 1 ->
			Result = assign9:eval(Env, Ex);
		true -> % Num == 2
			Result = assign9:execute(Env, Ex)
	end,
	Result2 = integer_to_list(Result),
	LineSep = io_lib:nl(),
	file:write(IoDevice, Result2),
	file:write(IoDevice, LineSep).

% Base case. Returns 2 for 2nd parsing method if no parenthesis found
% in line. 	
choose([]) -> 2;
	
% Takes in line without '(' at start.
% Checks rest of text for '(' to see which parsing method to choose. 
% If '(' is found it means that the expression uses parenthesis and
% a 1 is returned. Otherwise a 2 is returned to signify it doesn't uses
% parenthesis. 
choose([H|T]) ->
	if 
		H == $( ->
			1;
		true -> % Else recursive clause to keep searching
			choose(T)
	end.
	