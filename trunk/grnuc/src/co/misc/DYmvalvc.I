/* #######################    APOGEE COMPILED   ######################## */
class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "msdef.h"
#include "grgs.h"
#include "dpmacros.h"
#include "comndef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "dpstruct.h"

extern IGRboolean   MAtrlmx(), 
                    MAtypemx(), 
                    MAmulmx(),
                    MAptlnproj();

from GRgraphics   import GRxform, 
                         GRcopy, 
                         GRdelete;

struct dyn_args
{
    IGRboolean          mode;
    struct GRid         dyn_obj;
    struct GRmd_env     dyn_mod;
    IGRdouble           from_point[3],
                        delta[3];
    struct GRmdenv_info trans;
};

IGRint DYmv_along_vec ( msg, 
                        caller_id, 
                        caller_os, 
                        vector_pt1, 
                        vector_pt2, 
                        from_point, 
                        curr_mod,
                        gschan, 
                        event )

IGRlong            *msg;            /* return code                        */
GRobjid             caller_id;      /* caller id                          */
OMuword             caller_os;      /* caller's object space              */
struct EX_button   *vector_pt1,     /* start direction point              */
                   *vector_pt2,     /* end direction point                */
                   *from_point;     /* move from point                    */
struct GRmd_env    *curr_mod;       /* current module                     */
OM_S_CHANSELECT    *gschan;         /* channel located containing object  */
struct GRevent     *event;          /* containing located object          */

{
    IGRboolean          dyn_on;         /* is dynamics on?                */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags        */
    IGRint              DYmv_vec_dyn(); /* dynamics function              */
    IGRint              size;           /* for dpb call                   */
    IGRlong             sts;            /* return code                    */
    struct GRobj_env    obj_info;       /* object going into dynamics     */
    struct GRid         caller;         /* caller structure               */
    struct dyn_args     DYinfo;         /* arguments passed to DYmove_dyn */

    *msg = MSSUCC;

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
     *  check dynamics mode
     */

    size = sizeof (IGRboolean);

    sts = gr$get_dynamics_copy_flag( msg = msg, 
                                     sizbuf = &size,
                                     buffer = &DYinfo.mode, 
                                     nret = &size );

    /*
     *  set up dynamic object
     */
    if (DYinfo.mode == COPY_DYNAMICS)
    {
        DYinfo.dyn_mod = *curr_mod;
        DYinfo.dyn_mod.md_id.objid = NULL_OBJID; /* no R-tree manips */
        DYinfo.dyn_obj.osnum = curr_mod->md_id.osnum;
        sts = om$send (msg = message GRgraphics.GRcopy
                            (msg,
                             &(obj_info.mod_env),
                             &DYinfo.dyn_mod,
                             &DYinfo.dyn_obj.objid),
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
        DYinfo.dyn_obj.osnum = obj_info.obj_id.osnum;
        DYinfo.dyn_obj.objid = obj_info.obj_id.objid;
        DYinfo.dyn_mod = obj_info.mod_env;
        DYinfo.dyn_mod.md_id.objid = NULL_OBJID; /* no R-tree manips */
    }        


    /* get the delta of the vector points */
    DYinfo.delta[0] = vector_pt2->x - vector_pt1->x;
    DYinfo.delta[1] = vector_pt2->y - vector_pt1->y;
    DYinfo.delta[2] = vector_pt2->z - vector_pt1->z;

    DYinfo.from_point[0] = from_point->x;
    DYinfo.from_point[1] = from_point->y;
    DYinfo.from_point[2] = from_point->z;

    /*
     *  invoke dynamics
     */
    dp$dynamics( dyn_fun = DYmv_vec_dyn, 
                 information = &DYinfo );

    if (DYinfo.mode == COPY_DYNAMICS)
    {
        /*
         *  delete dynamic object
         */
        sts = om$send( msg = message GRgraphics.GRdelete( msg, 
                                                         &DYinfo.dyn_mod ),
                       senderid = caller_id,
                       targetid = DYinfo.dyn_obj.objid,
                       targetos = DYinfo.dyn_obj.osnum );

        if (!(sts & *msg & 1))
        {
            return (*msg = MSFAIL);
        }
    }

    return (*msg = MSSUCC);
}






#argsused
IGRint DYmv_vec_dyn( DYinfo, 
                     to_point, 
                     mtx, 
                     objects, 
                     num_objects, 
                     buffers,
                     num_buffers, 
                     in_dummy1, 
                     in_dummy2, 
                     in_dummy3, 
                     out_dummy1,
                     dyn_mod_info, 
                     out_dummy3 )

struct dyn_args       *DYinfo;
struct EX_button      *to_point;
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
    IGRshort    mxtype, n;      /* matrix type for xform, index */
    IGRlong     sts, msg;       /* return codes */
    IGRdouble   delta[3],       /* delta vector between the two move points */
                vector2[3],
                point[3],
                proj_pt[3],
                t_parm;
    IGRmatrix   t_matrix;       /* transformation matrix */
    IGRboolean  b_status;
    struct IGRline line;


    /* add the delta of the vector to the from point to generate
     * a infinite line to project the to point onto
     */
    vector2[0] = DYinfo->from_point[0] + DYinfo->delta[0];
    vector2[1] = DYinfo->from_point[1] + DYinfo->delta[1];
    vector2[2] = DYinfo->from_point[2] + DYinfo->delta[2];

    line.point1 = &DYinfo->from_point[0];
    line.point2 = &vector2[0];

    point[0] = to_point->x;
    point[1] = to_point->y;
    point[2] = to_point->z;

    /* project to point on the direction vector */
    b_status = MAptlnproj(&msg,
                          &point[0],
                          &line,
                          &proj_pt[0],
                          &t_parm );

    /* get the vector between the to and from points on vector */
    delta[0] = proj_pt[0] - DYinfo->from_point[0];
    delta[1] = proj_pt[1] - DYinfo->from_point[1];
    delta[2] = proj_pt[2] - DYinfo->from_point[2];


    /*
     *  get a transformation matrix
     */
    if (MAtrlmx (&msg, delta, t_matrix))
    {
        if (DYinfo->mode == COPY_DYNAMICS)
        {
            /*
             *  transform the clone
             */
            MAtypemx (&msg, t_matrix, &mxtype);

            sts = om$send( msg = message GRgraphics.GRxform
                                (&msg, 
                                 &DYinfo->dyn_mod, 
                                 &mxtype,
                                  t_matrix, 
                                 &DYinfo->dyn_obj.objid ),
                           senderid = NULL_OBJID,
                           targetid = DYinfo->dyn_obj.objid,
                           targetos = DYinfo->dyn_obj.osnum );

            if (sts & msg & 1)
            {
                msg = MSSUCC;
                DYinfo->from_point[0] = to_point->x;
                DYinfo->from_point[1] = to_point->y;
                DYinfo->from_point[2] = to_point->z;
            }
        }
        else
        {
            /*
             *  combine located object's module matrix and the
             *  translation matrix
             */
            n = 4;
            MAmulmx(&msg, 
                    &n, 
                    &n, 
                    &n, 
                     t_matrix,
                     DYinfo->dyn_mod.md_env.matrix,
                     DYinfo->trans.matrix );

            MAtypemx(&msg, 
                      DYinfo->trans.matrix,
                     &DYinfo->trans.matrix_type );

            *dyn_mod_info = &DYinfo->trans;
        }
    }
    else
    {
        msg = MSFAIL;   /* MAtrlmx failed */
    }

    /*
     *  set up the buffer pointer
     */
    *objects = &DYinfo->dyn_obj;
    *num_objects = 1;
    return (msg);
}

end implementation CEO_GSLOCATE;
