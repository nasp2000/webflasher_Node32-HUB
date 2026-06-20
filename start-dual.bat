@echo off
cd /d "%~dp0"
title Node32-HUB Configurator
set "PSFILE=%TEMP%\n32hub_srv.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$l=@(Get-Content '%~f0'|Where-Object{$_ -like '##*'});$l=$l-replace'^##','';[IO.File]::WriteAllLines('%PSFILE%',$l,[Text.Encoding]::UTF8);&'%PSFILE%';Remove-Item '%PSFILE%'"
if errorlevel 1 pause
exit /b
## # Node32-HUB Unified Server
## $port=8765;$root=(Get-Location).Path
## function Send-Json($c,$o,$s=200) {
##   try{$c.Response.StatusCode=$s;$c.Response.ContentType='application/json;charset=utf-8';$c.Response.Headers['Access-Control-Allow-Origin']='*';$b=[Text.Encoding]::UTF8.GetBytes(($o|ConvertTo-Json -Depth 4 -Compress));$c.Response.ContentLength64=$b.Length;$c.Response.OutputStream.Write($b,0,$b.Length);$c.Response.OutputStream.Close()}catch{}
## }
## function Serve-File($c,$r) {
##   $p=$r.Url.AbsolutePath.TrimStart('/').Replace('/','\');if(!$p){$p='node32-hub_webflash.html'}
##   $f=[IO.Path]::Combine($root,$p)
##   if(Test-Path -LiteralPath $f -PathType Leaf) {
##     $m=switch([IO.Path]::GetExtension($f)){'.html'{'text/html;charset=utf-8'};'.js'{'application/javascript'};'.css'{'text/css'};'.png'{'image/png'};'.ico'{'image/x-icon'};default{'application/octet-stream'}}
##     try{$b=[IO.File]::ReadAllBytes($f);$c.Response.ContentType=$m;$c.Response.ContentLength64=$b.Length;$c.Response.OutputStream.Write($b,0,$b.Length)}catch{}
##   } else {$c.Response.StatusCode=404}
##   $c.Response.OutputStream.Close()
## }
## function Find-Tool($n) {
##   $p="$env:USERPROFILE\.platformio\packages\tool-$n\$n.exe"
##   if(Test-Path $p){return $p}
##   try{$w=Get-Command "$n.exe" -ErrorAction SilentlyContinue;if($w){return $w.Source}}catch{}
##   return $null
## }
## function Find-Esptool {
##   $pioPy="$env:USERPROFILE\.platformio\penv\Scripts\python.exe"
##   if(Test-Path $pioPy){try{&$pioPy -m esptool version *>$null;if($LASTEXITCODE-eq0){return @{type='python';cmd=$pioPy}}}catch{}}
##   try{$w=Get-Command 'esptool.py' -ErrorAction SilentlyContinue;if($w){return @{type='exe';cmd='esptool.py'}}}catch{}
##   try{$py=Get-Command 'py' -ErrorAction SilentlyContinue;if($py){&py -m esptool version *>$null;if($LASTEXITCODE-eq0){return @{type='py';cmd='py'}}}}catch{}
##   return $null
## }
## function Invoke-Esptool($a) {
##   try{
##     if ($tool.type -eq 'python') {$e = $tool.cmd; $aa = @('-m','esptool') + $a}
##     elseif ($tool.type -eq 'py') {$e = 'py'; $aa = @('-m','esptool') + $a}
##     else {$e = 'esptool.py'; $aa = $a}
##     $aq = $aa | ForEach-Object { if ($_ -match '[\s"]') { '"' + $_ + '"' } else { $_ } }
##     $p=New-Object Diagnostics.ProcessStartInfo;$p.FileName=$e;$p.Arguments=($aq-join' ');$p.RedirectStandardOutput=$true;$p.RedirectStandardError=$true;$p.UseShellExecute=$false;$p.CreateNoWindow=$true;$p.StandardOutputEncoding=[Text.Encoding]::UTF8;$p.StandardErrorEncoding=[Text.Encoding]::UTF8
##     $p.EnvironmentVariables['PYTHONIOENCODING']='utf-8';$p.EnvironmentVariables['TERM']='dumb'
##     $proc=[Diagnostics.Process]::Start($p);$out=$proc.StandardOutput.ReadToEndAsync();$err=$proc.StandardError.ReadToEndAsync();$exited=$proc.WaitForExit(120000);$proc.WaitForExit()
##     $all=($out.Result.Trim()+' '+$err.Result.Trim()).Trim();return @{exit=$proc.ExitCode;log=$all;ok=($proc.ExitCode-eq0)}
##   }catch{return @{exit=1;log=$_.Exception.Message;ok=$false}}
## }
## function New-LfsImage($ssid,$pass) {
##   if(!$mkfs){return $null}
##   $tmp=[IO.Path]::GetTempPath()+'n32w_';[IO.Directory]::CreateDirectory($tmp)|Out-Null
##   $json='{"wifi":{"ssid":"'+$ssid.Replace('"','\"')+'","password":"'+$pass.Replace('"','\"')+'"}}'
##   [IO.File]::WriteAllText($tmp+'config.json',$json,[Text.Encoding]::UTF8)
##   $out=$tmp+'lfs.img'
##   $p=New-Object Diagnostics.ProcessStartInfo;$p.FileName=$mkfs;$p.Arguments="-c `"$tmp`" -s 6160384 `"$out`"";$p.UseShellExecute=$false;$p.RedirectStandardOutput=$true;$p.RedirectStandardError=$true;$p.CreateNoWindow=$true
##   $proc=[Diagnostics.Process]::Start($p);$proc.WaitForExit(30000)
##   if($proc.ExitCode-eq0 -and(Test-Path $out)){return $out}
##   return $null
## }
## function Handle-SaveWifi($c,$r) {
##   $rd=[IO.StreamReader]::new($r.InputStream,[Text.Encoding]::UTF8);$raw=$rd.ReadToEnd();$rd.Close();$b=$raw|ConvertFrom-Json
##   if(!$b.ssid){Send-Json $c @{success=$false;message='Missing SSID'}400;return}
##   if(!$mkfs){Send-Json $c @{success=$false;message='mklittlefs not installed'}500;return}
##   if(!$tool){Send-Json $c @{success=$false;message='esptool not installed'}500;return}
##   $img=New-LfsImage $b.ssid $b.password
##   if(!$img){Send-Json $c @{success=$false;message='Failed to create LittleFS image'}500;return}
##   $chip=if($b.chip){$b.chip}else{'esp32s3'}
##   $so=@{esp32s3='0xA10000';esp32p4='0xA10000'}
##   $a=@('--chip',$chip,'--before','default-reset','--after','hard-reset','--port',$b.port,'--baud','115200','write-flash',$so[$chip],$img)
##   $res=Invoke-Esptool $a
##   if($res.ok){Send-Json $c @{success=$true;message='WiFi saved'}}else{Send-Json $c @{success=$false;message=$res.log}500}
##   Remove-Item -Recurse -Force "$([IO.Path]::GetTempPath())n32w_" -ErrorAction SilentlyContinue
## }
## function Get-LanIp {
##   $ips=@()
##   try{$n=[Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()|Where-Object{$_.OperationalStatus-eq'Up'-and$_.NetworkInterfaceType-ne'Loopback'};foreach($if in $n){$ua=$if.GetIPProperties().UnicastAddresses|Where-Object{$_.Address.AddressFamily-eq'InterNetwork'-and![Net.IPAddress]::IsLoopback($_.Address)};foreach($u in $ua){$a=$u.Address.IPAddressToString;if($a-notmatch'^169\.254' -and $a-notmatch'^0\.'){$ips+=$a}}}}catch{}return $ips
## }
## $tool=Find-Esptool;$mkfs=Find-Tool 'mklittlefs'
## $lanIps=Get-LanIp
## $l=[Net.HttpListener]::new();$l.Prefixes.Add("http://localhost:$port/");$l.Prefixes.Add("http://+:$port/")
## try{$l.Start();$lan=$true}catch{$l.Close();$l=[Net.HttpListener]::new();$l.Prefixes.Add("http://localhost:$port/");$l.Start();$lan=$false}
## Write-Host "Node32-HUB Server" -ForegroundColor Cyan
## if($lan){Write-Host "  Local:  http://localhost:$port/" -ForegroundColor Green;foreach($ip in $lanIps){Write-Host "  LAN:    http://$ip`:$port/" -ForegroundColor Green}}else{Write-Host "  http://localhost:$port/" -ForegroundColor Green;Write-Host "  LAN:    run as admin for LAN access" -ForegroundColor DarkYellow}
## $link=if($lan -and $lanIps.Count -gt 0){"http://$($lanIps[0]):$port/"}else{"http://localhost:$port/"}
## Write-Host "  Browser: $link" -ForegroundColor White
## Write-Output ""
## Write-Host "esptool: $(!!$tool) | mklittlefs: $(!!$mkfs) | WiFi save: $(if($tool-and$mkfs){'ON'}else{'OFF (install mklittlefs+esptool)'})" -ForegroundColor Yellow
## Write-Output ""
## Start-Process $link
## while($l.IsListening) {
##   try{$c=$l.GetContext();$r=$c.Request;$p=$r.Url.AbsolutePath.ToLowerInvariant()
##     if($r.HttpMethod-eq'OPTIONS'){Send-Json $c @{success=$true};continue}
##     if($r.HttpMethod-eq'GET'-and$p-eq'/health'){Send-Json $c @{success=$true;esptool=!!$tool;mklittlefs=!!$mkfs;port=$port};continue}
##     if($r.HttpMethod-eq'POST'-and$p-eq'/save-wifi'){Handle-SaveWifi $c $r;continue}
##     Serve-File $c $r
##   }catch{if($c){try{Send-Json $c @{success=$false;message=$_.Exception.Message}500}catch{}}}
## }
## $l.Stop()
