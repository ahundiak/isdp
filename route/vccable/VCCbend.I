
/* $Id: VCCbend.I,v 1.2 2001/02/20 01:08:36 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCbend.I
 *
 * Description:
 *
 *      Methods to maintain bend overrides
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCbend.I,v $
 *      Revision 1.2  2001/02/20 01:08:36  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  19:59:08  pinnacle
# Replaced: vccable/VCCbend.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/07/14  22:31:10  pinnacle
# Replaced: vccable/VCCbend.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/06  22:53:30  pinnacle
# Replaced: vccable/VCCbend.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/26  16:58:18  pinnacle
# Replaced: vccable/VCCbend.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/12  15:40:54  pinnacle
# Replaced: vccable/VCCbend.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:46:46  pinnacle
# Created: vccable/VCCbend.I by hverstee for cabling
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
#define vdsDEBUG        1
#define  MY_DEBUG	1
*/

#include "nddef.h"
#include "ndmacros.h"
#include "vrdbgmacros.h"


/*------------------------------------------------------------------------- */

/*     Retrieve bend radius at index    */

method   VCCbBendrGet (IGRlong       *msg;
                       IGRint         Index;
                       IGRint         ISect;
                       IGRdouble     *dBrad)
{
  IGRint    status;
  IGRlong   retmsg;
  IGRint    NumBend, i;
  IGRshort  nIN = -1;
  IGRshort  nMP = -1;

  struct ret_struct p_rs;

SetProc(VCCable_VCCbBendrGet ); Begin

  status =
  om$send (msg = message VCDB.VCGpAnum
                         (&retmsg, nIN, nMP, VC_X_BEND_RAD_DB, &p_rs),
      targetid = my_id);

 *dBrad = p_rs.var.root_pm_st.value;

  NumBend = om$dimension_of( varray = me->Bend);

  for (i=0; i<NumBend; i++)
  {
    if ((me->Bend[i].secno == ISect) && (me->Bend[i].vtxno == Index))
    {
      *dBrad = me->Bend[i].rad;
      break;
    }
  }

End;
  return ( OM_S_SUCCESS );
}

/*------------------------------------------------------------------------- */

/*    Modify bend radius at vertex     */

method   VCCbBendrPut (IGRlong       *msg;
                       IGRint         Index;
                       IGRint         ISect;
                       IGRdouble      dBrad)
{
  IGRint    status;
  IGRlong   retmsg;
  IGRint    NumBend, i, jj;
  IGRshort  nIN = -1;
  IGRshort  nMP = -1;
  IGRint    cn_type;

  struct ret_struct       p_rs;
  struct GRid             meself;

SetProc(VCCable_VCCbBendrPut ); Begin

  meself.objid = my_id;
  meself.osnum = OM_Gw_current_OS;

  *msg = MSFAIL;
  status =
  om$send (msg = message VCDB.VCGpAnum
                         (&retmsg, nIN, nMP, VC_X_BEND_RAD_DB, &p_rs),
      targetid = my_id);

  if ((dBrad > 0.0001) && 
      (dBrad < p_rs.var.root_pm_st.value))     return ( OM_S_SUCCESS);

  NumBend = om$dimension_of( varray = me->Bend);

  *msg   = MSSUCC;

  for (i=0; i<NumBend; i++)
  {
    if ((me->Bend[i].secno == ISect) && (me->Bend[i].vtxno == Index))
    { /*  found earlier override, modify   */
      if (dBrad < p_rs.var.root_pm_st.value)
      { /*  must be zero.... remove    */
        if (NumBend > 1)
        {
          for (jj=i; jj<NumBend-1; jj++)
          {
            me->Bend[jj] = me->Bend[jj+1];
          }
        }

#ifdef MY_DEBUG
        printf ("remove bend override %d\n",i);
#endif
        status =
        om$vla_set_dimension (varray  = me->Bend,
                              size    = (NumBend-1));
      }
      else
        me->Bend[i].rad = dBrad;

      goto PROC;
    }
  }

  /*   not found, add new    */

  if (dBrad >= p_rs.var.root_pm_st.value)
  {
    status =
    om$vla_set_dimension (varray  = me->Bend,
                        size    = (NumBend+1));

    me->Bend[NumBend].secno = ISect;
    me->Bend[NumBend].vtxno = Index;
    me->Bend[NumBend].rad   = dBrad;
  }

  /* do the wait batch */
  PROC:
  cn_type = ND_COMP;
  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &meself,
             l_obj_info = &cn_type,
             nb_obj     = 1);

End;
  return ( OM_S_SUCCESS );
}

/*    Clear bend radius table    */

method   VCCbBendrClr (IGRlong       *msg)
{
  IGRint    status;
  IGRint    cn_type;

  struct GRid       meself;

SetProc(VCCable_VCCbBendrClr ); Begin

  meself.objid = my_id;
  meself.osnum = OM_Gw_current_OS;

  *msg   = MSSUCC;

  status =
  om$vla_set_dimension (varray  = me->Bend,
                        size    = 0);

  /* do the wait batch */
  cn_type = ND_COMP;
  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &meself,
             l_obj_info = &cn_type,
             nb_obj     = 1);

End;
  return ( OM_S_SUCCESS );
}

end implementation VCCable;

