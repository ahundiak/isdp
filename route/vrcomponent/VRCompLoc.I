
/* $Id: VRCompLoc.I,v 1.3 2001/02/20 01:12:38 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrcomponent/VRCompLoc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRCompLoc.I,v $
 *  Revision 1.3  2001/02/20 01:12:38  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/12 15:37:57  anand
 *  SP merge
 *
# Revision 1.1  2000/05/23  17:25:20  pinnacle
# Created: route/vrcomponent/VRCompLoc.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/03/25  21:23:32  pinnacle
# Replaced: vrcomponent/VRCompLoc.I for:  by hverstee for route
#
# Revision 1.3  1997/02/19  17:28:12  pinnacle
# Replaced: vrcomponent/VRCompLoc.I for:  by hverstee for route
#
# Revision 1.2  1997/02/18  19:55:48  pinnacle
# Replaced: vrcomponent/VRCompLoc.I for:  by hverstee for route
#
 *
 * History:
 *   ????     ???  Creation
 *
 ***********************************************************************/

/*
     CLASS  NAME: VRComponent
     METHOD NAMES: GRlocate_owner 

***********************************************************************/

class implementation VRComponent;

#include "asbox.h"
#include "vrdbgmacros.h"

/*
#define MY_DEBUG
*/

from VRCnrlSeg	import VRget_planes;

union VRcptunion
{
  IGRdouble     dXXX;
  IGRshort      nXXX[4];
};

/***********************************************************************/


method GRlocate_owner
  (
  IGRlong          *p_msg;        /* OUT    Return code of the method         */
  struct GRlc_cvl  *p_cvl;        /* IN     Module and action handler info    */
  struct GRlc_path *p_path;       /* IN/OUT The locate path of objects        */
  IGRint           *p_path_pos    /* IN/OUT Position of the obj in the path   */
  )
{
  IGRint      status;             /* Status returned by om                    */
  IGRlong     retmsg;             /* Return message */
  struct GRid PlaneId;            /* Terminal plane of the control segment */
  IGRpoint    acc_point;          /* Locate point (temporary stored)          */
  IGRint      index;              /* Index for a loop                         */
  SetProc( VRComponent_GRlocate_owner ); Begin

	/*" AABBCC = %s\n",me->szAABBCC */
	/*" Item   = %d\n",me->Desc.nItemNum*/

  status =
  om$send (msg = message VRGeneric.GRlocate_owner
                                   (p_msg,p_cvl,p_path,p_path_pos), 
          mode = OM_e_wrt_parent, 
      targetid = my_id);
  as$status(action = RET_STATUS);

  /* -- Propose my plane if I have only one determinant support -- */
  if 	(status != OM_I_STOP_SENDING && me->nNbTopo )
  {
    IGRshort nIndex;
    IGRshort ii,jj;

    /*| Store the locate point */

    for(index=0; index<3; index++)
       acc_point[index] = p_cvl->attributes.acc_point[index];

    status =
    om$send (msg = message VRGeneric.VRGetOrigCoor
    		( &retmsg, p_cvl->attributes.acc_point, &p_cvl->module ) ,
    	targetid = my_id );
    as$status(action = RET_STATUS);

    nIndex = -1;

    if ( me->Orientation.nPriIndex >= 0 )
    {	/* -- Propose Primary segment's end plane -- */
    	nIndex = me->Orientation.nPriIndex;
        ii     = nIndex-me->nNbAttr;

        status =
        om$send ( msg = message VRComponent.VRGetMEIX (&retmsg, ii, &jj),
             targetid = my_id);

    	/*" Get the Primary segment at index %d\n", nIndex*/
    	status =
    	om$send ( msg = message VRCnrlSeg.VRget_planes
                        	( &retmsg,NULL,NULL,
    		                  (jj)? NULL : &PlaneId,
    		                  (jj)? &PlaneId : NULL),
    		p_chanselect = &ND_father, from = nIndex, to = nIndex );
    	as$status ( action = RET_STATUS );


    	status =
    	om$send (msg      = message GRcmpowner.GRlocate_owner
					(p_msg, p_cvl, p_path, p_path_pos),
    		senderid = NULL_OBJID,
    		targetid = PlaneId.objid,
    		targetos = PlaneId.osnum);
    }


	if ( me->Orientation.nSecIndex >= 0 && status != OM_I_STOP_SENDING )
	{	/* -- Propose Secondary segment's end plane -- */
		nIndex = me->Orientation.nSecIndex;
        	ii     = nIndex-me->nNbAttr;

        status =
        om$send ( msg = message VRComponent.VRGetMEIX (&retmsg, ii, &jj),
             targetid = my_id);

		/*" Get the Secondary segment at index %d\n", nIndex*/

		status =
		om$send ( msg = message VRCnrlSeg.VRget_planes
			( &retmsg,NULL,NULL,
			(jj)? NULL : &PlaneId,
			(jj)? &PlaneId : NULL),
			p_chanselect = &ND_father, from = nIndex, to = nIndex );
		as$status ( action = RET_STATUS );


		status =
		om$send (msg      = message GRcmpowner.GRlocate_owner
					(p_msg, p_cvl, p_path, p_path_pos),
			senderid = NULL_OBJID,
			targetid = PlaneId.objid,
			targetos = PlaneId.osnum);

	}/* end propose secondary */


	/*| Restore the locate point */

	for(index=0; index<3; index++)
		p_cvl->attributes.acc_point[index] = acc_point[index];

 }/* end if propose planes */

  *p_msg = MSSUCC;
  End
  return (status);

}/* end GRlocate_owner */



method  VRGetMEIX (IGRlong  *msg ;     /* retrieve instance cptindex    */
                   IGRshort  nIX;      /* arrayindex (cptno)            */
                   IGRshort *nVIX)     /* indexvalue                    */
{
  IGRshort  nAltIdx;
  IGRshort  nIntIdx;
  IGRshort  nLocIdx;

  union VRcptunion     uFIELD;
  SetProc( VRComponent_VRGetMEIX ); Begin

  if ((nIX >= 0) && (nIX < VR_MAX_INST_CPTS))
  {
    *msg    = MSSUCC;

    *nVIX   = me->nIndex[nIX];
#ifdef MY_DEBUG
    printf (" MEIX get %d from %d\n",*nVIX, nIX);
#endif
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
#ifdef MY_DEBUG
    printf (" MEIX new %d from %d\n",*nVIX, nIX);
#endif
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

  SetProc( VRComponent_VRSetMEIX ); Begin
  if ((nIX >= 0) && (nIX < VR_MAX_INST_CPTS))
  {
    *msg    = MSSUCC;

    me->nIndex[nIX] = nVIX;
#ifdef MY_DEBUG
    printf (" MEIX set %d to %d\n",nIX, nVIX);
#endif
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
#ifdef MY_DEBUG
    printf (" MEIX new %d to %d\n",nIX, nVIX);
#endif
  }
  else
  {
    *msg    = MSFAIL;
  }

  End
  return OM_S_SUCCESS;
}

end implementation VRComponent;

