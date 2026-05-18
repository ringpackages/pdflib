/*
    PDFLib Demo - PDF Generation in Ring
    ====================================
    Demonstrates all features of PDFLib
*/

load "pdflib.ring"

func main

    ? "=============================================="
    ? "   PDFLib Demo - PDF Generation in Ring"
    ? "=============================================="
    ? ""

    # ------------------------------------------------------------------
    # Demo 1: Hello World
    # ------------------------------------------------------------------
    ? "Demo 1: Hello World..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Hello World")
    pdfDoc.setAuthor("RingPDFLib Demo")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 36)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Hello, PDF World!", 72, 700)

    pdfDoc.setFont(PDF_HELVETICA, 14)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("This PDF was generated using RingPDFLib.", 72, 660)
    pdfDoc.drawText("A pure Ring implementation with no dependencies.", 72, 640)

    if pdfDoc.save("demo1_hello.pdf")
        ? "  Created: demo1_hello.pdf"
    else
        ? "  FAILED: demo1_hello.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 2: Text and Fonts
    # ------------------------------------------------------------------
    ? "Demo 2: Text and fonts..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Font Showcase")

    curY = 750

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Font Showcase", 72, curY)
    curY -= 40

    # Helvetica family
    pdfDoc.setFont(PDF_HELVETICA, 14)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Helvetica Normal - The quick brown fox jumps.", 72, curY)
    curY -= 22

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.drawText("Helvetica Bold - The quick brown fox jumps.", 72, curY)
    curY -= 22

    pdfDoc.setFont(PDF_HELVETICA_ITALIC, 14)
    pdfDoc.drawText("Helvetica Italic - The quick brown fox jumps.", 72, curY)
    curY -= 22

    pdfDoc.setFont(PDF_HELVETICA_BOLDITALIC, 14)
    pdfDoc.drawText("Helvetica Bold Italic - The quick brown fox jumps.", 72, curY)
    curY -= 35

    # Times family
    pdfDoc.setFont(PDF_TIMES, 14)
    pdfDoc.drawText("Times Roman - The quick brown fox jumps.", 72, curY)
    curY -= 22

    pdfDoc.setFont(PDF_TIMES_BOLD, 14)
    pdfDoc.drawText("Times Bold - The quick brown fox jumps.", 72, curY)
    curY -= 22

    pdfDoc.setFont(PDF_TIMES_ITALIC, 14)
    pdfDoc.drawText("Times Italic - The quick brown fox jumps.", 72, curY)
    curY -= 35

    # Courier family
    pdfDoc.setFont(PDF_COURIER, 14)
    pdfDoc.drawText("Courier - The quick brown fox jumps.", 72, curY)
    curY -= 22

    pdfDoc.setFont(PDF_COURIER_BOLD, 14)
    pdfDoc.drawText("Courier Bold - The quick brown fox jumps.", 72, curY)
    curY -= 35

    # Font sizes
    pdfDoc.setFont(PDF_HELVETICA, 8)
    pdfDoc.drawText("8pt - Small text", 72, curY)
    curY -= 15

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.drawText("12pt - Normal text", 72, curY)
    curY -= 20

    pdfDoc.setFont(PDF_HELVETICA, 18)
    pdfDoc.drawText("18pt - Large text", 72, curY)
    curY -= 28

    pdfDoc.setFont(PDF_HELVETICA, 24)
    pdfDoc.drawText("24pt - Extra large text", 72, curY)
    curY -= 40

    # Colors
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 16)
    pdfDoc.setTextColor("red")
    pdfDoc.drawText("Red Text", 72, curY)

    pdfDoc.setTextColor("green")
    pdfDoc.drawText("Green Text", 220, curY)

    pdfDoc.setTextColor("blue")
    pdfDoc.drawText("Blue Text", 380, curY)
    curY -= 25

    pdfDoc.setTextColor("orange")
    pdfDoc.drawText("Orange", 72, curY)

    pdfDoc.setTextColor("purple")
    pdfDoc.drawText("Purple", 200, curY)

    pdfDoc.setTextColor("#FF6347")
    pdfDoc.drawText("Hex Color", 330, curY)

    if pdfDoc.save("demo2_fonts.pdf")
        ? "  Created: demo2_fonts.pdf"
    else
        ? "  FAILED: demo2_fonts.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 3: Paragraphs and Text Alignment
    # ------------------------------------------------------------------
    ? "Demo 3: Paragraphs and alignment..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Paragraphs and Alignment")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Paragraphs & Alignment", 72, 750)

    # Wrapped paragraph
    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Left-Aligned Paragraph:", 72, 710)

    loremText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."

    curY = pdfDoc.drawParagraph(loremText, 72, 690, 468, 16)
    curY -= 20

    # Center-aligned
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 12)
    pdfDoc.drawText("Center-Aligned Paragraph:", 72, curY)
    curY -= 20

    curY = pdfDoc.drawParagraphAligned("This text is centered. It demonstrates paragraph alignment in RingPDFLib. Each line is centered within the specified width.", 72, curY, 468, 16, PDF_ALIGN_CENTER)
    curY -= 20

    # Right-aligned
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 12)
    pdfDoc.drawText("Right-Aligned Paragraph:", 72, curY)
    curY -= 20

    curY = pdfDoc.drawParagraphAligned("This text is right-aligned. Each line is pushed to the right edge of the specified width.", 72, curY, 468, 16, PDF_ALIGN_RIGHT)

    if pdfDoc.save("demo3_paragraphs.pdf")
        ? "  Created: demo3_paragraphs.pdf"
    else
        ? "  FAILED: demo3_paragraphs.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 4: Shapes and Drawing
    # ------------------------------------------------------------------
    ? "Demo 4: Shapes and drawing..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Shapes and Drawing")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Shapes & Drawing", 72, 750)

    # Rectangles
    pdfDoc.setFont(PDF_HELVETICA, 11)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Rectangles:", 72, 710)

    pdfDoc.setStrokeColor("black")
    pdfDoc.setLineWidth(1)
    pdfDoc.drawRect(72, 660, 100, 40)

    pdfDoc.setFillColor("steelblue")
    pdfDoc.setStrokeColor("navy")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawFilledRect(190, 660, 100, 40)

    pdfDoc.setFillColor("coral")
    pdfDoc.drawFilledRectNoStroke(310, 660, 100, 40)

    # Circles
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Circles:", 72, 635)

    pdfDoc.setStrokeColor("black")
    pdfDoc.setLineWidth(1)
    pdfDoc.drawCircle(120, 585, 30)

    pdfDoc.setFillColor("green")
    pdfDoc.setStrokeColor("darkgreen")
    pdfDoc.drawFilledCircle(230, 585, 30)

    pdfDoc.setFillColor("gold")
    pdfDoc.setStrokeColor("orange")
    pdfDoc.drawFilledCircle(340, 585, 30)

    # Ellipses
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Ellipses:", 72, 535)

    pdfDoc.setStrokeColor("purple")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawEllipse(130, 490, 60, 30)

    pdfDoc.setFillColor("pink")
    pdfDoc.setStrokeColor("crimson")
    pdfDoc.drawFilledEllipse(290, 490, 50, 25)

    # Lines
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Lines:", 72, 440)

    pdfDoc.setStrokeColor("red")
    pdfDoc.setLineWidth(1)
    pdfDoc.drawLine(72, 425, 250, 425)

    pdfDoc.setStrokeColor("blue")
    pdfDoc.setLineWidth(3)
    pdfDoc.drawLine(72, 410, 250, 410)

    pdfDoc.setStrokeColor("green")
    pdfDoc.setLineWidth(1)
    pdfDoc.setDash([5, 3], 0)
    pdfDoc.drawLine(72, 395, 250, 395)

    pdfDoc.setStrokeColor("orange")
    pdfDoc.setDash([10, 5, 3, 5], 0)
    pdfDoc.drawLine(72, 380, 250, 380)

    pdfDoc.resetDash()

    # Horizontal rule
    pdfDoc.setStrokeColor("gray")
    pdfDoc.setLineWidth(0.5)
    pdfDoc.drawHorizontalRule(72, 350, 468)

    # Polygon
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Polygon:", 72, 330)
    pdfDoc.setFillColor("teal")
    pdfDoc.setStrokeColor("darkblue")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawPolygon([[100, 260], [150, 310], [130, 260], [170, 290], [80, 290]])

    if pdfDoc.save("demo4_shapes.pdf")
        ? "  Created: demo4_shapes.pdf"
    else
        ? "  FAILED: demo4_shapes.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 5: Tables
    # ------------------------------------------------------------------
    ? "Demo 5: Tables..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Tables")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Table Examples", 72, 750)

    # Simple table
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Employee Table:", 72, 710)

    tableData = [
        ["Name", "Department", "Salary", "Location"],
        ["John Smith", "Engineering", "$95,000", "New York"],
        ["Alice Brown", "Marketing", "$82,000", "Chicago"],
        ["Bob Wilson", "Sales", "$78,000", "Austin"],
        ["Carol Davis", "Engineering", "$91,000", "Seattle"],
        ["Dave Miller", "HR", "$75,000", "Boston"]
    ]

    colWidths = [130, 120, 100, 118]

    curY = pdfDoc.drawTable(tableData, 72, 695, colWidths, [
        :headerBg = "steelblue",
        :headerFg = "white",
        :evenRowBg = [230, 240, 250],
        :rowHeight = 22,
        :fontSize = 10
    ])

    curY -= 30

    # Another table with different styling
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Product Inventory:", 72, curY)
    curY -= 15

    productData = [
        ["Product", "SKU", "Stock", "Price"],
        ["Widget A", "WDG-001", "150", "$12.99"],
        ["Gadget B", "GDG-002", "85", "$24.50"],
        ["Tool C", "TL-003", "200", "$8.75"],
        ["Part D", "PT-004", "42", "$45.00"]
    ]

    curY = pdfDoc.drawTable(productData, 72, curY, [130, 110, 100, 128], [
        :headerBg = "darkgreen",
        :headerFg = "white",
        :evenRowBg = [220, 240, 220],
        :rowHeight = 20,
        :fontSize = 10
    ])

    curY -= 30

    # Auto-width table
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.drawText("Auto-Width Table:", 72, curY)
    curY -= 15

    simpleData = [
        ["Day", "Temp", "Weather"],
        ["Monday", "72F", "Sunny"],
        ["Tuesday", "68F", "Cloudy"],
        ["Wednesday", "75F", "Sunny"],
        ["Thursday", "61F", "Rain"]
    ]

    curY = pdfDoc.drawSimpleTable(simpleData, 72, curY, 400, [
        :headerBg = "crimson",
        :fontSize = 10
    ])

    if pdfDoc.save("demo5_tables.pdf")
        ? "  Created: demo5_tables.pdf"
    else
        ? "  FAILED: demo5_tables.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 6: Lists
    # ------------------------------------------------------------------
    ? "Demo 6: Lists..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Lists")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Bullet & Numbered Lists", 72, 750)

    # Bullet list
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Features of RingPDFLib:", 72, 710)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    curY = pdfDoc.drawBulletList([
        "Pure Ring implementation",
        "No external dependencies needed",
        "Multiple page support",
        "14 built-in fonts",
        "Text formatting and alignment",
        "Shapes: rectangles, circles, ellipses",
        "Tables with headers and styling",
        "Charts: bar and pie",
        "Page numbers and headers/footers"
    ], 90, 685, 20)

    curY -= 25

    # Numbered list
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.drawText("Steps to Create a PDF:", 72, curY)
    curY -= 20

    pdfDoc.setFont(PDF_HELVETICA, 12)
    curY = pdfDoc.drawNumberedList([
        "Load the ringpdflib.ring library",
        "Create a new PDFWriter object",
        "Set document properties (title, author)",
        "Add content: text, shapes, tables",
        "Save the document to a file",
        "Open the PDF in any viewer"
    ], 90, curY, 20)

    if pdfDoc.save("demo6_lists.pdf")
        ? "  Created: demo6_lists.pdf"
    else
        ? "  FAILED: demo6_lists.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 7: Multiple Pages
    # ------------------------------------------------------------------
    ? "Demo 7: Multiple pages..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Multi-Page Document")
    pdfDoc.setAuthor("RingPDFLib")

    # Page 1 - Title page
    pdfDoc.setFillColor([41, 98, 255])
    pdfDoc.drawFilledRectNoStroke(0, 0, 595.28, 841.89)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 48)
    pdfDoc.setTextColor("white")
    pdfDoc.drawTextCentered("Annual Report", 297.64, 500)

    pdfDoc.setFont(PDF_HELVETICA, 24)
    pdfDoc.drawTextCentered("2026 Edition", 297.64, 450)

    pdfDoc.setFont(PDF_HELVETICA, 16)
    pdfDoc.drawTextCentered("Ring Programming Language", 297.64, 350)

    # Page 2 - Content
    pdfDoc.addPage()
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 28)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Executive Summary", 72, 750)

    pdfDoc.setStrokeColor("navy")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 740, 400, 740)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.setTextColor("black")
    pdfDoc.drawParagraph("This document demonstrates the multi-page capability of RingPDFLib. Each page can have its own content, including text, shapes, tables, and charts. The library handles page management automatically.", 72, 710, 468, 16)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 18)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Key Highlights", 72, 620)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.setTextColor("black")
    pdfDoc.drawBulletList([
        "Revenue grew 24% year-over-year",
        "Customer base expanded to 50,000+",
        "Launched 3 new product lines",
        "Opened offices in 5 new cities"
    ], 90, 595, 20)

    # Page 3 - Chart page
    pdfDoc.addPage()
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 28)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Financial Overview", 72, 750)

    pdfDoc.setStrokeColor("navy")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 740, 400, 740)

    chartData = [
        :labels = ["Q1", "Q2", "Q3", "Q4"],
        :values = [320, 450, 520, 680]
    ]

    pdfDoc.drawBarChart(chartData, 72, 450, 400, 250, [
        :title = "Quarterly Revenue ($K)",
        :showValues = true
    ])

    if pdfDoc.save("demo7_multipage.pdf")
        ? "  Created: demo7_multipage.pdf"
    else
        ? "  FAILED: demo7_multipage.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 8: Page Numbers and Headers/Footers
    # ------------------------------------------------------------------
    ? "Demo 8: Page numbers and headers/footers..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Headers and Footers")

    pdfDoc.enablePageNumbers()
    pdfDoc.setPageNumberFormat("Page {n} of {total}")
    pdfDoc.setHeader("RingPDFLib Documentation", PDF_ALIGN_LEFT)
    pdfDoc.setFooter("Confidential", PDF_ALIGN_CENTER)

    # Page 1
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Chapter 1: Introduction", 72, 720)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.drawParagraph("This is the first page of a multi-page document with headers, footers, and page numbers. The header appears at the top of each page, and the footer and page numbers appear at the bottom.", 72, 690, 468, 16)

    # Page 2
    pdfDoc.addPage()
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Chapter 2: Features", 72, 720)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.drawParagraph("The second page continues with more content. Notice how headers, footers, and page numbers automatically appear on each page.", 72, 690, 468, 16)

    # Page 3
    pdfDoc.addPage()
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Chapter 3: Conclusion", 72, 720)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.drawParagraph("The final page demonstrates consistent formatting across all pages in the document.", 72, 690, 468, 16)

    if pdfDoc.save("demo8_headers.pdf")
        ? "  Created: demo8_headers.pdf"
    else
        ? "  FAILED: demo8_headers.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 9: Bar Chart
    # ------------------------------------------------------------------
    ? "Demo 9: Bar chart..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Bar Chart")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Sales Report", 72, 750)

    salesData = [
        :labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
        :values = [85, 120, 95, 150, 130, 170]
    ]

    pdfDoc.drawBarChart(salesData, 72, 400, 450, 280, [
        :title = "Monthly Sales (Units)",
        :showValues = true,
        :colors = [[66,133,244], [52,168,83], [251,188,4], [234,67,53], [171,71,188], [255,109,0]]
    ])

    if pdfDoc.save("demo9_bar_chart.pdf")
        ? "  Created: demo9_bar_chart.pdf"
    else
        ? "  FAILED: demo9_bar_chart.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 10: Pie Chart
    # ------------------------------------------------------------------
    ? "Demo 10: Pie chart..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Pie Chart")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Market Share Analysis", 72, 750)

    marketData = [
        :labels = ["Product A", "Product B", "Product C", "Product D", "Other"],
        :values = [35, 25, 20, 12, 8]
    ]

    pdfDoc.drawPieChart(marketData, 250, 500, 120, [
        :showLegend = true
    ])

    if pdfDoc.save("demo10_pie_chart.pdf")
        ? "  Created: demo10_pie_chart.pdf"
    else
        ? "  FAILED: demo10_pie_chart.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 11: Watermark
    # ------------------------------------------------------------------
    ? "Demo 11: Watermark..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Watermark Demo")

    # Content first
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Important Document", 72, 750)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.setTextColor("black")
    pdfDoc.drawParagraph("This document contains a watermark. Watermarks are useful for marking documents as drafts, confidential, or for branding purposes. The watermark appears behind the text content.", 72, 710, 468, 16)

    # Add watermark
    pdfDoc.drawWatermark("CONFIDENTIAL", [
        :fontSize = 60,
        :color = [220, 220, 220],
        :angle = 45
    ])

    if pdfDoc.save("demo11_watermark.pdf")
        ? "  Created: demo11_watermark.pdf"
    else
        ? "  FAILED: demo11_watermark.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 12: Landscape Page
    # ------------------------------------------------------------------
    ? "Demo 12: Landscape orientation..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Landscape Page")
    pdfDoc.setOrientation(PDF_LANDSCAPE)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 28)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Landscape Orientation", 72, 520)

    pdfDoc.setFont(PDF_HELVETICA, 14)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("This page uses landscape orientation for wider content.", 72, 480)

    # Wide table
    wideData = [
        ["Region", "Q1 Sales", "Q2 Sales", "Q3 Sales", "Q4 Sales", "Total", "Growth"],
        ["North", "$120K", "$135K", "$142K", "$160K", "$557K", "+15%"],
        ["South", "$98K", "$105K", "$112K", "$125K", "$440K", "+12%"],
        ["East", "$145K", "$150K", "$155K", "$170K", "$620K", "+8%"],
        ["West", "$110K", "$118K", "$130K", "$145K", "$503K", "+18%"]
    ]

    pdfDoc.drawTable(wideData, 72, 440, [100, 90, 90, 90, 90, 90, 90], [
        :headerBg = "steelblue",
        :headerFg = "white",
        :evenRowBg = [235, 240, 250],
        :rowHeight = 24,
        :fontSize = 11
    ])

    if pdfDoc.save("demo12_landscape.pdf")
        ? "  Created: demo12_landscape.pdf"
    else
        ? "  FAILED: demo12_landscape.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 13: Business Report
    # ------------------------------------------------------------------
    ? "Demo 13: Business report..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Business Report")
    pdfDoc.setAuthor("Ring Corporation")
    pdfDoc.enablePageNumbers()

    # --- Title Page ---
    pdfDoc.setFillColor([33, 37, 41])
    pdfDoc.drawFilledRectNoStroke(0, 0, 595.28, 841.89)

    pdfDoc.setFillColor([66, 133, 244])
    pdfDoc.drawFilledRectNoStroke(0, 350, 595.28, 200)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 42)
    pdfDoc.setTextColor("white")
    pdfDoc.drawTextCentered("Business Report", 297.64, 465)

    pdfDoc.setFont(PDF_HELVETICA, 20)
    pdfDoc.drawTextCentered("Q4 2026 Performance Review", 297.64, 420)

    pdfDoc.setFont(PDF_HELVETICA, 14)
    pdfDoc.drawTextCentered("Prepared by the Analytics Team", 297.64, 380)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.setTextColor([150, 150, 150])
    pdfDoc.drawTextCentered("Ring Corporation - January 2026", 297.64, 200)

    # --- Page 2: KPI Overview ---
    pdfDoc.addPage()

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Key Performance Indicators", 72, 760)

    pdfDoc.setStrokeColor([66, 133, 244])
    pdfDoc.setLineWidth(3)
    pdfDoc.drawLine(72, 750, 300, 750)

    # KPI Cards
    kpiX = 72
    kpiY = 680
    kpiW = 145
    kpiH = 70

    # Card 1
    pdfDoc.setFillColor([230, 240, 255])
    pdfDoc.setStrokeColor([66, 133, 244])
    pdfDoc.setLineWidth(1)
    pdfDoc.drawFilledRect(kpiX, kpiY, kpiW, kpiH)
    pdfDoc.setFont(PDF_HELVETICA, 10)
    pdfDoc.setTextColor([66, 133, 244])
    pdfDoc.drawText("REVENUE", kpiX + 10, kpiY + kpiH - 15)
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 22)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("$2.4M", kpiX + 10, kpiY + 15)

    # Card 2
    kpiX += kpiW + 15
    pdfDoc.setFillColor([220, 245, 220])
    pdfDoc.setStrokeColor([52, 168, 83])
    pdfDoc.drawFilledRect(kpiX, kpiY, kpiW, kpiH)
    pdfDoc.setFont(PDF_HELVETICA, 10)
    pdfDoc.setTextColor([52, 168, 83])
    pdfDoc.drawText("GROWTH", kpiX + 10, kpiY + kpiH - 15)
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 22)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("+24%", kpiX + 10, kpiY + 15)

    # Card 3
    kpiX += kpiW + 15
    pdfDoc.setFillColor([255, 240, 220])
    pdfDoc.setStrokeColor([255, 109, 0])
    pdfDoc.drawFilledRect(kpiX, kpiY, kpiW, kpiH)
    pdfDoc.setFont(PDF_HELVETICA, 10)
    pdfDoc.setTextColor([255, 109, 0])
    pdfDoc.drawText("CUSTOMERS", kpiX + 10, kpiY + kpiH - 15)
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 22)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("12,450", kpiX + 10, kpiY + 15)

    # Chart
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 16)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Quarterly Revenue Trend", 72, 620)

    chartData = [
        :labels = ["Q1", "Q2", "Q3", "Q4"],
        :values = [480, 520, 610, 680]
    ]
    pdfDoc.drawBarChart(chartData, 72, 350, 450, 240, [
        :showValues = true,
        :colors = [[66,133,244], [66,133,244], [66,133,244], [52,168,83]]
    ])

    # Summary table
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 16)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("Department Performance", 72, 310)

    deptData = [
        ["Department", "Revenue", "Target", "Status"],
        ["Engineering", "$890K", "$800K", "Exceeded"],
        ["Sales", "$720K", "$700K", "Exceeded"],
        ["Marketing", "$340K", "$400K", "Below"],
        ["Support", "$450K", "$450K", "On Target"]
    ]

    pdfDoc.drawTable(deptData, 72, 295, [130, 110, 110, 118], [
        :headerBg = [33, 37, 41],
        :headerFg = "white",
        :evenRowBg = [245, 245, 245],
        :fontSize = 10
    ])

    if pdfDoc.save("demo13_business.pdf")
        ? "  Created: demo13_business.pdf"
    else
        ? "  FAILED: demo13_business.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 14: Letter Size
    # ------------------------------------------------------------------
    ? "Demo 14: Letter size page..."

    pdfDoc = new PDFWriter()
    pdfDoc.setPageSize(PDF_LETTER)
    pdfDoc.setTitle("US Letter Size")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("US Letter Size (8.5 x 11 in)", 72, 720)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("This document uses US Letter page size (612 x 792 points).", 72, 690)
    pdfDoc.drawText("The default page size is A4 (595.28 x 841.89 points).", 72, 670)

    if pdfDoc.save("demo14_letter.pdf")
        ? "  Created: demo14_letter.pdf"
    else
        ? "  FAILED: demo14_letter.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 15: Quick PDF Function
    # ------------------------------------------------------------------
    ? "Demo 15: Quick PDF function..."

    quickPDF("demo15_quick.pdf", "Quick Document", [
        [:title = "Quick PDF Generation", :body = "This PDF was created using the quickPDF function. It provides a simple way to create basic documents with minimal code."],
        [:title = "Second Page", :body = "The quick function supports multiple pages. Each page can have a title and body text."]
    ])
    ? "  Created: demo15_quick.pdf"

    # ------------------------------------------------------------------
    ? ""
    ? "=============================================="
    ? "   All demos completed!"
    ? "=============================================="
    ? ""
    ? "Created files:"
    ? "  1.  demo1_hello.pdf - Hello World"
    ? "  2.  demo2_fonts.pdf - Fonts and colors"
    ? "  3.  demo3_paragraphs.pdf - Paragraphs and alignment"
    ? "  4.  demo4_shapes.pdf - Shapes and drawing"
    ? "  5.  demo5_tables.pdf - Tables"
    ? "  6.  demo6_lists.pdf - Bullet and numbered lists"
    ? "  7.  demo7_multipage.pdf - Multiple pages"
    ? "  8.  demo8_headers.pdf - Headers, footers, page numbers"
    ? "  9.  demo9_bar_chart.pdf - Bar chart"
    ? "  10. demo10_pie_chart.pdf - Pie chart"
    ? "  11. demo11_watermark.pdf - Watermark"
    ? "  12. demo12_landscape.pdf - Landscape orientation"
    ? "  13. demo13_business.pdf - Complete business report"
    ? "  14. demo14_letter.pdf - US Letter page size"
    ? "  15. demo15_quick.pdf - Quick function"
    ? ""
    ? "Open these files in any PDF viewer."
