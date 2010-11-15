// 1996.04.09:Alan Barksdale:This file is modified from csource\remove.c in
//	Setup SDK 02.03.01.02.

/******************************************************************************

    FILE

        remove.c 

    DESCRIPTION

        This file contains all the code for the remove executables for NT
        Intergraph Products.


    FUNCTIONS

        WinMain
        WndProc
        RmtOnActivate
        RmtOnSize
        RmtOnPaint
        RmtDrawFadeRect
        RmvCenterWindow

******************************************************************************/

#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <windowsx.h>
#include <commdlg.h>
#include <dlgs.h>   

#include "isdk.h"
#include "remove.h"
#include "ingrrmv.h"
#include "cuirsc.h"

#include "interop.h"
#include "msregdb.h"
#include "msshared.h"
#include "reglib.h"
#include "rmlib.h"
#include "risrem.h"
#include "setupapi.h"
#include "intrem.h"
#include "intstg.h"
#include "risver.h"

static HWND curdlg = NULL;
static HWND mainwin = NULL;
static HBITMAP bitmap = NULL;
HINSTANCE Instance = NULL;
static PCHAR apptitle = NULL;
static BOOL activated = FALSE;
static LONG exitstatus = RMV_CONTINUE;



/*
** This function is the TimerProc function called when the time-out value
** specified in the SetTimer function expires.  This function forces an exit
** of the program.  We use it so a message box can be displayed and dismissed
** without user intervention for silent mode (batch) operation.
*/

static TIMERPROC TimerExit (HWND hwnd,
                            UINT uMsg,
                            UINT idEvent,
                            DWORD dwTime)
{
    KillTimer (hwnd, idEvent);
    exit (RMV_TIMER);
    return (FALSE);
}


// 1996.02.27:Alan Barksdale:Is this function needed?
BOOL APIENTRY LibMain(HINSTANCE hDLL, DWORD dwReason, LPVOID lpReserved)
{
    return(TRUE);

}

/******************************************************************************

    SYNOPSIS

        INT WINAPI WinMain (HINSTANCE hInst,
                            HINSTANCE hPrevInst,
                            LPTSTR lpszLine,
                            INT nShow)

    PARAMETERS
    
        NAME        ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----        --------------------------------------------------------

        hInst       (I)     Handle to current instance of program.
        hPrevInst   (I)     Handle to previous instance of program.
        lpszLine    (I)     Command line string.
        nShow       (I)     Window show mode parameter.
    
    RETURN VALUE

        0

    DESCRIPTION

        WinMain is the main for the remove program. It is called by Windows
        when remove is run in the same way as a main would be called in a
        non-Windows program. In this case, the main creates an application
        window and displays it. It then goes into a message loop which
        terminates after the product has been removed.
        
    CHANGE HISTORY

        08/12/93    jar    Initial Definition.
        09-MAR-1994 mwm    call GetCommandLine() instead of using lpszLine
                           from WinMain
            
******************************************************************************/

INT WINAPI WinMain (HINSTANCE hInst,
                    HINSTANCE hPrevInst,
                    LPTSTR lpszLine,
                    INT nShow)
{
    /* 1996.04.09:vvv Alan Barksdale:Resources are linked in during compilation.
    CHAR dllname[_MAX_PATH];
    1996.04.09:Alan Barksdale:^^^ */

    INT argc;

    HINSTANCE rDll = NULL;

    /* 1996.04.09:vvv Alan Barksdale:Resources are linked in during compilation.
    LANGID langid;
    1996.04.09:Alan Barksdale:^^^ */

    WCHAR cVersionSwitch; // command line argument version display switch
    
    LPTSTR fname = NULL;
    LPTSTR pname = NULL;
    LPTSTR tname = NULL;
    
    LPWSTR wstr;
    LPWSTR *wargv;
    
    MSG msg;

    UINT emode;

    WNDCLASS rmtclass;

    
    /*
    ** Initialize our resource information.  The information gathered by this
    ** function is used extensively throughout the remainder of this program.
    ** See ingrrmv.c for details.
    **
    ** The first if-block below tries to load language keyed dll's in the 
    ** uixxxx.dll format.  This will handle any dlls delivered to a root 
    ** directory of an "admin" install when this program is run from a
    ** workstation installation.  Substitute the appropriate format for
    ** the "dialogs.dll" name if you deliver a unique dll name to handle
    ** your resources.
    **
    ** The second if-block tries to load language keyed dll's that have been
    ** delivered and renamed in the rmxxxxx.dlx format. This will handle any 
    ** standalone installations.  If you deliver and rename remove dll's
    ** substitue the appropriate name for the "rm000014" name below (000014
    ** is the product index used for SetupSDK). 
    */

    emode = SetErrorMode(SEM_NOOPENFILEERRORBOX|SEM_FAILCRITICALERRORS);

    /* 1996.04.09:vvv Alan Barksdale:Resources are linked in during compilation.
    langid = GetSystemDefaultLangID();
    wsprintf (dllname, 
              "ui%04x.dll", 
              langid);

    if ( ! (rDll = LoadLibraryEx (dllname,
                                  NULL,
                                  LOAD_LIBRARY_AS_DATAFILE)) ) {

        langid = MAKELANGID (PRIMARYLANGID (langid), SUBLANG_NEUTRAL);
        wsprintf (dllname, 
                  "ui%04x.dll", 
                  langid);
        
        if ( ! (rDll = LoadLibraryEx (dllname,
                                      NULL,
                                      LOAD_LIBRARY_AS_DATAFILE)) ) {

            rDll = LoadLibraryEx ("dialogs.dll",
                                  NULL,
                                  LOAD_LIBRARY_AS_DATAFILE);
        }
    }

    if ( ! rDll ) {

        if ( ! (rDll = LoadLibraryEx ("rm000014" ".dl1",
                                      NULL,
                                      LOAD_LIBRARY_AS_DATAFILE)) ) {
            
            if ( ! (rDll = LoadLibraryEx ("rm000014" ".dl2",
                                          NULL,
                                          LOAD_LIBRARY_AS_DATAFILE )) ) {
                
                rDll = LoadLibraryEx ("rm000014" ".dl3",
                                      NULL,
                                      LOAD_LIBRARY_AS_DATAFILE);
                
            }
        }
    }
    1996.04.09:Alan Barksdale:^^^ */

    SetErrorMode (emode);

    RMVResourceInitializeEx (rDll);
    
    remInstance = Instance = hInst;
    bitmap = LoadBitmap (hInst, MAKEINTRESOURCE(IDB_INGR));
    /* TR#439602540 - Melania M Stewart - The title was blank
    apptitle = RMVGetTitle();
     */
    apptitle=ISDKLoadString (hInst, IDS_CONFIGURE_RIS) ;

    /* 1996.02.27:vvv Alan Barksdale:See below.
    //******************************************************************
    //  The if statement was added to fix TR # 439501525.  The version 
    //  option was added.    GBF (9/27/95)                              
    //******************************************************************
    if((strcmp(lpszLine,"/V") == 0) || (strcmp(lpszLine,"-V") == 0))
    {
      MessageBox(NULL,RIS_VERSION_STR,"Version",MB_OK); 
      exit(1);
    }    
           
    strncpy(apptitle, GetResourceString(remInstance,IDS_CONFIGURE_RIS), RMT_MAX_STRLEN - 1);

    bitmap = LoadBitmap (hInst, "IngrBitmap");
    1996.02.27:^^^ Alan Barksdale */

    /*
    ** Determine the proper command line usage.  Only one optional command 
    ** line argument is accepted.  This argument turns on the silent mode 
    ** operation--product removal without the display of message boxes.
    ** In order to display the program name as part of the usage message box,
    ** return our executable name and locate the filename part.  
    */

    fname = ISDKGetModuleFileName (NULL);
    tname = ISDKGetFullPathName (fname, &pname);

    /*
    ** GetCommandLine() returns the full command line.  The first argument is
    ** the module name, the second argument is the silent switch, if present.
    */

    wstr = ISDKGetWideString (GetCommandLine());

    ISDKParseLineW (wstr, &argc, &wargv, 0, 0);

    if ( argc == 1 ) {
        RMVSetSilentMode (FALSE);
    } else if ( argc > 2 ) {
        RMVSetSilentMode (FALSE);
//        usage_err (pname);
    } else {

        if ( (wargv[1][0] == RMVGetSwitchFlag1()) ||
             (wargv[1][0] == RMVGetSwitchFlag2()) ) {

            mbtowc (&cVersionSwitch, "V", MB_CUR_MAX);

//            if ( wargv[1][1] == RMVGetSilentSwitch() ) {
//                RMVSetSilentMode (TRUE);
            /*} else*/ if ( wargv[1][1] == cVersionSwitch ) {
                MessageBox(NULL,RIS_VERSION_STR,"Version",MB_OK); 
                exit(1);
            } /*else {
                usage_err (pname);
            }*/
//        } else {
//            usage_err (pname);
        }
    }
    
    /* Register the application class */
    
    rmtclass.style =  CS_HREDRAW | CS_VREDRAW;
    rmtclass.lpfnWndProc = (WNDPROC) WndProc;
    rmtclass.cbClsExtra = 0;
    rmtclass.cbWndExtra = 0;
    rmtclass.hInstance = hInst;
    rmtclass.hIcon = LoadIcon (hInst, "InteropIcon");
    rmtclass.hCursor = LoadCursor (NULL, IDC_ARROW);
    rmtclass.hbrBackground = CreateSolidBrush (RGB (0,0,255));
    rmtclass.lpszMenuName = NULL;
    rmtclass.lpszClassName = "Remove";

    RegisterClass (&rmtclass);

    mainwin = CreateWindow ("Remove", apptitle, WS_OVERLAPPEDWINDOW, WIN_XORG,
                            WIN_YORG, WIN_WIDTH, WIN_HEIGHT, NULL,
                            (HMENU) NULL, hInst, NULL);
        ShowWindow (mainwin, SW_SHOWMAXIMIZED);
    UpdateWindow (mainwin);

    /* Process messages until done */
    
    while (GetMessage(&msg, NULL, 0, 0))
    {
        if (! IsDialogMessage (curdlg, &msg))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    /* Perform cleanup operations */
    
    DestroyWindow (mainwin);
    UnregisterClass ("Remove", hInst);

    if ( rDll ) FreeLibrary (rDll);

    return (exitstatus);
}


/******************************************************************************

    SYNOPSIS

        LONG APIENTRY WndProc (HWND msgwin,
                               UINT wMsg,
                               WPARAM wParam,
                               LONG lParam)

    PARAMETERS
    
        NAME        ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----        --------------------------------------------------------

        msgwin      (I)     Application's main window.
        wMsg        (I)     Message to process
        wParam      (I)     Word parameter of message.
        lParam      (I)     Long parameter of message.
    
    RETURN VALUE

        Return from message handler that handles message.

    DESCRIPTION

        WndProc is the message handler function for the main application
        window. It only handles WM_PAINT and WM_ACTIVATE messages. It
        passes any other messages to the default handler (DefWindowProc).
        
    CHANGE HISTORY

        08/12/93    (jar)    Initial Definition.
            
******************************************************************************/

LONG APIENTRY WndProc(HWND msgwin,
                      UINT wMsg,
                      WPARAM wParam,
                      LONG lParam)
{

    /* Use message crackers to distribute messages to handlers */
    
    switch (wMsg)
    {
        HANDLE_MSG (msgwin, WM_PAINT, RmtOnPaint);
        HANDLE_MSG (msgwin, WM_SIZE, RmtOnSize);
        HANDLE_MSG (msgwin, WM_ACTIVATE, RmtOnActivate);

        case WM_DESTROY:
          PostQuitMessage (0);

        case WM_NCACTIVATE:                             // Fall Through
            if (curdlg) SendMessage (curdlg, wMsg, wParam, lParam);

        default:
            return(DefWindowProc(msgwin, wMsg, wParam, lParam));
    }
}



/******************************************************************************

    SYNOPSIS
    
        void RmtOnActivate (HWND msgwin,
                            UINT state,
                            HWND act_deact,
                            BOOL minimized)

    PARAMETERS
    
    NAME            ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
    ----            --------------------------------------------------------

    msgwin          (I)     Application main window.
    state           (I)     New activation state.
    act_deact       (I)     Window deactivated/activated as a result of
                            msgwin's change of state.
    minimized       (I)     Minimized flag.
                            
    RETURN VALUE

        None.
        
    DESCRIPTION

        RmtOnActivate is used as a "one-shot". The first activation triggers
        the creation of a the welcome dialog for the remove program. The
        dialog is defined in the resource file for the product.
        
    CHANGE HISTORY

        08/12/93    (jar)    Initial Definition.
        09/08/93    (jdb)    Added check for admin privilage for removal.
    
******************************************************************************/

VOID RmtOnActivate (HWND msgwin,
                    UINT state,
                    HWND act_deact,
                    BOOL minimized)
{
    BOOL admin = TRUE;
    LPCTSTR args[2];

    if (FALSE == activated) {

        activated = TRUE;

        if ( ! ISDKMatchPlatform (ISm_WIN32S | ISm_CHICAGO) ) {

            admin = ISDKCheckForAdministrator();

        }
        
        if ( admin ) {

            InteropRemoveRIS(mainwin, remInstance);
/* unused
            if ( ! RMVGetSilentMode () ) {
                curdlg = CreateDialog (Instance, 
                                       MAKEINTRESOURCE(DLG_RMV_WELCOME),
                                       mainwin,
                                       (DLGPROC) RmtWelcomeDlgProc);
                UpdateWindow (mainwin);
                SendMessage (curdlg, WM_NCACTIVATE, (WPARAM) TRUE, (LPARAM) 0);

            } else {

                CallRemoveFns (mainwin, apptitle, NULL, NULL);
*/
                PostQuitMessage (0);
/* unused
            }
*/

        } else {
            
            /*
            ** The user is required to be in the administrator group.  We 
            ** will take advantage of the SetTimer function to display and 
            ** dismiss this message box if the silentmode has been set.  
            ** This allows the program to be executed in a batch mode 
            ** without hanging.
            */
            
            args[0] = ISDKLoadString (RMVGetResourceDll(), IDS_TITLE);
            args[1] = ISDKLastErrorText (RMVGetLangId(), RMVMESSAGELEN);
            
            if ( RMVGetSilentMode () ) {
                SetTimer (NULL, 1, RMVGRACETIMER, (TIMERPROC)TimerExit);
            }
            
            ISDKStringIdBox (msgwin,
                             RMVGetResourceDll(),
                             args,
                             ADMINISTRATOR_ERROR,
                             RMVGetLangId(),
                             RMVGetTitle(),
                             RMVMESSAGELEN,
                             MB_ICONSTOP);
            
            if (args[0]) LocalFree ((HLOCAL)args[0]);
            if (args[1]) LocalFree ((HLOCAL)args[1]);
            
            exit (RMV_ABORT);
        }
    } 
}


/******************************************************************************

    SYNOPSIS
    
        void RmtOnSize (HWND msgwin,
                        UINT state,
                        INT  cx,
                        INT  cy)

    PARAMETERS
    
        NAME        ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----        --------------------------------------------------------

        msgwin      (I)     Application main window.
        state       (I)     New activation state.
        cx          (I)     New window x size
        cy          (I)     New window y size
                            
    RETURN VALUE

        None.
        
    DESCRIPTION

        RmtOnSize is used to re-center the dialogs when the size of
        the main window changes.
        
    CHANGE HISTORY

        08/25/93    (jar)    Initial Definition.
            
******************************************************************************/

void RmtOnSize (HWND msgwin,
                UINT state,
                INT  cx,
                INT  cy)
{
    if (curdlg != NULL)  ISDKCenterWindow (msgwin, curdlg);
}


/******************************************************************************

    SYNOPSIS

        void RmtOnPaint (HWND msgwin)

    PARAMETERS
    
        NAME        ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----        --------------------------------------------------------

        msgwin      (I)     Application's main window.
    
    RETURN VALUE

        None.
        
    DESCRIPTION

        RmtOnPaint is called whenever the main window gets a WM_PAINT
        message. RmtOnPaint will draw a blue to black fading background
        and an Intergraph logo. The result is meant to look like the
        main window of the Setup program.
    
    CHANGE HISTORY

        08/14/93    (jar)    Initial Definition.
            
******************************************************************************/

void RmtOnPaint (HWND msgwin)

{
    HDC hdc;
    HDC bmpdc;
    PAINTSTRUCT ps;
    RECT client;
    INT width;
    INT height;
    RmtColor color1;
    RmtColor color2;

    hdc = BeginPaint (msgwin, &ps);

    /* Find the current size of the client area */
    
    GetClientRect (msgwin, &client);
    width = client.right;
    height = client.bottom;

    /* Draw the client area as color1 fading to color2 */
    /* Blue fading to black seems to be the "standard" */

    color1.red = 0;    color1.green = 0;    color1.blue = 255;
    color2.red = 0;    color2.green = 0;    color2.blue = 0;

    RmtDrawFadeRect (hdc, width, height, 50, &color1, &color2);

    /* Draw the INTERGRAPH logo in the upper left corner */
    
    bmpdc = CreateCompatibleDC (hdc);
    SelectObject (bmpdc, bitmap);
    BitBlt (hdc, 4, 4, 300, 100, bmpdc, 0, 0, 0x220326);
    BitBlt (hdc, 0, 0, 300, 100, bmpdc, 0, 0, SRCPAINT);
    DeleteDC (bmpdc);

    EndPaint (msgwin, &ps);
}


/******************************************************************************

    SYNOPSIS

        void RmtDrawFadeRect (HDC hdc,
                              INT width,
                              INT height,
                              INT divisions,
                              RmtColor *color1,
                              RmtColor *color2)

    PARAMETERS
    
        NAME        ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----        --------------------------------------------------------

        hdc         (I)     Handle to dc to draw rectangle.
        width       (I)     Width of rectangle to draw.
        height      (I)     Height of rectangle to draw.
        divisions   (I)     Number of vertical divisions to divide the
                            rectangle into.
        color1      (I)     RGB color of top division.
        color2      (I)     RGB color of bottom division.
    
    RETURN VALUE

        None.
        
    DESCRIPTION

        RmtDrawFadeRect will fill in the given rectangle with a "fade" from
        color1 to color2. The first division will be color1, the last
        will be color2, and those in between will be in between.
        
    CHANGE HISTORY

        08/14/93    (jar)    Initial Definition.
            
******************************************************************************/

void RmtDrawFadeRect (HDC hdc,
                      INT width,
                      INT height,
                      INT divisions,
                      RmtColor *color1,
                      RmtColor *color2)
{
    FLOAT dy;
    INT i, yend;
    INT xorg, yorg;
    INT xsize, ysize;
    HBRUSH shade;    
    BYTE red, green, blue;

    xsize = width;
    xorg = yorg = 0;

    dy = ((float) height) / ((float) divisions);

    /* Draw each division */
    
    for (i = 0; i < divisions; i++) {

        /* Compute the color for the division and create a brush to draw it. */

        red = (BYTE) BLEND (color1->red,color2->red,divisions,i);
        green = (BYTE) BLEND (color1->green,color2->green,divisions,i);
        blue = (BYTE) BLEND (color1->blue,color2->blue,divisions,i);

        shade = CreateSolidBrush (RGB (red,green,blue));
        shade = SelectObject (hdc, shade);

        /* Draw the division */
        
        yend = ((int) (((float) (i + 1)) * dy)) + 1;
        ysize = yend - yorg;
        BitBlt (hdc, xorg, yorg, xsize, ysize, NULL, 0, 0, PATCOPY);
        yorg = yend;

        /* Set the brush to its previous value and delete the brush that */
        /* was just created.                                             */
        
        shade = SelectObject (hdc, shade);
        DeleteObject (shade);
    }
}


/******************************************************************************

    SYNOPSIS

        VOID RmtCenterWindow (HWND parent,
                              HWND child)


    PARAMETERS
    
        NAME        ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----        --------------------------------------------------------

        parent      (I)     Handle of parent window to center child in.
        child       (I)     Handle of child to be centered with respect to
                            the parent.

    RETURN VALUE

        None.

    DESCRIPTION

        RmtCenterWindow will center the child window within the parent.

    CHANGE HISTORY

        08/25/93    (jar)    Initial Definition.
                
******************************************************************************/

VOID RmtCenterWindow (HWND parent,
                      HWND child)

{
    RECT prect;
    RECT crect;
    INT  parent_xsize;
    INT  parent_ysize;
    INT  child_xsize;
    INT  child_ysize;
    INT  child_xorg;
    INT  child_yorg;
    
    if (GetClientRect (parent, &prect)) {

        parent_xsize = (int) (prect.right - prect.left);
        parent_ysize = (int) (prect.bottom - prect.top);
        
        if (GetWindowRect (child, &crect)) {

            child_xsize = (int) (crect.right - crect.left);
            child_ysize = (int) (crect.bottom - crect.top);

            child_xorg = (parent_xsize - child_xsize) / 2;
            child_yorg = (parent_ysize - child_ysize) / 2;

            child_xorg = MAX (child_xorg, 0);
            child_yorg = MAX (child_yorg, 0);

            SetWindowPos (child, HWND_TOP, child_xorg, child_yorg,
                          0, 0, SWP_NOSIZE);
        }
    }
}

