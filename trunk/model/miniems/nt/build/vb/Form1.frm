VERSION 4.00
Begin VB.Form Form1 
   Caption         =   "BUILD"
   ClientHeight    =   6000
   ClientLeft      =   1104
   ClientTop       =   2016
   ClientWidth     =   5676
   Height          =   6324
   Left            =   1056
   LinkTopic       =   "Form1"
   ScaleHeight     =   6000
   ScaleWidth      =   5676
   Top             =   1740
   Width           =   5772
   Begin VB.CommandButton CB_FORM1_BSLIBS 
      Caption         =   "..."
      Height          =   372
      Left            =   3720
      TabIndex        =   22
      Top             =   3840
      Width           =   372
   End
   Begin VB.TextBox EDT_FORM1_BSLIBS 
      Height          =   372
      Left            =   1080
      TabIndex        =   21
      Top             =   3840
      Width           =   2532
   End
   Begin VB.CheckBox Append 
      Caption         =   "&Append"
      Height          =   255
      Left            =   4200
      TabIndex        =   27
      Top             =   4680
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.CommandButton CB_FORM1_LOG 
      Caption         =   "..."
      Height          =   375
      Left            =   3720
      TabIndex        =   26
      Top             =   4800
      Width           =   375
   End
   Begin VB.TextBox EDT_FORM1_LOG 
      Height          =   375
      Left            =   1080
      TabIndex        =   25
      Top             =   4800
      Width           =   2535
   End
   Begin VB.CommandButton CB_FORM1_MSVC 
      Caption         =   "..."
      Height          =   375
      Left            =   3720
      TabIndex        =   24
      Top             =   4320
      Width           =   375
   End
   Begin VB.TextBox EDT_FORM1_MSVC 
      Height          =   375
      Left            =   1080
      TabIndex        =   23
      Top             =   4320
      Width           =   2535
   End
   Begin VB.CommandButton Command9 
      Caption         =   "&Close"
      Height          =   372
      Left            =   2880
      TabIndex        =   30
      Top             =   5400
      Width           =   1404
   End
   Begin VB.CommandButton CB_FORM1_BUILD 
      Caption         =   "&Build"
      Height          =   372
      Left            =   1320
      TabIndex        =   29
      Top             =   5400
      Width           =   1404
   End
   Begin VB.CommandButton CB_FORM1_BS 
      Caption         =   "..."
      Height          =   375
      Left            =   3720
      TabIndex        =   20
      Top             =   3360
      Width           =   375
   End
   Begin VB.TextBox EDT_FORM1_BS 
      Height          =   375
      Left            =   1080
      TabIndex        =   19
      Top             =   3360
      Width           =   2535
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   3132
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   5412
      _Version        =   65536
      _ExtentX        =   9551
      _ExtentY        =   5530
      _StockProps     =   15
      Caption         =   "&OM"
      TabsPerRow      =   2
      Tab             =   0
      TabOrientation  =   0
      Tabs            =   2
      Style           =   0
      TabMaxWidth     =   0
      TabHeight       =   529
      TabCaption(0)   =   "&OM"
      Tab(0).ControlCount=   11
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "LBL_OM_SOURCE"
      Tab(0).Control(1)=   "LBL_OM_DBGTARGET"
      Tab(0).Control(2)=   "LBL_OM_RELTARGET"
      Tab(0).Control(3)=   "EDT_OM_SOURCE"
      Tab(0).Control(4)=   "CB_OM_SOURCE"
      Tab(0).Control(5)=   "CHK_OM_DBG"
      Tab(0).Control(6)=   "CHK_OM_REL"
      Tab(0).Control(7)=   "EDT_OM_DBG"
      Tab(0).Control(8)=   "EDT_OM_REL"
      Tab(0).Control(9)=   "CB_OM_TARG_DBG"
      Tab(0).Control(10)=   "CB_OM_TARG_REL"
      TabCaption(1)   =   "&MINIEMS"
      Tab(1).ControlCount=   11
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "EDT_MN_REL"
      Tab(1).Control(1)=   "CB_MN_TARG_REL"
      Tab(1).Control(2)=   "CB_MN_TARG_DBG"
      Tab(1).Control(3)=   "EDT_MN_DBG"
      Tab(1).Control(4)=   "CHK_MN_REL"
      Tab(1).Control(5)=   "CHK_MN_DBG"
      Tab(1).Control(6)=   "CB_MN_SOURCE"
      Tab(1).Control(7)=   "EDT_MN_SOURCE"
      Tab(1).Control(8)=   "LBL_MN_RELTARGET"
      Tab(1).Control(9)=   "LBL_MN_DBGTARGET"
      Tab(1).Control(10)=   "LBL_MN_SOURCE"
      Begin VB.TextBox EDT_MN_REL 
         Height          =   375
         Left            =   -73200
         TabIndex        =   17
         Top             =   2300
         Width           =   2700
      End
      Begin VB.CommandButton CB_MN_TARG_REL 
         Caption         =   "..."
         Height          =   375
         Left            =   -70400
         TabIndex        =   18
         Top             =   2300
         Width           =   375
      End
      Begin VB.CommandButton CB_MN_TARG_DBG 
         Caption         =   "..."
         Height          =   375
         Left            =   -70400
         TabIndex        =   15
         Top             =   1550
         Width           =   375
      End
      Begin VB.TextBox EDT_MN_DBG 
         Height          =   375
         Left            =   -73200
         TabIndex        =   14
         Top             =   1550
         Width           =   2700
      End
      Begin VB.CheckBox CHK_MN_REL 
         Caption         =   "&Release"
         Height          =   250
         Left            =   -74760
         TabIndex        =   16
         Top             =   2280
         Width           =   950
      End
      Begin VB.CheckBox CHK_MN_DBG 
         Caption         =   "&Debug"
         Height          =   250
         Left            =   -74760
         TabIndex        =   13
         Top             =   1560
         Width           =   950
      End
      Begin VB.CommandButton CB_MN_SOURCE 
         Caption         =   "..."
         Height          =   375
         Left            =   -70400
         TabIndex        =   12
         Top             =   720
         Width           =   375
      End
      Begin VB.TextBox EDT_MN_SOURCE 
         Height          =   375
         Left            =   -74000
         TabIndex        =   11
         Top             =   720
         Width           =   3500
      End
      Begin VB.CommandButton CB_OM_TARG_REL 
         Caption         =   "..."
         Height          =   375
         Left            =   4596
         TabIndex        =   9
         Top             =   2280
         Width           =   375
      End
      Begin VB.CommandButton CB_OM_TARG_DBG 
         Caption         =   "..."
         Height          =   375
         Left            =   4600
         TabIndex        =   6
         Top             =   1550
         Width           =   375
      End
      Begin VB.TextBox EDT_OM_REL 
         Height          =   375
         Left            =   1800
         TabIndex        =   8
         Top             =   2300
         Width           =   2700
      End
      Begin VB.TextBox EDT_OM_DBG 
         Height          =   375
         Left            =   1800
         TabIndex        =   5
         Top             =   1550
         Width           =   2700
      End
      Begin VB.CheckBox CHK_OM_REL 
         Caption         =   "&Release"
         Height          =   250
         Left            =   240
         TabIndex        =   7
         Top             =   2300
         Width           =   950
      End
      Begin VB.CheckBox CHK_OM_DBG 
         Caption         =   "&Debug"
         Height          =   250
         Left            =   240
         TabIndex        =   4
         Top             =   1550
         Width           =   950
      End
      Begin VB.CommandButton CB_OM_SOURCE 
         Caption         =   "..."
         Height          =   375
         Left            =   4600
         TabIndex        =   3
         Top             =   720
         Width           =   375
      End
      Begin VB.TextBox EDT_OM_SOURCE 
         Height          =   375
         Left            =   1000
         TabIndex        =   2
         Top             =   720
         Width           =   3500
      End
      Begin VB.Label LBL_MN_RELTARGET 
         Caption         =   "Target"
         Height          =   255
         Left            =   -73750
         TabIndex        =   34
         Top             =   2300
         Width           =   540
      End
      Begin VB.Label LBL_MN_DBGTARGET 
         Caption         =   "Target"
         Height          =   255
         Left            =   -73750
         TabIndex        =   33
         Top             =   1550
         Width           =   540
      End
      Begin VB.Label LBL_MN_SOURCE 
         Caption         =   "&SOURCE"
         Height          =   260
         Left            =   -74760
         TabIndex        =   10
         Top             =   840
         Width           =   730
      End
      Begin VB.Label LBL_OM_RELTARGET 
         Caption         =   "Target"
         Height          =   255
         Left            =   1250
         TabIndex        =   32
         Top             =   2300
         Width           =   540
      End
      Begin VB.Label LBL_OM_DBGTARGET 
         Caption         =   "Target"
         Height          =   255
         Left            =   1250
         TabIndex        =   31
         Top             =   1550
         Width           =   540
      End
      Begin VB.Label LBL_OM_SOURCE 
         Caption         =   "&SOURCE"
         Height          =   260
         Left            =   240
         TabIndex        =   1
         Top             =   840
         Width           =   730
      End
   End
   Begin VB.Label Label1 
      Caption         =   "BS     Libraries"
      Height          =   372
      Left            =   240
      TabIndex        =   38
      Top             =   3840
      Width           =   732
   End
   Begin ComctlLib.Toolbar Toolbar1 
      Height          =   300
      Left            =   4200
      TabIndex        =   28
      Top             =   4920
      Visible         =   0   'False
      Width           =   396
      _Version        =   65536
      _ExtentX        =   699
      _ExtentY        =   529
      _StockProps     =   96
      ImageList       =   "ImageList1"
      ButtonHeight    =   445
      NumButtons      =   1
      i1              =   "Form1.frx":0000
      AlignSet        =   -1  'True
   End
   Begin ComctlLib.ImageList ImageList1 
      Left            =   4200
      Top             =   3360
      _Version        =   65536
      _ExtentX        =   804
      _ExtentY        =   804
      _StockProps     =   1
      BackColor       =   -2147483643
      ImageWidth      =   17
      ImageHeight     =   15
      MaskColor       =   16777215
      NumImages       =   1
      i1              =   "Form1.frx":01AF
   End
   Begin MSComDlg.CommonDialog OpenLog 
      Left            =   4200
      Top             =   3960
      _Version        =   65536
      _ExtentX        =   677
      _ExtentY        =   677
      _StockProps     =   0
      CancelError     =   -1  'True
      DialogTitle     =   "Log File Name"
      FileName        =   "*.log"
      Filter          =   "*.log"
   End
   Begin VB.Label LBL_FORM1_LOG 
      Caption         =   "&Log File"
      Height          =   252
      Left            =   240
      TabIndex        =   37
      Top             =   4920
      Width           =   612
   End
   Begin VB.Label LBL_FORM1_MSVC 
      Caption         =   "MS&VC"
      Height          =   252
      Left            =   240
      TabIndex        =   36
      Top             =   4440
      Width           =   612
   End
   Begin VB.Label LBL_FORM1_BS 
      Caption         =   "BS Includes "
      Height          =   372
      Left            =   240
      TabIndex        =   35
      Top             =   3360
      Width           =   732
   End
End
Attribute VB_Name = "Form1"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit
Public strPath As String
Public bOK As Boolean
Public style As Integer
Public title As String
Public strEditor As String
Public strConfigFile As String

Private Sub CB_FORM1_BS_Click()
    FRM_PATH.Caption = "BS Includes Path"
    FRM_PATH.Show 1
    If bOK Then EDT_FORM1_BS.Text = strPath
End Sub


Private Sub CB_FORM1_BSLIBS_Click()
    FRM_PATH.Caption = "BS Static Libraries Path"
    FRM_PATH.Show 1
    If bOK Then EDT_FORM1_BSLIBS.Text = strPath
End Sub


'TODO : Can't we get MSVC location from registry
'
Private Sub CB_FORM1_BUILD_Click()

    ''Before doing the following checks, please save the options
    SaveOptions

    If CHK_MN_DBG.Value = vbUnchecked And CHK_MN_REL.Value = vbUnchecked Then
       If CHK_OM_DBG.Value = vbUnchecked And CHK_OM_REL.Value = vbUnchecked Then
           MsgBox "No Target Specified", style, title
           Exit Sub
       End If
    End If
    
    If Not trimAllFields() Then GoTo wrapup
    
    If Not IsOMExisting() Then GoTo wrapup
    
    If Not IsMSVCExisting() Then GoTo wrapup
    
    If CHK_MN_DBG.Value = vbChecked Or CHK_MN_REL.Value = vbChecked Then
      If Not IsBSExisting() Then GoTo wrapup
      If Not IsBSLibsExisting() Then GoTo wrapup
      If Not IsMnEmsExisting() Then GoTo wrapup
    End If
    
    If CHK_OM_DBG.Value Then
       If Not checkOMDbgTarget(True) Then GoTo wrapup
    End If
    
    If CHK_OM_REL.Value Then
       If Not checkOMRelTarget(True) Then GoTo wrapup
    End If
    
    If CHK_MN_DBG.Value Then
       If Not CHK_OM_DBG.Value Then
          If Not checkOMDbgTarget(False) Then GoTo wrapup
       End If
       If Not checkMnEmsDbgTarget(True) Then GoTo wrapup
    End If
    
    If CHK_MN_REL.Value Then
       If Not CHK_OM_REL.Value Then
          If Not checkOMRelTarget(False) Then GoTo wrapup
       End If
       If Not checkMnEmsRelTarget(True) Then GoTo wrapup
    End If
    
    If Not checkClashes() Then GoTo wrapup
    
    If Not checkLogFile() Then GoTo wrapup
    
    Dim RetID
    Dim strCmd
    
    If CHK_MN_DBG.Value = vbChecked Or CHK_MN_REL.Value = vbChecked Then
       If CHK_OM_DBG.Value = vbChecked Or CHK_OM_REL.Value = vbChecked Then
          build_OM_Miniems
       Else
          buildMiniEms
       End If
    ElseIf CHK_OM_DBG.Value = vbChecked Or CHK_OM_REL.Value = vbChecked Then
         buildOM
    End If
    
wrapup:

End Sub

Private Sub CB_FORM1_LOG_Click()
'    FRM_PATH.Show 1
'    If bOK Then EDT_FORM1_LOG.Text = strPath + "\build.log"
      
     OpenLog.DialogTitle = "Log File"
     OpenLog.Filter = "Log Files (*.LOG)|*.log|All Files (*.*)|*.*"
     OpenLog.Flags = cdlOFNHideReadOnly
     On Error Resume Next
     OpenLog.ShowOpen
     If Err = cdlCancel Then
       Err.Clear
       Exit Sub
     End If
     EDT_FORM1_LOG.Text = OpenLog.filename

     
End Sub

Private Sub CB_FORM1_MSVC_Click()
    FRM_PATH.Caption = "MSVC"
    FRM_PATH.Show 1
    If bOK Then EDT_FORM1_MSVC.Text = strPath
End Sub


Private Sub CB_MN_SOURCE_Click()
    FRM_PATH.Caption = "MINIEMS Source"
    FRM_PATH.Show 1
    If bOK Then EDT_MN_SOURCE.Text = strPath
End Sub


Private Sub CB_MN_TARG_DBG_Click()
   FRM_PATH.Caption = "MINIEMS Debug Target"
    FRM_PATH.Show 1
    If bOK Then EDT_MN_DBG.Text = strPath
End Sub


Private Sub CB_MN_TARG_REL_Click()
    FRM_PATH.Caption = "MINIEMS Release Target"
    FRM_PATH.Show 1
    If bOK Then EDT_MN_REL.Text = strPath
End Sub


Private Sub CB_OM_SOURCE_Click()
    FRM_PATH.Caption = "OM Source"
    FRM_PATH.Show 1
    If bOK Then EDT_OM_SOURCE.Text = strPath
      
End Sub

Private Sub Check1_Click()
    If LBL_OM_DBGTARGET.Visible Then
       LBL_OM_DBGTARGET.Visible = False
       EDT_OM_DBG.Visible = False
       CB_OM_TARG_DBG.Visible = False
    Else
       LBL_OM_DBGTARGET.Visible = True
       EDT_OM_DBG.Visible = True
       CB_OM_TARG_DBG.Visible = True
    End If
End Sub

Private Sub Command2_Click()
    FRM_PATH.Show 1
    EDT_OM_DBG.Text = strPath
End Sub


Private Sub Command3_Click()
    FRM_PATH.Show 1
    EDT_OM_REL.Text = strPath
End Sub

Private Sub Check2_Click()
    If LBL_OM_RELTARGET.Visible Then
       LBL_OM_RELTARGET.Visible = False
       EDT_OM_REL.Visible = False
       CB_OM_TARG_REL.Visible = False
    Else
       LBL_OM_RELTARGET.Visible = True
       EDT_OM_REL.Visible = True
       CB_OM_TARG_REL.Visible = True
    End If

End Sub

Private Sub CB_OM_TARG_DBG_Click()
    FRM_PATH.Caption = "OM Debug Target"
    FRM_PATH.Show 1
    If bOK Then EDT_OM_DBG.Text = strPath
End Sub

Private Sub CB_OM_TARG_REL_Click()
    FRM_PATH.Caption = "OM Release Target"
    FRM_PATH.Show 1
    If bOK Then EDT_OM_REL.Text = strPath

End Sub


Private Sub Command8_Click()

End Sub


Private Sub CB_OPEN_LOG_Click()

End Sub


Private Sub CHK_MN_DBG_Click()

On Error Resume Next

   If CHK_MN_DBG.Value = vbChecked Then
   
       EDT_MN_DBG.SetFocus
       
      
      If Err.Number <> 0 Then
         Err.Clear
      End If
       
   End If
End Sub

Private Sub CHK_MN_REL_Click()

On Error Resume Next

   If CHK_MN_REL.Value = vbChecked Then
   
      EDT_MN_REL.SetFocus
      
      If Err.Number <> 0 Then
         Err.Clear
      End If
       
   End If
End Sub


Private Sub CHK_OM_DBG_Click()
On Error Resume Next

   If CHK_OM_DBG.Value = vbChecked Then
   
      EDT_OM_DBG.SetFocus
      
      If Err.Number <> 0 Then
         Err.Clear
      End If
      
   End If
End Sub

Private Sub CHK_OM_REL_Click()

On Error Resume Next

   If CHK_OM_REL.Value = vbChecked Then
   
      EDT_OM_REL.SetFocus
      
      If Err.Number <> 0 Then
         Err.Clear
      End If
      
   End If

End Sub


Private Sub Command9_Click()
   SaveOptions
   Unload Me            ' Unload this form.
End Sub


Private Sub Text2_Change()

End Sub


Private Sub Text3_Change()

End Sub


Private Sub Label2_Click()

End Sub


Private Sub Label4_Click()

End Sub


Private Sub Label7_Click()

End Sub


Private Sub ED_FORM1_BS_Change()

End Sub


Private Sub EDT_FORM1_LOG_Change()
   Dim strTemp As String
   Dim iNum As Integer
   strTemp = EDT_FORM1_LOG.Text
   strTemp = Trim(strTemp)
   
   Append.Visible = False
   Toolbar1.Visible = False
   
   If "" = strTemp Then Exit Sub
   
   On Error Resume Next
   iNum = Len(Dir(strTemp))
   If Err Then
     Err.Clear
     Exit Sub
   End If
   
   If 0 = iNum Then Exit Sub
   
   If vbDirectory And GetAttr(strTemp) Then Exit Sub
   
   If vbSystem And GetAttr(strTemp) Then Exit Sub
   
   Append.Visible = True
   Toolbar1.Visible = True
End Sub

Private Sub Form_Load()
   
    LoadOptions
    
    style = vbOKOnly + vbExclamation
    title = "BUILD"
    strEditor = "MSVC"
   
    CHK_OM_DBG.Visible = True
    CHK_OM_REL.Visible = True
    LBL_OM_SOURCE.Visible = True
    CHK_MN_DBG.Visible = False
    CHK_MN_REL.Visible = False
    LBL_MN_SOURCE.Visible = False
    
    Form1.Left = Screen.Width / 2 - Form1.Width / 2
    Form1.Top = Screen.Height / 2 - Form1.Height / 2

End Sub





Public Function IsDirExisting(strSrc As String) As Boolean

    IsDirExisting = False
    
    If "" = strSrc Then
       GoTo wrapup
    End If
    
    Dim strCurDir As String
    
    strCurDir = CurDir()
    
    On Error Resume Next
    ChDir strSrc
    If Err.Number <> 0 Then
       Err.Clear
       ChDir strCurDir
    Else
       ChDir strCurDir
       IsDirExisting = True
    End If
    
wrapup:
    
End Function



Public Function IsBSExisting() As Boolean
    
    IsBSExisting = False
    Dim Result As Boolean
    Dim strTemp As String
    
    ''Check BSPMATH
    If EDT_FORM1_BS.Text = "" Then
       MsgBox "Specify BSPMATH location", style, title
       GoTo wrapup
    End If
    
    Result = IsDirExisting(EDT_FORM1_BS.Text)
    If Not Result Then
       strTemp = "BSPMATH Includes location" + Chr(13) + EDT_FORM1_BS.Text + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
    
    
    IsBSExisting = True
    
wrapup:
    If Not IsBSExisting Then
       EDT_FORM1_BS.SetFocus
    End If
End Function

Public Function IsOMExisting()
    
    IsOMExisting = False
    Dim Result As Boolean
    Dim strTemp As String
    
    If EDT_OM_SOURCE.Text = "" Then
       MsgBox "Specify OM location", style, title
       GoTo wrapup
    End If
    
    Result = IsDirExisting(EDT_OM_SOURCE.Text)
    If Not Result Then
       strTemp = "OM Source Location" + Chr(13) + EDT_OM_SOURCE.Text + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
    IsOMExisting = True
    
wrapup:
   If Not IsOMExisting Then
      EDT_OM_SOURCE.SetFocus
   End If
       
End Function

Public Function IsMSVCExisting() As Boolean

    Dim Result As Boolean
    Dim strTemp As String

    IsMSVCExisting = False
    
    If EDT_FORM1_MSVC.Text = "" Then
       MsgBox "Specify MSVC location", style, title
       GoTo wrapup
    End If
    
    Result = IsDirExisting(EDT_FORM1_MSVC.Text)
    If Not Result Then
       strTemp = "MSVC Source Location" + Chr(13)
       strTemp = strTemp + EDT_FORM1_MSVC.Text + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
    IsMSVCExisting = True
    
wrapup:
    If Not IsMSVCExisting Then
       EDT_FORM1_MSVC.SetFocus
    End If
   
End Function

Public Function CreateDir(strDir As String) As Boolean

   CreateDir = False
   If "" = strDir Then GoTo wrapup
   
   On Error Resume Next
   MkDir strDir
   If Err.Number <> 0 Then
      Err.Clear
   Else
      CreateDir = True
   End If
   
wrapup:
   
End Function

Public Function checkOMDbgTarget(bFlag As Boolean) As Boolean
   
' if bFlag is True try to create OM debug target directory

   Dim sT As String
   
   checkOMDbgTarget = False
   
   If "" = EDT_OM_DBG.Text Then
      MsgBox "Specfiy OM Debug Target", style, title
      GoTo wrapup
   End If
   
   If IsDirExisting(EDT_OM_DBG.Text) Then
      checkOMDbgTarget = True
   Else
      If bFlag Then
         If CreateDir(EDT_OM_DBG.Text) Then
            checkOMDbgTarget = True
         Else
            sT = "Can't create OM Debug Target" + Chr(13)
            sT = sT + EDT_OM_DBG.Text
            MsgBox sT, style, title
         End If
      Else
         sT = "OM Debug Target" + Chr(13)
         sT = sT + EDT_OM_DBG.Text + " not existing"
         MsgBox sT, style, title
      End If
   End If

wrapup:
   If Not checkOMDbgTarget Then
      EDT_OM_DBG.SetFocus
   End If

End Function

Public Function checkClashes() As Boolean
'TODO: We can perform these checks on all srting combinations

   checkClashes = False
   Dim sT As String
   
   If CHK_OM_DBG.Value = vbChecked Then
      If 0 = StrComp(EDT_OM_SOURCE.Text, EDT_OM_DBG.Text, 1) Then
        sT = "OM src and Debug target"
        GoTo wrapup
      End If
   End If
   
   If CHK_OM_REL.Value = vbChecked Then
     If 0 = StrComp(EDT_OM_SOURCE.Text, EDT_OM_REL.Text, 1) Then
       sT = "OM src and Release target"
       GoTo wrapup
     End If
   End If
  
   If CHK_OM_REL.Value = vbChecked And CHK_OM_DBG.Value = vbChecked Then
      If 0 = StrComp(EDT_OM_DBG.Text, EDT_OM_REL.Text, 1) Then
         sT = "OM Debug and Release targets"
         GoTo wrapup
      End If
   End If
   
   If CHK_MN_DBG.Value = vbChecked Then
      If 0 = StrComp(EDT_MN_SOURCE.Text, EDT_MN_DBG.Text, 1) Then
        sT = "Miniems src and Debug target"
        GoTo wrapup
      End If
   End If
   
   If CHK_MN_REL.Value = vbChecked Then
      If 0 = StrComp(EDT_MN_SOURCE.Text, EDT_MN_REL.Text, 1) Then
        sT = "Miniems src and Release target"
        GoTo wrapup
      End If
   End If
   
   If CHK_MN_DBG.Value = vbChecked And CHK_MN_REL.Value = vbChecked Then
      If 0 = StrComp(EDT_MN_DBG.Text, EDT_MN_REL.Text, 1) Then
        sT = "Miniems Debug and Release targets"
        GoTo wrapup
      End If
   End If
     
   checkClashes = True
   
wrapup:
   If Not checkClashes Then
      sT = sT + " cannot be the same"
      MsgBox sT, style, title
   End If

End Function

Public Function checkOMRelTarget(bFlag As Boolean) As Boolean
' if bFlag is True try to create OM Release target directory

   Dim sT As String
   
   checkOMRelTarget = False
   
   If "" = EDT_OM_REL.Text Then
      MsgBox "Specfiy OM Release Target", style, title
      GoTo wrapup
   End If
   
   If IsDirExisting(EDT_OM_REL.Text) Then
      checkOMRelTarget = True
   Else
      If bFlag Then
         If CreateDir(EDT_OM_REL.Text) Then
            checkOMRelTarget = True
         Else
            sT = "Can't create OM Release Target" + Chr(13)
            sT = sT + EDT_OM_REL.Text
            MsgBox sT, style, title
         End If
      Else
         sT = "OM Release Target" + Chr(13)
         sT = sT + EDT_OM_REL.Text + " not existing"
         MsgBox sT, style, title
      End If
   End If

wrapup:
   If Not checkOMRelTarget Then
      EDT_OM_REL.SetFocus
   End If

End Function

Public Function IsMnEmsExisting() As Boolean
    
    Dim Result As Boolean
    Dim strTemp As String

    IsMnEmsExisting = False
    
    If EDT_MN_SOURCE.Text = "" Then
       MsgBox "Specify MINIEMS location", style, title
       GoTo wrapup
    End If
    
    Result = IsDirExisting(EDT_MN_SOURCE.Text)
    If Not Result Then
       strTemp = "MINIEMS Source Location" + Chr(13)
       strTemp = strTemp + EDT_MN_SOURCE.Text + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
    IsMnEmsExisting = True
    
wrapup:
    If Not IsMnEmsExisting Then
       EDT_MN_SOURCE.SetFocus
    End If

End Function

Public Function checkMnEmsDbgTarget(bFlag As Boolean) As Boolean
' if bFlag is True try to create Miniems debug target directory

   Dim sT As String
   
   checkMnEmsDbgTarget = False
   
   If "" = EDT_MN_DBG.Text Then
      MsgBox "Specfiy Miniems Debug Target", style, title
      GoTo wrapup
   End If
   
   If IsDirExisting(EDT_MN_DBG.Text) Then
      checkMnEmsDbgTarget = True
   Else
      If bFlag Then
         If CreateDir(EDT_MN_DBG.Text) Then
            checkMnEmsDbgTarget = True
         Else
            sT = "Can't create MINIEMS Debug Target" + Chr(13)
            sT = sT + EDT_MN_DBG.Text
            MsgBox sT, style, title
         End If
      Else
         sT = "Miniems Debug Target" + Chr(13)
         sT = sT + EDT_MN_DBG.Text + " not existing"
         MsgBox sT, style, title
      End If
   End If

wrapup:
   If Not checkMnEmsDbgTarget Then
      EDT_MN_DBG.SetFocus
   End If

End Function



Public Function checkMnEmsRelTarget(bFlag As Boolean) As Boolean
' if bFlag is True try to create Miniems Release target directory

   Dim sT As String
   
   checkMnEmsRelTarget = False
   
   If "" = EDT_MN_REL.Text Then
      MsgBox "Specfiy Miniems Release Target", style, title
      GoTo wrapup
   End If
   
   If IsDirExisting(EDT_MN_REL.Text) Then
      checkMnEmsRelTarget = True
   Else
      If bFlag Then
         If CreateDir(EDT_MN_REL.Text) Then
            checkMnEmsRelTarget = True
         Else
            sT = "Can't create MINIEMS Release Target" + Chr(13)
            sT = sT + EDT_MN_REL.Text
            MsgBox sT, style, title
         End If
      Else
         sT = "Miniems Release Target" + Chr(13)
         sT = sT + EDT_MN_REL.Text + " not existing"
         MsgBox sT, style, title
      End If
   End If

wrapup:
   If Not checkMnEmsRelTarget Then
      EDT_MN_REL.SetFocus
   End If

End Function

Public Function buildOM()
   Dim pID
   Dim sCmd
   
   ''TODO: You may get two back slahes here
   sCmd = EDT_OM_SOURCE.Text + "\nt\vb\OMBLD.BAT "
   sCmd = sCmd + EDT_FORM1_MSVC.Text + " "
   sCmd = sCmd + EDT_FORM1_LOG.Text + " "
   sCmd = sCmd + EDT_OM_SOURCE.Text + " "
   
   If CHK_OM_DBG.Value = vbChecked Then
      sCmd = sCmd + EDT_OM_DBG.Text + " "
   Else
      sCmd = sCmd + "NO "
   End If
   
   If CHK_OM_REL.Value = vbChecked Then
      sCmd = sCmd + EDT_OM_REL.Text + " "
   Else
      sCmd = sCmd + "NO "
   End If
   
   ''Execute OM build script
   pID = Shell(sCmd, 1)
   
End Function

Public Function buildMiniEms()

   Dim pID
   Dim sCmd
    
   ''TODO: You may get two back slashes here
''   sCmd = EDT_MN_SOURCE + "\nt\build\log.bat "
   sCmd = EDT_MN_SOURCE + "\nt\build\vb\MNEMSBLD.BAT  "
   
   sCmd = sCmd + EDT_FORM1_MSVC.Text + " "
   sCmd = sCmd + EDT_FORM1_BS.Text + " "
   sCmd = sCmd + EDT_FORM1_BSLIBS.Text + " "
   sCmd = sCmd + EDT_FORM1_LOG.Text + " "
   sCmd = sCmd + EDT_OM_SOURCE.Text + " "
   
   If CHK_MN_DBG.Value = vbChecked Then
      sCmd = sCmd + EDT_OM_DBG.Text + " "
   Else
      sCmd = sCmd + "NO "
   End If
   
   If CHK_MN_REL.Value = vbChecked Then
      sCmd = sCmd + EDT_OM_REL.Text + " "
   Else
      sCmd = sCmd + "NO "
   End If
   
   sCmd = sCmd + EDT_MN_SOURCE.Text + " "
   
   If CHK_MN_DBG.Value = vbChecked Then
      sCmd = sCmd + EDT_MN_DBG.Text + " "
   Else
      sCmd = sCmd + "NO "
   End If
   
   If CHK_MN_REL.Value = vbChecked Then
      sCmd = sCmd + EDT_MN_REL.Text + " "
   Else
      sCmd = sCmd + "NO "
   End If
   
  pID = Shell(sCmd, 1)
   
End Function

Public Function build_OM_Miniems()
   
   Dim pID
   Dim sCmd As String
    
   ''TODO: You may get two back slashes here
   sCmd = EDT_MN_SOURCE + "\nt\build\vb\OM_MNEMS.BAT  "
   
   sCmd = sCmd + EDT_FORM1_MSVC.Text + " "
   sCmd = sCmd + EDT_FORM1_BS.Text + " "
   sCmd = sCmd + EDT_FORM1_BSLIBS.Text + " "
   sCmd = sCmd + EDT_FORM1_LOG.Text + " "
   sCmd = sCmd + EDT_OM_SOURCE.Text + " "
   sCmd = sCmd + EDT_OM_DBG.Text + " "
   sCmd = sCmd + EDT_OM_REL.Text + " "
   sCmd = sCmd + EDT_MN_SOURCE.Text + " "
   sCmd = sCmd + EDT_MN_DBG.Text + " "
   sCmd = sCmd + EDT_MN_REL.Text + " "
   
   If CHK_OM_DBG.Value = vbChecked Then
      sCmd = sCmd + "YES "
   Else
      sCmd = sCmd + "NO "
   End If
   
   If CHK_OM_REL.Value = vbChecked Then
      sCmd = sCmd + "YES "
   Else
      sCmd = sCmd + "NO "
   End If
   
   If CHK_MN_DBG.Value = vbChecked Then
      sCmd = sCmd + "YES "
   Else
      sCmd = sCmd + "NO "
   End If
   
   If CHK_MN_REL.Value = vbChecked Then
      sCmd = sCmd + "YES "
   Else
      sCmd = sCmd + "NO "
   End If
   
   pID = Shell(sCmd, 1)

End Function

Private Sub Option1_Click()

End Sub

Private Sub Image1_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
   If vbKeyLButton = Button Then
      Dim strTemp As String
      Dim iNum As Integer
      Dim pID
      On Error Resume Next
   
      ''Exit if the log file is empty
      If "" = EDT_FORM1_LOG.Text Then
         Exit Sub
      End If
   
      ''Check the existence of file
      strTemp = Trim(EDT_FORM1_LOG.Text)
   
      iNum = Len(Dir(strTemp))
      If Err Then
         MsgBox Error$, 48
         Exit Sub
      End If
   
     ''Try to open
      If 0 = iNum Then
         strTemp = strTemp + Chr(13)
         strTemp = strTemp + "File not found"
         MsgBox strTemp, style, title
      Else
        Dim strCmd As String
        strCmd = Trim(strEditor)
        strCmd = strCmd + "  " + strTemp
        pID = Shell(strCmd, 1)
        If Err Then
           Err.Clear
           strCmd = "notepad " + strTemp
           pID = Shell(strCmd, 1)
        End If
      End If
  ElseIf vbKeyRButton = Button Then
        Dim sP As String
        Dim sD As String
        sP = "Editor to view Log Files"
        sD = strEditor
        strTemp = LTrim(RTrim(UCase(InputBox(sP, title, sD))))
        If Not "" = strTemp Then
           strEditor = strTemp
        End If
  End If
End Sub


Private Sub SSTab1_Click(PreviousTab As Integer)

   If 0 = PreviousTab Then  ''OM Tab
      CHK_OM_DBG.Visible = False
      CHK_OM_REL.Visible = False
      LBL_OM_SOURCE.Visible = False
      CHK_MN_DBG.Visible = True
      CHK_MN_REL.Visible = True
      LBL_MN_SOURCE.Visible = True
   Else  ''MINIEMS Tab
      CHK_OM_DBG.Visible = True
      CHK_OM_REL.Visible = True
      LBL_OM_SOURCE.Visible = True
      CHK_MN_DBG.Visible = False
      CHK_MN_REL.Visible = False
      LBL_MN_SOURCE.Visible = False
   End If
End Sub


Public Function checkLogFile() As Boolean
   
   checkLogFile = False
   Dim sT As String
   Dim Ret As Integer
   Dim replace
   Dim F As Integer
   F = FreeFile
   
   If "" = EDT_FORM1_LOG.Text Then
      sT = "Specify Log File"
      MsgBox sT, style, title
      GoTo wrapup
   End If
   
   ''if the file is not existing, try to create it
   If Not Toolbar1.Visible Then
     Open EDT_FORM1_LOG.Text For Output As F
     sT = "OM - MINIEMS Build Log"
     Write #F, sT
     sT = Now
     Write #F, sT
     Close #F
     EDT_FORM1_LOG_Change
   Else
     If Append.Value = vbChecked Then
        Open EDT_FORM1_LOG.Text For Append As F
     Else
        Open EDT_FORM1_LOG.Text For Output As F
     End If
     sT = "OM - MINIEMS Build Log"
     Write #F, sT
     sT = Now
     Write #F, sT
     Close #F
   
   End If
   
   checkLogFile = True

wrapup:
   If Not checkLogFile Then EDT_FORM1_LOG.SetFocus
 
End Function

Public Function trimAllFields() As Boolean
   
   trimAllFields = True
   
   EDT_OM_SOURCE.Text = Trim(EDT_OM_SOURCE.Text)
   EDT_OM_DBG.Text = Trim(EDT_OM_DBG.Text)
   EDT_OM_REL.Text = Trim(EDT_OM_REL.Text)
   EDT_MN_SOURCE.Text = Trim(EDT_MN_SOURCE.Text)
   EDT_MN_DBG.Text = Trim(EDT_MN_DBG.Text)
   EDT_MN_REL.Text = Trim(EDT_MN_REL.Text)
   EDT_FORM1_BS.Text = Trim(EDT_FORM1_BS.Text)
   EDT_FORM1_BSLIBS.Text = Trim(EDT_FORM1_BSLIBS.Text)
   EDT_FORM1_MSVC.Text = Trim(EDT_FORM1_MSVC.Text)
   EDT_FORM1_LOG.Text = Trim(EDT_FORM1_LOG.Text)
   
End Function

Private Sub Toolbar1_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
   If vbKeyLButton = Button Then
      Dim strTemp As String
      Dim iNum As Integer
      Dim pID
      On Error Resume Next
   
      ''Exit if the log file is empty
      If "" = EDT_FORM1_LOG.Text Then
         Exit Sub
      End If
   
      ''Check the existence of file
      strTemp = Trim(EDT_FORM1_LOG.Text)
   
      iNum = Len(Dir(strTemp))
      If Err Then
         MsgBox Error$, 48
         Exit Sub
      End If
   
     ''Try to open
      If 0 = iNum Then
         strTemp = strTemp + Chr(13)
         strTemp = strTemp + "File not found"
         MsgBox strTemp, style, title
      Else
        Dim strCmd As String
        strCmd = Trim(strEditor)
        strCmd = strCmd + "  " + strTemp
        pID = Shell(strCmd, 1)
        If Err Then
           Err.Clear
           strCmd = "notepad " + strTemp
           pID = Shell(strCmd, 1)
        End If
      End If
  ElseIf vbKeyRButton = Button Then
        Dim sP As String
        Dim sD As String
        sP = "Editor to view Log Files"
        sD = strEditor
        strTemp = LTrim(RTrim(UCase(InputBox(sP, title, sD))))
        If Not "" = strTemp Then
           strEditor = strTemp
        End If
  End If

End Sub





Public Function LoadOptions()
    
    On Error Resume Next
    
    Dim strTemp As String
    Dim bExist As Boolean
    Dim F As Integer
    Dim iTemp As Integer
    
    bExist = False
    F = FreeFile
    
    strConfigFile = App.Path + "\" + App.EXEName + ".INI"
    
    strTemp = Dir(strConfigFile)
    If Err.Number <> 0 Then
        Err.Clear
    End If
        
    If strTemp = App.EXEName + ".INI" Then
        bExist = True
    Else
        bExist = False
    End If
    
    If False = bExist Then
        '' Initialize with default options
        EDT_MN_SOURCE.Text = "C:\MINIEMS"
        EDT_MN_DBG.Text = "C:\MINIEMS\WinDebug"
        EDT_MN_REL.Text = "C:\MINIEMS\WinRel"
        EDT_OM_SOURCE.Text = "C:\OM"
        EDT_OM_DBG.Text = "C:\OM\WinDebug"
        EDT_OM_REL.Text = "C:\OM\WinRel"
    
        EDT_FORM1_BS.Text = "C:\BSPMATH"
        EDT_FORM1_BSLIBS.Text = "Z:\MATH\SRC\UBSPMTH\DEV"
        EDT_FORM1_MSVC.Text = "C:\MSVC20"
        EDT_FORM1_LOG.Text = App.Path + "\" + App.EXEName + ".Log"
        
        CHK_OM_DBG.Value = vbChecked
        CHK_OM_REL.Value = vbChecked
        CHK_MN_DBG.Value = vbChecked
        CHK_MN_REL.Value = vbChecked
        Append.Value = vbUnchecked
        
    Else
        Open strConfigFile For Input Access Read As #F
        
        Input #F, strTemp
          EDT_MN_SOURCE.Text = strTemp
          
        Input #F, strTemp
          EDT_MN_DBG.Text = strTemp
          
        Input #F, strTemp
          EDT_MN_REL.Text = strTemp
          
        Input #F, strTemp
          EDT_OM_SOURCE.Text = strTemp
          
        Input #F, strTemp
          EDT_OM_DBG.Text = strTemp
          
        Input #F, strTemp
          EDT_OM_REL.Text = strTemp
          
        Input #F, strTemp
          EDT_FORM1_BS.Text = strTemp
          
        Input #F, strTemp
          EDT_FORM1_BSLIBS.Text = strTemp
          
        Input #F, strTemp
          EDT_FORM1_MSVC.Text = strTemp
          
        Input #F, strTemp
          EDT_FORM1_LOG.Text = strTemp
          
        Input #F, iTemp
          CHK_OM_DBG.Value = iTemp
          
        Input #F, iTemp
          CHK_OM_REL.Value = iTemp
    
        Input #F, iTemp
           CHK_MN_DBG.Value = iTemp
    
        Input #F, iTemp
           CHK_MN_REL.Value = iTemp
           
        Input #F, iTemp
           Append.Value = iTemp
        
        Close #F
    End If
    
    
End Function

Public Function SaveOptions()
    On Error Resume Next
    
    Dim strTemp As String
    Dim bExist As Boolean
    Dim F As Integer
    Dim sT As String
    
    F = FreeFile
    bExist = False
    
    strConfigFile = App.Path + "\" + App.EXEName + ".INI"
    
    ''Create/Open configuration file
    Open strConfigFile For Output As F
      
    Write #F, EDT_MN_SOURCE.Text
    Write #F, EDT_MN_DBG.Text
    Write #F, EDT_MN_REL.Text
    Write #F, EDT_OM_SOURCE.Text
    Write #F, EDT_OM_DBG.Text
    Write #F, EDT_OM_REL.Text
    Write #F, EDT_FORM1_BS.Text
    Write #F, EDT_FORM1_BSLIBS.Text
    Write #F, EDT_FORM1_MSVC.Text
    Write #F, EDT_FORM1_LOG.Text
    Write #F, CHK_OM_DBG.Value
    Write #F, CHK_OM_REL.Value
    Write #F, CHK_MN_DBG.Value
    Write #F, CHK_MN_REL.Value
    Write #F, Append.Value
    
    Close #F

End Function

Public Function IsBSLibsExisting()
   
    On Error Resume Next
    
    Dim Result As Boolean
    Dim strTemp As String
    Dim strPath As String
    Dim strSlash As String
    Dim strDir As String
     
    IsBSLibsExisting = False
    
    ''Check BSPMATH Libraries
    If EDT_FORM1_BSLIBS.Text = "" Then
       MsgBox "Specify BSPMATH Static Libraries location", style, title
       GoTo wrapup
    End If
    
    Result = IsDirExisting(EDT_FORM1_BSLIBS.Text)
    If Not Result Then
       strTemp = "BSPMATH Libraries location" + Chr(13) + EDT_FORM1_BSLIBS.Text + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
    '' Check for slash at the end of the text field
    strSlash = Right(EDT_FORM1_BSLIBS.Text, 1)
    If "\" = strSlash Then
       strDir = EDT_FORM1_BSLIBS.Text
    Else
       strDir = EDT_FORM1_BSLIBS.Text + "\"
    End If
    
    strPath = strDir + "UBSPM_EM.LIB"
    Result = IsFileExisting(strPath)
    If Not Result Then
       strTemp = strPath + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
    strPath = strDir + "UBSPM_MA.LIB"
    Result = IsFileExisting(strPath)
    If Not Result Then
       strTemp = strPath + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
    strPath = strDir + "UBSPM_MD.LIB"
    Result = IsFileExisting(strPath)
    If Not Result Then
       strTemp = strPath + " not existing"
       MsgBox strTemp, style, title
       GoTo wrapup
    End If
    
   
    
    strTemp = Dir()
    If Err.Number <> 0 Then
        Err.Clear
    End If
     
    
    IsBSLibsExisting = True
    
wrapup:
    If Not IsBSLibsExisting Then
       EDT_FORM1_BSLIBS.SetFocus
    End If
End Function

Public Function IsFileExisting(strSrc As String) As Boolean

   IsFileExisting = False
   On Error Resume Next
   
   Dim strTemp As String
   
   strTemp = Dir(strSrc)
   If Err.Number <> 0 Then
      Err.Clear
   End If
 
   If "" = strTemp Then
      IsFileExisting = False
   Else
      IsFileExisting = True
   End If
  
wrapup:

End Function
