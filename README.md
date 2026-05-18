# PDFLib Documentation

## Overview

PDFLib is a library for generating PDF files using the Ring programming language. It produces valid PDF 1.4 files that can be opened in any PDF viewer including Adobe Acrobat, Foxit Reader, web browsers, and more.

**Dependencies:** None (pure Ring implementation)

## Features

- **Page Management** - Multiple pages, sizes (A4, Letter, Legal, etc.), orientation
- **Text** - 14 built-in fonts, sizes, colors, bold, italic, alignment
- **Paragraphs** - Word wrapping, left/center/right alignment
- **Shapes** - Rectangles, circles, ellipses, lines, polygons
- **Tables** - Headers, colored rows, borders, auto-width
- **Lists** - Bullet lists, numbered lists
- **Charts** - Bar charts, pie charts with legends
- **Page Numbers** - Customizable format and position
- **Headers/Footers** - Text with alignment on every page
- **Watermarks** - Rotated text watermarks
- **Images** - JPEG image embedding
- **Document Properties** - Title, author, subject, keywords

## Installation

	ringpm install pdflib from ringpackages


## Quick Start

```ring
load "pdflib.ring"

pdfDoc = new PDFWriter()
pdfDoc.setTitle("My First PDF")
pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
pdfDoc.drawText("Hello, World!", 72, 700)
pdfDoc.save("hello.pdf")
```

### Quick Function

```ring
load "pdflib.ring"

quickPDF("output.pdf", "My Document", [
    [:title = "Page 1", :body = "Content for page 1..."],
    [:title = "Page 2", :body = "Content for page 2..."]
])
```

---

## API Reference

### Constructor

```ring
pdfDoc = new PDFWriter()
```

Creates a new PDF document with one blank A4 page.

---

### Document Settings

| Method | Description |
|--------|-------------|
| `setPageSize(size)` | Set page size (PDF_A4, PDF_LETTER, etc.) |
| `setOrientation(orient)` | PDF_PORTRAIT or PDF_LANDSCAPE |
| `setMargins(l, t, r, b)` | Set margins in points (72pt = 1 inch) |
| `setTitle(text)` | Set document title |
| `setAuthor(text)` | Set author name |
| `setSubject(text)` | Set subject |
| `setKeywords(text)` | Set keywords |
| `setCreator(text)` | Set creator application name |

### Page Sizes

| Constant | Size (points) | Physical |
|----------|--------------|----------|
| `PDF_A4` | 595.28 x 841.89 | 210 x 297 mm |
| `PDF_A3` | 841.89 x 1190.55 | 297 x 420 mm |
| `PDF_A5` | 419.53 x 595.28 | 148 x 210 mm |
| `PDF_LETTER` | 612 x 792 | 8.5 x 11 in |
| `PDF_LEGAL` | 612 x 1008 | 8.5 x 14 in |
| `PDF_TABLOID` | 792 x 1224 | 11 x 17 in |

---

### Page Management

| Method | Description |
|--------|-------------|
| `addPage()` | Add a new page |
| `selectPage(n)` | Select page by number |
| `getPageCount()` | Get total number of pages |
| `getPageWidth()` | Get current page width |
| `getPageHeight()` | Get current page height |
| `getContentWidth()` | Page width minus margins |
| `getContentHeight()` | Page height minus margins |

---

### Font Settings

```ring
pdfDoc.setFont(fontName, fontSize)
pdfDoc.setFontSize(size)
```

### Available Fonts

| Constant | Font |
|----------|------|
| `PDF_HELVETICA` | Helvetica (Arial-like) |
| `PDF_HELVETICA_BOLD` | Helvetica Bold |
| `PDF_HELVETICA_ITALIC` | Helvetica Italic |
| `PDF_HELVETICA_BOLDITALIC` | Helvetica Bold Italic |
| `PDF_TIMES` | Times Roman (serif) |
| `PDF_TIMES_BOLD` | Times Bold |
| `PDF_TIMES_ITALIC` | Times Italic |
| `PDF_TIMES_BOLDITALIC` | Times Bold Italic |
| `PDF_COURIER` | Courier (monospace) |
| `PDF_COURIER_BOLD` | Courier Bold |
| `PDF_COURIER_ITALIC` | Courier Italic |
| `PDF_COURIER_BOLDITALIC` | Courier Bold Italic |
| `PDF_SYMBOL` | Symbol |
| `PDF_ZAPFDINGBATS` | ZapfDingbats |

---

### Color Settings

```ring
pdfDoc.setTextColor(color)
pdfDoc.setFillColor(color)
pdfDoc.setStrokeColor(color)
```

**Color formats:**
- Named: `"red"`, `"blue"`, `"steelblue"`, etc.
- Hex: `"#FF5733"` or `"FF5733"`
- RGB array: `[255, 87, 51]`

**Named Colors:**
black, white, red, green, blue, yellow, orange, purple, pink, gray, navy, teal, maroon, silver, lime, aqua, cyan, fuchsia, olive, brown, coral, crimson, gold, indigo, salmon, steelblue, tomato, darkblue, darkgreen, darkred, lightgray, darkgray

---

### Text Drawing

```ring
pdfDoc.drawText(text, x, y)
pdfDoc.drawTextCentered(text, x, y)
pdfDoc.drawTextRight(text, x, y)
pdfDoc.drawTextAligned(text, x, y, width, alignment)
```

**Coordinate System:** PDF origin is bottom-left. Y increases upward.

**Alignment Constants:**
- `PDF_ALIGN_LEFT` (0)
- `PDF_ALIGN_CENTER` (1)
- `PDF_ALIGN_RIGHT` (2)

---

### Paragraphs

```ring
# Returns Y position after last line
newY = pdfDoc.drawParagraph(text, x, y, maxWidth, lineHeight)
newY = pdfDoc.drawParagraphAligned(text, x, y, maxWidth, lineHeight, align)
```

---

### Shapes

```ring
# Rectangles
pdfDoc.drawRect(x, y, width, height)             # Stroke only
pdfDoc.drawFilledRect(x, y, width, height)        # Fill + stroke
pdfDoc.drawFilledRectNoStroke(x, y, width, height) # Fill only

# Circles
pdfDoc.drawCircle(cx, cy, radius)                 # Stroke only
pdfDoc.drawFilledCircle(cx, cy, radius)           # Fill + stroke

# Ellipses
pdfDoc.drawEllipse(cx, cy, rx, ry)
pdfDoc.drawFilledEllipse(cx, cy, rx, ry)

# Lines
pdfDoc.drawLine(x1, y1, x2, y2)
pdfDoc.drawHorizontalRule(x, y, width)

# Polygons
pdfDoc.drawPolygon([[x1,y1], [x2,y2], [x3,y3], ...])
```

### Line Settings

```ring
pdfDoc.setLineWidth(width)
pdfDoc.setLineCap(PDF_CAP_BUTT)     # 0=butt, 1=round, 2=square
pdfDoc.setLineJoin(PDF_JOIN_MITER)  # 0=miter, 1=round, 2=bevel
pdfDoc.setDash([5, 3], 0)           # Dash pattern
pdfDoc.resetDash()                  # Solid line
```

---

### Tables

```ring
# With explicit column widths
newY = pdfDoc.drawTable(data, x, y, colWidths, options)

# Auto-calculated column widths
newY = pdfDoc.drawSimpleTable(data, x, y, totalWidth, options)
```

**Data format:** 2D list where first row is headers.

**Options:**
- `:rowHeight` - Row height in points (default: 20)
- `:headerBg` - Header background color
- `:headerFg` - Header text color
- `:evenRowBg` - Even row background color
- `:borderColor` - Border color
- `:fontSize` - Text size
- `:showHeader` - Show/hide header (default: true)
- `:padding` - Cell padding

---

### Lists

```ring
# Bullet list
newY = pdfDoc.drawBulletList(items, x, y, lineHeight)

# Numbered list
newY = pdfDoc.drawNumberedList(items, x, y, lineHeight)
```

---

### Charts

#### Bar Chart

```ring
data = [:labels = ["A", "B", "C"], :values = [10, 20, 30]]
pdfDoc.drawBarChart(data, x, y, width, height, options)
```

**Options:**
- `:title` - Chart title
- `:colors` - Array of RGB arrays
- `:showValues` - Show values above bars

#### Pie Chart

```ring
data = [:labels = ["A", "B", "C"], :values = [40, 35, 25]]
pdfDoc.drawPieChart(data, cx, cy, radius, options)
```

**Options:**
- `:colors` - Array of RGB arrays
- `:showLegend` - Show legend

---

### Page Numbers

```ring
pdfDoc.enablePageNumbers()
pdfDoc.setPageNumberFormat("Page {n} of {total}")
pdfDoc.setPageNumberPosition(x, y)
```

Placeholders: `{n}` = current page, `{total}` = total pages.

---

### Headers and Footers

```ring
pdfDoc.setHeader("Header Text", PDF_ALIGN_CENTER)
pdfDoc.setFooter("Footer Text", PDF_ALIGN_LEFT)
```

---

### Watermarks

```ring
pdfDoc.drawWatermark("DRAFT", [
    :fontSize = 60,
    :color = [200, 200, 200],
    :angle = 45
])
```

---

### Images

```ring
pdfDoc.drawImage("photo.jpg", x, y, width, height)
```

Supports JPEG images.

---

### Graphics State

```ring
pdfDoc.saveState()    # Save current graphics state
pdfDoc.restoreState() # Restore saved state
```

---

### Output

```ring
pdfDoc.save("output.pdf")  # Returns true/false
```

---

## Examples

### Invoice

```ring
load "pdflib.ring"

pdfDoc = new PDFWriter()
pdfDoc.setTitle("Invoice #1001")

# Header
pdfDoc.setFont(PDF_HELVETICA_BOLD, 28)
pdfDoc.setTextColor("navy")
pdfDoc.drawText("INVOICE", 72, 760)

pdfDoc.setFont(PDF_HELVETICA, 12)
pdfDoc.setTextColor("gray")
pdfDoc.drawTextRight("#INV-1001", 540, 760)
pdfDoc.drawTextRight("Date: 2025-01-15", 540, 740)

# Line items table
items = [
    ["Description", "Qty", "Price", "Total"],
    ["Web Design", "1", "$2,500", "$2,500"],
    ["Hosting (Annual)", "1", "$300", "$300"],
    ["Domain Name", "2", "$15", "$30"]
]

pdfDoc.drawTable(items, 72, 650, [250, 60, 80, 78], [
    :headerBg = "navy",
    :headerFg = "white"
])

# Total
pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
pdfDoc.setTextColor("black")
pdfDoc.drawTextRight("Total: $2,830.00", 540, 540)

pdfDoc.save("invoice.pdf")
```

### Certificate

```ring
load "pdflib.ring"

pdfDoc = new PDFWriter()
pdfDoc.setOrientation(PDF_LANDSCAPE)

# Border
pdfDoc.setStrokeColor("gold")
pdfDoc.setLineWidth(4)
pdfDoc.drawRect(30, 30, 781, 531)

# Title
pdfDoc.setFont(PDF_TIMES_BOLD, 36)
pdfDoc.setTextColor("navy")
pdfDoc.drawTextCentered("Certificate of Achievement", 420, 460)

# Recipient
pdfDoc.setFont(PDF_TIMES_ITALIC, 24)
pdfDoc.setTextColor("black")
pdfDoc.drawTextCentered("John Smith", 420, 350)

# Description
pdfDoc.setFont(PDF_TIMES, 14)
pdfDoc.drawTextCentered("For outstanding contributions to the team", 420, 300)

pdfDoc.save("certificate.pdf")
```

---

## Coordinate System

PDF uses a coordinate system where:
- Origin (0, 0) is at the **bottom-left** corner
- X increases to the **right**
- Y increases **upward**
- 1 point = 1/72 inch

For A4 paper: top of page is y=841, bottom is y=0.

**Tip:** For typical document layout, start at y=750 and work downward (decreasing y values).

---

## Technical Notes

- **Format:** PDF 1.4 (ISO 32000-1)
