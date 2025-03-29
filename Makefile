
TARGET := rune

build:
	@py ./scripts/build-debug.py win $(TARGET)

clean:
	@py ./scripts/clean.py