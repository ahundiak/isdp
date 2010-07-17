
/* $Id: VCBplace.I,v 1.3 2001/02/20 01:10:42 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcguide / VCBplace.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCBplace.I,v $
 *  Revision 1.3  2001/02/20 01:10:42  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/28 15:08:05  louis
 *  corrected punctuation
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/03/14  19:55:48  pinnacle
# Replaced: vcguide/VCBplace.I for:  by kddinov for route
#
# Revision 1.3  1998/02/18  20:03:00  pinnacle
# Replaced: vcguide/VCBplace.I for:  by kddinov for route
#
# Revision 1.2  1997/12/08  09:38:40  pinnacle
# Replaced: vcguide/VCBplace.I for:  by apazhani for route
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/10/24  12:46:58  pinnacle
# Replaced: vcguide/VCBplace.I for:  by apazhani for cabling
#
# Revision 1.1  1997/07/14  22:26:26  pinnacle
# Created: vcguide/VCBplace.I by hverstee for cabling
#
 *
 * History:
 *  06/10/96  hv      initial
 *  10/24/97  Alwin   Modified the NDplace method to specify the DBinfo,
 *                    for the object.
 *  12/08/97  Alwin   Overriden the method NDdelete
 *  01/28/01  law     error in dbg punctuation
 *
 *************************************************************************/

class implementation VCBksh;

#include "ACdb_info.h"
#include "VCMacLib.h"
#include "VDScheckdef.h"
#include "vrdbgmacros.h"

/*
#define  MY_DEBUG
*/

method NDplace( struct GRas      *asso_lis;
                struct GRmd_env  *md_env;
                       IGRchar   *go_cnst_lis)
{
  IGRlong     retmsg;
  IGRint      status;
  IGRint      FeetCount;
  IGRint      TypSav;
  IGRshort    nCP;
  IGRshort    nVal;
  IGRdouble   dMat[16];

  struct GRid FeetList [2];

  SetProc( NDplace ); Begin

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

   /* I cannot be moved to root */

   status =
   om$send( msg = message NDnode.NDchg_state
                        ( ND_DONT_MVRT, ND_DONT_MVRT),
       targetid = my_id);

  /*A attach to the macro definition */
  status =
  om$send(msg = message ACcpx.ACattach ((IGRint *)&retmsg, VC_MACDEF_TERM),
     targetid = my_id );

  /* ------------------------ */
  /* -- INSERT CC IN GRAPH -- */
  /* ------------------------ */

  __DBGpr_int( "No of Parents ", asso_lis->num_parents );

  if (asso_lis->num_parents)
  {
    status =
    om$send( msg = message NDnode.NDconnect (asso_lis->num_parents,
                                   asso_lis->parents, NULL_GRID, ND_NEW),
        targetid = my_id);
  }

  /*A   set local offsets from input   */

  /*   get base matrix (without translation) first   */

  TypSav = me->nVCType;
  nCP    = 0;
  nVal   = om$dimension_of (varray = me->dVCOffVal);

  status =
  om$send (msg = message VCRoot.VCBaseMat (&retmsg, nCP, dMat, md_env),
      targetid = my_id);

  me->nVCType = TypSav;

  /*   and translate to this input matrix   */

  status =
  VC_to_offset (dMat, me->nVCType, nVal, me->dVCOffVal, me->dVCOffVal);

  /* --------------------*/
  /* -- BUILD GRAPHICS --*/
  /* --------------------*/

  status =
  om$send( msg = message ACncpx.ACconstruct_feet
                         (&retmsg, 0, 0, NULL, md_env, &FeetCount, FeetList),
      targetid = my_id );

  status =
  om$send( msg = message ACncpx.ACchange_feet(FeetCount, FeetList, md_env ),
      targetid = my_id );

  /* -------------------*/
  /* -- SET SYMBOLOGY --*/
  /* -------------------*/

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

      status =
      om$send( msg = message GRvg.GRgetsymb (&retmsg,&Symb),
          targetid = GoId.objid,
          targetos = GoId.osnum );
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

  { /* added by alwin for TR179701824 */
    IGRlong stat1;
    struct ACdb_info        DbInfo;

    if (bVC_IS_PID(me->xform_chan))
        DbInfo.quantity = VD_CKIN_CABSCH_EBKSHELL;
    else
        DbInfo.quantity = VD_CKIN_CABMOD_EBKSHELL;

    __DBGpr_int( "DbInfo.quantity ", DbInfo.quantity );
 
    stat1 =
    om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
               targetid = my_id);
  }

  End ;
  return (status);
}

/* This has been done basically to do the cleaning up job like erasing
the display before deleting the BackShell Component. Alwin */
method NDdelete ( struct GRmd_env *md_env )
{
  IGRint         status=OM_S_SUCCESS;
  IGRlong        retmsg;
 
  SetProc( NDdelete of BackShell ); Begin
 
  /* Undisplay the BackShell first and then delete it */
  {
        enum   GRdpmode         Mode;
 
        GRabsg_del_all();
 
        Mode = GRbe;
        status = om$send( msg = message GRgraphics.GRdisplay( &retmsg,
                                        &md_env->md_env.matrix_type,
                                         md_env->md_env.matrix,
                                        &Mode, &md_env->md_id ),
              targetid = my_id );
        as$status();
  }
 
  status =
  om$send (msg = message VCRoot.NDdelete (md_env),
          mode = OM_e_wrt_message,
      targetid = my_id);
 
  End
  return (status);
}

end implementation VCBksh;

