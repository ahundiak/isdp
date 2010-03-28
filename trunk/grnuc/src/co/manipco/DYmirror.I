/*
Name
        DYmirror

Synopsis
        IGRint DYmirror (mirr_object, event, add_info)

        struct GRid       *mirr_object; - object to mirror
        struct GRevent    *event;       - locate event - also contains obj info
        struct COmnlcdyn  *add_info;    - data from command object

Description
        This routine implements dynamics for the mirror vertical and
        horizontal commands. The indicated object will be mirrored about the
        vertical or horizontal axis formed by the cursor location in the
        window.  Bit 4 (from 0) in add_info->flags specifies whether to use
        vertical or horizontal mirroring; set implies vertical.  According to
        the dpb parameter indicating dynamics type, the routine will either
        create a copy of the indicated object and repeatedly transform that
        copy, or combine the necessary transformation with the original
        object's environment matrix so that the dynamic display appears to
        make the necessary transformation.

Notes
        The input add_info arguments gschan and event are used to determine
        what object to drag.  If not NULL, gschan is expected to point to a
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

History
        mrm     07/18/86    creation
                03/09/87    include file revision
                11/13/87    call GRxform since GRtform no longer exists
                08/15/88    use display dynamics; allow event to specify
                            object to move
                09/18/89    add check to make sure dyn should proceed
*/
class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "msdef.h"
#include "comn.h"
#include "comndef.h"
#include "grgs.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "dpstruct.h"

extern IGRboolean MAgrefmx(), MAidmx(), MAmulmx(), MAtypemx();
extern IGRint EX_dyn_process_input_event();

from GRgraphics import GRxform, GRcopy, GRdelete;

struct dyn_args
{
    IGRboolean          normal;     /* 0 => vertical, 4 => horizontal */
    IGRboolean          mode;       /* copy or display dynamics */
    IGRmatrix           old_tmx;    /* last transformation matrix */
    struct IGRplane     plane;      /* reflection plane */
    struct GRid         dyn_obj;    /* dynamic object */
    struct GRmd_env     dyn_mod;    /* dynamic module */
    struct GRmdenv_info trans;      /* combined module & transformation */
};

IGRint DYmirror (mirr_object, event, add_info)

struct GRid       *mirr_object;    /* object to mirror */
struct GRevent    *event;          /* locate event - also contains obj info */
struct COmnlcdyn  *add_info;       /* struct with info from command object */

{
    IGRboolean          dyn_on;         /* is dynamics on? */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags */
    IGRint              DYmirror_dyn(); /* dynamics function */
    IGRint              size;           /* for dpb call */
    IGRlong             sts, msg;       /* return codes */
    IGRpoint            point;          /* space for mirror point storage */
    struct GRobj_env    obj_info;       /* object in dynamics */
    struct dyn_args     mirr_data;      /* arguments passed to DYmirror_dyn */

    /*
     *  if dynamics is off then exit
     */

    DPdynflags (&msg, &inquire, &dyn_on, NULL);

    if (!dyn_on)
    {
        return (MSSUCC);
    }

    /*
     *  if there is an event waiting to go on the queue then exit
     */

    if (!EX_dyn_process_input_event(0))  /*DLB 10/29/91 - pass 0 to dyn_ev*/
    {
        return (MSSUCC);
    }

    /*
     *  get info about the object going into dynamics
     */

    if (add_info->flags & 1)
    {
        /*
         *  called from locate
         */

        obj_info.obj_id = *mirr_object;
        obj_info.mod_env = event->located_object[0].module_info;
    }
    else
    {
        /*
         *  called from command object
         */

        if (add_info->gschan)
        {
            sts = GRgsget_simple_object (&msg, &add_info->caller,
                                         add_info->gschan, &obj_info);
            if (!(sts & msg & 1))
            {
                return (MSSUCC);
            }
        }
        else
        {
            obj_info.obj_id = add_info->event->located_object[0].located_obj;
            obj_info.mod_env = add_info->event->located_object[0].module_info;
        }
    }

    mirr_data.normal = (add_info->flags & 16) ? 0 : 4;
    mirr_data.plane.point = point;
    MAidmx (&msg, &mirr_data.old_tmx[0]);

    /*
     *  check dynamics mode
     */

    size = sizeof (IGRboolean);

    sts = gr$get_dynamics_copy_flag (msg = &msg, sizbuf = &size,
                                     buffer = &mirr_data.mode, nret = &size);

    /*
     *  set up dynamic object
     */

    if (mirr_data.mode == COPY_DYNAMICS)
    {
        mirr_data.dyn_mod = *add_info->curr_mod;
        mirr_data.dyn_mod.md_id.objid = NULL_OBJID; /* no R-tree manips */
        mirr_data.dyn_obj.osnum = add_info->curr_mod->md_id.osnum;
        sts = om$send (msg = message GRgraphics.GRcopy
                            (&msg, &obj_info.mod_env,
                            &mirr_data.dyn_mod, &mirr_data.dyn_obj.objid),
                       senderid = add_info->caller.objid,
                       targetid = obj_info.obj_id.objid,
                       targetos = obj_info.obj_id.osnum);

        if (!(sts & msg & 1))
        {
            return (MSFAIL);
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

    dp$dynamics (dyn_fun = DYmirror_dyn, 
                 information = &mirr_data);

    if (mirr_data.mode == COPY_DYNAMICS)
    {
        /*
         *  delete dynamic object
         */

        sts = om$send (msg = message GRgraphics.GRdelete
                           (&msg, &mirr_data.dyn_mod),
                       senderid = add_info->caller.objid,
                       targetid = mirr_data.dyn_obj.objid,
                       targetos = mirr_data.dyn_obj.osnum);

        if (!(sts & msg & 1))
        {
            return (MSFAIL);
        }
    }

    return (MSSUCC);
}

#argsused
IGRint DYmirror_dyn (mirr_data, mirr_point, mtx, objects, num_objects,
                     buffers, num_buffers, in_dummy1, in_dummy2, in_dummy3,
                     out_dummy1, dyn_mod_info, out_dummy3)

struct dyn_args       *mirr_data;
struct EX_button      *mirr_point;
IGRdouble             *mtx;
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
    IGRlong     sts, msg;       /* return codes */
    IGRshort    n = 4;          /* dimension of tmatrix */
    IGRmatrix   ref_mx;         /* reflection matrix */
    IGRmatrix   t_matrix;       /* transformation matrix */

    /*
     *  get the plane of reflection using a point on the reflection plane
     *  (the locate point) and a vector normal to the reflection plane
     */

    mirr_data->plane.point[0] = mirr_point->x;
    mirr_data->plane.point[1] = mirr_point->y;
    mirr_data->plane.point[2] = mirr_point->z;

    /*
     *  get the proper normal vector
     */

    mirr_data->plane.normal = &mtx[mirr_data->normal]; 

    /*
     *  get reflection matrix
     */

    if (! MAgrefmx (&msg, &mirr_data->plane, ref_mx))
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
     *  set up buffer pointer
     */

    *objects = &mirr_data->dyn_obj;
    *num_objects = 1;
    return (MSSUCC);
}

end implementation CEO_GSLOCATE;
