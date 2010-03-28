/* #######################    APOGEE COMPILED   ######################## */
/*
Function
        COch_cp_parallel

Description
        This function offsets the object found in the located object
        information of *events[0] according to the other events described
        below.  On exit the channel will contain only the new object.

Synopsis
        o   IGRlong *msg                return code
                                          MSSUCC - success
                                          MSFAIL - failure
        i   OM_S_OBJID caller_id        calling object object id
        i   OMuword caller_os           calling object osnum
        i   struct GRevent *events[]    user inputs defining offset
                                          0  located object information
                                          1  distance to offset (pt or value)
                                          2  pt defining direction and plane
                                             of offset

History
        mrm     09/13/88    creation
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "comn.h"
#include "dpstruct.h"

from GRgraphics import GRdelete;
from GRcurve import GRcpparallel;

extern IGRboolean MApapromx(), MAunitvc();

#argsused
IGRint COch_cp_parallel (msg, caller_id, caller_os, const_mod, events,
                         apparent, new_object)

IGRlong             *msg;
OM_S_OBJID           caller_id;
OMuword              caller_os;
struct GRmd_env     *const_mod;
struct GRevent      *events[];
IGRboolean           apparent;
GRobjid             *new_object;
{
    IGRlong              i;          /* variable */
    IGRlong             sts;        /* return code */
    IGRdouble          *p_dis_value;/* distance value to offset */
    IGRpoint            pts[4];     /* for borelines */
    IGRpoint            pl_pt;      /* point on view plane */
    IGRvector           pl_vc;      /* vector normal to view plane */
    IGRvector           uvc;        /* unitized view vector */
    IGRmatrix           wtv;        /* view matrix */
    IGRmatrix           wtvp;       /* world-to-view plane matrix */
    struct var_list     varlist[3]; /* for gragad inquiry */
    struct IGRline      dir_line;   /* boreline defining offset direction */
    struct IGRline      dis_line;   /* boreline defining offset distance */
    struct IGRline     *p_dis_line; /* points to distance boreline */
    struct IGRplane     view_plane; /* plane of view of offset */
    struct GRmd_env    *lc_mod;     /* located object's environment */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    /*
     *  get the world-to-view matrix and view plane
     */

    view_plane.point = pl_pt;
    view_plane.normal = pl_vc;
    varlist[0].var = WLD_TO_VIEW;
    varlist[0].var_ptr = (IGRchar *)wtv;
    varlist[0].num_bytes = sizeof (IGRmatrix);
    varlist[0].bytes_returned = &i;
    varlist[1].var = VIEW_PLANE;
    varlist[1].var_ptr = (IGRchar *)&view_plane;
    varlist[1].num_bytes = sizeof (struct IGRplane);
    varlist[1].bytes_returned = &i;
    varlist[2].var = END_PARAM;

    dp$inq_set_gragad (msg = msg,
                       osnum = events[2]->event.button.osnum,
                       gragad_objid = events[2]->event.button.objid,
                       which_error = &i,
                       var_list = varlist);

    /*
     *  get the direction boreline
     */

    dir_line.point1 = pts[0];
    dir_line.point2 = pts[1];
    GRbrlnconstr (msg, &events[2]->event.button.x, wtv, &dir_line);

    /*
     *  determine distance
     */

    if (events[1]->response == EX_DATA)
    {
        dis_line.point1 = pts[2];
        dis_line.point2 = pts[3];
        GRbrlnconstr (msg, &events[1]->event.button.x, wtv, &dis_line);
        p_dis_line = &dis_line;
        p_dis_value = NULL;
    }
    else if (events[1]->response == EX_VALUE)
    {    
        p_dis_value = &events[1]->event.value;
        p_dis_line = NULL;
    }
    else
    {
#ifdef DEBUG
        printf ("COch_cp_parallel: unknown distance response type = %d\n", events[1]->response);
#endif
        *msg = MSINARG;
        goto finish;
    }

    /*
     *  get a matrix which projects into the view plane
     */

    if (! MAunitvc (msg, pl_vc, uvc))
    {
#ifdef DEBUG
        printf ("COch_cp_parallel: MAunitvc failed (%#x)\n", *msg);
#endif
        *msg = MSFAIL;
        goto finish;
    }

    if (! MApapromx (msg, uvc, &view_plane, wtvp))
    {
#ifdef DEBUG
        printf ("COch_cp_parallel: MApapromx failed (%#x)\n", *msg);
#endif
        *msg = MSFAIL;
        goto finish;
    }

    /*
     *  offset the object
     */

    lc_mod = &events[0]->located_object[0].module_info;

    sts = om$send (msg = message GRcurve.GRcpparallel
                        (msg, &lc_mod->md_env.matrix_type,
                         lc_mod->md_env.matrix, const_mod, &dir_line,
                         p_dis_line, p_dis_value, &apparent, wtvp, new_object),
                   senderid = caller_id,
                   targetid = events[0]->located_object[0].located_obj.objid,
                   targetos = events[0]->located_object[0].located_obj.osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COch_cp_parallel: GRcurve.GRcpparallel failed\n");
#endif
        goto finish;
    }

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COch_cp_parallel: msg = %#x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    if ((*msg & 1) && (!(sts & 1)))
    {
        *msg = sts;
    }

    return (*msg & 1);
}

/*
Name
        COcppdyn

Description
        This function is called by dp$dynamics during copy parallel dynamics.

History
        mrm     12/20/88    creation
*/

#argsused
IGRint COcppdyn (cppinfo, to_point, mtx, objects, num_objects, buffers,
                 num_buffers, in_dummy1, in_dummy2, in_dummy3, out_dummy1,
                 dyn_mod_info, out_dummy3)

struct COcppdy        *cppinfo;
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
    /* delete any previous copy */

    if (cppinfo->new_object.objid != NULL_OBJID)
    {
        om$send (msg = message GRgraphics.GRdelete
                      (cppinfo->msg, &cppinfo->const_mod),
                 senderid = cppinfo->caller_id,
                 targetid = cppinfo->new_object.objid,
                 targetos = cppinfo->new_object.osnum);
    }

    /* produce a new copy */

    if (cppinfo->events[1]->response == EX_DATA)
    {
        cppinfo->events[1]->event.button = *to_point;
    }
    cppinfo->events[2]->event.button = *to_point;

    COch_cp_parallel (cppinfo->msg, cppinfo->caller_id, cppinfo->caller_os,
                      &cppinfo->const_mod, cppinfo->events, 
                      cppinfo->apparent, &cppinfo->new_object.objid);

    if (*cppinfo->msg & 1)
    {
        /* set up return info */

        *objects = &cppinfo->new_object;
        *num_objects = 1;
        return (MSSUCC);
    }

    return (MSFAIL);
}

/*
Name
        COcpplcdyn

Description
        This function is called from locate for dynamics.
*/

#argsused
IGRint COcpplcdyn (dynobj, locevent, cppinfo)

struct GRid     *dynobj;
struct GRevent  *locevent;
struct COcppdy  *cppinfo;

{
    IGRboolean          dyn_on;         /* is dynamics on? */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags */
    IGRint              COcppdyn();     /* dynamics function */
    IGRint              i;              /* variables */
    struct GRevent      dyevent;        /* distance event */

    DPdynflags (cppinfo->msg, &inquire, &dyn_on, NULL);
    if (!dyn_on) goto finish;

    dyevent.response = EX_DATA;
    cppinfo->events[0] = locevent;
    cppinfo->events[1] = &dyevent;
    cppinfo->events[2] = &dyevent;
    cppinfo->new_object.objid = NULL_OBJID;
    i = sizeof (IGRboolean);
    gr$get_apparent_flag (msg = cppinfo->msg,
                          sizbuf = &i,
                          buffer = &cppinfo->apparent,
                          nret = &i);

    dp$dynamics (dyn_fun = COcppdyn, information = cppinfo);

    if (cppinfo->new_object.objid != NULL_OBJID)
    {
        om$send (msg = message GRgraphics.GRdelete
                      (cppinfo->msg, &cppinfo->const_mod),
                 senderid = cppinfo->caller_id,
                 targetid = cppinfo->new_object.objid,
                 targetos = cppinfo->const_mod.md_id.osnum);
    }
finish:
    return (*cppinfo->msg);
}


end implementation CEO_GSLOCATE;
