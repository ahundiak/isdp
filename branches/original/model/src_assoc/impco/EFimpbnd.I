/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EFimpose_boundaries

Description
        This function associatively imposes boundaries on a surface.

Notes
        The fields in boundaries[0].geom_parms are expected to be
        valid.  They will be used during recompute to project from
        the curve onto the surface.

History
        mrm     06/03/91    creation
                06/26/91    change arglist to reflect arrow user interface
        DLB     01/04/92    set result.objid to null-objid if failure.
                            Also (re)set creator_id.
*/

class implementation EMSsfimpbnd;

#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"

/* Impose Surface Boundary recomputation info */

#if DEBUG
#define ERRORs(sts,msg,error_message,label)      \
    if (EMSmsgReport(sts,error_message,FALSE) || \
        EMSmsgReport(msg,error_message,FALSE))   \
                goto label;
#else
#define ERRORs(sts,msg,error_message,label)   if (!(sts & msg & 1)) goto label;
#endif

extern OMuword OPP_EMSsfimpbnd_class_id, OPP_NDnodein_class_id;

IGRlong EFimpose_boundaries(msg, options, surface, nboundaries, boundaries,
                            point, point_in_area, reverse, veclen, construct,
                            npoints, points, nbadcurves, badcurves, result)

IGRlong *msg;                       /* < return code */
IGRushort options;          /* > NULL || PLACE_NON_ASSOC */
struct GRlc_info *surface;          /* > surface upon which to impose */
IGRint nboundaries;                 /* > number of boundaries passed in */
struct GRlc_info *boundaries;       /* > curves to define boundaries */
IGRdouble *point;                   /* > point defining area/hole */
IGRboolean point_in_area;           /* > use point, or auto-nest */
IGRint reverse;                     /* > reverse vector for recompute? */
IGRdouble veclen;                   /* > distance to move along vector */
struct GRvg_construct *construct;   /* > construction information */
IGRlong *npoints;                   /* < passed out from EMimpose_boundaries */
IGRpoint **points;                  /* < passed out from EMimpose_boundaries */
IGRlong *nbadcurves;                /* < passed out from EMimpose_boundaries */
IGRlong *badcurves;                 /* < passed out from EMimpose_boundaries */
struct GRid *result;                /* < resultant surface */
{
    OMuword os, classid;
    OM_S_OBJID obj;
    IGRint sts, i, nparents, recompute;
    struct EMSobject_info *parents = NULL;
    struct EMSimpbndinfo info;
    struct EMSimpbndcmd cmdata;
    struct GRid active_state;
    extern OM_S_OBJID      current_creator;

    if (result->objid == NULL_OBJID)
    {
        recompute = FALSE;

        /* get the active state to hook up as a parent */

        sts = om$send(msg = message EMSsurface.EMgetactiveid
                           (msg, &active_state, NULL),
                      senderid = NULL_OBJID,
                      targetid = surface->located_obj.objid,
                      targetos = surface->located_obj.osnum);

        ERRORs(sts, *msg, "EMgetactiveid", wrapup);
            
        result->osnum = active_state.osnum;

        /* construct a surface boundary object */

        sts = om$construct(classid = OPP_EMSsfimpbnd_class_id,
                           osnum = result->osnum,
                           p_objid = &result->objid);

        ERRORs(sts, EMS_S_Success, "EFimpose_boundaries om$construct", wrapup);
    }
    else
    {
        recompute = TRUE;
    }

    /* Reformat the parent information for the init message.  The
    /* parents are the curves representing the boundaries, the surface
    /* on which to impose the boundaries, and the state object */

    nparents = nboundaries + 2;
    parents = (struct EMSobject_info *)alloca
	      (sizeof(struct EMSobject_info) * nparents);
    for (i = 0; i < nboundaries; i++)
    {
        parents[i].grid = boundaries[i].located_obj;
        parents[i].env = boundaries[i].module_info;
    }

    parents[nparents - 2].grid = surface->located_obj;
    parents[nparents - 2].env = surface->module_info;

    if (!recompute)
    {
        parents[nparents - 1].grid = active_state;
        parents[nparents - 1].env = surface->module_info;
    }
    else
    {
        parents[nparents - 1].grid.objid = NULL_OBJID;
    }
    
    /* make sure the surface object can participate in an associative
    /* relationship */

    os = surface->located_obj.osnum;
    obj = surface->located_obj.objid;
    
    sts = om$get_classid(osnum = os, objid = obj, p_classid = &classid);
    ERRORs(sts, EMS_S_Success, "unknown class", wrapup);

    sts = om$is_ancestry_valid(superclassid = OPP_NDnodein_class_id,
                               subclassid = classid);

    if (sts == OM_I_INVANCESTRY)
    {
        sts = om$send(msg = message EMSsurface.EMtransform_to_associative
                           (msg, &parents[nparents - 2].grid.objid),
                      senderid = NULL_OBJID,
                      targetid = obj,
                      targetos = os);

        ERRORs(sts, *msg, "EMtransform_to_asssociative", wrapup);
    }

    /* set up the information to be stored in the object */

    i = sizeof(struct EMSimpbndinfo);
    info.reverse = reverse;
    info.point_in_area = point_in_area;
    memcpy(info.uv_point, point, sizeof(IGRdouble) * 2);
    BSEXTRACTPAR(msg, BSTOLCHRDHT, info.cht);
    info.veclen = veclen;
    info.parms = boundaries[0].geom_parms;

    /* Pass some data in to init_assoc that will be passed through
    /* construct_assoc and end up down in EMimpose_boundaries.  This is
    /* stuff that is used by the command object.  It is kludged up for
    /* now to use construct->class_attr, but should eventually use a new
    /* argument that will eventually be provided to init_assoc and
    /* construct_assoc */

    cmdata.npoints = npoints;
    cmdata.points = points;
    cmdata.nbadcurves = nbadcurves;
    cmdata.badcurves = badcurves;
    construct->class_attr = (IGRchar *)&cmdata;

    /* initialize the associative composite surface object */

    current_creator = result->objid;

    sts = om$send(msg = message EMSassoc.EMinit_associative
                       (msg,                /* return code */
                        NULL,	            /* options */
                        nparents,           /* number of parents */
                        parents,            /* parent information */
                        EMS_ASno_type,      /* type not needed at this class */
                        i,                  /* size of info to store */
                        (IGRchar *)&info,   /* recompute info */
                        construct),         /* construction parameters */
                  senderid = NULL_OBJID,
                  targetid = result->objid,
                  targetos = result->osnum);

    current_creator = NULL_OBJID;


    ERRORs(sts, *msg, "EFimpose_boundaries EMinit_associative", wrapup);

    if (!(1 & sts & *msg) || *msg == EMS_I_NoMoreLoops)
    {
      result->objid = NULL_OBJID;
    }
    else if (options & EFfunc_PLACE_NON_ASSOC)
    {
      IGRlong loc_msg=EMS_S_Success, loc_sts=OM_S_SUCCESS;
      loc_sts = om$send(msg = message NDnode.NDmove_to_root(&loc_msg, result,
                              &surface->module_info),
                        senderid = NULL_OBJID,
                        targetid = result->objid,
                        targetos = result->osnum);
      if (!(1 & loc_msg & loc_sts)) {sts=loc_sts; *msg=loc_msg; goto wrapup;}
    }

wrapup:

    return(sts);
}


end implementation EMSsfimpbnd;


