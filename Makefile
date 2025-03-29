
TARGET := rune

build:
	@py ./scripts/build.py win $(TARGET)

clean:
	@py ./scripts/clean.py