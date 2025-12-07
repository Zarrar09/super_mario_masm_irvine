INCLUDE Irvine32.inc
INCLUDE macros.inc
includelib winmm.lib

.data

;LEVEL FILE VARIABLES
l1File BYTE "lvl1.txt", 0
l2File BYTE "lvl2.txt", 0
levelFileHandle DWORD ?    
levelGrid BYTE 3600 DUP(?)
levelLoaded BYTE 0

;PLAYER VARIABLES
marioPlayer BYTE "M", 0
marioHead BYTE "O", 0
xPos BYTE 4
yPos BYTE 27
prevXPos BYTE 4
prevYPos BYTE 27
isBig BYTE 0
onGround BYTE 0

;JUMP VARIABLES
upwardVelocity SBYTE 0
jumpCount BYTE 0
hasGravityBoots BYTE 0
gravityBootsTimer DWORD 0

;ENEMY VARIABLES
MAX_ENEMIES EQU 10
enemyX BYTE MAX_ENEMIES DUP(0)
enemyY BYTE MAX_ENEMIES DUP(0)
enemyType BYTE MAX_ENEMIES DUP(0)
enemyDir BYTE MAX_ENEMIES DUP(1)
enemyActive BYTE MAX_ENEMIES DUP(0)
enemyCount BYTE 0
enemyMoveTimer BYTE 0

;BOWSER VARIABLES
bowserIndex BYTE 0
bowserHealth BYTE 3
bowserChaseRange BYTE 30
bowserMoveTimer BYTE 0
bowserDefeatedMsg BYTE "BOWSER DEFEATED!  +2000", 0

;LIGHTNING VARIABLES
lightningTimer DWORD 0
lightningX BYTE 0
lightningY BYTE 0
lightningActive BYTE 0
lightningDisplayTimer BYTE 0
lightningWarning BYTE "!!    ZAP !  !", 0
lightningInterval DWORD 200

;USER INPUT VARIABLE
userInput BYTE ?     

;SCORE VARIABLES
stringScore BYTE "SCORE: ", 0
score DWORD 0

;TIMER VARIABLES
gameTimer DWORD 0
stringTimer BYTE "TIME: ", 0

;LEVEL VARIABLES
currentLevel BYTE "1-1", 0
currentLevel2 BYTE "2-1", 0
stringLevel BYTE "LEVEL: ", 0
currentLevelNum BYTE 1

;LIVES VARIABLES
lives BYTE 3
stringLives BYTE "LIVES: ", 0

;COINS VARIABLES
coins DWORD 0
stringCoins BYTE "COINS: ", 0

;PAUSE VARIABLES
isPaused BYTE 0
pauseTitle BYTE "============ GAME PAUSED ============", 0
pauseOption1 BYTE "1.      RESUME", 0
pauseOption2 BYTE "2.    EXIT", 0

;MENU VARIABLES
menuWelcome BYTE "W E L C O M E", 0
menuTitle BYTE "===== CHOOSE AN OPTION =====", 0
menuOption1 BYTE "1.  START GAME", 0
menuOption2 BYTE "2.  INSTRUCTIONS", 0
menuOption3 BYTE "3.  SAVE/LOAD", 0
menuOption4 BYTE "4.  EXIT", 0
levelPrompt BYTE "=========== SELECT LEVEL ===========", 0
level1Option BYTE "1. sLevel 1", 0
level2Option BYTE "2. Level 2 (Boss Fight)", 0
level3Option BYTE "3. Back to Menu", 0

;MENU ART VARIABLES
menuArtFile BYTE "menu.txt", 0
menuArtGrid BYTE 3600 DUP(?)
menuArtHandle DWORD ?  

;INSTRUCTIONS VARIABLES
instructionsTitle BYTE "===== INSTRUCTIONS =====", 0
instructLine1 BYTE "Controls:", 0
instructLine2 BYTE "W - Jump (Double jump allowed)", 0
instructLine3 BYTE "A - Move Left", 0
instructLine4 BYTE "D - Move Right", 0
instructLine5 BYTE "P - Pause Game", 0
instructLine6 BYTE "E - Exit Game", 0
instructLine7 BYTE "Power-ups:", 0
instructLine8 BYTE "C - Coin: +200 points", 0
instructLine9 BYTE "B - Mushroom: Grow bigger!", 0
instructLine10 BYTE "G - Gravity Boots: Higher jump!", 0
instructLine11 BYTE "Press any key to return to menu..   .", 0

;GAME OVER VARIABLES
gameOverText BYTE "GAME OVER", 0
finalScoreText BYTE "FINAL SCORE: ", 0
pressKeyText BYTE "Press any key to return to menu..  .", 0

;GAME STATE FLAG
isGameOver BYTE 0

;LEVEL COMPLETE VARIABLES
levelCompleteText1 BYTE "LEVEL 1 COMPLETE!", 0
levelCompleteText2 BYTE "PRINCESS RESCUED!    YOU WIN!", 0
timeText BYTE "TIME: ", 0
scoreText2 BYTE "SCORE: ", 0
livesText2 BYTE "LIVES: ", 0

;SAVE FILE VARIABLES
saveFileName BYTE "gamesave.dat", 0
saveFileHandle DWORD ?  
playerName BYTE 21 DUP(0)
playerNameLength BYTE 0
savedScore DWORD 0
savedLevel BYTE 0
savedLives BYTE 0
savedCoins DWORD 0

;SAVE BUFFER (for binary read/write)
saveBuffer BYTE 32 DUP(0)

;SAVE MENU VARIABLES
saveMenuTitle BYTE "========== SAVE/LOAD GAME ==========", 0
saveOption1 BYTE "1. Save Game", 0
saveOption2 BYTE "2. Load Game", 0
saveOption3 BYTE "3. Enter Player Name", 0
saveOption4 BYTE "4. View High Score", 0
saveOption5 BYTE "5. Back to Menu", 0
enterNamePrompt BYTE "Enter your name (max 20 chars): ", 0
saveSuccessMsg BYTE "Game saved successfully!", 0
loadSuccessMsg BYTE "Game loaded successfully!", 0
saveFailMsg BYTE "Failed to save game!", 0
loadFailMsg BYTE "No save file found!", 0
currentPlayerMsg BYTE "Current Player: ", 0
highScoreMsg BYTE "High Score: ", 0
highScorePlayer BYTE "Player: ", 0
pressAnyKey BYTE "Press any key to continue...", 0
noNameMsg BYTE "No name entered.   Using default.", 0
defaultName BYTE "Player", 0

.code

;====================
;FILE LOADING
;====================

loadLevel1 PROC
    mov edx, OFFSET l1File
    call OpenInputFile
    mov levelFileHandle, eax
    mov edx, OFFSET levelGrid
    mov ecx, LENGTHOF levelGrid
    call ReadFromFile
    mov eax, levelFileHandle
    call CloseFile
    mov currentLevelNum, 1
    mov levelLoaded, 0
    call scanForEnemies
    ret
loadLevel1 ENDP

;--------------------

loadLevel2 PROC
    mov edx, OFFSET l2File
    call OpenInputFile
    mov levelFileHandle, eax
    mov edx, OFFSET levelGrid
    mov ecx, LENGTHOF levelGrid
    call ReadFromFile
    mov eax, levelFileHandle
    call CloseFile
    mov currentLevelNum, 2
    mov xPos, 4
    mov yPos, 20
    mov prevXPos, 4
    mov prevYPos, 20
    mov lightningTimer, 0
    mov lightningActive, 0
    mov levelLoaded, 0
    mov bowserHealth, 3
    mov bowserMoveTimer, 0
    call scanForEnemies
    ret
loadLevel2 ENDP

;--------------------

loadMenuArt PROC
    mov edx, OFFSET menuArtFile
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je noMenuArt
    mov menuArtHandle, eax
    mov edx, OFFSET menuArtGrid
    mov ecx, LENGTHOF menuArtGrid
    call ReadFromFile
    mov eax, menuArtHandle
    call CloseFile
    ret
noMenuArt:
    ret
loadMenuArt ENDP

;====================
;DRAWING FUNCTIONS
;====================

drawMenuArt PROC
    mov esi, OFFSET menuArtGrid
    mov dh, 0
menuRowLoop:
    cmp dh, 30
    jge doneMenuArt
    mov dl, 0
    call Gotoxy
menuColLoop:
    cmp dl, 120
    jge nextMenuRow
    mov al, BYTE PTR [esi]
    cmp al, 'M'
    je RED_COLOR
    cmp al, 'F'
    je GREEN_COLOR
    cmp al, 'S'
    je BLUE_COLOR
    cmp al, 'P'
    je YELLOW_COLOR
    cmp al, 'C'
    je ORANGE_COLOR
    cmp al, 'K'
    je BLACK_COLOR
    cmp al, 'W'
    je WHITE_COLOR
    jmp BLACK_COLOR
RED_COLOR:
    mov eax, red * 16 + red
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp menuSkip
GREEN_COLOR:
    mov eax, green * 16 + green
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp menuSkip
BLUE_COLOR:
    mov eax, blue * 16 + blue
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp menuSkip
YELLOW_COLOR:
    mov eax, yellow * 16 + yellow
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp menuSkip
ORANGE_COLOR:
    mov eax, brown * 16 + brown
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp menuSkip
BLACK_COLOR:
    mov eax, black * 16 + black
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp menuSkip
WHITE_COLOR:
    mov eax, white * 16 + white
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp menuSkip
menuSkip:
    inc esi
    inc dl
    jmp menuColLoop
nextMenuRow:
    inc dh
    jmp menuRowLoop
doneMenuArt:
    mov eax, black * 16 + white
    call SetTextColor
    ret
drawMenuArt ENDP

;------LEVEL 1--------------

drawLevel1 PROC
    mov esi, OFFSET levelGrid
    mov dh, 0
rowLoop1:
    cmp dh, 30
    jge doneDrawing1
    mov dl, 0
    call Gotoxy
colLoop1:
    cmp dl, 120
    jge nextRow1
    mov al, BYTE PTR [esi]
    cmp al, 'S'
    je sky1
    cmp al, 'F'
    je floor1
    cmp al, 'K'
    je sky1
    cmp al, 'E'
    je sky1
    cmp al, 'P'
    je platform1
    cmp al, 'C'
    je coin1
    cmp al, 'M'
    je mystery1
    cmp al, 'B'
    je mushroom1
    cmp al, 'G'
    je gravityboots1
    cmp al, 'Q'
    je flag1
    jmp sky1
sky1:
    mov eax, lightBlue * 16 + lightBlue
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp skip1
floor1:
    mov eax, lightGreen * 16 + lightGreen
    call SetTextColor
    mov al, '#'
    call WriteChar
    jmp skip1
platform1:
    mov eax, brown * 16 + brown
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp skip1
coin1:
    mov eax, lightBlue * 16 + yellow
    call SetTextColor
    mov al, 'o'
    call WriteChar
    jmp skip1
mystery1:
    mov eax, red * 16 + white
    call SetTextColor
    mov al, '?'
    call WriteChar
    jmp skip1
mushroom1:
    mov eax, lightBlue * 16 + red
    call SetTextColor
    mov al, 'M'
    call WriteChar
    jmp skip1
gravityboots1:
    mov eax, white * 16 + magenta
    call SetTextColor
    mov al, 'G'
    call WriteChar
    jmp skip1
flag1:
    mov eax, gray * 16 + gray
    call SetTextColor
    mov al, '|'
    call WriteChar
    jmp skip1
skip1:
    inc esi
    inc dl
    jmp colLoop1
nextRow1:
    inc dh
    jmp rowLoop1
doneDrawing1:
    mov eax, black * 16 + white
    call SetTextColor
    ret
drawLevel1 ENDP

;LEVEL 2--------------------

drawLevel2 PROC
    mov esi, OFFSET levelGrid
    mov dh, 0
rowLoop2:
    cmp dh, 30
    jge doneDrawing2
    mov dl, 0
    call Gotoxy
colLoop2:
    cmp dl, 120
    jge nextRow2
    mov al, BYTE PTR [esi]
    cmp al, 'S'
    je sky2
    cmp al, 'F'
    je floor2
    cmp al, 'P'
    je platform2
    cmp al, 'C'
    je coin2
    cmp al, 'M'
    je mystery2
    cmp al, 'B'
    je mushroom2
    cmp al, 'Q'
    je princessFLAG2
    cmp al, 'W'
    je moon2
    cmp al, 'V'
    je sky2
    jmp sky2
sky2:
    mov eax, black * 16 + black
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp skip2
floor2:
    mov eax, gray * 16 + gray
    call SetTextColor
    mov al, '#'
    call WriteChar
    jmp skip2
platform2:
    mov eax, lightGray * 16 + lightGray
    call SetTextColor
    mov al, '*'
    call WriteChar
    jmp skip2
coin2:
    mov eax, black * 16 + yellow
    call SetTextColor
    mov al, 'o'
    call WriteChar
    jmp skip2
mystery2:
    mov eax, red * 16 + white
    call SetTextColor
    mov al, '?'
    call WriteChar
    jmp skip2
mushroom2:
    mov eax, black * 16 + lightMagenta
    call SetTextColor
    mov al, 'M'
    call WriteChar
    jmp skip2
princessFLAG2:
    mov eax, magenta * 16 + white
    call SetTextColor
    mov al, 'P'
    call WriteChar
    jmp skip2
moon2:
    mov eax, white * 16 + white
    call SetTextColor
    mov al, 'O'
    call WriteChar
    jmp skip2
skip2:
    inc esi
    inc dl
    jmp colLoop2
nextRow2:
    inc dh
    jmp rowLoop2
doneDrawing2:
    mov eax, black * 16 + white
    call SetTextColor
    ret
drawLevel2 ENDP

;--------------------

drawCurrentLevel PROC
    cmp currentLevelNum, 1
    je drawLvl1
    cmp currentLevelNum, 2
    je drawLvl2
    ret
drawLvl1:
    call drawLevel1
    ret
drawLvl2:
    call drawLevel2
    ret
drawCurrentLevel ENDP

;--------------------

drawHUD PROC
    cmp currentLevelNum, 2
    je hudLvl2
    mov eax, lightBlue * 16 + black
    jmp doHUD
hudLvl2:
    mov eax, black * 16 + white
doHUD:
    call SetTextColor
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET stringScore
    call WriteString
    mov eax, score
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    mov dl, 20
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET stringTimer
    call WriteString
    mov eax, gameTimer
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    mov dl, 35
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET stringLevel
    call WriteString
    cmp currentLevelNum, 2
    je showLvl2Text
    mov edx, OFFSET currentLevel
    jmp showLevelText
showLvl2Text:
    mov edx, OFFSET currentLevel2
showLevelText:
    call WriteString
    mov dl, 50
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET stringLives
    call WriteString
    movzx eax, lives
    call WriteDec
    cmp currentLevelNum, 2
    je coinsLvl2
    mov eax, lightBlue * 16 + yellow
    jmp doCoins
coinsLvl2:
    mov eax, black * 16 + yellow
doCoins:
    call SetTextColor
    mov dl, 65
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET stringCoins
    call WriteString
    mov eax, coins
    call WriteDec
    mov al, ' '
    call WriteChar
    cmp hasGravityBoots, 1
    jne noBootsDisplay
    cmp currentLevelNum, 2
    je bootsHudLvl2
    mov eax, lightBlue * 16 + magenta
    jmp doBootsHud
bootsHudLvl2:
    mov eax, black * 16 + magenta
doBootsHud:
    call SetTextColor
    mov dl, 80
    mov dh, 0
    call Gotoxy
    mov al, 'G'
    call WriteChar
    mov al, 'B'
    call WriteChar
    mov al, ':'
    call WriteChar
    mov eax, gravityBootsTimer
    call WriteDec
    mov al, ' '
    call WriteChar
noBootsDisplay:
    cmp currentLevelNum, 2
    je nameHudLvl2
    mov eax, lightBlue * 16 + white
    jmp doNameHud
nameHudLvl2:
    mov eax, black * 16 + white
doNameHud:
    call SetTextColor
    mov dl, 95
    mov dh, 0
    call Gotoxy
    cmp playerName, 0
    je skipNameHud
    mov edx, OFFSET playerName
    call WriteString
skipNameHud:
    mov eax, black * 16 + white
    call SetTextColor
    ret
drawHUD ENDP

;--------------------

clearPlayer PROC
    cmp currentLevelNum, 2
    je clearPlayerLvl2
    mov eax, lightBlue * 16 + lightBlue
    jmp doClearPlayer
clearPlayerLvl2:
    mov eax, black * 16 + black
doClearPlayer:
    call SetTextColor
    cmp isBig, 1
    jne clearSmall
    mov dl, prevXPos
    mov dh, prevYPos
    dec dh
    call Gotoxy
    mov al, ' '
    call WriteChar
clearSmall:
    mov dl, prevXPos
    mov dh, prevYPos
    call Gotoxy
    mov al, ' '
    call WriteChar
    mov eax, black * 16 + white
    call SetTextColor
    ret
clearPlayer ENDP

;--------------------

drawPlayer PROC
    mov al, xPos
    mov prevXPos, al
    mov al, yPos
    mov prevYPos, al
    cmp hasGravityBoots, 1
    jne checkLevel2Color
    cmp currentLevelNum, 2
    je bootsLvl2
    mov eax, lightBlue * 16 + blue
    jmp setPlayerColor
bootsLvl2:
    mov eax, black * 16 + blue
    jmp setPlayerColor
checkLevel2Color:
    cmp currentLevelNum, 2
    je normalLvl2Color
    mov eax, blue * 16 + white
    jmp setPlayerColor
normalLvl2Color:
    mov eax, black * 16 + white
setPlayerColor:
    call SetTextColor
    cmp isBig, 1
    jne drawSmall
    mov dl, xPos
    mov dh, yPos
    dec dh
    call Gotoxy
    mov edx, OFFSET marioHead
    call WriteString
drawSmall:
    mov dl, xPos
    mov dh, yPos
    call Gotoxy
    mov edx, OFFSET marioPlayer
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    ret
drawPlayer ENDP

;--------------------

drawEnemies PROC
    mov ecx, 0
drawEnemyLoop:
    cmp cl, MAX_ENEMIES
    jge doneDrawingEnemies
    mov esi, OFFSET enemyActive
    add esi, ecx
    cmp BYTE PTR [esi], 0
    je nextEnemy
    mov esi, OFFSET enemyX
    add esi, ecx
    mov dl, BYTE PTR [esi]
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    call Gotoxy
    mov esi, OFFSET enemyType
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, 'E'
    je drawGoomba
    cmp al, 'K'
    je drawKoopa
    cmp al, 'H'
    je drawShell
    cmp al, 'V'
    je drawBowser
    jmp nextEnemy
drawGoomba:
    mov eax, brown * 16 + brown
    call SetTextColor
    mov al, 'E'
    call WriteChar
    jmp nextEnemy
drawKoopa:
    mov eax, green * 16 + green
    call SetTextColor
    mov al, 'K'
    call WriteChar
    jmp nextEnemy
drawShell:
    cmp currentLevelNum, 2
    je shellLvl2
    mov eax, lightBlue * 16 + green
    jmp drawShellChar
shellLvl2:
    mov eax, black * 16 + green
drawShellChar:
    call SetTextColor
    mov al, 'O'
    call WriteChar
    jmp nextEnemy
drawBowser:
    mov eax, red * 16 + yellow
    call SetTextColor
    mov al, 'B'
    call WriteChar
    push ecx
    push edx
    mov esi, OFFSET enemyX
    movzx ecx, bowserIndex
    add esi, ecx
    mov dl, BYTE PTR [esi]
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    dec dh
    cmp dh, 1
    jl skipBowserHealthDraw
    call Gotoxy
    mov eax, black * 16 + red
    call SetTextColor
    mov al, 'H'
    call WriteChar
    mov al, 'P'
    call WriteChar
    mov al, ':'
    call WriteChar
    movzx eax, bowserHealth
    call WriteDec
skipBowserHealthDraw:
    pop edx
    pop ecx
    jmp nextEnemy
nextEnemy:
    inc ecx
    jmp drawEnemyLoop
doneDrawingEnemies:
    mov eax, black * 16 + white
    call SetTextColor
    ret
drawEnemies ENDP

;--------------------

clearEnemies PROC
    cmp currentLevelNum, 2
    je clearEnemiesLvl2
    mov eax, lightBlue * 16 + lightBlue
    jmp doClearEnemies
clearEnemiesLvl2:
    mov eax, black * 16 + black
doClearEnemies:
    call SetTextColor
    mov ecx, 0
clearEnemyLoop:
    cmp cl, MAX_ENEMIES
    jge doneClearingEnemies
    mov esi, OFFSET enemyActive
    add esi, ecx
    cmp BYTE PTR [esi], 0
    je nextClearEnemy
    mov esi, OFFSET enemyX
    add esi, ecx
    mov dl, BYTE PTR [esi]
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    call Gotoxy
    mov al, ' '
    call WriteChar
    mov esi, OFFSET enemyType
    add esi, ecx
    cmp BYTE PTR [esi], 'V'
    jne nextClearEnemy
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    dec dh
    cmp dh, 1
    jl nextClearEnemy
    mov esi, OFFSET enemyX
    add esi, ecx
    mov dl, BYTE PTR [esi]
    call Gotoxy
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
nextClearEnemy:
    inc ecx
    jmp clearEnemyLoop
doneClearingEnemies:
    mov eax, black * 16 + white
    call SetTextColor
    ret
clearEnemies ENDP

;====================
;LIGHTNING FUNCTIONS
;====================

updateLightning PROC
    cmp currentLevelNum, 2
    jne noLightningUpdate
    cmp lightningActive, 1
    je updateLightningDisplay
    inc lightningTimer
    mov eax, lightningTimer
    cmp eax, lightningInterval
    jl noLightningUpdate
    mov lightningTimer, 0
    mov eax, 110
    call RandomRange
    add eax, 5
    mov lightningX, al
    mov al, yPos
    mov lightningY, al
    mov lightningActive, 1
    mov lightningDisplayTimer, 15
    call drawLightningStrike
    call checkLightningHit
noLightningUpdate:
    ret
updateLightningDisplay:
    dec lightningDisplayTimer
    cmp lightningDisplayTimer, 0
    jg keepLightningActive
    call clearLightning
    mov lightningActive, 0
keepLightningActive:
    ret
updateLightning ENDP

;--------------------

drawLightningStrike PROC
    mov eax, yellow * 16 + white
    call SetTextColor
    mov dh, 1
    mov dl, lightningX
drawBoltLoop:
    cmp dh, lightningY
    jge drawStrikePoint
    call Gotoxy
    mov al, '|'
    call WriteChar
    inc dh
    jmp drawBoltLoop
drawStrikePoint:
    mov dl, lightningX
    mov dh, lightningY
    call Gotoxy
    mov eax, yellow * 16 + red
    call SetTextColor
    mov al, 'X'
    call WriteChar
    mov dl, lightningX
    sub dl, 4
    cmp dl, 0
    jg validZapPos
    mov dl, 1
validZapPos:
    mov dh, lightningY
    dec dh
    cmp dh, 1
    jl skipZapText
    call Gotoxy
    mov eax, black * 16 + yellow
    call SetTextColor
    mov edx, OFFSET lightningWarning
    call WriteString
skipZapText:
    mov eax, black * 16 + white
    call SetTextColor
    ret
drawLightningStrike ENDP

;--------------------

clearLightning PROC
    mov eax, black * 16 + black
    call SetTextColor
    mov dh, 1
    mov dl, lightningX
clearBoltLoop:
    cmp dh, lightningY
    jg clearZapText
    call Gotoxy
    mov al, ' '
    call WriteChar
    inc dh
    jmp clearBoltLoop
clearZapText:
    mov dl, lightningX
    sub dl, 4
    cmp dl, 0
    jg validClearPos
    mov dl, 1
validClearPos:
    mov dh, lightningY
    dec dh
    cmp dh, 1
    jl doneClearLightning
    call Gotoxy
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
doneClearLightning:
    mov levelLoaded, 0
    mov eax, black * 16 + white
    call SetTextColor
    ret
clearLightning ENDP

;--------------------

checkLightningHit PROC
    mov al, lightningX
    cmp al, xPos
    jne noLightningHit
    mov al, lightningY
    cmp al, yPos
    jne checkBigMarioLightning
    jmp lightningHitMario
checkBigMarioLightning:
    cmp isBig, 1
    jne noLightningHit
    mov bl, yPos
    dec bl
    cmp al, bl
    jne noLightningHit
lightningHitMario:
    cmp isBig, 1
    je shrinkFromLightning
    call playerDeath
    ret
shrinkFromLightning:
    mov isBig, 0
noLightningHit:
    ret
checkLightningHit ENDP

;====================
;TILE FUNCTIONS
;====================

getTileAt PROC
    push ebx
    push esi
    movzx eax, dh
    mov ebx, 120
    imul eax, ebx
    movzx ebx, dl
    add eax, ebx
    mov esi, OFFSET levelGrid
    add esi, eax
    mov al, BYTE PTR [esi]
    pop esi
    pop ebx
    ret
getTileAt ENDP

;--------------------

setTileAt PROC
    push ebx
    push esi
    push eax
    movzx eax, dh
    mov ebx, 120
    imul eax, ebx
    movzx ebx, dl
    add eax, ebx
    mov esi, OFFSET levelGrid
    add esi, eax
    pop eax
    mov BYTE PTR [esi], al
    pop esi
    pop ebx
    ret
setTileAt ENDP

;====================
;ENEMY FUNCTIONS
;====================

scanForEnemies PROC
    mov enemyCount, 0
    mov bowserHealth, 3
    mov esi, OFFSET levelGrid
    mov dh, 0
    mov dl, 0
scanLoop:
    cmp dh, 30
    jge doneScan
    mov al, BYTE PTR [esi]
    cmp al, 'E'
    je foundGoomba
    cmp al, 'K'
    je foundKoopa
    cmp al, 'V'
    je foundBowser
    jmp continueScanning
foundGoomba:
    movzx ecx, enemyCount
    cmp ecx, MAX_ENEMIES
    jge continueScanning
    push esi
    mov esi, OFFSET enemyX
    add esi, ecx
    mov BYTE PTR [esi], dl
    mov esi, OFFSET enemyY
    add esi, ecx
    mov BYTE PTR [esi], dh
    mov esi, OFFSET enemyType
    add esi, ecx
    mov BYTE PTR [esi], 'E'
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 1
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 1
    inc enemyCount
    pop esi
    jmp continueScanning
foundKoopa:
    movzx ecx, enemyCount
    cmp ecx, MAX_ENEMIES
    jge continueScanning
    push esi
    mov esi, OFFSET enemyX
    add esi, ecx
    mov BYTE PTR [esi], dl
    mov esi, OFFSET enemyY
    add esi, ecx
    mov BYTE PTR [esi], dh
    mov esi, OFFSET enemyType
    add esi, ecx
    mov BYTE PTR [esi], 'K'
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 1
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 1
    inc enemyCount
    pop esi
    jmp continueScanning
foundBowser:
    movzx ecx, enemyCount
    cmp ecx, MAX_ENEMIES
    jge continueScanning
    push esi
    mov bowserIndex, cl
    mov esi, OFFSET enemyX
    add esi, ecx
    mov BYTE PTR [esi], dl
    mov esi, OFFSET enemyY
    add esi, ecx
    mov BYTE PTR [esi], dh
    mov esi, OFFSET enemyType
    add esi, ecx
    mov BYTE PTR [esi], 'V'
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 0
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 1
    inc enemyCount
    pop esi
    jmp continueScanning
continueScanning:
    inc esi
    inc dl
    cmp dl, 120
    jl scanLoop
    mov dl, 0
    inc dh
    jmp scanLoop
doneScan:
    ret
scanForEnemies ENDP

;--------------------

updateEnemies PROC
    inc enemyMoveTimer
    cmp enemyMoveTimer, 3
    jl doneUpdatingEnemies
    mov enemyMoveTimer, 0
    call clearEnemies
    mov ecx, 0
updateEnemyLoop:
    cmp cl, MAX_ENEMIES
    jge doneUpdatingEnemies
    push ecx
    mov esi, OFFSET enemyActive
    add esi, ecx
    cmp BYTE PTR [esi], 0
    je skipEnemyUpdate
    mov esi, OFFSET enemyType
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, 'H'
    je updateShell
    cmp al, 'V'
    je updateBowserEnemy
    mov esi, OFFSET enemyX
    add esi, ecx
    mov dl, BYTE PTR [esi]
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov bl, BYTE PTR [esi]
    cmp bl, 1
    je moveEnemyRight
    jmp moveEnemyLeft
moveEnemyRight:
    inc dl
    cmp dl, 119
    jge reverseToLeft
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je reverseToLeft
    cmp al, 'P'
    je reverseToLeft
    cmp al, 'Q'
    je reverseToLeft
    cmp al, 'C'
    je reverseToLeft
    cmp al, 'B'
    je reverseToLeft
    cmp al, 'G'
    je reverseToLeft
    cmp al, 'M'
    je reverseToLeft
    cmp al, 'L'
    je reverseToLeft
    mov esi, OFFSET enemyX
    add esi, ecx
    mov BYTE PTR [esi], dl
    jmp skipEnemyUpdate
reverseToLeft:
    dec dl
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 0
    jmp skipEnemyUpdate
moveEnemyLeft:
    dec dl
    cmp dl, 1
    jle reverseToRight
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je reverseToRight
    cmp al, 'P'
    je reverseToRight
    cmp al, 'Q'
    je reverseToRight
    cmp al, 'C'
    je reverseToRight
    cmp al, 'B'
    je reverseToRight
    cmp al, 'G'
    je reverseToRight
    cmp al, 'M'
    je reverseToRight
    cmp al, 'L'
    je reverseToRight
    mov esi, OFFSET enemyX
    add esi, ecx
    mov BYTE PTR [esi], dl
    jmp skipEnemyUpdate
reverseToRight:
    inc dl
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 1
    jmp skipEnemyUpdate
updateShell:
    mov esi, OFFSET enemyX
    add esi, ecx
    mov dl, BYTE PTR [esi]
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov bl, BYTE PTR [esi]
    cmp bl, 1
    je shellRight
    dec dl
    cmp dl, 1
    jle deactivateShell
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je deactivateShell
    cmp al, 'P'
    je deactivateShell
    cmp al, 'Q'
    je deactivateShell
    cmp al, 'L'
    je deactivateShell
    mov esi, OFFSET enemyX
    add esi, ecx
    mov BYTE PTR [esi], dl
    jmp checkShellHitEnemy
shellRight:
    inc dl
    cmp dl, 119
    jge deactivateShell
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je deactivateShell
    cmp al, 'P'
    je deactivateShell
    cmp al, 'Q'
    je deactivateShell
    cmp al, 'L'
    je deactivateShell
    mov esi, OFFSET enemyX
    add esi, ecx
    mov BYTE PTR [esi], dl
    jmp checkShellHitEnemy
deactivateShell:
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 0
    jmp skipEnemyUpdate
checkShellHitEnemy:
    push ecx
    call shellHitCheck
    pop ecx
    jmp skipEnemyUpdate
updateBowserEnemy:
    call updateBowserMovement
    jmp skipEnemyUpdate
skipEnemyUpdate:
    pop ecx
    inc ecx
    jmp updateEnemyLoop
doneUpdatingEnemies:
    ret
updateEnemies ENDP

;--------------------

updateBowserMovement PROC
    cmp currentLevelNum, 2
    jne doneBowserMovement
    movzx ecx, bowserIndex
    mov esi, OFFSET enemyActive
    add esi, ecx
    cmp BYTE PTR [esi], 0
    je doneBowserMovement
    mov esi, OFFSET enemyX
    add esi, ecx
    mov dl, BYTE PTR [esi]
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    push edx
    mov al, dl
    mov bl, xPos
    cmp al, bl
    jge calcBowserXDist1
    sub bl, al
    mov cl, bl
    jmp calcBowserYDist
calcBowserXDist1:
    sub al, bl
    mov cl, al
calcBowserYDist:
    pop edx
    push edx
    mov al, dh
    mov bl, yPos
    cmp al, bl
    jge calcBowserYDist1
    sub bl, al
    add cl, bl
    jmp checkBowserInRange
calcBowserYDist1:
    sub al, bl
    add cl, al
checkBowserInRange:
    pop edx
    cmp cl, bowserChaseRange
    jg doneBowserMovement
    movzx ecx, bowserIndex
    mov esi, OFFSET enemyX
    add esi, ecx
    mov dl, BYTE PTR [esi]
    cmp dl, xPos
    je checkBowserYChase
    jg bowserMoveLeft
bowserMoveRight:
    mov dl, BYTE PTR [esi]
    inc dl
    cmp dl, 118
    jge checkBowserYChase
    push ecx
    mov esi, OFFSET enemyY
    movzx ecx, bowserIndex
    add esi, ecx
    mov dh, BYTE PTR [esi]
    pop ecx
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je checkBowserYChase
    cmp al, 'P'
    je checkBowserYChase
    mov esi, OFFSET enemyX
    movzx ecx, bowserIndex
    add esi, ecx
    mov BYTE PTR [esi], dl
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 1
    jmp doneBowserMovement
bowserMoveLeft:
    mov dl, BYTE PTR [esi]
    dec dl
    cmp dl, 2
    jle checkBowserYChase
    push ecx
    mov esi, OFFSET enemyY
    movzx ecx, bowserIndex
    add esi, ecx
    mov dh, BYTE PTR [esi]
    pop ecx
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je checkBowserYChase
    cmp al, 'P'
    je checkBowserYChase
    mov esi, OFFSET enemyX
    movzx ecx, bowserIndex
    add esi, ecx
    mov BYTE PTR [esi], dl
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 0
    jmp doneBowserMovement
checkBowserYChase:
    movzx ecx, bowserIndex
    mov esi, OFFSET enemyY
    add esi, ecx
    mov dh, BYTE PTR [esi]
    cmp dh, yPos
    je doneBowserMovement
    jg bowserMoveUp
bowserMoveDown:
    mov dh, BYTE PTR [esi]
    inc dh
    cmp dh, 28
    jge doneBowserMovement
    mov esi, OFFSET enemyX
    movzx ecx, bowserIndex
    add esi, ecx
    mov dl, BYTE PTR [esi]
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je doneBowserMovement
    cmp al, 'P'
    je doneBowserMovement
    mov esi, OFFSET enemyY
    movzx ecx, bowserIndex
    add esi, ecx
    mov BYTE PTR [esi], dh
    jmp doneBowserMovement
bowserMoveUp:
    mov dh, BYTE PTR [esi]
    dec dh
    cmp dh, 2
    jle doneBowserMovement
    mov esi, OFFSET enemyX
    movzx ecx, bowserIndex
    add esi, ecx
    mov dl, BYTE PTR [esi]
    push ecx
    push edx
    call getTileAt
    pop edx
    pop ecx
    cmp al, 'F'
    je doneBowserMovement
    cmp al, 'P'
    je doneBowserMovement
    mov esi, OFFSET enemyY
    movzx ecx, bowserIndex
    add esi, ecx
    mov BYTE PTR [esi], dh
doneBowserMovement:
    ret
updateBowserMovement ENDP

;--------------------

shellHitCheck PROC
    mov ecx, 0
shellCheckLoop:
    cmp cl, MAX_ENEMIES
    jge doneShellCheck
    mov esi, OFFSET enemyActive
    add esi, ecx
    cmp BYTE PTR [esi], 0
    je nextShellCheck
    mov esi, OFFSET enemyType
    add esi, ecx
    cmp BYTE PTR [esi], 'H'
    je nextShellCheck
    mov esi, OFFSET enemyX
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, dl
    jne nextShellCheck
    mov esi, OFFSET enemyY
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, dh
    jne nextShellCheck
    mov esi, OFFSET enemyType
    add esi, ecx
    cmp BYTE PTR [esi], 'V'
    je shellHitBowser
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 0
    add score, 100
    jmp nextShellCheck
shellHitBowser:
    dec bowserHealth
    add score, 500
    cmp bowserHealth, 0
    jg nextShellCheck
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 0
    add score, 2000
nextShellCheck:
    inc ecx
    jmp shellCheckLoop
doneShellCheck:
    ret
shellHitCheck ENDP

;====================
;COLLISION FUNCTIONS
;====================

isSolidTile PROC
    cmp al, 'F'
    je yesSolid
    cmp al, 'P'
    je yesSolid
    cmp al, 'M'
    je yesSolid
    cmp al, 'L'
    je yesSolid
    mov al, 0
    ret
yesSolid:
    mov al, 1
    ret
isSolidTile ENDP

;--------------------

checkCollisions PROC
    call checkGroundCollision
    call checkCeilingCollision
    call checkPowerupCollision
    call checkFlagCollision
    call checkEnemyCollision
    ret
checkCollisions ENDP

;--------------------

checkGroundCollision PROC
    mov dl, xPos
    mov dh, yPos
    inc dh
    cmp dh, 30
    jge noGroundBelow
    call getTileAt
    call isSolidTile
    cmp al, 1
    je hasGroundBelow
noGroundBelow:
    mov onGround, 0
    ret
hasGroundBelow:
    mov onGround, 1
    ret
checkGroundCollision ENDP

;--------------------

checkCeilingCollision PROC
    cmp upwardVelocity, 0
    jge noCeilingCheck
    mov dl, xPos
    mov dh, yPos
    dec dh
    cmp dh, 0
    jle noCeilingCheck
    call getTileAt
    cmp al, 'P'
    je hitPlatform
    cmp al, 'L'
    je hitPlatform
    cmp al, 'M'
    je hitMystery
    jmp noCeilingCheck
hitPlatform:
    mov upwardVelocity, 0
    ret
hitMystery:
    push dx
    mov al, 'P'
    call setTileAt
    pop dx
    dec dh
    cmp dh, 0
    jle skipSpawnMushroom
    push dx
    call getTileAt
    cmp al, 'S'
    pop dx
    jne skipSpawnMushroom
    mov al, 'B'
    call setTileAt
skipSpawnMushroom:
    mov upwardVelocity, 0
    add score, 100
    mov levelLoaded, 0
    ret
noCeilingCheck:
    ret
checkCeilingCollision ENDP

;--------------------

checkPowerupCollision PROC
    mov dl, xPos
    mov dh, yPos
    call getTileAt
    cmp al, 'C'
    je collectCoin
    cmp al, 'B'
    je collectMushroom
    cmp currentLevelNum, 1
    jne skipGravityCheck
    cmp al, 'G'
    je collectGravityBoots
skipGravityCheck:
    ret
collectCoin:
    add score, 200
    inc coins
    mov al, 'S'
    call setTileAt
    mov levelLoaded, 0
    ret
collectMushroom:
    mov isBig, 1
    add score, 500
    mov al, 'S'
    call setTileAt
    mov levelLoaded, 0
    ret
collectGravityBoots:
    mov hasGravityBoots, 1
    mov gravityBootsTimer, 300
    add score, 300
    mov al, 'S'
    call setTileAt
    mov levelLoaded, 0
    ret
checkPowerupCollision ENDP

;--------------------

checkFlagCollision PROC
    mov dl, xPos
    mov dh, yPos
    call getTileAt
    cmp al, 'Q'
    je reachedFlag
    ret
reachedFlag:
    call levelComplete
    ret
checkFlagCollision ENDP

;--------------------

checkEnemyCollision PROC
    mov ecx, 0
enemyCollisionLoop:
    cmp cl, MAX_ENEMIES
    jge noEnemyHit
    push ecx
    mov esi, OFFSET enemyActive
    add esi, ecx
    cmp BYTE PTR [esi], 0
    je nextEnemyCheck
    mov esi, OFFSET enemyX
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, xPos
    jne nextEnemyCheck
    mov esi, OFFSET enemyY
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, yPos
    je sideHit
    mov bl, yPos
    inc bl
    cmp al, bl
    je stompEnemy
    jmp nextEnemyCheck
stompEnemy:
    mov esi, OFFSET enemyType
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, 'K'
    je turnToShell
    cmp al, 'V'
    je stompBowser
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 0
    add score, 100
    mov upwardVelocity, -4
    jmp nextEnemyCheck
turnToShell:
    mov esi, OFFSET enemyType
    add esi, ecx
    mov BYTE PTR [esi], 'H'
    add score, 100
    mov upwardVelocity, -4
    jmp nextEnemyCheck
stompBowser:
    dec bowserHealth
    add score, 500
    mov upwardVelocity, -6
    cmp bowserHealth, 0
    jg pushBowserBack
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 0
    add score, 2000
    push ecx
    mov eax, black * 16 + green
    call SetTextColor
    mov dl, 45
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET bowserDefeatedMsg
    call WriteString
    mov eax, 1500
    call Delay
    mov levelLoaded, 0
    pop ecx
    jmp nextEnemyCheck
pushBowserBack:
    mov esi, OFFSET enemyX
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, xPos
    jl pushBowserRight
    sub al, 4
    cmp al, 2
    jg storeBowserPushLeft
    mov al, 2
storeBowserPushLeft:
    mov BYTE PTR [esi], al
    jmp nextEnemyCheck
pushBowserRight:
    add al, 4
    cmp al, 117
    jl storeBowserPushRight
    mov al, 117
storeBowserPushRight:
    mov BYTE PTR [esi], al
    jmp nextEnemyCheck
sideHit:
    mov esi, OFFSET enemyType
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, 'H'
    je kickShell
    cmp al, 'V'
    je bowserSideHit
    cmp isBig, 1
    je shrinkMario
    call playerDeath
    jmp nextEnemyCheck
bowserSideHit:
    cmp isBig, 1
    je shrinkFromBowserHit
    call playerDeath
    jmp nextEnemyCheck
shrinkFromBowserHit:
    mov isBig, 0
    mov esi, OFFSET enemyX
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, xPos
    jg pushMarioLeftFromBowser
    add xPos, 4
    cmp xPos, 117
    jl nextEnemyCheck
    mov xPos, 117
    jmp nextEnemyCheck
pushMarioLeftFromBowser:
    sub xPos, 4
    cmp xPos, 2
    jg nextEnemyCheck
    mov xPos, 2
    jmp nextEnemyCheck
kickShell:
    mov esi, OFFSET enemyX
    add esi, ecx
    mov al, BYTE PTR [esi]
    cmp al, xPos
    jl kickRight
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 0
    jmp nextEnemyCheck
kickRight:
    mov esi, OFFSET enemyDir
    add esi, ecx
    mov BYTE PTR [esi], 1
    jmp nextEnemyCheck
shrinkMario:
    mov isBig, 0
    jmp nextEnemyCheck
nextEnemyCheck:
    pop ecx
    inc ecx
    jmp enemyCollisionLoop
noEnemyHit:
    ret
checkEnemyCollision ENDP

;--------------------

canMoveLeft PROC
    mov dl, xPos
    dec dl
    cmp dl, 0
    jle cantMoveL
    mov dh, yPos
    call getTileAt
    call isSolidTile
    cmp al, 1
    je cantMoveL
    mov al, 1
    ret
cantMoveL:
    mov al, 0
    ret
canMoveLeft ENDP

;--------------------

canMoveRight PROC
    mov dl, xPos
    inc dl
    cmp dl, 119
    jge cantMoveR
    mov dh, yPos
    call getTileAt
    call isSolidTile
    cmp al, 1
    je cantMoveR
    mov al, 1
    ret
cantMoveR:
    mov al, 0
    ret
canMoveRight ENDP

;====================
;POWERUP FUNCTIONS
;====================

updatePowerups PROC
    cmp hasGravityBoots, 0
    je noPowerupUpdate
    dec gravityBootsTimer
    cmp gravityBootsTimer, 0
    jg noPowerupUpdate
    mov hasGravityBoots, 0
    mov gravityBootsTimer, 0
noPowerupUpdate:
    ret
updatePowerups ENDP

;====================
;GAME STATE FUNCTIONS
;====================

levelComplete PROC
    call autoSaveProgress
    call Clrscr
    mov eax, black * 16 + green
    call SetTextColor
    mov dl, 45
    mov dh, 10
    call Gotoxy
    cmp currentLevelNum, 2
    je showLevel2Complete
    mov edx, OFFSET levelCompleteText1
    jmp showCompleteText
showLevel2Complete:
    mov edx, OFFSET levelCompleteText2
showCompleteText:
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 45
    mov dh, 13
    call Gotoxy
    mov edx, OFFSET timeText
    call WriteString
    mov eax, gameTimer
    call WriteDec
    mov dl, 45
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET scoreText2
    call WriteString
    mov eax, score
    call WriteDec
    mov dl, 45
    mov dh, 17
    call Gotoxy
    mov edx, OFFSET livesText2
    call WriteString
    movzx eax, lives
    call WriteDec
    mov dl, 40
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET pressKeyText
    call WriteString
    call ReadChar
    call showMainMenu
    ret
levelComplete ENDP

;--------------------

playerDeath PROC
    dec lives
    cmp lives, 0
    jle callGameOver
    cmp currentLevelNum, 2
    je resetForLevel2
    mov xPos, 4
    mov yPos, 27
    jmp continueReset
resetForLevel2:
    mov xPos, 4
    mov yPos, 20
    mov lightningTimer, 0
    mov lightningActive, 0
    mov bowserHealth, 3
    mov bowserMoveTimer, 0
continueReset:
    mov isBig, 0
    mov hasGravityBoots, 0
    mov gravityBootsTimer, 0
    mov upwardVelocity, 0
    mov jumpCount, 0
    mov onGround, 0
    mov score, 0
    mov coins, 0
    mov gameTimer, 0
    mov levelLoaded, 0
    cmp currentLevelNum, 1
    je reloadLevel1
    call loadLevel2
    ret
reloadLevel1:
    call loadLevel1
    ret
callGameOver:
    call gameOver
    ret
playerDeath ENDP

;--------------------

gameOver PROC
    call Clrscr
    mov eax, black * 16 + red
    call SetTextColor
    mov dl, 50
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET gameOverText
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 45
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET finalScoreText
    call WriteString
    mov eax, score
    call WriteDec
    mov dl, 40
    mov dh, 18
    call Gotoxy
    mov edx, OFFSET pressKeyText
    call WriteString
    call ReadChar
    call showMainMenu
    ret
gameOver ENDP

;--------------------

resetGameLevel2 PROC
    mov xPos, 4
    mov yPos, 20
    mov prevXPos, 4
    mov prevYPos, 20
    mov score, 0
    mov gameTimer, 0
    mov lives, 3
    mov coins, 0
    mov isBig, 0
    mov upwardVelocity, 0
    mov jumpCount, 0
    mov onGround, 0
    mov hasGravityBoots, 0
    mov gravityBootsTimer, 0
    mov levelLoaded, 0
    mov enemyCount, 0
    mov enemyMoveTimer, 0
    mov lightningTimer, 0
    mov lightningActive, 0
    mov bowserHealth, 3
    mov bowserMoveTimer, 0
    mov bowserIndex, 0
    mov ecx, 0
resetEnemyLoop2:
    cmp ecx, MAX_ENEMIES
    jge doneResetEnemies2
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 0
    inc ecx
    jmp resetEnemyLoop2
doneResetEnemies2:
    ret
resetGameLevel2 ENDP

;====================
;INPUT FUNCTIONS
;====================

processInput PROC
    call ReadKey
    jz noKey
    mov userInput, al
    cmp userInput, 'e'
    je exitGame
    cmp userInput, 'p'
    je togglePause
    cmp userInput, 'w'
    je jump
    cmp userInput, 'a'
    je moveLeft
    cmp userInput, 'd'
    je moveRight
noKey:
    ret
togglePause:
    mov isPaused, 1
    call showPauseScreen
    mov levelLoaded, 0
    ret
jump:
    cmp onGround, 1
    jne tryDoubleJump
    call clearPlayer
    cmp hasGravityBoots, 1
    jne normalJump
    mov upwardVelocity, -10
    jmp didJump
normalJump:
    mov upwardVelocity, -6
didJump:
    mov jumpCount, 1
    mov onGround, 0
    ret
tryDoubleJump:
    cmp jumpCount, 1
    jne noJump
    call clearPlayer
    cmp hasGravityBoots, 1
    jne normalDoubleJump
    mov upwardVelocity, -8
    jmp didDoubleJump
normalDoubleJump:
    mov upwardVelocity, -5
didDoubleJump:
    mov jumpCount, 2
noJump:
    ret
moveLeft:
    call canMoveLeft
    cmp al, 0
    je noMoveLeft
    call clearPlayer
    dec xPos
noMoveLeft:
    ret
moveRight:
    call canMoveRight
    cmp al, 0
    je noMoveRight
    call clearPlayer
    inc xPos
noMoveRight:
    ret
exitGame:
    exit
processInput ENDP

;====================
;PHYSICS FUNCTIONS
;====================

applyGravity PROC
    cmp upwardVelocity, 0
    jl goingUp
    cmp onGround, 1
    je grounded
    call clearPlayer
    inc yPos
    cmp yPos, 30
    jge fellInGap
    mov dl, xPos
    mov dh, yPos
    inc dh
    cmp dh, 30
    jge checkIfGap
    call getTileAt
    call isSolidTile
    cmp al, 1
    je landedOnSolid
    ret
checkIfGap:
    mov dl, xPos
    mov dh, yPos
    call getTileAt
    cmp al, 'S'
    je stillFalling
    cmp al, 'F'
    je landedOnSolid
    cmp al, 'P'
    je landedOnSolid
    cmp al, 'L'
    je landedOnSolid
stillFalling:
    ret
landedOnSolid:
    mov onGround, 1
    mov jumpCount, 0
    ret
fellInGap:
    call playerDeath
    ret
grounded:
    mov jumpCount, 0
    ret
goingUp:
    call clearPlayer
    dec yPos
    cmp yPos, 1
    jge notAtTop
    mov yPos, 1
    mov upwardVelocity, 0
    ret
notAtTop:
    inc upwardVelocity
    ret
applyGravity ENDP

;====================
;TIMER FUNCTIONS
;====================

updateGameTimer PROC
    inc gameTimer
    ret
updateGameTimer ENDP

;====================
;PAUSE FUNCTIONS
;====================

showPauseScreen PROC
    call Clrscr
    mov eax, black * 16 + yellow
    call SetTextColor
    mov dl, 42
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET pauseTitle
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 50
    mov dh, 13
    call Gotoxy
    mov edx, OFFSET pauseOption1
    call WriteString
    mov dl, 50
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET pauseOption2
    call WriteString
pauseInputLoop:
    call ReadChar
    cmp al, '1'
    je resumeGame
    cmp al, '2'
    je exitFromPause
    jmp pauseInputLoop
resumeGame:
    mov isPaused, 0
    ret
exitFromPause:
    call showMainMenu
    ret
showPauseScreen ENDP

;====================
;SAVE/LOAD FUNCTIONS
;====================

showSaveMenu PROC
    call Clrscr
    mov eax, black * 16 + yellow
    call SetTextColor
    mov dl, 40
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET saveMenuTitle
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 40
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET currentPlayerMsg
    call WriteString
    cmp playerName, 0
    je showDefaultName
    mov edx, OFFSET playerName
    call WriteString
    jmp continueMenu
showDefaultName:
    mov edx, OFFSET defaultName
    call WriteString
continueMenu:
    mov dl, 45
    mov dh, 13
    call Gotoxy
    mov edx, OFFSET saveOption1
    call WriteString
    mov dl, 45
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET saveOption2
    call WriteString
    mov dl, 45
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET saveOption3
    call WriteString
    mov dl, 45
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET saveOption4
    call WriteString
    mov dl, 45
    mov dh, 17
    call Gotoxy
    mov edx, OFFSET saveOption5
    call WriteString
saveMenuInput:
    call ReadChar
    cmp al, '1'
    je doSaveGame
    cmp al, '2'
    je doLoadGame
    cmp al, '3'
    je doEnterName
    cmp al, '4'
    je doViewHighScore
    cmp al, '5'
    je backFromSave
    jmp saveMenuInput
doSaveGame:
    call saveGame
    jmp showSaveMenu
doLoadGame:
    call loadGame
    jmp showSaveMenu
doEnterName:
    call enterPlayerName
    jmp showSaveMenu
doViewHighScore:
    call viewHighScore
    jmp showSaveMenu
backFromSave:
    call showMainMenu
    ret
showSaveMenu ENDP

;--------------------

enterPlayerName PROC
    call Clrscr
    mov eax, black * 16 + yellow
    call SetTextColor
    mov dl, 35
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET enterNamePrompt
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov edx, OFFSET playerName
    mov ecx, 20
    call ReadString
    mov playerNameLength, al
    cmp al, 0
    jne nameEntered
    mov esi, OFFSET defaultName
    mov edi, OFFSET playerName
    mov ecx, 7
    rep movsb
    mov dl, 35
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET noNameMsg
    call WriteString
    jmp waitNameKey
nameEntered:
    mov eax, black * 16 + green
    call SetTextColor
    mov dl, 35
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET currentPlayerMsg
    call WriteString
    mov edx, OFFSET playerName
    call WriteString
waitNameKey:
    mov eax, black * 16 + gray
    call SetTextColor
    mov dl, 35
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret
enterPlayerName ENDP

;--------------------

saveGame PROC
    mov esi, OFFSET playerName
    mov edi, OFFSET saveBuffer
    mov ecx, 21
    rep movsb
    mov eax, score
    mov DWORD PTR [edi], eax
    add edi, 4
    mov al, currentLevelNum
    mov BYTE PTR [edi], al
    inc edi
    mov al, lives
    mov BYTE PTR [edi], al
    inc edi
    mov eax, coins
    mov DWORD PTR [edi], eax
    mov edx, OFFSET saveFileName
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je saveFailed
    mov saveFileHandle, eax
    mov eax, saveFileHandle
    mov edx, OFFSET saveBuffer
    mov ecx, 32
    call WriteToFile
    cmp eax, 0
    je saveFailed
    mov eax, saveFileHandle
    call CloseFile
    mov eax, black * 16 + green
    call SetTextColor
    mov dl, 40
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET saveSuccessMsg
    call WriteString
    jmp saveWaitKey
saveFailed:
    mov eax, black * 16 + red
    call SetTextColor
    mov dl, 40
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET saveFailMsg
    call WriteString
saveWaitKey:
    mov eax, black * 16 + gray
    call SetTextColor
    mov dl, 40
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret
saveGame ENDP

;--------------------

loadGame PROC
    mov edx, OFFSET saveFileName
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je loadFailed
    mov saveFileHandle, eax
    mov eax, saveFileHandle
    mov edx, OFFSET saveBuffer
    mov ecx, 32
    call ReadFromFile
    cmp eax, 0
    je loadFailed
    mov eax, saveFileHandle
    call CloseFile
    mov esi, OFFSET saveBuffer
    mov edi, OFFSET playerName
    mov ecx, 21
    rep movsb
    mov eax, DWORD PTR [esi]
    mov score, eax
    mov savedScore, eax
    add esi, 4
    mov al, BYTE PTR [esi]
    mov savedLevel, al
    inc esi
    mov al, BYTE PTR [esi]
    mov lives, al
    mov savedLives, al
    inc esi
    mov eax, DWORD PTR [esi]
    mov coins, eax
    mov savedCoins, eax
    mov eax, black * 16 + green
    call SetTextColor
    mov dl, 40
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET loadSuccessMsg
    call WriteString
    jmp loadWaitKey
loadFailed:
    mov eax, black * 16 + red
    call SetTextColor
    mov dl, 40
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET loadFailMsg
    call WriteString
loadWaitKey:
    mov eax, black * 16 + gray
    call SetTextColor
    mov dl, 40
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret
loadGame ENDP

;--------------------

viewHighScore PROC
    call Clrscr
    mov edx, OFFSET saveFileName
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je noHighScore
    mov saveFileHandle, eax
    mov eax, saveFileHandle
    mov edx, OFFSET saveBuffer
    mov ecx, 32
    call ReadFromFile
    mov eax, saveFileHandle
    call CloseFile
    mov eax, black * 16 + yellow
    call SetTextColor
    mov dl, 45
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET highScoreMsg
    call WriteString
    mov esi, OFFSET saveBuffer
    add esi, 21
    mov eax, DWORD PTR [esi]
    call WriteDec
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 45
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET highScorePlayer
    call WriteString
    mov edx, OFFSET saveBuffer
    call WriteString
    jmp highScoreWait
noHighScore:
    mov eax, black * 16 + red
    call SetTextColor
    mov dl, 45
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET loadFailMsg
    call WriteString
highScoreWait:
    mov eax, black * 16 + gray
    call SetTextColor
    mov dl, 40
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret
viewHighScore ENDP

;--------------------

autoSaveProgress PROC
    mov eax, score
    cmp eax, savedScore
    jle noAutoSave
    call saveGame
noAutoSave:
    ret
autoSaveProgress ENDP

;--------------------

loadAndContinue PROC
    call loadGame
    cmp savedLevel, 0
    je loadContinueFailed
    cmp savedLevel, 1
    je continueLevel1
    cmp savedLevel, 2
    je continueLevel2
    jmp loadContinueFailed
continueLevel1:
    call resetGame
    mov eax, savedScore
    mov score, eax
    mov al, savedLives
    mov lives, al
    mov eax, savedCoins
    mov coins, eax
    call loadLevel1
    ret
continueLevel2:
    call resetGameLevel2
    mov eax, savedScore
    mov score, eax
    mov al, savedLives
    mov lives, al
    mov eax, savedCoins
    mov coins, eax
    call loadLevel2
    ret
loadContinueFailed:
    ret
loadAndContinue ENDP

;====================
;MENU FUNCTIONS
;====================

showMainMenu PROC
    call Clrscr
    call loadMenuArt
    call drawMenuArt
    mov dl, 52
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET menuWelcome
    call WriteString
    mov dl, 45
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET menuTitle
    call WriteString
    mov dl, 50
    mov dh, 13
    call Gotoxy
    mov edx, OFFSET menuOption1
    call WriteString
    mov dl, 50
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET menuOption2
    call WriteString
    mov dl, 50
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET menuOption3
    call WriteString
    mov dl, 50
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET menuOption4
    call WriteString
    call ReadChar
    mov userInput, al
    cmp userInput, '1'
    je chooseLevel
    cmp userInput, '2'
    je showInstructions
    cmp userInput, '3'
    je goToSaveMenu
    cmp userInput, '4'
    je exitGameMenu
    jmp showMainMenu
chooseLevel:
    call levelMenu
    ret
showInstructions:
    call instructionsMenu
    jmp showMainMenu
goToSaveMenu:
    call showSaveMenu
    jmp showMainMenu
exitGameMenu:
    exit
showMainMenu ENDP

;--------------------

levelMenu PROC
    call Clrscr
    call drawMenuArt
    mov eax, black * 16 + yellow
    call SetTextColor
    mov dl, 40
    mov dh, 9
    call Gotoxy
    mov edx, OFFSET levelPrompt
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 45
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET level1Option
    call WriteString
    mov dl, 45
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET level2Option
    call WriteString
    mov dl, 45
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET level3Option
    call WriteString
    call ReadChar
    mov userInput, al
    cmp userInput, '1'
    je startLevel1
    cmp userInput, '2'
    je startLevel2
    cmp userInput, '3'
    je backToMain
    jmp levelMenu
startLevel1:
    call resetGame
    call loadLevel1
    ret
startLevel2:
    call resetGameLevel2
    call loadLevel2
    ret
backToMain:
    call showMainMenu
    ret
levelMenu ENDP

;--------------------

instructionsMenu PROC
    call Clrscr
    call drawMenuArt
    mov eax, black * 16 + yellow
    call SetTextColor
    mov dl, 45
    mov dh, 4
    call Gotoxy
    mov edx, OFFSET instructionsTitle
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 40
    mov dh, 6
    call Gotoxy
    mov edx, OFFSET instructLine1
    call WriteString
    mov dl, 40
    mov dh, 7
    call Gotoxy
    mov edx, OFFSET instructLine2
    call WriteString
    mov dl, 40
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET instructLine3
    call WriteString
    mov dl, 40
    mov dh, 9
    call Gotoxy
    mov edx, OFFSET instructLine4
    call WriteString
    mov dl, 40
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET instructLine5
    call WriteString
    mov dl, 40
    mov dh, 11
    call Gotoxy
    mov edx, OFFSET instructLine6
    call WriteString
    mov eax, black * 16 + yellow
    call SetTextColor
    mov dl, 40
    mov dh, 13
    call Gotoxy
    mov edx, OFFSET instructLine7
    call WriteString
    mov eax, black * 16 + white
    call SetTextColor
    mov dl, 40
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET instructLine8
    call WriteString
    mov dl, 40
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET instructLine9
    call WriteString
    mov dl, 40
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET instructLine10
    call WriteString
    mov eax, black * 16 + gray
    call SetTextColor
    mov dl, 40
    mov dh, 18
    call Gotoxy
    mov edx, OFFSET instructLine11
    call WriteString
    call ReadChar
    ret
instructionsMenu ENDP

;====================
;RESET FUNCTIONS
;====================

resetGame PROC
    mov xPos, 4
    mov yPos, 27
    mov prevXPos, 4
    mov prevYPos, 27
    mov score, 0
    mov gameTimer, 0
    mov lives, 3
    mov coins, 0
    mov isBig, 0
    mov upwardVelocity, 0
    mov jumpCount, 0
    mov onGround, 0
    mov hasGravityBoots, 0
    mov gravityBootsTimer, 0
    mov levelLoaded, 0
    mov enemyCount, 0
    mov enemyMoveTimer, 0
    mov lightningTimer, 0
    mov lightningActive, 0
    mov bowserHealth, 3
    mov bowserMoveTimer, 0
    mov bowserIndex, 0
    mov ecx, 0
resetEnemyLoop:
    cmp ecx, MAX_ENEMIES
    jge doneResetEnemies
    mov esi, OFFSET enemyActive
    add esi, ecx
    mov BYTE PTR [esi], 0
    inc ecx
    jmp resetEnemyLoop
doneResetEnemies:
    ret
resetGame ENDP

;====================
;MAIN
;====================

main PROC
    call Randomize
    call showMainMenu
gameLoop:
    cmp levelLoaded, 1
    je skipLevelDraw
    call Clrscr
    call drawCurrentLevel
    mov levelLoaded, 1
skipLevelDraw:
    call checkCollisions
    call updateEnemies
    call drawEnemies
    call updateLightning
    call drawPlayer
    call drawHUD
    call updateGameTimer
    call updatePowerups
    call applyGravity
    call processInput
    mov eax, 50
    call Delay
    jmp gameLoop
main ENDP
END main