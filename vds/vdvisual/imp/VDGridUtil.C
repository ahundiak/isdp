/* $Id: VDGridUtil.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/imp / VDGridUtil.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGridUtil.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
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
 * Revision 1.5  1995/12/13  19:48:30  pinnacle
 * Replaced: vdvisual/imp/VDGridUtil.C for:  by yzhu for vds.240
 *
 * Revision 1.4  1995/11/21  00:58:52  pinnacle
 * Replaced: ./vdvisual/imp/VDGridUtil.C for:  by azuurhou for vds.240
 *
 * Revision 1.3  1995/11/06  08:15:42  pinnacle
 * Replaced: vdvisual/imp/VDGridUtil.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/10/31  17:22:10  pinnacle
 * Replaced: vdvisual/imp/VDGridUtil.C for:  by sundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/31/95	Sundar		Added XWINDOW calls
 *	11/05/95	tlb		Remove X11 include - breaks on Clipper
 *					Remove inconsistent ext declarations
 * -------------------------------------------------------------------*/

#include <stdio.h>
#include "msdef.h"
#include "msmacros.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "v_dbgmacros.h"
#include <wl.h>

#ifdef ENV5
extern void Wait_timer(),
	    Inq_weight(),
	    weight(),
	    Inq_fgcolor(),
	    fgcolor(),
	    Inq_linestyle(),
	    linestyle(),
	    move(),
	    draw() ;
#endif


/*----------------------------------------------------------------------------*/
void tellUser( msgnumb )
long	msgnumb ;
/*.tellUser*/ {

	char	*in_buff ;
	int	prt_in_keyin_field = FALSE ;

	switch( msgnumb ) {

	case 0 : in_buff = "Not a principal view" ;		break ;
	case 1 : in_buff = "Cannot convert this window" ;	break ;
	case 2 : in_buff = "Cannot set dynamic this window" ;	break ;
	case 3 : in_buff = "Cannot rotate this window" ;	break ;
	case 4 : in_buff = "< Cannot modify this window >" ;
			 prt_in_keyin_field = TRUE ;		break ;
	default : in_buff = NULL ;				break ;
	}

	ex$message( field	  = prt_in_keyin_field ? KEYIN_FIELD :
							 ERROR_FIELD,
		    justification = CENTER_JUS,
		    in_buff	  = in_buff ) ;

	if( prt_in_keyin_field ) {
		/* Wait_timer( 90 ) ;    Sundar */
		ex$message( field	  = KEYIN_FIELD,
			    in_buff	  = "" ) ;
	}

} /* tellUser */

/* ****************************************************************************

   History :

   30 Jun 1993   Raju   2.2.0    changed the offsets to the border. Now the
				 border fully lies in VDgragadGrid.

   ***************************************************************************/

/*----------------------------------------------------------------------------*/
void drawWnGridBorder( wno, min_x, min_y, max_x, max_y )

int	wno,
	min_x,
	min_y,
	max_x,
	max_y ;

{
	int			lscreen_type ;
	WLuint16		lscreen;
	WLuint32		ctx_num;
	struct WLnative_info	native_info;
	long			sts;

#ifdef	ENV5
	int			oldWeight,
				oldColor,
				oldLinestyle ;
#endif

#ifdef X11
	XGCValues		actGCValues;
	XGCValues		newGCValues;
#endif

	SetProc( drawWnGridBorder ); Begin

	/*=============================================================*/
	/*  Get the Env5 window number from the logical window number  */
	/*=============================================================*/

	sts = WLget_active_screen ( &lscreen, &lscreen_type );
	if (sts != WL_SUCCESS) { return ; }

	sts = CMget_active_context ( lscreen, &ctx_num );
	if (sts != WL_SUCCESS) { return ; }

	sts = WLget_native_info ( wno, ctx_num, &native_info );
	if (sts != WL_SUCCESS) { return ; }

	/*
	 * Draw the border of the gragad which display the view.
	 */

#ifdef ENV5
	__DBGpr_com(" Checking on ENV5 ");
	Inq_weight(	native_info.base_win, &oldWeight ) ;
	Inq_fgcolor(	native_info.base_win, &oldColor ) ;
	Inq_linestyle(	native_info.base_win, &oldLinestyle ) ;

	weight(		native_info.base_win, 1 ) ;
	fgcolor(	native_info.base_win, 1 ) ;
	linestyle(	native_info.base_win, 0xf3f3 ) ;

	move( native_info.base_win, min_x, min_y ) ;
	draw( native_info.base_win, min_x, max_y-1 ) ;
	draw( native_info.base_win, max_x, max_y-1 ) ;

	weight(		native_info.base_win, oldWeight ) ;
	fgcolor(	native_info.base_win, oldColor ) ;
	linestyle(	native_info.base_win, oldLinestyle ) ;

#elif defined(X11)
 
	__DBGpr_com(" Checking on X11 ");
 
	sts =
	XGetGCValues( native_info.display, native_info.gc,
                      GCLineStyle | GCLineWidth | GCDashOffset | GCForeground,
                      &actGCValues);

	/****  Set the new symbology values  ****/
 
	newGCValues.line_style  = 2;
	newGCValues.line_width  = 1;
	newGCValues.dash_offset = 100;
	newGCValues.foreground  = WhitePixel (native_info.display, 
                                             native_info.screen);
 
	sts =
	XChangeGC(native_info.display, native_info.gc,
                  GCLineStyle | GCLineWidth | GCDashOffset | GCForeground,
                  &newGCValues);

	XDrawLine(native_info.display, native_info.base_win, native_info.gc,
                  min_x, min_y, min_x, (max_y-1));
 
	XDrawLine(native_info.display, native_info.base_win, native_info.gc,
                  min_x, (max_y-1), max_x, (max_y-1));
 
	/****  restoring the original values  ****/
	sts =
        XChangeGC(native_info.display, native_info.gc,
                  GCLineStyle | GCLineWidth | GCDashOffset | GCForeground,
                  &actGCValues);
 
#else
#error "windowing system other than X11 and ENV5"
#endif

	End

} /* drawWnGridBorder */
/*----------------------------------------------------------------------------*/
