# paperless-ocrmypdf

Docker compose recipe for The Paperless Project + OCRmyPDF

# How it works

This is a file-based workflow, organized in a bunch of folders inside "scans"

- PDFs to be OCRed are put into "in"

- inotify-based script picks them up and passes them to OCRmyPDF

- OCRmyPDF does its job, temporary creating files in "ocr"

- Once file is processed, the original is moved from "in" to "archive", and OCRed document is put into "ocr-ed"

- Paperless picks it up from "ocr-ed" and moves it into "documents"

If you have PDFs that do not need OCR, inject them in the middle of this pipeline by putting them in "ocr-ed"

# Configuration

Move "config" and "scans" folders somewhere on your filesystem.

Change paths in .env to point to the locations of "config" and "scans"

If you need extra languages, configure them in docker-compose.yml and modify Dockerfile to install them into ocrmypdf container.

Run "docker-compose up -d" and navigate to http://localhost:8000 to configure Paperless.
