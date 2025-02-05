# TakeoutCleaner - A tool to remove .json metadata from Google Takeout folders.
# Copyright (C) 2025 Callum Howell

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath,
    [Parameter(Mandatory=$true)]
    [string]$ExtractFolder
)

$fileCount = 0

If (-not (Test-Path -Path $FolderPath)) {
    Write-Host "Unable to locate $FolderPath. Please make sure the path is valid and contains the relevant .zip files"
    exit
}

if (-not (Test-Path -Path $ExtractFolder)) {
    Write-Host "Unable to locate $ExtractFolder. Creating the folder now."
    New-Item -ItemType Directory -Path $ExtractFolder | Out-Null
}

$archiveFiles = Get-ChildItem -Path $FolderPath -Recurse -Filter "*.zip"
$totalFiles = $archiveFiles.Count
$currentFile = 0

foreach ($archive in $archiveFiles) {
    $archivePath = $archive.FullName
    $destination = Join-Path -Path $ExtractFolder -ChildPath $archive.BaseName
    & 7z x $archivePath "-o$ExtractFolder" -y > $null 2>&1
    $currentFile++
    $progressPercentage = [Math]::Round(($currentFile/$totalFiles) * 100, 2)
    Write-Host "Extraction Progress: $progressPercentage% ($currentFile/$totalFiles)"
}

Write-Host "Extracted to $ExtractFolder"

Get-ChildItem -Path $ExtractFolder -Recurse -Filter "*.json" | ForEach-Object {
    Remove-Item $_.FullName -Force
#    Write-Host "Removed: $($_.FullName)"
    $fileCount++
}

#Write-Host "-----"
Write-Host ".json files removed: $fileCount"
#Write-Host "-----"