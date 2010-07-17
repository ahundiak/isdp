
/* $Id: VCECplace.I,v 1.5 2002/05/29 20:25:43 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCECplace.I
 *
 * Description:
 *   This file contains placement method for an electrical cable
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCECplace.I,v $
 *        Revision 1.5  2002/05/29 20:25:43  anand
 *        Third set of bug fixes for the split cable functionality.
 *        Merge does not corrupt the model. The marker information is
 *        now propagated to newly sketched cables/sub-cables. Changed
 *        interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *        Revision 1.4  2002/05/24 21:41:49  anand
 *        Second set of bug fixes for the cable lead enhancement.
 *        Fixes errors in model arising out of merge-cable workflows.
 *        Ensure placeholders are created for markers for DB driven
 *        cables. Major shuffling of code in Sketch cable state table.
 *
 *        Revision 1.3  2002/05/17 19:23:35  anand
 *        Misc. bug fixes. Covers change rejects CR 5846 and 6040.
 *        Ensures that new sub-cables carry over signals of parent
 *        cables.
 *
 *        Revision 1.2  2002/05/08 15:48:23  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/07/22  15:01:48  pinnacle
# Replaced: vccable/VCECplace.I for:  by hverstee for cabling
#
# Revision 1.3  1997/04/28  22:16:36  pinnacle
# Replaced: vccable/VCECplace.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/06  22:51:58  pinnacle
# Replaced: vccable/VCECplace.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:50:58  pinnacle
# Created: vccable/VCECplace.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCElCable;

#include "VDScheckdef.h"
#include "ACdb_info.h"

#include "VDmem.h"

/*
#define MY_DEBUG      1
*/




method NDplace( struct GRas        *asso_lis;
                struct GRmd_env    *md_env;
                       IGRchar     *go_cnst_lis)
{
  IGRlong     retmsg;
  IGRint      status;

  struct ACdb_info   DbInfo;

  status =
  om$send (msg = message VCCable.NDplace (asso_lis, md_env, go_cnst_lis),
      targetid = my_id,
          mode = OM_e_wrt_message);
  as$status();

  if (status & OM_S_SUCCESS)
  {
    if (bVC_IS_PID(me->xform_chan))
      DbInfo.quantity = VD_CKIN_CABSCH_ELCAB;
    else
      DbInfo.quantity = VD_CKIN_CABMOD_ELCAB;

    status=
    om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
       targetid = my_id);
  }

  return (status);
} /* end of NDplace */


method  VCCbInitCon (IGRlong       *msg;
                     IGRboolean     bDisc)
{
  IGRlong     retmsg;
  IGRint      status;
  IGRint      i;
  IGRint      NumFib;
  IGRshort    nEnt;
  IGRshort    nTab;
  IGRshort    nOld;

  struct VClayout   *Layout;
  struct GRid        ModelId, MyId;

  NumFib        = 1;
  ModelId.objid = NULL_OBJID;
  ModelId.osnum = OM_Gw_current_OS;
  Layout        = NULL;

  nOld = om$dimension_of (varray  = me->Connect_Data);

  status =
  om$send( msg  = message VCRoot.VCGetModel( &retmsg, &ModelId),
       targetid = my_id);
  as$status();

  /* ------------------------------- */
  /*A Initialize connectivity table  */
  /* ------------------------------- */

  if (ModelId.objid != NULL_OBJID)
  {

    status =
    om$send ( msg = message VCDB.VCGetLayout
                     (&retmsg, NULL, &nEnt, &nTab , NULL),
         targetid = ModelId.objid,
         targetos = ModelId.osnum);

    if (nEnt <= 0)
      printf (" Cannot find number of conductors, setting to 1");
    else
      NumFib = nEnt;
  }

    /*A    Initialize the connections table     */

  Layout = _MALLOC (NumFib, struct  VClayout);

#ifdef MY_DEBUG
  printf (" Initialize table....%d fibers\n",NumFib);
#endif

  status =
  om$vla_set_dimension (varray  = me->Connect_Data,
                        size    = NumFib);
  as$status(action = RET_STATUS );

  status =
  om$send ( msg = message VCDB.VCGetLayout
                     (&retmsg, NULL, &nEnt, &nTab , Layout),
       targetid = ModelId.objid,
       targetos = ModelId.osnum);

  for (i=0; i< NumFib; i++)
  {
    if (i>nOld || bDisc)
    {
      VC_INITSTR (me->Connect_Data[i].FibEnds[0].szModId);
      VC_INITSTR (me->Connect_Data[i].FibEnds[0].szPosId);
      VC_INITSTR (me->Connect_Data[i].FibEnds[1].szModId);
      VC_INITSTR (me->Connect_Data[i].FibEnds[1].szPosId);
      VC_INITSTR (me->Connect_Data[i].SigNam);

      me->Connect_Data[i].nEndStat[0] = VC_CBE_OPEN;
      me->Connect_Data[i].nEndStat[1] = VC_CBE_OPEN;
      me->Connect_Data[i].nFibStat    = VC_CAB_REGULAR;
    }

    if (nEnt > 0)
    {
      strcpy (me->Connect_Data[i].LeadNam, Layout[i].pDef.Conn.Cable.szLeadId);
      strcpy (me->Connect_Data[i].SigNam, Layout[i].szDefSig);
    }
    else
    {
      strcpy (me->Connect_Data[i].LeadNam, "DEF");
      VC_INITSTR (me->Connect_Data[i].SigNam);
    }

#ifdef MY_DEBUG
    printf (" Conductors init  %d %s\n", i, me->Connect_Data[i].LeadNam);
#endif
  }

  _FREE (Layout);

  /* Create place holders for the marker attribute. Note: This may be called
   * only after the vla size for me->Connect_Data has been set. */
  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;
  VCsyncLdAttrInfo( &MyId );

  return (status);
}

method VCCSetCon_Data( IGRlong  *msg;
                       IGRint   NbLeads;
                       struct VCcab_connect *Connect_Data;
                       IGRchar  (*LdNames)[VC_MAX_LEAD_ID] )
{
    IGRint status;

    status = om$send( msg = message VCCable.VCCSetCon_Data( msg,
                                                            NbLeads,
                                                            Connect_Data,
                                                            LdNames ),
                      targetid = my_id,
                      mode = OM_e_wrt_message );

    return status;
}

end implementation VCElCable;

