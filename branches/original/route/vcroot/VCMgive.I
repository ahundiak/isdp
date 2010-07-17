
/* $Id: VCMgive.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCMgive.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCMgive.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1999/01/28  20:09:20  pinnacle
# Replaced: vcroot/VCMgive.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/08/11  21:39:36  pinnacle
# Replaced: vcroot/VCMgive.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/14  22:00:00  pinnacle
# Created: vcroot/VCMgive.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        12/31/98        law       CR179802489-Added numerous values for
 *                                              posting.
 *
 *************************************************************************/

class implementation VCMac;

#include "ACrg_collect.h"
#include "VDsa.h"
#include "vc_param.h"

/*
#define MY_DEBUG
*/

from ACrg_collect       import  ACget_named_attribute,
                                ACset_list_attribute;



method ACgive_structure(int          *msg;
                        int          *direct_index;
                        char         *footname;
                 struct ret_struct   *p_rs;
                 struct GRmd_env     *md_env)

{
  IGRint     status;
  IGRlong    retmsg;

  struct GRid      Eqp_Id;

  *msg   = MSSUCC;
  /*A   test for the feet to be supplied by the equipment  */

  Eqp_Id.objid = NULL_OBJID;

  status =
  om$send (msg = message VCMac.VCGetEquipId (&retmsg, &Eqp_Id),
      targetid = my_id);
  if ( !(status & retmsg & OM_S_SUCCESS) ) goto DEFAULT;
  if (Eqp_Id.objid == NULL_OBJID) goto DEFAULT;    

  if ((!strcmp ( footname, VC_N_APPRV_STAT_AN  )) ||
      (!strcmp ( footname, VC_N_CONSTR_STAT_AN )))
  {  /*A   Try to get constr/apprv status from my own attributes first   */
    IGRint            i;
    struct GRid       AttrId;
    struct ACrg_coll  Attr;

#ifdef MY_DEBUG
    printf (" nVCAttr = %d\n", me->nVCAttr);
#endif

    for (i = 0; i < me->nVCAttr; i++)
    {
      status =
      om$get_objid_at_index ( object          = me,
                              p_chanselect    = &ND_father,
                              index           = i,
                              objidaddr       = &AttrId.objid,
                              osnumaddr       = &AttrId.osnum);

      strcpy (Attr.name , footname);

      status =
      om$send( msg = message ACrg_collect.ACget_named_attribute
                                ( &retmsg, &Attr ),
          senderid = NULL_OBJID,
          targetid = AttrId.objid,
          targetos = AttrId.osnum );
      as$status();

      if (retmsg)
      {
        p_rs->type= text_type;
        strcpy (p_rs->var.text_st.text_string, Attr.desc.value.att_txt);
        return (status);
      }
    }
  }

  /*A   Else get all remaining info from the equipment  */
  /*A   Or from the generic method                      */

  /*A   return the equipment objid   */
  if (!strcmp ( footname, VC_N_EQP_ID_IN ) ||
      !strcmp ( footname, VC_N_GENEQ_ID_IN) )  /** Modified for CR179802489 **/
  {
    p_rs->type = double_type;
    p_rs->var.root_pm_st.value = Eqp_Id.objid;
    return (1);
  }
  /** Added for CR179802489 **/
  else if ( ! strcmp (footname, VC_N_GENEQ_CAT_AN))
  {
    status = vdsa$GetStruct(objID = &Eqp_Id,
                            name = VDSA_KEY_SA_PDM_ASSY_CAT,rs = p_rs);
    return (status);
  }
  else if ( ! strcmp (footname, VC_N_GENEQ_NAM_AN))
  {
    status = vdsa$GetStruct(objID = &Eqp_Id,
                            name = VDSA_KEY_SA_PDM_ASSY_NAM,rs = p_rs);
    return (status);
  }
  else if ( ! strcmp (footname, VC_N_GENEQ_REV_AN))
  {
    status = vdsa$GetStruct(objID = &Eqp_Id,
                            name = VDSA_KEY_SA_PDM_ASSY_VER,rs = p_rs);
    return (status);
  }

  /*A   return the requested equipment info    */
  if ((!strcmp ( footname, VC_N_EQP_NUMBER_AN  )) ||
      (!strcmp ( footname, VC_N_APPRV_STAT_AN  )) ||
      (!strcmp ( footname, VC_N_CONSTR_STAT_AN )))
  {
    status =
    om$send( msg = message ACncpx.ACgive_structure
                     (msg, direct_index, footname, p_rs, md_env),
         targetid = Eqp_Id.objid,
         targetos = Eqp_Id.osnum);
    as$status();
    return (status);
  }

  /*A     if not yet done send to generic method   */
  DEFAULT:
  status=
  om$send (msg = message VCRoot.ACgive_structure 
                             (msg, direct_index, footname, p_rs, md_env),
          mode = OM_e_wrt_message,
      targetid = my_id);
  as$status();

  return ( status );
}/* end ACgive_structure */

end implementation VCMac;

