
/* $Id: VCMinfo.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCMinfo.I
 *
 * Description:
 *
 *      methods for VCMac instance control (offset values)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCMinfo.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/08/13  14:04:46  pinnacle
# Replaced: vcroot/VCMinfo.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/14  22:00:14  pinnacle
# Created: vcroot/VCMinfo.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCMac;

#include "VDmem.h"

#include "VCchansel.h"

extern GRclassid OPP_VCCable_class_id;


method VCSetInstance  (IGRlong    *msg;
                struct VCGenInfo  *Instance)

{
  IGRint        status;
  IGRshort      i;

  status =
  om$send (msg = message VCRoot.VCSetInstance (msg, Instance),
          mode = OM_e_wrt_message,
      targetid = my_id);

  status =
  om$vla_set_dimension (varray = me->dVCOffVal,
                        size   = Instance->Attr.Term.nOff);

  for (i=0; i<Instance->Attr.Term.nOff; i++)
    me->dVCOffVal[i] = Instance->Attr.Term.dOffVal[i];

  return ( OM_S_SUCCESS );

}/* end VCSetInstance */



method VCGetInstance (IGRlong    *msg;
               struct VCGenInfo  *Instance)

{
  IGRint		status;

  status =
  om$send (msg = message VCRoot.VCGetInstance (msg, Instance),
          mode = OM_e_wrt_message,
      targetid = my_id);


  Instance->Attr.Term.nOff = om$dimension_of (varray = me->dVCOffVal);
 
  if (Instance->Attr.Term.dOffVal)
  {
    IGRshort    i;

    for (i=0; i<Instance->Attr.Term.nOff; i++)
      Instance->Attr.Term.dOffVal[i] = me->dVCOffVal[i];
  }

  return ( OM_S_SUCCESS );
}/* end VRGetInstance */

method VCDUMP      (IGRlong   *msg)
{
  IGRint    status;
  IGRint    iSize, i;

  *msg = MSSUCC;

  status =
  om$send (msg = message VCRoot.VCDUMP (msg),
          mode = OM_e_wrt_message,
      targetid = my_id);

  printf (" TYPEFLAGS ");

  if (me->nVCType & VC_GEN_VIRTUAL)  printf (" VIRTUAL");
  if (me->nVCType & VC_GEN_BITERM)  printf (" BITERM");
  if (me->nVCType & VC_GEN_OWNED)  printf (" OWNED");
  if (me->nVCType & VC_GEN_EXTERN)  printf (" EXTERN");

  if (me->nVCType & VC_TERM_CS)  printf (" CS");
  if (me->nVCType & VC_TERM_NO)  printf (" NOPARENT");
  if (me->nVCType & VC_TERM_EQ)  printf (" EQUIPMENT");
  if (me->nVCType & VC_TERM_RE)  printf (" PID-EQ");

  if (me->nVCType & VC_TOFF_COORDS) printf (" OFFSET");
  if (me->nVCType & VC_TOFF_C_ANG) printf (" ANGLE");
  if (me->nVCType & VC_TOFF_C_VEC) printf (" VECTOR");
  if (me->nVCType & VC_TOFF_C_FULL) printf (" MATRIX");

  printf ("\n");

  iSize = om$dimension_of (varray = me->dVCOffVal);

  printf (" VCMAC %d offsets :", iSize);

  for (i=0; i<iSize; i++)
    printf (" %f",me->dVCOffVal[i]);

  printf ("\n");

  return (OM_S_SUCCESS);
}

method VCGetEquipId (IGRlong  *msg;
              struct GRid     *EquipId)

{
  /*    DUMMY     */
  *msg = MSFAIL;

  EquipId->objid = NULL_OBJID;
  EquipId->osnum = OM_Gw_current_OS;

  return (OM_S_SUCCESS);
}


method   VCGetEquipTag (IGRlong  *msg;
                        IGRchar  *EqTag;
                 struct GRmd_env *md_env)
{
  IGRint            status;
  struct GRid       eqid;

  eqid.objid = NULL_OBJID;
  VC_INITSTR(EqTag);

  status =
  om$send (msg = message VCMac.VCGetEquipId (msg, &eqid),
      targetid = my_id);

  if (eqid.objid != NULL_OBJID)
  {
    int            direct_index;
    int            intmsg;

    struct ret_struct rs;

    direct_index = -1;

#ifdef MY_DEBUG
    printf (" EQ found, get tag from  <%d %d>\n",eqid.objid,eqid.osnum);
#endif

    status =
    om$send( msg = message ACncpx.ACgive_structure
                     (&intmsg, &direct_index, VC_N_EQP_NUMBER_AN, &rs, md_env),
         targetid = eqid.objid,
         targetos = eqid.osnum);

    if (intmsg & MSSUCC)
      strcpy (EqTag, rs.var.text_st.text_string);
  }

  return (OM_S_SUCCESS);
}

end implementation VCMac;

