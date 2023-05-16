


 /*SETUP*/
%option noyywrap

%{
   #include <stdlib.h> 
   #include <iostream>
	#include "parser.tab.h"
%}

%%
 /*WYRAŻENIA REGULARNE*/
[0-9]+         { yylval.dtype = (double)atoi(yytext); return LICZBA; }
[a-z]          { yylval.ctype = yytext[0]; return ZNAK; }
"-"            return '-';
[+*/()=^]         return yytext[0];
[\n]           return '\n';

%%