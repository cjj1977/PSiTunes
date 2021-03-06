function Get-iTunesPlaylist {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name = ".",

        [Parameter()]
        [switch]$ExactMatch = $false
    )
    
    if($ExactMatch){
        $iTunesPlaylist = $iTunesApplication.Sources.Item(1).Playlists | ?{$_.Name -eq $Name}
    } else {
        $iTunesPlaylist = $iTunesApplication.Sources.Item(1).Playlists | ?{$_.Name -match $Name}
    }
    
    return $iTunesPlaylist
}

