VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Menu"
   ClientHeight    =   3810
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   2925
   LinkTopic       =   "Form1"
   ScaleHeight     =   3810
   ScaleWidth      =   2925
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command3 
      Caption         =   "About/Help"
      Height          =   735
      Left            =   240
      TabIndex        =   4
      Top             =   2880
      Width           =   2415
   End
   Begin VB.TextBox txtHeight 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1440
      TabIndex        =   3
      Text            =   "1024"
      Top             =   120
      Width           =   1335
   End
   Begin VB.TextBox txtWidth 
      Enabled         =   0   'False
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Text            =   "1280"
      Top             =   120
      Width           =   1215
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Play Full - Screen (nice and fast)"
      Height          =   675
      Left            =   120
      TabIndex        =   1
      Top             =   1560
      Width           =   2595
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Play in a window (real slow)"
      Height          =   675
      Left            =   120
      TabIndex        =   0
      Top             =   720
      Width           =   2595
   End
End
Attribute VB_Name = "Form1"
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


Private Sub Command1_Click()
    Form2.New_Game 0 'windowed
    Unload Form1
End Sub

Private Sub Command2_Click()
    Form2.New_Game 1 'full-screen
    Unload Form1
End Sub

Private Sub Command3_Click()
form3.Show
End Sub

Private Sub Form_Load()
Form1.Show
Command2.SetFocus
End Sub
