/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRgetrang
        GRlnproject
        GRapprojpt
        GRptproject
        GRgetobjinfo
        GRclipto
        GRcoplanar
        GRdetplane
        GRinplane
        GRkeypoint
        GRprojpt
        GRptdis
        GRmodify

Description
        These methods are overridden so that they may be passed to the
        master geometry for the pattern.

History
        sdm     04/01/87    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"

method GRgetrang (IGRlong *msg;
                  IGRshort *mat_type;
                  IGRdouble *matrix;
                  IGRboolean *world;
                  GRrange range)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRgetrang
                          (msg, mat_type, matrix, world, range),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRlnproject (IGRlong *msg;
                    IGRshort *mx_type;
                    IGRmatrix matrix;
                    struct IGRline *line;
                    IGRpoint p1, p2;
                    IGRdouble *t;
                    struct GRparms *parms)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRgraphics.GRlnproject
                          (msg, mx_type, matrix, line, p1, p2, t, parms),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return(OMmsg);
}

method GRapprojpt (IGRlong *msg;
                   IGRshort *matrix_type;
                   IGRmatrix matrix;
                   struct GRparms *locate_parms;
                   struct IGRline *boreline;
                   IGRpoint proj_pt;
                   struct GRparms *proj_parms)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRgraphics.GRapprojpt
                          (msg, matrix_type, matrix, locate_parms,
                           boreline, proj_pt, proj_parms),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRptproject (IGRlong *msg; IGRshort *matrix_type;
                    IGRmatrix matrix; IGRpoint point,proj_pt;
                            struct GRparms *proj_parms)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRgraphics.GRptproject
                        (msg, matrix_type, matrix, point, proj_pt, proj_parms),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRgetobjinfo (IGRlong *msg; struct GRobj_info *info)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRgraphics.GRgetobjinfo (msg, info),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRclipto (IGRlong *msg; IGRchar *classname)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRclipto (msg, classname),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRcoplanar (IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; IGRshort *num_objects;
                   GRobjid *objid_ids; IGRdouble *tolerance; 
                   struct IGRplane *plane)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRcoplanar
                          (msg, matrix_type, matrix, num_objects, objid_ids,
                           tolerance, plane),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}
 
method GRdetplane (IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; struct IGRplane *plane)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRdetplane
                          (msg, matrix_type, matrix, plane),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRinplane (IGRlong *msg; IGRshort *matrix_type;
                  IGRmatrix matrix; struct IGRplane *plane; 
                  IGRdouble *tolerance; IGRshort *rel)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRinplane
                          (msg, matrix_type, matrix, plane, tolerance, rel),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRkeypoint (IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; struct IGRline *boreline; 
                   IGRpoint keypoint; struct GRparms *key_parm)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRkeypoint
                          (msg, matrix_type, matrix, boreline,
                           keypoint, key_parm),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRprojpt (IGRlong *msg; IGRshort *matrix_type;
                 IGRmatrix matrix; struct GRparms *locate_parms;
                 IGRpoint point,proj_pt; struct GRparms *proj_parms)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRprojpt
                          (msg, matrix_type, matrix, locate_parms,
                           point, proj_pt, proj_parms),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRptdis (IGRlong *msg; IGRshort *matrix_type;
                IGRmatrix matrix; IGRpoint point; 
                IGRdouble *distance)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRptdis
                          (msg, matrix_type, matrix, point, distance),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
    return (OMmsg);
}

method GRmodify (IGRlong *msg; struct GRmd_env *md_env;
                 struct GRparms *parms; IGRpoint point;
                 struct IGRline *boreline; GRobjid *newid)
{
    IGRlong         OMmsg;                 /* OM return code       */
    OM_S_CHANSELECT to_components;

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_components);

    OMmsg = om$send (msg = message GRvg.GRmodify
                          (msg, md_env, parms, point, boreline, newid),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);

    me->update = TRUE;

    return (OMmsg);
}

end implementation GRpa;
