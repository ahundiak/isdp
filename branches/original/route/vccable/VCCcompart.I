
/* $Id: VCCcompart.I,v 1.2 2001/02/20 01:08:41 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCCcompart.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCcompart.I,v $
 *        Revision 1.2  2001/02/20 01:08:41  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  20:32:14  pinnacle
# Replaced: vccable/VCCcompart.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1996/10/16  21:32:28  pinnacle
# Replaced: vccable/VCCcompart.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/16  20:47:14  pinnacle
# Created: vccable/VCCcompart.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define MY_DEBUG	1
#define vdsDEBUG        1
*/

#include "vrdbgmacros.h"



method VCGetCompart (IGRlong    *msg;
                     IGRshort   *nNum;
              struct GRid       *Compart;
              struct GRmd_env   *md_env)
{
  IGRint     status;
  IGRlong    retmsg;
  IGRshort   iend, n;

  struct GRid      TR;
  struct GRid      CC;

SetProc(VCCable_VCGetCompart ); Begin

  *msg   = MSSUCC;
  *nNum  = 0;

  for (iend=0; iend<2; iend++)
  {
    TR.objid = NULL_OBJID;

    status =
    om$send( msg = message VCCable.VCCbTerm (&retmsg, iend, &TR),
        targetid = my_id);

    if (TR.objid != NULL_OBJID)
    {
      n = 0;
      CC.objid = NULL_OBJID;

      status =
      om$send( msg = message VCRoot.VCGetCompart (&retmsg, &n, &CC, md_env),
          targetid = TR.objid,
          targetos = TR.osnum);

      if (n > 0)
      {
        if (Compart)
          Compart[*nNum] = CC;
        (*nNum)++;
      }
    }
  }

End;
  return ( OM_S_SUCCESS );
}

end implementation VCCable;

