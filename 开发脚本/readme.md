# 工作日志快速启动器

快速浏览并用 Notepad++ 打开工作日志文本文件的桌面工具。

## 文件说明

| 文件 | 说明 |
|------|------|
| `启动日志查看器.bat` | 双击运行入口 |
| `工作日志启动器.ps1` | 主程序（WinForms 图形界面） |

## 使用方法

双击 `启动日志查看器.bat`，在左侧选择日期文件夹，右侧双击文件或点击"打开"按钮即可用 Notepad++ 打开。

## 配置

编辑 `工作日志启动器.ps1` 顶部配置区：

```powershell
$LogRoot    = "C:\Users\LG71\Desktop\工作日志"  # 日志根目录
$NotepadExe = "D:\Notepad++\notepad++.exe"       # Notepad++ 路径
```

## 注意事项

- 需要 Windows PowerShell 5.x
- PS1 文件编码须为 **UTF-8 with BOM**
