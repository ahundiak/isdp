
/* $Id: VCECmisc.I,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCECmisc.I
 *
 * Description:
 *   This file contains miscellaneous methods for an electrical cable
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCECmisc.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:07:26  pinnacle
# Replaced: vccable/VCECmisc.I for:  by r250_int for route
#
# Revision 1.6  1997/11/14  23:18:20  pinnacle
# Replaced: vccable/VCECmisc.I for:  by onayragu for cabling
#
# Revision 1.5  1997/07/14  22:33:14  pinnacle
# Replaced: vccable/VCECmisc.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/06  22:52:54  pinnacle
# Replaced: vccable/VCECmisc.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:05:18  pinnacle
# Replaced: vccable/VCECmisc.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:58:36  pinnacle
# Replaced: vccable/VCECmisc.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:50:44  pinnacle
# Created: vccable/VCECmisc.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCElCable;

#include "VCmacros.h"
#include "VCproto.h"
#include "VCdbaccess.h"
#include "VCTagDef.h"

method VCGetModel ( IGRlong    *msg;
             struct GRid       *ModelId)
{

  IGRint      status;
  IGRlong     retmsg;
  IGRchar     szCode[VC_MAX_CCODE];

  *msg = MSSUCC;

  ModelId->objid = NULL_OBJID;

  status =
  om$send (msg = message VCRoot.VCGetCode (szCode),
      targetid = my_id);

  vc$elcab_old (code = szCode, GRid = ModelId);

  return ( OM_S_SUCCESS );
}/* end VCGetModel */

method VCGetProduct (IGRint   *Prodno;
                     IGRchar  *ProdNam)
{
   if (Prodno) *Prodno = VC_PROD_ELEC;

   if (ProdNam) strcpy (ProdNam, "EL");

   return (OM_S_SUCCESS);
}

method NDdelete (struct GRmd_env   *md_env)
{
  IGRint                  status;
  IGRlong                 retmsg;
  IGRshort                nST;
  IGRchar                 szTag[VC_MAX_TAGNO];

  status =
  om$send (msg = message VCRoot.VCGetTagNo (szTag),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szTag)))
    status = VC_TAGdel (&nST, VCTAG_CAT_ELCABLE, szTag);

  status =
  om$send(msg = message VCRoot.VCCmpDel (&retmsg),
     targetid = my_id);

  status =
  om$send(msg = message VCCable.NDdelete (md_env),
         mode = OM_e_wrt_message,
     targetid = my_id);

  return (status);
}

method GRdelete (IGRlong    *msg;
          struct GRmd_env   *md_env)
{
  IGRint                  status;
  IGRlong                 retmsg;
  IGRshort                nST;
  IGRchar                 szTag[VC_MAX_TAGNO];

  status =
  om$send (msg = message VCRoot.VCGetTagNo (szTag),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szTag)))
    status = VC_TAGdel (&nST, VCTAG_CAT_ELCABLE, szTag);

  status =
  om$send(msg = message VCRoot.VCCmpDel (&retmsg),
     targetid = my_id);

  status =
  om$send(msg = message VCCable.GRdelete (msg, md_env),
         mode = OM_e_wrt_message,
     targetid = my_id);

  return (status);
}


method VCSetTagNo (IGRchar   *szTagIn)
{
  IGRint                  status;
  IGRlong                 retmsg;
  IGRshort                nST;
  IGRchar                 szTag[VC_MAX_TAGNO];
  struct GRid			MyId;

  MyId.osnum	= OM_Gw_current_OS;
  MyId.objid	= my_id;

  status =
  om$send (msg = message VCRoot.VCGetTagNo (szTag),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szTag)))
    status = VC_TAGdel (&nST, VCTAG_CAT_ELCABLE, szTag);

  if (!(VC_EMPTYSTR(szTagIn)))
    status = VC_TAGadd (&nST, VCTAG_CAT_ELCABLE, szTagIn, &MyId);

  status =
  om$send (msg = message VCRoot.VCSetTagNo (szTagIn),
          mode = OM_e_wrt_message,
      targetid = my_id);

  status =
  om$send(msg = message VCRoot.VCCmpSet (&retmsg),
     targetid = my_id);

  return (OM_S_SUCCESS);
}

method  VCCmpDef  (IGRlong    *msg;
                   CHARPTR    *pCHR)
{
  *msg = MSSUCC;

  pCHR[0] = VC_DIR_TAG;
  pCHR[1] = VC_DIR_ELEC;
  pCHR[2] = VC_DIR_CAB;

  return (OM_S_SUCCESS);
}

end implementation VCElCable;

