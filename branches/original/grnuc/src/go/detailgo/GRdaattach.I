/*
Name
    GRattach_model

Description
    This method attaches a model to the drawing view.

Arguments
    *msg              long              return code
    *mod_env          struct GRmd_env   module environment
    *filename         char              model file name
    *saveview_name    char              model save view name
    graphic_props     int               graphic properties
    reference_props   int               reference file properties
    level             char              reference file level
    *display          struct IGRdisplay reference file display info
                                          
Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
*/
class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

from GRdvalign import GRdvalign_pass_msg;

extern OMuword EX_dup_os_occured;

method GRattach_model ( long *msg; 
                        struct GRmd_env *mod_env; 
                        char *filename; 
                        char *saveview_name; 
                        int graphic_props; 
                        int reference_props;
                        IGRshort level; 
                        struct IGRdisplay *display)
{
    long                  om_msg, ret_msg;
    int                   i;
    int                   size;
    OM_S_CHANSELECT       chansel;
    struct GRrf_info      ref_info;
    struct IGRlbsys       lb;
    struct IGRlbsys       *absgptr;
    struct GRvg_construct const_list;
    struct GRid           ref_id;
    struct EX_button      window_btn;
    IGRmatrix             window_matrix;
    struct GRhesym        hesym;
    struct IGRdisplay     display_tmp;

    *msg = MSSUCC;
    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRnotify.notification";

    /*
     * KLUDGE: Set a global flag indicating that a dup os attachment
     *         has not occurred. This will be check after the construct.
     *         In the future construct should return OM_I_DUPLICATE_OS.
     */
    EX_dup_os_occured = 0;

    GRgetabsg ( msg, 
                &mod_env->md_env.matrix_type, 
                mod_env->md_env.matrix, 
                (IGRchar **)&absgptr, 
                i );

    ref_info.prism_classname   = NULL;
    ref_info.description       = NULL;
    ref_info.clip_poly         = NULL;
    ref_info.filename          = filename;
    ref_info.named_view        = saveview_name;

    size = om$dimension_of(varray = me->scale);

    ref_info.scale = (size) ? me->scale : NULL;
    ref_info.ref_properties = (unsigned int *)&reference_props;

    /*
     *  Build construct arguments.
     */
    const_list.msg = msg;
    const_list.newflag = FALSE;
    const_list.env_info = mod_env;
    const_list.properties = graphic_props;
    const_list.geometry = (char *)&lb;
    const_list.level = level;
    const_list.class_attr = (char *)&ref_info;
    const_list.name = NULL;

    /* the display depends on the visible edge symbology */
    gr$get_visible_edge_sym ( buffer = &hesym );
    if ((hesym.flags & DPB_USE_ORIG_COLOR) &&
        (hesym.flags & DPB_USE_ORIG_WEIGHT) &&
        (hesym.flags & DPB_USE_ORIG_STYLE))
      const_list.display = display;
    else
    {
      display_tmp = *display;      
      const_list.display = &display_tmp;
      if (!(hesym.flags & DPB_USE_ORIG_COLOR))
        display_tmp.color = hesym.color;
      if (!(hesym.flags & DPB_USE_ORIG_STYLE))
        display_tmp.style = hesym.style;
      if (!(hesym.flags & DPB_USE_ORIG_WEIGHT))
        display_tmp.weight = hesym.weight;
      reference_props |= GROVERRIDE_SYMBOLOGY;
    }

    for (i=0; i < 16; ++i) lb.matrix[i] = absgptr->matrix[i];

    /*
     *  The diagonal points have no meaning when a clip polygon is
     *  defined or a saved view was defined or a clip polygon was
     *  specified.
     */
    lb.diag_pt1[0] = lb.diag_pt1[1] = lb.diag_pt1[2] = 
        ((double)GRDGNLIMITS_MIN_D + 1.0);
    lb.diag_pt2[0] = lb.diag_pt2[1] = lb.diag_pt2[2] = 
        ((double)GRDGNLIMITS_MAX_D - 1.0);

    /*
     *  Construct the reference file object.
     */   
    ref_id.osnum = mod_env->md_id.osnum;
    om_msg = om$construct ( osnum = mod_env->md_id.osnum,
                            classname = "GRreffile", 
                            msg = message GRgraphics.GRconstruct(&const_list),
                            p_objid = &ref_id.objid );


    if (om_msg & *msg & 1) 
    { 
        /*
         * Connect the reference file to the drawing view attachment.
         */
        om_msg = om$send (msg = message GRdrawview.GRcomponent_add( msg,
                                                                    mod_env, 
                                                                    &ref_id, 
                                                                    GR_DV_REFFILE),
                          targetid = my_id);

        /*
         * Modify the reference file's clipping polygon so it aligns with 
         * the window of the last point.
         */
        size = sizeof(struct EX_button);
        gr$get_last_point ( msg = &ret_msg,
                            sizbuf = &size,
                            buffer = &window_btn,
                            nret = &size );
        if ( ret_msg & 1 )
        {
            GRget_window_matrix ( &ret_msg,
                                  window_btn.osnum,
                                  window_btn.objid,
                                  window_matrix,
                                  NULL );
            if ( ret_msg & 1 )
            {
                GRformdvprism ( &ret_msg, 
                                mod_env, 
                                window_matrix, 
                                &ref_id );
            }
        }

        om_msg = om$send (msg = message GRdvalign.GRdvalign_pass_msg ( msg, OPPmargs),
                          p_chanselect = &chansel);

        me->orientation = 0;

    }

    if ((om_msg & *msg & 1) && EX_dup_os_occured)
    {
        om_msg = OM_I_DUPLICATE_OS;
    }

    return (om_msg);
}
end implementation GRdvattach;
