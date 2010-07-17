
/* $Id: VCTpover.I,v 1.1.1.1 2001/01/04 21:12:39 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTpover.I
 *
 * Description:
 *
 *      VCP_reorg - reorganize dynamic connectpoints
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTpover.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.1  1997/07/22  14:49:34  pinnacle
# Created: vcterm/VCTpover.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCTerm;

#include "VDmem.h"

from       VCCable  import   VCCbDynCpt;

/*
#define MY_DEBUG
*/

method  VCP_reorg (IGRlong         *msg)
{
  IGRint        status;
  IGRlong       retmsg;
  IGRshort      nTopo;
  IGRshort     *nCPme;
  IGRshort     *nCPcb;
  IGRshort     *nCPnw;
  IGRshort      i, j;
  IGRint        NumCP;

  struct GRid  *Cabs;

  *msg = MSSUCC;

  status =
  om$send (msg = message VCRoot.VCGetTopology
                                (&retmsg, VC_REQ_ALL_CPT, &nTopo, 
                                  NULL, NULL, NULL, NULL),
      targetid = my_id);

  if (nTopo <= 0) return (OM_S_SUCCESS);

  Cabs  = _MALLOC (nTopo, struct GRid);
  nCPcb = _MALLOC (nTopo, IGRshort);
  nCPme = _MALLOC (nTopo, IGRshort);
  nCPnw = _MALLOC (nTopo, IGRshort);

  status =
  om$send (msg = message VCRoot.VCGetTopology
                                (&retmsg, VC_REQ_ALL_CPT, &nTopo, 
                                  Cabs, nCPcb, nCPme, NULL),
      targetid = my_id);

  for (i=0; i<nTopo; i++)
    nCPnw[i] = nCPme[i];

  NumCP = om$dimension_of (varray = me->VCoff);

  for (i=0; i<NumCP; i++)
  {
    for (j=0; j<nTopo; j++)
    {
      if (nCPme[j] == (i+1))   goto _next;    /*   used, keep   */
    }

    for (j=0; j<nTopo; j++)
    {
      if (nCPme[j] > (i+1))    nCPnw[j]--;
    }

#ifdef MY_DEBUG
    printf (" remove unused %d\n",(i+1));
#endif

    status =
    om$send (msg = message VCP.VCP_rem (&retmsg, (IGRshort) (i+1)),
        targetid = my_id);

    _next:
    continue;
  }

  for (i=0; i<nTopo; i++)
  {
#ifdef MY_DEBUG
    printf (" reprganize, old %d new %d\n",nCPcb[i], nCPnw[i]);
#endif

    status =
    om$send (msg = message VCCable.VCCbDynCpt (&retmsg, nCPcb[i], nCPnw[i]),
        targetid = Cabs[i].objid,
        targetos = Cabs[i].osnum);
  }

  _FREE (Cabs);
  _FREE (nCPcb);
  _FREE (nCPme);
  _FREE (nCPnw);
  return (OM_S_SUCCESS);
}

end implementation VCTerm;

