# Comparative-Programming-Languages
Projects from TCSS 480 Comparative Programming Languages

Expressions: Parses, evaluates and executes expressions using Erlang. 

Takes in a file, "expressions.txt", containing expressions of the form-
(2*(3+4))
(2 * ( 3 + 4 ))
(2 * 3 + 4)
(3 + 4 * 2)
(10 - 5)
(10 / 5)
(2 + 10 / 2)
(2 - 10 / 2)
(2 * 3 - 4 + 8 / 2)
(a - b)
(a + 1 + b)
(b + 14 - 1 + a)

Parses the expressions into the form 
{sub, {mul, {add, {num, 3}, {num, 1}}, {num, 3}}, {divide, {num, 6}, {num, 3}}}, ""} == assign9:parse("(((3+1)*3)-(6/3))").

{{mul, {add, {num, 3}, {num, 1}}, {divide, {num, 3}, {num, 3}}}, ""} == assign9:parse2("(3+1*3/3)").

2 Different parsing algorithms depending on whether Exp Op Exp are grouped by parenthesis or not. 
- Parenthesized expressions: Recursive descent
- Non Parenthesized: 2 stacks, 1 for numbers and 1 for operators

Evaluation
Expressions are defined as Number Op Number or Number or Variable. Evaluation is done by recursively
breaking down expressions till they reach the simplest form {num, N} so that N can be returned as an 
int and evaluated. 

Web Crawler:
Takes in a set of initial URLs and begins processing web pages. Crawls until all links are exhausted 
or 100 pages are processed. Outputs a csv file showing the crawl space with pages and links 
associated to them. Includes additional information that specifies the web page with the highest
number of links pointing to it. 
