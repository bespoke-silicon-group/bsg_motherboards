' This script takes a monochrome, uncompressed bitmap image
' and places a shape consisting of lines on the destination layer
' Curently only imperial units are supported 
' for specifying the line width but that does not impede
' using it with a metric database.
' How it works: Black pixels in the image are searched
' and converted into 2D Line elemnents. All 2D lines
' are combined to form one shape. Make sure 2D Lines
' visibility on the destination layer is turned on.
' To use the resulting shape in PADS Logic you have to
' save it to library from Layout and then use
' "Add 2D Line from Library" command in Logic.
'------------------------------------------------------
' Author: benradu at gmail dot com
' Released for public on Feb , 2013
'------------------------------------------------------
' THIS SCRIPT IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
' EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
' WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
' PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHOR
' BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
' WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
' ARISING FROM, OUT OF OR IN CONNECTION WITH THIS WORK.
'------------------------------------------------------
' ANY MODIFICATION TO THIS SCRIPT SHOULD BE CONTRIBUTED
' BACK TO THE ORIGINAL AUTHOR
'------------------------------------------------------
' Revisions:
'
' Date: 2013-02, Ver 1.1
' The destination layer can be selected from the drop down list
'
' Date: 2013-02, Ver 1.0, Initial Release
'------------------------------------------------------
Option Explicit
' -----------------------------------------------------
Type BmpHeaderTyp
	ID As String*2
	FSize As Long
	Rsvd As Long
	DataOffset As Long
	HdrSize As Long
	WidthPx As Long
	HeightPx As Long
	Planes As Integer
	Bpp As Integer	' bits per pixel
	Compression As Long ' should be 0
	DataSize As Long
	Hresolution As Long
	Vresolution As Long
	Colors As Long
	ImportantColors As Long
	Palette1 As Long
	Palette2 As Long
End Type
Dim LayersList$()
Const DEF_DEST_LAYER_NO	= 26	' default destination layer: Silk Screen
Const DEF_LINE_WIDTH_MILLS = 10 ' default line width in mills
' -----------------------------------------------
Sub Main
On Error Resume Next
Dim LayerDocCount As Integer
Dim DLayer
'

	ReDim LayersList$ (0 To Application.ActiveDocument.LayerCount-1)
	With Application.ActiveDocument
	LayerDocCount = 0
	For Each DLayer In .Layers
		'If (DLayer.Type = ppcbLayerSilkscreen)  Or (DLayer.Type = ppcbLayerAssembly) Then
			LayersList$(LayerDocCount) = DLayer.Name
			LayerDocCount = LayerDocCount + 1
		'End If
	Next DLayer
	ReDim Preserve LayersList$ (0 To LayerDocCount-1)
	End With
	
	Begin Dialog UserDialog 700,259,"Image2Layout",.DialogFunc ' %GRID:10,7,1,1
		GroupBox 10,7,680,245,"",.GroupBox1
		PushButton 20,21,140,28,"Open Image File",.btnOpen
		PushButton 20,217,180,28,"Create Ascii Only",.btnAscii
		PushButton 240,217,180,28,"Create Ascii then Import",.btnAsciiImport
		DropListBox 20,189,270,21,LayersList(),.lstDocLayers
		Text 20,56,230,14,"Image File Name:",.Text1
		CheckBox 20,126,170,14,"Invert Image",.chkInvert
		CancelButton 560,217,120,28
		Text 20,70,360,35,"",.txtFileName
		Text 20,147,200,14,"LineWidth (mills):",.Text2
		TextBox 250,140,120,21,.txtLSize
		Text 20,168,270,14,"Place Shape On Layer:",.Text3
		Picture 390,21,290,175,"Picture1",0,.picPreview
	End Dialog
	Dim dlg As UserDialog
	Dialog dlg
	
End Sub

Function DialogFunc(DlgItem$, Action%, SuppValue%) _
     As Boolean
  On Error GoTo ErrHand   
     Dim FileName As String
     Dim DestLayer As Integer
     Dim InvertSetting As Boolean
     Dim LSize As Long
    '----------------------------
    Select Case Action%
    Case 1 ' Dialog box initialization
    '
    	DlgText "txtFileName", "Select an image file..."
    	DlgEnable "btnAscii", False
    	DlgEnable "btnAsciiImport", False
    	'DlgEnable "lstDocLayers", False
    	DlgValue "lstDocLayers", FindLayerListIndex(DEF_DEST_LAYER_NO)
    	DlgText "txtLSize", CStr(DEF_LINE_WIDTH_MILLS)
    Case 2 ' Value changing or button pressed
    '
    	'Debug.Print "Button " & DlgItem$
    	Select Case DlgItem$
    	Case "btnOpen"
    		FileName = GetFilePath$ ( , "bmp", , "Select Bitmap File", 0)
    		DialogFunc = True 'do not exit the dialog
			If FileName <> "" Then
    			DlgText "txtFileName", FileName
    			DlgEnable "btnAscii", True
    			DlgEnable "btnAsciiImport", True
    			DlgSetPicture "picPreview", FileName, 0
    		End If
    	Case "chkInvert"
    		DialogFunc = True 'do not exit the dialog
    	Case "btnAscii"
    		LSize = CLng(DlgText("txtLSize"))
    		InvertSetting = IIf(DlgValue("chkInvert") = 1, True, False)
    		FileName = DlgText ("txtFileName")
    		DestLayer = FindLayerNumber(DlgValue ("lstDocLayers"))
    		If GenerateAsciiFile(FileName, LSize, DestLayer, InvertSetting) <> "OK" Then
    			MsgBox "An error occured during file processing!"
    		End If
    		DialogFunc = True 'do not exit the dialog
    	Case "btnAsciiImport"
    		LSize = CLng(DlgText("txtLSize"))
    		InvertSetting = IIf(DlgValue("chkInvert") = 1, True, False)
    		FileName = DlgText ("txtFileName")
    		DestLayer = FindLayerNumber(DlgValue ("lstDocLayers"))
    		If GenerateAsciiFile(FileName, LSize, DestLayer, InvertSetting) = "OK" Then
    			ActiveDocument.ImportECOFile(Application.ActiveDocument.FullName & "_img2pcb.asc")  	
    		Else
    			MsgBox "An error occured during file processing!"
    		End If
    		DialogFunc = True 'do not exit the dialog
    	End Select
    Case 3 ' TextBox or ComboBox text changed
    '
    Case 4 ' Focus changed
    '
    Case 5 ' Idle
    '
    Case 6 ' Function key
    '
    End Select
Exit Function
ErrHand:
	MsgBox("The followig error occured:" & Chr(13) & Chr(10) & Err.Description)
End Function

Function GenerateAsciiFile(Imagefile As String, LineWidth As Long, LayerNumber As Integer, InvertImage As Boolean) As String
On Error GoTo FErrHandler
'
Dim BmpHeader As BmpHeaderTyp	' holds the bitmap file header
Dim x1, x2 As Variant		' X position counters
Dim Ypos As Variant 		' Y position counter
Dim bword, bw_mask As Byte 	' used to analyze each bit in the bitmap
Dim bword_bytes(0 To 3) As Byte ' USED TO READ 4 BYTES AT ONCE FROM THE IMAGE FILE
Dim LineStarted As Boolean 	' this var keeps track of a line started or not
Dim InStr3 As String		' a string used to store lines to be copied ftom temp file in the asc file
Dim NumberOfElements As Long ' counter for the number of elemnts in the shape
Dim iLine, iPix As Long
Dim PaletteInv As Boolean
'
Dim asc_fname, tmp_fname As String
	'-------------------------
	Open ImageFile For Binary Access Read As #2
	' Get the bitmat header
	Get #2, , BmpHeader
	If (BmpHeader.ID <> "BM") Or (BmpHeader.Bpp <> 1) Or (BmpHeader.Compression <> 0) Then
		MsgBox "File Not Supported." & vbCrLf & "The file is not a bitmap file or is not monochrome or is compressed."
		GenerateAsciiFile = "Err"
		Close #2
		Exit Function
	End If
	' Do some checks on the header
	PaletteInv = IIf(BmpHeader.Palette1 = -1, False, True) Xor InvertImage
	'------------------------Application.ActiveDocument.FullNam
	asc_fname = Application.ActiveDocument.FullName & "_img2pcb.asc"
	tmp_fname = Application.ActiveDocument.FullName & "_img2pcb_tmp.asc"
	'-------------------------
	Open tmp_fname For Output As #3
	' Create a temporary file containing all lines composing the image
	Ypos = 0
	NumberOfElements = 0
	' -----Read all pixels and create line segments from them
	For iLine = 1 To BmpHeader.HeightPx
		x1 = 0
		x2 = 0
		LineStarted = False
		
		For iPix = 0 To BmpHeader.WidthPx-1
			' Read in multiple of 4 bytes
			If (iPix Mod 32) = 0 Then
				Get #2, , bword_bytes
			End If
			' Get bytes one by one from the array of four bytes
			If (iPix Mod 8) = 0 Then
				bword = bword_bytes((iPix Mod 32) / 8)
				bw_mask = &H80
			End If
			'-------------------------
			If ((bw_mask And bword) <> 0) Xor PaletteInv Then
				If LineStarted = False Then
					x1 = x2 ' start a new line
					LineStarted = True
				End If
			Else
				If LineStarted = True Then
					LineStarted = False
					Print #3, "OPEN   2   " & LineWidth & "   " & LayerNumber & "   "
					Print #3, x1 & "   " & Ypos
					Print #3, (x2 - LineWidth + 1) & "   " & Ypos
					NumberOfElements = NumberOfElements + 1
				End If
			End If
			'------------------------
			bw_mask = bw_mask / 2
			x2 = x2 + LineWidth
		Next iPix
		' Forcefully end the line if necessary
		If LineStarted = True Then
			LineStarted = False
			Print #3, "OPEN   2   " & LineWidth & "   " & LayerNumber & "   "
			Print #3, x1 & "   " & Ypos
			Print #3, (x2 - LineWidth + 1) & "   " & Ypos
			NumberOfElements = NumberOfElements + 1
		End If
		Ypos = Ypos + LineWidth
	Next iLine
	Close #3
	' ------
	Open asc_fname For Output As #1
	Print #1, "!PADS-POWERPCB-V9.0-MILS! DESIGN DATABASE ASCII FILE 1.0"
	Print #1, "*LINES*      LINES ITEMS"
	Print #1, ""
	Print #1, "*REMARK* NAME TYPE XLOC YLOC PIECES TEXT SIGSTR"
	Print #1, "*REMARK* .REUSE. INSTANCE RSIGNAL"
	Print #1, "*REMARK* PIECETYPE CORNERS WIDTHHGHT LEVEL RESTRICTIONS"
	Print #1, "*REMARK* XLOC YLOC BEGINANGLE DELTAANGLE"
	Print #1, "*REMARK* XLOC YLOC ORI LEVEL HEIGHT WIDTH MIRRORED HJUST VJUST"
	Print #1, ""
	Randomize
	Print #1, "IMG2ASC" & CLng(Rnd()*1000) & "      LINES    0      0      " & NumberOfElements & "   0"
	Print #1, ""
	' Header printed, Now copy tmp file containing the lines into the asc file
	Open tmp_fname For Input As #3
	While Not EOF(3)
		Line Input #3, InStr3$
		Print #1, InStr3$
	Wend
	' Append the footer
	Print #1, ""
	Print #1, "*END*     OF ASCII OUTPUT FILE"
	' close all files
	Close #1
	Close #2
	Close #3
	' Cleanup, delete the temporary file
	Kill tmp_fname
	GenerateAsciiFile = "OK"
	Exit Function
FErrHandler:
	GenerateAsciiFile = "Err"
End Function
Function FindLayerNumber(ListIndex As Integer) As Integer
Dim DLayer
	For Each DLayer In Application.ActiveDocument.Layers
		If DLayer.Name = LayersList$(ListIndex) Then
			FindLayerNumber = DLayer.Number
			Exit Function
		End If
	Next DLayer
	FindLayerNumber = DEF_DEST_LAYER_NO
End Function
Function FindLayerListIndex(LayerNumber As Integer) As Integer
Dim Lindex As Integer
	For Lindex = LBound(LayersList$) To UBound(LayersList$)
		If LayersList$(Lindex) = Application.ActiveDocument.Layers(LayerNumber).Name Then
			FindLayerListIndex = Lindex
			Exit Function
		End If
	Next Lindex
	FindLayerListIndex = 0
End Function
