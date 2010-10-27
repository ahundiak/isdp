/* $Id: VDFitObj.I,v 1.2 2001/01/10 18:12:24 art Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil/ VDFitObj.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDFitObj.I,v $
 *	Revision 1.2  2001/01/10 18:12:24  art
 *	sp merge
 *	
# Revision 1.2  2000/07/07  21:40:20  pinnacle
# Replaced: vds/vdutil/VDFitObj.I for:  by rchennup for Service Pack
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
# Revision 1.1  1995/07/24  15:46:40  pinnacle
# Created: vdutil/VDFitObj.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *       07/25/95         HV             Moved from smfit/cmd
 *
 * -------------------------------------------------------------------*/

/*
 *
 *	Filename:	VDFitObj.C
 *	Author:		Ad Zuurhout
 *
 *	Date:		Jan 1993
 *	Type:		Macro Fucntion;
 *	Process by:	vd$vw_fit_object();	(vdsmacros.h)
 *
 *	Description:
 *
 *	Having a view (IGEgragad) and a object, this function will
 *	fit the view to the selected object, depending on the active 
 *	view representation (top,right,iso) of the view. 
 *	
 *	Both Parallel Projection and Perspective Projection are used.
 *
 *	History:
 *	Jan	1993	Creation date.
 *	Mrs	1993	Add an optical viewing scale factor to fit.
 *	July	2000	Added VDvw_fit_many_objects() function.
 *
 */

class implementation Root;

/************************************************************************/
/*	IMPLEMENTATION FUNCTION						*/
/************************************************************************/

#include <string.h>
#include <stdio.h>
#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"

#include "grdpb.h"
#include "grdpbdef.h"
#include "dperr.h"
#include "grdpbmacros.h"
#include "grmessage.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "go.h"
#include "growner.h"
#include "msdef.h"
#include "msmacros.h"
#include "dpfile.h"

#include "asbox.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#include "dpcodef.h"		/* codpb_get_persp_flags */
#include "dpcomacros.h"

#include "AS_status.h"

#define	BORDER_PERC	0.05

from	GRgraphics	import GRgetrang;
from	IGEgragad	import DPcal, DPset;
from	IGEdisplay	import DPupdate;
from	NDmacro		import ACreturn_foot;

extern	double	fabs();
extern	int	DPalignper();
extern	int	DPfitpersp();
extern	int	DPgetrng();
extern	int	DPsetrng();


/************************************************************************/
/*	FUNCTION	VDvw_fit_object					*/
/************************************************************************/

IGRint	VDvw_fit_object( object, factor, md_env, ggid, num_ggid )

struct	GRid		*object;	/* object to fit		*/
IGRdouble		factor;		/* fit multiplication factor	*/
struct	GRmd_env	*md_env;	/* modul environment		*/
struct	GRid		*ggid;		/* list  view gragad to update	*/
IGRint			num_ggid;	/* number view gragad to update	*/
{
IGRint		status = OM_S_SUCCESS;
IGRint		var, rc;
IGRint		size;
IGRshort	id, i;
IGRushort	pflags;
IGRlong		msg, one;
IGRlong		num_bytes, error_var;
IGRboolean	world;
IGRdouble	v_range, delta, rng_delta[3];
GRrange		comp_range, new_range;
GRclassid	classid;

/* view gragad variables */
IGRint		type_gragad;
IGRchar		str_name[20];

IGRint		gg_num, gg_flags;
IGRdouble	gg_near, gg_far, gg_new_z;
IGRdouble	gg_vw_angle, gg_act_z;
IGRdouble	gg_wld_to_vw[16], gg_ex_mtx[16];
IGRdouble	gg_vwport_to_wld[16];
IGRdouble	gg_vrp[3], gg_coi[3]; 
IGRdouble	gg_vpn[3], gg_vup[3], gg_eye_pt[3];
IGRdouble	gg_clip_range[6];
IGRdouble	gg_act_z_screen;

struct	GRid		*gg_list, gg_array[MAX_WINDOW];
struct	DPrange_check	gg_range_chk;
struct	var_list	var_list[10];
struct	GRmd_env	loc_env;

  /*
   * test if object given
   */
  if( ! object ) {
    /*
     * no object given.
     */
    status = SrchFlt;
    goto wrapup;
  }

  /*
   * determine if the module environment is given.
   */
  if( md_env == NULL ){
    size = sizeof ( struct GRmd_env ) ;
    status =
    gr$get_module_env(	msg	= & rc,
    			sizbuf	= & size,
			buffer	= & loc_env,
			nret	= & size );
    as$status();
  }
  else { loc_env = *md_env; }

  /*
   * see if view gragads are defined.
   */
  gg_num  = num_ggid ;
  gg_list = ggid ;
  if( ! gg_list ) {
    /*
     * take as default all active view gragads.
     */
    gg_num = 0 ;
    gg_list = gg_array ;
    strcpy(str_name, "*");
    type_gragad = ALL_GG_CLASSES | GG_WIN_ON ;

    status = 
    dp$get_gragad_id(	msg         = &msg,
		name        = str_name,
		array_size  = MAX_WINDOW,
		numberofids = &gg_num, 
		found_GRids = gg_list,
		type_gragad = type_gragad );
    /*
     * Display appr. error messages  & set the "action return code"
     */
    if ( gg_num == 0 ) {
      ex$message ( msgnumb = GR_E_WinNotFnd);
      status = SrchFlt;
      goto wrapup;
    }
  }

  /*
   * calculate the range of the comparment.
   */
  comp_range[0] = comp_range[1] = comp_range[2] =  1.e+23;
  comp_range[3] = comp_range[4] = comp_range[5] = -1.e+23;
  world = TRUE;

  /*
   * get range could also be done in a the plane CS To be evaluated
   */
  status =
  om$send(msg = message GRgraphics.GRgetrang(
			&msg,
			&loc_env.md_env.matrix_type,
			loc_env.md_env.matrix,
			&world,
			comp_range ),
  targetid = object->objid,
  targetos = object->osnum,
  senderid = NULL_OBJID );
  as$status( sts = (status & msg),action = RET_STATUS);

  for ( id=0; id<gg_num; id++ ) {

    /*
     * test if the gragad is not of the class VDggxyGrid
     */
     status = om$get_classid(	osnum     = gg_list[id].osnum,
				objid     = gg_list[id].objid,
				p_classid = &classid );

      if( ! (1&status) ) {
        printf(" vw_fit_object: om$get_classid for SMFitCmd failed\n");
        continue ;
      }
    
     if( om$is_ancestry_valid(
			subclassid     = classid,
			superclassname = "VDggxyGrid" ) == OM_S_SUCCESS ){

        /*
         * ex$message(	field   = STATUS_FIELD,
	 *		in_buff = " Not a principal view " );
	 */
        continue ;
      }

    /*
     * get the world to view matrix of gadget
     */
    var = 0 ;
    var_list[var].var               = GRAGAD_FLAGS;
    var_list[var].var_ptr           = (IGRchar *) &gg_flags;
    var_list[var].num_bytes         = sizeof (IGRint) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = RANGE_CHK;
    var_list[var].var_ptr           = (IGRchar *) &gg_range_chk;
    var_list[var].num_bytes         = sizeof (struct DPrange_check) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;
 
    var_list[var].var               = END_PARAM ;

    /*
     * get the flag of the gragad
     */
    status =
    dp$inq_set_gragad (	msg         = &msg,
		inq0_set1   = 0,
		calc_info   = 0,
		update      = 0,        /* or 1 KLUDGE */
		osnum        = gg_list[id].osnum,
		gragad_objid = gg_list[id].objid,
		which_error = &error_var,
		var_list    = var_list ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
      continue ;
    }

    /*
     * look in what type of view we are working to get the
     * world to view matrix
     */
    if( gg_flags & IS_PERSP ) {

      /*
       * get  vpn   : view plane normal			( IGRdouble * 3 )
       *      vup   : view up vector			( IGRdouble * 3 )
       *      eye_pt: eye point for perspective		( IGRdouble * 3 )
       *      vrp   : view reference point		( IGRdouble * 3 )
       *      act_z : active z in viewing c.s.		( IGRdouble     )
       *      coi   : center of interest		( IGRdouble * 3 )
       *      vw_ang: view angle			( IGRdouble	)
       */
        var = 0;
	var_list[var].var               = VPN;
	var_list[var].var_ptr           = (IGRchar *) gg_vpn;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = VUP;
	var_list[var].var_ptr           = (IGRchar *) gg_vup;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = EYE_PT;
	var_list[var].var_ptr           = (IGRchar *) gg_eye_pt;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = VRP;
	var_list[var].var_ptr           = (IGRchar *) gg_vrp;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = ACT_Z;
	var_list[var].var_ptr           = (IGRchar *) &gg_act_z;
	var_list[var].num_bytes         = sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = COI;
	var_list[var].var_ptr           = (IGRchar *) gg_coi;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = VIEW_ANGLE;
	var_list[var].var_ptr           = (IGRchar *) &gg_vw_angle;
	var_list[var].num_bytes         = sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = END_PARAM;

	status =
	dp$inq_set_gragad (	msg         = &msg,
				inq0_set1   = 0,
				calc_info   = 0,
				update      = 0,        /* or 1 KLUDGE */
				osnum        = gg_list[id].osnum,
				gragad_objid = gg_list[id].objid,
				which_error = &error_var,
				var_list    = var_list ) ;

	if( !( status & msg & 1 ) ) {
	  if( ! (status & 1) ) om$report_error( sts = status );
	  if( ! (   msg & 1) ) om$report_error( sts = msg );
	  continue ;
	}

	/*
	 * calculate the world to view volume
	 */
	DPalignper( &msg, DPLEFT_VIEW, gg_vpn, gg_vup, gg_eye_pt, gg_ex_mtx,
		    gg_wld_to_vw );
    }
    else {
	/*
	 * get the world to view volume directly from gragad
	 */
	var_list[0].var               = WLD_TO_VIEW;
	var_list[0].var_ptr           = (IGRchar *) gg_wld_to_vw;
	var_list[0].num_bytes         = 16 * sizeof (IGRdouble);
	var_list[0].bytes_returned    = &num_bytes;

	var_list[1].var               = END_PARAM;

	status =
	dp$inq_set_gragad (	msg         = &msg,
				inq0_set1   = 0,
				calc_info   = 0,
				update      = 0,        /* or 1 KLUDGE */
				osnum        = gg_list[id].osnum,
				gragad_objid = gg_list[id].objid,
				which_error = &error_var,
				var_list    = var_list ) ;

	if( !( status & msg & 1 ) ) {
	  if( ! (status & 1) ) om$report_error( sts = status );
	  if( ! (   msg & 1) ) om$report_error( sts = msg );
	  continue ;
	}
    } /* gg_flags */

    /*
     * give update message
     */
    ex$message( msgnumb = GR_I_FitProg );

    /*
     * See if compartment touch the design limits.
     */
    if( comp_range[0] == IGE_DESIGN_LIMITS_MAX ) {
      /*
       * compartment on bourder limits
       */
      continue;
    }

    /*
     * adjust view volume to correspond to calculated range.
     */
    if( ! DPsetrng( &msg, gg_wld_to_vw, &gg_range_chk )){
      /*
       * error in function DPgetrng
       */
      printf("\tError in DPgetrng in VDvw_fit_object \n");
      continue;
    }

    if( ! DPgetrng( &msg, gg_wld_to_vw, &gg_range_chk, 
					comp_range,new_range )){
      /*
       * error in function DPgetrng
       */
      printf("\tError in DPgetrng in VDvw_fit_object \n");
      continue;
    }

    /*
     * determine the border extents for the compartment.
     */
    for( i=0 ; i<3 ; i++ )
      rng_delta[i] = fabs( new_range[3+i] - new_range[i] ) ;

    delta = ( rng_delta[0] < rng_delta[1] ) ? rng_delta[1] : rng_delta[0] ;

    if( ! (gg_flags & AXIS_WLD_ALIGN) ) {
        if( delta < rng_delta[2] ) delta = rng_delta[2] ;
    }

    /*
     * get a fit viewing factor to the object range.
     */
    v_range = ( factor > 1.0 ) ? ((delta*(factor - 1.0))/2.0) : 0.0 ;

    /*
     * add the viewing factor and border perspective to the delta view volume.
     */
    delta *= BORDER_PERC ;

    for( i=0 ; i<3 ; i++ ) {
	new_range[  i] -= ( v_range + delta ) ;
	new_range[3+i] += ( v_range + delta ) ;
    }

    /*
     * fit the compartment in the view volume
     */
    var = 0 ;
    var_list[var].var               = VW_VOLUME;
    var_list[var].var_ptr           = (IGRchar *) new_range;
    var_list[var].num_bytes         = sizeof (GRrange) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    /* temporary endlist */
    var_list[var].var               = END_PARAM ;

    /*
     * see if we change the view volume for the perspective view.
     */
    if( gg_flags & IS_PERSP ) {

      dp$codpb_get_persp_flags( persp_flags = &pflags );
      if( pflags & PERSP_CHANGE_ANGLE ) {

          gg_vw_angle = DEF_VWANGLE;
 
          var_list[var].var               = VIEW_ANGLE ;
          var_list[var].var_ptr           = (IGRchar *) &gg_vw_angle;
          var_list[var].num_bytes         = sizeof (IGRdouble) ;
          var_list[var].bytes_returned    = &num_bytes;
          var ++ ;

          var_list[var].var               = END_PARAM ;
      }
      /*
       * calculate the fit perspective volume.
       */
      gg_near = new_range[2];
      gg_far  = new_range[5];
      DPfitpersp(	&msg,		/* return message	*/
			0,		/* input flag		*/
			new_range,	/* view volume		*/
			&gg_act_z,	/* active Zdepth value	*/
			gg_wld_to_vw,	/* world to view matrix	*/
			gg_coi,		/* old center interest	*/
			gg_vrp,		/* view reference point	*/
			gg_vw_angle,	/* view angle		*/
			gg_vrp,		/* NEW view ref point	*/
			gg_eye_pt,	/* MODIFY eye point	*/
			gg_coi,		/* NEW center interest	*/
			&gg_near,	/* NEW near location	*/
			&gg_far,	/* NEW far location	*/
			&gg_new_z );	/* new z depth value	*/
      new_range[2] = gg_near ;
      new_range[5] = gg_far ;

      var_list[var].var               = VRP ;
      var_list[var].var_ptr           = (IGRchar *) gg_vrp;
      var_list[var].num_bytes         = 3 * sizeof (IGRdouble) ;
      var_list[var].bytes_returned    = &num_bytes;
      var ++ ;

      var_list[var].var               = COI ;
      var_list[var].var_ptr           = (IGRchar *) gg_coi;
      var_list[var].num_bytes         = 3 * sizeof (IGRdouble) ;
      var_list[var].bytes_returned    = &num_bytes;
      var ++ ;

      var_list[var].var               = EYE_PT;
      var_list[var].var_ptr           = (IGRchar *) gg_eye_pt;
      var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
      var_list[var].bytes_returned    = &num_bytes;
      var ++ ;

      var_list[var].var               = END_PARAM ;
    }

    /*
     * set the volume of the gragad
     */
/**
    status =
    dp$inq_set_gragad (	msg          = &msg,
			inq0_set1    = 1,
			calc_info    = 0,
			update       = 0, 
			osnum        = gg_list[id].osnum,
			gragad_objid = gg_list[id].objid,
			which_error  = &error_var,
			var_list     = var_list ) ;
 **/
    status = 
    om$send(msg = message IGEgragad.DPset( &msg,
					   &error_var,
                                           var_list ),
            mode = OM_e_wrt_message,
	    senderid = NULL_OBJID,
            targetid = gg_list[id].objid,
	    targetos = gg_list[id].osnum ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * update the gragad
     */
    status =
    om$send(msg = message IGEgragad.DPcal( &msg ),
            targetid = gg_list[id].objid,
            targetos = gg_list[id].osnum,
            senderid = NULL_OBJID );

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * fit the compartment in the view volume
     */
    var = 0 ;
    var_list[var].var               = DIT_CLIP_RANGE;
    var_list[var].var_ptr           = (IGRchar *) gg_clip_range;
    var_list[var].num_bytes         = 6 * sizeof (IGRdouble) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = ACT_Z_SCREEN;
    var_list[var].var_ptr           = (IGRchar *) &gg_act_z_screen;
    var_list[var].num_bytes         = sizeof (IGRdouble) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = VIEWPORT_TO_WLD;
    var_list[var].var_ptr           = (IGRchar *) gg_vwport_to_wld;
    var_list[var].num_bytes         = 16 * sizeof (IGRdouble) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = END_PARAM ;

    /*
     * get the clip range, viewport and active zdepth of screen of the gragad
     */
    status =
    dp$inq_set_gragad (	msg          = &msg,
			inq0_set1    = 0,
			calc_info    = 0,
			update       = 0,        /* or 1 KLUDGE */
			osnum        = gg_list[id].osnum,
			gragad_objid = gg_list[id].objid,
			which_error  = &error_var,
			var_list     = var_list ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * create the new center of interest
     */
    gg_coi[0] = gg_clip_range[0] + ( gg_clip_range[3] / 2 );
    gg_coi[1] = gg_clip_range[1] + ( gg_clip_range[4] / 2 );
    gg_coi[2] = gg_act_z_screen ;

    one = 1;
    if( ! MAptsxform( &msg, &one, gg_vwport_to_wld, gg_coi, gg_coi ) ){
      /*
       * error in MAptsxform of gragad
       */
      continue;
    }

    /*
     * set the new center of interest of the gragad
     */
    var = 0 ;
    var_list[var].var               = COI;
    var_list[var].var_ptr           = (IGRchar *) gg_coi;
    var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = END_PARAM;
/**
    status =
    dp$inq_set_gragad (	msg          = &msg,
			inq0_set1    = 1,
			calc_info    = 0,
			update       = 0, 
			osnum        = gg_list[id].osnum,
			gragad_objid = gg_list[id].objid,
			which_error  = &error_var,
			var_list     = var_list ) ;
 **/

    status = 
    om$send(msg = message IGEgragad.DPset( &msg,
					   &error_var,
                                           var_list ),
            mode = OM_e_wrt_message,
	    senderid = NULL_OBJID,
            targetid = gg_list[id].objid,
	    targetos = gg_list[id].osnum ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * look if we update in delay.
     */
    if( ! ( gg_flags & DP_DELAY ) ) {

        IGRboolean upd_flag = FALSE ;

        status =
        om$send(msg = message IGEdisplay.DPupdate(&msg, NULL, &upd_flag ),
      	        targetid = gg_list[id].objid,
	        targetos = gg_list[id].osnum,
	        senderid = NULL_OBJID );

        if( !( status & msg & 1 ) ) {
          if( ! (status & 1) ) om$report_error( sts = status );
          if( ! (   msg & 1) ) om$report_error( sts = msg );
          continue ;
        }
    }
    else{
        ex$message( msgnumb = GR_I_DlyOn );
    }

    ex$message( msgnumb = EX_S_Clear );

  } /* close for for */

  wrapup:

  return( status );

}

/************************************************************************/
/*	FUNCTION	VDvw_fit_many_objects				*/
/************************************************************************/

IGRint	VDvw_fit_many_objects( 	count, objects, objenvs,
				factor, md_env, ggid, num_ggid )
IGRint			count;		/* Number of Objects		*/
struct  GRid            *objects;       /* object to fit                */
struct  GRobj_env       *objenvs;       /* Obj Envs                     */
IGRdouble		factor;		/* fit multiplication factor	*/
struct	GRmd_env	*md_env;	/* modul environment		*/
struct	GRid		*ggid;		/* list  view gragad to update	*/
IGRint			num_ggid;	/* number view gragad to update	*/
{
IGRint		status = OM_S_SUCCESS;
IGRint		var, rc;
IGRint		size;
IGRshort	id, i;
IGRushort	pflags;
IGRlong		msg, one;
IGRlong		num_bytes, error_var;
IGRboolean	world;
IGRdouble	v_range, delta, rng_delta[3];
GRrange		loc_range, comp_range, new_range;
GRclassid	classid;

/* view gragad variables */
IGRint		type_gragad;
IGRchar		str_name[20];

IGRint		gg_num, gg_flags, range_found;
IGRdouble	gg_near, gg_far, gg_new_z;
IGRdouble	gg_vw_angle, gg_act_z;
IGRdouble	gg_wld_to_vw[16], gg_ex_mtx[16];
IGRdouble	gg_vwport_to_wld[16];
IGRdouble	gg_vrp[3], gg_coi[3]; 
IGRdouble	gg_vpn[3], gg_vup[3], gg_eye_pt[3];
IGRdouble	gg_clip_range[6];
IGRdouble	gg_act_z_screen;

struct	GRid		tmp_obj, *gg_list, gg_array[MAX_WINDOW];
struct	DPrange_check	gg_range_chk;
struct	var_list	var_list[10];
struct	GRmd_env	loc_env;

  /*
   * test if object given
   */
  if( ! objects && !objenvs ) {
    /*
     * no object given.
     */
    status = SrchFlt;
    goto wrapup;
  }

  /*
   * determine if the module environment is given.
   */
  if( md_env == NULL ){
    size = sizeof ( struct GRmd_env ) ;
    status =
    gr$get_module_env(	msg	= & rc,
    			sizbuf	= & size,
			buffer	= & loc_env,
			nret	= & size );
    as$status();
  }
  else { loc_env = *md_env; }

  /*
   * see if view gragads are defined.
   */
  gg_num  = num_ggid ;
  gg_list = ggid ;
  if( ! gg_list ) {
    /*
     * take as default all active view gragads.
     */
    gg_num = 0 ;
    gg_list = gg_array ;
    strcpy(str_name, "*");
    type_gragad = ALL_GG_CLASSES | GG_WIN_ON ;

    status = 
    dp$get_gragad_id(	msg         = &msg,
		name        = str_name,
		array_size  = MAX_WINDOW,
		numberofids = &gg_num, 
		found_GRids = gg_list,
		type_gragad = type_gragad );
    /*
     * Display appr. error messages  & set the "action return code"
     */
    if ( gg_num == 0 ) {
      ex$message ( msgnumb = GR_E_WinNotFnd);
      status = SrchFlt;
      goto wrapup;
    }
  }

  /*
   * calculate the range of the comparment.
   */
  comp_range[0] = comp_range[1] = comp_range[2] =  1.e+23;
  comp_range[3] = comp_range[4] = comp_range[5] = -1.e+23;
  world = TRUE;

  range_found = 0;
  /*
   *  Accumulate the range for all input objects.
   */
  for ( id=0; id<count; id++ )
  {

    if( objects )	tmp_obj = objects[id] ;
    else		tmp_obj = objenvs[id].obj_id ;
    status =  om$send(msg = message GRgraphics.GRgetrang(
			&msg,
			&loc_env.md_env.matrix_type,
			loc_env.md_env.matrix,
			&world,
			loc_range ),
       targetid = tmp_obj.objid,
       targetos = tmp_obj.osnum,
       senderid = NULL_OBJID );

     if( range_found ) 	GRaccumulate_range( msg, loc_range, comp_range );
     else
     {
         range_found = 1;
         for( i=0; i<6; i++ ) comp_range[i] = loc_range[i];
     }

     for( i=0; i<6; i++ ) if( fabs(comp_range[i]) > 0.000001 )	break;
     if( i == 6 )  { goto wrapup; }
  }

  for ( id=0; id<gg_num; id++ ) {

    /*
     * test if the gragad is not of the class VDggxyGrid
     */
     status = om$get_classid(	osnum     = gg_list[id].osnum,
				objid     = gg_list[id].objid,
				p_classid = &classid );

      if( ! (1&status) ) {
        printf(" vw_fit_object: om$get_classid for SMFitCmd failed\n");
        continue ;
      }
    
     if( om$is_ancestry_valid(
			subclassid     = classid,
			superclassname = "VDggxyGrid" ) == OM_S_SUCCESS ){

        /*
         * ex$message(	field   = STATUS_FIELD,
	 *		in_buff = " Not a principal view " );
	 */
        continue ;
      }

    /*
     * get the world to view matrix of gadget
     */
    var = 0 ;
    var_list[var].var               = GRAGAD_FLAGS;
    var_list[var].var_ptr           = (IGRchar *) &gg_flags;
    var_list[var].num_bytes         = sizeof (IGRint) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = RANGE_CHK;
    var_list[var].var_ptr           = (IGRchar *) &gg_range_chk;
    var_list[var].num_bytes         = sizeof (struct DPrange_check) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;
 
    var_list[var].var               = END_PARAM ;

    /*
     * get the flag of the gragad
     */
    status =
    dp$inq_set_gragad (	msg         = &msg,
		inq0_set1   = 0,
		calc_info   = 0,
		update      = 0,        /* or 1 KLUDGE */
		osnum        = gg_list[id].osnum,
		gragad_objid = gg_list[id].objid,
		which_error = &error_var,
		var_list    = var_list ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
      continue ;
    }

    /*
     * look in what type of view we are working to get the
     * world to view matrix
     */
    if( gg_flags & IS_PERSP ) {

      /*
       * get  vpn   : view plane normal			( IGRdouble * 3 )
       *      vup   : view up vector			( IGRdouble * 3 )
       *      eye_pt: eye point for perspective		( IGRdouble * 3 )
       *      vrp   : view reference point		( IGRdouble * 3 )
       *      act_z : active z in viewing c.s.		( IGRdouble     )
       *      coi   : center of interest		( IGRdouble * 3 )
       *      vw_ang: view angle			( IGRdouble	)
       */
        var = 0;
	var_list[var].var               = VPN;
	var_list[var].var_ptr           = (IGRchar *) gg_vpn;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = VUP;
	var_list[var].var_ptr           = (IGRchar *) gg_vup;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = EYE_PT;
	var_list[var].var_ptr           = (IGRchar *) gg_eye_pt;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = VRP;
	var_list[var].var_ptr           = (IGRchar *) gg_vrp;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = ACT_Z;
	var_list[var].var_ptr           = (IGRchar *) &gg_act_z;
	var_list[var].num_bytes         = sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = COI;
	var_list[var].var_ptr           = (IGRchar *) gg_coi;
	var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = VIEW_ANGLE;
	var_list[var].var_ptr           = (IGRchar *) &gg_vw_angle;
	var_list[var].num_bytes         = sizeof (IGRdouble);
	var_list[var].bytes_returned    = &num_bytes;
	var ++ ;

	var_list[var].var               = END_PARAM;

	status =
	dp$inq_set_gragad (	msg         = &msg,
				inq0_set1   = 0,
				calc_info   = 0,
				update      = 0,        /* or 1 KLUDGE */
				osnum        = gg_list[id].osnum,
				gragad_objid = gg_list[id].objid,
				which_error = &error_var,
				var_list    = var_list ) ;

	if( !( status & msg & 1 ) ) {
	  if( ! (status & 1) ) om$report_error( sts = status );
	  if( ! (   msg & 1) ) om$report_error( sts = msg );
	  continue ;
	}

	/*
	 * calculate the world to view volume
	 */
	DPalignper( &msg, DPLEFT_VIEW, gg_vpn, gg_vup, gg_eye_pt, gg_ex_mtx,
		    gg_wld_to_vw );
    }
    else {
	/*
	 * get the world to view volume directly from gragad
	 */
	var_list[0].var               = WLD_TO_VIEW;
	var_list[0].var_ptr           = (IGRchar *) gg_wld_to_vw;
	var_list[0].num_bytes         = 16 * sizeof (IGRdouble);
	var_list[0].bytes_returned    = &num_bytes;

	var_list[1].var               = END_PARAM;

	status =
	dp$inq_set_gragad (	msg         = &msg,
				inq0_set1   = 0,
				calc_info   = 0,
				update      = 0,        /* or 1 KLUDGE */
				osnum        = gg_list[id].osnum,
				gragad_objid = gg_list[id].objid,
				which_error = &error_var,
				var_list    = var_list ) ;

	if( !( status & msg & 1 ) ) {
	  if( ! (status & 1) ) om$report_error( sts = status );
	  if( ! (   msg & 1) ) om$report_error( sts = msg );
	  continue ;
	}
    } /* gg_flags */

    /*
     * give update message
     */
    ex$message( msgnumb = GR_I_FitProg );

    /*
     * See if compartment touch the design limits.
     */
    if( comp_range[0] == IGE_DESIGN_LIMITS_MAX ) {
      /*
       * compartment on bourder limits
       */
      continue;
    }

    /*
     * adjust view volume to correspond to calculated range.
     */
    if( ! DPsetrng( &msg, gg_wld_to_vw, &gg_range_chk )){
      /*
       * error in function DPgetrng
       */
      printf("\tError in DPgetrng in VDvw_fit_object \n");
      continue;
    }

    if( ! DPgetrng( &msg, gg_wld_to_vw, &gg_range_chk, 
					comp_range,new_range )){
      /*
       * error in function DPgetrng
       */
      printf("\tError in DPgetrng in VDvw_fit_object \n");
      continue;
    }

    /*
     * determine the border extents for the compartment.
     */
    for( i=0 ; i<3 ; i++ )
      rng_delta[i] = fabs( new_range[3+i] - new_range[i] ) ;

    delta = ( rng_delta[0] < rng_delta[1] ) ? rng_delta[1] : rng_delta[0] ;

    if( ! (gg_flags & AXIS_WLD_ALIGN) ) {
        if( delta < rng_delta[2] ) delta = rng_delta[2] ;
    }

    /*
     * get a fit viewing factor to the object range.
     */
    v_range = ( factor > 1.0 ) ? ((delta*(factor - 1.0))/2.0) : 0.0 ;

    /*
     * add the viewing factor and border perspective to the delta view volume.
     */
    delta *= BORDER_PERC ;

    for( i=0 ; i<3 ; i++ ) {
	new_range[  i] -= ( v_range + delta ) ;
	new_range[3+i] += ( v_range + delta ) ;
    }

    /*
     * fit the compartment in the view volume
     */
    var = 0 ;
    var_list[var].var               = VW_VOLUME;
    var_list[var].var_ptr           = (IGRchar *) new_range;
    var_list[var].num_bytes         = sizeof (GRrange) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    /* temporary endlist */
    var_list[var].var               = END_PARAM ;

    /*
     * see if we change the view volume for the perspective view.
     */
    if( gg_flags & IS_PERSP ) {

      dp$codpb_get_persp_flags( persp_flags = &pflags );
      if( pflags & PERSP_CHANGE_ANGLE ) {

          gg_vw_angle = DEF_VWANGLE;
 
          var_list[var].var               = VIEW_ANGLE ;
          var_list[var].var_ptr           = (IGRchar *) &gg_vw_angle;
          var_list[var].num_bytes         = sizeof (IGRdouble) ;
          var_list[var].bytes_returned    = &num_bytes;
          var ++ ;

          var_list[var].var               = END_PARAM ;
      }
      /*
       * calculate the fit perspective volume.
       */
      gg_near = new_range[2];
      gg_far  = new_range[5];
      DPfitpersp(	&msg,		/* return message	*/
			0,		/* input flag		*/
			new_range,	/* view volume		*/
			&gg_act_z,	/* active Zdepth value	*/
			gg_wld_to_vw,	/* world to view matrix	*/
			gg_coi,		/* old center interest	*/
			gg_vrp,		/* view reference point	*/
			gg_vw_angle,	/* view angle		*/
			gg_vrp,		/* NEW view ref point	*/
			gg_eye_pt,	/* MODIFY eye point	*/
			gg_coi,		/* NEW center interest	*/
			&gg_near,	/* NEW near location	*/
			&gg_far,	/* NEW far location	*/
			&gg_new_z );	/* new z depth value	*/
      new_range[2] = gg_near ;
      new_range[5] = gg_far ;

      var_list[var].var               = VRP ;
      var_list[var].var_ptr           = (IGRchar *) gg_vrp;
      var_list[var].num_bytes         = 3 * sizeof (IGRdouble) ;
      var_list[var].bytes_returned    = &num_bytes;
      var ++ ;

      var_list[var].var               = COI ;
      var_list[var].var_ptr           = (IGRchar *) gg_coi;
      var_list[var].num_bytes         = 3 * sizeof (IGRdouble) ;
      var_list[var].bytes_returned    = &num_bytes;
      var ++ ;

      var_list[var].var               = EYE_PT;
      var_list[var].var_ptr           = (IGRchar *) gg_eye_pt;
      var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
      var_list[var].bytes_returned    = &num_bytes;
      var ++ ;

      var_list[var].var               = END_PARAM ;
    }

    /*
     * set the volume of the gragad
     */
/**
    status =
    dp$inq_set_gragad (	msg          = &msg,
			inq0_set1    = 1,
			calc_info    = 0,
			update       = 0, 
			osnum        = gg_list[id].osnum,
			gragad_objid = gg_list[id].objid,
			which_error  = &error_var,
			var_list     = var_list ) ;
 **/
    status = 
    om$send(msg = message IGEgragad.DPset( &msg,
					   &error_var,
                                           var_list ),
            mode = OM_e_wrt_message,
	    senderid = NULL_OBJID,
            targetid = gg_list[id].objid,
	    targetos = gg_list[id].osnum ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * update the gragad
     */
    status =
    om$send(msg = message IGEgragad.DPcal( &msg ),
            targetid = gg_list[id].objid,
            targetos = gg_list[id].osnum,
            senderid = NULL_OBJID );

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * fit the compartment in the view volume
     */
    var = 0 ;
    var_list[var].var               = DIT_CLIP_RANGE;
    var_list[var].var_ptr           = (IGRchar *) gg_clip_range;
    var_list[var].num_bytes         = 6 * sizeof (IGRdouble) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = ACT_Z_SCREEN;
    var_list[var].var_ptr           = (IGRchar *) &gg_act_z_screen;
    var_list[var].num_bytes         = sizeof (IGRdouble) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = VIEWPORT_TO_WLD;
    var_list[var].var_ptr           = (IGRchar *) gg_vwport_to_wld;
    var_list[var].num_bytes         = 16 * sizeof (IGRdouble) ;
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = END_PARAM ;

    /*
     * get the clip range, viewport and active zdepth of screen of the gragad
     */
    status =
    dp$inq_set_gragad (	msg          = &msg,
			inq0_set1    = 0,
			calc_info    = 0,
			update       = 0,        /* or 1 KLUDGE */
			osnum        = gg_list[id].osnum,
			gragad_objid = gg_list[id].objid,
			which_error  = &error_var,
			var_list     = var_list ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * create the new center of interest
     */
    gg_coi[0] = gg_clip_range[0] + ( gg_clip_range[3] / 2 );
    gg_coi[1] = gg_clip_range[1] + ( gg_clip_range[4] / 2 );
    gg_coi[2] = gg_act_z_screen ;

    one = 1;
    if( ! MAptsxform( &msg, &one, gg_vwport_to_wld, gg_coi, gg_coi ) ){
      /*
       * error in MAptsxform of gragad
       */
      continue;
    }

    /*
     * set the new center of interest of the gragad
     */
    var = 0 ;
    var_list[var].var               = COI;
    var_list[var].var_ptr           = (IGRchar *) gg_coi;
    var_list[var].num_bytes         = 3 * sizeof (IGRdouble);
    var_list[var].bytes_returned    = &num_bytes;
    var ++ ;

    var_list[var].var               = END_PARAM;
/**
    status =
    dp$inq_set_gragad (	msg          = &msg,
			inq0_set1    = 1,
			calc_info    = 0,
			update       = 0, 
			osnum        = gg_list[id].osnum,
			gragad_objid = gg_list[id].objid,
			which_error  = &error_var,
			var_list     = var_list ) ;
 **/

    status = 
    om$send(msg = message IGEgragad.DPset( &msg,
					   &error_var,
                                           var_list ),
            mode = OM_e_wrt_message,
	    senderid = NULL_OBJID,
            targetid = gg_list[id].objid,
	    targetos = gg_list[id].osnum ) ;

    if( !( status & msg & 1 ) ) {
      if( ! (status & 1) ) om$report_error( sts = status );
      if( ! (   msg & 1) ) om$report_error( sts = msg );
        continue ;
    }

    /*
     * look if we update in delay.
     */
    if( ! ( gg_flags & DP_DELAY ) ) {

        IGRboolean upd_flag = FALSE ;

        status =
        om$send(msg = message IGEdisplay.DPupdate(&msg, NULL, &upd_flag ),
      	        targetid = gg_list[id].objid,
	        targetos = gg_list[id].osnum,
	        senderid = NULL_OBJID );

        if( !( status & msg & 1 ) ) {
          if( ! (status & 1) ) om$report_error( sts = status );
          if( ! (   msg & 1) ) om$report_error( sts = msg );
          continue ;
        }
    }
    else{
        ex$message( msgnumb = GR_I_DlyOn );
    }

    ex$message( msgnumb = EX_S_Clear );

  } /* close for for */

  wrapup:

  return( status );

}

end implementation Root;

