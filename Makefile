# ============================================================
# Makefile for Electronics I Project Report
# Ubuntu / Debian
# ============================================================

TEXFILE := report.tex
PDF     := $(TEXFILE:.tex=.pdf)
LATEX   := pdflatex

# Ubuntu packages that provide the required LaTeX packages
# (tcolorbox, tikz/pgfplots, libertinus, newtxmath, subcaption, etc.)
DEBS    := texlive-latex-base \
           texlive-latex-extra \
           texlive-fonts-recommended \
           texlive-fonts-extra \
           texlive-pictures

# Packages used in the document (filename.sty form)
PKGS    := libertinus.sty newtxmath.sty tcolorbox.sty pgfplots.sty \
           tikz.sty booktabs.sty caption.sty enumitem.sty fancyhdr.sty \
           titlesec.sty wrapfig.sty subcaption.sty multicol.sty \
           amsmath.sty amssymb.sty xcolor.sty hyperref.sty

.PHONY: all check install build clean help

# Default target
all: check build

help:
	@echo "Usage:"
	@echo "  make check    - Verify dependencies"
	@echo "  make install  - Install missing packages via apt (requires sudo)"
	@echo "  make build    - Compile $(TEXFILE) to PDF"
	@echo "  make all      - Run check + build"
	@echo "  make clean    - Remove auxiliary files"

# ----------------------------------------------------------
# 1. Check for pdflatex and required .sty files
# ----------------------------------------------------------
check:
	@echo "==> Checking for $(LATEX)..."
	@command -v $(LATEX) >/dev/null 2>&1 || { \
		echo "ERROR: $(LATEX) not found."; \
		echo "Run 'make install' to install dependencies."; \
		exit 1; \
	}
	@echo "==> Checking LaTeX packages..."
	@MISSING=0; \
	for pkg in $(PKGS); do \
		kpsewhich $$pkg >/dev/null 2>&1 || { \
			echo "  MISSING: $$pkg"; \
			MISSING=1; \
		}; \
	done; \
	if [ $$MISSING -eq 1 ]; then \
		echo; \
		echo "Some packages are missing. Run 'make install'."; \
		exit 1; \
	fi
	@echo "All dependencies satisfied."

# ----------------------------------------------------------
# 2. Install dependencies via apt
# ----------------------------------------------------------
install:
	@if ! command -v apt-get >/dev/null 2>&1; then \
		echo "ERROR: apt-get not found. This target is for Ubuntu/Debian only."; \
		exit 1; \
	fi
	@echo "==> Updating package list..."
	sudo apt-get update
	@echo "==> Installing LaTeX packages..."
	sudo apt-get install -y $(DEBS)
	@echo "==> Installation complete."

# ----------------------------------------------------------
# 3. Build the PDF
# ----------------------------------------------------------
build: $(PDF)

$(PDF): $(TEXFILE)
	@echo "==> First pass..."
	$(LATEX) -interaction=nonstopmode -halt-on-error $(TEXFILE)
	@echo "==> Second pass (for TOC / references)..."
	$(LATEX) -interaction=nonstopmode -halt-on-error $(TEXFILE)
	@echo "==> Done: $(PDF)"

# ----------------------------------------------------------
# 4. Cleanup
# ----------------------------------------------------------
clean:
	rm -f *.aux *.log *.out *.toc *.synctex.gz \
	      *.fdb_latexmk *.fls *.bbl *.blg
	@echo "Cleaned auxiliary files."
