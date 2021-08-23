Param(
  # Array of values which will be analysed
  [Alias()][Parameter(Mandatory=$True)][Array]$Values, 

  # Default error margins, only referenced if there is only one item
  [Alias()][Parameter(Mandatory=$False)][Int]$Margin = 5, 

  # Number of decimal points real speeds should be rounded to
  # Defaults to 0, as Assetto Corsa does not handle float values
  [Alias()][Parameter(Mandatory=$False)][Int]$Round = 2
);

Try
{
  # Get the average of the values
  
  # If there is at least one item in the arguments
  If ($Values.Count -Gt 0)
  {
    # Check if the first element is a string
    If ($Values[0].GetType() -Eq [System.String])
    {
      # Run the array through the cardinal converter
      $Values = (& "$PSScriptRoot/Get-Cardinal.ps1" -Directions $Values);
    }

    # If there is more than one item provided
    If ($Values.Count -Gt 1)
    {
      # Sort the values array
      $Values = $Values | Sort-Object;

      # Perform measure object on the values
      $Measure = $Values | Measure-Object -Average -StandardDeviation -Minimum -Maximum;

      # Get the minimum value from the array
      $Minimum = $Measure | Select-Object -ExpandProperty Minimum;

      # Get the maximum value from the array
      $Maximum = $Measure | Select-Object -ExpandProperty Maximum;

      # Get the average temperature value
      # This will be used for calculating the midpoint
      $Average = $Measure | Select-Object -ExpandProperty Average;

      # Get the standard deviation value
      # This will be used for calculating the ambient variation
      $Deviation = $Measure | Select-Object -ExpandProperty StandardDeviation;
    }
    Else
    {
      # Only one element, no need to calculate
      $Minimum = $Maximum = $Average = $Values;

      # Set the deviation to the default error margin
      $Deviation = $Margin;
    }

    # Create a new powershell object for adding outputs to
    $Output = New-Object -TypeName PSObject;

    # Add the parameters to the object
    
    # Minimum / Maximum Values

    # Get the predicted min/max via average deviation
    $PredictedMin = ($Average - $Deviation);
    $PredictedMax = ($Average + $Deviation);

    $Output | Add-Member -MemberType NoteProperty -Name "Minimum (Predicted)" -Value ([Math]::Round($PredictedMin,$Round));
    $Output | Add-Member -MemberType NoteProperty -Name "Minimum (Rounded)" -Value ([Math]::Round($PredictedMin,0));
    $Output | Add-Member -MemberType NoteProperty -Name "Minimum (Actual)" -Value $Minimum;

    $Output | Add-Member -MemberType NoteProperty -Name "Maximum (Predicted)" -Value ([Math]::Round($PredictedMax,$Round));
    $Output | Add-Member -MemberType NoteProperty -Name "Maximum (Rounded)" -Value ([Math]::Round($PredictedMax,0));
    $Output | Add-Member -MemberType NoteProperty -Name "Maximum (Actual)" -Value $Maximum;

    # Average Values (Rounded & Real)
    $Output | Add-Member -MemberType NoteProperty -Name "Average (Rounded)" -Value ([Math]::Round($Average,0));
    $Output | Add-Member -MemberType NoteProperty -Name "Average (Real)" -Value ([Math]::Round($Average,$Round));
    
    # Average Variance (Rounded & Real)
    $Output | Add-Member -MemberType NoteProperty -Name "Variance (Rounded)" -Value ([Math]::Round($Deviation,0));
    $Output | Add-Member -MemberType NoteProperty -Name "Variance (Real)" -Value ([Math]::Round($Deviation,$Round));


    # Return the object to the terminal
    Return $Output;
  }
  Else
  {
    Throw "No arguments provided!";
  }
}
Catch
{
  Write-Output "Failed to calculate variance! Reason: $($_.Exception.Message)";
}