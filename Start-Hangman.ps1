# Version 1.0.0

param (
    # This param makes the script easier to test
    [switch]$Cheat
)

# Draw the visuals for each mistake
$hangmanVisuals = [pscustomobject]@{
    Mistake0 = ' '
    Mistake1 = '

    




    
    _________
    '
    Mistake2 = '
        |
        |
        |
        |
        |
        |
        |
    _________
    '
    Mistake3 = '
        |-----------
        |
        |
        |
        |
        |
        |
    _________
    '
    Mistake4 = '
        |-----------
        |          |
        |          O
        |
        |
        |
        |
    _________
    '
    Mistake5 = '
        |-----------
        |          |
        |          O
        |          |
        |          |
        |
        |
    _________
    '
    Mistake6 = '
        |-----------
        |          |
        |          O
        |        __|
        |          |
        |
        |
    _________
    '
    Mistake7 = '
        |-----------
        |          |
        |          O
        |        __|__
        |          |
        |
        |
    _________
    '
    Mistake8 = '
        |-----------
        |          |
        |          O
        |        __|__
        |          |
        |         /
        |        /
    _________
    '
    Mistake9 = '
        |-----------
        |          |
        |          O
        |        __|__
        |          |
        |         / \
        |        /   \
    _________

            FAIL
    '
}

$url = "https://random-word-api.herokuapp.com/word?number=1"

# Validate that the website the API is hosted on is online and then get a word
try {
    if ((Invoke-WebRequest -uri $url).StatusCode -eq 200) {
        try {
            $word = Invoke-RestMethod -uri "https://random-word-api.herokuapp.com/word?number=1"
        }
        catch {
            throw "Could not get dictionary word from $url."
        }
    }
}
catch {
    throw "Could not get HTTP status code 200 from $url"
}

$wordCharArray = $word.ToCharArray()

$tracking = @{
    MistakeCount      = 0
    MatchedCharacters = @()
    CorrectCount      = 0
    WordVisual        = @()
}

if ($Cheat) {
    Write-Host "`nThe word is" $word
}

do {
    Write-Host $hangmanVisuals.("Mistake" + $tracking.MistakeCount)
    
    # Loop to try and validate the input as a single character
    do {
        $choice = Read-Host "Please choose a letter"
    }
    until ($choice.Length -eq 1)

    # Penalise the player for chosing an already matched character
    if ($tracking.MatchedCharacters -contains $choice) {
        $tracking.MistakeCount++
    }
    # Match the character given to a character in the chosen word's character array
    elseif ($wordCharArray -contains $choice) {
        $wordCharArray | foreach {
            if ($choice -eq $_){
                $tracking.MatchedCharacters += $choice
                $tracking.CorrectCount++
            }
        }
    }
    # If the incorrect character has been inputted
    else {
        $tracking.MistakeCount++
    }

    # Build visual that shows the player which characters they have right.
    # CR-someday: this shouldn't really be generated on each loop; this is inefficient, but doesn't really matter.
    $tracking.WordVisual = $null
    $wordCharArray | foreach {
        if ($tracking.MatchedCharacters -contains $_) {
        $tracking.WordVisual +=  $_
    }
    else {
        $tracking.WordVisual += "_"
    }
}
        
    $tracking.WordVisual -join ' '

    if ($tracking.CorrectCount -eq ($wordCharArray.Count-1)) {
        $won = $true
    }

} until ($tracking.MistakeCount -ge 9 -or $tracking.CorrectCount -eq ($wordCharArray.Count))

if ($won) {
    Write-Host "`nYou won!`n"
    pause
}
else {
    Write-Host $hangmanVisuals.Mistake9
    pause
}