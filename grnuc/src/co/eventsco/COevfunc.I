/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COevfunc

Synopsis
        IGRlong COev_pt_xxx (msg, caller, events)

        IGRlong         *msg;       return code
        struct GRid     *caller;    calling object's id
        struct GRevent  events[];   event array

Description
        This file contains functions which obtain special points from
        objects presumed to be located by the calling object.  Certain
        assuptions are made about the "events" argument.  The first
        event should always contain the first located object event (the
        accept event from the locate filter).  If more than one object
        is located, the second object located should be in the second
        event, and so on.  The point generated (along with any other
        pertinent information) is always returned in the first event.

History
        mrm     02/17/88    creation
	jhw	11/7/88     modified COev_pt_intersection so it uses the
                            locate points to identify the segment to be 
                            intersected. (TR88N2918)
        scw     07/13/92    ansi conversion

                            
*/

class implementation COevgen;

#include "coimport.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "comiscmac.h"

#define LOCATED_OBJECT events[0].located_object[0]

from GRvg      import GRkeypoint, GRptproject;
from GRcurve   import GRendpoint, GRmidpoint;
from IGEgragad import DPinrot;
from GRvg import GRcentcurv;


/*
Name
        COev_pt_angle_from 

Description
        This function returns a point on the located object with a subtype
        of angle from.

Synopsis
        The first element in the input events array should contain a
        located object with the proj_pnt info filled in.  The second element
        should contain the desired angle in the value[0] field.
*/


#argsused
IGRlong COev_pt_angle_from (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    events[0].event.button.x = LOCATED_OBJECT.proj_pnt[0];
    events[0].event.button.y = LOCATED_OBJECT.proj_pnt[1];
    events[0].event.button.z = LOCATED_OBJECT.proj_pnt[2];
    events[0].subtype = GRst_ANGLE_FROM;
    events[0].num_id = 1;
    events[0].num_val = 1;
    events[0].response = DATA;
    events[0].values[0] = events[1].event.value;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("CO_ev_pt_angle_from failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_angle_to

Description
        This function returns a point on the located object with a subtype
        of angle to.

Synopsis
        The first element in the input events array should contain a
        located object with the proj_pnt info filled in.  The second element
        should contain the desired angle in the value[0] field.
*/

IGRlong COev_pt_angle_to (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    sts = COev_pt_angle_from (msg, caller, events);

    events[0].subtype = GRst_ANGLE_TO;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_angle_to failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_center

Description
        This function returns a point at the center of curvature of the
        located object.

Synopsis
        The first element in the events array should contain a located object.
*/

IGRlong COev_pt_center (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */


    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    events[0].subtype = GRst_CENTER;

    sts = om$send (msg = message GRvg.GRcentcurv
                        (msg,
                         &LOCATED_OBJECT.module_info.md_env.matrix_type,
                         LOCATED_OBJECT.module_info.md_env.matrix,
                         &LOCATED_OBJECT.geom_parms,
                         (IGRdouble *)&events[0].event.button),
                   senderid = caller->objid,
                   targetid = LOCATED_OBJECT.located_obj.objid,
                   targetos = LOCATED_OBJECT.located_obj.osnum);

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_center failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_end

Description
        This function returns the endpoint of the located object nearest
        to the data point in the event structure.

Synopsis
        The first element in the events array should contain a located object.
*/

IGRlong COev_pt_end (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong         sts;                /* return code */
    IGRpoint        pt1, pt2, pt3;      /* boreline, endpoint */
    IGRmatrix       view_matrix;        /* of view in which ele identified */
    struct IGRline  boreline;           /* normal to view */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  get the view vector
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, view_matrix),
                   senderid = caller->objid,
                   targetid = events[0].event.button.objid,
                   targetos = events[0].event.button.osnum);

    if (sts & *msg & 1)
    {
        pt1[0] = events[0].event.button.x;
        pt1[1] = events[0].event.button.y;
        pt1[2] = events[0].event.button.z;
        pt2[0] = events[0].event.button.x + view_matrix[8];
        pt2[1] = events[0].event.button.y + view_matrix[9];
        pt2[2] = events[0].event.button.z + view_matrix[10];
        boreline.point1 = pt1;
        boreline.point2 = pt2;

        /*
         *  get the endpoint
         */

        sts = om$send (msg = message GRcurve.GRendpoint
                            (msg,
                             &LOCATED_OBJECT.module_info.md_env.matrix_type,
                             LOCATED_OBJECT.module_info.md_env.matrix,
                             &boreline, pt3),
                       senderid = caller->objid,
                       targetid = LOCATED_OBJECT.located_obj.objid,
                       targetos = LOCATED_OBJECT.located_obj.osnum);

        if (sts & *msg & 1)
        {
            events[0].subtype = GRst_ENDPOINT;
            events[0].num_id = 1;
            events[0].num_val = 0;
            events[0].response = DATA;
            events[0].event.button.x = pt3[0];
            events[0].event.button.y = pt3[1];
            events[0].event.button.z = pt3[2];
        }
    }
    
#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_end failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_intersection

Description
        This function returns the apparent intersection point of the two
        located objects.  The intersection point nearest the data point
        in the second event is returned.

Synopsis
        The first and second events should contain located objects.  The
        second event is also used to form a boreline normal to the view
        of the data point in the event. The third and fourth events should
        contain the locate points for the two objects. These events will 
        be used to determine which of the object segment to use in the 
        intersection.
*/

IGRlong COev_pt_intersection (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRboolean          apparent;        /* true or apparent flag */
    IGRlong             sts;             /* return code */
    IGRlong             size;            /* for dpb call */
    IGRpoint            point;           /* approximate intersection point */
    IGRvector           view_vector;     /* normal to view */
    IGRmatrix           view_matrix;     /* of view in which ele identified */
    struct GRlc_info   *obj1, *obj2;     /* objects to intersect */
    struct GRmd_env     ModuleInfo;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  get the view vector
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, view_matrix),
                   senderid = caller->objid,
                   targetid = events[1].event.button.objid,
                   targetos = events[1].event.button.osnum);


    if ( !(sts & *msg & 1) ) goto quit;

    /*
     * Get the module enviroment.
     */
    size = sizeof (struct GRmd_env);
    sts = gr$get_module_env ( msg = msg,
                              sizbuf = &size,
                              buffer = &ModuleInfo,
                              nret = &size );

    if ( !( sts & *msg & 1 ) ) goto quit;

    /*
     * Project the first locate point onto the element identified by the 
     * first accept point's event. This allows the segment identified by
     * the locate point to be used in the intersection rather than the 
     * segment identified by the accept point.
     */
    obj1 = events[0].located_object;
    sts = co$project_event (  msg = msg,
                              event = &(events[2]),
                              module = &ModuleInfo,
                              parms = &(obj1->geom_parms),
                              cob_id = caller->objid,
                              grid = &(obj1->located_obj) );

    if ( !( sts & *msg & 1 ) ) goto quit;

    /*
     * Project the second locate point onto the element identified by the 
     * second accept point's event. This allows the segment identified by
     * the locate point to be used in the intersection rather than the 
     * segment identified by the accept point.
     */
    obj2 = events[1].located_object;
    sts = co$project_event (  msg = msg,
                              event = &(events[3]),
                              module = &ModuleInfo,
                              parms = &(obj2->geom_parms),
                              cob_id = caller->objid,
                              grid = &(obj2->located_obj) );

    if ( !( sts & *msg & 1 ) ) goto quit;

    view_vector[0] = view_matrix[8];
    view_vector[1] = view_matrix[9];
    view_vector[2] = view_matrix[10];
    point[0] = events[1].event.button.x;
    point[1] = events[1].event.button.y;
    point[2] = events[1].event.button.z;
        
    /*
     *  get the true/apparent flag
     */

    size = sizeof (IGRboolean);
    gr$get_apparent_flag (msg = msg,
                          sizbuf = &size,
                          buffer = &apparent,
                          nret = &size);

#ifdef DEBUG
    printf ("COev_pt_intersection: apparent = %d\n", apparent);
#endif

    if (apparent)
    {
        sts = GR2objaisect (msg, &obj1->located_obj,
                            &obj1->module_info.md_env, &obj1->geom_parms,
                            &obj2->located_obj, &obj2->module_info.md_env,
                            &obj2->geom_parms, point, view_vector,
                            &events[0].event.button);
    }
    else
    {
        sts = GR2objisect (msg, &obj1->located_obj,
                           &obj1->module_info.md_env, &obj1->geom_parms,
                           &obj2->located_obj, &obj2->module_info.md_env,
                           &obj2->geom_parms, point, &events[0].event.button);
    }

    if (sts & *msg & 1)
    {
        events[0].num_val = 0;
        events[0].response = DATA;
        events[0].subtype = GRst_INTER;
        events[0].num_id = 2;
        events[0].located_object[1] = events[1].located_object[0];
    }

quit:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_intersection failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_key

Description
        This function returns the keypoint nearest to the data point in the
        first event.

Synopsis
        The first element in the events array should contain a located object.
*/

IGRlong COev_pt_key (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong         sts;                /* return code */
    IGRpoint        pt1, pt2, pt3;      /* boreline, endpoint */
    IGRmatrix       view_matrix;        /* of view in which ele identified */
    struct IGRline  boreline;           /* normal to view */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  get the view vector
     */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, view_matrix),
                   senderid = caller->objid,
                   targetid = events[0].event.button.objid,
                   targetos = events[0].event.button.osnum);

    if (sts & *msg & 1)
    {
        pt1[0] = events[0].event.button.x;
        pt1[1] = events[0].event.button.y;
        pt1[2] = events[0].event.button.z;
        pt2[0] = events[0].event.button.x + view_matrix[8];
        pt2[1] = events[0].event.button.y + view_matrix[9];
        pt2[2] = events[0].event.button.z + view_matrix[10];
        boreline.point1 = pt1;
        boreline.point2 = pt2;

        /*
         *  get the keypoint
         */

        sts = om$send (msg = message GRvg.GRkeypoint
                            (msg,
                             &LOCATED_OBJECT.module_info.md_env.matrix_type,
                             LOCATED_OBJECT.module_info.md_env.matrix,
                             &boreline, pt3, &LOCATED_OBJECT.geom_parms),
                       senderid = caller->objid,
                       targetid = LOCATED_OBJECT.located_obj.objid,
                       targetos = LOCATED_OBJECT.located_obj.osnum);

        if (sts & *msg & 1)
        {
            events[0].subtype = GRst_KEYPOINT;
            events[0].num_id = 1;
            events[0].num_val = 0;
            events[0].response = DATA;
            events[0].event.button.x = pt3[0];
            events[0].event.button.y = pt3[1];
            events[0].event.button.z = pt3[2];
        }
    }

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_key failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_mid

Description
        This function returns the midpoint of the located object.

Synopsis
        The first element in the events array should contain a located object.
*/

IGRlong COev_pt_mid (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  get the midpoint
     */

    sts = om$send (msg = message GRcurve.GRmidpoint
                        (msg, &LOCATED_OBJECT.module_info.md_env.matrix_type,
                         LOCATED_OBJECT.module_info.md_env.matrix,
                         &LOCATED_OBJECT.geom_parms,
                         (IGRdouble *)&events[0].event.button),
                   senderid = caller->objid,
                   targetid = LOCATED_OBJECT.located_obj.objid,
                   targetos = LOCATED_OBJECT.located_obj.osnum);

    if (sts & *msg & 1)
    {
        events[0].subtype = GRst_MIDPOINT;
        events[0].num_id = 1;
        events[0].num_val = 0;
        events[0].response = DATA;
    }

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_mid failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_project

Description
        This function returns a point projected onto the located object.

Synopsis
        The first element in the events array should contain a located object
        with the proj_pnt info filled in.
*/

#argsused
IGRlong COev_pt_project (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    events[0].event.button.x = LOCATED_OBJECT.proj_pnt[0];
    events[0].event.button.y = LOCATED_OBJECT.proj_pnt[1];
    events[0].event.button.z = LOCATED_OBJECT.proj_pnt[2];
    events[0].subtype = GRst_PROJECT;
    events[0].num_id = 1;
    events[0].num_val = 0;
    events[0].response = DATA;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_project failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_perpendicular_from

Description
        This function returns a point projected onto the located object
        with a subtype of perpendicular from.

Synopsis
        The first element in the events array should contain a located object
        with the proj_pnt info filled in.
*/

IGRlong COev_pt_perpendicular_from (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    sts = COev_pt_project (msg, caller, events);

    events[0].subtype = GRst_PERPEND_FROM;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_perpendicular_from failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_perpendicular_to

Description
        This function returns a point projected onto the located object
        with a subtype of perpendicular to.

Synopsis
        The first element in the events array should contain a located object
        with the proj_pnt info filled in.
*/

IGRlong COev_pt_perpendicular_to (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    sts = COev_pt_project (msg, caller, events);

    events[0].subtype = GRst_PERPEND_TO;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_perpendicular_to failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_tangent_from

Description
        This function returns a point projected onto the located object
        with a subtype of tangent from.

Synopsis
        The first element in the events array should contain a located object
        with the proj_pnt info filled in.
*/

IGRlong COev_pt_tangent_from (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    sts = COev_pt_project (msg, caller, events);

    events[0].subtype = GRst_TANGENT_FROM;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_tangent_from failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}



/*
Name
        COev_pt_tangent_to

Description
        This function returns a point projected onto the located object
        with a subtype of tangent to.

Synopsis
        The first element in the events array should contain a located object
        with the proj_pnt info filled in.
*/

IGRlong COev_pt_tangent_to (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];  /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    sts = COev_pt_project (msg, caller, events);

    events[0].subtype = GRst_TANGENT_TO;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_tangent_to failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}


/*
Name
        COev_pt_tentative_key

Description
        Not yet implemented
*/

#argsused
IGRlong COev_pt_tentative_key (msg, caller, events)

IGRlong         *msg;       /* return code */
struct GRid     *caller;    /* command id */
struct GRevent  events[];   /* input events */

{
    IGRlong     sts;        /* return code */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("COev_pt_tentative_key failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation COevgen;
