$path = "C:\Users\UserName\Documents\Temp\test" 
"Remember to put the document in a trusted location: Trust Center -> Trusted Locations" 
Add-Type -AssemblyName Microsoft.Office.Interop.Excel 
$xlRemoveDocType = "Microsoft.Office.Interop.Excel.XlRemoveDocInfoType" -as [type] 
$excelFiles = Get-ChildItem -Path $path -include *.xls, *.xlsx -recurse 
$objExcel = New-Object -ComObject excel.application 
$objExcel.visible = $false 
foreach($wb in $excelFiles) 
{ 
$workbook = $objExcel.workbooks.open($wb.fullname) 
"Removing document information from $wb"
"If it is an XLS document remember to run sed -i 's/[USERNAME]/[SAME#CHARS]g' [File Name]"
"Remember to Right Click Properties -> Details -> Remove Properties"
$workbook.RemoveDocumentInformation($xlRemoveDocType::xlRDIAll) 
$workbook.Save() 
$objExcel.Workbooks.close() 
} 
$objExcel.Quit() 
