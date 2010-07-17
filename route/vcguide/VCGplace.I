
/* $Id: VCGplace.I,v 1.2 2001/02/20 01:10:48 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcguide / VCGplace.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCGplace.I,v $
 *  Revision 1.2  2001/02/20 01:10:48  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/02  21:41:24  pinnacle
# Replaced: vcguide/VCGplace.I for:  by kddinov for route
#
# Revision 1.4  1998/03/14  19:53:26  pinnacle
# Replaced: vcguide/VCGplace.I for:  by kddinov for route
#
# Revision 1.3  1998/02/18  20:04:02  pinnacle
# Replaced: vcguide/VCGplace.I for:  by kddinov for route
#
# Revision 1.2  1997/11/30  16:09:00  pinnacle
# Replaced: vcguide/VCGplace.I for:  by r250_int for route
#
# Revision 1.9  1997/11/14  23:19:30  pinnacle
# Replaced: vcguide/VCGplace.I for:  by onayragu for cabling
#
# Revision 1.8  1997/07/14  22:25:22  pinnacle
# Replaced: vcguide/VCGplace.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/25  20:32:58  pinnacle
# Replaced: vcguide/VCGplace.I for:  by hverstee for cabling
#
# Revision 1.6  1997/03/06  23:08:08  pinnacle
# Replaced: vcguide/VCGplace.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/09  21:57:26  pinnacle
# Replaced: vcguide/VCGplace.I for:  by hverstee for cabling
#
# Revision 1.4  1996/09/26  13:40:08  pinnacle
# Replaced: vcguide/VCGplace.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:07:56  pinnacle
# Replaced: vcguide/VCGplace.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  16:01:50  pinnacle
# Replaced: vcguide/VCGplace.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:41:28  pinnacle
# Created: vcguide/VCGplace.I by hverstee for cabling
#
 *
 * History:
 *  06/10/96  hv      initial
 *  3-98      KDD	VDputAttrDrivenSymb
 *
 *************************************************************************/

class implementation VCGuide;

/*
#define  MY_DEBUG	1
#define vdsDEBUG        1
*/
 
#include "VDScheckdef.h"
#include "ACdb_info.h"

#include "VCMacLib.h"
#include "VCmacros.h"
#include "VCproto.h"
#include "VCTagDef.h"
#include "vrdbgmacros.h"


method NDplace( struct GRas      *asso_lis;
                struct GRmd_env  *md_env;
                       IGRchar   *go_cnst_lis)
{
  IGRlong     retmsg;
  IGRint      status;
  IGRint      stat1;
  IGRint      FeetCount;

  struct GRid        FeetList [2];
  struct ACdb_info   DbInfo;

SetProc(VCGuide_NDplace ); Begin

  if ( asso_lis->as_attr == NULL || md_env == NULL)
  {
    /*| ERROR -> MISSING ATTRIBUTES */
    return OM_E_INVARG;
  }

  /* -------------------------- */
  /* -- INITIALIZE INSTANCE -- */
  /* ------------------------- */
 
  status = om$send( msg      = message VCRoot.VCInitInstance (&retmsg),
                    targetid = my_id) ;


  status =
  om$send( msg = message VCRoot.VCSetInstance
                            (&retmsg, (struct VCGenInfo *) asso_lis->as_attr),
      targetid = my_id);
  as$status();

  /* I cannot be moved to root */
  status =
  om$send( msg = message NDnode.NDchg_state
                       ( ND_DONT_MVRT, ND_DONT_MVRT),
      targetid = my_id);

  /*A attach to the macro definition */
  status =
  om$send(msg = message ACcpx.ACattach ((IGRint *)&retmsg,VC_MACDEF_GUIDE),
     targetid = my_id );
  as$status();
  as$status(action = RET_STATUS);

  /* ------------------------ */
  /* -- INSERT CC IN GRAPH -- */
  /* ------------------------ */

#ifdef MY_DEBUG
  printf (" Guide parents %d\n",asso_lis->num_parents);
#endif

  if (asso_lis->num_parents)
  {
    status =
    om$send( msg = message NDnode.NDconnect (asso_lis->num_parents,
                                   asso_lis->parents, NULL_GRID, ND_NEW),
        targetid = my_id);
    as$status();
    as$status(action = RET_STATUS);
  }

  /* --------------------*/
  /* -- BUILD GRAPHICS --*/
  /* --------------------*/

  status =
  om$send( msg = message ACncpx.ACconstruct_feet
                         (&retmsg, 0, 0, NULL, md_env, &FeetCount, FeetList),
      targetid = my_id );
  as$status();
  as$status ( action = RET_STATUS );

  status =
  om$send( msg = message ACncpx.ACchange_feet(FeetCount, FeetList, md_env ),
      targetid = my_id );
  as$status();
  as$status ( action = RET_STATUS );

  if ( !(me->nVCStat & VC_ERROR) )
  {
    struct GRsymbology        Symb;

    if (go_cnst_lis)
    { /*C Take given symbology */
      Symb.display_attr =  *(((struct GRvg_construct *)go_cnst_lis)->display);
      Symb.level        =   (((struct GRvg_construct *)go_cnst_lis)->level);
    }
    else
    {  /*C Get symbology from parent */
      struct GRid        GoId;

      status =
      om$send (msg = message NDnode.ASreturn_go
                                       (&GoId, NULL, NULL),
          targetid = asso_lis->parents[me->nVCAttr].objid,
          targetos = asso_lis->parents[me->nVCAttr].osnum );
      as$status( action = RET_STATUS );

      status =
      om$send( msg = message GRvg.GRgetsymb (&retmsg,&Symb),
          targetid = GoId.objid,
          targetos = GoId.osnum );
      as$status ( action = RET_STATUS );
    }

    status =
    om$send(msg = message GRvg.GRputsymb(&retmsg,&Symb),
       targetid = my_id);
    as$status();

    /* KDD 2-98 for CR179702225 VCRoot overrides this method */
 
    status = om$send( msg      = message VDSroot.VDputAttrDrivenSymb
                                        ( &retmsg, md_env, "cableattr.symb"),
                      targetid = my_id);
  }

  if (bVC_IS_PID(me->xform_chan))
    DbInfo.quantity = VD_CKIN_CABSCH_GUIDE;
  else
    DbInfo.quantity = VD_CKIN_CABMOD_GUIDE;

  stat1 =
  om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
     targetid = my_id);

End;
  return (status);
}

method NDdelete (struct GRmd_env   *md_env)
{
  IGRint                  status;
  IGRlong                 retmsg;
  IGRshort                nST;
  IGRchar                 szTag[VC_MAX_TAGNO];

SetProc(VCGuide_NDdelete ); Begin

  status =
  om$send (msg = message VCRoot.VCGetTagNo (szTag),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szTag)))
    status = VC_TAGdel (&nST, VCTAG_CAT_GUIDE, szTag);

  status =
  om$send(msg = message VCRoot.VCCmpDel (&retmsg),
     targetid = my_id);

  status =
  om$send(msg = message VCRoot.NDdelete (md_env),
         mode = OM_e_wrt_message,
     targetid = my_id);

End;
  return (status);
}

method GRdelete (IGRlong       *msg;
          struct GRmd_env      *md_env)
{
  IGRint                  status;
  IGRlong                 retmsg;
  IGRshort                nST;
  IGRchar                 szTag[VC_MAX_TAGNO];

SetProc(VCGuide_GRdelete ); Begin

  status =
  om$send (msg = message VCRoot.VCGetTagNo (szTag),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szTag)))
    status = VC_TAGdel (&nST, VCTAG_CAT_GUIDE, szTag);

  status =
  om$send(msg = message VCRoot.VCCmpDel (&retmsg),
     targetid = my_id);

  status =
  om$send(msg = message VCRoot.GRdelete (msg, md_env),
         mode = OM_e_wrt_message,
     targetid = my_id);

End;
  return (status);
}

method VCSetTagNo (IGRchar   *szTagIn)
{
  IGRint                  status;
  IGRlong                 retmsg;
  IGRshort                nST;
  IGRchar                 szTag[VC_MAX_TAGNO];
  struct GRid			MyId;

SetProc(VCGuide_VCSetTagNo ); Begin

  MyId.osnum	= OM_Gw_current_OS;
  MyId.objid	= my_id;

  status =
  om$send (msg = message VCRoot.VCGetTagNo (szTag),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szTag)))
    status = VC_TAGdel (&nST, VCTAG_CAT_GUIDE, szTag);

  if (!(VC_EMPTYSTR(szTagIn)))
    status = VC_TAGadd (&nST, VCTAG_CAT_GUIDE, szTagIn, &MyId);

  status =
  om$send (msg = message VCRoot.VCSetTagNo (szTagIn),
          mode = OM_e_wrt_message,
      targetid = my_id);

  status =
  om$send(msg = message VCRoot.VCCmpSet (&retmsg),
     targetid = my_id);

End;
  return (OM_S_SUCCESS);
}

end implementation VCGuide;

