VERSION 5.00
Begin VB.Form form3 
   Caption         =   "About/Help"
   ClientHeight    =   2415
   ClientLeft      =   3585
   ClientTop       =   3345
   ClientWidth     =   6525
   LinkTopic       =   "Form3"
   ScaleHeight     =   2415
   ScaleWidth      =   6525
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   495
      Left            =   120
      TabIndex        =   2
      Top             =   1680
      Width           =   3255
   End
   Begin VB.Label Label4 
      Caption         =   "Protect the crate at all costs! The little pluses are powerups"
      Height          =   495
      Left            =   240
      TabIndex        =   4
      Top             =   1200
      Width           =   5655
   End
   Begin VB.Label Label3 
      Caption         =   "Mouse: L. Click = machine gun, middle = heavy artillery, middle = spread gun"
      Height          =   375
      Left            =   240
      TabIndex        =   3
      Top             =   600
      Width           =   5775
   End
   Begin VB.Label Label2 
      Caption         =   "Keyboard: WASD for movement, P for Pause, Esc to quit"
      Height          =   375
      Left            =   240
      TabIndex        =   1
      Top             =   120
      Width           =   5655
   End
   Begin VB.Label Label1 
      Caption         =   "By Vlad Kvitnevski"
      Height          =   255
      Left            =   3600
      TabIndex        =   0
      Top             =   1800
      Width           =   2175
   End
End
Attribute VB_Name = "form3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
form3.Hide
End Sub
