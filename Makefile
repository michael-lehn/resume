# Build the resume PDFs with LuaLaTeX and a fixed timestamp (reproducible)
export SOURCE_DATE_EPOCH = 1792800000
export FORCE_SOURCE_DATE = 1

LUALATEX = lualatex -interaction=nonstopmode -halt-on-error

.PHONY: all clean

all: resume.pdf resume_public.pdf

resume.pdf: resume.tex firstfit.lua
	$(LUALATEX) resume.tex
	$(LUALATEX) resume.tex

resume_public.pdf: resume.tex firstfit.lua
	$(LUALATEX) -jobname=resume_public '\def\PublicVersion{}\input{resume}'
	$(LUALATEX) -jobname=resume_public '\def\PublicVersion{}\input{resume}'

clean:
	rm -f *.aux *.log *.out
