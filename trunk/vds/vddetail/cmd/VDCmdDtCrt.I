/* $Id: VDCmdDtCrt.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtCrt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtCrt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1997/02/04  05:10:32  pinnacle
# Replaced: vddetail/cmd/VDCmdDtCrt.I for:  by rgade for vds.241
#
# Revision 1.2  1996/08/12  09:17:34  pinnacle
# Replaced: vddetail/cmd/VDCmdDtCrt.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/08/28  21:42:32  pinnacle
# Replaced: ./vddetail/cmd/VDCmdDtCrt.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/05/10  13:10:50  pinnacle
# Replace: vddetail/cmd/VDCmdDtCrt.I by azuurhou for OPE
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
 *
 * -------------------------------------------------------------------*/

/*
	File	VDSdet_crt.I
	Auteur	Ad Zuurhout
	Date	19-Mai-1992

	Description:
		This file contains a method to display more than one 
		drawing views from different reference object spaces at one 
		given event location.
	History:
		Creation Date 19-Mai-92
*/

class implementation VDCmdDetail;

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "UOMmacros.h"
#include "UOM.h"

#include "bserr.h"
#include "bstypes.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMerrordef.h"
#include "execmsg.h"
#include "grmessage.h"
#include "detailcodef.h"
#include "detailco.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "toolco.h"
#include "grerr.h"
#include "msdef.h"
#include "referr.h"

#include "exdef.h"
#include "exmacros.h"
#include "exproto.h"
#include "msmacros.h"

#include "dpdef.h"
#include "dpmacros.h"

#include "AS_status.h"

/* include/prototypes */
#include "maidmx.h"
#include "matypemx.h"
/**
  #include "VDpr_detail.h"
  #include "VDpr_dtlref.h"
 **/

#include "vddlodef.h"
#include "vddlomacros.h"

#define  VD_GET_LAYER_FROM_DLO  1


#define AS_DEBUG	1

from	GRvg		import	GRgetgeom;
from	GRdrawview	import	GRget_drawview_scale;
from	GRgraphics	import	GRxform, GRdisplay;

extern GRget_to_comp_chansel();

/**************************************************************/
/* MESSAGE create_drawview( int * sts )
/**************************************************************/

method create_drawview( long * sts )
{
int	status = OM_S_SUCCESS;
long	loc_sts;
struct	GRevent 	loc_event;
int	to_deep = TRUE;
short   oldActiveLevel;
char    default_unit[10][15];
char    current_unit[10][15];
IGRboolean      flag=FALSE;
short           num_defaults, num_def;
long            msg;
/*
UOMalias_name   dbualias;
*/

    /*
     * assign the event location (window_id and window_matrix) to
     * the reference file window
     */
  
    /* copy the window object */
    me->window_id.objid = me->event1.event.button.objid;
    me->window_id.osnum = me->event1.event.button.osnum;

    /* copy the window matrix */
    /* replace by the function contents of GRget_window_matrix */
    status =
    om$send(msg = message COtools.assign( (char *)&me->event1.event.button,
					  (char *)me->window_matrix,
					  CO_btn_to_mtx ),
	    targetid = my_id );
    if(!(status&1)) goto wrapup;

    loc_event = me->event1;

    status =
    om$send(msg = message VDCmdDetail.construct_objview( &loc_sts ),
	    targetid = my_id );
    if(!(status&loc_sts&1)){
      ex$message(msgnumb = GR_E_ErrEncCmdRst );
      goto wrapup;
    }

    status =
    om$send(msg = message VDCmdDetail.object_disconnect( &loc_sts ),
	    targetid = my_id );
    as$status( action = RET_STATUS );


#ifdef  VD_GET_LAYER_FROM_DLO
    {
	long		sts1, msg;
	VD_drwLoInfo	drwLoInfo;

	oldActiveLevel = me->ActiveLevel;
	sts1 = vd$drw_layout_info ( msg	 = &msg,
				    type = VD_K_drwLO_drvLevel,
				    info = &drwLoInfo  );
	if ( sts1 == VD_UNDEFINED )
	{
	   /* not defined . need not do any thing */
	}
	else if ( !(sts1&msg&1) )
	{
	  /* collector does not exists or some problem. need not do anything */
	}
	else
	{
	   me->ActiveLevel = drwLoInfo.val.sValue;
	}
    }
#endif
     /* TR#179527420 & 179603612  -02/03/97 --Ravi */

    status = co$get_default_units (     msg = &msg,
                                        table_name = "UOM_DISTANCE",
                                        osnum = me->VDcur_os,
                                        flag = &flag,
                                        num_defaults = &num_def,
                                        default_units = current_unit );
    if(!(status & msg & 1)) goto wrapup;
    status = co$get_default_units (     msg = &msg,
                                        table_name = "UOM_DISTANCE",
                                        osnum = me->VDref_os,
                                        flag = &flag,
                                        num_defaults = &num_defaults,
                                        default_units = default_unit );
    if(!(status & msg & 1)) goto wrapup;
    status = co$put_default_units (     msg = &msg,
                                        table_name = "UOM_DISTANCE",
                                        osnum = me->VDcur_os,
                                        flag = &flag,
                                        num_defaults = &num_defaults,
                                        default_units = default_unit );
    if(!(status & msg &1)) goto wrapup;

    status =
    om$send(msg = message COdetail.construct_drawview( &loc_sts ),
            targetid = my_id );
    if(!(status&1)) goto wrapup;

    status = co$put_default_units (     msg = &msg,
                                        table_name = "UOM_DISTANCE",
                                        osnum = me->VDcur_os,
                                        flag = &flag,
                                        num_defaults = &num_def,
                                        default_units = current_unit );
    if(!(status &  msg & 1)) goto wrapup;


#ifdef  VD_GET_LAYER_FROM_DLO
    /*
     * first set the active layer back to old active layer
     */
    me->ActiveLevel = oldActiveLevel;
#endif

    /*
     * show response of contruct_objview method
     */
    if( loc_sts == GRFILENOTFOUND ){
      ex$message( msgnumb = GR_E_FlNotFnd ); goto wrapup; }

    if( loc_sts == GRVIEWNOTFOUND ){
      ex$message( msgnumb = GR_E_SvVwNotFnd ); goto wrapup; } 

    if( loc_sts == GRSDGNEXCEED ){
      ex$message( msgnumb = GR_E_InvScFac ); goto wrapup; }

    if( loc_sts == GR_E_INV_REQUEST ){
      ex$message( msgnumb = GR_E_FlCantOpn ); goto wrapup; }

    if( loc_sts == OM_E_NO_OS_AVAIL ){
      ex$message( msgnumb = GR_E_MaxRfFl ); goto wrapup; }

    if( loc_sts == MSFAIL ){
      ex$message( msgnumb = GR_E_ErrEncCmdRst ); goto wrapup; }

    if( loc_sts == OM_I_DUPLICATE_OS ||
        loc_sts == MSSUCC ){

      if( loc_sts == OM_I_DUPLICATE_OS ){
        ex$message( msgnumb = EX_F_DupIntOSName );
      }

      /* do display_mode GRbd */
      me->DisplayMode = GRbd;

      status =
      om$send(msg = message VDCmdDetail.VDdet_display_located( &loc_sts ),
  	      targetid = my_id );
      if(!(status&loc_sts&1)) goto wrapup;

      /*| construct default coordinate system */
      status =
      om$send(msg = message COdetail.construct_default_cs( &loc_sts ),
	      targetid = my_id );
      as$status( action = RET_STATUS );
    }
    else{
      /* error in return value */
      goto wrapup;
    }

    status =
    om$send(msg = message VDCmdDetail.VDadd_view_info( &loc_sts ),
	    targetid = my_id );
    if(!(status&loc_sts&1)) goto wrapup;

    status =
    om$send(msg = message VDCmdDetail.clear_objects( &loc_sts ),
            targetid = my_id );
    if(!(status&loc_sts&1)) goto wrapup;

    to_deep = FALSE;

    *sts = MSSUCC;

    if ( to_deep ){
       /*
        * give error message as result of selected plane of plane of 2nd level
	* of reference file
        */
	UI_status( "Only planes of (nested) reference files allowed ");
	*sts = MSFAIL;
     }

     return( OM_S_SUCCESS );

wrapup:

  /*| wrapup */
  *sts = MSFAIL;
  return( OM_S_SUCCESS );
}


/**************************************************************/
/* MESSAGE VDadd_view_info( long * sts )
/**************************************************************/
method VDadd_view_info ( long * sts )
{
/*
 * This method add view information to the drawig view.
 */
int		status = OM_S_SUCCESS;
IGRlong		msg;
IGRint          i;
IGRshort        matrix_type;
IGRmatrix       matrix;

  *sts = MSSUCC;

  status =
  om$send(msg = message COdetail.get_name_from_matrix( sts ),
	  targetid = my_id );
  as$status( action = RET_STATUS );

  /*" cs_id : %d,%d\n", me->cs_id.objid,me->cs_id.osnum */

  /*
   *  Build a translation matrix with replaced origin.
   */

  MAidmx(sts, matrix);
  for(i=0;i<3;i++) matrix[3+4*i] -= me->VDvec_origin[i];
  /*
   * Transform the coordinate system.
   */
  MAtypemx (sts, matrix, &matrix_type);
  status =
  om$send(msg = message GRgraphics.GRxform ( &msg, 	&me->ModuleInfo,
                                                        &matrix_type, 
                                                        matrix, 
                                                        &me->cs_id.objid ),
          targetos = me->cs_id.osnum,
          targetid = me->cs_id.objid);
  as$status( action = RET_STATUS );

/***
  MAidmx(sts, matrix);
  for(i=0;i<16;i++) matrix[i] = me->VDdet_matrix[i];
  MAtypemx (sts, matrix, &matrix_type);
  status =
  om$send(msg = message GRgraphics.GRxform ( &msg, 	&me->ModuleInfo,
                                                        &matrix_type, 
                                                        matrix, 
                                                        &me->cs_id.objid ),
          targetos = me->cs_id.osnum,
          targetid = me->cs_id.objid);
  as$status( action = RET_STATUS );
 ***/

  /* do display_mode GRbd */
  me->DisplayMode = GRbd;

  status =
  om$send(msg = message COdetail.send_foreign( CO_display_cs ),
          targetid = my_id);
  as$status( action = RET_STATUS );

  status =
  om$send(msg = message COtools.empty_channel(&me->located_chansel),
	  targetid = my_id );
  as$status( action = RET_STATUS );

  *sts = MSSUCC;
  return( OM_S_SUCCESS );
}


/**************************************************************/
/* MESSAGE set_grid_flags_off( long * sts )
/**************************************************************/
method set_grid_flags_off( long * sts )
{
/*
 * This method looks for the active values of the grid flags GRID_ON and 
 * GRID_LOCK. It stores the initial values in a structure before the 
 * lc$locate of the plane to be selected.
 * After the object is selected the method reset_grid_flags reset the window
 * to their initial values.
 */
int		status = OM_S_SUCCESS;
IGRint		flag, flags[2];
IGRlong		msg, return_bytes, error;
IGRchar		path[80], path_buf[80], **lines;
IGRlong		i;
struct	digrid	*grids;
DIint		count;
GRspacenum	cur_os;
struct var_list	gad_list[2];

  grids = NULL;
  count = 0;

  status = om$vla_set_dimension( varray = me->vw_grid, size = 0 );

  status = ex$get_cur_mod(	osnum	= &cur_os );
  status = di$give_pathname(	osnum	= cur_os, pathname = path );
  if(!(status&1)){
    printf(" Can't get pathname of current file ");
    goto wrapup;
  }

  /*" File [%d]: %s\n", cur_os, path */
  sprintf( path_buf, "%s:views:regviews:GRviews", path );
  /*" Path: %s\n", path_buf */

  status = di$find(	start_dir	= path_buf,
			lines		= &lines,
			grids		= &grids,
			ptr		= &count );
  if(!(status&1)){
    printf(" di$find fails \n");
    goto wrapup;
  }

  /*^
    for(i=0;i<count;i=i+1){
      printf(" window: [%d,%d] -> %s\n", grids[i].objid, grids[i].osnum, lines[i] );
    }
   */

  status = om$vla_set_dimension( varray = me->vw_grid, size = count );

  for( i=0; i<count; i++){
    /*
     * test if window grid lock is active 
     */
    me->vw_grid[i].grid.objid	= grids[i].objid;
    me->vw_grid[i].grid.osnum	= grids[i].osnum;
    me->vw_grid[i].flags	= 0x0;
    /*" window [%d,%d] -> %s\n",grids[i].objid,grids[i].osnum,lines[i] */

    gad_list[0].var		= GRAGAD_FLAGS;
    gad_list[0].var_ptr		= (char *)&me->vw_grid[i].flags;
    gad_list[0].num_bytes	= sizeof(IGRint);
    gad_list[0].bytes_returned	= &return_bytes;

    gad_list[1].var	 	= END_PARAM;
  
    status =
    dp$inq_set_gragad(	msg		= &msg,
			which_error	= &error,
			var_list	= gad_list,
			gragad_objid	= grids[i].objid,
			osnum		= grids[i].osnum );
    if(!(status&1)) continue;

    /*
     * set the GRID_ON and GRID_LOCK of
     */
    flag = me->vw_grid[i].flags;
    if( me->vw_grid[i].flags & GRID_ON  ) flag &= ~GRID_ON;
    if( me->vw_grid[i].flags & GRID_LOCK) flag &= ~GRID_LOCK;

    flags[0] = 0xffffffff;
    flags[1] = flag;

    gad_list[0].var		= GRAGAD_FLAGS;
    gad_list[0].var_ptr		= (char *)flags;
    gad_list[0].num_bytes	= sizeof(IGRint) * 2;
    gad_list[0].bytes_returned	= &return_bytes;
    gad_list[1].var		= END_PARAM;

    status =
    dp$inq_set_gragad(	msg		= &msg,
			inq0_set1	= 1,
			which_error	= &error,
                        var_list	= gad_list,
			gragad_objid	= grids[i].objid,
			osnum		= grids[i].osnum );
    if( !(status&1)) continue;
  }

wrapup:
  di$free( count = count, lines = lines ) ;
  if( grids ) free( grids );
  *sts = MSSUCC;
  return( OM_S_SUCCESS );

}


/**************************************************************/
/* MESSAGE reset_grid_flags( long * sts )
/**************************************************************/
method reset_grid_flags ( long * sts )
{
/*
 * This method reset the grid flags GRID_ON and GRID_LOCK to their initial
 * values, before this command object was called.
 */
int	status = OM_S_SUCCESS;
IGRint	i, size, flags[2], flag;
IGRlong	msg, return_bytes, error;
struct	var_list gad_list[2];

  size = om$dimension_of( varray = me->vw_grid );

  for( i=0; i<size; i++ ){

    gad_list[0].var		= GRAGAD_FLAGS;
    gad_list[0].var_ptr		= (char *)&flag;
    gad_list[0].num_bytes	= sizeof(IGRint);
    gad_list[0].bytes_returned	= &return_bytes;

    gad_list[1].var	 	= END_PARAM;
  
    status = dp$inq_set_gragad( msg		= &msg,
				which_error	= &error,
				var_list	= gad_list,
				gragad_objid	= me->vw_grid[i].grid.objid,
				osnum		= me->vw_grid[i].grid.osnum );
    if(!(status&1)){
      printf(" fct dp$inq_set_gragad fails \n");
      continue;
    }
    
    if( me->vw_grid[i].flags & GRID_ON )
	flag |= GRID_ON;
    else
	flag &= ~GRID_ON;
    
    if( me->vw_grid[i].flags & GRID_LOCK )
	flag |= GRID_LOCK;
    else
	flag &= ~GRID_LOCK;

    flags[0] = 0xffffffff;
    flags[1] = flag;

    gad_list[0].var		= GRAGAD_FLAGS;
    gad_list[0].var_ptr		= (char *)flags;
    gad_list[0].num_bytes	= sizeof(IGRint) * 2;
    gad_list[0].bytes_returned	= &return_bytes;

    gad_list[1].var		= END_PARAM;

    status =
    dp$inq_set_gragad(	msg		= &msg,
			inq0_set1	= 1,
			which_error	= &error,
                        var_list	= gad_list,
			gragad_objid	= me->vw_grid[i].grid.objid,
			osnum		= me->vw_grid[i].grid.osnum );
    if(!(status&1)){
      printf("Error in inq_set in ...\n");
      continue;
    }
  }

  status = om$vla_set_dimension( varray = me->vw_grid, size = 0 );

  *sts = MSSUCC;
  return( OM_S_SUCCESS );
}

end implementation VDCmdDetail;
