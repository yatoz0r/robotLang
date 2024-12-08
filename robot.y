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

%token INITIALIZE_ROBOT MOVE_FORWARD MOVE_BACKWARD TURN_LEFT TURN_RIGHT;
%token START_CLEANING STOP_CLEANING RETURN_TO_BASE CHECK_BATTERY REPORT_STATUS;
%token PAUSE RESUME SET_SPEED SET_CLEANING_MODE DETECT_OBSTACLE;

%token CLEANING_MODE_NORMAL CLEANING_MODE_DEEP CLEANING_MODE_QUICK;

%type <identifier> str oper;
%type <identifier> cleaning_mode;

%%

program: str {
    printf("#include \"robot.h\"\n\n"); /* headers */
    printf("int main(int argc, char const *argv[])\n{\n\t%s\n\treturn 0;\n}\n", $1); /* entrypoint */
}

str: oper       { sprintf($$, "%s", $1); } /* singleline */
    | oper str  { sprintf($$, "%s\n\t%s", $1, $2); }  /* multiline */
    ;

oper: INITIALIZE_ROBOT NUMBER                 	  { sprintf($$, "robot_t *R%d = initialize_robot(%d);", (int)$2, (int)$2); }
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
