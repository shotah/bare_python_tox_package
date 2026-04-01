# Consumer demo: installs hello-world-package from GitHub (requirements.txt).
# From this directory: make install && make run
# From repo root:      make example-install && make example-run

PYTHON ?= python
.DEFAULT_GOAL := help

ifeq ($(OS),Windows_NT)
SHELL := cmd.exe
.SHELLFLAGS := /C

.PHONY: help
help: ## Show targets
	@echo.
	@echo Example — install from GitHub, run demo
	@echo ========================================
	@echo   make install     Create .venv and pip install -r requirements.txt
	@echo   make run         Run demo.py (run install first)
	@echo   make clean       Remove .venv
	@echo.

.PHONY: install
install: ## Create venv and install deps from requirements.txt
	@if not exist .venv $(PYTHON) -m venv .venv
	@.venv\Scripts\python.exe -m pip install --upgrade pip -q
	@.venv\Scripts\python.exe -m pip install -r requirements.txt
	@echo Done. Run: make run

.PHONY: run
run: ## Run demo.py using .venv
	@if not exist .venv\Scripts\python.exe (echo Run make install first. & exit /b 1)
	@.venv\Scripts\python.exe demo.py

.PHONY: clean
clean: ## Remove local .venv
	@if exist .venv rmdir /s /q .venv

else

SHELL := /bin/bash

VENV_PY := .venv/bin/python

.PHONY: help
help: ## Show targets
	@echo ""
	@echo "Example — install from GitHub, run demo"
	@echo "========================================"
	@echo "  make install     Create .venv and pip install -r requirements.txt"
	@echo "  make run         Run demo.py (run install first)"
	@echo "  make clean       Remove .venv"
	@echo ""

.PHONY: install
install: ## Create venv and install deps from requirements.txt
	@if [ ! -d .venv ]; then $(PYTHON) -m venv .venv; fi
	@"$(VENV_PY)" -m pip install --upgrade pip -q
	@"$(VENV_PY)" -m pip install -r requirements.txt
	@echo "Done. Run: make run"

.PHONY: run
run: ## Run demo.py using .venv
	@test -f "$(VENV_PY)" || { echo "Run make install first."; exit 1; }
	@"$(VENV_PY)" demo.py

.PHONY: clean
clean: ## Remove local .venv
	rm -rf .venv

endif
