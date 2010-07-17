/* $Id: VSgraphicenv.C,v 1.1.1.1 2001/01/04 21:10:42 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:	vsio / VSgraphicenv.C
 *
 * Description:
	Basic graphic interface routines calling either
		- Environ V
		- X window
	Or calling the specific EXNUC or I/FORMS routine in either case,
	or implementing a facility when running under X which exists in
	Environ V but not X.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSgraphicenv.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:42  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.7  1996/07/29  15:53:16  pinnacle
 * Replaced: vsio/VSgraphicenv.C for:  by s240_int for struct
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	07/29/96   Suresh	TR 179602397 - bad return code for XQueryPointer
 *
 *************************************************************************/
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
#include "vsgraphicenv.h"
#include "dpgraphics.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "exproto.h"
#include "vsgrenvproto.h"


/*----------------------------------------------------------------------------*/
int VS_flipblock( wno, x, y, X, Y ) VSgrEnvWindow *wno ; int x, y, X, Y ; {


#if defined(ENV5)

	flipblock( *wno, x, y, X, Y ) ;
	return 1 ;

#elif defined(X11) 

	return 1 ;

#else
#	omerror "Windowing system switches must be set!"
#endif



} /* VS_flipblock */
/*-SCRAP BUFFER---------------------------------------------------------------*/
int VS_Clear_scrap() {



#if defined(ENV5)

	return Clear_scrap() ;

#elif defined(X11)
	return Clear_scrap_ig() ; 
#else
#	omerror "Windowing system switches must be set!"
#endif


} /* VS_Clear_scrap */
/*----------------------------------------------------------------------------*/
int VS_Put_scrap( type, buf, size ) char *type, *buf ; int size ; {




#if defined(ENV5)

	return Put_scrap( type, buf, size ) ;

#elif defined(X11)
	return Put_scrap_ig(type, buf, size) ;
#else
#	omerror "Windowing system switches must be set!"
#endif


} /* VS_Put_scrap */
/*----------------------------------------------------------------------------*/
int VS_Get_scrap( type, data, size, index )

char *type, *data ;
int *size, *index ; {



#if defined(ENV5)

	return Get_scrap( type, data, size, index ) ;

#elif defined(X11)
	return Get_scrap_ig( type, data, size, index) ;	
#else
#	omerror "Windowing system switches must be set!"
#endif


} /* VS_Get_scrap */
/*-TIMER----------------------------------------------------------------------*/
int VS_Wait_timer( time ) int time ; {


	/*
	 * For Environ V, time is in 1/60th of seconds.
	 */


#if defined(ENV5)

	 return Wait_timer( time ) ;

#elif defined(X11)
	if ( time < 60 )
		sleep(1);
	else
		sleep(time/60);

#else
#	omerror "Windowing system switches must be set!"
#endif


} /* VS_Wait_timer */
/*-MOUSE----------------------------------------------------------------------*/
int VS_Mouseposition( wno, x, y, work_status )

VSgrEnvWindow	*wno ;
int		*x,
		*y,
		*work_status ; {


	/*
	 * Environ V : Use Mouseposition ( arg *wno is a window number ("int"))
	 * X window  : Use ?             ( arg *wno is a window Id ("Window") )
	 * As Environ V's Mouseposition returns 0 if successful.
	 * Returns 0 in case of Success
	 */

#if defined(ENV5)

	return Mouseposition( *wno, x, y, work_status ) ;

#elif defined(X11)

        int     root_x,root_y, rc;
        Window  root_w,child_w;

        rc = XQueryPointer(EXdisplay,( Window )*wno,&root_w,&child_w,
                                    &root_x,&root_y,x,y,
                                        (unsigned int *)work_status);
	if (rc == True ) {
		*work_status = 1;
		return 0;
	} else {
		return 1;
	}

/*
	return WLmouse_win_position( (WLuint32 *)wno, x, y, work_status ) ;
*/
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_Mouseposition */
/*-EVENTS---------------------------------------------------------------------*/
int VS_InqEvents( events ) VSgrEnvEvent *events ; {


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

	WLuint32 lwin_no, *event ;
	int x, y, in_window ;

	WLmouse_win_position( &lwin_no, &x, &y, &in_window ) ;

  	event = (WLuint32 *)events ;	
	WLget_event_mask( lwin_no, event ) ;

	return ( *event ) ; 

#else
#	omerror "Windowing system switches must be set!"
#endif


} /* VS_InqEvents */
/*----------------------------------------------------------------------------*/
int VS_isKeyBoardEvent( events ) VSgrEnvEvent *events ; {
	
#if defined(ENV5)

	return *events & KEYBOARD_EVENT ;

#elif defined(X11)
	int *x ;
	x = (int *) events ;
	return *x & WL_KEY ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_isKeyBoardEvent */
/*----------------------------------------------------------------------------*/
int VS_isBtnOrWnEvent( events ) VSgrEnvEvent *events ; {


#if defined(ENV5)

	return *events & ( BUTTON_EVENT | WINDOW_EVENTS ) ;

#elif defined(X11)
	#define WL_WINDOW    (WL_REFRESH | WL_DELETE   | \
                                 WL_USER  | WL_COLLAPSE  )
	int *x ;
	x = (int *)events ;
	return *x & (WL_BUTTON | WL_WINDOW) ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_isBtnOrWnEvent */
/*----------------------------------------------------------------------------*/
int VS_isWnEvent( events ) VSgrEnvEvent *events ; {


#if defined(ENV5)
	return *events & WINDOW_EVENTS ;

#elif defined(X11)
#       define WL_WINDOW    (WL_REFRESH | WL_DELETE   | \
                                 WL_USER  | WL_COLLAPSE )
	int *x ;
	x = (int *)events ;
	return *x & WL_WINDOW ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_isWnEvent */
/*----------------------------------------------------------------------------*/
#if defined(ENV5)
	/*ARGSUSED*/
#	argsused
#endif
int VS_DPhandle_event( events ) VSgrEnvEvent *events ; {

	/*
	 * Environ V : call DPhandle_event().
	 * X window  : call DPhandle_event( events ) ;
	 */

#if defined(ENV5)

	return DPhandle_event() ;

#elif defined(X11)


	/* printf ("VS_DPhandle_event\n");  */

	return DPhandle_event( events ) ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_DPhandle_event */
/*-FORMS----------------------------------------------------------------------*/
int VS_FI_process_event( events ) VSgrEnvEvent *events ; {


	/*
	 * Environ V : call FI_process_event( *events ).
	 * X window  : call FI_process_event( events, transition )
	 * (transition = 1 ? ).
	 */

#if defined(ENV5)

	return FI_process_event( *events ) ;

#elif defined(X11)


	/* printf ("VS_FI_process_event\n");  */

	return FI_process_event( events, 1 ) ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_FI_process_event */
/*----------------------------------------------------------------------------*/
int VS_FIf_get_window( form, p_wno ) char *form ; VSgrEnvWindow *p_wno ; {

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

} /* VS_FIf_get_window */
/*----------------------------------------------------------------------------*/
int VS_FImouseposition( form, x, y,  work_status )

char	*form ;
int	*x,
	*y,
	*work_status ; {
	

#if defined(ENV5)

	int		rc,
			(*FImouseposition)() ;
	VSgrEnvWindow	wno ;

	FI_get_graphic_env( FI_MOUSEPOSITION, &FImouseposition ) ;
	if( ( rc = VS_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		rc = FImouseposition( wno, x, y, work_status ) ;
	}

	return rc ;

#elif defined(X11)

	VSgrEnvWindow wno ;
	int rc ;

	if ( ( rc = VS_FIf_get_window( form, &wno )) == FI_SUCCESS ) {
		WLmouse_win_position( (WLuint32 *) &wno, x, y, work_status ) ;
	}

	return rc ;

#else
#	omerror "Windowing system switches must be set!"
#endif


} /* VS_FImouseposition */
/*----------------------------------------------------------------------------*/
int VS_FIweight( form, weight ) char *form ; int weight ; {


#if defined(ENV5)

	int		(*FIweight)() ;
	VSgrEnvWindow	wno ;
	int		rc ;

	FI_get_graphic_env( FI_WEIGHT, &FIweight ) ;
	if( ( rc = VS_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		FIweight( wno, weight ) ;
	}

	return rc ;

#elif defined(X11)
	int rc ;
	VSgrEnvWindow wno ;

	if( ( rc = VS_FIf_get_window(form, &wno) ) == FI_SUCCESS){ 
		WLIwin_set_active_weight( (WLuint32)wno, weight ) ;
	}

	return rc ;

#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_FIweight */
/*----------------------------------------------------------------------------*/
int VS_FIfgcolor( form, color ) char *form ; int color ; {


#if defined(ENV5)

	int		(*FIfgcolor)() ;
	VSgrEnvWindow	wno ;
	int		rc ;


	FI_get_graphic_env( FI_FGCOLOR, &FIfgcolor ) ;
	if( ( rc = VS_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		FIfgcolor( wno, color ) ; 
	}
	return rc ;

#elif defined(X11)
	int rc ;
	VSgrEnvWindow wno ;

	/* printf ("VS_FIfgcolor\n"); */

	if( ( rc = VS_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		WLIwin_set_active_foreground((WLuint32)wno,(WLcolorref)color);
	}

	return rc ;

#else
#	omerror "Windowing system switches must be set!"
#endif


} /* VS_FIfgcolor */
/*----------------------------------------------------------------------------*/
int VS_FIhidecursor( form ) char *form ; {


#if defined(ENV5)
	int		(*FIhidecursor)() ;
	VSgrEnvWindow	wno ;
	int		rc ;
	
	FI_get_graphic_env( FI_HIDECURSOR, &FIhidecursor ) ; 

	if( ( rc = VS_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		FIhidecursor( wno ) ; 
		
	}

	return rc ; 

#elif defined(X11)
        VSgrEnvWindow wno ;
	int rc ;

	if ( (rc = VS_FIf_get_window( form, &wno )) == FI_SUCCESS) { 
		WLhide_cursor( wno, 0 ) ;
	}
        
	return rc ;

#else
#	omerror "Windowing system switches must be set!"
#endif 

} /* VS_FIhidecursor */
/*----------------------------------------------------------------------------*/
int VS_FIshowcursor( form ) char *form ; {

#if defined(ENV5)

	int		(*FIshowcursor)() ;
	VSgrEnvWindow	wno ;
	int		rc ;
	

	FI_get_graphic_env( FI_SHOWCURSOR, &FIshowcursor ) ;
	
	if( ( rc = VS_FIf_get_window( form, &wno ) ) == FI_SUCCESS ) {
		 FIshowcursor( wno ) ; 
	}
	return rc ;


#elif defined(X11)
	int rc ;
	VSgrEnvWindow win ;

	/* printf ("VS_FIshowcursor\n") ; */

	if( (rc=VS_FIf_get_window(form, &win)) == FI_SUCCESS ) {
		WLshow_cursor( (WLuint32) win ) ;
	}
	return rc ;
#else
#	omerror "Windowing system switches must be set!"
#endif

} /* VS_FIshowcursor */
/*----------------------------------------------------------------------------*/
