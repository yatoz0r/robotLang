# Курсовая работа по Системному программированию

## 1. Выбор целевой платформы
Целевая платформа: Unix-подобная ОС с компилятором GCC. Язык программирования будет транслироваться в язык C.

## 2. Разработка языка программирования
Язык предоставляет команды для управления роботом-уборщиком.

Команды:
1. `INITIALIZE [number]` - Инициализация робота с заданным идентификатором.
2. `MOVE_FORWARD [robot_id] [distance]` - Движение вперед на заданное расстояние.
3. `MOVE_BACKWARD [robot_id] [distance]` - Движение назад на заданное расстояние.
4. `TURN_LEFT [robot_id] [angle]` - Поворот налево на заданный угол.
5. `TURN_RIGHT [robot_id] [angle]` - Поворот направо на заданный угол.
6. `START_CLEANING [robot_id]` - Начало уборки.
7. `STOP_CLEANING [robot_id]` - Остановка уборки.
8. `RETURN_TO_BASE [robot_id]` - Возврат на базу для зарядки.
9. `CHECK_BATTERY [robot_id]` - Проверка уровня заряда батареи.
10. `REPORT_STATUS [robot_id]` - Отчет о текущем состоянии робота (включая координаты, уровень заряда и статус уборки).
11. `PAUSE [robot_id]` - Пауза в работе робота.
12. `RESUME [robot_id]` - Возобновление работы робота.
13. `SET_SPEED [robot_id] [speed]` - Установка скорости движения робота.
14. `SET_CLEANING_MODE [robot_id] [mode]` - Установка режима уборки (normal, deep, или quick).
15. `IF (expr) THEN {} ELSE {}` - Условные операторы.
    
`robot_id` – идентификатор робота.
`distance` – расстояние (в метрах).
`angle` – угол (в градусах).
`speed` – скорость (в метрах секунду).
`expr` - условие.

## 3. Ручная трансляция под целевую платформу
Для примера ручной трансляции языка была написана следующая программа:
```txt
initialize_robot 5
move_forward R5 2.5
turn_left R5 90
start_cleaning R5
move_forward R5 3.0
check_battery R5
report_status R5
return_to_base R5 
```

Ниже представлен код, транслированный на язык C:
```C
// manual.c
#include "robot.h"

int main(int argc, char const *argv[])
{
        robot_t *R5 = initialize_robot(5);
        move_forward(R5, 2.50);
        turn_left(R5, 90.00);
        start_cleaning(R5);
        move_forward(R5, 3.00);
        check_battery(R5);
        report_status(R5);
        return_to_base(R5);
        return 0;
} 
```

```C
#ifndef ROBOT_H
#define ROBOT_H

#include <stdio.h>
#include <stdlib.h>

typedef enum _robot_status
{
    ROBOT_STATUS_IDLE,
    ROBOT_STATUS_CLEANING,
    ROBOT_STATUS_PAUSED,
    ROBOT_STATUS_RETURNING,
} robot_status_t;

typedef enum _cleaning_mode
{
    CLEANING_MODE_NORMAL,
    CLEANING_MODE_DEEP,
    CLEANING_MODE_QUICK,
} cleaning_mode_t;

typedef struct _robot
{
    int id;
    robot_status_t status;
    cleaning_mode_t mode;
    float battery_level;
    float speed;
    float x_coord;
    float y_coord;
    float angle;
} robot_t;

robot_t *initialize_robot(int id);
int move_forward(robot_t *robot, float distance);
int move_backward(robot_t *robot, float distance);
int turn_left(robot_t *robot, float angle);
int turn_right(robot_t *robot, float angle);
int start_cleaning(robot_t *robot);
int stop_cleaning(robot_t *robot);
int return_to_base(robot_t *robot);
int check_battery(robot_t *robot);
int report_status(robot_t *robot);
int pause(robot_t *robot);
int resume(robot_t *robot);
int set_speed(robot_t *robot, float speed);
int set_cleaning_mode(robot_t *robot, cleaning_mode_t mode);
void set_speed_based_on_mode(robot_t *robot);
int detect_obstacle(robot_t *robot);

#endif // ROBOT_H
```

## 4. Разработка лексического анализатора
Для разработанного языка был написан лексический анализатор:

```lex
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
"turn_left" { return TURN_LEFT; } "turn_right" { return TURN_RIGHT; }
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
```

## 5. Разработка грамматики синтаксического разбора

TODO

## 6. Разработка синтаксического анализатора
```yyac
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

oper: INITIALIZE_ROBOT NUMBER                     { sprintf($$, "robot_t *R%d = initialize_robot(%d);", (int)$2, (int)$2); }
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
```

## 7. Компиляция компилятора
```bash
rm -rf build
bison -d -o build/robot.tab.c robot.y
lex -o build/lex.yy.c robot.l
```

## 8. Компилирование программы на своем языке
```bash
build/robot_compiler < test.txt > test.c
```

## 9. Запуск программы
```bash 
gcc test.c robot.c -o test -lm
./test ( или make test)
Robot 5 initialized.
Robot 5 moving forward by 2.50 meters.
Robot 5 turning left by 90.00 degrees. New angle: 90.00 degrees.
Robot 5 started cleaning.
Robot 5 moving forward by 3.00 meters.
Robot 5 battery level: 99.45%
Robot 5 status report:
1. Status: Cleaning
2. Cleaning Mode: Normal
3. Battery Level: 99.45%
4. Speed: 0.50 m/s
5. Coordinates: (2.50, 3.00)
6. Angle: 90.00 degrees
```

## 10. Makefile
```Makefile
CC = gcc
CFLAGS = -O2 -Wall -Wno-implicit -Wno-return-type -Wno-unused-function

LEX = lex
BISON = bison

# Output directory (for .gitignore)
OUTPUT_DIR = build

# Compile manual
MANUAL_OUTPUT = ${OUTPUT_DIR}/manual
MANUAL_SOURCES = manual.c

# Compile lex
LEX_OUTPUT = ${OUTPUT_DIR}/lex.yy.c
LEX_SOURCES = robot.l

# Compile bison
BISON_OUTPUT = ${OUTPUT_DIR}/robot.tab.c
BISON_OUTPUT_HEADER = ${OUTPUT_DIR}/robot.tab.h
BISON_SOURCES = robot.y

# Compile compiler
COMPILER_OUTPUT = ${OUTPUT_DIR}/robot_compiler
COMPILER_SOURCES = ${LEX_OUTPUT} ${BISON_OUTPUT}

.PHONY: all lex test clean

all: clean lex

lex: ${BISON_OUTPUT} ${LEX_OUTPUT} ${COMPILER_OUTPUT}

${MANUAL_OUTPUT}: ${MANUAL_SOURCES}
        @mkdir -p ${OUTPUT_DIR}
        ${CC} $^ -o $@ ${CFLAGS}

${BISON_OUTPUT}: ${BISON_SOURCES}
        @mkdir -p ${OUTPUT_DIR}
        ${BISON} -d -o $@ $^

${LEX_OUTPUT}: ${LEX_SOURCES}
        @mkdir -p ${OUTPUT_DIR}
        ${LEX} -o $@ $^

${COMPILER_OUTPUT}: ${COMPILER_SOURCES}
        @${CC} $^ -lfl -o $@ ${CFLAGS}
        @rm -f ${BISON_OUTPUT_HEADER}
test: ${COMPILER_OUTPUT}
        @${COMPILER_OUTPUT} < test.txt > test.c
        @${CC} test.c robot.c -o test
        @./test
        @rm -f test.c test

clean:
rm -rf ${OUTPUT_DIR}
```
