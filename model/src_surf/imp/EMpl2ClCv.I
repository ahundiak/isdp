/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

#include "EMS.h"
/*
ALGORITHM

use EFplaneOfPointSets to get planar B-spline surface containing
input curves

send self GRconstruct message

get own partolbasis

make loops from curves

get nesting information from first loop

make loopset of first loop and attach to surface

get nesting information from second loop

get nesting relationship of second loop to first loop

add second loop to loopset

send set-loop-types message down loop channel of loopset

HISTORY

23-May-1988 jBk Genesis.
07-Dec-1988 SM  Argument change for EMSloop.EMtoggle_type.
28-Mar-1989 SM	Argument change in EMget_loops_for_imposition().
		Renamed the function as EMget_mapped_data().
02/10/92    pp  Corrected the logic in nesting. This was creating problems
                when the user was offsetting a surface to create a solid.
                Eg: Cylinder.
*/

/*
    EMMapBnd_NoClip
    EMMapBnd_NoFixing
    EMMapBnd_NoValidate
    EMMapBnd_StrokeIfNeeded
    EMMapBnd_SurfIsPlane
*/
# include "emsmapdef.h"

/* ADD_CHILD */
# include "EMSopt.h"

/* EMS_S_ClearStatusField */
# include "EMS_S.h"

/* EMS_E_.+ */
# include "EMS_E.h"

/* IF_NULL_OBJID IF_EQ_OBJID */
# include "OMmacros.h"

enum idtypes {loop1, loop2, loopset};

from EMSloopset import EMtreemod;
from EMSloop import EMgivenestinfo;
from EMSloop import EMnesting;
from EMSloop import EMtreemod;
from EMSloop import EMtoggle_type;

method EMplaneContainingTwoClosedCurves (
    IGRlong rc[1];
    struct GRvg_construct list[1];
    struct IGRbsp_curve *cv[2]
)
{
    EMSrc omrc;
    struct IGRbsp_surface plane;
    IGRpoint poles[4];
    IGRdouble uKnots[4], vKnots[4];
    IGRdouble partolbasis;
    OM_S_OBJID ids[3];
    struct EMSnest_info nesting[2];
    struct EMSpartolbasis partolbasisStruct;
    IGRushort togtype_options = EMTogType_SendInner;

    plane.poles = (IGRdouble *)poles;
    plane.u_knots = uKnots;
    plane.v_knots = vKnots;

    /* intentional block for id assignments */
    {
        int idix;

        for (idix = loop1; idix <= loopset; idix++)
        {
            ids[idix] = NULL_OBJID;
        }
    }

    /* intentional block for getting planar surface */
    {
        extern EMSrc EFplaneOfPointSets ();
        IGRlong numPoints[2];
        IGRpoint *pointSets[2];
        IGRdouble *weightSets[2];

        numPoints[0] = cv[0]->num_poles;
        numPoints[1] = cv[1]->num_poles;

        pointSets[0] = (IGRpoint *)cv[0]->poles;
        pointSets[1] = (IGRpoint *)cv[1]->poles;

        weightSets[0] = NULL;
        weightSets[1] = NULL;

        if (cv[0]->rational) weightSets[0] = cv[0]->weights;
        if (cv[1]->rational) weightSets[1] = cv[1]->weights;

        *rc = EFplaneOfPointSets (
            2,
            numPoints,
            pointSets,
            weightSets,
            &plane
        );

        /* *rc is set desirably now */
    }

    if (EMSokay (*rc)) /* construct my basic geometry */
    {
        struct GRvg_construct myList;

        myList = *list;
        myList.geometry = (IGRchar *)&plane;

        omrc = om$send (
            msg = message GRgraphics.GRconstruct (&myList),
            targetid = my_id
        );

        if (EMSerror (omrc) OR EMSerror (*list->msg))
        {
            *rc = EMS_E_EMSplaneGRconstruct;
        }
    }

    if (EMSokay (*rc)) /* get my parametric basis tolerance */
    {
        extern IGRlong EFsspbtol_by_geom ();

        omrc = EFsspbtol_by_geom (
            rc,
            &plane,
            &partolbasis
        );

        if (EMSerror (*rc) OR EMSerror (omrc))
        {
            *rc = EMS_E_SubSGetPartolbasis;
        }
    }

    if (EMSokay (*rc)) /* get loops for boundary imposition */
    {
        extern IGRint EMget_mapped_data();
        struct IGRbsp_curve *dptr;
        IGRlong numBadCvs, badCvIxs[2];
        IGRushort options;
        IGRint numLoops;
        struct GRid nullGRid;

        nullGRid.objid = NULL_OBJID;
            /* does not matter since EMMapBnd_NoClip is used */

        options =
            EMMapBnd_NoClip |
            EMMapBnd_NoFixing |
            EMMapBnd_NoValidate |
            EMMapBnd_StrokeIfNeeded |
            EMMapBnd_SurfIsPlane
        ;

        {
	 struct EMSgetlp_output		junk;

	 junk.num_objs = 0;
	 junk.objs = &ids[loop1];
	
         omrc = EMget_mapped_data(
            /* number_of_objects = */       (IGRlong)2,
            /* input_curves = */            cv,
            /* object_information = */      NULL,
            /* const_list = */              list,
            /* surface = */                 &plane,
            /* par_tol_basis = */           &partolbasis,
            /* env = */                     list->env_info,
            /* bad_curve_indices = */       NULL,
            /* bad_points = */              NULL,
            /* out_loops = */               &junk,
            /* out_curves = */ 	            NULL,
            /* clip_ls = */                 nullGRid,
            /* options = */                 options,
            /* planar_info = */             NULL,
            /* EMmsg = */                   rc
         );
	 numLoops = junk.num_objs;
        }

        if (EMSerror (omrc) OR EMSerror (*rc) OR EMSerror (*list->msg))
        {
            *rc = EMS_E_GetLoopsForImposition;
        }

        if (EMSokay (*rc) AND numLoops ISNT 2)
        {
            ids[loop2] = NULL_OBJID;
            if (numLoops ISNT 1) ids[loop1] = NULL_OBJID;

            *rc = EMS_E_GetLoopsForImposition;
        }
    }

    if (EMSokay (*rc)) /* construct loopset */
    {
        extern OMuword OPP_EMSloopset_class_id;

        omrc = om$construct (
            classid = OPP_EMSloopset_class_id,
            p_objid = &ids[loopset]
        );

        if (EMSerror (omrc)) *rc = EMS_E_EMSloopsetConstruct;
    }

    if (EMSokay (*rc)) /* connect loopset to me */
    {
        OM_S_CHANSELECT toLoopset, toSurface;

        toLoopset.type = OM_e_addr;
        toLoopset.u_sel.addr = &me->to_loopset;

        toSurface.type = OM_e_name;
        toSurface.u_sel.name = "EMSloopset.to_surface";

        omrc = om$send (
            msg = message Root.connect (
                toSurface, 0,
                my_id, OM_Gw_current_OS, toLoopset, 0
            ),
            targetid = ids[loopset]
        );

        if (EMSerror (omrc)) *rc = EMS_E_EMSloopsetConnect;
    }

    if (EMSokay (*rc)) /* get nesting info from loops */
    {
        int idix;

        for (idix = loop1; idix <=loop2; idix++)
        {
            omrc = om$send (
                msg = message EMSloop.EMgivenestinfo (
                    rc,
                    &nesting[idix]
                ),
                targetid = ids[idix]
            );

            nesting[idix].parent = NULL_OBJID;
            nesting[idix].parent_props = NULL;

            if (EMSerror (*rc) OR EMSerror (omrc))
            {
                *rc = EMS_E_GiveNestInfo;
                break;
            }
        }
    }

    if (EMSokay (*rc)) /* add first loop to loopset */
    {
        partolbasisStruct.tol = partolbasis;
        partolbasisStruct.is_valid = TRUE;
        partolbasisStruct.in_world = TRUE;
        partolbasisStruct.mattyp = &list->env_info->md_env.matrix_type;
        partolbasisStruct.mat = list->env_info->md_env.matrix;

        omrc = om$send (
            msg = message EMSloopset.EMtreemod (
                rc,
                &nesting[loop1],
                (IGRint)ADD_CHILD,
                &partolbasisStruct
            ),
            targetid = ids[loopset]
        );

        if (EMSerror (*rc) OR EMSerror (omrc))
        {
            *rc = EMS_E_LoopsetAddLoop;
        }
    }

    if (EMSokay (*rc)) /* get nesting relationship between loops */
    {
        omrc = om$send (
            msg = message EMSloop.EMnesting (
                rc,
                &nesting[loop2],
                &partolbasisStruct
            ),
            targetid = ids[loop1]
        );

        if (EMSerror (*rc) OR EMSerror (omrc))
        {
            *rc = EMS_E_LoopNesting;
        }
    }

    if (EMSokay (*rc)) /* add second loop to loopset */
    {
        if ((IF_EQ_OBJID (ids[loopset], nesting[loop2].parent)) ||
            (nesting[loop2].parent == NULL_OBJID))
        {
            omrc = om$send (
                msg = message EMSloopset.EMtreemod (
                    rc,
                    &nesting[loop2],
                    (IGRint)ADD_CHILD,
                    &partolbasisStruct
                ),
                targetid = ids[loopset]
            );

            if (EMSerror (*rc) OR EMSerror (omrc))
            {
                *rc = EMS_E_LoopsetAddLoop;
            }
        }
        else /* must be subordinate to first loop */
        {
            omrc = om$send (
                msg = message EMSloop.EMtreemod (
                    rc,
                    &nesting[loop2],
                    (IGRint)ADD_CHILD,
                    &partolbasisStruct
                ),
                targetid = ids[loop1]
            );

            if (EMSerror (*rc) OR EMSerror (omrc))
            {
                *rc = EMS_E_LoopAddLoop;
            }
        }
    }

    if (EMSokay (*rc)) /* set loop types */
    {
        OM_S_CHANSELECT toLoops;

        toLoops.type = OM_e_name;
        toLoops.u_sel.name = "EMSloopset.to_loops";

        omrc = om$send (
            msg = message EMSloop.EMtoggle_type (
                /* EMmsg */         	rc,
                /* P_loop */        	TRUE,
		/* deletable */	    	FALSE, 
                /* sender_obj */    	ids[loopset],
		/* options */	    	togtype_options, 
                /* numtogloops */   	NULL,
                /* togloops */      	NULL, 
		/* numdelloops*/    	NULL, 
		/* delloops */	    	NULL, 
		/* num_loops_received*/	NULL, 
		/* loops_received*/	NULL
            ),
            p_chanselect = &toLoops,
            senderid = ids[loopset]
        );
    }

    if (EMSokay (*rc))
    {
        *rc = EMS_S_ClearStatusField;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        int idix;

        for (idix = loop1; idix <= loopset; idix++)
        {
            if (NOT IF_NULL_OBJID (ids[idix]))
            {
                (void)om$send (
                    msg = message Root.delete (NULL),
                    targetid = ids[idix]
                );
            }        
        }

        omrc = OM_E_ABORT;
    }

    return omrc;
}

end implementation EMSplane;
