
/* $Id: VCTsignal.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm / VCTsignal.I
 *
 * Description:
 *   This file contains the signal name methods for terminals
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTsignal.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.7  1997/08/11  21:33:28  pinnacle
# Replaced: vcterm/VCTsignal.I for:  by hverstee for cabling
#
# Revision 1.6  1997/07/22  14:49:04  pinnacle
# Replaced: vcterm/VCTsignal.I for:  by hverstee for cabling
#
# Revision 1.5  1997/07/14  22:10:22  pinnacle
# Replaced: vcterm/VCTsignal.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/19  16:07:50  pinnacle
# Replaced: vcterm/VCTsignal.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  16:34:40  pinnacle
# Replaced: vcterm/VCTsignal.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:38:40  pinnacle
# Replaced: vcterm/VCTsignal.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:32:36  pinnacle
# Created: vcterm/VCTsignal.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCTerm;

/*
#define MY_DEBUG
*/

method  VCPutSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid)
{
  IGRint         status;
  IGRshort       nSig;
  IGRshort       nIndex;
  IGRshort       nMAP;
  IGRshort       iNo;
  IGRshort       i, j;

  status =
  om$send (msg = message VCDB.VCGetPos (msg, ConId, &nIndex, &nMAP, &nSig),
      targetid = my_id);

  if (nSig >= 0)
  {
    iNo = om$dimension_of (varray = me->VCT_sig);

    for (i=0; i<iNo;i++)
    {
      if (nSig == me->VCT_sig[i].nPkey)
      {  /*   found, replace   */
        if (!(VC_EMPTYSTR(sigid)))
        {
          strcpy (me->VCT_sig[i].SigNam, sigid);
        }
        else
        {  /*  or remove */
          for (j=i; j< (iNo-1); j++)
          {
            me->VCT_sig[j].nPkey = me->VCT_sig[j+1].nPkey;
            strcpy (me->VCT_sig[j].SigNam, me->VCT_sig[j+1].SigNam);
          }

          status =
          om$vla_set_dimension (varray = me->VCT_sig,
                                size   = (iNo-1));
        }

        return (OM_S_SUCCESS);
      }
    }

    if (!(VC_EMPTYSTR(sigid)))
    {
      status =
      om$vla_set_dimension (varray = me->VCT_sig,
                            size   = (iNo+1));

      me->VCT_sig[iNo].nPkey = nSig;
      strcpy (me->VCT_sig[iNo].SigNam, sigid);
    }
  }

  return (OM_S_SUCCESS);
}

method  VCGetSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid)
{
  IGRint         status;
  IGRshort       nSig;
  IGRshort       nIndex;
  IGRshort       nMAP;
  IGRshort       iNo;
  IGRshort       i;

  status =
  om$send (msg = message VCDB.VCGetPos (msg, ConId, &nIndex, &nMAP, &nSig),
      targetid = my_id);

  VC_INITSTR (sigid);

  if (nSig >= 0)
  {
    iNo = om$dimension_of (varray = me->VCT_sig);

    for (i=0; i<iNo;i++)
    {
      if (nSig == me->VCT_sig[i].nPkey)
      {  /*   found, return   */
        strcpy (sigid, me->VCT_sig[i].SigNam);
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}

end implementation VCTerm;

