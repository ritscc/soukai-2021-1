PLATEX = platex
DVIPDFMX = dvipdfmx

TARGET = document
OUTPUT_DIR = build
BUILDED_TARGET = $(OUTPUT_DIR)/$(TARGET)

BRANCH = HEAD
SUBMODULE_BRANCH = master

YEAR = $(shell cat README.md | head -n 1 | sed -e 's/^\([0-9]*\).*/\1/')
TEST_TARGET = $(shell ls src/*/?kai.tex src/hajimeni.tex) $(shell tools/auto_input.sh show)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
# for Linux

  PDF_READER = evince
endif
ifeq ($(UNAME_S),Darwin)
# for MacOSX

  PDF_READER = open
endif

all: $(BUILDED_TARGET).dvi

pdf: $(BUILDED_TARGET).pdf

git:
	@git checkout $(BRANCH) > /dev/null

	@git submodule init > /dev/null
	@git submodule update > /dev/null
	@git submodule foreach 'git checkout $(SUBMODULE_BRANCH)' > /dev/null

$(BUILDED_TARGET).dvi: $(TARGET).tex git
	mkdir -p $(OUTPUT_DIR)
	ruby tools/auto_input.rb
	$(PLATEX) -interaction=nonstopmode -output-directory=$(OUTPUT_DIR) $(TARGET).tex
	$(PLATEX) -interaction=nonstopmode -output-directory=$(OUTPUT_DIR) $(TARGET).tex

$(BUILDED_TARGET).pdf: $(BUILDED_TARGET).dvi
	$(DVIPDFMX) -o $(BUILDED_TARGET).pdf $(BUILDED_TARGET).dvi

allclean: clean
	cd $(OUTPUT_DIR) && rm -rf $(TARGET).pdf

clean:
	cd $(OUTPUT_DIR) && rm -rf *.dvi *.log *.aux *.toc

open: $(BUILDED_TARGET).pdf
	$(PDF_READER) $(BUILDED_TARGET).pdf &

test: git
	@mkdir -p $(OUTPUT_DIR)
	@tools/auto_input.sh
	@$(PLATEX) -interaction=nonstopmode -output-directory=$(OUTPUT_DIR) $(TARGET).tex > /dev/null || (ruby tools/filter-error.rb $(BUILDED_TARGET).log && false)
	@echo $(TEST_TARGET) | YEAR=$(YEAR) xargs ruby ta9boh/ta9boh.rb $(OPTION)
