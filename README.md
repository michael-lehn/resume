# Resume — Michael Lehn

- 📄 **[Software Engineering Resume](resume_public.pdf)**
- ✉️ **[Cover Letter — D-Wave Quantum, Senior Scientific Software Developer](cover_letter_dwave_public.pdf)**

## Building

The resume is generated from `resume.tex` with LuaLaTeX:

```sh
make            # builds the resume and cover letter PDFs
```

`resume_public.pdf` is the same document without the phone number
(`\PublicVersion`). The phone number lives in `private.tex`, which is not
committed (it defines `\PrivatePhone`); the private versions `resume.pdf` and
`cover_letter_dwave.pdf` refuse to build without it. The layout reproduces the original Pages document: Arial
(or the metric-compatible Arimo if Arial is not installed), and first-fit line
breaking as in Pages (`firstfit.lua`). The Makefile builds with a fixed
`SOURCE_DATE_EPOCH` so that rebuilt PDFs are reproducible.

`cover_letter_dwave.tex` reproduces the design of the Pages cover letter
(A4, Ulm University letterhead `uulm-logo.png`, fold marks, Arial, justified
text with hyphenation). `cover_letter_dwave_public.pdf` omits the phone number;
the version with the phone number (`cover_letter_dwave.pdf`) is built locally
and not committed.
