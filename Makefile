# Build the resume PDFs with LuaLaTeX and a fixed timestamp (reproducible)
export SOURCE_DATE_EPOCH = 1792800000
export FORCE_SOURCE_DATE = 1

LUALATEX = lualatex -interaction=nonstopmode -halt-on-error

# Cover letters (cover_letter_<name>.tex) are private and not committed;
# build them with 'make letters'
LETTERS = $(filter-out %_public.tex,$(wildcard cover_letter_*.tex))

.PHONY: all letters clean

all: resume.pdf resume_public.pdf

letters: $(LETTERS:.tex=.pdf) $(LETTERS:.tex=_public.pdf)

# Private versions (with phone number) need private.tex, which is not committed
resume.pdf: resume.tex firstfit.lua private.tex
	$(LUALATEX) resume.tex
	$(LUALATEX) resume.tex

resume_public.pdf: resume.tex firstfit.lua
	$(LUALATEX) -jobname=resume_public '\def\PublicVersion{}\input{resume}'
	$(LUALATEX) -jobname=resume_public '\def\PublicVersion{}\input{resume}'

# The public rule comes first, so that it is chosen for *_public.pdf
cover_letter_%_public.pdf: cover_letter_%.tex firstfit.lua uulm-logo.png
	$(LUALATEX) -jobname=cover_letter_$*_public '\def\PublicVersion{}\input{cover_letter_$*}'
	$(LUALATEX) -jobname=cover_letter_$*_public '\def\PublicVersion{}\input{cover_letter_$*}'

cover_letter_%.pdf: cover_letter_%.tex firstfit.lua uulm-logo.png private.tex
	$(LUALATEX) cover_letter_$*.tex
	$(LUALATEX) cover_letter_$*.tex

clean:
	rm -f *.aux *.log *.out
