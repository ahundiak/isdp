class implementation EMSvsgd;

# include "EMSlogic.h"
# include "EMSmsgdef.h"
# include "emserr.h"

method EMput_window(IGRlong     *EMmsg;
                    struct GRid *window_id)
{
  *EMmsg = EMS_S_Success;

  me->window_id = *window_id;

  return(OM_S_SUCCESS);
}

method EMget_class_info(IGRlong         *EMmsg;
                        OMuword         *frt_classid;
                        OM_p_MESSAGE    messg)
{
  struct EMSvsgd_EMput_window_Msg   *parglist;
  IGRlong                           sts = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;

  if(frt_classid) *frt_classid = OPP_EMSvsgd_class_id;

  if(messg)
  {
    parglist = NULL;
    parglist= (struct EMSvsgd_EMput_window_Msg *) 
        om$malloc(size = sizeof(struct EMSvsgd_EMput_window_Msg));
    EMerr_hndlr (!parglist, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

    parglist->EMmsg = EMmsg;
    parglist->window_id = &me->window_id;

    sts = om$make_message (classname = "EMSvsgd",
              methodname = "EMput_window",
              size = (OMuword) sizeof(struct EMSvsgd_EMput_window_Msg),
              p_arglist = (char *) parglist, p_msg = messg);
    if(! (1 & sts)) goto wrapup;

  } /* if (messg) */

  sts = OM_I_STOP_SENDING;

wrapup:
  EMWRAPUP (*EMmsg, sts, "EMSvsgd.EMget_class_info")
  return (sts);
}

method EMlocate(IGRlong                 *EMmsg;
                struct IGRbsp_surface   *surface;
                struct GRlc_info        *lc_info;
                struct GRlc_cvl         *cvl;
                IGRlong                 *prism_rel;
                IGRboolean              *inside,
                                        *outside,
                                        *overlap,
                                        *was_located;
                struct GRid             *window_id)
{
  IGRlong                   sts = OM_S_SUCCESS;

  if(! window_id) { *EMmsg = EMS_I_InvalidArg; goto wrapup; }

  if((window_id->objid IS me->window_id.objid) &&
     (window_id->osnum IS me->window_id.osnum))
  {
    sts = om$send(msg = message EMSgradata.EMlocate(
                    EMmsg,
                    surface,
                    lc_info,
                    cvl,
                    prism_rel,
                    inside,
                    outside,
                    overlap,
                    was_located,
                    window_id),
                  mode = OM_e_wrt_message,
                  targetid = my_id);
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSvsgd.EMlocate")
  return(sts);
};

method EMkeypoint(IGRlong               *EMmsg;
                  struct IGRbsp_surface *surf;
                  IGRshort              *matrix_type;
                  IGRmatrix             matrix;
                  struct IGRline        *boreline;
                  IGRdouble             *dist;
                  IGRpoint              keypoint;
                  struct GRparms        *key_parm;
                  struct GRid           *window_id)
{
  IGRlong                   sts = OM_S_SUCCESS;

/*
  if(! window_id) { *EMmsg = EMS_I_InvalidArg; goto wrapup; }

  if((window_id->objid IS me->window_id.objid) &&
     (window_id->osnum IS me->window_id.osnum))
*/
  {
    sts = om$send(msg = message EMSgradata.EMkeypoint(
                    EMmsg,
                    surf,
                    matrix_type,
                    matrix,
                    boreline,
                    dist,
                    keypoint,
                    key_parm,
                    window_id),
                  mode = OM_e_wrt_message,
                  targetid = my_id);
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSvsgd.EMkeypoint")
  return(sts);
};

method EMdisplay(IGRlong                *EMmsg;
                 IGRboolean             owner_origin;
                 enum GRdpmode          *mode;
                 struct DP_information  *sp_info;
                 struct IGResbs         *bs_attr;
                 struct DPele_header    *ele_header;
                 IGRshort               *mx_type;
                 IGRmatrix              matrix;
                 IGRchar                *buffer;
                 IGRint                 buffer_size;
                 struct EMSpartolbasis  *partol;
                 IGRboolean             *display_done;
                 struct GRid            *window_id)
{
  IGRlong                   sts = OM_S_SUCCESS;

  if(! window_id) { *EMmsg = EMS_I_InvalidArg; goto wrapup; }

  if((window_id->objid IS me->window_id.objid) &&
     (window_id->osnum IS me->window_id.osnum))
  {
    sts = om$send(msg = message EMSgradata.EMdisplay(
                    EMmsg,
                    owner_origin,
                    mode,
                    sp_info,
                    bs_attr,
                    ele_header,
                    mx_type,
                    matrix,
                    buffer,
                    buffer_size,
                    partol,
                    display_done,
                    window_id),
                  mode = OM_e_wrt_message,
                  targetid = my_id);
  }
  else *display_done = TRUE;

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSvsgd.EMdisplay")
  return(sts);
};

end implementation EMSvsgd;
