# Resume — Michael Lehn

- 📄 **[Software Engineering Resume](resume_public.pdf)**

## Building

The resume is generated from `resume.tex` with LuaLaTeX:

```sh
make            # builds resume.pdf and resume_public.pdf
```

`resume_public.pdf` is the same document without the phone number
(`\PublicVersion`). The phone number lives in `private.tex`, which is not
committed (it defines `\PrivatePhone`); the private `resume.pdf` refuses to build
without it. The layout reproduces the original Pages document: Arial
(or the metric-compatible Arimo if Arial is not installed), and first-fit line
breaking as in Pages (`firstfit.lua`). The Makefile builds with a fixed
`SOURCE_DATE_EPOCH` so that rebuilt PDFs are reproducible.

Cover letters are private application documents and are not committed
(see `.gitignore`); `make letters` builds them locally.
