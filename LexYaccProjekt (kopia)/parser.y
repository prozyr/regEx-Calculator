 /*SETUP*/
%{
	#include <stdio.h>
    #include <math.h>
    #define YYSTPE double

    double buffer[100];
    int pt_buffer = 0;
	
	void yyerror(char *s);
	int yylex();
    int licznik = 0;
    double zmienne['z' - 'a'];

    bool sem = 0;
	
%}
 /*DEFINICJE*/
%union 
{
    double dtype;
    char ctype;
}
%verbose 

%token  MIN MAX MEAN MEDIAN

%token  <dtype>LICZBA
%token  <ctype>ZNAK
%type   <dtype>program
%type   <dtype>wyrazenie
%type   <dtype>param_min
%type   <dtype>param_max
%type   <dtype>param_mean
%type   <dtype>param_median

%left '+' '-'
%left '*' '/'
%right '^'
%left NEG
	
%%
 /*BIZON*/
program: program wyrazenie '\n'     { if(!sem)printf("Wynik = %lf\n\n", $2);else sem=0; }
    | error                         { yyerrok; }
    |
    ;
wyrazenie: LICZBA                   { $$ = $1; }
    | ZNAK                          { $$ = zmienne[$1 - 'a']; }
    | ZNAK '=' wyrazenie            { $$ = $3; zmienne[$1 - 'a'] = $3; }
    | ZNAK '=' ZNAK                 { $$ = $3; zmienne[$1 - 'a'] = zmienne[$3 - 'a']; }
    | ZNAK '+' ZNAK                 { $$ = zmienne[$1 - 'a'] + zmienne[$3 - 'a']; }
    | ZNAK '-' ZNAK                 { $$ = zmienne[$1 - 'a'] - zmienne[$3 - 'a']; }
    | ZNAK '*' ZNAK                 { $$ = zmienne[$1 - 'a'] * zmienne[$3 - 'a']; }
    | ZNAK '/' ZNAK                 { if(zmienne[$3 - 'a'] != 0)$$ = zmienne[$1 - 'a'] / (zmienne[$3 - 'a']*1.0); else { yyerror("dzielenie przez zero!");
                                                                                                                         printf("%d %d %d %d",
                                                                                                                                @3.first_line, 
                                                                                                                                @3.first_column,
                                                                                                                                @3.last_line, 
                                                                                                                                @3.last_column);                                                                                                                      
                                                                                                                        } 
                                    }
    | ZNAK '^' ZNAK                 { $$ = pow(zmienne[$1 - 'a'], zmienne[$3 - 'a']); }
    | '{' ZNAK '}'                  { $$ = $2; }
    | '-' ZNAK %prec NEG            { $$ = -$2; }
    | wyrazenie '+' wyrazenie       { $$ = $1 + $3; }
    | wyrazenie '-' wyrazenie       { $$ = $1 - $3; }
    | wyrazenie '*' wyrazenie       { $$ = $1 * $3; }
    | wyrazenie '/' wyrazenie       { if($3 != 0)$$ = $1 / $3; else { yyerror("dzielenie przez zero!"); 
                                                                        printf("%d %d %d %d",
                                                                                @3.first_line, 
                                                                                @3.first_column,
                                                                                @3.last_line, 
                                                                                @3.last_column);
                                                                    } 
                                    }
    | wyrazenie '^' wyrazenie       { $$ = pow($1, $3); }
    | '{' wyrazenie '}'             { $$ = $2; }
    | '-' wyrazenie %prec NEG       { $$ = -$2; }
    | MIN '(' param_min ')'         { $$ = $3; }
    | MAX '(' param_max ')'         { $$ = $3; }
    | MEAN '(' param_mean ')'       { $$ = $3/licznik; licznik = 0; }
    | MEDIAN '(' param_median ')'   { for(int i = 0; i < pt_buffer ; i++) { 
                                            for(int j = 0; j < pt_buffer-1 ; j++) {
                                                if(buffer[j] > buffer[j+1]) { 
                                                    int kopia = buffer[j+1]; buffer[j+1] = buffer[j]; buffer[j] = kopia; 
                                                } 
                                            } 
                                        }
                                        if(pt_buffer%2 == 0) {
                                            $$ = buffer[(pt_buffer/2)]; 
                                        } else { 
                                            $$ = (buffer[int(pt_buffer/2)] + buffer[int(pt_buffer/2)+1])/2.0;
                                            pt_buffer = 0; }                                    
                                    }
    |
    ;
param_min: LICZBA                   { $$ = $1; }
    | param_min ',' LICZBA          { $$ = $1 < $3 ? $1 : $3; }
    |
    ; 
param_max: LICZBA                   { $$ = $1; }
    | param_max ',' LICZBA          { $$ = $1 > $3 ? $1 : $3; }
    |
    ;
param_mean: LICZBA                  { licznik++; $$ = $1; }
    | param_mean ',' LICZBA         { licznik++; $$ = $1 + $3; }
    |
    ;
param_median: LICZBA                { buffer[0] = $1; pt_buffer = 0; }
    | param_median ',' LICZBA       { buffer[pt_buffer++] = $3; }
    |
    ;
%%

void yyerror(char *s) {
    sem = 1;
    fprintf(stderr, "ERROR: %s\n", s);
}

int main() {
    yyparse();    
    return 0;
}