
/* $Id: VCCtopo.I,v 1.4 2002/05/14 14:15:05 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCCtopo.I
 *
 * Description:
 *   This file contains the topological methods for cables
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCtopo.I,v $
 *        Revision 1.4  2002/05/14 14:15:05  anand
 *        Bug fixes. TRs 6347 and 6348.
 *
 *        Revision 1.3  2002/05/08 15:48:23  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:09:15  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  19:58:12  pinnacle
# Replaced: vccable/VCCtopo.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/01/20  20:49:58  pinnacle
# Replaced: vccable/VCCtopo.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  14:03:22  pinnacle
# Replaced: vccable/VCCtopo.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/11  21:46:42  pinnacle
# Replaced: vccable/VCCtopo.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:50:16  pinnacle
# Created: vccable/VCCtopo.I by hverstee for cabling
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

method  VCCbTerm (IGRlong       *msg;
                  IGRshort       nEnd;      /* I  End indicator             */
           struct GRid          *Term)
{
  IGRint         status=OM_S_SUCCESS;
  IGRshort       nSct=0;
  IGRshort       i=0;

  SetProc(VCCable_VCCbTerm ); Begin;
  __DBGpr_me();

  *msg = MSSUCC;
  Term->objid = NULL_OBJID;
  Term->osnum = OM_Gw_current_OS;

  nSct = om$dimension_of (varray = me->Sect);
  __DBGpr_int("Number of sections",nSct);

  if (nEnd == 0)   i = 0;
  else             i = nSct -1;

  __DBGpr_int("Which End?",nEnd);
  __DBGpr_int("Section type of cable end",me->Sect[i].type);

  if (me->Sect[i].type == VCC_TERM_CHILD)
  {
    IGRshort  nT, nR;

    struct GRid    Local[2];

    status =
    om$send (msg = message VCRoot.VCChildren (msg, &nT, &nR, Local),
        targetid = my_id);

    *Term = Local[0];

    if ((nEnd > 0) && (nT > 1))
      *Term = Local[1];
  }
  else
  if (me->Sect[i].type == VCC_TERM_PARENT)
  {
    IGRshort    ipar;

    ipar = me->Sect[i].parno;

    status =
    om$send (msg = message VCRoot.VCParent (msg, ipar, Term, NULL),
        targetid = my_id);
  }

  __DBGpr_int("return status",status);

  End;
  return (status);
}

method VCGetCpts ( IGRlong *msg;
	       struct GRid *RefId;
		  IGRshort *nRefCp;
		  IGRshort *nMyCp;
		  IGRshort *nPass )
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nEnd;
  IGRshort       nSct;
  IGRshort       i, j;

  struct GRid    Parid;

  SetProc(VCCable_VCGetCpts); Begin;

  *msg = MSFAIL;

  for (nEnd = 0; nEnd < 2; nEnd++)
  {
    status =
    om$send( msg = message VCCable.VCCbTerm (&retmsg, nEnd, &Parid),
        targetid = my_id);

    if ((Parid.objid == RefId->objid) &&
        (Parid.osnum == RefId->osnum))
	break;
  }

  if( nEnd==2 )
  {
      /* Terminal parent not found at end of cable.
       * Check for Parent Cable at end 0 */

      /* It is not a sub-cable so quit */

      /* The parent cable is not RefId so quit */
  }

  *msg = MSSUCC;
  nSct = om$dimension_of (varray = me->Sect);

  i = nEnd;
  if (nEnd == 1) i = nSct - 1;

  *nPass  = 0;
  *nRefCp = me->Sect[i].iFrom;
  *nMyCp  = nEnd;

  j = om$dimension_of (varray = me->Connect_Data);

  for (i=0; i<j; i++)
  {
    if (me->Connect_Data[i].nEndStat[nEnd] & VC_CBE_PASSTHRU)    (*nPass)++;
  }

End;
  return (OM_S_SUCCESS);
}

method  VCGetTopology ( IGRlong   *msg;
			IGRshort   nCpt;    /*I	my CPT or ALL		   */
			IGRshort  *nConn;   /*O	number output		   */
		     struct GRid  *ConId;   /*O	list of GRids		   */
			IGRshort  *nConCp;  /*O	list of cpts on GRids	   */
			IGRshort  *nMyCp;   /*O	list of cpts on me	   */
			IGRshort  *nPass )  /*O	list of passthru counters  */
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nEnd;

  IGRshort       lConcp;
  IGRshort       lMycp;
  IGRshort       lPass;

  struct GRid    Parid;

  SetProc(VCCable_VCGetTopology); Begin;
  __DBGpr_me();
  __DBGpr_int("Parent sought at cpt",nCpt);

  *msg         = MSFAIL;
  *nConn       = 0;
  Parid.objid  = NULL_OBJID;
  Parid.osnum  = OM_Gw_current_OS;

  for (nEnd = 0; nEnd < 2; nEnd++)
  {
    if ((nCpt != nEnd) && (nCpt != VC_REQ_ALL_CPT)) continue;

    status =
    om$send( msg = message VCCable.VCCbTerm (&retmsg, nEnd, &Parid),
        targetid = my_id);

    if( retmsg!=MSSUCC || Parid.objid==NULL_OBJID )
    {
	if( nEnd==1 )
	    continue;

	/* Check for my_id being a sub-cable */

	/* if not a sub-cable */
	continue;
    }

    status =
    om$send( msg = message VCRoot.VCGetCpts
                               (&retmsg, &Parid, &lConcp, &lMycp, &lPass),
        targetid = my_id);

    if (retmsg != MSSUCC) continue;

    if (ConId)
      ConId[*nConn] = Parid;

    if (nConCp)
      nConCp[*nConn] = lConcp;

    if (nMyCp)
      nMyCp[*nConn] = lMycp;

    if (nPass)
      nPass[*nConn] = lPass;

    *msg   = MSSUCC;
    (*nConn)++;
  }

End;
  return (OM_S_SUCCESS);
}

method  VCGetSupports (IGRlong   *msg;
                       IGRshort  *nNbSupps;
                struct GRid      *SuppIds)

{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nSct;
  IGRint       i;

SetProc(VCCable_VCGetSupports ); Begin

  *msg        = MSSUCC;
  *nNbSupps   = 0;

  nSct = om$dimension_of (varray = me->Sect) - 1;

  for (i=0; i<nSct; i++)
  {
    IGRshort   iparno;

    if (me->Sect[i].parno < 0)               continue;
    if (me->Sect[i].type == VCC_TERM_PARENT) continue;

    iparno = me->Sect[i].parno;

    if (SuppIds)
    {
      status =
      om$send( msg = message VCRoot.VCParent
                          (&retmsg, iparno, &SuppIds[*nNbSupps], NULL),
          targetid = my_id);
    }

    (*nNbSupps)++;
  }

End;
  return (OM_S_SUCCESS);
}

end implementation VCCable;

