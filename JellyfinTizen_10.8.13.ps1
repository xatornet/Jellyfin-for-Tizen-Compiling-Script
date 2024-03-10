#XaToR's Script for Compiling Jellyfin (10.8.13) for Tizen TVs

#Saving Initial Location
$Init = Get-Location


#A little guide
$wsh = New-Object -ComObject Wscript.Shell

$wsh.Popup("Welcome to Jellyfin for Tizen Compilation Script:

-1. This will check requirements and help to compile Jellyfin.wgt for Tizen TVs

-2. This script will ask you to create a Samsung Certificate using Tizen Studio Certificate Manager.

-3. This script will ask you to add your TVs into Tizen Studio Device Manager.

-4. Check https://github.com/xatornet/Jellyfin-for-Tizen-Compiling-Script for a detailed guide.")

#Checking requirements

#Is Tizen-Studio with Native CLI installed?

$TizenStudioCorrect = Test-Path "C:\tizen-studio\tools\ide\bin\tizen.bat"
if ( $TizenStudioCorrect )
{
    $wsh.Popup("Tizen Studio/Native CLI detected.")
}
else
{
	$wsh.Popup("Tizen Studio/Native CLI not detected.Please install it properly.
	Script exiting...")
	Start-Process "https://developer.tizen.org/development/tizen-studio/download"
	Exit
}

#Is GIT installed?

$GitInstalled = Test-Path "C:\Program Files\Git\bin\git.exe"
if ( $GitInstalled )
{
    $wsh.Popup("Git detected.")
}
else
{
	$wsh.Popup("Git not detected. Please, install it properly.
	Script exiting...")
	Start-Process "https://git-scm.com/downloads"
	Exit
}

#Is Node & Yarn installed?

$Nodeinstalled = Test-Path "C:\Program Files\nodejs\npm"
if ( $Nodeinstalled )
{
    $wsh.Popup("Node.js detected, installing Yarn and resuming script...")
	npm install --global yarn --quiet --no-progress
}
else
{
	$wsh.Popup("Node.js not detected. Please install it properly.
	Script exiting...")
	Start-Process "https://nodejs.org/en"
	Exit
}

#Repo cloning
cls

Write-Output "CREATING DIRECTORIES"
Start-Sleep -Seconds 2



New-Item "C:\Jellyfin" -itemType Directory | Out-Null

Write-Output "DIRECTORY CREATED"
Start-Sleep -Seconds 2

cls
Start-Sleep -Seconds 2
Write-Output "CLONING REPOSITORIES"
Start-Sleep -Seconds 2

cd c:\Jellyfin

#git clone https://github.com/jellyfin/jellyfin-web.git We are going to use the published stable source release

Invoke-WebRequest -Uri https://github.com/jellyfin/jellyfin-web/archive/refs/tags/v10.8.13.zip -OutFile ".\JellyWeb10.8.13Source.zip" | out-null
Expand-Archive ".\JellyWeb10.8.13Source.zip" ".\" | Out-Null
Rename-Item -Path ".\jellyfin-web-10.8.13\" ".\jellyfin-web" | Out-Null
Remove-Item -Path ".\JellyWeb10.8.13Source.zip" -Force -Recurse -Confirm:$false | Out-Null
git clone https://github.com/jellyfin/jellyfin-tizen.git | out-null

cls
Start-Sleep -Seconds 2
Write-Output "INSTALLING MODULES"
Start-Sleep -Seconds 2

#Node Requirement (not in wiki)
npm install --quiet --no-progress -g win-node-env

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$result = [System.Windows.Forms.MessageBox]::Show('Do you want the Script to open Wiki page to follow the install procedure? (Recomended)' , "Info" , 4)
if ($result -eq 'Yes') {
    cls
	Start-Sleep -Seconds 2
	Write-Output "OPENING WIKI PAGE"
	Start-Sleep -Seconds 2
    Start-Process "https://github.com/xatornet/Jellyfin-for-Tizen-Compiling-Script/wiki"
} else { 
	cls
	Start-Sleep -Seconds 2
	Write-Output "CONTINUING"
	Start-Sleep -Seconds 2
       }

$wsh.Popup("Please, do this now (follow Steps 6 to 9 from WIKI):

-1. Open Tizen Studio Certificate Manager, sign in with your Samsung Account and create a Samsung Certificate.

-2. Add all of your TVs UUID inside this certificate. You can get these adding them inside Tizen Studio Device Manager.

-3. Be sure to have all this TVs with Dev Mode enabled..

-4. Once this is done, press to continue...")

cls
Start-Sleep -Seconds 2
Write-Output "COMPYLING JELLYFIN-WEB"
Start-Sleep -Seconds 2

#jellyfin-web compilation
cd jellyfin-web
$env:SKIP_PREPARE=1
npm ci --no-audit --quiet --no-progress 
npm run --quiet --no-progress build:production
cd..

cls
Start-Sleep -Seconds 2
Write-Output "COMPYLING JELLYFIN-TIZEN"
Start-Sleep -Seconds 2

#jellyfin-tizen compilation
cd jellyfin-tizen

#get JELLYFIN_WEB_DIR to the dist folder
$env:JELLYFIN_WEB_DIR="C:\jellyfin\jellyfin-web\dist"

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$resultf = [System.Windows.Forms.MessageBox]::Show('Do you want the Script to discard Jellyfin unused fonts, to reduce file size?' , "Info" , 4)
if ($resultf -eq 'Yes') {
    cls
	Start-Sleep -Seconds 2
	Write-Output "DISCARDING UNUSED FONTS"
	Start-Sleep -Seconds 2
	#This ENABLES REDUCED SIZE. Disable this variable if you have any problems.
    $env:DISCARD_UNUSED_FONTS=1
} else { 
	cls
	Start-Sleep -Seconds 2
	Write-Output "CONTINUING"
	Start-Sleep -Seconds 2
	Remove-Item Env:\DISCARD_UNUSED_FONTS | Out-Null
       }

#$titleFonts = 'JELLYFIN FONTS'
#$questionFonts = 'DO YOU WANT JELLYFIN TO DISCARD UNUSED FONTS TO REDUCE SIZE OF THE APP?'
#$Fonts = 'Y', 'N'

#$decisionFonts = $Host.Ui.PromptForChoice($titleFonts, $questionFonts, $Fonts, 1)
#if ($decisionFonts -eq 0) {
#	cls
#	Start-Sleep -Seconds 2
#	Write-Output "DISCARDING UNUSED FONTS"
#	Start-Sleep -Seconds 2
	#This ENABLES REDUCED SIZE. Disable this variable if you have any problems.
#    $env:DISCARD_UNUSED_FONTS=1
#} else {
	#cls
	#Start-Sleep -Seconds 2
	#Write-Output "CONTINUING"
	#Start-Sleep -Seconds 2
#}

npm ci --no-audit --quiet --no-progress 

cls
Start-Sleep -Seconds 2
Write-Output "BUILDING JELLYFIN APP"
Start-Sleep -Seconds 2

#Building App
$env:Path +=";C:\tizen-studio\tools\ide\bin"
tizen.bat build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock" | out-null
tizen.bat package -t wgt -o . -- .buildResult | out-null

#Moving results and cleaning
Move-Item -Path ".\Jellyfin.wgt" "$Init" | out-null
cd $Init
Remove-Item -Path "C:\Jellyfin" -Force -Recurse -Confirm:$false | out-null

Start-Sleep -Seconds 2
Write-Output "SCRIPT ENDED"
Start-Sleep -Seconds 2



$wsh.Popup("Job Done:

-1. Jellyfin.wgt should be created near the script.

-2. Open Tizen Studio Device Manager and connect to all your TVs.

-3. Right click on them and use PERMIT TO INSTALL APPLICATIONS first on each TV.

-4. Once this is done, right click on them again and use INSTALL APP, and select Jellyfin.wgt.

-5. If this wont work, use the command 'tizen install -n Jellyfin.wgt -t NAMEofyourTV'

-6. It should be installed and working.

Goodbye :-)")
Exit
