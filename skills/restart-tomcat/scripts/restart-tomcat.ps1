# Tomcat restart script
$jh = "D:\eclipse\JDK\jdk1.8.0_492"
$ch = "D:\eclipse\apache-tomcat-8.0.48"
$cb = "D:\eclipse\workspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp0"

# kill old
$tp = (netstat -ano | Select-String ":8080.*LISTEN" | ForEach-Object { ($_ -split '\s+')[-1] } | Select-Object -First 1)
if ($tp) { Stop-Process -Id $tp -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Write-Host "Killed PID $tp" }

# deploy
$cp = "$ch\lib\servlet-api.jar;D:\eclipse\workspace\SamSplitSystem\WebContent\WEB-INF\lib\mysqlconnectorjava8.0.20.jar"
foreach ($proj in @("hwjweb23", "SamSplitSystem")) {
    $sd = "D:\eclipse\workspace\$proj\src"
    $od = "D:\eclipse\workspace\$proj\build\classes"
    $wd = "$cb\wtpwebapps\$proj"
    if (-not (Test-Path $sd)) { continue }
    Get-ChildItem $sd -Recurse -Filter "*.java" | ForEach-Object { javac -encoding UTF-8 -cp "$od;$cp" -d $od $_.FullName 2>$null }
    # copy all class packages
    foreach ($pkg in @("com", "javabean", "servlet")) {
        if (Test-Path "$od\$pkg") { Copy-Item "$od\$pkg" "$wd\WEB-INF\classes\" -Recurse -Force }
    }
    # copy root JSPs
    Copy-Item "D:\eclipse\workspace\$proj\WebContent\*.jsp" "$wd\" -Force -ErrorAction SilentlyContinue
    # copy JSP subdirectories
    foreach ($sub in @("student", "coach", "admin", "META-INF")) {
        $srcSub = "D:\eclipse\workspace\$proj\WebContent\$sub"
        if (Test-Path $srcSub) { Copy-Item $srcSub "$wd\" -Recurse -Force }
    }
    Copy-Item "D:\eclipse\workspace\$proj\WebContent\WEB-INF\web.xml" "$wd\WEB-INF\web.xml" -Force -ErrorAction SilentlyContinue
    # copy static assets
    if (Test-Path "D:\eclipse\workspace\$proj\WebContent\common") {
        Copy-Item "D:\eclipse\workspace\$proj\WebContent\common" "$wd\" -Recurse -Force
    }
    Write-Host "  $proj deployed"
}

# start
Write-Host "Starting Tomcat..."
$javaArgs = @("-Dcatalina.base=$cb", "-Dcatalina.home=$ch", "-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager", "-Djava.io.tmpdir=$cb\temp", "-classpath", "$ch\bin\bootstrap.jar;$ch\bin\tomcat-juli.jar", "org.apache.catalina.startup.Bootstrap", "start")
Start-Process -FilePath "$jh\bin\java.exe" -ArgumentList $javaArgs -WindowStyle Hidden

# wait
Write-Host "Waiting..."
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 1
    $check = netstat -ano | Select-String ":8080.*LISTEN"
    if ($check) { Write-Host "Tomcat ready! http://localhost:8080/" -ForegroundColor Green; return }
}
Write-Host "Startup timeout" -ForegroundColor Red
