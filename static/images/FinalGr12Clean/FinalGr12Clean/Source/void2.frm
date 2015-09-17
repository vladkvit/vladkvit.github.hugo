VERSION 5.00
Begin VB.Form Form2 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "shoot"
   ClientHeight    =   12660
   ClientLeft      =   330
   ClientTop       =   675
   ClientWidth     =   14430
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   844
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   962
   Begin VB.Timer tmrBreak 
      Enabled         =   0   'False
      Left            =   30000
      Top             =   360
   End
   Begin VB.Timer tmrUpgrade 
      Interval        =   3000
      Left            =   12000
      Top             =   240
   End
   Begin VB.Timer tmrRightMouse 
      Interval        =   400
      Left            =   13920
      Top             =   1800
   End
   Begin VB.Timer tmrMiddleMouse 
      Interval        =   200
      Left            =   13440
      Top             =   1800
   End
   Begin VB.Timer tmrLeftMouse 
      Interval        =   20
      Left            =   12960
      Top             =   1800
   End
   Begin VB.Timer tmrSpawn2 
      Interval        =   3000
      Left            =   11520
      Top             =   240
   End
   Begin VB.Timer tmrSpawn1 
      Interval        =   2000
      Left            =   11040
      Top             =   240
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Final , gr12 for ISC4, Aurora High, Mr Martin
'By Vlad Kvitnevski
'This game is COMPLETELY rewritten from the ground up, compared to my last year's project
'For reference, my last year's project is located at g:\ICS4\FinalGr11
'This project is located at g:\ICS4\FinalGr12

'How does this work?
'the play buttons trigger the new_game sub from the form2
'the sub initializes DirectDraw, and calls RenderLoop
'RenderLoop runs while bquit = false. Bquit is the 'quit' flag
'bstate is the state of the game, where 0 is normal, and the others are: pause, level up and game over
'a whole bunch of stuff is controlled by the current level and the number of uprgrades (little pluses) that
'the player got
'The things include, but are not limited to, the speed, damage and quantity of shots, and how many enemies spawn per second
'The level-up code is triggered by score going up. It is exponential, so to reach the next level is exponentially harder
'there are 2 types of enemies
'the skulls CHASE YOU! if you die, they chase the crate.
'the other ones target the crate
'3 types of lasers
'one's the machine gun
'one's the artillery. Slow, but powerful
'one's the spread shot
'There are tons of other nifty features that I'm not listing

Dim KeyUpAscii As Integer
Dim KeyLeftAscii As Integer
Dim KeyRightAscii As Integer
Dim KeyDownAscii As Integer
Dim KeyPauseAscii As Integer

Dim KeyUpPressed As Boolean
Dim KeyLeftPressed As Boolean
Dim KeyRightPressed As Boolean
Dim KeyDownPressed As Boolean

Dim MouseLeftDown As Boolean
Dim MouseRightDown As Boolean
Dim MouseMiddleDown As Boolean

'screen offsets go in play when you move to the left or right of the screen
Dim ScreenOffsetX As Integer
Dim ScreenOffsetY As Integer

Dim MouseX As Integer
Dim MouseY As Integer

Private Type GenericShip
    Xpos As Single
    Ypos As Single
    Xvel As Single
    Yvel As Single
    Rotation As Integer '(360 degrees)
    Health As Integer
    dead As Boolean
End Type

Private Type Animation
    Xpos As Single
    Ypos As Single
    Frame As Integer
    State As Integer '0 for off, 1 for on
End Type

Private Type EnemyShip
  posX As Single
  posY As Single
  velX As Single
  velY As Single
  State As Integer  '0 for destroyed, 1 for not destroyed,
  Direction As Integer
  TypeOf As Integer 'how the enemy looks and acts
  Health As Integer
  Points As Integer 'how many points the player scores for destroying it
  Damage As Integer 'the damage it deals
End Type

Private Type LaserType
  posX As Single
  posY As Single
  SpeedX As Single
  SpeedY As Single
  State As Integer
  Type As Integer
  Damage As Integer
End Type


Dim MyShip As GenericShip
Dim MyBase As GenericShip
Dim EnemyShips() As EnemyShip
Dim MyLasers() As LaserType
Dim Explosions() As Animation
Dim powerUp() As GenericShip '(health is used as "state")
Dim HowManyEnemies As Integer  'how many of them are on screen
Dim HowManyLasers As Integer  'how many of them are on screen
Dim HowManyExplosions As Integer
Dim Score As Integer
Dim CurLevel As Integer
Dim Upgrades As Integer





'for collision detection
Private Declare Function IntersectRect Lib "user32" (lpDestRect As RECT, lpSrc1Rect As RECT, lpSrc2Rect As RECT) As Long

Dim dx As New DirectX7
Dim dd As DirectDraw7

'these surfaces hold the window
Dim DDS_primary As DirectDrawSurface7
Dim ddsd_primary As DDSURFACEDESC2
Dim BackBuffer As DirectDrawSurface7
Dim ddsd_back As DDSURFACEDESC2

'a clipper for windowed mode
Dim ddClipper As DirectDrawClipper

'these surfaces hold our sprites
Dim DDS_run As DirectDrawSurface7
Dim ddsd_run As DDSURFACEDESC2

Dim R As RECT 'usefull 1280 by 1024 rect

'hold the current screen mode
Dim smode As Integer


'Sprites dimmed below
Public mainShipSprite As DirectDrawSurface7
Public mainShipHP As DirectDrawSurface7
Public BaseSprite As DirectDrawSurface7
Public bgImg As DirectDrawSurface7
Public EnemyShipSprite1 As DirectDrawSurface7
Public EnemyShipSprite2 As DirectDrawSurface7
Public LaserSprite1 As DirectDrawSurface7
Public LaserSprite2 As DirectDrawSurface7
Public LaserSprite3 As DirectDrawSurface7
Public Explosion As DirectDrawSurface7
Public GameOver As DirectDrawSurface7
Public PauseScreen As DirectDrawSurface7
Public LevelUpSprite As DirectDrawSurface7
Public powerUpSprite As DirectDrawSurface7


'hold the quit flag
Dim bquit As Boolean
'dim the state flag
Dim bState As Integer '0 for normal operation, 1 for pause, 2 for game over, 3 for level up


Private Declare Function GetTickCount Lib "kernel32" () As Long
Dim lasttickcount As Long


Public Sub New_Game(screenmode As Integer)
    LoadConfigFromFile
    Unload Form1
    
    'create the DirectDraw object
    Set dd = dx.DirectDrawCreate("")
    
    'resize the form to the right size
    Form2.Move 0, 0, 1280 * Screen.TwipsPerPixelX, 1024 * Screen.TwipsPerPixelY

    'remember the screenmode
    smode = screenmode
    
    
    If screenmode = 0 Then
        '***************************************
        'windowed
        '***************************************
        'make the application a happy normal window
        Call dd.SetCooperativeLevel(Me.hWnd, DDSCL_NORMAL)
        
        'Indicate that the ddsCaps member is valid in this type
        ddsd_primary.lFlags = DDSD_CAPS
        'This surface is the primary surface (what is visible to the user)
        ddsd_primary.ddsCaps.lCaps = DDSCAPS_PRIMARYSURFACE
        'Your creating the primary surface now with the surface description you just set
        Set DDS_primary = dd.CreateSurface(ddsd_primary)
        
        'allocate the clipper
        Set ddClipper = dd.CreateClipper(0)
        ddClipper.SetHWnd Me.hWnd
        DDS_primary.SetClipper ddClipper
        
        'This is going to be a plain off-screen surface
        ddsd_back.ddsCaps.lCaps = DDSCAPS_OFFSCREENPLAIN Or DDSCAPS_SYSTEMMEMORY
        'tell create we want to set the width and height & caps
        ddsd_back.lFlags = DDSD_CAPS Or DDSD_WIDTH Or DDSD_HEIGHT
        'at 1280 by 1024 in size
        ddsd_back.lHeight = 1024
        ddsd_back.lWidth = 1280
        'Now we create the 1280x1024 off-screen surface
        Set BackBuffer = dd.CreateSurface(ddsd_back)

        
    Else '***************************************
        ' full-screen!!
        '***************************************
            
        'make your application full-screen
        Call dd.SetCooperativeLevel(Me.hWnd, DDSCL_FULLSCREEN Or DDSCL_ALLOWMODEX Or DDSCL_EXCLUSIVE)
        
        'set the screen mode
        dd.SetDisplayMode 1280, 1024, 32, 0, DDSDM_DEFAULT

        'get the screen surface and create a back buffer too
        ddsd_primary.lFlags = DDSD_CAPS Or DDSD_BACKBUFFERCOUNT
        ddsd_primary.ddsCaps.lCaps = DDSCAPS_PRIMARYSURFACE Or DDSCAPS_FLIP Or DDSCAPS_COMPLEX
        ddsd_primary.lBackBufferCount = 1
        Set DDS_primary = dd.CreateSurface(ddsd_primary)
        
        'now grab the back surface (from the flipping chain)
        Dim caps As DDSCAPS2
        caps.lCaps = DDSCAPS_BACKBUFFER
        Set BackBuffer = DDS_primary.GetAttachedSurface(caps)
                
    End If
    
    
    'show this form
    Form2.Show
    
    
    'load surfaces and any data
    loaddata
    
    NewLevel
    
    'wait 1000

    'begin the main rendering loop
    renderloop
End Sub

Sub NewLevel()
CurLevel = CurLevel + 1
MyShip.Xpos = 500
MyShip.Ypos = 450
MyShip.Health = 100
MyBase.Health = 100
MyShip.dead = False

MyBase.Xpos = 500
MyBase.Ypos = 450
MyBase.Health = 100
ReDim EnemyShips(1 To 100)
ReDim MyLasers(1 To 100)
ReDim Explosions(1 To 100)
ReDim powerUp(1 To 3)
 'howmany enemies, lasers, explosions
HowManyEnemies = 0
HowManyLasers = 0
HowManyExplosions = 0

'timer intervals adjusted
tmrSpawn1.Interval = 2000 / Sqr(CurLevel)
tmrSpawn2.Interval = 2000 / Sqr(Sqr(Sqr(CurLevel)))
'the powerup spawn interval remains the same. I think that that's fair

End Sub


Sub DrawBG()

'colour the non-image part in black
BackBuffer.BltColorFill R, RGB(0, 0, 0)

'blt the bgImg to the backbuffer.ScrenoffsetX is non-zero when you move to the left or the right of the screen edge
BackBuffer.Blt REC(100 - ScreenOffsetX, 50, 1123 - ScreenOffsetX, 937), bgImg, REC(0, 0, 0, 0), DDBLT_ASYNC
End Sub


Sub loaddata()
Dim ddckey As DDCOLORKEY

'let's set the surface description
ddsd_run.lFlags = DDSD_CAPS
ddsd_run.ddsCaps.lCaps = DDSCAPS_OFFSCREENPLAIN
'color key defines which colors are transparent
ddckey.low = RGB(0, 0, 0) 'black color key
ddckey.high = RGB(0, 0, 0) 'black color key


Dim ddsd1 As DDSURFACEDESC2
Set mainShipSprite = dd.CreateSurfaceFromFile(App.Path + "\ship1.bmp", ddsd1)
mainShipSprite.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd2 As DDSURFACEDESC2
Set mainShipHP = dd.CreateSurfaceFromFile(App.Path + "\health.bmp", ddsd2)
'don't need alpha transparency for HP

Dim ddsd3 As DDSURFACEDESC2
Set bgImg = dd.CreateSurfaceFromFile(App.Path + "\bg_crop.bmp", ddsd3)
'don't need alpha here either

Dim ddsd4 As DDSURFACEDESC2
Set BaseSprite = dd.CreateSurfaceFromFile(App.Path + "\crate.bmp", ddsd4)
BaseSprite.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd5 As DDSURFACEDESC2
Set EnemyShipSprite1 = dd.CreateSurfaceFromFile(App.Path + "\ship3.bmp", ddsd5)
EnemyShipSprite1.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd7 As DDSURFACEDESC2
Set EnemyShipSprite2 = dd.CreateSurfaceFromFile(App.Path + "\pirates.bmp", ddsd7)
EnemyShipSprite2.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd6 As DDSURFACEDESC2
Set LaserSprite1 = dd.CreateSurfaceFromFile(App.Path + "\laser1.bmp", ddsd6)
LaserSprite1.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd9 As DDSURFACEDESC2
Set LaserSprite2 = dd.CreateSurfaceFromFile(App.Path + "\laser2.bmp", ddsd9)
LaserSprite2.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd10 As DDSURFACEDESC2
Set LaserSprite3 = dd.CreateSurfaceFromFile(App.Path + "\laser3.bmp", ddsd10)
LaserSprite3.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd8 As DDSURFACEDESC2
Set Explosion = dd.CreateSurfaceFromFile(App.Path + "\explosion2.bmp", ddsd8)
Explosion.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd11 As DDSURFACEDESC2
Set GameOver = dd.CreateSurfaceFromFile(App.Path + "\GameOver.bmp", ddsd11)
GameOver.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd12 As DDSURFACEDESC2
Set PauseScreen = dd.CreateSurfaceFromFile(App.Path + "\pause.bmp", ddsd12)
PauseScreen.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd13 As DDSURFACEDESC2
Set LevelUpSprite = dd.CreateSurfaceFromFile(App.Path + "\lvlup.bmp", ddsd13)
LevelUpSprite.SetColorKey DDCKEY_SRCBLT, ddckey

Dim ddsd14 As DDSURFACEDESC2
Set powerUpSprite = dd.CreateSurfaceFromFile(App.Path + "\powerup.bmp", ddsd14)
powerUpSprite.SetColorKey DDCKEY_SRCBLT, ddckey
End Sub

Sub drawText(whichText As Integer) '0 for pause, 1 for game over, 2 for lvlup
If whichText = 0 Then 'pause
    BackBuffer.Blt REC(400, 400, 692, 501), PauseScreen, REC(0, 0, 292, 101), DDBLT_KEYSRC
ElseIf whichText = 1 Then 'lvlup
    BackBuffer.Blt REC(400, 400, 904, 581), GameOver, REC(0, 0, 504, 181), DDBLT_KEYSRC
ElseIf whichText = 2 Then    'lvlup
    BackBuffer.Blt REC(400, 400, 900, 700), LevelUpSprite, REC(0, 0, 500, 300), DDBLT_KEYSRC
End If
End Sub



Sub drawStuff() 'where the drawing to the buffer actually happens.
Dim R As RECT 'the output rectangle, useful for not having one long expression
Dim i As Integer 'useful little integer for loops

'base crate
R.Left = MyBase.Xpos - ScreenOffsetX
R.Top = MyBase.Ypos
R.Right = MyBase.Xpos + 150 - ScreenOffsetX
R.Bottom = MyBase.Ypos + 166
BackBuffer.Blt R, BaseSprite, REC(0, 0, 150, 166), DDBLT_KEYSRC 'draws the crate

'base's (crate's) hp
R.Top = R.Top + 140
R.Bottom = R.Top + 10
R.Right = R.Left + MyBase.Health
BackBuffer.Blt R, mainShipHP, REC(0, 0, MyBase.Health, 10), DDBLT_ASYNC 'async doesn't use alpha


For i = 1 To HowManyLasers 'for any lasers that might be on
    If MyLasers(i).State = 1 Then 'only lasers that are 'on'
        R.Left = MyLasers(i).posX
        R.Top = MyLasers(i).posY

        If MyLasers(i).Type = 0 Then 'red laser
            R.Right = MyLasers(i).posX + 12
            R.Bottom = MyLasers(i).posY + 12
            BackBuffer.Blt R, LaserSprite1, REC(0, 0, 12, 12), DDBLT_KEYSRC
        ElseIf MyLasers(i).Type = 1 Then 'green/yellow
            R.Right = MyLasers(i).posX + 12
            R.Bottom = MyLasers(i).posY + 12
            BackBuffer.Blt R, LaserSprite2, REC(0, 0, 12, 12), DDBLT_KEYSRC
        ElseIf MyLasers(i).Type = 2 Then 'blue
            R.Right = MyLasers(i).posX + 12
            R.Bottom = MyLasers(i).posY + 12
            BackBuffer.Blt R, LaserSprite3, REC(0, 0, 12, 12), DDBLT_KEYSRC
        End If
    End If
Next i

'myship
If MyShip.dead = False Then
    R.Left = MyShip.Xpos
    R.Top = MyShip.Ypos
    R.Right = MyShip.Xpos + 100
    R.Bottom = MyShip.Ypos + 100
    
    BackBuffer.Blt R, mainShipSprite, REC(MyShip.Rotation * 100 / 45, 0, 100 + MyShip.Rotation * 100 / 45, 100), DDBLT_KEYSRC
    
    'ship's HP bar
    R.Top = R.Top + 110
    R.Bottom = MyShip.Ypos + 120
    R.Right = R.Left + MyShip.Health
    BackBuffer.Blt R, mainShipHP, REC(0, 0, MyShip.Health, 10), DDBLT_ASYNC

End If


'Write score and level and other useful info
BackBuffer.SetForeColor RGB(0, 256, 0)
BackBuffer.drawText 0, 430, "Score : " & Score, False
BackBuffer.drawText 0, 450, "Level : " & CurLevel, False
BackBuffer.drawText 0, 0, "Mouse Pos : " & MouseX & ", " & MouseY, False

If MouseLeftDown = True Then
    BackBuffer.drawText 0, 30, "left click", False
End If
If MouseRightDown = True Then
    BackBuffer.drawText 0, 35, "right click", False
End If
If MouseMiddleDown = True Then
    BackBuffer.drawText 0, 40, "middle click", False
End If
    
'enemy ships


For i = 1 To HowManyEnemies
    If EnemyShips(i).State = 1 Then
        If EnemyShips(i).TypeOf = 0 Then
            R.Left = EnemyShips(i).posX - ScreenOffsetX
            R.Top = EnemyShips(i).posY
            R.Right = EnemyShips(i).posX + 100 - ScreenOffsetX
            R.Bottom = EnemyShips(i).posY + 100
            BackBuffer.Blt R, EnemyShipSprite1, REC(EnemyShips(i).Direction / 45 * 100, 0, EnemyShips(i).Direction / 45 * 100 + 100, 100), DDBLT_KEYSRC
            'BackBuffer.drawText EnemyShips(i).posX, EnemyShips(i).posY, EnemyShips(i).Direction, False
        ElseIf EnemyShips(i).TypeOf = 1 Then
            R.Left = EnemyShips(i).posX - ScreenOffsetX
            R.Top = EnemyShips(i).posY
            R.Right = EnemyShips(i).posX + 100 - ScreenOffsetX
            R.Bottom = EnemyShips(i).posY + 100
            BackBuffer.Blt R, EnemyShipSprite2, REC(0, 0, 100, 100), DDBLT_KEYSRC


        End If
        'hp bar, if needed
        If (EnemyShips(i).Health < 100) Then
            R.Top = R.Top + 100
            R.Bottom = R.Top + 10
            R.Right = R.Left + EnemyShips(i).Health
            BackBuffer.Blt R, mainShipHP, REC(0, 0, EnemyShips(i).Health, 10), DDBLT_ASYNC
        End If

    End If
Next i

'explosions
For i = 1 To HowManyExplosions
    If Explosions(i).State = 1 Then 'blit it
        R.Left = Explosions(i).Xpos
        R.Top = Explosions(i).Ypos
        R.Right = Explosions(i).Xpos + 64
        R.Bottom = Explosions(i).Ypos + 64
        BackBuffer.Blt R, Explosion, REC(Explosions(i).Frame * 64, 0, Explosions(i).Frame * 64 + 64, 64), DDBLT_KEYSRC
    End If
Next i

For i = 1 To 3
    If powerUp(i).Health > 0 Then
        'blt the powerup
        R.Left = powerUp(i).Xpos
        R.Top = powerUp(i).Ypos
        R.Right = R.Left + 20
        R.Bottom = R.Top + 20
        BackBuffer.Blt R, powerUpSprite, REC(0, 0, 20, 20), DDBLT_KEYSRC
    End If
Next i
End Sub

Function REC(x, y, x1, y1) As RECT 'an uber-useful function for putting in rectangles
REC.Left = x
REC.Right = x1
REC.Bottom = y1
REC.Top = y
End Function

Sub renderloop()
'the rectangle for windowed mode
Dim r2 As RECT
Do
        DrawBG 'draw bg no matter what
    If bState = 0 Then 'normal
        'draw current game screen, and handle stuff

        HandleInput
        HandleLasers
        HandleEnemies
        HandlePowerups
        HandleExplosions
        HandleLvlScore
        drawStuff 'blits everything to the buffer
    ElseIf bState = 1 Then 'paused

        SStimers (False) 'stop all timers so enemies/lasers don't spawn
        drawStuff
        'draw pause text
        drawText (0)
        'do nothing, basically, because the game is paused
    ElseIf bState = 2 Then 'game over

        SStimers (False)
        drawStuff
        'draw game over text
        drawText (1)
    Else 'bstate = 3, level up screen
        SStimers (False)
        'newlevel called elsewhere, here it would be called too many times, this is a loop, remember
        HandleInput
        HandleLasers
        HandleEnemies
        HandleExplosions
        HandlePowerups
        drawStuff
        drawText (2)
    End If
    'flip the double buffered surfaces
    If smode = 0 Then 'windowed
        dx.GetWindowRect Me.hWnd, r2
        r2.Top = r2.Top + 22
        DDS_primary.Blt r2, BackBuffer, R, DDBLTFAST_NOCOLORKEY + DDBLTFAST_WAIT
    Else 'full-screen
        DDS_primary.Flip Nothing, DDFLIP_WAIT
    End If
    
    'make time for other things
    DoEvents
Loop Until bquit
End Sub

Private Sub SStimers(start As Boolean)  'start or stop timers
If start = False Then
    tmrLeftMouse.Enabled = False
    tmrMiddleMouse.Enabled = False
    tmrRightMouse.Enabled = False
    tmrSpawn1.Enabled = False
    tmrSpawn2.Enabled = False
    tmrUpgrade.Enabled = False
Else
    tmrLeftMouse.Enabled = True
    tmrMiddleMouse.Enabled = True
    tmrRightMouse.Enabled = True
    tmrSpawn1.Enabled = True
    tmrSpawn2.Enabled = True
    tmrUpgrade.Enabled = True
End If
End Sub


Private Sub HandleLvlScore()
If (Score > 10 * 2 ^ CurLevel) Then 'the exponential function for going up a level
    NewLevel
    bState = 3 'switch the state to the 'level up' text
    tmrBreak.Enabled = True 'level up text timer
End If
End Sub

Sub drawMirror() 'here for reference purporses ONLY. (the mirror command seems useful)
    If reverseflag Then '(i.e. facing right)
        mbltfx.lDDFX = DDBLTFX_MIRRORLEFTRIGHT 'mirrors the image
        BackBuffer.BltFx r3, DDS_run, r2, DDBLT_KEYSRC Or DDBLT_DDFX, mbltfx 'use bltFx
    Else '(i.e. facing left)
        BackBuffer.Blt r3, DDS_run, r2, DDBLT_KEYSRC
    End If
End Sub

Private Sub HandleLasers()
For i = 1 To HowManyLasers
    If MyLasers(i).State = 1 Then
        MyLasers(i).posX = MyLasers(i).SpeedX + MyLasers(i).posX
        MyLasers(i).posY = MyLasers(i).SpeedY + MyLasers(i).posY
    End If
    
    'handle going off screen
    If MyLasers(i).posX > 1280 Or MyLasers(i).posX < 0 Then
        MyLasers(i).State = 0
    End If
    
    If MyLasers(i).posY > 1024 Or MyLasers(i).posY < 0 Then
        MyLasers(i).State = 0
    End If
Next i
End Sub

Private Sub HandleExplosions()
Dim i As Integer

If (HowManyExplosions + 1 > UBound(Explosions())) Then
    ReDim Preserve Explosions(1 To HowManyExplosions + 100) 'if i need more array space
End If

For i = 1 To HowManyExplosions
    If Explosions(i).State = 1 Then
        If (Explosions(i).Frame > 8) Then '8 frames
            Explosions(i).State = 0
            Explosions(i).Frame = 0
        Else
            Explosions(i).Frame = Explosions(i).Frame + 1
        End If
    End If
Next i
End Sub

Private Sub HandlePowerups()
Dim i As Integer
For i = 1 To 3
    If powerUp(i).Health > 0 Then
        'move it
        powerUp(i).Xpos = powerUp(i).Xpos + powerUp(i).Xvel
        powerUp(i).Ypos = powerUp(i).Ypos + powerUp(i).Yvel
        
        'collision detection
        If MyShip.dead = False Then
            If RectCollision(REC(powerUp(i).Xpos, powerUp(i).Ypos, powerUp(i).Xpos + 20, powerUp(i).Ypos + 20), REC(MyShip.Xpos, MyShip.Ypos, MyShip.Xpos + 100, MyShip.Ypos + 100)) Then
                powerUp(i).Health = 0
                If MyShip.Health < 100 Then
                    Upgrades = Upgrades + 1
                    tmrLeftMouse.Interval = tmrLeftMouse.Interval / 1.2
                    tmrMiddleMouse.Interval = tmrMiddleMouse.Interval / 1.2
                    tmrRightMouse.Interval = tmrRightMouse.Interval / 1.2
                    MyShip.Health = MyShip.Health + 10
                    If MyShip.Health > 100 Then
                        MyShip.Health = 100
                    End If
                End If
                
            End If
        End If
        
        'handle going off screen
        'i could've used the rectCollision sub, but decided not to due to performance concerns
        If powerUp(i).Xpos > 1280 Or powerUp(i).Xpos < 1 Then
            powerUp(i).Health = 0
        End If
        
        If powerUp(i).Xpos > 1024 Or powerUp(i).Ypos < 1 Then
            powerUp(i).Health = 0
        End If
    End If
Next i
End Sub

Private Sub HandleEnemies()
Dim d As Integer 'a for loop int
'handle their movement
For i = 1 To HowManyEnemies
    If EnemyShips(i).State = 1 Then
        'check if the ship is on screen
        If EnemyShips(i).posX > 1280 Or EnemyShips(i).posX < 0 Then
            EnemyShips(i).State = 0
        End If
        
        If EnemyShips(i).posY > 1024 Or EnemyShips(i).posY < 0 Then
            EnemyShips(i).State = 0
        End If
    
        If EnemyShips(i).State = 1 Then
            EnemyShips(i).posX = EnemyShips(i).posX + EnemyShips(i).velX
            EnemyShips(i).posY = EnemyShips(i).posY + EnemyShips(i).velY
            If EnemyShips(i).TypeOf = 0 Then 'if that's the default enemy
                'any code to make generic regular enemies do stuff
            ElseIf EnemyShips(i).TypeOf = 1 Then
                Dim DiffX As Integer
                Dim DiffY As Integer
                Dim Hypot As Single 'hypotinuse
                If MyShip.dead = False Then

                    DiffX = EnemyShips(i).posX - MyShip.Xpos
                    DiffY = EnemyShips(i).posY - MyShip.Ypos
                    Hypot = Sqr(DiffX ^ 2 + DiffY ^ 2)
                    If Hypot > 0 Then
                        EnemyShips(i).velX = -DiffX * 3 / Hypot
                        EnemyShips(i).velY = -DiffY * 3 / Hypot
                    Else
                        EnemyShips(i).velX = 0
                        EnemyShips(i).velY = 0
                    End If
                Else 'aim towards base

                    DiffX = EnemyShips(i).posX - MyBase.Xpos
                    DiffY = EnemyShips(i).posY - MyBase.Ypos
                    Hypot = Sqr(DiffX ^ 2 + DiffY ^ 2)
                    If Hypot > 0 Then
                        EnemyShips(i).velX = -DiffX * 3 / Hypot
                        EnemyShips(i).velY = -DiffY * 3 / Hypot
                    Else
                        EnemyShips(i).velX = 0
                        EnemyShips(i).velY = 0
                    End If
                End If
            End If
            
            'check collision with: myship, use rectCollision
            If MyShip.dead = False Then
                If RectCollision(REC(EnemyShips(i).posX, EnemyShips(i).posY, EnemyShips(i).posX + 100, EnemyShips(i).posY + 100), REC(MyShip.Xpos, MyShip.Ypos, MyShip.Xpos + 100, MyShip.Ypos + 100)) Then
                    EnemyShips(i).State = 0
                    MyShip.Health = MyShip.Health - EnemyShips(i).Damage
                    SpawnExplosion EnemyShips(i).posX, EnemyShips(i).posY
                    If MyShip.Health < 1 Then
                        'destroy ship and stuff
                        MyShip.dead = True
                        SpawnExplosion MyShip.Xpos, MyShip.Ypos
                    End If
                End If
            End If
            'check collision with lasers
            For d = 1 To HowManyLasers
                If MyLasers(d).State = 1 Then
                    If RectCollision(REC(EnemyShips(i).posX, EnemyShips(i).posY, EnemyShips(i).posX + 100, EnemyShips(i).posY + 100), REC(MyLasers(d).posX, MyLasers(d).posY, MyLasers(d).posX + 12, MyLasers(d).posY + 12)) = True Then
                        
                        EnemyShips(i).Health = EnemyShips(i).Health - MyLasers(d).Damage
                        'use ship's HP to check if it should explode
                        If (EnemyShips(i).Health < 1) Then
                            EnemyShips(i).State = 0
                            SpawnExplosion EnemyShips(i).posX, EnemyShips(i).posY
                            Score = Score + EnemyShips(i).Points
                        End If
                        MyLasers(d).State = 0
                        '_____________
                        '______________
                        d = HowManyLasers 'exit loop
                    End If
                End If
            Next d
            
            'base collision
            If RectCollision(REC(EnemyShips(i).posX, EnemyShips(i).posY, EnemyShips(i).posX + 100, EnemyShips(i).posY + 100), REC(MyBase.Xpos, MyBase.Ypos, MyBase.Xpos + 150, MyBase.Ypos + 166)) Then
                MyBase.Health = MyBase.Health - EnemyShips(i).Damage
                EnemyShips(i).State = 0
                SpawnExplosion EnemyShips(i).posX, EnemyShips(i).posY
                If (MyBase.Health < 1) Then
                    'game over stuff here!!!
                    SpawnExplosion EnemyShips(i).posX, EnemyShips(i).posY
                    bState = 2
                End If
            End If
        End If
    End If
Next i
End Sub

Private Sub HandleInput()

HandleKeyboardIn

'HandleMouseIn 'don't need to, already handled by timers
End Sub
Sub HandleKeyboardIn()
If KeyLeftPressed Then
    MyShip.Xpos = MyShip.Xpos - 10
    If KeyUpPressed Then
        MyShip.Rotation = 315
    ElseIf KeyDownPressed Then
        MyShip.Rotation = 225
    Else
        MyShip.Rotation = 270
    End If
ElseIf KeyRightPressed Then
    MyShip.Xpos = MyShip.Xpos + 10
    If KeyUpPressed Then
        MyShip.Rotation = 45
    ElseIf KeyDownPressed Then
        MyShip.Rotation = 135
    Else
        MyShip.Rotation = 90
    End If
Else
    If KeyUpPressed Then
        MyShip.Rotation = 0
    ElseIf KeyDownPressed Then
        MyShip.Rotation = 180
    End If
End If

If KeyUpPressed Then
    MyShip.Ypos = MyShip.Ypos - 10

ElseIf KeyDownPressed Then
    MyShip.Ypos = MyShip.Ypos + 10

End If

'bg and enemy offset
If (MyShip.Xpos < 0) Then
    ScreenOffsetX = MyShip.Xpos + ScreenOffsetX
    MyShip.Xpos = 0
ElseIf (ScreenOffsetX < 0) Then
    ScreenOffsetX = MyShip.Xpos + ScreenOffsetX
    MyShip.Xpos = 0
End If

If (MyShip.Xpos > 1180) Then
    ScreenOffsetX = MyShip.Xpos - 1180 + ScreenOffsetX
    MyShip.Xpos = 1180
ElseIf (ScreenOffsetX > 0) Then
    ScreenOffsetX = MyShip.Xpos - 1180 + ScreenOffsetX
    MyShip.Xpos = 1180
End If
End Sub
Sub HandleMouseIn()
If MouseLeftDown Then
'if lasersonscreen
End If

If MouseRightDown Then

End If

If MouseMiddleDown Then

End If
End Sub

Private Sub Form_DblClick()
'double click doesn't register with the normal mouseDown, I might do something about it
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    
    If (KeyCode = KeyPauseAscii) Then
        If bState = 0 Then 'pause
            bState = 1
        ElseIf bState = 1 Then 'unpause
            bState = 0
            SStimers (True)
        End If
    End If
    If (KeyCode = KeyUpAscii) Then
        KeyUpPressed = True
    ElseIf (KeyCode = KeyDownAscii) Then
        KeyDownPressed = True
    End If
    If (KeyCode = KeyLeftAscii) Then
        KeyLeftPressed = True
    ElseIf (KeyCode = KeyRightAscii) Then
        KeyRightPressed = True
    End If
    
    If KeyCode = 27 Then Unload Form2 'escape
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)

    If (KeyCode = KeyUpAscii) Then 'input for the ship
        KeyUpPressed = False
    ElseIf (KeyCode = KeyDownAscii) Then
        KeyDownPressed = False
    End If
    If (KeyCode = KeyLeftAscii) Then
        KeyLeftPressed = False
    ElseIf (KeyCode = KeyRightAscii) Then
        KeyRightPressed = False
    End If
    
End Sub


Private Sub form_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
If (Button = 1) Then 'left mouse
    tmrLeftMouse = True
    MouseLeftDown = True
ElseIf (Button = 2) Then
    tmrRightMouse = True
    MouseRightDown = True
ElseIf (Button = 4) Then
    tmrMiddleMouse = True
    MouseMiddleDown = True
End If
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
'"X: " & mouseposition.x & " Y: " & mouseposition.y 'just for the information for debugging
MouseX = x
MouseY = y
End Sub

Private Sub Form_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
If (Button = 1) Then 'shots controlling
    MouseLeftDown = False
    tmrLeftMouse = False
ElseIf (Button = 2) Then
    MouseRightDown = False
    tmrRightMouse = False
ElseIf (Button = 4) Then
    MouseMiddleDown = False
    tmrMiddleMouse = False
End If
End Sub



Private Sub Form_Load()
Randomize
'make the usefull full-screen rectangle
R.Top = 0
R.Left = 0
R.Right = 1280
R.Bottom = 1024

'the stupid timer doesn't show up on the form, but still exists!!! I can't let a perfectly good timer go to waste
tmrBreak.Interval = 2000
tmrBreak.Enabled = False
End Sub

Private Sub Form_Unload(Cancel As Integer)
    bquit = True
    'Form1.Show
End Sub

Private Sub LoadConfigFromFile()
'setting the key codes
'---need to read from text file---

KeyUpAscii = 87 'W
KeyDownAscii = 83 'S
KeyLeftAscii = 65 'A
KeyRightAscii = 68 'D
KeyPauseAscii = 80 'P

End Sub

Private Sub SpawnExplosion(x As Single, y As Single)
If (HowManyExplosions + 1 > UBound(Explosions())) Then
    ReDim Preserve Explosions(1 To HowManyExplosions + 100)
End If
HowManyExplosions = HowManyExplosions + 1
Explosions(HowManyExplosions).State = 1
Explosions(HowManyExplosions).Xpos = x
Explosions(HowManyExplosions).Ypos = y

End Sub


Private Sub SpawnEnemy(EnemyType As Integer)
Dim side As Integer
Dim i As Integer
Dim Speed As Integer
'If (HowManyEnemies + 1 > 11) Then
If (HowManyEnemies + 10 > UBound(EnemyShips())) Then

    ReDim Preserve EnemyShips(1 To HowManyEnemies + 10)
End If
HowManyEnemies = HowManyEnemies + 1
side = Rnd * 4 + 1 'which side of the screen should they fly from?

If side = 1 Then 'left
    EnemyShips(HowManyEnemies).posX = 10
    EnemyShips(HowManyEnemies).posY = Rnd * 900
ElseIf side = 2 Then 'top
    EnemyShips(HowManyEnemies).posX = Rnd * 1000
    EnemyShips(HowManyEnemies).posY = 10
ElseIf side = 3 Then 'right
    EnemyShips(HowManyEnemies).posX = 1000
    EnemyShips(HowManyEnemies).posY = Rnd * 800
Else 'bottom
    EnemyShips(HowManyEnemies).posX = Rnd * 1000
    EnemyShips(HowManyEnemies).posY = 800
End If
EnemyShips(HowManyEnemies).State = 1

If EnemyType = 0 Then
    Speed = 2 + Rnd * 2
    EnemyShips(HowManyEnemies).Damage = 5
    'their direction and vels
    Dim DiffX As Integer
    Dim DiffY As Integer
    Dim Hypot As Single
    'Dim z As Integer
    
    DiffX = EnemyShips(HowManyEnemies).posX - MyBase.Xpos
    DiffY = EnemyShips(HowManyEnemies).posY - MyBase.Ypos
    Hypot = Sqr(DiffX ^ 2 + DiffY ^ 2)
    If (Hypot <> 0) Then 'i can't divide by 0
        EnemyShips(HowManyEnemies).velX = -DiffX * 3 / Hypot
        EnemyShips(HowManyEnemies).velY = -DiffY * 3 / Hypot
    Else 'something to keep the ship occupied
        EnemyShips(HowManyEnemies).velX = 1
        EnemyShips(HowManyEnemies).velY = 1
    End If
    EnemyShips(HowManyEnemies).Direction = RadiansToDegrees(Atan2(DiffY, DiffX))
    EnemyShips(HowManyEnemies).Direction = EnemyShips(HowManyEnemies).Direction - 90
    If EnemyShips(HowManyEnemies).Direction < 0 Then
        EnemyShips(HowManyEnemies).Direction = EnemyShips(HowManyEnemies).Direction + 360
    End If
    'set the direction in 45 degree chunks!!! doesn't work currently
    If EnemyShips(HowManyEnemies).Direction < 23 Then
        EnemyShips(HowManyEnemies).Direction = 0
    ElseIf EnemyShips(HowManyEnemies).Direction < 68 Then
        EnemyShips(HowManyEnemies).Direction = 45
    ElseIf EnemyShips(HowManyEnemies).Direction < 108 Then
        EnemyShips(HowManyEnemies).Direction = 90
    ElseIf EnemyShips(HowManyEnemies).Direction < 158 Then
        EnemyShips(HowManyEnemies).Direction = 135
    ElseIf EnemyShips(HowManyEnemies).Direction < 203 Then
        EnemyShips(HowManyEnemies).Direction = 180
    ElseIf EnemyShips(HowManyEnemies).Direction < 248 Then
        EnemyShips(HowManyEnemies).Direction = 225
    ElseIf EnemyShips(HowManyEnemies).Direction < 293 Then
        EnemyShips(HowManyEnemies).Direction = 270
    ElseIf EnemyShips(HowManyEnemies).Direction < 338 Then
        EnemyShips(HowManyEnemies).Direction = 315
    Else
        EnemyShips(HowManyEnemies).Direction = 0
    End If
    'type
    'z = Speed / Sqr(2)
    'If EnemyShips(HowManyEnemies).velX > z Then
    
    'Else
    
    EnemyShips(HowManyEnemies).TypeOf = 0 'ship type 0, the regular dumb ship
    EnemyShips(HowManyEnemies).Points = 10
ElseIf EnemyType = 1 Then
    EnemyShips(HowManyEnemies).Damage = 6
    EnemyShips(HowManyEnemies).TypeOf = 1
    EnemyShips(HowManyEnemies).Points = 20
End If
EnemyShips(HowManyEnemies).Health = 100

End Sub

Private Sub SpawnLaser(LaserType As Integer, x As Integer, y As Integer)
Dim i As Integer
Dim DiffX As Integer
Dim DiffY As Integer
Dim Hypot As Single
Dim Speed As Integer


If HowManyLasers + 1 > UBound(MyLasers()) Then
    ReDim Preserve MyLasers(1 To HowManyLasers + 4)
End If
MyLasers(HowManyLasers + 1).Type = LaserType

MyLasers(HowManyLasers + 1).State = 1
MyLasers(HowManyLasers + 1).posX = MyShip.Xpos + 50
MyLasers(HowManyLasers + 1).posY = MyShip.Ypos + 50
If LaserType = 0 Then 'spawn regular laser
    DiffX = -MyLasers(HowManyLasers + 1).posX + MouseX
    DiffY = -MyLasers(HowManyLasers + 1).posY + MouseY
    MyLasers(HowManyLasers + 1).Damage = 4 * Sqr(Sqr(Sqr(Sqr(CurLevel)))) + Upgrades / 4 'i had to tune down the weapons a whole lot, so u can't just kill everything in one shot
    Speed = 6
ElseIf LaserType = 1 Then
    DiffX = -MyLasers(HowManyLasers + 1).posX + MouseX
    DiffY = -MyLasers(HowManyLasers + 1).posY + MouseY
    MyLasers(HowManyLasers + 1).Damage = 15 * Sqr(Sqr(Sqr(Sqr(CurLevel)))) + Upgrades / 4
    Speed = 3
ElseIf LaserType = 2 Then
    DiffX = MyLasers(HowManyLasers + 1).posX - MouseX
    DiffY = MyLasers(HowManyLasers + 1).posY - MouseY
    MyLasers(HowManyLasers + 1).Damage = 5 * Sqr(Sqr(Sqr(Sqr(CurLevel)))) + Upgrades / 4
    Speed = 4
End If

Hypot = Sqr(DiffX ^ 2 + DiffY ^ 2)
If Hypot <> 0 Then
    MyLasers(HowManyLasers + 1).SpeedX = DiffX * Speed / Hypot
    MyLasers(HowManyLasers + 1).SpeedY = DiffY * Speed / Hypot
Else
    MyLasers(HowManyLasers + 1).SpeedX = 1
    MyLasers(HowManyLasers + 1).SpeedY = 1
End If
MyLasers(HowManyLasers + 1).State = 1
HowManyLasers = HowManyLasers + 1
End Sub

Function RectCollision(r1 As RECT, r2 As RECT) As Boolean

Dim rOut As RECT     'The IntersectRect call will return a rectangle equal in size to the intersection between two rectangles

'Check for rectangle collision
RectCollision = IntersectRect(rOut, r1, r2)

End Function

Private Sub tmrBreak_Timer()
'this timer disappeared from the form for some reason. It still exists, but it isn't visible.
bState = 0
SStimers (True)
tmrBreak.Enabled = False
End Sub

Private Sub tmrLeftMouse_Timer()
If (MouseLeftDown = True) Then
    SpawnLaser 0, MouseX, MouseY
End If
End Sub

Private Sub tmrMiddleMouse_Timer()
If MouseMiddleDown = True Then
    SpawnLaser 1, MouseX, MouseY
End If
End Sub

Private Sub tmrRightMouse_Timer()
If MouseRightDown = True Then
    SpawnLaser 2, MouseX, MouseY
    SpawnLaser 1, MouseX, MouseY
End If
End Sub

Private Sub tmrSpawn1_Timer()

SpawnEnemy 0

End Sub

Private Sub tmrSpawn2_Timer()
SpawnEnemy 1
    
End Sub

Private Sub tmrUpgrade_Timer()
Dim i As Integer
For i = 1 To 3
    If powerUp(i).Health = 0 Then
        'spawn powerup and stuff
        spawnUpgrade i
        
        i = 3 'exit loop
    End If
Next i
End Sub
Sub spawnUpgrade(i As Integer)
Dim DiffX As Integer
Dim DiffY As Integer
Dim Hypot As Single
Dim side As Integer
side = Rnd * 4 + 1 'which side of the screen should they fly from

If side = 1 Then 'left
    powerUp(i).Xpos = 10
    powerUp(i).Ypos = Rnd * 900
ElseIf side = 2 Then 'top
    powerUp(i).Xpos = Rnd * 1000
    powerUp(i).Ypos = 10
ElseIf side = 3 Then 'right
    powerUp(i).Xpos = 1000
    powerUp(i).Ypos = Rnd * 800
Else 'bottom
    powerUp(i).Xpos = Rnd * 1000
    powerUp(i).Ypos = 800
End If
powerUp(i).Health = 1




DiffX = powerUp(i).Xpos - MyBase.Xpos
DiffY = powerUp(i).Ypos - MyBase.Ypos
Hypot = Sqr(DiffX ^ 2 + DiffY ^ 2)
If (Hypot <> 0) Then 'i can't divide by 0
    powerUp(i).Xvel = -DiffX * 3 / Hypot
    powerUp(i).Yvel = -DiffY * 3 / Hypot
Else 'something to keep the ship occupied
    powerUp(i).Xvel = 1
    powerUp(i).Yvel = 1
End If

End Sub
