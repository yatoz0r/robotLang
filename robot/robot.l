%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "robot.tab.h"
%}

%%
"initialize_robot" { return INITIALIZE_ROBOT; }
"move_forward" { return MOVE_FORWARD; }
"move_backward" { return MOVE_BACKWARD; }
"turn_left" { return TURN_LEFT; }
"turn_right" { return TURN_RIGHT; }
"start_cleaning" { return START_CLEANING; }
"stop_cleaning" { return STOP_CLEANING; }
"return_to_base" { return RETURN_TO_BASE; }
"check_battery" { return CHECK_BATTERY; }
"report_status" { return REPORT_STATUS; }
"pause" { return PAUSE; }
"resume" { return RESUME; }
"set_speed" { return SET_SPEED; }
"set_cleaning_mode" { return SET_CLEANING_MODE; }
"detect_obstacle" { return DETECT_OBSTACLE; }

"if" { return IF; }
"then" { return THEN; }
"else" { return ELSE; }

"<" { return LT; }
">" { return GT; }
"<=" { return LE; }
">=" { return GE; }
"==" { return EQ; }
"!=" { return NE; }

"normal" { return CLEANING_MODE_NORMAL; }
"deep" { return CLEANING_MODE_DEEP; }
"quick" { return CLEANING_MODE_QUICK; }

[0-9]+(\.[0-9]+)? {
    yylval.number = atof(yytext);
    return NUMBER;
}

[a-zA-Z][a-zA-Z0-9]* {
    strcpy(yylval.identifier, yytext);
    return IDENTIFIER;
}

[ \n\t]+ { /* Skip */ }
%%

int yywrap() {
    return 1;
}
