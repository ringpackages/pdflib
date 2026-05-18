# PDFLib — PDF Generation Library for Ring

## Overview

PDFLib is a pure Ring implementation for generating PDF 1.4 files with no external dependencies. Output is compatible with any PDF viewer including Adobe Acrobat, Foxit Reader, and web browsers.

## Features

- **Page management** — multiple pages, sizes (A4, Letter, Legal, etc.), portrait/landscape orientation, margins
- **Text** — 14 PDF standard fonts (no font files needed; supplied by every PDF viewer), sizes, colors, left/center/right alignment
- **Paragraphs** — word-wrapping with configurable line height and alignment
- **Arabic / Unicode text** — any TTF can be loaded and embedded; full shaping and RTL pipeline for Arabic; direct glyph mapping for Latin extensions, Greek, Cyrillic, and CJK; complex scripts (Devanagari, Thai, etc.) are not supported
- **Shapes** — rectangles, circles, ellipses, lines, polygons; stroke, fill, or both
- **Tables** — headers, alternating row colors, borders, explicit or auto column widths, Arabic-aware cell rendering
- **Lists** — bullet lists and numbered lists
- **Charts** — bar charts and pie charts with legends
- **Images** — JPEG (DCTDecode), PNG (FlateDecode, all color types), BMP (24-bit); pure Ring parsers, no C library required
- **Page numbers** — configurable format and position
- **Headers / Footers** — per-document text with alignment
- **Watermarks** — rotated text at arbitrary angle
- **Graphics state** — save/restore, line width, cap, join, dash patterns
- **Document properties** — title, author, subject, keywords, creator

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Coordinate System](#coordinate-system)
- [API Reference](#api-reference)
  - [Constructor](#constructor)
  - [Document Settings](#document-settings)
  - [Page Sizes](#page-sizes)
  - [Page Management](#page-management)
  - [Fonts](#fonts)
    - [PDF Standard Fonts](#pdf-standard-fonts)
    - [TrueType Fonts](#truetype-fonts)
  - [Arabic / Unicode Text](#arabic--unicode-text)
    - [Drawing Arabic Text](#drawing-arabic-text)
    - [Mixed Arabic/Latin Documents](#mixed-arabiclatin-documents)
  - [Colors](#colors)
  - [Text Drawing](#text-drawing)
  - [Paragraphs](#paragraphs)
  - [Shapes](#shapes)
    - [Rectangles](#rectangles)
    - [Circles and Ellipses](#circles-and-ellipses)
    - [Lines](#lines)
    - [Polygons](#polygons)
    - [Line Style](#line-style)
  - [Images](#images)
  - [Tables](#tables)
  - [Lists](#lists)
  - [Charts](#charts)
    - [Bar Chart](#bar-chart)
    - [Pie Chart](#pie-chart)
  - [Page Numbers](#page-numbers)
  - [Headers and Footers](#headers-and-footers)
  - [Watermarks](#watermarks)
  - [Graphics State](#graphics-state)
  - [Output](#output)
- [Examples](#examples)
  - [Invoice](#invoice)
  - [Certificate](#certificate)
  - [Arabic Document](#arabic-document)
  - [Images](#images-1)
- [Technical Notes](#technical-notes)

---

## Installation

```ring
ringpm install pdflib from ringpackages
```

## Quick Start

```ring
load "pdflib.ring"

pdf = new PDFWriter()
pdf.setTitle("My First PDF")
pdf.setFont(PDF_HELVETICA_BOLD, 24)
pdf.drawText("Hello, World!", 72, 700)
pdf.save("hello.pdf")
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

## Coordinate System

PDF uses a bottom-left origin:

- (0, 0) is the **bottom-left** corner of the page
- X increases to the **right**
- Y increases **upward**
- 1 point = 1/72 inch

For A4 paper (595 × 842 pt), the top of the page is y ≈ 842. For typical document layout, start drawing at y = 750 and decrease y for each new line.

---

## API Reference

### Constructor

```ring
pdf = new PDFWriter()
```

Creates a new PDF document with one blank A4 page. All 14 PDF standard fonts are pre-registered and ready to use — no font files required.

---

### Document Settings

| Method | Description |
|--------|-------------|
| `setPageSize(size)` | Page size constant — see Page Sizes table |
| `setOrientation(orient)` | `PDF_PORTRAIT` or `PDF_LANDSCAPE` |
| `setMargins(left, top, right, bottom)` | Margins in points (72 pt = 1 inch). Default: 72 all sides |
| `setTitle(text)` | Document title |
| `setAuthor(text)` | Author name |
| `setSubject(text)` | Subject |
| `setKeywords(text)` | Keywords |
| `setCreator(text)` | Creator application name |

### Page Sizes

| Constant | Points | Physical |
|----------|--------|----------|
| `PDF_A4` | 595.28 × 841.89 | 210 × 297 mm |
| `PDF_A3` | 841.89 × 1190.55 | 297 × 420 mm |
| `PDF_A5` | 419.53 × 595.28 | 148 × 210 mm |
| `PDF_LETTER` | 612 × 792 | 8.5 × 11 in |
| `PDF_LEGAL` | 612 × 1008 | 8.5 × 14 in |
| `PDF_TABLOID` | 792 × 1224 | 11 × 17 in |

---

### Page Management

| Method | Returns | Description |
|--------|---------|-------------|
| `addPage()` | self | Add a new page and switch to it |
| `selectPage(n)` | self | Switch to page n (1-based) |
| `getPageCount()` | number | Total number of pages |
| `getPageWidth()` | number | Current page width in points |
| `getPageHeight()` | number | Current page height in points |
| `getContentWidth()` | number | Page width minus left and right margins |
| `getContentHeight()` | number | Page height minus top and bottom margins |

---

### Fonts

PDFLib supports two categories of fonts: **PDF standard fonts** for Latin text, and **TrueType fonts** for Arabic/Unicode text.

#### PDF Standard Fonts

The PDF specification (ISO 32000) defines 14 standard fonts that every conforming PDF viewer is required to have built in. PDFLib references these by name only — **no font files are shipped or embedded**; the viewer supplies the glyphs. This makes standard-font PDFs very small.

Set the active font with `setFont(fontName, size)` or change only the size with `setFontSize(size)`.

```ring
pdf.setFont(PDF_HELVETICA_BOLD, 18)
pdf.setFontSize(12)
```

| Constant | PDF Font Name | Style |
|----------|---------------|-------|
| `PDF_HELVETICA` | Helvetica | Sans-serif |
| `PDF_HELVETICA_BOLD` | Helvetica-Bold | Sans-serif bold |
| `PDF_HELVETICA_ITALIC` | Helvetica-Oblique | Sans-serif italic |
| `PDF_HELVETICA_BOLDITALIC` | Helvetica-BoldOblique | Sans-serif bold italic |
| `PDF_TIMES` | Times-Roman | Serif |
| `PDF_TIMES_BOLD` | Times-Bold | Serif bold |
| `PDF_TIMES_ITALIC` | Times-Italic | Serif italic |
| `PDF_TIMES_BOLDITALIC` | Times-BoldItalic | Serif bold italic |
| `PDF_COURIER` | Courier | Monospace |
| `PDF_COURIER_BOLD` | Courier-Bold | Monospace bold |
| `PDF_COURIER_ITALIC` | Courier-Oblique | Monospace italic |
| `PDF_COURIER_BOLDITALIC` | Courier-BoldOblique | Monospace bold italic |
| `PDF_SYMBOL` | Symbol | Greek and mathematical symbols |
| `PDF_ZAPFDINGBATS` | ZapfDingbats | Decorative dingbats |

> **Note:** Standard fonts only cover the Latin-1 (Western) character set. They do not support Arabic, Hebrew, Chinese, or other non-Latin scripts. For Arabic text, a TrueType font must be loaded separately — see the [Arabic / Unicode Text](#arabic--unicode-text) section.

#### TrueType Fonts

Any `.ttf` file can be loaded. The font is fully parsed (cmap, hmtx, glyf, head, hhea, loca, OS/2, and post tables) and embedded in the output PDF as a CIDFont/Type0 object with a ToUnicode CMap. No external tool or C library is needed.

```ring
pdf.loadTTFFont("font/arial.ttf", "Arabic")    # general method
pdf.loadArabicFont("font/arial.ttf", "Arabic") # alias — identical behaviour
pdf.setFont("Arabic", 24)
```

The second argument is a free-form alias used with `setFont`. The library ships `font/arial.ttf` in the samples folder as a ready-to-use example; any other TTF can be substituted.

**Script support matrix:**

| Script | Method to use | Notes |
|--------|---------------|-------|
| Arabic | `drawArabicText` / `drawArabicParagraph` | Full support: contextual shaping, RTL layout, word wrap |
| Latin extensions (é, ü, ñ …) | `drawText` | Works — direct codepoint-to-glyph mapping, no shaping needed |
| Greek, Cyrillic | `drawText` | Works — no shaping required |
| CJK (Chinese, Japanese, Korean) | `drawText` | Works — one codepoint maps to one glyph |
| Hebrew (basic) | `drawText` | Glyphs render but no RTL layout support outside the Arabic path |
| Devanagari (Hindi), Thai, Khmer, Myanmar | — | Not supported — these scripts require a shaping engine not present in the library |

> **In short:** load any TTF and use `drawText` for scripts that don't need complex shaping. Use the `drawArabicText` family specifically for Arabic, which is the only script with a full shaping and bidirectional layout pipeline implemented.

---

### Arabic / Unicode Text

PDFLib includes a pure Ring Arabic text engine supporting UTF-8 decoding, contextual letter shaping (isolated/initial/medial/final letter forms), bidi reordering, and right-to-left layout. A TrueType font must be loaded first — see [TrueType Fonts](#truetype-fonts) above.

#### Drawing Arabic Text

| Method | Description |
|--------|-------------|
| `drawArabicText(text, x, y)` | Draw Arabic text; **x is the right edge** of the text (RTL) |
| `drawArabicTextLeft(text, x, y)` | Draw Arabic text with **x as the left edge** |
| `drawArabicTextCentered(text, x, y)` | Draw Arabic text centered at x |
| `drawArabicTextInCell(text, x, y)` | Draw Arabic text in a LTR cell context (left-edge x) |
| `drawArabicParagraph(text, x, y, maxWidth, lineHeight)` | RTL word-wrapped paragraph; x is right edge; returns final Y |
| `getArabicTextWidth(text)` | Returns rendered width in points for the current font and size |

```ring
pdf.loadArabicFont("font/arial.ttf", "Arabic")
pdf.setFont("Arabic", 28)
pdf.setTextColor("black")

# x = 523 is the right edge of the text
pdf.drawArabicText("مرحبا بالعالم", 523, 700)

# RTL paragraph with word wrap, max width 441 pt
pdf.drawArabicParagraph("لغة البرمجة رينج هي لغة حديثة وسهلة التعلم", 523, 600, 441, 28)
```

#### Mixed Arabic/Latin Documents

When an `arabicFont` option is passed to `drawTable`, cells are automatically rendered with the correct font and direction based on their content. Arabic segments within a mixed cell are drawn right-to-left; Latin segments are drawn left-to-right.

```ring
pdf.drawTable(data, 72, 700, [200, 268], [
    :headerBg = "navy",
    :headerFg = "white",
    :arabicFont = "Arabic"
])
```

---

### Colors

```ring
pdf.setTextColor(color)
pdf.setFillColor(color)
pdf.setStrokeColor(color)
```

Colors can be specified in three formats:

- Named string: `"red"`, `"navy"`, `"steelblue"`, etc.
- Hex string: `"#FF5733"` or `"FF5733"`
- RGB array: `[255, 87, 51]`

**Named colors:** black, white, red, green, blue, yellow, orange, purple, pink, gray, grey, navy, teal, maroon, silver, lime, aqua, cyan, fuchsia, olive, brown, coral, crimson, gold, indigo, salmon, steelblue, tomato, darkblue, darkgreen, darkred, lightgray, lightgrey, darkgray, darkgrey

---

### Text Drawing

```ring
pdf.drawText(text, x, y)                          # Left-aligned at (x, y)
pdf.drawTextCentered(text, x, y)                  # Horizontally centered at x
pdf.drawTextRight(text, x, y)                     # Right edge at x
pdf.drawTextAligned(text, x, y, width, align)     # Within a box of given width
```

**Alignment constants:**

| Constant | Value |
|----------|-------|
| `PDF_ALIGN_LEFT` | 0 |
| `PDF_ALIGN_CENTER` | 1 |
| `PDF_ALIGN_RIGHT` | 2 |

---

### Paragraphs

Both functions return the Y position after the last line, which can be used to continue drawing below the paragraph.

```ring
newY = pdf.drawParagraph(text, x, y, maxWidth, lineHeight)
newY = pdf.drawParagraphAligned(text, x, y, maxWidth, lineHeight, align)
```

`lineHeight` defaults to `fontSize × 1.2` when `NULL` is passed.

---

### Shapes

#### Rectangles

```ring
pdf.drawRect(x, y, width, height)                # Stroke only
pdf.drawFilledRect(x, y, width, height)           # Fill and stroke
pdf.drawFilledRectNoStroke(x, y, width, height)   # Fill only
```

#### Circles and Ellipses

```ring
pdf.drawCircle(cx, cy, radius)
pdf.drawFilledCircle(cx, cy, radius)

pdf.drawEllipse(cx, cy, rx, ry)
pdf.drawFilledEllipse(cx, cy, rx, ry)
```

#### Lines

```ring
pdf.drawLine(x1, y1, x2, y2)
pdf.drawHorizontalRule(x, y, width)    # Horizontal line
```

#### Polygons

```ring
# Points is a list of [x, y] pairs; polygon is always filled and stroked
pdf.drawPolygon([[x1, y1], [x2, y2], [x3, y3], ...])
```

### Line Style

```ring
pdf.setLineWidth(width)
pdf.setLineCap(cap)     # 0 = butt (PDF_CAP_BUTT), 1 = round, 2 = square
pdf.setLineJoin(join)   # 0 = miter (PDF_JOIN_MITER), 1 = round, 2 = bevel
pdf.setDash([5, 3], 0)  # Dash array and phase
pdf.resetDash()         # Restore solid line
```

---

### Images

`drawImage` detects the file format automatically by its header bytes and embeds accordingly. No external image library is required.

```ring
pdf.drawImage(filename, x, y, width, height)
```

| Format | Encoding | Notes |
|--------|----------|-------|
| JPEG (`.jpg`, `.jpeg`) | DCTDecode | All standard JPEG files; dimensions parsed from SOF marker |
| PNG (`.png`) | FlateDecode | Grayscale, RGB, grayscale+alpha, RGBA; predictor 15 |
| BMP (`.bmp`) | Raw RGB | 24-bit BMP only; rows converted from BGR bottom-up to RGB top-down |

```ring
# JPEG
pdf.drawImage("photo.jpg", 72, 500, 200, 150)

# PNG (all color types supported)
pdf.drawImage("logo.png", 72, 400, 100, 100)

# BMP (24-bit)
pdf.drawImage("scan.bmp", 72, 300, 150, 100)
```

Width and height are the display dimensions in points (72 pt = 1 inch). The image is scaled to fit the specified rectangle regardless of its pixel dimensions.

---

### Tables

#### Explicit Column Widths

```ring
# data is a 2D list; first row is the header
newY = pdf.drawTable(data, x, y, colWidths, options)
```

#### Auto Column Widths

```ring
# Divides totalWidth evenly across all columns
newY = pdf.drawSimpleTable(data, x, y, totalWidth, options)
```

Both return the Y position after the last row.

**Table options:**

| Key | Default | Description |
|-----|---------|-------------|
| `:rowHeight` | 20 | Row height in points |
| `:headerBg` | `[66, 133, 244]` | Header background color |
| `:headerFg` | `[255, 255, 255]` | Header text color |
| `:evenRowBg` | `[240, 240, 240]` | Even row background color |
| `:borderColor` | `[0, 0, 0]` | Cell border color |
| `:fontSize` | 10 | Text size in points |
| `:showHeader` | `true` | Show or hide the header row |
| `:padding` | 5 | Cell padding in points |
| `:arabicFont` | `""` | Font alias for Arabic cell content (enables mixed-script cells) |

---

### Lists

```ring
newY = pdf.drawBulletList(items, x, y, lineHeight)
newY = pdf.drawNumberedList(items, x, y, lineHeight)
```

`items` is a list of strings. `lineHeight` defaults to `fontSize × 1.4` when `NULL`. Both return the Y position after the last item.

---

### Charts

#### Bar Chart

```ring
data = [:labels = ["Q1", "Q2", "Q3"], :values = [120, 200, 170]]
pdf.drawBarChart(data, x, y, width, height, options)
```

| Option | Description |
|--------|-------------|
| `:title` | Chart title drawn above the chart |
| `:colors` | List of RGB arrays for bars |
| `:showValues` | `true` to draw each bar's value above it |

#### Pie Chart

```ring
data = [:labels = ["Alpha", "Beta", "Gamma"], :values = [40, 35, 25]]
pdf.drawPieChart(data, cx, cy, radius, options)
```

| Option | Description |
|--------|-------------|
| `:colors` | List of RGB arrays for slices |
| `:showLegend` | `true` to draw a legend to the right of the chart |

---

### Page Numbers

```ring
pdf.enablePageNumbers()
pdf.setPageNumberFormat("Page {n} of {total}")   # {n} and {total} are placeholders
pdf.setPageNumberPosition(x, y)                  # Default: horizontally centered, y = 30
```

Page numbers are added to all pages automatically at save time.

---

### Headers and Footers

```ring
pdf.setHeader("My Document", PDF_ALIGN_CENTER)
pdf.setFooter("Confidential", PDF_ALIGN_RIGHT)
```

Headers and footers are drawn on every page at save time using 10 pt Helvetica in gray. The `align` parameter is a `PDF_ALIGN_*` constant and defaults to `PDF_ALIGN_LEFT`.

---

### Watermarks

```ring
pdf.drawWatermark("DRAFT", [
    :fontSize = 60,
    :color = [200, 200, 200],
    :angle = 45
])
```

All three options are optional. Defaults are fontSize 60, light gray, angle 45°. The watermark is centered on the current page.

---

### Graphics State

```ring
pdf.saveState()     # Push current graphics state (color, line width, etc.)
pdf.restoreState()  # Pop and restore previously saved state
```

---

### Output

```ring
ok = pdf.save("output.pdf")   # Returns true on success, false on failure
```

---

## Examples

### Invoice

```ring
load "pdflib.ring"

pdf = new PDFWriter()
pdf.setTitle("Invoice #1001")

pdf.setFont(PDF_HELVETICA_BOLD, 28)
pdf.setTextColor("navy")
pdf.drawText("INVOICE", 72, 760)

pdf.setFont(PDF_HELVETICA, 12)
pdf.setTextColor("gray")
pdf.drawTextRight("#INV-1001", 540, 760)
pdf.drawTextRight("Date: 2025-01-15", 540, 740)

items = [
    ["Description", "Qty", "Price", "Total"],
    ["Web Design", "1", "$2,500", "$2,500"],
    ["Hosting (Annual)", "1", "$300", "$300"],
    ["Domain Name", "2", "$15", "$30"]
]

pdf.drawTable(items, 72, 650, [250, 60, 80, 78], [
    :headerBg = "navy",
    :headerFg = "white"
])

pdf.setFont(PDF_HELVETICA_BOLD, 14)
pdf.setTextColor("black")
pdf.drawTextRight("Total: $2,830.00", 540, 540)

pdf.save("invoice.pdf")
```

### Certificate

```ring
load "pdflib.ring"

pdf = new PDFWriter()
pdf.setOrientation(PDF_LANDSCAPE)

pdf.setStrokeColor("gold")
pdf.setLineWidth(4)
pdf.drawRect(30, 30, 781, 531)

pdf.setFont(PDF_TIMES_BOLD, 36)
pdf.setTextColor("navy")
pdf.drawTextCentered("Certificate of Achievement", 420, 460)

pdf.setFont(PDF_TIMES_ITALIC, 24)
pdf.setTextColor("black")
pdf.drawTextCentered("Jane Smith", 420, 350)

pdf.setFont(PDF_TIMES, 14)
pdf.drawTextCentered("For outstanding contributions to the team", 420, 300)

pdf.save("certificate.pdf")
```

### Arabic Document

```ring
load "pdflib.ring"

pdf = new PDFWriter()
pdf.setTitle("Arabic Demo")

# Load a TrueType font for Arabic rendering
pdf.loadArabicFont("font/arial.ttf", "Arabic")

# English heading
pdf.setFont(PDF_HELVETICA_BOLD, 16)
pdf.setTextColor("black")
pdf.drawText("Bilingual Document", 72, 760)

# Arabic heading — x is the right edge
pdf.setFont("Arabic", 20)
pdf.drawArabicText("وثيقة ثنائية اللغة", 523, 760)

# Arabic paragraph with RTL word wrap
pdf.setFont("Arabic", 14)
pdf.drawArabicParagraph(
    "لغة البرمجة رينج هي لغة حديثة وسهلة التعلم تدعم البرمجة الكائنية",
    523, 720, 440, 22
)

pdf.save("arabic_demo.pdf")
```

### Images

```ring
load "pdflib.ring"

pdf = new PDFWriter()
pdf.setTitle("Image Gallery")

# JPEG
pdf.drawImage("photo.jpg", 72, 560, 200, 150)

# PNG (transparent backgrounds and all color types supported)
pdf.drawImage("logo.png", 300, 560, 120, 120)

# BMP (24-bit)
pdf.drawImage("scan.bmp", 72, 380, 180, 140)

pdf.save("gallery.pdf")
```

---

## Technical Notes

- **Format:** PDF 1.4 (ISO 32000-1), compatible with all modern viewers
- **Arabic pipeline:** UTF-8 decode → contextual shaping → bidi reorder → TrueType glyph mapping → CIDFont / Type0 embedding with ToUnicode CMap
- **PNG support:** all PNG color types (grayscale, RGB, grayscale+alpha, RGBA) via FlateDecode with Predictor 15; alpha channels are handled through a DeviceN tint function
- **BMP support:** 24-bit BMP only; rows are converted from BGR bottom-up storage to RGB top-down on read
- **No external dependencies:** all format parsing (JPEG, PNG, BMP, TTF) is implemented in pure Ring
