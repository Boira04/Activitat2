TARGET = primers

all: $(TARGET)

$(TARGET): $(TARGET).l $(TARGET).y
	bison -d $(TARGET).y
	flex $(TARGET).l
	gcc -o $(TARGET) $(TARGET).tab.c lex.yy.c -lfl

clean:
	rm -f $(TARGET) lex.yy.c $(TARGET).tab.c $(TARGET).tab.h
