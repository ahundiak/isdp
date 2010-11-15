
#include "windows.h"
#ifndef WIN16
        #define WIN32   1       /* placed because RC can't pass in C_DEFINES*/
    #include <commdlg.h>
#endif

#ifdef WIN16
#include "drivinit.h"
#endif

//typedef  int            HFILE          ;

#ifdef WIN32
#define GET_EM_SETSEL_MPS(iStart, iEnd) (UINT)(iStart), (LONG)(iEnd)
#define GET_WM_COMMAND_CMD(wp, lp)      HIWORD(wp)
#define GET_WM_COMMAND_HWND(wp, lp)     (HWND)(lp)
#define GET_WM_COMMAND_MPS(id, hwnd, cmd) (UINT)MAKELONG(id, cmd), (LONG)(hwnd)
#define GET_EM_SETSEL_MPS(iStart, iEnd) (UINT)(iStart), (LONG)(iEnd)
#define GET_WM_MDIACTIVATE_FACTIVATE(hwnd, wp, lp)  (lp == (LONG)hwnd)
#else
#define GET_EM_SETSEL_MPS(iStart, iEnd) 0, MAKELONG(iStart, iEnd)
#define GET_WM_COMMAND_CMD(wp, lp)      HIWORD(lp)
#define GET_WM_COMMAND_HWND(wp, lp)     (HWND)LOWORD(lp)
#define GET_WM_COMMAND_MPS(id, hwnd, cmd) (UINT)(id), MAKELONG(hwnd, cmd)
#define GET_EM_SETSEL_MPS(iStart, iEnd) 0, MAKELONG(iStart, iEnd)
#define GET_WM_MDIACTIVATE_FACTIVATE(hwnd, wp, lp)  (BOOL)(wp)
#endif

#define WINDOWMENU  3   /* position of window menu               */
#define SHORTMENU   2   /* position of short version window menu */

#define DEFFILESEARCH   (LPSTR) "*.TXT"

#ifdef RC_INVOKED
#define ID(id) id
#else
#define ID(id) MAKEINTRESOURCE(id)
#endif

/* edit control identifier */
#define ID_EDIT 0xCAC

/* resource ID's */
#define RISsql  ID(1)
//#define IDMULTIPAD2 ID(3)
#define IDNOTE      ID(2)

/* Window word values for child windows */
#define GWL_HWNDEDIT    0
#define GWW_CHANGED     4
#define GWL_WORDWRAP    6
#define GWW_UNTITLED    10
#define CBWNDEXTRA      12

/* menu ID's */
#define IDM_FILENEW     1001
#define IDM_FILEOPEN    1002
#define IDM_FILESAVE    1003
#define IDM_FILESAVEAS  1004
#define IDM_FILEPRINT   1005
#define IDM_FILEEXIT    1006
#define IDM_FILEABOUT   1007
#define IDM_FILESETUP   1008
#define IDM_FILEMENU    1009

#define IDM_EDITUNDO    2001
#define IDM_EDITCUT     2002
#define IDM_EDITCOPY    2003
#define IDM_EDITPASTE   2004
#define IDM_EDITCLEAR   2005
#define IDM_EDITSELECT  2006
#define IDM_EDITTIME    2007
#define IDM_EDITWRAP    2008
#define IDM_EDITFONT    2009
#define IDM_EDITFIRST   IDM_EDITUNDO
#define IDM_EDITLAST    IDM_EDITFONT

#define IDM_SEARCHFIND  3001
#define IDM_SEARCHNEXT  3002
#define IDM_SEARCHPREV  3003
#define IDM_SEARCHFIRST IDM_SEARCHFIND
#define IDM_SEARCHLAST  IDM_SEARCHPREV

#define IDM_WINDOWTILE  4001
#define IDM_WINDOWCASCADE 4002
#define IDM_WINDOWCLOSEALL  4003
#define IDM_WINDOWICONS 4004

#define IDM_WINDOWCHILD 4100

#define IDM_HELPHELP    5001
#define IDM_HELPABOUT   5002
#define IDM_HELPSPOT    5003

#define IDD_FILEOPEN    ID(200)
#define IDD_FILENAME    201
#define IDD_FILES       202
#define IDD_PATH        203
#define IDD_DIRS        204

/* dialog ids */
#define IDD_ABOUT       ID(300)

#define IDD_FIND        ID(400)
#define IDD_SEARCH      401
#define IDD_PREV        402
#define IDD_NEXT        IDOK
#define IDD_CASE        403

#define IDD_SAVEAS      ID(500)
#define IDD_SAVEFROM    501
#define IDD_SAVETO      502

#define IDD_PRINT       ID(600)
#define IDD_PRINTDEVICE 601
#define IDD_PRINTPORT   602
#define IDD_PRINTTITLE  603

#define IDD_FONT        ID(700)
#define IDD_FACES       701
#define IDD_SIZES       702
#define IDD_BOLD        703
#define IDD_ITALIC      704
#define IDD_FONTTITLE   705

/* strings */
#define IDS_CANTOPEN    1
#define IDS_CANTREAD    2
#define IDS_CANTCREATE  3
#define IDS_CANTWRITE   4
#define IDS_ILLFNM      5
#define IDS_ADDEXT      6
#define IDS_CLOSESAVE   7
#define IDS_CANTFIND    8
#define IDS_HELPNOTAVAIL 9

#define IDS_CLIENTTITLE 16
#define IDS_UNTITLED    17
#define IDS_APPNAME     18

#define IDS_PRINTJOB    24
#define IDS_PRINTERROR  25

/* attribute flags for DlgDirList */
#define ATTR_DIRS       0xC010          /* find drives and directories */
#define ATTR_FILES      0x0000          /* find ordinary files         */
#define PROP_FILENAME   szPropertyName  /* name of property for dialog */

/*
 *  External variable declarations
 */
extern HANDLE hInst;            /* application instance handle            */
extern HANDLE hAccel;           /* resource handle of accelerators        */
extern HWND hwndFrame;          /* main window handle                     */
extern HWND hwndMDIClient;      /* handle of MDI Client window            */
extern HWND hwndActive;         /* handle of current active MDI child     */
extern HWND hwndActiveEdit;     /* handle of edit control in active child */
extern LONG styleDefault;       /* default child creation state           */
extern CHAR szChild[];          /* class of child                         */
extern CHAR szSearch[];         /* search string                          */
extern CHAR *szDriver;          /* name of printer driver                 */
extern CHAR szPropertyName[];   /* filename property for dialog box       */
extern INT iPrinter;            /* level of printing capability           */
extern BOOL fCase;              /* searches case sensitive                */
extern WORD cFonts;             /* number of fonts enumerated             */

/*  externally declared functions
 */
extern BOOL APIENTRY InitializeApplication(VOID);
extern BOOL APIENTRY InitializeInstance(LPSTR,INT);
extern BOOL APIENTRY AboutDlgProc(HWND,UINT,UINT,LONG);
extern HWND APIENTRY AddFile(CHAR *);
extern INT APIENTRY _LoadBuffer(CHAR *, HINSTANCE);
extern VOID APIENTRY MyReadFile(HWND);
extern VOID APIENTRY SaveFile(HWND);
extern BOOL APIENTRY ChangeFile(HWND);
extern INT APIENTRY LoadFile(HWND, CHAR *);
extern VOID APIENTRY PrintFile(HWND);
extern BOOL APIENTRY GetInitializationData(HWND);
extern SHORT MPError(HWND,WORD,WORD, char *);
extern VOID APIENTRY Find(VOID);
extern VOID APIENTRY FindNext(VOID);
extern VOID APIENTRY FindPrev(VOID);
extern LONG APIENTRY MPFrameWndProc(HWND,UINT,UINT,LONG);
extern LONG APIENTRY MPMDIChildWndProc(HWND,UINT,UINT,LONG);
extern HDC APIENTRY GetPrinterDC(BOOL);
extern VOID NEAR PASCAL SetSaveFrom (HWND, PSTR);
extern BOOL NEAR PASCAL RealSlowCompare (PSTR, PSTR);
extern VOID APIENTRY FindPrev (VOID);
extern VOID APIENTRY FindNext (VOID);
extern BOOL NEAR PASCAL IsWild (PSTR);
extern VOID NEAR PASCAL SelectFile (HWND);
extern VOID NEAR PASCAL Local_FindText ( INT );

typedef struct _gui_globals
{
   char szAppName[80];
   char szTitle[80];
   HICON hIcon;
   HCURSOR hCursor ;
   int argc;
   char **argv;
   HWND hIntro;
   DWORD ScreenConfig ;
   HMENU hMenu ;
   char ActiveSchema[20] ;
   int NumberOfSchemas ;
   char **ArrayOfSchemas ;
   int FirstFetch ;
   int LastBuffer ;
   char HistoryFile[_MAX_FNAME+1] ;
   HANDLE CommandBoxHandle ;
   DWORD MDIstyle ;
   HANDLE ResultBoxHandle ;
   int  NextResultBoxNumber ;
   int  LabelEnable ;
} gui_globals ;

extern gui_globals gui ;

