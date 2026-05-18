load "pdflib.ring"

new PDFWriter() {
	setTitle("My First PDF")
	setFont(PDF_HELVETICA_BOLD, 24)
	drawText("Hello, World!", 72, 700)
	save("hello.pdf")
}