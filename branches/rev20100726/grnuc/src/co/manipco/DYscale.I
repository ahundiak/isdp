/*
Name
        DYscale

Synopsis
        IGRint DYscale (msg, caller_id, caller_os, origin, ref_pt, curr_mod,
                        gschan, event)

        IGRlong            *msg;            return code
        GRobjid             caller_id;      caller id
        OMuword             caller_os;      caller's object space
        struct EX_button   *origin;         origin of scale
        struct EX_button   *ref_pt;         reference point
        struct GRmd_env    *curr_mod;       current module
        OM_S_CHANSELECT    *gschan;         channel located containing object
        struct GRevent     *event;          containing located object

Description
        This routine implements dynamics for the Scale by 3 Points
        command.  The indicated object will be dynamically displayed
        as being scaled from the input origin by factors determined
        from the reference point and the cursor position.

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
                08/12/88    use display dynamics; allow event to specify
                            object to scale
	DLB     10/25/91    Pass *short to MA routines instead of *int.  
			    This is a sparc related problem.
*/
class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "comndef.h"
#include "grgs.h"
#include "msdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "dpstruct.h"

from GRgraphics import GRcopy, GRdelete, GRxform;
from IGEgragad  import DPinrot;

extern double fabs();
extern IGRboolean MAgscamx(), MAtrnmx(), MAwclsmx();
extern IGRboolean MAptsxform(), MAinvmx(), MAmulmx();

struct dyn_args
{
    IGRboolean          mode;           /* copy or display dynamics */
    IGRboolean          invert;         /* invert previous mx? if error no */
    IGRdouble           wld_pts[9];     /* points defining scale in world */
    IGRdouble           lcl_pts[9];     /* points defining scale in local */
    IGRmatrix           old_tmx;        /* last transformation matrix */
    struct GRid         dyn_obj;        /* id of object in dynamics */
    struct GRmd_env     dyn_mod;        /* module dynamics takes place in */
    struct GRmdenv_info trans;          /* combined module & transformation */
};

IGRint DYscale (msg, caller_id, caller_os, origin, ref_pt, curr_mod,
                gschan, event)

IGRlong            *msg;            /* return code */
GRobjid             caller_id;      /* caller id */
OMuword             caller_os;      /* caller's object space */
struct EX_button   *origin;         /* origin of scale */
struct EX_button   *ref_pt;         /* reference point */
struct GRmd_env    *curr_mod;       /* current module */
OM_S_CHANSELECT    *gschan;         /* channel located containing object */
struct GRevent     *event;          /* containing located object */

{
    IGRboolean          dyn_on;         /* is dynamics on? */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags */
    IGRint              DYscale_dyn();  /* dynamics function */
    IGRint              i;              /* number of pts sent to MAptsxform */
    IGRlong             sts;            /* function return code */
    struct GRid         caller;         /* caller structure */
    struct GRobj_env    obj_info;       /* object displayed in dynamics */
    struct dyn_args     sca_data;       /* arguments passed to DYscale */

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

    sca_data.wld_pts[0] = ref_pt->x;
    sca_data.wld_pts[1] = ref_pt->y;
    sca_data.wld_pts[2] = ref_pt->z;
    sca_data.wld_pts[3] = origin->x;
    sca_data.wld_pts[4] = origin->y;
    sca_data.wld_pts[5] = origin->z;
    sca_data.invert = FALSE;
    MAidmx (msg, &sca_data.old_tmx[0]);

    /*
     *  check dynamics mode
     */

    i = sizeof (IGRboolean);

    sts = gr$get_dynamics_copy_flag (msg = msg, sizbuf = &i,
                                     buffer = &sca_data.mode, nret = &i);

    /*
     *  set up dynamic object
     */

    if (sca_data.mode == COPY_DYNAMICS)
    {
        sca_data.dyn_mod = *curr_mod;
        sca_data.dyn_mod.md_id.objid = NULL_OBJID;      /* no Rtree manips */
        sca_data.dyn_obj.osnum = curr_mod->md_id.osnum;
        sts = om$send (msg = message GRgraphics.GRcopy
                            (msg,
                             &(obj_info.mod_env),
                             &sca_data.dyn_mod,
                             &sca_data.dyn_obj.objid),
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
        sca_data.dyn_obj.osnum = obj_info.obj_id.osnum;
        sca_data.dyn_obj.objid = obj_info.obj_id.objid;
        sca_data.dyn_mod = obj_info.mod_env;
        sca_data.dyn_mod.md_id.objid = NULL_OBJID;      /* no Rtree manips */
    }        

    /*
     *  invoke dynamics
     */

    dp$dynamics (dyn_fun = DYscale_dyn,
                 information = &sca_data);

    if (sca_data.mode == COPY_DYNAMICS)
    {
        /*
         *  delete dynamic object
         */

        sts = om$send (msg = message GRgraphics.GRdelete
                            (msg, &sca_data.dyn_mod),
                       senderid = caller_id,
                       targetid = sca_data.dyn_obj.objid,
                       targetos = sca_data.dyn_obj.osnum);

        if (!(sts & *msg & 1))
        {
            return (*msg = MSFAIL);
        }
    }

    return (*msg = MSSUCC);
}

#argsused
IGRint DYscale_dyn (sca_data, dypoint, wld_to_vw, objects, num_objects,
                    buffers, num_buffers, new_point, in_dummy2, in_dummy3,
                    out_dummy1, dyn_mod_info, out_dummy3)

struct dyn_args      *sca_data;
struct EX_button     *dypoint;
IGRdouble            *wld_to_vw;
struct GRid         **objects;
IGRint               *num_objects;
struct DPele_header **buffers;
IGRint               *num_buffers;
IGRint               *new_point;   /* flag - is dypoint reset in this func? */
IGRchar              *in_dummy2;
IGRchar              *in_dummy3;
IGRchar             **out_dummy1;
struct GRmdenv_info **dyn_mod_info;
IGRchar             **out_dummy3;

{
    IGRshort    mxtype;         /* matrix type for xform */
    IGRlong     sts, msg;       /* function return code */
    IGRshort    i, j;           /* index- DLB chg to short -SUN PORT 10/25/91*/
    IGRdouble   scale[4];       /* delta defining (& holding) scale factor */
    IGRdouble   vectors[6];     /* vectors defining scale */
    IGRmatrix   sca_mx;         /* scale matrix */
    IGRmatrix   t_matrix;       /* transformation matrix */
    IGRmatrix   vw_to_wld;      /* rotation matrix */

    /*
     *  store the second reference point
     */

    sca_data->wld_pts[6] = dypoint->x;
    sca_data->wld_pts[7] = dypoint->y;
    sca_data->wld_pts[8] = dypoint->z;

    /*
     *  get the view to world rotation matrix
     */

    i = 4;

    if (! MAtrnmx (&msg, &i, wld_to_vw, vw_to_wld))
    {
        sca_data->invert = FALSE;
        return (MSFAIL);
    }

    /*
     *  build a world to local matrix
     */

    if (! MAwclsmx (&msg, &sca_data->wld_pts[3], vw_to_wld, t_matrix))
    {
        sca_data->invert = FALSE;
        return (MSFAIL);
    }

    /*
     *  transform the points to the local system
     */

    { 
      IGRlong long_i=3;

      if (! MAptsxform (&msg, &long_i, t_matrix, sca_data->wld_pts,
                        sca_data->lcl_pts))
      {
          sca_data->invert = FALSE;
          return (MSFAIL);
      }
    }

    /*
     *  get the vectors defining the scale ratios
     */

    vectors[0] = sca_data->lcl_pts[0] - sca_data->lcl_pts[3];
    vectors[1] = sca_data->lcl_pts[1] - sca_data->lcl_pts[4];
    vectors[2] = sca_data->lcl_pts[2] - sca_data->lcl_pts[5];
    vectors[3] = sca_data->lcl_pts[6] - sca_data->lcl_pts[3];
    vectors[4] = sca_data->lcl_pts[7] - sca_data->lcl_pts[4];
    vectors[5] = sca_data->lcl_pts[8] - sca_data->lcl_pts[5];

    /*
     *  calculate scale factors
     */

    for (i = 0, j = 3; i < 3; i++, j++)
    {
        vectors[i] = (vectors[i]) ? vectors[i] : 1.0;
        vectors[j] = (vectors[j]) ? vectors[j] : 1.0;
        scale[i] = fabs (vectors[j] / vectors[i]);
    }

    scale[3] = 1.0; /* homogeneous */

    /*
     *  get a scaling matrix
     */
                        
    if (! MAgscamx (&msg, wld_to_vw, &sca_data->wld_pts[3], scale, sca_mx))
    {
        sca_data->invert = FALSE;
        return (MSFAIL);
    }

    if (sca_data->mode == COPY_DYNAMICS)
    {
        /*
         *  invert previous transformation matrix
         */

        if (sca_data->invert)
        {
            i = 4;
            if (! MAinvmx (&msg, &i, sca_data->old_tmx, sca_data->old_tmx))
            {
                return (MSFAIL);
            }
        }

        /*
         *  multiply transformation matrices to get the effect of
         *  scaling the original rather than the clone
         */

        i = 4;
        if (! MAmulmx (&msg, &i, &i, &i, sca_mx, sca_data->old_tmx, t_matrix))
        {
            sca_data->invert = FALSE;
            return (MSFAIL);
        }

        /*
         *  transform the clone
         */

        MAtypemx (&msg, t_matrix, &mxtype);

        sts = om$send (msg = message GRgraphics.GRxform
                            (&msg, &sca_data->dyn_mod, &mxtype,
                             t_matrix, &sca_data->dyn_obj.objid),
                       senderid = NULL_OBJID,
                       targetid = sca_data->dyn_obj.objid,
                       targetos = sca_data->dyn_obj.osnum);

        if (!(sts & msg & 1))
        {
            sca_data->invert = FALSE;
            return (MSFAIL);
        }

        /*
         *  put the scale matrix into old_tmx
         */

        sca_data->old_tmx[0] = sca_mx[0];
        sca_data->old_tmx[1] = sca_mx[1];
        sca_data->old_tmx[2] = sca_mx[2];
        sca_data->old_tmx[3] = sca_mx[3];
        sca_data->old_tmx[4] = sca_mx[4];
        sca_data->old_tmx[5] = sca_mx[5];
        sca_data->old_tmx[6] = sca_mx[6];
        sca_data->old_tmx[7] = sca_mx[7];
        sca_data->old_tmx[8] = sca_mx[8];
        sca_data->old_tmx[9] = sca_mx[9];
        sca_data->old_tmx[10] = sca_mx[10];
        sca_data->old_tmx[11] = sca_mx[11];
        sca_data->old_tmx[12] = sca_mx[12];
        sca_data->old_tmx[13] = sca_mx[13];
        sca_data->old_tmx[14] = sca_mx[14];
        sca_data->old_tmx[15] = sca_mx[15];
        sca_data->invert = TRUE;
    }
    else
    {
        /*
         *  combine located object's module matrix and the translation matrix
         */

        i = 4;

        MAmulmx (&msg, &i, &i, &i, sca_mx, sca_data->dyn_mod.md_env.matrix,
                 sca_data->trans.matrix);

        MAtypemx (&msg, sca_data->trans.matrix, &sca_data->trans.matrix_type);

        *dyn_mod_info = &sca_data->trans;
   }


    *objects = &sca_data->dyn_obj;
    *num_objects = 1;

    return (MSSUCC);
}

end implementation CEO_GSLOCATE;
