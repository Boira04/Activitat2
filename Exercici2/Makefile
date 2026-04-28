CC     = gcc
CFLAGS = -Wall -g

all: cp1

cp1.tab.c cp1.tab.h: cp1.y
	bison -d cp1.y

lex.yy.c: cp1.l cp1.tab.h
	flex cp1.l

cp1: lex.yy.c cp1.tab.c cp1.tab.h
	$(CC) $(CFLAGS) -o cp1 lex.yy.c cp1.tab.c

clean:
	rm -f cp1 lex.yy.c cp1.tab.c cp1.tab.h

test: cp1
	./cp1 < test.txt

.PHONY: all clean test
