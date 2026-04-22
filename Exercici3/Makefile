# Nom de l'executable
TARGET = traductor

all: $(TARGET)

$(TARGET): $(TARGET).l $(TARGET).y
	# Generar l'analitzador sintàctic (Bison)
	bison -d $(TARGET).y
	# Generar l'analitzador lèxic (Flex)
	flex $(TARGET).l
	# Compilar-ho tot amb GCC
	gcc -o $(TARGET) $(TARGET).tab.c lex.yy.c -lfl

clean:
	rm -f $(TARGET) lex.yy.c $(TARGET).tab.c $(TARGET).tab.h