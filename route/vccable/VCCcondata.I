
/* $Id: VCCcondata.I,v 1.2 2001/02/20 01:08:43 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCcondata.I
 *
 * Description:
 *
 *      Methods to return connectivity for cables
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCcondata.I,v $
 *      Revision 1.2  2001/02/20 01:08:43  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  20:35:36  pinnacle
# Replaced: vccable/VCCcondata.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/03/06  22:53:46  pinnacle
# Replaced: vccable/VCCcondata.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/25  14:03:58  pinnacle
# Replaced: vccable/VCCcondata.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/03  18:19:14  pinnacle
# Replaced: vccable/VCCcondata.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:25:06  pinnacle
# Replaced: vccable/VCCcondata.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:47:00  pinnacle
# Created: vccable/VCCcondata.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define  MY_DEBUG	1
#define vdsDEBUG        1
*/

#include "VDmem.h"
#include "vrdbgmacros.h"


from    VCTerm   import   VCTpWhich;


method  VCGetThru (IGRlong         *msg ;
            struct VC_contrace     *ConnIn;
            struct VC_contrace     *ConnRef;
                   IGRshort        *nPos;
            struct VC_contrace     *Conn)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        i;
  IGRshort        nCP, nLD;
  IGRshort        iNo;

SetProc(VCCable_VCGetThru ); Begin

#ifdef MY_DEBUG
  printf (" cable getthru IN %s\n", ConnIn->OutId.Conn.Cable.szLeadId);
#endif
  if (ConnRef->GRid.objid != ConnIn->GRid.objid ||
      ConnRef->GRid.osnum != ConnIn->GRid.osnum)
  {  /*  Reference is NOT the other cable end, so that's what we're 
         looking for                                                  */
    *msg  = MSSUCC;
    *nPos = 1;

    if (Conn)
    {
      *Conn = *ConnIn;

      /*  simply swap connectpoints       */
      Conn->OutId.Conn.Cable.nCpt = 1 - Conn->OutId.Conn.Cable.nCpt;
      Conn->nTrans                = VCO_CAB_CAB;
#ifdef MY_DEBUG
      printf (" cable getthru other end\n");
#endif
    }
  }
  else
  {  /*  look for the terminal or passthru  */
    struct GRid     Term;

    *msg  = MSFAIL;
    *nPos = 0;

    iNo = om$dimension_of (varray = me->Connect_Data);
    nLD = -1;
    nCP = ConnIn->OutId.Conn.Cable.nCpt;

#ifdef MY_DEBUG
     printf (" cable getthru nCP %d\n", nCP);
#endif
    for (i=0; i<iNo; i++)
    {
      if (strcmp (ConnIn->OutId.Conn.Cable.szLeadId,
                  me->Connect_Data[i].LeadNam) == 0)
      {
        nLD = i;
        break;
      }
    }
    if (nLD < 0) goto wrapup;

    *msg  = MSSUCC;
    *nPos = 1;
    if (Conn == NULL) goto wrapup;

    status =
    om$send (msg = message VCCable.VCCbTerm (&retmsg, nCP, &Term),
        targetid = my_id);

#ifdef MY_DEBUG
     printf (" cable getthru endstat, termn %d <%d %d>\n",
                          me->Connect_Data[nLD].nEndStat[nCP],
                          Term.objid, Term.osnum);
#endif
    if ((me->Connect_Data[nLD].nEndStat[nCP] & VC_CBE_OPEN) ||
        (retmsg != MSSUCC))
    {  /*    it's open, return end of trace   */
      Conn->OutId.nType = VC_UNKNOWN;
      Conn->GRid.objid  = NULL_OBJID;
      Conn->nTrans      = VCO_SEPARATE;
#ifdef MY_DEBUG
      printf (" cable getthru open end\n");
#endif
    }
    else
    if (me->Connect_Data[nLD].nEndStat[nCP] & VC_CBE_PASSTHRU)
    {  /*    it's a passthru, get other cable    */
      IGRshort     nOC;
      struct GRid  Pcab;

      status =
      om$send (msg = message VCTerm.VCTpWhich
                             (&retmsg, &ConnIn->GRid, &Pcab, &nOC),
          targetid = Term.objid,
          targetos = Term.osnum);

      *Conn = *ConnIn;

      Conn->nTrans                = VCO_PASS;
      Conn->GRid                  = Pcab;
      Conn->OutId.nType           = VC_CABLE_TYPE;
      Conn->OutId.Conn.Cable.nCpt = nOC;
#ifdef MY_DEBUG
      printf (" cable getthru PASS\n");
#endif
    }
    else
    if (me->Connect_Data[nLD].nEndStat[nCP] & VC_CBE_CONNECTED)
    {  /*    it's a regular connection, set terminal.  */
      Conn->nTrans                = VCO_CAB_CON;
      Conn->GRid                  = Term;
      Conn->OutId.nType           = VC_TERM_TYPE;
      Conn->OutId.Conn.Term       = me->Connect_Data[nLD].FibEnds[nCP];
#ifdef MY_DEBUG
      printf (" cable getthru CONNECTED\n");
#endif
    }
  }

  wrapup:
#ifdef MY_DEBUG
      printf (" cable getthru WRAPUP with %d \n", *nPos);
#endif
End;
  return (OM_S_SUCCESS);
}

method VCConGetTrace (IGRlong         *msg ;
                      IGRint           TransFlags;
               struct VC_contrace     *ConId;
                      IGRboolean      *bBranched;
                      IGRshort        *nTrac;
               struct VC_contrace    **TracTab;
                      IGRchar         *SigId)
{
  IGRlong       retmsg;
  IGRlong       status;
  IGRshort      nPos;

  struct VC_contrace   ConnRef;
  struct VC_contrace   ConnX;
  struct VC_contrace  *Cout;

SetProc(VCCable_VCConGetTrace ); Begin

  /*C   return the signal ID if requested   */

  nPos = 0;

#ifdef MY_DEBUG
  printf (" GetTrace fiber in grid <%d %d>\n",
                     ConId->GRid.objid, ConId->GRid.osnum);
#endif

  if (SigId)
  {
    status =
    om$send (msg = message VCCon.VCGetSignal
                          (&retmsg, &ConId->OutId, SigId),
        targetid = my_id);
    as$status();
  }

  /*C  find a connecting terminal          */

  ConnRef = *ConId;
  ConnRef.OutId.Conn.Cable.nCpt = 1 - ConId->OutId.Conn.Cable.nCpt;

  status =
  om$send (msg = message VCCon.VCGetThru
                      (&retmsg, ConId, &ConnRef, &nPos, &ConnX),
      targetid = my_id);
  as$status();

  if ((nPos > 0) && (ConnX.nTrans  != VCO_SEPARATE))
  {
#ifdef MY_DEBUG
    printf (" to gettrace term 0\n");
#endif
    status =
    om$send (msg = message VCCon.VCConGetTrace
                          (msg, TransFlags, &ConnX, bBranched,
                           nTrac, TracTab, NULL),
        targetid = ConnX.GRid.objid,
        targetos = ConnX.GRid.osnum);
    as$status();

    return (status);
  }

  /*C   if this end is floating try the other   */

  status =
  om$send (msg = message VCCon.VCGetThru
                      (&retmsg, &ConnRef, ConId, &nPos, &ConnX),
      targetid = my_id);
  as$status();

  if ((nPos > 0) && (ConnX.nTrans  != VCO_SEPARATE))
  {
#ifdef MY_DEBUG
    printf (" to gettrace term 1\n");
#endif
    status =
    om$send (msg = message VCCon.VCConGetTrace
                          (msg, TransFlags, &ConnX, bBranched,
                           nTrac, TracTab, NULL),
        targetid = ConnX.GRid.objid,
        targetos = ConnX.GRid.osnum);
    as$status();

    return (status);
  }

  /*C this cable is not connected at all, return just it's two ends  */

  *nTrac = 2;

  if (TracTab)
  {
    Cout = _MALLOC (2, struct VC_contrace);

    if (Cout)
    {
      Cout[0] = *ConId;
      Cout[1] = ConnRef;
    }
    else
      status = OM_E_NODYNMEM;

    *TracTab = Cout;
  }

End;
  return (status);
}
    
end implementation VCCable;

