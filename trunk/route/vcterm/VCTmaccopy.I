
/* $Id: VCTmaccopy.I,v 1.2 2001/02/20 01:11:38 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTmaccopy.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTmaccopy.I,v $
 *      Revision 1.2  2001/02/20 01:11:38  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/02/18  20:08:56  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by kddinov for route
#
# Revision 1.2  1997/11/30  16:09:38  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by r250_int for route
#
# Revision 1.8  1997/11/09  06:37:28  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by apazhani for cabling
#
# Revision 1.7  1997/11/09  06:31:04  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by apazhani for cabling
#
# Revision 1.6  1997/07/14  22:09:22  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/22  15:24:00  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/19  13:51:34  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by hverstee for cabling
#
# Revision 1.3  1997/05/02  20:29:44  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by hverstee for cabling
#
# Revision 1.2  1997/04/29  13:10:26  pinnacle
# Replaced: vcterm/VCTmaccopy.I for:  by hverstee for cabling
#
# Revision 1.1  1997/04/28  22:03:14  pinnacle
# Created: vcterm/VCTmaccopy.I by hverstee for cabling
#
 *
 * History:
 *        MM/DD/YY        AUTHOR        DESCRIPTION
 *        11/09/97        Alwin         Modified the Method NDcopy, to check
 *                                      a particular condition. for TR179701970
 *
 *************************************************************************/

class implementation VCTerm;

#include "OMmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "maidmx.h"
#include "parametric.h"
#include "vrdbgmacros.h"

/*
#define MY_DEBUG
*/

extern GRclassid    OPP_VCEmbed_class_id;

from   VCEmbed     import   VCETSetIns;
from   VCEmbed     import   VCETSetMat;

/*****************************************************************************/

method NDcopy (IGRlong       *msg;
               IGRint         cp_type;
        struct GRmd_env      *fr_env;
        struct GRmd_env      *to_env;
        struct GRid          *newobjid)

{
  IGRint          status;
  IGRlong         retmsg;

  SetProc( NDcopy.VCTmaccopy ); Begin
 
  __DBGpr_int( " NDcopy Type ", cp_type );
  __DBGpr_int( " nVCType ", me->nVCType );

#ifdef MY_DEBUG
  printf ("NDcopy cptype = %d\n",cp_type);
#endif

  if ( cp_type == ND_TO_MACRO ) 
/*      (!(me->nVCType & VC_GEN_BITERM)))
  commented this particular condition as this always prevents control to enter
  inside this loop, as a result VCEmbed object is not getting constructed
  properly. added by alwin for TR179701970 */
  {
    IGRdouble               dMat[16];
    IGRshort                nCP;
    struct VCET_ins         Ins;
    struct GRsymbology      symb;

    *msg = MSFAIL;

    /*| Copy to macro definition */

    /* -- construct VCEmbed -- */
    newobjid->objid = NULL_OBJID;
    newobjid->osnum = to_env->md_id.osnum;

    status = om$construct(  classid = OPP_VCEmbed_class_id,
                            p_objid = &newobjid->objid,
                            osnum   = newobjid->osnum );
    as$status( action = RET_STATUS );

    __DBGpr_int( " NDcopy to macro Id,objid ", newobjid->objid );
    __DBGpr_int( " NDcopy to macro Id,osnum ", newobjid->osnum );

#ifdef MY_DEBUG
  printf ("NDcopy to macro, create %d\n",newobjid->objid);
#endif

    /* -- Set symbology -- */

    status =
    om$send (msg = message GRvg.GRgetsymb (msg,&symb),
        targetid = my_id );

    status =
    om$send (msg = message GRvg.GRputsymb (msg,&symb),
            mode = OM_e_wrt_message,
        targetid = newobjid->objid,
        targetos = newobjid->osnum );

    /* -- Set instance -- */

    nCP = 0;

    Ins.Type  = VC_GEN_TERM | VC_GEN_OWNED | VC_TOFF_C_FULL;

    Ins.Statx = VC_STATUS_INIT;

    status =
    om$send (msg = message VCRoot.VCGetProduct (&Ins.Product, NULL),
        targetid = my_id );
    __DBGpr_int( " Ins.Product ", Ins.Product );

    status =
    om$send (msg = message VCRoot.VCGetCode (Ins.szCode),
        targetid = my_id );
    __DBGpr_str( " Comp Code ", Ins.szCode );

    status =
    om$send (msg = message VCRoot.VCGetTagNo (Ins.szTag),
        targetid = my_id );
    __DBGpr_str( " Tag Number ", Ins.szTag );

    status =
    om$send (msg = message VCRoot.VCTransMat (&retmsg, nCP, dMat, fr_env),
        targetid = my_id );

    status = om$send( msg      = message VCRoot.VCInitInstance (&retmsg),
                      targetid = newobjid->objid,
                      targetos = newobjid->osnum );

    status =
    om$send (msg = message VCEmbed.VCETSetIns (&retmsg, &Ins),
        targetid = newobjid->objid,
        targetos = newobjid->osnum );

    status =
    om$send (msg = message VCEmbed.VCETSetMat (&retmsg, dMat),
        targetid = newobjid->objid,
        targetos = newobjid->osnum );

  }/* end copy to macro definition */
  else
  {
    /*   for copy to macro template adapt upscan again    */

    if( to_env->md_id.osnum != fr_env->md_id.osnum )
    {
      IGRboolean     bEmbed;

      bEmbed = TRUE;

      __DBGpr_com( " Calling the Md VCMac.VCMchgup " );
      status =
      om$send (msg = message VCMac.VCMchgup
                             (&retmsg, bEmbed, NULL, NULL, NULL),
          targetid = my_id );
    }

        /*| Generic copy */

    __DBGpr_com( " Calling the Md VCRoot.NDcopy " );
    status =
    om$send (msg = message VCRoot.NDcopy
                        (msg,cp_type,fr_env,to_env,newobjid),
            mode = OM_e_wrt_message,
        targetid = my_id );

    __DBGpr_int( " NDcopy to macro Id,objid ", newobjid->objid );
    __DBGpr_int( " NDcopy to macro Id,osnum ", newobjid->osnum );

    status =
    om$send (msg = message VCRoot.VCSetStatus (VC_CLONE, VC_CLONE),
        targetid = newobjid->objid,
        targetos = newobjid->osnum );

    /*  change back upscan    */

    if( to_env->md_id.osnum != fr_env->md_id.osnum )
    {
      status =
      om$send (msg = message VCMac.VCMchgdn (&retmsg, NULL, NULL),
          targetid = my_id );

      status =
      om$send (msg = message VCRoot.VCSetType (VC_GEN_OWNED, VC_GEN_OWNED),
          targetid = newobjid->objid,
          targetos = newobjid->osnum );

    }

  }/* end generic copy */

#ifdef MY_DEBUG
  printf ("NDcopy end, newobject = %d, old = %d\n",newobjid->objid, my_id);
#endif

  End
  return ( status);
}/* end NDcopy */

end implementation VCTerm;

