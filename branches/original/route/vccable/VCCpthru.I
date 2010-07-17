
/* $Id: VCCpthru.I,v 1.2 2001/02/20 01:09:08 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCCpthru.I
 *
 * Description:
 *   This file contains the passthrough methods for cables
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCpthru.I,v $
 *        Revision 1.2  2001/02/20 01:09:08  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  20:34:54  pinnacle
# Replaced: vccable/VCCpthru.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/03/19  16:17:04  pinnacle
# Replaced: vccable/VCCpthru.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/06  22:55:32  pinnacle
# Replaced: vccable/VCCpthru.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:49:30  pinnacle
# Created: vccable/VCCpthru.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
*/
 
#include "vrdbgmacros.h"

method  VCCbPass (IGRlong       *msg;
                  IGRshort      *nCurr;
           struct VCpos         *Cutpos)
{
  IGRshort        j;
  IGRshort        iNo;
  IGRshort        nCP;

SetProc(VCCable_VCCbPass ); Begin

  *msg   = MSSUCC;
  *nCurr = 0;
  nCP    = Cutpos->Conn.Cable.nCpt;

  iNo = om$dimension_of (varray = me->Connect_Data);

  for (j=0; j<iNo; j++)
  {
    if (Cutpos->Conn.Cable.szLeadId[0] == '\0')
      me->Connect_Data[j].nEndStat[nCP] &= VC_CBE_PASSTHRU;
    else
    if (strcmp (Cutpos->Conn.Cable.szLeadId, 
                me->Connect_Data[j].LeadNam) == 0)
      me->Connect_Data[j].nEndStat[nCP] &= VC_CBE_PASSTHRU;

    if (me->Connect_Data[j].nEndStat[nCP] & VC_CBE_PASSTHRU) (*nCurr)++;
  }

End;
  return (OM_S_SUCCESS);
}

method  VCCbCut  (IGRlong       *msg;
                  IGRshort      *nCurr;
           struct VCpos         *Cutpos)
{
  IGRshort        j;
  IGRshort        iNo;
  IGRshort        nCP;

SetProc(VCCable_VCCbCut ); Begin

  *msg   = MSSUCC;
  *nCurr = 0;
  nCP    = Cutpos->Conn.Cable.nCpt;

  iNo = om$dimension_of (varray = me->Connect_Data);

  for (j=0; j<iNo; j++)
  {
    if (Cutpos->Conn.Cable.szLeadId[0] == '\0')
      me->Connect_Data[j].nEndStat[nCP] = VC_CBE_OPEN;
    else
    if (strcmp (Cutpos->Conn.Cable.szLeadId, 
                me->Connect_Data[j].LeadNam) == 0)
      me->Connect_Data[j].nEndStat[nCP] = VC_CBE_OPEN;

    if (me->Connect_Data[j].nEndStat[nCP] & VC_CBE_PASSTHRU) (*nCurr)++;
  }

End;
  return (OM_S_SUCCESS);
}

end implementation VCCable;

