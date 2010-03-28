/*
Name
        DYrotate

Synopsis
        IGRint DYrotate (msg, caller_id, caller_os, origin, handle, radius,
                         curr_mod, gschan, event)

        IGRlong            *msg;            return code
        GRobjid             caller_id;      caller id
        OMuword             caller_os;      caller's object space
        struct EX_button   *origin;         of rotation
        struct EX_button   *handle;         used to define angle
        IGRdouble          *radius;         length of rb lines; 0 -> calculate
        struct GRmd_env    *curr_mod;       current module
        OM_S_CHANSELECT    *gschan;         channel located containing object
        struct GRevent     *event;          containing located object

Description
        This routine implements dynamics for the Rotate by 3 Points
        command.  The indicated object will be dynamically displayed
        as rotating around the input origin by an angle defined by the
        input handle and the cursor position.

Notes
        The input arguments gschan and event are used to determine what
        object to drag.  If not NULL, gschan is expected to point to a
        channel containing the results of a call to gr$gslocate.  If gschan
        is NULL, then event is expected to point to an event with the
        information about located_object[0] filled in, such as the
        accept event from lc$locate.

        The temporary copy, or clone, is created in the current module space
        as defined in the dpb.  A NULL_OBJID is placed in the module
        environment structure to indicate to the graphics object methods that
        no R-tree manipulations are to be performed.

Return values
        IGRint  ()      MSSUCC - success
                        MSFAIL - failure

        IGRlong *msg    MSSUCC - success
                        MSFAIL - failure

History
        mrm     07/18/86    creation
                03/09/87    include file revision
                08/04/87    convert points to a local coordinate system before
                            defining angle (fix for iso-type views)
                11/13/87    call GRxform since GRtform no longer exists
                08/12/88    use display dynamics; allow event to specify
                            object to rotate
	DLB     10/25/91    Pass *short to MA routines instead of *int - SUN.
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

from GRgraphics import GRcopy, GRdelete, GRxform;

extern IGRboolean MA2ptdis(), MAunitvc(), MAgrotmx(), MAtrnmx();
extern IGRboolean MAwclsmx(), MAptsxform(), MAang2vc();
extern IGRboolean MAinvmx(), MAmulmx();

struct dyn_args
{
    IGRboolean          invert;         /* invert previous mx? if error no */
    IGRboolean          mode;           /* copy or display dynamics */
    IGRmatrix           old_tmx;        /* last transformation matrix */
    IGRdouble           radius;         /* radius of "rotation circle" */
    IGRdouble           wld_pts[9];     /* points defining angle in world */
    IGRdouble           lcl_pts[9];     /* points defining angle in local */
    struct GRid         dyn_obj;        /* id of object in dynamics */
    struct GRmd_env     dyn_mod;        /* module dynamics takes place in */
    struct GRmdenv_info trans;          /* combined module & transformation */
    struct DPele_header rb_elem;        /* rubber band lines defining angle */
    struct IGRplane     plane;          /* plane to rotate in */
};

IGRint DYrotate (msg, caller_id, caller_os, origin, handle, radius, curr_mod,
                 gschan, event)

IGRlong            *msg;            /* return code */
GRobjid             caller_id;      /* caller id */
OMuword             caller_os;      /* caller's object space */
struct EX_button   *origin;         /* of rotation */
struct EX_button   *handle;         /* used to define angle */
IGRdouble          *radius;         /* length of rb lines; 0 -> calculate */
struct GRmd_env    *curr_mod;       /* current module */
OM_S_CHANSELECT    *gschan;         /* channel located containing object */
struct GRevent     *event;          /* containing located object */

{
    IGRboolean          dyn_on;         /* is dynamics on? */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags */
    IGRint              DYrotate_dyn(); /* dynamics function */
    IGRint              size;           /* for dpb call */
    IGRlong             sts;            /* function return code */
    struct GRid         caller;         /* caller structure */
    struct GRobj_env    obj_info;       /* of object being cloned */
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
     *  get info about the object going into dynamics
     */

    if (gschan)
    {
        caller.objid = caller_id;
        caller.osnum = caller_os;

        sts = GRgsget_simple_object (msg, &caller, gschan, &obj_info);

        if (!(sts & *msg & 1))
        {
            return (*msg = MSSUCC);
        }
    }
    else
    {
        obj_info.obj_id = event->located_object[0].located_obj;
        obj_info.mod_env = event->located_object[0].module_info;
    }

    /*
     *  set up data for dynamics
     */

    MAidmx (msg, rot_data.old_tmx);
    rot_data.invert = FALSE;
    rot_data.wld_pts[0] = handle->x;
    rot_data.wld_pts[1] = handle->y;
    rot_data.wld_pts[2] = handle->z;
    rot_data.wld_pts[3] = origin->x;
    rot_data.wld_pts[4] = origin->y;
    rot_data.wld_pts[5] = origin->z;
    rb_line.num_points = 3;
    rb_line.points = rot_data.wld_pts;
    dis_att.color = 2;
    dis_att.weight = 0;
    dis_att.style = 3;

    dp$build_dis_buffer (buffer = &rot_data.rb_elem,
                         type = IGRPY,
                         display_att = &dis_att,
                         geometry = &rb_line);

    /*
     *  check dynamics mode
     */

    size = sizeof (IGRboolean);

    sts = gr$get_dynamics_copy_flag (msg = msg, sizbuf = &size,
                                     buffer = &rot_data.mode, nret = &size);

    /*
     *  set up dynamic object
     */

    if (rot_data.mode == COPY_DYNAMICS)
    {
        rot_data.dyn_mod = *curr_mod;
        rot_data.dyn_mod.md_id.objid = NULL_OBJID;
        rot_data.dyn_obj.osnum = curr_mod->md_id.osnum;
        sts = om$send (msg = message GRgraphics.GRcopy
                            (msg, &obj_info.mod_env,
                             &rot_data.dyn_mod, &rot_data.dyn_obj.objid),
                       senderid = caller_id,
                       targetid = obj_info.obj_id.objid,
                       targetos = obj_info.obj_id.osnum);

        if (!(sts & *msg & 1))
        {
            return (*msg = MSFAIL);
        }
    }
    else
    {
        rot_data.dyn_obj.osnum = obj_info.obj_id.osnum;
        rot_data.dyn_obj.objid = obj_info.obj_id.objid;
        rot_data.dyn_mod = obj_info.mod_env;
        rot_data.dyn_mod.md_id.objid = NULL_OBJID;
    }        

    /*
     *  if radius is zero (first time the function is called for a particular
     *  element) get a radius, otherwise project the handle to the previously
     *  defined radius
     */

    if (*radius == 0.0)
    {
        if (! MA2ptdis (msg, rot_data.wld_pts, &rot_data.wld_pts[3], radius))
        {
            return (*msg = MSFAIL);
        }
    }
    else
    {
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
    }

    rot_data.radius = *radius;
        
    /*
     *  invoke dynamics
     */

    dp$dynamics (dyn_fun = DYrotate_dyn,
                 information = &rot_data);

    if (rot_data.mode == COPY_DYNAMICS)
    {
        /*
         *  delete dynamic object
         */

        sts = om$send (msg = message GRgraphics.GRdelete
                            (msg, &rot_data.dyn_mod),
                       senderid = caller_id,
                       targetid = rot_data.dyn_obj.objid,
                       targetos = rot_data.dyn_obj.osnum);

        if (!(sts & *msg & 1))
        {
            return (*msg = MSFAIL);
        }
    }

    return (*msg = MSSUCC);
}

#argsused
IGRint DYrotate_dyn (rot_data, dypoint, wld_to_vw, objects, num_objects,
                     buffers, num_buffers, in_dummy1, in_dummy2, in_dummy3,
                     reset_dypoint, dyn_mod_info, out_dummy3)

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
    IGRshort    mxtype;         /* matrix type for xform */
    IGRshort    n;              /* index - DLB chg to short - SUN*/
    IGRlong     sts, msg;       /* return codes */
    IGRdouble   angle[3];       /* rotation angle, sin, cos */
    IGRmatrix   rot_mx;         /* rotation matrix */
    IGRmatrix   t_matrix;       /* transformation matrix */
    IGRmatrix   vw_to_wld;      /* rotation matrix */

    /*
     *  adjust the length of the second line to equal the input radius
     */

    rot_data->wld_pts[6] = dypoint->x - rot_data->wld_pts[3];
    rot_data->wld_pts[7] = dypoint->y - rot_data->wld_pts[4];
    rot_data->wld_pts[8] = dypoint->z - rot_data->wld_pts[5];

    if (! MAunitvc (&msg, &rot_data->wld_pts[6], &rot_data->wld_pts[6]))
    {
        rot_data->invert = FALSE;
        return (MSFAIL);
    }

    dypoint->x = rot_data->wld_pts[6] = 
            (rot_data->wld_pts[6] * rot_data->radius) + rot_data->wld_pts[3];

    dypoint->y = rot_data->wld_pts[7] = 
            (rot_data->wld_pts[7] * rot_data->radius) + rot_data->wld_pts[4];

    dypoint->z = rot_data->wld_pts[8] = 
            (rot_data->wld_pts[8] * rot_data->radius) + rot_data->wld_pts[5];

    /*
     *  tell dp$dynamics that the cursor position has been modified
     */
/*
    reset_dypoint = 1;
*/
    /*
     *  get the view to world rotation matrix
     */

    n = 4;

    if (! MAtrnmx (&msg, &n, wld_to_vw, vw_to_wld))
    {
        rot_data->invert = FALSE;
        return (MSFAIL);
    }

    /*
     *  build a world to local matrix
     */

    if (! MAwclsmx (&msg, &rot_data->wld_pts[3], vw_to_wld, t_matrix))
    {
        rot_data->invert = FALSE;
        return (MSFAIL);
    }

    /*
     *  transform the points to the local system
     */

    {
      IGRlong long_n=3;

      if (! MAptsxform (&msg, &long_n, t_matrix, rot_data->wld_pts,
                        rot_data->lcl_pts))
      {
          rot_data->invert = FALSE;
          return (MSFAIL);
      }
    }

    /*
     *  get the vectors defining the rotation angle
     */

    rot_data->lcl_pts[0] -= rot_data->lcl_pts[3];
    rot_data->lcl_pts[1] -= rot_data->lcl_pts[4];
    rot_data->lcl_pts[2] =  0;
    rot_data->lcl_pts[6] -= rot_data->lcl_pts[3];
    rot_data->lcl_pts[7] -= rot_data->lcl_pts[4];
    rot_data->lcl_pts[8] =  0;

    /*
     *  if the first vector is zero, let it be the unit x vector
     */

    if ((rot_data->lcl_pts[0] == 0.0) && (rot_data->lcl_pts[1] == 0.0))
    {
       /* rot_data->lcl_pts[0] == 1.0; ??? APOGEE */

        rot_data->lcl_pts[0] = 1.0;
    }

    /*
     *  get the angle between the two vectors
     */

    if (! MAang2vc (&msg, rot_data->lcl_pts, &rot_data->lcl_pts[6], angle))
    {
        rot_data->invert = FALSE;
        return (MSFAIL);
    }
    
    /*
     *  get the rotation matrix
     */

    if (! MAgrotmx (&msg, &wld_to_vw[8], &rot_data->wld_pts[3], angle,
                    rot_mx))
    {
        rot_data->invert = FALSE;
        return (MSFAIL);
    }

    if (rot_data->mode == COPY_DYNAMICS)
    {
        /*
         *  invert previous transformation matrix
         */

        n = 4;

        if (rot_data->invert)
        {
            if (! MAinvmx (&msg, &n, rot_data->old_tmx, rot_data->old_tmx))
            {
                return (MSFAIL);
            }
        }

        /*
         *  multiply transformation matrices to get the effect of
         *  rotating the original rather than the clone
         */

        if (! MAmulmx (&msg, &n, &n, &n, rot_mx, &rot_data->old_tmx[0],
                       t_matrix))
        {
            rot_data->invert = FALSE;
            return (MSFAIL);
        }

        /*
         *  transform clone
         */

        MAtypemx (&msg, t_matrix, &mxtype);

        sts = om$send (msg = message GRgraphics.GRxform
                            (&msg, &rot_data->dyn_mod, &mxtype,
                             t_matrix, &rot_data->dyn_obj.objid),
                       senderid = NULL_OBJID,
                       targetid = rot_data->dyn_obj.objid,
                       targetos = rot_data->dyn_obj.osnum);

        if (!(sts & msg & 1))
        {
            rot_data->invert = FALSE;
            return (MSFAIL);
        }

        /*
         *  put the rotation matrix into old_tmx
         */

        rot_data->old_tmx[0] = rot_mx[0];
        rot_data->old_tmx[1] = rot_mx[1];
        rot_data->old_tmx[2] = rot_mx[2];
        rot_data->old_tmx[3] = rot_mx[3];
        rot_data->old_tmx[4] = rot_mx[4];
        rot_data->old_tmx[5] = rot_mx[5];
        rot_data->old_tmx[6] = rot_mx[6];
        rot_data->old_tmx[7] = rot_mx[7];
        rot_data->old_tmx[8] = rot_mx[8];
        rot_data->old_tmx[9] = rot_mx[9];
        rot_data->old_tmx[10] = rot_mx[10];
        rot_data->old_tmx[11] = rot_mx[11];
        rot_data->old_tmx[12] = rot_mx[12];
        rot_data->old_tmx[13] = rot_mx[13];
        rot_data->old_tmx[14] = rot_mx[14];
        rot_data->old_tmx[15] = rot_mx[15];
        rot_data->invert = TRUE;
    }
    else
    {
        /*
         *  combine located object's module matrix and the translation matrix
         */

        n = 4;

        MAmulmx (&msg, &n, &n, &n, rot_mx, rot_data->dyn_mod.md_env.matrix,
                 rot_data->trans.matrix);

        MAtypemx (&msg, rot_data->trans.matrix, &rot_data->trans.matrix_type);

        *dyn_mod_info = &rot_data->trans;
   }

    /*
     *  set up buffer pointers
     */

    *objects = &rot_data->dyn_obj;
    *buffers = &rot_data->rb_elem;
    *num_objects = 1;
    *num_buffers = 1;
    return (MSSUCC);
}

end implementation CEO_GSLOCATE;
