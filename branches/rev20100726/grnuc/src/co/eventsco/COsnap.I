/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COev_pt_snap

Description
        This function is used to provide an intelligent snap mechanism
        to a point generator.  The type of point returned depends on
        what the user locates and where it is located.  The user should
        know which point is desired and select near that point.  This is
        intended to combine the functionality of the Keypoint,
        Intersection, Midpoint, Center, and Endpoint commands into a
        single command for easier workflow. 

        The input is interpreted as follows: If two objects are in the
        first event, they are intersected, providing they are both
        subclasses of GRcurve.  If either is not under GRcurve, the
        second object is ignored and the input is treated as if the
        first object is the only located object.  This is necessary to
        prevent, for example, intersecting a line and a symbol.  If one
        object is located, its geometric properties are examined.  A
        closed non-segmented object is probably a circle or ellipse, so
        the Center point is generated.  It is possible that this will
        fail if the object is actually an owner with a closed
        non-segmented object as its first component.  Therefore, if
        center fails the keypoint is calculated and returned.  If the
        object is open or segmented, it is further checked to determine
        whether it is an arc.  Arcs return center points.  This is
        arbitrary.  If the object is not an arc, it is sent the midpoint
        and keypoint messages.  The nearer of these points to the
        original locate point is returned. 

History
        mrm     06/08/90    creation
*/

class implementation COevgen;

#include "coimport.h"
#include "OMmacros.h"

extern OMuword OPP_GRcurve_class_id, OPP_GRconic_class_id;

from GRvg import GRgeomprops;

#define POINTSIZE (sizeof(IGRdouble) * 3)

IGRint COev_pt_snap (msg, caller, events)
IGRlong *msg;
struct GRid *caller;
struct GRevent events[];
{
    IGRlong sts, compare = TRUE;
    IGRdouble *p, *d, midpoint[3], keypoint[3], datapoint[3];
    IGRdouble m_dis, e_dis;
    OMuword subclassid;
    struct GRlc_info *lc;
    struct GRprops props;

    *msg = MSSUCC;
    lc = events[0].located_object;

    if ((events[0].num_id == 1 && events[1].num_id == 1) ||
         events[0].num_id == 2)
    {
        /* make sure both objects are under GRcurve */

        om$get_classid (osnum = lc->located_obj.osnum,
                        objid = lc->located_obj.objid,
			p_classid = &subclassid);

        sts = om$is_ancestry_valid (subclassid = subclassid,
                                    superclassid = OPP_GRcurve_class_id);
        if (sts != OM_S_SUCCESS)
        {
            events[0].num_id = 1;
        }
        else
        {
            lc = events[1].located_object;
            om$get_classid (osnum = lc->located_obj.osnum,
                            objid = lc->located_obj.objid,
		            p_classid = &subclassid);

            sts = om$is_ancestry_valid (subclassid = subclassid,
                                        superclassid = OPP_GRcurve_class_id);
            if (sts != OM_S_SUCCESS)
            {
                events[0].num_id = 1;
            }
            else
            {
                /* get the intersection */

                sts = COev_pt_intersection (msg, caller, events);
            }
        }
    }
    if (events[0].num_id == 1)
    {
        /* determine whether the object is closed or segmented */

        sts = om$send (msg = message GRvg.GRgeomprops
                            (msg, &lc->module_info.md_env.matrix_type,
                             lc->module_info.md_env.matrix, &props),
                       senderid = caller->objid,
                       targetid = lc->located_obj.objid,
                       targetos = lc->located_obj.osnum);

        if (!(sts & *msg & 1)) goto finish;

        /* save the datapoint */

        d = (IGRdouble *)&events[0].event.button.x;
        OM_BLOCK_MOVE (d, datapoint, POINTSIZE);

        if (props.phy_closed && !props.is_segmented)
        {
            /* find the center of the object */

            sts = COev_pt_center (msg, caller, events);

            if (!(sts & *msg & 1))
            {
                /* get the keypoint */

                OM_BLOCK_MOVE (datapoint, d, POINTSIZE);
                sts = COev_pt_key (msg, caller, events);
            }
        }
        else
        {
            om$get_classid (osnum = lc->located_obj.osnum,
                            objid = lc->located_obj.objid,
                            p_classid = &subclassid);

            sts = om$is_ancestry_valid (subclassid = subclassid,
                                        superclassid = OPP_GRconic_class_id);

            if (sts == OM_S_SUCCESS && !props.phy_closed)
            {
                /* must be an arc; find the center point */

                sts = COev_pt_center (msg, caller, events);
            }
            else
            {
                /* find a keypoint on the object near the locate point */

                /* get the midpoint */

                sts = COev_pt_mid (msg, caller, events);
                if (sts & *msg & 1)
                {
                    OM_BLOCK_MOVE (d, midpoint, POINTSIZE);
                }
                else
                {
                    compare = FALSE;
                }

                /* get the keypoint */

                OM_BLOCK_MOVE (datapoint, d, POINTSIZE);
                sts = COev_pt_key (msg, caller, events);
                p = (sts & *msg & 1) ? d : datapoint;
                OM_BLOCK_MOVE (p, keypoint, POINTSIZE);

                if (compare)
                {
                    /* which point is closest to the original data point? */

                    MA2pt2dis(msg, datapoint, keypoint, &e_dis);
                    MA2pt2dis(msg, datapoint, midpoint, &m_dis);

                    if (m_dis < e_dis)
                    {
                        p = midpoint;
                        events[0].subtype = GRst_MIDPOINT;
                    }
                    else
                    {
                        p = keypoint;
                        events[0].subtype = GRst_KEYPOINT;
                    }
                    OM_BLOCK_MOVE (p, d, POINTSIZE);
                }
            }
        }
    }

finish:

    return (*msg & 1);
}

end implementation COevgen;
