/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    The following function is used to create shell objects for the curves
    in a buffer (or a set of contiguous curve buffers - forming a composite
    curve).  If more than one curve-buffer is input, a composite curve shell
    object will also be created.
        Note:  A shell object is a transient object (created in the transient
    object space) which can be reused.  The caller should not delete these
    objects.

  BUGS

    No known bugs.

  HISTORY
    WBC          :  05/21/93  :  Creation
    V.Srinivas   :  15/08/96  :  Set correctly curve type and used 
                                 count of composite curves as argument
                                 to the function EMgettrshobj_byinx
                                 instead of hard coded 0 value.
                                 This is provided as a fix for TR#119524911

*/

class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "emsdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "EMSlcdef.h"
#include "EMSlc.h"
#include "emsedgedef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_EMSbsedge_class_id;

from GRgraphics import GRconstruct;


IGRlong EFget_curve_shell_obj(msg, numcv, cv, cvtype, cvsymb, cvattr,
                              mdenv_info, cvshobj, shellobj)

IGRlong             *msg;      /* Output:  return msg */
IGRint               numcv;    /* Input:   number of curves passed in */
struct IGRbsp_curve *cv;       /* Input:   array of structures containg the
                                           geometry of the curves */
IGRuchar            *cvtype;   /* Input:   array of curve types that corresponds
                                           to the array "cv" */
struct GRsymbology  *cvsymb;   /* Input:   array of curve symbologies that
                                           corresponds to the array "cv" */
struct IGResbc      *cvattr;   /* Input:   array of curve attributes (curve
                                           specific data) that corresponds to
                                           the array "cv" */
struct GRmdenv_info *mdenv_info; /* Input: module environment of the curves */
struct GRid         *cvshobj;  /* Output:  array of ids of the created shell
                                           objects that correspond to the curves
                                           in the array "cv"; the memory for
                                           this array is to be allocated by the
                                           caller and array should have the
                                           number of entries equal to the
                                           argument "numcv" */
struct GRid         *shellobj; /* Output:  A single shell id that contains
                                           either the id of a composite curve
                                           shell object (if numcv > 1) else
                                           its the same id that is returned in
                                           "cvshobj" */
{
    IGRuchar                           tmp_cvtype;
    IGRint                             objinx,
                                       i,
                                       j;
    IGRlong                            constmsg,
                                       msg_loc,
                                       stat_OM;
    GRclassid                          cvclass;
    GRspacenum                         transos;
    struct GRvg_construct              const_list;
    struct GRmd_env                    locmdenv;
    struct GRgraphics_GRconstruct_Msg  grconst_args;
    struct Root_connect_Msg            conn_args;
    OM_S_CHANSELECT                    chan_to_comps,
                                       chan_to_owners,
                                       chan_to_notification;
    OM_S_MESSAGE                       messg;

    IGRboolean EFget_classid_for_an_edge_type();
    IGRlong    EMgettrshobj_byinx();
    *msg = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;
    shellobj->objid = NULL_OBJID;

    /* For each input curve, a shell object is constructed.  If there is more
     * than one curve object, a composite curve is made out of them and this
     * shell object is returned along with the individual curve shell objects.
     * Otherwise, the single shell object itself is returned. This
     * These objects are lying in  the transient object space. 
     */
    for (i = 0; i < numcv; i++)
    {
     /* Composite curve type is illegal */
        if(cvtype[i] == EMcomposite_curve)
          continue;
        tmp_cvtype = cvtype[i];

        if( (cv[i].order == 2) && (!(cv[i].rational)) )
        {
            if (!EFisEdgeTypeLinear(tmp_cvtype))
            {
                /* there may be curves that have incorrect types,
                 * if the curve is order 2 and nonrational, based
                 * on the number of poles, we can set the curve type.
                 */

                if(cv[i].num_poles == 2)
                    tmp_cvtype = EMlinesegment;
                else
                    tmp_cvtype = EMlinestring;                 
            }
        }
        else if (cv[i].order > 2)
        {
            if (EFisEdgeTypeLinear(tmp_cvtype))
                tmp_cvtype = EMfreeform_curve;
        }

        stat_OM = EFget_classid_for_an_edge_type (&cvclass, tmp_cvtype);
        EMomerr_exit (stat_OM, ret_end);

         objinx = 0; 
        /* update cvtype[i] also if tmp_cvtype is changed */
        cvtype[i] = tmp_cvtype;

        for (j=0; j<i; j++) 
        {
            if (tmp_cvtype == cvtype[j])
                objinx++;
        }
 
        stat_OM = EMgettrshobj_byinx(&msg_loc, cvclass, objinx,
                                     &cvshobj[i]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);


    }
    transos = cvshobj[0].osnum;

    if (numcv > 1)
    {
        stat_OM = EMgettrshobj_byinx(&msg_loc, OPP_GRcompcurve_class_id,0,
                                     shellobj);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
        shellobj[0] = cvshobj[0];

    /* Initialize the object (posting the geometry(ies), symbology and the
     * graphic-attributes). The object is flagged as read-only and is not
     * put into the R-tree.  All objects that may be connected to the
     * notification channel are disconnected.
     */

    OM_BLOCK_MOVE(mdenv_info, &locmdenv.md_env, sizeof(struct GRmdenv_info));
    locmdenv.md_id.objid = NULL_OBJID;

    const_list.msg = &constmsg;
    const_list.env_info = &locmdenv;
    const_list.newflag = FALSE;
    const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | 
                             GRIS_READ_ONLY |
                             (numcv > 1 ? GR_RIGID_RELATIONSHIP : NULL);
    const_list.name = NULL;
    const_list.level = cvsymb->level;
    const_list.display = &cvsymb->display_attr;
    const_list.class_attr = (IGRchar *) cvattr;

    grconst_args.arglist = &const_list;

    stat_OM = om$make_message(classname = "GRgraphics", 
                              methodname = "GRconstruct",
                              size = sizeof (grconst_args),
                              p_arglist = &grconst_args, p_msg = &messg);
    EMomerr_exit (stat_OM, ret_end);
    for (i=0; i<numcv; i++)
    {
        const_list.geometry = (IGRchar *) &cv[i];

        stat_OM = om$send(msg = &messg,
                          targetid = cvshobj[i].objid, 
                          targetos = transos,
                          senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (constmsg), *msg, EMS_E_CurveError, ret_end);
    }

    if (numcv > 1)
    {
        const_list.properties &= ~GR_RIGID_RELATIONSHIP;
        stat_OM = om$send(msg = message GRgraphics.GRconstruct (&const_list),
                          targetid = shellobj->objid,
                          targetos = transos,
                          senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (constmsg), *msg, EMS_E_CurveError, ret_end);

        stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        EMomerr_exit (stat_OM, ret_end);

        stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
        EMomerr_exit (stat_OM, ret_end);

        conn_args.to_sel = chan_to_comps;
        conn_args.to_idx = 0;
        conn_args.fr_sel = chan_to_owners;
        conn_args.fr_os = transos;

        stat_OM = om$make_message(classname = "Root",
                                  methodname = "connect", 
                                  size = sizeof (conn_args),
                                  p_arglist = &conn_args,
                                  p_msg = &messg);
        EMomerr_exit (stat_OM, ret_end);

        for (i=0; i<numcv; i++)
        {
            conn_args.fr_objid = cvshobj[i].objid;
            conn_args.fr_idx = i;

            stat_OM = om$send(msg = &messg,
                              targetid = shellobj->objid,
                              targetos = transos,
                              senderid = cvshobj[i].objid);
            EMomerr_exit (stat_OM, ret_end);
        }
    }
    EMmake_chanselect (GRnotify_notification, &chan_to_notification);
    om$send(msg = message Root.wild_disconnect (chan_to_notification),
            targetid = shellobj->objid,
            targetos = shellobj->osnum,
            senderid = NULL_OBJID);
ret_end:

  return(stat_OM);
}

end implementation Root;
