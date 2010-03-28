/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRget_drawview_scale

Description
    This method returns the scale of the drawing view.

Arguments
    *msg           IGRlong           return code
    *mod_env       struct GRmd_env   module envrionment
    *scale_string  IGRchar           scale string
    *scale         IGRdouble         x,y,z scale values

Notes
    Either scale_string or scale can be NULL.
   
Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure

History
    Gray Winn      08/04/88    Creation Date
\*/

class implementation GRdvattach;

#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "grimport.h"
#include "OMerrordef.h"
#include "madef.h"
#include "gocmacros.h"
#include "detaildef.h"
#include "OMmacros.h"

from GRreffile    import   GRgetenvironment;

method GRget_drawview_scale ( IGRlong *msg; 
                              struct GRmd_env *mod_env;
                              IGRchar *scale_string; 
                              IGRdouble *scale)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRmatrix         scale_matrix;
    struct GRmd_env   ref_env;

    *msg = MSSUCC;
    if (scale_string) 
    {
        if (om$dimension_of(varray = me->scale)) 
            strcpy(scale_string, me->scale);
        else 
            ex$message(msgnumb = GR_I_11, buff = scale_string);
    }

    if (scale) 
    {
        ret_msg = MSFAIL;
        om_msg = GRcomponent_pass_fun ( msg,
                                        message GRreffile.GRgetenvironment 
                                                    ( &ret_msg, 
                                                      mod_env, 
                                                      &ref_env), 
                                        GR_DV_REFFILE, 
                                        my_id, 
                                        OM_Gw_current_OS);

        if (om$dimension_of(varray = me->scale)) 
        {
            if (om_msg & *msg & ret_msg &1) 
            {
                om_msg = GRmodel_scale( msg, 
                                        &mod_env->md_id.osnum,
                                        &ref_env.md_id.osnum, 
                                        me->scale, 
                                        scale_matrix);

                if (!(om_msg & *msg & 1)) 
                {
                    *msg = MSFAIL;
                    goto quit;
                }
                   
            }
            else 
            {
                om_msg = GRmodel_scale( msg, 
                                        &mod_env->md_id.osnum,
                                        &mod_env->md_id.osnum, 
                                        me->scale, 
                                        scale_matrix);

                if (!(om_msg & *msg & 1)) 
                {
                    *msg = MSFAIL;
                    goto quit;
                }
                   
            }

            scale[0] = scale_matrix[0];
            scale[1] = scale_matrix[5];
            scale[2] = scale_matrix[10];
        }
        else scale[0] = scale[1] = scale[2] = 1.0;
   }

quit:

   return(OM_S_SUCCESS);
}
end implementation GRdvattach;
