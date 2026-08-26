Add-Type -AssemblyName System.Drawing

$srcPath = 'D:\Web\PVZ-Godot\pvz_icon.png'
$dstPath = 'D:\Web\PVZ-Godot\pvz_icon_new.ico'

$src = [System.Drawing.Image]::FromFile($srcPath)
Write-Host "source: $($src.Width)x$($src.Height)"

$sizes = @(16,24,32,48,64,128,256)
$entries = @()
foreach ($s in $sizes) {
    $bmp = New-Object System.Drawing.Bitmap($s, $s)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($src, 0, 0, $s, $s)
    $g.Dispose()
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $entries += ,@($s, $ms.ToArray())
    $bmp.Dispose()
    $ms.Dispose()
}
$src.Dispose()

$fs = [System.IO.File]::Create($dstPath)
$bw = New-Object System.IO.BinaryWriter($fs)
$bw.Write([uint16]0)                 # reserved
$bw.Write([uint16]1)                 # type: icon
$bw.Write([uint16]$entries.Count)    # count
$offset = 6 + 16 * $entries.Count
foreach ($e in $entries) {
    $s = $e[0]
    $dim = 0
    if ($s -lt 256) { $dim = $s }
    $bw.Write([byte]$dim)            # width (0 => 256)
    $bw.Write([byte]$dim)            # height
    $bw.Write([byte]0)               # palette
    $bw.Write([byte]0)               # reserved
    $bw.Write([uint16]1)             # planes
    $bw.Write([uint16]32)            # bpp
    $bw.Write([uint32]$e[1].Length)  # data size
    $bw.Write([uint32]$offset)       # data offset
    $offset += $e[1].Length
}
foreach ($e in $entries) {
    $bw.Write($e[1])
}
$bw.Dispose()
$fs.Dispose()
Write-Host "written: $dstPath ($((Get-Item $dstPath).Length) bytes)"

# verify
$chk = [System.IO.File]::ReadAllBytes($dstPath)
$cnt = [BitConverter]::ToUInt16($chk, 4)
for ($i = 0; $i -lt $cnt; $i++) {
    $o = 6 + $i * 16
    $w = $chk[$o]
    if ($w -eq 0) { $w = 256 }
    $len = [BitConverter]::ToUInt32($chk, $o + 8)
    Write-Host ("entry {0}: {1}px dataLen={2}" -f $i, $w, $len)
}
