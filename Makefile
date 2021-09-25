SRC=jGuidebook.366.tex
PDF=jguidebook.366.pdf
HTML=jguidebook.366.html
TMPPDF=jGuidebook.366.pdf

all: docs/$(HTML) docs/$(PDF)

docs/$(HTML): $(SRC)
	perl tex2html.pl

$(TMPPDF): $(SRC)
	ptex2pdf -l -od "-p a4" $(SRC)

docs/$(PDF): $(TMPPDF)
	cp $(TMPPDF) docs/$(PDF)

# uncommented jguidebook
jg.uc.tex:
	perl uncomment.pl $(SRC) > jg.uc.tex
