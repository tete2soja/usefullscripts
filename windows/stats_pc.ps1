[CmdletBinding()]
param(
    [switch]$SaveImage
)

function createChart {
    param(
        $position,
        $data,
        [string]$description
        )
    # create chart object 
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart.Width = $position[0]
    $Chart.Height = $position[1]
    $Chart.Left = $position[2]
    $Chart.Top = $position[3]
    # create a chartarea to draw on and add to chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Chart.ChartAreas.Add($ChartArea)
    # add title and axes labels
    [void]$Chart.Titles.Add($description)
    # add data to chart
    [void]$Chart.Series.Add("Data")
    $Chart.Series["Data"].Points.DataBindXY($data.Keys, $data.Values)
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
                    [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Leff
    return $Chart
}

function createDataGridView {
    param(
        $form,
        $position,
        $data,
        [string]$description
        )

    $dataGridView = New-Object System.Windows.Forms.DataGridView
    $dataGridView.AutoSize = $true
    $dataGridView.AutoSizeColumnsMode = "AllCells"
    $form.Controls.Add($dataGridView)
    $dataGridView.ColumnCount = 2
    $dataGridView.top = $position[0]
    $dataGridView.left = $position[1]
    $dataGridView.ColumnHeadersVisible = $true
    $dataGridView.Columns[0].Name = $description
    $dataGridView.Columns[1].Name = "Nombre"
    foreach($value in $data.keys) {
        $dataGridView.Rows.Add($value, $data[$value])
    }
}

$OS = @{}
$RAM = @{}
$CPU = @{}
$CORE = @{}

$tri = Import-Csv C:\stats.csv

$unique = $tri | select -Unique buildnumber,name

foreach( $value in $unique) {
    $count = $($tri | where -filter {$_.buildnumber -eq $value.buildnumber -and $_.name -like "*server*"} | measure).Count
    if ( $count -ne 0 ) { $OS.Add($value.Name, $count) }
    $count = $($tri | where -filter {$_.buildnumber -eq $value.buildnumber -and $_.name -notlike "*server*"} | measure).Count
    if ( $count -ne 0 ) { $OS.Add($value.Name, $count) }
}

$unique = $tri | select -Unique ram

foreach( $value in $unique) {
    Write-Host $value
    $count = $($tri | where -filter {$_.ram -eq $value.ram} | measure).Count
    if ( $count -ne 0 ) { $RAM.Add($value.ram, $count) }
}

$unique = $tri | select -Unique cpu

foreach( $value in $unique) {
    Write-Host $value
    $count = $($tri | where -filter {$_.cpu -eq $value.cpu} | measure).Count
    if ( $count -ne 0 ) { $CPU.Add($value.cpu, $count) }
}

$unique = $tri | select -Unique coeur

foreach( $value in $unique) {
    Write-Host $value
    $count = $($tri | where -filter {$_.coeur -eq $value.coeur} | measure).Count
    if ( $count -ne 0 ) { $CORE.Add($value.coeur, $count) }
}

# load the appropriate assemblies 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

$position = @(300,225,40,10)
$Chart = createChart $position $OS "Repartition des OS"

$position = @(300,225,440,10)
$Chart2 = createChart $position $RAM "Repartition de la RAM"

$position = @(300,225,40,410)
$Chart3 = createChart $position $CPU "Repartition des modeles CPU"

$position = @(300,225,440,410)
$Chart4 = createChart $position $CORE "Repartition du nombre de coeurs"

if ($Save) {
    $Chart.SaveImage($HOME+"\Desktop\OS.png", "PNG")
    $Chart2.SaveImage($HOME+"\Desktop\OS.png", "PNG")
    $Chart3.SaveImage($HOME+"\Desktop\OS.png", "PNG")
    $Chart4.SaveImage($HOME+"\Desktop\OS.png", "PNG")
}

$Form = New-Object Windows.Forms.Form 
$Form.Text = "OS"
$Form.AutoSize = $True
$Form.AutoSizeMode = "GrowAndShrink"
$Form.MinimizeBox = $False
$Form.MaximizeBox = $False
$Form.FormBorderStyle = "FixedDialog"

#$pathlabel = New-Object System.Windows.Forms.Label
#$pathlabel.top = 250
#$pathlabel.left = 60
#$pathlabel.Width = 350
#$pathlabel.Height = 60
#$Font = New-Object System.Drawing.Font("Times New Roman",12)
#$pathlabel.Font =  $Font
#$pathlabel.Text = $text
#$Form.controls.add($pathlabel)

createDataGridView $form @(240,45) $OS "OS"

createDataGridView $form @(240,450) $RAM "RAM en GB"

createDataGridView $form @(640,35) $CPU "CPU model"

createDataGridView $form @(640,450) $CORE "Nb cores"


$Form.controls.add($Chart)
$Form.controls.add($Chart2)
$Form.controls.add($Chart3)
$Form.controls.add($Chart4)
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()