# Cüzdanım — telefonda çalıştır
Set-Location $PSScriptRoot
Write-Host "Telefon USB ile bagli mi? USB hata ayiklama acik mi?" -ForegroundColor Cyan
flutter devices
Write-Host ""
Write-Host "Samsung/telefon seciliyor..." -ForegroundColor Green
flutter run
