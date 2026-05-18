load "pdflib.ring"

items = [
    ["Description", "Qty", "Price", "Total"],
    ["Web Design", "1", "$2,500", "$2,500"],
    ["Hosting (Annual)", "1", "$300", "$300"],
    ["Domain Name", "2", "$15", "$30"]
]

? "Generate File: " + substr(filename(),".ring",".pdf")

new PDFWriter() {
	setTitle("Invoice #1001")
	setFont(PDF_HELVETICA_BOLD, 28)
	setTextColor("navy")
	drawText("INVOICE", 72, 760)
	setFont(PDF_HELVETICA, 12)
	setTextColor("gray")
	drawTextRight("#INV-1001", 540, 760)
	drawTextRight("Date: 2025-01-15", 540, 740)
	drawTable(items, 72, 650, [250, 60, 80, 78], [
    		:headerBg = "navy",
    		:headerFg = "white"
	])
	setFont(PDF_HELVETICA_BOLD, 14)
	setTextColor("black")
	drawTextRight("Total: $2,830.00", 540, 540)
	save("invoice.pdf")
}

? "Done..."