/* #######################    APOGEE COMPILED   ######################## */
/*
Method
        GRgencs.GRxform

Description
        This method transforms the coordinate system after adjusting the
        input transformation matrix so that any scale is filtered out.  The
        coordinate system scale is stored and maintained separately from
        other types of manipulations.  The origin of the coordinate system
        is transformed by the original input matrix so that the "translation"
        part of the transformation always takes place.  The transformed 
        origin is used to replace the origin obtained after transforming the
        local bounded system's matrix by the orthogonalized transformation
        matrix. This resulting matrix is posted back into the coordinate
        system's permanent format.

History
        mrm     08/03/88    creation
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

extern IGRboolean MAgrmscht(), MAoptsxform(), MAmulmx();

method GRxform (IGRlong         *msg;
                struct GRmd_env *mod;
                IGRshort        *matrix_type;
                IGRmatrix        matrix;
                GRobjid         *newobjid)
{
    IGRshort            i, rank;
    IGRlong             sts, npts;
    IGRdouble           vectors[9], o_vectors[9];
    IGRdouble           origin[3];
    IGRmatrix           omx;
    IGRchar            *absg;
    struct IGRlbsys    *lbs, xformed_lbs;
    struct GRpost_info  post_info;

    sts = OM_S_SUCCESS;

    if (*matrix_type != MAIDMX)
    {
        /*
         *  get the local bounded system geometry
         */

        GRgetabsg (msg, &mod->md_env.matrix_type, mod->md_env.matrix, &absg, i);

        if (!(*msg & 1))
        {
#ifdef DEBUG
            printf ("GRgencs.GRxform: GRgetabsg failed\n");
#endif
            goto finish;
        }

        lbs = (struct IGRlbsys *) absg;

        /*
         *  tranform cs origin
         */

        origin[0] = lbs->matrix[3];
        origin[1] = lbs->matrix[7];
        origin[2] = lbs->matrix[11];

        npts = 1;

        if (! MAoptsxform (msg, &npts, matrix_type, matrix, origin, origin))
        {
#ifdef DEBUG
            printf ("GRgencs.GRxform: MAoptsxform failed\n");
#endif
            goto finish;
        }

        /*
         *  adjust transformation matrix to orthogonalize out the scale
         */

        vectors[0] = matrix[0]; vectors[1] = matrix[1]; vectors[2] = matrix[2];
        vectors[3] = matrix[4]; vectors[4] = matrix[5]; vectors[5] = matrix[6];
        vectors[6] = matrix[8]; vectors[7] = matrix[9]; vectors[8] = matrix[10];

        i = 3;

        if (!MAgrmscht (msg, &i, &i, vectors, o_vectors, &rank))
        {
#ifdef DEBUG
            printf ("GRgencs.GRxform: MAgrmscht failed\n");
#endif
            goto finish;
        }

        omx[0] = o_vectors[0];
        omx[1] = o_vectors[1];
        omx[2] = o_vectors[2];
        omx[3] = matrix[3];
        omx[4] = o_vectors[3];
        omx[5] = o_vectors[4];
        omx[6] = o_vectors[5];
        omx[7] = matrix[7];
        omx[8] = o_vectors[6];
        omx[9] = o_vectors[7];
        omx[10] = o_vectors[8];
        omx[11] = matrix[11];
        omx[12] = matrix[12];
        omx[13] = matrix[13];
        omx[14] = matrix[14];
        omx[15] = matrix[15];

        /*
         *  transform the geometry
         */

        if (! MAlbxform (msg, lbs, omx, &xformed_lbs))
        {
#ifdef DEBUG
            printf ("GRgencs.GRxform: MAlbxform failed\n");
#endif
            goto finish;
        }

        xformed_lbs.matrix[3] = origin[0];
        xformed_lbs.matrix[7] = origin[1];
        xformed_lbs.matrix[11] = origin[2];

        /*
         *  post the transformed geometry
         */

        post_info.construct_flag = FALSE;

        sts = om$send (msg = message GRvg.GRpostabsg
                            (msg, mod, &post_info, (IGRchar *) &xformed_lbs,
                             newobjid),
                       targetid = my_id);
#ifdef DEBUG
        if (!(sts & *msg & 1))
        {
            printf ("GRgencs.GRxform: GRpostabsg failed\n");
        }
#endif
        /*
         *  delete geometry from cache
         */

        GRabsg_del_all ();
    }

    GR_NOTIFY_LISTENERS (msg, &sts, GR_GEOM_XFORMED);

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("GRgencs.GRxform failed\n");
    if (!(*msg & 1)) printf ("msg = %#x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRgencs;
