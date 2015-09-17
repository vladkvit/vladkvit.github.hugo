Attribute VB_Name = "Module1"
Const Pi = 3.14159265

Declare Function GetCursorPos Lib "user32" (lpPoint As POINTAPI) As Long

'mouse position stuff
Private Type POINTAPI
    x As Long
    y As Long
End Type

Global mouseposition As POINTAPI

'mouse angle stuff
Public Function Atan2(ByVal y As Double, ByVal x As Double) As Double
  Dim theta As Double

  If (Abs(x) < 0.0000001) Then
    If (Abs(y) < 0.0000001) Then
      theta = 0#
    ElseIf (y > 0#) Then
      theta = 1.5707963267949
    Else
      theta = -1.5707963267949
    End If
  Else
    theta = Atn(y / x)
  
    If (x < 0) Then
      If (y >= 0#) Then
        theta = 3.14159265358979 + theta
      Else
        theta = theta - 3.14159265358979
      End If
    End If
  End If
    
  Atan2 = theta
End Function

Sub wait(ticks As Long)
    Dim tick As Long
    tick = GetTickCount()
    Do
    Loop Until GetTickCount() - tick > ticks
End Sub

Public Function RadiansToDegrees(ByVal vX As Variant) As Variant
RadiansToDegrees = vX * 180 / Pi
End Function

