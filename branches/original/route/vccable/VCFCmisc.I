
/* $Id: VCFCmisc.I,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCFCmisc.I
 *
 * Description:
 *   This file contains miscellaneous methods for a fiberoptic cable
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCFCmisc.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:07:30  pinnacle
# Replaced: vccable/VCFCmisc.I for:  by r250_int for route
#
# Revision 1.7  1997/11/14  23:18:54  pinnacle
# Replaced: vccable/VCFCmisc.I for:  by onayragu for cabling
#
# Revision 1.6  1997/07/14  22:33:34  pinnacle
# Replaced: vccable/VCFCmisc.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/19  16:17:28  pinnacle
# Replaced: vccable/VCFCmisc.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/06  22:53:12  pinnacle
# Replaced: vccable/VCFCmisc.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:05:32  pinnacle
# Replaced: vccable/VCFCmisc.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:58:56  pinnacle
# Replaced: vccable/VCFCmisc.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:51:48  pinnacle
# Created: vccable/VCFCmisc.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCFoCable;

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

  vc$focab_old (code = szCode, GRid = ModelId);

  return ( OM_S_SUCCESS );
}/* end VCGetModel */

method VCGetProduct (IGRint   *Prodno;
                     IGRchar  *ProdNam)
{
   if (Prodno) *Prodno = VC_PROD_FO;

   if (ProdNam) strcpy (ProdNam, "Fo");

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
    status = VC_TAGdel (&nST, VCTAG_CAT_FOCABLE, szTag);

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
    status = VC_TAGdel (&nST, VCTAG_CAT_FOCABLE, szTag);

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
    status = VC_TAGdel (&nST, VCTAG_CAT_FOCABLE, szTag);

  if (!(VC_EMPTYSTR(szTagIn)))
    status = VC_TAGadd (&nST, VCTAG_CAT_FOCABLE, szTagIn, &MyId);

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
  pCHR[1] = VC_DIR_FO;
  pCHR[2] = VC_DIR_CAB;

  return (OM_S_SUCCESS);
}

end implementation VCFoCable;

