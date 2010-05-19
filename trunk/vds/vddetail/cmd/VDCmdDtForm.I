/* $Id: VDCmdDtForm.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtForm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtForm.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  2000/03/07  16:06:30  pinnacle
# TR179901164 b ylong
#
# Revision 1.3  2000/03/01  14:36:44  pinnacle
# ylong
#
# Revision 1.2  1999/10/29  20:20:48  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.11  1996/04/12  09:51:00  pinnacle
# Replaced: vddetail/cmd/VDCmdDtForm.I for:  by rgade for vds.240
#
# Revision 1.10  1996/03/18  11:02:44  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
#
# Revision 1.9  1996/01/04  06:36:42  pinnacle
# Replaced: vddetail/cmd/VDCmdDtForm.I for:  by rgade for vds.240
#
# Revision 1.8  1995/11/29  13:55:36  pinnacle
# Replaced: ./vddetail/cmd/VDCmdDtForm.I for:  by ksundar for vds.240
#
# Revision 1.7  1995/11/22  23:50:24  pinnacle
# Replaced: ./vddetail/cmd/VDCmdDtForm.I for:  by azuurhou for vds.240
#
# Revision 1.6  1995/08/28  21:43:00  pinnacle
# Replaced: ./vddetail/cmd/VDCmdDtForm.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/03/22  14:52:46  pinnacle
# Replaced: vddetail/cmd/VDCmdDtForm.I by azuurhou r#
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
 *	10/27/99	ylong		added selecting VDatBase obj
 *	03/01/00	ylong		TR179901113
 *	03/07/00	ylong		TR179901164
 * -------------------------------------------------------------------*/

/*
        File    VDSdet_form.I
        Auteur  Ad Zuurhout
        Date    01-Januari-1992

        Description:
		Method for the form interface with the user.

		- VDfill_in_form.
		- get_reference_info
		- get_ref_component_id
		- get_component_id
		- get_component_name

        History:
                Creation Date 01-01-92
*/

class implementation VDCmdDetail;

#include <stdio.h>
%safe
#include <math.h>
%endsafe

#include "bserr.h"
#include "FI.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "AS_debug.h"
#include "igrtypedef.h"
#include "dp.h"
#include "grmacros.h"
#include "asbox.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "bstypes.h"
#include "bsdotp.h"
#include "bslenvec.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"

#include "VDmsg.h"
#include "VDdetail.h"
#include "vdrefmacros.h"
/* include/prototypes */
/**
#include "VDpr_detail.h"
#include "VDpr_dtlref.h"
**/
#include "VDtypedef.h"

#include "v_dbgmacros.h"
#include "VDobj.h"

#define AS_DEBUG 1

from	GRgraphics	import	GRgetrang;
from	IGEgragad	import	DPinquire;
from 	NDmacro		import  ACreturn_foot;
from	ACcpx		import	find_macro;
from	ACcpx_defn	import	ACgive_name;
from	GRvg		import	GRdetplane; 

extern			DPdisbybuf();
extern			ASmake_source_from_env(), ASmake_source();
extern			NDget_graph(), NDget_list();
extern	IGRint		VDatGetDrwViewPlane();


/* ********************************************************** */
method VDfill_in_form( long * sts )
/* ********************************************************** */
/*.fill_in_form*/
{
char		*fm_ptr;
IGRint		i, j, count;
IGRlong		msg, status;
IGRdouble	cht;
IGRboolean	resp, found;
IGRdouble	ext6[6], ext3[3], ext2[2];
GRspacenum	*locRefOsList = NULL;
char		filename[15];


  *sts = MSSUCC;
  fm_ptr = me->status_display_form_ptr;

  /* 
   * Show the existing gadget values for the command
   * Create Drawing View From Plane 
   */

  if( me->mytype == VD_drawview ){

    /* set scale value */
    VDdet_set_ALPHA( fm_ptr,VD_DET_SCALE,me->fd_new.text_scale );
    VDdet_set_ALPHA( fm_ptr,VD_DET_LAYERS,me->fd_new.layer_str );

    /* set origin values */
    if( me->fd_new.vol_toggle & VD_DET_USER_FLAG ||
        me->fd_new.vol_toggle & VD_DET_OBJ_RNG   ||
        me->fd_new.vol_toggle & VD_DET_ADD_RNG   ||
        me->fd_new.vol_toggle & VD_DET_PTS_RNG     )
    {
      for(i=0;i<3;i++)
        VDdet_conv_int_ext( me->fd_new.origin[i], &(ext3[i]), me->VDcur_os );
      VDdet_set_VALUES3(fm_ptr, VD_DET_ORIGIN, ext3 );
      VDdet_set_MODE_ON(fm_ptr, VD_DET_ORIGIN, 3);
    }
    else{
	if( me->fd_new.vol_toggle & VD_DET_DEP_EXT ){
	  /* calculate dependency extents */
	  VDget_dep_extents( sts, &me->VDdet_obj_env.obj_id,
				NULL, me->fd_new.dep_volume );
	  for(i=0;i<3;i++)
	    me->fd_new.origin[i] =
		(me->fd_new.dep_volume[3+i] - me->fd_new.dep_volume[i] ) * 0.5;
	}
	else{
	  VDdet_vec_COPY(me->fd_old.origin, me->fd_new.origin );
	}

        for(i=0;i<3;i++)
	  VDdet_conv_int_ext( me->fd_new.origin[i], &(ext3[i]), me->VDcur_os );
	VDdet_set_VALUES3(fm_ptr, VD_DET_ORIGIN, ext3 );
	VDdet_set_MODE_OFF(fm_ptr, VD_DET_ORIGIN, 3 );
    }

    /*
     * add the gadget VD_DET_REFERENCE in case more reference files are
     * directly or indirectly connected to current object space.
     */

/*
/*	Temporary set as comment.
/*	=========================
/*
/*    if( me->VDdet_space_cnt > 1 ){
/*
/*      FIfld_set_list_num_rows( fm_ptr, VD_DET_REFERENCE, 0, 0 );
/*      FIfld_set_text( fm_ptr, VD_DET_REFERENCE, 0, 0, "", FALSE);
/*
/*      for( i=0; i<me->VDdet_space_cnt; i++ ){
/*	FIfld_set_list_default_text( fm_ptr, VD_DET_REFERENCE, i, 0, 
/*					me->VDdet_space[i].ref_name, FALSE);
/*      }
/*      FIg_display( fm_ptr, VD_DET_REFERENCE );
/*      FIg_display( fm_ptr, VD_DET_REF_NAME );
/*    }
/*    else{
/*      FIg_erase( fm_ptr, VD_DET_REFERENCE );
/*      FIg_erase( fm_ptr, VD_DET_REF_NAME );
/*    }
/*
/*    FIg_erase( fm_ptr, VD_DET_REFERENCE );
/*    FIg_erase( fm_ptr, VD_DET_REF_NAME );
/**** */
    status = 	vd$get_ref_os_list (	msg   =  &msg,
					main_os = &me->VDcur_os,
					num_ref_os = &me->nbRefOs,
					ref_os_list = &locRefOsList );

    om$vla_set_dimension ( varray = me->refOsList,
			   size   = me->nbRefOs    );

    count = 0;
    for(i=0; i<me->nbRefOs; i++ )
    {
	found = FALSE;
	for(j=0; j<count; j++)
	  if ( locRefOsList[i] == me->refOsList[j] )
	  {
	    found = TRUE;
	    break;
	  }

	if ( !found )
	{
	  me->refOsList[count] = locRefOsList[i];
	  count++;
	}
    }
    me->nbRefOs = count;

    FIfld_set_list_num_rows( fm_ptr, VD_DET_REF_FLD, me->nbRefOs+1, 0 );
/*
	FIfld_set_text( fm_ptr, VD_DET_REFERENCE, 0, 0, "", FALSE);
*/

    for ( i=0; i<me->nbRefOs; i++)
    {
	VDget_filename_from_os ( me->refOsList[i], filename );
	VDfld_set_list_text ( fm_ptr, VD_DET_REF_FLD, i, 0, filename, 0);
	if ( i == 0 )
	{
	  FIg_set_text ( fm_ptr, VD_DET_REF_FLD, filename );
	  me->VDref_os = me->refOsList[i];
	}
    }

    VDget_filename_from_os ( me->VDcur_os, filename );
    VDfld_set_list_text ( fm_ptr, VD_DET_REF_FLD, me->nbRefOs, 0, filename, 0);
    if ( !me->nbRefOs )
    {
	 FIg_set_text ( fm_ptr, VD_DET_REF_FLD, filename );
	 me->VDref_os = me->VDcur_os;
    }

  }
  else{
    /* setting the drawing name for the window */
	resp = 0;
    resp = VDdet_gen_window_name( &msg, me->VDcur_os, me->VDdet_win_name );
    if( ! resp ) me->VDdet_win_name[0] = '\0';
    FIg_set_text( fm_ptr, VD_DET_WIN_NAME_DESC, me->VDdet_win_name );
  }
	
  /*
   * display common information for both the command:
   *	- Create Drawing View From Plane
   *	- Create Window From Plane 
   */

  if( me->fd_new.offset_toggle ){
   
    /* get the intern cht value */
    {
      IGRint nret, sizbuf = sizeof( IGRdouble );
      gr$get_chord_height_tolerance(msg    = &msg,
				    sizbuf = &sizbuf,
				    buffer = &cht,
				    nret   = &nret );
    }

    cht *= 2;
    if( fabs( me->fd_new.offset_value ) < cht ) me->fd_new.offset_value = cht;

    /* convert to display the form cht value */
    VDdet_conv_int_ext( &me->fd_new.offset_value, &cht, me->VDcur_os );
    FIg_set_value( fm_ptr, VD_DET_OFFSET_VALUE, cht ); 
  }
  FIg_set_state( fm_ptr, VD_DET_OFFSET_TOGGLE, me->fd_new.offset_toggle ); 

  if( me->fd_new.toggle & VD_DET_ZDEPTH_FLAG ){
	VDdet_set_STATE_ON(fm_ptr, VD_DET_Z_DEPTH_TOGGLE );
	for(i=0;i<2;i++)
	  VDdet_conv_int_ext( me->fd_new.usr_z_depth[i],
				&(ext2[i]), me->VDcur_os );
	VDdet_set_VALUES2(fm_ptr, VD_DET_Z_DEPTH, ext2 );
	VDdet_set_MODE_ON(fm_ptr, VD_DET_Z_DEPTH, 2);
  }
  else{
	VDdet_set_STATE_OFF(fm_ptr, VD_DET_Z_DEPTH_TOGGLE );
	for(i=0;i<2;i++)
	  VDdet_conv_int_ext( me->fd_new.z_depth[i], &(ext2[i]), me->VDcur_os );
	VDdet_set_VALUES2(fm_ptr, VD_DET_Z_DEPTH, ext2 );
	VDdet_set_MODE_OFF(fm_ptr, VD_DET_Z_DEPTH, 2 );
  }

  /* view orientation values */
  if( me->fd_new.toggle & VD_DET_AXIS_FLAG ){

	SMVA_display ( fm_ptr, 3, VD_DET_X_AXIS, VD_DET_Y_AXIS, VD_DET_Z_AXIS );
	SMVA_erase   ( fm_ptr, 4, VD_DET_VIEW_TXT, VD_DET_VIEW_FLD,
		       VD_DET_ROT_TXT, VD_DET_ROT_FLD );

	/*| x-axis values user defined (+ ViewOrient) */
	if( me->fd_new.orient_name[0] == '\0' )
	  VDdet_set_TEXT( fm_ptr, VD_DET_AXIS_TOGGLE, 2 );
	else
	  VDdet_set_ALPHA( fm_ptr, VD_DET_AXIS_TOGGLE, me->fd_new.orient_name );
  
	VDdet_vec_LIMITS( me->fd_new.x_vec );
	VDdet_vec_LIMITS( me->fd_new.y_vec );
	VDdet_vec_LIMITS( me->fd_new.z_vec );

	VDdet_set_VALUES3(fm_ptr, VD_DET_X_AXIS, me->fd_new.x_vec );
	VDdet_set_VALUES3(fm_ptr, VD_DET_Y_AXIS, me->fd_new.y_vec );
	VDdet_set_VALUES3(fm_ptr, VD_DET_Z_AXIS, me->fd_new.z_vec );

	VDdet_set_MODE_ON(fm_ptr, VD_DET_X_AXIS, 3);
	VDdet_set_MODE_ON(fm_ptr, VD_DET_Y_AXIS, 3);
  }
  else if( me->fd_new.toggle & VD_DET_ALT_FLAG )
  {
	SMVA_erase   ( fm_ptr, 3, VD_DET_X_AXIS, VD_DET_Y_AXIS, VD_DET_Z_AXIS );
	SMVA_display ( fm_ptr, 4, VD_DET_VIEW_TXT, VD_DET_VIEW_FLD,
		       VD_DET_ROT_TXT, VD_DET_ROT_FLD );

	VDdet_set_TEXT( fm_ptr, VD_DET_AXIS_TOGGLE, 2 );
  } else {

	SMVA_display ( fm_ptr, 3, VD_DET_X_AXIS, VD_DET_Y_AXIS, VD_DET_Z_AXIS );
	SMVA_erase   ( fm_ptr, 4, VD_DET_VIEW_TXT, VD_DET_VIEW_FLD,
		       VD_DET_ROT_TXT, VD_DET_ROT_FLD );

	/*  x-axis plane vector */
	VDdet_set_TEXT( fm_ptr, VD_DET_AXIS_TOGGLE, 1 );

	VDdet_vec_COPY( me->fd_old.x_vec, me->fd_new.x_vec );
	VDdet_vec_COPY( me->fd_old.y_vec, me->fd_new.y_vec );
	VDdet_vec_COPY( me->fd_old.z_vec, me->fd_new.z_vec );

	VDdet_vec_LIMITS( me->fd_new.x_vec );
	VDdet_vec_LIMITS( me->fd_new.y_vec );
	VDdet_vec_LIMITS( me->fd_new.z_vec );

	VDdet_set_VALUES3(fm_ptr, VD_DET_X_AXIS, me->fd_new.x_vec );
	VDdet_set_VALUES3(fm_ptr, VD_DET_Y_AXIS, me->fd_new.y_vec );
	VDdet_set_VALUES3(fm_ptr, VD_DET_Z_AXIS, me->fd_new.z_vec );

	VDdet_set_MODE_OFF(fm_ptr, VD_DET_X_AXIS, 3);
	VDdet_set_MODE_OFF(fm_ptr, VD_DET_Y_AXIS, 3);
  }

  /* view volume values */
  if( me->fd_new.vol_toggle & VD_DET_USER_FLAG ){

	/*| view volume user defined ( + ViewVolume ) */
	if( me->fd_new.volume_name[0] == '\0' )
	  VDdet_set_TEXT(fm_ptr, VD_DET_VOLUME_TOGGLE, 6 );
	else
	  VDdet_set_ALPHA( fm_ptr, VD_DET_VOLUME_TOGGLE, me->fd_new.volume_name );

        for(i=0;i<6;i++)
	  VDdet_conv_int_ext(me->fd_new.vw_volume[i],&(ext6[i]), me->VDcur_os );
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);
  }
  else if( me->fd_new.vol_toggle & VD_DET_OBJ_RNG )
  {
	VDdet_set_TEXT(fm_ptr, VD_DET_VOLUME_TOGGLE, 3 );

        for(i=0;i<6;i++)
	  VDdet_conv_int_ext(me->fd_new.vw_volume[i],&(ext6[i]), me->VDcur_os );
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);
  }
  else if( me->fd_new.vol_toggle & VD_DET_ADD_RNG )
  {
	VDdet_set_TEXT(fm_ptr, VD_DET_VOLUME_TOGGLE, 4 );

        for(i=0;i<6;i++)
	  VDdet_conv_int_ext(me->fd_new.vw_volume[i],&(ext6[i]), me->VDcur_os );
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);
  }
  else if( me->fd_new.vol_toggle & VD_DET_PTS_RNG )
  {
	VDdet_set_TEXT(fm_ptr, VD_DET_VOLUME_TOGGLE, 5 );

        for(i=0;i<6;i++)
	  VDdet_conv_int_ext(me->fd_new.vw_volume[i],&(ext6[i]), me->VDcur_os );
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
	VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);
  }
  else{
    if( me->fd_new.vol_toggle & VD_DET_DEP_EXT ){

	/*|  view volume dependency extents */
	VDdet_set_TEXT(fm_ptr, VD_DET_VOLUME_TOGGLE, 2 );

        for(i=0;i<6;i++)
	  VDdet_conv_int_ext(me->fd_new.dep_volume[i], &(ext6[i]),me->VDcur_os);
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

	VDdet_set_MODE_OFF(fm_ptr, VD_DET_VOL_MIN, 3 );
	VDdet_set_MODE_OFF(fm_ptr, VD_DET_VOL_MAX, 3 );
    }
    else{
	/*| view volume plane extents */
	me->fd_new.vol_toggle = VD_DET_EXTENDED;

	VDdet_set_TEXT(fm_ptr, VD_DET_VOLUME_TOGGLE, 1 );

	VDdet_vec_COPY( &(me->fd_old.vw_volume[0]), &(me->fd_new.vw_volume[0]) );
	VDdet_vec_COPY( &(me->fd_old.vw_volume[3]), &(me->fd_new.vw_volume[3]) );

        for(i=0;i<6;i++)
	  VDdet_conv_int_ext(me->fd_new.vw_volume[i], &(ext6[i]), me->VDcur_os);
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));
	VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

	VDdet_set_MODE_OFF(fm_ptr, VD_DET_VOL_MIN, 3 );
	VDdet_set_MODE_OFF(fm_ptr, VD_DET_VOL_MAX, 3 );
    }
  }

  /*
   * add the user View Orientation and View Volume values in the list
   */
  i = 0;
  VD_ViewOrientationFile( VD_DET_NAME_DISPLAY, fm_ptr, &i, NULL, NULL, NULL );
  VD_ViewVolumeFile( VD_DET_NAME_DISPLAY, fm_ptr, &i, NULL, NULL, NULL, NULL);

  *sts = MSSUCC;
  goto wrapup;		/* to avoid warning during compilation */

wrapup:
  if ( locRefOsList )  free ( locRefOsList );
  return(OM_S_SUCCESS);
}

/* ********************************************************** */
method get_reference_info ( long * sts )
/* ********************************************************** */
{
int	status = OM_S_SUCCESS;
/*
 * This method looks if any reference files are connected with
 * the current module environment.
 * The result is written in the instance:
 *		VDdet_refcount,
 *		VDdet_reftab
 * In case no reference file is connected an message is returned
 * to attach a reference file.
 */

  me->VDdet_refer_cnt = 0;
  me->VDdet_space_cnt = 0;
  if( me->VDdet_refer ) om$dealloc( ptr = me->VDdet_refer );
  if( me->VDdet_space ) om$dealloc( ptr = me->VDdet_space );

  /*
   * Look of any reference file are precent by direct or idirect
   * attachment with the current file.
   */
  status = VDdet_get_ref_info(	&me->ModuleInfo,
				&me->VDdet_refer_cnt,
				&me->VDdet_refer );
  if(!(status&1)){
    printf(" get_reference_info : fct VDdet_get_ref_info fails \n");
    goto wrapup;
  }

  status = VDdet_get_refspace(	&me->VDdet_space_cnt,
				&me->VDdet_space );
  if(!(status&1)){
    printf(" get_reference_info : fct VDdet_get_ref_info fails \n");
    goto wrapup;
  }

  if( me->VDdet_refer_cnt == 0 ){
    ex$message( msgnumb = VD_S_AttRfFl );
    *sts = MSFAIL;
    return(OM_S_SUCCESS);
  }

  /*^
  {
    int ii;
    for(ii=0; ii<me->VDdet_refer_cnt; ii++ ){
      printf(" Ref_file [ %d ] : %s\n", me->VDdet_refer[ii].osnum,
					me->VDdet_refer[ii].ref_name );
    }

    for(ii=0; ii<me->VDdet_space_cnt; ii++ ){
      printf(" Ref_space [ %d ] : %s\n", me->VDdet_space[ii].osnum,
					me->VDdet_space[ii].ref_name );
    }
  }
  */

wrapup:
  *sts = MSSUCC;
  return( OM_S_SUCCESS );
}

/* ********************************************************** */
method get_ref_component_id ( long * sts )
/* ********************************************************** */
{
int	status = OM_S_SUCCESS;

/*
 * This method test the input from "me->event1.located_object[0]"
 * and get the located_obj and module_info for later use.
 * The window gragad environment will be equal to the reference 
 * environment. In case the object is not selected from a reference 
 * environment the object is not accepted and an error message will
 * be returned.
 */
IGRint			i;
IGRlong			loc_msg;
IGRchar			*macro_name;
OMuword			sender_class;
IGRboolean		ref_object;
struct	GRid		macro_id;
struct	VDdet_reffile	*curref;
GRspacenum              ref_os;
TGRobj_env		planeOE, objOE ;
TGRplane		plane ;
IGRpoint		point ;
IGRvector		normal ;
IGRint			side ;		// 0: bottom, 1: top (default)

SetProc(method get_ref_component_id); Begin

  *sts		= MSSUCC;
  ref_object	= FALSE;
  ref_os	= 0;
  side		= 1 ;
  objOE.obj_id.objid	= NULL_OBJID ;
  planeOE.obj_id.objid	= NULL_OBJID ;

  me->VDdet_obj_env.obj_id  = me->event1.located_object[0].located_obj;
  me->VDdet_obj_env.mod_env = me->event1.located_object[0].module_info;
 
  status =
  om$get_classid(	osnum     = me->VDdet_obj_env.obj_id.osnum,
			objid     = me->VDdet_obj_env.obj_id.objid,
			p_classid = &sender_class );

  if( om$is_ancestry_valid(
                        subclassid      = sender_class,
                        superclassname  = "ACncpx") == OM_S_SUCCESS ){

    __DBGpr_com("superclassname is ACncpx");
    status = 
    om$send(msg = message ACcpx.find_macro( &macro_id ),
	    targetid = me->VDdet_obj_env.obj_id.objid,
	    targetos = me->VDdet_obj_env.obj_id.osnum );
    if(status&1){
      __DBGpr_obj("found macro ID", macro_id);
      status =
      om$send(msg = message ACcpx_defn.ACgive_name( &macro_name ),
	      targetid = macro_id.objid,
	      targetos = macro_id.osnum );
      if( status&1 && strcmp( macro_name, "drawing_frame") == 0 ){
        __DBGpr_com("macro name is <drawing_frame>");
	status =
	om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,
				"",
				&me->VDdet_obj_env.obj_id,
				&me->VDdet_obj_env.mod_env.md_env.matrix_type,
				me->VDdet_obj_env.mod_env.md_env.matrix ),
		senderid = me->VDdet_obj_env.obj_id.objid,
		targetos =  me->VDdet_obj_env.obj_id.osnum,
		p_chanselect = &ND_father,
		from = 0, to = 0 );
	if(status&loc_msg&1){
	  /* found a plane object */
	  ref_object = TRUE;
	}
	__DBGpr_obj("ACncpx is ancsestry,me->VDdet_obj_env.obj_id",
			me->VDdet_obj_env.obj_id);
      }
      // added for VSplate obj TR179901113, by ylong
      else if( om$is_ancestry_valid(
			subclassid      = sender_class,
			superclassname  = "VSplate") == OM_S_SUCCESS )
      {
        __DBGpr_com("superclassname is VSplate");
        /*
         * Check if plate is planar
         */
        objOE = me->VDdet_obj_env ;
        plane.point = point; plane.normal = normal ;
        status = om$send (      msg     = message GRvg.GRdetplane (
                                        &loc_msg,
                                        &objOE.mod_env.md_env.matrix_type,
                                        objOE.mod_env.md_env.matrix,
                                        &plane),
                        senderid = NULL_OBJID,
                        targetid = objOE.obj_id.objid,
                        targetos = objOE.obj_id.osnum ) ;

        if( status&loc_msg&1 ) {
           vdobj$GetFoot (      objOE    = &objOE,
                                footName = "plate:base",
                                footOE   = &planeOE );

           __DBGpr_obj("planeID", planeOE.obj_id);
           if( planeOE.obj_id.objid != NULL_OBJID ) {
                /*
                 * Check the side of plane with max stiffeners, for TR179901164
                 */
                status = VDgetFavoriteSide( &objOE, &side );
                if( (status&1) && side == 0 ) {
                        me->VDdet_rev_normal = 1 ; /* 0 */
                }
                __DBGpr_int("side", side);

                me->VDdet_obj_env.obj_id = planeOE.obj_id ;
                me->VDdet_obj_env.mod_env = planeOE.mod_env ;
                status = om$get_classid(osnum  = me->VDdet_obj_env.obj_id.osnum,
                                        objid = me->VDdet_obj_env.obj_id.objid,
                                        p_classid = &sender_class );
                if( !(status & 1) ) {
                        __DBGpr_com("om$get_classid failed");
                }
                else {
                        __DBGpr_int("sender_class", sender_class);
                }
           }
        }
      }
    }
  }
  // added for VDatBase obj, by ylong
  else if( om$is_ancestry_valid( 
				subclassid      = sender_class,
				superclassname  = "VDatBase") == OM_S_SUCCESS )
  {
        __DBGpr_com("superclassname is VDatBase");
        if( VDatGetDrwViewPlane(&me->VDdet_obj_env.obj_id, &objOE, &planeOE)) {
                __DBGpr_obj("plateID", objOE.obj_id);
                __DBGpr_obj("planeID", planeOE.obj_id);
                me->VDdet_obj_env.obj_id = planeOE.obj_id ;
                me->VDdet_obj_env.mod_env = planeOE.mod_env ;

                /*
                 * Check the side of plane with max stiffeners, for TR179901164
                 */
                status = VDgetFavoriteSide( &objOE, &side );
                if( (status&1) && side == 0 ) {
                        me->VDdet_rev_normal = 1 ; /* 0 */
                }
                __DBGpr_int("side", side);

                status = om$get_classid(osnum  = me->VDdet_obj_env.obj_id.osnum,
                                        objid = me->VDdet_obj_env.obj_id.objid,
                                        p_classid = &sender_class );
                if( !(status & 1) ) {
                        __DBGpr_com("om$get_classid failed");
                }
                else {
                        __DBGpr_int("sender_class", sender_class);
                }
        }
        else {
                __DBGpr_com("VDatGetDrwViewPlane failed");
        }

  }



  if( ref_object == FALSE ){
    if( om$is_ancestry_valid(subclassid      = sender_class,
			superclassname  = "EMSplane" ) == OM_S_SUCCESS ){
	/* select a reference plane object */
	ref_object = TRUE;
        __DBGpr_com("superclassname is EMSplane --");
    }
    // added by ylong for checking EMSgenbs obj
    else if( om$is_ancestry_valid(subclassid      = sender_class,
                        superclassname  = "EMSgenbs" ) == OM_S_SUCCESS ){
        /* select a reference plane object */
        ref_object = TRUE;
        __DBGpr_com("superclassname is EMSgenbs --");
    }

    /*
     * check for volume.
     */
    if( om$is_ancestry_valid(subclassid      = sender_class,
			superclassname  = "EMSsolid" ) == OM_S_SUCCESS ){
	/* select a reference plane object */
	ref_object = TRUE;
        __DBGpr_com("superclassname is EMSsolid --");
    }
  }

  /*
   * test if object directly or indirectly attached to current object
   * space : Reference object spaces are stored in:
   * 		- VDdet_space
   *		- VDdet_space_cnt
   */
  if( ref_object ){
    ref_object = FALSE;
    /*  test if object is from an reference object space */
    for( i=0, curref=me->VDdet_space; i<me->VDdet_space_cnt; i++, curref++ ){
      if( me->VDdet_obj_env.obj_id.osnum == curref->osnum ){
	strcpy( me->VDdet_ref_name, curref->ref_name );
	ref_os = me->VDdet_obj_env.obj_id.osnum;
	ref_object = TRUE;
	break;
      }
    }
  }

  /* find object name later */
  me->VDdet_obj_name[0] = '\0';
  me->VDdet_win_name[0] = '\0';

/*
  if( ! ref_object ){
    me->VDdet_obj_env.obj_id.objid = NULL_OBJID; 
    ex$message( msgnumb = VD_S_SlNtFrRfFl);
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }
*/
   /* 
    * Check if the setup of reference files is OK or not.  Refer to 
    * $VDS/notes/drw_view.doc for details
    */

    if(me->VDdet_refer_cnt == 1)
        i = 0;
    else
    {
        for(i = 0 ; i < me->VDdet_refer_cnt ; i++ )
            if( ref_os == me->VDdet_refer[i].osnum )
                break;
/*
        if(i >= me->VDdet_refer_cnt)
        {
            ex$message( msgnumb = VD_S_InvSpSeNt );
            *sts = MSFAIL;
            return( OM_S_SUCCESS );
        }
*/
    }

    /*
     * me->VDref_os is the reference object space, in which we select elements
     * to create the view.
     */
    if ( i < me->VDdet_refer_cnt )
    {
	me->VDref_os = me->VDdet_refer[i].osnum;
	strcpy( me->model, me->VDdet_refer[i].ref_name );
    }
    else if ( me->VDdet_refer_cnt )
    {
	me->VDref_os = me->VDdet_refer[0].osnum;
	strcpy( me->model, me->VDdet_refer[0].ref_name );
    }
    else
    {
	VDget_filename_from_os ( me->VDcur_os, me->model );
	me->VDref_os = me->VDcur_os;
    }


  /* set all levels active */
  for( i=0; i<32; i++) me->VDdet_levels[i] = 0xffffffff;
  
  *sts = MSSUCC;
End
  return( OM_S_SUCCESS );
}

/* ********************************************************** */
method get_component_id ( long * sts )
/* ********************************************************** */
{
  int		  status = OM_S_SUCCESS;

/*
 * This method test the input from "me->event1.located_object[0]"
 *   and get the located_obj and module_info for later use.
 * The object will be considerd as an object from the active working
 * environment. 
 * Objects from reference object spaces are no longer refused; this to create
 * the possibility to create window from plane by selecting frame planes.
 */
IGRint			i;
struct	var_list	w_info[2];
IGRlong			rc, error, bytes_returned;
IGRboolean		ref_object;

  *sts = MSSUCC;
  ref_object = FALSE;

  me->VDdet_obj_env.obj_id  = me->event1.located_object[0].located_obj;
  me->VDdet_obj_env.mod_env = me->event1.located_object[0].module_info;
  me->VDdet_rev_normal = 0 ;	// added for TR179901164
 
  /* find object name later */
  me->VDdet_obj_name[0] = '\0';
  me->VDdet_win_name[0] = '\0';


#ifdef CUR_SPACE

  ------------------------------------------------------------------------
  The current object space check is canceled to create window from planes
  defined in reference object spaces.
  ------------------------------------------------------------------------

  /*
   * test is object is from current object space
   */
  if( me->VDdet_obj_env.obj_id.osnum != me->VDcur_os ){
    me->VDdet_obj_env.obj_id.objid = NULL_OBJID;
    me->VDdet_obj_name[0] = '\0';
    ex$message( msgnumb = VD_S_ObjRfFlNAc );
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }

#endif

  /* set all levels active */
  for( i=0; i<32; i++) me->VDdet_levels[i] = 0xffffffff;

  /* get the active levels in window */
  if( me->event1.event.button.objid != NULL_OBJID ){

    /*  get the window levels */
    w_info[0].var		= LEVELS;
    w_info[0].var_ptr		= (IGRchar *)me->VDdet_levels;
    w_info[0].num_bytes		= 32 * sizeof ( IGRint);
    w_info[0].bytes_returned	= &bytes_returned;

    w_info[1].var		= END_PARAM; 

    status =
    om$send(msg = message IGEgragad.DPinquire( &rc, &error,w_info),
	    targetid = me->event1.event.button.objid,
	    targetos = me->event1.event.button.osnum);
    as$status(action = RET_STATUS);
  }

  /*
   * set the window name for the SMframe object
   */
  if( me->mytype == VD_viewplane ){
    status = VDInfPlGetName(	&me->VDdet_obj_env.obj_id,
				me->VDdet_win_name );
    status = OM_S_SUCCESS ;
  }

  *sts = MSSUCC;

return( OM_S_SUCCESS );

}

/* ********************************************************** */
method get_component_name ( long * sts )
/* ********************************************************** */
{
int	status = OM_S_SUCCESS;
/*
 * This method test the input from "me->event1.event.keyin"
 * and find the cooresponding object identifier.
 * The method handles as get_ref_component_id
 * 
 */
IGRchar		path[256];
IGRint		i;
struct VDdet_reffile	*curref;
IGRboolean		ref_object;
GRspacenum              ref_os;

  *sts = MSSUCC;
  ref_object = FALSE;
  ref_os = 0;

  strcpy( me->VDdet_obj_name, me->event1.event.keyin );

  /* look for object in reference object space */
  me->VDdet_obj_env.obj_id.objid = NULL_OBJID;
  me->VDdet_rev_normal = 0 ;	// added for 179901164

  /* get working directory */
  path[0] = '\0';
  status = di$pwd( dirname = path );
  if( status != DIR_S_SUCCESS){
      printf(" ERROR: cannot get active working directory\n");
      me->state = _terminate;
      return( OM_I_STOP_SENDING );
  }

  status = 
  di$translate(	objname = me->VDdet_obj_name,
                path    = path,
                p_objid = &(me->VDdet_obj_env.obj_id.objid),
                p_osnum = &(me->VDdet_obj_env.obj_id.osnum) );
  if( status != DIR_S_SUCCESS ){
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }

  if( me->mytype == VD_viewplane ){
 
#ifdef CUR_SPACE

   ------------------------------------------------------------------------
    The current object space check is canceled to create window from planes
    defined in reference object spaces.
    ------------------------------------------------------------------------ 
    /*
     * test is object is from current object space
     */

    if( me->VDdet_obj_env.obj_id.osnum != me->VDcur_os ){
      me->VDdet_obj_env.obj_id.objid = NULL_OBJID;
      me->VDdet_obj_name[0] = '\0';
      ex$message( msgnumb = VD_S_ObjRfFlNAc );
      *sts = MSFAIL;
      return( OM_S_SUCCESS );
    }

#endif

    /*
     * Find the window name for an SMframe object.
     */
    status = VDInfPlGetName(	&me->VDdet_obj_env.obj_id,
				me->VDdet_win_name );
    status = OM_S_SUCCESS ;
  }
  else{
    /*
     * test if object is from an reference object space
     */
    for( i=0, curref=me->VDdet_refer; i<me->VDdet_refer_cnt; i++, curref++ ){
      if( me->VDdet_obj_env.obj_id.osnum == curref->osnum ){
        strcpy( me->VDdet_ref_name, curref->ref_name );
        ref_os = me->VDdet_obj_env.obj_id.osnum;
        ref_object = TRUE;
        break;
      }
    }
/*
    if( ref_object != TRUE ){
      me->VDdet_obj_env.obj_id.objid = NULL_OBJID;
      me->VDdet_obj_name[0] = '\0';
      ex$message( msgnumb = VD_S_SlNtFrRfFl );
      *sts = MSFAIL;
      return( OM_S_SUCCESS );
    }
*/

   /* 
    * Check if the setup of reference files is OK or not.  Refer to 
    * $VDS/notes/drw_view.doc for details
    */

    if(me->VDdet_refer_cnt == 1)
        i = 0;
    else
    {
        for(i = 0 ; i < me->VDdet_refer_cnt ; i++ )
            if( ref_os == me->VDdet_refer[i].osnum )
                break;
/*
        if(i >= me->VDdet_refer_cnt)
        {
            ex$message( msgnumb = VD_S_InvSpSeNt );
            *sts = MSFAIL;
            return( OM_S_SUCCESS );
        }
*/
    }

    /*
     * me->VDref_os is the reference object space, in which we select elements
     * to create the view.
     */
    if ( i < me->VDdet_refer_cnt )
    {
	me->VDref_os = me->VDdet_refer[i].osnum;
	strcpy( me->model, me->VDdet_refer[i].ref_name );
    }
    else if ( me->VDdet_refer_cnt )
    {
	me->VDref_os = me->VDdet_refer[0].osnum;
	strcpy( me->model, me->VDdet_refer[0].ref_name );
    }
    else
    {
	VDget_filename_from_os ( me->VDcur_os, me->model );
	me->VDref_os = me->VDcur_os;
    }
  }

  /* set all levels active */
  for( i=0; i<32; i++) me->VDdet_levels[i] = 0xffffffff;

  *sts = MSSUCC;
  return( OM_S_SUCCESS );
}

/* ********************************************************** */

VDdet_get_VIEWCHAR( view, viewchar )
IGRchar		*view;
IGRchar		*viewchar ;
{
	*viewchar	= VD_NODIR ;

	if (      !strcmp (view, "X-POSITIVE") ) *viewchar = VD_XPOS;
	else if ( !strcmp (view, "X-NEGATIVE") ) *viewchar = VD_XNEG;
	else if ( !strcmp (view, "Y-POSITIVE") ) *viewchar = VD_YPOS;
	else if ( !strcmp (view, "Y-NEGATIVE") ) *viewchar = VD_YNEG;
	else if ( !strcmp (view, "Z-POSITIVE") ) *viewchar = VD_ZPOS;
	else if ( !strcmp (view, "Z-NEGATIVE") ) *viewchar = VD_ZNEG;
	else					 *viewchar = VD_NODIR;

	return TRUE ;
}

/* ********************************************************** */
/* display and structure functions			      */
/* ********************************************************** */

VDdet_get_ALPHA(form, label, str)
Form		form;
IGRint		label;
char		*str;
{
	IGRint	status;
	char	string[1024];

	status =
	FIg_get_text(form, label, string);
	if (status != FI_SUCCESS)
	{
		printf("FIg_get_text Fails\n");
		return(OM_E_ABORT);
	}

	strcpy( str, string );
	return(TRUE);
}

VDdet_set_ALPHA(form, label, str)
Form		form;
IGRint		label;
char		*str;
{
	IGRint status;

	status =
	FIg_set_text(form, label, str);
	if (status != FI_SUCCESS)
	{
		printf("FIg_set_text Fails\n");
		return(OM_E_ABORT);
	}
	return(TRUE);
}

VDdet_set_STATE_ON(form, label)
Form		form;
IGRint		label;
{
	IGRint status;

	status =
	FIg_set_value(form, label, 1.0 );
	if (status != FI_SUCCESS)
	{
		printf("FIg_set_state_on Fails\n");
		return(OM_E_ABORT);
	}
	return(TRUE);
}

VDdet_set_STATE_OFF(form, label)
Form		form;
IGRint		label;
{
	IGRint status;

	status =
	FIg_set_value( form, label, 0.0 );
	if (status != FI_SUCCESS)
	{
		printf("FIg_set_state_off Fails\n");
		return(OM_E_ABORT);
	}
	return(TRUE);
}

VDdet_get_STATE( form, label)
Form		form;
IGRint		label;
{
	IGRint status, state;

	status =
	FIg_get_state(form, label, &state);
	if (status != FI_SUCCESS)
	{
		printf("FIg_get_state Fails\n");
		return(OM_E_ABORT);
	}
	return(state);
}

VDdet_get_VALUES3( form, label, values)
Form		form;
IGRint		label;
IGRdouble	*values;
{
	IGRint i,status, flag, pos;

	for(i=0;i<3;i++){
	  status =
	  FIfld_get_value(form, label, i, 0, &(values[i]), &flag, &pos);
	  if (status != FI_SUCCESS)
	  {
		printf("FIfld_get_value Fails\n");
		return(OM_E_ABORT);
	  }
	}
	return(TRUE);
}


VDdet_get_VALUES2( form, label, values)
Form		form;
IGRint		label;
IGRdouble	*values;
{
	IGRint i,status, flag, pos;

	for(i=0;i<2;i++){
	  status =
	  FIfld_get_value(form, label, i, 0, &(values[i]), &flag, &pos);
	  if (status != FI_SUCCESS)
	  {
		printf("FIfld_get_value Fails\n");
		return(OM_E_ABORT);
	  }
	}
	return(TRUE);
}


VDdet_set_VALUES3( form, label, values)
Form		form;
IGRint		label;
IGRdouble	*values;
{
	IGRint	i,status;
	IGRint	flag = TRUE;
	
	for(i=0;i<3;i++){
          if( fabs( values[i] ) < VD_DET_EPSILON ) values[i] = 0.0;
	  status =
	  FIfld_set_value(form, label, i, 0, values[i], flag);
	  if (status != FI_SUCCESS)
	  {
		printf("FIfld_set_value Fails\n");
		return(OM_E_ABORT);
	  }
	}
	return(TRUE);
}


VDdet_set_VALUES2( form, label, values)
Form		form;
IGRint		label;
IGRdouble	*values;
{
	IGRint	i,status;
	IGRint	flag = TRUE;

	for(i=0;i<2;i++){
	  status =
	  FIfld_set_value(form, label, i, 0, values[i], flag);
	  if (status != FI_SUCCESS)
	  {
		printf("FIfld_set_value Fails\n");
		return(OM_E_ABORT);
	  }
	}
	return(TRUE);
}

VDdet_set_MODE_ON(form, label, col)
Form		form;
IGRint		label;
IGRint		col;
{
	IGRint	i,status;

	for(i=0;i<col;i++){
	    status =
	    FIfld_set_mode(form, label, i, FI_INSERT );
	    if (status != FI_SUCCESS)
	    {
		printf("FIfld_set_mode Fails\n");
		return(OM_E_ABORT);
	    }
	}

	status =
	FIg_display(form, label);
	if (status != FI_SUCCESS)
	{
		printf("FIg_display Fails\n");
		return(OM_E_ABORT);
	}
	return(TRUE);
}

VDdet_erase_LABEL(form, label)
Form form;
IGRint label;
{
        IGRint status;

        status =
        FIg_erase(form, label);
        if (status != FI_SUCCESS)
        {
                printf("FIg_erase Fails\n");
                return(OM_E_ABORT);
        }

        return(TRUE);
}


VDdet_set_MODE_OFF(form, label, col)
Form		form;
IGRint		label;
IGRint		col;
{
	IGRint	i,status;

	for(i=0;i<col;i++){
	  status =
	  FIfld_set_mode(form, label, i, FI_REVIEW);
	  if (status != FI_SUCCESS)
	  {
		printf("FIfld_set_mode Fails\n");
		return(OM_E_ABORT);
	  }
	}

	status =
	FIg_display(form, label);
	if (status != FI_SUCCESS)
	{
		printf("FIg_display Fails\n");
		return(OM_E_ABORT);
	}
	return(TRUE);
}

VDdet_set_TEXT(form, label, row)
Form		form;
IGRint		label;
IGRint		row;
{
	IGRint	status;
	IGRchar	string[80];

	string[0] = '\0';

	switch( label ){
	case VD_DET_AXIS_TOGGLE:

	  switch( row ){
	  case 1:  strcpy( string, "Plane Vector"); break;
	  case 2:  strcpy( string, "Alternative"); break;
	  case 3:  strcpy( string, "User Defined"); break;
	  default: strcpy( string, "User Defined"); break;
	  }
	  break;
	case VD_DET_VOLUME_TOGGLE:

	  switch( row ){
	  case 1: strcpy( string, "Plane Extents and Center"); break;
	  case 2: strcpy( string, "Dependency Extents"); break;
	  case 3: strcpy( string, "Range by Objects(Override existing range)");
		  break;
	  case 4: strcpy( string, "Range by Objects(Add to existing range)");
		  break;
	  case 5: strcpy( string, "User Defined"); break;
	  default: strcpy( string, "User Defined"); break;
	  }
	}

	status =
	FIg_set_text(form, label, string);
	if (status != FI_SUCCESS)
	{
		printf("FIg_set_text Fails\n");
		return(OM_E_ABORT);
	}
	return(TRUE);
}

VDdet_vec_COPY( v1, v2 )
IGRdouble *v1;
IGRdouble *v2;
{
	v2[0] = v1[0];
	v2[1] = v1[1];
	v2[2] = v1[2];
return( TRUE );
}

VDdet_vec_LIMITS( vec )
IGRdouble	*vec;
{
IGRint	i, one = -1;
IGRlong	rc;

	BSnorvec( &rc, vec );
	for(i=0;i<3;i++){
	  if( fabs(vec[i]) < VD_DET_EPSILON ){
		vec[i] = 0.0;
	  }
	  if( fabs(vec[i]) > (1.0 - VD_DET_EPSILON) ){
	    vec[i] = ( vec[i] > 0.0 ) ?	1.0 : -1.0;
	    one = i;
	  }
	}
	if( one != -1 ){
	  for(i=0;i<3;i++){ if( i != one ) vec[i] = 0.0; }
	}

return(TRUE);
}

VDdet_get_global_DATA( to, global )
struct	VDdet_formdata	*to;
struct	VDdet_formdata	global;
/*.get_global_DATA*/
{
IGRint	i;
IGRlong	rc;
IGRdouble	value;
IGRvector	x_vec, y_vec, z_vec, y_tmp;

  /*
   * The structure VDdet_formdata "to" contains the active values.
   * Modifications:
   * 	- The text_scale can be copied. 
   * 	- The layer_str can be copied. 
   *	- The z_depth depends on the flag. 
   *	- The origin depends on the flag and user defined names.
   *	- The plane depends on the flag and user defined names.
   *	- The x- and y-axis, these vectors has be to recalculated, in case
   *	- the plane has a different normal vector or an user defined name.
   */

  /*
   * copy global values of text_scale and layers
   */
  strcpy(to->text_scale, global.text_scale );
  strcpy(to->layer_str, global.layer_str );

  to->flag = FALSE;

  /* offset setting */
  to->offset_toggle = global.offset_toggle;
  to->offset_value = global.offset_value;

  /*
   * copy the z_depth values
   */
  if( global.toggle & VD_DET_ZDEPTH_FLAG ){
    to->toggle |= VD_DET_ZDEPTH_FLAG;
    to->usr_z_depth[0] = global.usr_z_depth[0];
    to->usr_z_depth[1] = global.usr_z_depth[1];
  }
  else{
    to->toggle &= ~VD_DET_ZDEPTH_FLAG; 
    to->usr_z_depth[0] = -100.0;
    to->usr_z_depth[1] =  100.0;
  }

  /*
   * copy the View Volume and the origin
   * -- if the structure instance is defined find the name in the
   * -- the file ViewVolume (available in current directory or ./config
   */
  if( global.vol_toggle & VD_DET_USER_FLAG ){

    /*
     * Find name in file ViewVolume
     */
    if( VD_ViewVolumeFile(VD_DET_NAME_SEARCH, NULL, NULL,
				global.volume_name,
				to->vw_volume,
				&(to->vw_volume[3]),
				to->origin ) ){
      strcpy( to->volume_name, global.volume_name );
    }
    else{
      to->volume_name[0] = '\0';
      VDdet_vec_COPY(   global.vw_volume,       to->vw_volume );
      VDdet_vec_COPY( &(global.vw_volume[3]), &(to->vw_volume[3]) );
      VDdet_vec_COPY(   global.origin,          to->origin );
    }
    to->vol_toggle = VD_DET_USER_FLAG;
  }
  else{
    /*| plane extents  */
    to->vol_toggle = global.vol_toggle;
  }


  if(!( global.toggle & VD_DET_AXIS_FLAG )){
    /*| no modif for vectors */
    to->toggle = global.toggle;
    to->volume_name[0] = '\0';
    return( TRUE );
  }

  /*
   * Look if orient_name is found in ViewOrient file
   */
  if( VD_ViewOrientationFile( VD_DET_NAME_SEARCH, NULL, NULL,
				global.orient_name, x_vec, y_vec ) ){
    strcpy( to->orient_name, global.orient_name );
  }
  else{
    to->orient_name[0] = '\0';
    VDdet_vec_COPY( global.x_vec, x_vec );
    VDdet_vec_COPY( global.y_vec, y_vec );
  }
  VDdet_vec_COPY( to->z_vec, z_vec );
  to->toggle = global.toggle;

  /*
   * calculate the View Orientation values
   */
  BSnorvec( &rc, x_vec );	
  value = BSdotp( &rc, x_vec, z_vec );

  for(i=0;i<3;i++) x_vec[i] = x_vec[i] - (value * z_vec[i]);
  BSnorvec( &rc, x_vec );
	  
  if( value = BSlenvec ( &rc, x_vec ) < VD_DET_EPSILON ){
    /*| reset values */
    to->toggle &= ~VD_DET_AXIS_FLAG;
    return( TRUE );
  }

  /*  get the z_vector direction */
  BScrossp( &rc, z_vec, x_vec, y_tmp );
  BSnorvec( &rc, y_tmp );
  value = BSdotp( &rc, y_vec, y_tmp );
  if( fabs( value ) < VD_DET_EPSILON ){
    /*| reset values */
    to->toggle &= ~VD_DET_AXIS_FLAG;
    return( TRUE );
  }

  if( value < 0.0 ){
    /*| inverse the z-vector */
    for(i=0;i<3;i++) z_vec[i] *= -1;
  }

  /*  calculate the y_vector */
  BSnorvec( &rc, z_vec );
  BScrossp( &rc, z_vec, x_vec, y_vec );
  if( value = BSlenvec ( &rc, y_vec ) < VD_DET_EPSILON ){
    /*| reset values */
    to->toggle &= ~VD_DET_AXIS_FLAG;
  }

  /*  display the vectors */
  VDdet_vec_COPY( x_vec, to->x_vec );
  VDdet_vec_COPY( y_vec, to->y_vec );
  VDdet_vec_COPY( z_vec, to->z_vec );

  to->toggle |= VD_DET_AXIS_FLAG;


  to->flag = TRUE;
  

return( TRUE );
}


VDproj_pnt_plane( sts, pnt, nor, sf_pnt, pr_pnt )
IGRlong		*sts;
IGRdouble	*pnt;
IGRdouble	*nor;
IGRdouble	*sf_pnt;
IGRdouble	*pr_pnt;
/*.proj_pnt_plane*/
{
IGRint		i;
IGRdouble	line[6];

  *sts = MSSUCC;

  for(i=0;i<3;i++){
    line[i]   = pnt[i] + (nor[i] * 1000 );
    line[3+i] = pnt[i] - (nor[i] * 1000 );
  }

  BSproj0( sts, sf_pnt, line, pr_pnt );
  if( *sts != BSSUCC ){
    printf(" VDproj_pnt_plane: fct BSproj0 failed\n");
    for(i=0;i<3;i++)	pr_pnt[i] = pnt[i];
  }
  *sts = MSSUCC;

return( TRUE );
}

/* ********************************************************** */
VDget_dep_extents( sts, obj, matrix, volume )
/* ********************************************************** */
IGRint		*sts;
struct	GRid	*obj;
IGRdouble	*matrix;
IGRdouble	*volume;
{
struct	GRmd_env	dummy_env;
struct	GRid		*list, plane, plane_source;
IGRlong			rc;
IGRboolean		world;
IGRint			i, status, i_obj, count;
GRrange			elem_range;

  /*
   * This method gets the range of plane dependency
   */

  /* init */
  *sts = MSSUCC;

  plane.objid = obj->objid;
  plane.osnum = obj->osnum;
  plane_source.osnum = obj->osnum;

  dummy_env.md_id.osnum		= plane.osnum;
  dummy_env.md_id.objid		= NULL_OBJID;

  if( matrix == NULL ){
    /* get default matrix */
    dummy_env.md_env.matrix_type = MAIDMX;
    MAidmx( &rc, dummy_env.md_env.matrix );
  }
  else{
    for(i=0;i<16;i++)
	dummy_env.md_env.matrix[i] = matrix[i];
    MAtypemx( &rc, dummy_env.md_env.matrix, &dummy_env.md_env.matrix_type );
  }

  /* Find source object in the OS of the plane */
  as$make_source(go_grid = plane,
		 as_os =   plane.osnum,
		 as_grid = &plane_source);

  /*" plane_source: %d,%d\n", plane_source.objid, plane_source.osnum */

  /* Find dependent graph */
  status = nd$get_graph(p_root = &plane_source,nb_root = 1);
  as$status(action = RET_STATUS);

  status = nd$get_list_in_graph(acc_type = ND_BODY | ND_ROOT,
                                       p_count = &count, buf_addr = &list);
  as$status(action = RET_STATUS);

  /*" count: %d\n", count */

  /* accumulate range */
  volume[0] = volume[1] = volume[2] =  1.e+23;
  volume[3] = volume[4] = volume[5] = -1.e+23;

  world = FALSE;
  for(i_obj=0 ; i_obj<count ; i_obj++){

    status =
    om$send(msg = message NDmacro.ACreturn_foot
					(&rc,"",list+i_obj,NULL,NULL),
	    targetid = list[i_obj].objid,
	    targetos = list[i_obj].osnum,
	    senderid = NULL_OBJID );
    if(! (status & rc & 1)){
	/*| NDmacro.ACreturn_foot fails */
	continue;
    }

    /* get range could also be done in a the plane CS To be evaluated */
    status =
    om$send(msg = message GRgraphics.GRgetrang(&rc,
					&dummy_env.md_env.matrix_type,
					dummy_env.md_env.matrix,
					&world,
					elem_range),
	   targetid = list[i_obj].objid,
	   targetos = list[i_obj].osnum,
	   senderid = NULL_OBJID );
    
    if( status != OM_S_SUCCESS || !( rc & 1 )){
        /*| GRgraphics.GRgetrang fails */
        continue;
    }
    for(i=0;i<3;i++) if(elem_range[i] < volume[i]) volume[i] = elem_range[i];
    for(i=3;i<6;i++) if(elem_range[i] > volume[i]) volume[i] = elem_range[i];
  }

  /*" volume: %f %f %f\n", volume[0], volume[1], volume[2] */
  /*" volume: %f %f %f\n", volume[3], volume[4], volume[5] */

  *sts = MSSUCC;

return( TRUE );

}  

end implementation VDCmdDetail;
