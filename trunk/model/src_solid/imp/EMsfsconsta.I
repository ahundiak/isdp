/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsolid;

#include "EMSconstruct.h"
#include "godef.h"

#include "actparam.h"


extern OMuword OPP_EMSgencompsf_class_id;
extern OMuword OPP_EMSgenbs_class_id;

static IGRboolean aflag;
static GRspacenum osn;

/*History
    Jay Wallingford 7/??/91     Creation.
    DLB             9/09/91     Dont set surface's IS_ASSOC bit.
*/    

method EMconstruct_associative ( IGRlong *msg; 
                                 IGRushort opts;
                                 GRobjid old_objid;
                                 IGRint num_parents; 
                                 IGRchar *parent_info;
                                 IGRint type; 
                                 IGRchar *recomp_info;
                                 struct GRvg_construct *constr_list )
{
    IGRlong     msg_loc, om_msg = OM_S_SUCCESS;
    GRclassid   sfclass;
    IGRint      sftype;
    GRobjid     sfobjid;
    IGRshort    props = GRIS_ASSOCIATIVE;
    IGRshort    action = 0; /* ReSet the bit. - DLB 9/9/91*/
    IGRlong     EMgetsfclass();

    *msg = EMS_S_Success;

    /*
     * Get the charateristic surface.
     */
    switch (type)
    {
    case EMS_ASsolid_by_capping_surface:
    {
        IGRuint         param_type;
        union EMSparent_info    param;

        if (num_parents < 1)
        {
            *msg = EMS_E_Fail;
            om_msg = OM_E_ABORT;
            goto ret_end;
        }

        param_type = EMSgrid;

        om_msg = om$send ( msg = message EMSassoc.EMget_parent_info
                                                ( &msg_loc,
                                                  NULL,
                                                  num_parents,
                                                  parent_info,
                                                  &param_type,
                                                  &param ),
                           targetid = my_id);

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        sfobjid = param.grobj.grid.objid;
    }
        break;

    default:
        /*
         * Obtain the classid of my characteristic surface.
         */
        msg_loc = EMgetsfclass (type, &sfclass, &sftype);
        EMerr_hndlr (!msg_loc, *msg, EMS_E_InvalidCase, ret_end);

        /*
         * Construct a surface of this particular class and send it the
         * construct associative message. This would ensure that the characteristic
         * geometry has been created.
         */
 
        aflag = pwIsActivationOn();
        if (!aflag)
        {
        om_msg = om$construct ( classid = sfclass, 
                                msg = message EMSassoc.EMconstruct_associative 
                                                ( &msg_loc,
                                                  opts, 
                                                  old_objid, 
                                                  num_parents, 
                                                  parent_info, 
                                                  sftype, 
                                                  recomp_info,
                                                  constr_list ), 
                                 p_objid = &sfobjid );

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        }
        else
        {
           osn = pwGetActiveOs();

           om_msg = om$construct ( classid = sfclass,
                                   osnum = osn,
                                   p_objid = &sfobjid );

           om$send(msg = message EMSassoc.EMconstruct_associative
                                                ( &msg_loc,
                                                  opts,
                                                  old_objid,
                                                  num_parents,
                                                  parent_info,
                                                  sftype,
                                                  recomp_info,
                                                  constr_list ),
                                 senderid = NULL_OBJID,
                                 targetos = osn,    
                                 targetid = sfobjid ); 
        }

        /*
         * Make sure the associative surface has IS_ASSOC bit off.
         *  
         */
        om_msg = om$send ( msg = message GRgraphics.GRchgprops 
                                                ( &msg_loc, &action, &props ),
                           targetid = sfobjid );

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        break;
    }

    /*
     * The next step is to cap this characteristic surface off by sending
     * the cap yourself message. Ignore the caps that are degenerate.
     */
    om_msg = om$send ( msg = message EMSsfsolid.EMcap_thyself 
                                                ( &msg_loc,
                                                  constr_list, 
                                                  &sfobjid ), 
                            targetid = my_id );

    EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

ret_end:

  EMWRAPUP (*msg, om_msg, "EMSsfsolid.EMconstr");
  return (om_msg);
}

end implementation EMSsfsolid;
