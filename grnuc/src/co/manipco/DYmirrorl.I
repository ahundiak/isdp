/*
Name
        DYmirrorl

Synopsis
        IGRint DYmirrorl (msg, caller_id, caller_os, point1, curr_mod,
                          gschan, event)

        IGRlong            *msg;            return code
        GRobjid             caller_id;      caller id
        OMuword             caller_os;      caller's object space
        struct EX_button   *point1;         of mirror line
        struct GRmd_env    *curr_mod;       current module
        OM_S_CHANSELECT    *gschan;         channel located containing object
        struct GRevent     *event;          containing located object

Description
        This routine implements dynamics for the mirror about line command.
        The indicated object will be mirrored about the line formed by the
        input point and the cursor location.  According to the dpb parameter
        indicating dynamics type, the routine will either create a copy of
        the indicated object and repeatedly transform that copy, or combine
        the necessary transformation with the original object's environment
        matrix so that the dynamic display appears to make the necessary
        transformation.

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
                11/13/87    call GRxform since GRtform no longer exists
                08/11/88    use display dynamics; allow event to specify
                            object to move
*/
class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "igrdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "msdef.h"
#include "grgs.h"
#include "comndef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"

extern IGRboolean MAgrefmx(), MAidmx(), MAlpfrln();
extern IGRboolean MAsubvc(), MAmulmx(), MAtypemx();

from GRgraphics import GRcopy, GRdelete, GRxform;

struct dyn_args
{
    IGRboolean          mode;           /* copy or display dynamics */
    IGRpoint            origin;         /* "origin" of mirror line */
    IGRmatrix           old_tmx;        /* last transformation matrix */
    struct GRid         dyn_obj;        /* clone object */
    struct GRmd_env     dyn_mod;        /* clone (current) module */
    struct GRmdenv_info trans;          /* combined module & transformation */
    struct IGRline      mirr_line;      /* mirror line */
    struct IGRplane     mirr_plane;     /* plane to mirror about */
    struct DPele_header rb_elem;        /* rubber band mirror line */
};

IGRint DYmirrorl (msg, caller_id, caller_os, point1, curr_mod, gschan, event)

IGRlong            *msg;            /* return code */
GRobjid             caller_id;      /* caller id */
OMuword             caller_os;      /* caller's object space */
struct EX_button   *point1;         /* of mirror line */
struct GRmd_env    *curr_mod;       /* current module */
OM_S_CHANSELECT    *gschan;         /* channel located containing object */
struct GRevent     *event;          /* containing located object */

{
    IGRboolean          dyn_on;         /* is dynamics on? */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags */
    IGRint              DYmirrorl_dyn();/* dynamics function */
    IGRint              size;           /* for dpb call */
    IGRlong             sts;            /* return code */
    IGRdouble           pts[6];         /* points defining mirror line */
    IGRvector           vector;         /* vector normal to mirror line */
    IGRpoint            pt2;            /* 2nd pt of mirror line */
    struct GRid         caller;         /* calling object */
    struct GRobj_env    obj_info;       /* object to be cloned */
    struct IGRdisplay   dis_att;        /* display attr for mirror line */
    struct IGRpolyline  rb_line;        /* mirror line to rubberband */
    struct dyn_args     mirr_data;      /* arguments passed to DYmirrorl_dyn */

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

    rb_line.num_points = 2;
    rb_line.points = pts;
    dis_att.color = 2;
    dis_att.weight = 0;
    dis_att.style = 3;

    mirr_data.origin[0] = point1->x;
    mirr_data.origin[1] = point1->y;
    mirr_data.origin[2] = point1->z;
    mirr_data.mirr_plane.normal = vector;
    mirr_data.mirr_plane.point = pts;
    mirr_data.mirr_line.point1 = pts;
    mirr_data.mirr_line.point2 = pt2;

    dp$build_dis_buffer (buffer = &mirr_data.rb_elem,
                         type = IGRPY,
                         display_att = &dis_att,
                         geometry = &rb_line);

    MAidmx (msg, mirr_data.old_tmx);

    /*
     *  check dynamics mode
     */

    size = sizeof (IGRboolean);

    sts = gr$get_dynamics_copy_flag (msg = msg, sizbuf = &size,
                                     buffer = &mirr_data.mode, nret = &size);

    /*
     *  set up dynamic object
     */

    if (mirr_data.mode == COPY_DYNAMICS)
    {
        mirr_data.dyn_mod = *curr_mod;
        mirr_data.dyn_mod.md_id.objid = NULL_OBJID; /* no R-tree manips */
        mirr_data.dyn_obj.osnum = curr_mod->md_id.osnum;
        sts = om$send (msg = message GRgraphics.GRcopy
                            (msg,
                             &(obj_info.mod_env),
                             &mirr_data.dyn_mod,
                             &mirr_data.dyn_obj.objid),
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
        mirr_data.dyn_obj.osnum = obj_info.obj_id.osnum;
        mirr_data.dyn_obj.objid = obj_info.obj_id.objid;
        mirr_data.dyn_mod = obj_info.mod_env;
        mirr_data.dyn_mod.md_id.objid = NULL_OBJID; /* no R-tree manips */
    }        

    /*
     *  invoke dynamics
     */

    dp$dynamics (dyn_fun = DYmirrorl_dyn, 
                 information = &mirr_data);

    if (mirr_data.mode == COPY_DYNAMICS)
    {
        /*
         *  delete dynamic object
         */

        sts = om$send (msg = message GRgraphics.GRdelete
                           (msg, &mirr_data.dyn_mod),
                       senderid = caller_id,
                       targetid = mirr_data.dyn_obj.objid,
                       targetos = mirr_data.dyn_obj.osnum);

        if (!(sts & *msg & 1))
        {
            return (*msg = MSFAIL);
        }
    }

    return (*msg = MSSUCC);
}

#argsused
IGRint DYmirrorl_dyn(mirr_data, point2, view_mx, objects, num_objects, buffers,
                     num_buffers, in_dummy1, in_dummy2, in_dummy3,
                     out_dummy1, dyn_mod_info, out_dummy3 )

struct dyn_args       *mirr_data;
struct EX_button      *point2;
IGRdouble             *view_mx;
struct GRid          **objects;
IGRint                *num_objects;
struct DPele_header  **buffers;
IGRint                *num_buffers;
IGRchar               *in_dummy1;
IGRchar               *in_dummy2;
IGRchar               *in_dummy3;
IGRchar              **out_dummy1;
struct GRmdenv_info  **dyn_mod_info;
IGRchar              **out_dummy3;

{
    IGRshort    mxtype;         /* matrix type for xform */
    IGRshort    n = 4;          /* index */
    IGRlong     sts, msg;       /* return codes */
    IGRdouble  *pypts;          /* points to polyline points */
    IGRmatrix   ref_mx;         /* reflection matrix */
    IGRmatrix   t_matrix;       /* transformation matrix */

    /*
     *  set up second point of rubberbanded mirror line
     */

    pypts = mirr_data->rb_elem.geometry.polyline->points;
    pypts[0] = (2.0 * mirr_data->origin[0]) - point2->x;
    pypts[1] = (2.0 * mirr_data->origin[1]) - point2->y;
    pypts[2] = (2.0 * mirr_data->origin[2]) - point2->z;
    pypts[3] = point2->x;
    pypts[4] = point2->y;
    pypts[5] = point2->z;

    /*
     *  get line perpendicular from mirror line
     */

    mirr_data->mirr_line.point2[0] = point2->x;
    mirr_data->mirr_line.point2[1] = point2->y;
    mirr_data->mirr_line.point2[2] = point2->z;

    if (! MAlpfrln (&sts, &mirr_data->mirr_line,
                    &mirr_data->mirr_line.point1[0],
                    &view_mx[8], &mirr_data->mirr_line))
    {
        return (MSFAIL);
    }

    /*
     *  get vector normal to mirror line
     */

    if (! MAsubvc (&sts, &mirr_data->mirr_line.point2[0],
                   &mirr_data->mirr_line.point1[0],
                   &mirr_data->mirr_plane.normal[0]))
    {
        return (MSFAIL);
    }

    /*
     *  get reflection matrix
     */

    if (! MAgrefmx (&msg, &mirr_data->mirr_plane, ref_mx))
    {
        return (MSFAIL);
    }

    if (mirr_data->mode == COPY_DYNAMICS)
    {
        /*
         *  multiply transformation matrices to get the effect of
         *  mirroring the original rather than the clone
         */

        if (! MAmulmx (&msg, &n, &n, &n, ref_mx, mirr_data->old_tmx, t_matrix))
        {
            return (MSFAIL);
        }

        /*
         *  transform the clone
         */

        MAtypemx (&msg, t_matrix, &mxtype);

        sts = om$send (msg = message GRgraphics.GRxform
                            (&msg, &mirr_data->dyn_mod, &mxtype,
                             t_matrix, &mirr_data->dyn_obj.objid),
                       senderid = NULL_OBJID,
                       targetid = mirr_data->dyn_obj.objid,
                       targetos = mirr_data->dyn_obj.osnum);

        /*
         *  put the reflection matrix into old_tmx
         */

        mirr_data->old_tmx[0] = ref_mx[0];
        mirr_data->old_tmx[1] = ref_mx[1];
        mirr_data->old_tmx[2] = ref_mx[2];
        mirr_data->old_tmx[3] = ref_mx[3];
        mirr_data->old_tmx[4] = ref_mx[4];
        mirr_data->old_tmx[5] = ref_mx[5];
        mirr_data->old_tmx[6] = ref_mx[6];
        mirr_data->old_tmx[7] = ref_mx[7];
        mirr_data->old_tmx[8] = ref_mx[8];
        mirr_data->old_tmx[9] = ref_mx[9];
        mirr_data->old_tmx[10] = ref_mx[10];
        mirr_data->old_tmx[11] = ref_mx[11];
        mirr_data->old_tmx[12] = ref_mx[12];
        mirr_data->old_tmx[13] = ref_mx[13];
        mirr_data->old_tmx[14] = ref_mx[14];
        mirr_data->old_tmx[15] = ref_mx[15];
    }
    else
    {
        /*
         *  combine located object's module matrix and the translation matrix
         */

        MAmulmx (&msg, &n, &n, &n, ref_mx, mirr_data->dyn_mod.md_env.matrix,
                 mirr_data->trans.matrix);

        MAtypemx (&msg, mirr_data->trans.matrix,
                  &mirr_data->trans.matrix_type);

        *dyn_mod_info = &mirr_data->trans;
    }

    /*
     *  set up buffer pointers
     */

    *objects = &mirr_data->dyn_obj;
    *buffers = &mirr_data->rb_elem;
    *num_objects = 1;
    *num_buffers = 1;
    return (MSSUCC);
}

end implementation CEO_GSLOCATE;
