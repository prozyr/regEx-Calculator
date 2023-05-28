


 /*SETUP*/
%option noyywrap

%{
   #include <stdlib.h> 
   #include <iostream>
	#include "parser.tab.h"
   #define MAX 100            /*Wczytywanie plików tekstowych*/
   YY_BUFFER_STATE stos[MAX]; /*Wczytywanie plików tekstowych*/
   int nBufor = 0;            /*Wczytywanie plików tekstowych*/
%}

%x INCLUDE 

%%
 /*WYRAŻENIA REGULARNE*/
"min"                   { return MIN; }
"max"                   { return MAX; }
"mean"                  { return MEAN; }
"median"                { return MEDIAN; }
"include"               { BEGIN(INCLUDE); }  /*Wczytywanie plików tekstowych*/
[0-9]+"."[0-9]+         { yylval.dtype = strtod(yytext,NULL); return LICZBA; }
[0-9]+                  { yylval.dtype = (double)atoi(yytext); return LICZBA; }
[a-z]                   { yylval.ctype = yytext[0]; return ZNAK; }
"-"                     { return '-'; }
[+*/()=^,]              { return yytext[0]; }
[\n]                    { return '\n'; }
.                       {  }
<INCLUDE>{  /*Wczytywanie plików tekstowych*/
[\t]* ; /*Omijaj tabulacje*/
[a-z0-9]+"."[a-z]{3} {
   stos[nBufor++] = YY_CURRENT_BUFFER;
   yyin = fopen(yytext, "r");
   yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
   BEGIN(INITIAL);
   }
}
<<EOF>>  {  /*Wczytywanie plików tekstowych*/
   if(nBufor == 0) {
      yyterminate();
   } else {
      yy_delete_buffer(YY_CURRENT_BUFFER);
      yy_switch_to_buffer(stos[--nBufor]);
   }
}
%%