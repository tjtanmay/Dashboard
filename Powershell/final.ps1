$excel = New-Object -Com Excel.Application
$wb = $excel.Workbooks.Open("C:\Users\Tanmay\Desktop\Dashboard\info.xlsx")
$ws=$wb.Worksheets.Item("Sheet1")
$UsedRange = $ws.usedrange
ForEach($Row in ($UsedRange.Rows)){
 $Row.cells.Item(1).text
}
$wb.close()
