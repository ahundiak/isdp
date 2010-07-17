
/* $Id: VCCmdPBoff.I,v 1.2 2001/02/20 01:09:34 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPBoff.I
 *
 * Description:
 *      Implementation file for place backshell command object
 *         (offset/orientation input)
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPBoff.I,v $
 *  Revision 1.2  2001/02/20 01:09:34  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.4  2000/03/13  17:06:02  pinnacle
# Replaced: vccmd/VCCmdPBoff.I for:  by lawaddel for route
#
# Revision 1.3  1998/12/22  17:01:06  pinnacle
# Replaced: vccmd/VCCmdPBoff.I for:  by lawaddel for route
#
# Revision 1.2  1998/06/24  19:32:28  pinnacle
# tr179801106
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/26  22:02:42  pinnacle
# Replaced: vccmd/VCCmdPBoff.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.1  1997/07/14  22:59:02  pinnacle
# Created: vccmd/VCCmdPBoff.I by hverstee for cabling
#
 *
 * History:
 * 06/18/96  hv   New
 * 04/26/98  KDD  Always use full matrix when creating new component.
 * 06/24/98  ah   TR179801106 Backshell problem
 * 12/20/98  law  CR179802404 - Allow rotating terminals, connectors
 * 03/13/00  law  cr179900814 - Allow backshells on guides
 *************************************************************************/

class implementation VCCmdPB;

#include "VCCmdForm.h"
#include "VCmacros.h"
#include "VCproto.h"
#include "maidmx.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

extern double     atof();

/*
#define MY_DEBUG
*/

%safe
#include "VX_FIproto.h"
%endsafe


from VCRoot	import VCGetMatrix;
from   VCGuide     import    VCGetCptCoord;

/**********************************************************/

method VCCmdPosition ( int * sts )
{
  IGRlong	retmsg;
  IGRdouble tcoord[3];
    IGRlong status = OM_S_SUCCESS;

  SetProc( Md VCCmdPosition ); Begin 

  __DBGpr_obj( " Parent Id ", me->RefId );

  *sts = VC_RTC_ALLOK;

/* 4-98 KDD Always use full matrix 
*
*  me->dValues[0] = me->event1.event.button.x;
*  me->dValues[1] = me->event1.event.button.y;
*  me->dValues[2] = me->event1.event.button.z;
*
*  me->nVal = 3;
*  me->nVCConn_type |= VC_TOFF_COORDS;
*/

  MAidmx (&retmsg, me->dValues);

/* 4-98 KDD translate the terminal to the current mouse "clicked" position */
 
  /* modified for cr179900814 */
  tcoord[0] = me->event1.event.button.x;
  tcoord[1] = me->event1.event.button.y;
  tcoord[2] = me->event1.event.button.z;

/*** Block added for CR179900814 ***/
  {
   GRclassid          parentClassId;
   IGRchar         c200ClassName[200];
   IGRshort CpNum;
   IGRdouble dCptCoor0[3], dCptCoor1[3];

   om$get_classid (objid = me->RefId.objid,
                   osnum = me->RefId.osnum,
               p_classid = &parentClassId);

   om$get_classname(classid = parentClassId, classname = c200ClassName);
   if(!strcmp(c200ClassName,"VCGuide"))
   {
      IGRint i;
      IGRdouble dP0,dP1;
      BSrc  rc;

      CpNum = 0;
      status =   om$send ( msg = message VCGuide.VCGetCptCoord( &retmsg,
                        CpNum,dCptCoor0,&me->ModuleInfo  ),
                                senderid = NULL_OBJID,
                                targetid = me->RefId.objid,
                                targetos = me->RefId.osnum );
      CpNum = 1;
      status =   om$send ( msg = message VCGuide.VCGetCptCoord( &retmsg,
                        CpNum,dCptCoor1,&me->ModuleInfo  ),
                                senderid = NULL_OBJID,
                                targetid = me->RefId.objid,
                                targetos = me->RefId.osnum );
      dP1 = BSdistptpt (&rc, tcoord, dCptCoor1);
      dP0 = BSdistptpt (&rc, tcoord, dCptCoor0);
      if(dP0 < dP1)
      {
         for(i=0; i<3; i++) tcoord[i] = dCptCoor0[i];
      }
      else
      {
         for(i=0; i<3; i++) tcoord[i] = dCptCoor1[i];
      }
    }
  }

  /* modified for cr179900814 */
  me->dValues[3] = tcoord[0] -
                                        me->ModuleInfo.md_env.matrix[3];
  me->dValues[7] = tcoord[1] -
                                        me->ModuleInfo.md_env.matrix[7];
  me->dValues[11]= tcoord[2] -
                                        me->ModuleInfo.md_env.matrix[11];
  /* added by alwin for TR179801106 */
  /* the offsets of the Connection Component w.r.t the Parent Terminal has to be
  stored instead of the actual co-ordinates. */
  /* Major modifications for rotation - CR179802404 */
  {
    IGRshort	nCpt = -1;
    IGRdouble	dRefMatrix[16],InvRefMat[16];
    IGRdouble   Click_point[4]={0.0, 0.0, 0.0, 1.0},
                My_Offset[4]={0.0, 0.0, 0.0, 1.0};
    IGRshort                      I_four = 4, I_one= 1;
    IGRint dumndx;
    struct ACrg_coll GetAttr;
    IGRdouble dang;

    /* modified for cr179900814 */
    Click_point[0] = tcoord[0];
    Click_point[1] = tcoord[1];
    Click_point[2] = tcoord[2];

    __DBGpr_com( " Get the Parent Matrix " );
    status = om$send ( msg = message VCRoot.VCGetMatrix( &retmsg, nCpt, 
				dRefMatrix, &me->ModuleInfo ),
			    targetid = me->RefId.objid,
			    targetos = me->RefId.osnum );
    /* Added for CR179802404 */
    VC_mat_invert(dRefMatrix, InvRefMat);
    MAmulmx(&retmsg,&I_four,&I_four,&I_one, InvRefMat, Click_point, My_Offset);

    me->dValues[3] = My_Offset[0];
    me->dValues[7] = My_Offset[1];
    me->dValues[11]= My_Offset[2];
    __DBGpr_mat( " Offset Conn. Component ", me->dValues );
    /* Store the angle from the collection into dValues */
     GetAttr.desc.value.att_exp = 0.0;
     status = om$send (msg = message VCAT.VCAT_get
                              (&retmsg, VC_SYSTEM, -1,VC_N_PID_ANGLE_DB,
                                    &dumndx, &GetAttr),
                      targetid = my_id);
     __DBGpr_int("objid for angle is ",my_id);
     dang = GetAttr.desc.value.att_exp * M_PI / 180.0;
     __DBGpr_dbl("angle fetched is", GetAttr.desc.value.att_exp);

     /* CR179802404-rotation values stored in me->dValues */
     me->dValues[0] = me->dValues[5] = cos(dang);
     me->dValues[4] = sin(dang);
     me->dValues[1] = -me->dValues[4];

    __DBGpr_mat( " Final Offset Conn. Component ", me->dValues );
    __DBGpr_mat( " Final Refmatrix Component ", dRefMatrix );
  }
  /* added by alwin for TR179801106 */

  me->nVal = 16;
  me->nVCConn_type |= VC_TOFF_C_FULL;

  End
  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdRotate ( int * sts )
{
  IGRdouble dAngleXY;

  dAngleXY       = 0.0;
  me->dValues[3] = 0.0;

  if (me->event1.response == EX_STRING)
  {
    IGRchar      szSTR[50];

    strcpy (szSTR, me->event1.event.keyin);

    dAngleXY = VC_DEG_RAD(atof(szSTR)) + M_PI;

  }
  else
  if (me->event1.response == EX_VALUE)
    dAngleXY = VC_DEG_RAD(me->event1.event.value) + M_PI;
  else
  if (me->event1.response == GRm_ANGLE)
    dAngleXY = VC_DEG_RAD(me->event1.event.value) + M_PI;
  else
  if (me->event1.response == EX_DATA)
  {
    IGRdouble dx, dy;

    dx      = me->event1.event.button.x - me->dValues[0];
    dy      = me->event1.event.button.y - me->dValues[1];

    if (!((dx == 0) && (dy == 0)))
    {
      dAngleXY = atan2 (dy, dx);
    }
  }

  if (dAngleXY != 0.0)
  {
    /*    normalize angles     */

    while (dAngleXY > (M_PI))
      dAngleXY -= M_PI*2.0;

    me->dValues[3] = dAngleXY;
    me->nVal = 4;

    __DBGpr_mat( " Rotate 1x4 Conn. Component ", me->dValues );
#ifdef MY_DEBUG
    printf ("ANGLESET %f  in DEG %f\n",dAngleXY, VC_RAD_DEG(dAngleXY));
#endif

    me->nVCConn_type = me->nVCConn_type  & (~VC_TOFF_COORDS);
    me->nVCConn_type |= VC_TOFF_C_ANG;
  }

  *sts = me->ret = VC_RTC_ALLOK;

  return (OM_S_SUCCESS);
}

/**********************************************************/

end implementation VCCmdPB;

