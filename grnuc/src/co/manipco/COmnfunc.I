/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COmnfunc

Description
        This file contains noninteractive functions which accept arrays
        of pointers to events to build a transformation matrix.  These
        functions correspond to and are called by the generic manipulation
        commands to build their transformation matrices.  Since the output
        matrices of some functions would be duplicates, such as Align and
        Copy and Align, the copy version simply invokes the non-copy
        version (e.g. COmn_cp_align calls COmn_align).

Synopsis
        All routines have an argument list of the form shown below.  See
        the individual function headers for what is expected in the
        event array.

        IGRlong COmn_function (msg, caller_id, caller_os, events, matrix)

        IGRlong         ()          o - TRUE if successful
                                        FALSE if unsuccessful
        IGRlong        *msg;        o - return code
                                        MSSUCC if successful
        OM_S_OBJID      caller_id   i - calling object's id
        OMuword         caller_os   i - calling object's id
        struct GRevent *events[]    i - array of pointers to events
        IGRdouble      *matrix      o - transformation matrix

History
        mrm     07/28/88    created by extracting code from existing commands
                10/11/89    reworked COmn_align
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "madef.h"
#include "grdpbmacros.h"

from IGEgragad import DPinrot;

extern IGRboolean MAang2vc();
extern IGRboolean MArang2vc();
extern IGRboolean MAcrossvc();
extern IGRboolean MAdetplane();
extern IGRboolean MAgrefmx();
extern IGRboolean MAgrotmx(); 
extern IGRboolean MAgscamx(); 
extern IGRboolean MAidmx();
extern IGRboolean MAlpfrln(); 
extern IGRboolean MAmulmx();
extern IGRboolean MAptsxform(); 
extern IGRboolean MAsubvc(); 
extern IGRboolean MAtrlmx();
extern IGRboolean MAtrnmx(); 
extern IGRboolean MAwclsmx();
extern IGRboolean MA3protmx();
extern double fabs();


/* 
Function
        COmn_move
        COmn_copy

Description
        This function builds a matrix for translation from the point
        in events[0] to the point in events[1].

Synopsis
        events[0] - from point
        events[1] - destination point
*/

#argsused
IGRint COmn_move (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRdouble   delta[3];   /* translation vector */

    /* get the vector between the points */

    delta[0] = events[1]->event.button.x - events[0]->event.button.x;
    delta[1] = events[1]->event.button.y - events[0]->event.button.y;
    delta[2] = events[1]->event.button.z - events[0]->event.button.z;

    /* get a transformation matrix */

    MAtrlmx (msg, delta, matrix);

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COmn_move: msg = %x\n", *msg);
#endif

    return (*msg & 1);
}

IGRint COmn_copy (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_move (msg, caller_id, caller_os, events, matrix));
}


/*
Function
        COmn_align
        COmn_cp_align

Description
        This function builds a matrix to move and rotate an element
        through space from a reference position and orientation to a new
        position and orientation.

Synopsis
        events[0] - origin of first orientation
        events[1] - second point defining first orientation
        events[2] - third point defining first orientation
        events[3] - origin of second orientation
        events[4] - second point defining second orientation
        events[5] - third point defining second orientation
*/

#argsused
IGRint COmn_align (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRint          i;          /* index */
    IGRdouble       tol = 0.3;  /* tolerance for planarity */
    IGRdouble       angle[3];   /* also contains sine and cosine */
    IGRvector       vector[3];  /* working vectors */
    IGRvector       plvec[2];   /* plane vectors */
    IGRpoint        plpt[2];    /* plane points */
    IGRpoint        opts[6];    /* orientation points */
    IGRpoint        pts[2];     /* working points */
    IGRmatrix       t_matrix;   /* transformation matrix */
    IGRmatrix       r1_matrix;  /* rotation matrix */
    IGRmatrix       r2_matrix;  /* rotation matrix */
    IGRmatrix       tmp_matrix; /* combined matrices */
    struct IGRplane plane1;     /* first orientation */
    struct IGRplane plane2;     /* second orientation */

    for (i = 0; i < 6; i++)
    {
        opts[i][0] = events[i]->event.button.x;
        opts[i][1] = events[i]->event.button.y;
        opts[i][2] = events[i]->event.button.z;
    }

    /*
     *  translate the old system so that its origin coincides
     *  with the origin of the new system
     */

    MAidmx (msg, t_matrix);
    t_matrix[3]  = opts[3][0] - opts[0][0];
    t_matrix[7]  = opts[3][1] - opts[0][1];
    t_matrix[11] = opts[3][2] - opts[0][2];

    /*
     *  determine orientation planes
     */

    i = 3;
    plane1.point = plpt[0];
    plane1.normal = plvec[0];

    if (! MAdetplane (msg, opts[0], &i, &tol, &plane1))
    {
        goto finish;
    }
                
    plane2.point = plpt[1];
    plane2.normal = plvec[1];

    if (! MAdetplane (msg, opts[3], &i, &tol, &plane2))
    {
        goto finish;
    }

    /*
     *  rotate planes into alignment
     */

    if (! MAcrossvc (msg, plane1.normal, plane2.normal, vector[0]))
    {
        goto finish;
    }

    if (*msg == MAIDGENRAT)     /* same vector (same plane) */
    {
        vector[0][0] = plvec[0][0];
        vector[0][1] = plvec[0][1];
        vector[0][2] = plvec[0][2];
    }

    if (! MArang2vc (msg, plane1.normal, plane2.normal, vector[0], angle))
    {
        goto finish;
    }

    if (angle[0] == 0 || angle[0] == PI)
    {
        MAidmx (msg, r1_matrix);   /* already in the same plane */
    }
    else
    {
        if (! MAgrotmx (msg, vector[0], opts[3], angle, r1_matrix))
        {
            goto finish;
        }
    }

    /*
     *  transform the first x-axis into the same space as the second x-axis
     */

    i = 2;

    if (! MAptsxform (msg, &i, t_matrix, opts[0], pts[0]))
    {
        goto finish;
    }

    if (! MAptsxform (msg, &i, r1_matrix, pts[0], pts[0]))
    {
        goto finish;
    }

    vector[0][0] = pts[1][0] - pts[0][0];
    vector[0][1] = pts[1][1] - pts[0][1];
    vector[0][2] = pts[1][2] - pts[0][2];

    vector[1][0] = opts[4][0] - opts[3][0];
    vector[1][1] = opts[4][1] - opts[3][1];
    vector[1][2] = opts[4][2] - opts[3][2];

    /*
     *  rotate origin->first point vectors into alignment
     */

    if (! MAcrossvc (msg, vector[0], vector[1], vector[2]))
    {
        goto finish;
    }

    if (*msg == MAIDGENRAT)     /* same vector (same plane) */
    {
        vector[2][0] = plvec[1][0];
        vector[2][1] = plvec[1][1];
        vector[2][2] = plvec[1][2];
    }

    if (! MArang2vc (msg, vector[0], vector[1], vector[2], angle))
    {
        goto finish;
    }

    if (! MAgrotmx (msg, vector[2], opts[3], angle, r2_matrix))
    {
        goto finish;
    }
                
    /*
     *  combine the matrices
     */

    {  /*Call with *short not *int - SUN PORT - DLB 10/25/91*/
      IGRshort short_i=4;

      if (! MAmulmx (msg, &short_i, &short_i, &short_i, r2_matrix, r1_matrix, 
	             tmp_matrix))
      {
          goto finish;
      }
                
      MAmulmx (msg, &short_i, &short_i, &short_i, tmp_matrix, t_matrix, matrix);
    }

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COmn_align: msg = %x\n", *msg);
#endif

    return (*msg & 1);
}

IGRint COmn_cp_align (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_align (msg, caller_id, caller_os, events, matrix));
}


/*
Function
        COmn_mirrorvh

Description
        This function builds a matrix to reflect objects about a vertical
        or horizontal line (actually a plane extending out of and into the
        view).  The function assumes that the first event contains a valid
        data point and window info.  This function is called by COmn_mirrorv,
        COmn_cp_mirrorv, COmn_mirrorh, and COmn_cp_mirrorh, since the only
        difference in the functions is which vector from the view rotation
        matrix to use as the normal to the plane.

Synopsis
        events[0] - point defining reflection line (plane).
        normal - index into view matrix for vector normal to reflection plane
*/

#argsused
IGRint COmn_mirrorvh (msg, caller_id, caller_os, events, matrix, normal)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
IGRint          normal;
{
    IGRlong         sts;
    IGRpoint        origin;
    IGRmatrix       wtv;
    struct IGRplane plane;

    /*
     *  get the world to view rotation matrix
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, wtv),
                   senderid = caller_id,
                   targetid = events[0]->event.button.objid,
                   targetos = events[0]->event.button.osnum);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  get the plane of reflection using a point on the reflection plane
     *  (the accept point) and a vector normal to the reflection plane
     */

    origin[0] = events[0]->event.button.x;
    origin[1] = events[0]->event.button.y;
    origin[2] = events[0]->event.button.z;
        
    plane.normal = &wtv[normal];
    plane.point = origin;

    /* 
     *  get transformation matrix
     */

    MAgrefmx (msg, &plane, matrix);

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COmn_mirrorvh failed\n");
    if (!(*msg & 1)) printf ("COmn_mirrorvh: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}

IGRint COmn_mirrorv (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_mirrorvh (msg, caller_id, caller_os, events, matrix, 0));
}

IGRint COmn_cp_mirrorv (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_mirrorvh (msg, caller_id, caller_os, events, matrix, 0));
}

IGRint COmn_mirrorh (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_mirrorvh (msg, caller_id, caller_os, events, matrix, 4));
}

IGRint COmn_cp_mirrorh (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_mirrorvh (msg, caller_id, caller_os, events, matrix, 4));
}


/*
Function
        COmn_mirrorl
        COmn_cp_mirrorl

Description
        This function builds a matrix to reflect objects about a line in
        space (actually a plane extending out of and into the view).  The
        second event is used to determine the plane of the view and the
        plane of the reflection.

Synopsis
        events[0] - first point of mirror line
        events[1] - second point of mirror line
*/

#argsused
IGRint COmn_mirrorl (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRlong         sts;
    IGRpoint        pt1, pt2;
    IGRvector       vector;
    IGRmatrix       wtv;
    struct IGRline  line;
    struct IGRplane plane;

    /*
     *  get the world to view rotation matrix
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, wtv),
                   senderid = caller_id,
                   targetid = events[1]->event.button.objid,
                   targetos = events[1]->event.button.osnum);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  build the reflection plane
     */

    line.point1 = pt1;
    line.point2 = pt2;
    plane.point = pt1;
    plane.normal = vector;
    pt1[0] = events[0]->event.button.x;
    pt1[1] = events[0]->event.button.y;
    pt1[2] = events[0]->event.button.z;
    pt2[0] = events[1]->event.button.x;
    pt2[1] = events[1]->event.button.y;
    pt2[2] = events[1]->event.button.z;

    if (! MAlpfrln (msg, &line, pt1, &wtv[8], &line))
    {
        goto finish;
    }

    if (! MAsubvc (msg, pt2, pt1, vector))
    {
        goto finish;
    }

    /* 
     *  get transformation matrix
     */

    MAgrefmx (msg, &plane, matrix);

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COmn_mirrorl failed\n");
    if (!(*msg & 1)) printf ("COmn_mirrorl: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}

IGRint COmn_cp_mirrorl (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_mirrorl (msg, caller_id, caller_os, events, matrix));
}


/*
Function
        COmn_rotate_aa
        COmn_cp_rotate_aa

Description
        This function builds a rotation matrix to rotate at the active
        angle about the point in events[0], with the rotation taking
        place in the plane of the view in which the point was entered.

Synopsis
        events[0] - point to rotate about; use plane of view in which the
                    point was entered
*/

#argsused
IGRint COmn_rotate_aa (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRlong     sts, size;
    IGRdouble   aa;
    IGRpoint    origin;
    IGRmatrix   wtv;

    /*
     *  get the world to view rotation matrix (view normal is fourth column)
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, wtv),
                   senderid = caller_id,
                   targetid = events[0]->event.button.objid,
                   targetos = events[0]->event.button.osnum);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  get the active angle
     */

    size = sizeof (aa);

    gr$get_active_angle (msg = msg,
                         sizbuf = &size,
                         buffer = &aa,
                         nret = &size);

    if (!(*msg & 1))
    {
        goto finish;
    }

    /*
     *  get a rotation matrix
     */
                        
    origin[0] = events[0]->event.button.x;
    origin[1] = events[0]->event.button.y;
    origin[2] = events[0]->event.button.z;

    MAgrotmx (msg, &wtv[8], origin, &aa, matrix);

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COmn_rotate_aa failed\n");
    if (!(*msg & 1)) printf ("COmn_rotate_aa: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}

IGRint COmn_cp_rotate_aa (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_rotate_aa (msg, caller_id, caller_os, events, matrix));
}


/*
Function
        COmn_rotate_ax
        COmn_cp_rotate_ax

Description
        This function builds a matrix which will rotate objects about
        the axis in space specified by the points in events[0] and [1].

Synopsis
        events[0] - point one of axis to rotate about
        events[1] - point two of axis to rotate about
*/

#ifndef IDRAW

#argsused
IGRint COmn_rotate_ax (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRlong         size;       /* for dpb call */
    IGRdouble       angle;      /* active angle from the dpb */
    IGRpoint        pt;         /* second point of rotation axis */
    IGRvector       vector;     /* rotation vector */

    size = sizeof (angle);

    gr$get_active_angle (msg = msg,
                         sizbuf = &size,
                         buffer = &angle,
                         nret = &size);
    if (*msg & 1)
    {
        pt[0] = events[1]->event.button.x;
        pt[1] = events[1]->event.button.y;
        pt[2] = events[1]->event.button.z;
        vector[0] = pt[0] - events[0]->event.button.x;
        vector[1] = pt[1] - events[0]->event.button.y;
        vector[2] = pt[2] - events[0]->event.button.z;

        MAgrotmx (msg, vector, pt, &angle, matrix);
    }

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COmn_rotate_aa: msg = %x\n", *msg);
#endif

    return (*msg & 1);
}

IGRint COmn_cp_rotate_ax (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_rotate_ax (msg, caller_id, caller_os, events, matrix));
}

#endif IDRAW


/*
Function
        COmn_rotate_3pts
        COmn_cp_rotate_3pts

Description
        This function builds a matrix which defines a rotation by the
        angle between the vectors events[0]->events[1] and
        events[0]->events[2].  The rotation takes place in the plane
        derived from the view of events[0].

Synopsis
        events[0] - origin of rotation
        events[1] - defines first vector
        events[2] - defines second vector
*/

#argsused
IGRint COmn_rotate_3pts (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRint              i;
    IGRlong             sts;
    IGRdouble           pts[9], origin[3];
    IGRdouble           angle[3];
    IGRmatrix           wtv, vtw, wtl;

    sts = OM_S_SUCCESS;

    pts[0] = events[1]->event.button.x;
    pts[1] = events[1]->event.button.y;
    pts[2] = events[1]->event.button.z;
    pts[3] = events[0]->event.button.x;
    pts[4] = events[0]->event.button.y;
    pts[5] = events[0]->event.button.z;
    pts[6] = events[2]->event.button.x;
    pts[7] = events[2]->event.button.y;
    pts[8] = events[2]->event.button.z;
    origin[0] = events[0]->event.button.x;
    origin[1] = events[0]->event.button.y;
    origin[2] = events[0]->event.button.z;

    /*
     *  get the world to view rotation matrix 
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, wtv),
                   senderid = caller_id,
                   targetid = events[2]->event.button.objid,
                   targetos = events[2]->event.button.osnum);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  get the view to world rotation matrix
     */

    {
      IGRshort short_i=4;    /*DLB - SUN PORT 10/25/91*/

      if (! MAtrnmx (msg, &short_i, wtv, vtw))
      {
        goto finish;
      }
    }

    /*
     *  build a world to local matrix
     */

    if (! MAwclsmx (msg, &pts[3], vtw, wtl))
    {
        goto finish;
    }

    /*
     *  transform the points to the local system
     */

    i=3; 

    if (! MAptsxform (msg, &i, wtl, pts, pts))
    {
        goto finish;
    }

    /*
     *  get the vectors defining the angle
     */

    pts[0] -= pts[3];  pts [1] -= pts[4];  pts[2] = 0;
    pts[6] -= pts[3];  pts [7] -= pts[4];  pts[8] = 0;

    /*
     *  if vector 1 is zero, let vector 1 be the unit x-vector
     */

    if ((pts[0] == 0.0) && (pts[1] == 0.0))
    {
        pts[0] = 1.0;
    }

    /*
     *  get the angle between the vectors
     */

    if (!MAang2vc (msg, pts, &pts[6], angle))
    {
        goto finish;
    }

    /*
     *  get the rotation matrix
     */

    MAgrotmx (msg, &wtv[8], origin, angle, matrix);

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COmn_rotate_3pts failed\n");
    if (!(*msg & 1)) printf ("COmn_rotate_3pts: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}

IGRint COmn_cp_rotate_3pts (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_rotate_3pts (msg, caller_id, caller_os, events, matrix));
}


/*
Function
        COmn_scale_as
        COmn_cp_scale_as

Description
        This function builds a matrix for scaling at the active scale.  The
        point in events[0] is assumed to contain valid window information.

Synopsis
        events[0] - origin of scale
*/

#argsused
IGRint COmn_scale_as (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRint              size;
    IGRlong             sts;
    IGRpoint            pt;
    IGRdouble           scale[4];
    IGRmatrix           wtv;
    struct GRdpb_scale  dpb_scale;

    /*
     *  get the world to view rotation matrix 
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, wtv),
                   senderid = caller_id,
                   targetid = events[0]->event.button.objid,
                   targetos = events[0]->event.button.osnum);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  get the active scale
     */

    size = sizeof (scale);

    gr$get_active_scale (msg = msg,
                         sizbuf = &size,
                         buffer = &dpb_scale,
                         nret = &size);

    if (!(*msg & 1))
    {
        goto finish;
    }

    scale[0] = (dpb_scale.Active_xscale) ? dpb_scale.Active_xscale : 1.0;
    scale[1] = (dpb_scale.Active_yscale) ? dpb_scale.Active_yscale : 1.0;
    scale[2] = (dpb_scale.Active_zscale) ? dpb_scale.Active_zscale : 1.0;
    scale[3] = 1.0;

    /*
     *  get a scaling matrix
     */
    
    pt[0] = events[0]->event.button.x;
    pt[1] = events[0]->event.button.y;
    pt[2] = events[0]->event.button.z;

    MAgscamx (msg, wtv, pt, scale, matrix);

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COmn_scale_as failed\n");
    if (!(*msg & 1)) printf ("COmn_scale_as: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}

IGRint COmn_cp_scale_as (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_scale_as (msg, caller_id, caller_os, events, matrix));
}


/*
Function
        COmn_scale_3pts
        COmn_cp_scale_3pts

Description
        This function builds a matrix which scales by the ratio of the
        vectors from events[0] (origin) -> events[1] (reference point 1)
        and events[0] -> events[2] (reference point 2).  The scale takes
        place in the plane of the view of the origin.

Synopsis
        events[0] - origin
        events[1] - reference point 1
        events[2] - reference point 2
*/

#ifndef IDRAW

IGRint COmn_scale_3pts (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    IGRint              i, j;
    IGRlong             sts;
    IGRdouble           pts[9], origin[3], vectors[6];
    IGRdouble           scale[4];
    IGRmatrix           wtv, vtw, wtl;

    sts = OM_S_SUCCESS;

    pts[0] = events[1]->event.button.x;
    pts[1] = events[1]->event.button.y;
    pts[2] = events[1]->event.button.z;
    pts[3] = events[0]->event.button.x;
    pts[4] = events[0]->event.button.y;
    pts[5] = events[0]->event.button.z;
    pts[6] = events[2]->event.button.x;
    pts[7] = events[2]->event.button.y;
    pts[8] = events[2]->event.button.z;
    origin[0] = events[0]->event.button.x;
    origin[1] = events[0]->event.button.y;
    origin[2] = events[0]->event.button.z;

    /*
     *  get the world to view rotation matrix 
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, wtv),
                   senderid = caller_id,
                   targetid = events[2]->event.button.objid,
                   targetos = events[2]->event.button.osnum);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  get the view to world rotation matrix
     */

    {
      IGRshort short_i = 4; /*DLB - SUN PORT 10/25/91*/

      if (! MAtrnmx (msg, &short_i, wtv, vtw))
      {
          goto finish;
      }
    }

    /*
     *  build a world to local matrix
     */

    if (! MAwclsmx (msg, &pts[3], vtw, wtl))
    {
        goto finish;
    }

    /*
     *  transform the points to the local system
     */

    i = 3;

    if (! MAptsxform (msg, &i, wtl, pts, pts))
    {
        goto finish;
    }

    /*
     *  get the vectors defining the scale ratios
     */

    vectors[0] = pts[0] - pts[3];
    vectors[1] = pts[1] - pts[4];
    vectors[2] = pts[2] - pts[5];
    vectors[3] = pts[6] - pts[3];
    vectors[4] = pts[7] - pts[4];
    vectors[5] = pts[8] - pts[5];

    /*
     *  get the scale, checking for zero vectors
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
    
    MAgscamx (msg, wtv, origin, scale, matrix);

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COmn_scale_3pts failed\n");
    if (!(*msg & 1)) printf ("COmn_scale_3pts: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}

IGRint COmn_cp_scale_3pts (msg, caller_id, caller_os, events, matrix)

IGRlong        *msg;
OM_S_OBJID      caller_id;
OMuword         caller_os;
struct GRevent *events[];
IGRdouble      *matrix;
{
    return (COmn_scale_3pts (msg, caller_id, caller_os, events, matrix));
}

#endif IDRAW

end implementation CEO_GSLOCATE;

