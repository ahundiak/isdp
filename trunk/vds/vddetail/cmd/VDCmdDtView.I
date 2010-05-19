/* $Id: VDCmdDtView.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtView.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtView.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/03/18  11:03:12  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
#
# Revision 1.4  1995/10/25  17:26:52  pinnacle
# Replaced: vddetail/cmd/VDCmdDtView.I for:  by tlbriggs for vds.240
#
# Revision 1.3  1995/08/28  21:43:30  pinnacle
# Replaced: ./vddetail/cmd/VDCmdDtView.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/03/22  14:54:26  pinnacle
# Replaced: vddetail/cmd/VDCmdDtView.I by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/25/95	tlb		EMS 3.2: changed cs.h to grcoordsys.h
 *
 * -------------------------------------------------------------------*/

/*
	File	VDCmdDtView.I
	Auteur	Ad Zuurhout
	Date	01-Januari-1992

	Description:
		Functions for definition of the view.

		Available functions for view:
			- VDdet_create_view.
			- VDdet_make_window.
			- VDdet_design_data.
			- VDdet_set_window_size.

	History:
		Creation Date 01-01-92
*/

class implementation VDCmdDetail;

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

%safe
#include <math.h>
%endsafe

#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "parametric.h"
#include "msdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "gocmacros.h"
#include "EMScmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "AS_status.h"
#include "grmessage.h"
#include "csdef.h"
#include "grcoordsys.h"

#include "msdef.h"
#include "msmacros.h"
#include "VDmsg.h"
#include "VDdetail.h"
#include "v_dbgmacros.h"


/* include/prototypes */
/**
  #include "VDpr_detail.h"
 **/


/* import routines */
from	IGEgragad	import gragad_cons;
from	IGEwindow	import activate;
from	IGEwindow	import add_gadget;

extern	GRclassid	OPP_IGEwindow_class_id;

/**************************************************************/
IGRboolean VDdet_create_view ( sts, gragad, name)
/**************************************************************/

/*
 * This function create and initise the graged 
 * and set the window name.
 */

IGRlong		*sts;
struct 	GRid	*gragad;
IGRchar		*name;
/*.create_view*/
{
long	msg;

  *sts = MSSUCC;

  gragad->objid = NULL_OBJID;

  __DBGpr_obj(" Gragad ", *gragad );
  __DBGpr_str(" Name   ", name );

  *sts = om$construct(  msg = message IGEgragad.gragad_cons ( &msg, name,
					0.0, 0.0, 1.0, 1.0 ),
			classname = "IGEgragad",
			obj_osnum = gragad->osnum,
			p_objid   = &gragad->objid,
			osnum     = gragad->osnum );

  if( !( *sts & msg & 1)){
    as$status( sts = *sts, action = GOTO_VALUE, value = wrapup );
    as$status( sts =  msg, action = GOTO_VALUE, value = wrapup );
  }

  __DBGpr_obj(" Gragad ", *gragad );

  return( TRUE );

wrapup:
  *sts = om$send( msg      = message Root.delete ( 1 ),
		  targetid = gragad->objid,
		  targetos = gragad->osnum,
		  senderid = NULL_OBJID );

  as$status( sts = *sts );

  *sts = MSFAIL;
  return( FALSE );
}


/**************************************************************/
IGRboolean VDdet_make_window( sts, gragad, win_name, win_id, win_range, mytype )
/**************************************************************/
/*
 * This function does the creation and activation of physical window
 */
IGRlong		*sts;
struct GRid	*gragad;
IGRchar		*win_name;
struct GRid	*win_id;
IGRdouble	*win_range;	/* MIN_X, MIN_Y, 0, MAX_X, MAX_Y, 0 */
IGRint		mytype;
/*.make_window*/
{
IGRlong		msg;
struct	GRid	mod_id;

  SetProc( VDdet_make_window ); Begin

  *sts = MSSUCC ;
  msg  = MSSUCC ;

  /*| construction of the window object	*/

  win_id->objid = NULL_OBJID;
  win_id->osnum = gragad->osnum;

  mod_id.objid = NULL_OBJID;
  mod_id.osnum = gragad->osnum;

  ex$get_modid( mod_osnum = mod_id.osnum,
		mod_id	  = &mod_id.objid ) ;

  if( mod_id.objid == NULL_OBJID ){
    /*|Object space doesn't exist */
    ex$message( msgnumb = VD_S_ObjSpNtExt );
    goto wrapup ;
  }

  __DBGpr_obj(" win_id ", *win_id );
  __DBGpr_obj(" mod_id ", mod_id );
  __DBGpr_str(" win_nm ", win_name );
  __DBGpr_dbl(" range0 ", win_range[0] );
  __DBGpr_dbl(" range1 ", win_range[1] );
  __DBGpr_dbl(" range2 ", win_range[2] );
  __DBGpr_dbl(" range3 ", win_range[3] );
  
  /* name -> NULL; No name will be defined in object environment */
  *sts = ige$construct_win(	msg		= &msg,
				win_class	= "GRwindow",
				win_objid	= &win_id->objid,
			     	mod_id		= mod_id.objid,
				mod_osnum	= mod_id.osnum,
				name		= win_name,
				dep_indep	= IGE_DEPENDENT,
				min_x		= win_range[0],
				min_y		= win_range[1],
				max_x		= win_range[3],
				max_y		= win_range[4] );

  if ( ! (*sts & msg & 1) ){
    printf(" VDdet_make_window : macro vds$construct_win failed\n");
    as$status( sts = *sts, action = GOTO_VALUE, value = wrapup );
    as$status( sts =  msg, action = GOTO_VALUE, value = wrapup );
  }

  if( mytype == VD_viewplane ){
    /*  call IGRwindow.activate message */
    *sts = om$send(	msg      = message IGEwindow.activate( &msg, 0 ),
			targetid = win_id->objid,
			targetos = win_id->osnum,
			senderid = NULL_OBJID );

    if( ! (*sts & msg & 1) ){
      /*  VDdet_make_window : msg IGEgadget.add_gadget failed */
      as$status( sts = *sts, action = GOTO_VALUE, value = wrapup );
      as$status( sts =  msg, action = GOTO_VALUE, value = wrapup );
    }
  } 

  /* Connection of the gragad with the window	*/
  *sts = om$send(	msg      = message IGEwindow.add_gadget(
						&msg, &gragad->objid, 1 ),
			targetid = win_id->objid,
			targetos = win_id->osnum,
			senderid = NULL_OBJID );

  if ( ! (*sts & msg & 1) ){
    /* VDdet_make_window : msg IGEgadget.add_gadget failed */
    as$status( sts = *sts, action = GOTO_VALUE, value = wrapup );
    as$status( sts =  msg, action = GOTO_VALUE, value = wrapup );
  }

  End ;
  *sts = MSSUCC;
  return( TRUE );

wrapup:
  *sts = MSFAIL;
  return( FALSE );
}


/**************************************************************/
IGRint VDdet_design_data( sts, pixel_unit )
/**************************************************************/
IGRlong		*sts;
IGRdouble	*pixel_unit ;	/* O */
/*.design_data*/
{
IGRdouble	rap_x, rap_y;
IGRdouble	y_on_x, x_on_y;
IGRdouble	width, height;

/*
 * This function calculate the pixel_unit, necessary to calculate the
 * view volume of the window.
 * To define the pixel_unit to following constrats are defined in
 * VDdetail.h :
 *
 * 	- screen width  dimension 	: 1184	VD_DET_DIMENS_WIDTH
 *	- screen height dimension 	: 884	VD_DET_DIMENS_HEIGHT
 *	- screen left margin		: 4	VD_DET_LEFT_MARGIN
 *	- screen right margin		: 194	VD_DET_RIGHT_MARGIN
 *      - screen top margin		: 134	VD_DET_TOP_MARGIN
 *	- screen bottom margin		: 4	VD_DET_BOTTOM_MARGIN
 *
 *	- the screen surface is simulated as an are of the sizes
 *		of 1000 by 1000 units.		VD_DET_DIMENS_MAX_X
 *						VD_DET_DIMENS_MAX_Y
 */

  *sts = MSSUCC;

  /*| Give the values of dimensions */
  width  = VD_DET_DIMENS_WIDTH  - (VD_DET_LEFT_MARGIN + VD_DET_RIGHT_MARGIN );
  height = VD_DET_DIMENS_HEIGHT - (VD_DET_TOP_MARGIN  + VD_DET_BOTTOM_MARGIN );
  rap_x  = width  / VD_DET_DIMENS_MAX_X ; 
  rap_y  = height / VD_DET_DIMENS_MAX_Y ; 
	
  /* to keep sheet's proportions, and fit it into design area */
  y_on_x = height / width;
  x_on_y = VD_DET_DIMENS_MAX_Y / VD_DET_DIMENS_MAX_X ;

  if ( x_on_y > y_on_x )	*pixel_unit = rap_y ;
  else				*pixel_unit = rap_x ;

  *sts = MSSUCC;
return( TRUE );
}


/**************************************************************/
IGRboolean VDdet_set_window_size( sts, my_obj, matrix, win_range )
/**************************************************************/
/*
 * This function calculates the window range according the the object
 * range values.
 */
IGRlong			*sts;
struct GRobj_env	*my_obj;
IGRdouble		*matrix;
IGRdouble		*win_range;	/* MIN_X, MIN_Y, MAX_X, MAX_Y */
/*.set_window_size*/
{
IGRint		resp;
GRrange		my_range;
IGRdouble       xmin, ymin, Dx, Dy;
IGRdouble	dxx, dyy, pixel_unit;

  /* define the pixel_unit */
  resp = VDdet_design_data( sts, &pixel_unit );
  if( ! resp ){
    printf(" VDdet_setwindow_size : fct VDdet_design_data failed \n");
    return FALSE;
  }

  /* definition of the window range	*/
	resp = 0;
  resp = VDdet_find_obj_range( sts,	my_obj,
                                        matrix,
                                        my_range );
  xmin = 0.0 ;
  ymin = 0.0 ;

  dxx = my_range[3] - my_range[0];		/* object size */
  dyy = my_range[4] - my_range[1];

  Dx = (dxx / ( dxx + dyy )) * VD_DET_DIMENS_MAX_X;
  Dy = (dyy / ( dxx + dyy )) * VD_DET_DIMENS_MAX_Y;

  if( Dx < 100.0 ){	 Dx = 100.0; Dy = 900.0; }
  else if( Dy < 100.0 ){ Dx = 900.0; Dy = 100.0; }

  /* calculation of the location of the window on the screen	*/

  win_range[0] = VD_DET_LEFT_MARGIN + floor( xmin * pixel_unit );	/* X */
  win_range[1] = VD_DET_TOP_MARGIN  + floor((Dx + xmin) * pixel_unit );	/* Y */
  win_range[2] = 0.0;

  win_range[3] = VD_DET_DIMENS_HEIGHT - VD_DET_RIGHT_MARGIN
		 - 4.0 - ceil( (Dy + ymin) * pixel_unit ); 		/* X */
  win_range[4] = VD_DET_DIMENS_HEIGHT - VD_DET_BOTTOM_MARGIN 
		- 4.0 - ceil( ymin * pixel_unit );			/* Y */
  win_range[5] = 0.0;

  *sts = MSSUCC;
return( TRUE );
}

/**************************************************************/
IGRboolean VDdet_set_window_size1( sts, view_volume, viewchar, matrix,
				   win_range )
/**************************************************************/
/*
 * This function calculates the window range according the the object
 * range values.
 */
IGRlong			*sts;
GRrange			view_volume;
char			viewchar;
IGRdouble		*matrix;
IGRdouble		*win_range;	/* MIN_X, MIN_Y, MAX_X, MAX_Y */
/*.set_window_size*/
{
IGRint		resp;
GRrange		my_range;
IGRdouble       xmin, ymin, Dx, Dy;
IGRdouble	dxx, dyy, pixel_unit;

  /* define the pixel_unit */
  resp = VDdet_design_data( sts, &pixel_unit );
  if( ! resp ){
    printf(" VDdet_setwindow_size : fct VDdet_design_data failed \n");
    return FALSE;
  }

/*
  / * definition of the window range	* /
  resp = VDdet_find_obj_range( sts,	my_obj,
                                        matrix,
                                        my_range );

*/
  xmin = 0.0 ;
  ymin = 0.0 ;

  switch ( viewchar )
  {
    case VD_XPOS :
    case VD_XNEG :
	dxx = view_volume[5]  - view_volume[2];
	dyy = view_volume[4]  - view_volume[1];
	break;

    case VD_YPOS :
    case VD_YNEG :
	dxx = view_volume[3]  - view_volume[0];
	dyy = view_volume[5]  - view_volume[2];
	break;

    case VD_ZPOS :
    case VD_ZNEG :
	dxx = view_volume[3]  - view_volume[0];
	dyy = view_volume[4]  - view_volume[1];
	break;
  }


  dxx = my_range[3] - my_range[0];		/* object size */
  dyy = my_range[4] - my_range[1];

  Dx = (dxx / ( dxx + dyy )) * VD_DET_DIMENS_MAX_X;
  Dy = (dyy / ( dxx + dyy )) * VD_DET_DIMENS_MAX_Y;

  if( Dx < 100.0 ){	 Dx = 100.0; Dy = 900.0; }
  else if( Dy < 100.0 ){ Dx = 900.0; Dy = 100.0; }

  /* calculation of the location of the window on the screen	*/

  win_range[0] = VD_DET_LEFT_MARGIN + floor( xmin * pixel_unit );	/* X */
  win_range[1] = VD_DET_TOP_MARGIN  + floor((Dx + xmin) * pixel_unit );	/* Y */
  win_range[2] = 0.0;

  win_range[3] = VD_DET_DIMENS_HEIGHT - VD_DET_RIGHT_MARGIN
		 - 4.0 - ceil( (Dy + ymin) * pixel_unit ); 		/* X */
  win_range[4] = VD_DET_DIMENS_HEIGHT - VD_DET_BOTTOM_MARGIN 
		- 4.0 - ceil( ymin * pixel_unit );			/* Y */
  win_range[5] = 0.0;

  *sts = MSSUCC;
return( TRUE );
}


end implementation VDCmdDetail;

