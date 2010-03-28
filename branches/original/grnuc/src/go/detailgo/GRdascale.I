/*\
Name
    GRscale_drawing_view

Description
    This method scales a drawing view.  The drawing view scale is replaced
    by the new drawing view scale.

Arguments
    *msg           IGRlong           return code
    *mod_env       struct GRmd_env   module environment
    *flag          IGRint            if 0 scale about origin
                                    if 1 scale about point
    *scale         IGRchar           scale string
    point          IGRpoint          point to scale about

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
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
#include "csdef.h"

#define SCALE_ABOUT_ORIGIN    0
#define SCALE_ABOUT_POINT     1

from GRreffile import GRgetenvironment, GRaltscale;
from GRdvalign import GRdvalign_pass_msg;
from GRgencs   import GRcssetscale;
from GRtext    import GRreplace_text;

method GRscale_drawing_view ( IGRlong *msg;
                              struct GRmd_env *mod_env;
                              IGRint *flag;
                              IGRchar *scale;
                              IGRpoint point)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            i;
    IGRshort          four = 4;
    IGRint            ref_exist;
    IGRshort          text_length;
    IGRshort          matrix_type;
    IGRdouble         scale_vc[4];
    IGRmatrix         result_matrix;
    IGRmatrix         inv_matrix;
    IGRmatrix         scale_matrix;
    IGRmatrix         old_scale_matrix;
    IGRpoint          origin;
    GRobjid           objid;
    OM_S_CHANSELECT   notify_chansel;
    struct GRmd_env   ref_env;
    struct GRid       my_GRid;
    struct IGRlbsys   *absgptr;
/*
    IGRdouble         tempd;
    struct IGRlbsys   lb;
*/

    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    notify_chansel.type = OM_e_name;
    notify_chansel.u_sel.name = "GRnotify.notification";

    if (*flag == SCALE_ABOUT_POINT) 
    {
      origin[0] = point[0];
      origin[1] = point[1];
      origin[2] = point[2];
    }
    else 
    {
        GRgetabsg ( msg, 
                    &mod_env->md_env.matrix_type, 
                    mod_env->md_env.matrix, 
                    (IGRchar **)&absgptr, 
                    i);

        origin[0] = absgptr->matrix[3];
        origin[1] = absgptr->matrix[7];
        origin[2] = absgptr->matrix[11];
    }
    
    ret_msg = MSFAIL;
    om_msg = GRcomponent_pass_fun ( msg, 
                                    message GRreffile.GRgetenvironment 
                                                    ( &ret_msg,
                                                      mod_env, 
                                                      &ref_env ), 
                                    GR_DV_REFFILE, 
                                    my_id, 
                                    OM_Gw_current_OS);

    if (om_msg & *msg & ret_msg & 1) 
    {
        /*
         *  A reference exists; get the new scale matrix.
         */
        ref_exist = TRUE;
        om_msg = GRmodel_scale ( msg, 
                                 &mod_env->md_id.osnum,
                                 &ref_env.md_id.osnum,
                                 scale,
                                 scale_matrix );

        if (!(om_msg & *msg & 1)) 
        {
            *msg = MSFAIL;
            goto quit;
        }
                   
    }
    else 
    {
        /*
         *  A reference does not exist; verify that the string is valid.
         */
        ref_exist = FALSE;
        om_msg = GRmodel_scale ( msg, 
                                 &mod_env->md_id.osnum,
                                 &mod_env->md_id.osnum,
                                 scale,
                                 scale_matrix );

        if (!(om_msg & *msg & 1)) 
        {
            *msg = MSFAIL;
            goto quit;
        }
                   
    }

    if (om_msg & *msg & 1) 
    {
        if ( om$dimension_of(varray = me->scale)) 
        {
            if (ref_exist) 
            {
                /*
                 *  If the attachment already was attached with a scale
                 *  factor, the inverse of this matrix must be applied
                 *  before the attachment's new scale is correct.
                 */
                om_msg = GRmodel_scale ( msg,   
                                         &mod_env->md_id.osnum, 
                                         &ref_env.md_id.osnum,
                                         me->scale,
                                         old_scale_matrix );
            }
            else 
            {
                om_msg = GRmodel_scale ( msg, 
                                         &mod_env->md_id.osnum,
                                         &mod_env->md_id.osnum,
                                         me->scale,
                                         old_scale_matrix );
            }

            if (om_msg & *msg & 1) 
            {
                MAinvscmx(msg, old_scale_matrix, inv_matrix);
                MAmulmx(msg, &four, &four, &four, scale_matrix, inv_matrix, result_matrix);
            }
        }
        else for (i=0; i < 16; ++i) result_matrix[i] = scale_matrix[i];

        if (om_msg & *msg & 1) 
        {
            scale_vc[0] = result_matrix[0];
            scale_vc[1] = result_matrix[5];
            scale_vc[2] = result_matrix[10];
            scale_vc[3] = 1.0;
            MAgscamx (msg, mod_env->md_env.matrix, origin, scale_vc, result_matrix);
            MAtypemx (msg, result_matrix, &matrix_type);

            if (*flag == SCALE_ABOUT_POINT) 
            {
                /*
                 *  Transform the drawing view geometry.
                 */
                om$send ( mode = OM_e_wrt_message,
                          msg = message GRlbsys.GRxform ( msg, 
                                                          mod_env, 
                                                          &matrix_type, 
                                                          result_matrix, 
                                                          &objid ),
                          targetid = my_id);
            }

            /*
             *  Transform the reference file and the coordinate system.
             */
            GRcomponent_pass_fun ( msg, 
                                   message GRreffile.GRaltscale ( msg,
                                                                  mod_env,
                                                                  &matrix_type,
                                                                  result_matrix,
                                                                  &objid,
								  scale), 
                                   GR_DV_REFFILE, 
                                   my_id, 
                                   OM_Gw_current_OS);

            GRcomponent_pass_fun ( msg, 
                                   message GRgraphics.GRxform ( msg,
                                                                mod_env,
                                                                &matrix_type,
                                                                result_matrix,
                                                                &objid ), 
                                   GR_DV_CS, 
                                   my_id, 
                                   OM_Gw_current_OS);

            if (*flag == SCALE_ABOUT_POINT) 
            {
                /*
                 *  Delete the scale text, and name text.
                 */
                om_msg = om$send ( msg = message GRdrawview.GRcomponent_delete
                                                        ( msg,
                                                          mod_env,
                                                          GR_DV_TEXTNAME | GR_DV_TEXTSCALE),
                                   targetid = my_id);
            }
            else 
            {
                /*
                 *  Translate the scale text and the name text.
                 */
/*
            om_msg = GRcomponent_pass_fun (msg, 
                     message GRvg.GRgetgeom (msg, 
                     &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                     &lb), GR_DV_TEXTSCALE, my_id, 
                     OM_Gw_current_OS);

            MAidmx(msg, result_matrix);
            tempd = lb.matrix[3] - origin[0];
            result_matrix[3] = tempd * scale_vc[0] - tempd;
            tempd =  lb.matrix[7] - origin[1];
            result_matrix[7] = tempd * scale_vc[1] - tempd;
            tempd = lb.matrix[11] - origin[2];
            result_matrix[11] = tempd * scale_vc[2] - tempd;
            MAtypemx (msg, result_matrix, &matrix_type);

            om_msg = GRcomponent_pass_fun (msg, 
                     message GRgraphics.GRxform (msg, mod_env, 
                     &matrix_type, result_matrix, &objid), 
                     GR_DV_TEXTSCALE, my_id, OM_Gw_current_OS);

            om_msg = GRcomponent_pass_fun (msg, 
                     message GRvg.GRgetgeom (msg, 
                     &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                     &lb), GR_DV_TEXTNAME, my_id, 
                     OM_Gw_current_OS);

            MAidmx(msg, result_matrix);
            tempd = lb.matrix[3] - origin[0];
            result_matrix[3] = tempd * scale_vc[0] - tempd;
            tempd =  lb.matrix[7] - origin[1];
            result_matrix[7] = tempd * scale_vc[1] - tempd;
            tempd = lb.matrix[11] - origin[2];
            result_matrix[11] = tempd * scale_vc[2] - tempd;
            MAtypemx (msg, result_matrix, &matrix_type);

            om_msg = GRcomponent_pass_fun (msg, 
                     message GRgraphics.GRxform (msg, mod_env, 
                     &matrix_type, result_matrix, &objid), 
                     GR_DV_TEXTNAME, my_id, OM_Gw_current_OS);
*/  
            }
         
            if (om_msg & *msg & 1) 
            {
                /*
                 *  Change the drawing view scale string.
                 */
                text_length = strlen(scale);
                om$vla_set_dimension(varray = me->scale, size = text_length + 1);
                strcpy(me->scale, scale);

                if (*flag == SCALE_ABOUT_ORIGIN) 
                {
                    /*
                     *  Change the drawing view scale text.
                     */
                    om_msg = GRcomponent_pass_fun(msg, 
                                                  message GRtext.GRreplace_text 
                                                         ( msg,
                                                           mod_env, 
                                                           text_length,
                                                           (IGRuchar *)scale ), 
                                                  GR_DV_TEXTSCALE, 
                                                  my_id, 
                                                  OM_Gw_current_OS);
                }

                /*
                 *  Update the scale in the drawing view coordinate system.
                 */
                scale_vc[0] = scale_matrix[0];
                scale_vc[1] = scale_matrix[5];
                scale_vc[2] = scale_matrix[10];
                om_msg = GRcomponent_pass_fun ( msg,
                                                message GRgencs.GRcssetscale 
                                                                ( msg, 
                                                                  CS_ABSOLUTE, 
                                                                  scale_vc ),
                                                GR_DV_CS, 
                                                my_id, 
                                                OM_Gw_current_OS );

                if (*flag == SCALE_ABOUT_ORIGIN) 
                {
                    /*
                     *  Change the scale of all associated drawing views.
                     */
                    om_msg = om$send ( msg = message GRdvalign.GRdvalign_pass_msg
                                                                ( msg, OPPmargs),
                                       p_chanselect = &notify_chansel);
                }
                else 
                {
                    /*
                     *  Drop the drawing view alignment.
                     */
                    om_msg = om$send ( msg = message GRdrawview.GRdrop_alignment 
                                                                ( msg ),
                                       targetid = my_id);
                }
            }
            GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_XFORMED);
        }
    }

quit:

    return (om_msg);
}
end implementation GRdvattach;
