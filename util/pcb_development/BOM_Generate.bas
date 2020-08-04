' BOM Generate Script
'
' This script traverses all components in the PCB file and creates a CSV file
' with the follwoing format:
'
'	<reference>,<description [(value)]>
'
' 	Note: The (value) will be excluded if no value is present for the component
'
' This csv file is then passed to a python script that will process the data and
' create the final BOM.

Const tempFile = "temp_bom.csv"
Const pythonScript = "BOM_Generate.py"

Sub Main

	' Create and open a temp file
	Open tempFile For Output As #1

	' Ouput necessary info for each component in the current document
	For Each part In ActiveDocument.Components
		' Print the reference
		Print #1, part.Name & ",";
		
		' Print the description
		Print #1, part.PartType;
		
		' Traverse backwards through the attributes (value is often near the end of the attribute list)
		For i = part.Attributes.Count To 1 Step -1
			If (part.Attributes(i).Name = "Value") Then
				' Print the (value) if found
				Print #1, " (" & part.Attributes(i).value & ")";
				Exit For
			End If
		Next
		
		' New line
		Print #1
	Next
	
	' Close the file descriptor
	Close #1
	
	' Shell out to the python script (passing the tempFile as an argument)
	Shell("python " & pythonScript & " " & tempFile)
	
End Sub
