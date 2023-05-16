 /*SETUP*/
%{
	#include <stdio.h>
    #include <math.h>
    #define YYSTPE double
	
	void yyerror(char *s);
	int yylex();
    double zmienne['z' - 'a'];
	
%}
 /*DEFINICJE*/
%union 
{
    double dtype;
    char ctype;
}
%verbose 

%token  <dtype>LICZBA
%token  <ctype>ZNAK
%type   <dtype>program
%type   <dtype>wyrazenie

%left '+' '-'
%left '*' '/'
%right '^'
%left NEG
	
%%
 /*BIZON*/
program: program wyrazenie '\n'     { printf("Wynik = %lf\n\n", $2); }
    |
    ;
wyrazenie: LICZBA               { $$ = $1; }
    | ZNAK                      { $$ = zmienne[$1 - 'a']; }
    | ZNAK '=' wyrazenie        { $$ = $3; zmienne[$1 - 'a'] = $3; }
    | ZNAK '=' ZNAK             { $$ = $3; zmienne[$1 - 'a'] = zmienne[$3 - 'a']; }
    | ZNAK '+' ZNAK             { $$ = zmienne[$1 - 'a'] + zmienne[$3 - 'a']; }
    | ZNAK '-' ZNAK             { $$ = zmienne[$1 - 'a'] - zmienne[$3 - 'a']; }
    | ZNAK '*' ZNAK             { $$ = zmienne[$1 - 'a'] * zmienne[$3 - 'a']; }
    | ZNAK '/' ZNAK             { if(zmienne[$3 - 'a'] != 0)$$ = zmienne[$1 - 'a'] / (zmienne[$3 - 'a']*1.0); else yyerror("dzielenie przez zero!"); }
    | ZNAK '^' ZNAK             { $$ = pow(zmienne[$1 - 'a'], zmienne[$3 - 'a']); }
    | '{' ZNAK '}'              { $$ = $2; }
    | '-' ZNAK %prec NEG        { $$ = -$2; }
    | wyrazenie '+' wyrazenie   { $$ = $1 + $3; }
    | wyrazenie '-' wyrazenie   { $$ = $1 - $3; }
    | wyrazenie '*' wyrazenie   { $$ = $1 * $3; }
    | wyrazenie '/' wyrazenie   { if($3 != 0)$$ = $1 / $3; else yyerror("dzielenie przez zero!"); }
    | wyrazenie '^' wyrazenie   { $$ = pow($1, $3); }
    | '{' wyrazenie '}'         { $$ = $2; }
    | '-' wyrazenie %prec NEG   { $$ = -$2; }
    |
    ; 
%%

void yyerror(char *s) 
{
    fprintf(stderr, "%s\n", s);
}

int main() 
{
    yyparse();    
    return 0;
}