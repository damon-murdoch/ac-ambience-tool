Param(
  # List of cardinal directions (or singular) to convert to degrees
  [Alias()][Parameter(Mandatory=$True)][String[]]$Directions
);

Function Get-CardinalSubprocess
{
  Param(
    # Direction which should be converted to degrees
    [Alias()][Parameter(Mandatory=$True)][String]$Direction
  );

  # Switch on input direction
  Switch($Direction)
  {
    "N" {Return 0;}
    "NNE" {Return 22.5;}
    "NE" {Return 45;}
    "ENE" {Return 67.5;}
    "E" {Return 90;}
    "ESE" {Return 112.5;}
    "SE" {Return 135;}
    "SSE" {Return 157.5;}
    "S" {Return 180;}
    "SSW" {Return 202.5;}
    "SW" {Return 225;}
    "WSW" {Return 247.5;}
    "W" {Return 270;}
    "WNW" {Return 292.5;}
    "NW" {Return 315;}
    "NNW" {Return 337.5;}
    default {Return $_;}
  }
}

# List of directions to return, converted to degrees
$Result = [System.Collections.ArrayList]@();

# Loop over all of the provided items
Foreach($Direction in $Directions)
{
  # Process the node, and add it to the array
  $Result += Get-CardinalSubprocess -Direction $Direction;
}

# Return the result to the calling process
Return [Double[]]$Result;