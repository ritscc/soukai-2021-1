PLATEX = platex
DVIPDFMX = dvipdfmx

PDF_READER = evince

TARGET = document
OUTPUT_DIR = build
BUILDED_TARGET = $(OUTPUT_DIR)/$(TARGET)

all: $(BUILDED_TARGET).dvi

pdf: $(BUILDED_TARGET).pdf

$(BUILDED_TARGET).dvi: $(TARGET).tex
	mkdir -p $(OUTPUT_DIR)
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

