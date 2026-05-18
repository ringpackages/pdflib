load "pdflib.ring"

func main

	cFileName = substr(filename(),".ring",".pdf")
	? "Generate File: " + cFileName

	quickPDF(cFileName, "My Document", [
		[:title = "Page 1", :body = "Content for page 1..."],
		[:title = "Page 2", :body = "Content for page 2..."]
	])

	? "Done..."