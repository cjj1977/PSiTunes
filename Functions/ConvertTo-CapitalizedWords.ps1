<#
  .SYNOPSIS
    Creates and calls a function to capitalize initial letters of words
  .DESCRIPTION
    Creates and calls a function to capitalize initial letters of words, where the words in the
    string passed to the function can be separated by spaces, hyphens or other non-alphanumeric
    characters (i.e. "word boundary" characters. The function does try to un-capitalize letters
    following apostrophes within words.
  .NOTES
    Filename: ConvertTo-CapitalizedWords.ps1
    Author:   Charles Joynt
    History:  19/01/2011 script created
  .LINK
    https://sites.google.com/a/joynt.co.uk/wiki/kb/scripting/powershell/ConvertTo-CapitalizedWords
  .LINK
    https://github.com/cjj1977/PSiTunes/wiki/ConvertTo-CapitalizedWords
  .EXAMPLE
    [PS]>ConvertTo-CapitalizedWords.ps1
  .EXAMPLE
    [PS]>ConvertTo-CapitalizedWords.ps1 -Text "hello-world"
    Hello-World
  .EXAMPLE
    [PS]>ConvertTo-CapitalizedWords.ps1
    
    [PS]>ConvertTo-CapitalizedWords -Text "hello-world"
    Hello-World
#>
function ConvertTo-CapitalizedWords{
  [CmdletBinding()]
  param(
    [Parameter(
      Mandatory=$true,
      ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("Text")]
    [System.String]
    $InputObject
  )

  #################################################################################################  
  # Capitalize all letters following a word boundary

  # Script block to convert text to capital letter, to be used/called by the Regex::Replace method
  $CapitalizeSB = {
    param($string)
    $string.Value.ToUpper()
  }

  $CapitalizedWords = [Regex]::Replace($InputObject,'\b\w',$CapitalizeSB)
  
  #################################################################################################  
  # Fix capitalization of letters following apostrophes within words

  # Script block to convert text following an apostrophe back to lower case
  $ApostropheSB = {
    param($string)
    $string.Value.Substring(0,2) + $string.Value.Substring(2,1).ToLower()
  }

  $CapitalizedWords = [Regex]::Replace($CapitalizedWords,'\w''\w',$ApostropheSB)
  
  #################################################################################################  
  # Return capitalized string

  return $CapitalizedWords
}