/* $Id: VDi2eOrg.I,v 1.2 2001/07/23 22:13:44 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl/VDi2eOrg.I
 *
 * Description: Intersect 2 elements routines
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDi2eOrg.I,v $
 *	Revision 1.2  2001/07/23 22:13:44  hans
 *	Inconsistent use of _MALLOC/_FREE
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/25  15:06:38  pinnacle
# ah
#
# Revision 1.1  1997/10/28  17:42:50  pinnacle
# ah Int 2 element changes
#
# Revision 1.3  1997/03/03  17:39:12  pinnacle
# ah
#
# Revision 1.2  1997/02/27  22:51:06  pinnacle
# ah
#
# Revision 1.1  1996/10/29  17:53:08  pinnacle
# Intersect 2 Elements API
#
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/29/96	ah		creation
 *      06/13/97        ah              Added Drop Graphic Group
 *      08/30/97        ah              Intersect Bounded Plane
 *					with infinite plane speedup
 *      11/30/97	ah		VDmaster.h added
 *
 * Getting really deep here but noticed that when intersecting a plane
 * against a surface, the trim required was not always getting set
 * In the case of 3 composite planes, the curve would be extended a bit
 * Changed SURF_PLANE.VDintSrfPlInf to set TrimRequired = TRUE
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include "VDmaster.h"

#include "bsconic.h"
#include "bsplptnorrg.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bsxln.h"
#include "bsxlnpl.h"
#include "bsmklnintbx.h"
#include "bspl_pl.h"
#include "bsallocsf.h"
#include "bsfreesf.h"
#include "bsnorvec.h"
#include "bssf_copy.h"

#include "emssfintdef.h"

#include "vdAPImacros.h"
#include "vdintproto.h"

from GRvg		import GRgetsize, GRgetgeom, GRgetexsize, GRgetexgeom,
			       GRdetplane, EMintplane ;

from GRgraphics		import GRdisplay, GRcptform, GRdelete, GRgetrang,
			       GRptproject, GRconstruct, GRcopy ;
from GRvg		import GRgeomprops, GRgenabsg ;
from GRowner		import GRget_number_components, GRget_components,
			       GRdrop      ;

from GR3dpoint		import GRaltconstruct;
from GR3dlineseg	import GRaddpts;

from GRlinear		import GRgetpolyline;
from GRcurve		import GRendpts    ;
from GRbcsubbc		import EMleast_squares_fit_curvee ;

from NDnode		import ASreturn_go ;
from NDmacro		import ACconsume, ACreturn_foot   ;
from NDnodein		import ACunconsume ;

from EMSproject		import EMplace_surface_of_projection ;
from EMSsubbs		import EMtangent_normal ;
from EMSsurface		import EMdelete_boundary;
from EMSplane		import EMplane;

/*
	Definition of our intersection states table
 */

enum IntStatesTable {
	PLANE_PLANE, PLANE_SURF, PLANE_LINE, PLANE_CURVE,
	SURF_PLANE,  SURF_SURF,  SURF_LINE,  SURF_CURVE,
	LINE_PLANE,  LINE_SURF,  LINE_LINE,  LINE_CURVE,
	CURVE_PLANE, CURVE_SURF, CURVE_LINE, CURVE_CURVE,
	PLANE_UNKNOWN, UNKNOWN_PLANE
	} ;

extern 		ASsuper_construct() ;

extern IGRint	IntTwoSrf() ;

extern		GRabsg_del_by_objid() ;
extern 		GRdisplay_object()  ;
extern		GRdpb_get() ;
extern		pr_mat() ;
extern	long	VDSapplyDataReduction();

extern GRclassid OPP_EMSplane_class_id    ;
extern GRclassid OPP_EMSsurface_class_id  ;
extern GRclassid OPP_GR3dlineseg_class_id ;
extern GRclassid OPP_GR3dinfline_class_id ;	/* 92/06/03 */
extern GRclassid OPP_GRcurve_class_id     ;
extern GRclassid OPP_EMSsfimpbnd_class_id, OPP_EMSsubbs_class_id ;
extern GRclassid OPP_GRgrgrp_class_id;

/* ---------------------------------------------------------------
 * This is the customer interface to the intersect 2 elements
 * command.
 */
IGRlong  VDint2elem(
  struct GRobj_env      *obj_env1,
  struct GRobj_env      *obj_env2,
  IGRint	        Trim1Req,
  IGRint                Trim2Req,
  IGRboolean 		AppRequired,
  IGRint                *num_inter,
  struct GRid 	       **GRid_tab)
{
  struct GRid GRid_int[256];
  IGRlong sts,msg;
  int i;

  struct GRmd_env md_env;
  IGRint          md_env_size;
  IGRint          md_env_rec;

  // Need Module Env Later */
  md_env_size = sizeof( struct GRmd_env );
  gr$get_module_env(
    msg     = &msg,
    sizbuf  = &md_env_size,
    buffer  = &md_env,
    nret    = &md_env_rec
  );

  // Intersect Them
  sts = VDint2elemInternal(
    obj_env1,
    obj_env2,
    (struct GRid*)NULL,
    (struct GRid*)NULL,
    Trim1Req,Trim2Req,AppRequired,
    &md_env,
     num_inter,
    &GRid_int[0]);

  if (!(sts & 1))       return sts;
  if (*num_inter == 0)  return sts;

  /* --------------------------------------------------------
   * In some cases, multiple solutions are returned as graphic
   * groups.  Drop em (copied from IntTwoSrf)
   */

  if (vd_$is_ancestry_valid(
    object = &GRid_int[0],
    classid = OPP_GRgrgrp_class_id ))
  {
    IGRint  num_comp = 0;
    IGRint  num_ret;
    IGRlong msg;
    struct  GRid grpId = GRid_int[0];

    sts = om$send(
      msg = message GRowner.GRget_number_components(&msg, &num_comp ),
      senderid = NULL_OBJID,
      targetid = grpId.objid,
      targetos = grpId.osnum
    );
    if (!(sts & msg & 1)) return 0;

    sts = om$send(
      msg = message GRowner.GRget_components(
        &msg,
        &md_env,
	&GRid_int[0],
         num_comp,
	&num_ret,
       (IGRint) 0,
       (IGRint) 256
      ),
      senderid = NULL_OBJID,
      targetid = grpId.objid,
      targetos = grpId.osnum
    );
    if (!(sts & msg & 1)) return 0;

    sts = om$send(
      msg = message GRowner.GRdrop(&msg,&md_env),
      senderid = NULL_OBJID,
      targetid = grpId.objid,
      targetos = grpId.osnum
    );
    if (!(sts & msg & 1)) return 0;

    *num_inter = num_ret;
/*
    printf("Dropped %d items from graphic group\n",num_ret);
*/
  }

  if (*num_inter == 0)    return 0;
  if (GRid_tab   == NULL) return 0; /* Really should delete graphics */

  // HF: 07/23/2001 - Inconsistent use of _MALLOC / _FREE
  //*GRid_tab = (struct GRid *)malloc((*num_inter) * sizeof(struct GRid));
  *GRid_tab = _MALLOC( *num_inter, struct GRid );
  if (*GRid_tab == NULL) return 0;

  for(i = 0; i < *num_inter; i++)
  {
    (*GRid_tab)[i].objid = GRid_int[i].objid;
    (*GRid_tab)[i].osnum = GRid_int[i].osnum;
  }

  return sts;
}

/* ---------------------------------------------------------------
 *
 * Fills in lc_obj data from GRobj_env
 */
int VDintSetLcObjFromObjEnv(
  struct GRobj_env  *obj_env,
  struct GRlc_info  *lc_obj,
  OMuword           *temp_cl)
{
  IGRlong msg,sts;
  IGRint  i;
  IGRchar name[32];

  // Ignore NULLs, assume GRid was passed
  if (obj_env == NULL) return 1;

  // Gets the geometry
  sts = om$send(
    msg = message NDmacro.ACreturn_foot(
      &msg,
      ".",
      &lc_obj->located_obj,
       NULL,NULL
    ),
    senderid = NULL_OBJID,
    targetid = obj_env->obj_id.objid,
    targetos = obj_env->obj_id.osnum
  );

  if (!(sts & msg & 1)) {
    sts = om$send(
      msg = message NDnode.ASreturn_go(
        &lc_obj->located_obj,
        NULL,NULL
      ),
      senderid = NULL_OBJID,
      targetid = obj_env->obj_id.objid,
      targetos = obj_env->obj_id.osnum
    );
  }
  if (!(sts & 1)) {
    lc_obj->located_obj = obj_env->obj_id;
  }

  // Ignore matrix from ACreturn_foot, used the one in obj_env
  lc_obj->module_info.md_id.objid = obj_env->mod_env.md_id.objid;
  lc_obj->module_info.md_id.osnum = obj_env->mod_env.md_id.osnum;

  lc_obj->module_info.md_env.matrix_type = obj_env->mod_env.md_env.matrix_type;
  for(i = 0; i < 16; i++) {
    lc_obj->module_info.md_env.matrix[i] = obj_env->mod_env.md_env.matrix[i];
  }

  om$get_classid(
    osnum     = lc_obj->located_obj.osnum,
    objid     = lc_obj->located_obj.objid,
    p_classid = temp_cl	) ;

  om$get_classname(
    osnum     = lc_obj->located_obj.osnum,
    objid     = lc_obj->located_obj.objid,
    classname = name
  ) ;
/*
  printf(
    "Intersect: %d,%d %s\n",
    lc_obj->located_obj.osnum,
    lc_obj->located_obj.objid,
    name
  );
*/
  return 1;
}

/* ---------------------------------------------------------------
 *
 * Fills in lc_obj data from GRid
 */
int VDintSetLcObjFromId(
  struct GRid       *id,
  struct GRlc_info  *lc_obj,
  OMuword           *temp_cl)
{
  IGRlong msg,sts;

  // Ignore NULLs, assume GRobj_env was passed
  if (id == NULL) return 1;

  // Gets the geometry
  sts = om$send(msg = message NDmacro.ACreturn_foot(
      &msg,
      ".",
      &lc_obj->located_obj,
      &lc_obj->module_info.md_env.matrix_type,
       lc_obj->module_info.md_env.matrix),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum );

  as$status(sts = sts);
  if (!(sts & msg & 1)) {
    printf("Problem in VDintSetLcObjFromId, ACreturn_foot\n");
    return 0;
  }

  lc_obj->module_info.md_id.osnum = lc_obj->located_obj.osnum;
  ex$get_modid(	mod_osnum =  lc_obj->module_info.md_id.osnum,
	        mod_id    = &lc_obj->module_info.md_id.objid) ;

  om$get_classid(
    osnum     = lc_obj->located_obj.osnum,
    objid     = lc_obj->located_obj.objid,
    p_classid = temp_cl	) ;

  return 1;
}

/* =========================================================================
 * This is the internal use function for intersecting two elements.
 * You can pass it either GRobj_env (from a user written ppl) or
 * assoc GRid from nci_macros
 */

IGRlong
VDint2elemInternal(
  struct GRobj_env      *obj_env1,
  struct GRobj_env      *obj_env2,
  struct GRid      	*id1,
  struct GRid      	*id2,
  IGRint	        Trim1Req,
  IGRint                Trim2Req,
  IGRboolean 		AppRequired,
  struct GRmd_env	*MOD_ENV,
  IGRint                *num_inter,
  struct GRid 	        *GRid_tab)
{
// Symbology
struct GRvg_construct   cst ;
struct IGRdisplay	dis ;

OMuword	 		temp_cl[2]   ;
struct GRlc_info        lc_obj[2]    ; /* graphic obj or construction */

enum IntStatesTable	int_state    ; /* indicate the type of intersection */

IGRboolean TrimRequired;

/* 92/03/05 : trimmed-surfaces support */
struct GRlc_info	to_be_del[2]  ;
IGRint			count_copysrf ; /* 0, 1 or 2 */

/* 92/05/07 : extended curve support */
struct GRlc_info	del_extcrv[2] ;
IGRint			count_extcrv  ; /* 0, 1 or 2 */

IGRlong			sts,msg;
IGRint			rc_intersect ;

/* Active Module Env */
struct	GRmd_env	curMOD_ENV;
IGRint                  NumberOfBytes;
IGRint                  BytesReceived;

  /*
	Get current symbology, and begin to set construction list
   */

  count_copysrf = 0 ; /* Initialization for non-trimmed surfaces support    */
								/* 92/03/05 */

  count_extcrv  = 0 ; /* Initialization for extended curves (92/05/07)      */

  ASget_active_symb(&cst.level,&dis);

  if (MOD_ENV == NULL) {

    MOD_ENV = &curMOD_ENV;

    NumberOfBytes = sizeof( struct GRmd_env );

    gr$get_module_env(
      msg     = &msg,
      sizbuf  = &NumberOfBytes,
      buffer  =  MOD_ENV,
      nret    = &BytesReceived );
  }

  cst.msg		= &msg;
  cst.properties	= GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
  cst.display		= &dis;
  cst.env_info		= MOD_ENV;
  cst.newflag		= 0;
  cst.geometry		= NULL;
  cst.class_attr	= 0;
  cst.name		= 0;

  rc_intersect = 0;
  *num_inter   = 0;

  // Fill in lc_obj info, assume two objects are passed
  if (!VDintSetLcObjFromObjEnv(obj_env1,&lc_obj[0],&temp_cl[0])) goto wrapup;
  if (!VDintSetLcObjFromObjEnv(obj_env2,&lc_obj[1],&temp_cl[1])) goto wrapup;

  if (!VDintSetLcObjFromId(id1,&lc_obj[0],&temp_cl[0])) goto wrapup;
  if (!VDintSetLcObjFromId(id2,&lc_obj[1],&temp_cl[1])) goto wrapup;

  /*
	Set intersection states table flag
   */

 /* ---> 92/06/03 kludge */
	if (temp_cl[0] == OPP_GR3dinfline_class_id)
			temp_cl[0] = OPP_GR3dlineseg_class_id ;
	if (temp_cl[1] == OPP_GR3dinfline_class_id)
			temp_cl[1] = OPP_GR3dlineseg_class_id ;
 /* <--- 92/06/03 kludge */


  while (1) {

	if (VDintCheckAncestry(OPP_EMSplane_class_id, OPP_EMSplane_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = PLANE_PLANE ; break ;
		}
	if (VDintCheckAncestry(OPP_EMSplane_class_id, OPP_EMSsurface_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = PLANE_SURF ; break ;
		}
	if (VDintCheckAncestry(OPP_EMSplane_class_id, OPP_GR3dlineseg_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = PLANE_LINE ; break ;
		}

	if (VDintCheckAncestry(OPP_EMSplane_class_id, OPP_GRcurve_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = PLANE_CURVE ;
		if (Trim2Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[1]) ;
			if (!(sts & 1))
				count_extcrv = 0 ;
			else {
				count_extcrv  = 1 ;
				del_extcrv[0] = lc_obj[1] ;
				}
			} /* if */
		break ;
		}

	if (VDintCheckAncestry(OPP_EMSsurface_class_id, OPP_EMSplane_class_id,
						temp_cl[0], temp_cl[1])) {

		int_state = SURF_PLANE ; break ;
		}
	if (VDintCheckAncestry(OPP_EMSsurface_class_id, OPP_EMSsurface_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = SURF_SURF ;  break ;
		}
	if (VDintCheckAncestry(OPP_EMSsurface_class_id, OPP_GR3dlineseg_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = SURF_LINE ;  break ;
		}

	if (VDintCheckAncestry(OPP_EMSsurface_class_id, OPP_GRcurve_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = SURF_CURVE ;
		if (Trim2Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[1]) ;
			if (!(sts & 1))
				count_extcrv = 0 ;
			else {
				count_extcrv  = 1 ;
				del_extcrv[0] = lc_obj[1] ;
				}
			}
		break ;
		}

	if (VDintCheckAncestry(OPP_GR3dlineseg_class_id, OPP_EMSplane_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = LINE_PLANE ; break ;
		}
	if (VDintCheckAncestry(OPP_GR3dlineseg_class_id, OPP_EMSsurface_class_id,
						 temp_cl[0], temp_cl[1])) {
		int_state = LINE_SURF ; break ;
		}
	if (VDintCheckAncestry(OPP_GR3dlineseg_class_id, OPP_GR3dlineseg_class_id,
						 temp_cl[0], temp_cl[1])) {
		int_state = LINE_LINE ; break ;
		}

	if (VDintCheckAncestry(OPP_GR3dlineseg_class_id, OPP_GRcurve_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = LINE_CURVE ;
		if (Trim2Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[1]) ;
			if (!(sts & 1))
				count_extcrv = 0 ;
			else {
				count_extcrv  = 1 ;
				del_extcrv[0] = lc_obj[1] ;
				}
			}
		break ;
		}

	if (VDintCheckAncestry(OPP_GRcurve_class_id, OPP_EMSplane_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = CURVE_PLANE ;
		if (Trim1Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[0]) ;
			if (!(sts & 1))
				count_extcrv = 0 ; /* style */
			else {
				del_extcrv[0] = lc_obj[0] ;
				count_extcrv  = 1 ;
				}
			}
		break ;
		}

	if (VDintCheckAncestry(OPP_GRcurve_class_id, OPP_EMSsurface_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = CURVE_SURF ;
		if (Trim1Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[0]) ;
			if (!(sts & 1))
				count_extcrv = 0 ; /* style */
			else {
				del_extcrv[0] = lc_obj[0] ;
				count_extcrv  = 1 ;
				}
			} /* if */
		break ;
		}

	if (VDintCheckAncestry(OPP_GRcurve_class_id, OPP_GR3dlineseg_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = CURVE_LINE ;
		if (Trim1Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[0]) ;
			if (!(sts & 1))
				count_extcrv = 0 ; /* style */
			else {
				del_extcrv[0] = lc_obj[0] ;
				count_extcrv  = 1 ;
				}
			} /* if */
		break ;
		}

	if (VDintCheckAncestry(OPP_GRcurve_class_id, OPP_GRcurve_class_id,
						temp_cl[0], temp_cl[1])) {
		int_state = CURVE_CURVE ;
		count_extcrv = 0 ;
		if (Trim1Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[0]) ;
			if (!(sts & 1))
				count_extcrv = 0 ; /* style */
			else {
				del_extcrv[count_extcrv] = lc_obj[0] ;
				count_extcrv  = count_extcrv + 1 ;
				}
			}
		if (Trim2Req == INF_B) {			/* 92/05/07 */
			sts = VDintGetExtCurve(&cst, &lc_obj[1]) ;
			if (!(sts & 1))
				count_extcrv = count_extcrv + 0 ; /* style */
			else {
				del_extcrv[count_extcrv] = lc_obj[1] ;
				count_extcrv  = count_extcrv +1 ;
				}
			}
		break ; /* CURVE_CURVE state */
		}

	/*
		92/02/19

		Allow compatibility with an old bug due to 'Change Root Element'
		on a tentative point, which indirectly breaks the filter in
		COint_2_elem.u.  In our case, it was an intersection between
		an infinite plane and an object of class VSselector (I/STRUCT).
	 */

	if (om$is_ancestry_valid(superclassid 	= OPP_EMSplane_class_id,
				subclassid	= temp_cl[0]) == OM_S_SUCCESS){
		int_state = PLANE_UNKNOWN ; break ;
		}
	if (om$is_ancestry_valid(superclassid 	= OPP_EMSplane_class_id,
				subclassid	= temp_cl[1]) == OM_S_SUCCESS){
		int_state = UNKNOWN_PLANE ; break ;
		}

	printf("VDS_Intersect : unknown intersection state \n") ;
	rc_intersect = 0 ; /* error */
	if (1) goto wrapup ;
	} /* while (1) */

  /*
	--------------------------------------------------------------
	Given the type of intersection, choose the right piece of code
	--------------------------------------------------------------
   */

switch (int_state) {

	case PLANE_UNKNOWN :

		/*
			Infinite plane and UNKNOWN		92/02/19
		 (because the GRvg.EMintplane() message used by IntCrvPlInf()
		  allows it).
		 */

		#ifdef DEBUG
		printf("PLANE_UNKNOWN intersection \n") ;
		#endif

		sts = VDintCrvPlInf(&lc_obj[0], /* infinite plane            */
				&lc_obj[1], 	/* unknown (e.g. VSselector) */
				&cst, num_inter, GRid_tab) ;
		if (!(sts & 1)) {
			#ifdef DEBUG
			printf("Error in VDintCrvPlInf() \n") ;
			#endif
			rc_intersect = 0 ; goto wrapup ;
			}
		break ;


	case UNKNOWN_PLANE :

		#ifdef DEBUG
		printf("UNKNOWN_PLANE intersection \n") ;
		#endif

		sts = VDintCrvPlInf(&lc_obj[1], /* infinite plane            */
				&lc_obj[0], 	/* unknown (e.g. VSselector) */
				&cst, num_inter, GRid_tab) ;
		if (!(sts & 1)) {
			#ifdef DEBUG
			printf("Error in VDintCrvPlInf() \n") ;
			#endif
			rc_intersect = 0 ; goto wrapup ;
			}
		break ;


	case PLANE_PLANE :

		#ifdef DEBUG
		printf("PLANE_PLANE intersection \n") ;
		#endif

		if ((Trim1Req == INF_B) && (Trim2Req == INF_B)) {
			/*
				Two infinite planes
			 */
			sts = VDintPlPlInf(&lc_obj[1], 	/* infinite plane */
				&lc_obj[0],		/* infinite plane */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintPlPlInf() \n") ;
				#endif
				rc_intersect = 0 ; goto wrapup ;
				}
			break ; /* break PLANE_PLANE */
			}

		if (Trim1Req == INF_B) {
			/*
				infinite plane and bounded plane
			 */
			TrimRequired = FALSE ;
			sts = VDintPlWithInfPl(&lc_obj[0], 	/* infinite plane */
				&lc_obj[1], 		/* bounded  plane */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintCrvPlInf() \n") ;
				#endif
				rc_intersect = 0 ; goto wrapup ;
				}
			break ; /* break PLANE_PLANE */
			}

		if (Trim2Req == INF_B) {
			/*
				bounded plane and infinite plane
			 */
			TrimRequired = FALSE ;
			sts = VDintPlWithInfPl(&lc_obj[1], 	/* infinite plane */
				&lc_obj[0],		/* bounded  plane */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintCrvPlInf() \n") ;
				#endif
				rc_intersect = 0 ; goto wrapup ;
				}
			break ; /* break PLANE_PLANE */
			}

		if (1) {
			/*
				two bounded planes
			 */
			TrimRequired = FALSE ;  /* not needed for EMSplane  */
			AppRequired  = FALSE  ; /* because we'll get a line */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ; goto wrapup ;
				}
			break ; /* break PLANE_PLANE */
			}
		break ; 	/* style only */

	case PLANE_SURF :

		#ifdef DEBUG
		printf("PLANE_SURF intersection \n") ;
		#endif

		/*
		   Template 1 is a plane, and Template 2 is a general surface.
		   Note that a plane with imposed boundaries will be treated
		   as a general surface in our intersection table (wad).
		   Besides, since an infinite general surface does'nt exist,
		   we choose to treat it like a general surface with its
		   imposed boundaries if they exist (EMSsfimpbnd class),
		   otherwise like a general surface with its natural boundaries.

		   Note :
		   ----
		   The approximation expression has been set previously, and is
		   simply provided as an argument to the function IntSrfPlInf(),
		   or to the function IntTwoSrf().
		 */

		if ((Trim2Req == IMP_B) || (Trim2Req == INF_B)) {
			TrimRequired = TRUE  ; /* surface with imposed bound */
			}
		else {
			TrimRequired = FALSE ; /* natural boundaries of surf */
			}

		/*
			Trim support for surfaces (92/03/05)
		 */

		if ( (Trim2Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[1]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[1], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[1]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 ; /* style only, and go on */
				}
			else {
				/* one intermediate copy done */
				count_copysrf = 1        ;
				to_be_del[0] = lc_obj[1] ;
				}
			} /* if trim support requested (92/03/05)*/

		if (Trim1Req == INF_B) {
			/*
				Infinite plane
			 */
			sts = VDintSrfPlInf(TrimRequired,      /* surface trim */
				AppRequired,	/* turn on/off JLL algorithm */
				&lc_obj[0], 	/* infinite plane            */
				&lc_obj[1],	/* general surface (only)    */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfPlInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case PLANE_LINE :

		#ifdef DEBUG
		printf("PLANE_LINE intersection \n") ;
		#endif

		if ((Trim1Req == INF_B) && (Trim2Req == INF_B)) {
			/*
				infinite plane and infinite line
			 */
			sts = VDintPlLnInf(&lc_obj[0], 	/* plane */
				&lc_obj[1],		/* line  */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintPlLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break PLANE_LINE */
			}

		if (Trim2Req == INF_B) {
			/* naturally bounded plane and infinite line */
			TrimRequired = FALSE ;
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[1], /* infinite line */
				&lc_obj[0], /* surface       */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break PLANE_LINE */
			}

		if (Trim1Req == INF_B) {
			/*
				infinite plane and segment
			 */
			sts = VDintCrvPlInf(&lc_obj[0], /* infinite plane */
				&lc_obj[1],		/* segment        */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintCrvPlInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break PLANE_LINE */
			}

		if (1) {
			/*
				segment and bounded plane
			 */
			TrimRequired = FALSE ; /* naturally bounded plane   */
			AppRequired  = FALSE ; /* because we'll get points */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break PLANE_LINE */
			}

		break ; 	/* style only */

	case PLANE_CURVE :

		#ifdef DEBUG
		printf("PLANE_CURVE intersection \n") ;
		#endif

		/*
		   Template 1 is a plane, and Template 2 is a general curve.
		   The only significative value of Trim2Req is NAT_B.

		   Note :
		   The approximation expression is not needed to compute
		   the intersection between a plane (infinite or bounded)
		   a curve.
		 */
		TrimRequired = FALSE ;
		if (Trim1Req == INF_B) {
			/*
				infinite plane
			 */
			sts = VDintCrvPlInf(&lc_obj[0], 		/* plane */
				&lc_obj[1],			/* curve */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintCrvPlInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case SURF_PLANE :

		#ifdef DEBUG
		printf("SURF_PLANE intersection \n") ;
		#endif

		/*
		   Template 1 is a general surface, and Template 2 is a plane.
		   Similar to PLANE_SURF.
		 */

		if ((Trim1Req == IMP_B) || (Trim1Req == INF_B)) {
			TrimRequired = TRUE  ; /* surface with imposed bound */
			}
		else {
			TrimRequired = FALSE ; /* natural boundaries */
			}

		/*
			Trim support for surfaces (92/03/05)
		 */

		if ( (Trim1Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[0]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[0], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[0]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 ; /* style only, and go on */
				}
			else {
				/* one intermediate copy done */
				count_copysrf = 1        ;
				to_be_del[0] = lc_obj[0] ;
				}
			} /* if trim support requested (92/03/05)*/

		if (Trim2Req == INF_B) {
			/*
				infinite plane
			 */
TrimRequired = TRUE;
			sts = VDintSrfPlInf(TrimRequired,      /* surface trim */
				AppRequired,	/* turn on/off JLL algorithm */
				&lc_obj[1], 	/* infinite plane            */
				&lc_obj[0],	/* general surface (only)    */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfPlInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case SURF_SURF :

		#ifdef DEBUG
		printf("SURF_SURF intersection \n") ;
		#endif

		/*
			Surf1 : trim support for surfaces (92/03/05)
		 */

		if ( (Trim1Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[0]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[0], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[0]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 ; /* style only, and go on */
				}
			else {
				/* one intermediate copy done (surf1) */
				to_be_del[0]  = lc_obj[0] ;
				count_copysrf = 1 ;
				}
			} /* if trim support requested (92/03/05) */

		/*
			Surf2 : trim support for surfaces (92/03/05)
		 */

		if ( (Trim2Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[1]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[1], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[1]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 + count_copysrf ; /* go on */
				}
			else {
				/* one intermediate copy done or once more ! */
				to_be_del[count_copysrf] = lc_obj[1] ;
				count_copysrf = 1 + count_copysrf ;
				}
			} /* if trim support requested (92/03/05)*/

		/*
		   Infinite surface is a non-sense in this case, and will
		   be treated by considering its imposed boundaries if they
		   exist.
		   Besides, only one trim expression is needed.
		 */
		if ((Trim1Req == IMP_B) || (Trim2Req == IMP_B)
			   || (Trim1Req == INF_B) || (Trim2Req == INF_B)){
			TrimRequired = TRUE  ;
			}
		else {
			TrimRequired = FALSE ; /* natural or infinite */
			}
		sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("Error in IntTwoSrf() \n") ;
			#endif
			rc_intersect = 0 ;
			goto wrapup ;
			}
		break ;

	case SURF_LINE :

		#ifdef DEBUG
		printf("SURF_LINE intersection \n") ;
		#endif

		/*
			Trim support for surfaces (92/03/05)
		 */

		if ( (Trim1Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[0]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[0], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[0]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 ; /* style only, and go on */
				}
			else {
				/* one intermediate copy done */
				count_copysrf = 1        ;
				to_be_del[0] = lc_obj[0] ;
				}
			} /* if trim support requested (92/03/05)*/

		/*
		   Template 1 is a general surface, and Template 2 is a line.
		   An infinite line is defined if Trim2Req is equal to INF_B.
		   Otherwise, we have a line-segment (IMP_B or NAT_B).
		 */

		if ((Trim1Req == IMP_B) || (Trim1Req == INF_B)) {
			TrimRequired = TRUE  ; /* surface with imposed bound */
			}
		else {
			TrimRequired = FALSE ; /* natural boundaries of surf */
			}
		if (Trim2Req == INF_B) {
			/* infinite line */
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[1], 	/* line            */
				&lc_obj[0],	/* general surface */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			AppRequired = FALSE ; /* because we will have points */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[1], &lc_obj[0],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case SURF_CURVE :

		#ifdef DEBUG
		printf("SURF_CURVE intersection \n") ;
		#endif

		/*
			Trim support for surfaces (92/03/05)
		 */

		if ( (Trim1Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[0]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[0], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[0]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 ; /* style only, and go on */
				}
			else {
				/* one intermediate copy done */
				count_copysrf = 1        ;
				to_be_del[0] = lc_obj[0] ;
				}
			} /* if trim support requested (92/03/05)*/

		/*
		   Infinite curve or curve with imposed boundaries doesn't exist
		   Look at Trim1Req
		 */

		if ((Trim1Req == IMP_B) || (Trim1Req == INF_B)) {
			TrimRequired = TRUE  ;
			}
		else {
			TrimRequired = FALSE ;
			}
		sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("Error in IntTwoSrf() \n") ;
			#endif
			rc_intersect = 0 ;
			goto wrapup ;
			}
		break ;

	case LINE_PLANE :

		#ifdef DEBUG
		printf("LINE_PLANE intersection \n") ;
		#endif

		if ((Trim1Req == INF_B) && (Trim2Req == INF_B)) {
			/* infinite line and infinite plane */
			sts = VDintPlLnInf(&lc_obj[1],		/* plane */
				&lc_obj[0],		     	/* line  */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintPlLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_PLANE */
			}

		if (Trim1Req == INF_B) {
			/* infinite line and naturally bounded plane */
			TrimRequired = FALSE ;
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[0], /* infinite line */
				&lc_obj[1], /* surface       */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_PLANE */
			}

		if (Trim2Req == INF_B) {
			/* segment and infinite plane */
			sts = VDintCrvPlInf(&lc_obj[1], /* infinite plane     */
				&lc_obj[0],		/* segment as a curve */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintCrvPlInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_PLANE */
			}

		if (1) {
			/*
				segment and bounded plane
			 */
			TrimRequired = FALSE ; /* naturally bounded plane   */
			AppRequired  = FALSE  ; /* because we'll get points */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_PLANE */
			}

		break ; 	/* style only */

	case LINE_SURF :

		#ifdef DEBUG
		printf("LINE_SURF intersection \n") ;
		#endif

		/*
			Trim support for surfaces (92/03/05)
		 */

		if ( (Trim2Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[1]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[1], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[1]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 ; /* style only, and go on */
				}
			else {
				/* one intermediate copy done */
				count_copysrf = 1        ;
				to_be_del[0] = lc_obj[1] ;
				}
			} /* if trim support requested (92/03/05)*/

		/*
		   Template 1 is a line, and Template 2 is a general surface.
		   An infinite line is defined if Trim1Req is equal to INF_B.
		   Otherwise, it's a line-segment (IMP_B or NAT_B).
		 */

		if ((Trim2Req == IMP_B) || (Trim2Req == INF_B)) {
			TrimRequired = TRUE  ; /* surface with imposed bound */
			}
		else {
			TrimRequired = FALSE ; /* natural boundaries of surf */
			}
		if (Trim1Req == INF_B) {
			/* infinite line */
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[0], 	/* infinite line   */
				&lc_obj[1],	/* general surface */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			AppRequired = FALSE ; /* because we will have points */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case LINE_LINE :

		#ifdef DEBUG
		printf("LINE_LINE intersection \n") ;
		#endif

		if ((Trim1Req == INF_B) && (Trim2Req == INF_B)) {
			/* two infinite lines */
			sts = VDintLnLnInf(&lc_obj[0], /* infinite line */
				&lc_obj[1],		/* infinite line */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintLnLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_LINE */
			}

		if (Trim1Req == INF_B) {
			/* infinite line and segment */
			TrimRequired = FALSE ;
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[0], /* infinite line */
				&lc_obj[1], /* segment       */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_LINE */
			}

		if (Trim2Req == INF_B) {
			/* segment and infinite line */
			TrimRequired = FALSE ;
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[1], 	/* infinite line */
				&lc_obj[0],	/* segment       */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_LINE */
			}

		if (1) {
			/* segment and segment */
			TrimRequired = FALSE ;  /* segments */
			AppRequired  = FALSE  ; /* because we'll get points */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			break ; /* break LINE_LINE */
			}

		break ; 	/* style only */

	case LINE_CURVE :

		#ifdef DEBUG
		printf("LINE_CURVE intersection \n") ;
		#endif

		/*
		   Template 1 is a line, and Template 2 is a general curve.
		   An infinite line is defined if Trim1Req is equal to INF_B.
		   Otherwise, we have a line-segment (IMP_B or NAT_B).
		 */

		TrimRequired = FALSE ; /* template 2 is a curve */
		if (Trim1Req == INF_B) {
			/* infinite line */
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[0], 	/* line            */
				&lc_obj[1],	/* general curve   */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			AppRequired = FALSE ; /* because we will have points */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case CURVE_PLANE :

		#ifdef DEBUG
		printf("CURVE_PLANE intersection \n") ;
		#endif

		/*
		   Template 1 is a general curve, and Template 2 is a plane.
		   The only significative value of Trim1Req is NAT_B.
		   Similar to PLANE_CURVE.
		 */
		TrimRequired = FALSE ;
		if (Trim2Req == INF_B) {
			/* infinite plane */
			sts = VDintCrvPlInf(&lc_obj[1], 	/* plane */
				&lc_obj[0],		/* curve */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintCrvPlInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case CURVE_SURF :

		#ifdef DEBUG
		printf("CURVE_SURF intersection \n") ;
		#endif

		/*
			Trim support for surfaces (92/03/05)
		 */

		if ( (Trim2Req == NAT_B) && (om$is_ancestry_valid(
			superclassid 	= OPP_EMSsfimpbnd_class_id,
			subclassid	= temp_cl[1]) == OM_S_SUCCESS) ) {
			/*
				Get a non-trimmed surface
			 */
			sts = VDintGetNoTrimSrf(&lc_obj[1], /* I      */
						 MOD_ENV,   /* I only */
						&lc_obj[1]  /* O      */
						) ;
			if (sts != 1) {
				#ifdef DEBUG
				printf("Error in VDintGetNoTrimSrf() \n") ;
				#endif
				count_copysrf = 0 ; /* style only, and go on */
				}
			else {
				/* one intermediate copy done */
				count_copysrf = 1        ;
				to_be_del[0] = lc_obj[1] ;
				}
			} /* if trim support requested (92/03/05)*/

		/*
			   Look at Trim2Req (surface trim expression)
		 */

		if ((Trim2Req == IMP_B) || (Trim2Req == INF_B)) {
			TrimRequired = TRUE ;
			}
		else {
			TrimRequired = FALSE ;
			}
		sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("Error in IntTwoSrf() \n") ;
			#endif
			rc_intersect = 0 ;
			goto wrapup ;
			}
		break ;

	case CURVE_LINE :

		#ifdef DEBUG
		printf("CURVE_LINE intersection \n") ;
		#endif

		/*
		   Template 1 is a general curve, and Template 2 is a line.
		   An infinite line is defined if Trim2Req is equal to INF_B.
		   Otherwise, we have a line-segment (IMP_B or NAT_B).
		 */

		TrimRequired = FALSE ; /* we have a curve */
		if (Trim2Req == INF_B) {
			/* infinite line */
			sts = VDintSrfLnInf(TrimRequired,
				&lc_obj[1], 	/* line            */
				&lc_obj[0],	/* general curve   */
				&cst, num_inter, GRid_tab) ;
			if (!(sts & 1)) {
				#ifdef DEBUG
				printf("Error in VDintSrfLnInf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		else {
			AppRequired = FALSE ; /* because we will have points */
			sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[1], &lc_obj[0],
				&cst, num_inter, GRid_tab, &msg) ;
			if (!(sts & msg & 1)) {
				#ifdef DEBUG
				printf("Error in IntTwoSrf() \n") ;
				#endif
				rc_intersect = 0 ;
				goto wrapup ;
				}
			}
		break ;

	case CURVE_CURVE :

		#ifdef DEBUG
		printf("CURVE_CURVE intersection \n") ;
		#endif

		/*
		   The only curves (except GR3dlineseg) that make sense
		   have a trim expression equal to NAT_B
		 */

		TrimRequired = FALSE ;
		sts = IntTwoSrf(TrimRequired, AppRequired,
				&lc_obj[0], &lc_obj[1],
				&cst, num_inter, GRid_tab, &msg) ;
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("Error in IntTwoSrf() \n") ;
			#endif
			rc_intersect = 0 ;
			goto wrapup ;
			}
		break ;

	default :
		printf("VDS_Intersect : unknown intersection state \n") ;
		rc_intersect = 0 ; /* error */
		goto wrapup ;
//		break ;
	} /* switch int_state */

rc_intersect = 1 ; /* success */

wrapup :

	#ifdef DEBUG
	printf("count_copysrf is %d \n", count_copysrf) ;
	printf("count_extcrv  is %d \n", count_extcrv)  ;
	#endif

	if (count_copysrf == 1) {
	   sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
						&to_be_del[0].module_info),
			senderid = NULL_OBJID,
			targetid = to_be_del[0].located_obj.objid,
			targetos = to_be_del[0].located_obj.osnum	) ;
	   as$status(sts = sts) ;

	   #ifdef DEBUG
	   printf("Deleted object is %d/%d \n", to_be_del[0].located_obj.objid,
						to_be_del[0].located_obj.osnum) ;
	   if (!(msg & 1))	printf("Delete failed \n") ;
	   #endif
	   }

	if (count_copysrf == 2) {
	   sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
						&to_be_del[0].module_info),
			senderid = NULL_OBJID,
			targetid = to_be_del[0].located_obj.objid,
			targetos = to_be_del[0].located_obj.osnum	) ;
	   as$status(sts = sts) ;

	   #ifdef DEBUG
	   printf("Deleted object is %d/%d \n", to_be_del[0].located_obj.objid,
						to_be_del[0].located_obj.osnum) ;
	   if (!(msg & 1))	printf("Delete failed \n") ;
	   #endif

	   sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
						&to_be_del[1].module_info),
			senderid = NULL_OBJID,
			targetid = to_be_del[1].located_obj.objid,
			targetos = to_be_del[1].located_obj.osnum	) ;
	   as$status(sts = sts) ;

	   #ifdef DEBUG
	   printf("Deleted object is %d/%d \n", to_be_del[1].located_obj.objid,
						to_be_del[1].located_obj.osnum) ;
	   if (!(msg & 1))	printf("Delete failed \n") ;
	   #endif
	   }

							/* 92/05/07 kludge */
	if (count_extcrv == 1) {
	   sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
						&del_extcrv[0].module_info),
			senderid = NULL_OBJID,
			targetid = del_extcrv[0].located_obj.objid,
			targetos = del_extcrv[0].located_obj.osnum	) ;
	   as$status(sts = sts) ;

	   #ifdef DEBUG
	   printf("Deleted curve is %d/%d \n", del_extcrv[0].located_obj.objid,
						del_extcrv[0].located_obj.osnum) ;
	   if (!(msg & 1))	printf("Delete failed \n") ;
	   #endif
	   }

	if (count_extcrv == 2) {
	   sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
						&del_extcrv[0].module_info),
			senderid = NULL_OBJID,
			targetid = del_extcrv[0].located_obj.objid,
			targetos = del_extcrv[0].located_obj.osnum	) ;
	   as$status(sts = sts) ;

	   #ifdef DEBUG
	   printf("Deleted object is %d/%d \n", del_extcrv[0].located_obj.objid,
						del_extcrv[0].located_obj.osnum) ;
	   if (!(msg & 1))	printf("Delete failed \n") ;
	   #endif

	   sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
						&del_extcrv[1].module_info),
			senderid = NULL_OBJID,
			targetid = del_extcrv[1].located_obj.objid,
			targetos = del_extcrv[1].located_obj.osnum	) ;
	   as$status(sts = sts) ;

	   #ifdef DEBUG
	   printf("Deleted curve is %d/%d \n", del_extcrv[1].located_obj.objid,
					del_extcrv[1].located_obj.osnum) ;
	   if (!(msg & 1))	printf("Delete failed \n") ;
	   #endif
	   }

	#ifdef DEBUG
  	printf("<--- End of intersect() function \n") ;
	#endif

	return   rc_intersect ;

} /* intersect() */


/*
	------------------------------------------------------------------
 */

int VDintCheckAncestry(
  GRclassid ancestor1,
  GRclassid ancestor2,
  OMuword   class1,
  OMuword   class2)
{
	if ((om$is_ancestry_valid(superclassid = ancestor1,
			subclassid   = class1) == OM_S_SUCCESS) &&
      	    (om$is_ancestry_valid(superclassid = ancestor2,
			subclassid   = class2) == OM_S_SUCCESS)) {
		return 1 ; /* true  */
		}
	else {
		return 0 ; /* false */
		}
} /* VDintCheckAncestry() */

/*
	------------------------------------------------------------------
	sts = VDintSrfPlInf() :
	----------------------

	This function computes the intersection between an infinite plane
	and a general surface only (in particular, the bounded or infinite
	planes are not considered as a general surface).
	A return code of 1 indicates a successful processing.

	Note1 :
	-----
		After having got the range of the general surface, this
		function builds an intermediate bounded plane in the given
		range, and calls the IntTwoSrf() function which
		implements JLL algorithm to compute intersection.
	Note2 :
	-----
		The function VDintCrvPlInf() should be used to compute an
		intersection between an infinite plane and a curve
		(including the case of segment), or an intersection
		between an infinite plane and a bounded plane.
	------------------------------------------------------------------
 */

int VDintSrfPlInf(
IGRboolean		trim_option,	/* I */
IGRboolean		app_option,	/* I */
struct GRlc_info 	*plane_lc_ptr,	/* infine  plane   */ 	    /* I */
struct GRlc_info	*srf_lc_ptr,	/* general surface */       /* I */
struct  GRvg_construct	*cst_ptr,	 			    /* I */
IGRint			*nb_int_ptr,	/* number of intersection*/ /* O */
struct GRid		*int_sol)	/* list of intersection  */ /* O */
{
   struct  GRvg_construct cstbis ;

   struct GRlc_info	trav_obj  ;
   IGRdouble		t_plan[6], scale ;
   IGRdouble		pl_poles[12]   ; /* 4 poles   */
   IGRdouble		pl_u_knots[12] ; /* 4 u_knots */
   IGRdouble		pl_v_knots[12] ; /* 4 v_knots */
   struct IGRplane	plane        ;
   struct IGRbsp_surface new_plane   ;
// struct IGRbsp_surface *sfGeom     ;
   IGRboolean		world, in_range ;
   GRrange		range     ;

   BSrc			rc        ; /* rc of BSplptnorrg() */
   IGRint		rc_int    ; /* rc of this function */
   IGRlong 		sts, msg  ;

#ifdef DEBUGX
   printf("	---> Call to VDintSrfPlInf() function \n") ;
#endif

   *nb_int_ptr  = 0 ;
   cstbis 	= *cst_ptr ; /* re-copy whole construction list structure */

   /*
	Get plane info
    */

   plane.point  = &t_plan[0] ;
   plane.normal = &t_plan[3] ;
   sts = om$send(msg =	message GRvg.GRdetplane(&msg,
				&plane_lc_ptr->module_info.md_env.matrix_type,
				 plane_lc_ptr->module_info.md_env.matrix,
				&plane),
		senderid = NULL_OBJID,
		targetid = plane_lc_ptr->located_obj.objid,
	 	targetos = plane_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}

   /*
	Get surface range in world coordinates
    */

#ifdef DEBUGX
printf("Srf Info: %d,%d\n",
  srf_lc_ptr->located_obj.objid,
  srf_lc_ptr->located_obj.osnum);
#endif

   world = 1 ;
   sts = om$send(msg = message EMSsurface.GRgetrang(&msg,
				&srf_lc_ptr->module_info.md_env.matrix_type,
				 srf_lc_ptr->module_info.md_env.matrix,
				&world,
				range),
		senderid = NULL_OBJID,
		targetid = srf_lc_ptr->located_obj.objid,
	 	targetos = srf_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   /*
	Compute an intermediate plane in the surface range
    */

   scale = 2 ;
   new_plane.poles   = &pl_poles[0]   ;
   new_plane.u_knots = &pl_u_knots[0] ;
   new_plane.v_knots = &pl_v_knots[0] ;
   new_plane.weights = NULL ;
   new_plane.bdrys   = NULL ;

#ifdef	DEBUG
   printf(" Range#0 : %f, %f, %f \n", range[0], range[1], range[2] );
   printf(" Range#1 : %f, %f, %f \n", range[3], range[4], range[5] );
   printf(" Pl.Pnts : %f, %f, %f \n", t_plan[0], t_plan[1], t_plan[2] );
   printf(" Pl.Norm : %f, %f, %f \n", t_plan[3], t_plan[4], t_plan[5] );
#endif

   BSplptnorrg(	&range[0], &range[3],
		plane.point, plane.normal,
		scale,
		&in_range,
		&new_plane,			/* bounded B-spline plane */
		&rc) ;

   if (rc != BSSUCC) {
	#ifdef DEBUG
	printf("VDintSrfPlInf() : error when calling BSplptnorrg() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}
#ifdef DEBUG
   printf("Information : in_range for intermediate plane is %d \n", in_range) ;
#endif

   /*
	Construct the new plane
    */

   cstbis.geometry = (char *)&new_plane  ;
   cstbis.msg = &msg ;

   trav_obj.located_obj.objid    = NULL_OBJID ;
   trav_obj.located_obj.osnum    =  cst_ptr->env_info->md_id.osnum ;
   trav_obj.module_info          = *cst_ptr->env_info ;

   ex$get_modid(mod_osnum =  trav_obj.module_info.md_id.osnum,
	        mod_id    = &trav_obj.module_info.md_id.objid) 		;

   cstbis.env_info = &trav_obj.module_info ;

   sts  = om$construct (  classid = OPP_EMSplane_class_id,
                          p_objid = &trav_obj.located_obj.objid,
                          osnum   =  trav_obj.located_obj.osnum);
   as$status(sts = sts)  ;

   sts = om$send(msg = message EMSplane.GRconstruct(&cstbis),
		senderid = NULL_OBJID,
		targetid = trav_obj.located_obj.objid,
		targetos = trav_obj.located_obj.osnum) ;
   msg = *(cstbis.msg) ;
   as$status(sts = sts)  ;

   if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}
#ifdef DEBUG
   gr$display_object(object_id = &trav_obj.located_obj,
		md_env  = &trav_obj.module_info,
		mode	= GRbd) ;
#endif

   /*
    * Intersect the intermediate plane with the general surface
    * works better with the tolerance when the surface is intersecting
    * on the plane and the inverse. ( Diff is variation of 0.0001
    * Oct'95: adz
    *
    * sts = IntTwoSrf(trim_option, app_option, srf_lc_ptr, &trav_obj,
    */

   sts = IntTwoSrf(trim_option, app_option, &trav_obj, srf_lc_ptr,
		cst_ptr, nb_int_ptr, int_sol, &msg) ;
   if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("VDintSrfPlInf() : error when calling IntTwoSrf() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

rc_int = 1 ; /* success */

quit:

	if( trav_obj.located_obj.objid != NULL_OBJID ) {
		#ifdef DEBUG
		printf("Delete the intermediate constructed plane \n") ;
		#endif
		sts = om$send(msg = message EMSplane.GRdelete(&msg,
					&trav_obj.module_info),
			senderid = NULL_OBJID,
			targetid = trav_obj.located_obj.objid,
	 		targetos = trav_obj.located_obj.osnum) ;
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("IntSrfPlInf() : warning - delete of intermediate plane not done \n") ;
			#endif
			/* continue however */
			}
		}
	return rc_int ;

} /* VDintSrfPlInf() */

/*
	------------------------------------------------------------------
	sts = VDintCrvPlInf() :
	----------------------

	This function computes the intersection between an infinite plane
	and a general curve (or a segment), or the intersection between an
	infinite plane and a bounded plane.
	A return code of 1 indicates a successful processing.

	Note1 :
	-----
		This function doesn't call the function IntTwoSrf().
	Note2 :
	-----
		The function VDintSrfPlInf() should be used to compute
		intersection between an infinite plane and a general
		surface which allows the usage of the trim and
		approximation expressions.
	Note3 :
	-----
		- 92/02/19 -
		This function is also applied to compute the intersection
		between an infinite plane and an unknown object such as
		VSselector, because GRvg.EMintplane() message allows it !

	------------------------------------------------------------------
 */

int VDintCrvPlInf(
struct GRlc_info 	*plane_lc_ptr,	/* infine  plane   */ 	    /* I */
struct GRlc_info	*crv_lc_ptr,	/* general curve   */       /* I */
struct GRvg_construct	*cst_ptr,	 			    /* I */
IGRint			*nb_int_ptr,	/* number of intersection*/ /* O */
struct GRid		*int_sol)	/* list of intersection  */ /* O */
{
   IGRdouble		t_plan[6] ;
   struct IGRplane	plane     ;
   struct GRid		*GRint    ;
   IGRint		i         ;
   IGRlong 		sts, msg  ;
   IGRint		msgx;

#ifdef DEBUG
   printf("	---> Call to VDintCrvPlInf() function \n") ;
XXX
#endif

   GRint        = NULL ;
   *nb_int_ptr  = 0    ;
   plane.point  = &t_plan[0] ;
   plane.normal = &t_plan[3] ;
   sts = om$send(msg =	message GRvg.GRdetplane(&msg,
				&plane_lc_ptr->module_info.md_env.matrix_type,
				plane_lc_ptr->module_info.md_env.matrix,
				&plane),
		senderid = NULL_OBJID,
		targetid = plane_lc_ptr->located_obj.objid,
	 	targetos = plane_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
		return 0 ; /* failure */
		}

// printf("Calling GRvg.EMintplane\n");

   sts = om$send(msg = message GRvg.EMintplane(	cst_ptr,
						&plane,
						crv_lc_ptr,
						nb_int_ptr,
						&GRint,
						&msgx),
		senderid = NULL_OBJID,
		targetid = crv_lc_ptr->located_obj.objid,
	 	targetos = crv_lc_ptr->located_obj.osnum) ;
// printf("Called   GRvg.EMintplane\n");
   msg = msgx;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
		if (GRint) {
			free(GRint) ;
			}
		return 0    ; /* failure */
		}

#ifdef  VDS_DATA_REDUCTION
/*
 * EF/AZ
 * Execute data reduction (Don't check about return code because the function
 *                         returns something; even if it fails).
 */

   VDSapplyDataReduction(       &msg,
                                crv_lc_ptr,    /* Not Used */
                                crv_lc_ptr,    /* Not Used */
                                cst_ptr,
                                *nb_int_ptr,
                                GRint );

#endif  /* VDS_DATA_REDUCTION */

   for (i = 0 ; i < *nb_int_ptr ; i = i+1) {
	int_sol[i].objid = (GRint + i)->objid ;
	int_sol[i].osnum = (GRint + i)->osnum ;
	}
   if (GRint) {
	free(GRint) ;
	}
   return 1 ; /* success */
} /* VDintCrvPlInf() */

/*
	------------------------------------------------------------------
	sts = VDintSrfLnInf() :
	----------------------

	This function computes the intersection between an infinite line
	and a general surface/curve.
	A return code of 1 indicates a successful processing.

	History :
	92/06/03	Support GR3dinfline (polyline struct has 4 points !)
	------------------------------------------------------------------
 */

int VDintSrfLnInf(
IGRboolean		trim_option,
struct GRlc_info 	*line_lc_ptr,  	/* infine  line */ 	    /* I */
struct GRlc_info	*srf_lc_ptr,   	/* general surface/curve */ /* I */
struct GRvg_construct	*cst_ptr,       			    /* I */
IGRint			*nb_int_ptr,   	/* number of intersection*/ /* O */
struct GRid		*int_sol)      	/* list of intersections */ /* O */
{
   struct GRvg_construct cstbis ;

   IGRint		i ;
   IGRlong		msg, sts, rc_int ;
   struct GRlc_info 	trav_obj	 ;

   IGRint		action   ;
   IGRint		shift    ;
   IGRdouble		line_pt_vect[12] ; /* up to 4 points */
   struct IGRpolyline	polyline ;

   IGRboolean		world, app_option ;
   GRrange		range    ;

   BSrc			rc       ;
   struct IGRbsp_curve	new_line ;
   IGRdouble		nl_poles[6], nl_knots[12] ; /* 2 poles, 4 knots */

// struct GRpost_info	post_info ;

#ifdef DEBUG
   printf("	---> Call to VDintSrfLnInf() function \n") ;
#endif

   *nb_int_ptr  = 0 ;
   cstbis 	= *cst_ptr ; 	/* re-copy whole structure content */

   /*
	Get a point and a vector from the line parent
    */

   polyline.points = &line_pt_vect[0] ;

   action = 0 ; /* Get number of points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line_lc_ptr->module_info.md_env.matrix_type,
				line_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline),
		senderid = NULL_OBJID,
		targetid = line_lc_ptr->located_obj.objid,
	 	targetos = line_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit  ; }

   action = 1 ; /* Get points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line_lc_ptr->module_info.md_env.matrix_type,
				line_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline),
		senderid = NULL_OBJID,
		targetid = line_lc_ptr->located_obj.objid,
	 	targetos = line_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit ; }

   if (polyline.num_points == 2) shift = 0 ;  	/* GR3dlineseg */
   else shift = 1 ;				/* GR3dinfline */

   line_pt_vect[0] = line_pt_vect[3*shift] ;	/* Get an origin point */
   line_pt_vect[1] = line_pt_vect[3*shift + 1] ;
   line_pt_vect[2] = line_pt_vect[3*shift + 2] ;

   line_pt_vect[3] = line_pt_vect[3*(shift+1)]     - line_pt_vect[0] ;
   line_pt_vect[4] = line_pt_vect[3*(shift+1) + 1] - line_pt_vect[1] ;
   line_pt_vect[5] = line_pt_vect[3*(shift+1) + 2] - line_pt_vect[2] ;

#ifdef DEBUG
	printf("Vector is %f/%f/%f \n", line_pt_vect[3],
					line_pt_vect[4], line_pt_vect[5]) ;
#endif

   /*
	Get the range of the surface parent in world coordinates
    */

   world = 1 ;
   sts = om$send(msg = message EMSsurface.GRgetrang(&msg,
				&srf_lc_ptr->module_info.md_env.matrix_type,
				srf_lc_ptr->module_info.md_env.matrix,
				&world,
				range),
		senderid = NULL_OBJID,
		targetid = srf_lc_ptr->located_obj.objid,
	 	targetos = srf_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   /*
	Given the min-max points for a range box, a point and a vector, this
	routine will create a bounded line which will intersect the range box.
    */

  new_line.poles   = &nl_poles[0] ; /* 2 poles */
  new_line.knots   = &nl_knots[0] ; /* 4 knots */
  new_line.weights = NULL ;
  new_line.bdrys   = NULL ;

  BSmklnintbx(	&line_pt_vect[0],
		&line_pt_vect[3],
		&range[0],
		&range[3],
		TRUE,
		&new_line,
		&rc) ;
  if (rc != BSSUCC) {
	#ifdef DEBUG
	printf("VDintSrfLnInf() : error when calling BSmklnintbx() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   /*
	Construct the new line
    */

   cstbis.geometry = (char *)&new_line  ;
   cstbis.msg = &msg ;
   trav_obj.located_obj.objid    = NULL_OBJID          ;
   trav_obj.located_obj.osnum    = cst_ptr->env_info->md_id.osnum ;
// trav_obj.located_obj.osnum    = MOD_ENV.md_id.osnum ;

   trav_obj.module_info.md_id.osnum = cst_ptr->env_info->md_id.osnum ;
// trav_obj.module_info.md_id.osnum = MOD_ENV.md_id.osnum        ;

   ex$get_modid(mod_osnum = trav_obj.module_info.md_id.osnum,
	        mod_id    = &trav_obj.module_info.md_id.objid) 		;

   trav_obj.module_info.md_env.matrix_type = cst_ptr->env_info->md_env.matrix_type ;
// trav_obj.module_info.md_env.matrix_type = MOD_ENV.md_env.matrix_type ;

   for( i=0; i<16; i=i+1 )
     trav_obj.module_info.md_env.matrix[i] = cst_ptr->env_info->md_env.matrix[i]   ;
//   trav_obj.module_info.md_env.matrix[i] = MOD_ENV.md_env.matrix[i]   ;
   cstbis.env_info = &trav_obj.module_info ;

   sts  = om$construct (  classid = OPP_GR3dlineseg_class_id,
                          p_objid = &trav_obj.located_obj.objid,
                          osnum   =  trav_obj.located_obj.osnum);
   as$status(sts = sts)  ;

   sts = om$send(msg = message GR3dlineseg.GRconstruct(&cstbis),
		senderid = NULL_OBJID,
		targetid = trav_obj.located_obj.objid,
		targetos = trav_obj.located_obj.osnum) ;
   as$status(sts = sts)  ;
   msg = *(cstbis.msg) ;
   if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}

#ifdef DEBUG
   gr$display_object(object_id = &trav_obj.located_obj,
		md_env  = &trav_obj.module_info,
		mode	= GRbd) ;
#endif

   /*
	Compute the intersection
    */

   app_option = FALSE ; /* we will have points */
   sts = IntTwoSrf(trim_option, app_option, srf_lc_ptr, &trav_obj,
		cst_ptr, nb_int_ptr, int_sol, &msg) ;
   if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("VDintSrfLnInf() : error when calling IntTwoSrf() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   rc_int = 1 ; /* success */

   quit :
	if (trav_obj.located_obj.objid != NULL_OBJID) {
		#ifdef DEBUG
		printf("Delete the intermediate constructed line \n") ;
		#endif
		sts = om$send(msg = message GR3dlineseg.GRdelete(&msg,
					&trav_obj.module_info),
			senderid = NULL_OBJID,
			targetid = trav_obj.located_obj.objid,
	 		targetos = trav_obj.located_obj.osnum) ;
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("VDintSrfLnInf() : warning - delete of tempory line not done \n") ;
			#endif
			/* continue however */
			}
		} /* flag */
	return rc_int ;
} /* VDintSrfLnInf()  */


/*
	------------------------------------------------------------------
	sts = VDintPlLnInf() :
	------------------

	This function computes the intersection between an infinite plane
	and an infinite line.
	A return code of 1 indicates a successful processing.

	History :
	92/06/03	Support GR3dinfline (polyline struct has 4 points !)
	------------------------------------------------------------------
 */

int VDintPlLnInf(
struct GRlc_info 	*plane_lc_ptr,	/* infine  plane   */ 	    /* I */
struct GRlc_info	*line_lc_ptr,	/* infinite line   */       /* I */
struct GRvg_construct	*cst_ptr,	 			    /* I */
IGRint			*nb_int_ptr,	/* number of intersection*/ /* O */
struct GRid		*int_sol)	/* list of intersection  */ /* O */
{
   IGRdouble		t_plan[6]    ;
   IGRdouble		line_pts[12] ;  /* up to 4 points */
   struct IGRplane	plane        ;
   struct IGRpolyline	polyline, geom ;
   IGRint		action      ;
   IGRint		j, shift    ;
   IGRlong 		sts, msg    ;
   IGRpoint		x_point     ; /* solution */
   BSrc			rc     ; /* rc of BSxlnpl()     */
   IGRint		rc_int ; /* rc of this function */

#ifdef DEBUG
   printf("	---> Call to VDintPlLnInf() function \n") ;
#endif

   *nb_int_ptr  = 0    ;

   /*
	Get a point and a normal from the plane parent
    */

   plane.point  = &t_plan[0] ;
   plane.normal = &t_plan[3] ;
   sts = om$send(msg =	message GRvg.GRdetplane(&msg,
				&plane_lc_ptr->module_info.md_env.matrix_type,
				plane_lc_ptr->module_info.md_env.matrix,
				&plane),
		senderid = NULL_OBJID,
		targetid = plane_lc_ptr->located_obj.objid,
	 	targetos = plane_lc_ptr->located_obj.osnum) ;
   if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}
   /*
	Get 2 points from the line parent
    */

   polyline.points = &line_pts[0] ;

   action = 0 ; /* Get number of points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line_lc_ptr->module_info.md_env.matrix_type,
				line_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline),
		senderid = NULL_OBJID,
		targetid = line_lc_ptr->located_obj.objid,
	 	targetos = line_lc_ptr->located_obj.osnum) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit ; }

   action = 1 ; /* Get 2 or 4 points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line_lc_ptr->module_info.md_env.matrix_type,
				line_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline),
		senderid = NULL_OBJID,
		targetid = line_lc_ptr->located_obj.objid,
	 	targetos = line_lc_ptr->located_obj.osnum) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit ; }

   if (polyline.num_points == 2) shift = 0 ;  	/* GR3dlineseg */
   else shift = 1 ;				/* GR3dinfline */

   if (shift) {
   	for (j = 0 ; j < 3 ; j = j+1) {
		line_pts[j]     = line_pts[3*shift + j]     ;
		line_pts[3 + j] = line_pts[3*(shift+1) + j] ;
		}
	}

   /*
	Compute intersection point
    */

   BSxlnpl(	&rc,
		plane.normal, plane.point, &line_pts[0], &line_pts[3],
		&x_point[0]) ;
   if (rc != BSSUCC) {
	#ifdef DEBUG
	printf("VDintPlLnInf() : error when calling BSxlnpl() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   /*
	Construct the intersection point
    */

   geom.num_points   = 1 ;
   geom.points       = &x_point[0]   ;
   cst_ptr->geometry = (char *)&geom ;

   if (cst_ptr->display->weight < 3) {
	cst_ptr->display->weight = 3 ;
	}

   int_sol[0].objid = NULL_OBJID ;
   int_sol[0].osnum = cst_ptr->env_info->md_id.osnum ;
// int_sol[0].osnum = MOD_ENV.md_id.osnum ;

   sts  = om$construct (  classid = OPP_GR3dpoint_class_id,
                          p_objid = &int_sol[0].objid,
                          osnum   =  int_sol[0].osnum);
   as$status(sts = sts)  ;

   sts = om$send(msg = message GR3dpoint.GRaltconstruct(cst_ptr),
		senderid = NULL_OBJID,
		targetid = int_sol[0].objid,
		targetos = int_sol[0].osnum) ;
   as$status(sts = sts)  ;
   msg = *(cst_ptr->msg) ;
   if (!(sts & msg & 1)) {
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   *nb_int_ptr = 1 ;
   rc_int = 1 ; /* success */

quit :
	return rc_int ;
} /* VDintPlLnInf() */

/*
	----------------------------------------------------------------------
	sts = VDintPlPlInf() :
	------------------

	This function computes the intersection between two infinite planes.
	A return code of 1 indicates a successful processing.

	History :
	92/06/03	Support intersection between a frame system plane and
		   a standard EMS plane to compute a visible bounded line
		   representation.
	----------------------------------------------------------------------
 */

int VDintPlPlInf(
struct GRlc_info 	*plane1_lc_ptr, /* infinite plane  */ 	    /* I */
struct GRlc_info	*plane2_lc_ptr, /* infinite plane  */ 	    /* I */
struct GRvg_construct	*cst_ptr,	 			    /* I */
IGRint			*nb_int_ptr,	/* number of intersection*/ /* O */
struct GRid		*int_sol)	/* list of intersection  */ /* O */
{
   struct GRlc_info 		*parent[2]    ;
   struct IGRbsp_surface	*bsp_plan[2]  ;
   IGRvector			du, dv, n1, n2, x_vect ;
   IGRdouble			x_point[3]    ;
   struct IGRpolyline		geom	      ;
   IGRdouble			t_points[6]   ;
   IGRdouble			dotmin, dotmax, dotcou ;
   IGRlong 			size          ;
   IGRint			i, flag_pl_pl ;
   OMuword			plane2_class   ; /* 92/06/03 */
   IGRint			selected_plane ; /* 92/06/03 */
   IGRlong 			sts, msg      ;
   BSrc				rc            ; /* rc of BS... functions  */
   IGRint			rc_int        ;	/* rc of this function    */
   extern GRclassid		OPP_SMframe_class_id, OPP_VDSInfPl_class_id ;

#ifdef DEBUG
   printf("	---> Call to VDintPlPlInf() function \n") ;
#endif

   *nb_int_ptr  = 0    ;

   /*
	Get a point and a normal for each plane
    */

   parent[0]   = plane1_lc_ptr ;
   parent[1]   = plane2_lc_ptr ;
   bsp_plan[0] = NULL ;
   bsp_plan[1] = NULL ;
   for (i = 0 ; i < 2 ; i = i+1) {
	sts = om$send( 	msg = message EMSplane.GRgetsize(
				&msg,
				&parent[i]->module_info.md_env.matrix_type,
				parent[i]->module_info.md_env.matrix,
 	       		        &size ),
			senderid = NULL_OBJID,
	  	 	targetid = parent[i]->located_obj.objid,
	  	 	targetos = parent[i]->located_obj.osnum ) ;
	as$status(sts = sts) ;
	if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}

	bsp_plan[i] = (struct IGRbsp_surface *) malloc(size) ;
	if (bsp_plan[i] == NULL) {
		#ifdef DEBUG
		printf("Unable to malloc \n") ;
		#endif
		rc_int = 0 ; /* failure */
		goto quit  ;
		}

	sts = om$send( msg = message EMSplane.GRgetgeom(
				&msg,
				&parent[i]->module_info.md_env.matrix_type,
				parent[i]->module_info.md_env.matrix,
 	     		        (char*)bsp_plan[i] ),
			senderid = NULL_OBJID,
	  	 	targetid = parent[i]->located_obj.objid,
	  	 	targetos = parent[i]->located_obj.osnum ) ;
	as$status(sts = sts) ;
	if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}
	} /* for */

   BSmkvec(&rc, du, &bsp_plan[0]->poles[0], &bsp_plan[0]->poles[3]) ;
   BSmkvec(&rc, dv, &bsp_plan[0]->poles[0], &bsp_plan[0]->poles[6]) ;
   BScrossp(&rc, du, dv, n1) ;
   BSnorvec(&rc, n1) ;
   if (rc != BSSUCC) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}
   BSmkvec(&rc, du, &bsp_plan[1]->poles[0], &bsp_plan[1]->poles[3]) ;
   BSmkvec(&rc, dv, &bsp_plan[1]->poles[0], &bsp_plan[1]->poles[6]) ;
   BScrossp(&rc, du, dv, n2) ;
   BSnorvec(&rc, n2) ;
   if (rc != BSSUCC) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}

   /*
	Compute intersection line
    */

   BSpl_pl(	&bsp_plan[0]->poles[0], n1,
		&bsp_plan[1]->poles[0], n2,
		&flag_pl_pl,
		&x_point[0],		/* only one point */
		x_vect,
		&rc) ;
   if ((rc != BSSUCC) || (flag_pl_pl != BSCINTERSECTING)) {
	#ifdef DEBUG
	printf("VDintPlPlInf() : error when calling BSpl_pl() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

/*
	Check if we have a VDSInfPl plane or a SMframe plane
 */

sts = om$get_classid(	osnum		= plane2_lc_ptr->located_obj.osnum,
			objid		= plane2_lc_ptr->located_obj.objid,
			p_classid 	= &plane2_class) ;
as$status(sts = sts) ; if (sts != OM_S_SUCCESS) { rc_int = 0 ; goto quit ; }

if ((om$is_ancestry_valid(subclassid 	= plane2_class,
			superclassid 	= OPP_SMframe_class_id)
							== OM_S_SUCCESS) ||
    (om$is_ancestry_valid(subclassid 	= plane2_class,
			superclassid 	= OPP_VDSInfPl_class_id)
							== OM_S_SUCCESS)) {
	#ifdef DEBUG
	printf("The second plane is a frame \n") ;
	#endif

	selected_plane = 0 ;
	/* => don't use the second plane to compute a bounded line rep */
	}

else {
	selected_plane = 1 ;
	/* => use the second plane to compute a bounded line rep */
	}

/*
	Compute a bounded representation of our infinite intersection line
 */

   dotmin =  1.E30  ;
   dotmax = -1.E-30 ;
   for (i = 0 ; i < 4 ; i = i+1) { 	/* for each pole of selected plane */
	BSmkvec(&rc, dv, &x_point[0], &bsp_plan[selected_plane]->poles[3*i]) ;
	dotcou = BSdotp(&rc, x_vect, dv) ;
   	if (rc != BSSUCC) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}
	if (dotcou < dotmin) dotmin = dotcou ;
	if (dotcou > dotmax) dotmax = dotcou ;
	}

   geom.num_points = 2 ;
   geom.points     = &t_points[0] ;
   for (i = 0 ; i < 3 ; i = i+1) {
	geom.points[i]   = x_point[i] + dotmin * x_vect[i] ;
	geom.points[i+3] = x_point[i] + dotmax * x_vect[i] ;
	}

/*
	Construct the line macro foot
 */

   cst_ptr->geometry = (char *)&geom ;
   int_sol[0].objid  = NULL_OBJID    ;
   int_sol[0].osnum  = cst_ptr->env_info->md_id.osnum ;
// int_sol[0].osnum  = MOD_ENV.md_id.osnum ;

   sts  = om$construct (  classid = OPP_GR3dlineseg_class_id,
                          p_objid = &int_sol[0].objid,
                          osnum   =  int_sol[0].osnum);
   as$status(sts = sts)  ;


   sts = om$send(msg = message GR3dlineseg.GRaltconstruct(cst_ptr),
		senderid = NULL_OBJID,
		targetid = int_sol[0].objid,
		targetos = int_sol[0].osnum) ;
   as$status(sts = sts)  ;

   msg = *(cst_ptr->msg) ;
   if (!(sts & msg & 1)) {
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   *nb_int_ptr = 1 ;
   rc_int = 1 ; /* success */

quit:
	if( bsp_plan[0] != NULL ) free(bsp_plan[0]);
	if( bsp_plan[1] != NULL ) free(bsp_plan[1]);
	return rc_int ;
} /* VDintPlPlInf() */


/*
	------------------------------------------------------------------
	sts = VDintLnLnInf() :
	------------------

	This function computes the intersection between two infinite lines.
	A return code of 1 indicates a successful processing.

	History :
	92/06/03	Support GR3dinfline (polyline struct has 4 points !)
	------------------------------------------------------------------
 */

int VDintLnLnInf(
struct GRlc_info 	*line1_lc_ptr,	/* infinite line   */ 	    /* I */
struct GRlc_info	*line2_lc_ptr,  /* infinite line   */       /* I */
struct GRvg_construct	*cst_ptr,	 			    /* I */
IGRint			*nb_int_ptr,	/* number of intersection*/ /* O */
struct GRid		*int_sol)	/* list of intersection  */ /* O */
{
   IGRdouble		line1_pts[12], line2_pts[12] ; /* up to 4 points */
   struct IGRpolyline	polyline1, polyline2, geom   ;
   IGRint		action      ;
   IGRint		shift1, shift2 ;
   IGRlong 		sts, msg    ;
   IGRpoint		x_point     ; /* solution */
   BSrc			rc     ; /* rc of BSxln()       */
   IGRint		rc_int ; /* rc of this function */

#ifdef DEBUG
   printf("	---> Call to VDintLnLnInf() function \n") ;
#endif

   *nb_int_ptr  = 0 ;

   /*
	Get polyline structure for line1 and line2
    */

   polyline1.points = &line1_pts[0] ;

   action = 0 ; /* Get number of points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line1_lc_ptr->module_info.md_env.matrix_type,
				line1_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline1),
		senderid = NULL_OBJID,
		targetid = line1_lc_ptr->located_obj.objid,
	 	targetos = line1_lc_ptr->located_obj.osnum) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit ; }

   action = 1 ; /* Get points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line1_lc_ptr->module_info.md_env.matrix_type,
				line1_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline1),
		senderid = NULL_OBJID,
		targetid = line1_lc_ptr->located_obj.objid,
	 	targetos = line1_lc_ptr->located_obj.osnum) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit ; }

   polyline2.points = &line2_pts[0] ;

   action = 0 ; /* Get number of points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line2_lc_ptr->module_info.md_env.matrix_type,
				line2_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline2),
		senderid = NULL_OBJID,
		targetid = line2_lc_ptr->located_obj.objid,
	 	targetos = line2_lc_ptr->located_obj.osnum) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit ; }

   action = 1 ; /* Get points */
   sts = om$send(msg = message GRlinear.GRgetpolyline(&msg,
				&line2_lc_ptr->module_info.md_env.matrix_type,
				line2_lc_ptr->module_info.md_env.matrix,
				&action,
				&polyline2),
		senderid = NULL_OBJID,
		targetid = line2_lc_ptr->located_obj.objid,
	 	targetos = line2_lc_ptr->located_obj.osnum) ;
   if (!(sts & msg & 1)) { rc_int = 0 ; goto quit ; }

   /*
	Compute the intersection
    */

   if (polyline1.num_points == 2) shift1 = 0 ;  /* GR3dlineseg */
   else shift1 = 1 ;				/* GR3dinfline */

   if (polyline2.num_points == 2) shift2 = 0 ;  /* GR3dlineseg */
   else shift2 = 1 ;				/* GR3dinfline */


   BSxln(	&rc,
		&line1_pts[3 * shift1], &line1_pts[3 * (shift1 + 1)],
		&line2_pts[3 * shift2], &line2_pts[3 * (shift2 + 1)],
		&x_point[0]) ;
   if (rc != BSSUCC) {
	#ifdef DEBUG
	printf("VDintLnLnInf() : error when calling BSxln() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   /*
	Construct the intersection point
    */

   geom.num_points   = 1 ;
   geom.points       = &x_point[0]   ;
   cst_ptr->geometry = (char *)&geom ;

   if (cst_ptr->display->weight < 3) {
	cst_ptr->display->weight = 3 ;
	}

   int_sol[0].objid = NULL_OBJID ;
   int_sol[0].osnum = cst_ptr->env_info->md_id.osnum ;
// int_sol[0].osnum = MOD_ENV.md_id.osnum ;

   sts  = om$construct (  classid = OPP_GR3dpoint_class_id,
                          p_objid = &int_sol[0].objid,
                          osnum   =  int_sol[0].osnum);
   as$status(sts = sts)  ;

   sts = om$send(msg = message GR3dpoint.GRaltconstruct(cst_ptr),
		senderid = NULL_OBJID,
		targetid = int_sol[0].objid,
		targetos = int_sol[0].osnum) ;
   as$status(sts = sts)  ;

   msg = *(cst_ptr->msg) ;
   if (!(sts & msg & 1)) {
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   *nb_int_ptr = 1 ;
   rc_int = 1 ; /* success */

quit :
	#ifdef DEBUG
   	printf("	<--- Return from IntLnLnInf() function \n") ;
	#endif
	return rc_int ;
} /* VDintLnLnInf() */

/*
	------------------------------------------------------------------
							 	  92/03/05
	sts = VDintGetNoTrimSrf() :
	--------------------
		--	Get a non-trimmed surface	--
	Given a surface of class EMSsfimpbnd, this function returns a
	copy from the initial surface after having deleted its boundaries
	(EMScompsurf.EMdelete_boundary() message).

	A return code of 1 denotes a successful completion.
	After usage, the caller should delete this tempory object.

	Programmer's note :
		A structure modbis_env is used because MOD_ENV.md_id.objid = -1.
	ex$get_modid() is needed to get the module id which is necessary
	for display ops (rtree modifications).
	------------------------------------------------------------------
 */

int VDintGetNoTrimSrf(
struct GRlc_info	*lc_obj_ptr,	/* I : imposed-boundary surface */
struct GRmd_env		*mod_env_ptr,	/* I : mod. env. for copy       */
struct GRlc_info	*new_lc_obj_ptr)/* O : surf with no boundary    */
{
   struct GRlc_info	aux_lc_obj	;  /* prepare output */
   struct GRid		tmp_obj		;
   GRobjid		new_objid	;
   OMuword		obj_cl		;
   struct GRmd_env	display_env	;
   struct GRmd_env	modbis_env	;
   IGRint		bytes_in, bytes_out ;
   IGRlong 		msg, sts ;

#ifdef DEBUG
printf("	---> Call to VDintGetNoTrimSrf() function \n") ;
#endif

#ifdef DEBUGPLUS
printf("Input obj id/osnum = %d/%d \n", 	lc_obj_ptr->located_obj.objid,
						lc_obj_ptr->located_obj.osnum) ;

printf("Input obj module_info\n") ;
printf("	id/osnum = %d/%d \n", 	lc_obj_ptr->module_info.md_id.objid,
					lc_obj_ptr->module_info.md_id.osnum) ;
printf("	matrix type %d \n", lc_obj_ptr->module_info.md_env.matrix_type) ;
pr_mat("	matrix	       \n", 4, 4, lc_obj_ptr->module_info.md_env.matrix);
printf("\n") ;

printf("Given module_info\n") ;
printf("	id/osnum = %d/%d \n", 	mod_env_ptr->md_id.objid,
					mod_env_ptr->md_id.osnum) ;
printf("	matrix type %d \n", mod_env_ptr->md_env.matrix_type)  ;
pr_mat("	matrix	       \n", 4, 4, mod_env_ptr->md_env.matrix) ;
printf("\n") ;
#endif

modbis_env = *mod_env_ptr ;
ex$get_modid(	mod_osnum	= modbis_env.md_id.osnum,
		mod_id		= &modbis_env.md_id.objid	) ;

sts = om$get_classid(	osnum		= lc_obj_ptr->located_obj.osnum,
			objid		= lc_obj_ptr->located_obj.objid,
			p_classid 	= &obj_cl	) ;
as$status(sts = sts) ;
if (sts != OM_S_SUCCESS) 		return 0 ; /* error */


if (om$is_ancestry_valid(subclassid 	= obj_cl,
			superclassid 	= OPP_EMSsfimpbnd_class_id)
							== OM_S_SUCCESS) {
	/*
		Surface with imposed boundaries  (EMSsfimpbnd)
		=> make a copy of it, and delete its boundaries
	 */

#ifdef DEBUG
	printf("VDintGetNoTrimSrf() : Surface with imposed boundaries\n") ;
#endif

	sts = om$send(msg	= message GRgraphics.GRcopy(&msg,
						&lc_obj_ptr->module_info,
						&modbis_env,	/* ! */
						&new_objid),
		senderid	= NULL_OBJID,
		targetid	= lc_obj_ptr->located_obj.objid,
		targetos	= lc_obj_ptr->located_obj.osnum) ;
	as$status(sts = sts) ;
	if (!(sts & msg & 1))	return 0 ; 	/* error */

	aux_lc_obj.located_obj.objid = new_objid  ;
	aux_lc_obj.located_obj.osnum = modbis_env.md_id.osnum ;
	aux_lc_obj.module_info       = modbis_env ;

#ifdef DEBUG
	printf("id/osnum of EMSsfimpbnd copy is %d/%d \n",
						aux_lc_obj.located_obj.objid,
						aux_lc_obj.located_obj.osnum) ;
#endif

	/*
		Delete boundaries of the copy
	 */

	/* Get the enviroment in which displays are to take place */
	bytes_in = sizeof(display_env);
	gr$get_display_env(	msg 	= &msg,
   				sizbuf	= &bytes_in,
   				buffer 	= &display_env,
   				nret 	= &bytes_out	);
	if (!(msg & 1)) {
		sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
								&modbis_env),
			senderid = NULL_OBJID,
      			targetid = aux_lc_obj.located_obj.objid,
      			targetos = aux_lc_obj.located_obj.osnum) ;
		return 0 ; 	/* error */
		}

	sts = om$send(	msg = message EMSsurface.EMdelete_boundary(
					&msg,
					&modbis_env,		/* ! */
					&display_env.md_id,
					&tmp_obj),
			senderid = NULL_OBJID,
      			targetid = aux_lc_obj.located_obj.objid,
      			targetos = aux_lc_obj.located_obj.osnum) ;
	as$status(sts = sts) ;
	if (!(sts & msg & 1)) {
		sts = om$send(	msg = message GRgraphics.GRdelete(&msg,
								&modbis_env),
			senderid = NULL_OBJID,
      			targetid = aux_lc_obj.located_obj.objid,
      			targetos = aux_lc_obj.located_obj.osnum) ;
		return 0 ; 	/* error */
		}
#ifdef DEBUG
	printf("After deleting boundaries, id/osnum is %d/%d \n", tmp_obj.objid,
								tmp_obj.osnum) ;
#endif
	aux_lc_obj.located_obj = tmp_obj ;
	*new_lc_obj_ptr = aux_lc_obj ;
	return 1 ; 			/* success */
	} 	/* if    */

else {
	/*
		No imposed boundaries
	 */
#ifdef DEBUG
	printf("GetNoTrimSrf() : No imposed boundaries\n") ;
#endif
	return 0 ; /* error */
	}
} /* VDintGetNoTrimSrf() */

/* ==============================================================
 *
 */
int VDintGetExtCurve(
	struct GRvg_construct   *cst_ptr,   	/* I   */
	struct GRlc_info	*lc_obj_ptr)	/* I/O */
/*
								92/05/07
	Description :
		This function supports infinite curves (more precisely,
		extended curves), and should be called when the trim expression
		of a curve is set to INF_B (0 by default).
		A return code of 1 indicates a successful completion.

	Note :
		An intermediate object corresponding to the extended curve
		is constructed, and should be deleted after user by the
		caller.
 */
{
struct GRvg_construct   cstbis  ;
struct GRlc_info	aux_obj ;	/* intermediate to construct object */
struct IGRbsp_curve 	*bsp_curve ;
IGRlong			size   ;
IGRlong			msg, stat ;
IGRint 			ii, k  ;
IGRint			rc_func   ;

bsp_curve = NULL     ;
cstbis   = *cst_ptr  ; /* recopy construction list structure locally */

#ifdef DEBUG
	printf("	---> Call to GetExtCurve() \n") ;
#endif

/*
	Get the extended geometry
 */

	GRabsg_del_by_objid(	&lc_obj_ptr->located_obj.objid,
				&lc_obj_ptr->located_obj.osnum	) ;

  	stat = om$send( msg = message GRvg.GRgetexsize(
				&msg,
				&lc_obj_ptr->module_info.md_env.matrix_type,
				lc_obj_ptr->module_info.md_env.matrix,
			     	&size ),
			senderid = NULL_OBJID,
	  	 	targetid = lc_obj_ptr->located_obj.objid,
	  	 	targetos = lc_obj_ptr->located_obj.osnum) ;

	as$status(sts = stat) ;

	if( !(msg & stat & 1) ) { rc_func = 0 ; goto wrapup ; }

	bsp_curve = (struct IGRbsp_curve *) malloc(size) ;
        if( bsp_curve == NULL ) { rc_func = 0 ; goto wrapup ; }

  	stat = om$send( msg = message GRvg.GRgetexgeom(
				&msg,
				&lc_obj_ptr->module_info.md_env.matrix_type,
				lc_obj_ptr->module_info.md_env.matrix,
			     	(IGRchar*)bsp_curve ),
			senderid = NULL_OBJID,
	  	 	targetid = lc_obj_ptr->located_obj.objid,
	  	 	targetos = lc_obj_ptr->located_obj.osnum) ;

	as$status(sts = stat) ;

	if( !(msg & stat & 1) ) { rc_func = 0 ; goto wrapup ; }

/*
	Handle segment case
 */

	if (bsp_curve->order == 2 && !bsp_curve->phy_closed) {

		ii = 3 * ( bsp_curve->num_poles - 2 ) ;
	    	for (k=0;k<3;k=k+1){
		      bsp_curve->poles[k] =
					101 * bsp_curve->poles[k] -
					100 * bsp_curve->poles[k+3];
		      bsp_curve->poles[k+ii+3] =
		 			101 * bsp_curve->poles[ii+3+k] -
					100 * bsp_curve->poles[ii+k];
	              }
		} /* if */

/*
	Construct the extended curve
 */

aux_obj = *lc_obj_ptr ; 			/* structure recopy */
aux_obj.located_obj.objid = NULL_OBJID ;
aux_obj.located_obj.osnum = cst_ptr->env_info->md_id.osnum ;

aux_obj.module_info.md_id.osnum = cst_ptr->env_info->md_id.osnum ;
ex$get_modid(	mod_osnum = aux_obj.module_info.md_id.osnum,
	        mod_id    = &aux_obj.module_info.md_id.objid) 	;
aux_obj.module_info.md_env = cst_ptr->env_info->md_env ;

cstbis.msg	   = &msg ;
cstbis.env_info    = &aux_obj.module_info  ;
cstbis.geometry    = (IGRchar *) bsp_curve ;

stat  = om$construct (  classid = OPP_GRbcsubbc_class_id,
                          p_objid = &aux_obj.located_obj.objid,
                          osnum   =  aux_obj.located_obj.osnum);
as$status(sts = stat)  ;

stat = om$send(msg = message GRbcsubbc.GRconstruct(&cstbis),
			senderid = NULL_OBJID,
	  	 	targetid = aux_obj.located_obj.objid,
	  	 	targetos = aux_obj.located_obj.osnum) ;
as$status(sts = stat) ;
msg = *cstbis.msg ;
if (!(stat & msg & 1)) {
	#ifdef DEBUG
	write("VDintGetExtCurve() : GRconstruct() failed \n") ;
	#endif
	rc_func = 0 ; goto wrapup ;
	}

#ifdef DEBUG
   gr$display_object(object_id = &aux_obj.located_obj,
		md_env  = &aux_obj.module_info,
		mode	= GRbd) ;
   printf("Constructed extended curve is %d / %d \n",
						aux_obj.located_obj.objid,
						aux_obj.located_obj.osnum) ;
#endif

*lc_obj_ptr = aux_obj ; /* recopy structure to output */
rc_func = 1 ; 		/* success */

wrapup :
	if (bsp_curve) free(bsp_curve) ;
	return rc_func ;
} /* GetExtCurve() */


/*
	------------------------------------------------------------------
 */

end implementation Root;
