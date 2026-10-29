# Build the resume and cover letter PDFs with LuaLaTeX and a fixed timestamp (reproducible)
export SOURCE_DATE_EPOCH = 1792800000
export FORCE_SOURCE_DATE = 1

LUALATEX = lualatex -interaction=nonstopmode -halt-on-error

.PHONY: all clean

all: resume.pdf resume_public.pdf cover_letter_dwave.pdf cover_letter_dwave_public.pdf

resume.pdf: resume.tex firstfit.lua
	$(LUALATEX) resume.tex
	$(LUALATEX) resume.tex

resume_public.pdf: resume.tex firstfit.lua
	$(LUALATEX) -jobname=resume_public '\def\PublicVersion{}\input{resume}'
	$(LUALATEX) -jobname=resume_public '\def\PublicVersion{}\input{resume}'

cover_letter_dwave.pdf: cover_letter_dwave.tex firstfit.lua uulm-logo.png
	$(LUALATEX) cover_letter_dwave.tex
	$(LUALATEX) cover_letter_dwave.tex

cover_letter_dwave_public.pdf: cover_letter_dwave.tex firstfit.lua uulm-logo.png
	$(LUALATEX) -jobname=cover_letter_dwave_public '\def\PublicVersion{}\input{cover_letter_dwave}'
	$(LUALATEX) -jobname=cover_letter_dwave_public '\def\PublicVersion{}\input{cover_letter_dwave}'

clean:
	rm -f *.aux *.log *.out
