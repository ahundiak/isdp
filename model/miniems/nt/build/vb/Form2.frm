VERSION 4.00
Begin VB.Form FRM_PATH 
   Caption         =   "PATH"
   ClientHeight    =   3528
   ClientLeft      =   1476
   ClientTop       =   1800
   ClientWidth     =   3888
   Height          =   3852
   Left            =   1428
   LinkTopic       =   "Form2"
   ScaleHeight     =   3528
   ScaleWidth      =   3888
   Top             =   1524
   Width           =   3984
   Begin VB.CommandButton Command2 
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   2640
      TabIndex        =   3
      Top             =   1560
      Width           =   1215
   End
   Begin VB.CommandButton Command1 
      Caption         =   "&OK"
      Height          =   375
      Left            =   2640
      TabIndex        =   2
      Top             =   1080
      Width           =   1215
   End
   Begin VB.DriveListBox drvList 
      Height          =   315
      Left            =   120
      TabIndex        =   1
      Top             =   3000
      Width           =   2295
   End
   Begin VB.DirListBox dirList 
      Height          =   1605
      Left            =   120
      TabIndex        =   0
      Top             =   1080
      Width           =   2295
   End
   Begin VB.Label Dir 
      Caption         =   "Label3"
      Height          =   375
      Left            =   120
      TabIndex        =   6
      Top             =   600
      Width           =   3735
   End
   Begin VB.Label Label2 
      Caption         =   "Directory"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Drives"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   2760
      Width           =   975
   End
End
Attribute VB_Name = "FRM_PATH"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()
   Form1.strPath = dirList.Path
   Form1.bOK = True
   Unload Me            ' Unload this form.
End Sub



Private Sub Command2_Click()
   Unload Me            ' Unload this form.
End Sub




Private Sub List1_Click()

End Sub


Private Sub dirList_Change()
    ' Update file list box to synchronize with the directory list box.
    Dir.Caption = dirList.Path
End Sub

Private Sub drvList_Change()
    On Error GoTo DriveHandler
    ' If new drive was selected, the Dir1 box updates its display.
    dirList.Path = drvList.Drive
    Exit Sub
' If there is an error, reset drvList.Drive with the drive from
' dirList.Path.
DriveHandler:
    drvList.Drive = dirList.Path
    Exit Sub
End Sub


Private Sub File1_Click()

End Sub


Private Sub Form_Load()
    If Form1.strPath = "" Then
       Dir.Caption = dirList.Path
    Else
       drvList.Drive = Form1.strPath
       dirList.Path = Form1.strPath
    End If
    
    FRM_PATH.Left = Form1.Left + Form1.Width / 2 - FRM_PATH.Width / 2
    FRM_PATH.Top = Form1.Top + Form1.Height / 2 - FRM_PATH.Height / 2
    Form1.bOK = False
End Sub


