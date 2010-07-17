
/* $Id: VCRexpand.I,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRexpand.I
 *
 * Description:
 *   Store/retrieve methods for object expander..
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRexpand.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.1  1997/07/31  19:49:18  pinnacle
# Created: vcroot/VCRexpand.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCRoot;

method  VCGetExpand (IGRlong    *msg;
                     IGRshort    iWhich;   /*  Expand index or -1 (all)    */
                     IGRshort   *noret;    /*  number returned             */
              struct VCEXpan    *ExRec)    /*  output buffer               */
{
  IGRint       ibuff;
  IGRint       i;

  ibuff = om$dimension_of (varray = me->EXPAND);

  if (iWhich < 0)
  {
    *msg   = MSSUCC;
    *noret = ibuff;

    if (ExRec != NULL)
    {
      for (i=0; i<ibuff; i++)
        ExRec[i] = me->EXPAND[i];
    }
  }
  else
  if (iWhich < ibuff)
  {
    *msg   = MSSUCC;
    *noret = 1;

    if (ExRec != NULL)
      *ExRec = me->EXPAND[iWhich];
  }
  else
  {
    *msg   = MSFAIL;
    *noret = 0;
  }

  return (OM_S_SUCCESS);
}

method  VCPutExpand (IGRlong    *msg;
                     IGRshort    iWhich;   /*  Expand index or -1 (next)   */
                     IGRshort   *noret;    /*  index returned              */
              struct VCEXpan    *ExRec)    /*  input record                */
{
  IGRint       status;
  IGRint       ibuff;

  ibuff = om$dimension_of (varray = me->EXPAND);
  *msg   = MSFAIL;
  *noret = -1;

  if (ExRec == NULL) return (OM_S_SUCCESS);

  if (iWhich < 0)
  {
    status =
    om$vla_set_dimension (varray = me->EXPAND,
                          size   = (ibuff + 1));
    if (!(status & OM_S_SUCCESS)) return (status);

    *msg   = MSSUCC;
    *noret = ibuff;

    me->EXPAND[ibuff] = *ExRec;
  }
  else
  {
    if (iWhich >= ibuff)
    {
      status =
      om$vla_set_dimension (varray = me->EXPAND,
                            size   = (iWhich + 1));

      if (!(status & OM_S_SUCCESS)) return (status);
    }

    *msg   = MSSUCC;
    *noret = iWhich;

    me->EXPAND[iWhich] = *ExRec;
  }

  return (OM_S_SUCCESS);
}

end implementation VCRoot;

