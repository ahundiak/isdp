
/* $Id: VCTcompart.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTcompart.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTcompart.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1996/10/16  22:22:08  pinnacle
# Replaced: vcterm/VCTcompart.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/16  20:44:16  pinnacle
# Replaced: vcterm/VCTcompart.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/16  20:40:46  pinnacle
# Created: vcterm/VCTcompart.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class implementation VCTerm;

#include "VDmem.h"

/*
#define MY_DEBUG
*/


method VCGetCompart (IGRlong    *msg;
                     IGRshort   *nNum;
              struct GRid       *Compart;
              struct GRmd_env   *md_env)
{
  IGRint     status;
  IGRint     nLoc;
  IGRchar    CompName[90];

  struct GRid      meself;
  struct GRid      GR;
  struct GRid     *LocGR;

  extern IGRint  SMIsInCompt();

  *msg   = MSSUCC;
  *nNum  = 0;
  LocGR  = NULL;

  meself.objid = my_id;
  meself.osnum = OM_Gw_current_OS;

  GR.objid = NULL_OBJID;

  status =
  SMIsInCompt (&meself, md_env, 1, 1, &GR, CompName, &nLoc, &LocGR);

  if ((nLoc > 0) && (GR.objid != NULL_OBJID))
  {
    *nNum++;
    if (Compart)
       *Compart = GR;
  }

  _FREE (LocGR);

  return ( status );
}

end implementation VCTerm;

