%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%union {
    float number;
    char identifier[1024];
}

%token <number> NUMBER;
%token <identifier> IDENTIFIER;
%token <identifier> LT GT LE GE EQ NE;
%token <identifier> LS RS;

%token INITIALIZE_ROBOT MOVE_FORWARD MOVE_BACKWARD TURN_LEFT TURN_RIGHT;
%token START_CLEANING STOP_CLEANING RETURN_TO_BASE CHECK_BATTERY REPORT_STATUS;
%token PAUSE RESUME SET_SPEED SET_CLEANING_MODE DETECT_OBSTACLE;
%token <identifier> IF THEN ELSE;

%token CLEANING_MODE_NORMAL CLEANING_MODE_DEEP CLEANING_MODE_QUICK;

%type <identifier> str oper if_stmt;
%type <identifier> cleaning_mode;
%type <identifier> expr;
%type <identifier> func_call;
%%

program: str {
    printf("#include \"robot.h\"\n\n"); /* headers */
    printf("int main(int argc, char const *argv[])\n{\n\t%s\n\treturn 0;\n}\n", $1); /* entrypoint */
}

str: oper       { sprintf($$, "%s", $1); } /* singleline */
    | oper str  { sprintf($$, "%s\n\t%s", $1, $2); }  /* multiline */
    | if_stmt   { sprintf($$, "%s", $1); } /* if statement */
    | if_stmt str  { sprintf($$, "%s\n%s", $1, $2); }
    ;

oper: INITIALIZE_ROBOT NUMBER	                  { sprintf($$, "robot_t *R%d = initialize_robot(%d);", (int)$2, (int)$2); }
    | MOVE_FORWARD IDENTIFIER NUMBER              { sprintf($$, "move_forward(%s, %.2f);", $2, $3); }
    | MOVE_BACKWARD IDENTIFIER NUMBER             { sprintf($$, "move_backward(%s, %.2f);", $2, $3); }
    | TURN_LEFT IDENTIFIER NUMBER                 { sprintf($$, "turn_left(%s, %.2f);", $2, $3); }
    | TURN_RIGHT IDENTIFIER NUMBER                { sprintf($$, "turn_right(%s, %.2f);", $2, $3); }
    | START_CLEANING IDENTIFIER                   { sprintf($$, "start_cleaning(%s);", $2); }
    | STOP_CLEANING IDENTIFIER                    { sprintf($$, "stop_cleaning(%s);", $2); }
    | RETURN_TO_BASE IDENTIFIER                   { sprintf($$, "return_to_base(%s);", $2); }
    | CHECK_BATTERY IDENTIFIER                    { sprintf($$, "check_battery(%s);", $2); }
    | REPORT_STATUS IDENTIFIER                    { sprintf($$, "report_status(%s);", $2); }
    | PAUSE IDENTIFIER                            { sprintf($$, "pause(%s);", $2); }
    | RESUME IDENTIFIER                           { sprintf($$, "resume(%s);", $2); }
    | SET_SPEED IDENTIFIER NUMBER                 { sprintf($$, "set_speed(%s, %.2f);", $2, $3); }
    | SET_CLEANING_MODE IDENTIFIER cleaning_mode  { sprintf($$, "set_cleaning_mode(%s, %s);", $2, $3); }
    | DETECT_OBSTACLE IDENTIFIER                  { sprintf($$, "detect_obstacle(%s);", $2); }
    ;

if_stmt: IF LS expr RS THEN LS str RS ELSE LS str RS { sprintf($$, "if (%s) {\n\t%s\n} else {\n\t%s\n}", $3, $7, $11);}
    | IF expr THEN str { sprintf($$, "if (%s) {\n\t%s\n}", $2, $4);}
    ;

expr: func_call LT NUMBER { sprintf($$, "%s < %.2f", $1, $3); }
    | func_call GT NUMBER { sprintf($$, "%s > %.2f", $1, $3); }
    | func_call LE NUMBER { sprintf($$, "%s <= %.2f", $1, $3); }
    | func_call GE NUMBER { sprintf($$, "%s >= %.2f", $1, $3); }
    ;

func_call: CHECK_BATTERY IDENTIFIER { sprintf($$, "check_battery(%s)", $2); }
    ;

cleaning_mode: CLEANING_MODE_NORMAL    { sprintf($$, "CLEANING_MODE_NORMAL"); }
    | CLEANING_MODE_DEEP               { sprintf($$, "CLEANING_MODE_DEEP"); }
    | CLEANING_MODE_QUICK              { sprintf($$, "CLEANING_MODE_QUICK"); }
    ;

%%

void yyerror(char* s)
{
    printf("Error: %s.\n", s);
}

int main(int argc, char *argv[])
{
    yyparse();
    return 0;
}
