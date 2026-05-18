load "pdflib.ring"

? "Generate File: " + substr(filename(),".ring",".pdf")

quickPDF("quick.pdf", "My Document", [
    [:title = "Page 1", :body = "Content for page 1..."],
    [:title = "Page 2", :body = "Content for page 2..."]
])

? "Done..."