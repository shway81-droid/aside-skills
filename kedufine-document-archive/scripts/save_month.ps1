param([string]$Destination,[int]$Expected,[string]$StartFile,[int]$StableSeconds=8,[int]$MaxWait=600)
Add-Type -AssemblyName UIAutomationClient
Add-Type @'
using System; using System.Runtime.InteropServices;
public class MonthSave2 {
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
 [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a,uint b,bool c);
 [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint x,uint y,uint d,UIntPtr e);
 [DllImport("kernel32.dll")] public static extern IntPtr OpenProcess(uint a,bool i,int p);
 [DllImport("kernel32.dll")] public static extern IntPtr VirtualAllocEx(IntPtr p,IntPtr a,UIntPtr s,uint t,uint pr);
 [DllImport("kernel32.dll")] public static extern bool WriteProcessMemory(IntPtr p,IntPtr a,byte[] b,int n,out IntPtr w);
 [DllImport("kernel32.dll")] public static extern bool VirtualFreeEx(IntPtr p,IntPtr a,UIntPtr s,uint t);
 [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,uint m,IntPtr w,IntPtr l);
}
'@
function Focus-Window([IntPtr]$h){$fg=[MonthSave2]::GetForegroundWindow();$p=0;$ft=[MonthSave2]::GetWindowThreadProcessId($fg,[ref]$p);$ct=[MonthSave2]::GetCurrentThreadId();[MonthSave2]::AttachThreadInput($ct,$ft,$true)|Out-Null;[MonthSave2]::BringWindowToTop($h)|Out-Null;[MonthSave2]::SetForegroundWindow($h)|Out-Null;[MonthSave2]::AttachThreadInput($ct,$ft,$false)|Out-Null;Start-Sleep -Milliseconds 300}
function Click-At([int]$x,[int]$y){[MonthSave2]::SetCursorPos($x,$y)|Out-Null;[MonthSave2]::mouse_event(2,0,0,0,[UIntPtr]::Zero);[MonthSave2]::mouse_event(4,0,0,0,[UIntPtr]::Zero)}
$start=[datetime](Get-Content -LiteralPath $StartFile)
$desk=[Windows.Automation.AutomationElement]::RootElement
$save=$null
for($j=0;$j -lt 40 -and -not $save;$j++){$wins=$desk.FindAll([Windows.Automation.TreeScope]::Children,[Windows.Automation.Condition]::TrueCondition);for($i=0;$i -lt $wins.Count;$i++){if($wins.Item($i).Current.Name -match '^파일저장'){$save=$wins.Item($i);break}};if(-not $save){Start-Sleep -Milliseconds 250}}
if(-not $save){throw '파일저장 창을 찾지 못했습니다.'}
$sh=[IntPtr]$save.Current.NativeWindowHandle;$sr=$save.Current.BoundingRectangle
Focus-Window $sh
Click-At ([int]($sr.X+268)) ([int]($sr.Y+154));Start-Sleep -Milliseconds 180
Click-At ([int]($sr.X+437)) ([int]($sr.Y+84))
$folder=$null
for($j=0;$j -lt 40 -and -not $folder;$j++){Start-Sleep -Milliseconds 250;$wins=$desk.FindAll([Windows.Automation.TreeScope]::Children,[Windows.Automation.Condition]::TrueCondition);for($i=0;$i -lt $wins.Count;$i++){if($wins.Item($i).Current.Name -eq '폴더 찾아보기'){$folder=$wins.Item($i);break}}}
if(-not $folder){throw '폴더 선택창을 찾지 못했습니다.'}
$fh=[IntPtr]$folder.Current.NativeWindowHandle;$ph=[MonthSave2]::OpenProcess(0x1F0FFF,$false,$folder.Current.ProcessId)
if($ph -eq [IntPtr]::Zero){throw '저장 폴더 프로세스 접근 실패'}
$bytes=[Text.Encoding]::Unicode.GetBytes($Destination+[char]0);$mem=[MonthSave2]::VirtualAllocEx($ph,[IntPtr]::Zero,[UIntPtr]$bytes.Length,0x3000,4);$wr=[IntPtr]::Zero
[void][MonthSave2]::WriteProcessMemory($ph,$mem,$bytes,$bytes.Length,[ref]$wr);[void][MonthSave2]::SendMessage($fh,0x0467,[IntPtr]1,$mem);Start-Sleep -Milliseconds 400
[void][MonthSave2]::VirtualFreeEx($ph,$mem,[UIntPtr]::Zero,0x8000);[void][MonthSave2]::CloseHandle($ph)
$fr=$folder.Current.BoundingRectangle;Focus-Window $fh;Click-At ([int]($fr.X+224)) ([int]($fr.Y+350))

# Wait until file count stops changing for $StableSeconds consecutive seconds
$last=-1;$stable=0;$elapsed=0
while($elapsed -lt $MaxWait){
  Start-Sleep -Seconds 1;$elapsed++
  $cur=@(Get-ChildItem -LiteralPath $Destination -File -ErrorAction SilentlyContinue|Where-Object{$_.LastWriteTime -ge $start})
  if($cur.Count -eq $last){$stable++}else{$stable=0;$last=$cur.Count}
  $body=@($cur|Where-Object{$_.Name -match '\(본문\)'}).Count
  # early exit if reached expected and stable briefly
  if($Expected -gt 0 -and $body -ge $Expected -and $stable -ge 3){break}
  # general exit: no new files for StableSeconds and at least something saved
  if($stable -ge $StableSeconds -and $last -gt 0){break}
}
$cur=@(Get-ChildItem -LiteralPath $Destination -File -ErrorAction SilentlyContinue|Where-Object{$_.LastWriteTime -ge $start})
$body=@($cur|Where-Object{$_.Name -match '\(본문\)'}).Count
$wins=$desk.FindAll([Windows.Automation.TreeScope]::Children,[Windows.Automation.Condition]::TrueCondition);for($i=0;$i -lt $wins.Count;$i++){$e=$wins.Item($i);$p=Get-Process -Id $e.Current.ProcessId -ErrorAction SilentlyContinue;if($p.ProcessName -eq 'WXSClient'){[void][MonthSave2]::SendMessage([IntPtr]$e.Current.NativeWindowHandle,0x10,[IntPtr]::Zero,[IntPtr]::Zero)}}
[pscustomobject]@{Destination=$Destination;Documents=$body;TotalFiles=$cur.Count;Expected=$Expected;Shortfall=($Expected-$body)}|ConvertTo-Json -Compress
