


 /*SETUP*/
%option noyywrap

%{
   #include <stdlib.h> 
   #include <iostream>
	#include "parser.tab.h"
%}

%x SUM
%x SUB
%x DIV
%X MUL

%%
 /*WYRAŻENIA REGULARNE*/
"sum"          BEGIN(SUM);
"sub"          BEGIN(SUB);
"div"          BEGIN(DIV);
"mul"          BEGIN(MUL);
[0-9]+"."[0-9]+         { yylval.dtype = strtod(yytext,NULL); return LICZBA; }
[a-z]                   { yylval.ctype = yytext[0]; return ZNAK; }
"-"                     { return '-'; }
[+*/()=^]               { return yytext[0]; }
[\n]                    { return '\n'; }

<SUM>{
[]
}
%%