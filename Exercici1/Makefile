CC      = gcc
CFLAGS  = -Wall -g
LIBS    = -lm

all: calc

calc.tab.c calc.tab.h: calc.y
	bison -d calc.y

lex.yy.c: calc.l calc.tab.h
	flex calc.l

calc: lex.yy.c calc.tab.c calc.tab.h
	$(CC) $(CFLAGS) -o calc lex.yy.c calc.tab.c $(LIBS)

clean:
	rm -f calc lex.yy.c calc.tab.c calc.tab.h

test: calc
	./calc < exemple.txt

.PHONY: all clean test
