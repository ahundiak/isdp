/*\
Name
    GRrealign_drawing_view

Description
    This method realigns a drawing view with another drawing view.

Arguments
    *msg              IGRlong              completion code
    *mod_env          struct GRmd_env      module environment
    *window_matrix    IGRdouble            window rotation matrix
    *dv_id            struct GRid          drawing view object id

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.
\*/
class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "grownmacros.h"
#include "vardef.h"
#include "bserr.h"

#define  MAETA    1.0e-15
#define  LENGTH   120

from GRreffile    import   GRinquireref;
from GRdvalign    import   GRdvalign_init;

method GRrealign_drawing_view ( IGRlong *msg; 
                                struct GRmd_env *mod_env;
                                IGRdouble *window_matrix; 
                                struct GRid *dv_id)
{
    IGRlong                 om_msg;
    IGRint                  i,j;
    IGRshort		    four = 4;
    IGRboolean              zero = FALSE;
    IGRint                  temp;
    IGRchar                 filename[LENGTH];
    IGRchar                 saveview[LENGTH];
    IGRchar                 scale[LENGTH];
    IGRshort                matrix_type;
    IGRpoint                direction[3];
    IGRpoint                point1;
    IGRpoint                point2;
    IGRpoint                point3;
    IGRpoint                point4;
    IGRpoint                origin1;
    IGRpoint                origin2;
    IGRpoint                prj_point;
    IGRvector               vector;
    IGRdouble               t;
    IGRdouble               radians;
    IGRmatrix               invmx;
    IGRmatrix               result_matrix;
    IGRmatrix               tmatrix;
    GRobjid                 objid;
    struct GRinquire_list   list[3];
    struct IGRline          line;
    struct IGRline          normal;
    struct IGRlbsys         lb1;
    struct IGRlbsys         lb2;
    struct GRid             my_GRid;
    struct GRid             my_dv_id;

    *msg = MSSUCC;
    filename[0] = '\0';
    saveview[0] = '\0';
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    /*
     *  Get the model file name and saved view name.
     */
    list[0].var = REFERENCE_FILE_NAME;
    list[0].var_ptr = filename;
    list[0].num_requested = LENGTH;

    list[1].var = SAVED_VIEW_NAME;
    list[1].var_ptr = saveview;
    list[1].num_requested = LENGTH;

    list[2].var = END_PARAM;
    list[2].var_ptr = NULL;
    list[2].num_requested = NULL;
         
    om_msg = GRcomponent_pass_fun ( msg, 
                                    message GRreffile.GRinquireref ( msg,
                                                                     mod_env,
                                                                     list,
                                                                     &temp,
                                                                     &zero,
                                                                     NULL),
                                    GR_DV_REFFILE, 
                                    my_id, 
                                    OM_Gw_current_OS);

    /*
     *  Get the scale.
     */
    om$send ( msg = message GRdrawview.GRget_drawview_scale ( msg,
                                                              mod_env,
                                                              scale, 
                                                              NULL), 
              targetid = my_id);

    /*
     *  Send a message to validate that the drawing views can be aligned.
     */
    om_msg = om$send ( msg = message GRdrawview.GRrealign_compare ( msg,
                                                                    mod_env, 
                                                                    &me->orientation, 
                                                                    filename, 
                                                                    saveview, 
                                                                    scale),
                       targetid = dv_id->objid,
                       targetos = dv_id->osnum);

    if (om_msg & *msg & 1) 
    {
        /*
         *  Generate the direction rotation matrix;
         */
        om$send (msg = message GRvg.GRgetgeom ( msg,
                                                &mod_env->md_env.matrix_type, 
                                                mod_env->md_env.matrix, 
                                                (IGRchar *)&lb1 ),
                 targetid = dv_id->objid,
                 targetos = dv_id->osnum);

        om$send (msg = message GRvg.GRgetgeom ( msg,
                                                &mod_env->md_env.matrix_type, 
                                                mod_env->md_env.matrix, 
                                                (IGRchar *)&lb2 ),
                 targetid = my_id);

        origin1[0] = lb1.matrix[3];
        origin1[1] = lb1.matrix[7];
        origin1[2] = lb1.matrix[11];
        origin2[0] = lb2.matrix[3];
        origin2[1] = lb2.matrix[7];
        origin2[2] = lb2.matrix[11];
   
        /*
         *  Remove translation from the matrices.
         */
        lb1.matrix[3] = lb1.matrix[7] = lb1.matrix[11] = lb2.matrix[3] = 
        lb2.matrix[7] = lb2.matrix[11] = 0.0;

        MAinvmx(msg, &four, lb1.matrix, invmx);
        MAmulmx(msg, &four, &four, &four, lb2.matrix, invmx, result_matrix);

        /*
         *  Call a routine to get the axis of rotation.
         */
        t = 1.0;
        tmatrix[0] = result_matrix[0];
        tmatrix[1] = result_matrix[1];
        tmatrix[2] = result_matrix[2];
        tmatrix[3] = result_matrix[4];
        tmatrix[4] = result_matrix[5];
        tmatrix[5] = result_matrix[6];
        tmatrix[6] = result_matrix[8];
        tmatrix[7] = result_matrix[9];
        tmatrix[8] = result_matrix[10];
        BSeigvec3x3 (tmatrix, t, &temp, direction, msg);

/******************************************************************
      printf ("The number of eigenvectors %d\n", temp);
      printf ("Eigenvectors: %g  %g  %g\n", direction[0][0], 
               direction[0][1], direction[0][2]);
*******************************************************************/

        if ((*msg == BSSUCC) && (temp == 1)) 
        {
            *msg = MSSUCC;
            radians = PI/2;
            point1[0] = point1[1] = point1[2] = 0.0;
            MAgrotmx (msg, direction, point1, &radians, tmatrix);
            GRis_matrix_equal (msg, tmatrix, result_matrix);

            if (!(*msg & 1)) 
            {
                radians = - PI/2;
                MAgrotmx (msg, direction, point1, &radians, tmatrix);
                GRis_matrix_equal (msg, tmatrix, result_matrix);
            }
        }
        else *msg = MSFAIL;

        if (om_msg & *msg & 1) 
        {
            /* 
             *  Project the origin of the drawing view onto the axis of 
             *  rotation.
             */
            point1[0] = point1[1] = point1[2] = 0.0;
            line.point1 = point1;
            line.point2 = (IGRdouble *)direction;
            MAptlnproj (msg, origin1, &line, prj_point, &t);

            /*
             *  Form a line normal to the folding line through the project 
             *  origin and in the plane of view.
             */
            normal.point1 = point3;
            normal.point2 = point4;
            MAlpfrln(msg, &line, prj_point, &window_matrix[8], &normal);

            for (i=0; i < 3; ++i) 
            {
                vector[i] = normal.point2[i] - normal.point1[i];
            }

            point2[0] = origin1[0] + vector[0];
            point2[1] = origin1[1] + vector[1];
            point2[2] = origin1[2] + vector[2];
            line.point1 = origin1;
            line.point2 = point2;
            MAptlnproj (msg, origin2, &line, prj_point, &t);

            MAidmx (msg, result_matrix);
            for (i=0, j=3; i < 3; ++i, j += 4) 
            {
                result_matrix[j] = prj_point[i] - origin2[i];
            }

            MAtypemx (msg, result_matrix, &matrix_type);
   
            om_msg = om$construct( osnum = mod_env->md_id.osnum, 
                                   classname = "GRdvalign",
                                   msg = message GRdvalign.GRdvalign_init
                                                            ( msg, 
                                                              dv_id,
                                                              &my_GRid,
                                                              vector),
                                   p_objid = &objid);

            if (om_msg & *msg & 1) 
            {
                om$send ( msg = message GRdvattach.GRget_drawing_view_id 
                                                            ( msg,
                                                              &my_dv_id), 
                          targetid = my_id);

                om_msg = om$send ( msg = message GRgraphics.GRxform 
                                                            ( msg, 
                                                              mod_env,
                                                              &matrix_type,
                                                              result_matrix,
                                                              &objid),
                                   targetid = my_dv_id.objid,
                                   targetos = my_dv_id.osnum);
            }
        }
    }

    return (om_msg);
}

/*\
Name
    GRrealign_compare

Description
    This method compares the informatin from one drawing view to its 
    information to see if the drawing views can be aligned.

Arguments
    *msg              IGRlong              completion code
    *mod_env          struct GRmd_env      module environment
    *orientation      IGRint               orientation
    *filename         IGRchar              model filename 
    *saveview         IGRchar              model save view
    *scale            IGRchar              scale string

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.
\*/
method GRrealign_compare ( IGRlong *msg;
                           struct GRmd_env *mod_env;
                           IGRint *orientation; 
                           IGRchar *filename;
                           IGRchar *saveview; 
                           IGRchar *scale)
{
    IGRlong                 om_msg;
    IGRboolean              zero = FALSE;
    IGRint                  temp;
    IGRchar                 myfilename[LENGTH];
    IGRchar                 mysaveview[LENGTH];
    IGRchar                 myscale[LENGTH];
    struct GRinquire_list   list[3];
    IGRint                  from_orient, to_orient;

    *msg = MSSUCC;
    myfilename[0] = '\0';
    mysaveview[0] = '\0';
    myscale[0] = '\0';

    /*
     *  Get the model file name and saved view name.
     */
    list[0].var = REFERENCE_FILE_NAME;
    list[0].var_ptr = myfilename;
    list[0].num_requested = LENGTH;

    list[1].var = SAVED_VIEW_NAME;
    list[1].var_ptr = mysaveview;
    list[1].num_requested = LENGTH;

    list[2].var = END_PARAM;
    list[2].var_ptr = NULL;
    list[2].num_requested = NULL;
         
    GRcomponent_pass_fun ( msg, 
                           message GRreffile.GRinquireref ( msg, 
                                                            mod_env, 
                                                            list, 
                                                            &temp,
                                                            &zero, 
                                                            NULL),
                           GR_DV_REFFILE,
                           my_id, 
                           OM_Gw_current_OS);

    /*
     *  Get the scale.
     */
    om_msg = om$send ( msg = message GRdrawview.GRget_drawview_scale 
                                                          ( msg,
                                                            mod_env, 
                                                            myscale, 
                                                            NULL), 
                       targetid = my_id);

    /*
     *  Compare the information.
     */
    *msg = MSFAIL;

    from_orient = me->orientation & GR_DV_VIEW_MASK;
    to_orient = *orientation & GR_DV_VIEW_MASK;
    
    if (((from_orient == 0) && (to_orient == 0)) ||
        (from_orient & to_orient))
    {
        if (!strcmp (myfilename, filename)) 
        {
            if (!strcmp (mysaveview, saveview)) 
            {
                if (!strcmp (myscale, scale)) 
                {
                    *msg = MSSUCC;
                }
            }
        }
    }    

    return (OM_S_SUCCESS);
}

/*\
Name
    GRis_matrix_equal

Description
    This function compares to matrices.

    *msg           IGRlong        return code
    a              IGRmatrix      matrix a
    b              IGRmatrix      matrix b
   
Return Values
    MSSUCC   -  is equal
    MSFAIL   -  is not equal
\*/
IGRint GRis_matrix_equal (msg, a, b)
    IGRlong     *msg;
    IGRmatrix   a;
    IGRmatrix    b;
{
    IGRint      i;
    IGRdouble   temp;

    *msg = MSSUCC;
    for (i=0; ((*msg & 1) && (i < 16)); ++i) 
    {
        temp = a[i] - b[i];
        if ((temp > MAETA) || (temp < (- MAETA))) 
            *msg = MSFAIL;
    }

    return (OM_S_SUCCESS);
}
end implementation GRdvattach;
