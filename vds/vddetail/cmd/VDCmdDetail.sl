/* $Id: VDCmdDetail.sl,v 1.1.1.1 2001/01/04 21:08:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDetail.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDetail.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/07  16:06:30  pinnacle
# TR179901164 b ylong
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/27  18:12:18  pinnacle
# TR179601991
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.14  1996/04/23  05:13:44  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for:  by rgade for vds.240
#
# Revision 1.13  1996/04/12  09:46:28  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for:  by rgade for vds.240
#
# Revision 1.12  1996/03/28  10:31:42  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for:  by msbraju for vds.240
#
# Revision 1.11  1996/03/22  10:34:34  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for:  by msbraju for vds.240
#
# Revision 1.10  1996/03/18  11:00:42  pinnacle
# Replaced: smsurf/cmd/SMCmdSurf.sl for:  by ksundar for vds.240
#
# Revision 1.9  1996/01/08  10:34:58  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for:  by rgade for vds.240
#
# Revision 1.8  1996/01/04  06:33:26  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for:  by rgade for vds.240
#
# Revision 1.7  1995/10/30  12:10:52  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for: OPE by msbraju for $PROJ
#
# Revision 1.6  1995/08/28  21:40:10  pinnacle
# Replaced: ./vddetail/cmd/VDCmdDetail.sl for:  by azuurhou for vds.240
#
# Revision 1.5  1995/03/22  14:51:48  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl by azuurhou r#
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
 *      08/27/96        ah              TR179601991
 *      03/07/00        ylong		TR179901164
 *
 * -------------------------------------------------------------------*/

/*
    File : VDCmdDetail.sl

    Depedencies :	VDCmdDetail.S / VDCmdDetaili.I

    Description
	The class VDCmdDetail is created as a subclass of COdetail which
	contains methods for:
		- creating of drawing views from reference objects.
		- creating windows from planes.

	The class contains message for the user interface and the
	calculation of the drawing view.

	The userinterface is realised with a STATUS_DISPLAY form.


    History
	AdZ   01/01/92	Creation date.
        AdZ   12/29/92	Modification in super_class for is command
			object class. 
			Form is optimized for a better user-interface.
			Plane_offset, Window_Name and Distance Units
			type are added in form and prgram.
			The display box for dynamics is recalculated.
	AdZ   05/01/93	Z Depth problem for compartment extraction.

        ah    08/27/96  Arrows and view boxes were not being displayed
                        properly under Solaris with dynamics.  Moved
                        the graphic display of these objects to the
                        dynamic method.
*/

/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */
class		VDCmdDetail
super_class	"COdetail"
super_class	"VDS_LOCATE"
product_name    "$VDS"
options		"SItc"

start_state     terminate


/* ********************************************************** */
/*	SPECIFICATION AREA				      */
/* ********************************************************** */

specification

#include "OMlimits.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "go.h"
#include "FI.h"
#include "growner.h"
#include "VDdetail.h"


instance
{
	struct	GRobj_env	VDdet_obj_env;
	IGRshort		VDdet_rev_normal; /* added for TR179901164 */

	IGRchar			VDdet_obj_name[VD_DET_TEXT_MAX];
	IGRchar			VDdet_win_name[VD_DET_TEXT_MAX];
	IGRchar			VDdet_ref_name[VD_DET_TEXT_MAX];

	struct	GRid		VDdet_win_id;
	struct	GRid		VDdet_gragad;
	GRspacenum		VDcur_os;
	GRspacenum		VDref_os;

	/* default values for initialisation */
	IGRmatrix		VDdet_matrix;
	IGRvector		VDvec_origin;
	IGRint			VDdet_levels[32];

	/* reference file table and count */
	struct	VDdet_reffile	*VDdet_refer;
	IGRlong			VDdet_refer_cnt;

	/* refernce file active spaces */
	struct	VDdet_reffile	*VDdet_space;
	IGRlong			VDdet_space_cnt;

	/* instance for the status form and used instances */
	IGRint			VDdet_form_display;

	struct	VDdet_formdata	fd_old;		/* original info */
	struct	VDdet_formdata	fd_new;		/* current setting */
	struct	VDdet_formdata	fd_data;	/* working set */

	variable struct VDdet_vw_grid	vw_grid[0];

	/* form_notification return label */
	int			my_label;

	/* solid box showing the clipping box for drawing view*/
	struct  GRid		tmpList[3] ;

		/* [0] : VD_Obj_boxId 	*/
		/* [1] : VD_Obj_csId	*/
		/* [2] : VD_Obj_arrId	*/

/*
 * TR179601991
 * Need to defer deletion of erased arrows until the dynamics
 * method is called again so the screen is updated properly.
*/

struct GRid m_OldBoxId;
struct GRid m_OldArrId;
struct GRid m_OldCsId;

IGRboolean  m_UpdateBox;
IGRboolean  m_UpdateArr;
IGRboolean  m_UpdateCs;

	/* coordinate system at center of clipping box */
	double			csRotMx[16];
	GRrange			tmp_range;
	int			nbRefOs;
	variable GRspacenum	refOsList[1];
}


/* ********************************************************** */
/*	IMPLEMENTATION AREA				      */
/* ********************************************************** */

implementation

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%safe
#include <math.h>
%endsafe

#include "OMerrordef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "go.h"
#include "asbox.h"
#include "growner.h"
#include "execmsg.h"
#include "referr.h"
#include "grerr.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "grmessage.h"
#include "msdef.h"
#include "toolco.h"
#include "detailcodef.h"
#include "detailco.h"
#include "AS_status.h"
#include "lcmacros.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "v_miscmacros.h"
#include "VDmsg.h"

/* include/prototypes */
#include "bstypes.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bscrossp.h"
#include "mamulmx.h"
#include "mainvmx.h"

#include "vderrmacros.h"


#define  VD_CHANGE_ZDEPTHS  1

/**
  #include "VDpr_detail.h"
 **/

/* external functions */
extern		GRgspass();
extern	int	DPsetinqgragad();
extern		VDconvert_lev_string();

/* #define	AS_DEBUG	1 */

/*
 * the static variables are used for:
 *   - VDdet_x_memo, VDdet_y_memo : form location.
 *   - VDdet_global_defined       : constant to see if struct VDdet_formdata
 *                                  is already used.
 *   - VDdet_global_formdata      : Stored information of the latest displayed
 *                                  drawing view.
 */

%safe
static	int	VDdet_x_memo = -1;
static	int	VDdet_y_memo = -1;
static	int	VDdet_global_defined = 0;
static	struct	VDdet_formdata	VDdet_global_formdata;
%endsafe

from  GRgraphics  import  GRdelete;
from  GRgraphics  import  GRdisplay;

/* 
 * **********************************************************
 *	ACTION DEFINITIONS				     
 * **********************************************************
 */

/* ********************************************************** */
action	define_objview
/* ********************************************************** */
{
/* 
 * This method does the creation of the object view. Therefor it calculates
 * first the object volume and the pixel_units on the screen. 
 * An unique view name will be defined.
 * The object matrix, view volume and level will be set in the view
 * gragad object.
 */
IGRint		i;
IGRlong		msg;
GRrange		range;
IGRdouble	ddelta, delta[3];

	status = 0;
  status = VDdet_find_obj_range(&msg,
				&me->VDdet_obj_env,
				me->VDdet_obj_env.mod_env.md_env.matrix,
				range );
  if( status ) {

    /*
     * See if the select plane is an infinite or frame plane.
     * If selected: give total intersection of the hull as default
     */
    IGRint	loc_sts;
    GRclassid	ClassId;
    GRrange	HullRange;
    struct GRid	HullGr, HullAs;
    struct GRmd_env	HullEnv;

    loc_sts = om$get_classid(osnum = me->VDdet_obj_env.obj_id.osnum,
                             objid = me->VDdet_obj_env.obj_id.objid,
                             p_classid = &ClassId );

    if( ( om$is_ancestry_valid (
		subclassid = ClassId,
		superclassname = "VDSInfPl") == OM_S_SUCCESS ) ||
	( om$is_ancestry_valid (
		subclassid = ClassId,
		superclassname = "SMframe" ) == OM_S_SUCCESS )){

      /* Look if a hull is defined. */
      if( SMGetActHull( &HullAs, NULL, &HullEnv, &HullGr ) ){
        
	/* get Hull Range. */
	loc_sts = SMExtToRng(&HullGr, &HullEnv, NULL, NULL, HullRange );
	if( loc_sts&1 ){
	  for(i=0;i<3;i++){
	    if( range[i+3] != range[i] ) {
	        range[i]   = HullRange[i];
		range[3+i] = HullRange[3+i];
	    }
          }
	}
      }
    }
  }
  if( ! status ){
    printf(" define_objview : msg VDdet_find_obj_range failed\n");
    goto wrapup;
  } 

  /* we will try to create an volume margin of five procent */
  for(i=0;i<3;i++) delta[i] = ( range[3+i] - range[i] ) / 20.0;

  for(i=0; i<3; i++){
    me->fd_data.vw_volume[i]    = range[i]   - delta[i]; /* x,y minimum */
    me->fd_data.vw_volume[3+i]  = range[3+i] + delta[i]; /* x,y maximum */
    me->fd_data.dep_volume[i]   = range[i];	/* x,y minimum */
    me->fd_data.dep_volume[3+i] = range[3+i];	/* x,y maximum */
  }

  for(i=0; i<3; i++){
    me->fd_data.x_vec[i] = me->VDdet_matrix[i];
    me->fd_data.y_vec[i] = me->VDdet_matrix[4+i];
    me->fd_data.z_vec[i] = me->VDdet_matrix[8+i];
  }

  /* volume values 5% limits */
  for(i=0;i<3;i++) delta[i] = ( range[i+3] - range[i] ) / 20.0;

  /* get the z_depth factor */
  if(      delta[0] < delta[1] && delta[0] < delta[2] ){
    ddelta = ( delta[1] < delta[2] ) ? delta[1] : delta[2];
  }
  else if( delta[1] < delta[0] && delta[1] < delta[2] ){
    ddelta = ( delta[0] < delta[2] ) ? delta[0] : delta[2];
  }
  else if( delta[2] < delta[0] && delta[2] < delta[1] ){
    ddelta = ( delta[0] < delta[1] ) ? delta[0] : delta[1];
  }
  else{
    ddelta = ( delta[0] < delta[1] ) ? delta[1] : delta[0];
    if( ddelta < delta[2] ) ddelta = delta[2];
  }

  me->fd_data.z_depth[0] = -(ddelta);
  me->fd_data.z_depth[1] =  ddelta;

  /* get origin of plane */
  for(i=0;i<3;i++) me->fd_data.origin[i] = (range[3+i] + range[i]) / 2.0;

  /* save defaults instance values */
  strcpy( me->fd_data.name, me->VDdet_obj_name );
  me->fd_data.flag = FALSE;

  /* copy the instance data */
  me->fd_old = me->fd_data;

  /* set the global information setting */
  if( VDdet_global_defined ){
    /*
     * compare with previous info
     */
    VDdet_get_global_DATA( &(me->fd_data), VDdet_global_formdata );
    VDconvert_lev_string(sts, me->fd_data.layer_str, me->VDdet_levels );
  }

  /* copy info to form data structures */
  me->fd_new = me->fd_data;

  /* set vector values in matrix for dynamics */
  for( i=0; i<3; i++){
    me->VDdet_matrix[i]   = me->fd_new.x_vec[i];
    me->VDdet_matrix[4+i] = me->fd_new.y_vec[i];
    me->VDdet_matrix[8+i] = me->fd_new.z_vec[i];
  }

/*
 * Will need to correct this code if ever uncommented
  if ( me->tmpList[VD_Obj_boxId].objid == NULL_OBJID )
  {
    status = VDdisp_clip_box(	&msg,
				&me->tmpList[VD_Obj_boxId],
				&me->tmpList[VD_Obj_csId],
				&me->tmpList[VD_Obj_arrId],
				0,
				&me->ModuleInfo, me->fd_new.vw_volume,
				&me->fd_new.vw_volume[3], 0 );

    if ( me->tmpList[VD_Obj_boxId].objid != NULL_OBJID &&
	 me->fd_new.toggle & VD_DET_ALT_FLAG )
    {
	status = VDdisp_view_arrow (	&msg,
					&me->tmpList[VD_Obj_arrId],
					&me->ModuleInfo,
					me->fd_new.vw_volume,
					&me->fd_new.vw_volume,
					me->fd_new.viewchar );
    }
  }
*/

  *sts = MSSUCC;
  goto quit ;

wrapup:
  *sts = MSFAIL;
  goto quit ;
}

/* ********************************************************** */
action	construct_objview
/* ********************************************************** */
{
/* 
 * The object matrix, view volume and level will be set in the view
 * gragad object.
 * The window size will be created depended on the obj_range and a
 * display margin.
 * Finally, the window will be created but not activated.
 */
IGRint	i,j;
IGRlong	rc, msg, error_var;
IGRlong	num_bytes;
GRrange	win_range;		/* MIN_X, MIN_Y, 0, MAX_X, MAX_Y, 0 */
IGRshort	one, four;
IGRpoint	range_origin;
IGRdouble	fr_pnt[4], to_pnt[4];
IGRdouble 	ref_scale, units_scale, scale;
IGRdouble	volume[6];	
IGRboolean	resp;
struct var_list	var_list[4];
char		*fm_ptr = NULL, axis_tgl[20], view[20];
char		viewchar = VD_NODIR ;

  /**********************/
  /* define the view	*/
  /**********************/

  /* set the gragad module environment */
  me->VDdet_gragad.objid = NULL_OBJID;
  me->VDdet_gragad.osnum = ( me->mytype != VD_viewplane )
            ? me->VDref_os		/* to reference object space */
            : me->VDcur_os;		/* to current object space */

	resp=0;
  resp = VDdet_gen_window_name(	&msg,	me->VDdet_gragad.osnum,
					me->VDdet_win_name );
  if( ! resp ){
    printf(" construct_objview : fct VDdet_gen_window_name failed\n");
    goto wrapup;
  }

  /* creation of the gragad and the initialisation */
	resp=0;
  resp = VDdet_create_view ( &msg,	&me->VDdet_gragad,
					me->VDdet_win_name );
  if( ! resp ){
    printf(" construct_objview : fct VDdet_create_view failed \n");
    goto wrapup;
  }

  /* construction values */
  for( i=0; i<3; i++){
    me->VDdet_matrix[i]		= me->fd_data.x_vec[i];
    me->VDdet_matrix[4+i]	= me->fd_data.y_vec[i];
    me->VDdet_matrix[8+i]	= me->fd_data.z_vec[i];
  }

  if( me->fd_data.vol_toggle & VD_DET_DEP_EXT ){
    /* copy dependency extents */
    for(i=0;i<6;i++)
	me->fd_data.vw_volume[i] = me->fd_data.dep_volume[i];
  }

  /*
   * calculate the origin of the selected range, projected
   * on the plane origin
   */
  for(i=0;i<3;i++) range_origin[i] =
	( me->fd_data.vw_volume[3+i] + me->fd_data.vw_volume[i] ) / 2.0;

  VDproj_pnt_plane( &rc, range_origin,
			 me->fd_data.z_vec,
			 me->fd_old.origin,
			 range_origin );

  /*  project the view volume values on the plane */
  VDproj_pnt_plane( &rc, &(me->fd_data.vw_volume[0]),
			 me->fd_data.z_vec,
			 range_origin,
			 &(volume[0]) );

  VDproj_pnt_plane( &rc, &(me->fd_data.vw_volume[3]),
			 me->fd_data.z_vec,
			 range_origin, 
			 &(volume[3]) );

  /* copy to active values */
  for(i=0;i<6;i++)	me->fd_data.vw_volume[i] = volume[i];

  /* set the new z_depth values */
  if( me->fd_data.toggle & VD_DET_ZDEPTH_FLAG ){
    for(i=0;i<3;i++){
      me->fd_data.vw_volume[i]  +=
		me->fd_data.usr_z_depth[0] * me->fd_data.z_vec[i];
      me->fd_data.vw_volume[3+i]+=
		me->fd_data.usr_z_depth[1] * me->fd_data.z_vec[i];
    }
  }
  else{
    for(i=0;i<3;i++){
      me->fd_data.vw_volume[i]  += 
		me->fd_data.z_depth[0] * me->fd_data.z_vec[i];
      me->fd_data.vw_volume[3+i]+= 
		me->fd_data.z_depth[1] * me->fd_data.z_vec[i];
    }
  }

  /* 
   * move the vw_volume with a given offset.
   */
  if( me->fd_data.offset_toggle ){
    for(i=0;i<3;i++){
      me->fd_data.vw_volume[i]   += me->fd_data.offset_value *
				    me->fd_data.z_vec[i];
      me->fd_data.vw_volume[3+i] += me->fd_data.offset_value *
				    me->fd_data.z_vec[i];
    }
  }

  /* calculate the points is new object space */
  four = 4; one = 1;
  for(i=0; i<2; i++){
    /* copy the points */
    for(j=0;j<3;j++) fr_pnt[j] = me->fd_data.vw_volume[i*3+j];
    fr_pnt[3] = 1;
    MAmulmx( &msg, &four, &four, &one, me->VDdet_matrix, fr_pnt, to_pnt );
    if( ! msg ) {
      printf(" construct_objview : fct MAmulmx failed\n");
      goto wrapup;
    }
    for( j=0; j<3; j++ ) me->fd_data.vw_volume[i*3+j] = to_pnt[j];
  }

  /* Setting of the view rotation	*/
  var_list[0].var		= VIEW_ROTATION;
  var_list[0].var_ptr		= (IGRchar *)me->VDdet_matrix;
  var_list[0].num_bytes		= 16 * sizeof (IGRdouble) ;
  var_list[0].bytes_returned	= &num_bytes;
	
  var_list[1].var		= VW_VOLUME;
  var_list[1].var_ptr		= (IGRchar *)me->fd_data.vw_volume;
  var_list[1].num_bytes		= 6 * sizeof (IGRdouble);
  var_list[1].bytes_returned	= &num_bytes;

  var_list[2].var		= LEVELS;
  var_list[2].var_ptr		= (IGRchar *)me->VDdet_levels;
  var_list[2].num_bytes		= 32 * sizeof (IGRint);
  var_list[2].bytes_returned	= &num_bytes;

  var_list[3].var		= END_PARAM ;

  status =
  dp$inq_set_gragad (	msg         = &msg,
			inq0_set1   = 1,
			calc_info   = 0,
			update      = 0,	/* or 1 KLUDGE */
			osnum       = me->VDdet_gragad.osnum,
			gragad_objid = me->VDdet_gragad.objid,
			which_error = &error_var,
			var_list    = var_list ) ;
  if ( !(status & 1) ){
    printf(" construct_objview : macro inq_set_gragad failed \n");
    om$report_error( sts = status );
    goto wrapup;
  }

  fm_ptr = me->status_display_form_ptr;
  VDdet_get_ALPHA( fm_ptr, VD_DET_AXIS_TOGGLE, axis_tgl );

  if ( !strcmp(axis_tgl, "Alternative") )
  {
     VDdet_get_ALPHA ( fm_ptr, VD_DET_VIEW_FLD, view );
     VDdet_get_VIEWCHAR( view, &viewchar );

	resp=0;
     resp = VDdet_set_window_size1 ( &msg, me->fd_data.vw_volume, viewchar,
				    me->VDdet_matrix, win_range );
     if( ! resp ){
        om$report_error( sts = *sts );
        printf(" construct_objview : fct VDdet_set_window_size1 failed \n");
        goto wrapup;
     }
  }
  else
  {
     /* creation, activation, gragad linking of physical window */
	resp=0;
     resp = VDdet_set_window_size ( &msg, 	&me->VDdet_obj_env,
					me->VDdet_matrix,
					win_range );
     if( ! resp ){
        om$report_error( sts = *sts );
        printf(" construct_objview : fct VDdet_set_window_size failed \n");
        goto wrapup;
     }
  }

  {
    /*
     * When a SMframe or a VDSInfPl object is selected, construct an
     * window using the limits of the defined Hull.
     */

    IGRint loc_sts;
    GRclassid	ClassId;
    GRrange	HullRange;
    struct GRid HullGr,HullAs;
    struct GRmd_env HullEnv;

    loc_sts = om$get_classid(osnum = me->VDdet_obj_env.obj_id.osnum,
                             objid = me->VDdet_obj_env.obj_id.objid,
                             p_classid = &ClassId );

    if( ( om$is_ancestry_valid (
                subclassid = ClassId,
                superclassname = "VDSInfPl" ) == OM_S_SUCCESS ) || 
	( om$is_ancestry_valid (
		subclassid = ClassId,
		superclassname = "SMframe" ) == OM_S_SUCCESS )) {

      /* Look if a hull is defined. */
      if( SMGetActHull( &HullAs, NULL, &HullEnv, &HullGr ) ){
        
	/* get Hull Range. */
	for(i=0;i<16;i++) HullEnv.md_env.matrix[i] = me->VDdet_matrix[i];
	MAtypemx( sts, HullEnv.md_env.matrix, &HullEnv.md_env.matrix_type );

	loc_sts = SMExtToRng(&HullGr, &HullEnv, NULL, NULL, HullRange );
	if( loc_sts&1 ){
	  IGRdouble xmin, ymin, Dx, Dy;
	  IGRdouble dxx, dyy, pixel_unit;

	  xmin = ymin = 0.0;
	  loc_sts = VDdet_design_data( sts, &pixel_unit );
	  if( loc_sts ){

	    dxx = HullRange[3] - HullRange[0];		/* object size */
	    dyy = HullRange[4] - HullRange[1];

	    Dx = (dxx / ( dxx + dyy )) * VD_DET_DIMENS_MAX_X;
	    Dy = (dyy / ( dxx + dyy )) * VD_DET_DIMENS_MAX_Y;

	    if( Dx < 100.0 ){	 Dx = 100.0; Dy = 900.0; }
	    else if( Dy < 100.0 ){ Dx = 900.0; Dy = 100.0; }

	    /* calculation of the location of the window on the screen	*/

	    win_range[0] = VD_DET_LEFT_MARGIN + floor( xmin * pixel_unit );
	    win_range[1] = VD_DET_TOP_MARGIN  + floor((Dx + xmin) * pixel_unit );
	    win_range[2] = 0.0;

	    win_range[3] = VD_DET_DIMENS_HEIGHT - VD_DET_RIGHT_MARGIN
			   - 4.0 - ceil( (Dy + ymin) * pixel_unit ); 
	    win_range[4] = VD_DET_DIMENS_HEIGHT - VD_DET_BOTTOM_MARGIN 
			  - 4.0 - ceil( ymin * pixel_unit );
	    win_range[5] = 0.0;
	  }
        }
      }
    }
  }

	resp=0;
  resp = VDdet_make_window( &msg,	&me->VDdet_gragad,
					me->VDdet_win_name,
					&me->VDdet_win_id,
					win_range,
					me->mytype );
  if( ! resp ){
    printf(" construct_objview : fct VDdet_make_window failed \n");
    goto wrapup;
  }

  if( me->mytype == VD_viewplane ){
    *sts = MSSUCC;
    return( OM_S_SUCCESS );
  }

  /*
   * set view name and scaling factor
   */
  strcpy( me->view, me->VDdet_win_name );
  strcpy( me->text_scale, me->fd_data.text_scale );
  me->VDvec_origin[0] = me->VDvec_origin[1] = me->VDvec_origin[2] = 0.0; 

  /*
   * Calcalution of the scale factor for the placement of the drawing view,
   * which depends on : 
   *	- drawing view scale factor	( user defined )
   *	- local scale factor between intern and user distance units
   *    - reference scale factor between intern and reference intern
   *	  distance units.
   */

  VDdet_get_scale_fact( me->text_scale, &scale );

  /* reference scale factor */
  ref_scale = 1.0;
  VDdet_conv_ext_int( ref_scale, &ref_scale, me->VDref_os );
  
  /* local scale factor */
  units_scale = 1.0;
  VDdet_conv_ext_int( units_scale, &units_scale, me->VDcur_os );

  /* used scale factor */ 
  scale = scale * units_scale / ref_scale ;
  
  /*
   *  define new place origin
   */
  if( me->fd_data.vol_toggle & VD_DET_USER_FLAG ||
      me->fd_data.vol_toggle & VD_DET_OBJ_RNG   ||
      me->fd_data.vol_toggle & VD_DET_ADD_RNG   ||
      me->fd_data.vol_toggle & VD_DET_PTS_RNG     ){

    /*  project origin on plane */
    VDproj_pnt_plane( &rc,	me->fd_data.origin,
				me->fd_data.z_vec,
				range_origin,
				me->fd_data.origin );

    /* calculate the vector is new object space */
    four = 4; one = 1;
    /* copy the points */
    for(j=0;j<3;j++) fr_pnt[j] = range_origin[j] - me->fd_data.origin[j];
    fr_pnt[3] = 1; 
    MAmulmx( &msg, &four, &four, &one,
		me->VDdet_matrix,
		fr_pnt, to_pnt );
    if( ! msg ) {
      printf(" construct_objview : fct MAmulmx failed\n");
      goto wrapup;
    }

    /* we change the event location */
    me->event1.event.button.x += to_pnt[0] * scale;
    me->event1.event.button.y += to_pnt[1] * scale;
    me->event1.event.button.z += to_pnt[2] * scale;

    for(i=0;i<3;i++) me->VDvec_origin[i] = to_pnt[i] * scale;
  }

  /*
   * test the z_depth difference
   */

#ifdef no_zdepth

  /*
   * CH,ADZ (Saterday, 1 MAI 1993)
   *
   * To place the drawing view at the user aspected location the loc_event
   * is modified.
   * By having an asymetric zdepth range for the drawing view gives a
   * problem during drawing extraction of compartments.
   * The intersection calculation is incorrect.
   *
   * Only symetrical values are accepted.
   */

  if( me->fd_data.toggle & VD_DET_ZDEPTH_FLAG ){
    if( fabs(me->fd_data.usr_z_depth[0] + me->fd_data.usr_z_depth[1] ) 
	> VD_DET_EPSILON ){

	/*  calculate the offset vector for the origin */
	delta = (me->fd_data.usr_z_depth[0] + me->fd_data.usr_z_depth[1]) / 2.0;

	/* offset vector */
	for(i=0;i<3;i++){
	  offset[i] = delta * scale * me->ModuleInfo.md_env.matrix[4*i+2];
	  me->VDvec_origin[i] += offset[i];
	}
	/*  we change the event location */
	me->event1.event.button.x += offset[0];
	me->event1.event.button.y += offset[1];
	me->event1.event.button.z += offset[2];
    }
  }

#endif

  *sts = MSSUCC;
  goto quit ;

wrapup:
  *sts = MSFAIL;
  goto quit ;
}


/* ********************************************************** */
action VDupdate_form( long * sts; int index )
/* ********************************************************** */
/*.update_from*/
{
  /* 
   * depending on the place where this method is called, 
   * the form will be  displayed
   * either according to the active mode or set to display mode.
   */
IGRint	state;
IGRchar	buffer[256];
char	*fm_ptr;

  if( index ) me->VDdet_form_display = TRUE;

  fm_ptr = me->status_display_form_ptr;

  /* test the display conditions */
  if(( me->VDdet_form_display ) && ( fm_ptr )){
    if( me->VDdet_obj_env.obj_id.objid != NULL_OBJID ){
      /* fill in the form data */
      status =
      _VD_SEND_MY( VDCmdDetail.VDfill_in_form( sts ));
      as$status( action = RET_STATUS );

      if( VDdet_x_memo != -1 || VDdet_y_memo != -1 )
	FIf_set_location(fm_ptr, VDdet_x_memo, VDdet_y_memo);

      FIg_get_state( fm_ptr, VD_DET_OFFSET_TOGGLE, &state );
      if( state ) 
	FIg_display( fm_ptr, VD_DET_OFFSET_VALUE );
      else
	FIg_erase( fm_ptr, VD_DET_OFFSET_VALUE );
      FIg_display( fm_ptr, VD_DET_OFFSET_TOGGLE );

      FIg_display( fm_ptr, VD_DET_LAYER_NAME );
      FIg_display( fm_ptr, VD_DET_LAYERS );

      if( me->mytype == VD_viewplane ){
	/*
	 * erase/display gadgets for plane view
	 */
	FIg_erase( fm_ptr, VD_DET_ORIGIN_NAME );
	FIg_erase( fm_ptr, VD_DET_ORIGIN );
	FIg_erase( fm_ptr, VD_DET_EXT_DRAWING );
	FIg_erase( fm_ptr, VD_DET_SCALE_NAME );
	FIg_erase( fm_ptr, VD_DET_SCALE );

	FIg_display( fm_ptr, VD_DET_EXT_WINDOW );
	FIg_display( fm_ptr, VD_DET_WIN_NAME );
	FIg_display( fm_ptr, VD_DET_WIN_NAME_DESC );
      }
      else{
	/*
	 * erase/display gadgets for drawing view
	 */
	FIg_erase( fm_ptr, VD_DET_EXT_WINDOW );
	FIg_erase( fm_ptr, VD_DET_WIN_NAME );
	FIg_erase( fm_ptr, VD_DET_WIN_NAME_DESC );

	FIg_display( fm_ptr, VD_DET_EXT_DRAWING );
	FIg_display( fm_ptr, VD_DET_ORIGIN_NAME );
	FIg_display( fm_ptr, VD_DET_ORIGIN );
	FIg_display( fm_ptr, VD_DET_SCALE_NAME );
	FIg_display( fm_ptr, VD_DET_SCALE );

	

      }

      /*
       * Display the active distance units
       */
      state = VDdet_get_def_units( me->ModuleInfo.md_id.osnum,
			           "Distance Units : " , buffer );
      if( state ){
	VDdet_set_ALPHA( fm_ptr, VD_DET_DIST_UNITS, buffer );
	FIg_display( fm_ptr, VD_DET_DIST_UNITS );
      }

      status = FIf_display(fm_ptr);
      if(status != FI_SUCCESS){
	printf("FIf_display fails\n");
	return(OM_E_ABORT);
      }
      me->form_requested = 1;
    }
    else{
      ex$message( msgnumb = VD_E_IdStaDisp );
    }
  }

  *sts = MSSUCC;
  goto quit ;
}


/* ********************************************************** */
action form_notification
/* ********************************************************** */
/*.form_not*/
{
IGRint		i, flag, row, row_max, len;
IGRlong		rc, sts;
IGRdouble	value, values[3], ext6[6];
IGRvector	x_vec, y_vec, z_vec, y_tmp;
IGRchar		my_text[256], filename[15], name[15];
IGRint		set_previous;
char		*fm_ptr;


/*
 * This method is used for the interface for the command objects for
 * drawing either a drawing view or a window.
 * The scale factor and the origin of the drawing view are not interpreted
 * for the window construction.
 * The c-forms are VDDetail and VDDetailWin
 */

  me->my_label = VD_DET_FORM_INIT;

  if( form_ptr != me->status_display_form_ptr ){
    /*| wrong form */
    return( OM_S_SUCCESS );
  }

	fm_ptr = me->status_display_form_ptr;
	VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, "" );

	/*
	 * if the flag = TRUE, the x,y,z-vectors are recalculated,
	 * otherwise wait for result.
	 * In case the flags stays TRUE after the calculations it
	 * will be forbidden to leave the form_notification form
	 */

	{
		GRclassid	sender_class;

		status =
		om$get_classid(
			osnum     = me->VDdet_obj_env.obj_id.osnum,
                        objid     = me->VDdet_obj_env.obj_id.objid,
                        p_classid = &sender_class );

		if( om$is_ancestry_valid(
			subclassid   = sender_class,
                        superclassname  = "EMSsolid" ) == OM_S_SUCCESS ){

			goto start_switch;
		}
	}


	set_previous = FALSE;
	if( me->fd_new.flag == TRUE ){
	  /* test for input event type */
	  if( gadget_label != VD_DET_X_AXIS &&
	      gadget_label != VD_DET_Y_AXIS &&
	      gadget_label != FI_RESET ){

	    VDdet_get_VALUES3( fm_ptr, VD_DET_X_AXIS, x_vec );
	    VDdet_get_VALUES3( fm_ptr, VD_DET_Y_AXIS, y_vec );
	    VDdet_get_VALUES3( fm_ptr, VD_DET_Z_AXIS, z_vec );
	    
	    /* calculate the x-vector */
	    BSnorvec( &rc, x_vec );	
	    value = BSdotp( &rc, x_vec, z_vec );
	    for(i=0;i<3;i++) x_vec[i] = x_vec[i] - (value * z_vec[i]);
	    BSnorvec( &rc, x_vec );
	  
	    if( value = BSlenvec ( &rc, x_vec ) < VD_DET_EPSILON ){
	        /*| reset initial values */
		set_previous = TRUE;
 	    }
	    else{
		/* get the z_vector direction */
		BScrossp( &rc, z_vec, x_vec, y_tmp );
		BSnorvec( &rc, y_tmp );
		value = BSdotp( &rc, y_vec, y_tmp );
		if( fabs( value ) < VD_DET_EPSILON ){
		  /*| reset values */
		  set_previous = TRUE;
		}

		if( value < 0.0 ){
		  /* inverse the z-vector */
		  for(i=0;i<3;i++) z_vec[i] *= -1;
		}

		/* calculate the y_vector */
		BSnorvec( &rc, z_vec );
		BScrossp( &rc, z_vec, x_vec, y_vec );

		if( value = BSlenvec ( &rc, y_vec ) < VD_DET_EPSILON ){
		  /* reset initial values */
		  set_previous = TRUE;
		}

		/* display the vectors */
		VDdet_vec_COPY( x_vec, me->fd_new.x_vec );
		VDdet_vec_COPY( y_vec, me->fd_new.y_vec );
		VDdet_vec_COPY( z_vec, me->fd_new.z_vec );

		VDdet_set_VALUES3(fm_ptr, VD_DET_X_AXIS, me->fd_new.x_vec );
		VDdet_set_VALUES3(fm_ptr, VD_DET_Y_AXIS, me->fd_new.y_vec );
		VDdet_set_VALUES3(fm_ptr, VD_DET_Z_AXIS, me->fd_new.z_vec );

		me->fd_new.flag = FALSE;
	    }
	  }
	}
	
 	if( set_previous ){

	  /* set to Plane Vector values */
	  VDdet_set_TEXT( fm_ptr, VD_DET_AXIS_TOGGLE, 1 );

	  VDdet_vec_COPY( me->fd_old.x_vec, me->fd_new.x_vec );
	  VDdet_vec_COPY( me->fd_old.y_vec, me->fd_new.y_vec );
	  VDdet_vec_COPY( me->fd_old.z_vec, me->fd_new.z_vec );

	  VDdet_set_VALUES3(fm_ptr, VD_DET_X_AXIS, me->fd_new.x_vec );
	  VDdet_set_VALUES3(fm_ptr, VD_DET_Y_AXIS, me->fd_new.y_vec );
	  VDdet_set_VALUES3(fm_ptr, VD_DET_Z_AXIS, me->fd_new.z_vec );

	  VDdet_set_MODE_OFF( fm_ptr, VD_DET_X_AXIS, 3 );
	  VDdet_set_MODE_OFF( fm_ptr, VD_DET_Y_AXIS, 3 );

	  me->fd_new.toggle &= ~VD_DET_AXIS_FLAG;

	  VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, " Invalid axis values" );
	}

	/* set vector values in matrix for dynamics */
	for( i=0; i<3; i++){
	  me->VDdet_matrix[i]	= me->fd_new.x_vec[i];
	  me->VDdet_matrix[4+i]	= me->fd_new.y_vec[i];
	  me->VDdet_matrix[8+i]	= me->fd_new.z_vec[i];
	}

start_switch:

	switch(gadget_label)
	{
	case FI_CVT_TO_PERM_WIN:
		/*| FI_CVT_TO_PERM_WIN */

	break;
	case FI_RESET:
		/*
		 * reset to initial values
		 * The structure fd_data contain the original values of the
		 * plane after the information of get_global_DATA modifications,
		 * which will be get by reset option.
		 */

		/* copy the instance data */
		me->fd_new = me->fd_data;

		status =
		_VD_SEND_MY( VDCmdDetail.VDupdate_form( &sts, 0 ));
		as$status( action = RET_STATUS );
	break;

	case FI_EXECUTE:
		/*
		 * Is not active in the form, but can be implementated
		 * if prefered.
		 * The action is equal to FI_ACCEPT, only the forms stays
		 * active.
		 */
		/* copy the instance data */
		me->fd_data = me->fd_new;

		VDdet_global_formdata = me->fd_new;
		VDdet_global_defined = TRUE;

		me->my_label = VD_DET_FORM_EXECUTE;

		me->fd_old = me->fd_new;
	break;

	case FI_ACCEPT:
		/*
		 * The modified values are set in the structure fd_data,
		 * which will be read for construction.
		 * The resulting values are stored in global defined
		 * structure called VDdet_global_formdata.
		 */

		/* warning of vector values */
		if( me->fd_new.flag == TRUE ){
		  VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD,
				"Warning: Vector values are reset " );
		  FIg_set_state_off( fm_ptr, FI_ACCEPT );
		  me->fd_new.flag = FALSE;
		  break;
 		}

		/* copy the instance data */
		me->fd_data = me->fd_new;
		me->fd_old = me->fd_new;

		VDdet_global_formdata = me->fd_new;
		VDdet_global_defined = TRUE;
      		FIf_get_location( me->status_display_form_ptr,
					&VDdet_x_memo, &VDdet_y_memo );

                status = FIf_erase(fm_ptr);
                if(status != FI_SUCCESS)
                {
                        printf("FIf_erase fails\n");
                        return(OM_E_ABORT);
                }
		me->form_requested = 0;
                me->VDdet_form_display = FALSE;

		me->my_label = VD_DET_FORM_ACCEPT;

	break;

	case VD_DET_SCALE:
		/*
		 * The scale has to be of the following structure:
		 * <value>:<factor>
		 * The syntax will be tested to avoide error.
		 */
		strcpy(my_text, me->fd_new.text_scale );
		VDdet_get_ALPHA( fm_ptr, gadget_label, me->fd_new.text_scale );

		len = strlen( me->fd_new.text_scale );
		if( len == 0 ){
		  /* set old scale factor */
		  strcpy( me->fd_new.text_scale, VD_DET_DEF_SCALE );
		  VDdet_set_ALPHA( fm_ptr, gadget_label, me->fd_new.text_scale );
		  VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, "Set default scale factor" );
		  break;
		}
		i=0;
		while(me->fd_new.text_scale[i] != ':' && i<len ) i++;
		if( i==0 || i==len ){
		  /* set old scale factor */
		  strcpy( me->fd_new.text_scale, my_text );
		  VDdet_set_ALPHA( fm_ptr, gadget_label, me->fd_new.text_scale );
		  VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, 
			"Syntax error in scale factor: use X:Y" );
		  break;
		}
		VDdet_set_ALPHA( fm_ptr, gadget_label, me->fd_new.text_scale );
	break;

	case VD_DET_Z_DEPTH_TOGGLE:

		if( VDdet_get_STATE( fm_ptr, gadget_label )){

		  /* state USER_DEFINED */
		  me->fd_new.toggle |= VD_DET_ZDEPTH_FLAG;
		  for(i=0;i<2;i++)
		    VDdet_conv_int_ext( me->fd_new.usr_z_depth[i], &(ext6[i]), 
					me->VDcur_os );
		  VDdet_set_VALUES2( fm_ptr, VD_DET_Z_DEPTH, ext6 );
		  VDdet_set_MODE_ON( fm_ptr, VD_DET_Z_DEPTH, 2 );
		}
		else{
		  /* state PLANE_DEFINE */
		  me->fd_new.toggle &= ~VD_DET_ZDEPTH_FLAG;
		  me->fd_new.z_depth[0] = me->fd_old.z_depth[0]; 
		  me->fd_new.z_depth[1] = me->fd_old.z_depth[1]; 

		  for(i=0;i<2;i++)
		    VDdet_conv_int_ext( me->fd_new.z_depth[i], &(ext6[i]), 
					me->VDcur_os );
		  VDdet_set_VALUES2(  fm_ptr, VD_DET_Z_DEPTH, ext6 );
		  VDdet_set_MODE_OFF( fm_ptr, VD_DET_Z_DEPTH, 2 );
		}
	break;

	case VD_DET_Z_DEPTH:

		if(! (me->fd_new.toggle & VD_DET_ZDEPTH_FLAG )){
		  /* No modif possible */
		  break;
		}

		VDdet_get_VALUES2( fm_ptr, gadget_label, ext6 );
		for(i=0;i<2;i++)
		  VDdet_conv_ext_int( ext6[i], &(values[i]), me->VDcur_os );

		me->fd_new.usr_z_depth[0] = values[0];
		me->fd_new.usr_z_depth[1] = values[1];

	  /* Donot allow (0.0,0.0 ) for zdepth */
		if( values[0] == 0.0 && values[1] == 0.0 ) {
		    me->fd_new.usr_z_depth[0] = -1.0;
		    me->fd_new.usr_z_depth[1] = 1.0;
		    VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD,
					"Invalid z_depth (min and max) values");
		} else 
                    
		 if( values[0] > 0.0 || values [1] < 0.0 ){
		  
		  if( values[0] > 0.0 ){
		    me->fd_new.usr_z_depth[0] = -100.0;
		    VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD,
					"Invalid z_depth (min) value");
		  }
		  if( values[1] < 0.0 ){
		    me->fd_new.usr_z_depth[1] = 100.0;
		    VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD,
					"Invalid z_depth (max) value");
		  }
		}
		else{
		  me->fd_new.usr_z_depth[0] = values[0];
		  me->fd_new.usr_z_depth[1] = values[1];
		}

		for(i=0;i<2;i++)
		  VDdet_conv_int_ext( me->fd_new.usr_z_depth[i],
					&(ext6[i]), me->VDcur_os );
		VDdet_set_VALUES2( fm_ptr, gadget_label, ext6 );
	break;

	case VD_DET_NAME:
		/* not implementated */
		VDdet_get_ALPHA(fm_ptr, gadget_label, me->fd_new.name );
	break;

	case VD_DET_NAME_DESC:
		/* not implemetated */
		VDdet_get_ALPHA(  fm_ptr, gadget_label, me->fd_new.name_desc );
	break;

	case VD_DET_ORIGIN:
		/*
		 * For the origin values is no control
		 */
		VDdet_get_VALUES3( fm_ptr, gadget_label, ext6 );
		for(i=0;i<3;i++)
		  VDdet_conv_ext_int(   ext6[i], &(me->fd_new.origin[i]),
					me->VDcur_os );
#ifdef VD_CHANGE_ZDEPTHS
		status =
		_VD_SEND_MY( VDCmdDetail.VDdet_set_zdepths( &sts ));
#endif
	break;

	case VD_DET_AXIS_TOGGLE:

		VD_ViewOrientationFile( VD_DET_NAME_COUNT,
					fm_ptr,
					&row_max,
					NULL, NULL, NULL );
		flag = FALSE;
		my_text[0] = '\0';
		row_max += VD_DET_AXIS_LIST_MIN;
		row = 0;
		do{
		  FIfld_get_list_default_text( fm_ptr, gadget_label, row, 0, 
						256, my_text, &flag);
		  FIfld_get_list_select( fm_ptr,gadget_label,row,0,&flag);
		  ++row;
		}while( flag != TRUE && row <= row_max );

		if( row == 0 || row > row_max ){
		  /* error in select options */
		  break;
		}

		FIfld_set_list_select( fm_ptr,gadget_label,(row-1),0,FALSE);

		me->fd_new.orient_name[0] = '\0';
/*
  Commented - raju 03/02/95, could not understand why the statement.
		me->fd_new.toggle = 0;
*/
		if ( row == 2 && me->mytype != VD_drawview )
		{
		  FIg_set_text ( fm_ptr, FI_MSG_FIELD,
				"Option valid for draw view command only" );
		  row = 1;
		  VDdet_set_TEXT( fm_ptr, VD_DET_AXIS_TOGGLE, 1 );
		}

		if ( row != 2 )
		{
		  SMVA_display ( fm_ptr, 6, VD_DET_X_AXIS,
					    VD_DET_Y_AXIS,
					    VD_DET_Z_AXIS, 
					    VD_DET_X_AXIS_TXT,
				       	    VD_DET_Y_AXIS_TXT,
					    VD_DET_Z_AXIS_TXT );

		  SMVA_erase   ( fm_ptr, 4, VD_DET_VIEW_TXT,
					    VD_DET_VIEW_FLD,
					    VD_DET_ROT_TXT,
					    VD_DET_ROT_FLD   );

		  if ( me->tmpList[VD_Obj_arrId].objid != NULL_OBJID )
		  {
/*
			sts =
			vd_$bulk_display(count	= 1,
					dpmode	= GRbe,
					grids	= &me->tmpList[VD_Obj_arrId],
					theEnv	= &me->ModuleInfo );
			sts =
			vd_$bulk_delete(count	= 1,
					grids	= &me->tmpList[VD_Obj_arrId],
					theEnv	= &me->ModuleInfo );
*/
  me->m_OldArrId = me->tmpList[VD_Obj_arrId];
  me->m_UpdateArr = TRUE;
  me->tmpList[VD_Obj_arrId].objid = NULL_OBJID;
		   }
		}

		switch( row ){
		case 1:

		  /*| state PLANE_DEFINE */
		  me->fd_new.toggle &= ~VD_DET_AXIS_FLAG;
		  me->fd_new.toggle &= ~VD_DET_ALT_FLAG;

		  VDdet_vec_COPY( me->fd_old.x_vec, me->fd_new.x_vec );
		  VDdet_vec_COPY( me->fd_old.y_vec, me->fd_new.y_vec );
		  VDdet_vec_COPY( me->fd_old.z_vec, me->fd_new.z_vec );

		  VDdet_set_VALUES3( fm_ptr, VD_DET_X_AXIS, me->fd_new.x_vec );
		  VDdet_set_VALUES3( fm_ptr, VD_DET_Y_AXIS, me->fd_new.y_vec );
		  VDdet_set_VALUES3( fm_ptr, VD_DET_Z_AXIS, me->fd_new.z_vec );

		  VDdet_set_MODE_OFF( fm_ptr, VD_DET_X_AXIS, 3 );
		  VDdet_set_MODE_OFF( fm_ptr, VD_DET_Y_AXIS, 3 );

		  break;

		case 2:
		  /*| state ALTERNATE */
		  me->fd_new.toggle &= ~VD_DET_AXIS_FLAG;
		  me->fd_new.toggle |= VD_DET_ALT_FLAG;

		  {
		    char	view[11], viewchar = VD_NODIR ;
		    long	msg;
		    double	rng[6], theta;
		    IGRint	flag, pos;

		    SMVA_erase   ( fm_ptr, 6, VD_DET_X_AXIS,
					      VD_DET_Y_AXIS,
					      VD_DET_Z_AXIS,
					      VD_DET_X_AXIS_TXT,
				       	      VD_DET_Y_AXIS_TXT,
					      VD_DET_Z_AXIS_TXT );

		    SMVA_display ( fm_ptr, 4, VD_DET_VIEW_TXT,
					      VD_DET_VIEW_FLD,
					      VD_DET_ROT_TXT,
					      VD_DET_ROT_FLD   );

		    VDdet_get_ALPHA ( fm_ptr, VD_DET_VIEW_FLD, view );
		    VDdet_get_VIEWCHAR( view, &viewchar );
		    VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MIN,rng);
		    VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MAX,&rng[3]);

		    if ( me->tmpList[VD_Obj_boxId].objid != NULL_OBJID )
		    {
			for ( i=0; i<6; i++ )
			   VDdet_conv_ext_int ( rng[i], &rng[i], me->VDcur_os );

  me->m_OldArrId = me->tmpList[VD_Obj_arrId];
  me->m_UpdateArr = TRUE;
  me->tmpList[VD_Obj_arrId].objid = NULL_OBJID;

			status = VDdisp_view_arrow (
					&msg,
					&me->tmpList[VD_Obj_arrId],
					&me->ModuleInfo,
					rng, &rng[3], viewchar );
		    }
		    me->fd_new.viewchar = viewchar;

		    FIfld_get_value(	fm_ptr, VD_DET_ROT_FLD, 0, 0,
					&theta, &flag, &pos );

		    status =
		    _VD_SEND_MY( VDCmdDetail.VDdet_set_view_mat(
						&msg,
						&me->fd_new,
						viewchar,
						theta ));

#ifdef VD_CHANGE_ZDEPTHS
		   status = 
		   _VD_SEND_MY( VDCmdDetail.VDdet_set_zdepths( &sts ));
#endif
		  }
		  break;

		case 3:

		  /*| state USER_DEFINED */
		  me->fd_new.toggle &= ~VD_DET_ALT_FLAG;
		  me->fd_new.toggle |= VD_DET_AXIS_FLAG;

		  VDdet_set_VALUES3( fm_ptr, VD_DET_X_AXIS, me->fd_new.x_vec );
		  VDdet_set_VALUES3( fm_ptr, VD_DET_Y_AXIS, me->fd_new.y_vec );
		  VDdet_set_VALUES3( fm_ptr, VD_DET_Z_AXIS, me->fd_new.z_vec );

		  VDdet_set_MODE_ON( fm_ptr, VD_DET_X_AXIS, 3);
		  VDdet_set_MODE_ON( fm_ptr, VD_DET_Y_AXIS, 3);

		  me->fd_new.flag = TRUE;

		default:

		  /*| state file USER_DEFINED */
		  me->fd_new.toggle |= VD_DET_AXIS_FLAG;

		  if( VD_ViewOrientationFile(	VD_DET_NAME_SEARCH,
						NULL, 
						NULL,
						my_text,
						me->fd_new.x_vec, 
						me->fd_new.y_vec ) ){
		  
		    strcpy( me->fd_new.orient_name, my_text );
		    VDdet_vec_COPY( me->fd_old.z_vec, me->fd_new.z_vec );
		    VDdet_set_VALUES3( fm_ptr, VD_DET_X_AXIS, me->fd_new.x_vec );
		    VDdet_set_VALUES3( fm_ptr, VD_DET_Y_AXIS, me->fd_new.y_vec );
		    VDdet_set_VALUES3( fm_ptr, VD_DET_Z_AXIS, me->fd_new.z_vec );
		  	
		    VDdet_set_MODE_ON( fm_ptr, VD_DET_X_AXIS, 3 );
		    VDdet_set_MODE_ON( fm_ptr, VD_DET_Y_AXIS, 3 );

		    me->fd_new.flag = TRUE;

		    /*
		     * the method form_notification is recalled to determine
		     * if the chosen option is allowed for the selected plane/
		     * drame object.
		     * For gadget_label is chosen FI_MSG_FIELD
		     */
		    status =
		    _VD_SEND_MY( VDCmdDetail.form_notification(
							form_label,
							FI_MSG_FIELD,
							1.0, fm_ptr ));
		    as$status( action = RET_STATUS );
		  }
		  else{
		    VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, "Select invalid option" );
		  }
		}
	break;

	case VD_DET_X_AXIS:
		me->fd_new.flag = TRUE;
	break;

	case VD_DET_Y_AXIS:
		me->fd_new.flag = TRUE;
	break;

	case VD_DET_VOLUME_TOGGLE:

		VD_ViewVolumeFile(	VD_DET_NAME_COUNT, NULL,
					&row_max, NULL, NULL, NULL, NULL );
		flag = FALSE;
		my_text[0] = '\0';
		row_max += VD_DET_VOLUME_LIST_MIN;
		row = 0;
		do{
		  FIfld_get_list_default_text( fm_ptr,gadget_label,row,0,
					256, my_text, &flag);
		  FIfld_get_list_select( fm_ptr,gadget_label,row,0,&flag);
		  ++row;
		}while( flag != TRUE && row <= row_max );

		if( row == 0 || row > row_max ){
		  /* error in select options */
		  break;
		}

		FIfld_set_list_select( fm_ptr,gadget_label,(row-1),0,FALSE);

		/* set flag */
		me->fd_new.volume_name[0] = '\0';
		me->fd_new.vol_toggle = 0;
		switch(row){

		case 1:
		  /*| VD_DET_EXTENDED */
		  me->fd_new.vol_toggle = VD_DET_EXTENDED;

		  VDdet_vec_COPY( &(me->fd_old.vw_volume[0]), &(me->fd_new.vw_volume[0]));
		  VDdet_vec_COPY( &(me->fd_old.vw_volume[3]), &(me->fd_new.vw_volume[3]));

		  for(i=0;i<6;i++)
		    VDdet_conv_int_ext( me->fd_new.vw_volume[i],
					&(ext6[i]), me->VDcur_os);

		  VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MIN,&(ext6[0]));
		  VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MAX,&(ext6[3]));

		  VDdet_set_MODE_OFF(fm_ptr,VD_DET_VOL_MIN, 3 );
		  VDdet_set_MODE_OFF(fm_ptr,VD_DET_VOL_MAX, 3 );

		  if( me->mytype == VD_drawview ){
		    VDdet_vec_COPY( me->fd_old.origin, me->fd_new.origin );
		    for(i=0;i<3;i++)
		      VDdet_conv_int_ext( me->fd_new.origin[i],
					  &(ext6[i]), me->VDcur_os ); 
		    VDdet_set_VALUES3(fm_ptr,VD_DET_ORIGIN,   ext6 );
		    VDdet_set_MODE_OFF(fm_ptr,VD_DET_ORIGIN,  3 );
		  }

		  break;

		case 2:
		  /*| VD_DET_DEP_EXT */
		  me->fd_new.vol_toggle = VD_DET_DEP_EXT;
		  /*
		   * Calculate the dependency extents only when reqiured.
		   * Therfor the function is called locally in the form.
		   */
		  VDget_dep_extents(	&sts,
					&me->VDdet_obj_env.obj_id,
					me->VDdet_obj_env.mod_env.md_env.matrix,
					me->fd_new.dep_volume );
		  
		  for(i=0;i<3;i++)
		    me->fd_new.origin[i] = ( me->fd_new.dep_volume[3+i] -
					me->fd_new.dep_volume[i] ) * 0.5;

		  for(i=0;i<6;i++)
		    VDdet_conv_int_ext( me->fd_new.dep_volume[i],
					&(ext6[i]), me->VDcur_os );
		  VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));
		  VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

		  VDdet_set_MODE_OFF(fm_ptr,VD_DET_VOL_MIN, 3 );
		  VDdet_set_MODE_OFF(fm_ptr,VD_DET_VOL_MAX, 3 );

		  if( me->mytype == VD_drawview ){
		    for(i=0;i<3;i++)
		      VDdet_conv_int_ext( me->fd_new.origin[i],
					  &(ext6[i]), me->VDcur_os ); 
		    VDdet_set_VALUES3(fm_ptr,VD_DET_ORIGIN,   ext6 );
		    VDdet_set_MODE_OFF(fm_ptr,VD_DET_ORIGIN,  3 );
		  }
		  break;

		case 3:
		  /* locate objects and extend the range */
		  me->fd_new.vol_toggle = VD_DET_OBJ_RNG;
		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);
		  if ( me->mytype == VD_drawview )
			VDdet_set_MODE_ON(fm_ptr,VD_DET_ORIGIN,  3 );
		  _put_response ( resp = VD_RANGE_BY_OBJECTS );
		  break;

		case 4:
		  /* locate objects and extend the range */
		  me->fd_new.vol_toggle = VD_DET_ADD_RNG;
		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);
		  if ( me->mytype == VD_drawview )
			VDdet_set_MODE_ON(fm_ptr,VD_DET_ORIGIN,  3 );
		  _put_response ( resp = VD_EXTEND_RANGE );
		  break;

		case 5:
		  /* locate objects and extend the range */
		  me->fd_new.vol_toggle = VD_DET_PTS_RNG;
		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);
		  if ( me->mytype == VD_drawview )
			VDdet_set_MODE_ON(fm_ptr,VD_DET_ORIGIN,  3 );
		  _put_response ( resp = VD_RANGE_BY_POINTS );
		  break;

		case 6:
		  /*| VD_DET_USER_FLAG */
		  me->fd_new.vol_toggle = VD_DET_USER_FLAG;

		  VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MIN,&(ext6[0]));
		  VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MAX,&(ext6[3]));
		  for(i=0;i<6;i++)
		    VDdet_conv_ext_int( ext6[i], &(me->fd_new.vw_volume[i]),
					me->VDcur_os );

		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3);
		  VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3);

		  if( me->mytype == VD_drawview ){
		    VDdet_get_VALUES3(fm_ptr,VD_DET_ORIGIN, ext6 );
		    for(i=0;i<3;i++)
		      VDdet_conv_ext_int( ext6[i], &(me->fd_new.origin[i]),
					me->VDcur_os );
		    VDdet_set_MODE_ON(fm_ptr, VD_DET_ORIGIN,  3);
		  }

		  break;

		default:

		  /*| state file USER_DEFINED */
		  me->fd_new.vol_toggle = VD_DET_USER_FLAG;
		  if( VD_ViewVolumeFile(VD_DET_NAME_SEARCH,
					NULL, NULL,
					my_text, 
					me->fd_new.vw_volume, 
					&(me->fd_new.vw_volume[3]), 
					me->fd_new.origin ) ){

		    strcpy( me->fd_new.volume_name, my_text );
		    VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MIN,me->fd_new.vw_volume );
		    VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MAX,&(me->fd_new.vw_volume[3]));

		    VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MIN, 3 );
		    VDdet_set_MODE_ON(fm_ptr, VD_DET_VOL_MAX, 3 );

		    if( me->mytype == VD_drawview ){
		      VDdet_set_VALUES3(fm_ptr, VD_DET_ORIGIN, me->fd_new.origin);
		      VDdet_set_MODE_ON(fm_ptr, VD_DET_ORIGIN, 3 );
		    }
		  	
	 	  } 
		  else{
		    VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, "Select invalid option" );
		  }
		}

		if ( row != 3 && row != 4 && row != 5 &&
		     me->mytype == VD_drawview )
		{
		   status = _VD_SEND_MY( VDCmdDetail.disp_view_vol ( &sts ));
		   VDS_ERR_RPT( "VDCmdDetail.disp_view_vol", status, sts,
				VD_VERBOSE );
 		}

		break;

	case VD_DET_VOL_MIN:
		VDdet_get_VALUES3( fm_ptr, gadget_label, values );
		for(i=0;i<3;i++)
		  VDdet_conv_ext_int( values[i], &(me->fd_new.vw_volume[i]),
				      me->VDcur_os );
		for(i=0;i<3;i++)
		  VDdet_conv_int_ext( me->fd_new.vw_volume[i], &(ext6[i]),
				      me->VDcur_os );
		VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MIN, &(ext6[0]));

		if ( me->mytype == VD_drawview )
		{
		   status = _VD_SEND_MY( VDCmdDetail.disp_view_vol ( &sts ));
		   VDS_ERR_RPT( "VDCmdDetail.disp_view_vol", status, sts,
				VD_VERBOSE );

#ifdef VD_CHANGE_ZDEPTHS
		   status = 
		   _VD_SEND_MY( VDCmdDetail.VDdet_set_zdepths( &sts ));
#endif
		}
		break;

	case VD_DET_VOL_MAX:
		VDdet_get_VALUES3( fm_ptr, gadget_label, values );
		for(i=0;i<3;i++)
		  VDdet_conv_ext_int( values[i], &(me->fd_new.vw_volume[3+i]),
				      me->VDcur_os );
		for(i=0;i<3;i++)
		  VDdet_conv_int_ext( me->fd_new.vw_volume[3+i], &(ext6[3+i]),
				      me->VDcur_os );
		VDdet_set_VALUES3(fm_ptr, VD_DET_VOL_MAX, &(ext6[3]));

		if ( me->mytype == VD_drawview )
		{
		   status = _VD_SEND_MY( VDCmdDetail.disp_view_vol ( &sts ));
		   VDS_ERR_RPT( "VDCmdDetail.disp_view_vol", status, sts,
				VD_VERBOSE );

#ifdef VD_CHANGE_ZDEPTHS
		   status =
		   _VD_SEND_MY( VDCmdDetail.VDdet_set_zdepths( &sts ));
#endif
		}
		break;

	case VD_DET_REF_FLD:
		/*
		 * In case more than one reference object space is attached
		 * to the current object space, the gadget VD_DET_REFERENCE is
		 * is displayed and give the possibility to select another
		 * reference object space.
		 * The List contains all directly and indirectly connected 
		 * reference object spaces.
		 */

		FIg_get_text ( fm_ptr, gadget_label, filename );
		for(i=0; i<me->nbRefOs; i++)
		{
		  FIfld_get_list_text( fm_ptr, gadget_label, i, 0,
				       15, name, &flag);
		  if ( !strcmp( filename, name ) ) break;
		}

		if ( i < me->nbRefOs )
		{
		   VDget_filename_from_os ( me->refOsList[i], me->model );
		   me->VDref_os = me->refOsList[i];
		}
		else
		{
		   VDget_filename_from_os ( me->VDcur_os, me->model );
		   me->VDref_os = me->VDcur_os;
		}
/*		
		flag = FALSE;
		my_text[0] = '\0';
		row = 0;
		do{
		  FIfld_get_list_default_text( fm_ptr,gadget_label,row,0,
					256, my_text, &flag);
		  FIfld_get_list_select( fm_ptr,gadget_label,row,0,&flag);
		  ++row;
		}while( flag != TRUE && row <= me->VDdet_space_cnt );

		if( row == 0 || row > me->VDdet_space_cnt ){
		  / * error in select options * /
		  VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, "Select invalid option" );
		  break;
		}
		
		for(i=0;i< me->VDdet_space_cnt; i++ ){
		  if( strcmp( me->VDdet_refer[i].ref_name, my_text ) == 0 ){
		    / * set new reference object space * /
		    me->VDref_os = me->VDdet_refer[i].osnum;
		    strcpy( me->model, me->VDdet_refer[i].ref_name );
		  }
		}
*/
	break;

	case VD_DET_LAYERS:
		/* 
		 * The users may modify the active layers of the drawing view
		 * In case of syntax error in the text string, all layers
		 * will be activated as default option.
		 */
		VDdet_get_ALPHA( fm_ptr, gadget_label, me->fd_new.layer_str );
		len = strlen( me->fd_new.layer_str );
		if( len == 0 || (strcmp( me->fd_new.layer_str, "*" ) == 0)){
		  /* reset the default layer string */
		  strcpy( me->fd_new.layer_str, VD_DET_DEF_LAYER );
		  VDdet_set_ALPHA( fm_ptr, gadget_label, me->fd_new.layer_str );
		  VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, "Set default all layers" );
		  break;
		}

		status = VDconvert_lev_string(	&sts,
						me->fd_new.layer_str,
						me->VDdet_levels );
		if( ! status || !(sts&1) ){
		  strcpy( me->fd_new.layer_str, VD_DET_DEF_LAYER );
		  ex$message( msgnumb = GR_E_InvLy, buff = my_text );
		  VDdet_set_ALPHA( fm_ptr, FI_MSG_FIELD, my_text );
		  VDdet_set_ALPHA( fm_ptr, gadget_label, me->fd_new.layer_str );
		}

	break;

	case VD_DET_OFFSET_TOGGLE:

		if( VDdet_get_STATE( fm_ptr, gadget_label )){

		  /* state USER_DEFINED */
		  me->fd_new.offset_toggle = 1;
		  {
		  IGRint nret, sizbuf = sizeof( IGRdouble );
		  gr$get_chord_height_tolerance(msg    = &rc,
						sizbuf = &sizbuf,
						buffer = &(values[0]),
						nret   = &nret );
		  }
		  /* test the offset values in intern units */
		  if( fabs( me->fd_new.offset_value ) < (2 * values[0]) ){
		    me->fd_new.offset_value = 2 * values[0];
		  }
		  /* conversion to extern units for form */
                  VDdet_conv_int_ext( me->fd_new.offset_value,
                                      &(values[0]), me->VDcur_os );

		  FIg_set_value( fm_ptr, VD_DET_OFFSET_VALUE, values[0] );
		  FIg_display( fm_ptr, VD_DET_OFFSET_VALUE );
		}
		else{
		  /* state PLANE_DEFINE */
		  me->fd_new.offset_toggle = 0;
		  FIg_erase( fm_ptr, VD_DET_OFFSET_VALUE );
		}
	break;

	case VD_DET_OFFSET_VALUE:

		{
		  IGRint nret, sizbuf = sizeof( IGRdouble );
		  gr$get_chord_height_tolerance(msg    = &rc,
						sizbuf = &sizbuf,
						buffer = &(values[0]),
						nret   = &nret );
		}

		FIg_get_value( fm_ptr, gadget_label, &(values[1]) );

		/* convert to intern units to test with system cht offset */
                VDdet_conv_ext_int( values[1], &(values[1]), me->VDcur_os );

		me->fd_new.offset_value =
		  (fabs(values[1])<(2*values[0])) ? (2*values[0]) : values[1];

		/* conversion to extern units for form */
                VDdet_conv_int_ext( me->fd_new.offset_value,
                                    &(values[0]), me->VDcur_os );

		FIg_set_value( fm_ptr, gadget_label, values[0] );
		  
	break;

	case VD_DET_WIN_NAME_DESC:

		VDdet_get_ALPHA( fm_ptr, gadget_label, my_text );
		if( my_text[0] == '\0' )
		  strcpy( my_text, VD_DET_WINDOW_NAME );

		sts = VDdet_gen_window_name( &rc, me->VDcur_os, my_text );
		if( ! sts ){
		  printf(" form_not : fct VDdet_gen_window_name failed\n");
		  break;
		}

		strcpy( me->VDdet_win_name, my_text );
		VDdet_set_ALPHA( fm_ptr, gadget_label, me->VDdet_win_name );

	break;

	case VD_DET_VIEW_FLD :
	case VD_DET_ROT_FLD :
	{
	    char		view[11], viewchar = VD_NODIR ;
	    long		msg;
	    double		rng[6], theta;
	    IGRint		flag, pos;

	    VDdet_get_ALPHA ( fm_ptr, VD_DET_VIEW_FLD, view );
	    VDdet_get_VIEWCHAR( view, &viewchar );
	    VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MIN,rng);
	    VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MAX,&rng[3]);

	    if ( me->tmpList[VD_Obj_arrId].objid != NULL_OBJID )
	    {
		for ( i=0; i<6; i++ )
		   VDdet_conv_ext_int ( rng[i], &rng[i], me->VDcur_os );

  me->m_OldArrId = me->tmpList[VD_Obj_arrId];
  me->m_UpdateArr = TRUE;
  me->tmpList[VD_Obj_arrId].objid = NULL_OBJID;

		status = VDdisp_view_arrow (
				&msg,
				&me->tmpList[VD_Obj_arrId], &me->ModuleInfo,
				rng, &rng[3], viewchar );
	    }
	    me->fd_new.viewchar = viewchar;

	    FIfld_get_value(	fm_ptr, VD_DET_ROT_FLD, 0, 0,
				&theta, &flag, &pos );

	    status = 
	    _VD_SEND_MY( VDCmdDetail.VDdet_set_view_mat(
						&msg,
						&me->fd_new,
						viewchar,
						theta ));
#ifdef VD_CHANGE_ZDEPTHS
	   status =
	   _VD_SEND_MY( VDCmdDetail.VDdet_set_zdepths( &sts ));
#endif
	}
	break;

	default:
		/*" Invalid gadget_label = %d\n", gadget_label*/
		goto quit ;
	}

        if( me->mytype != VD_viewplane ){
                _put_response( resp = VD_DET_FORM_ACCEPT );
        }
        else{
          if(( gadget_label == FI_ACCEPT )||( gadget_label == FI_EXECUTE )){
            /* have accept/execute statement */
            _put_response( resp = VD_DET_FORM_ACCEPT );
          }
        }

	goto quit ;
}


/* ********************************************************** */
action delete
/* ********************************************************** */
/*.delete*/
{
/*
 * This method removes the following temporary objects 
 *	VDdet_gragad,
 *	VDdet_win_id
 */
long	sts;

  me->VDdet_obj_env.obj_id.objid = NULL_OBJID;

  if( me->mytype != VD_viewplane ){

    if( me->VDdet_gragad.objid != NULL_OBJID ){
      status =
      om$send(msg      = message Root.delete ( 1 ),
	    targetid = me->VDdet_gragad.objid,
	    targetos = me->VDdet_gragad.osnum,
	    senderid = NULL_OBJID );
      as$status( action = RET_STATUS );
      me->VDdet_gragad.objid = NULL_OBJID;
    }

    if( me->VDdet_win_id.objid != NULL_OBJID ){
      status =
      om$send(msg      = message Root.delete ( 1 ),
  	    targetid = me->VDdet_win_id.objid,
	    targetos = me->VDdet_win_id.osnum,
	    senderid = NULL_OBJID );
      as$status( action = RET_STATUS );
      me->VDdet_win_id.objid = NULL_OBJID;
    }

    if( me->VDdet_refer ){
      om$dealloc( ptr = me->VDdet_refer );
      me->VDdet_refer = NULL;
    }

    if( me->VDdet_space ){
      om$dealloc( ptr = me->VDdet_space );
      me->VDdet_space = NULL;
    }

    me->VDdet_refer_cnt = 0;
    me->VDdet_space_cnt = 0;
  }

  /* delete status form */
  if(  me->status_display_form_ptr ){
    if( me->status_display_form_ptr != (char *)1 ){

      FIf_get_location( me->status_display_form_ptr,
				&VDdet_x_memo, &VDdet_y_memo );
      /*" location : %d, %d\n", VDdet_x_memo, VDdet_y_memo */
      me->form_requested = 0;
    }
  }

  /*
   * look id GRID_ON and GRID_LOCK are still active 
   */
  status =
  _VD_SEND_MY( VDCmdDetail.reset_grid_flags( &sts ));
  as$status( action = RET_STATUS );

  /* remove the objects hilited */
  status =
  _VD_SEND_MY( VDCmdDetail.VDdet_erase_hilite( &sts ));
  as$status( action = RET_STATUS );

  /* The message delete controls the status_display_form_ptr */ 
  status =
  _VD_SEND_WRT_M( my_id, CEO.delete(f_defer_flag));
  as$status(action = RET_STATUS);


  goto quit ;
}

/* ********************************************************** */
action sleep( int pos )					extern
action wakeup( int pos )				extern
action status_disp( )					extern
action dynamics( int dynamics; int * sts )		extern

action VDfill_in_form( long * sts)			extern
action get_reference_info( long * sts )			extern
action get_ref_component_id( long * sts )		extern
action get_component_id( long * sts )			extern
action get_component_name( long * sts )			extern
action VDdet_init( long * sts )				extern
action get_object_environment( long * sts )		extern
action object_disconnect( long * sts )			extern
action clear_objects( long * sts )			extern
action VDdet_display_located( long * sts )		extern
action VDdet_erase_hilite( long * sts )			extern
action create_drawview( long * sts )			extern
action VDadd_view_info( long * sts )			extern
action set_grid_flags_off( long * sts )			extern
action reset_grid_flags( long * sts )			extern
action VDdet_del_tmp_obj ( long *sts )			extern
action VDdet_init_noplane()				extern

action VDdet_set_view_mat(
 long				*msg;
 struct VDdet_formdata		*fd_new;
 char				viewchar;
 double				theta     )		extern

action get_range_from_objid				extern
action get_range_from_objname				extern
action set_range					extern
action extend_range					extern

action get_coord_of_pt( long *msg; int flag )		extern

action erase_sts_disp					extern
action disp_sts_disp					extern
action disp_view_vol					extern
action VDdet_init_toggles				extern
action VDdet_set_zdepths				extern

/* ********************************************************** */


