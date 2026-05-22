/*
    PDFLib - Functions
*/

# ============================================================================
# Helper Functions
# ============================================================================

func pdfColorToRGB color
    if color = NULL return [0, 0, 0] ok
    if isList(color) return color ok
    if !isString(color) return [0, 0, 0] ok
    
    color = lower(trim(color))
    
    namedColors = [
        :black = [0, 0, 0],
        :white = [255, 255, 255],
        :red = [255, 0, 0],
        :green = [0, 128, 0],
        :blue = [0, 0, 255],
        :yellow = [255, 255, 0],
        :orange = [255, 165, 0],
        :purple = [128, 0, 128],
        :pink = [255, 192, 203],
        :gray = [128, 128, 128],
        :grey = [128, 128, 128],
        :navy = [0, 0, 128],
        :teal = [0, 128, 128],
        :maroon = [128, 0, 0],
        :silver = [192, 192, 192],
        :lime = [0, 255, 0],
        :aqua = [0, 255, 255],
        :cyan = [0, 255, 255],
        :fuchsia = [255, 0, 255],
        :olive = [128, 128, 0],
        :brown = [139, 69, 19],
        :coral = [255, 127, 80],
        :crimson = [220, 20, 60],
        :gold = [255, 215, 0],
        :indigo = [75, 0, 130],
        :salmon = [250, 128, 114],
        :steelblue = [70, 130, 180],
        :tomato = [255, 99, 71],
        :darkblue = [0, 0, 139],
        :darkgreen = [0, 100, 0],
        :darkred = [139, 0, 0],
        :lightgray = [211, 211, 211],
        :lightgrey = [211, 211, 211],
        :darkgray = [64, 64, 64],
        :darkgrey = [64, 64, 64]
    ]
    
    if namedColors[color] != NULL
        return namedColors[color]
    ok
    
    # Parse hex color
    hexStr = color
    if left(hexStr, 1) = "#"
        hexStr = right(hexStr, len(hexStr) - 1)
    ok
    
    if len(hexStr) = 6
        rVal = pdfHexToDec(left(hexStr, 2))
        gVal = pdfHexToDec(substr(hexStr, 3, 2))
        bVal = pdfHexToDec(right(hexStr, 2))
        return [rVal, gVal, bVal]
    ok
    
    return [0, 0, 0]

func pdfHexToDec hexStr
    hexStr = upper(hexStr)
    result = 0
    hexLen = len(hexStr)
    for i = 1 to hexLen
        cVal = ascii(hexStr[i])
        if cVal >= 48 and cVal <= 57         # '0'-'9'
            val = cVal - 48
        elseif cVal >= 65 and cVal <= 70     # 'A'-'F'
            val = cVal - 55
        else
            val = 0
        ok
        result = result * 16 + val
    next
    return result

func pdfEscapeText str
    if str = NULL return "" ok
    str = "" + str
    # Use substr() to find special chars — if none, return fast
    if substr(str, "(") = 0 and substr(str, ")") = 0 and substr(str, "\") = 0
        return str
    ok
    result = ""
    strLen = len(str)
    for i = 1 to strLen
        c = str[i]
        if c = "(" or c = ")" or c = "\"
            result += "\" + c
        else
            result += c
        ok
    next
    return result

func pdfNum value
    if !isNumber(value) return "0" ok
    if value = floor(value)
        return "" + value
    ok
    # Format with 2 decimal places
    rounded = floor(value * 100 + 0.5) / 100
    return "" + rounded

func pdfRGBNorm rgb
    # Normalize 0-255 to 0-1
    return [rgb[1]/255, rgb[2]/255, rgb[3]/255]

# Quick function
func quickPDF filename, title, pages
    writer = new PDFWriter()
    writer.setTitle(title)
    
    pagesLen = len(pages)
    for i = 1 to pagesLen
        if i > 1 writer.addPage() ok
        pageData = pages[i]
        
        if pageData[:title] != NULL
            writer.setFont(PDF_HELVETICA_BOLD, 24)
            writer.setTextColor("black")
            writer.drawText(pageData[:title], 72, 720)
        ok
        
        if pageData[:body] != NULL
            writer.setFont(PDF_HELVETICA, 12)
            writer.drawParagraph(pageData[:body], 72, 680, 468, 14)
        ok
    next
    
    return writer.save(filename)

# ============================================================================
# Image format parsers
# ============================================================================

# Parse PNG IHDR chunk for dimensions and color type
func pdfParsePNGInfo data
    result = [:width = 0, :height = 0, :colorType = 0, :bitDepth = 0]
    if len(data) < 26 return result ok
    result[:width] = ascii(data[17]) * 16777216 + ascii(data[18]) * 65536 + ascii(data[19]) * 256 + ascii(data[20])
    result[:height] = ascii(data[21]) * 16777216 + ascii(data[22]) * 65536 + ascii(data[23]) * 256 + ascii(data[24])
    result[:bitDepth] = ascii(data[25])
    result[:colorType] = ascii(data[26])
    return result

# Parse BMP dimensions from header (pure Ring)
func pdfParseBMPInfo data
    result = [:width = 0, :height = 0, :bpp = 0, :dataOffset = 0]
    if len(data) < 30 return result ok
    # BMP header: offset 18-21 = width, 22-25 = height (little-endian)
    result[:width] = ascii(data[19]) + ascii(data[20]) * 256 + ascii(data[21]) * 65536 + ascii(data[22]) * 16777216
    result[:height] = ascii(data[23]) + ascii(data[24]) * 256 + ascii(data[25]) * 65536 + ascii(data[26]) * 16777216
    result[:bpp] = ascii(data[29]) + ascii(data[30]) * 256
    result[:dataOffset] = ascii(data[11]) + ascii(data[12]) * 256 + ascii(data[13]) * 65536 + ascii(data[14]) * 16777216
    return result

