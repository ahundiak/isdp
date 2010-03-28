/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        DYaux_cs_rotate

Synopsis
        IGRint DYaux_cs_rotate (msg, origin, handle, handle_norm, radius, curr_mod, cs_id)

        IGRlong            *msg;            return code
        IGRboolean         mode;            rotate continuously?
        IGRpoint           origin;          of rotation
        IGRpoint           handle;          used to define angle
        IGRpoint           handle_norm;     normal to the handle
        IGRdouble          *radius;         length of rb lines
        struct GRmd_env    *curr_mod;       current module
        struct GRid        *cs_id;          containing located object

Description
        This routine implements dynamics which rotates a object
        in either 1/4PI increments or continuously depending on 
        mode.
Notes

Return values
        IGRint  ()      MSSUCC - success
                        MSFAIL - failure

        IGRlong *msg    MSSUCC - success
                        MSFAIL - failure

History
	jhw	01/22/89	creation date (adapted from DYrotate)
        scw     07/08/92        ansi conversion
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "comndef.h"
#include "igrdef.h"
#include "msdef.h"
#include "grgs.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"

extern IGRboolean MA2ptdis(), MAunitvc(), MAgrotmx(), MAtrnmx();
extern IGRboolean MAwclsmx(), MAptsxform(), MAang2vc();
extern IGRboolean MAinvmx(), MAmulmx();

struct dyn_args
{
    IGRboolean          mode;           /* continuous or 90 deg increments */
    IGRdouble           radius;         /* radius of "rotation circle" */
    IGRdouble           wld_pts[12];    /* points defining angle in world */
    IGRdouble           lcl_pts[12];    /* points defining angle in local */
    IGRpoint            norm;
    struct GRid         dyn_obj;        /* id of object in dynamics */
    struct GRmd_env     dyn_mod;        /* module dynamics takes place in */
    struct GRmdenv_info trans;          /* combined module & transformation */
    struct DPele_header rb_elem;        /* rubber band lines defining angle */
};

IGRint DYaux_cs_rotate (msg, mode, origin, handle, handle_norm, radius, curr_mod, cs_id)

IGRlong            *msg;            /* return code */
IGRboolean         mode;            /* continuous rotate */
IGRpoint           origin;          /* of rotation */
IGRpoint           handle;          /* used to define angle */
IGRpoint           handle_norm;     /* normal to the handle */
IGRdouble          *radius;         /* length of rb lines */
struct GRmd_env    *curr_mod;       /* current module */
struct GRid        *cs_id;          /* pointer to the coordinate system*/

{
    IGRboolean          dyn_on;         /* is dynamics on? */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags */
    IGRint              DYaux_cs_rotate_dyn(); /* dynamics function */
    struct IGRdisplay   dis_att;        /* display attr for rotate line */
    struct IGRpolyline  rb_line;        /* rotate line to rubberband */
    struct dyn_args     rot_data;       /* arguments passed to DYrotate */

    /*
     *  if dynamics is off then exit
     */

    DPdynflags (msg, &inquire, &dyn_on, NULL);

    if (!dyn_on)
    {
        return (*msg = MSSUCC);
    }

    /*
     *  set up data for dynamics
     */
    rot_data.mode = mode;
    rot_data.wld_pts[0] = handle[0];
    rot_data.wld_pts[1] = handle[1];
    rot_data.wld_pts[2] = handle[2];
    rot_data.wld_pts[3] = origin[0];
    rot_data.wld_pts[4] = origin[1];
    rot_data.wld_pts[5] = origin[2];
    rot_data.norm[0] = handle_norm[0];
    rot_data.norm[1] = handle_norm[1];
    rot_data.norm[2] = handle_norm[2];
    rb_line.num_points = 3;
    rb_line.points = rot_data.wld_pts;
    dis_att.color = 2;
    dis_att.weight = 0;
    dis_att.style = 3;

    dp$build_dis_buffer (buffer = &rot_data.rb_elem,
                         type = IGRPY,
                         display_att = &dis_att,
                         geometry = &rb_line);

    rot_data.dyn_obj.osnum = cs_id->osnum;
    rot_data.dyn_obj.objid = cs_id->objid;
    rot_data.dyn_mod = *curr_mod;
    rot_data.dyn_mod.md_id.objid = NULL_OBJID;

    /*
     *  Project the handle to the length of the radius.
     */
    rot_data.wld_pts[0] = rot_data.wld_pts[0] - rot_data.wld_pts[3];
    rot_data.wld_pts[1] = rot_data.wld_pts[1] - rot_data.wld_pts[4];
    rot_data.wld_pts[2] = rot_data.wld_pts[2] - rot_data.wld_pts[5];

    if (! MAunitvc (msg, rot_data.wld_pts, rot_data.wld_pts))
    {
        return (*msg = MSFAIL);
    }

    rot_data.wld_pts[0] =
                     (rot_data.wld_pts[0] * *radius) + rot_data.wld_pts[3];
    rot_data.wld_pts[1] =
                     (rot_data.wld_pts[1] * *radius) + rot_data.wld_pts[4];
    rot_data.wld_pts[2] =
                     (rot_data.wld_pts[2] * *radius) + rot_data.wld_pts[5];

    rot_data.radius = *radius;
        
    /*
     *  invoke dynamics
     */
    dp$dynamics (dyn_fun = DYaux_cs_rotate_dyn,
                 information = &rot_data);

    return (*msg = MSSUCC);
}


#argsused
IGRint DYaux_cs_rotate_dyn (rot_data, dypoint, wld_to_vw, objects, num_objects,
                            buffers, num_buffers, in_dummy1, in_dummy2, 
                            in_dummy3, reset_dypoint, dyn_mod_info, out_dummy3)

struct dyn_args       *rot_data;
struct EX_button      *dypoint;
IGRdouble             *wld_to_vw;
struct GRid          **objects;
IGRint                *num_objects;
struct DPele_header  **buffers;
IGRint                *num_buffers;
IGRint                *in_dummy1;
IGRchar               *in_dummy2;
IGRchar               *in_dummy3;
IGRchar               *reset_dypoint;   /* is dypoint reset in this func? */
struct GRmdenv_info  **dyn_mod_info;
IGRchar               *out_dummy3;
{
    IGRshort    n;              /* index */
    IGRlong     nn;             /* index */
    IGRlong     msg;       	/* return codes */
    IGRdouble   angle[3];       /* rotation angle, sin, cos */
    IGRmatrix   rot_mx;         /* rotation matrix */
    IGRmatrix   t_matrix;       /* transformation matrix */
    IGRmatrix   vw_to_wld;      /* rotation matrix */
    IGRdouble   *angle_point;
    struct IGRline line1,line2; /* lines used for quarter PI rotate */

    if ( !rot_data->mode ) {
        line1.point1 = &(rot_data->wld_pts[3]);
        line1.point2 = rot_data->wld_pts;    
        line2.point1 = &(rot_data->wld_pts[3]);
        line2.point2 = rot_data->norm;

        /*
         * Project the dynamic point onto the nearest line.
         */
        GRptnlineproj ( &msg, 
                        &(line1), 
                        &(line2),
                        &(dypoint->x),
                        &(rot_data->wld_pts[9]) );
    }

    /*
     *  adjust the length of the second line to equal the input radius
     */
    rot_data->wld_pts[6] = dypoint->x - rot_data->wld_pts[3];
    rot_data->wld_pts[7] = dypoint->y - rot_data->wld_pts[4];
    rot_data->wld_pts[8] = dypoint->z - rot_data->wld_pts[5];

    if (! MAunitvc (&msg, &rot_data->wld_pts[6], &rot_data->wld_pts[6]))
    {
        return (MSFAIL);
    }

    rot_data->wld_pts[6] = 
        (rot_data->wld_pts[6] * rot_data->radius) + rot_data->wld_pts[3];

    rot_data->wld_pts[7] = 
        (rot_data->wld_pts[7] * rot_data->radius) + rot_data->wld_pts[4];

    rot_data->wld_pts[8] = 
        (rot_data->wld_pts[8] * rot_data->radius) + rot_data->wld_pts[5];

    /*
     *  get the view to world rotation matrix
     */
    n = 4;

    if (! MAtrnmx (&msg, &n, wld_to_vw, vw_to_wld))
    {
        return (MSFAIL);
    }

    /*
     *  build a world to local matrix
     */
    if (! MAwclsmx (&msg, &rot_data->wld_pts[3], vw_to_wld, t_matrix))
    {
        return (MSFAIL);
    }

    /*
     *  transform the points to the local system
     */
    nn = 4;

    if (! MAptsxform (&msg, &nn, t_matrix, rot_data->wld_pts,
                      rot_data->lcl_pts))
    {
        return (MSFAIL);
    }

    /*
     *  get the vectors defining the rotation angle
     */
    rot_data->lcl_pts[0]  -= rot_data->lcl_pts[3];
    rot_data->lcl_pts[1]  -= rot_data->lcl_pts[4];
    rot_data->lcl_pts[2]  =  0;

    angle_point = (rot_data->mode) ? &(rot_data->lcl_pts[6]) : &(rot_data->lcl_pts[9]);

    angle_point[0] -= rot_data->lcl_pts[3];
    angle_point[1] -= rot_data->lcl_pts[4];
    angle_point[2] =  0;

    /*
     *  if the first vector is zero, let it be the unit x vector
     */

    if ((rot_data->lcl_pts[0] == 0.0) && (rot_data->lcl_pts[1] == 0.0))
    {
        rot_data->lcl_pts[0] = 1.0;
    }

    /*
     *  get the angle between the two vectors
     */

    if (! MAang2vc (&msg, rot_data->lcl_pts, angle_point, angle))
    {
        return (MSFAIL);
    }
    
    /*
     *  get the rotation matrix
     */
    if (! MAgrotmx (&msg, &wld_to_vw[8], &rot_data->wld_pts[3], angle,
                    rot_mx))
    {
        return (MSFAIL);
    }

    /*
     *  combine located object's module matrix and the translation matrix
     */
    n = 4;
    MAmulmx (&msg, &n, &n, &n, rot_mx, rot_data->dyn_mod.md_env.matrix,
             rot_data->trans.matrix);

    MAtypemx (&msg, rot_data->trans.matrix, &rot_data->trans.matrix_type);
              *dyn_mod_info = &rot_data->trans;

    /*
     *  set up buffer pointers
     */
    *objects = &rot_data->dyn_obj;
    *buffers = &rot_data->rb_elem;
    *num_objects = 1;
    *num_buffers = 1;
    return (MSSUCC);
}


IGRint GRptnlineproj ( sts, line1, line2, point, proj_point )
    IGRlong          *sts;
    struct IGRline   *line1, *line2;
    IGRpoint        point, proj_point;
{
    IGRdouble   d1,d2,*p,t;
    IGRpoint    p1,p2;

    *sts = 1;

    /*
     * Project the input point onto both lines and determine 
     * which line is the closest.
     */
    MAptlnproj( sts, point, line1, p1, &t ); 
    MAptlnproj( sts, point, line2, p2, &t ); 
    MA2ptdis( sts, point, p1, &d1 );
    MA2ptdis( sts, point, p2, &d2 );

    /*
     * Set the project point to the point projected 
     * onto the nearest line.
     */
    p = (d1 < d2) ? p1 : p2;

    proj_point[0] = p[0];
    proj_point[1] = p[1];
    proj_point[2] = p[2];

    return (1);
}

end implementation CEO_GSLOCATE;
