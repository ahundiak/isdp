/* $Id: VDgraphicenv.C,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/func / VDgraphicenv.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgraphicenv.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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
 * Revision 1.3  1995/10/30  16:33:48  pinnacle
 * Replaced: vdlocate/func/VDgraphicenv.C for:  by sundar for vds.240
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
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS
	Basic graphic interface routines calling either
		- Environ V
		- X window
	Or calling the specific EXNUC or I/FORMS routine in either case,
	or implementing a facility when running under X which exists in
	Environ V but not X.

        Note : This file has been taken from I/STRUCT. All "VS" changed to "VD"
               (R. Manem)
*/
#if defined(ENV5)
#	include <tools.h>

	extern int		Inq_weight() ;
	extern int		Inq_fgcolor() ;
	extern int		Clear_scrap() ;
	extern int		Put_scrap() ;
	extern int		Get_scrap() ;
	extern int		Wait_timer() ;
	extern int		Mouseposition() ;
	extern void		flipblock() ;

#elif defined(X11)
#	include <X11/Xlib.h>
#	include <X11/Xutil.h>
#else
#	omerror "Windowing system switches must be set!"
#endif

#include <FI.h>
#include <FEI.h>
#include "vdgraphicenv.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "exproto.h"

/*----------------------------------------------------------------------------*/
int VD_flipblock( wno, x, y, X, Y ) VDgrEnvWindow *wno ; int x, y, X, Y ; {

#if defined(ENV5)

	flipblock( *wno, x, y, X, Y ) ;
	return 1 ;

#elif defined(X11)
/* #	omerror "VD_flipblock not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_flipblock */
/*-SCRAP BUFFER---------------------------------------------------------------*/
int VD_Clear_scrap() {

#if defined(ENV5)

	return Clear_scrap() ;

#elif defined(X11)
/* #	omerror "VD_Clear_scrap not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_Clear_scrap */
/*----------------------------------------------------------------------------*/
int VD_Put_scrap( type, buf, size ) char *type, *buf ; int size ; {

#if defined(ENV5)

	return Put_scrap( type, buf, size ) ;

#elif defined(X11)
/* #	omerror "VD_Put_scrap not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_Put_scrap */
/*----------------------------------------------------------------------------*/
int VD_Get_scrap( type, data, size, index )

char *type, *data ;
int *size, *index ; {

#if defined(ENV5)

	return Get_scrap( type, data, size, index ) ;

#elif defined(X11)
/* #	omerror "VD_Get_scrap not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_Get_scrap */
/*-TIMER----------------------------------------------------------------------*/
int VD_Wait_timer( time ) int time ; {

	/*
	 * For Environ V, time is in 1/60th of seconds.
	 */

#if defined(ENV5)

	 return Wait_timer( time ) ;

#elif defined(X11)
/* #	omerror "VD_Wait_timer not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_Wait_timer */
/*-MOUSE----------------------------------------------------------------------*/
int VD_Mouseposition( wno, x, y, work_status )

VDgrEnvWindow	*wno ;
int		*x,
		*y,
		*work_status ; {

	/*
	 * Environ V : Use Mouseposition ( arg *wno is a window number ("int"))
	 * X window  : Use ?             ( arg *wno is a window Id ("Window") )
	 * As Environ V's Mouseposition returns 0 if successful.
	 */

#if defined(ENV5)

	return Mouseposition( *wno, x, y, work_status ) ;

#elif defined(X11)
/* #	omerror "VD_Mouseposition not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_Mouseposition */
/*-EVENTS---------------------------------------------------------------------*/
int VD_InqEvents( events ) VDgrEnvEvent *events ; {

	/*
	 * Environ V : Use EX_inq_events
	 * X Window  : Use ?
	 */

#if defined(ENV5)

#	define WINDOW_EVENTS	(REFRESH_EVENT  | DELETE_EVENT   | \
				 COVER_EVENT    | USER_EVENT     | \
				 COLLAPSE_EVENT | WINDOW_USER_ICON_EVENT)
#	define INPUT_EVENTS	(BUTTON_EVENT | KEYBOARD_EVENT | TIMER_EVENT)

#	define CATCH_EVENTS	(INPUT_EVENTS | WINDOW_EVENTS)

	*events = 0 ;
	EX_inq_events( events ) ;
	
	return ( *events & CATCH_EVENTS ) ;

#elif defined(X11)
/* #	omerror "VD_InqEvents not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_InqEvents */
/*----------------------------------------------------------------------------*/
int VD_isKeyBoardEvent( events ) VDgrEnvEvent *events ; {

#if defined(ENV5)

	return *events & KEYBOARD_EVENT ;

#elif defined(X11)
/* #	omerror "VD_isKeyBoardEvent not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_isKeyBoardEvent */
/*----------------------------------------------------------------------------*/
int VD_isBtnOrWnEvent( events ) VDgrEnvEvent *events ; {

#if defined(ENV5)

	return *events & ( BUTTON_EVENT | WINDOW_EVENTS ) ;

#elif defined(X11)
/* #	omerror "VD_isBtnOrWnEvent not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_isBtnOrWnEvent */
/*----------------------------------------------------------------------------*/
int VD_isWnEvent( events ) VDgrEnvEvent *events ; {

#if defined(ENV5)

	return *events & WINDOW_EVENTS ;

#elif defined(X11)
/* #	omerror "VD_isWnEvent not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_isWnEvent */
/*----------------------------------------------------------------------------*/
#if defined(ENV5)
	/*ARGSUSED*/
#	argsused
#endif
int VD_DPhandle_event( events ) VDgrEnvEvent *events ; {

	/*
	 * Environ V : call DPhandle_event().
	 * X window  : call DPhandle_event( events ) ;
	 */

#if defined(ENV5)

	return DPhandle_event() ;

#elif defined(X11)

	return DPhandle_event( events ) ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_DPhandle_event */
/*-FORMS----------------------------------------------------------------------*/
int VD_FI_process_event( events ) VDgrEnvEvent *events ; {


	/*
	 * Environ V : call FI_process_event( *events ).
	 * X window  : call FI_process_event( events, transition )
	 * (transition = 1 ? ).
	 */

#if defined(ENV5)

	return FI_process_event( *events ) ;

#elif defined(X11)

	return FI_process_event( events, 1 ) ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_FI_process_event */
/*----------------------------------------------------------------------------*/
int VD_FIf_get_window( form, p_wno ) char *form ; VDgrEnvWindow *p_wno ; {

	int	rc ;

#if defined(ENV5)

	int	fwno ;

	/*
	 * `FIf_get_window' returns an Environ V hardware window number.
	 */
	rc = FIf_get_window( form, &fwno ) ;
	*p_wno = fwno ;

#elif defined(X11)

	Window	fwid ;

	/*
	 * `FIf_get_window' returns an X Window window id.
	 */
	rc = FIf_get_window( form, &fwid ) ;
	*p_wno = fwid ;

#else
#	omerror "Windowing system switches must be set!"
#endif
	return rc ;

} /* VD_FIf_get_window */
/*----------------------------------------------------------------------------*/
int VD_FImouseposition( form, x, y,  work_status )

char	*form ;
int	*x,
	*y,
	*work_status ; {


#if defined(ENV5)

	int		rc,
			(*FImouseposition)() ;
	VDgrEnvWindow	wno ;

	FI_get_graphic_env( FI_MOUSEPOSITION, &FImouseposition ) ;
	if( ( rc = VD_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		rc = FImouseposition( wno, x, y, work_status ) ;
	}

	return rc ;

#elif defined(X11)
/* #	omerror "VD_FImouseposition not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_FImouseposition */
/*----------------------------------------------------------------------------*/
int VD_FIweight( form, weight ) char *form ; int weight ; {

#if defined(ENV5)

	int		(*FIweight)() ;
	VDgrEnvWindow	wno ;
	int		rc ;

	FI_get_graphic_env( FI_WEIGHT, &FIweight ) ;
	if( ( rc = VD_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		FIweight( wno, weight ) ;
	}

	return rc ;

#elif defined(X11)
/* #	omerror "VD_FIweight not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_FIweight */
/*----------------------------------------------------------------------------*/
int VD_FIfgcolor( form, color ) char *form ; int color ; {

#if defined(ENV5)

	int		(*FIfgcolor)() ;
	VDgrEnvWindow	wno ;
	int		rc ;

	FI_get_graphic_env( FI_FGCOLOR, &FIfgcolor ) ;
	if( ( rc = VD_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		FIfgcolor( wno, color ) ;
	}
	return rc ;

#elif defined(X11)
/* #	omerror "VD_FIfgcolor not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_FIfgcolor */
/*----------------------------------------------------------------------------*/
int VD_FIhidecursor( form ) char *form ; {

#if defined(ENV5)

	int		(*FIhidecursor)() ;
	VDgrEnvWindow	wno ;
	int		rc ;
	
	FI_get_graphic_env( FI_HIDECURSOR, &FIhidecursor ) ;
	
	if( ( rc = VD_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		FIhidecursor( wno ) ;
	}
	return rc ;

#elif defined(X11)
/* #	omerror "VD_FIhidecursor not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_FIhidecursor */
/*----------------------------------------------------------------------------*/
int VD_FIshowcursor( form ) char *form ; {

#if defined(ENV5)

	int		(*FIshowcursor)() ;
	VDgrEnvWindow	wno ;
	int		rc ;
	
	FI_get_graphic_env( FI_SHOWCURSOR, &FIshowcursor ) ;
	
	if( ( rc = VD_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		FIshowcursor( wno ) ;
	}
	return rc ;

#elif defined(X11)
/* #	omerror "VD_FIshowcursor not defined for X Window" */
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VD_FIshowcursor */
/*----------------------------------------------------------------------------*/
