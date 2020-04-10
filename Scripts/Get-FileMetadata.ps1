Set-StrictMode -Version 2

function Get-FileMetadata {
  param(
    [Parameter(ValueFromPipeline=$True)]
    [ValidateScript({Test-Path -LiteralPath $_})]
    [string]$Path = (Get-Location),

    [string]$Include = '*'
  )
  
  $Path = (Get-Item -LiteralPath $Path).FullName
  Write-Verbose "Processing $Path"

  $Shell = New-Object -ComObject Shell.Application
  $Folder = $Shell.Namespace($Path)
  
  Write-Debug "$($Folder.Items().Count) items in $Path"

  $Items = $Folder.Items() | Where-Object {$_.Path -like $Include}

  foreach ($Item in $Items) {
    
    if(Test-Path -PathType Container $Item.Path){
      Get-FileMetadata -Path $Item.Path
    } else {
        $Count=0
        $Object = New-Object PSObject
        $Object | Add-Member NoteProperty FullName $Item.Path
        #Get all the file detail items of the current file and add them to an object.
        while($Folder.getDetailsOf($Folder.Items, $Count) -ne "") {
            $Object | Add-Member -Force NoteProperty ($Folder.getDetailsOf($Folder.Items, $Count)) ($Folder.getDetailsOf($Item, $Count))
            $Count+=1
        }

        Write-Output $Object
    }
  }
}

function ConvertTo-iTunesFieldNames {
  param(
    [Parameter(ValueFromPipeline)]
    $InputObject
  )
  
  BEGIN {
  }

  PROCESS {
    $InputObject | Where-Object {$_.Kind -eq "Music"} |
      Foreach-Object {
        if($_.Album -match "\\Various Artists\\"){
          $Compilation = $true
        } else {
          $Compilation = $False
        }

        if($_.Album -match "Disc\s*(\d+)"){
          $DiscNumber = $Matches[1]
        } else {
          $DiscNumber = 1
        }

        [PSCustomObject]@{
          Name = $_.Title
          Album = $_.Album
          Artist = $_."Contributing Artists"
          BitRate = $_."Bit rate"
          Comment = $_.Comments
          Compilation = $Compilation
          Composer = $_.Authors
          #DiscCount =  
          DiscNumber = $DiscNumber
          Duration = ($_.Length -as [TimeSpan]).TotalSeconds
          Genre = $_.Genre
          # Rating = $_.Rating
          Size = [int]($_.Size.Split(" ")[0]) * 1MB
          Time = ($_.Length -as [TimeSpan])
          #TrackCount = 
          TrackNumber = $_."#"
          Year = $_.Year
          Location = $_.Fullname
          AlbumArtist = if($Compilation){"Various Artists"} else {$_."Contributing Artists"}
          # Conductor = $_.Conductors
        }
      }
  }
  END {
  }
}