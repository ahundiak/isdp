/* $Id: VDgeomGet.I,v 1.2 2001/01/11 18:41:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomGet.I
 *
 * Description:	Geometry Get Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomGet.I,v $
 *      Revision 1.2  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.3  2000/06/19  18:06:40  pinnacle
# ah
#
# Revision 1.2  2000/04/28  19:32:24  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.1  2000/03/24  17:16:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/00  ah      Creation, Broke up geom routines
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDmem.h"

from EMSsubbs import EMget_boundaries;

from GRvg import GRgetsize;
from GRvg import GRgetgeom;

/* ----------------------------------------------
 * My own little geometry extractor
 * so I understand what is going on
 */
IGRstat VDgeomGet(TGRobj_env    *a_objOE,
		  TGRid         *a_objID,
		  TGRmdenv_info *a_mat,
		  IGRchar      **a_buf)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRlong numBytes;

  TGRid objID;
  TGRmdenv_info mat;

  // Output buffer
  if (a_buf == NULL) goto wrapup;
  *a_buf = NULL;

  // Object
  objID.objid = NULL_OBJID;
  
  if (a_objID) objID = *a_objID;
  if (a_objOE) objID =  a_objOE->obj_id;
  
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Matrix
  if (a_mat == NULL) {
    if (a_objOE) a_mat = &a_objOE->mod_env.md_env;
  }
  if (a_mat == NULL) {
    a_mat = &mat;
    MAidmx(&msg,mat.matrix);
    mat.matrix_type = MAIDMX;
  }

  // BS buffer nonsense
  GRabsg_del_all();

  sts = om$send(msg = message GRvg.
		GRgetsize(&msg,
			  &a_mat->matrix_type,
			  a_mat->matrix,
			  &numBytes),
		senderid = NULL_OBJID,
		targetid = objID.objid,
		targetos = objID.osnum);
  if (!(sts & msg & 1)) {
    printf("Problem Getting Geometry Size ");
    goto wrapup;
  }

  *a_buf = _MALLOC(numBytes,char);
  if (*a_buf == NULL) {
    printf("Problem Getting Geometry Memory ");
    goto wrapup;
  }

  sts = om$send(msg = message GRvg.
		GRgetgeom(&msg,
			  &a_mat->matrix_type,
			  a_mat->matrix,
			  *a_buf),
		senderid = NULL_OBJID,
		targetid = objID.objid,
		targetos = objID.osnum);
  GRabsg_del_all();

  if (!(sts & msg & 1)) {
    _FREE(*a_buf);
    *a_buf = NULL;
    printf("Problem Getting Geometry ");
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    vdobj$Print(objID = &objID);
  }
  return retFlag;
}

/* ----------------------------------------------
 * Wrapper just to save on some typecasting
 */
IGRstat VDgeomGet2(TGRobj_env      *a_objOE,
		   TGRid           *a_objID,
		   TGRmdenv_info   *a_mat,
		   TGRbsp_curve   **a_crv,
                   TGRbsp_surface **a_srf)
{
  if (a_crv) return VDgeomGet(a_objOE,a_objID,a_mat,(IGRchar**)a_crv);
  if (a_srf) return VDgeomGet(a_objOE,a_objID,a_mat,(IGRchar**)a_srf);
  return 0;
}

/* ----------------------------------------------
 * Specifically for surfaces with an edge option
 */
IGRstat VDgeomGetSurface(TGRobj_env      *a_objOE,
                         TGRid           *a_objID, 
                         TGRmdenv_info   *a_mat,
                         IGRboolean       a_getEdges,
                         TGRbsp_surface **a_srf)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid objID;
  TGRmdenv_info   mat;
  TGRbsp_surface *bsp;

  // Use the normal routine
  sts = VDgeomGet(a_objOE, a_objID, a_mat, (IGRchar **)a_srf);
  if ((a_srf == NULL) || (*a_srf == NULL)) goto wrapup;
  if (!(sts & 1)) goto wrapup;

  bsp = *a_srf;

  // If don't want edges then done
  if (!a_getEdges) {
    retFlag = 1;
    goto wrapup;
  }

  // Need to go though object nonsense again
  objID.objid = NULL_OBJID;
  
  if (a_objID) objID = *a_objID;
  if (a_objOE) objID =  a_objOE->obj_id;
  
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Matrix
  if (a_mat == NULL) {
    if (a_objOE) a_mat = &a_objOE->mod_env.md_env;
  }
  if (a_mat == NULL) {
    a_mat = &mat;
    MAidmx(&msg,mat.matrix);
    mat.matrix_type = MAIDMX;
  }

  // Get the edges
  sts = om$send(msg = message EMSsubbs.
                EMget_boundaries(&msg,
				 &mat.matrix_type,
				  mat.matrix,
				 &bsp->on_off,
				 &bsp->num_boundaries,
				 &bsp->bdrys),
		senderid = NULL_OBJID,
		targetid = objID.objid,
		targetos = objID.osnum);
  if (!(sts & msg & 1)) {
    printf("*** Problem getting edge geometry for\n");
    vdobj$Print(objID = &objID);
    goto wrapup;
  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Get the min distance from point to a curve
 */
IGRstat VDgeomGetDisPtCv(IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis)
{
  IGRstat retFlag = 0;
  
  IGRshort   k,n;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  BSrc       rc;

  // Arg check
  if (dis == NULL) goto wrapup;
  *dis = 0.0;
  
  BSmdistptcv(crv,pt,&k,&n,&pars,dis,&intpars,&rc);
  if (rc == BSSUCC) retFlag = 1;
  
wrapup:
  _FREE(pars);
  _FREE(intpars);
  
  return retFlag;
}

/* ---------------------------------------------------
 * Get the min distance from point to a curve
 */
IGRstat VDgeomGetDisPtCrv(IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis)
{
  IGRstat retFlag = 0;
  
  IGRshort   k,n;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  BSrc       rc;

  // Arg check
  if (dis == NULL) goto wrapup;
  *dis = 0.0;
  
  BSmdistptcv(crv,pt,&k,&n,&pars,dis,&intpars,&rc);
  if (rc == BSSUCC) retFlag = 1;
  
wrapup:
  _FREE(pars);
  _FREE(intpars);
  
  return retFlag;
}

/* ---------------------------------------------------
 * Get the min distance and the parameter value from point to a curve
 */
IGRstat VDgeomGetDisPtParCrv(IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis, IGRdouble *par)
{
  IGRstat retFlag = 0;
  
  IGRshort   k,n;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  IGRdouble  disx = 0.0;
  BSrc       rc;

  // Arg check
  if (dis) *dis = 0.0;
  if (par) *par = 0.0;

  
  BSmdistptcv(crv,pt,&k,&n,&pars,&disx,&intpars,&rc);
  if (rc == BSSUCC) retFlag = 1;
  
  if (dis) *dis = disx;
  if ((par) && (pars)) *par = pars[0];
  
wrapup:
  _FREE(pars);
  _FREE(intpars);
  
  return retFlag;
}

/* ---------------------------------------------------
 * Get the distance between points
 */
IGRstat VDgeomGetDisPtPt(IGRpoint pt1, IGRpoint pt2, IGRdouble *dis)
{
  IGRstat retFlag = 0;
  
  BSrc       rc;

  // Do It
  if (dis == NULL) goto wrapup;  
  *dis = BSdistptpt(&rc,pt1,pt2);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------
 * Gets point along surface
 */
IGRstat VDgeomGetSrfPt(TGRbsp_surface *bsp, 
		       IGRdouble u, 
		       IGRdouble v, 
		       IGRpoint pt)
{
  IGRstat retFlag = 0;
  BSrc rc;

  IGRint   numDeriv = 0;

  BSsfeval(bsp,u,v,numDeriv,(IGRpoint*)pt,&rc);
  if (rc != BSSUCC) goto wrapup;
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------
 * Gets point along curve
 */
IGRstat VDgeomGetCrvPt(TGRbsp_curve *bsp, IGRdouble u, IGRpoint pt)
{
  IGRstat retFlag = 0;
  BSrc rc;

  IGRint   numDeriv = 0;

  BScveval(bsp,u,numDeriv,(IGRpoint*)pt,&rc);
  if (rc != BSSUCC) goto wrapup;
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Gets the end points of a curve
 */
IGRstat VDgeomGetEndPoints(TGRbsp_curve *crv, IGRpoint pt1, IGRpoint pt2)
{
  VDgeomGetCrvPt(crv,0.0,pt1);
  VDgeomGetCrvPt(crv,1.0,pt2);
  return 1;
}

IGRstat VDgeomGetCrvEndPts(TGRbsp_curve *crv, IGRpoint pt1, IGRpoint pt2)
{
  VDgeomGetCrvPt(crv,0.0,pt1);
  VDgeomGetCrvPt(crv,1.0,pt2);
  return 1;
}

/* -------------------------------------------------
 * Make getting tolerances easier
 */
IGRstat VDgeomGetTolerance(IGRdouble *basis,
                           IGRdouble *cht,
                           IGRdouble *offset,
                           IGRdouble *arclen,
                           IGRdouble *stepmax)
{
  IGRstat retFlag = 1;

  if (basis)   gr$get_basis_tolerance       (buffer = basis);
  if (cht)     gr$get_chord_height_tolerance(buffer = cht);
  if (offset)  gr$get_offset_tolerance      (buffer = offset);
  if (arclen)  gr$get_arclength_tolerance   (buffer = arclen);
  if (stepmax) gr$get_maximum_step_size     (buffer = stepmax);

  return retFlag;
}

end implementation Root;









