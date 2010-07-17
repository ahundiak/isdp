
/* $Id: VCRparam.I,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRparam.I
 *
 * Description:
 *   This file contains the methods maintaining attributes
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRparam.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/12/22  17:04:12  pinnacle
# Replaced: vcroot/VCRparam.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/12  20:46:50  pinnacle
# Replaced: vcroot/VCRparam.I for:  by kddinov for route
#
# Revision 1.5  1997/08/11  21:40:06  pinnacle
# Replaced: vcroot/VCRparam.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:57:50  pinnacle
# Replaced: vcroot/VCRparam.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:53:24  pinnacle
# Replaced: vcroot/VCRparam.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/08  21:43:14  pinnacle
# Replaced: vcroot/VCRparam.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:13:14  pinnacle
# Created: vcroot/VCRparam.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCRoot;

#include "VDmem.h"

#include "ACrg_collect.h"

from     ACrg_collect  import   AClist_attribute;

/*
#define MY_DEBUG
*/

method VCGetParams( IGRlong       *msg;
                    IGRshort      *nNbPar;
              struct GRid         *ParamId)
{
  /* -- The parameters are the first templates of the list -- */

  IGRint        status, NbRoots;
  struct GRid  *buffer;

  *msg = MSSUCC;

  *nNbPar = me->nVCAttr;

  if (ParamId)
  {
    IGRshort     i;

    status = 
    om$send( msg = message NDnode.NDget_objects
                                   (ND_ROOT | ND_IN_BUF, NULL, 0, &buffer,
                                    0, OM_K_MAXINT, &NbRoots ),
        targetid = my_id);
    as$status();

    for (i=0; i<me->nVCAttr; i++)
    {

      if ( i < NbRoots)
      {
        ParamId[i].objid = buffer[i].objid;
        ParamId[i].osnum = buffer[i].osnum;
      }
      else
      {
        ParamId[i].objid = NULL_OBJID;
        ParamId[i].osnum = OM_Gw_current_OS;
      }
    }
  }

  return (OM_S_SUCCESS);

}/* end VCGetParams */


method VCChgParam ( IGRlong   *msg;
                    IGRshort   nIndex;
             struct GRid      *ParamId )
{
  IGRint    status;
  IGRint    NbRoots;
  IGRint    i; 

  struct GRid     *NewTemplates;
  struct GRid     *buffer;

  *msg = MSFAIL;

  if ((nIndex < 0) || (nIndex >= me->nVCAttr))
    return (OM_S_SUCCESS);

  *msg = MSSUCC;

  /* Correction of crash for CR179802404 - Cause is unknown */
  NbRoots = 0;
  /* get previous templates */
  status = 
  om$send( msg = message NDnode.NDget_objects
                                  (ND_ROOT | ND_IN_BUF, NULL, 0,
                                   &buffer, 0, OM_K_MAXINT, &NbRoots ),
      targetid = my_id);
  as$status();
  if(NbRoots > 0) /* CR179802404 */
  { 
  NewTemplates = _MALLOC (NbRoots, struct GRid);

  for (i=0; i<NbRoots; i++)
  {
    NewTemplates[i].objid = buffer[i].objid;
    NewTemplates[i].osnum = buffer[i].osnum;
  }

  NewTemplates[nIndex].objid = ParamId->objid;
  NewTemplates[nIndex].osnum = ParamId->osnum;

  status =
  om$send( msg = message NDnode.NDconnect ( NbRoots, NewTemplates,
                                            NULL_GRID,ND_FULL),
      targetid = my_id);

  _FREE (NewTemplates);
  }

  return status;

}/* end method VCChgParams */


method  VCGetSysPar (IGRlong   *msg;
              struct GRid      *CollId;
                     IGRshort  *nNbChild;
                     IGRshort  *nNbPar;
              struct ACrg_coll *Coll)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRshort    nId;
  IGRint      NbAttr;
  IGRint      NbChild;

  struct GRid       ParamId[2];
  struct GRid      *buffer;

  *msg = MSSUCC;

  status =
  om$send (msg = message VCRoot.VCGetParams(&retmsg, &nId, ParamId),
      targetid = my_id);

  if ( CollId )  *CollId = ParamId[0]; 

  status =
  om$send (msg = message ACrg_collect.AClist_attribute
                          (&retmsg, 0, NULL, &NbAttr),
      targetid = ParamId[0].objid,
      targetos = ParamId[0].osnum);

  if ( nNbPar) *nNbPar = NbAttr;

  /*   find the number of children of this collection   */

  status =
  om$send (msg = message NDnode.NDget_objects
                                (ND_CHILDREN | ND_IN_BUF, NULL, 0,
                                 &buffer, 0, OM_K_MAXINT, &NbChild ),
      targetid = ParamId[0].objid,
      targetos = ParamId[0].osnum);

  if ( nNbChild) *nNbChild = NbChild;

#ifdef MY_DEBUG
  printf ("coll <%d %d> has %d att\n",ParamId[0].objid, ParamId[0].osnum,
                                     NbAttr);
#endif

  if (Coll) {
    status = om$send( msg     = message ACrg_collect.AClist_attribute
                                      (&retmsg, NbAttr, Coll, &NbAttr),
                     targetid = ParamId[0].objid,
                     targetos = ParamId[0].osnum);
  }

  return (OM_S_SUCCESS);
}

method  VCGetInsPar (IGRlong   *msg;
                     IGRshort  *nNbPar;
              struct ACrg_coll *Coll)
{
  IGRint      status;
  IGRchar     szTag[VC_MAX_TAGNO];

  *msg    = MSSUCC;
  *nNbPar = 0;

  if (Coll)
  {
    Coll[*nNbPar].desc.type = AC_ATTRIB_TEXT;
    strcpy (Coll[*nNbPar].name, VC_N_COMP_CODE_AN);

    status =
    om$send (msg = message VCRoot.VCGetCode (Coll[*nNbPar].desc.value.att_txt),
        targetid = my_id);
  }
  (*nNbPar)++;

  status =
  om$send (msg = message VCRoot.VCGetTagNo (szTag),
      targetid = my_id);

  if (!(VC_EMPTYSTR(szTag)))
  {
    if (Coll)
    {
      Coll[*nNbPar].desc.type = AC_ATTRIB_TEXT;
      strcpy (Coll[*nNbPar].name, VC_N_TAG_NUMBER_AN);
      strcpy (Coll[*nNbPar].desc.value.att_txt, szTag);
    }

    (*nNbPar)++;
  }

  if (Coll)
  {
    Coll[*nNbPar].desc.type = AC_ATTRIB_TEXT;
    strcpy (Coll[*nNbPar].name,VC_N_NO_MTO_AN);

    status =
    om$send (msg = message VCRoot.VCGetMtoFlag
                                  (NULL, Coll[*nNbPar].desc.value.att_txt),
        targetid = my_id);
  }

  (*nNbPar)++;

  return (OM_S_SUCCESS);
}

method  VCGetUsrPar (IGRlong   *msg;
              struct GRid      *CollId;
                     IGRshort  *nNbChild;
                     IGRshort  *nNbPar;
              struct ACrg_coll *Coll)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRshort    nId;
  IGRint      NbAttr;
  IGRint      NbChild;

  struct GRid       ParamId[2];
  struct GRid      *buffer;

  *msg = MSSUCC;

  status =
  om$send (msg = message VCRoot.VCGetParams(&retmsg, &nId, ParamId),
      targetid = my_id);

  CollId->objid = ParamId[1].objid;
  CollId->osnum = ParamId[1].osnum;

  status =
  om$send (msg = message ACrg_collect.AClist_attribute
                          (&retmsg, 0, NULL, &NbAttr),
      targetid = ParamId[1].objid,
      targetos = ParamId[1].osnum);

  /*   find the number of children of this collection   */

  status =
  om$send (msg = message NDnode.NDget_objects
                                (ND_CHILDREN | ND_IN_BUF, NULL, 0,
                                 &buffer, 0, OM_K_MAXINT, &NbChild ),
      targetid = ParamId[1].objid,
      targetos = ParamId[1].osnum);

  *nNbChild = NbChild;
  *nNbPar   = NbAttr;

  if (Coll)
  {
    status =
    om$send (msg = message ACrg_collect.AClist_attribute
                          (&retmsg, NbAttr, Coll, &NbAttr),
        targetid = ParamId[1].objid,
        targetos = ParamId[1].osnum);
  }

  return (OM_S_SUCCESS);
}

end implementation VCRoot;

