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
