EXEC = cleaner
FASMARCHIVE = fasm-1.71.22.tgz
FASMURL = "http://flatassembler.net/$(FASMARCHIVE)"

SOURCE = cleaner.asm
OUTPUT = cleaner

all: configure $(EXEC)
.PHONY: configure install-fasm
configure: install-fasm
install-fasm:
	@echo "INSTALL fasm"
	@wget $(FASMURL) 2> /dev/null
	@tar xf "$(FASMARCHIVE)"
	@rm "$(FASMARCHIVE)"
 $(EXEC): configure
	@echo "FASM $(OUTPUT)"
	@./fasm/fasm $(SOURCE)
	@rm -rf fasm
