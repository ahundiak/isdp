
/* $Id: VCXi.I,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCXi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCXi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/03/19  15:54:02  pinnacle
# Replaced: vcroot/VCXi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:15:02  pinnacle
# Created: vcroot/VCXi.I by hverstee for cabling
#
 *
 * History:
 *        06/26/96        hv        Initial
 *
 *************************************************************************/

class implementation VCX;

method VCx_init (IGRlong      *msg)
{
  IGRint   status;

  *msg = MSSUCC;

  status = om$vla_set_dimension (varray = me->nVCx,
                                 size   = 0);
  return (OM_S_SUCCESS);
}

method VCx_ref  (IGRlong      *msg;
          struct GRid         *gID;
                 IGRshort     *nType;
                 IGRint       *nIndex)
{
  IGRint             status;
  OMuint             l_index;

  *msg   = MSFAIL;
  *nType = VCP_TYPE_NONE;

  status = om$get_index (object_c     = me,
                         p_chanselect = &ND_children,
                         objid        = gID->objid,
                         osnum2       = gID->osnum,
                         indexaddr    = &l_index);

  if (status & OM_S_SUCCESS)
  {
    *msg    = MSSUCC;
    *nType  = VCP_TYPE_CHILD;
    *nIndex = l_index;
  }
  else
  {
    status = om$get_index (object_c     = me,
                           p_chanselect = &ND_father,
                           objid        = gID->objid,
                           osnum2       = gID->osnum,
                           indexaddr    = &l_index);
    if (status & OM_S_SUCCESS)
    {
      *msg    = MSSUCC;
      *nType  = VCP_TYPE_PARENT;
      *nIndex = l_index;
    }
  }

  return (status);
}

method VCx_get  (IGRlong      *msg;
          struct GRid         *gID;
                 IGRshort     *nType;
                 IGRshort     *nCPoth;
                 IGRshort     *nCPmy) 
{
  IGRint             status;
  IGRint             nEnt;
  IGRint             nIndex;
  IGRint             i;

  status = 
  om$send (msg = message VCX.VCx_ref (msg, gID, nType, &nIndex),
      targetid = my_id);

  if (*nType == VCP_TYPE_NONE) return (status);

  nEnt   = om$dimension_of (varray = me->nVCx);

  for (i=0; i< nEnt; i++)
  {
    if ((*nType == me->nVCx[i].nPtype) &&
        (nIndex == me->nVCx[i].nPchnix))
    {
      *msg = MSSUCC;
      *nCPoth = me->nVCx[i].nPocpt;
      *nCPmy  = me->nVCx[i].nPmycpt;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method VCx_chg  (IGRlong      *msg;
          struct GRid         *gID;
                 IGRshort      nCPoth;
                 IGRshort      nCPmy)
{
  IGRint             status;
  IGRint             nEnt;
  IGRint             nIndex;
  IGRshort           nType;
  IGRint             i;

  status =
  om$send (msg = message VCX.VCx_ref (msg, gID, &nType, &nIndex),
      targetid = my_id);

  if (nType == VCP_TYPE_NONE) return (status);

  nEnt   = om$dimension_of (varray = me->nVCx);

  for (i=0; i< nEnt; i++)
  {
    if ((nType  == me->nVCx[i].nPtype) &&
        (nIndex == me->nVCx[i].nPchnix))
    {
      *msg = MSSUCC;
      me->nVCx[i].nPocpt  = nCPoth;
      me->nVCx[i].nPmycpt = nCPmy;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method VCx_add  (IGRlong      *msg;
          struct GRid         *gID;
                 IGRshort      nCPoth;
                 IGRshort      nCPmy)
{
  IGRint             status;
  IGRint             nEnt;
  IGRint             nIndex;
  IGRshort           nType;

  status =
  om$send (msg = message VCX.VCx_ref (msg, gID, &nType, &nIndex),
      targetid = my_id);

  if (nType == VCP_TYPE_NONE) return (status);

  *msg   = MSSUCC;
  nEnt   = om$dimension_of (varray = me->nVCx);

  status = om$vla_set_dimension (varray = me->nVCx,
                                 size   = (nEnt+1));

  me->nVCx[nEnt].nPtype  = nType;
  me->nVCx[nEnt].nPchnix = nIndex;
  me->nVCx[nEnt].nPocpt  = nCPoth;
  me->nVCx[nEnt].nPmycpt = nCPmy;

  return (OM_S_SUCCESS);
}

method VCx_rem  (IGRlong      *msg;
          struct GRid         *gID)
{
  IGRint             status;
  IGRint             nEnt;
  IGRshort           nType;
  IGRint             nIndex;
  IGRint             i, j;

  status =
  om$send (msg = message VCX.VCx_ref (msg, gID, &nType, &nIndex),
      targetid = my_id);

  if (nType == VCP_TYPE_NONE) return (status);

  nEnt   = om$dimension_of (varray = me->nVCx);

  for (i=0; i< nEnt; i++)
  {
    if ((nType  == me->nVCx[i].nPtype) &&
        (nIndex == me->nVCx[i].nPchnix))
    {
      *msg = MSSUCC;

      for (j=(nEnt-1);j > i; j--)
      {
        if ((me->nVCx[j].nPtype == nType) &&
            (me->nVCx[j].nPchnix > nIndex))    me->nVCx[j].nPchnix--;

        me->nVCx[j-1].nPtype  = me->nVCx[j].nPtype;
        me->nVCx[j-1].nPchnix = me->nVCx[j].nPchnix;
        me->nVCx[j-1].nPocpt  = me->nVCx[j].nPocpt;
        me->nVCx[j-1].nPmycpt = me->nVCx[j].nPmycpt;
      }

      status = om$vla_set_dimension (varray = me->nVCx,
                                     size   = (nEnt-1));
      break;
    }
  }

  return (OM_S_SUCCESS);
}

end implementation VCX;

