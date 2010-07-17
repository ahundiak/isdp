
/* $Id: VCFTmisc.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm / VCFTmisc.I
 *
 * Description:
 *   This file contains miscellaneous methods for a fiberoptic term
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCFTmisc.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:09:46  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by r250_int for route
#
# Revision 1.8  1997/11/26  18:58:42  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by apazhani for cabling
#
# Revision 1.7  1997/11/14  23:20:40  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by onayragu for cabling
#
# Revision 1.6  1997/07/14  22:07:40  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by hverstee for cabling
#
# Revision 1.5  1997/04/28  22:05:20  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/12  16:38:40  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:01:36  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:54:08  pinnacle
# Replaced: vcterm/VCFTmisc.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:25:58  pinnacle
# Created: vcterm/VCFTmisc.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *        11/26/97        Alwin      Implemented the NDmove_to_root
 *
 *************************************************************************/

class implementation VCFoTerm;

#include "VDScheckdef.h"
#include "ACdb_info.h"

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

  vc$foterm_old (code = szCode, GRid = ModelId);

  return ( OM_S_SUCCESS );
}/* end VCGetModel */

method VCGetProduct (IGRint   *Prodno;
                     IGRchar  *ProdNam)
{
   if (Prodno) *Prodno = VC_PROD_FO;

   if (ProdNam) strcpy (ProdNam, "Fo");

   return (OM_S_SUCCESS);
}

method NDplace( struct GRas      *asso_lis;
                struct GRmd_env  *md_env;
                       IGRchar   *go_cnst_lis)
{
  IGRint                  status;
  IGRint                  stat1;
  IGRlong                 retmsg;

  struct ACdb_info        DbInfo;

  status =
  om$send(msg = message VCTerm.NDplace (asso_lis, md_env, go_cnst_lis),
         mode = OM_e_wrt_message,
     targetid = my_id);

  if (bVC_IS_PID(me->xform_chan))
    DbInfo.quantity = VD_CKIN_CABSCH_FOTERM;
  else
    DbInfo.quantity = VD_CKIN_CABMOD_FOTERM;

  stat1 =
  om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
     targetid = my_id);

  return (status);
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
    status = VC_TAGdel (&nST, VCTAG_CAT_FOTERM, szTag);

  status =
  om$send(msg = message VCRoot.VCCmpDel (&retmsg),
     targetid = my_id);

  status =
  om$send(msg = message VCTerm.NDdelete (md_env),
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
    status = VC_TAGdel (&nST, VCTAG_CAT_FOTERM, szTag);

  status =
  om$send(msg = message VCRoot.VCCmpDel (&retmsg),
     targetid = my_id);

  status =
  om$send(msg = message VCTerm.GRdelete (msg, md_env),
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

  if (me->nVCType & VC_GEN_VIRTUAL)
  { /* embedded terminals do not play tag    */
    status =
    om$send (msg = message VCRoot.VCSetTagNo (szTagIn),
            mode = OM_e_wrt_message,
        targetid = my_id);
  }
  else
  {
    status =
    om$send (msg = message VCRoot.VCGetTagNo (szTag),
        targetid = my_id);

    if (!(VC_EMPTYSTR(szTag)))
      status = VC_TAGdel (&nST, VCTAG_CAT_FOTERM, szTag);

    if (!(VC_EMPTYSTR(szTagIn)))
      status = VC_TAGadd (&nST, VCTAG_CAT_FOTERM, szTagIn, &MyId);

    status =
    om$send (msg = message VCRoot.VCSetTagNo (szTagIn),
            mode = OM_e_wrt_message,
        targetid = my_id);

    status =
    om$send(msg = message VCRoot.VCCmpSet (&retmsg),
       targetid = my_id);
  }

  return (OM_S_SUCCESS);
}

method  VCCmpDef  (IGRlong    *msg;
                   CHARPTR    *pCHR)
{
  *msg = MSSUCC;

  pCHR[0] = VC_DIR_TAG;
  pCHR[1] = VC_DIR_FO;
  pCHR[2] = VC_DIR_TERM;

  return (OM_S_SUCCESS);
}

/* Just call the Superclass implementation. Alwin */
method NDmove_to_root(IGRlong     *msg;
                struct GRid        *src_grid;
                struct GRmd_env    *md_env )
{
  return
  ( om$send ( msg = message VCTerm.NDmove_to_root( msg, src_grid, md_env ),
              mode = OM_e_wrt_message,
              targetid = my_id ) );
}

end implementation VCFoTerm;

