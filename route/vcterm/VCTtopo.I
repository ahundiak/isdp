
/* $Id: VCTtopo.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm / VCTtopo.I
 *
 * Description:
 *   This file contains the topological methods for terminals
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTtopo.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.7  1997/07/14  22:10:28  pinnacle
# Replaced: vcterm/VCTtopo.I for:  by hverstee for cabling
#
# Revision 1.6  1997/05/19  13:50:10  pinnacle
# Replaced: vcterm/VCTtopo.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  16:39:20  pinnacle
# Replaced: vcterm/VCTtopo.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/23  23:38:46  pinnacle
# Replaced: vcterm/VCTtopo.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/20  20:39:10  pinnacle
# Replaced: vcterm/VCTtopo.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/25  13:54:16  pinnacle
# Replaced: vcterm/VCTtopo.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:32:54  pinnacle
# Created: vcterm/VCTtopo.I by hverstee for cabling
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

method  VCGetCpts   (IGRlong    *msg;
              struct GRid       *RefId;
                     IGRshort   *nRefCp;
                     IGRshort   *nMyCp;
                     IGRshort   *nPass)
{
  struct GRid    meself;

  meself.objid = my_id;
  meself.osnum = OM_Gw_current_OS;

  /*   just send to the cable who knows   */

  return (

  om$send (msg = message VCRoot.VCGetCpts
                           (msg, &meself, nMyCp, nRefCp, nPass),
      targetid = RefId->objid,
      targetos = RefId->osnum)
                                                );
}

method  VCGetTopology (IGRlong   *msg;
                      IGRshort   nCpt;    /*I    my CPT or ALL               */
                      IGRshort  *nConn;   /*O    number output               */
               struct GRid      *ConId;   /*O    list of GRids               */
                      IGRshort  *nConCp;  /*O    list of cpts on GRids       */
                      IGRshort  *nMyCp;   /*O    list of cpts on me          */
                      IGRshort  *nPass)   /*O    list of passthru counters   */
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nTmCp;
  IGRshort     nCbCp;
  IGRshort     nLocp;
  IGRshort     nTC;
  IGRshort     nRC;
  IGRint       i;

  struct GRid  meself;
  struct GRid *Passon;

  meself.objid = my_id;
  meself.osnum = OM_Gw_current_OS;

  *msg = MSSUCC;

  *nConn = 0;

  if (ConId)  Passon = &(ConId[*nConn]);
  else        Passon = NULL;

  status =
  om$send( msg = message VCTerm.VCTcables
                                (&retmsg, &nTC, &nRC, Passon),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" Gettopo term %d %d children\n",nTC, nRC);
#endif

  if (Passon == NULL)
  {
    (*nConn) += nTC;
  }
  else
  for (i=0; i<nTC; i++)
  {
    status =
    om$send (msg = message VCRoot.VCGetCpts
                             (&retmsg, &meself, &nTmCp, &nCbCp, &nLocp),
      targetid = Passon[i].objid,
      targetos = Passon[i].osnum);
 
    if ((nCpt != nTmCp) && (nCpt != VC_REQ_ALL_CPT)) continue;

    if (nConCp)
      nConCp[*nConn] = nCbCp;

    if (nMyCp)
      nMyCp[*nConn] = nTmCp;

    if (nPass)
      nPass[*nConn] = nLocp;

    (*nConn)++;
  }
  
  return (OM_S_SUCCESS);
}

method  VCGetSupports (IGRlong   *msg;
                       IGRshort  *nNbSupps;
                struct GRid      *SuppIds)

{
  IGRint        status;

  struct GRid   RefId;

  *nNbSupps   = 0;
  RefId.objid = NULL_OBJID;

  status =
  om$send (msg = message VCMac.VCGetEquipId (msg, &RefId),
      targetid = my_id);

  if (RefId.objid != NULL_OBJID)
  {
    *nNbSupps = 1;
    if (SuppIds)
    {
      SuppIds->objid = RefId.objid;
      SuppIds->osnum = RefId.osnum;
    }
  }

  return (OM_S_SUCCESS);
}

end implementation VCTerm;

