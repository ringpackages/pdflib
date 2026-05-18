/*
    PDFLib - PDF Generation Library for Ring Programming Language
    =============================================================
   
    Generates valid PDF 1.4 files per ISO 32000
    
    Features:
    - Multiple pages with custom sizes
    - Text with fonts (Helvetica, Times, Courier families)
    - Paragraphs with word wrapping
    - Bold, italic, font size, color
    - Lines, rectangles, circles, ellipses
    - Fill and stroke colors with opacity
    - Images (JPEG direct, PNG via FlateDecode, BMP via pixel parsing)
    - Tables with headers, borders, cell colors
    - Page headers and footers
    - Page numbers
    - Document properties (title, author, subject)
    - Bullet and numbered lists
    - Horizontal rules
    - Bookmarks / outline
    - Links (internal and external)
    - Simple bar and pie charts
    - Watermark text
    - Multi-column layout
    - Page margins
*/

# ============================================================================
# PDFWriter Class
# ============================================================================

class PDFWriter

    # Document settings
    aPageSize
    nOrientation
    aMargins        # [left, top, right, bottom]
    
    # Object tracking
    aObjects
    aObjectOffsets
    nObjectCount
    
    # Pages
    aPages
    aPageContents
    nCurrentPage
    
    # Resources
    aFonts
    aFontMap
    nFontCount
    aImages
    nImageCount
    
    # TrueType font storage (for Arabic/Unicode support)
    aTTFFonts       # List of loaded TrueType fonts
    nTTFFontCount
    
    # Current state
    cCurrentFont
    nCurrentFontSize
    aTextColor
    aFillColor
    aStrokeColor
    nLineWidth
    nLineCap
    nLineJoin
    cDashPattern
    
    # Document info
    cTitle
    cAuthor
    cSubject
    cKeywords
    cCreator
    
    # Page features
    aHeaders
    aFooters
    lPageNumbers
    cPageNumberFormat
    nPageNumberX
    nPageNumberY
    
    # Content tracking per page
    aPageStreams
    
    func init
        aPageSize = PDF_A4
        nOrientation = PDF_PORTRAIT
        aMargins = [72, 72, 72, 72]   # 1 inch all around
        
        aObjects = []
        aObjectOffsets = []
        nObjectCount = 0
        
        aPages = []
        aPageContents = []
        nCurrentPage = 0
        
        aFonts = []
        aFontMap = []
        nFontCount = 0
        aImages = []
        nImageCount = 0
        aTTFFonts = []
        nTTFFontCount = 0
        
        cCurrentFont = PDF_HELVETICA
        nCurrentFontSize = 12
        aTextColor = [0, 0, 0]
        aFillColor = [255, 255, 255]
        aStrokeColor = [0, 0, 0]
        nLineWidth = 1
        nLineCap = 0
        nLineJoin = 0
        cDashPattern = "[] 0"
        
        cTitle = ""
        cAuthor = ""
        cSubject = ""
        cKeywords = ""
        cCreator = "RingPDFLib 1.0"
        
        aHeaders = []
        aFooters = []
        lPageNumbers = false
        cPageNumberFormat = "Page {n} of {total}"
        nPageNumberX = -1
        nPageNumberY = 30
        
        aPageStreams = []
        
        # Add first page
        addPage()
        
        # Register standard fonts
        registerFont(PDF_HELVETICA)
        registerFont(PDF_HELVETICA_BOLD)
        registerFont(PDF_HELVETICA_ITALIC)
        registerFont(PDF_HELVETICA_BOLDITALIC)
        registerFont(PDF_TIMES)
        registerFont(PDF_TIMES_BOLD)
        registerFont(PDF_TIMES_ITALIC)
        registerFont(PDF_TIMES_BOLDITALIC)
        registerFont(PDF_COURIER)
        registerFont(PDF_COURIER_BOLD)
        registerFont(PDF_COURIER_ITALIC)
        registerFont(PDF_COURIER_BOLDITALIC)
        registerFont(PDF_SYMBOL)
        registerFont(PDF_ZAPFDINGBATS)
        
        return self
    
    # ========================================================================
    # Document Settings
    # ========================================================================
    
    func setPageSize size
        aPageSize = size
        return self
    
    func setOrientation orientation
        nOrientation = orientation
        return self
    
    func setMargins left, top, right, bottom
        aMargins = [left, top, right, bottom]
        return self
    
    func setTitle title
        cTitle = title
        return self
    
    func setAuthor author
        cAuthor = author
        return self
    
    func setSubject subject
        cSubject = subject
        return self
    
    func setKeywords keywords
        cKeywords = keywords
        return self
    
    func setCreator creator
        cCreator = creator
        return self
    
    # ========================================================================
    # Page Management
    # ========================================================================
    
    func addPage
        nCurrentPage++
        aPages + nCurrentPage
        aPageStreams + ""
        return self
    
    func selectPage pageNum
        if pageNum >= 1 and pageNum <= len(aPages)
            nCurrentPage = pageNum
        ok
        return self
    
    func getPageCount
        return len(aPages)
    
    func getPageWidth
        if nOrientation = PDF_LANDSCAPE
            return aPageSize[2]
        ok
        return aPageSize[1]
    
    func getPageHeight
        if nOrientation = PDF_LANDSCAPE
            return aPageSize[1]
        ok
        return aPageSize[2]
    
    func getContentWidth
        return getPageWidth() - aMargins[1] - aMargins[3]
    
    func getContentHeight
        return getPageHeight() - aMargins[2] - aMargins[4]
    
    # ========================================================================
    # Font Management
    # ========================================================================
    
    func registerFont fontName
        # Check if already registered
        fontMapLen = len(aFontMap)
        for i = 1 to fontMapLen
            if aFontMap[i][:name] = fontName
                return aFontMap[i][:id]
            ok
        next
        
        nFontCount++
        fontId = "F" + nFontCount
        aFontMap + [:name = fontName, :id = fontId]
        
        return fontId
    
    func getFontId fontName
        fontMapLen = len(aFontMap)
        for i = 1 to fontMapLen
            if aFontMap[i][:name] = fontName
                return aFontMap[i][:id]
            ok
        next
        # Auto register
        return registerFont(fontName)
    
    func setFont fontName, size
        cCurrentFont = fontName
        nCurrentFontSize = size
        return self
    
    func setFontSize size
        nCurrentFontSize = size
        return self
    
    # ========================================================================
    # TrueType Font Loading (for Arabic/Unicode text)
    # ========================================================================
    
    # Load a TrueType font file for Arabic/Unicode text support
    # fontFile: path to .ttf file
    # fontAlias: name to use with setFont() (e.g. "Arabic")
    func loadTTFFont fontFile, fontAlias
        if !fexists(fontFile) return self ok
        
        fontData = read(fontFile)
        if len(fontData) < 12 return self ok
        
        # Parse the font
        fontInfo = ttfParseFontFile(fontData)
        
        nTTFFontCount++
        fontId = "TF" + nTTFFontCount
        
        # Store parsed font info
        aTTFFonts + [
            :alias = fontAlias,
            :id = fontId,
            :info = fontInfo,
            :usedGlyphs = [],        # Track which glyphs are actually used
            :cidToUnicode = [],       # CID -> Unicode mappings for ToUnicode
            :cidToGlyph = [],         # CID -> GlyphID mappings (list of [cid, gid])
            :cidToGlyphMap = [],      # Hash keys: "" + glyphID 
            :cidToGlyphCIDs = []      # Parallel to cidToGlyphMap: the CID values
        ]
        
        # Register in font map so setFont works
        aFontMap + [:name = fontAlias, :id = fontId, :isTTF = true]
        
        # Initialize glyph ID cache for fast repeated lookups
        initGlyphIDCache()
        
        return self
    
    # Convenience alias
    func loadArabicFont fontFile, fontAlias
        return loadTTFFont(fontFile, fontAlias)
    
    # Find TTF font info by alias
    func findTTFFont fontAlias
        ttfCount = len(aTTFFonts)
        for i = 1 to ttfCount
            if aTTFFonts[i][:alias] = fontAlias
                return i
            ok
        next
        return 0
    
    # Check if current font is TTF
    func isTTFFont fontName
        fmLen = len(aFontMap)
        for i = 1 to fmLen
            if aFontMap[i][:name] = fontName
                if len(aFontMap[i]) >= 3
                    return aFontMap[i][:isTTF]
                ok
            ok
        next
        return false
    
    # Register a glyph as used and return its CID
    # Uses sequential CID assignment (0, 1, 2, ...) with explicit CID→GID mapping
    func registerGlyphMapping ttfIdx, unicode, glyphID
        # Use string key for hash lookup
        key = "" + glyphID
        cidToGlyphMap = aTTFFonts[ttfIdx][:cidToGlyphMap]
        
        idx = find(cidToGlyphMap, key)
        if idx > 0
            # Already registered - return its CID
            return aTTFFonts[ttfIdx][:cidToGlyphCIDs][idx]
        ok
        
        # Assign next sequential CID (starting from 0)
        cid = len(cidToGlyphMap)   # 0-based: first glyph gets CID 0, etc.
        aTTFFonts[ttfIdx][:cidToGlyphMap] + key
        aTTFFonts[ttfIdx][:cidToGlyphCIDs] + cid
        aTTFFonts[ttfIdx][:cidToGlyph] + [cid, glyphID]
        aTTFFonts[ttfIdx][:cidToUnicode] + [cid, unicode]
        
        return cid
    
    # ========================================================================
    # Arabic Text Drawing
    # ========================================================================
    
    # Draw Arabic text (with shaping and RTL layout)
    # x,y is the RIGHT edge of text (since Arabic is RTL)
    # Returns the total width of the rendered text
    func drawArabicText text, x, y
        ttfIdx = findTTFFont(cCurrentFont)
        if ttfIdx = 0
            drawText(text, x, y)
            return getTextWidth(text)
        ok
        
        fontInfo = aTTFFonts[ttfIdx][:info]
        fontId = aTTFFonts[ttfIdx][:id]
        
        # Step 1: Decode UTF-8 to codepoints
        codepoints = utf8ToCodepoints(text)
        if len(codepoints) = 0 return 0 ok
        
        # Step 2: Shape Arabic letters (contextual forms)
        shaped = shapeArabicText(codepoints)
        
        # Step 3: Bidi reorder (reverse for RTL display)
        reordered = bidiReorder(shaped)
        
        # Step 4: Map to glyph IDs and build CID string
        cmapF4 = fontInfo[:cmapFormat4]
        unitsPerEm = fontInfo[:unitsPerEm]
        scale = nCurrentFontSize / unitsPerEm
        
        # Pre-allocate CID string (2 bytes per character)
        reLen = len(reordered)
        cidString = copy(char(0) + char(0), reLen)
        totalWidth = 0
        
        for i = 1 to reLen
            cp = reordered[i]
            gid = ttfGetGlyphID(cmapF4, cp)
            
            # Register glyph usage (sequential CID mapping)
            cid = registerGlyphMapping(ttfIdx, cp, gid)
            
            # Write to pre-allocated CID string (big-endian 16-bit)
            pos = (i - 1) * 2 + 1
            cidString[pos] = char((cid >> 8) & 0xFF)
            cidString[pos + 1] = char(cid & 0xFF)
            
            # Accumulate width
            w = ttfGetGlyphWidth(fontInfo, gid)
            totalWidth += w * scale
        next
        
        # Step 5: Generate PDF content stream
        # Position at x (right edge), shift left by total width
        drawX = x - totalWidth
        
        rgb = pdfRGBNorm(aTextColor)
        hexStr = binToHex(cidString)
        stream = "BT" + char(10) +
                 "/" + fontId + " " + pdfNum(nCurrentFontSize) + " Tf" + char(10) +
                 pdfNum(rgb[1]) + " " + pdfNum(rgb[2]) + " " + pdfNum(rgb[3]) + " rg" + char(10) +
                 pdfNum(drawX) + " " + pdfNum(y) + " Td" + char(10) +
                 "<" + hexStr + "> Tj" + char(10) +
                 "ET" + char(10)
        
        appendToPage(stream)
        return totalWidth
    
    # Draw Arabic text with left edge at x (like drawText but handles RTL internally)
    # Returns the total width
    func drawArabicTextLeft text, x, y
        w = getArabicTextWidth(text)
        drawArabicText(text, x + w, y)
        return w
    
    # Draw Arabic text in LTR cell context (left edge at x)
    # Single-pass: decode, shape, bidi, measure, draw — all at once
    # Returns the total width
    func drawArabicTextInCell text, x, y
        ttfIdx = findTTFFont(cCurrentFont)
        if ttfIdx = 0
            drawText(text, x, y)
            return getTextWidth(text)
        ok
        
        fontInfo = aTTFFonts[ttfIdx][:info]
        fontId = aTTFFonts[ttfIdx][:id]
        cmapF4 = fontInfo[:cmapFormat4]
        unitsPerEm = fontInfo[:unitsPerEm]
        scale = nCurrentFontSize / unitsPerEm
        
        # Single pipeline: decode → shape → bidi → glyphs + width
        codepoints = utf8ToCodepoints(text)
        cpLen = len(codepoints)
        if cpLen = 0 return 0 ok
        
        shaped = shapeArabicText(codepoints)
        reordered = bidiReorder(shaped)
        
        reLen = len(reordered)
        cidString = copy(char(0) + char(0), reLen)
        totalWidth = 0
        
        for i = 1 to reLen
            cp = reordered[i]
            gid = ttfGetGlyphID(cmapF4, cp)
            cid = registerGlyphMapping(ttfIdx, cp, gid)
            
            pos = (i - 1) * 2 + 1
            cidString[pos] = char((cid >> 8) & 0xFF)
            cidString[pos + 1] = char(cid & 0xFF)
            
            w = ttfGetGlyphWidth(fontInfo, gid)
            totalWidth += w * scale
        next
        
        # Draw at left edge x, offset right by totalWidth to get right edge
        drawX = x   # This is the left edge; drawArabicText uses right edge
        
        rgb = pdfRGBNorm(aTextColor)
        hexStr = binToHex(cidString)
        stream = "BT" + char(10) +
                 "/" + fontId + " " + pdfNum(nCurrentFontSize) + " Tf" + char(10) +
                 pdfNum(rgb[1]) + " " + pdfNum(rgb[2]) + " " + pdfNum(rgb[3]) + " rg" + char(10) +
                 pdfNum(drawX) + " " + pdfNum(y) + " Td" + char(10) +
                 "<" + hexStr + "> Tj" + char(10) +
                 "ET" + char(10)
        
        appendToPage(stream)
        return totalWidth
    
    # Get width of Arabic text in LTR cell context
    func getArabicTextWidthInCell text
        return getArabicTextWidth(text)
    
    # Draw Arabic text centered at x
    func drawArabicTextCentered text, x, y
        w = getArabicTextWidth(text)
        drawArabicText(text, x + w / 2, y)
        return w
    
    # Get width of Arabic text in points
    func getArabicTextWidth text
        ttfIdx = findTTFFont(cCurrentFont)
        if ttfIdx = 0 return getTextWidth(text) ok
        
        fontInfo = aTTFFonts[ttfIdx][:info]
        cmapF4 = fontInfo[:cmapFormat4]
        unitsPerEm = fontInfo[:unitsPerEm]
        scale = nCurrentFontSize / unitsPerEm
        
        codepoints = utf8ToCodepoints(text)
        shaped = shapeArabicText(codepoints)
        
        totalWidth = 0
        shapedLen = len(shaped)
        for i = 1 to shapedLen
            cp = shaped[i]
            if !isArabicDiacritic(cp)
                gid = ttfGetGlyphID(cmapF4, cp)
                w = ttfGetGlyphWidth(fontInfo, gid)
                totalWidth += w * scale
            ok
        next
        
        return totalWidth
    
    # Draw Arabic paragraph (RTL, right-aligned word wrap)
    func drawArabicParagraph text, x, y, maxWidth, lineHeight
        if lineHeight = NULL lineHeight = nCurrentFontSize * 1.4 ok
        
        # Split by spaces (preserve Arabic word boundaries)
        words = []
        word = ""
        codepoints = utf8ToCodepoints(text)
        cpLen = len(codepoints)
        
        for i = 1 to cpLen
            if codepoints[i] = 32  # space
                if len(word) > 0
                    words + word
                    word = ""
                ok
            else
                # Rebuild UTF-8 for this codepoint
                word += codepointToUTF8(codepoints[i])
            ok
        next
        if len(word) > 0
            words + word
        ok
        
        # Build lines right-to-left
        rightEdge = x
        currentLine = ""
        currentY = y
        
        wordsLen = len(words)
        for i = 1 to wordsLen
            if len(currentLine) > 0
                testLine = currentLine + " " + words[i]
            else
                testLine = words[i]
            ok
            
            testWidth = getArabicTextWidth(testLine)
            
            if testWidth > maxWidth and len(currentLine) > 0
                drawArabicText(currentLine, rightEdge, currentY)
                currentY -= lineHeight
                currentLine = words[i]
            else
                currentLine = testLine
            ok
        next
        
        if len(currentLine) > 0
            drawArabicText(currentLine, rightEdge, currentY)
            currentY -= lineHeight
        ok
        
        return currentY
    
    # ========================================================================
    # Color Settings
    # ========================================================================
    
    func setTextColor color
        aTextColor = pdfColorToRGB(color)
        return self
    
    func setFillColor color
        aFillColor = pdfColorToRGB(color)
        return self
    
    func setStrokeColor color
        aStrokeColor = pdfColorToRGB(color)
        return self
    
    # ========================================================================
    # Line Settings
    # ========================================================================
    
    func setLineWidth width
        nLineWidth = width
        return self
    
    func setLineCap cap
        nLineCap = cap
        return self
    
    func setLineJoin join
        nLineJoin = join
        return self
    
    func setDash pattern, phase
        if pattern = NULL or len(pattern) = 0
            cDashPattern = "[] 0"
        else
            cDashPattern = "[" 
            patternLen = len(pattern)
            for i = 1 to patternLen
                if i > 1 cDashPattern += " " ok
                cDashPattern += pdfNum(pattern[i])
            next
            cDashPattern += "] " + pdfNum(phase)
        ok
        return self
    
    func resetDash
        cDashPattern = "[] 0"
        return self
    
    # ========================================================================
    # Text Drawing
    # ========================================================================
    
    func drawText text, x, y
        stream = "BT" + char(10)
        
        # Font
        fontId = getFontId(cCurrentFont)
        stream += "/" + fontId + " " + pdfNum(nCurrentFontSize) + " Tf" + char(10)
        
        # Color
        rgb = pdfRGBNorm(aTextColor)
        stream += pdfNum(rgb[1]) + " " + pdfNum(rgb[2]) + " " + pdfNum(rgb[3]) + " rg" + char(10)
        
        # Position (PDF origin is bottom-left)
        stream += pdfNum(x) + " " + pdfNum(y) + " Td" + char(10)
        
        # Text
        stream += "(" + pdfEscapeText(text) + ") Tj" + char(10)
        stream += "ET" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawTextAligned text, x, y, width, align
        textW = getTextWidth(text)
        
        switch align
            on PDF_ALIGN_LEFT
                drawText(text, x, y)
            on PDF_ALIGN_CENTER
                drawText(text, x + (width - textW) / 2, y)
            on PDF_ALIGN_RIGHT
                drawText(text, x + width - textW, y)
        off
        
        return self
    
    func drawTextCentered text, x, y
        textW = getTextWidth(text)
        drawText(text, x - textW / 2, y)
        return self
    
    func drawTextRight text, x, y
        textW = getTextWidth(text)
        drawText(text, x - textW, y)
        return self
    
    # ========================================================================
    # Paragraph Drawing
    # ========================================================================
    
    func drawParagraph text, x, y, maxWidth, lineHeight
        if lineHeight = NULL lineHeight = nCurrentFontSize * 1.2 ok
        
        words = pdfSplitWords(text)
        wordsLen = len(words)
        
        currentLine = ""
        currentY = y
        
        for i = 1 to wordsLen
            testLine = currentLine
            if len(testLine) > 0
                testLine += " "
            ok
            testLine += words[i]
            
            testWidth = getTextWidth(testLine)
            
            if testWidth > maxWidth and len(currentLine) > 0
                drawText(currentLine, x, currentY)
                currentY -= lineHeight
                currentLine = words[i]
            else
                currentLine = testLine
            ok
        next
        
        if len(currentLine) > 0
            drawText(currentLine, x, currentY)
            currentY -= lineHeight
        ok
        
        return currentY
    
    func drawParagraphAligned text, x, y, maxWidth, lineHeight, align
        if lineHeight = NULL lineHeight = nCurrentFontSize * 1.2 ok
        
        words = pdfSplitWords(text)
        wordsLen = len(words)
        
        currentLine = ""
        currentY = y
        
        for i = 1 to wordsLen
            testLine = currentLine
            if len(testLine) > 0
                testLine += " "
            ok
            testLine += words[i]
            
            testWidth = getTextWidth(testLine)
            
            if testWidth > maxWidth and len(currentLine) > 0
                drawTextAligned(currentLine, x, currentY, maxWidth, align)
                currentY -= lineHeight
                currentLine = words[i]
            else
                currentLine = testLine
            ok
        next
        
        if len(currentLine) > 0
            drawTextAligned(currentLine, x, currentY, maxWidth, align)
            currentY -= lineHeight
        ok
        
        return currentY
    
    # ========================================================================
    # Drawing Primitives
    # ========================================================================
    
    func drawLine x1, y1, x2, y2
        stream = ""
        rgb = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(rgb[1]) + " " + pdfNum(rgb[2]) + " " + pdfNum(rgb[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        stream += cDashPattern + " d" + char(10)
        stream += pdfNum(x1) + " " + pdfNum(y1) + " m" + char(10)
        stream += pdfNum(x2) + " " + pdfNum(y2) + " l" + char(10)
        stream += "S" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawRect x, y, width, height
        stream = ""
        rgb = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(rgb[1]) + " " + pdfNum(rgb[2]) + " " + pdfNum(rgb[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        stream += pdfNum(x) + " " + pdfNum(y) + " " + pdfNum(width) + " " + pdfNum(height) + " re" + char(10)
        stream += "S" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawFilledRect x, y, width, height
        stream = ""
        fRGB = pdfRGBNorm(aFillColor)
        sRGB = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(fRGB[1]) + " " + pdfNum(fRGB[2]) + " " + pdfNum(fRGB[3]) + " rg" + char(10)
        stream += pdfNum(sRGB[1]) + " " + pdfNum(sRGB[2]) + " " + pdfNum(sRGB[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        stream += pdfNum(x) + " " + pdfNum(y) + " " + pdfNum(width) + " " + pdfNum(height) + " re" + char(10)
        stream += "B" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawFilledRectNoStroke x, y, width, height
        stream = ""
        fRGB = pdfRGBNorm(aFillColor)
        stream += pdfNum(fRGB[1]) + " " + pdfNum(fRGB[2]) + " " + pdfNum(fRGB[3]) + " rg" + char(10)
        stream += pdfNum(x) + " " + pdfNum(y) + " " + pdfNum(width) + " " + pdfNum(height) + " re" + char(10)
        stream += "f" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawCircle cx, cy, r
        # Approximate circle with bezier curves
        k = 0.5523 * r
        stream = ""
        sRGB = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(sRGB[1]) + " " + pdfNum(sRGB[2]) + " " + pdfNum(sRGB[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        
        stream += pdfNum(cx + r) + " " + pdfNum(cy) + " m" + char(10)
        stream += pdfNum(cx + r) + " " + pdfNum(cy + k) + " " + pdfNum(cx + k) + " " + pdfNum(cy + r) + " " + pdfNum(cx) + " " + pdfNum(cy + r) + " c" + char(10)
        stream += pdfNum(cx - k) + " " + pdfNum(cy + r) + " " + pdfNum(cx - r) + " " + pdfNum(cy + k) + " " + pdfNum(cx - r) + " " + pdfNum(cy) + " c" + char(10)
        stream += pdfNum(cx - r) + " " + pdfNum(cy - k) + " " + pdfNum(cx - k) + " " + pdfNum(cy - r) + " " + pdfNum(cx) + " " + pdfNum(cy - r) + " c" + char(10)
        stream += pdfNum(cx + k) + " " + pdfNum(cy - r) + " " + pdfNum(cx + r) + " " + pdfNum(cy - k) + " " + pdfNum(cx + r) + " " + pdfNum(cy) + " c" + char(10)
        stream += "S" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawFilledCircle cx, cy, r
        k = 0.5523 * r
        stream = ""
        fRGB = pdfRGBNorm(aFillColor)
        sRGB = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(fRGB[1]) + " " + pdfNum(fRGB[2]) + " " + pdfNum(fRGB[3]) + " rg" + char(10)
        stream += pdfNum(sRGB[1]) + " " + pdfNum(sRGB[2]) + " " + pdfNum(sRGB[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        
        stream += pdfNum(cx + r) + " " + pdfNum(cy) + " m" + char(10)
        stream += pdfNum(cx + r) + " " + pdfNum(cy + k) + " " + pdfNum(cx + k) + " " + pdfNum(cy + r) + " " + pdfNum(cx) + " " + pdfNum(cy + r) + " c" + char(10)
        stream += pdfNum(cx - k) + " " + pdfNum(cy + r) + " " + pdfNum(cx - r) + " " + pdfNum(cy + k) + " " + pdfNum(cx - r) + " " + pdfNum(cy) + " c" + char(10)
        stream += pdfNum(cx - r) + " " + pdfNum(cy - k) + " " + pdfNum(cx - k) + " " + pdfNum(cy - r) + " " + pdfNum(cx) + " " + pdfNum(cy - r) + " c" + char(10)
        stream += pdfNum(cx + k) + " " + pdfNum(cy - r) + " " + pdfNum(cx + r) + " " + pdfNum(cy - k) + " " + pdfNum(cx + r) + " " + pdfNum(cy) + " c" + char(10)
        stream += "B" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawEllipse cx, cy, rx, ry
        kx = 0.5523 * rx
        ky = 0.5523 * ry
        stream = ""
        sRGB = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(sRGB[1]) + " " + pdfNum(sRGB[2]) + " " + pdfNum(sRGB[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        
        stream += pdfNum(cx + rx) + " " + pdfNum(cy) + " m" + char(10)
        stream += pdfNum(cx + rx) + " " + pdfNum(cy + ky) + " " + pdfNum(cx + kx) + " " + pdfNum(cy + ry) + " " + pdfNum(cx) + " " + pdfNum(cy + ry) + " c" + char(10)
        stream += pdfNum(cx - kx) + " " + pdfNum(cy + ry) + " " + pdfNum(cx - rx) + " " + pdfNum(cy + ky) + " " + pdfNum(cx - rx) + " " + pdfNum(cy) + " c" + char(10)
        stream += pdfNum(cx - rx) + " " + pdfNum(cy - ky) + " " + pdfNum(cx - kx) + " " + pdfNum(cy - ry) + " " + pdfNum(cx) + " " + pdfNum(cy - ry) + " c" + char(10)
        stream += pdfNum(cx + kx) + " " + pdfNum(cy - ry) + " " + pdfNum(cx + rx) + " " + pdfNum(cy - ky) + " " + pdfNum(cx + rx) + " " + pdfNum(cy) + " c" + char(10)
        stream += "S" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawFilledEllipse cx, cy, rx, ry
        kx = 0.5523 * rx
        ky = 0.5523 * ry
        stream = ""
        fRGB = pdfRGBNorm(aFillColor)
        sRGB = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(fRGB[1]) + " " + pdfNum(fRGB[2]) + " " + pdfNum(fRGB[3]) + " rg" + char(10)
        stream += pdfNum(sRGB[1]) + " " + pdfNum(sRGB[2]) + " " + pdfNum(sRGB[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        
        stream += pdfNum(cx + rx) + " " + pdfNum(cy) + " m" + char(10)
        stream += pdfNum(cx + rx) + " " + pdfNum(cy + ky) + " " + pdfNum(cx + kx) + " " + pdfNum(cy + ry) + " " + pdfNum(cx) + " " + pdfNum(cy + ry) + " c" + char(10)
        stream += pdfNum(cx - kx) + " " + pdfNum(cy + ry) + " " + pdfNum(cx - rx) + " " + pdfNum(cy + ky) + " " + pdfNum(cx - rx) + " " + pdfNum(cy) + " c" + char(10)
        stream += pdfNum(cx - rx) + " " + pdfNum(cy - ky) + " " + pdfNum(cx - kx) + " " + pdfNum(cy - ry) + " " + pdfNum(cx) + " " + pdfNum(cy - ry) + " c" + char(10)
        stream += pdfNum(cx + kx) + " " + pdfNum(cy - ry) + " " + pdfNum(cx + rx) + " " + pdfNum(cy - ky) + " " + pdfNum(cx + rx) + " " + pdfNum(cy) + " c" + char(10)
        stream += "B" + char(10)
        
        appendToPage(stream)
        return self
    
    func drawPolygon points
        stream = ""
        fRGB = pdfRGBNorm(aFillColor)
        sRGB = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(fRGB[1]) + " " + pdfNum(fRGB[2]) + " " + pdfNum(fRGB[3]) + " rg" + char(10)
        stream += pdfNum(sRGB[1]) + " " + pdfNum(sRGB[2]) + " " + pdfNum(sRGB[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        
        pointsLen = len(points)
        for i = 1 to pointsLen
            pt = points[i]
            if i = 1
                stream += pdfNum(pt[1]) + " " + pdfNum(pt[2]) + " m" + char(10)
            else
                stream += pdfNum(pt[1]) + " " + pdfNum(pt[2]) + " l" + char(10)
            ok
        next
        stream += "B" + char(10)
        
        appendToPage(stream)
        return self
    
    # ========================================================================
    # Horizontal Rule
    # ========================================================================
    
    func drawHorizontalRule x, y, width
        drawLine(x, y, x + width, y)
        return self
    
    # ========================================================================
    # Lists
    # ========================================================================
    
    func drawBulletList items, x, y, lineHeight
        if lineHeight = NULL lineHeight = nCurrentFontSize * 1.4 ok
        
        currentY = y
        itemsLen = len(items)
        for i = 1 to itemsLen
            # Bullet character
            drawText(char(149), x, currentY)
            # Text
            drawText(items[i], x + 15, currentY)
            currentY -= lineHeight
        next
        
        return currentY
    
    func drawNumberedList items, x, y, lineHeight
        if lineHeight = NULL lineHeight = nCurrentFontSize * 1.4 ok
        
        currentY = y
        itemsLen = len(items)
        for i = 1 to itemsLen
            numStr = "" + i + "."
            drawText(numStr, x, currentY)
            drawText(items[i], x + 20, currentY)
            currentY -= lineHeight
        next
        
        return currentY
    
    # ========================================================================
    # Tables
    # ========================================================================
    
    func drawTable data, x, y, colWidths, options
        if options = NULL options = [] ok
        
        rowHeight = 20
        if options[:rowHeight] != NULL rowHeight = options[:rowHeight] ok
        
        headerBg = [66, 133, 244]
        if options[:headerBg] != NULL headerBg = pdfColorToRGB(options[:headerBg]) ok
        
        headerFg = [255, 255, 255]
        if options[:headerFg] != NULL headerFg = pdfColorToRGB(options[:headerFg]) ok
        
        borderColor = [0, 0, 0]
        if options[:borderColor] != NULL borderColor = pdfColorToRGB(options[:borderColor]) ok
        
        evenRowBg = [240, 240, 240]
        if options[:evenRowBg] != NULL evenRowBg = pdfColorToRGB(options[:evenRowBg]) ok
        
        fontSize = 10
        if options[:fontSize] != NULL fontSize = options[:fontSize] ok
        
        showHeader = true
        if options[:showHeader] = false showHeader = false ok
        
        padding = 5
        if options[:padding] != NULL padding = options[:padding] ok
        
        # Arabic font support: if set, cells with Arabic text use this font
        arabicFont = ""
        if options[:arabicFont] != NULL arabicFont = options[:arabicFont] ok
        
        dataLen = len(data)
        currentY = y
        
        # Save current state
        savedFont = cCurrentFont
        savedSize = nCurrentFontSize
        savedTextColor = aTextColor
        
        for rowIdx = 1 to dataLen
            row = data[rowIdx]
            colsLen = len(row)
            
            # Background
            if rowIdx = 1 and showHeader
                setFillColor(headerBg)
                setStrokeColor(borderColor)
                setLineWidth(0.5)
                drawFilledRect(x, currentY - rowHeight, pdfSumList(colWidths), rowHeight)
            elseif rowIdx % 2 = 0
                setFillColor(evenRowBg)
                setStrokeColor(borderColor)
                setLineWidth(0.5)
                drawFilledRect(x, currentY - rowHeight, pdfSumList(colWidths), rowHeight)
            else
                setStrokeColor(borderColor)
                setLineWidth(0.5)
                drawRect(x, currentY - rowHeight, pdfSumList(colWidths), rowHeight)
            ok
            
            # Cell borders and text
            cellX = x
            for colIdx = 1 to colsLen
                colW = colWidths[colIdx]
                
                # Cell border
                setStrokeColor(borderColor)
                setLineWidth(0.5)
                drawRect(cellX, currentY - rowHeight, colW, rowHeight)
                
                # Determine text color for this row
                if rowIdx = 1 and showHeader
                    setTextColor(headerFg)
                else
                    setTextColor("black")
                ok
                
                cellText = "" + row[colIdx]
                textY = currentY - rowHeight + padding + 2
                
                # Check if cell has Arabic content and we have an Arabic font
                if len(arabicFont) > 0 and containsArabic(cellText)
                    # Split cell into Latin and Arabic segments
                    segments = splitMixedText(cellText)
                    drawX = cellX + padding
                    segLen = len(segments)
                    for si = 1 to segLen
                        seg = segments[si]
                        segText = seg[1]
                        segIsArabic = seg[2]
                        
                        if segIsArabic
                            # Draw Arabic segment in LTR cell context
                            # drawArabicTextInCell returns width, no need for separate width call
                            setFont(arabicFont, fontSize)
                            segW = drawArabicTextInCell(segText, drawX, textY)
                            drawX += segW
                        else
                            # Draw Latin segment using standard font
                            if rowIdx = 1 and showHeader
                                setFont(PDF_HELVETICA_BOLD, fontSize)
                            else
                                setFont(PDF_HELVETICA, fontSize)
                            ok
                            drawText(segText, drawX, textY)
                            drawX += getTextWidth(segText)
                        ok
                    next
                else
                    # Pure Latin text - use standard font
                    if rowIdx = 1 and showHeader
                        setFont(PDF_HELVETICA_BOLD, fontSize)
                    else
                        setFont(PDF_HELVETICA, fontSize)
                    ok
                    drawText(cellText, cellX + padding, textY)
                ok
                
                cellX += colW
            next
            
            currentY -= rowHeight
        next
        
        # Restore state
        cCurrentFont = savedFont
        nCurrentFontSize = savedSize
        aTextColor = savedTextColor
        
        return currentY
    
    # ========================================================================
    # Simple Table (auto column widths)
    # ========================================================================
    
    func drawSimpleTable data, x, y, totalWidth, options
        if len(data) = 0 return y ok
        
        numCols = len(data[1])
        colWidth = totalWidth / numCols
        colWidths = []
        for i = 1 to numCols
            colWidths + colWidth
        next
        
        return drawTable(data, x, y, colWidths, options)
    
    # ========================================================================
    # Images (JPEG, PNG, BMP) - Pure Ring parsing
    # ========================================================================
    
    func drawImage filename, x, y, width, height
        if !fexists(filename) return self ok
        
        nImageCount++
        imageId = "Img" + nImageCount
        
        # Read file
        imageData = read(filename)
        imgDataLen = len(imageData)
        if imgDataLen < 8 return self ok
        
        b1 = ascii(imageData[1])
        b2 = ascii(imageData[2])
        
        imgPixelWidth = 0
        imgPixelHeight = 0
        imgFilter = ""
        imgColorSpace = "DeviceRGB"
        imgBPC = 8
        imgStreamData = ""
        imgDecodeParms = ""
        
        if b1 = 0xFF and b2 = 0xD8
            # ---- JPEG: embed as-is with DCTDecode ----
            imgFilter = "/DCTDecode"
            imgStreamData = imageData
            jpegInfo = parseJPEGDimensions(imageData)
            imgPixelWidth = jpegInfo[1]
            imgPixelHeight = jpegInfo[2]
            
        elseif b1 = 0x89 and b2 = 0x50
            # ---- PNG: embed IDAT directly with FlateDecode + Predictor ----
            # PDF readers handle zlib decompression and PNG filter reversal
            pngInfo = pdfParsePNGInfo(imageData)
            imgPixelWidth = pngInfo[:width]
            imgPixelHeight = pngInfo[:height]
            
            idatData = extractPNGIdatChunks(imageData)
            if len(idatData) > 0
                colorType = pngInfo[:colorType]
                bitDepth = pngInfo[:bitDepth]
                
                # Colors per pixel for the predictor
                colors = 3
                if colorType = 0 colors = 1 ok      # Grayscale
                if colorType = 2 colors = 3 ok      # RGB
                if colorType = 4 colors = 2 ok      # Gray + Alpha
                if colorType = 6 colors = 4 ok      # RGBA
                
                imgStreamData = idatData
                imgFilter = "/FlateDecode"
                imgDecodeParms = "<< /Predictor 15 /Colors " + colors +
                                 " /BitsPerComponent " + bitDepth +
                                 " /Columns " + imgPixelWidth + " >>"
                imgBPC = bitDepth
                
                if colorType = 0
                    # Grayscale -> simple DeviceGray
                    imgColorSpace = "DeviceGray"
                elseif colorType = 2
                    # RGB -> simple DeviceRGB
                    imgColorSpace = "DeviceRGB"
                elseif colorType = 4
                    # Gray+Alpha -> DeviceN (2 components, drop alpha)
                    imgColorSpace = "DeviceN_GrayAlpha"
                elseif colorType = 6
                    # RGBA -> DeviceN (4 components, drop alpha)
                    imgColorSpace = "DeviceN_RGBA"
                else
                    imgColorSpace = "DeviceRGB"
                ok
            ok
            
        elseif b1 = 0x42 and b2 = 0x4D
            # ---- BMP: parse pixel data directly ----
            bmpInfo = pdfParseBMPInfo(imageData)
            imgPixelWidth = bmpInfo[:width]
            imgPixelHeight = bmpInfo[:height]
            
            bmpData = extractBMPPixels(imageData, bmpInfo)
            if len(bmpData) > 0
                imgStreamData = bmpData
                imgFilter = ""
            ok
        ok
        
        if len(imgStreamData) = 0 return self ok
        
        # Fallback dimensions
        if imgPixelWidth = 0 imgPixelWidth = width ok
        if imgPixelHeight = 0 imgPixelHeight = height ok
        
        aImages + [
            :id = imageId,
            :data = imgStreamData,
            :pixelWidth = imgPixelWidth,
            :pixelHeight = imgPixelHeight,
            :displayWidth = width,
            :displayHeight = height,
            :colorSpace = imgColorSpace,
            :bpc = imgBPC,
            :filter = imgFilter,
            :decodeParms = imgDecodeParms,
            :x = x,
            :y = y,
            :page = nCurrentPage
        ]
        
        # Add image reference to page stream
        stream = "q" + char(10)
        stream += pdfNum(width) + " 0 0 " + pdfNum(height) + " " + pdfNum(x) + " " + pdfNum(y) + " cm" + char(10)
        stream += "/" + imageId + " Do" + char(10)
        stream += "Q" + char(10)
        
        appendToPage(stream)
        return self
    
    # Parse JPEG to find width/height from SOF marker
    func parseJPEGDimensions data
        dataLen = len(data)
        pos = 3   # Skip FF D8
        while pos < dataLen - 8
            if ascii(data[pos]) != 0xFF
                pos++
                loop
            ok
            marker = ascii(data[pos + 1])
            
            # SOF markers (0xC0 - 0xC3)
            if marker >= 0xC0 and marker <= 0xC3
                imgH = ascii(data[pos + 5]) * 256 + ascii(data[pos + 6])
                imgW = ascii(data[pos + 7]) * 256 + ascii(data[pos + 8])
                return [imgW, imgH]
            ok
            
            # Skip to next marker
            if pos + 2 <= dataLen
                segLen = ascii(data[pos + 2]) * 256 + ascii(data[pos + 3])
                pos += segLen + 2
            else
                pos += 2
            ok
        end
        return [0, 0]
    
    # Extract all IDAT chunks from PNG and concatenate them
    func extractPNGIdatChunks data
        dataLen = len(data)
        pos = 9    # Skip 8-byte PNG signature
        idatParts = []
        totalLen = 0
        
        while pos + 12 <= dataLen
            # Each chunk: 4 bytes length + 4 bytes type + data + 4 bytes CRC
            chunkLen = ascii(data[pos]) * 16777216 + ascii(data[pos+1]) * 65536 + ascii(data[pos+2]) * 256 + ascii(data[pos+3])
            chunkType = substr(data, pos + 4, 4)
            
            if chunkType = "IDAT"
                if chunkLen > 0 and pos + 7 + chunkLen <= dataLen
                    idatParts + substr(data, pos + 8, chunkLen)
                    totalLen += chunkLen
                ok
            ok
            
            if chunkType = "IEND" exit ok
            
            # Move to next chunk: 4(length) + 4(type) + chunkLen(data) + 4(CRC)
            pos += 12 + chunkLen
        end
        
        if totalLen = 0 return "" ok
        
        # Concatenate all IDAT data
        result = ""
        idatCount = len(idatParts)
        for i = 1 to idatCount
            result += idatParts[i]
        next
        return result
    
    # Extract RGB pixel data from BMP file
    # BMP stores pixels bottom-up in BGR order with row padding
    func extractBMPPixels data, bmpInfo
        imgW = bmpInfo[:width]
        imgH = bmpInfo[:height]
        bpp = bmpInfo[:bpp]
        dataOffset = bmpInfo[:dataOffset]
        
        # Only support 24-bit (RGB) BMPs for now
        if bpp != 24 return "" ok
        
        dataLen = len(data)
        rowSize = imgW * 3
        # BMP rows are padded to 4-byte boundaries
        bmpRowSize = floor((imgW * 3 + 3) / 4) * 4
        
        # Build rows using substr (fast) instead of per-pixel loops
        rows = []
        for row = 0 to imgH - 1
            # BMP is bottom-up, so read from last row first
            srcRow = imgH - 1 - row
            srcOffset = dataOffset + 1 + srcRow * bmpRowSize
            
            if srcOffset + rowSize - 1 <= dataLen
                rowData = substr(data, srcOffset, rowSize)
                # Swap BGR to RGB: swap every 3-byte triplet
                swapped = rowData
                for col = 0 to imgW - 1
                    pos = col * 3 + 1
                    tmp = swapped[pos]
                    swapped[pos] = swapped[pos + 2]
                    swapped[pos + 2] = tmp
                next
                rows + swapped
            ok
        next
        
        # Join all rows
        result = ""
        rowCount = len(rows)
        for i = 1 to rowCount
            result += rows[i]
        next
        return result
    
    # ========================================================================
    # Page Numbers
    # ========================================================================
    
    func enablePageNumbers
        lPageNumbers = true
        return self
    
    func setPageNumberFormat format
        cPageNumberFormat = format
        return self
    
    func setPageNumberPosition x, y
        nPageNumberX = x
        nPageNumberY = y
        return self
    
    # ========================================================================
    # Headers and Footers
    # ========================================================================
    
    func setHeader text, align
        if align = NULL align = PDF_ALIGN_LEFT ok
        aHeaders = [:text = text, :align = align]
        return self
    
    func setFooter text, align
        if align = NULL align = PDF_ALIGN_LEFT ok
        aFooters = [:text = text, :align = align]
        return self
    
    # ========================================================================
    # Watermark
    # ========================================================================
    
    func drawWatermark text, options
        if options = NULL options = [] ok
        
        fontSize = 60
        if options[:fontSize] != NULL fontSize = options[:fontSize] ok
        
        color = [200, 200, 200]
        if options[:color] != NULL color = pdfColorToRGB(options[:color]) ok
        
        angle = 45
        if options[:angle] != NULL angle = options[:angle] ok
        
        pageW = getPageWidth()
        pageH = getPageHeight()
        cx = pageW / 2
        cy = pageH / 2
        
        # Rotation matrix
        rad = angle * 3.14159 / 180
        cosA = cos(rad)
        sinA = sin(rad)
        
        stream = "q" + char(10)
        
        # Set color with transparency
        rgb = pdfRGBNorm(color)
        stream += pdfNum(rgb[1]) + " " + pdfNum(rgb[2]) + " " + pdfNum(rgb[3]) + " rg" + char(10)
        
        # Transform matrix for rotation around center
        stream += pdfNum(cosA) + " " + pdfNum(sinA) + " " + pdfNum(-sinA) + " " + pdfNum(cosA) + " " + pdfNum(cx) + " " + pdfNum(cy) + " cm" + char(10)
        
        # Draw text centered at origin
        fontId = getFontId(PDF_HELVETICA_BOLD)
        stream += "BT" + char(10)
        stream += "/" + fontId + " " + pdfNum(fontSize) + " Tf" + char(10)
        
        textW = len(text) * fontSize * 0.5
        stream += pdfNum(-textW / 2) + " 0 Td" + char(10)
        stream += "(" + pdfEscapeText(text) + ") Tj" + char(10)
        stream += "ET" + char(10)
        stream += "Q" + char(10)
        
        appendToPage(stream)
        return self
    
    # ========================================================================
    # Charts
    # ========================================================================
    
    func drawBarChart chartData, x, y, width, height, options
        if options = NULL options = [] ok
        
        labels = chartData[:labels]
        values = chartData[:values]
        labelsLen = len(labels)
        
        colors = [[66, 133, 244], [234, 67, 53], [251, 188, 4], [52, 168, 83], [255, 109, 0], [171, 71, 188]]
        if options[:colors] != NULL colors = options[:colors] ok
        
        # Find max
        maxVal = 0
        for i = 1 to labelsLen
            if values[i] > maxVal maxVal = values[i] ok
        next
        if maxVal = 0 maxVal = 1 ok
        
        # Draw axes
        setStrokeColor("darkgray")
        setLineWidth(1)
        drawLine(x, y, x, y + height)
        drawLine(x, y, x + width, y)
        
        # Draw bars
        barWidth = (width - 20) / labelsLen * 0.7
        barGap = (width - 20) / labelsLen * 0.3
        
        for i = 1 to labelsLen
            barH = (values[i] / maxVal) * (height - 20)
            barX = x + 10 + (i - 1) * (barWidth + barGap)
            
            colorIdx = ((i - 1) % len(colors)) + 1
            setFillColor(colors[colorIdx])
            setStrokeColor(colors[colorIdx])
            drawFilledRect(barX, y, barWidth, barH)
            
            # Label
            setFont(PDF_HELVETICA, 8)
            setTextColor("black")
            drawTextCentered(labels[i], barX + barWidth / 2, y - 12)
            
            # Value
            if options[:showValues] = true
                drawTextCentered("" + values[i], barX + barWidth / 2, y + barH + 5)
            ok
        next
        
        # Title
        if options[:title] != NULL
            setFont(PDF_HELVETICA_BOLD, 12)
            setTextColor("black")
            drawTextCentered(options[:title], x + width / 2, y + height + 10)
        ok
        
        return self
    
    func drawPieChart chartData, cx, cy, radius, options
        if options = NULL options = [] ok
        
        labels = chartData[:labels]
        values = chartData[:values]
        labelsLen = len(labels)
        
        colors = [[66, 133, 244], [234, 67, 53], [251, 188, 4], [52, 168, 83], [255, 109, 0], [171, 71, 188]]
        if options[:colors] != NULL colors = options[:colors] ok
        
        # Total
        total = 0
        for i = 1 to labelsLen
            total += values[i]
        next
        if total = 0 total = 1 ok
        
        # Draw slices
        startAngle = 0
        for i = 1 to labelsLen
            sliceAngle = (values[i] / total) * 360
            endAngle = startAngle + sliceAngle
            
            colorIdx = ((i - 1) % len(colors)) + 1
            setFillColor(colors[colorIdx])
            setStrokeColor("white")
            setLineWidth(1)
            
            drawPieSlice(cx, cy, radius, startAngle, endAngle)
            startAngle = endAngle
        next
        
        # Legend
        if options[:showLegend] = true
            legendX = cx + radius + 20
            legendY = cy + radius - 10
            
            for i = 1 to labelsLen
                colorIdx = ((i - 1) % len(colors)) + 1
                setFillColor(colors[colorIdx])
                setStrokeColor(colors[colorIdx])
                drawFilledRect(legendX, legendY - (i - 1) * 16, 10, 10)
                
                pct = floor((values[i] / total) * 100)
                setFont(PDF_HELVETICA, 9)
                setTextColor("black")
                drawText(labels[i] + " (" + pct + "%)", legendX + 14, legendY - (i - 1) * 16 + 1)
            next
        ok
        
        return self
    
    # Draw a pie slice
    func drawPieSlice cx, cy, r, startAngle, endAngle
        startRad = startAngle * 3.14159 / 180
        endRad = endAngle * 3.14159 / 180
        
        x1 = cx + r * cos(startRad)
        y1 = cy + r * sin(startRad)
        x2 = cx + r * cos(endRad)
        y2 = cy + r * sin(endRad)
        
        stream = ""
        fRGB = pdfRGBNorm(aFillColor)
        sRGB = pdfRGBNorm(aStrokeColor)
        stream += pdfNum(fRGB[1]) + " " + pdfNum(fRGB[2]) + " " + pdfNum(fRGB[3]) + " rg" + char(10)
        stream += pdfNum(sRGB[1]) + " " + pdfNum(sRGB[2]) + " " + pdfNum(sRGB[3]) + " RG" + char(10)
        stream += pdfNum(nLineWidth) + " w" + char(10)
        
        # Move to center
        stream += pdfNum(cx) + " " + pdfNum(cy) + " m" + char(10)
        # Line to start
        stream += pdfNum(x1) + " " + pdfNum(y1) + " l" + char(10)
        
        # Arc approximation with bezier
        steps = ceil((endAngle - startAngle) / 90)
        if steps < 1 steps = 1 ok
        stepAngle = (endAngle - startAngle) / steps
        
        currentAngle = startAngle
        for s = 1 to steps
            nextAngle = currentAngle + stepAngle
            
            a1 = currentAngle * 3.14159 / 180
            a2 = nextAngle * 3.14159 / 180
            aMid = (a1 + a2) / 2
            
            # Control point distance
            halfAngle = (a2 - a1) / 2
            dist = r * (4.0 / 3.0) * (1 - cos(halfAngle)) / sin(halfAngle)
            
            cpx1 = cx + r * cos(a1) - dist * sin(a1)
            cpy1 = cy + r * sin(a1) + dist * cos(a1)
            cpx2 = cx + r * cos(a2) + dist * sin(a2)
            cpy2 = cy + r * sin(a2) - dist * cos(a2)
            ex = cx + r * cos(a2)
            ey = cy + r * sin(a2)
            
            stream += pdfNum(cpx1) + " " + pdfNum(cpy1) + " " + pdfNum(cpx2) + " " + pdfNum(cpy2) + " " + pdfNum(ex) + " " + pdfNum(ey) + " c" + char(10)
            
            currentAngle = nextAngle
        next
        
        stream += "b" + char(10)
        
        appendToPage(stream)
        return self
    
    # ========================================================================
    # Graphics State
    # ========================================================================
    
    func saveState
        appendToPage("q" + char(10))
        return self
    
    func restoreState
        appendToPage("Q" + char(10))
        return self
    
    # ========================================================================
    # Text Width Calculation
    # ========================================================================
    
    func getTextWidth text
        # Approximate character widths for Helvetica (per 1000 units)
        avgWidth = 500
        
        if cCurrentFont = PDF_COURIER or cCurrentFont = PDF_COURIER_BOLD or
           cCurrentFont = PDF_COURIER_ITALIC or cCurrentFont = PDF_COURIER_BOLDITALIC
            avgWidth = 600
        ok
        
        textLen = len(text)
        totalWidth = 0
        for i = 1 to textLen
            c = ascii(text[i])
            if c >= 32 and c <= 126
                # Width lookup by ASCII code (faster than switch on strings)
                if c = 105 or c = 108 or c = 73 or c = 106    # i l I j
                    if c = 108 or c = 106   # l j
                        totalWidth += 222
                    else
                        totalWidth += 278   # i I
                    ok
                elseif c = 102 or c = 116 or c = 32 or c = 46 or c = 44  # f t space . ,
                    totalWidth += 278
                elseif c = 114 or c = 33   # r !
                    totalWidth += 333
                elseif c = 109 or c = 77   # m M
                    totalWidth += 833
                elseif c = 119   # w
                    totalWidth += 722
                elseif c = 87    # W
                    totalWidth += 944
                elseif c >= 65 and c <= 90  # Uppercase
                    totalWidth += 667
                else
                    totalWidth += avgWidth
                ok
            else
                totalWidth += avgWidth
            ok
        next
        
        return totalWidth * nCurrentFontSize / 1000
    
    # ========================================================================
    # Internal Helpers
    # ========================================================================
    
    func appendToPage stream
        if nCurrentPage >= 1 and nCurrentPage <= len(aPageStreams)
            aPageStreams[nCurrentPage] += stream
        ok
    
    func pdfSplitWords text
        words = []
        word = ""
        textLen = len(text)
        for i = 1 to textLen
            c = text[i]
            if c = " " or c = char(9)
                if len(word) > 0
                    words + word
                    word = ""
                ok
            elseif c = char(10) or c = char(13)
                if len(word) > 0
                    words + word
                    word = ""
                ok
            else
                word += c
            ok
        next
        if len(word) > 0
            words + word
        ok
        return words
    
    func pdfSumList lst
        total = 0
        listLen = len(lst)
        for i = 1 to listLen
            total += lst[i]
        next
        return total
    
    # ========================================================================
    # PDF File Generation
    # ========================================================================
    
    func save filename
        totalPages = len(aPages)
        
        # Add page numbers and headers/footers to each page
        for pg = 1 to totalPages
            savedPage = nCurrentPage
            nCurrentPage = pg
            
            # Header
            if len(aHeaders) > 0
                savedFont2 = cCurrentFont
                savedSize2 = nCurrentFontSize
                savedColor2 = aTextColor
                
                setFont(PDF_HELVETICA, 10)
                setTextColor("gray")
                
                headerText = aHeaders[:text]
                headerAlign = aHeaders[:align]
                pageW = getPageWidth()
                
                if headerAlign = PDF_ALIGN_LEFT
                    drawText(headerText, aMargins[1], getPageHeight() - aMargins[2] + 20)
                elseif headerAlign = PDF_ALIGN_CENTER
                    drawTextCentered(headerText, pageW / 2, getPageHeight() - aMargins[2] + 20)
                elseif headerAlign = PDF_ALIGN_RIGHT
                    drawTextRight(headerText, pageW - aMargins[3], getPageHeight() - aMargins[2] + 20)
                ok
                
                cCurrentFont = savedFont2
                nCurrentFontSize = savedSize2
                aTextColor = savedColor2
            ok
            
            # Footer
            if len(aFooters) > 0
                savedFont3 = cCurrentFont
                savedSize3 = nCurrentFontSize
                savedColor3 = aTextColor
                
                setFont(PDF_HELVETICA, 10)
                setTextColor("gray")
                
                footerText = aFooters[:text]
                footerAlign = aFooters[:align]
                pageW = getPageWidth()
                
                if footerAlign = PDF_ALIGN_LEFT
                    drawText(footerText, aMargins[1], aMargins[4] - 15)
                elseif footerAlign = PDF_ALIGN_CENTER
                    drawTextCentered(footerText, pageW / 2, aMargins[4] - 15)
                elseif footerAlign = PDF_ALIGN_RIGHT
                    drawTextRight(footerText, pageW - aMargins[3], aMargins[4] - 15)
                ok
                
                cCurrentFont = savedFont3
                nCurrentFontSize = savedSize3
                aTextColor = savedColor3
            ok
            
            # Page numbers
            if lPageNumbers
                savedFont4 = cCurrentFont
                savedSize4 = nCurrentFontSize
                savedColor4 = aTextColor
                
                setFont(PDF_HELVETICA, 10)
                setTextColor("gray")
                
                pnText = cPageNumberFormat
                pnText = substr(pnText, "{n}", "" + pg)
                pnText = substr(pnText, "{total}", "" + totalPages)
                
                pnX = nPageNumberX
                if pnX = -1
                    pnX = getPageWidth() / 2
                ok
                
                drawTextCentered(pnText, pnX, nPageNumberY)
                
                cCurrentFont = savedFont4
                nCurrentFontSize = savedSize4
                aTextColor = savedColor4
            ok
            
            nCurrentPage = savedPage
        next
        
        # Now build the PDF file using direct file I/O
        # (avoids huge string concatenation with image data)
        objectOffsets = []
        objectNum = 0
        bytePos = 0
        
        fp = fopen(filename, "wb")
        if fp = NULL return false ok
        
        # PDF Header (contains binary marker bytes)
        hdr = "%PDF-1.4" + char(10) + "%" + char(226) + char(227) + char(207) + char(211) + char(10)
        fwrite(fp, hdr)
        bytePos += len(hdr)
        
        # Object 1: Catalog
        objectNum++
        objectOffsets + bytePos
        chunk = "" + objectNum + " 0 obj" + char(10)
        chunk += "<< /Type /Catalog /Pages 2 0 R >>" + char(10)
        chunk += "endobj" + char(10)
        fputs(fp, chunk)
        bytePos += len(chunk)
        
        # Object 2: Pages - we need Kids, so build it now using a two-pass trick
        # First, calculate how many objects come before pages
        # Type1 fonts: 1 object each
        # TTF fonts: 6 objects each (Type0, CIDFont, FontDescriptor, FontStream, CIDToGIDMap, ToUnicode)
        # Then: tint functions + images
        fontMapLen = len(aFontMap)
        imagesLen = len(aImages)
        ttfLen = len(aTTFFonts)
        
        # Count font objects
        type1Count = 0
        ttfObjCount = 0
        for fi = 1 to fontMapLen
            isTTF = false
            if len(aFontMap[fi]) >= 3
                isTTF = aFontMap[fi][:isTTF]
            ok
            if isTTF
                ttfObjCount += 6   # Type0 + CIDFont + Descriptor + Stream + CIDToGIDMap + ToUnicode
            else
                type1Count++
            ok
        next
        totalFontObjects = type1Count + ttfObjCount
        
        # Count tint function objects (RGBA/GrayAlpha PNGs)
        tintFuncCount = 0
        for ii = 1 to imagesLen
            cs = aImages[ii][:colorSpace]
            if cs = "DeviceN_RGBA" or cs = "DeviceN_GrayAlpha"
                tintFuncCount++
            ok
        next
        
        fontObjectStart = 3  # Object 3 is first font
        afterFontsStart = fontObjectStart + totalFontObjects
        tintFuncObjectStart = afterFontsStart
        imageObjectStart = tintFuncObjectStart + tintFuncCount
        pageObjectStart = imageObjectStart + imagesLen
        
        # Build page object numbers (2 objects per page: page + content)
        pageObjNums = []
        for pg = 1 to totalPages
            pageObjNums + (pageObjectStart + (pg - 1) * 2)
        next
        
        # Now write Pages object with correct Kids
        objectNum++
        pagesObjNum = objectNum
        objectOffsets + bytePos
        chunk = "" + pagesObjNum + " 0 obj" + char(10)
        chunk += "<< /Type /Pages /Kids ["
        for pg = 1 to totalPages
            chunk += " " + pageObjNums[pg] + " 0 R"
        next
        chunk += " ] /Count " + totalPages + " >>" + char(10)
        chunk += "endobj" + char(10)
        fputs(fp, chunk)
        bytePos += len(chunk)
        
        # Font objects - Type1 (simple) and TTF (composite with 5 objects each)
        fontObjNumMap = []  # Map from font index -> first object number
        for fi = 1 to fontMapLen
            isTTF = false
            if len(aFontMap[fi]) >= 3
                isTTF = aFontMap[fi][:isTTF]
            ok
            
            if !isTTF
                # Standard Type1 font: single object
                objectNum++
                objectOffsets + bytePos
                fontObjNumMap + objectNum
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /Type /Font /Subtype /Type1 /BaseFont /" + aFontMap[fi][:name] + " /Encoding /WinAnsiEncoding >>" + char(10)
                chunk += "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
            else
                # TrueType composite font: 6 objects
                # Find the TTF font data
                ttfIdx = findTTFFont(aFontMap[fi][:name])
                ttfFont = aTTFFonts[ttfIdx]
                fntInfo = ttfFont[:info]
                
                uPerEm = fntInfo[:unitsPerEm]
                scaleFactor = 1000.0 / uPerEm
                bbox = fntInfo[:bbox]
                
                # Build CIDWidths array from used glyphs
                cidWidthEntries = ""
                usedGlyphs = ttfFont[:cidToGlyph]
                usedLen = len(usedGlyphs)
                for gi = 1 to usedLen
                    cid = usedGlyphs[gi][1]
                    gid = usedGlyphs[gi][2]
                    w = ttfGetGlyphWidth(fntInfo, gid)
                    scaledW = floor(w * scaleFactor + 0.5)
                    cidWidthEntries += " " + cid + " [" + scaledW + "]"
                next
                
                # Build ToUnicode CMap
                tounicode = buildToUnicodeCMap(ttfFont[:cidToUnicode])
                
                # Build CIDToGIDMap binary stream
                # Only need entries 0..maxCID (sequential CIDs are small numbers)
                # Each entry is 2 bytes: big-endian GlyphID
                maxCID = 0
                for gi = 1 to usedLen
                    cid = usedGlyphs[gi][1]
                    if cid > maxCID maxCID = cid ok
                next
                mapEntries = maxCID + 1
                nulByte = char(0)
                cidToGIDMapData = copy(nulByte + nulByte, mapEntries)
                for gi = 1 to usedLen
                    cid = usedGlyphs[gi][1]
                    gid = usedGlyphs[gi][2]
                    byteOffset = cid * 2 + 1  # Ring 1-based
                    cidToGIDMapData[byteOffset] = char((gid >> 8) & 0xFF)
                    cidToGIDMapData[byteOffset + 1] = char(gid & 0xFF)
                next
                
                # Obj A: Type0 font (top-level, referenced by pages)
                objectNum++
                type0ObjNum = objectNum
                objectOffsets + bytePos
                fontObjNumMap + type0ObjNum
                
                cidFontObjNum = objectNum + 1
                tounicodeObjNum = objectNum + 5  # Now 6th object (was 5th)
                
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /Type /Font /Subtype /Type0"
                chunk += " /BaseFont /" + fntInfo[:fontName]
                chunk += " /Encoding /Identity-H"
                chunk += " /DescendantFonts [" + cidFontObjNum + " 0 R]"
                chunk += " /ToUnicode " + tounicodeObjNum + " 0 R"
                chunk += " >>" + char(10)
                chunk += "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
                
                # Obj B: CIDFont (now references CIDToGIDMap stream instead of /Identity)
                objectNum++
                objectOffsets + bytePos
                descriptorObjNum = objectNum + 1
                cidToGIDMapObjNum = objectNum + 3  # Points to Obj E
                
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /Type /Font /Subtype /CIDFontType2"
                chunk += " /BaseFont /" + fntInfo[:fontName]
                chunk += " /CIDSystemInfo << /Registry (Adobe) /Ordering (Identity) /Supplement 0 >>"
                chunk += " /FontDescriptor " + descriptorObjNum + " 0 R"
                chunk += " /DW " + floor(500 * scaleFactor + 0.5)
                if len(cidWidthEntries) > 0
                    chunk += " /W [" + cidWidthEntries + "]"
                ok
                chunk += " /CIDToGIDMap " + cidToGIDMapObjNum + " 0 R"
                chunk += " >>" + char(10)
                chunk += "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
                
                # Obj C: FontDescriptor
                objectNum++
                objectOffsets + bytePos
                fontStreamObjNum = objectNum + 1
                
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /Type /FontDescriptor"
                chunk += " /FontName /" + fntInfo[:fontName]
                chunk += " /Flags " + fntInfo[:flags]
                chunk += " /FontBBox [" + floor(bbox[1] * scaleFactor) + " " + floor(bbox[2] * scaleFactor) + " " + floor(bbox[3] * scaleFactor) + " " + floor(bbox[4] * scaleFactor) + "]"
                chunk += " /ItalicAngle " + fntInfo[:italicAngle]
                chunk += " /Ascent " + floor(fntInfo[:ascent] * scaleFactor)
                chunk += " /Descent " + floor(fntInfo[:descent] * scaleFactor)
                chunk += " /CapHeight " + floor(fntInfo[:capHeight] * scaleFactor)
                chunk += " /StemV " + fntInfo[:stemV]
                chunk += " /FontFile2 " + fontStreamObjNum + " 0 R"
                chunk += " >>" + char(10)
                chunk += "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
                
                # Obj D: Font stream (entire TTF file)
                objectNum++
                objectOffsets + bytePos
                fontFileData = fntInfo[:data]
                fontFileLen = len(fontFileData)
                
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /Length " + fontFileLen + " /Length1 " + fontFileLen + " >>" + char(10)
                chunk += "stream" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
                fwrite(fp, fontFileData)
                bytePos += fontFileLen
                chunk = char(10) + "endstream" + char(10) + "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
                
                # Obj E: CIDToGIDMap stream (binary table: 65536 × 2 bytes)
                # Maps each CID to its actual GlyphID in the font
                objectNum++
                objectOffsets + bytePos
                cidToGIDMapLen = len(cidToGIDMapData)
                
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /Length " + cidToGIDMapLen + " >>" + char(10)
                chunk += "stream" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
                fwrite(fp, cidToGIDMapData)
                bytePos += cidToGIDMapLen
                chunk = char(10) + "endstream" + char(10) + "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
                
                # Obj F: ToUnicode CMap
                objectNum++
                objectOffsets + bytePos
                tounicodeLen = len(tounicode)
                
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /Length " + tounicodeLen + " >>" + char(10)
                chunk += "stream" + char(10)
                chunk += tounicode + char(10)
                chunk += "endstream" + char(10)
                chunk += "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
            ok
        next
        
        # Image objects - write header, then stream data, then footer separately
        # For RGBA/GrayAlpha PNGs, we also need tint function objects
        imageObjectNums = []
        tintFuncObjectNums = []
        
        # First pass: create tint function objects for DeviceN images
        for ii = 1 to imagesLen
            img = aImages[ii]
            cs = img[:colorSpace]
            if cs = "DeviceN_RGBA" or cs = "DeviceN_GrayAlpha"
                objectNum++
                objectOffsets + bytePos
                tintFuncObjectNums + [ii, objectNum]
                
                # PostScript Type 4 function: {pop} drops the alpha channel
                tintFunc = "{ pop }"
                if cs = "DeviceN_RGBA"
                    funcDomain = "0 1 0 1 0 1 0 1"   # R G B A
                    funcRange = "0 1 0 1 0 1"          # R G B
                else
                    funcDomain = "0 1 0 1"             # Gray Alpha
                    funcRange = "0 1"                   # Gray
                ok
                
                chunk = "" + objectNum + " 0 obj" + char(10)
                chunk += "<< /FunctionType 4"
                chunk += " /Domain [" + funcDomain + "]"
                chunk += " /Range [" + funcRange + "]"
                chunk += " /Length " + len(tintFunc)
                chunk += " >>" + char(10)
                chunk += "stream" + char(10)
                chunk += tintFunc + char(10)
                chunk += "endstream" + char(10)
                chunk += "endobj" + char(10)
                fputs(fp, chunk)
                bytePos += len(chunk)
            ok
        next
        
        # Second pass: create image XObject objects
        for ii = 1 to imagesLen
            img = aImages[ii]
            
            objectNum++
            objectOffsets + bytePos
            imageObjectNums + objectNum
            
            imgData = img[:data]
            imgDataLen = len(imgData)
            cs = img[:colorSpace]
            
            # Build ColorSpace specification
            csSpec = ""
            tintFuncLen = len(tintFuncObjectNums)
            if cs = "DeviceN_RGBA"
                # Find the tint function object number for this image
                tintObjNum = 0
                for tt = 1 to tintFuncLen
                    if tintFuncObjectNums[tt][1] = ii
                        tintObjNum = tintFuncObjectNums[tt][2]
                    ok
                next
                csSpec = " /ColorSpace [/DeviceN [/Red /Green /Blue /Alpha] /DeviceRGB " + tintObjNum + " 0 R]"
            elseif cs = "DeviceN_GrayAlpha"
                tintObjNum = 0
                for tt = 1 to tintFuncLen
                    if tintFuncObjectNums[tt][1] = ii
                        tintObjNum = tintFuncObjectNums[tt][2]
                    ok
                next
                csSpec = " /ColorSpace [/DeviceN [/Gray /Alpha] /DeviceGray " + tintObjNum + " 0 R]"
            else
                csSpec = " /ColorSpace /" + cs
            ok
            
            # Image object header
            chunk = "" + objectNum + " 0 obj" + char(10)
            chunk += "<< /Type /XObject /Subtype /Image"
            chunk += " /Width " + img[:pixelWidth]
            chunk += " /Height " + img[:pixelHeight]
            chunk += csSpec
            chunk += " /BitsPerComponent " + img[:bpc]
            imgFilterStr = img[:filter]
            if len(imgFilterStr) > 0
                chunk += " /Filter " + imgFilterStr
            ok
            imgDecodeParmsStr = img[:decodeParms]
            if len(imgDecodeParmsStr) > 0
                chunk += " /DecodeParms " + imgDecodeParmsStr
            ok
            chunk += " /Length " + imgDataLen
            chunk += " >>" + char(10)
            chunk += "stream" + char(10)
            fputs(fp, chunk)
            bytePos += len(chunk)
            
            # Write raw image data directly to file (binary, not text)
            fwrite(fp, imgData)
            bytePos += imgDataLen
            
            # End stream
            chunk = char(10) + "endstream" + char(10) + "endobj" + char(10)
            fputs(fp, chunk)
            bytePos += len(chunk)
        next
        
        # Page + Content stream pairs
        for pg = 1 to totalPages
            # Page object
            objectNum++
            objectOffsets + bytePos
            
            pgW = getPageWidth()
            pgH = getPageHeight()
            
            # Font resources
            fontResources = ""
            for fi = 1 to fontMapLen
                fontResources += " /" + aFontMap[fi][:id] + " " + fontObjNumMap[fi] + " 0 R"
            next
            
            # Image resources for this page
            imageResources = ""
            for ii = 1 to imagesLen
                if aImages[ii][:page] = pg
                    imageResources += " /" + aImages[ii][:id] + " " + imageObjectNums[ii] + " 0 R"
                ok
            next
            
            contentObjNum = objectNum + 1
            
            chunk = "" + objectNum + " 0 obj" + char(10)
            chunk += "<< /Type /Page /Parent 2 0 R"
            chunk += " /MediaBox [0 0 " + pdfNum(pgW) + " " + pdfNum(pgH) + "]"
            chunk += " /Contents " + contentObjNum + " 0 R"
            chunk += " /Resources << /Font <<" + fontResources + " >>"
            if len(imageResources) > 0
                chunk += " /XObject <<" + imageResources + " >>"
            ok
            chunk += " >> >>" + char(10)
            chunk += "endobj" + char(10)
            fputs(fp, chunk)
            bytePos += len(chunk)
            
            # Content stream
            objectNum++
            objectOffsets + bytePos
            
            pageContent = aPageStreams[pg]
            pageContentLen = len(pageContent)
            
            chunk = "" + objectNum + " 0 obj" + char(10)
            chunk += "<< /Length " + pageContentLen + " >>" + char(10)
            chunk += "stream" + char(10)
            fputs(fp, chunk)
            bytePos += len(chunk)
            
            fputs(fp, pageContent)
            bytePos += pageContentLen
            
            chunk = "endstream" + char(10) + "endobj" + char(10)
            fputs(fp, chunk)
            bytePos += len(chunk)
        next
        
        # Info dictionary
        objectNum++
        infoObjNum = objectNum
        objectOffsets + bytePos
        chunk = "" + objectNum + " 0 obj" + char(10)
        chunk += "<< /Producer (RingPDFLib 1.1)"
        if len(cTitle) > 0
            chunk += " /Title (" + pdfEscapeText(cTitle) + ")"
        ok
        if len(cAuthor) > 0
            chunk += " /Author (" + pdfEscapeText(cAuthor) + ")"
        ok
        if len(cSubject) > 0
            chunk += " /Subject (" + pdfEscapeText(cSubject) + ")"
        ok
        if len(cCreator) > 0
            chunk += " /Creator (" + pdfEscapeText(cCreator) + ")"
        ok
        chunk += " >>" + char(10) + "endobj" + char(10)
        fputs(fp, chunk)
        bytePos += len(chunk)
        
        # Cross-reference table
        xrefOffset = bytePos
        chunk = "xref" + char(10)
        chunk += "0 " + (objectNum + 1) + char(10)
        chunk += "0000000000 65535 f " + char(10)
        
        for oi = 1 to objectNum
            offsetStr = "" + objectOffsets[oi]
            while len(offsetStr) < 10
                offsetStr = "0" + offsetStr
            end
            chunk += offsetStr + " 00000 n " + char(10)
        next
        
        # Trailer
        chunk += "trailer" + char(10)
        chunk += "<< /Size " + (objectNum + 1) + " /Root 1 0 R /Info " + infoObjNum + " 0 R >>" + char(10)
        chunk += "startxref" + char(10)
        chunk += "" + xrefOffset + char(10)
        chunk += "%%EOF" + char(10)
        fputs(fp, chunk)
        
        fclose(fp)
        return fexists(filename)
