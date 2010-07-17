
/* $Id: VCCbreak.I,v 1.2 2001/02/20 01:08:38 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccable / VCCbreak.I
 *
 * Description:
 *
 *      Place break symbol.
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCbreak.I,v $
 *  Revision 1.2  2001/02/20 01:08:38  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  20:29:30  pinnacle
# Replaced: vccable/VCCbreak.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/08/15  12:44:56  pinnacle
# Replaced: vccable/VCCbreak.I for:  by hverstee for cabling
#
# Revision 1.2  1997/07/26  13:37:24  pinnacle
# Replaced: vccable/VCCbreak.I for:  by hverstee for cabling
#
# Revision 1.1  1997/05/06  23:10:28  pinnacle
# Created: vccable/VCCbreak.I by hverstee for cabling
#
 *
 * History:
 *  06/10/96  hv      initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
#define MY_DEBUG	1
*/

#include "godef.h"
#include "gotextdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "nddef.h"
#include "ndmacros.h"
#include "cotxmacros.h"

#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

#include "bsdistptpt.h"

#include "VCsys.h"

from    GRlinear   import   GRgetpolyline;
from    GRlinear   import   GRputpolyline;


method VCCbPlaceBreak (IGRlong         *msg;
                       IGRdouble       *dCoord;
                       IGRdouble       *dPrev;
                       IGRint          *NumBrk;
                struct GRid            *OutId;
                struct GRvg_construct  *cnst_lis;
                struct GRmd_env        *md_env)

{
  IGRdouble    dIdMat[16],dDiameter;
  IGRdouble    dVec[3];
  BSrc         rc;
  IGRlong      retmsg;
  IGRshort     nProperties,nLength;

  struct GRdpb_text_symb  TxtSymb;

SetProc(VCCable_VCCbPlaceBreak ); Begin

  *msg = MSSUCC;

  if VC_EMPTYSTR (VCSYSGLB_brkchr) return (OM_S_SUCCESS);

  BSmkvec (&rc, dVec, dPrev, dCoord);

  VC_mat_from_vector (dCoord, dVec, dIdMat);

#ifdef MY_DEBUG
  printf (" Break at %f %f %f from %f %f %f\n",
                        dCoord[0],dCoord[1],dCoord[2],
                        dPrev[0],dPrev[1],dPrev[2]);
#endif

  /* -- Get diameter for error symbol sizing -- */

  {
    dDiameter = 2.0;
    /*" Diameter for text dimensions = %f\n",dDiameter */
  }

  /* -- Fill in text Attributes -- */
  TxtSymb.Active_font          = 0;
  TxtSymb.Active_fraction_font = 0;
  TxtSymb.Active_symbol_font   = 0;
  TxtSymb.Active_ascii_font    = 0;
  TxtSymb.Active_just          = (IGRshort)CENTER_CENTER;
  TxtSymb.Active_width         = dDiameter;
  TxtSymb.Active_height        = 1.3*dDiameter;
  TxtSymb.Active_charspac      = 1.0;
  TxtSymb.Active_linespac      = 0.0;
  TxtSymb.Active_flags         = (IGRshort)VI_FLAG;

  nProperties = (IGRshort) (GRIS_LOCATABLE |
        GRIS_DISPLAYABLE | GRIS_VIEW_INDEP);

  nLength = 1,

  co$place_text ( msg    = &retmsg,
            text_string  = VCSYSGLB_brkchr,
            text_length  = &nLength,
               origin    = dCoord,
             rot_matrix  = dIdMat,
         ActiveDisplay   = cnst_lis->display,
           ActiveLevel   = cnst_lis->level,
            Properties   = &nProperties,
            ModuleInfo   = md_env,
             TextSymb    = &TxtSymb,
                flags    = 0,    /* no disp, non empty */
              buffer     = OutId);

  if ( retmsg != MSSUCC ) return ( OM_E_ABORT );

  (*NumBrk)++;

End;
  return ( OM_S_SUCCESS );
}

method  VCCbInsBrk (IGRlong        *msg;
                    IGRint          SecNum;
                    IGRint          VtxNum;
                    IGRdouble      *dCoord;    /*  coordinates            */
            struct  GRmd_env       *md_env)
{
  IGRlong        retmsg;
  IGRint         status;
  IGRint         NumSec;
  IGRint         NumBend;
  IGRint         iVert;
  IGRint         iSect;
  IGRint         action;
  IGRint         cn_type;
  IGRint         iMstr;
  IGRint         i;
  IGRint         isec;
  BSrc           rc;
  IGRdouble     *dVertex;
  IGRdouble      diff[3];
  GRobjid        New;

  IGRdouble      dV1[3], dV2[3];
  IGRdouble      dF1, dF2;
  IGRdouble      dDD;

  struct IGRpolyline     LineIn;
  struct GRpost_info     post_info;
  struct GRid            Test;
  struct GRid            mygrid;
  struct VCCL_sectmap   *LocSect;

  extern  NDwait_batch();

SetProc(VCCable_VCCbInsBrk ); Begin

  *msg     = MSFAIL;

#ifdef MY_DEBUG
  printf ("insert break %d %d\n", SecNum, VtxNum);
#endif

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  NumSec  = om$dimension_of (varray = me->Sect);

  if ((SecNum >= NumSec) || (SecNum < 0))       return (OM_E_ABORT);
  if (me->Sect[SecNum].type != VCC_STRING)       return (OM_E_ABORT);

  iMstr  = me->Sect[SecNum].strno;

  action = 0;
  status =
  om$send(msg    = message GRlinear.GRgetpolyline
                              (&retmsg, &md_env->md_env.matrix_type,
                                md_env->md_env.matrix, &action, &LineIn),
    p_chanselect = &AS_to_comp,
    from         = iMstr,
    to           = iMstr);

  /*  legal segment num   */
  if ((VtxNum > (LineIn.num_points -1)) || (VtxNum < 0)) return (OM_E_ABORT);
  if ((VtxNum > (me->Sect[SecNum].iTo - 1))  ||
      (VtxNum < me->Sect[SecNum].iFrom))                 return (OM_E_ABORT);

  action = 1;
 
  dVertex  = _MALLOC (((LineIn.num_points+3) * 3), IGRdouble);

  LineIn.points     = dVertex;
  LineIn.num_points = 0;

  status =
  om$send(msg    = message GRlinear.GRgetpolyline
                              (&retmsg, &md_env->md_env.matrix_type,
                                md_env->md_env.matrix, &action, &LineIn),
    p_chanselect = &AS_to_comp,
    from         = iMstr,
    to           = iMstr);

  dDD = BSdistptpt (&rc, &dVertex[VtxNum*3],  &dVertex[(VtxNum+1)*3]);

  dF1 = BSdistptpt (&rc, &dVertex[VtxNum*3], dCoord);
  dF2 = BSdistptpt (&rc, &dVertex[(VtxNum+1)*3], dCoord);

  dF1 = (dF1 / dDD) - 0.15;
  if (dF1 <= 0.0) dF1 = 0.01;
  dF2 = dF1 + 0.3;
  if (dF2 >= 1.0)
  {
     dF2 = 0.99;
     dF1 = dF2 - 0.3;
  }

#ifdef MY_DEBUG
  printf ("insert factors %f %f\n", dF1, dF2);
#endif


  for (i=0; i<3; i++)
  {

    diff[i] = dVertex[(VtxNum+1)*3+i] - dVertex[VtxNum*3+i];
  }

#ifdef MY_DEBUG
  printf ("DIFF  %f %f %f \n", diff[0],diff[1],diff[2]);
#endif

  for (i=0; i<3; i++)
  {
    dV1[i] = dVertex[VtxNum*3+i] + diff[i] * dF1;
    dV2[i] = dVertex[VtxNum*3+i] + diff[i] * dF2;
  }

#ifdef MY_DEBUG
  printf ("insert vertex1 factors %f %f %f \n", dV1[0],dV1[1],dV1[2]);
  printf ("insert vertex2 factors %f %f %f \n", dV2[0],dV2[1],dV2[2]);
#endif

  for (iVert = LineIn.num_points; iVert > VtxNum; iVert--)
  {
    dVertex[(iVert+2)*3]   = dVertex[iVert*3];
    dVertex[(iVert+2)*3+1] = dVertex[iVert*3+1];
    dVertex[(iVert+2)*3+2] = dVertex[iVert*3+2];
  }

  dVertex[VtxNum*3+3] = dV1[0];
  dVertex[VtxNum*3+4] = dV1[1];
  dVertex[VtxNum*3+5] = dV1[2];
  dVertex[VtxNum*3+6] = dV2[0];
  dVertex[VtxNum*3+7] = dV2[1];
  dVertex[VtxNum*3+8] = dV2[2];

  LineIn.num_points    += 2;
  me->Sect[SecNum].iTo += 2;

  /*    adapt following section records ....  */
#ifdef MY_DEBUG
  printf ("adapt section for vertexinsert \n");
#endif

  for (iSect=SecNum+1; iSect<NumSec; iSect++)
  {
    if (me->Sect[iSect].type != VCC_STRING) continue;
    if (me->Sect[iSect].strno != iMstr)     break;

    me->Sect[iSect].iFrom += 2;
    me->Sect[iSect].iTo   += 2;
  }

  /*    adapt bend override table....  */

  NumBend = om$dimension_of( varray = me->Bend);

  for (iVert=0; iVert<NumBend; iVert++)
  {
    IGRint   iST;

    iST = me->Sect[me->Bend[iVert].secno].strno;

    if ((iST == iMstr) &&
        (me->Bend[iVert].vtxno > VtxNum))
    {
      me->Bend[iVert].vtxno += 2;
    }
  }

  /*    store new string          */

#ifdef MY_DEBUG
  printf ("modified string \n");
#endif

  post_info.construct_flag = FALSE;
  New = NULL_OBJID;

  Test.objid = NULL_OBJID;

  status =
  om$get_objid_at_index( objid = my_id,
                  p_chanselect = &AS_to_comp,
                  index        = iMstr,
                  objidaddr    = &Test.objid,
                  osnumaddr    = &Test.osnum );
  status =
  om$send(msg    = message GRlinear.GRputpolyline
                           (&retmsg, md_env, &post_info, &LineIn, &New),
    p_chanselect = &AS_to_comp,
    from         = iMstr,
    to           = iMstr);

  /* @@@@  TBD  @@@@  see if reconnect is necessary ..................   */
  if ((Test.objid != New) && (New != NULL_OBJID))
    printf (" new objid after change %d\n",New);

  _FREE (dVertex);

  /*    now that two new vertices are inserted we change these
        (VtxNum+1 and VtxNum+2) to breaks...................... */

  /*    (copied from attach conduit......)   */

  /* ----------------------------------------------------------------------*/
  /*C Allocate temp space */

  LocSect = _MALLOC ((NumSec + 3), struct VCCL_sectmap);

  /*C Create gap in section map     */

  for (i=0; i<=SecNum; i++)
    LocSect[i] = me->Sect[i];

  for (i=SecNum; i<NumSec; i++)
    LocSect[i+3] = me->Sect[i];

  LocSect[SecNum].iTo     = VtxNum + 1;
  LocSect[SecNum].numvert = LocSect[SecNum].iTo - LocSect[SecNum].iFrom + 1;

  for (i=0; i<2; i++)
  {
    isec = SecNum + 1 + i;

    /* create break sections  */
 
    LocSect[isec].type    = (i == 0) ? VCC_BREAK_ON : VCC_BREAK_OFF;
    LocSect[isec].numvert =  0;
    LocSect[isec].iFrom   = -1;
    LocSect[isec].iTo     = -1;
    LocSect[isec].strno   = -1;
    LocSect[isec].dY0     =  0;
    LocSect[isec].dZ0     =  0;
    LocSect[isec].dY1     =  0;
    LocSect[isec].dZ1     =  0;
    LocSect[isec].parno   = -1;;
  }

  isec = SecNum + 2;
  LocSect[isec+1].iFrom   = VtxNum + 2;
  LocSect[isec+1].numvert = LocSect[isec+1].iTo - LocSect[isec+1].iFrom + 1;

  NumSec = NumSec + 3;

  status =
  om$vla_set_dimension (varray  = me->Sect,
                         size   = NumSec);

  /*C  refill instance section table   */

  for (i=0; i<NumSec; i++)
    me->Sect[i] = LocSect[i];

   _FREE (LocSect);

  /* ----------------------------------------------------------------------*/
  /* do the wait batch */
  cn_type = ND_COMP;
  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &mygrid,
             l_obj_info = &cn_type,
             nb_obj     = 1);

End;
  return OM_S_SUCCESS;
}

end implementation VCCable;

