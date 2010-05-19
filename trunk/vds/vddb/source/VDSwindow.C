/* $Id: VDSwindow.C,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS 
 *
 * File:	vds/vddb/source / VDSwindow.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSwindow.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  1998/10/23  16:41:42  pinnacle
 * Replaced: vddb/source/VDSwindow.C for:  by vsrivast for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.9  1996/05/29  10:06:02  pinnacle
 * Replaced: vddb/source/VDSwindow.C for:  by ksundar for vds.240
 *
 * Revision 1.8  1996/05/27  12:11:56  pinnacle
 * Replaced: vddb/source/VDSwindow.C for:  by ksundar for vds.240
 *
 * Revision 1.7  1996/05/20  03:29:28  pinnacle
 * Replaced: vddb/source/VDSwindow.C for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/05/08  23:02:28  pinnacle
 * Replaced: vddb/source/VDSwindow.C for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1996/04/24  23:01:46  pinnacle
 * Replaced: vddb/source/VDSwindow.C for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/04/21  23:49:20  pinnacle
 * Replaced: vddb/source/*.C for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/09  21:45:18  pinnacle
 * Replaced: vddb/source/VDSwindow.C for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/01  12:52:00  pinnacle
 * Replaced: vdris/imp/VdsRisTbl.C for:  by msbraju for vds.240
 *
 * Revision 1.1  1996/01/31  16:17:32  pinnacle
 * Created: ./vddb/source/VDSwindow.C by azuurhou for vds.240
 *
 * Revision 1.3  1996/01/31  11:53:04  pinnacle
 * Replaced: vddb/source/VDSwindow.c for:  by ksundar for vds.240
 *
 * Revision 1.2  1996/01/30  11:34:58  pinnacle
 * Replaced: vddb/source/VDSwindow.c for:  by ksundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 * 	10/20/93   Raju   	Creation in 2.2
 *	04/09/96   tlb		Remove special test for 'e' - causes select
 *	04/15/96   tlb		Use VDS memory allocation
 *				Add prototypes
 *	04/24/96   tlb		Change 'Exit' to 'Cancel' on menu.
 *	05/08/96   tlb  	Change prototype file name
 *	05/08/96   tlb  	Use standard error routines,
 *				 Change remaining 'Exit' to 'Cancel'
 *	10/22/98   vinit	Changes for Solaris 2.6: TR179802013
 *				The F1 key in Solaris 2.6 has been
 *				mapped to desktop help. So, the PROCESS key
 *				which was earlier mapped to F1 has been
 *				mapped to F6 and some other changes have been
 * 				done to bring in consistency. Here are the 
 *				changes:(the present key mappings:)
 *				F2	CANCEL		(Unchanged)
 *				F3	CLR_FIELD	(Unchanged)
 *				F4	SELECT_ALL	(Unchanged)
 *				F5	UNSELECT_ALL	(Unchanged)
 *				F6	PROCESS		(Changed : Earlier F1)
 *				F7	SELECT		(Changed : Earlier F1)
 *				
 * -------------------------------------------------------------------*/

#include <string.h>
#include <curses.h>
#include <varargs.h>
#include "VDBload.h"
#include "VDmem.h"
#include "v_risproto.h"
#include "v_dbloadprot.h"


#define VDB_COL  ( field == 0 ) ? (firstcol+col) : \
                                     (firstcol+maxlen1+VDB_GAP+col)

/* #define VDB_DEBUG   1*/

/*========================= Internal Functions ==========================*/
/* --------------------------------------------------------------------------
Doc :  VDBinsertChar

  Desc : It pushes the string from given position to right by one position
         and inserts given character at given position.

----------------------------------------------------------------------------*/
static
void  VDBinsertChar(
  char *str,
  char c1,
  int  pos
)
{

int len, ii;

#ifdef VDB_DEBUG
     VDSdebug( "VDBinsertChar : str = [%s], c1 = [%c], pos= [%d]\n",
	 						str, c1, pos );
#endif

    len = strlen( str );
    if ( pos > len - 1  || pos < 0)
      return;

    for( ii=len-1; ii>pos; ii--)
      str[ii] = str[ii-1];

    str[pos] = c1;

#ifdef VDB_DEBUG
    VDSdebug( "VDBinsertChar : str = [%s]\n", str );
#endif

}
// VDSdbdbg.c
/* --------------------------------------------------------------------------
Doc :  VDBdeleteChar

  Desc : It deletes a char at given position by pushing the string left by
         one position. All characters right to the position are moved.
         One blank character is added at the end.

----------------------------------------------------------------------------*/
static
void  VDBdeleteChar(
  char *str,
  int  pos
)
{

int len, ii;

#ifdef VDB_DEBUG
     VDSdebug( "VDBdeleteChar : str = [%s], pos = [%d]\n", str, pos );
#endif

    len = strlen( str );
    if ( pos > len - 1  || pos < 0)
      return;

    for( ii=pos+1; ii<len; ii++)
      str[ii-1] = str[ii];

    str[len-1] = ' ';

#ifdef VDB_DEBUG
     VDSdebug( "VDBdeleteChar : str = [%s]\n", str );
#endif

}

/*========================= Public Functions ==========================*/
/* --------------------------------------------------------------------------
Doc :  VDBmake_select_win

  Desc : This function creates a window from which one entry is selected.
         It accepts variable number of strings.

  Input ( in order )
    WINDOW   **wind    ** o - created window **
    int      begline   ** i - line no. where window to start **
    int      begcol    ** i - col no. where window to start **
    int      *maxlen   ** o - max. length of any of the strings **
    int      totnostr  ** i - total no. of strings = no. of strings
                                     in the menu + 1 ( window title ) **
    char     *strng[0] ** i - first character string - window title **
    char     *strng[1] ** i - next char. string - first menu entry **
    .
    .
    char     *strng[totnostr-1]
                       ** i - last character string  **

  return vlaues - 1, always

  History

  10-20-93   2.2   Raju   Creation

----------------------------------------------------------------------------*/
long VDBmake_select_win( va_alist )
va_dcl
{

WINDOW	**wind;
int	ii, jj, sts;
int	begline, begcol, totnostr, len, *maxlen;
char  	(*strng)[VDB_MAX_SELSTR_LEN];
char	*tstr;
va_list pa;
int	wlines, wcols;

  va_start ( pa );

  wind = va_arg( pa, WINDOW **);
  begline = va_arg ( pa, int );
  begcol  = va_arg ( pa, int );
  maxlen  = va_arg ( pa, int *);
  totnostr = va_arg ( pa, int );

  strng = _MALLOC_ARR (totnostr, char, VDB_MAX_SELSTR_LEN);
  _CheckAlloc(strng, "window string", sts, FALSE, quit )

  /* Store menu item srings */
  for ( ii=0; ii< totnostr; ii++)
  {  tstr = va_arg( pa, char *);
     strncpy( strng[ii], tstr, VDB_MAX_SELSTR_LEN-1 );
     strng[ii][VDB_MAX_SELSTR_LEN-1] = '\0';
     len = strlen ( tstr );
     *maxlen = MAX( *maxlen, len );
     /* if ( *maxlen > VDB_MAX_SELSTR_LEN ) *maxlen = VDB_MAX_SELSTR_LEN; */
  }

  /* Pad menu item srings */
  for ( ii=0; ii< totnostr; ii++)
  {  len = strlen ( strng[ii] );
     for( jj=len; jj< *maxlen; jj++)
        strng[ii][jj] = ' ';
     strng[ii][ *maxlen ] = '\0';
  }

/*  extra lines at top + extra lines at bot */
  wlines = totnostr + (VDB_FIRST_LINE-1) + 2;

/* extra 2 cols on right side */
  wcols  = *maxlen + VDB_FIRST_COL + 2;

  *wind = newwin ( wlines, wcols, begline, begcol );
  box ( *wind, 0, 0 );
  wattrset ( *wind, A_REVERSE );
  mvwaddstr( *wind, 0, VDB_FIRST_COL, strng[0] );
  wattrset ( *wind, A_NORMAL );
  for( ii=1; ii < totnostr; ii++)
     mvwaddstr( *wind, ii+VDB_FIRST_LINE-1, VDB_FIRST_COL, strng[ii] );
/*
  wmove ( *wind, VDB_FIRST_LINE, VDB_FIRST_COL-1);
*/
  wrefresh ( *wind );

  _FREE ( strng );
  return TRUE;

quit:
  return FALSE;
}


/* --------------------------------------------------------------------------
Doc :  VDBmake_input_win

  Desc : This function creates a window in which values are keyed in.
         The menu contains two columns, of which first column is field
         name and second column is input field.
         It accepts varaible number of fields.

  Input ( in order )
    WINDOW   **wind    ** o - created window **
    int      begline   ** i - line no. where window to start (wrt screen coordinates) **
    int      begcol    ** i - col no. where window to start (wrt screen coordinates) **
    int      *maxlen1  ** o - max. length of any of the strings in first col**
    int      *maxlen2  ** i - max. lenght of any of the atrings in second col **
    int      totnostr  ** i - total no. of strings = no. of strings
                                     in the menu + 1 ( window title ) **
    char     *strng[0] ** i - first character string - window title **
    char     *strng[1] ** i - next char. string - first field name **
    char     *strng[2] ** i - next char, string - default string for
                                    first input field **
    .
    .
    char     *strng[totnostr-2]
                       ** i - last field name **
    char     *strng[totnostr-1]
                       ** i - default string for last input field **


  return vlaue - 1, always

----------------------------------------------------------------------------*/
long VDBmake_input_win( va_alist )
va_dcl
{
WINDOW	**wind;
int	ii, sts;
int	begline, begcol, totnostr, len, *maxlen1, *maxlen2;
char	(*strng)[81];
char	*tstr;
va_list pa;
int	wlines, wcols;
int     norow;

#ifdef VDB_DEBUG
char	s[300];
#endif

  va_start ( pa );

  wind = va_arg( pa, WINDOW **);
  begline = va_arg ( pa, int );
  begcol  = va_arg ( pa, int );
  maxlen1  = va_arg ( pa, int *);
  maxlen2  = va_arg ( pa, int *);
  totnostr = va_arg ( pa, int );

  strng = _MALLOC_ARR ( totnostr, char, 81 );
   _CheckAlloc(strng, "window string", sts, FALSE, quit )

  tstr = va_arg ( pa, char *);
  *maxlen1 = strlen ( tstr );
  strcpy ( strng[0], tstr );

  norow = totnostr / 2;

  for ( ii=1; ii< totnostr; ii++)
  {  tstr = va_arg( pa, char *);
     strcpy( strng[ii], tstr );
     len = strlen ( tstr );
     if ( ii%2 ) 
       *maxlen1 = MAX( *maxlen1, len );
  }

#ifdef VDB_DEBUG
  VDSdebug( " maxlen1 = [%d], maxlen2 = [%d]\n", *maxlen1, *maxlen2 );

  for( ii=0; ii<totnostr; ii++) {
 	VDSdebug( s, "str%d = [%s]\n", ii, VDBmsgstrs[ii] );
   	}
#endif

/* pad the strings at end with blanks */
  for ( ii=1; ii<totnostr; ii++)
  {  len = strlen ( strng[ii] );
     if ( ii % 2 )
       VDBpadstr( (char *) strng[ii], *maxlen1+1, ' ' );
     else
       VDBpadstr( (char *) strng[ii], *maxlen2+1, ' ' );
  }

/*                 extra lines at top + extra lines at bot 
*/
  wlines = norow + VDB_FIRST_LINE + 1;

  wcols  = VDB_FIRST_COL + *maxlen1 + VDB_GAP + *maxlen2 + 2;

  *wind = newwin ( wlines, wcols, begline, begcol );
  box ( *wind, 0, 0 );

  wattrset ( *wind, A_REVERSE );
  mvwaddstr( *wind, 0, VDB_FIRST_COL, strng[0] );
  wattrset ( *wind, A_NORMAL );
  for( ii=0; ii < norow; ii++)
  {  sprintf( VDBtmps, "%-6s", strng[ii*2+1] );
     mvwaddstr( *wind, VDB_FIRST_LINE+ii, VDB_FIRST_COL, VDBtmps );
     wattrset ( *wind, A_UNDERLINE );
     mvwaddstr ( *wind, VDB_FIRST_LINE+ii, VDB_FIRST_COL+(*maxlen1)+VDB_GAP,
		           strng[ii*2+2] );
     wattrset ( *wind, A_NORMAL );
  }

  wmove ( *wind, VDB_FIRST_LINE, VDB_FIRST_COL+(*maxlen1)+VDB_GAP);

  wrefresh ( *wind );

  _FREE ( strng );

  return TRUE;

quit:

  return FALSE;

}

/*-------------------------------------------------------------------------
  Doc : VDBmenu_select_oper
 
  Description : This allows user to select one of the items displayed in
     select window.
     
  Return values :
  1 - always
-------------------------------------------------------------------------*/ 
long VDBmenu_select_oper (
 WINDOW **wind,			/* i - select window */
 int	maxlen,			/* i - max. length of any of the strings in window */
 int	nostr,			/* i - no. of strings in the window */
 char   msgstrs[8][81],		/* i - message strings displayed for each of the strings */ 
 int	*selno			/* o - selected item no.  */
)

{
chtype	ch;
int	curpos, nextline, ii;
char    selected, barstrs[8][9];

  strcpy( barstrs[0], "SELECT" );
  strcpy( barstrs[1], "CANCEL" );

  for ( ii=2; ii<8; ii++)	strcpy ( barstrs[ii], "");
  VDBdisplay_bar_menu ( 2, barstrs );

  for(ii=0; ii<nostr; ii++)	VDBpadstr( msgstrs[ii], 81, ' ');

  curpos = *selno;

  VDB_DISP_PADED_MSG ( msgstrs[curpos] );
  wmove ( *wind, VDB_FIRST_LINE + curpos, VDB_FIRST_COL-1 );
  VDBhilite ( wind, curpos, maxlen );
  wrefresh ( *wind );

  selected = 0;
  keypad( *wind, TRUE );
  while ( ! selected )
  {
    ch = wgetch ( *wind );

    switch ( ch )
    {
      case KEY_DOWN :
      case CTRL_N   :
	nextline = (curpos+1) % nostr;
	VDBdehilite ( wind, curpos, maxlen );
        VDBhilite ( wind, nextline, maxlen );
        curpos = nextline;
        mvwaddstr( VDBmsgwin, 0, 0, msgstrs[curpos]);
        wrefresh( VDBmsgwin );
        wmove ( *wind, curpos+VDB_FIRST_LINE, VDB_FIRST_COL-1);
        break;

      case KEY_UP :
      case CTRL_P   :
	nextline = curpos-1;
        if ( nextline < 0 ) nextline += nostr;
	VDBdehilite ( wind, curpos, maxlen );
        VDBhilite ( wind, nextline, maxlen );
        curpos = nextline;
        mvwaddstr( VDBmsgwin, 0, 0, msgstrs[curpos]);
        wrefresh( VDBmsgwin );
        wmove ( *wind, curpos+VDB_FIRST_LINE, VDB_FIRST_COL-1);
        break;

      case '\n':
      case KEY_F(22) :
      case KEY_F(7) :
/*	VDBdehilite ( wind, curpos, maxlen );
*/        *selno = curpos;
        selected = 1;
        break;

      case KEY_F(17) :
      case KEY_F(2) :
	*selno = nostr-1;
	selected = 1;
        break;

      default :
        break;

    }

  }

  return 1;

}
/*-------------------------------------------------------------------------
  Doc : VDBmenu_input_oper
 
  Description : This allows user to keyin data in input window.
     
  Return values :
  VDB_PROCESS - process data
  VDB_EXIT    - user selected exit
-------------------------------------------------------------------------*/ 
long VDBmenu_input_oper (
 WINDOW **wind,			/* i - input window */
 int	maxlen,			/* i - max. length of any of the input fields */
 int    first_line,		/* i - line no. where first input field starts. */
 int    first_col,		/* i - col no. where input fields start */
 int	nostr,			/* i - no. of input fileds in window */
 int    passwdrow,		/* i - row to be considered as password row */
 char   delspaces,		/* i - 1, if the spaces before and after the keyed
				       strings to be deleted.
				       0, if not to be deleted.
				       This flag is not applied to passwdrow */
 char   msgstrs[8][81],		/* i - massage strings. Not used */
 char   *outstrs[]		/* o - keyed in strings */
)

{
chtype	ch, ch1;
int	row, col, ii, jj, passwdcol;
char    selected,  barstrs[8][9];
int     c1;

#ifdef VDB_DEBUG
char	s[300];
#endif

  strcpy( barstrs[0], "PROCESS" );
  strcpy( barstrs[1], "CANCEL" );
  strcpy( barstrs[2], "CLR_FLD" );

  for ( ii=3; ii<8; ii++) strcpy ( barstrs[ii], "");
  VDBdisplay_bar_menu ( 3, barstrs );

  for(ii=0; ii<nostr; ii++) VDBpadstr ( (char *) msgstrs[ii], 81, ' ' );

  passwdcol=0;
  row = col = 0;
  selected = 0;
  keypad( *wind, TRUE );
  wmove ( *wind, first_line, first_col );
  wattrset ( *wind, A_UNDERLINE );
  while ( ! selected )
  {
    if ( col > maxlen-1 ) col = maxlen -1;
    if ( col < 0 ) col = 0;
    if ( row > nostr-1 )  row  = nostr -1;
    if ( row < 0 ) row = 0;
    wmove ( *wind, first_line+row, first_col+col );

    ch = wgetch ( *wind );
    c1 = ch & A_CHARTEXT;
    switch ( c1 )
    {
      case KEY_F(3):
      case KEY_F(18):
     	col=0;
	for( ii=0; ii<maxlen; ii++ )
		mvwaddstr( *wind, first_line+row, first_col+ii, " " );
	outstrs[row][0]='\0' ;
	break;

      case KEY_DOWN:
      case CTRL_N:
        row = row+1;
        if ( row == passwdrow )
	{  col = 0;
           passwdcol = 0;
        }
        break;

      case KEY_UP:
      case CTRL_P:
        row = row - 1;
        if ( row == passwdrow )
	{  col = 0;
           passwdcol = 0;
        }
        break;

      case KEY_LEFT:
      case CTRL_B:
        col = col - 1;
        break;


      case KEY_RIGHT:
      case CTRL_F:
        col = col + 1;
        break;


      case CTRL_D:
        wdelch( *wind );
        ch1 = ' ';
        mvwinsch( *wind, row+first_line, maxlen+first_col-1, ch1 );
        break;

      case CTRL_H:
      case VDB_DELETE:
        if ( col == 0 ) break;
        col--;
        mvwdelch( *wind , row+first_line, first_col+col );
        ch1 = ' ';
        mvwinsch( *wind, row+first_line, maxlen+first_col-1, ch1 );
        break;

      case '\n' :
        row = (row+1) % nostr;
        col = 0; 
        break;

      case KEY_F(21):
      case KEY_F(6):
#ifdef VDB_DEBUG
  	VDSdebug( "VDBmenu_input_oper(process)\n" );
#endif
        for ( ii=0; ii<nostr; ii++)
	{ if ( ii == passwdrow ) 
	    continue;

          for ( jj=0; jj<maxlen; jj++ )
	    outstrs[ii][jj] 
                 = mvwinch ( *wind, first_line+ii, first_col+jj ) & A_CHARTEXT;
          outstrs[ii][maxlen] = '\0';

          if ( delspaces )
	  {  VDBdelTrailSpaces ( (char *) outstrs[ii] );
             VDBdelLeadSpaces ( (char *) outstrs[ii] );
	  }

#ifdef VDB_DEBUG
	VDSdebug( s, "string[%d]=[%s]\n", ii, outstrs[ii] );
#endif
	}
        selected = 1;
        break;

      case KEY_F(17):
      case KEY_F(2):
        goto cancel;
/* uncomment following statement if goto is deleted */
/*        break; */

      default :
        if ( row == passwdrow )
	{ outstrs[row][passwdcol] = c1;
          outstrs[row][++passwdcol] = '\0';
        }
        else if ( c1 > 31 && c1 < 127 )
        { mvwdelch( *wind, row+first_line, first_col+maxlen-1 );
          mvwinsch ( *wind, row+first_line, col+first_col, ch );
          col++;
        }
        break;
    }

  }

 return VDB_PROCESS;

cancel:
 return VDB_EXIT;
}


/*-------------------------------------------------------------------------
  Doc : VDBdisplaySelectWin
 
  Description : This displays a select window. Used for scrolling when no. of
	total strings are greater no. of strings displayed in the window.
     
  Return values :
   1 - always
-------------------------------------------------------------------------*/ 
long VDBdisplaySelectWin ( 
WINDOW **wind,			/* i - window */
char   (*strs)[81],		/* i - list containing the strings */
int    topline,			/* i - list to be displayed from this line */
int    nostrdis,		/* i - no. of strings to be displayed */
int    first_line,		/* i - line no. in window where the first string
				       is dispalyed */
int    first_col,		/* i - column no. in window where the strings start */
char   *selflag			/* i -  =1, the corresponding string is selected
					=0, string not selected */
)

{
int ii, jj;


   wattrset ( *wind, A_NORMAL );
   jj = 0;
   for ( ii=topline; ii<topline+nostrdis; ii++)
   {  if ( selflag[ii] )
        mvwaddstr ( *wind, first_line+jj, 1, ">" );
      else
        mvwaddstr ( *wind, first_line+jj, 1, " " );

      mvwaddstr( *wind, first_line+jj, first_col, strs[topline+jj] );
      jj++;
   }
   
   return 1;
}

/*-------------------------------------------------------------------------
  Doc : VDBmenu_multi_select_oper
 
  Description : This allows user to select more than one entry from a
	select window.
     
  Return values :
   VDB_PROCESS  - continue process
   VDB_EXIT     - user selected exit
-------------------------------------------------------------------------*/ 
long VDBmenu_multi_select_oper (
       WINDOW **wind,		/* i - select window */
       int	maxlen,		/* i - max. length of any of the strings 
					in the window */
       int    first_line,	/* i - line no. where first string is 
					displayed */
       int    first_col,	/* i - col. no. where strings are displayed */
       int	nostr,		/* i - total no. of the strings in the list */
       int    nostrdis,		/* i - no. of strings displayed in the window */
       char   hilitemode,	/* i - 1, the current string is highlighted.
       			       		0, current string is not higlighted */
       char   msgstrs[8][81], 	/* i - message strings. 
					Not used in the function*/
       char   (*strs)[81],	/* i - strings from which user selects some 
					or all */
       short	bSelectAll,	/* i - Enable/Disable SEL_ALL key.
      			       		1 => Enable,	0 => Disable */
       char   *selflag		/* o - 
					=1, the string is selected. 
					=0, not selected */
)
{
chtype	ch;
int	row, prevrow, topline, botline, ii;
char    selected, dispwinflag, barstrs[8][9];
long    sts;

  strcpy( barstrs[0], "PROCESS" );
  strcpy( barstrs[1], "CANCEL" );
  strcpy( barstrs[2], "SELECT" );

  if( bSelectAll )	strcpy( barstrs[3], "SELECT" );
  else			strcpy( barstrs[3], "" );

  strcpy( barstrs[4], "UNSELECT" );

  for ( ii=5; ii<8; ii++)	strcpy ( barstrs[ii], "");
  VDBdisplay_bar_menu ( 5, barstrs );

  for( ii=0; ii<nostr; ii++){
	selflag[ii] = 0;
	VDBpadstr( (char *)strs[ii], maxlen, ' ' );
  }
  
  /* message strings are not used anywhere */
  for( ii=0; ii<8; ii++) VDBpadstr ( (char *) msgstrs[ii], 81, ' ' ); 

  wmove ( *wind, first_line, first_col-1 );

  row = 0;
  topline = 0;
  botline = nostrdis-1;

  selected = 0;
  keypad( *wind, TRUE );
  while ( ! selected )
  {

    dispwinflag = 0;
    prevrow = row;
    ch = wgetch ( *wind );

    switch ( ch )
    {
      case KEY_DOWN:
      case CTRL_N:
        row++;
        break;

      case KEY_UP:
      case CTRL_P:
        row--;
        break;

      case '\n' :
      case KEY_F(7) :
      case KEY_F(22) :
        if ( selflag[topline+row] ) 
        {  selflag[topline+row] = 0;
           mvwaddstr( *wind, row+VDB_FIRST_LINE, 1, " " );
	}
        else
        {  selflag[topline+row] = 1;
           mvwaddstr( *wind, row+VDB_FIRST_LINE, 1, ">" );
	}
        row++;
        break;

      case KEY_F(4) :
      case KEY_F(19) :
        if( bSelectAll )
	{
          for( ii=0; ii<nostr; ii++)
           selflag[ii] = 1;
          for( ii=0; ii<nostrdis; ii++ )
           mvwaddstr( *wind, ii+VDB_FIRST_LINE, 1, ">" );
        }
        break;

      case '7' :
      case KEY_F(5) :
        for( ii=0; ii<nostr; ii++)
          selflag[ii] = 0;
        for( ii=0; ii<nostrdis; ii++ )
           mvwaddstr( *wind, ii+VDB_FIRST_LINE, 1, " " );
        break;

      case KEY_F(21) :
      case KEY_F(6) :
        selected = TRUE;
        break;

      case KEY_F(17) :
      case KEY_F(2) :
	goto cancel;
/* uncomment following statement if goto is deleted */
/*        break;  */

    }

    if ( row == -1 )
    { topline--;
      row = 0;

      if ( topline == -1 )
        topline = 0;
      else
      { botline--;
        sts=VDBdisplaySelectWin(wind, strs, topline, nostrdis, first_line, first_col, 
				selflag );
        dispwinflag = 1;
      }
    }

    if ( row == nostrdis )
    { botline++;
      row = nostrdis -1;

      if ( botline == nostr )
         botline = nostr - 1;
      else
      { topline++;
        sts=VDBdisplaySelectWin(wind, strs, topline, nostrdis, first_line, first_col,
				selflag );
        dispwinflag = 1;
      }
    }
    if ( hilitemode )
    { if ( !dispwinflag && prevrow != row )
         VDBdehilite ( wind, prevrow, maxlen );
      VDBhilite ( wind, row, maxlen );
    }
    wmove ( *wind, first_line+row, first_col-1 );
  }

 return VDB_PROCESS;

cancel:
 return VDB_EXIT;

}

/*----------------------------------------------------------------------------------
  Doc : VDBdehilite
  
  Description : This dehighlights a string in a select window.
----------------------------------------------------------------------------------*/
void VDBdehilite(
  WINDOW **wind,	/* i - select window */
  int	 line,		/* i - no. of the line to be dehighlighted */
  int    maxlen		/* i - max. length of any the strings in window */
  )
{
char	strng[81];
int	ii;

     ii = 0;
     for ( ii=0; ii<maxlen; ii++)
       strng[ii] = (*wind)->_y[line+VDB_FIRST_LINE][ii+VDB_FIRST_COL];
     strng[maxlen] = '\0';

     wattrset ( *wind, A_NORMAL );
     mvwaddstr( *wind, line+VDB_FIRST_LINE, VDB_FIRST_COL, strng );
     wmove ( *wind, line+VDB_FIRST_LINE, VDB_FIRST_COL-1 );
     wrefresh( *wind );

}

/*----------------------------------------------------------------------------------
  Doc : VDBhilite
  
  Description : This highlights a string in a select window.

----------------------------------------------------------------------------------*/
void VDBhilite(
  WINDOW **wind,	/* i - select window */
  int	 line,		/* i - no. of the line to be highlighted */
  int    maxlen		/* i - max. length of any of the strings in window */
  )
{
char	strng[81];
int	ii;

     ii = 0;
     for ( ii=0; ii<maxlen; ii++)
       strng[ii] = (*wind)->_y[line+VDB_FIRST_LINE][ii+VDB_FIRST_COL];
     strng[maxlen] = '\0';

     wattrset ( *wind, HIGHLIGHT_MODE );
     mvwaddstr( *wind, line+VDB_FIRST_LINE, VDB_FIRST_COL, strng );
     wattrset ( *wind, A_NORMAL );
     wmove ( *wind, line+VDB_FIRST_LINE, VDB_FIRST_COL-1 );
     wrefresh( *wind );
}

/*------------------------------------------------------------------------------
  Doc : VDBgetfampartlist
  
  Description : This gets list of family files or part files from the given paths.

  Return values:
  1 - success
  0 - failure
-----------------------------------------------------------------------------*/  
long VDBgetfampartlist (
	char *path_list[],	    /* i - list of product paths */
	int  noprods,		    /* i - no. of products       */
	char selflag[],		    /* i - flags indicating the products 
								selected */
	char fampartflag,	    /* i -  = VDB_FAM, get list of family files.
					= VDB_PART, get list of part files. */
	char (**fam_part_list)[81], /* o - list of familiy files or part files */
	int  *nofampart		    /* o - no. of files in the list */
)

{
long   sts;
int    ii, total, count;
FILE   *pf=NULL;

   remove ( "/usr/tmp/fampartlist" );
   for ( ii=0; ii<noprods; ii++)
     if ( selflag[ii] )
     { if ( fampartflag == VDB_FAM )
         sprintf( VDBtmps, "\\ls %s/*.f >> /usr/tmp/fampartlist 2>/dev/null",
               path_list[ii] );
       else
         sprintf( VDBtmps, "\\ls %s/*.p >> /usr/tmp/fampartlist 2>/dev/null",
               path_list[ii] );
       sts = system ( VDBtmps );
       if ( sts == 1 ) {
	 VDSprintErr( "", "Cannot create catalogs/parts list\n" );
         goto failure;
       }
     }


   pf = (FILE *) fopen("/usr/tmp/fampartlist", "r");
   if ( !pf ) {
     VDSprintErr  ( "", "Cannot open /usr/tmp/fampartlist for reading\n" );
     goto failure;
   }
   total = 200;

   _FREE ( *fam_part_list ) ;
   *fam_part_list = _MALLOC_ARR ( total, char, 81 );
   _CheckAlloc(*fam_part_list, "family part list", sts, FALSE, failure )

   count = 0;
   while ( fgets( VDBtmps, 81, pf ) )
   {  if ( count == total )
      { total += 200;
        *fam_part_list= _REALLOC_ARR (fam_part_list, total, char, 81);
        _CheckAlloc(*fam_part_list, "family part list", sts, FALSE, failure )
      }
      sscanf ( VDBtmps, "%s", (*fam_part_list)[count] );
      count++;
   }

   fclose ( pf );
   remove ( "/usr/tmp/fampartlist" );

#ifdef VDB_DEBUG
    VDSdebug( "No.of catalogs/parts : [%d]\n", count );
#endif

   *nofampart = count;
   return TRUE;

failure :
   return FALSE;
}

/* --------------------------------------------------------------------------
Doc :  VDBmake_attrib_win

  Desc : This creates window in which table opeartions are performed.
         This window is used for creating tables and adding data.
         The window contains two columns, of which first column is attribute
         and second column is either datatype or data value.
         It displays blank fields in both columns.

  Input ( in order )
    WINDOW   **wind    ** o - created window **
    int      begline   ** i - line no. where window to start (wrt screen coordinates)**
    int      begcol    ** i - col no. where window to start (wrt screen coordinates) **
    int      *maxlen1  ** i - max. length of any of the strings in first col**
    int      *maxlen2  ** i - max. lenght of any of the strings in second col**
    int      norowsdisp ** i - no. of rows (blanks, of course ) to be displayed**

  return vlaue - 1, always
----------------------------------------------------------------------------*/
long VDBmake_attrib_win( va_alist )
va_dcl
{
WINDOW	**wind;
int	ii;
int	begline, begcol, *maxlen1, *maxlen2, norowsdisp;
char	strng[81];
char	*tstr1, *tstr2;
va_list pa;
int	wlines, wcols;

  va_start ( pa );

  wind = va_arg( pa, WINDOW **);
  begline = va_arg ( pa, int );
  begcol  = va_arg ( pa, int );
  maxlen1  = va_arg ( pa, int *);
  maxlen2  = va_arg ( pa, int *);
  norowsdisp = va_arg ( pa, int );

#ifdef VDB_DEBUG
  VDSdebug( "VDBmake_attrib_win >>>>\n");

  VDSdebug( "maxlen1 = [%d], maxlen2 = [%d]\n", *maxlen1, *maxlen2 );
#endif

/* create window */
  wlines = norowsdisp + 3; /* two rows at top and one row at bottom */
  wcols  = VDB_FIRST_COL + *maxlen1 + VDB_GAP + *maxlen2 + 2;

  *wind = newwin ( wlines, wcols, begline, begcol );
  box ( *wind, 0, 0 );

/* make the table name string */
  tstr1 = va_arg ( pa, char *);
  tstr2 = va_arg ( pa, char *);
  sprintf( strng, "%s : %s", tstr1, tstr2 );
  VDBpadstr( (char *) strng, *maxlen1 + *maxlen2 + VDB_GAP + 1, ' ');

  wattrset ( *wind, A_REVERSE );
  mvwaddstr( *wind, 0, VDB_FIRST_COL, strng );
  wattrset ( *wind, A_NORMAL );

/* make the row containing titles of parameters*/
  tstr1 = va_arg ( pa, char *);
  strcpy( VDBtmps, tstr1 );
  VDBpadstr( VDBtmps, *maxlen1+1, ' ' );
  tstr2 = va_arg ( pa, char *);
  strcpy( VDBbuff, tstr2 );
  VDBpadstr( VDBbuff, *maxlen2+1, ' ' );
  sprintf( strng, "  %s |%s ", VDBtmps, VDBbuff );

  wattrset ( *wind, A_BOLD | A_UNDERLINE );
  mvwaddstr( *wind, 1, 1, strng );
  wattrset ( *wind, A_NORMAL );

  wattrset ( *wind, A_UNDERLINE );
  for ( ii=0; ii< norowsdisp; ii++)
  {  
     strng[0] = '\0';
     VDBpadstr( strng, *maxlen1+1, ' ');
     mvwaddstr ( *wind, ii+VDB_FIRST_LINE, VDB_FIRST_COL, strng);

     strng[0] = '\0';
     VDBpadstr( strng, *maxlen2+1, ' ');
     mvwaddstr ( *wind, ii+VDB_FIRST_LINE, VDB_FIRST_COL+ *maxlen1+VDB_GAP,strng);
  }

  wrefresh ( *wind );

  return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBdisplayTable

  Desc : This displays table data rows in given window.

  return vlaue - 1, always
----------------------------------------------------------------------------*/
long VDBdisplayTable (
WINDOW *wind,			/* i - table window */
struct VDBtable *recs,		/* i - records containing data of table */
char   tbltype,			/* i - = VDB_DTYPE, second column is datatype.
				       = VDB_DVAL,  second column is data value. */
int    toprow,			/* i - record no. to be displayed as first row.
					( Table starts with this record. Needed
					  during scrolling operation ) */
int    norowsdisp,		/* i - no. of rows displayed in the window */
int    first_line,		/* i - line no. in the window where the toprow
				       is displayed */
int    first_col,		/* i - column no. in the window where the first column
					starts */
int    maxlen1			/* i - max. length of any of strings in first column */
)

{
int ii;

   for ( ii=0; ii<norowsdisp; ii++)
   {  
      mvwaddstr( wind, first_line+ii, first_col, recs[toprow+ii].attrib );
      if ( tbltype == VDB_DTYPE )
         mvwaddstr( wind, first_line+ii, first_col+maxlen1+VDB_GAP,
                                            recs[toprow+ii].dtype );
      else
         mvwaddstr( wind, first_line+ii, first_col+maxlen1+VDB_GAP,
                                            recs[toprow+ii].dval  );

   }
   
   return 1;
}

/*---------------------------------------------------------------------------
  Doc : VDBattrib_win_oper
  
  Description: This performs the table operations
  
  return values :
  VDB_PROCESS : continue processing
  VDB_EXIT    : exit the attribute window
---------------------------------------------------------------------------*/
long VDBattrib_win_oper(
  WINDOW *wind,			/* i - window */
  int    maxlen1,		/* i - max. length of any of strings in first col */
  int    maxlen2,		/* i - max. length of any of strings in second col */
  int    firstline,		/* i - line no. where first row in the window displayed */
  int    firstcol,		/* i - col no. where strings in attribute field start */
  int    norowsdisp,		/* i - no. of rows of data displayed in the window */
  int    editflag,		/* i = VDB_EDITABLE, minrow, maxrow, mincol, maxcol
  					represent range in the window that is editable
  				       VDB_NONEDITABLE, they represent range that can be
  				       edited */
  int    minrow,		/* i - min. row no. of the editable/non-editable range */
  int    maxrow,                /* i - max. row no.  */ 
  int    mincol,		/* i - min. col. no. */
  int    maxcol,		/* i - max. col. no. */
  int    *norecs,		/* i - no. of records in the list 'recs' */
  struct VDBtable **recs,	/* i - list of records */
  char   tbltype		/* i - = VDB_DTYPE, second column is datatype
  				       = VDB_DVAL, second column data value */
)

{
long     sts;
int      ii, row, col, toprow, field;
chtype   ch, ch1;
int      c;
char     selected, barstrs[8][9];

#ifdef VDB_DEBUG
   VDSdebug( "Entered VDB_attrib_oper\n" );
    for( ii=0; ii< *norecs; ii++ ) {
  	VDSdebug( "ii=[%d], attrib=[%s], \n\tdtype=[%s], dval=[%s]\n", ii,
                    (*recs)[ii].attrib, (*recs)[ii].dtype, (*recs)[ii].dval );
	}
#endif

   strcpy( barstrs[0], "PROCESS" );
   strcpy( barstrs[1], "CANCEL" );

   for ( ii=2; ii<8; ii++)	strcpy ( barstrs[ii], "");
   VDBdisplay_bar_menu ( 2, barstrs );

   sts = VDBdisplayTable( wind, *recs, tbltype, 0, norowsdisp, 
			  firstline, firstcol, maxlen1 );

   row = col = 0;
   field = 0;
   toprow = 0;
   selected = 0;
   keypad( wind, TRUE );
   wmove ( wind, firstline, firstcol );
   wattrset ( wind, A_UNDERLINE );
   while ( ! selected )
   {
     ch = wgetch( wind );
     c = ch & A_CHARTEXT;
     VDB_DISP_PADED_MSG ( "" );
     wmove( wind, firstline+row, VDB_COL );

     /* check whether the field can be edited. If no, continue */
     if ( c == CTRL_D || c == VDB_DELETE || c == CTRL_H ||
          ( c > 31 && c < 127 ) )
     {
         if ( editflag == VDB_EDITABLE )
	 { if ( (toprow+row) < minrow || (toprow+row) > maxrow ||
	            field < mincol || field>maxcol )
           {  VDB_DISP_PADED_MSG( "Can not edit this field" );
              wmove( wind, firstline+row, VDB_COL );
	      beep();
	      continue;
	   }
         }
         else
         { 
           if ( (toprow+row) >= minrow && (toprow+row) <= maxrow && 
                       field >=mincol && field<=maxcol )
           {  VDB_DISP_PADED_MSG( "Can not edit this field" );
              wmove( wind, firstline+row, VDB_COL );
	      beep();
	      continue;
	   }
	}
     }


     switch ( c )
     {
       case KEY_UP :
       case CTRL_P :
         row--;
         if ( row == -1 )
         {  if ( toprow > 0 )
	    { toprow--;
              sts = VDBdisplayTable( wind, *recs, tbltype, toprow, norowsdisp,
                               firstline, firstcol, maxlen1 );
            }
            row = 0;
         }

         wmove( wind, firstline+row, VDB_COL);
         break;


       case '\n' : 
         col = 0;
         if ( field == 0 )
         {  field = 1;
            wmove( wind, firstline+row, VDB_COL);
            break;
         }
         else
            field = 0;
         goto key_down;

       case KEY_DOWN :
       case CTRL_N  :
key_down:
         row++;
         if ( row == norowsdisp )
         { if ( toprow+row == *norecs )
           { 
             *recs = _REALLOC (*recs, (*norecs+30), struct VDBtable);
             _CheckAlloc(*recs, "records", sts, FALSE, cancel )

             for( ii= *norecs; ii< *norecs+30; ii++)
             { (*recs)[ii].attrib[0] = '\0';
               (*recs)[ii].dtype[0] = '\0';
               (*recs)[ii].dval[0] = '\0';
               VDBpadstr( (*recs)[ii].attrib, VDB_MAX_ATTRIB_LEN, ' ' );
               if ( tbltype == VDB_DTYPE )
                   VDBpadstr( (*recs)[ii].dtype, VDB_MAX_DTYPE_LEN, ' ' );
               else
                   VDBpadstr( (*recs)[ii].dval, VDB_MAX_DVAL_LEN, ' ' );
             }
             *norecs += 30;
           }
           toprow++;
           sts = VDBdisplayTable( wind, *recs, tbltype, toprow, norowsdisp,
                               firstline, firstcol, maxlen1 );
           row = norowsdisp - 1;
         }

         wmove( wind, firstline+row, VDB_COL );
         break;

       case KEY_LEFT : 
       case CTRL_B :
         col--;
         if (col < 0 ) col = 0;
         wmove( wind, firstline+row, VDB_COL );
         break;


       case KEY_RIGHT :
       case CTRL_F :
control_f:
         col++;
         if( field == 0 )
         {  if ( col > maxlen1-1 ) col = maxlen1 -1; }
         else
         {  if ( col > maxlen2-1 ) col = maxlen2 -1; }
         wmove( wind, firstline+row, VDB_COL );
         break;

       case CTRL_D:
         wdelch( wind );
         ch1 = ' ';
         if ( field == 0 )
            mvwinsch( wind, row+firstline, firstcol+maxlen1-1, ch1 );
         else
            mvwinsch( wind, row+firstline, firstcol+maxlen1+VDB_GAP+maxlen2-1, ch1 );
         wmove( wind, row+firstline, VDB_COL );
         if ( field == 0 )
               VDBdeleteChar ( (char *) (*recs)[toprow+row].attrib, col );
         else if ( tbltype == VDB_DTYPE )
               VDBdeleteChar ( (char *) (*recs)[toprow+row].dtype, col );
         else
               VDBdeleteChar ( (char *) (*recs)[toprow+row].dval, col );
     
         break;

       case CTRL_H:
       case VDB_DELETE:
         if ( col == 0 ) break;
         col--;
         mvwdelch( wind , row+firstline, VDB_COL );
         ch1 = ' ';
         if ( field == 0 )
            mvwinsch( wind, row+firstline, firstcol+maxlen1-1, ch1 );
         else
            mvwinsch( wind, row+firstline, firstcol+maxlen1+VDB_GAP+maxlen2-1, ch1 );
         wmove( wind, row+firstline, VDB_COL );
         if ( field == 0 )
               VDBdeleteChar ( (char *) (*recs)[toprow+row].attrib, col );
         else if ( tbltype == VDB_DTYPE )
               VDBdeleteChar ( (char *) (*recs)[toprow+row].dtype, col );
         else
               VDBdeleteChar ( (char *) (*recs)[toprow+row].dval, col );
         break;


       default :
         if ( c > 31 && c < 127 )
         { if ( field == 0 )
           {  mvwdelch( wind, row+firstline, firstcol+maxlen1-1 );
              mvwinsch ( wind, row+firstline, col+firstcol, ch );
	   }
           else
           {  mvwdelch( wind, row+firstline, firstcol+maxlen1+VDB_GAP+maxlen2-1 );
              mvwinsch ( wind, row+firstline, col+firstcol+maxlen1+VDB_GAP, ch );
	   }

           if ( field == 0 )
               VDBinsertChar ( (char *) (*recs)[toprow+row].attrib, c,col );
           else if ( tbltype == VDB_DTYPE )
               VDBinsertChar ( (char *) (*recs)[toprow+row].dtype, c, col );
           else
               VDBinsertChar ( (char *) (*recs)[toprow+row].dval, c, col );
           goto control_f;
         }
         break;

      case KEY_F(21):
      case KEY_F(6):
        selected = 1;
#	ifdef VDB_DEBUG
		VDSdebug( "VDB_attrib_oper(process)\n" );

		for( ii=0; ii< *norecs; ii++ ) {
  			VDSdebug( "ii=[%d], attrib=[%s], \n\tdtype=[%s], dval=[%s]\n", 
					ii, (*recs)[ii].attrib, 
					(*recs)[ii].dtype, (*recs)[ii].dval );
			}
#	endif

       break;

      case KEY_F(17):
      case KEY_F(2):
        goto cancel;
/* uncomment following statement if goto is deleted */
/*        break; */
       }
   }

   return VDB_PROCESS;

cancel:
   return VDB_EXIT;

}
