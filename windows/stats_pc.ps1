$correspondances = @{}

$tri = Import-Csv C:\stats.csv

$unique = $tri | select -Unique buildnumber,name

foreach( $value in $unique) {
    Write-Host $value
    $count = $($tri | where -filter {$_.buildnumber -eq $value.buildnumber -and $_.name -like "*server*"} | measure).Count
    if ( $count -ne 0 ) { $correspondances.Add($value.Name, $count) }
    $count = $($tri | where -filter {$_.buildnumber -eq $value.buildnumber -and $_.name -notlike "*server*"} | measure).Count
    if ( $count -ne 0 ) { $correspondances.Add($value.Name, $count) }
}

Write-Host $correspondances["Microsoft Windows Server 2012 R2 Standard"]
Write-Host $correspondances["Widows 8.1"]

# load the appropriate assemblies 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")





# create chart object 
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
$Chart.Width = 600 
$Chart.Height = 450 
$Chart.Left = 40 
$Chart.Top = 30



# create a chartarea to draw on and add to chart 
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
$Chart.ChartAreas.Add($ChartArea)

# add title and axes labels 
[void]$Chart.Titles.Add("Repartition des OS") 


# add data to chart 
[void]$Chart.Series.Add("Data") 
$Chart.Series["Data"].Points.DataBindXY($correspondances.Keys, $correspondances.Values)

# Find point with max/min values and change their colour 
$maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue() 
$maxValuePoint.Color = [System.Drawing.Color]::Red

$minValuePoint = $Chart.Series["Data"].Points.FindMinByValue() 
$minValuePoint.Color = [System.Drawing.Color]::Green



# change chart area colour 
$Chart.BackColor = [System.Drawing.Color]::Transparent


$Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie
# set chart options 
$Chart.Series["Data"]["PieLabelStyle"] = "Outside" 
$Chart.Series["Data"]["PieLineColor"] = "Black" 
$Chart.Series["Data"]["PieDrawingStyle"] = "Concave" 
($Chart.Series["Data"].Points.FindMaxByValue())["Exploded"] = $true



# display the chart on a form 
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor 
                [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
$Form = New-Object Windows.Forms.Form 
$Form.Text = "OS" 
$Form.Width = 800 
$Form.Height = 800 
$Form.controls.add($Chart) 
$Form.Add_Shown({$Form.Activate()}) 
$Form.ShowDialog()