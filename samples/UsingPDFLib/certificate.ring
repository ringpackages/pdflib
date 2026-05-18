load "pdflib.ring"

func main

	cFileName = substr(filename(),".ring",".pdf")
	? "Generate File: " + cFileName

	new PDFWriter() {
		setOrientation(PDF_LANDSCAPE)
		setStrokeColor("gold")
		setLineWidth(4)
		drawRect(30, 30, 781, 531)
		setFont(PDF_TIMES_BOLD, 36)
		setTextColor("navy")
		drawTextCentered("Certificate of Achievement", 420, 460)
		setFont(PDF_TIMES_ITALIC, 24)
		setTextColor("black")
		drawTextCentered("Jane Smith", 420, 350)
		setFont(PDF_TIMES, 14)
		drawTextCentered("For outstanding contributions to the team", 420, 300)
		save(cFileName)
	}

? "Done..."