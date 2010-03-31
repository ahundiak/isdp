class implementation EMSdpr;

#include "emsdef.h"
#include "msdef.h"

method GRdisyourself(IGRlong *EMmsg; IGRshort *mx_type; 
                     IGRmatrix matrix;  enum GRdpmode *mode;
                     struct IGRaltdisplay *alt_symb; 
                     struct DP_information *sp_info; 
                     OM_p_KEY_DESC range_key)
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            num_in=0;
  GRobjid          *in=NULL;    
  IGRboolean        send_to_comp_mac=FALSE;
  extern OMuword    OPP_EMSsfmacro_class_id;
  extern unsigned char EMS_locate_features;


  *EMmsg = MSSUCC;

  if (EMS_locate_features)
  {
    OMuint ii, jj;
    IGRint comp_cnt=0;
    struct GRid *comp_lst=NULL;


    if ((ME.EMSdpr->dpr_props & EMS_MACRO_STATE) ||
        EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                          OPP_EMSsfmacro_class_id, FALSE))
    {
      OM_S_CHANSELECT to_comps;
      IGRushort       dpr_props;

      EMmake_chanselect(GRcmpowner_to_components, &to_comps);
      OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                              &dpr_props), 
                        p_chanselect = &to_comps,
                        from = 0, to = 0);
      if ((1 & OM_stat & *EMmsg) && (dpr_props & EMS_MACRO_STATE))
        send_to_comp_mac = TRUE;
    }      

    OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg, NULL_OBJID,
                            FALSE, &num_in, &in, NULL),
                      targetid = my_id); 
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    for(ii=0; ii<num_in; ii++)
    {
      (void) EFgetcomponents(EMmsg, in[ii], in[ii], OM_Gw_current_OS,
                             &comp_cnt, &comp_lst);
      if (!(1 & *EMmsg)) goto wrapup;

      for(jj=0; jj<comp_cnt; jj++)
      {
        om$send(msg = OPPmargs,
                senderid = comp_lst[jj].objid,
                targetid = comp_lst[jj].objid);
      }
      if (comp_lst)
      {
        om$dealloc(ptr = comp_lst);
        comp_lst = NULL;
        comp_cnt = 0;
      }
    }                        
  }    

  if (!EMS_locate_features || send_to_comp_mac)
  {
    OM_stat = om$send(mode = OM_e_wrt_message,
                      msg = message EMScomposite.GRdisyourself(EMmsg, mx_type, 
                                    matrix, mode, alt_symb, sp_info,
                                    range_key),  
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
  }

wrapup:
  if (in) om$dealloc(ptr = in);
  EMWRAPUP (*EMmsg, OM_stat, "dpr.disyours");
  return(OM_stat);
}
end implementation EMSdpr;
