/* $Id: VDsupMisc.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupMisc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupMisc.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/11/25  15:50:52  pinnacle
# NULL_GRID
#
# Revision 1.3  1997/10/29  15:23:44  pinnacle
# Add VDmaster.h
#
# Revision 1.2  1997/10/28  18:16:14  pinnacle
# Assorted 2.5 Fixes
#
 *
 * History:
 *      MM/DD/YY        AUTHOR   DESCRIPTION
 *      10/28/97        ah       Added header
 *      11/25/97        ah       Deleted extern NULL_GRID
 ***************************************************************************/

class implementation VDsupGen;

#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bscveval.h"
#include "bsdistptpt.h"
#include "bsiarcln.h"

#include "EMSstruct.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"

#include "VDmsg.h"

#include "VDsupMisc.h"

from  GRcurve       import  GRendpts;
from  GRlinear      import  GRgetpolyline;
from  GRbcsubbc     import  EMcurve_by_poles;
from  EMSplane      import  EMplane;
from  ci_macro	    import  init;
from  ACrg_collect  import  AClist_attribute;

/* --------------------------------------------------------
 * FCT VDsupLinestrToCurve  ORG VLlinestrToCurve
 * The ems project sometimes gives back line strings instead
 * of bsplines, this routine converts them
 */

IGRstat VDsupLinestrToCurve (
  TGRid           *strId,   // IN : lineString id
  TGRmd_env	  *strEnv,  // IN : linestring GRmd_env
  TGRvg_construct *strCnst, // IN : B-spline cnst info
  TGRid 	  *bspId    // OUT: B-spline curve
)

{
  IGRuchar    buffer;     // for EMSdpb functions
  IGRboolean  u_periodic;

  IGRlong     u_order = 0;
  IGRlong     n_poles = 0;

  IGRpoint   *poles = NULL; // list of poles for curve
  TGRlc_info  strLc;

  TGRvg_construct bspCnst;

  IGRstat sts,l_msg,l_ret;

  l_ret = MSFAIL;

  sts = EMdpb_get(
    &l_msg,
     EMSdpb_props,
    &buffer);
  __CheckRC(sts, l_msg, "EMSdpb_props:u_period",wrapup);

  if ((buffer & EMDPB_U_PERIODIC) && (u_order > 2)) u_periodic = TRUE;
  else                                              u_periodic = FALSE;

  sts = VDsupConsObj(
    OPP_GRbcsubbc_class_id,
    strCnst->env_info,
    bspId
  );
  __CheckSTS(sts,"Constructing bspline object",wrapup);

  strLc.located_obj = *strId;
  strLc.module_info = *strEnv;

  bspCnst = *strCnst;
  bspCnst.geometry  = NULL;
  u_order           = 3 ;

  sts = om$send(
    msg = message GRbcsubbc.EMcurve_by_poles(
      u_order,
      u_periodic,
      n_poles,
      poles,
     &strLc,
     &bspCnst 
    ),
    senderid = NULL_OBJID,
    targetid = bspId->objid,
    targetos = bspId->osnum
  );
  __CheckRC(sts, *bspCnst.msg , "EMcurve_by_poles:", wrapup);

  l_ret = MSSUCC;

wrapup:

  return l_ret;
}

/* --------------------------------------------
 * FCT VDsupGetDistPt
 * Finds point on curve at arc distance from
 * given point
 */
IGRstat VDsupGetDistPt(
  TGRbsp_curve *crv,
  IGRdouble     intPar,
  IGRdouble     dirPar,
  IGRdouble     dist,
  TGRpoint     *pt
)
{
  BSrc rc;
  IGRdouble par;
  IGRstat   l_ret = MSFAIL;

  /* Set direction parameter to end of curve to allow
   * for max possible distance
   */
  if (dirPar < intPar) dirPar = 0.0;
  else                 dirPar = 1.0;

  /* Make sure distance is positive else flip */
  if (dist < 0.0) {
    dist = fabs(dist);
    if (dirPar < intPar) dirPar = 1.0;
    else                 dirPar = 0.0;
  }

  BSiarcln(&rc,crv,&intPar,&dist,&dirPar,&par);
  __CheckBSRC(rc,"BSiarcln in Point on Curve",wrapup);

  BScveval(crv,par,0,(IGRpoint*)pt,&rc);
  __CheckBSRC(rc,"BScveval in Point on Curve",wrapup);

#ifdef vdsDEBUG
  printf("Dist %.2f Beg: %.2f End: %.2f  Par: %.2f Result: %.2f,%.2f,%.2f\n",
    dist/12.0,intPar,dirPar,
    par,
    pt->x/12.0,pt->y/12.0,pt->z/12.0);
#endif

  l_ret = MSSUCC;

wrapup:
  return l_ret;
}

/* --------------------------------------------
 * Utility for extracting lc info
 */
IGRstat VDsupGetLcInfo(
  TGRmd_env     *md_env,
  TGRid         *id,
  TGRlc_info    *lc
)
{
  IGRstat sts;

  /* Filter Nulls */
  if ((id->objid == 0) || (id->objid == NULL_OBJID)) goto wrapup;

  lc->module_info.md_id = md_env->md_id;

  sts = om$send(
    msg	= message NDnode.ASreturn_go(
      &lc->located_obj,
      &lc->module_info.md_env.matrix_type,
       lc->module_info.md_env.matrix ),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum 
  );
  __CheckSTS(sts,"Problem with LC Info",wrapup);

  return MSSUCC;

wrapup:
  memset(lc,0,sizeof(TGRlc_info));
  return MSFAIL;
}

/* --------------------------------------------
 * Utility for extracting point
 */
IGRstat VDsupGetPoint(
  TGRmd_env  *md_env,
  TGRid      *id,
  TGRpoint   *pt,
  IGRboolean *bool
)
{
  IGRstat sts,l_msg;
  Tret_struct rs;

  /* Skip Nulls */
  if ((id->objid == 0) || (id->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message NDnode.NDgive_structure(&l_msg,&rs,md_env),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );
  __CheckRC(sts,l_msg,"Bad Point Attribute Structure",wrapup);

  pt->x = rs.var.point_st.pt[0];
  pt->y = rs.var.point_st.pt[1];
  pt->z = rs.var.point_st.pt[2];

  *bool = TRUE;
  return MSSUCC;

wrapup:
  memset(pt,0,sizeof(TGRpoint));
  *bool = FALSE;
  return MSFAIL;
}

/* --------------------------------------------
 * Utility for assigning double value
 */
IGRstat VDsupGetDouble(
  TGRmd_env  *md_env,
  TGRid      *id,
  IGRdouble  *value
)
{
  IGRstat sts,l_msg;
  Tret_struct rs;

  /* Filter Nulls */
  if ((id->objid == 0) || (id->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message NDnode.NDgive_structure(&l_msg,&rs,md_env),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );
  __CheckRC(sts,l_msg,"Bad Attribute Structure",wrapup);

  *value = rs.var.root_pm_st.value;
  return MSSUCC;

wrapup:
  *value = 0.0;
  return MSFAIL;
}

/* -----------------------------------------------------
 * FCT VDsupInitCnst
 * Originally VLinitCnt
 * May be replaced by vd_$fill_cnst_list later on
 */
static struct {
  IGRlong     msg;
  TGRdisplay  display;
  IGRshort    level;
  TGRmd_env   md_env;
} g_VDsupCnstInfo;

void VDsupInitCnst(TGRvg_construct *usr_cnst )
{
  IGRlong  msg,NumberOfBytes,BytesReceived;

  NumberOfBytes = sizeof(g_VDsupCnstInfo.md_env);
  gr$get_module_env(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &g_VDsupCnstInfo.md_env,
                nret   = &BytesReceived);

  ASget_active_symb( &g_VDsupCnstInfo.level, &g_VDsupCnstInfo.display);

  usr_cnst->msg       = &g_VDsupCnstInfo.msg;        
  usr_cnst->env_info  = &g_VDsupCnstInfo.md_env;
  usr_cnst->display   = &g_VDsupCnstInfo.display;
  usr_cnst->level     =  g_VDsupCnstInfo.level;

  usr_cnst->newflag   = FALSE;
  usr_cnst->properties= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  usr_cnst->class_attr= NULL;
  usr_cnst->name      = NULL;
  usr_cnst->geometry  = NULL; 

}

IGRstat VDsupSelectClosestCvObj(
  IGRint      nb_cv,	   /*I number of cv in list	*/
  GRobjid    *list_objid,  /*I list of cv		*/
  TGRmd_env  *cv_env,	   /*I module enviroment of cvs*/
  IGRdouble  *select_pt,   /*I point of selection	*/
  TGRid      *closest	   /*O selected element	*/
)
{
  IGRstat sts;
  TGRid *list_cv;
  IGRint i;
  
  list_cv = (TGRid*) _CALLOC(nb_cv,TGRid);
  __CheckPtr(list_cv,"Allocating Object List",wrapup);

  for(i = 0; i < nb_cv; i++) {
    list_cv[i].objid = list_objid[i];
    list_cv[i].osnum = cv_env->md_id.osnum;
  }
  sts = VDsupSelectClosestCv(
    nb_cv,
    list_cv,
    cv_env,
    select_pt,
    closest
  );

  _FREE(list_cv);
  return sts;

wrapup:
  return MSFAIL;
}

/* ---------------------------------------------------------
 * FCT VDsupSelectClosestCv OLD VLselectClosestCv
 * Returns the closest curve in a list to a given point
 * 01/01/93 : created by Ludovic LE CORVEC (ISDC)
 */
IGRstat VDsupSelectClosestCv(
  IGRint      nb_cv,	   /*I number of cv in list	*/
  TGRid      *list_cv,	   /*I list of cv		*/
  TGRmd_env  *cv_env,	   /*I module enviroment of cvs*/
  IGRdouble  *select_pt,   /*I point of selection	*/
  TGRid      *closest	   /*O selected element	*/
)
{
  IGRstat   sts, l_msg;
  IGRstat   l_ret = MSFAIL;

  IGRint    i;
  IGRdouble proj_pt[3];
  TGRparms  pj_par;
  IGRdouble dist, mdist;
  BSrc      bs_rc;

  /*c initialization */
  closest->objid  = NULL_OBJID;
  mdist	= 100000000;

  for( i=0; i<nb_cv; i++ ){
				
    sts = om$send(
      msg = message GRgraphics.GRptproject(
        &l_msg,
        &cv_env->md_env.matrix_type,
         cv_env->md_env.matrix,
         select_pt,
         proj_pt,
        &pj_par ),
      senderid = NULL_OBJID,
      targetid = list_cv[i].objid,
      targetos = list_cv[i].osnum 
    );
    if(!(sts&l_msg&1)) continue;

    dist = BSdistptpt( &bs_rc, select_pt, proj_pt );
    if( bs_rc != BSSUCC ) continue;

    if( dist < mdist ){ 
      mdist = dist; 
      *closest = list_cv[i]; 
    }
  }

  if( closest->objid != NULL_OBJID ) l_ret = MSSUCC;

  return  l_ret;
}

/* ----------------------------------------------------
 * Min distance between point and curve
 */
IGRstat VDsupGetPtCrvPar(
  TGRbsp_curve *crv,
  TGRpoint     *pt,
  IGRdouble    *par
)
{
  IGRpoint  l_pt;
  IGRdouble l_par;
  IGRdouble l_dist;

  BSrc       rc;

  BSmdstptcv(crv,(IGRdouble*)pt,&l_par,l_pt,&l_dist,&rc);

  if (rc != BSSUCC) {
    *par = -1.0;
    __DBGpr_com("VDsupGetPtCrvPar Failed\n");
    return MSFAIL;
  }

  *par = l_par;
/*
  printf("Direction Pt: %.2f,%.2f,%.2f\n",pt->x/12.0,pt->y/12.0,pt->z/12.0);

  printf("Parameter: %.2f %.2f # %.2f,%.2f,%.2f\n",
    *par,l_par,l_pt[0]/12.0,l_pt[1]/12.0,l_pt[2]/12.0);
*/
/*
  BScveval(crv,0.0,0,l_pt,&rc);
  printf("Parameter: %.2f %.2f # %.2f,%.2f,%.2f\n",
    *par,0.0,l_pt[0]/12.0,l_pt[1]/12.0,l_pt[2]/12.0);

  BScveval(crv,1.0,0,l_pt,&rc);
  printf("Parameter: %.2f %.2f # %.2f,%.2f,%.2f\n",
    *par,1.0,l_pt[0]/12.0,l_pt[1]/12.0,l_pt[2]/12.0);
*/
  return MSSUCC;
}

/* ----------------------------------------------------
 * Intersect two curves
 *
 * Uses min distance point, upt to calling routine
 * to test for tolerance
 */
IGRstat VDsupIntCrvCrv(
  TGRbsp_curve *crv1,
  TGRbsp_curve *crv2,
  TGRpoint     *pt1,
  TGRpoint     *pt2,
  IGRdouble    *par1,
  IGRdouble    *par2,
  IGRdouble    *dist
)
{
  IGRstat    l_ret = MSFAIL;

  IGRint     num = 0;
  IGRdouble *l_par1 = NULL;
  IGRdouble *l_par2 = NULL;
  IGRpoint  *l_pt1  = NULL;
  IGRpoint  *l_pt2  = NULL;
  BSrc       rc;

  *dist = 0.0;

  BSmdistcvcv(
    crv1,crv2,
   &num,
   &l_par1,&l_par2,
   &l_pt1, &l_pt2,
    dist,
   &rc
  );

  if ((rc != BSSUCC) || (num == 0)) goto wrapup;

  pt1->x = l_pt1[0][0];
  pt1->y = l_pt1[0][1];
  pt1->z = l_pt1[0][2];
  pt2->x = l_pt2[0][0];
  pt2->y = l_pt2[0][1];
  pt2->z = l_pt2[0][2];
  
  *par1 = l_par1[0];
  *par2 = l_par2[0];

  l_ret = MSSUCC;
/*
  printf("Int1: %.2f,%.2f,%.2f %.2f\n",pt1->x/12.0,pt1->y/12.0,pt1->z/12.0,*par1);
  printf("Int2: %.2f,%.2f,%.2f %.2f\n",pt2->x/12.0,pt2->y/12.0,pt2->z/12.0,*par2);
*/
wrapup:

  _FREE(l_pt1);
  _FREE(l_pt2);
  _FREE(l_par1);
  _FREE(l_par2);

  if (l_ret == MSSUCC) return MSSUCC;

  __DBGpr_com("VDsupIntCrvCrv Failed\n");

  return MSFAIL;
}

/* ----------------------------------------------------
 * FCT VDsupConsObj
 * Streamline object construction abit
 */
IGRstat VDsupConsObj(GRclassid classid, TGRmd_env *md_env, TGRid *objId)
{
  IGRstat sts;

  objId->osnum = md_env->md_id.osnum;
  objId->objid = NULL_OBJID;

  sts = om$construct(
    classid =  classid,
    osnum   =  objId->osnum,
    p_objid = &objId->objid
  );

  return sts;
}

end implementation VDsupGen;
