/*
    PDFLib - Images Demo
    ====================
    Demonstrates embedding PNG, JPEG and BMP images in PDF
*/

load "pdflib.ring"

C_IMAGE_TEST1 = "images/test1.png"
C_IMAGE_TEST2 = "images/test2.jpg"
C_IMAGE_TEST3 = "images/test3.bmp"

func main

    ? "=============================================="
    ? "   PDFLib - Images Demo"
    ? "=============================================="
    ? ""

    # Check which test images exist
    img1Exists = fexists(C_IMAGE_TEST1)
    img2Exists = fexists(C_IMAGE_TEST2)
    img3Exists = fexists(C_IMAGE_TEST3)

    ? "Image files found:"
    if img1Exists ? "  [OK]  images/test1.png" else ? "  [--]  images/test1.png not found" ok
    if img2Exists ? "  [OK]  images/test2.jpg" else ? "  [--]  images/test2.jpg not found" ok
    if img3Exists ? "  [OK]  images/test3.bmp" else ? "  [--]  images/test3.bmp not found" ok
    ? ""

    # ------------------------------------------------------------------
    # Demo 1: Single Image Per Page (Gallery Style)
    # ------------------------------------------------------------------
    ? "Demo 1: Image gallery..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Image Gallery")
    pdfDoc.setAuthor("RingPDFLib")
    pdfDoc.enablePageNumbers()

    # === Page 1: PNG Image ===

    # Title bar
    pdfDoc.setFillColor([41, 98, 255])
    pdfDoc.drawFilledRectNoStroke(0, 790, 595.28, 52)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("white")
    pdfDoc.drawText("Image Gallery", 72, 805)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.drawTextRight("RingPDFLib Demo", 523, 805)

    # Section
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 18)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("1. PNG Image (images/test1.png)", 72, 750)

    pdfDoc.setStrokeColor([41, 98, 255])
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 743, 350, 743)

    if img1Exists
        # Image border/frame
        pdfDoc.setFillColor([245, 245, 250])
        pdfDoc.setStrokeColor([200, 200, 210])
        pdfDoc.setLineWidth(1)
        pdfDoc.drawFilledRect(67, 387, 460, 340)
        
        # Draw the image
        pdfDoc.drawImage(C_IMAGE_TEST1, 72, 392, 450, 330)
        
        # Caption
        pdfDoc.setFont(PDF_HELVETICA_ITALIC, 11)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("Figure 1: PNG format image embedded in PDF", 297, 373)
    else
        pdfDoc.setFillColor([255, 240, 240])
        pdfDoc.setStrokeColor([220, 180, 180])
        pdfDoc.drawFilledRect(72, 500, 450, 200)
        pdfDoc.setFont(PDF_HELVETICA, 14)
        pdfDoc.setTextColor("red")
        pdfDoc.drawTextCentered("images/test1.png not found", 297, 610)
        pdfDoc.setFont(PDF_HELVETICA, 11)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("Place a PNG file named test1.png in the images folder", 297, 585)
    ok

    # Info box
    pdfDoc.setFillColor([240, 248, 255])
    pdfDoc.setStrokeColor([176, 196, 222])
    pdfDoc.setLineWidth(1)
    pdfDoc.drawFilledRect(72, 260, 450, 90)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 11)
    pdfDoc.setTextColor([41, 98, 255])
    pdfDoc.drawText("About PNG Format:", 82, 330)

    pdfDoc.setFont(PDF_HELVETICA, 10)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("PNG (Portable Network Graphics) supports lossless compression,", 82, 312)
    pdfDoc.drawText("transparency (alpha channel), and is ideal for graphics, logos,", 82, 298)
    pdfDoc.drawText("screenshots, and images requiring sharp edges.", 82, 284)

    # === Page 2: JPEG Image ===
    pdfDoc.addPage()

    # Title bar
    pdfDoc.setFillColor([234, 67, 53])
    pdfDoc.drawFilledRectNoStroke(0, 790, 595.28, 52)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("white")
    pdfDoc.drawText("Image Gallery", 72, 805)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.drawTextRight("RingPDFLib Demo", 523, 805)

    # Section
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 18)
    pdfDoc.setTextColor([180, 30, 20])
    pdfDoc.drawText("2. JPEG Image (images/test2.jpg)", 72, 750)

    pdfDoc.setStrokeColor([234, 67, 53])
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 743, 350, 743)

    if img2Exists
        # Image frame
        pdfDoc.setFillColor([245, 245, 250])
        pdfDoc.setStrokeColor([200, 200, 210])
        pdfDoc.setLineWidth(1)
        pdfDoc.drawFilledRect(67, 387, 460, 340)
        
        # Draw the image
        pdfDoc.drawImage(C_IMAGE_TEST2, 72, 392, 450, 330)
        
        # Caption
        pdfDoc.setFont(PDF_HELVETICA_ITALIC, 11)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("Figure 2: JPEG format image embedded in PDF", 297, 373)
    else
        pdfDoc.setFillColor([255, 240, 240])
        pdfDoc.setStrokeColor([220, 180, 180])
        pdfDoc.drawFilledRect(72, 500, 450, 200)
        pdfDoc.setFont(PDF_HELVETICA, 14)
        pdfDoc.setTextColor("red")
        pdfDoc.drawTextCentered("images/test2.jpg not found", 297, 610)
        pdfDoc.setFont(PDF_HELVETICA, 11)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("Place a JPEG file named test2.jpg in the images folder", 297, 585)
    ok

    # Info box
    pdfDoc.setFillColor([255, 245, 245])
    pdfDoc.setStrokeColor([222, 180, 180])
    pdfDoc.setLineWidth(1)
    pdfDoc.drawFilledRect(72, 260, 450, 90)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 11)
    pdfDoc.setTextColor([234, 67, 53])
    pdfDoc.drawText("About JPEG Format:", 82, 330)

    pdfDoc.setFont(PDF_HELVETICA, 10)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("JPEG uses lossy compression, making it ideal for photographs", 82, 312)
    pdfDoc.drawText("and complex images with smooth color gradients. Files are", 82, 298)
    pdfDoc.drawText("typically much smaller than PNG for photo content.", 82, 284)

    # === Page 3: BMP Image ===
    pdfDoc.addPage()

    # Title bar
    pdfDoc.setFillColor([52, 168, 83])
    pdfDoc.drawFilledRectNoStroke(0, 790, 595.28, 52)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("white")
    pdfDoc.drawText("Image Gallery", 72, 805)

    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.drawTextRight("RingPDFLib Demo", 523, 805)

    # Section
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 18)
    pdfDoc.setTextColor([30, 120, 50])
    pdfDoc.drawText("3. BMP Image (images/test3.bmp)", 72, 750)

    pdfDoc.setStrokeColor([52, 168, 83])
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 743, 350, 743)

    if img3Exists
        # Image frame
        pdfDoc.setFillColor([245, 245, 250])
        pdfDoc.setStrokeColor([200, 200, 210])
        pdfDoc.setLineWidth(1)
        pdfDoc.drawFilledRect(67, 387, 460, 340)
        
        # Draw the image
        pdfDoc.drawImage(C_IMAGE_TEST3, 72, 392, 450, 330)
        
        # Caption
        pdfDoc.setFont(PDF_HELVETICA_ITALIC, 11)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("Figure 3: BMP format image embedded in PDF", 297, 373)
    else
        pdfDoc.setFillColor([255, 240, 240])
        pdfDoc.setStrokeColor([220, 180, 180])
        pdfDoc.drawFilledRect(72, 500, 450, 200)
        pdfDoc.setFont(PDF_HELVETICA, 14)
        pdfDoc.setTextColor("red")
        pdfDoc.drawTextCentered("images/test3.bmp not found", 297, 610)
        pdfDoc.setFont(PDF_HELVETICA, 11)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("Place a BMP file named test3.bmp in the images folder", 297, 585)
    ok

    # Info box
    pdfDoc.setFillColor([240, 255, 240])
    pdfDoc.setStrokeColor([180, 220, 180])
    pdfDoc.setLineWidth(1)
    pdfDoc.drawFilledRect(72, 260, 450, 90)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 11)
    pdfDoc.setTextColor([52, 168, 83])
    pdfDoc.drawText("About BMP Format:", 82, 330)

    pdfDoc.setFont(PDF_HELVETICA, 10)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("BMP (Bitmap) is an uncompressed image format native to Windows.", 82, 312)
    pdfDoc.drawText("It stores raw pixel data without compression, resulting in larger", 82, 298)
    pdfDoc.drawText("file sizes but preserving exact pixel values.", 82, 284)

    if pdfDoc.save("demo_images_gallery.pdf")
        ? "  Created: demo_images_gallery.pdf"
    else
        ? "  FAILED: demo_images_gallery.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 2: Multiple Images on One Page
    # ------------------------------------------------------------------
    ? "Demo 2: Multiple images on one page..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Multiple Images Layout")

    # Title
    pdfDoc.setFillColor([33, 37, 41])
    pdfDoc.drawFilledRectNoStroke(0, 795, 595.28, 47)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 22)
    pdfDoc.setTextColor("white")
    pdfDoc.drawTextCentered("Multiple Images - Side by Side", 297.64, 810)

    # Row 1 - Two images side by side
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Row 1: PNG and JPEG Side by Side", 72, 755)

    pdfDoc.setStrokeColor([200, 200, 200])
    pdfDoc.setLineWidth(0.5)

    if img1Exists
        # Left image frame
        pdfDoc.setFillColor([248, 248, 248])
        pdfDoc.drawFilledRect(72, 575, 220, 165)
        pdfDoc.drawImage(C_IMAGE_TEST1, 75, 578, 214, 159)
    ok

    if img2Exists
        # Right image frame
        pdfDoc.setFillColor([248, 248, 248])
        pdfDoc.drawFilledRect(310, 575, 220, 165)
        pdfDoc.drawImage(C_IMAGE_TEST2, 313, 578, 214, 159)
    ok

    pdfDoc.setFont(PDF_HELVETICA, 9)
    pdfDoc.setTextColor("gray")
    if img1Exists pdfDoc.drawTextCentered(C_IMAGE_TEST1, 182, 562) ok
    if img2Exists pdfDoc.drawTextCentered(C_IMAGE_TEST2, 420, 562) ok

    # Row 2 - BMP image centered
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Row 2: BMP Image Centered", 72, 535)

    if img3Exists
        pdfDoc.setFillColor([248, 248, 248])
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.drawFilledRect(148, 345, 300, 175)
        pdfDoc.drawImage(C_IMAGE_TEST3, 151, 348, 294, 169)
        
        pdfDoc.setFont(PDF_HELVETICA, 9)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered(C_IMAGE_TEST3, 297, 332)
    ok

    # Row 3 - Three thumbnails
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 14)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Row 3: Three Thumbnails", 72, 310)

    thumbW = 135
    thumbH = 100
    thumbY = 190
    gap = 22

    if img1Exists
        pdfDoc.setFillColor([248, 248, 248])
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.drawFilledRect(72, thumbY, thumbW, thumbH)
        pdfDoc.drawImage(C_IMAGE_TEST1, 75, thumbY + 3, thumbW - 6, thumbH - 6)
        pdfDoc.setFont(PDF_HELVETICA, 8)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("PNG", 72 + thumbW / 2, thumbY - 12)
    ok

    if img2Exists
        thX = 72 + thumbW + gap
        pdfDoc.setFillColor([248, 248, 248])
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.drawFilledRect(thX, thumbY, thumbW, thumbH)
        pdfDoc.drawImage(C_IMAGE_TEST2, thX + 3, thumbY + 3, thumbW - 6, thumbH - 6)
        pdfDoc.setFont(PDF_HELVETICA, 8)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("JPEG", thX + thumbW / 2, thumbY - 12)
    ok

    if img3Exists
        thX = 72 + (thumbW + gap) * 2
        pdfDoc.setFillColor([248, 248, 248])
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.drawFilledRect(thX, thumbY, thumbW, thumbH)
        pdfDoc.drawImage(C_IMAGE_TEST3, thX + 3, thumbY + 3, thumbW - 6, thumbH - 6)
        pdfDoc.setFont(PDF_HELVETICA, 8)
        pdfDoc.setTextColor("gray")
        pdfDoc.drawTextCentered("BMP", thX + thumbW / 2, thumbY - 12)
    ok

    # Format comparison note
    pdfDoc.setFillColor([255, 255, 240])
    pdfDoc.setStrokeColor([220, 200, 150])
    pdfDoc.setLineWidth(1)
    pdfDoc.drawFilledRect(72, 80, 450, 80)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 11)
    pdfDoc.setTextColor([130, 100, 20])
    pdfDoc.drawText("Supported Image Formats:", 82, 142)

    pdfDoc.setFont(PDF_HELVETICA, 10)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("JPEG (.jpg) - Best for photos, small file size, lossy compression", 82, 125)
    pdfDoc.drawText("PNG  (.png) - Best for graphics/logos, lossless, supports transparency", 82, 110)
    pdfDoc.drawText("BMP  (.bmp) - Uncompressed, large file size, exact pixel data", 82, 95)

    if pdfDoc.save("demo_images_layout.pdf")
        ? "  Created: demo_images_layout.pdf"
    else
        ? "  FAILED: demo_images_layout.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 3: Image with Text Wrap Around
    # ------------------------------------------------------------------
    ? "Demo 3: Image with text flow..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Image with Text")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 26)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Travel Magazine", 72, 760)

    pdfDoc.setStrokeColor("navy")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 752, 523, 752)

    # Lead paragraph
    pdfDoc.setFont(PDF_HELVETICA, 12)
    pdfDoc.setTextColor("black")

    curY = pdfDoc.drawParagraph("Welcome to our monthly travel feature. In this issue we explore some of the most breathtaking destinations around the world and share our favorite photographs from recent journeys.", 72, 730, 451, 16)
    curY -= 20

    # Image on the right with text on left
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 16)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Featured Destination", 72, curY)
    curY -= 20

    if img1Exists
        # Place image on the right
        imgW = 200
        imgH = 150
        imgX = 323
        imgY = curY - imgH
        
        pdfDoc.setFillColor([240, 240, 240])
        pdfDoc.setStrokeColor([180, 180, 180])
        pdfDoc.setLineWidth(0.5)
        pdfDoc.drawFilledRect(imgX - 3, imgY - 3, imgW + 6, imgH + 6)
        pdfDoc.drawImage(C_IMAGE_TEST1, imgX, imgY, imgW, imgH)
        
        # Text flows beside the image (narrower width)
        pdfDoc.setFont(PDF_HELVETICA, 11)
        pdfDoc.setTextColor([60, 60, 60])
        textWidth = imgX - 72 - 15
        curY = pdfDoc.drawParagraph("The ancient city offers a stunning blend of history and modern culture. Walking through its cobblestone streets, visitors are transported back in time to an era of magnificent architecture and rich traditions.", 72, curY, textWidth, 15)
        curY -= 5
        curY = pdfDoc.drawParagraph("Local markets overflow with colorful textiles, aromatic spices, and handcrafted goods that tell stories of generations of artisans.", 72, curY, textWidth, 15)
        
        # After image, full-width text
        if curY > imgY
            curY = imgY - 15
        ok
    else
        curY -= 10
    ok

    pdfDoc.setFont(PDF_HELVETICA, 11)
    pdfDoc.setTextColor([60, 60, 60])
    curY = pdfDoc.drawParagraph("Beyond the historic center, natural wonders await. Crystal-clear waters and dramatic mountain landscapes make this region a paradise for nature lovers and adventure seekers alike. Whether hiking through dense forests or relaxing on sun-drenched beaches, every moment offers a new discovery.", 72, curY, 451, 15)
    curY -= 25

    # Second section with image on the left
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 16)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Culinary Journey", 72, curY)
    curY -= 20

    if img2Exists
        imgW = 180
        imgH = 130
        imgX = 72
        imgY = curY - imgH
        
        pdfDoc.setFillColor([240, 240, 240])
        pdfDoc.setStrokeColor([180, 180, 180])
        pdfDoc.setLineWidth(0.5)
        pdfDoc.drawFilledRect(imgX - 3, imgY - 3, imgW + 6, imgH + 6)
        pdfDoc.drawImage(C_IMAGE_TEST2, imgX, imgY, imgW, imgH)
        
        # Text flows to the right of image
        pdfDoc.setFont(PDF_HELVETICA, 11)
        pdfDoc.setTextColor([60, 60, 60])
        textX = imgX + imgW + 15
        textWidth = 523 - textX
        curY = pdfDoc.drawParagraph("No visit is complete without sampling the local cuisine. From street food vendors serving sizzling specialties to elegant restaurants offering fusion dishes that blend traditional recipes with contemporary techniques.", textX, curY, textWidth, 15)
        curY -= 5
        curY = pdfDoc.drawParagraph("The seafood markets are particularly renowned, offering the freshest catch prepared with techniques passed down through centuries.", textX, curY, textWidth, 15)
        
        if curY > imgY
            curY = imgY - 15
        ok
    else
        curY -= 10
    ok

    pdfDoc.setFont(PDF_HELVETICA, 11)
    pdfDoc.setTextColor([60, 60, 60])
    curY = pdfDoc.drawParagraph("We hope these images and stories inspire your next adventure. Travel opens our minds, enriches our souls, and connects us with people and places that forever change our perspective on the world.", 72, curY, 451, 15)

    if pdfDoc.save("demo_images_text.pdf")
        ? "  Created: demo_images_text.pdf"
    else
        ? "  FAILED: demo_images_text.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 4: Image Sizes and Scaling
    # ------------------------------------------------------------------
    ? "Demo 4: Image sizes and scaling..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Image Scaling Demo")

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 24)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Image Scaling & Sizing", 72, 760)

    pdfDoc.setStrokeColor("navy")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 752, 380, 752)

    if img2Exists
        # Small
        pdfDoc.setFont(PDF_HELVETICA_BOLD, 12)
        pdfDoc.setTextColor("black")
        pdfDoc.drawText("Small (80 x 60)", 72, 720)
        
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.setLineWidth(0.5)
        pdfDoc.drawRect(71, 649, 82, 62)
        pdfDoc.drawImage(C_IMAGE_TEST2, 72, 650, 80, 60)
        
        # Medium
        pdfDoc.drawText("Medium (200 x 150)", 200, 720)
        
        pdfDoc.drawRect(199, 559, 202, 152)
        pdfDoc.drawImage(C_IMAGE_TEST2, 200, 560, 200, 150)
        
        # Large
        pdfDoc.drawText("Large (400 x 250)", 72, 530)
        
        pdfDoc.drawRect(71, 269, 402, 252)
        pdfDoc.drawImage(C_IMAGE_TEST2, 72, 270, 400, 250)
        
        # Stretched
        pdfDoc.drawText("Stretched Wide (450 x 80)", 72, 240)
        
        pdfDoc.drawRect(71, 149, 452, 82)
        pdfDoc.drawImage(C_IMAGE_TEST2, 72, 150, 450, 80)

    elseif img1Exists
        pdfDoc.setFont(PDF_HELVETICA_BOLD, 12)
        pdfDoc.setTextColor("black")
        pdfDoc.drawText("Small (80 x 60)", 72, 720)
        pdfDoc.drawImage(C_IMAGE_TEST1, 72, 650, 80, 60)
        
        pdfDoc.drawText("Medium (200 x 150)", 200, 720)
        pdfDoc.drawImage(C_IMAGE_TEST1, 200, 560, 200, 150)
        
        pdfDoc.drawText("Large (400 x 250)", 72, 530)
        pdfDoc.drawImage(C_IMAGE_TEST1, 72, 270, 400, 250)
    else
        pdfDoc.setFont(PDF_HELVETICA, 14)
        pdfDoc.setTextColor("red")
        pdfDoc.drawTextCentered("No test images found for scaling demo", 297, 500)
    ok

    if pdfDoc.save("demo_images_scaling.pdf")
        ? "  Created: demo_images_scaling.pdf"
    else
        ? "  FAILED: demo_images_scaling.pdf"
    ok

    # ------------------------------------------------------------------
    # Demo 5: Photo Report with All Three Formats
    # ------------------------------------------------------------------
    ? "Demo 5: Photo report..."

    pdfDoc = new PDFWriter()
    pdfDoc.setTitle("Photo Report")
    pdfDoc.setAuthor("RingPDFLib")
    pdfDoc.enablePageNumbers()
    pdfDoc.setHeader("Photo Report - Confidential", PDF_ALIGN_LEFT)

    # === Cover Page ===
    pdfDoc.setFillColor([25, 25, 50])
    pdfDoc.drawFilledRectNoStroke(0, 0, 595.28, 841.89)

    # Decorative line
    pdfDoc.setFillColor([66, 133, 244])
    pdfDoc.drawFilledRectNoStroke(60, 440, 475, 4)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 40)
    pdfDoc.setTextColor("white")
    pdfDoc.drawTextCentered("Photo Report", 297.64, 520)

    pdfDoc.setFont(PDF_HELVETICA, 18)
    pdfDoc.setTextColor([150, 180, 255])
    pdfDoc.drawTextCentered("Image Format Comparison", 297.64, 470)

    pdfDoc.setFont(PDF_HELVETICA, 14)
    pdfDoc.setTextColor([180, 180, 200])
    pdfDoc.drawTextCentered("Generated by RingPDFLib", 297.64, 370)
    pdfDoc.drawTextCentered("Demonstrating PNG, JPEG, and BMP Support", 297.64, 345)

    # === Page 2: Comparison Table + Images ===
    pdfDoc.addPage()

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 22)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Format Comparison", 72, 750)

    pdfDoc.setStrokeColor("navy")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 742, 320, 742)

    # Comparison table
    compData = [
        ["Property", "JPEG", "PNG", "BMP"],
        ["Compression", "Lossy", "Lossless", "None"],
        ["File Size", "Small", "Medium", "Large"],
        ["Transparency", "No", "Yes (Alpha)", "No"],
        ["Best For", "Photos", "Graphics", "Raw Data"],
        ["Color Depth", "24-bit", "24/32-bit", "24-bit"],
        ["Extension", ".jpg / .jpeg", ".png", ".bmp"]
    ]

    curY = pdfDoc.drawTable(compData, 72, 725, [100, 118, 125, 125], [
        :headerBg = [33, 37, 41],
        :headerFg = "white",
        :evenRowBg = [240, 245, 250],
        :rowHeight = 22,
        :fontSize = 10
    ])

    curY -= 60

    # Show all three images side by side
    pdfDoc.setFont(PDF_HELVETICA_BOLD, 16)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Sample Images", 72, curY)
    curY -= 60

    imgW = 140
    imgH = 105

    # PNG
    pdfDoc.setFillColor([230, 240, 255])
    pdfDoc.setStrokeColor([100, 140, 220])
    pdfDoc.setLineWidth(1)
    pdfDoc.drawFilledRect(72, curY - imgH - 5, imgW + 10, imgH + 30)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 9)
    pdfDoc.setTextColor([41, 98, 255])
    pdfDoc.drawTextCentered("PNG", 72 + (imgW + 10) / 2, curY + 10)

    if img1Exists
        pdfDoc.drawImage(C_IMAGE_TEST1, 77, curY - imgH, imgW, imgH)
    ok

    # JPEG
    startX2 = 72 + imgW + 20
    pdfDoc.setFillColor([255, 235, 230])
    pdfDoc.setStrokeColor([220, 100, 80])
    pdfDoc.drawFilledRect(startX2, curY - imgH - 5, imgW + 10, imgH + 30)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 9)
    pdfDoc.setTextColor([234, 67, 53])
    pdfDoc.drawTextCentered("JPEG", startX2 + (imgW + 10) / 2, curY + 10)

    if img2Exists
        pdfDoc.drawImage(C_IMAGE_TEST2, startX2 + 5, curY - imgH, imgW, imgH)
    ok

    # BMP
    startX3 = startX2 + imgW + 20
    pdfDoc.setFillColor([230, 255, 235])
    pdfDoc.setStrokeColor([80, 180, 100])
    pdfDoc.drawFilledRect(startX3, curY - imgH - 5, imgW + 10, imgH + 30)

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 9)
    pdfDoc.setTextColor([52, 168, 83])
    pdfDoc.drawTextCentered("BMP", startX3 + (imgW + 10) / 2, curY + 10)

    if img3Exists
        pdfDoc.drawImage(C_IMAGE_TEST3, startX3 + 5, curY - imgH, imgW, imgH)
    ok

    # === Page 3: Full Size Showcase ===
    pdfDoc.addPage()

    pdfDoc.setFont(PDF_HELVETICA_BOLD, 22)
    pdfDoc.setTextColor("navy")
    pdfDoc.drawText("Full Size Showcase", 72, 750)

    pdfDoc.setStrokeColor("navy")
    pdfDoc.setLineWidth(2)
    pdfDoc.drawLine(72, 742, 320, 742)

    pdfDoc.setFont(PDF_HELVETICA, 11)
    pdfDoc.setTextColor("black")
    pdfDoc.drawText("All three images displayed at 451 x 200 points:", 72, 720)

    curY = 690

    if img1Exists
        pdfDoc.setFont(PDF_HELVETICA_BOLD, 11)
        pdfDoc.setTextColor([41, 98, 255])
        pdfDoc.drawText(C_IMAGE_TEST1, 72, curY)
        curY -= 10
        
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.setLineWidth(0.5)
        pdfDoc.drawRect(71, curY - 201, 453, 202)
        pdfDoc.drawImage(C_IMAGE_TEST1, 72, curY - 200, 451, 200)
        curY -= 220
    ok

    if img2Exists
        pdfDoc.setFont(PDF_HELVETICA_BOLD, 11)
        pdfDoc.setTextColor([234, 67, 53])
        pdfDoc.drawText(C_IMAGE_TEST2, 72, curY)
        curY -= 10
        
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.setLineWidth(0.5)
        pdfDoc.drawRect(71, curY - 201, 453, 202)
        pdfDoc.drawImage(C_IMAGE_TEST2, 72, curY - 200, 451, 200)
        curY -= 220
    ok

    if img3Exists
        if curY < 250
            pdfDoc.addPage()
            curY = 750
        ok
        
        pdfDoc.setFont(PDF_HELVETICA_BOLD, 11)
        pdfDoc.setTextColor([52, 168, 83])
        pdfDoc.drawText(C_IMAGE_TEST3, 72, curY)
        curY -= 10
        
        pdfDoc.setStrokeColor([200, 200, 200])
        pdfDoc.setLineWidth(0.5)
        pdfDoc.drawRect(71, curY - 201, 453, 202)
        pdfDoc.drawImage(C_IMAGE_TEST3, 72, curY - 200, 451, 200)
    ok

    if pdfDoc.save("demo_images_report.pdf")
        ? "  Created: demo_images_report.pdf"
    else
        ? "  FAILED: demo_images_report.pdf"
    ok

    # ------------------------------------------------------------------
    ? ""
    ? "=============================================="
    ? "   All image demos completed!"
    ? "=============================================="
    ? ""
    ? "Created files:"
    ? "  1. demo_images_gallery.pdf  - One image per page gallery"
    ? "  2. demo_images_layout.pdf   - Multiple images on one page"
    ? "  3. demo_images_text.pdf     - Images with text flow"
    ? "  4. demo_images_scaling.pdf  - Different sizes and scaling"
    ? "  5. demo_images_report.pdf   - Full photo report"
    ? ""
    ? "Supported image formats: JPEG (.jpg), PNG (.png), BMP (.bmp)"
