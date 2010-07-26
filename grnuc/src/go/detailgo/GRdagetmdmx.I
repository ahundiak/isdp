/*\
Name
    GRget_model_matrix

Description
    This method is used to generate a matrix which defines the orientation
    of the drawing view with respect to the model.

Arguments
    *msg           IGRlong           return code
    *mod_env       struct GRmd_env   module environment
    no_scale_flag  IGRint            flag signifing whether to remove
                                    scale from the matrix.
    matrix         IGRmatrix         matrix defining model coordinates

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "madef.h"
#include "gocmacros.h"
#include "detaildef.h"

from  GRreffile   import   GRgetenvironment, GRgetscale;

method GRget_model_matrix ( IGRlong *msg; 
                            struct GRmd_env *mod_env;
                            IGRint no_scale_flag; 
                            IGRdouble *matrix)
{
    IGRlong           om_msg;
    IGRint            i, type;
    IGRshort          four = 4;
    IGRdouble         scale;
    IGRmatrix         scale_matrix;
    IGRmatrix         tmatrix;
    IGRmatrix         mx;
    struct GRmd_env   new_env;
    struct IGRlbsys   *absgptr;
    struct GRid       id;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;

    /*  Find out if there is a reference file attachment as one of the
     *  components.
     */

    id.objid = NULL_OBJID;
    om_msg = om$send(msg = message GRdvattach.GRget_component_id(msg,
                           GR_DV_REFFILE, 1, &id, &type),
                     targetos = OM_Gw_current_OS,
                     targetid = my_id);
    if ( !(om_msg&1) )
       goto wrapup;


    if (id.objid != NULL_OBJID)
    {
        om_msg = GRcomponent_pass_fun ( msg,
                                        message GRreffile.GRgetenvironment 
                                                    (msg, mod_env, &new_env), 
                                        GR_DV_REFFILE, 
                                        my_id, 
                                        OM_Gw_current_OS);
        if (no_scale_flag) 
        {
            om_msg = GRcomponent_pass_fun ( msg,
                                            message GRreffile.GRgetscale 
                                                    (msg, &scale),
                                            GR_DV_REFFILE, 
                                            my_id, 
                                            OM_Gw_current_OS);

            MAidmx(msg, scale_matrix);
            scale_matrix[0] = scale_matrix[5] = scale_matrix[10] = 1.0/scale;
            MAmulmx ( msg, 
                      &four, 
                      &four, 
                      &four, 
                      scale_matrix, 
                      new_env.md_env.matrix, 
                      matrix);
        }
        else for (i=0; i < 16; ++i) matrix[i] = new_env.md_env.matrix[i];
    }
    else 
    {
        GRgetabsg ( msg, 
                    &mod_env->md_env.matrix_type,
                    mod_env->md_env.matrix, 
                    (IGRchar **)&absgptr, 
                    i);
      
        for (i = 0; i < 16; ++i) tmatrix[i] = absgptr->matrix[i];
        tmatrix[3] = tmatrix[7] = tmatrix[11] = tmatrix[12] = 
        tmatrix[13] = tmatrix[14] = 0.0;
        tmatrix[15] = 1.0;

        for (i=0; i < 16; ++i) mx[i] = 0.0;

        mx[15] = 1.0;

/*      switch (me->orientation)
        {
*/

        if (me->orientation & GR_DV_TOP)
        {
            mx[0] = mx[5] = mx[10] = mx[15] = 1.0;
        }
        else if (me->orientation & GR_DV_BOTTOM)
        {
            mx[5] = mx[10] = -1.0;
            mx[0] = 1.0;
        }
        else if (me->orientation & GR_DV_FRONT)
        {
            mx[9] = -1.0;
            mx[0] = mx[6] = 1.0;
        }
        else if (me->orientation & GR_DV_BACK)
        {
            mx[0] = -1.0;
            mx[6] = mx[9] = 1.0;
        }
        else if (me->orientation & GR_DV_LEFT)
        {
            mx[1] = mx[8] = -1.0;
            mx[6] = 1.0;
        }
        else if (me->orientation & GR_DV_RIGHT)
        {
            mx[1] = mx[6] = mx[8] = 1.0;
        }
        else if (me->orientation & GR_DV_ISO)
        {
/*
            mx[8] = -0.707;
	    mx[9] = -0.408;
	    mx[10] = 0.0;
*/
		mx[0] =  0.707106781186548;
		mx[1] =  0.707106781186548;
		mx[4] = -0.408248290463863;
		mx[5] =  0.408248290463863;
		mx[6] =  0.816496580927726;
		mx[8] =  0.577350269189626;
		mx[9] = -0.577350269189626;
		mx[10]=  0.577350269189626;
        }

        MAmulmx (msg, &four, &four, &four, tmatrix, mx, matrix);
        matrix[3] = absgptr->matrix[3];
        matrix[7] = absgptr->matrix[7];
        matrix[11] = absgptr->matrix[11];
    }

  wrapup:

    return(om_msg);
}
end implementation GRdvattach;
