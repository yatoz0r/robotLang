# Курсовая работа по Системному программированию

## 1. Выбор целевой платформы
Целевая платформа: Unix-подобная ОС с компилятором GCC. Язык программирования будет транслироваться в язык C.

## 2. Разработка языка программирования
Язык предоставляет команды для упрощения создания, хранения и применения рецептов (алгоритмов) приготовления чая.

Команды:
1. `PREPARE_CUP [cup_id] [size]` - подготовка кружки заданного размера (`small`, `medium`, или `large`).
2. `ADD_WATER [cup_id] [N]` - добавление `N` мл кипятка.
3. `BREW_TEA [cup_id] [type]` - заваривание чая типа `type` (`green`, `black`, или `pink`).
4. `ADD_SUGAR [cup_id] [N]` - добавление `N` чайных ложек сахара.
5. `ADD_HONEY [cup_id] [N]` - добавление `N` чайных ложек мёда.
6. `ADD_MILK [cup_id] [N]` - добавление `N` мл молока.
7. `ADD_LEMON [cup_id] [N]` - добавление `N` долек лимона.
8. `SERVE [cup_id]` - подать чай (вывести свойства чая).
9. `EMPTY_CUP [cup_id]` - опустошить кружку.

`cup_id` - идентификатор кружки.

## 3. Ручная трансляция под целевую платформу
Для примера ручной трансляции языка была написана следующая программа:
```txt
prepare_cup cup1 small
add_water cup1 50
brew_tea cup1 pink
add_honey cup1 2
serve cup1
empty_cup cup1
```

Ниже представлен код, транслированный на язык C:
```C
// manual.c
#include "stie.h"

int main()
{
    cup_t *someCup = prepare_cup(CUP_SIZE_SMALL);
    add_water(someCup, 50);
    brew_tea(someCup, TEA_TYPE_PINK);
    add_honey(someCup, 2);
    serve(someCup);
    empty_cup(someCup);
    return 0;
}
```

```C
// stie.h
#ifndef STIE_H
#define STIE_H

#include <stdio.h>
#include <stdlib.h>

typedef enum _cup_size
{
    CUP_SIZE_SMALL,
    CUP_SIZE_MEDIUM,
    CUP_SIZE_LARGE,
} cup_size_t;

typedef enum _tea_type
{
    TEA_TYPE_GREEN,
    TEA_TYPE_BLACK,
    TEA_TYPE_PINK,
} tea_type_t;

typedef struct _cup
{
    cup_size_t size;
    tea_type_t type;

    int water;
    int sugar;
    int honey;
    int milk;
    int lemon;
} cup_t;

cup_t *prepare_cup(cup_size_t size);
int add_water(cup_t *cup, int value);
int brew_tea(cup_t *cup, tea_type_t value);
int add_sugar(cup_t *cup, int value);
int add_honey(cup_t *cup, int value);
int add_milk(cup_t *cup, int value);
int add_lemon(cup_t *cup, int value);
int empty_cup(cup_t *cup);
int serve(cup_t *cup);

#endif
```

## 4. Разработка лексического анализатора
Для разработанного языка был написан лексический анализатор:

```lex
%{
#include <stdio.h>
#include <stdlib.h>

#include "stie.tab.h"
%}

%%
"prepare_cup" { return PREPARE_CUP; }
"add_water" { return ADD_WATER; }
"brew_tea" { return BREW_TEA; }
"add_sugar" { return ADD_SUGAR; }
"add_honey" { return ADD_HONEY; }
"add_milk" { return ADD_MILK; }
"add_lemon" { return ADD_LEMON; }
"serve" { return SERVE; }
"empty_cup" { return EMPTY_CUP; }

"small" { return CUP_SIZE_SMALL; }
"medium" { return CUP_SIZE_MEDIUM; }
"large" { return CUP_SIZE_LARGE; }

"black" { return TEA_TYPE_BLACK; }
"green" { return TEA_TYPE_GREEN; }
"pink" { return TEA_TYPE_PINK; }


[0-9]+ {
    yylval.number = atoi(yytext);
    return NUMBER;
}

[a-zA-Z][a-zA-Z0-9]* {
    strcpy(yylval.identifier, yytext);
    return IDENTIFIER;
}

[ \n\t]+ { /* Skip */ }
%%
```

## 5. Разработка грамматики синтаксического разбора

TODO

## 6. Разработка синтаксического анализатора
```yyac
%{
#include <stdio.h>
%}

%union {
    int number;
    char identifier[1024];
}

%token <number> NUMBER;
%token <identifier> IDENTIFIER;

%token PREPARE_CUP ADD_WATER BREW_TEA;
%token ADD_SUGAR ADD_HONEY ADD_MILK;
%token ADD_LEMON SERVE EMPTY_CUP;

%token CUP_SIZE_SMALL CUP_SIZE_MEDIUM CUP_SIZE_LARGE;
%token TEA_TYPE_BLACK TEA_TYPE_GREEN TEA_TYPE_PINK;

%type <identifier> str oper tea_size tea_type;

%%

program: str {
    printf("#include \"stie.h\"\n\n"); /* headers */
    printf("int main(int argc, char const *argv[])\n{\n\t%s\n\treturn 0;\n}\n", $1); /* entrypoint */
}

str: oper       { sprintf($$, "%s", $1); } /* singleline */
    | oper str  { sprintf($$, "%s\n\t%s", $1, $2); }  /* multiline */
    ;

oper: PREPARE_CUP IDENTIFIER tea_size       { sprintf($$, "cup_t *%s = prepare_cup(%s);", $2, $3); }
    | ADD_WATER IDENTIFIER NUMBER           { sprintf($$, "add_water(%s, %d);", $2, $3); }
    | BREW_TEA IDENTIFIER tea_type          { sprintf($$, "brew_tea(%s, %s);", $2, $3); }
    | ADD_SUGAR IDENTIFIER NUMBER           { sprintf($$, "add_sugar(%s, %d);", $2, $3); }
    | ADD_HONEY IDENTIFIER NUMBER           { sprintf($$, "add_honey(%s, %d);", $2, $3); }
    | ADD_MILK IDENTIFIER  NUMBER           { sprintf($$, "add_milk(%s, %d);", $2, $3); }
    | ADD_LEMON IDENTIFIER NUMBER           { sprintf($$, "add_lemon(%s, %d);", $2, $3); }
    | SERVE IDENTIFIER                      { sprintf($$, "serve(%s);", $2); }
    | EMPTY_CUP IDENTIFIER                  { sprintf($$, "empty_cup(%s);", $2); }
    ;

tea_size: CUP_SIZE_SMALL    { sprintf($$, "CUP_SIZE_SMALL"); }
    | CUP_SIZE_MEDIUM       { sprintf($$, "CUP_SIZE_MEDIUM"); }
    | CUP_SIZE_LARGE        { sprintf($$, "CUP_SIZE_LARGE"); }
    ;

tea_type: TEA_TYPE_BLACK    { sprintf($$, "TEA_TYPE_BLACK"); }
    | TEA_TYPE_GREEN        { sprintf($$, "TEA_TYPE_GREEN"); }
    | TEA_TYPE_PINK         { sprintf($$, "TEA_TYPE_PINK"); }
    ;
%%

yyerror(char* s)
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
mkdir -p build
bison -d -o build/stie.tab.c stie.y
lex -o build/lex.yy.c stie.l
clang-18 build/lex.yy.c build/stie.tab.c -lfl -o build/stie_compiler -Wno-implicit
```

## 8. Компилирование программы на своем языке
```bash
build/stie_compiler < test.txt > test.c
```

## 9. Запуск программы
```bash 
clang-18 test.c stie.c -o test
./test
Preparing a small cup...
Adding 50 ml of water...
Brewing pink tea...
Adding 2 teaspoons of honey...
Serving tea!
1. Cup size: small
2. Water: 50 ml
3. Tea type: pink
4. Sugar: 0 teaspoons
5. Honey: 2 teaspoons
6. Milk: 0 ml
7. Lemon: 0 slices
Cup is empty now.
```

## 10. Makefile
```Makefile
CC = clang-18
CFLAGS = -O2 -Wall -Wno-implicit -Wno-return-type -Wno-unused-function

LEX = lex
BISON = bison

# output directory (for .gitignore)
OUTPUT_DIR = build

# compile manual
MANUAL_OUTPUT = ${OUTPUT_DIR}/manual
MANUAL_SOURCES = manual.c

# compile lex
LEX_OUTPUT = ${OUTPUT_DIR}/lex.yy.c
LEX_SOURCES = stie.l

# compile bison
BISON_OUTPUT = ${OUTPUT_DIR}/stie.tab.c
BISON_OUTPUT_HEADER = ${OUTPUT_DIR}/stie.tab.h
BISON_SOURCES = stie.y

# compile compiler
COMPILER_OUTPUT = ${OUTPUT_DIR}/stie_compiler
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
	@rm -f ${COMPILER_SOURCES} ${BISON_OUTPUT_HEADER}

test: ${COMPILER_OUTPUT}
	@$^ < test.txt > test.c
	@${CC} test.c stie.c -o test
	@./test
	@rm -f test.c test

clean:
	rm -rf ${OUTPUT_DIR}
```
