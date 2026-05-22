/*
    PDFLib - Arabic Text Support Module
    ===================================
    Pure Ring implementation of:
    1. UTF-8 decoder
    2. Arabic contextual shaping (isolated/initial/medial/final forms)
    3. TrueType font parser (cmap, hmtx, glyf, head, hhea, maxp, loca, OS/2, post)
    4. PDF Type0/CIDFont embedding with ToUnicode CMap
    5. RTL text layout
    
    Usage:
        pdf = new PDFWriter()
        pdf.loadArabicFont("font/arial.ttf", "ArabicFont")
        pdf.setFont("ArabicFont", 24)
        pdf.drawArabicText(مرحبا بالعالم", 500, 700")
*/

# ============================================================================
# Arabic Unicode Shaping Tables
# ============================================================================

# Arabic letter forms: [Unicode, Isolated, Final, Initial, Medial]
# 0 = no form (use isolated)
# Letters that only connect on the right: Alef, Dal, Thal, Ra, Zain, Waw
# Letters that connect on both sides: all others

# Global cache for shaping table (avoid rebuilding on every call)
$arabicShapingLookup = NULL
$hexChars = "0123456789ABCDEF"

# Glyph ID cache (initialized by initGlyphIDCache after font load)
$glyphCache1 = []
$glyphCache2 = []
$glyphCacheReady = false

# Pre-built byte-to-hex lookup table (256 entries: "00", "01", ... "FF")
$byteToHex = list(256)
prepareByteToHex()

func prepareByteToHex
    for nIndex = 0 to 255
        $byteToHex[nIndex + 1] = $hexChars[(nIndex >> 4) + 1] + $hexChars[(nIndex & 0x0F) + 1]
    next

# ============================================================================
# UTF-8 Decoding
# ============================================================================

# Decode UTF-8 string to list of Unicode codepoints
func utf8ToCodepoints text
    result = []
    textLen = len(text)
    i = 1
    while i <= textLen
        b1 = ascii(text[i])
        if b1 < 0x80
            # ASCII
            result + b1
            i++
        elseif (b1 & 0xE0) = 0xC0
            # 2-byte
            if i + 1 <= textLen
                b2 = ascii(text[i + 1])
                cp = ((b1 & 0x1F) << 6) | (b2 & 0x3F)
                result + cp
                i += 2
            else
                i++
            ok
        elseif (b1 & 0xF0) = 0xE0
            # 3-byte
            if i + 2 <= textLen
                b2 = ascii(text[i + 1])
                b3 = ascii(text[i + 2])
                cp = ((b1 & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F)
                result + cp
                i += 3
            else
                i++
            ok
        elseif (b1 & 0xF8) = 0xF0
            # 4-byte
            if i + 3 <= textLen
                b2 = ascii(text[i + 1])
                b3 = ascii(text[i + 2])
                b4 = ascii(text[i + 3])
                cp = ((b1 & 0x07) << 18) | ((b2 & 0x3F) << 12) | ((b3 & 0x3F) << 6) | (b4 & 0x3F)
                result + cp
                i += 4
            else
                i++
            ok
        else
            i++
        ok
    end
    return result

# Encode a single Unicode codepoint to UTF-16BE bytes (for PDF strings)
func codepointToUTF16BE cp
    if cp < 0x10000
        return char((cp >> 8) & 0xFF) + char(cp & 0xFF)
    ok
    # Surrogate pair
    cp -= 0x10000
    hi = 0xD800 | ((cp >> 10) & 0x3FF)
    lo = 0xDC00 | (cp & 0x3FF)
    return char((hi >> 8) & 0xFF) + char(hi & 0xFF) + char((lo >> 8) & 0xFF) + char(lo & 0xFF)

# Encode a single Unicode codepoint back to UTF-8 bytes
func codepointToUTF8 cp
    if cp < 0x80
        return char(cp)
    elseif cp < 0x800
        return char(0xC0 | (cp >> 6)) + char(0x80 | (cp & 0x3F))
    elseif cp < 0x10000
        return char(0xE0 | (cp >> 12)) + char(0x80 | ((cp >> 6) & 0x3F)) + char(0x80 | (cp & 0x3F))
    else
        return char(0xF0 | (cp >> 18)) + char(0x80 | ((cp >> 12) & 0x3F)) + char(0x80 | ((cp >> 6) & 0x3F)) + char(0x80 | (cp & 0x3F))
    ok

# ============================================================================
# Arabic Text Shaping
# ============================================================================

# Check if a codepoint is an Arabic letter
func isArabicLetter cp
    return (cp >= 0x0621 and cp <= 0x064A) or cp = 0x0640

# Check if a raw UTF-8 string contains Arabic characters
# Uses substr() find (C-level search) for each Arabic lead byte
# Arabic block lead bytes: 0xD8-0xDB (U+0600-U+06FF)
func containsArabic text
    return substr(text, char(0xD8)) or substr(text, char(0xD9)) or 
           substr(text, char(0xD9)) or substr(text, char(0xDA)) 
      
# Split a mixed UTF-8 string into segments of Latin and Arabic text
# Returns list of [text, isArabic] pairs
# Example: "Field / الحقل" -> [["Field / ", false], ["الحقل", true]]
func splitMixedText text
    segments = []
    tLen = len(text)
    if tLen = 0 return segments ok
    
    segStart = 1         # byte position where current segment started
    currentIsArabic = false
    i = 1
    
    while i <= tLen
        b = ascii(text[i])
        
        # Determine character type and byte length
        if b < 0x80
            charLen = 1
            if b = 32
                isAr = currentIsArabic   # space inherits current context
            else
                isAr = false
            ok
        elseif b >= 0xC0 and b < 0xE0
            charLen = 2
            isAr = (b >= 0xD8 and b <= 0xDB)
        elseif b >= 0xE0 and b < 0xF0
            charLen = 3
            isAr = false
            if b = 0xEF and i + 1 <= tLen
                b2 = ascii(text[i + 1])
                if b2 >= 0xB9 and b2 <= 0xBF
                    isAr = true
                ok
            ok
        elseif b >= 0xF0
            charLen = 4
            isAr = false
        else
            charLen = 1
            isAr = false
        ok
        
        if i + charLen - 1 > tLen charLen = tLen - i + 1 ok
        
        # Space lookahead: if current is Arabic, check if next char is Arabic too
        if b = 32 and currentIsArabic
            ni = i + 1
            if ni <= tLen
                nb = ascii(text[ni])
                if nb >= 0xC0 and nb < 0xE0
                    if nb >= 0xD8 and nb <= 0xDB isAr = true ok
                elseif nb >= 0xE0 and nb < 0xF0
                    if nb = 0xEF and ni + 1 <= tLen
                        nb2 = ascii(text[ni + 1])
                        if nb2 >= 0xB9 and nb2 <= 0xBF isAr = true ok
                    ok
                ok
            ok
        ok
        
        # If type changed, extract segment using one substr call
        if i > segStart and isAr != currentIsArabic
            segments + [substr(text, segStart, i - segStart), currentIsArabic]
            segStart = i
        ok
        
        currentIsArabic = isAr
        i += charLen
    end
    
    # Push final segment
    if segStart <= tLen
        segments + [substr(text, segStart, tLen - segStart + 1), currentIsArabic]
    ok
    
    return segments

# Split an Arabic UTF-8 string by spaces into words
# Uses Ring's built-in split() function
func splitArabicBySpaces text
    return split(text, " ")

# Check if a codepoint is an Arabic diacritic/tashkeel
func isArabicDiacritic cp
    return (cp >= 0x064B and cp <= 0x0652) or (cp >= 0x0670 and cp <= 0x0670)

# Shape Arabic text: convert base forms to contextual forms
# Input: list of Unicode codepoints
# Output: list of shaped Unicode codepoints (presentation forms)
func shapeArabicText codepoints
    cpLen = len(codepoints)
    if cpLen = 0 return [] ok
    
    # Arabic base letters are in range 0x0621-0x064A (42 entries)
    if $arabicShapingLookup = NULL
        $arabicShapingLookup = list(42)
        tableLen = len(aArabicShapingTable)
        for si = 1 to tableLen
            idx = aArabicShapingTable[si][1] - 0x0621 + 1
            if idx >= 1 and idx <= 42
                $arabicShapingLookup[idx] = aArabicShapingTable[si]
            ok
        next
    ok
    shapingLookup = $arabicShapingLookup
    
    result = []
    
    i = 1
    while i <= cpLen
        cp = codepoints[i]
        
        # Check for Lam-Alef ligature
        if cp = 0x0644 and i + 1 <= cpLen
            nextCP = codepoints[i + 1]
            # Skip diacritics between lam and alef
            nextIdx = i + 1
            while nextIdx <= cpLen and isArabicDiacritic(codepoints[nextIdx])
                nextIdx++
            end
            if nextIdx <= cpLen
                nextCP = codepoints[nextIdx]
                lamAlefCP = 0
                if nextCP = 0x0622 lamAlefCP = 0xFEF5 ok       # Lam + Alef with Madda
                if nextCP = 0x0623 lamAlefCP = 0xFEF7 ok       # Lam + Alef with Hamza Above
                if nextCP = 0x0625 lamAlefCP = 0xFEF9 ok       # Lam + Alef with Hamza Below
                if nextCP = 0x0627 lamAlefCP = 0xFEFB ok       # Lam + Alef
                
                if lamAlefCP > 0
                    # Replace with ligature - determine form based on context
                    prevJoins = false
                    if i > 1
                        prevCP = codepoints[i - 1]
                        prevEntry = findShapingEntryFast(shapingLookup, prevCP)
                        if prevEntry != NULL
                            if prevEntry[6] = 1  # prev joins next
                                prevJoins = true
                            ok
                        ok
                    ok
                    
                    if prevJoins
                        result + (lamAlefCP + 1)  # Final form
                    else
                        result + lamAlefCP          # Isolated form
                    ok
                    i = nextIdx + 1
                    loop
                ok
            ok
        ok
        
        if !isArabicLetter(cp)
            # Non-Arabic: pass through (including diacritics)
            result + cp
            i++
            loop
        ok
        
        entry = findShapingEntryFast(shapingLookup, cp)
        if entry = NULL
            result + cp
            i++
            loop
        ok
        
        # Determine context: does previous letter join to this one?
        # and does this letter join to the next?
        prevJoins = false
        nextJoins = false
        
        # Check previous: find last Arabic letter before this one
        pi = i - 1
        while pi >= 1 and isArabicDiacritic(codepoints[pi])
            pi--
        end
        if pi >= 1
            prevCP = codepoints[pi]
            if isArabicLetter(prevCP)
                prevEntry = findShapingEntryFast(shapingLookup, prevCP)
                if prevEntry != NULL
                    if prevEntry[6] = 1  # Previous letter is dual-joining
                        prevJoins = true
                    ok
                ok
            ok
        ok
        
        # Check next: find next Arabic letter after this one
        ni = i + 1
        while ni <= cpLen and isArabicDiacritic(codepoints[ni])
            ni++
        end
        if ni <= cpLen
            nextCP = codepoints[ni]
            if isArabicLetter(nextCP)
                nextJoins = true
            ok
        ok
        
        # Now determine the form
        if prevJoins and nextJoins and entry[6] = 1
            # Medial form
            if entry[5] > 0
                result + entry[5]
            else
                result + entry[2]  # Fallback to isolated
            ok
        elseif prevJoins
            # Final form (previous connects to us)
            if entry[3] > 0
                result + entry[3]
            else
                result + entry[2]
            ok
        elseif nextJoins and entry[6] = 1
            # Initial form (we connect to next)
            if entry[4] > 0
                result + entry[4]
            else
                result + entry[2]
            ok
        else
            # Isolated form
            result + entry[2]
        ok
        
        i++
    end
    
    return result

# Find entry in shaping table by base codepoint
func findShapingEntry table, cp
    tableLen = len(table)
    for i = 1 to tableLen
        if table[i][1] = cp
            return table[i]
        ok
    next
    return NULL

func findShapingEntryFast shapingLookup, cp
    idx = cp - 0x0621 + 1
    if idx >= 1 and idx <= 42
        entry = shapingLookup[idx]
        if isList(entry) and len(entry) >= 6
            return entry
        ok
    ok
    return NULL

# ============================================================================
# Bidirectional Text Processing (simplified)
# ============================================================================

# Reorder text for RTL display
# Arabic/Hebrew runs are reversed, Latin/number runs stay LTR
func bidiReorder codepoints
    # Simple approach: detect runs and reverse Arabic runs
    cpLen = len(codepoints)
    if cpLen = 0 return [] ok
    
    # For a primarily Arabic text, the overall direction is RTL
    # We reverse the entire sequence, then un-reverse any LTR runs (Latin/digits)
    
    # Copy and reverse in one pass
    result = list(cpLen)
    for i = 1 to cpLen
        result[i] = codepoints[cpLen - i + 1]
    next
    
    # Now find LTR runs (Latin, digits) and reverse them back in-place
    i = 1
    while i <= cpLen
        if isLTRChar(result[i])
            # Find end of LTR run
            j = i
            while j <= cpLen and isLTRChar(result[j])
                j++
            end
            # Reverse this run in-place
            lo = i
            hi = j - 1
            while lo < hi
                tmp = result[lo]
                result[lo] = result[hi]
                result[hi] = tmp
                lo++
                hi--
            end
            i = j
        else
            i++
        ok
    end
    
    return result

func isLTRChar cp
    # Latin letters, digits, and some punctuation
    if cp >= 0x0041 and cp <= 0x005A return true ok  # A-Z
    if cp >= 0x0061 and cp <= 0x007A return true ok  # a-z
    if cp >= 0x0030 and cp <= 0x0039 return true ok  # 0-9
    return false

# ============================================================================
# TrueType Font Parser (Pure Ring)
# ============================================================================

# Read 16-bit unsigned big-endian (with pre-computed length)
func ttfReadU16L data, offset, dataLen
    if offset + 1 > dataLen return 0 ok
    return ascii(data[offset]) * 256 + ascii(data[offset + 1])

# Read 16-bit signed big-endian (with pre-computed length)
func ttfReadS16L data, offset, dataLen
    if offset + 1 > dataLen return 0 ok
    v = ascii(data[offset]) * 256 + ascii(data[offset + 1])
    if v >= 32768 v -= 65536 ok
    return v

# Read 32-bit unsigned big-endian (with pre-computed length)
func ttfReadU32L data, offset, dataLen
    if offset + 3 > dataLen return 0 ok
    return ascii(data[offset]) * 16777216 + ascii(data[offset + 1]) * 65536 + ascii(data[offset + 2]) * 256 + ascii(data[offset + 3])

# Wrappers for callers that don't pre-compute length
func ttfReadU16 data, offset
    return ttfReadU16L(data, offset, len(data))

func ttfReadS16 data, offset
    return ttfReadS16L(data, offset, len(data))

func ttfReadU32 data, offset
    return ttfReadU32L(data, offset, len(data))

# Parse TrueType font file - returns font info needed for PDF embedding
func ttfParseFontFile fontData
    result = [
        :data = fontData,
        :tables = [],
        :unitsPerEm = 1000,
        :ascent = 800,
        :descent = -200,
        :numGlyphs = 0,
        :cmapFormat4 = NULL,
        :glyphWidths = [],
        :indexToLocFormat = 0,
        :locaOffsets = [],
        :glyfOffset = 0,
        :glyfLength = 0,
        :fontName = "CustomFont",
        :italicAngle = 0,
        :capHeight = 700,
        :stemV = 80,
        :bbox = [0, 0, 1000, 1000],
        :flags = 4
    ]
    
    dataLen = len(fontData)
    if dataLen < 12 return result ok
    
    # Parse offset table
    numTables = ttfReadU16L(fontData, 5, dataLen)
    
    # Parse table directory
    # TTF header: 12 bytes (scaler 4, numTables 2, searchRange 2, entrySelector 2, rangeShift 2)
    # Each directory entry: 16 bytes (tag 4, checksum 4, offset 4, length 4)
    for i = 0 to numTables - 1
        dirPos = 13 + i * 16       # Ring 1-based: byte 12 + i*16
        if dirPos + 15 > dataLen exit ok
        tag = substr(fontData, dirPos, 4)
        # Inlined ttfReadU32L for offset and length
        p8 = dirPos + 8
        tableOffset = (ascii(fontData[p8]) * 16777216 + ascii(fontData[p8+1]) * 65536 + ascii(fontData[p8+2]) * 256 + ascii(fontData[p8+3])) + 1
        p12 = dirPos + 12
        tableLength = ascii(fontData[p12]) * 16777216 + ascii(fontData[p12+1]) * 65536 + ascii(fontData[p12+2]) * 256 + ascii(fontData[p12+3])
        result[:tables] + [:tag = tag, :offset = tableOffset, :length = tableLength]
    next
    
    # Parse 'head' table
    headOff = ttfFindTable(result, "head")
    if headOff > 0
        result[:unitsPerEm] = ttfReadU16L(fontData, headOff + 18, dataLen)
        # Bounding box
        xMin = ttfReadS16L(fontData, headOff + 36, dataLen)
        yMin = ttfReadS16L(fontData, headOff + 38, dataLen)
        xMax = ttfReadS16L(fontData, headOff + 40, dataLen)
        yMax = ttfReadS16L(fontData, headOff + 42, dataLen)
        result[:bbox] = [xMin, yMin, xMax, yMax]
        result[:indexToLocFormat] = ttfReadS16L(fontData, headOff + 50, dataLen)
    ok
    
    # Parse 'hhea' table
    hheaOff = ttfFindTable(result, "hhea")
    if hheaOff > 0
        result[:ascent] = ttfReadS16L(fontData, hheaOff + 4, dataLen)
        result[:descent] = ttfReadS16L(fontData, hheaOff + 6, dataLen)
    ok
    
    # Parse 'maxp' table
    maxpOff = ttfFindTable(result, "maxp")
    if maxpOff > 0
        result[:numGlyphs] = ttfReadU16L(fontData, maxpOff + 4, dataLen)
    ok
    
    # Parse 'OS/2' table for additional metrics
    os2Off = ttfFindTable(result, "OS/2")
    if os2Off > 0
        result[:stemV] = 80  # Approximate
        # sCapHeight at offset 88 (version >= 2)
        os2Len = ttfFindTableLength(result, "OS/2")
        if os2Len >= 90
            result[:capHeight] = ttfReadS16L(fontData, os2Off + 88, dataLen)
        ok
    ok
    
    # Parse 'post' table
    postOff = ttfFindTable(result, "post")
    if postOff > 0
        # italicAngle is a Fixed 16.16 at offset 4
        result[:italicAngle] = ttfReadS16L(fontData, postOff + 4, dataLen)
    ok
    
    # Parse 'name' table for font name
    nameOff = ttfFindTable(result, "name")
    if nameOff > 0
        nameCount = ttfReadU16L(fontData, nameOff + 2, dataLen)
        stringOff = ttfReadU16L(fontData, nameOff + 4, dataLen)
        for i = 0 to nameCount - 1
            recOff = nameOff + 6 + i * 12
            if recOff + 11 > dataLen exit ok
            # Inlined ttfReadU16L for speed
            platformID = ascii(fontData[recOff]) * 256 + ascii(fontData[recOff + 1])
            nameID = ascii(fontData[recOff + 6]) * 256 + ascii(fontData[recOff + 7])
            strLength = ascii(fontData[recOff + 8]) * 256 + ascii(fontData[recOff + 9])
            strOffset = ascii(fontData[recOff + 10]) * 256 + ascii(fontData[recOff + 11])
            # nameID 6 = PostScript name
            if nameID = 6 and platformID = 1 and strLength > 0
                nameStart = nameOff + stringOff + strOffset
                if nameStart + strLength - 1 <= dataLen
                    psName = substr(fontData, nameStart, strLength)
                    # Remove spaces and special chars for PDF
                    cleanName = ""
                    psNameLen = len(psName)
                    for ci = 1 to psNameLen
                        ch = ascii(psName[ci])
                        if (ch >= 65 and ch <= 90) or (ch >= 97 and ch <= 122) or (ch >= 48 and ch <= 57) or ch = 45
                            cleanName += psName[ci]
                        ok
                    next
                    if len(cleanName) > 0
                        result[:fontName] = cleanName
                    ok
                ok
                exit
            ok
        next
    ok
    
    # Parse 'cmap' table - find format 4 subtable (Unicode BMP)
    cmapOff = ttfFindTable(result, "cmap")
    if cmapOff > 0
        numSubtables = ttfReadU16L(fontData, cmapOff + 2, dataLen)
        for i = 0 to numSubtables - 1
            subOff = cmapOff + 4 + i * 8
            if subOff + 7 > dataLen exit ok
            platformID = ttfReadU16L(fontData, subOff, dataLen)
            encodingID = ttfReadU16L(fontData, subOff + 2, dataLen)
            subtableOff = ttfReadU32L(fontData, subOff + 4, dataLen) 
            
            # Microsoft Unicode BMP (3,1) or Unicode (0,3)
            if (platformID = 3 and encodingID = 1) or (platformID = 0 and encodingID = 3) or (platformID = 0 and encodingID = 4)
                absOff = cmapOff + subtableOff
                if absOff + 2 <= dataLen
                    fmt = ttfReadU16L(fontData, absOff, dataLen)
                    if fmt = 4
                        result[:cmapFormat4] = ttfParseCmapFormat4(fontData, absOff)
                        exit
                    ok
                ok
            ok
        next
        # Fallback: try any format 4
        if result[:cmapFormat4] = NULL
            for i = 0 to numSubtables - 1
                subOff = cmapOff + 4 + i * 8
                if subOff + 7 > dataLen exit ok
                subtableOff = ttfReadU32L(fontData, subOff + 4, dataLen)
                absOff = cmapOff + subtableOff
                if absOff + 2 <= dataLen
                    fmt = ttfReadU16L(fontData, absOff, dataLen)
                    if fmt = 4
                        result[:cmapFormat4] = ttfParseCmapFormat4(fontData, absOff)
                        exit
                    ok
                ok
            next
        ok
    ok
    
    # Parse 'hmtx' table for glyph widths
    hmtxOff = ttfFindTable(result, "hmtx")
    hheaOff2 = ttfFindTable(result, "hhea")
    numHMetrics = 0
    if hheaOff2 > 0
        numHMetrics = ttfReadU16L(fontData, hheaOff2 + 34, dataLen)
    ok
    
    if hmtxOff > 0 and numHMetrics > 0
        widths = []
        for i = 0 to numHMetrics - 1
            wOff = hmtxOff + i * 4
            if wOff + 1 <= dataLen
                # Inlined ttfReadU16L for speed (4548 iterations)
                widths + (ascii(fontData[wOff]) * 256 + ascii(fontData[wOff + 1]))
            ok
        next
        # Remaining glyphs use last width
        lastW = 0
        if len(widths) > 0 lastW = widths[len(widths)] ok
        numGlyphs = result[:numGlyphs]
        while len(widths) < numGlyphs
            widths + lastW
        end
        result[:glyphWidths] = widths
    ok
    
    # Parse 'loca' table 
    locaOff = ttfFindTable(result, "loca")
    if locaOff > 0
        numGlyphs = result[:numGlyphs]
        offsets = []
        if result[:indexToLocFormat] = 0
            # Short format: offsets are 16-bit, multiply by 2
            for i = 0 to numGlyphs
                off = locaOff + i * 2
                if off + 1 <= dataLen
                    # Inlined ttfReadU16L for speed (4549 iterations)
                    offsets + ((ascii(fontData[off]) * 256 + ascii(fontData[off + 1])) * 2)
                ok
            next
        else
            # Long format: offsets are 32-bit
            for i = 0 to numGlyphs
                off = locaOff + i * 4
                if off + 3 <= dataLen
                    # Inlined ttfReadU32L for speed
                    offsets + (ascii(fontData[off]) * 16777216 + ascii(fontData[off + 1]) * 65536 + ascii(fontData[off + 2]) * 256 + ascii(fontData[off + 3]))
                ok
            next
        ok
        result[:locaOffsets] = offsets
    ok
    
    # Get glyf table info
    glyfOff = ttfFindTable(result, "glyf")
    if glyfOff > 0
        result[:glyfOffset] = glyfOff
        result[:glyfLength] = ttfFindTableLength(result, "glyf")
    ok
    
    return result

# Find table offset by tag
func ttfFindTable fontInfo, tag
    tablesLen = len(fontInfo[:tables])
    for i = 1 to tablesLen
        if fontInfo[:tables][i][:tag] = tag
            return fontInfo[:tables][i][:offset]
        ok
    next
    return 0

# Find table length by tag
func ttfFindTableLength fontInfo, tag
    tablesLen = len(fontInfo[:tables])
    for i = 1 to tablesLen
        if fontInfo[:tables][i][:tag] = tag
            return fontInfo[:tables][i][:length]
        ok
    next
    return 0

# Parse cmap format 4 subtable
func ttfParseCmapFormat4 data, offset
    dataLen = len(data)
    segCountX2 = ttfReadU16L(data, offset + 6, dataLen)
    segCount = segCountX2 / 2
    
    endCodesOff = offset + 14
    startCodesOff = endCodesOff + segCountX2 + 2  # +2 for reservedPad
    idDeltaOff = startCodesOff + segCountX2
    idRangeOffsetOff = idDeltaOff + segCountX2
    
    result = [
        :segCount = segCount,
        :endCodes = [],
        :startCodes = [],
        :idDeltas = [],
        :idRangeOffsets = [],
        :idRangeOffsetBase = idRangeOffsetOff,
        :data = data
    ]
    
    for i = 0 to segCount - 1
        ec = endCodesOff + i * 2
        sc = startCodesOff + i * 2
        id = idDeltaOff + i * 2
        iro = idRangeOffsetOff + i * 2
        
        if ec + 1 <= dataLen and sc + 1 <= dataLen and id + 1 <= dataLen and iro + 1 <= dataLen
            # Inlined reads for speed (164 segments × 4 reads each)
            result[:endCodes] + (ascii(data[ec]) * 256 + ascii(data[ec + 1]))
            result[:startCodes] + (ascii(data[sc]) * 256 + ascii(data[sc + 1]))
            # Signed 16-bit for idDeltas
            sv = ascii(data[id]) * 256 + ascii(data[id + 1])
            if sv >= 32768 sv -= 65536 ok
            result[:idDeltas] + sv
            result[:idRangeOffsets] + (ascii(data[iro]) * 256 + ascii(data[iro + 1]))
        ok
    next
    
    return result

# Global glyph ID cache: avoids repeated cmap segment scans
# Two separate caches for the two Arabic ranges we use most:
#   Cache 1: ASCII + Arabic base (0x0000-0x06FF) = 1792 entries 
#   Cache 2: Arabic Presentation Forms (0xFE70-0xFEFF) = 144 entries

# Look up glyph ID for a Unicode codepoint using cmap format 4
# Uses cache for frequently accessed codepoints
func ttfGetGlyphID cmapF4, codepoint
    if cmapF4 = NULL return 0 ok
    if codepoint > 0xFFFF return 0 ok
    
    # Check cache first
    if $glyphCacheReady
        if codepoint <= 0x06FF
            cached = $glyphCache1[codepoint + 1]
            if cached >= 0 return cached ok
        elseif codepoint >= 0xFE70 and codepoint <= 0xFEFF
            cached = $glyphCache2[codepoint - 0xFE70 + 1]
            if cached >= 0 return cached ok
        ok
    ok
    
    # Cache miss - do full cmap segment scan
    segCount = cmapF4[:segCount]
    endCodes = cmapF4[:endCodes]
    startCodes = cmapF4[:startCodes]
    idDeltas = cmapF4[:idDeltas]
    idRangeOffsets = cmapF4[:idRangeOffsets]
    iroBase = cmapF4[:idRangeOffsetBase]
    cmapData = cmapF4[:data]
    cmapDataLen = len(cmapData)
    
    gid = 0
    for i = 1 to segCount
        if codepoint <= endCodes[i]
            if codepoint >= startCodes[i]
                rangeOff = idRangeOffsets[i]
                if rangeOff = 0
                    gid = (codepoint + idDeltas[i]) & 0xFFFF
                else
                    iroOff = iroBase + (i - 1) * 2
                    glyphOff = iroOff + rangeOff + (codepoint - startCodes[i]) * 2
                    if glyphOff + 1 <= cmapDataLen
                        gid = ttfReadU16L(cmapData, glyphOff, cmapDataLen)
                        if gid != 0
                            gid = (gid + idDeltas[i]) & 0xFFFF
                        ok
                    ok
                ok
            ok
            # Store in cache
            if $glyphCacheReady
                if codepoint <= 0x06FF
                    $glyphCache1[codepoint + 1] = gid
                elseif codepoint >= 0xFE70 and codepoint <= 0xFEFF
                    $glyphCache2[codepoint - 0xFE70 + 1] = gid
                ok
            ok
            return gid
        ok
    next
    return 0

# Initialize glyph ID cache (call after loading font)
func initGlyphIDCache
    $glyphCache1 = list(1792)   # 0x0000-0x06FF
    for nIndex = 1 to 1792
        $glyphCache1[nIndex] = -1
    next
    $glyphCache2 = list(144)    # 0xFE70-0xFEFF
    for nIndex = 1 to 144
        $glyphCache2[nIndex] = -1
    next
    $glyphCacheReady = true

# Get glyph width in font units
func ttfGetGlyphWidth fontInfo, glyphID
    widths = fontInfo[:glyphWidths]
    widthsLen = len(widths)
    if glyphID >= 0 and glyphID < widthsLen
        return widths[glyphID + 1]  # Ring 1-based
    ok
    if widthsLen > 0
        return widths[widthsLen]
    ok
    return 500

# ============================================================================
# PDF Font Embedding Helpers
# ============================================================================

# Build a hex string from binary data
func binToHex data
    dataLen = len(data)
    # Pre-allocate result string of exact size (2 hex chars per byte)
    result = copy("00", dataLen)
    for i = 1 to dataLen
        hex2 = $byteToHex[ascii(data[i]) + 1]
        pos = (i - 1) * 2 + 1
        result[pos] = hex2[1]
        result[pos + 1] = hex2[2]
    next
    return result

# Build ToUnicode CMap for the font subset
# Maps CID values to Unicode codepoints
func buildToUnicodeCMap cidToUnicode
    nl = char(10)
    
    # Build header
    cmap = "/CIDInit /ProcSet findresource begin" + nl
    cmap += "12 dict begin" + nl
    cmap += "begincmap" + nl
    cmap += "/CIDSystemInfo" + nl
    cmap += "<< /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def" + nl
    cmap += "/CMapName /Adobe-Identity-UCS def" + nl
    cmap += "/CMapType 2 def" + nl
    cmap += "1 begincodespacerange" + nl
    cmap += "<0000> <FFFF>" + nl
    cmap += "endcodespacerange" + nl
    
    # Build mappings in batches of 100
    entries = cidToUnicode
    entriesLen = len(entries)
    pos = 1
    while pos <= entriesLen
        batchEnd = pos + 99
        if batchEnd > entriesLen batchEnd = entriesLen ok
        batchSize = batchEnd - pos + 1
        
        batchStr = "" + batchSize + " beginbfchar" + nl
        for i = pos to batchEnd
            cidHex = hexU16(entries[i][1])
            uniHex = hexU16(entries[i][2])
            batchStr += "<" + cidHex + "> <" + uniHex + ">" + nl
        next
        batchStr += "endbfchar" + nl
        cmap += batchStr
        pos = batchEnd + 1
    end
    
    cmap += "endcmap" + nl
    cmap += "CMapName currentdict /CMap defineresource pop" + nl
    cmap += "end" + nl
    cmap += "end" + nl
    
    return cmap

# Format a 16-bit value as 4-char hex
func hexU16 val
    h1 = $hexChars[((val >> 12) & 0x0F) + 1]
    h2 = $hexChars[((val >> 8) & 0x0F) + 1]
    h3 = $hexChars[((val >> 4) & 0x0F) + 1]
    h4 = $hexChars[(val & 0x0F) + 1]
    return "" + h1 + h2 + h3 + h4
