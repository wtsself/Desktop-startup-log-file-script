Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
#  配置区：按需修改以下路径
# ============================================================
$LogRoot    = "C:\Users\LG71\Desktop\工作日志"
$NotepadExe = "D:\Notepad++\notepad++.exe"
# ============================================================

# ---------- 主窗体 ----------
$form                  = New-Object System.Windows.Forms.Form
$form.Text             = "工作日志快速启动器"
$form.Size             = New-Object System.Drawing.Size(720, 540)
$form.StartPosition    = "CenterScreen"
$form.FormBorderStyle  = "FixedSingle"
$form.MaximizeBox      = $false
$form.BackColor        = [System.Drawing.Color]::FromArgb(245, 246, 250)

# ---------- 字体 ----------
$fontTitle  = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$fontNormal = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)

# ---------- 左侧：日期文件夹列表 ----------
$lblFolder          = New-Object System.Windows.Forms.Label
$lblFolder.Text     = "📁  日期文件夹"
$lblFolder.Location = New-Object System.Drawing.Point(15, 12)
$lblFolder.Size     = New-Object System.Drawing.Size(210, 24)
$lblFolder.Font     = $fontTitle

$lstFolder                  = New-Object System.Windows.Forms.ListBox
$lstFolder.Location         = New-Object System.Drawing.Point(15, 40)
$lstFolder.Size             = New-Object System.Drawing.Size(210, 410)
$lstFolder.Font             = $fontNormal
$lstFolder.BorderStyle      = "FixedSingle"
$lstFolder.BackColor        = [System.Drawing.Color]::White
$lstFolder.IntegralHeight   = $false

# ---------- 右侧：文件列表 ----------
$lblFile          = New-Object System.Windows.Forms.Label
$lblFile.Text     = "📄  日志文件（双击或点击`"打开`"）"
$lblFile.Location = New-Object System.Drawing.Point(242, 12)
$lblFile.Size     = New-Object System.Drawing.Size(460, 24)
$lblFile.Font     = $fontTitle

$lstFile                = New-Object System.Windows.Forms.ListBox
$lstFile.Location       = New-Object System.Drawing.Point(242, 40)
$lstFile.Size           = New-Object System.Drawing.Size(460, 380)
$lstFile.Font           = $fontNormal
$lstFile.BorderStyle    = "FixedSingle"
$lstFile.BackColor      = [System.Drawing.Color]::White
$lstFile.IntegralHeight = $false

# ---------- 底部按钮区 ----------
$btnOpen            = New-Object System.Windows.Forms.Button
$btnOpen.Text       = "用 Notepad++ 打开"
$btnOpen.Location   = New-Object System.Drawing.Point(242, 432)
$btnOpen.Size       = New-Object System.Drawing.Size(200, 36)
$btnOpen.Font       = $fontNormal
$btnOpen.BackColor  = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnOpen.ForeColor  = [System.Drawing.Color]::White
$btnOpen.FlatStyle  = "Flat"
$btnOpen.FlatAppearance.BorderSize = 0
$btnOpen.Cursor     = [System.Windows.Forms.Cursors]::Hand

$btnRefresh           = New-Object System.Windows.Forms.Button
$btnRefresh.Text      = "🔄 刷新列表"
$btnRefresh.Location  = New-Object System.Drawing.Point(15, 462)
$btnRefresh.Size      = New-Object System.Drawing.Size(210, 32)
$btnRefresh.Font      = $fontNormal
$btnRefresh.FlatStyle = "Flat"
$btnRefresh.Cursor    = [System.Windows.Forms.Cursors]::Hand

$lblStatus          = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(242, 476)
$lblStatus.Size     = New-Object System.Drawing.Size(460, 20)
$lblStatus.Font     = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$lblStatus.ForeColor = [System.Drawing.Color]::Gray

# ============================================================
#  函数：加载日期文件夹
# ============================================================
function Load-Folders {
    $lstFolder.Items.Clear()
    $lstFile.Items.Clear()
    $lblStatus.Text = ""

    if (-not (Test-Path $LogRoot)) {
        [System.Windows.Forms.MessageBox]::Show(
            "未找到日志根目录：`n$LogRoot`n`n请确认目录存在。",
            "目录不存在",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        $lblStatus.Text = "⚠ 目录不存在：$LogRoot"
        return
    }

    $dirs = Get-ChildItem -Path $LogRoot -Directory |
            Sort-Object Name -Descending

    if ($dirs.Count -eq 0) {
        $lblStatus.Text = "（暂无子文件夹）"
        return
    }

    foreach ($d in $dirs) {
        $lstFolder.Items.Add($d.Name) | Out-Null
    }

    $lblStatus.Text = "共找到 $($dirs.Count) 个日期文件夹"
}

# ============================================================
#  函数：根据所选文件夹加载文件
# ============================================================
function Load-Files {
    $lstFile.Items.Clear()
    $lblStatus.Text = ""

    $selected = $lstFolder.SelectedItem
    if (-not $selected) { return }

    $folderPath = Join-Path $LogRoot $selected

    $files = Get-ChildItem -Path $folderPath -File |
             Where-Object { $_.Extension -match '\.(txt|log|md|csv)$' } |
             Sort-Object Name

    if ($files.Count -eq 0) {
        $lblStatus.Text = "「$selected」下暂无文本文件"
        return
    }

    foreach ($f in $files) {
        $lstFile.Items.Add($f.Name) | Out-Null
    }

    $lblStatus.Text = "「$selected」共 $($files.Count) 个文件"
}

# ============================================================
#  函数：打开选中文件
# ============================================================
function Open-SelectedFile {
    $folder = $lstFolder.SelectedItem
    $file   = $lstFile.SelectedItem

    if (-not $folder -or -not $file) {
        [System.Windows.Forms.MessageBox]::Show(
            "请先在左侧选择日期文件夹，再在右侧选择要打开的文件。",
            "未选择文件",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    $filePath = Join-Path (Join-Path $LogRoot $folder) $file

    if (-not (Test-Path $filePath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "文件不存在：`n$filePath",
            "错误",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return
    }

    if (-not (Test-Path $NotepadExe)) {
        # 回退：使用系统默认程序打开
        $result = [System.Windows.Forms.MessageBox]::Show(
            "未找到 Notepad++：`n$NotepadExe`n`n是否用系统默认程序打开？",
            "Notepad++ 未找到",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-Process $filePath
        }
        return
    }

    Start-Process -FilePath $NotepadExe -ArgumentList "`"$filePath`""
    $lblStatus.Text = "已打开：$file"
}

# ============================================================
#  事件绑定
# ============================================================
$lstFolder.Add_SelectedIndexChanged({ Load-Files })
$lstFile.Add_DoubleClick({ Open-SelectedFile })
$btnOpen.Add_Click({ Open-SelectedFile })
$btnRefresh.Add_Click({ Load-Folders })

# ---------- 组装控件 ----------
$form.Controls.AddRange(@(
    $lblFolder, $lstFolder,
    $lblFile,   $lstFile,
    $btnOpen,   $btnRefresh,
    $lblStatus
))

# ---------- 初始化 ----------
Load-Folders

[void]$form.ShowDialog()
