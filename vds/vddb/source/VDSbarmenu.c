/* $Id: VDSbarmenu.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddb/source / VDSbarmenu.c
 *
 * Description:
 *	Bar menu functions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSbarmenu.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  1998/10/23  16:42:26  pinnacle
 * Replaced: vddb/source/VDSbarmenu.c for:  by vsrivast for vds
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
 * Revision 1.1  1996/05/20  05:08:06  pinnacle
 * Created: vddb/source/VDSbarmenu.c by v240_int for vds.240
 *
 *
 * History:
 *	05/09/96   tlb		Created from functions in VDSload.C
 *	10/22/98   vinit	TR 179802013. F1 key cannot be used 
 *				under Solaris 2.6. So some remapping has been
 *				done for the keys and hence the display
 *				has been changed by changing some keystrs.
 *				The new mappings:
 *				F2	CANCEL		(Unchanged)
 *				F3	CLR_FIELD	(Unchanged)
 *				F4	SELECT_ALL	(Unchanged)
 *				F5	UNSELECT_ALL	(Unchanged)
 *				F6	PROCESS		(Changed : Earlier F1)
 *				F7	SELECT		(Changed : Earlier F1)
 *************************************************************************/

#include <stdio.h>
#include <string.h>
#include <curses.h>
#include "VDmem.h"
#include "v_risproto.h"
#include "v_dbloadprot.h"


/* Local variables */
static 	WINDOW  *VDBbarwin;
static  int     bar_width, bar_spacing;


/* --------------------------------------------------------------------------
VDBrefresh_bar_menu
    Refresh bar menu 
    	This seems to be the only way to clear out extra entries
----------------------------------------------------------------------------*/
void VDBrefresh_bar_menu ()
{
   VDB_DELETE_WIN ( VDBbarwin );
   VDBmake_bar_win();
}

/* --------------------------------------------------------------------------
Doc :  VDBdisplay_bar_menu

  Desc : It pads the given strings with blanks upto bar_width
         and displays them in the bar_menu.
----------------------------------------------------------------------------*/
void VDBdisplay_bar_menu(
  int     num_strs,
  char    barstrs[8][9]  /* i - input strings */
)
{
	int    ii, jj, len;
	char   str[9];
	char keystrs[8][9];

	num_strs = (num_strs > 8) ? 8 : num_strs;

	/* Create first row of input strings */
	for( ii = 0; ii<num_strs ; ii++ ){ 
	  	strncpy ( str, barstrs[ii], bar_width );
     	  	len = strlen ( str );
      	  	for ( jj=len; jj< bar_width; jj++)	str[jj] = ' ';
	  	str[bar_width] = '\0';
	  	mvwaddstr( VDBbarwin, 0, ii*(bar_width+bar_spacing), str );

#		ifdef VDB_DEBUG
	 	     VDSdebug( "barstrs[%d] = %s\n", ii, str );
#		endif
		}

 
	/* Define function key names */
#ifdef X11
	/*** Following line changed for TR 179802013. F1 key 
	     mapped to desktop help on Solaris 2.6. So, keys 
	     have been reorganised ***/ 
	     
	/* strcpy(keystrs[0],"     F1");  */
	strcpy(keystrs[0],"     F6");

	/**************************************/
	strcpy(keystrs[1],"     F2");
	strcpy(keystrs[2],"     F3");
	if ( strlen (barstrs[3]))
	  strcpy(keystrs[3],"ALL  F4");
	else
	  strcpy(keystrs[3],"     F4");
	strcpy(keystrs[4],"ALL  F5");
#else
	strcpy(keystrs[0],"    PF1");
	strcpy(keystrs[1],"    PF2");
	strcpy(keystrs[2],"    PF3");
	if ( strlen (barstrs[3]))
	  strcpy(keystrs[3],"ALL PF4");
	else
	  strcpy(keystrs[3],"    PF4");
	strcpy(keystrs[4],"ALL PF5");
#endif
	/**** Following Changes for TR 179802013******/

	/*  strcpy(keystrs[5],""); */
	strcpy(keystrs[5],"    F7");

	/*********************************************/
	strcpy(keystrs[6],"");
	strcpy(keystrs[7],"");
 
	/* Create second row of function key names */
        for( ii=0; ii<num_strs ; ii++ ){

		/* Changes for TR 179802013. F1 key mapped to Desktop help 
		   in Solaris 2.6. So, Keys have been remapped and hence the
		   following changes in the keystrs. The PROCESS key is made
		   F6 and the SELECT key is F7. Both were earlier F1 */

		if(!strcmp(barstrs[ii], "PROCESS"))
          		strncpy ( str, keystrs[0], bar_width );
		else if(!strcmp(barstrs[ii], "SELECT") && ii!=3)
          		strncpy ( str, keystrs[5], bar_width );

		/*****************************************************/
		else
          		strncpy ( str, keystrs[ii], bar_width );
          	len = strlen ( str );
          	for ( jj=len; jj< bar_width; jj++) str[jj] = ' ';
          	str[bar_width] = '\0';
          	mvwaddstr( VDBbarwin, 1, ii*(bar_width+bar_spacing), str );
 
#	  	ifdef VDB_DEBUG
	  	   VDSdebug( "barstrs[%d] = %s\n", ii, str );
#	  	endif
          	}
 
	wrefresh ( VDBbarwin );
}

/* --------------------------------------------------------------------------
Doc :  VDBmake_bar_win

  Desc : It calculates bar_width and bar_spacing for bar_menu and
         creates a window with those variables. The bar_width and spacing
         is calculated depending upon extern vars COLS.

----------------------------------------------------------------------------*/
void VDBmake_bar_win()

{
   VDBbarwin = newwin ( 2, COLS, LINES-2, 0 ); 
   wattrset ( VDBbarwin, A_REVERSE );

   bar_width = 8;
   bar_spacing = 2;

   if ( COLS < 80 )
   {  bar_spacing = 1;
      bar_width = ( COLS - 7*bar_spacing )/8;
      if ( bar_width > 8 ) bar_width = 8;
   }

#ifdef VDB_DEBUG
    VDSdebug( "bar menu : width=%d, spacing=%d\n", bar_width, bar_spacing );
#endif

}

