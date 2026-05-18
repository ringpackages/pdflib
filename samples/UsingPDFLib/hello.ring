load "pdflib.ring"

func main

	cFileName = substr(filename(),".ring",".pdf")
	? "Generate File: " + cFileName

	new PDFWriter() {
		setTitle("My First PDF")
		setFont(PDF_HELVETICA_BOLD, 24)
		drawText("Hello, World!", 72, 700)
		save(cFileName)
	}

	? "Done..."