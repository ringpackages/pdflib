load "pdflib.ring"

func main

	cFileName = substr(filename(),".ring",".pdf")
	? "Generate File: " + cFileName

	new PDFWriter() {
		setTitle("Image Gallery")
		drawImage("images/test2.jpg", 72, 560, 200, 150)
		drawImage("images/test1.png", 300, 560, 120, 120)
		drawImage("images/test3.bmp", 72, 380, 180, 140)
		save(cFileName)
	}

	? "Done..."