/* $Id: VScsby2elF.I,v 1.3 2001/07/13 16:34:43 jayadev Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        vscoord/VScsby2elF.I
 *
 * Description:	This macro constructs a coordinate system between a beam
 *		and a beam or plate.
 *		The coordinate system will be later used to place an
 *		end cut macro.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VScsby2elF.I,v $
 *      Revision 1.3  2001/07/13 16:34:43  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/07/09 21:11:51  jayadev
 *      fix for TR#MP5386
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:30  cvs
 *      Initial import to CVS
 *
# Revision 1.4  2000/02/23  22:22:04  pinnacle
# tr179901005
#
# Revision 1.3  2000/02/17  16:45:38  pinnacle
# (No comment)
#
# Revision 1.2  1998/06/24  13:05:54  pinnacle
# tr179801147
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.6  1998/02/03  19:23:12  pinnacle
# TR179702554
#
# Revision 1.5  1997/11/19  16:39:02  pinnacle
# TR179702163
#
# Revision 1.4  1997/10/31  15:32:10  pinnacle
# Remove Spec File
#
# Revision 1.3  1997/09/26  18:06:42  pinnacle
# TR179701071
#
# Revision 1.17  1997/05/28  12:28:56  pinnacle
# Replaced: vscoord/VScsby2elF.I for:  by mfournie for struct
#
# Revision 1.16  1997/05/22  17:02:10  pinnacle
# Replaced: vscoord/VScsby2elF.I for: use <int_2_elem> CImacro with trim = NO. by mfournie for struct
#
# Revision 1.15  1997/05/20  16:40:24  pinnacle
# Replaced: vscoord/VScsby2elF.I for: extend extracted isocurves by mfournie for struct
#
# Revision 1.14  1997/04/17  12:30:28  pinnacle
# Replaced: vscoord/VScsby2elF.I for:  by mfournie for struct
#
# Revision 1.13  1997/04/17  12:25:22  pinnacle
# Replaced: vscoord/VScsby2elF.I for: delete old code. fix in VSprojectOnTop(). by mfournie for struct
#
# Revision 1.12  1997/04/01  14:31:34  pinnacle
# Replaced: vscoord/VScsby2elF.I for:  by jwfrosch for struct
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *	04/17/97   mf		delete old code. fix in VSprojectOnTop().
 *	05/20/97   mf		extend extracted isocurves.
 *	05/22/97   mf		use <int_2_elem> CImacro with trim = NO.
 *	05/28/97   mf		use <srf_ext> CImacro for complex cases.
 *      06/16/97   ah           TR179701071 Checkin
 *      09/26/97   ah           problem with "center" cs's
 *      10/30/97   ah           Changed from VScs2el to VShelper implementation
 *      11/19/97   ah		TR179702163 Deleted all unused functions
 *      02/03/98   ah           TR179702554 Typo in VSfind_surf_to_intersect
 *      06/24/98   ah           TR179801147 Core dump for base/offset tan to inter
 *      02/23/00   ah           Turn debugs off
 *      07/09/01   Jayadev      TR#MP5386 
 *************************************************************************/

class implementation VShelper;

#include "VDmaster.h"

#include        "gotextdef.h"
#include        "cotxmacros.h"
#include	"grcoordsys.h"

#include        "ACdyn_col.h"
#include        "bsparameters.h"
#include        "EMSssprops.h"

#include	"vdAPImacros.h"

#include 	"vspart.h"
#include 	"vsdpb.h"

#include        "vscoordproto.h"

#include 	"vsbeamdef.h"
#include 	"vsbeam.h"
#include 	"vssectiondef.h"
#include 	"vsbeam.h"
#include 	"vsbeammacros.h"
#include 	"vsplatedef.h"

#include 	"vsstfnrdef.h"

#include 	"vsmiscmacros.h"
#include 	"vsgeommacros.h"

/* Include of prototypes */
#include        "bscrossp.h"
#include        "bscveval.h"
#include        "bsdistptpt.h"
#include        "bsdotp.h"
#include        "bsmdistptsf.h"
#include        "bsmdstptcv.h"
#include        "bsnorvec.h"
#include        "bspj_pt_sf.h"
#include        "bsptnorsf.h"
#include        "bssfevaln.h"

 
/* Externals */
extern  GRclassid       OPP_GR3dlinestr_class_id;
extern  GRclassid       OPP_EMSsubbs_class_id;
extern  GRclassid       OPP_EMSgenbs_class_id;
extern  GRclassid       OPP_VSplate_class_id;
extern  GRclassid       OPP_VSbeam_class_id;
extern  GRclassid       OPP_GRgencs_class_id;

extern 	IGRint 		init_cnst_list();
extern  IGRchar         *memcpy();

/* Imports */
from 	VSstfBeam 	import 	VSgetSupports;
from 	EMSsurface 	import 	EMcrvsrfint;
from 	GRcurve 	import 	GRendpts;
from	EMSsubbs 	import 	EMisoparcvs ;
from 	EMSsubbs	import	EMget_props;

/*
#define	TRACE
#define	vsDEBUG
#define	vserrDEBUG
*/

#include	"vsdbgmacros.h"
#define         DELTA 0.0001
/*---------------------------------------------------------------------------*/
long VSfind_longer_u_v_iso (
	struct GRobj_env 	*surface,    /*I: the surface 		   */
	struct  GRvg_construct 	*cst,        /*I: construction list 	   */
	int			*u_is_longer)/*O: TRUE : iso in u is longer
						  FALSE: iso in v is longer*/
/*
 * Given a surface, this function finds which between the iso in u and the
 * iso in v is longer
 */
{
	long 			msg,loc_msg,sts;
	double			uv,len[2];
	GRobjid			*iso_objid = NULL;
	int			j,k;
	long			i;
	struct	IGRbsp_curve	*cv=NULL;
	BSrc			bsrc;
	struct	GRid		dummy;

	msg = MSFAIL;

	*u_is_longer = TRUE;
	len[0] = len[1] = 0;
	uv=0;
	sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
					&loc_msg,
					&(surface->mod_env.md_env.matrix_type),
					surface->mod_env.md_env.matrix,
					cst,
					FALSE,
					1,
					&uv,
					TRUE,
					&i,
					&iso_objid),
			senderid  = NULL_OBJID,
			targetid  = surface->obj_id.objid,
			targetos  = surface->obj_id.osnum );
	if (!(sts&loc_msg&1)) {
		__DBGpr_com("EMSsubbs.EMisoparcvs Failed");
		goto wrapup;
	}

	_FREE ( cv );

	dummy.objid = *iso_objid;
	dummy.osnum = cst->env_info->md_id.osnum;
	sts = vd_$get_geometry ( msg		= &loc_msg,
				 grobjId	= &dummy,
				 grobjEnv	= cst->env_info,
				 geometry	= (IGRchar **) &cv );
	if (!(loc_msg&sts&1)) goto wrapup;
	k = 3 * (cv->num_poles - 1);
	for ( j=0; j<k; j=j+3)
		len[0] += BSdistptpt( 	&bsrc, 
					&(cv->poles[j]), 
					&(cv->poles[j+3]) );
	if (bsrc != BSSUCC) {
		__DBGpr_com( "Error in BSdistptpt");
		goto wrapup;
	}
	if (iso_objid) {
		sts = om$send( msg      = message GRgraphics.GRdelete (
						&loc_msg, 
						cst->env_info ),
				senderid = NULL_OBJID,
				targetid = *iso_objid,
				targetos = cst->env_info->md_id.osnum);
		free (iso_objid); iso_objid = NULL;
	}
	sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
					&loc_msg,
					&(surface->mod_env.md_env.matrix_type),
					surface->mod_env.md_env.matrix,
					cst,
					FALSE,
					1,
					&uv,
					FALSE,
					&i,
					&iso_objid),
			senderid  = NULL_OBJID,
			targetid  = surface->obj_id.objid,
			targetos  = surface->obj_id.osnum );
	if (!(sts&loc_msg&1)) {
		__DBGpr_com("EMSsubbs.EMisoparcvs Failed");
		goto wrapup;
	}

	_FREE ( cv );
	dummy.objid = *iso_objid;
	dummy.osnum = cst->env_info->md_id.osnum;
	sts = vd_$get_geometry ( msg		= &loc_msg,
				 grobjId	= &dummy,
				 grobjEnv	= cst->env_info,
				 geometry	= (IGRchar **) &cv );
	if (!(loc_msg&sts&1)) goto wrapup;
	k = 3 * (cv->num_poles - 1);
	for ( j=0; j<k; j=j+3)
		len[1] += BSdistptpt( 	&bsrc,
					&(cv->poles[j]),
					&(cv->poles[j+3]) );
	if (bsrc != BSSUCC) {     
		__DBGpr_com( "Error in BSdistptpt");
		goto wrapup;
	}

	if (len[0] >= len[1]) *u_is_longer = TRUE;
	else *u_is_longer = FALSE;

	msg = MSSUCC;
wrapup :
	if (iso_objid) {
		sts = om$send( msg      = message GRgraphics.GRdelete(
						&loc_msg, 
						cst->env_info),
				senderid = NULL_OBJID,
				targetid = *iso_objid,
				targetos = cst->env_info->md_id.osnum);
		free (iso_objid); iso_objid = NULL;
	}
	_FREE ( cv );
	return msg;
} /* VSfind_longer_u_v_iso */
/*---------------------------------------------------------------------------*/
IGRlong VStest_angle
(
	IGRlong		*msg,		/*O Completion code		*/
struct	GRobj_env	*Axis,		/*I Axis object			*/
struct	GRobj_env	*Surf,		/*I Surface object		*/
struct	IGRbsp_surface	**srf,		/*O Surface structure		*/
	IGRdouble	*angle		/*O Cosinus of resulting angle	*/
)
/*
 * This function computes the cosinus of the angle between the normal of 
 * a given surface and a given axis. It uses and returns the extended 
 * geometry of the surface.
 */
{
	IGRlong		sts;
	IGRint		num=0 ;
	IGRdouble	u, v, t;
	IGRpoint	p, pnt;
	IGRvector	nrm[1], axe;
struct	IGRbsp_curve	*crv=NULL;
	BSrc		rc;

	/* Initialize */
	*angle = 0.0;
	*srf   = NULL;

#ifdef TRACE
  printf("Find angle between\n");
  VDbroPrintObj(&Axis->obj_id);
  VDbroPrintObj(&Surf->obj_id);
#endif
	/* Intersection Axis with Surf */
	sts = VScsIntCrvSrf( msg, Axis, Surf, NULL, p, &t, &u, &v);
	if (!(sts & 0x00000001 & (*msg))) {
		__DBGpr_com ( "VStest_angle() : VScsIntCrvSrf() failed" );
		sts  = OM_S_SUCCESS;
		*msg = MSSUCC;
		goto wrapup;
	}
#ifdef TRACE
  printf("VStest_angle.VScsIntCrvSrf worked\n");
#endif

	/* Get axis geometry */
	sts = vd_$get_geometry ( msg	  = msg,
				 grobjId  = &Axis->obj_id,
				 grobjEnv = &Axis->mod_env,
				 geometry = (IGRchar **) &crv );
	__CheckRC ( sts, *msg, "vd_$get_geometry()", wrapup ) ;

	/* Get surface geometry */
	sts = vd_$get_geometry ( msg	  = msg,
				 grobjId  = &Surf->obj_id,
				 grobjEnv = &Surf->mod_env,
				 geometry = (IGRchar **) srf );
	__CheckRC ( sts, *msg, "vd_$get_geometry()", wrapup ) ;

	/* Find normal to surface */
	BSsfevaln ( *srf, u, v, 1, &num, pnt, nrm, &rc );
	if (rc != BSSUCC) {
		__DBGpr_com("PBS dans BSsfevaln");
		goto wrapup;
	}
	BSnorvec ( &rc, nrm[0] );
        if (rc != BSSUCC) goto wrapup;

	/* Find normal to axis */
	axe[0] = crv->poles[3*(crv->num_poles-1)+0] - crv->poles[0];
	axe[1] = crv->poles[3*(crv->num_poles-1)+1] - crv->poles[1];
	axe[2] = crv->poles[3*(crv->num_poles-1)+2] - crv->poles[2];
	BSnorvec ( &rc, axe );
	if (rc != BSSUCC) goto wrapup;

	/* Evaluate dot product of normals */
	*angle = BSdotp ( &rc, axe, nrm[0] ); 
        if (rc != BSSUCC) goto wrapup;
 
wrapup :
	_FREE (crv)

	return (sts);
} /* VStest_angle */

/* ------------------------------------------------------ */
/* Extracts Geometry for named surface and does matrix bs */
long VSgetWebGeom(
  struct GRobj_env *beam,
  IGRchar          *name,
  struct IGRbsp_surface **sf
)
{
  char  srfName[DI_PATH_MAX];
  long	sts,loc_msg,msg;
  int   i;

  struct GRobj_env srfObjEnv;

  msg = MSFAIL;
  *sf = NULL;

  sprintf ( 
    srfName, "%s:%s:%s", 
    VS_K_bmGrCmpName, VS_K_bmBody, name
  );

  sts = om$send( 
    msg = message NDmacro.ACreturn_foot(
      &loc_msg,
       srfName,
      &srfObjEnv.obj_id,
      &srfObjEnv.mod_env.md_env.matrix_type,
       srfObjEnv.mod_env.md_env.matrix 
    ),
    targetid = beam->obj_id.objid,
    targetos = beam->obj_id.osnum,
    senderid = NULL_OBJID 
  );
  if (!(sts&loc_msg&1)) {
    __DBGpr_com("Problems at NDmacro.ACreturn_foot");
    goto wrapup;
  }

  /* Not sure why we need this bs */
  srfObjEnv.mod_env.md_id.osnum = srfObjEnv.obj_id.osnum;
  ex$get_modid(
    mod_osnum =  srfObjEnv.mod_env.md_id.osnum,
    mod_id    = &srfObjEnv.mod_env.md_id.objid
  );

  if (beam->mod_env.md_env.matrix_type != MAIDMX) {
    i = 4;
    MAmulmx(
      &loc_msg,&i,&i,&i,
      beam->mod_env.md_env.matrix,
      srfObjEnv.mod_env.md_env.matrix,
      srfObjEnv.mod_env.md_env.matrix
    );
    MAtypemx( 
      &loc_msg, 
       srfObjEnv.mod_env.md_env.matrix,
      &srfObjEnv.mod_env.md_env.matrix_type
    );
  }

  sts = vd_$get_geometry ( 
    msg	     = &loc_msg,
    grobjId  = &srfObjEnv.obj_id,
    grobjEnv = &srfObjEnv.mod_env,
    geometry = (IGRchar **) sf );
  if (!(loc_msg&sts&1)) goto wrapup;

  msg = MSSUCC;

wrapup:
  return msg;

}

/*---------------------------------------------------------------------------*/
long VSfind_botu0_web (
	struct GRobj_env *beam,   /*I: the beam 			  */
	struct GRobj_env *bot_srf,/*I: Flange Inferior surface of th beam */
	int	      	 *web )	  /*O: *web == 0 --> closest to web right
                                       *web == 1 --> closest to web left  */
/*
 * Given a beam and its Flange Inferior surface, this function compute 
 * the iso curve on this surface at u==0 and find if this curve is closest
 * to web left or web right. 
 */
{
  long      sts,loc_msg,msg;
  
  IGRpoint  point,base;
  double    distR,distL;
  double    u,v;

  BSrc      bsrc;

  struct IGRbsp_surface *sf=NULL;

  *web = 0;
  msg  = MSFAIL;

  /* Find point at uv=0 on bottom surface */
  sts = vd_$get_geometry ( 
    msg	      = &loc_msg,
    grobjId   = &bot_srf->obj_id,
    grobjEnv  = &bot_srf->mod_env,
    geometry  = (IGRchar **) &sf );

  if (!(loc_msg&sts&1)) goto wrapup;

  point[0] = sf->poles[0];
  point[1] = sf->poles[1];
  point[2] = sf->poles[2];

  /* Find distance to right web */
  _FREE( sf );
  sf = NULL;
  sts = VSgetWebGeom(beam,VS_K_nmWebR,&sf);
  if (!(sts & 1)) goto wrapup;

  distR = 0.0;
  BSmdistptsf(&bsrc,sf,point,&u,&v,base,&distR);

  /* If the right distance is zero then no need to check left */
  if (distR < .0001) {
    *web = 0;
    msg = MSSUCC;
    goto wrapup;
  }

  /* Find distance to left web */
  _FREE( sf );
  sf = NULL;
  sts = VSgetWebGeom(beam,VS_K_nmWebL,&sf);
  if (!(sts & 1)) goto wrapup;

  distL = 0.0;
  BSmdistptsf(&bsrc,sf,point,&u,&v,base,&distL);
/*
  printf("Distance Right: %.2f, Left: %.2f\n",distR,distL);
*/
  if (distL < distR) *web = 1;
  else               *web = 0;

  msg = MSSUCC;

wrapup :
  _FREE( sf );
  return msg;

}/* VSfind_bot0_web */


/*---------------------------------------------------------------------------*/
long VSfind_webL_webR_vec (
	struct GRobj_env      *surface,   /*I: surface 			    */
	struct GRparms	      *par,       /*I: parameter 		    */
	double		      web,        /*I: indicate if the point at u=0 
					      v=0 on the surface is closest 
					      to web left or web right      */
	int		      u_is_longer,/*I: iso u is longer than iso v   */
	int		      *options,   /*I: the chosen options 	    */
	struct GRvg_construct *cst,       /*I construction list 	    */
	double  	      *vec )      /*O: vector from web_l to web_r   */
/*
 * Given a surface, this function computes a tangent vector to an iso
 * curve on this surface at a given parameter such that it points
 * in the direction web_left to web_right.
 */
{
	long		sts,loc_msg,msg;
	long		j;
	GRobjid 	*iso_objid=NULL;
	struct GRid 	iso;
	IGRpoint 	startpt,endpt;
	double   	dbl;
	int		bool;

	msg = MSFAIL;

	if (u_is_longer) {
		dbl = par->v;
		bool = FALSE;
	} else {
		dbl = par->u;
		bool = TRUE; 
	}
	/*
	 * find iso curve
	 */
	sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
					&loc_msg,
					&(surface->mod_env.md_env.matrix_type),
					surface->mod_env.md_env.matrix,
					cst,
					FALSE,
					1,
					&dbl,
					bool,
					&j,
					&iso_objid ),
			senderid  = NULL_OBJID,
			targetid  = surface->obj_id.objid,
			targetos  = surface->obj_id.osnum );
	if (!(sts&loc_msg&1)) {
		__DBGpr_com("EMSsubbs.EMisoparcvs Failed");
		goto wrapup;
	}
	iso.objid = *iso_objid;
	iso.osnum = cst->env_info->md_id.osnum;
	/*
	 * find end points
	 */
	sts = om$send ( msg =  message GRcurve.GRendpts (
					&loc_msg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
					startpt,endpt),
			targetid = iso.objid,
			targetos = iso.osnum,
			senderid = NULL_OBJID );
	if (!(sts&loc_msg&1)) {
		goto wrapup;
	}
	vec[0] = endpt[0] - startpt[0];
	vec[1] = endpt[1] - startpt[1];
	vec[2] = endpt[2] - startpt[2];

	/*
	 *  if options[1] > 3 the given surface is the top superior flange.
	 *  this means the vector web_left to web right is the inverse of
	 *  this vector if the given surface was bottom inferior flange 
	 * (options[1]<3).
	 */ 
	if ( (!web && options[1] < 3) || (web && options[1] >= 3)) {
		vec[0] = -vec[0];
		vec[1] = -vec[1];
		vec[2] = -vec[2];
	}

	msg = MSSUCC;
wrapup :
	if (iso_objid) {
		om$send( msg      = message GRgraphics.GRdelete(
						&loc_msg, 
						cst->env_info),
			senderid = NULL_OBJID,
			targetid = iso.objid,
			targetos = iso.osnum);
		free (iso_objid); iso_objid = NULL;
	}
	return msg;
} /* VSfind_webL_webR_vec */
/*---------------------------------------------------------------------------*/
IGRlong VSgetBeamCenter( 
	struct GRobj_env *beam, 	/*I: the beam 		*/
	double		 *center )	/*O: center point	*/
/*
 * Given a beam, this function compute the center of the left web surface.
 */
{
	char		        srfName[DI_PATH_MAX];
	IGRlong		        sts, loc_msg,msg;
	struct GRobj_env	SrfL;
	struct IGRbsp_surface	*sf=NULL;
	BSrc			bsrc;
	double			tmp[3];
	IGRint			i;

	msg = MSFAIL;

	sprintf ( srfName, "%s:%s:%s", VS_K_bmGrCmpName, VS_K_bmBody,
								VS_K_nmWebL);
	/*
	 * find web left surface
	 */
	sts = om$send ( msg = message NDmacro.ACreturn_foot (
					&loc_msg,
					srfName,
					&SrfL.obj_id,
					&SrfL.mod_env.md_env.matrix_type,
					SrfL.mod_env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = beam->obj_id.objid,
			targetos = beam->obj_id.osnum );
	if (!(sts&loc_msg&1)) {
		__DBGpr_com("Problems in ACreturn foot");
		goto wrapup;
	}
	SrfL.mod_env.md_id.osnum = SrfL.obj_id.osnum;
	ex$get_modid(   mod_osnum = SrfL.mod_env.md_id.osnum,
			mod_id    = &(SrfL.mod_env.md_id.objid)) ;
	if (beam->mod_env.md_env.matrix_type != MAIDMX) {
		i = 4;
		MAmulmx(&loc_msg,&i,&i,&i,beam->mod_env.md_env.matrix,
				SrfL.mod_env.md_env.matrix,
				SrfL.mod_env.md_env.matrix);
		MAtypemx( &loc_msg, SrfL.mod_env.md_env.matrix,
		&SrfL.mod_env.md_env.matrix_type);
	}

	_FREE ( sf );
	sts = vd_$get_geometry ( msg		= &loc_msg,
				 grobjId	= &SrfL.obj_id,
				 grobjEnv	= &SrfL.mod_env,
				 geometry	= (IGRchar **) &sf );
	if (!(loc_msg&sts&1)) {
		goto wrapup;
	}

	BSsfevaln(sf,0.5,0.5,1,&i,center,(IGRvector *)tmp,&bsrc);
	if (bsrc != BSSUCC) {
		__DBGpr_com("PBS dans BSsfevaln");
		goto wrapup;
	}

	msg = MSSUCC;
wrapup :
	_FREE ( sf );

	return msg;
} /* VSgetBeamCenter */

/*---------------------------------------------------------------------------*/
IGRlong VSfind_surf_to_intersect (
	struct GRobj_env 	*plate_or_beam,/*I:plate or beam (input2)   */
	double			*beam_center,  /*I:beam center 		    */
	int			*options,      /*I:option chosen by the user*/
	struct GRobj_env	*axis,         /*I:beam axis 		    */
	int			*idxSurf,      /*O:index of chosen surface  */
	struct GRobj_env	*srf_to_int,   /*O:chosen surface 	    */
	struct IGRbsp_surface	**bspexsrf )   /*O:the extended surface of the
						 chosen surface 	    */
/*
 *    This function find the surface of the second input of this command
 *    to intersect with the beam (the first input) in respect with the
 *    options chosen by the user.
 */
{
	IGRlong		msg, sts;
	IGRint		i, j1, j2, idx, angCount = 0;
	BSrc		bsrc;
	IGRchar	        srfName[DI_PATH_MAX], dbgName[DI_PATH_MAX];
struct GRobj_env	surf[4];
struct IGRbsp_surface	*Srf[4];
struct IGRbsp_surface	*srf1=NULL, *srf2=NULL;
struct GRobj_env	*srf1_id=NULL, *srf2_id=NULL;
	IGRdouble	dist1=0.0, dist2=0.0, tmp[3], angle[4];
	IGRint		indx_surf[4], angIndex[4], option;
struct IGRbsp_surface	*Bsf=NULL, *Tsf=NULL;
	IGRpoint	tmpPoint;
	IGRboolean	isPlate;

        option = options[0];
#ifdef TRACE
  printf("VSfind_surf_to_intersect\n");
  VDbroPrintObj(&plate_or_beam->obj_id);
  VDbroPrintObj(&axis->obj_id);
#endif

	/* Initialize */
	msg = MSFAIL;
	*bspexsrf = NULL ;
	for( i=0; i<4; i++ )	Srf[i] = NULL;
	for( i=0; i<4; i++ )	angIndex[i] = 0;

	/* <plate_or_beam> is a VSplate or a VSbeam ? */
	isPlate = vs$is_ancestry_valid ( object  = &plate_or_beam->obj_id,
					 classid = OPP_VSplate_class_id );

	if (isPlate == TRUE ) {	/* VSplate case */

		if (option == 2) {	/* Find base surface */
			sts = vd_$return_foot (
					msg     = &msg,
					name	= VS_K_plBotSfPath,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &srf_to_int->obj_id,
					footEnv	= &srf_to_int->mod_env );
			sprintf ( dbgName, "vd_$return_foot(%s)",
				  VS_K_plBotSfPath );
			__CheckRC ( sts, msg, dbgName, wrapup );
			*idxSurf = VS_K_stOnBotOfPlate;
			// goto wrapup; TR179801147 Still need ext geom
		}
		else if (option == 3) {	 /* Find offset surface */
			sts = vd_$return_foot (
					msg     = &msg,
					name	= VS_K_plTopSfPath,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &srf_to_int->obj_id,
					footEnv	= &srf_to_int->mod_env );
			sprintf ( dbgName, "vd_$return_foot(%s)",
				  VS_K_plTopSfPath );
			__CheckRC ( sts, msg, dbgName, wrapup );
			*idxSurf = VS_K_stOnTopOfPlate ;
			// goto wrapup; TR179801147 Still need ext geom
		}
		else {	/* Find base surface */
			sts = vd_$return_foot (
					msg     = &msg,
					name	= VS_K_plBotSfPath,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &surf[0].obj_id,
					footEnv	= &surf[0].mod_env );
			sprintf ( dbgName, "vd_$return_foot(%s)",
				  VS_K_plBotSfPath );
			__CheckRC ( sts, msg, dbgName, wrapup );

			/* Extract base surface geometry */
			sts = vd_$get_geometry ( msg	  = &msg,
						 grobjId  = &surf[0].obj_id,
						 grobjEnv = &surf[0].mod_env,
						 geometry = (IGRchar **) &Bsf );
			__CheckRC ( sts, msg, "vd_$get_geometry()", wrapup ) ;

			/* Find the distance between the base surface and
		           the geometric center of the first beam */
			BSptnorsf( Bsf, beam_center, &i, &tmp[0], &tmp[0],
				   tmp , &dist1 , &bsrc ) ;
			if (bsrc != BSSUCC) {
				__DBGpr_com("Problerms BSptnorsf");
				sts = MSFAIL;
				goto wrapup;
			} 
			if (i == 0)
				BSmdistptsf ( &bsrc, Bsf, beam_center,
					      &tmp[0], &tmp[1], tmpPoint,
					      &dist1);
			if (bsrc != BSSUCC) {
				__DBGpr_com("Problerms BSmdistptsf");
				sts = MSFAIL;
				goto wrapup;
			} 

			/* Find offset surface */
			sts = vd_$return_foot (
					msg     = &msg,
					name	= VS_K_plTopSfPath,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &surf[1].obj_id,
					footEnv	= &surf[1].mod_env );
			sprintf ( dbgName, "vd_$return_foot(%s)",
				  VS_K_plTopSfPath );
			__CheckRC ( sts, msg, dbgName, wrapup );

			/* Extract offset surface geometry */
			sts = vd_$get_geometry ( msg	  = &msg,
						 grobjId  = &surf[1].obj_id,
						 grobjEnv = &surf[1].mod_env,
						 geometry = (IGRchar **) &Tsf );
			__CheckRC ( sts, msg, "vd_$get_geometry()", wrapup ) ;

			/* Find the distance between the offset surface and
		           the geometric center of the first beam */
			BSptnorsf( Tsf, beam_center, &i, &tmp[0], &tmp[0],
				   tmp , &dist2 , &bsrc ) ;
			if (bsrc != BSSUCC) {
				__DBGpr_com("Problerms BSptnorsf");
				sts = MSFAIL;
				goto wrapup;
			} 
			if (i == 0)
				BSmdistptsf ( &bsrc, Tsf, beam_center,
					      &tmp[0], &tmp[1], tmpPoint,
					      &dist2);
			if (bsrc != BSSUCC) {
				__DBGpr_com("Problerms BSmdistptsf");
				sts = MSFAIL;
				goto wrapup;
			} 

			if (option == 0) {	/* Closest surface */
				if (dist1 < dist2) { 
					*srf_to_int = surf[0];
					*idxSurf = VS_K_stOnBotOfPlate;
				}
				else {	*srf_to_int = surf[1];
					*idxSurf = VS_K_stOnTopOfPlate ;
				}
			}
			else {			/* Farthest surface */
				if (dist1 < dist2) { 
					*srf_to_int = surf[1];
					*idxSurf = VS_K_stOnTopOfPlate ;
				}
				else {	*srf_to_int = surf[0];  // TR179702554 Was 2
					*idxSurf = VS_K_stOnBotOfPlate;
				}
			}
		}
	}
	else {	/* VSbeam case	*/

		/* Build right web path */
		indx_surf[0] = VS_K_sc_WebR;
		sprintf ( srfName, "%s:%s:%s",
			  VS_K_bmGrCmpName, VS_K_bmBody, VS_K_nmWebR );

		/* Find right web surface */
		sts = vd_$return_foot ( msg     = &msg,
					name	= srfName,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &surf[0].obj_id,
					footEnv	= &surf[0].mod_env );
		sprintf ( dbgName, "vd_$return_foot(%s)", srfName );
		__CheckRC ( sts, msg, dbgName, wrapup );

		/* Build left web path */
		indx_surf[1] = VS_K_sc_WebL;
		sprintf ( srfName, "%s:%s:%s",
			  VS_K_bmGrCmpName, VS_K_bmBody, VS_K_nmWebL );

		/* Find left web surface */
		sts = vd_$return_foot ( msg     = &msg,
					name	= srfName,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &surf[1].obj_id,
					footEnv	= &surf[1].mod_env );
		sprintf ( dbgName, "vd_$return_foot(%s)", srfName );
		__CheckRC ( sts, msg, dbgName, wrapup );

		/* Build bottom inferior flange path */
		indx_surf[2] = VS_K_sc_FlgInfE ;
		sprintf ( srfName, "%s:%s:%s",
			  VS_K_bmGrCmpName, VS_K_bmBody, VS_K_nmFlgInfE );

		/* Find bottom inferior flange surface */
		sts = vd_$return_foot ( msg     = &msg,
					name	= srfName,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &surf[2].obj_id,
					footEnv	= &surf[2].mod_env );
		sprintf ( dbgName, "vd_$return_foot(%s)", srfName );
		__CheckRC ( sts, msg, dbgName, wrapup );

		/* Build top inferior flange path */
		indx_surf[3] = VS_K_sc_FlgSupE ;
		sprintf ( srfName, "%s:%s:%s",
			  VS_K_bmGrCmpName, VS_K_bmBody, VS_K_nmFlgSupE );

		/* Find top inferior flange surface */
		sts = vd_$return_foot ( msg     = &msg,
					name	= srfName,
					objId	= &plate_or_beam->obj_id,
					objEnv	= &plate_or_beam->mod_env,
					footId	= &surf[3].obj_id,
					footEnv	= &surf[3].mod_env );
		sprintf ( dbgName, "vd_$return_foot(%s)", srfName );
		__CheckRC ( sts, msg, dbgName, wrapup );

		/* Find the angle between axis and the normal on webR */
		sts = VStest_angle ( &msg, axis, &surf[0], &Srf[0], &angle[0] );
		__CheckRC ( sts, msg, "VStest_angle()", wrapup );
		if (angle[0] < 0) angle[0] = -angle[0];
                if(fabs(angle[0]) > DELTA) 
                {
                  angIndex[0] =1;
                  angCount ++;
                }
		
		/* Find the angle between axis and the normal on webL */
		sts = VStest_angle ( &msg, axis, &surf[1], &Srf[1], &angle[1] );
		__CheckRC ( sts, msg, "VStest_angle()", wrapup );
		if (angle[1] < 0) angle[1] = -angle[1];
                if(fabs(angle[1]) > DELTA) 
                {
                  angIndex[1] =1;
                  angCount ++;
                }

		/* Find the angle between axis and the normal on FlgInfE */
		sts = VStest_angle ( &msg, axis, &surf[2], &Srf[2], &angle[2] );
		__CheckRC ( sts, msg, "VStest_angle()", wrapup );
		if (angle[2] < 0) angle[2] = -angle[2];
                if(fabs(angle[2]) > DELTA) 
                {
                  angIndex[2] =1;
                  angCount ++;
                }
 
		/* Find the angle between axis and the normal on FlgSupE */
		sts = VStest_angle ( &msg, axis, &surf[3], &Srf[3], &angle[3] );
		__CheckRC ( sts, msg, "VStest_angle()", wrapup );
		if (angle[3] < 0) angle[3] = -angle[3];
                if(fabs(angle[3]) > DELTA) 
                {
                  angIndex[3] =1;
                  angCount ++;
                }
                __DBGpr_int ("angCount :",angCount); 
		if (option == 0 || option == 1) {

		  if(angCount == 1)
		  {
		    __DBGpr_com("only one surf from second beam is eligible ");
		    for(i = 0; i<4; i++)
		    {
		      if(angIndex[i] == 1)
                      {

			/* Let the required surface of the 2nd beam
			 * influenced by the position of the coordinate
			 * system on the 1st beam (top/bottom flange)
			 */
                        if(i>=2) // if the selected surface is a flange
                        {
			  if(options[1] <= 2){ // take the bottom flange of beam2
			    __DBGpr_com("taken the bottom flange ");
			    *srf_to_int = surf[2];
			    *bspexsrf   = Srf[2];
			    *idxSurf    = indx_surf[2];
			    idx = 2;
			    break;
			  }
			  else{ // take the top flange of beam2
			    __DBGpr_com("taken the top flange ");
			    *srf_to_int = surf[3];
			    *bspexsrf   = Srf[3];
			    *idxSurf    = indx_surf[3];
			    idx = 3;
			    break;
			  } 
                        }
                        else
                        {
			  *srf_to_int = surf[i];
			  *bspexsrf   = Srf[i];
			  *idxSurf    = indx_surf[i];
			  idx = i;
			  break;
                        }
                      }
		    }
		  }
		  else
		  {
		    /* Find the two surfaces that are closest to 
		       be orthogonal to the beam axis */
		    srf1    = Srf[0];
		    srf2    = Srf[1];
		    srf1_id = &surf[0];
		    srf2_id = &surf[1];
		    j1 = j2 = 0;
		    for ( i=1; i<4; i++) {
		      if (angle[i] > angle[j1]) {
			srf2    = Srf[j1];
			srf2_id = &surf[j1];
			srf1    = Srf[i];
			srf1_id = &surf[i];
			j2 = j1;
			j1 = i;
		      }
		      else if (angle[i] > angle[j2]) {
			srf2    = Srf[i];
			srf2_id = &surf[i];
			j2 = i;
		      }
		    }
		    
		    /* Check if surfaces have been found */
		    if ( (!srf1) || (!srf2) ) {
		      __DBGpr_com("No surfaces found by angle");
		      sts = MSFAIL;
		      goto wrapup;
		    }
		    
		    /* Find distance between beam center and srf1 */
		    i = 0;
		    __DBGpr_com(">> BSptnorsf()");
		    BSptnorsf( srf1, beam_center, &i, &tmp[0], &tmp[0],
			       tmp , &dist1 , &bsrc ) ;
		    if (bsrc != BSSUCC) {
		      __DBGpr_com("Problerms BSptnorsf");
		      sts = MSFAIL;
		      goto wrapup;
		    }
		    if (i == 0) {
		      __DBGpr_com(">> BSmdistptsf()");
		      BSmdistptsf ( &bsrc, srf1, beam_center,
				    &tmp[0], &tmp[1], tmp, &dist1 );
		      if (bsrc != BSSUCC) {
			__DBGpr_com("Problerms BSmdistptsf");
			sts = MSFAIL;
			goto wrapup;
		      }
		    }
		    
		    /* Find distance between beam center and srf2 */
		    __DBGpr_com(">> BSptnorsf()");
		    BSptnorsf ( srf2, beam_center, &i, &tmp[0], &tmp[0],
				tmp , &dist2 , &bsrc ) ;
		    if (bsrc != BSSUCC) {
		      __DBGpr_com("Problerms BSptnors");
		      sts = MSFAIL;
		      goto wrapup;
		    }
		    if( i == 0) {
		      __DBGpr_com(">> BSmdistptsf()");
		      BSmdistptsf ( &bsrc, srf2, beam_center,
				    &tmp[0], &tmp[1], tmp, &dist2 );
		      if (bsrc != BSSUCC) {
			__DBGpr_com("Problerms BSmdistptsf");
			sts = MSFAIL;
			goto wrapup;
		      }
		    }
		    
		    if (option == 0) {
		      /* The chosen surface is the closest to be
			 orthogonal to the beam axis and the 
			 closest to the beam center. */
		      if (dist1 < dist2) {
			*srf_to_int = *srf1_id;
			*bspexsrf   = srf1;
			*idxSurf    = indx_surf[j1];
			idx = j1;
		      }
		      else {	*srf_to_int = *srf2_id;
		      *bspexsrf   = srf2;
		      *idxSurf    = indx_surf[j2];
		      idx = j2;
		      }
		    }
		    else if (dist1 < dist2) {
		      /* The chosen surface is the closest 
			 to be orthogonal to the beam axis 
			 and the furthest to the beam center */
		      
		      *srf_to_int = *srf2_id ;
		      *bspexsrf   = srf2;
		      *idxSurf    = indx_surf[j2];
		      idx = j2;
		    }
		    else {	*srf_to_int = *srf1_id;
		    *bspexsrf   = srf1;
		    *idxSurf    = indx_surf[j1];
		    idx = j1;
		    }
                  }
		}
		else if (option == 2) {
		  /* If left web is more orthogonal to beam axis than
		     top superior flange, choose left web surface. */
		  if (angle[1] > angle[3]) {
		    *srf_to_int = surf[1];
		    *bspexsrf   = Srf[1];
		    *idxSurf    = indx_surf[1];
		    idx = 1;
		  }
		  else {	*srf_to_int = surf[3];
		  *bspexsrf   = Srf[3];
		  *idxSurf    = indx_surf[3];
		  idx = 3;
		  }
		}
		else {	if (angle[0] > angle[2]) {
		  /* If right web is more orthogonal 
		     to beam axis than bottom inferior 
		     flange, choose right web surface */ 
		  *srf_to_int = surf[0];
		  *bspexsrf   = Srf[0];
		  *idxSurf    = indx_surf[0];
		  idx = 0;
		}
		else {	*srf_to_int = surf[2];
		*bspexsrf   = Srf[2];
		*idxSurf    = indx_surf[2];
		idx = 2;
		}
		}
	}
	
	/* Extract chosen surface geometry */
	sts = vd_$get_geometry ( msg	  = &msg,
				 grobjId  = &srf_to_int->obj_id,
				 grobjEnv = &srf_to_int->mod_env,
				 geometry = (IGRchar **) &(*bspexsrf) );
	__CheckRC ( sts, msg, "vd_$get_geometry()", wrapup ) ;
	
	sts = MSSUCC;
	__DBGpr_obj("Surf to intersect ", srf_to_int->_grid );
	
 wrapup:
	if (Srf) {
	  for( i=0; i<4; i++ ) {
	    if (Srf[i]) {
	      _FREE (Srf[i]);
	      Srf[i] = NULL;
	    }
	  }
	}
	if (Bsf)	_FREE (Bsf);
	if (Tsf)	_FREE (Tsf);
	
	return sts;
} /* VSfind_surf_to_intersect */


/* -------------------------------------------------------- */
IGRlong VSfind_origin_pnt(
  TGRobj_env *Beam,
  TGRobj_env *BeamSrf,
  TGRobj_env *IntSrf,
  IGRchar  *webName,
  TGRvg_construct  *Cst,
  IGRpoint  pnt,
  IGRdouble *u,
  IGRdouble *v
)
{
  IGRlong l_ret = 0;
  IGRlong sts;
  IGRlong msg;

  struct  GRobj_env Web,Crv;

  IGRdouble t;

  IGRchar webPath[DI_PATH_MAX];

  /* Initialize */
  Crv.mod_env = *(Cst->env_info);
  Crv.obj_id.osnum = Crv.mod_env.md_id.osnum;
  Crv.obj_id.objid = NULL_OBJID;

  sprintf (webPath, "%s:%s:%s",
    VS_K_bmGrCmpName, VS_K_bmBody, webName);
  __DBGpr_str( "webPath ", webPath );
  
  sts = vd_$return_foot ( 
    msg     = &msg,
    name    =  webPath,
    objId   = &Beam->obj_id,
    objEnv  = &Beam->mod_env,
    footId  = &Web.obj_id,
    footEnv = &Web.mod_env 
  );
  __CheckRC ( sts, msg, "vd_$return_foot()", wrapup ) ;

  /* Intersect web surface with Top/Bottom surface */
  sts = VScsIntSrfSrf( 
    &msg, &Web, BeamSrf, &Crv.mod_env, &Crv.obj_id 
  );
  __CheckRC ( sts, msg, "VScsIntSrfSrf()", wrapup ) ;

  /* Intersect resulting curve with 2nd element surface */
  sts = VScsIntCrvSrf ( 
    &msg, &Crv, IntSrf, &Crv.mod_env, pnt, &t, u, v 
  );
  __CheckRC ( sts, msg, "VScsIntCrvSrf()", wrapup ) ;

  l_ret = 1;

wrapup:

  if (Crv.obj_id.objid != NULL_OBJID) {

    gr$delete_object ( 
      msg = &msg,
      object_id	= &Crv.obj_id,
      md_env	= &Crv.mod_env,
      display_flag = 0 
    );
  }
  return l_ret;
}


/* -------------------------------------------------------------------------- */
IGRlong	VSfind_origin
(
struct	GRobj_env	*Beam,	 /* I	Struct beam object		*/
struct	GRobj_env	*PlBm,	 /* I	Struct beam object		*/
struct	GRobj_env	*botS,	 /* I	Bottom inferior flange		*/
struct	GRobj_env	*topS,	 /* I	Top superior flange		*/
struct	GRobj_env	*Surf,	 /* I	Surface to intersect with *Beam	*/
struct	GRvg_construct	*Cst,	 /* I	Construction list		*/
	IGRint		Option,	 /* I	Option 1 in [0,5]		*/
	IGRint		Ulonger, /* I	0 -> iso along V is longer
					1 -> iso along U is longer	*/
	IGRdouble	*Origin, /* O	Coordinate system origin	*/
struct	GRparms		*Bparms, /* O	(u,v) parameter of the origin
						on the bottom flange inferior
						or the top flange superior 
						surface 		      */
struct	GRparms		*Sparms	 /* O	(u,v) parameter of the origin 
						on the surface to intersecte 
						with the beam		      */
)
{
  IGRlong l_ret = 0;
  IGRlong sts, msg;

  TGRobj_env *pSrf = NULL;

  IGRpoint  pnt,pntR,pntL;
  IGRint    i;
  IGRdouble u,uR,uL;
  IGRdouble v,vR,vL;

  /* Not Used */
  PlBm = PlBm;
  Ulonger = Ulonger;

  /* Top or bottom surface */
  switch(Option) {

    case 0: case 1: case 2: pSrf = botS; break;
    case 3: case 4: case 5: pSrf = topS; break;
    default: goto wrapup;
  }

  /* Foind Point */
  sts = 0;

  switch(Option) {
    case 0:
    case 3: 
      sts = VSfind_origin_pnt(Beam,pSrf,Surf,VS_K_nmWebL,Cst,pnt,&u,&v); 
    break;

    case 2:
    case 5: 
      sts = VSfind_origin_pnt(Beam,pSrf,Surf,VS_K_nmWebR,Cst,pnt,&u,&v); 
    break;

    case 1:
    case 4:
      sts = VSfind_origin_pnt(Beam,pSrf,Surf,VS_K_nmWebL,Cst,pntL,&uL,&vL); 
      __CheckRC ( sts, 1, "VSfind_origin_pnt()", wrapup ) ;
      sts = VSfind_origin_pnt(Beam,pSrf,Surf,VS_K_nmWebR,Cst,pntR,&uR,&vR); 
      __CheckRC ( sts, 1, "VSfind_origin_pnt()", wrapup ) ;
    
      /* Use Middle */
      pnt[0] = (pntL[0] + pntR[0]) / 2.0;
      pnt[1] = (pntL[1] + pntR[1]) / 2.0;
      pnt[2] = (pntL[2] + pntR[2]) / 2.0;
      u = (uL + uR) / 2.0;
      v = (vL + vR) / 2.0;
    break;
  }
  __CheckRC ( sts, 1, "VSfind_origin_pnt()", wrapup ) ;

  /* Gather resulting info */
  for ( i=0; i<3; i++ )	Origin[i] = pnt[i];
  if (Bparms) {
    sts = om$send (
      msg = message GRgraphics.GRptproject (
        &msg,
        &pSrf->mod_env.md_env.matrix_type,
         pSrf->mod_env.md_env.matrix,
	 Origin, pnt, Bparms 
      ),
      senderid = NULL_OBJID,
      targetid = pSrf->obj_id.objid,
      targetos = pSrf->obj_id.osnum 
    );
    __CheckRC ( sts, msg, "GRptproject", wrapup ) ;
  }
  if (Sparms) {
    Sparms->u = u;
    Sparms->v = v;
  }
  l_ret = 1;

wrapup:
  return l_ret;
}
/* -------------------------------------------------------------------------- */

/*---------------------------------------------------------------------------*/
long VSfind_xaxis(
	struct GRobj_env 	*bot_or_sup_surf,/*bottom inferior flange or
                                                   top superior flange of
                                                   the beam */
	struct IGRbsp_surface	*surface,   /* surface to intersecte with 
                                               the beam */
	struct  GRvg_construct  *cst,       /*I: construction list */
	int		        *options,   /*I: options chosen by the user */
	int	                web,         /*I: if web == 0, the u=0 iso curve
                                              of the bottom flange surface 
                                              is closest to web right, else
                                              it is closest to web left */
	int			u_is_longer, /*I: TRUE : iso in u is longer
						  FALSE: iso in v is longer*/
	struct GRparms          *beam_parms,/*I: (u,v) parameter of the origin
					         on the bottom flange inferior
						 or the top flange superior 
					 	 surface */
	struct GRparms          *srf_parms, /*I: (u,v) parameter of the origin 
                                                on the surface to intersecte 
                                                with the beam */
	double	      		*xaxis      /*O: xaxis */
        )
/*
 * this function find the xaxis of the coordinate system to create using
 * options given by the user.
 */
{
	long			loc_msg,msg,sts;
	int			i;
	long			j;
	struct IGRbsp_surface   *sf=NULL;
	struct IGRbsp_curve     *cv=NULL;
	double			tmp[13];
	double			dot;
	GRobjid			*iso_objid=NULL;
	struct GRid		iso;
	IGRuchar		props;
	BSrc			bsrc;
	double   	dbl;
	int		bool;

	msg = MSFAIL;

	if (options[3] == 0) {
		/*
		 * xaxis is tangent to the beam (input1) 
		 */
		if (options[2] == 0) {
			/*
			 * xaxis points from bottom flange to top flane
			 */
			sts = om$send(msg = message GRvg.GRgenabsg(
						&loc_msg,
						&cst->env_info->md_env.matrix_type,
						cst->env_info->md_env.matrix,
						(IGRchar **)&sf),
					senderid = NULL_OBJID,
					targetid = bot_or_sup_surf->obj_id.objid,
					targetos = bot_or_sup_surf->obj_id.osnum );
			if (!(loc_msg&sts&1)) {
				goto wrapup;
			}
			BSsfevaln( sf, beam_parms->u, beam_parms->v,
				   1,&i,tmp,(IGRvector *)xaxis,&bsrc);
			if (bsrc != BSSUCC) {
				__DBGpr_com("PBS dans BSsfevaln");
				goto wrapup;
			}
			/*
			 *  Check the surface orientation 
			 */
			sts = om$send ( msg = message EMSsubbs.EMget_props (
							&loc_msg,
							&props),
					senderid = NULL_OBJID,
					targetid = bot_or_sup_surf->obj_id.objid,
					targetos = bot_or_sup_surf->obj_id.osnum );
			if (!(sts&loc_msg&1)) {
				__DBGpr_com("PBS EMSsubbs.EMget_props");
				goto wrapup;
			}
			if (options[1] >= 3)
			{
				if (!(props & EMSIS_NRML_REVERSED)) 
				{
					xaxis[0] = -xaxis[0];
					xaxis[1] = -xaxis[1];
					xaxis[2] = -xaxis[2];
				}
			} else {
				if ((props & EMSIS_NRML_REVERSED)) 
				{
					xaxis[0] = -xaxis[0];
					xaxis[1] = -xaxis[1];
					xaxis[2] = -xaxis[2];
				}
			}
		} else {
			/*
			 * xaxis points from web left to web right
			 */
			if (u_is_longer) {
				dbl = beam_parms->v;
				bool = FALSE;
			} else {
				dbl = beam_parms->u;
				bool = TRUE; 
			}
			sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
						&loc_msg,
						&(bot_or_sup_surf->mod_env.md_env.matrix_type),
						bot_or_sup_surf->mod_env.md_env.matrix,
						cst,
						FALSE,
						1,
						&dbl,
						bool,
						&j,
						&iso_objid),
						senderid  = NULL_OBJID,
					targetid  = bot_or_sup_surf->obj_id.objid,
					targetos  = bot_or_sup_surf->obj_id.osnum );
			if (!(sts&loc_msg&1)) {
				__DBGpr_com("EMSsubbs.EMisoparcvs Failed");
				goto wrapup;
			}
			iso.objid = *iso_objid;
			iso.osnum = cst->env_info->md_id.osnum;
			_FREECV ( &bsrc, cv );
			sts = om$send(msg = message GRvg.GRgenabsg(
						&loc_msg,
						&cst->env_info->md_env.matrix_type,
						cst->env_info->md_env.matrix,
						(IGRchar **)&cv),
				senderid = NULL_OBJID,
				targetid = iso.objid,
				targetos = iso.osnum );
			if (!(loc_msg&sts&1)) {
				goto wrapup;
			}
			BScveval( cv, beam_parms->u, 1, 
				  (IGRpoint *)tmp, &bsrc );
			if (bsrc != BSSUCC) goto wrapup;
			xaxis[0] = tmp[3];
			xaxis[1] = tmp[4];
			xaxis[2] = tmp[5];
			if ((!web && options[1] < 3) || 
			    (web && options[1] >= 3)) {
				xaxis[0] = -tmp[3];
				xaxis[1] = -tmp[4];
				xaxis[2] = -tmp[5];
			}
		}
	} else {
		/*
		 * xaxis is tangent to the profile intersection beam/surface.
		 */
		if (options[2] == 0) {
			/*
			 * xaxis points from bottom flange to top flane
			 */
			 if (u_is_longer) {
				dbl = beam_parms->v;
				bool = FALSE;
			} else {
				dbl = beam_parms->u;
				bool = TRUE; 
			}
			sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
						&loc_msg,
						&(bot_or_sup_surf->mod_env.md_env.matrix_type),
						bot_or_sup_surf->mod_env.md_env.matrix,
						cst,
						FALSE,
						1,
						&dbl,
						bool,
						&j,
						&iso_objid),
				senderid  = NULL_OBJID,
				targetid  = bot_or_sup_surf->obj_id.objid,
				targetos  = bot_or_sup_surf->obj_id.osnum );
			if (!(sts&loc_msg&1)) {
				__DBGpr_com("EMSsubbs.EMisoparcvs Failed");
				goto wrapup;
			}
			iso.objid = *iso_objid;
			iso.osnum = cst->env_info->md_id.osnum;
			_FREECV ( &bsrc, cv );
			sts = om$send(msg = message GRvg.GRgenabsg(
						&loc_msg,
						&cst->env_info->md_env.matrix_type,
						cst->env_info->md_env.matrix,
						(IGRchar **)&cv),
					senderid = NULL_OBJID,
					targetid = iso.objid,
					targetos = iso.osnum );
			if (!(loc_msg&sts&1)) {
				goto wrapup;
			}
			BScveval( cv, beam_parms->u, 1, 
					(IGRpoint *)tmp, &bsrc );
			if (bsrc != BSSUCC) goto wrapup;
			BSsfevaln( surface, srf_parms->u, srf_parms->v,
				  1,&i,&tmp[6],(IGRvector *)&tmp[9],&bsrc);
			if (bsrc != BSSUCC) {
				__DBGpr_com("PBS dans BSsfevaln");
				goto wrapup;
			}
			{ 
			IGRboolean loc_sts = 0;
			loc_sts = BScrossp(&bsrc,&tmp[3],&tmp[9],xaxis);
			}
			if (bsrc != BSSUCC) goto wrapup;
			_FREESF ( &bsrc, sf );
			sts = om$send(msg = message GRvg.GRgenabsg(
						&loc_msg,
						&cst->env_info->md_env.matrix_type,
						cst->env_info->md_env.matrix,
						(IGRchar **)&sf),
				senderid = NULL_OBJID,
				targetid = bot_or_sup_surf->obj_id.objid,
				targetos = bot_or_sup_surf->obj_id.osnum );
			if (!(loc_msg&sts&1)) {
				goto wrapup;
			}
			BSsfevaln(sf, beam_parms->u, beam_parms->v,
				  1,&i,tmp,(IGRvector *)&tmp[3],&bsrc);
			if (bsrc != BSSUCC) {
				__DBGpr_com("PBS dans BSsfevaln");
				goto wrapup;
			}
			/*
			 *  Check the surface orientation 
			 */
			sts = om$send ( msg = message EMSsubbs.EMget_props(
							&loc_msg,
							&props),
					senderid = NULL_OBJID,
					targetid = bot_or_sup_surf->obj_id.objid,
					targetos = bot_or_sup_surf->obj_id.osnum );
			if (!(sts&loc_msg&1)) {
				__DBGpr_com("PBS EMSsubbs.EMget_props");
				goto wrapup;
			}
			if ((props & EMSIS_NRML_REVERSED)) {
				tmp[3] = -tmp[3];
				tmp[4] = -tmp[4];
				tmp[5] = -tmp[5];
			}
			dot = BSdotp(&bsrc,xaxis,&tmp[3]);
			if (bsrc != BSSUCC) goto wrapup;
			if ( (dot>0 && options[1] >= 3) || 
			     (dot<0 && options[1] < 3) ) {
				xaxis[0] = -xaxis[0];
				xaxis[1] = -xaxis[1];
				xaxis[2] = -xaxis[2];
			}
		} else {
			/*
			 * xaxis points from web left to web right
			 */
			_FREESF ( &bsrc, sf );
			sts = om$send(msg = message GRvg.GRgenabsg(
						&loc_msg,
						&cst->env_info->md_env.matrix_type,
						cst->env_info->md_env.matrix,
						(IGRchar **)&sf),
				senderid = NULL_OBJID,
				targetid = bot_or_sup_surf->obj_id.objid,
				targetos = bot_or_sup_surf->obj_id.osnum );
			if (!(loc_msg&sts&1)) {
				goto wrapup;
			}
			BSsfevaln( sf, beam_parms->u, beam_parms->v,
				   1,&i,tmp,(IGRvector *)&tmp[3],&bsrc);
			if (bsrc != BSSUCC) {
				__DBGpr_com("PBS dans BSsfevaln");
				goto wrapup;
			}
			BSsfevaln( surface, srf_parms->u, srf_parms->v,
				     1,&i,tmp,(IGRvector *)&tmp[6],&bsrc);
			if (bsrc != BSSUCC) {
			__DBGpr_com("PBS dans BSsfevaln");
			goto wrapup;
			}
			{ 
			IGRboolean loc_sts = 0;
			loc_sts = BScrossp(&bsrc,&tmp[3],&tmp[6],xaxis);
			}
			if (bsrc != BSSUCC) goto wrapup;
			sts = VSfind_webL_webR_vec( bot_or_sup_surf,beam_parms,
							web, u_is_longer,
							options,cst,tmp);
			if (!(sts&1)) goto wrapup;
			dot = BSdotp(&bsrc,xaxis,tmp);
			if (bsrc != BSSUCC) goto wrapup;
			if (dot<0) {
				xaxis[0] = -xaxis[0];
				xaxis[1] = -xaxis[1];
				xaxis[2] = -xaxis[2];
			}
		}
	}
	{ 
	IGRboolean loc_sts = 0;
	loc_sts = BSnorvec(&bsrc,xaxis);
	}

if (bsrc != BSSUCC) goto wrapup;
       
msg = MSSUCC;

wrapup :
	if (iso.objid != NULL_OBJID)
		om$send( msg      = message GRgraphics.GRdelete(
					&loc_msg, 
					cst->env_info),
			senderid = NULL_OBJID,
			targetid = iso.objid,
			targetos = iso.osnum);
	if (iso_objid) {free (iso_objid); iso_objid = NULL;}

	return msg;

} /* VSfind_xaxis */
/*---------------------------------------------------------------------------*/
long VSfind_yaxis(
	struct GRobj_env       *bot_or_sup_surf,/* bottom inferior flange or
						    top superior flange of
						    the beam */
	struct IGRbsp_surface  *surface,   /* surface to intersecte with 
                                               the beam */
	double		       *xaxis,     /*I: xaxis */
	double		       *beam_center,/*I: beam center */
	struct  GRvg_construct *cst,       /*I: construction list */
	int		       *options,    /*I: options chosen by the user */
	int	               web,         /*I: if web == 0, the u=0 iso curve
                                              of the bottom flange surface 
                                              is closest to web right, else
                                              it is closest to web left */
	int		       u_is_longer, /*I: TRUE : iso in u is longer
						  FALSE: iso in v is longer*/
	struct GRparms         *beam_parms,/*I: (u,v) parameter of the origin
					         on the bottom flange inferior
						 or the top flange superior 
					 	 surface */
	struct GRparms         *srf_parms, /*I: (u,v) parameter of the origin 
                                                on the surface to intersecte 
                                                with the beam */
	double	      	       *yaxis      /*O: yaxis */
        )
/*
 * this function find the yaxis of the coordinate system to create using
 * options given by the user.
 */
{
	long		msg,loc_msg,sts;
	int		i;
	long		j;
	GRobjid			*iso_objid=NULL;
	struct IGRbsp_curve	*cv=NULL;
	struct GRid		iso;
	double			dot,tmp[12],vec[3];
	BSrc			bsrc;
	struct IGRbsp_surface   *sf=NULL;
	double   	dbl;
	int		bool;

	msg = MSFAIL;

	if (options[3] == 0) {
		/*
		 * xaxis is tangent to the beam (input1)
		 */
		if (options[4] == 0 || (options[4] != 0 && options[2] != 0)) 
		{
			/*
			 * yaxis is tangent to beam1 pointing toward 
			 * beam center
			 */
			if (options[2] == 0) {
				/*
				 * xaxis points from bottom flange to 
				 * top flange
				 */
				if (u_is_longer) {
					dbl = beam_parms->u;
					bool = TRUE;
				} else {
					dbl = beam_parms->v;
					bool = FALSE; 
				}
				sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
						&loc_msg,
						&(bot_or_sup_surf->mod_env.md_env.matrix_type),
						bot_or_sup_surf->mod_env.md_env.matrix,
						cst,
						FALSE,
						1,
						&dbl,
						bool,
						&j,
						&iso_objid ) ,
					senderid  = NULL_OBJID,
					targetid  = bot_or_sup_surf->obj_id.objid,
					targetos  = bot_or_sup_surf->obj_id.osnum );
				if (!(sts&loc_msg&1)) {
					__DBGpr_com("EMSsubbs.EMisoparcvs Failed");
					goto wrapup;
				}
				iso.objid = *iso_objid;
				iso.osnum = cst->env_info->md_id.osnum;
				_FREECV ( &bsrc, cv );
				sts = om$send(msg = message GRvg.GRgenabsg(
     							&loc_msg,
							&cst->env_info->md_env.matrix_type,
							cst->env_info->md_env.matrix,
							(IGRchar **)&cv),
					senderid = NULL_OBJID,
					targetid = iso.objid,
					targetos = iso.osnum );
				if (!(loc_msg&sts&1)) {
					goto wrapup;
				}
				BScveval( cv, beam_parms->v,1,(IGRpoint *)tmp, &bsrc );
				if (bsrc != BSSUCC) goto wrapup;
				vec[0] = beam_center[0] - tmp[0];
				vec[1] = beam_center[1] - tmp[1];
				vec[2] = beam_center[2] - tmp[2];
				dot = BSdotp(&bsrc,vec,&tmp[3]);
				if (bsrc != BSSUCC) goto wrapup;
				if (dot < 0) {
					yaxis[0] = -tmp[3];
					yaxis[1] = -tmp[4];
					yaxis[2] = -tmp[5];
				} else {
					yaxis[0] = tmp[3];
					yaxis[1] = tmp[4];
					yaxis[2] = tmp[5];
				}
			} else {
				/*
				 * xaxis points from web left to web right
				 */
				_FREESF ( &bsrc, sf );
				sts = om$send(msg = message GRvg.GRgenabsg(
							&loc_msg,
							&cst->env_info->md_env.matrix_type,
							cst->env_info->md_env.matrix,
							(IGRchar **)&sf),
					senderid = NULL_OBJID,
					targetid = bot_or_sup_surf->obj_id.objid,
					targetos = bot_or_sup_surf->obj_id.osnum );
				if (!(loc_msg&sts&1)) {
					goto wrapup;
				}
				BSsfevaln( sf, 
					   beam_parms->u, 
					   beam_parms->v,
					   1, 
					   &i, 
					   tmp,
					   (IGRvector *)&tmp[3], 
					   &bsrc ) ;
				if (bsrc != BSSUCC) {
					__DBGpr_com("PBS dans BSsfevaln");
					goto wrapup;
				}
				{
				IGRboolean loc_sts = 0;
				loc_sts = BScrossp(&bsrc,xaxis,&tmp[3],yaxis);
				}
				if (bsrc != BSSUCC) goto wrapup;
				vec[0] = beam_center[0] - tmp[0];
				vec[1] = beam_center[1] - tmp[1];
				vec[2] = beam_center[2] - tmp[2];
				dot = BSdotp(&bsrc,vec,yaxis);
				if (bsrc != BSSUCC) goto wrapup;
				if (dot<0) {
					yaxis[0] = -yaxis[0];
					yaxis[1] = -yaxis[1];
					yaxis[2] = -yaxis[2];
				} 
			}
		} else {
			/*
			 * yaxis is tangent to beam1 pointing from 
			 * web left to web right
			 */

			sts = VSfind_webL_webR_vec( bot_or_sup_surf,
						    beam_parms,
						    web,
						    u_is_longer,
						    options,
						    cst,
						    tmp ) ;
			if (!(sts&1)) goto wrapup;
			yaxis[0]=tmp[0];
			yaxis[1]=tmp[1];
			yaxis[2]=tmp[2];
     		}
	} else {
		/*
		 * xaxis is tangent to the surface to intersect
		 */
		if (options[4] == 0 || (options[4] != 0 && options[2] != 0)) 
		{
			/*
			 * yaxis is tangent to beam1 pointing toward 
			 * beam center
			 */
			if (options[2] == 0) {
				/*
				 * xaxis points from bottom flange to 
				 * top flange
				 */
				if (u_is_longer) {
					dbl = beam_parms->v;
					bool = FALSE;
				} else {
					dbl = beam_parms->u;
					bool = TRUE; 
				}
				sts = om$send(
					msg = message EMSsubbs.EMisoparcvs  (
							&loc_msg,
							&(bot_or_sup_surf->mod_env.md_env.matrix_type),
							bot_or_sup_surf->mod_env.md_env.matrix,
							cst,
							FALSE,
							1,
							&dbl,
							bool,
							&j,
							&iso_objid),
					senderid  = NULL_OBJID,
					targetid  = bot_or_sup_surf->obj_id.objid,
					targetos  = bot_or_sup_surf->obj_id.osnum );
				if (!(sts&loc_msg&1)) {
					__DBGpr_com("EMSsubbs.EMisoparcvs Failed");
					goto wrapup;
				}
				iso.objid = *iso_objid;
				iso.osnum = cst->env_info->md_id.osnum;
				_FREECV ( &bsrc, cv );
				sts = om$send(msg = message GRvg.GRgenabsg(
							&loc_msg,
							&cst->env_info->md_env.matrix_type,
							cst->env_info->md_env.matrix,
							(IGRchar **)&cv),
						senderid = NULL_OBJID,
						targetid = iso.objid,
						targetos = iso.osnum );
				if (!(loc_msg&sts&1)) {
					goto wrapup;
				}
				BScveval( cv, beam_parms->u, 
						1, (IGRpoint *)tmp, &bsrc );
				{ 
				IGRboolean loc_sts = 0;
				loc_sts = BScrossp(&bsrc,xaxis,&tmp[3],yaxis);
				}
				if (bsrc != BSSUCC) goto wrapup;
				vec[0] = beam_center[0] - tmp[0];
				vec[1] = beam_center[1] - tmp[1];
				vec[2] = beam_center[2] - tmp[2];
				dot = BSdotp(&bsrc,vec,yaxis);
				if (bsrc != BSSUCC) goto wrapup;
				if (dot<0) {
				yaxis[0] = -yaxis[0];
				yaxis[1] = -yaxis[1];
				yaxis[2] = -yaxis[2];
				} 
			} else {
				/*
				 * xaxis points from web left to web right
				 */
				_FREESF ( &bsrc, sf );
				sts = om$send(msg = message GRvg.GRgenabsg(
							&loc_msg,
							&cst->env_info->md_env.matrix_type,
							cst->env_info->md_env.matrix,
							(IGRchar **)&sf),
					senderid = NULL_OBJID,
					targetid = bot_or_sup_surf->obj_id.objid,
					targetos = bot_or_sup_surf->obj_id.osnum );
				if (!(loc_msg&sts&1)) {
					goto wrapup;
				}
				BSsfevaln( sf, beam_parms->u, beam_parms->v,
						1, &i, tmp,
						(IGRvector *)&tmp[3], &bsrc);
				if (bsrc != BSSUCC) {
					__DBGpr_com("PBS dans BSsfevaln");
					goto wrapup;
				}
				{ 
				IGRboolean loc_sts = 0;
				loc_sts = BScrossp(&bsrc,xaxis,&tmp[3],yaxis);
				}
				if (bsrc != BSSUCC) goto wrapup;
				vec[0] = beam_center[0] - tmp[0];
				vec[1] = beam_center[1] - tmp[1];
				vec[2] = beam_center[2] - tmp[2];
				dot = BSdotp(&bsrc,vec,yaxis);
				if (bsrc != BSSUCC) goto wrapup;
				if (dot<0) {
					yaxis[0] = -yaxis[0];
					yaxis[1] = -yaxis[1];
					yaxis[2] = -yaxis[2];
				} 
			}
		} else {
			/*
			 * yaxis is tangent to the profile intersection 
			 * beam/surface
			 */
			BSsfevaln( surface, srf_parms->u, srf_parms->v,
				   1, &i, tmp, (IGRvector *)&tmp[3], &bsrc);
			if (bsrc != BSSUCC) {
				__DBGpr_com("PBS dans BSsfevaln");
				goto wrapup;
			}
			{ 
			IGRboolean loc_sts = 0;
			loc_sts = BScrossp(&bsrc,xaxis,&tmp[3],yaxis);
			}
			if (bsrc != BSSUCC) goto wrapup;
			sts = VSfind_webL_webR_vec(
						bot_or_sup_surf,
						beam_parms,
						web,
						u_is_longer,
						options,
						cst,
						tmp);
			if (!(sts&1)) goto wrapup;
			dot = BSdotp(&bsrc,tmp,yaxis);
			if (bsrc != BSSUCC) goto wrapup;
			if (dot<0) {
				yaxis[0] = -yaxis[0];
				yaxis[1] = -yaxis[1];
				yaxis[2] = -yaxis[2];
			} 
		}
	}
	{ 
	IGRboolean loc_sts = 0;
	loc_sts = BSnorvec(&bsrc,yaxis);
	}
	if (bsrc != BSSUCC) goto wrapup;

	msg = MSSUCC;

wrapup :
	if (iso.objid != NULL_OBJID)
		om$send( msg      = message GRgraphics.GRdelete(
						&loc_msg, 
						cst->env_info),
			senderid = NULL_OBJID,
			targetid = iso.objid,
			targetos = iso.osnum);
	_FREE (iso_objid);
	
	return msg;
} /* VSfind_yaxis */

end implementation VShelper;
