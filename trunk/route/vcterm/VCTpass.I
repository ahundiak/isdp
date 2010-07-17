
/* $Id: VCTpass.I,v 1.1.1.1 2001/01/04 21:12:39 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTpass.I
 *
 * Description:
 *
 *      methods for terminal cable passthru control
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTpass.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/03/12  16:35:28  pinnacle
# Replaced: vcterm/VCTpass.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:22:04  pinnacle
# Replaced: vcterm/VCTpass.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:29:34  pinnacle
# Created: vcterm/VCTpass.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      06/26/96    hv          Initial
 *
 *************************************************************************/

class implementation VCTerm;

/*
#define MY_DEBUG
*/


from   VCCable  import  VCCbPass;
from   VCCable  import  VCCbCut;

method  VCTpass   (IGRlong    *msg;
            struct GRid       *CB1;
            struct VCpos      *Cutpos1;
            struct GRid       *CB2;
            struct VCpos      *Cutpos2)

{
  IGRint     status;
  IGRshort   nCurr;

  status = 
  om$send (msg = message VCCable.VCCbPass (msg, &nCurr, Cutpos1),
      targetid = CB1->objid,
      targetos = CB1->osnum);

  status = 
  om$send (msg = message VCCable.VCCbPass (msg, &nCurr, Cutpos2),
      targetid = CB2->objid,
      targetos = CB2->osnum);

  /*  add/update VCX reference   */

  return (OM_S_SUCCESS);
}

method  VCTcut    (IGRlong    *msg;
            struct GRid       *CB1;
            struct VCpos      *Cutpos1;
            struct GRid       *CB2;
            struct VCpos      *Cutpos2)

{
  IGRint     status;
  IGRshort   nCurr;

  status =
  om$send (msg = message VCCable.VCCbCut (msg, &nCurr, Cutpos1),
      targetid = CB1->objid,
      targetos = CB1->osnum);

  status =
  om$send (msg = message VCCable.VCCbCut (msg, &nCurr, Cutpos2),
      targetid = CB2->objid,
      targetos = CB2->osnum);

  if (nCurr == 0)
  {  /*  remove VCX reference   */

  }

  return (OM_S_SUCCESS);
}

method  VCTpWhich (IGRlong    *msg;
            struct GRid       *CB1;
            struct GRid       *CB2;
                   IGRshort   *nCP)
{
  /*  find CB2 that is connected to CB1   */

  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

end implementation VCTerm;

