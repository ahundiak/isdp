/* $Id: VRCConcLoc.I,v 1.4 2002/04/10 15:14:50 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconccomp / VRCConcLoc.I
 *
 * Description:
 *  		Locate the equipment					      
 *               and if reset the planes of the connection point if the      
 *		 connection point is in the locate tolerance 		    /
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCConcLoc.I,v $
 *	Revision 1.4  2002/04/10 15:14:50  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.3  2001/02/20 01:12:56  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:50:00  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  22:34:30  pinnacle
# Created: route/vrconccomp/VRCConcLoc.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/03/25  21:24:40  pinnacle
# Replaced: vrconccomp/VRCConcLoc.I for:  by hverstee for route
#
# Revision 1.2  1997/02/18  20:02:26  pinnacle
# Replaced: vrconccomp/VRCConcLoc.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  21:52:24  pinnacle
# Replaced: vrconccomp/VRCConcLoc.I for:  by r240_int for route240
#
 *
 * History:
 * 	02/10/92   Bruno	Remove the code adding the component to the 
				locate path because the header was never 
				located ?? and this code  did not seem to be 
				usefull.	   
 *	01/16/96   tlb		Add prototypes
 *      04/05/02   law          TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
class implementation VRConcComp;


#include "igrdef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "grerr.h"
#include "grownerdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "nddef.h"
#include "VRMath.h"
#include "AS_status.h"
#include "vrdbgmacros.h"

#define AS_DEBUG 1

union VRcptunion
{
  IGRdouble     dXXX;
  IGRshort      nXXX[4];
};

method GRlocate_owner
  (
  IGRlong          *p_msg;        /* OUT    Completion code                   */
  struct GRlc_cvl  *p_cvl;        /* IN     Module and action handler info    */
  struct GRlc_path *p_path;       /* IN/OUT The locate path of objects        */
  IGRint           *p_path_pos    /* IN/OUT Position of the obj in the path   */
  )

{
  IGRlong     		status;             /* Status returned by om          */
  IGRpoint 		dummy_pt;           /* dummy points                   */
  struct 	GRid 	planes[3];          /* Parents to get 	       	      */
  double view[3],tmp[3];
  double dist;
  double v_len();

  int ncpt,icpt,ip;

#define MAX_CPT 10
  double con_cor[3*MAX_CPT],*i_cor;

  SetProc( VRConcComp_GRlocate_owner ); Begin
  *p_msg = MSSUCC;
  status = OM_S_SUCCESS;

/* Does locate on my self */

/* NOTE
   the "legal" implementation of the locate owner mechanism 
   is by sending the locate_owner message to the owner before trying
   the locate of the component.
   It does not work on ASplane acting like the owner of the object because
   ASplane tells to the locate that its components are non locatable 
					jla may 19991
*/


  status = om$send(msg = message VRGeneric.GRlocate_owner
			 		     (p_msg, p_cvl, p_path, p_path_pos),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if( status == OM_I_STOP_SENDING ) 
  {
     End
     return status;
  }

/* If the component itself is not locatable, try the support planes of
   connect points  which are in  the locate tolerance */


/* Save initial locate point */

if (p_cvl->attributes.type == GR_pt_loc ||
    p_cvl->attributes.type == GR_bl_loc)
 {
  /*^pr_point("save acc pt",p_cvl->attributes.acc_point);
     pr_point("line pt1",p_cvl->attributes.acc_line.point1);
     pr_point("line pt2",p_cvl->attributes.acc_line.point2);
  */
  tmp[0] = p_cvl->attributes.acc_point[0] ;
  tmp[1] = p_cvl->attributes.acc_point[1] ;
  tmp[2] = p_cvl->attributes.acc_point[2] ;
 }


if (p_cvl->attributes.type == GR_bl_loc)
 { /*| bore line locate             */
   v_sub(p_cvl->attributes.acc_line.point1,
         p_cvl->attributes.acc_line.point2,view);
   dist = v_len(view);
   if(dist>VRGetTol(VR_DIST_TOL)) v_scale(view,1./dist,view);
 }
else if ((p_cvl->attributes.type == GR_rp_loc) ||
         (p_cvl->attributes.type == GR_cv_loc))
 { /*| fence locate */ }
else if ((p_cvl->attributes.type == GR_nam_loc) ||
         (p_cvl->attributes.type == GR_crit_loc))
 { /*| name locate */ }

 /* Send locate owner to the planes of the connection points if they are in 
    the locate tolerance */

 status = om$send(msg = message VRGeneric.VRGetTopo
		    (p_msg,MAX_CPT,&ncpt,NULL,con_cor,NULL,NULL,&p_cvl->module),
		  targetid = my_id);
 as$status();


 for(icpt=0,i_cor=con_cor ; icpt<ncpt ; icpt++,i_cor+=3)
  {
   /* Verify if the connect point is in the locate tolerance */
   if      (p_cvl->attributes.type == GR_pt_loc)
    {
     v_sub(i_cor,tmp,dummy_pt);
     dist = v_len(dummy_pt);
     if(dist>p_cvl->attributes.acc_tolerance) continue;
    }
   else if (p_cvl->attributes.type == GR_bl_loc)
    {
     v_dist_line(i_cor,tmp,view,&dist,dummy_pt);
     /*"dist %lf tol %lf\n",dist,p_cvl->attributes.acc_tolerance */
     if(dist>p_cvl->attributes.acc_tolerance) continue;
    }

   /* Get the planes and send them the locate message */
						       
   p_cvl->attributes.acc_point[0] = *i_cor;
   p_cvl->attributes.acc_point[1] = *(i_cor+1);
   p_cvl->attributes.acc_point[2] = *(i_cor+2);

   status = om$send(msg = message VRGeneric.VRGetPlanesOnCpt(p_msg,(short)icpt,
							planes,&p_cvl->module),
		    targetid = my_id);
   for(ip=0;ip<3;ip++)
    {
     *p_msg = GR_I_NO_RESPONSE;
     status = om$send( msg      = message GRcmpowner.GRlocate_owner( p_msg, 
                                                                  p_cvl,
                                                                  p_path,
                                                                  p_path_pos ),
                    targetid = planes[ip].objid,
                    targetos = planes[ip].osnum);
     as$status( action = RET_STATUS );
     as$status( sts = *p_msg, action = RET_STATUS );
  /*"handler[1] %d\n",p_path[1].call_action_handler */

     if( status == OM_I_STOP_SENDING ) break;
    }
   if( status == OM_I_STOP_SENDING ) break;
  }


/* Restore locate point */

if (p_cvl->attributes.type == GR_pt_loc ||
    p_cvl->attributes.type == GR_bl_loc)
 { /*| Restore initial locate point */
  p_cvl->attributes.acc_point[0] = tmp[0];
  p_cvl->attributes.acc_point[1] = tmp[1];
  p_cvl->attributes.acc_point[2] = tmp[2];
 }

End
return(status);

}


method  VRGetMEIX (IGRlong  *msg ;     /* retrieve instance cptindex    */
                   IGRshort  nIX;      /* arrayindex (cptno)            */
                   IGRshort *nVIX)     /* indexvalue                    */
{
  IGRshort  nAltIdx;
  IGRshort  nIntIdx;
  IGRshort  nLocIdx;

  union VRcptunion     uFIELD;

  SetProc( VRConcComp_VRGetMEIX ); Begin
  if ((nIX >= 0) && (nIX < VR_MAX_INST_CPTS))
  {
    *msg    = MSSUCC;

    *nVIX   = me->nIndex[nIX];
  }
  else
  if ((nIX >= VR_MAX_INST_CPTS) && (nIX < VR_NWMAX_CMPIDX))
  {
    *msg    = MSSUCC;

    nLocIdx = nIX - VR_MAX_INST_CPTS;
    nAltIdx = nLocIdx / 4;
    nIntIdx = nLocIdx - nAltIdx * 4;

    uFIELD.dXXX = me->dOrigCoord[nAltIdx];

    *nVIX = uFIELD.nXXX[nIntIdx];
  }
  else
  {
    *msg    = MSFAIL;
  }

  End
  return OM_S_SUCCESS;
}

method  VRSetMEIX (IGRlong  *msg ;     /* store instance cptindex       */
                   IGRshort  nIX;      /* arrayindex (cptno)            */
                   IGRshort  nVIX)     /* indexvalue                    */
{
  IGRshort  nAltIdx;
  IGRshort  nIntIdx;
  IGRshort  nLocIdx;

  union VRcptunion     uFIELD;
  SetProc( VRConcComp_VRSetMEIX ); Begin
  if ((nIX >= 0) && (nIX < VR_MAX_INST_CPTS))
  {
    *msg    = MSSUCC;

    me->nIndex[nIX] = nVIX;
  }
  else
  if ((nIX >= VR_MAX_INST_CPTS) && (nIX < VR_NWMAX_CMPIDX))
  {
    *msg    = MSSUCC;

    nLocIdx = nIX - VR_MAX_INST_CPTS;
    nAltIdx = nLocIdx / 4;
    nIntIdx = nLocIdx - nAltIdx * 4;

    uFIELD.dXXX = me->dOrigCoord[nAltIdx];

    uFIELD.nXXX[nIntIdx] = nVIX;

    me->dOrigCoord[nAltIdx] = uFIELD.dXXX;
  }
  else
  {
    *msg    = MSFAIL;
  }

  End
  return OM_S_SUCCESS;
}


method  VRGetMECI (IGRlong  *msg ;     /* retrieve instance cptindex    */
                   IGRshort  nCI;      /* arrayindex (cptno)            */
                   IGRshort *nVCI)     /* indexvalue                    */
{
  IGRshort  nAltIdx;
  IGRshort  nIntIdx;
  IGRshort  nLocIdx;
  IGRshort  nCutover;
  IGRshort  nCutend;
  IGRshort  nLocal, nl1, nl2;

  SetProc( VRConcComp_VRGetMECI ); Begin
  nCutover = (VR_MAX_INST_CPTS-1) *3;
  nCutend  = VR_NWMAX_CNSEND * 3;

  if ((nCI >= 0) && (nCI < nCutover))
  {
    *msg    = MSSUCC;

    *nVCI   = me->nConsIndex[nCI];
  }
  else
  if (nCI < nCutend)
  {
    *msg    = MSSUCC;

    nLocIdx = nCI - nCutover;
    nAltIdx = nLocIdx / 2;
    nIntIdx = nLocIdx - nAltIdx * 2;

    nLocal = me->nOrienToPlanes[nAltIdx + 1];
    nl1 = nLocal / 100;
    nl2 = nLocal - (nl1 * 100);

    if (nIntIdx == 0)  *nVCI = nl1;
    else               *nVCI = nl2;
  }
  else
  {
    *msg    = MSFAIL;
  }

  End
  return OM_S_SUCCESS;
}

method  VRSetMECI (IGRlong  *msg ;     /* store instance cptindex       */
                   IGRshort  nCI;      /* arrayindex (cptno)            */
                   IGRshort  nVCI)     /* indexvalue                    */
{
  IGRshort  nAltIdx;
  IGRshort  nIntIdx;
  IGRshort  nLocIdx;
  IGRshort  nCutover;
  IGRshort  nCutend;
  IGRshort  nLocal, nl1, nl2;

  SetProc( VRConcComp_VRSetMECI ); Begin
  nCutover = (VR_MAX_INST_CPTS-1) *3;
  nCutend  = VR_NWMAX_CNSEND * 3;

  if ((nCI >= 0) && (nCI < nCutover))
  {
    *msg    = MSSUCC;

    me->nConsIndex[nCI] = nVCI;
  }
  else
  if (nCI < nCutend)
  {
    *msg    = MSSUCC;

    nLocIdx = nCI - nCutover;
    nAltIdx = nLocIdx / 2;
    nIntIdx = nLocIdx - nAltIdx * 2;

    nLocal = me->nOrienToPlanes[nAltIdx + 1];
    nl1 = nLocal / 100;
    nl2 = nLocal - (nl1 * 100);

    if (nIntIdx == 0)  nl1 = nVCI;
    else               nl2 = nVCI;

    me->nOrienToPlanes[nAltIdx + 1] = nl1 * 100 + nl2;
  }
  else
  {
    *msg    = MSFAIL;
  }

  End
  return OM_S_SUCCESS;
}



end implementation VRConcComp;

