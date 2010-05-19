/* $Id: VDi2e.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl/VDi2e.I
 *
 * Description: Intersect 2 elements routines
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDi2e.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/25  15:06:38  pinnacle
# ah
#
# Revision 1.1  1997/10/28  17:42:26  pinnacle
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
 *      06/13/96        ah              Added Drop Graphic Group
 *      10/28/97        ah              Broke out some routines
 *	11/30/97	ah		Added VDmaster.h
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

#include "emssfintdef.h"
#include "vdAPImacros.h"
#include "vdintproto.h"


from GRvg		import GRgetsize, GRgetgeom, GRgetexsize, GRgetexgeom,
			       GRdetplane, EMintplane ;

from GRgraphics		import GRdisplay, GRcptform, GRdelete, GRgetrang,
			       GRptproject, GRconstruct, GRcopy ;

from GR3dlineseg import GRaltconstruct;

from EMSsubbs    import EMproject_curve_along_surface_normals;

extern GRclassid OPP_GR3dlineseg_class_id ;
extern GRclassid OPP_GR3dinfline_class_id ;

/* ---------------------------------------------------- */
/* Intersection beteen bounded plane and infinite plane */

int VDintPlWithInfPl( 
  TGRlc_info      *infPlaneLc,  /* I infine plane   */
  TGRlc_info      *bndPlaneLc,  /* I bound  plane   */	
  TGRvg_construct *cst,         /* I */
  IGRint          *intNum,      /* O number of intersection*/
  TGRid           *intIds)	/* O list of intersection  */
{
  IGRdouble ptsPlane[12];
  TGRplane  infPlane;
  TGRplane  bndPlane;

  IGRpoint  intPnt;
  IGRvector intVec;
  IGRint    intFlag;

  IGRdouble   lineMul;
  IGRdouble   linePts[6];
  TGRpolyline lineGeom;
  TGRlc_info  lineLc;

  GRobjid    *projIds = NULL;
  IGRlong     projNum = 0;

  BSrc      rc;
  IGRlong   sts, msg, i;
  IGRint    retFlag = 0;

  // Init
  *intNum = 0;

  lineLc.located_obj.objid = NULL_OBJID;
  lineLc.located_obj.osnum = cst->env_info->md_id.osnum ;

  infPlane.point  = &ptsPlane[0] ;   	
  infPlane.normal = &ptsPlane[3] ;   	
  bndPlane.point  = &ptsPlane[6] ;   	
  bndPlane.normal = &ptsPlane[9] ;   	

  // Grab infinite Planes
  sts = om$send(
    msg = message GRvg.GRdetplane(
      &msg,
      &infPlaneLc->module_info.md_env.matrix_type,
       infPlaneLc->module_info.md_env.matrix,
      &infPlane
    ),
    senderid = NULL_OBJID,
    targetid = infPlaneLc->located_obj.objid,
    targetos = infPlaneLc->located_obj.osnum
  ) ;
  __CheckRC (sts,msg,"Getting Plane Geometry",wrapup);

  sts = om$send(
    msg = message GRvg.GRdetplane(
      &msg,
      &bndPlaneLc->module_info.md_env.matrix_type,
       bndPlaneLc->module_info.md_env.matrix,
      &bndPlane
    ),
    senderid = NULL_OBJID,
    targetid = bndPlaneLc->located_obj.objid,
    targetos = bndPlaneLc->located_obj.osnum
  ) ;
  __CheckRC (sts,msg,"Getting Plane Geometry",wrapup);

  // Intersect as infinite planes
  BSpl_pl(
    bndPlane.point, bndPlane.normal,
    infPlane.point, infPlane.normal,
    &intFlag,intPnt,intVec,
    &rc
  );
  if ((rc != BSSUCC) || (intFlag != BSCINTERSECTING)) {
    printf("Plane to Plane Intersection Failed!\n");
    goto wrapup;
  }

  // Make big line segment
  lineMul = 10000.0 * 10000.0;
  linePts[0] = intPnt[0] + (lineMul * intVec[0]);
  linePts[1] = intPnt[1] + (lineMul * intVec[1]);
  linePts[2] = intPnt[2] + (lineMul * intVec[2]);
  linePts[3] = intPnt[0] - (lineMul * intVec[0]);
  linePts[4] = intPnt[1] - (lineMul * intVec[1]);
  linePts[5] = intPnt[2] - (lineMul * intVec[2]);

  lineGeom.num_points = 2 ;
  lineGeom.points     = &linePts[0];

  cst->geometry = (char *)&lineGeom;

  sts = om$construct (  
    classid = OPP_GR3dlineseg_class_id,
    p_objid = &lineLc.located_obj.objid,
    osnum   =  lineLc.located_obj.osnum
  );
  __CheckRC (sts,1,"Constructing GR3dlineseg",wrapup);

  sts = om$send(
    msg = message GR3dlineseg.GRaltconstruct(cst),
    senderid = NULL_OBJID,
    targetid = lineLc.located_obj.objid,
    targetos = lineLc.located_obj.osnum
  ) ;
  __CheckRC (sts,1,"Constructing GR3dlineseg",wrapup);

  lineLc.module_info = *cst->env_info;

  // Trim to bounded plane
  sts = om$send(
    msg = message EMSsubbs.EMproject_curve_along_surface_normals(
      &lineLc,
       bndPlaneLc,
       cst,
       FALSE,TRUE,
      &projNum,&projIds,
      &msg
    ),
    senderid = NULL_OBJID,
    targetid = bndPlaneLc->located_obj.objid,
    targetos = bndPlaneLc->located_obj.osnum
  );

  __CheckRC (sts,msg,"Constructing Projected Curve",wrapup);
  __CheckPtr(projIds,"Constructing Projected Curve",wrapup);

  // Copy Results
  *intNum = projNum;
  for(i = 0; i < projNum; i++) {
    intIds[i].objid = projIds[i];
    intIds[i].osnum = lineLc.located_obj.osnum;
  }

  retFlag = 1;

wrapup:

  if (lineLc.located_obj.objid != NULL_OBJID) {
    vd_$bulk_delete(
      theEnv = &lineLc.module_info, 
      grids  = &lineLc.located_obj
    );
  }

  if (projIds) free(projIds);

  return retFlag;

} /* VDintCrvPlInf() */


#ifdef XXX_YYY
IGRstat VDsupPlaceCurve(
  VDsupConsInfo *info,
  TGRpoint      *ptList,
  IGRlong        j
) 
{
  IGRlong traceNum = info->traceNum;
  IGRstat sts,l_msg,l_ret;

  TGRmd_env *md_env = info->md_env;

  TGRvg_construct cnst;

  struct {
    TGRlc_info lc;
    TGRid      id,footId,trimId;
    GRobjid   *list;
    IGRlong    num;
    IGRchar    name[DI_PATH_MAX];
  } proj;

  UI_status("Support Macro Placing Curve Begins...");

  l_ret = MSFAIL;

  memset(&fit, 0,sizeof(fit));
  memset(&proj,0,sizeof(proj));


  /* Project to surface just to be sure get surface curve */
  proj.lc.module_info = *md_env;
  proj.lc.located_obj =  fit.id;

  cnst.geometry = NULL;
  sts = om$send(
    msg = message EMSsubbs.EMproject_curve_along_surface_normals(
      &proj.lc,
      &info->baseSurfLc,
      &cnst,
       FALSE,FALSE,
      &proj.num,&proj.list,
      &l_msg
    ),
    senderid = NULL_OBJID,
    targetid = info->baseSurfLc.located_obj.objid,
    targetos = info->baseSurfLc.located_obj.osnum
  );
  __CheckRC (sts,l_msg,"Constructing Projected Curve",wrapup);
  __CheckPtr(proj.list,"Constructing Projected Curve",wrapup);

  /* Find desired result */
  if (proj.num == 0) {
    __CheckRC(0,0,"No Projected Curves",wrapup);
  }
  if ((proj.num == 1) || (info->selBool != TRUE)) {
    proj.id.objid = proj.list[0];
    proj.id.osnum = md_env->md_id.osnum;
  }
  else {
    sts = VDsupSelectClosestCvObj(
      proj.num,
      proj.list,
      info->md_env,
     (IGRdouble*)&info->selPt,
     &proj.id
    );
    __CheckSTS(sts,"Getting Closest Curve",wrapup);
  }

  /* Convert linestrings to curve */
  if (vd_$is_ancestry_valid(
        object = &proj.id, 
        classid = OPP_GR3dlinestr_class_id
      )
    ) {
      sts = VDsupLinestrToCurve(&proj.id,md_env,&cnst,&proj.footId);
      __CheckSTS(sts,"Converting line string",wrapup);
    }
  else {
    sts = vd_$grCopy(
      msg = &l_msg,
      frObj = &proj.id,     frEnv = md_env,
      toObj = &proj.footId, toEnv = md_env
    );
    __CheckRC(sts,l_msg,"Copying line string",wrapup);
  }

  /* Cut It */
  sts = VDsupCutCurve(info,&proj.footId,&proj.trimId);
  __CheckSTS(sts,"Cutting Curve",wrapup);

  if (proj.trimId.objid != NULL_OBJID) {
    vd_$bulk_delete(theEnv = md_env, grids = &proj.footId);
    proj.footId = proj.trimId;
  }

  info->feetListId[j] = proj.footId;
 *info->feetNum = *info->feetNum + 1;

  l_ret = MSSUCC;
  if (*info->occName == NULL) goto wrapup;

  sprintf(proj.name,"%s_%02d",info->occName,j+1);

  di$rm_name(
    regexp = proj.name,
    osnum  = proj.footId.osnum
  );

  om$send(
    msg = message GRvg.GRchgname(&l_msg,md_env,proj.name),
    senderid = NULL_OBJID,
    targetid = proj.footId.objid,
    targetos = proj.footId.osnum
  );

wrapup:

  vd_$bulk_delete(theEnv = md_env, objids = proj.list, count = proj.num);
  vd_$bulk_delete(theEnv = md_env, grids  = &fit.id);

  _FREE(fit.bsp.poles);
  _FREE(fit.bsp.knots);
  _FREE(proj.list);

  UI_status("Support Macro Placing Curve Complete");

  return l_ret;
}
#endif

/* ------------------------------------------------------------
 */

#ifdef EX_PL_PL

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
#endif

end implementation Root;
