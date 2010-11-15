/***************************************************************************
 *                                                                         *
 *  MODULE      : gcomdi.c                                                 * 
 *  DESCRIPTION : Support for mdi application                              *
 *                                                                         *
 *                                                                         *
 *  FUNCTIONS   : InitializeApplication() - Sets up Class data structure   *
 *                                          and registers window class.    *
 *                                                                         *
 *                InitializeInstance ()   - Does a per-instance initial-   *
 *                                          ization. Creates               *
 *                                          the "frame" and MDI client.    *
 *                                                                         *
 ***************************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <stdio.h>
#include "rissql.h"
#include "ressql.h"

#define sqlmdi_c
#include "sql.prt"
#include "sqlmdi.prt"

CHAR szFrame[] = "mpframe";   /* Class name for "frame" window */
CHAR szChild[] = "mpchild";   /* Class name for MDI window     */

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : InitializeApplication ()                                   *
 *                                                                          *
 *  PURPOSE    : Sets up the class data structures and does a one-time      *
 *               initialization of the app by registering the window classes*
 *                                                                          *
 *  RETURNS    : TRUE  - If RegisterClass() was successful for both classes.*
 *               FALSE - otherwise.                                         *
 *                                                                          *
 ****************************************************************************/

BOOL APIENTRY InitializeApplication()
{
    WNDCLASS    wc;

    /* Register the frame class */
    wc.style         = 0 ;
    wc.lpfnWndProc   = (WNDPROC) MPFrameWndProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hInst;
    wc.hIcon         = LoadIcon(hInst,MAKEINTRESOURCE(IDI_SQL));
    wc.hCursor       = LoadCursor(NULL,IDC_ARROW);
    wc.hbrBackground = (HBRUSH) (COLOR_APPWORKSPACE+1);
    wc.lpszMenuName  = RISsql ;
    wc.lpszClassName = szFrame;

    if (!RegisterClass (&wc) )
        return FALSE;

    /* Register the MDI child class */
    wc.style         = 0 ;
    wc.lpfnWndProc   = (WNDPROC) MPMDIChildWndProc;
    wc.hIcon         = LoadIcon(hInst,MAKEINTRESOURCE(IDI_SQL));
    wc.lpszMenuName  = NULL;
    wc.cbWndExtra    = CBWNDEXTRA;
    wc.lpszClassName = szChild;

    if (!RegisterClass(&wc))
        return FALSE;

    return TRUE;

}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : InitializeInstance ()                                      *
 *                                                                          *
 *  PURPOSE    : Performs a per-instance initialization. It                 *
 *               also creates the frame and an MDI window.                  *
 *                                                                          *
 *  RETURNS    : TRUE  - If initialization was successful.                  *
 *               FALSE - otherwise.                                         *
 *                                                                          *
 ****************************************************************************/
BOOL APIENTRY InitializeInstance(LPSTR lpCmdLine, INT nCmdShow)
{
    extern HWND  hwndMDIClient;
    CHAR         sz[80], *pCmdLine;
    HDC          hdc;
    HMENU        hmenu;

    /* Get the base window title */
    LoadString (hInst, IDS_APPNAME, sz, sizeof(sz));

    /* Create the frame */
    hwndFrame = CreateWindow (szFrame,
                              sz,
                              WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
                              CW_USEDEFAULT,
                              0,
                              CW_USEDEFAULT,
                              0,
                              NULL,
                              NULL,
                              hInst,
                              NULL);

    LoadMenu(hInst, MAKEINTRESOURCE(RISsql)) ;                              

    if ((!hwndFrame) || (!hwndMDIClient))
        return FALSE;

    /* Load main menu accelerators */
    /*
    if (!(hAccel = LoadAccelerators (hInst, RISsql)))
        return FALSE;
        */

    /* Display the frame window */
    ShowWindow (hwndFrame, nCmdShow);
    UpdateWindow (hwndFrame);

    /* If the command line string is empty, nullify the pointer to it 
    ** else copy command line into our data segment 
    */
    if ( lpCmdLine && !(*lpCmdLine))
             pCmdLine = NULL;
    else {
        pCmdLine = (CHAR *) LocalAlloc(LPTR, lstrlen(lpCmdLine) + 1);
        if (pCmdLine)
           lstrcpy(pCmdLine, lpCmdLine);
    }

    /* Add the first MDI window */
    gui.CommandBoxHandle=_CreateNewMDIWnd("Command Box") ;
    

    
    /* if we allocated a buffer then free it */
    if (pCmdLine)
        LocalFree((LOCALHANDLE) pCmdLine);

    /* Default to minimized windows after the first. */
    styleDefault = 0L;

    return TRUE;
        UNREFERENCED_PARAMETER(hmenu);
        UNREFERENCED_PARAMETER(hdc);

}

/***************************************************************************
 *                                                                         *
 *  MODULE    : MpFile.c                                                   *
 *                                                                         *
 *                                                                         *
 *  FUNCTIONS : AlreadyOpen   - Determines if a file is already open.      *
 *                                                                         *
 *              AddFile       - Creates a new MDI window and, if specified,*
 *                              loads a file into it.                      *
 *                                                                         *
 *              LoadFile      - Loads a file into a MDI window.            *
 *                                                                         *
 *              MyReadFile    - Calls File/Open dialog and appropriately   *
 *                              responds to the user's input.              *
 *                                                                         *
 *              SaveFile      - Saves the contents of a MDI window's edit  *
 *                              control to a file.                         *
 *                                                                         *
 *              SetSaveFrom   - Formats the "Save 'file' to" string.       *
 *                                                                         *
 *              SaveAsDlgProc - Dialog function for the File/SaveAs dialog.*
 *                                                                         *
 *              ChangeFile    - Calls File/SaveAs dialog.                  *
 *                                                                         *
 ***************************************************************************/
#include <fcntl.h>
#include <SYS\types.h>
#include <SYS\stat.h>
#include <io.h>
#include <string.h>

VOID APIENTRY GetFileName(PSTR);
//INT APIENTRY DialogBoxParam(HANDLE,LPSTR,HWND,FARPROC,LONG);
//LPSTR WINAPI AnsiUpper(LPSTR);

OFSTRUCT        of;
/****************************************************************************
 *                                                                          *
 *  FUNCTION   : AlreadyOpen(szFile)                                        *
 *                                                                          *
 *  PURPOSE    : Checks to see if the file described by the string pointed  *
 *               to by 'szFile' is already open.                            *
 *                                                                          *
 *  RETURNS    : a handle to the described file's window if that file is    *
 *               already open;  NULL otherwise.                             *
 *                                                                          *
 ****************************************************************************/

HWND AlreadyOpen(CHAR *szFile)
{
    INT     iDiff;
    HWND    hwndCheck;
    CHAR    szChild[64];
    LPSTR   lpChild, lpFile;
    HFILE     wFileTemp;

    /* Open the file with the OF_PARSE flag to obtain the fully qualified
     * pathname in the OFSTRUCT structure.
     */
    wFileTemp = OpenFile((LPSTR)szFile, (LPOFSTRUCT)&of, OF_PARSE);
    if (! wFileTemp)
        return(NULL);
    _lclose(wFileTemp);

    /* Check each MDI child window */
    for (   hwndCheck = GetWindow(hwndMDIClient, GW_CHILD);
            hwndCheck;
            hwndCheck = GetWindow(hwndCheck, GW_HWNDNEXT)   ) {
        /* Initialization  for comparison */
        lpChild = szChild;
        lpFile = (LPSTR)AnsiUpper((LPSTR) of.szPathName);
        iDiff = 0;

        /* Skip icon title windows */
        if (GetWindow(hwndCheck, GW_OWNER))
            continue;

        /* Get current child window's name */
        GetWindowText(hwndCheck, lpChild, 64);

        /* Compare window name with given name */
        while ((*lpChild) && (*lpFile) && (!iDiff)){
            if (*lpChild++ != *lpFile++)
                iDiff = 1;
        }

        /* If the two names matched, the file is already   */
        /* open -- return handle to matching child window. */
        if (!iDiff)
            return(hwndCheck);
    }
    /* No match found -- file is not open -- return NULL handle */
    return(NULL);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : AddFile (lpName)                                           *
 *                                                                          *
 *  PURPOSE    : Creates a new MDI window. If the lpName parameter is not   *
 *               NULL, it loads a file into the window.                     *
 *                                                                          *
 *  RETURNS    : HWND  - A handle to the new window.                        *
 *                                                                          *
 ****************************************************************************/

HWND APIENTRY AddFile(CHAR * pName)
{
    HWND hwnd;

    CHAR            sz[160];
    MDICREATESTRUCT mcs;

    if (!pName) {
        /* The pName parameter is NULL -- load the "Untitled" string from */
        /* STRINGTABLE and set the title field of the MDI CreateStruct.    */
        LoadString (hInst, IDS_UNTITLED, sz, sizeof(sz));
//mms        mcs.szTitle = (LPSTR)sz;
            mcs.szTitle = "Command Box" ;
    }
    else
        /* Title the window with the fully qualified pathname obtained by
         * calling OpenFile() with the OF_PARSE flag (in function
         * AlreadyOpen(), which is called before AddFile().
         */
        mcs.szTitle = of.szPathName;

    mcs.szClass = szChild;
    mcs.hOwner  = hInst;

    /* Use the default size for the window */
    mcs.x = mcs.cx = CW_USEDEFAULT;
    mcs.y = mcs.cy = CW_USEDEFAULT;

    /* Set the style DWORD of the window to default */
//    mcs.style = styleDefault;
        mcs.style = 0 ;

    /* tell the MDI Client to create the child */
    hwnd = (HWND)SendMessage (hwndMDIClient,
                              WM_MDICREATE,
                              0,
                              (LONG)(LPMDICREATESTRUCT)&mcs);

    /* Did we get a file? Read it into the window */
    if (pName){
        if (!LoadFile(hwnd, pName)){
            /* File couldn't be loaded -- close window */
            SendMessage(hwndMDIClient, WM_MDIDESTROY, (DWORD) hwnd, 0L);
        }
        
    }

    return hwnd;
}



/****************************************************************************
 *                                                                          *
 *  FUNCTION   : LoadFile (lpName)                                          *
 *                                                                          *
 *  PURPOSE    : Given the handle to a MDI window and a filename, reads the *
 *               file into the window's edit control child.                 *
 *                                                                          *
 *  RETURNS    : TRUE  - If file is sucessfully loaded.                     *
 *               FALSE - Otherwise.                                         *
 *                                                                          *
 ****************************************************************************/

INT APIENTRY LoadFile (
        HWND hwnd,
        CHAR * pName)
{
    LONG   wLength;
    HANDLE hT;
    LPSTR  lpB;
    HWND   hwndEdit;
    HFILE  fh;
        OFSTRUCT  of;
    hwndEdit = (HWND)GetWindowLong (hwnd, GWL_HWNDEDIT);

    /* The file has a title, so reset the UNTITLED flag. */
    SetWindowWord(hwnd, GWW_UNTITLED, FALSE);

    fh = OpenFile(pName, &of, OF_READ);  /* JAP was 0, which is OF_READ)*/

    /* Make sure file has been opened correctly */
    if ( fh < 0 )
        goto error;

    /* Find the length of the file */
    wLength = (DWORD)_llseek(fh, 0L, 2);
    _llseek(fh, 0L, 0);

    /* Attempt to reallocate the edit control's buffer to the file size */
    hT = (HANDLE)SendMessage (hwndEdit, EM_GETHANDLE, 0, 0L);
    if (LocalReAlloc(hT, wLength+1, LHND) == NULL) {
        /* Couldn't reallocate to new size -- error */
        _lclose(fh);
        goto error;
    }

    /* read the file into the buffer */
    if (wLength != (LONG)_lread(fh, (lpB = (LPSTR)LocalLock (hT)), (UINT)wLength))
        MPError (hwnd, MB_OK|MB_ICONHAND, IDS_CANTREAD, (LPSTR)pName);

    /* Zero terminate the edit buffer */
    lpB[wLength] = 0;
    LocalUnlock (hT);

    SendMessage (hwndEdit, EM_SETHANDLE, (UINT)hT, 0L);
    _lclose(fh);

    return TRUE;

error:
    /* Report the error and quit */
    MPError(hwnd, MB_OK | MB_ICONHAND, IDS_CANTOPEN, (LPSTR)pName);
    return FALSE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : _CreateNewMDIWnd (lpName)                                           *
 *                                                                          *
 *  PURPOSE    : Creates a new MDI window. If the lpName parameter is not   *
 *               NULL, it loads a file into the window.                     *
 *                                                                          *
 *  RETURNS    : HWND  - A handle to the new window.                        *
 *                                                                          *
 ****************************************************************************/

static HWND APIENTRY _CreateNewMDIWnd(CHAR * title)
{
    HWND hwnd;

    CHAR            sz[160];
    MDICREATESTRUCT mcs;

    mcs.szTitle = title ;

    mcs.szClass = szChild;
    mcs.hOwner  = hInst;

    /* Use the default size for the window */
    mcs.x = mcs.cx = CW_USEDEFAULT;
    mcs.y = mcs.cy = CW_USEDEFAULT;

    /* Set the style DWORD of the window to default */
    mcs.style = 0 ;

    /* tell the MDI Client to create the child */
    hwnd = (HWND)SendMessage (hwndMDIClient,
                              WM_MDICREATE,
                              0,
                              (LONG)(LPMDICREATESTRUCT)&mcs);
    return hwnd;
}


/****************************************************************************
 *                                                                          *
 *  FUNCTION   : _LoadBuffer (lpName, buffer)                                          *
 *                                                                          *
 *  PURPOSE    : Given the handle to a MDI window and a buffer, reads the *
 *               buffer into the window's edit control child.                 *
 *                                                                          *
 *  RETURNS    : TRUE  - If file is sucessfully loaded.                     *
 *               FALSE - Otherwise.                                         *
 *                                                                          *
 ****************************************************************************/

INT APIENTRY _LoadBuffer (CHAR *buffer, HINSTANCE hInst)
{
    char szTitle[20] = "Result" ;
    LONG   wLength;
    HANDLE hT;
    LPSTR  lpB;
    HWND   hwndEdit;
    OFSTRUCT  of;
    HWND   hwnd ;
    char String [200] ;

    LOGFONT   lfEditFont;                            // arw fixed width font
    HFONT     hFont;                                 // arw we can take this out if you it looks funny to you.... 
 

    if ((gui.ResultBoxHandle) && (gui.MDIstyle == IDM_GUI_SINGLE))
    {
        gui.NextResultBoxNumber = 2 ;
        QueryCloseChild (gui.ResultBoxHandle) ;
        DestroyWindow (gui.ResultBoxHandle);
        gui.ResultBoxHandle = NULL ;

    }
    
    if (gui.MDIstyle == IDM_GUI_MULTIPLE)
        sprintf (szTitle, "Result #%d", gui.NextResultBoxNumber++) ;
        
    hwnd = _CreateNewMDIWnd(szTitle) ;
    if (hwnd == NULL)
    {
        MessageBox (NULL, "Result box", "", MB_OK) ;
        goto error ;
    }
    
    gui.ResultBoxHandle = hwnd ;
    
    hwndEdit = (HWND)GetWindowLong (hwnd, GWL_HWNDEDIT);
    if (hwndEdit == NULL)
    {
        MessageBox (NULL, "hwndEdit", "", MB_OK) ;
        goto error ;
    }

    
     /* increase edit control max character limit beyond 30,000 default */           // arw
        SendMessage (hwndEdit, EM_LIMITTEXT, 0x0FFFFFFF, 0);                         // arw

    
        /* create fixed pitch font as default font */                                // arw
        lfEditFont.lfHeight = 16;
        lfEditFont.lfWidth = 0;
        lfEditFont.lfEscapement = 0;
        lfEditFont.lfOrientation = 0;
        lfEditFont.lfWeight = 400;
        lfEditFont.lfItalic = FALSE;
        lfEditFont.lfUnderline = FALSE;
        lfEditFont.lfStrikeOut = FALSE;
        lfEditFont.lfCharSet = ANSI_CHARSET;
        lfEditFont.lfOutPrecision = OUT_DEFAULT_PRECIS;
        lfEditFont.lfClipPrecision = CLIP_DEFAULT_PRECIS;
        lfEditFont.lfQuality = DEFAULT_QUALITY;
        lfEditFont.lfPitchAndFamily = FIXED_PITCH | FF_MODERN;
        *lfEditFont.lfFaceName = 0;                                                     // arw

        if (hFont = CreateFontIndirect (&lfEditFont))                                   // arw
        SendMessage (hwndEdit, WM_SETFONT, (UINT)hFont, 0);
        else
        goto error;


    /* Find the length of the buffer */
    wLength = strlen (buffer) ;
    
    /* Attempt to reallocate the edit control's buffer to the file size */
    hT = (HANDLE)SendMessage (hwndEdit, EM_GETHANDLE, 0, 0L);
    if (hT == NULL)
    {
        goto error;
    }
    
    if (LocalReAlloc(hT, wLength+1, LHND) == NULL) {
        /* Couldn't reallocate to new size -- error */
        sprintf (String, "ERROR %d", GetLastError()) ;
        MessageBox (NULL, String, "", MB_OK) ;
        goto error;
    }
    
    lpB = (LPSTR) LocalLock (hT) ;
    strcpy (lpB, buffer) ;
    
    LocalUnlock (hT);

    SendMessage (hwndEdit, EM_SETHANDLE, (UINT)hT, 0L);

    return TRUE;

error:
    /* Report the error and quit */
    MPError(hwnd, MB_OK | MB_ICONHAND, IDS_CANTOPEN, (LPSTR)"Buffer");
    return FALSE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : MyReadFile(hwnd)                                           *
 *                                                                          *
 *  PURPOSE    : Called in response to a File/Open menu selection. It asks  *
 *               the user for a file name and responds appropriately.       *
 *                                                                          *
 ****************************************************************************/

VOID APIENTRY MyReadFile(HWND hwnd)
{
    CHAR    szFile[128];
    HWND    hwndFile;

    GetFileName (szFile);

    /* If the result is not the empty string -- take appropriate action */
    if (*szFile) {
            /* Is file already open?? */
            if (hwndFile = AlreadyOpen(szFile)) {
                /* Yes -- bring the file's window to the top */
                BringWindowToTop(hwndFile);
            }
            else {
                /* No -- make a new window and load file into it */
                AddFile(szFile);
            }
    }
        UNREFERENCED_PARAMETER(hwnd);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : SaveFile (hwnd)                                            *
 *                                                                          *
 *  PURPOSE    : Saves contents of current edit control to disk.            *
 *                                                                          *
 ****************************************************************************/

VOID APIENTRY SaveFile(HWND hwnd)
{
    HANDLE   hT;
    LPSTR    lpT;
    CHAR     szFile[128];
    INT      cch;
    INT      fh;
//    OFSTRUCT of;
    HWND     hwndEdit;

    PSTR     pch;

    hwndEdit = (HWND)GetWindowLong ( hwnd, GWL_HWNDEDIT);
    GetWindowText (hwnd, szFile, sizeof(szFile));

    /* If there is no extension (control is 'Untitled') add .TXT as extension */
    for (cch = FALSE, lpT = szFile; *lpT; lpT++)
        switch (*lpT){
            case '.':
                 cch = TRUE;
                 break;

            case '\\':
            case ':' :
                 cch = FALSE;
                 break;
        }
    if (!cch)
        LoadString (hInst, IDS_ADDEXT, lpT, lpT - (LPSTR)szFile);

    fh = open(szFile, O_BINARY | O_WRONLY | O_CREAT, S_IWRITE);

    /* If file could not be opened, quit */
    if (fh < 0){
        MPError (hwnd, MB_OK | MB_ICONHAND, IDS_CANTCREATE, (LPSTR)szFile);
        return;
    }

    /* Find out the length of the text in the edit control */
    cch = GetWindowTextLength (hwndEdit);

    /* Obtain a handle to the text buffer */
    hT  = (HANDLE)SendMessage (hwndEdit, EM_GETHANDLE, 0, 0L);
    lpT = (LPSTR)LocalLock (hT);

    /* Write out the contents of the buffer to the file. */
    if (cch != write(fh, lpT, cch))
        MPError (hwnd, MB_OK | MB_ICONHAND, IDS_CANTWRITE, (LPSTR)szFile);

    /* Clean up */
    LocalUnlock (hT);
    SendMessage (hwndEdit, EM_SETHANDLE, (UINT)hT, 0L);

    close(fh);

    return;
        UNREFERENCED_PARAMETER(pch);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : SetSaveFrom ()                                             *
 *                                                                          *
 *  PURPOSE    : Formats the "Save 'file' to .." string.                    *
 *                                                                          *
 ****************************************************************************/

VOID NEAR PASCAL SetSaveFrom (
        HWND hwnd,
        PSTR psz)
{
    CHAR szFmt[32];
    CHAR szText[160];

    /* The text string in the .RC file contains the format string... */
    GetDlgItemText( hwnd, IDD_SAVEFROM, szFmt, sizeof(szFmt));

    /* NOTE: this (LPSTR) cast MUST be here... wsprintf() is a cdecl
     * (C calling conventions) function with varying args... there is
     * no way for the compiler to know that all strings must be LPSTR's
     * and do the conversion, so we have to be careful about wsprintf()'s.
     */
    wsprintf ( szText, szFmt, (LPSTR)psz);

    /* set the text in the static control */
    SetDlgItemText (hwnd, IDD_SAVEFROM, szText);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : SaveAsDlgProc(hwnd, message, wParam, lParam)               *
 *                                                                          *
 *  PURPOSE    : Dialog function File/SaveAs. It waits for a filename, and  *
 *               then calls SaveFile or cancels the operation.              *
 *                                                                          *
 ****************************************************************************/

BOOL APIENTRY SaveAsDlgProc(
        HWND hwnd,
        UINT message,
        UINT wParam,
        LONG lParam)
{
    CHAR   sz[64];
    CHAR   *pch;
    BOOL   fExt;
    HWND   hwndSave;

    switch (message){

        case WM_INITDIALOG:

            /* Identify the window whose contents we're saving */
#ifdef ORGCODE
            hwndSave = LOWORD (lParam);
#else
                hwndSave = (HWND)lParam;                /*passed in from another procedure*/
#endif
            /* Set it's name in the property list */
            SetProp (hwnd, PROP_FILENAME, hwndSave);

            GetWindowText (hwndSave, sz, sizeof(sz));

            /* Set the save from string... */
            SetSaveFrom (hwnd,sz);

            /* Generate a filename complete with extension */
            AnsiUpper (sz);
            for (fExt = FALSE, pch = sz; *pch; pch++)
                if (*pch == '.')
                    fExt = TRUE;
                else if (*pch == '\\')
                    fExt = FALSE;
            if (!fExt)
                LoadString (hInst, IDS_ADDEXT, (LPSTR)pch, pch - sz);

            /* Display the filename in the edit control */
            SetDlgItemText (hwnd, IDD_SAVETO, sz);

            /* Select the entire range of text */
            SendMessage(GetDlgItem(hwnd, IDD_SAVETO), EM_SETSEL, GET_EM_SETSEL_MPS(0, 100));

            DlgDirList (hwnd, "*.*", (INT)IDD_DIRS, (INT)IDD_PATH, (WORD)ATTR_DIRS);

            /* enable OK butto iff edit control is nonempty */
            if (!*sz)
                EnableWindow (GetDlgItem (hwnd, IDOK), FALSE);
            break;

        case WM_COMMAND:
            switch (LOWORD(wParam)){
                case IDCANCEL:
                    /* Abort operation */
                    EndDialog(hwnd,1);
                    break;

                case IDOK:
                   /*  Just change the title of the MDI child. The calling
                    *  function of ChangeFile(), which uses the title text
                    *  for the filename, will do the actual save.
                    */
                    hwndSave = GetProp (hwnd, PROP_FILENAME);
                    GetDlgItemText (hwnd, IDD_SAVETO, sz, sizeof(sz));
                    AnsiUpper ((LPSTR)sz);
                    SetWindowText (hwndSave, sz);
                    EndDialog (hwnd, 0);
                    break;

                case IDD_SAVETO:
                   /* If the edit control changes, check to see if its empty.
                    * enable OK if it contains something
                    */
                    if (HIWORD (lParam) != EN_CHANGE)
                        return FALSE;
                    EnableWindow (GetDlgItem (hwnd, IDOK),
                                SendDlgItemMessage (hwnd,
                                                   IDD_SAVETO,
                                                   WM_GETTEXTLENGTH,
                                                   0,
                                                   0L));
                    break;

                case IDD_DIRS:
                    if (HIWORD(lParam)==LBN_DBLCLK){
                        CHAR szT[64];

                        DlgDirSelectEx(hwnd, szT, 64, IDD_DIRS);
                        lstrcat ( szT, "*.*");
                        DlgDirList (hwnd, szT, (INT)IDD_DIRS, (INT)IDD_PATH, (WORD)ATTR_DIRS);
                        break;
                    }
                    return FALSE;

                default:
                    return FALSE;
            }

        default:
            return FALSE;
    }
    return TRUE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : ChangeFile (hwnd)                                          *
 *                                                                          *
 *  PURPOSE    : Invokes the File/SaveAs dialog.                            *
 *                                                                          *
 *  RETURNS    : TRUE  - if user selected OK or NO.                         *
 *               FALSE - otherwise.                                         *
 *                                                                          *
 ****************************************************************************/

BOOL APIENTRY ChangeFile (HWND hwnd)
{
    INT     i;

#ifdef NOTCOMMONDIALOGS
    i = DialogBoxParam (hInst, IDD_SAVEAS, hwnd, SaveAsDlgProc, (LONG)hwnd);
    if (!i)
            SetWindowWord (hwnd, GWW_UNTITLED, 0);
    return !i;
#else
    OPENFILENAME ofn;
    CHAR szFilterSpec [128] =                       /* file type filters */
             "TEXT FILES(*.TXT)\0*.txt\0";

    #define MAXFILENAME 256
    CHAR szFileName[MAXFILENAME];
    CHAR szFileTitle[MAXFILENAME];

    strcpy(szFileName, "");   /* these need be NULL*/
    strcpy(szFileTitle, "");

    /* fill in non-variant fields of OPENFILENAME struct. */
    ofn.lStructSize       = sizeof(OPENFILENAME);
    ofn.hwndOwner         = hwnd;
    ofn.lpstrFilter       = szFilterSpec;
    ofn.lpstrCustomFilter = NULL;
    ofn.nMaxCustFilter    = 0;
    ofn.nFilterIndex      = 0;
    ofn.lpstrFile         = szFileName;
    ofn.nMaxFile          = MAXFILENAME;
    ofn.lpstrInitialDir   = NULL;
    ofn.lpstrFileTitle    = szFileTitle;
    ofn.nMaxFileTitle     = MAXFILENAME;
    ofn.lpstrTitle        = "Save TextFiles";
    ofn.lpstrDefExt       = "TXT";
    ofn.Flags             = 0;
    /* Use standard open dialog */
    i = GetSaveFileName ((LPOPENFILENAME)&ofn);
    if (i)
	{
        AnsiUpper ((LPSTR)ofn.lpstrFile);
        SetWindowText (hwnd, ofn.lpstrFile);
        SetWindowWord (hwnd, GWW_UNTITLED, 0);
	}
    return i;
#endif

}


/***************************************************************************
 *                                                                         *
 *  MODULE      : MpPrint()                                                *
 *                                                                         *
 *  PURPOSE     : Printing code.                                           *
 *                                                                         *
 *  FUNCTIONS   : GetPrinterDC ()          -  Creates a printer DC for the *
 *                                            default device.              *
 *                                                                         *
 *                AbortProc ()             -  Export proc. for GDI to check*
 *                                            print abort.                 *
 *                                                                         *
 *                PrintDlgProc ()          -  Dialog function for the print*
 *                                            cancel dialog.               *
 *                                                                         *
 *                PrintFile ()             -  Prints the contents of the   *
 *                                            edit control.                *
 *                                                                         *
 *                GetInitializationData () -  Gets DC initialisation data  *
 *                                            from a DC supporting         *
 *                                            ExtDeviceMode().                   *
 *                                                                         *
 ***************************************************************************/

BOOL fAbort;            /* TRUE if the user has aborted the print job    */
HWND hwndPDlg;          /* Handle to the cancel print dialog             */
CHAR szDevice[160];     /* Contains the device, the driver, and the port */
PSTR szDriver;          /* Pointer to the driver name                    */
PSTR szPort;            /* Port, ie, LPT1                                */
PSTR szTitle;           /* Global pointer to job title                   */
INT iPrinter = 0;       /* level of available printer support.           */
                        /* 0 - no printer available                      */
                        /* 1 - printer available                         */
                        /* 2 - driver supports 3.0 device initialization */
HANDLE hInitData=NULL;  /* handle to initialization data                 */

CHAR szExtDeviceMode[] = "EXTDEVICEMODE";

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : GetPrinterDC ()                                            *
 *                                                                          *
 *  PURPOSE    : Creates a printer display context for the default device.  *
 *               As a side effect, it sets the szDevice and szPort variables*
 *               It also sets iPrinter to the supported level of printing.  *
 *                                                                          *
 *  RETURNS    : HDC   - A handle to printer DC.                            *
 *                                                                          *
 ****************************************************************************/
HDC APIENTRY GetPrinterDC(BOOL bInformation)
{
    HDC      hdc;
    LPDEVMODE  lpdevmode = NULL;

    iPrinter = 0;

    /* Get the printer information from win.ini into a buffer and
     * null terminate it.
     */
    GetProfileString ( "windows", "device", "" ,szDevice, sizeof(szDevice));
    for (szDriver = szDevice; *szDriver && *szDriver != ','; szDriver++)
        ;
    if (*szDriver)
        *szDriver++ = 0;

    /* From the current position in the buffer, null teminate the
     * list of ports
     */
    for (szPort = szDriver; *szPort && *szPort != ','; szPort++)
        ;
    if (*szPort)
        *szPort++ = 0;

    /* if the device, driver and port buffers all contain meaningful data,
     * proceed.
     */
    if (!*szDevice || !*szDriver || !*szPort){
        *szDevice = 0;
        return NULL;
    }

    /* Create the printer display context */
    if (hInitData){
        /* Get a pointer to the initialization data */
        lpdevmode = (LPDEVMODE) LocalLock (hInitData);

        if (lstrcmp (szDevice, (LPSTR)lpdevmode)){
            /* User has changed the device... cancel this setup, as it is
             * invalid (although if we worked harder we could retain some
             * of it).
             */
            lpdevmode = NULL;
            LocalUnlock (hInitData);
            LocalFree (hInitData);
            hInitData = NULL;
        }
    }

    if (bInformation)
      hdc = CreateIC (szDriver, szDevice, szPort, lpdevmode);
   else
      hdc = CreateDC (szDriver, szDevice, szPort, lpdevmode);

    /* Unlock initialization data */
    if (hInitData)
        LocalUnlock (hInitData);

    if (!hdc)
        return NULL;


    iPrinter = 1;

    /* Find out if ExtDeviceMode() is supported and set flag appropriately */
    if (GetProcAddress (LoadLibrary(szDriver), szExtDeviceMode))
        iPrinter = 2;

    return hdc;

}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : AbortProc()                                                *
 *                                                                          *
 *  PURPOSE    : To be called by GDI print code to check for user abort.    *
 *                                                                          *
 ****************************************************************************/
INT APIENTRY AbortProc (
        HDC hdc,
        WORD reserved)
{
    MSG msg;

    /* Allow other apps to run, or get abort messages */
    while (!fAbort && PeekMessage (&msg, NULL, 0, 0, TRUE))
        if (!hwndPDlg || !IsDialogMessage (hwndPDlg, &msg)){
            TranslateMessage (&msg);
            DispatchMessage  (&msg);
        }
    return !fAbort;

        UNREFERENCED_PARAMETER(hdc);
        UNREFERENCED_PARAMETER(reserved);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : PrintDlgProc ()                                            *
 *                                                                          *
 *  PURPOSE    : Dialog function for the print cancel dialog box.           *
 *                                                                          *
 *  RETURNS    : TRUE  - OK to abort/ not OK to abort                       *
 *               FALSE - otherwise.                                         *
 *                                                                          *
 ****************************************************************************/
BOOL APIENTRY PrintDlgProc(HWND hwnd, UINT msg, WORD wParam, LONG lParam)
{
    switch (msg){
        case WM_INITDIALOG:
            /* Set up information in dialog box */
            SetDlgItemText (hwnd, IDD_PRINTDEVICE, (LPSTR)szDevice);
            SetDlgItemText (hwnd, IDD_PRINTPORT, (LPSTR)szPort);
            SetDlgItemText (hwnd, IDD_PRINTTITLE, (LPSTR)szTitle);
            break;

        case WM_COMMAND:
            /* abort printing if the only button gets hit */
            fAbort = TRUE;
            break;

        default:
            return FALSE;
    }
    return TRUE;
        UNREFERENCED_PARAMETER(wParam);
        UNREFERENCED_PARAMETER(lParam);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : PrintFile ()                                               *
 *                                                                          *
 *  PURPOSE    : Prints the contents of the edit control.                   *
 *                                                                          *
 ****************************************************************************/

VOID APIENTRY PrintFile(HWND hwnd)
{
    HDC     hdc;
    INT     yExtPage;
    CHAR    sz[32];
    int     cch;
    WORD    ich;
    PSTR    pch;
    WORD    iLine;
    WORD    nLinesEc;
    WORD    i;
    HANDLE  hT;
    HWND    hwndPDlg;
    DWORD   dy;
    INT     yExtSoFar;
    WORD    fError = TRUE;
    HWND    hwndEdit;

    hwndEdit = (HWND)GetWindowLong(hwnd,GWL_HWNDEDIT);

    /* Create the job title by loading the title string from STRINGTABLE */
    cch = LoadString (hInst, IDS_PRINTJOB, sz, sizeof(sz));
    szTitle = sz + cch;
    cch += GetWindowText (hwnd, sz + cch, 32 - cch);
    sz[31] = 0;

    /* Initialize the printer */
    hdc = GetPrinterDC(FALSE);
    if (!hdc)
        goto getout5;

    /* Disable the main application window and create the Cancel dialog */
    EnableWindow (hwndFrame, FALSE);

    hwndPDlg = CreateDialog (hInst, IDD_PRINT, hwnd, (DLGPROC) PrintDlgProc);

    if (!hwndPDlg)
        goto getout3;
    ShowWindow (hwndPDlg, SW_SHOW);
    UpdateWindow (hwndPDlg);

    /* Allow the app. to inform GDI of the escape function to call */
    if (Escape(hdc, SETABORTPROC, 0, (LPSTR)AbortProc, NULL) < 0)
        goto getout1;

    /* Initialize the document */
    if (Escape(hdc, STARTDOC, cch, (LPSTR)sz, NULL) < 0)
        goto getout1;

    /* Get the height of one line and the height of a page */
    {
    SIZE tmp;
    GetTextExtentPoint(hdc, "CC", 2, &tmp );
    dy = tmp.cy;
    }

    yExtPage = GetDeviceCaps(hdc, VERTRES);

    /* Get the lines in document and and a handle to the text buffer */
    iLine     = 0;
    yExtSoFar = 0;
    nLinesEc  = (WORD)SendMessage (hwndEdit, EM_GETLINECOUNT, 0, 0L);
    hT        = (HANDLE)SendMessage (hwndEdit, EM_GETHANDLE, 0, 0L);

    /* While more lines print out the text */
    while (iLine < nLinesEc){
        if (yExtSoFar + (int) dy > yExtPage){
            /* Reached the end of a page. Tell the device driver to eject a
             * page
             */
            if (Escape(hdc, NEWFRAME, 0, NULL, NULL) < 0 || fAbort)
                goto getout2;
            yExtSoFar = 0;
        }

        /* Get the length and position of the line in the buffer
         * and lock from that offset into the buffer */
        ich = (WORD)SendMessage (hwndEdit, EM_LINEINDEX, iLine, 0L);
        cch = (WORD)SendMessage (hwndEdit, EM_LINELENGTH, ich, 0L);
        pch = (PSTR)LocalLock(hT) + ich;

        /* Print the line and unlock the text handle */
        TextOut (hdc, 0, yExtSoFar, (LPSTR)pch, cch);
        LocalUnlock (hT);

        /* Test and see if the Abort flag has been set. If yes, exit. */
        if (fAbort)
            goto getout2;

        /* Move down the page */
        yExtSoFar += dy;
        iLine++;
    }

    /* Eject the last page. */
    if (Escape(hdc, NEWFRAME, 0, NULL, NULL) < 0)
        goto getout2;

    /* Complete the document. */
    if (Escape(hdc, ENDDOC, 0, NULL, NULL) < 0){
getout2:
        /* Ran into a problem before NEWFRAME? Abort the document */
        Escape( hdc, ABORTDOC, 0, NULL, NULL);
    }
    else
        fError=FALSE;

getout3:
    /* Close the cancel dialog and re-enable main app. window */
    EnableWindow (hwndFrame, TRUE);
    DestroyWindow (hwndPDlg);

getout1:
    DeleteDC(hdc);

getout5:
#ifdef WIN16
    /* Get rid of dialog procedure instances */
    FreeProcInstance (lpfnPDlg);
#endif

#ifdef WIN16
getout4:
    FreeProcInstance (lpfnAbort);
getout:
#endif

    /* Error? make sure the user knows... */
    if (fError)
        MPError (hwnd, MB_OK | MB_ICONEXCLAMATION, IDS_PRINTERROR, (LPSTR)szTitle);

    return;
        UNREFERENCED_PARAMETER(i);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : GetInitializationData()                                    *
 *                                                                          *
 *  PURPOSE    : Gets DC initialization data from a printer driver          *
 *               supporting ExtDeviceMode(). Called in response to the      *
 *               File/Printer setup menu selection.                         *
 *                                                                          *
 *               This function allows the user to change the printer        *
 *               settings FOR MULTIPAD ONLY.  This allows Multipad to print *
 *               in a variety of settings without messing up any other      *
 *               applications. In a more sophisticated application, this    *
 *               setup could even be saved on a document-by-document basis. *
 *                                                                          *
 ****************************************************************************/
BOOL APIENTRY GetInitializationData( HWND hwnd )
{
    LPSTR     lpOld;
    LPSTR     lpNew;
    FARPROC   lpfn;
    HANDLE    hT,hDrv;
    CHAR      sz[32];
    int           cb;
    INT       flag;

    /* Pop up dialog for user and retain data in app buffer */
    flag = DM_PROMPT | DM_COPY;

    /* Load the device driver and find the ExtDeviceMode() function */
    wsprintf (sz, "%s.drv", (LPSTR)szDriver);
    if ((int)(hDrv = LoadLibrary (sz)) < 32)
        return FALSE;
    if (!(lpfn = GetProcAddress (hDrv, szExtDeviceMode)))
        return FALSE;

    if (hInitData){
        /* We have some old data... we want to modify the previously specified
         * setup rather than starting with the default setup.
         */
        lpOld = (LPSTR)LocalLock(hInitData);
        flag |= DM_MODIFY;
    }
    else
        lpOld = NULL;

    /* Get the number of bytes needed for the init data */
    cb = (*lpfn) (hwnd,
                  hDrv,
                  (LPDEVMODE)NULL,
                  (LPSTR)szDevice,
                  (LPSTR)szPort,
                  (LPDEVMODE)NULL,
                  (LPSTR)NULL,
                  0);

    /* Grab some memory for the new data and lock it. */
    hT    = LocalAlloc (LHND,cb);
    if(!hT){
        MessageBox(hwnd, "<GetInitializationData> Not enough memory.", NULL, MB_OK | MB_ICONHAND);
            LocalUnlock(hInitData);
            LocalFree(hInitData);
        FreeLibrary(hDrv);
        return(FALSE);
    }

    lpNew = (LPSTR)LocalLock (hT);

    /* Post the device mode dialog. 0 flag iff user hits OK button */
    if ((*lpfn) (hwnd,
                 hDrv,
                 (LPDEVMODE)lpNew,
                 (LPSTR)szDevice,
                 (LPSTR)szPort,
                 (LPDEVMODE)lpOld,
                 (LPSTR)NULL,
                 flag)==IDOK)
        flag = 0;

    /* Unlock the input structures */
    LocalUnlock (hT);

    if (hInitData)
        LocalUnlock (hInitData);

    /* If the user hit OK and everything worked, free the original init.
     * data and retain the new one.  Otherwise, toss the new buffer.
     */
    if (flag)
        LocalFree (hT);
    else{
        if (hInitData)
            LocalFree (hInitData);
        hInitData = hT;
    }

    FreeLibrary(hDrv);
    return (!flag);
}


/***************************************************************************
 *                                                                         *
 *  MODULE      : MpFind.c                                                 *
 *                                                                         *
 *  PURPOSE     : Code to do text searches.                                *
 *                                                                         *
 *  FUNCTIONS   : RealSlowCompare () - Compares subject string with target *
 *                                     string.                             *
 *                                                                         *
 *                Local_FindText ()          - Looks for the search string in the  *
 *                                     active window.                      *
 *                                                                         *
 *                FindPrev ()        - Find previous occurence of search   *
 *                                     string.                             *
 *                                                                         *
 *                FindNext ()        - Find next occurence of search string*
 *                                                                         *
 *                FindDlgProc ()     - Dialog function for Search/Find.    *
 *                                                                         *
 *                Find ()            - Invokes FindDlgProc ()              *
 *                                                                         *
 ***************************************************************************/

#undef HIWORD
#undef LOWORD

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])

BOOL fCase         = FALSE;    /* Turn case sensitivity off */
CHAR szSearch[160] = "";       /* Initialize search string  */

//LPSTR WINAPI AnsiLower (LPSTR);

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : RealSlowCompare ()                                         *
 *                                                                          *
 *  PURPOSE    : Compares subject string with the target string. This fn/   *
 *               is called repeatedly so that all substrings are compared,  *
 *               which makes it O(n ** 2), hence it's name.                 *
 *                                                                          *
 *  RETURNS    : TRUE  - If pSubject is identical to pTarget.               *
 *               FALSE - otherwise.                                         *
 *                                                                          *
 ****************************************************************************/

BOOL NEAR PASCAL RealSlowCompare (
        register PSTR pSubject,
        register PSTR pTarget)
{
    if (fCase){
        while (*pTarget)
            if (*pTarget++ != *pSubject++)
                return FALSE;
    }
    else{
        /* If case-insensitive, convert both subject and target to lowercase
         * before comparing.
         */
        AnsiLower ((LPSTR)pTarget);
        while (*pTarget)
            if (*pTarget++ != (CHAR)(DWORD)AnsiLower ((LPSTR)(DWORD)(BYTE)*pSubject++))
                return FALSE;
    }
    return TRUE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : Local_FindText ()                                                  *
 *                                                                          *
 *  PURPOSE    : Finds the search string in the active window according to  *
 *               search direction (dch) specified ( -1 for reverse and 1 for*
 *               forward searches).                                         *
 *                                                                          *
 ****************************************************************************/
VOID NEAR PASCAL Local_FindText(register INT dch)
{
    register PSTR pText;
    HANDLE        hT;
    LONG          l;
    WORD          cch;
    INT           i;

    if (!*szSearch)
        return;

    /* Find the current selection range */
    l = (LONG)SendMessage(hwndActiveEdit, EM_GETSEL, 0, 0);

    /* Get the handle to the text buffer and lock it */
    hT    = (HANDLE)SendMessage (hwndActiveEdit, EM_GETHANDLE, 0, 0L);
    pText = LocalLock(hT);

    /* Get the length of the text */
    cch = (WORD)SendMessage (hwndActiveEdit, WM_GETTEXTLENGTH, 0, 0L);

    /* Start with the next char. in selected range ... */
    pText += LOWORD (l) + dch;

    /* Compute how many characters are before/after the current selection*/
    if (dch < 0)
        i = LOWORD (l);
    else
        i = cch - LOWORD (l) + 1 - lstrlen (szSearch);

    /* While there are uncompared substrings... */
    while ( i > 0){
        LOWORD(l)+=dch;

        /* Does this substring match? */
        if (RealSlowCompare(pText,szSearch)){

            /* Yes, unlock the buffer.*/
            LocalUnlock(hT);

            /* Select the located string */
            HIWORD(l) = LOWORD(l) + (WORD)lstrlen (szSearch);
            SendMessage(hwndActiveEdit, EM_SETSEL, GET_EM_SETSEL_MPS(LOWORD(l), HIWORD(l)));
            return;
        }
        i--;

        /* increment/decrement start position by 1 */
        pText += dch;
    }

    /* Not found... unlock buffer. */
    LocalUnlock (hT);

    /* Give a message */
    MPError (hwndFrame, MB_OK | MB_ICONEXCLAMATION, IDS_CANTFIND, (LPSTR)szSearch);

    return;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : FindPrev ()                                                *
 *                                                                          *
 *  PURPOSE    : Finds the previous occurence of the search string. Calls   *
 *               Local_FindText () with a negative search direction.                *
 *                                                                          *
 ****************************************************************************/
VOID APIENTRY FindPrev()
{
    Local_FindText(-1);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : FindNext ()                                                *
 *                                                                          *
 *  PURPOSE    : Finds the next occurence of search string. Calls           *
 *               Local_FindText () with a positive search direction.                *
 *                                                                          *
 ****************************************************************************/
VOID APIENTRY FindNext()
{
    Local_FindText(1);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : FindDlgProc(hwnd, message, wParam, lParam)                 *
 *                                                                          *
 *  PURPOSE    : Dialog function for the Search/Find command. Prompts user  *
 *               for target string, case flag and search direction.         *
 *                                                                          *
 ****************************************************************************/
BOOL APIENTRY FindDlgProc(
        HWND hwnd,
        UINT msg,
        UINT wParam,
        LONG lParam)
{
    switch (msg){
        case WM_INITDIALOG:{

            /* Check/uncheck case button */
            CheckDlgButton (hwnd, (int)IDD_CASE, (WORD)fCase);

            /* Set default search string to most recently searched string */
            SetDlgItemText (hwnd, IDD_SEARCH, szSearch);

            /* Allow search only if target is nonempty */
            if (!lstrlen (szSearch)){
                EnableWindow (GetDlgItem (hwnd, IDOK), FALSE);
                EnableWindow (GetDlgItem (hwnd, IDD_PREV), FALSE);
            }
            break;
        }

        case WM_COMMAND:
        {

            /* Search forward by default (see IDOK below) */
            INT i = 1;

            switch (LOWORD(wParam)){
                /* if the search target becomes non-empty, enable searching */
                case IDD_SEARCH:
                    if (GET_WM_COMMAND_CMD(wParam, lParam) == EN_CHANGE){
                        if (!(WORD) SendDlgItemMessage (hwnd,
                                                        IDD_SEARCH,
                                                        WM_GETTEXTLENGTH,
                                                        0,
                                                        0L))
                            i = FALSE;
                        else
                            i = TRUE;
                        EnableWindow (GetDlgItem (hwnd, IDOK), i);
                        EnableWindow (GetDlgItem (hwnd, IDD_PREV), i);
                    }
                    break;

                case IDD_CASE:
                    /* Toggle state of case button */
                    CheckDlgButton (hwnd,
                                    (int)IDD_CASE,
                                    (WORD)!IsDlgButtonChecked (hwnd, (int)IDD_CASE));
                    break;

                case IDD_PREV:
                    /* Set direction to backwards */
                    i=-1;
                    /*** FALL THRU ***/

                case IDOK:
                    /* Save case selection */
                    fCase = IsDlgButtonChecked( hwnd, IDD_CASE);

                    /* Get search string */
                    GetDlgItemText (hwnd, IDD_SEARCH, szSearch, sizeof (szSearch));

                    /* Find the text */
                    Local_FindText (i);
                    /*** FALL THRU ***/

                /* End the dialog */
                case IDCANCEL:
                    EndDialog (hwnd, 0);
                    break;

                default:
                    return FALSE;
            }
            break;
        }
        default:
            return FALSE;
    }
    return TRUE;
        UNREFERENCED_PARAMETER(lParam);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : Find()                                                     *
 *                                                                          *
 *  PURPOSE    : Invokes the Search/Find dialog.                            *
 *                                                                          *
 ****************************************************************************/

VOID APIENTRY Find()
{
    DialogBox (hInst, IDD_FIND, hwndFrame, FindDlgProc);
}


/***************************************************************************
 *                                                                         *
 *  MODULE      : MpOpen.c                                                 *
 *                                                                         *
 *  PURPOSE     : Contains the file open dialog function and it's helper   *
 *                functions.                                               *
 *                                                                         *
 *  FUNCTIONS   : IsWild ()           - Ascertains that the input string   *
 *                                      contains a DOS wildcard character. *
 *                                                                         *
 *                SelectFile()        - If filename supplied contains a    *
 *                                      wildcard, this function fills the  *
 *                                      listboxes in File/Open dialog, else*
 *                                      the dialog is closed.              *
 *                                                                         *
 *                FileOpenDlgProc()   - Dialog funcion for the File/Open   *
 *                                      dialog.                            *
 *                                                                         *
 *                GetFileName ()      - Gets a file name from the user.    *
 *                                                                         *
 ***************************************************************************/

CHAR szPropertyName [] = "FILENAME";/* Name of the File name property list item */



/****************************************************************************
 *                                                                          *
 *  FUNCTION   : IsWild ( psz )                                             *
 *                                                                          *
 *  PURPOSE    : Checks if the string (referenced by a NEAR pointer)        *
 *               contains a DOS wildcard character ("*" or "?").            *
 *                                                                          *
 *  RETURNS    : TRUE  - iff the string contains a wildcard character.      *
 *               FALSE - otherwise.                                  .      *
 *                                                                          *
 ****************************************************************************/
BOOL NEAR PASCAL IsWild(register PSTR psz)
{
    for(;;)
        switch (*psz++){
            case '*':
            case '?':
                /* Found wildcard */
                return TRUE;

            case 0:
                /* Reached end of string */
                return FALSE;

            default:
                continue;
        }
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : FileExists(pch)                                            *
 *                                                                          *
 *  PURPOSE    : Checks to see if a file exists with the path/filename      *
 *               described by the string pointed to by 'pch'.               *
 *                                                                          *
 *  RETURNS    : TRUE  - if the described file does exist.                  *
 *               FALSE - otherwise.                                         *
 *                                                                          *
 ****************************************************************************/


BOOL FileExists(PSTR pch)
{
        int fh;

        if ((fh = open(pch, O_RDONLY)) < 0)
             return(FALSE);

        _lclose(fh);
        return(TRUE);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : SelectFile ( hwnd )                                        *
 *                                                                          *
 *  PURPOSE    : Reads the string in the edit control of the File/Open      *
 *               dialog. If it contains a wildcard, then it attempts to     *
 *               fill the listboxes in the File/Open dialog. Othewise it    *
 *               ends the dialog. Modifies the FILENAME item in the property*
 *               list of the window.                                        *
 *                                                                          *
 ****************************************************************************/

VOID NEAR PASCAL SelectFile(register HWND hwnd)
{
    register PSTR pch;
    PSTR          pch2;

    /* Get handle (near address) to filename data in window's property list */
    pch = (PSTR)GetProp (hwnd, PROP_FILENAME);

    /* Get the text from the dialog's edit control into this address */
    GetDlgItemText (hwnd, IDD_FILENAME, pch, 64);

    if ( IsWild (pch)){
        /* Select the directory and make a listing of the directories */
        DlgDirList(hwnd, (LPSTR)pch, (int)IDD_DIRS, (int)IDD_PATH, (WORD)ATTR_DIRS);

        /* Obtain the filename-only part of the path in the edit control */
        for (pch2 = pch; *pch; pch++)
            if (*pch == '\\' || *pch == ':')
                pch2 = pch + 1;

        /* List the files in this directory based on the wildcard. */
        DlgDirList(hwnd, (LPSTR)pch2, IDD_FILES, IDD_PATH, ATTR_FILES);

        /* Set the dialog's edit control to the filename part of path
         * string.
         */
        SetDlgItemText (hwnd, IDD_FILENAME, pch2);
    }
    else
    {
        /* The filename in the property list is not a wildcard */
        if (FileExists (pch)){

            RemoveProp (hwnd, PROP_FILENAME);
            EndDialog (hwnd, 0);
        }
        else{
            MPError ( hwnd, MB_OK | MB_SYSTEMMODAL, IDS_CANTOPEN, (LPSTR) pch);
            SetActiveWindow (hwnd);
        }
    }
}


/****************************************************************************
 *                                                                          *
 *  FUNCTION   : GetFilename ( pstr )                                       *
 *                                                                          *
 *  PURPOSE    : Gets a filename from the user by calling the File/Open     *
 *               dialog.                                                    *
 *                                                                          *
 ****************************************************************************/
VOID APIENTRY GetFileName(PSTR pstr)
{
#ifdef NOTCOMMONDIALOGS
    DialogBoxParam (hInst, IDD_FILEOPEN, hwndFrame, FileOpenDlgProc, (LONG)pstr);
#else
    OPENFILENAME ofn;
    CHAR szFilterSpec [128] =                       /* file type filters */
             "TEXT FILES(*.TXT)\0*.TXT\0";

    #define MAXFILENAME 256
    CHAR szFileName[MAXFILENAME];
    CHAR szFileTitle[MAXFILENAME];

    strcpy(szFileName, "");   /* these need be NULL*/
    strcpy(szFileTitle, "");

    /* fill in non-variant fields of OPENFILENAME struct. */
    ofn.lStructSize       = sizeof(OPENFILENAME);
    ofn.hwndOwner         = NULL;
    ofn.lpstrFilter       = szFilterSpec;
    ofn.lpstrCustomFilter = NULL;
    ofn.nMaxCustFilter    = 0;
    ofn.nFilterIndex      = 0;
    ofn.lpstrFile         = szFileName;
    ofn.nMaxFile          = MAXFILENAME;
    ofn.lpstrInitialDir   = NULL;
    ofn.lpstrFileTitle    = szFileTitle;
    ofn.nMaxFileTitle     = MAXFILENAME;
    ofn.lpstrTitle        = "Open TextFiles";
    ofn.lpstrDefExt       = "TXT";
    ofn.Flags             = OFN_FILEMUSTEXIST;
    /* Use standard open dialog */
    if (!GetOpenFileName ((LPOPENFILENAME)&ofn)){
        *pstr = 0;
        MessageBox(hwndFrame, " FileOpen FAILed!", "RIS Interactive", MB_OK | IDOK);
    }
    else{
        strcpy(pstr, ofn.lpstrFile);
    }
 
#endif
   return;

}

