/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcodbg.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   GUI Debug Functions

Revision History:

********************************************************************/
/*
	Thanks to Kevin P. Welch for his program that appeared in MSJ vol 3 no3
	and to Grady Dill for the processing of the RISdbg.ini file
*/
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <memory.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>
#include <time.h>
#include <windows.h>
#include <windowsx.h>
#include "gcodbg.h"
#include "resource.h"
#include "gco.h"

#define gcodbg_c
#include "gcodbg.prt"
#include "gcortns.prt"

char appnameID[80];
char HomeDir[255];
char	szLogFile[64];	/* debug log file name */

/* internal macros */
#define TOGGLE(x,y)	CheckDlgButton(x,y,!IsDlgButtonChecked(x,y))
#define ENABLE(x,y,z)	EnableWindow(GetDlgItem(x,y),z)

/* general definitions */
#define SHARED		S_IREAD|S_IWRITE
#define MODE_APPEND	O_RDWR|O_APPEND|O_BINARY	
#define MODE_CREATE	O_RDWR|O_CREAT|O_BINARY

/* listbox viewport definitions */
#define PORT_X		20	/* viewport x origin */
#define PORT_Y		40	/* viewport y origin */
#define PORT_WIDTH	600	/* viewport width */
#define PORT_HEIGHT	144	/* viewport height */

/* debug statement data structure */
#define MAX_FILTER	32	/* maximum filter categories */

typedef struct
{
	/* general options */
	BOOL	bSetup;		/* debug setup flag */
	BOOL	bActive;	/* debug active flag */
	
	/* count options */
	BOOL	bCount;		/* count events flag */
	LONG	lMsgCount;	/* debug message count */

	/* display options */
	BOOL	bDisplay;	/* display debug events */
	HWND	hListBox;	/* listbox window handle */
	WORD	wEntries;	/* current listbox lines */
	WORD	wMaxEntries;	/* maximum listbox lines */

	/* file names/line numbers */
	BOOL bFileLine;

	/* filter options */
	BOOL	bFilter;	/* filter debug events */
	WORD	wFilterSize;	/* size of categories */
	WORD	Filter[MAX_FILTER];	/* list of categories */

	/* log-file options */
	BOOL	bLog;		/* log debug events */

} OPTIONS;

/* global data definitions */
static OPTIONS	Options;

#define MAX_LINES 30000

/****************************************************************************
_InitDebug
****************************************************************************/
extern BOOL _InitDebug(
	int argc,
	char **argv,
	HWND hwnd,
	char *ProgramID)
{
BOOL bOk;		/* boolean result */
char DebugIniFile[128], *ptr1, *ptr2, intstr[10], strng[128];
WORD	x;
OFSTRUCT of;
int i;
char   szModuleName[255];
int nGDebugOn=FALSE;
int nRDebugOn=FALSE;

	GetModuleFileName(gco.hhInst, szModuleName, sizeof(szModuleName));
	argv[0] = szModuleName;
	
	for (i=0; i<argc; i++)
	{
		if (strcmp(argv[i],"-db") ==0)
		{
			nRDebugOn = TRUE;
		}

		if (strcmp(argv[i],"-d") ==0)
		{
			nGDebugOn = TRUE;
		}
	}
	if (nRDebugOn == TRUE || nGDebugOn == TRUE)
	{
		_AddDebugMenu(hwnd);

			_DEBUG(PROG,2,"argc=%d argv=%s",i,(LPSTR)argv[i]);
			_Debug(PROG,2,"Homedir=<%s>",_GetHomeDir(gco.hhInst));
//			_InitializeDebug( hwnd, IDM_GUI_DEBUG, 30000,ProgramId );
//			_DebugControlPanel( gco.hhLib,hwnd,TRUE );
	}
	strcpy(appnameID,ProgramID);
	strcpy(HomeDir,_GetHomeDir(gco.hhInst));

	/* boolean result */
	bOk = FALSE;

	/* check if debug already activated */
	if(!Options.bSetup)
	{
			/* create listbox window -initially hidden */
			Options.hListBox = CreateWindow(
				"LISTBOX",		/* class name */
				"",				/* window caption */
				WS_THICKFRAME|WS_VSCROLL|WS_HSCROLL,	/* window style */
				PORT_X,			/* x position */
				PORT_Y,			/* y position */
				PORT_WIDTH,		/* width */
				PORT_HEIGHT,	/* height */
				NULL,			/* parent window */
				NULL,			/* menu */
				gco.hhInst,
				(LPSTR)NULL		/* other data */
				);
			/* continue if successful */
			if(Options.hListBox)
			{
				/* define options data */
				bOk = TRUE;
				Options.bSetup = TRUE;
				Options.wMaxEntries = MAX_LINES;
				SendMessage(Options.hListBox,
					LB_SETHORIZONTALEXTENT, 3 * PORT_WIDTH, 0L);

				/* define default log file name */
				wsprintf((LPSTR)szLogFile, "%s.LOG",appnameID);

				/* Does a RISdbg.INI file reside in directory of applicaiton? */
				wsprintf(DebugIniFile,"%s\\RISdbg.ini",(LPSTR)HomeDir);

				if (OpenFile(DebugIniFile,&of,OF_EXIST) != -1)
				{
					/* INI file does exist, read info from it. */
					Options.bActive = GetPrivateProfileInt(appnameID,
						"DebugActive", 0, DebugIniFile);
					Options.bCount = GetPrivateProfileInt(appnameID,
						"CountEvents", 0, DebugIniFile);
					Options.bDisplay = GetPrivateProfileInt(appnameID,
						"DisplayInBox", 0, DebugIniFile);
					Options.bFileLine = GetPrivateProfileInt(appnameID,
						"Filename_LineNumber", 0, DebugIniFile);
					Options.bFilter = GetPrivateProfileInt(appnameID,
						"FilterActive", 0, DebugIniFile);
					Options.wFilterSize = GetPrivateProfileInt(appnameID,
						"FilterSize", 0, DebugIniFile);
					GetPrivateProfileString(appnameID, "Filter", "",
						strng, sizeof(strng), DebugIniFile);
					if(Options.wFilterSize > 0 && lstrlen((LPSTR)strng))
					{
						ptr1 = strng;
						for(x = 0 ; x < Options.wFilterSize ; x++)
						{
							ptr2 = strchr(ptr1, ',');
							if(ptr2 == NULL)
							{
								ptr2 = strchr(ptr1, '\0');
							}
							memset(intstr, '\0', sizeof(intstr));
							strncpy(intstr, ptr1, ptr2 - ptr1);
							Options.Filter[x] = atoi(intstr);
							ptr1 = ptr2 + 1;
						} /* for */
					}
					else
					{
						Options.bFilter = 0;
						for(x = 0 ; x < Options.wFilterSize ; x++)
						{
							Options.Filter[x] = 0;
						} /* for */
						Options.wFilterSize = 0;
					} /* if - else */
					Options.bLog = GetPrivateProfileInt(appnameID,
						"LogActive", 0, DebugIniFile);
				wsprintf((LPSTR)szLogFile, "%s.LOG",appnameID);
				}
			}
	} 
	if (nGDebugOn == TRUE)	
		_DebugControlPanel( gco.hhLib,hwnd,TRUE );
	_DEBUG(PROG,2,"Appname=%s",(LPSTR)ProgramID);
			i = _GetPlatform();
			switch (i)
			{
				case IS_WIN32:
					_Debug(PROG,2,"Platform %d = NT 3.1",i);
					break;
				case IS_DAYTONA:
					_Debug(PROG,2,"Platform %d = NT 3.5",i);
					break;
				case IS_WIN32S:
					_Debug(PROG,2,"Platform %d = Win32s",i);
					break;
				case IS_CHICAGO:
					_Debug(PROG,2,"Platform %d = Windows95",i);
					break;
			}
	return(bOk);	/* return final result */
	
} /* _InitDebug */

/****************************************************************************
_DebugControlPanel
****************************************************************************/
extern BOOL _DebugControlPanel(
	HINSTANCE hInst,
	HWND hWnd,
	BOOL bCommandLine)
{
BOOL		bResult;		/* boolean result value */

	/* display dialog box */
	bResult = DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_GDEBUG),hWnd, (DLGPROC)DebugControlDlg);

	/* return final result */
	return(bResult);
	
} /* _DebugControlPanel */

static LRESULT CALLBACK DebugControlDlg(HWND hDlg, UINT wMsg, WPARAM wParam, LPARAM lParam)
{
BOOL	bResult;	/* boolean result variable */
WORD	i;			/* loop variable */
int		xPopup;		/* popup x position */
int		yPopup;		/* popup y position */
int		cxPopup;	/* width of popup window */
int		cyPopup;	/* height of popup window */
RECT	rectWnd;	/* temporary window rect */
char	szToken[8];	/* character token */
char	szFilterList[64];	/* filter list string */
char	*spToken;
char	szCaption[64];
OFSTRUCT of;

	/* initialization */
	bResult = TRUE;
	ENABLE(hDlg, BUG_LOGFILE, FALSE);

	/* process message */
	switch(wMsg)
	{
	case WM_INITDIALOG:	/* initialize dialog box */
		{
			/*
				The following code centers the dialog box in the
				middle of the screen.  It uses the dimensions of 
				the display and the dialog box and repositions the
				dialog box accordingly.
			*/
			
			/* retrieve popup rectangle  */
			GetWindowRect(hDlg, (LPRECT)&rectWnd);
			
			/* calculate popup extents */
			cxPopup = rectWnd.right - rectWnd.left;
			cyPopup = rectWnd.bottom - rectWnd.top;
	
			/* calculate new location & move dialog box */
			xPopup = (GetSystemMetrics(SM_CXSCREEN) - cxPopup) / 2;
			yPopup = (GetSystemMetrics(SM_CYSCREEN) - cyPopup) / 2;
			MoveWindow(hDlg, xPopup, yPopup, cxPopup, cyPopup, TRUE);

			/* define filter list */
			szFilterList[0] = 0;
			if(Options.wFilterSize)
			{
				wsprintf((LPSTR)szFilterList, "%u", Options.Filter[0]);
				for(i = 1 ; i < Options.wFilterSize ; i++)
				{
					wsprintf((LPSTR)szToken, ",%u", Options.Filter[i]);
					lstrcat((LPSTR)szFilterList, szToken);
				} /* for */
			}
			
			/* check ON-OFF radio buttons */
			CheckRadioButton(hDlg, BUG_OFF, BUG_ON, (Options.bActive) ? BUG_ON :BUG_OFF);
		
			/* define check boxes */
			CheckDlgButton(hDlg, BUG_COUNT, Options.bCount);
			CheckDlgButton(hDlg, BUG_DISPLAY, Options.bDisplay);
			CheckDlgButton(hDlg, BUG_FILE_LINE, Options.bFileLine);
			CheckDlgButton(hDlg, BUG_FILTER, Options.bFilter);
			CheckDlgButton(hDlg, BUG_LOG, Options.bLog);
	
			/* display filter categories & log file name */
			SetDlgItemText(hDlg, BUG_FILTERLIST, szFilterList);
			SetDlgItemText(hDlg, BUG_LOGFILE, szLogFile);
		
			/* disable check boxes & edit fields if debug inactive */
			if(!Options.bActive)
			{
				/* disable check boxes */
				ENABLE(hDlg, BUG_COUNT, FALSE);
				ENABLE(hDlg, BUG_DISPLAY, FALSE);
				ENABLE(hDlg, BUG_FILTER, FALSE);
				ENABLE(hDlg, BUG_LOG, FALSE);

				/* disable edit fields */
				ENABLE(hDlg, BUG_FILTERLIST, FALSE);
			}
			else
			{
				/* enable edits field */
				ENABLE( hDlg, BUG_FILTERLIST, IsDlgButtonChecked(hDlg,BUG_FILTER));
//				ENABLE( hDlg, BUG_LOGFILE, IsDlgButtonChecked(hDlg,BUG_LOG));
			} /* if - else */

		} /* WM_INITDIALOG */
		break;

	case WM_COMMAND:	/* dialog box command */
		{
			switch(wParam) /* process sub-message */
			{
			case BUG_ON: /* turn debug on */
				{
					/* redefine radio button */
					CheckRadioButton(hDlg, BUG_OFF, BUG_ON, BUG_ON);

					/* enable check boxes */
					ENABLE(hDlg, BUG_COUNT, TRUE);
					ENABLE(hDlg, BUG_DISPLAY, TRUE);
					ENABLE(hDlg, BUG_FILTER, TRUE);
					ENABLE(hDlg, BUG_LOG, TRUE);
				
					/* enable edits field */
					ENABLE(hDlg, BUG_FILTERLIST, IsDlgButtonChecked(hDlg,BUG_FILTER));
//					ENABLE(hDlg, BUG_LOGFILE, IsDlgButtonChecked(hDlg,BUG_LOG));
					
				}
				break;
				
			case BUG_OFF: /* turn debug off */
				{
					/* redefine radio button */
					CheckRadioButton(hDlg, BUG_OFF, BUG_ON, BUG_OFF);
								
					/* enable check boxes */
					ENABLE(hDlg, BUG_COUNT, FALSE);
					ENABLE(hDlg, BUG_DISPLAY, FALSE);
					ENABLE(hDlg, BUG_FILTER, FALSE);
					ENABLE(hDlg, BUG_LOG, FALSE);

					/* enable edit fields */
					ENABLE(hDlg, BUG_FILTERLIST, FALSE);
//					ENABLE(hDlg, BUG_LOGFILE, FALSE);
				}
				break;

			case BUG_COUNT: /* count debug events */
				{
					TOGGLE(hDlg, BUG_COUNT);						
				}
				break;
						
			case BUG_DISPLAY: /* display debug events */
				{
					TOGGLE(hDlg, BUG_DISPLAY);
				}
				break;
				
			case BUG_FILE_LINE: /* filter debug events */
				{
					TOGGLE(hDlg, BUG_FILE_LINE);
				}
				break;

				case BUG_FILTER: /* filter debug events */
				{
					TOGGLE(hDlg, BUG_FILTER);
					ENABLE(hDlg, BUG_FILTERLIST, IsDlgButtonChecked(hDlg,BUG_FILTER));
				}
				break;

				
			case BUG_LOG: /* log debug events */
				{
					TOGGLE(hDlg, BUG_LOG);
//					ENABLE(hDlg, BUG_LOGFILE, IsDlgButtonChecked(hDlg,BUG_LOG));
				}
				break;
				
			case BUG_OK: /* done with debug control panel */
				{
				char	DebugIniFile[128], tempstr[15];
				HFILE	hFile;
	
					/* capture radio button state */
					Options.bActive = IsDlgButtonChecked(hDlg, BUG_ON);

					/* capture check box states */
					Options.bCount   = IsDlgButtonChecked(hDlg, BUG_COUNT);
					Options.bDisplay = IsDlgButtonChecked(hDlg,BUG_DISPLAY);
					Options.bFileLine = IsDlgButtonChecked(hDlg,BUG_FILE_LINE);
					Options.bFilter  = IsDlgButtonChecked(hDlg,BUG_FILTER);
					Options.bLog     = IsDlgButtonChecked(hDlg, BUG_LOG);

					/* capture filter list changes - no limit checking! */
					GetDlgItemText(hDlg, BUG_FILTERLIST, szFilterList, sizeof(szFilterList));

					Options.wFilterSize = 0;
					spToken = strtok(szFilterList, " ,;");
					while(spToken)
					{
						Options.Filter[Options.wFilterSize++] = atoi(spToken);
						spToken = strtok(NULL, " ,;");
					} /* while */

					/* capture log file changes */
					GetDlgItemText(hDlg, BUG_LOGFILE, szLogFile, sizeof(szLogFile));
						
					/* display listbox if necessary */
					if(Options.bActive)
					{
						/* update viewport window caption */
						if(Options.bFilter && Options.wFilterSize)
						{
							/* define filter list */
							szFilterList[0] = 0;
							if(Options.wFilterSize)
							{
								wsprintf((LPSTR)szFilterList, "%u", Options.Filter[0]);
								for(i = 1 ; i < Options.wFilterSize ; i++)
								{
									wsprintf((LPSTR)szToken, ",%u", Options.Filter[i]);
									lstrcat((LPSTR)szFilterList, szToken);
								} /* for */
							}	
							wsprintf((LPSTR)szCaption, "%s - (Filtering: %s)", szLogFile, szFilterList);
						}
						else
						{
							wsprintf((LPSTR)szCaption, "%s - (Filtering: NONE)", szLogFile);
						} /* if - else */
										
						/* define caption */
						SetWindowText(Options.hListBox, szCaption);

						/* Save settings to .ini file where application was ran from. */
						lstrcpy((LPSTR)DebugIniFile, (LPSTR)HomeDir);
						lstrcat((LPSTR)DebugIniFile, "\\RISdbg.ini");

						if (OpenFile(DebugIniFile,&of,OF_EXIST) == -1)
						{
							/* INI file doesn't exist, create and close so it will exist. */
							lstrcpy((LPSTR)DebugIniFile, (LPSTR)HomeDir);
							lstrcat((LPSTR)DebugIniFile, "\\RISdbg.ini");
							hFile = _lopen((LPSTR)DebugIniFile, OF_WRITE);
							_lclose(hFile);
						}
						wsprintf((LPSTR)tempstr, "%d", Options.bActive);
						WritePrivateProfileString(appnameID, "DebugActive", tempstr, DebugIniFile);

						wsprintf((LPSTR)tempstr, "%d", Options.bCount);
						WritePrivateProfileString(appnameID, "CountEvents", tempstr, DebugIniFile);

						wsprintf((LPSTR)tempstr, "%d", Options.bDisplay);
						WritePrivateProfileString(appnameID, "DisplayInBox", tempstr, DebugIniFile);

						wsprintf((LPSTR)tempstr, "%d", Options.bFileLine);
						WritePrivateProfileString(appnameID, "FileName_LineNumber", tempstr, DebugIniFile);

						wsprintf((LPSTR)tempstr, "%d", Options.bFilter);
						WritePrivateProfileString(appnameID, "FilterActive", tempstr, DebugIniFile);

						wsprintf((LPSTR)tempstr, "%d", Options.wFilterSize);
						WritePrivateProfileString(appnameID, "FilterSize", tempstr, DebugIniFile);
						WritePrivateProfileString(appnameID, "Filter", szFilterList, DebugIniFile);

						wsprintf((LPSTR)tempstr, "%d", Options.bLog);
						WritePrivateProfileString(appnameID, "LogActive", tempstr, DebugIniFile);
					
						/* make window visible */
						if(Options.bDisplay)
							ShowWindow(Options.hListBox, SHOW_OPENWINDOW);
					}
					else
					{
						ShowWindow(Options.hListBox, HIDE_WINDOW);
					} /* if - else */
								
					/* exit */
					EndDialog( hDlg, TRUE );
				}
				break;

			case BUG_CANCEL:	/* cancel control panel */
			case IDCANCEL:
				{
					EndDialog( hDlg, FALSE );
				}
				break;
					
			default:	/* ignore all others */
				{
					bResult = FALSE;
				}
				break;
			} /* switch */
			
		} /* WM_COMMAND */
		break;
		
	default:
		{
			bResult = FALSE;
		}
		break;
		
	} /* switch */
	
	/* return final result */
	return(bResult);
	
} /* DebugControldlg */

/****************************************************************************
_Debug
****************************************************************************/
extern BOOL _Debug(
	LPSTR szFileName,
	UINT nLine,
	WORD wCategory,
	LPSTR dbgfrmt,
	...)
{
WORD	i,j;					/* temporary loop variable */
int	hFile;				/* log file handle */
BOOL	bResult;			/* result of function */
BOOL	bInclude;			/* include message flag */
char	szStatement[2048];	/* temporary statement */
struct tm *datetime;
static LONG ltime;
char wrk[255];
va_list	valist;

	/* initialization */
	bResult = FALSE;

	/* process statement if debug active */
	if(Options.bSetup && Options.bActive)
	{
		va_start(valist, dbgfrmt);
		
		bInclude = TRUE;

		/* check for inclusion in filter list */
		if(Options.bFilter)
		{
			/* search filter list */
			for(i = 0 ;
				(i < Options.wFilterSize) && (Options.Filter[i] != wCategory) ;
				i++);

			/* turn off include if not found */
			if(i >= Options.wFilterSize)
			{
				bInclude = FALSE;
			}
		}

		/* format debug statement if included */
		if(bInclude)
		{
			/* prepare for debug statement */
			i = 0;
			bResult = TRUE;
			Options.lMsgCount++;

			/* define debug statement */
			if(Options.bCount) 
			{
				if(Options.bFileLine) 
					i = wsprintf((LPSTR)szStatement, "#%5ld: %s:%d-> ", Options.lMsgCount,szFileName,nLine);
				else
					i = wsprintf((LPSTR)szStatement, "#%5ld - ", Options.lMsgCount);
			}
			else if(Options.bFileLine)
				i = wsprintf((LPSTR)szStatement, "%s:%d-> ", szFileName,nLine);

			i += wvsprintf((LPSTR)&szStatement[i], (LPSTR)dbgfrmt, valist);

			/* display debug statement in listbox */
			if(Options.bDisplay)
			{			
				/*
					Note: since we are passing the formatted
					debugging statement to the listbox using
					a SendMessage we cannot do anything which
					would cause memory to be shuffled - this
					invalidates the pointer!
				*/

				/* add new statement to listbox */
				SendMessage(Options.hListBox, LB_ADDSTRING,
					(WPARAM)0, (LPARAM)(LPSTR)szStatement);

				/* remove first statement from listbox if necessary */
				if(Options.wEntries >= Options.wMaxEntries)
				{
					SendMessage(Options.hListBox, LB_DELETESTRING, (WPARAM)0, (LPARAM)0);
				}
				else
				{
					Options.wEntries++; 
				} /* if - else */

				/* make last statement visible */
				SendMessage(Options.hListBox, LB_SETCURSEL,
					(WPARAM)(Options.wEntries - 1), (LPARAM)0);
			}

			/* output debug statement to logfile */
			if(Options.bLog)
			{
				/* open or create log file */
				hFile = open(szLogFile, MODE_APPEND, SHARED);
				if(hFile < 0)
				{
					hFile = open(szLogFile, MODE_CREATE, SHARED);
				}
				if(hFile > 0)
				{
					/* if first message, record date & time */
					if (Options.lMsgCount ==1)
					{
						time(&ltime);
						datetime = localtime(&ltime);

						j = wsprintf ((LPSTR)wrk, "<%02d/%02d/19%d %02d:%02d:%02d>",
							datetime->tm_mon+1,
							datetime->tm_mday,
							datetime->tm_year,
							datetime->tm_hour,
							datetime->tm_min,
							datetime->tm_sec);

						write(hFile, wrk, j);
						write(hFile, "\r\n", 2);
					}
				}
				/* write message to file if sucessful */
				if(hFile > 0)
				{
					write(hFile, szStatement, i);
					write(hFile, "\r\n", 2);
					close(hFile);
				}
			}
		}
	}

	/* return result */
	return(bResult);

} /* _Debug */



