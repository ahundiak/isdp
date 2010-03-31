/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "EMSopt.h"
#include "bs.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"
#include "madef.h"
#include "ma2pttobc.h"
#include "bsprptonsf.h"
#include "bsdistptpt.h"

struct xsect_obj_info
{
    GRobjid   objid;
    IGRint    flags;  /* #defines defined below */
    IGRpoint  endpoints[2];
};

struct xsect_info
{
    IGRint            num_objects;  /* number of curves in this cross section */
    struct  xsect_obj_info *xsect_obj;
};

struct point_info
{
    IGRpoint  point;
    IGRdouble u_parm;
    IGRdouble v_parm;
};

struct open_points
{
    IGRint      num_points;
    struct point_info  *pt_info;
};

#define BUF_INC  6

/* for xsect_obj_info flags above */
#define CLOSED   1
#define CURVE    2

from GRcurve import GRendpts;
from GRcompcurve import EMaddtocomp, EMmakecomp;
from GRowner import GRdelete_owner;

/*

  HISTORY
         
    WBC      09/24/91      Creation Date.
    Sudha    07/08/93      Modified for BSprototypes ansification
    Sp.Bala  06/20/96      Modified to create part sections. TR # 119601712

  This function tries to close any open elements in the input list by first
  trying to connect adjacent elements into composite curves.  If there are
  still open elements an attempt will be made to create line segments to close
  the curves.  These line segments will be created from the end points of the
  open elements that have been sorted according to their u,v parameters on the
  input surface.  It is assumed that the the input elements are curves that
  lie on the input plane.
*/

extern OMuword  OPP_EMSplane_class_id, OPP_GRcompcurve_class_id,
                OPP_GRgrgrp_class_id, OPP_GR3dlineseg_class_id;


IGRlong EFclose_planar_elems(EMmsg, num_elems, elems, construct_list,
                             surf_geom, num_closed_elems, closed_elems)

IGRlong                *EMmsg; 
IGRint                 num_elems;          /* number of elements in elems */
struct GRid            *elems;             /* planar curve elements */
struct GRvg_construct  *construct_list;    /* construct list to be used if
                                              closing line segments have to
                                              be constructed */
struct IGRbsp_surface  *surf_geom;         /* planar surface on which the
                                              planar curve elements lie */
IGRint                 *num_closed_elems;  /* number of elements being
                                              returned in closed_elems */
struct GRid            **closed_elems;     /* list of closed elements; the
                                              memory for this array is allocated
                                              within this function using
                                              om$malloc - it is the caller's
                                              responsibility to deallocate
                                              the memory (using om$dealloc) */
{
    OM_S_CHANSELECT	        to_cmpnt_chan;
    struct     GRid             cmpnt_GRid;
    struct     GRid             *closed_grids;
    struct     GRprops          geomprops;
    struct     xsect_info       *xsection_info;
    struct     open_points      open_pts;
    struct     xsect_obj_info   *lineseg_objects;
    struct     GRvg_construct   const_list;
    struct     IGRbsp_curve     bsp_geom;
    IGRdouble                   poles[6], knots[4], uparm, vparm,
                                param_tolerance;
    extern IGRdouble            fabs();
    IGRlong                     OM_stat, mthd_stat, rc;
    IGRint                      r,i, j, k, sts, num_open_sections, index1,
                                line_index, insert_index, num_entries,
                                elem_index, have_open_connect;
    OMuword                     classid, elem_osnum;
    OMuint                      num_cmpnts, total_num_cmpnts;
    IGRboolean                  on_surface, owner_deleted = FALSE;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    total_num_cmpnts = 0;
    sts = 1;

    OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    xsection_info = NULL;
    xsection_info = (struct xsect_info *) alloca(num_elems *
                                                    sizeof(struct xsect_info));
    EMerr_hndlr (! xsection_info, *EMmsg, EMS_E_NoStackMemory, wrapup);

    BSEXTRACTPAR(&rc, BSTOLLENVEC, param_tolerance);
    EMerr_hndlr ((rc != BSSUCC), *EMmsg, EMS_E_BSerror, wrapup);

    for (elem_index = 0; elem_index < num_elems; elem_index++)
    {
        /* if any component of the cross section is not closed, find
         * its end points which will be used later in an attempt
         * to close all cross sections
         */

        OM_stat = om$get_classid(osnum = elems[elem_index].osnum,
                                 objid = elems[elem_index].objid,
                                 p_classid = &classid);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        OM_stat = om$is_ancestry_valid(subclassid = classid,
                                       superclassid = OPP_GRgrgrp_class_id);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        if (OM_stat == OM_S_SUCCESS)
        {
            OM_stat = om$get_channel_count(osnum = elems[elem_index].osnum,
                                           objid = elems[elem_index].objid,
                                           p_chanselect = &to_cmpnt_chan,
                                           count = &num_cmpnts);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            xsection_info[elem_index].num_objects = num_cmpnts;
            xsection_info[elem_index].xsect_obj = NULL;
            xsection_info[elem_index].xsect_obj = (struct xsect_obj_info *)
                           alloca(num_cmpnts * sizeof(struct xsect_obj_info));
            EMerr_hndlr (! xsection_info[elem_index].xsect_obj, *EMmsg,
                         EMS_E_NoStackMemory, wrapup);

            for (i = 0; i < num_cmpnts; i++)
            {
                OM_stat = om$get_objid_at_index(osnum = elems[elem_index].osnum,
                                                objid = elems[elem_index].objid,
                                                p_chanselect = &to_cmpnt_chan,
                                                index = i,
                                                objidaddr = &cmpnt_GRid.objid,
                                                osnumaddr = &cmpnt_GRid.osnum);
                EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

                xsection_info[elem_index].xsect_obj[i].objid = cmpnt_GRid.objid;
            }

            /* delete the graphic group object since it's not needed */

            OM_stat = om$send(msg = message GRowner.GRdelete_owner(&mthd_stat,
                                                    construct_list->env_info),
                              senderid = NULL_OBJID,
                              targetid = elems[elem_index].objid,
                              targetos = elems[elem_index].osnum);
            EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
            owner_deleted = TRUE;
        }
        else
        {
            num_cmpnts = 1;
            xsection_info[elem_index].num_objects = 1;
            xsection_info[elem_index].xsect_obj = NULL;
            xsection_info[elem_index].xsect_obj = (struct xsect_obj_info *)
                                       alloca( sizeof(struct xsect_obj_info));
            EMerr_hndlr (! xsection_info[elem_index].xsect_obj, *EMmsg,
                         EMS_E_NoStackMemory, wrapup);

            xsection_info[elem_index].xsect_obj[0].objid = elems[elem_index].objid;
        }

        total_num_cmpnts += num_cmpnts;

        for (i = 0; i < num_cmpnts; i++)
        {
            /* determine if the component is a composite curve or a
             * "plain" curve (makeing the assumption it's some type of
             * curve) and whether or not it is closed
             */

            OM_stat = om$send(msg = message GRvg.GRgeomprops(&mthd_stat,
                                       &construct_list->env_info->md_env.matrix_type,
                                       construct_list->env_info->md_env.matrix,
                                       &geomprops),
                              senderid = NULL_OBJID,
                              targetid = xsection_info[elem_index].xsect_obj[i].objid,
                              targetos = construct_list->env_info->md_id.osnum);
            EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

            if (geomprops.subtype == GRCC)
                xsection_info[elem_index].xsect_obj[i].flags = 0;
            else
                xsection_info[elem_index].xsect_obj[i].flags = CURVE;

            xsection_info[elem_index].xsect_obj[i].flags |=
                                        geomprops.phy_closed ? CLOSED : 0;

            /* if the component is not closed, find its end points
             * to be used later in an attemp to close all cross sections
             */

            if (! geomprops.phy_closed)
            {
                OM_stat = om$send(msg = message GRcurve.GRendpts(&mthd_stat,
                                       &construct_list->env_info->md_env.matrix_type,
                                       construct_list->env_info->md_env.matrix,
                                       xsection_info[elem_index].xsect_obj[i].endpoints[0],
                                       xsection_info[elem_index].xsect_obj[i].endpoints[1]),
                                  senderid = NULL_OBJID,
                                  targetid = xsection_info[elem_index].xsect_obj[i].objid,
                                  targetos = construct_list->env_info->md_id.osnum);
                EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
            }
        }  /* for (i = 0; i < num_cmpnts; i++) */

    } /* for (elem_index = 0; elem_index < num_elems; elem_index++) */

    /* attempt to close all cross sections; on the first pass, if there is
     * more than one cross section try to connect adjacent sections; if any
     * sections are connected but do not result in a closed section,
     * must retry connecting all the open sections again
     */

    do
    {
        have_open_connect = FALSE;

        for (i = 0; i + 1 < num_elems; i++)
        {
            for (j = 0; j < xsection_info[i].num_objects; j++)
            {
                if ((xsection_info[i].xsect_obj[j].objid != NULL_OBJID) &&
                    ! (xsection_info[i].xsect_obj[j].flags & CLOSED))
                {
                    for (elem_index = i; elem_index < num_elems; elem_index++)
                    {
                        for (k = (elem_index == i) ? j + 1 : 0; k < xsection_info[elem_index].num_objects; k++)
                        {
                            if ((xsection_info[elem_index].xsect_obj[k].objid != NULL_OBJID) &&
                                ! (xsection_info[elem_index].xsect_obj[k].flags & CLOSED))
                            {
                                sts = EFconnect_xsections(&rc,
                                           &(xsection_info[i].xsect_obj[j]),
                                           &(xsection_info[elem_index].xsect_obj[k]),
                                           construct_list->env_info);

                                if (sts)
                                {
                                    if (rc == EMS_I_Closed)
                                        break;
                                    else if (rc != EMS_I_NoIntersection)
                                        have_open_connect = TRUE;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    while (have_open_connect);

    /* see if there are any open sections */

    num_open_sections = 0;
    
    for (i = 0; i < num_elems; i++)
    {
        for (j = 0; j < xsection_info[i].num_objects; j++)
        {
            if ((xsection_info[i].xsect_obj[j].objid != NULL_OBJID) &&
                ! (xsection_info[i].xsect_obj[j].flags & CLOSED))
            {
                if (! num_open_sections)
                {
                    open_pts.num_points = 0;

                    /* allocate memory for an array of structs to hold the
                     * points and parameters corresponding to the endpoints
                     * of the open curves
                     */

                    open_pts.pt_info = NULL;
                    open_pts.pt_info = (struct point_info *) alloca(
                            total_num_cmpnts * 2 *  sizeof(struct point_info));
                    EMerr_hndlr (! open_pts.pt_info, *EMmsg, EMS_E_NoStackMemory, wrapup);
                }

                /* insert and sort (according to parmeter value) end points */

                for (index1 = 0; index1 < 2; index1++)
                {
                    /* find the parameters of the end point */

                    BSprptonsf(&rc, surf_geom,
                               xsection_info[i].xsect_obj[j].endpoints[index1],
                               &uparm, &vparm, &on_surface);

                    /* sort on the u parameter first to group the points that
                     * are vertically aligned on the surface, then on the
                     * v parameter; sort both in ascending order; using a
                     * tolerance when sorting on the u-parameter since the
                     * points that were projected onto the surface may have
                     * been transformed so their u-parameters may not lie
                     * EXACTLY along a vertical line, but for our purposed it
                     * is the same line and it's important these points are
                     * group together according to their v-parameters
                     */

                    for (insert_index = 0; insert_index < open_pts.num_points; insert_index++)
                    {
                        if (fabs(uparm - open_pts.pt_info[insert_index].u_parm) < param_tolerance)
                        {
                            do
                            {
                                if (vparm <= open_pts.pt_info[insert_index].v_parm)
                                    break;
                                insert_index++;
                            }
                            while ((insert_index < open_pts.num_points) &&
                                   (fabs(uparm - open_pts.pt_info[insert_index].u_parm) < param_tolerance));

                            break;
                        }
                        else if (uparm < open_pts.pt_info[insert_index].u_parm)
                            break;
                    }

                    if (insert_index < open_pts.num_points)
                    {
                        num_entries = open_pts.num_points - insert_index;
                        OM_BLOCK_MOVE(&(open_pts.pt_info[insert_index]),
                                      &(open_pts.pt_info[insert_index + 1]),
                                      num_entries * sizeof(struct point_info));
                    }

                    (open_pts.num_points)++;
                    OM_BLOCK_MOVE(xsection_info[i].xsect_obj[j].endpoints[index1],
                                  open_pts.pt_info[insert_index].point,
                                  sizeof(IGRpoint));
                    open_pts.pt_info[insert_index].u_parm = uparm;
                    open_pts.pt_info[insert_index].v_parm = vparm;

                }

                num_open_sections++;
            }
        }
    }

    if (num_open_sections)
    {
        /* try to close remaining open cross sections by constructing line
         * segments from the ordered end points and connecting these line
         * segments to the remaining open curves to create closed composite
         * curves
         */

        lineseg_objects = NULL;
        lineseg_objects = (struct xsect_obj_info *) alloca(num_open_sections *
                                              sizeof(struct xsect_obj_info));
        EMerr_hndlr (! lineseg_objects, *EMmsg, EMS_E_NoStackMemory, wrapup);
        line_index = 0;

        const_list.msg = &mthd_stat;
        const_list.env_info = construct_list->env_info;
        const_list.newflag = FALSE;
        const_list.level = construct_list->level;
        const_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        const_list.geometry = (IGRchar *) &bsp_geom;
        bsp_geom.poles = poles;
        bsp_geom.knots = knots;
        const_list.display = construct_list->display;
        const_list.class_attr = NULL;
        const_list.name = NULL;

        for (i = 0; i < open_pts.num_points; i += 2)
        {
            MA2pttobc(&rc, open_pts.pt_info[i].point,
                      open_pts.pt_info[i + 1].point, &bsp_geom);

            OM_stat = om$construct(classid = OPP_GR3dlineseg_class_id,
                                   osnum = construct_list->env_info->md_id.osnum,
                                   p_objid = &lineseg_objects[line_index].objid,
                                   msg = message GRgraphics.GRconstruct(
                                                            &const_list));

            EMerr_hndlr (!(1 & OM_stat & mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

            lineseg_objects[line_index].flags = CURVE;

            for (index1 = 0; index1 < 3; index1++)
            {
                lineseg_objects[line_index].endpoints[0][index1] =
                                           open_pts.pt_info[i].point[index1];
                lineseg_objects[line_index].endpoints[1][index1] =
                                       open_pts.pt_info[i + 1].point[index1];
            }
            line_index++;
        }

        /* connect the line segments to the open sections */

       for (i = 0; i < num_elems; i++)
        {
            for (j = 0; j < xsection_info[i].num_objects; j++)
            {
                if ((xsection_info[i].xsect_obj[j].objid != NULL_OBJID) &&
                    ! (xsection_info[i].xsect_obj[j].flags & CLOSED))
                {
                    for (k = 0; k < line_index; k++)
                    {
                        if (lineseg_objects[k].objid != NULL_OBJID)
                        { 
                          /* modified for TR# 119601712 .Added the cases
			     to connect parent curve to constructor line */
                          for(k=0,r=1;k<line_index;k++,r++)
                          {
			    sts = EFconnect_xsections(&rc,
                                      &(xsection_info[i].xsect_obj[j]),
                                      &lineseg_objects[k],
                                      construct_list->env_info);
                    
                            sts = EFconnect_xsections(&rc,
                                       &(xsection_info[i].xsect_obj[j]),
                                       &lineseg_objects[k+r],
                                       construct_list->env_info);
      
                            sts = EFconnect_xsections(&rc,
                                       &(xsection_info[i].xsect_obj[j]),
                                       &(xsection_info[i].xsect_obj[j+r]),
                                       construct_list->env_info);
                          } 
                          if (sts && (rc != EMS_I_NoIntersection))
                                break;
                        }
                    }
                }
            }
        }

        /* last pass - connect any adjacent sections */

        do
        {
            have_open_connect = FALSE;

            for (i = 0; i + 1 < num_elems; i++)
            {
                for (j = 0; j < xsection_info[i].num_objects; j++)
                {
                    if ((xsection_info[i].xsect_obj[j].objid != NULL_OBJID) &&
                        ! (xsection_info[i].xsect_obj[j].flags & CLOSED))
                    {
                        for (elem_index = i; elem_index < num_elems; elem_index++)
                        {
                            for (k = (elem_index == i) ? j + 1 : 0; k < xsection_info[elem_index].num_objects; k++)
                            {
                                if ((xsection_info[elem_index].xsect_obj[k].objid != NULL_OBJID) &&
                                    ! (xsection_info[elem_index].xsect_obj[k].flags & CLOSED))
                                {
                                    sts = EFconnect_xsections(&rc,
                                               &(xsection_info[i].xsect_obj[j]),
                                               &(xsection_info[elem_index].xsect_obj[k]),
                                               construct_list->env_info);

                                    if (sts)
                                    {
                                        if (rc == EMS_I_Closed)
                                            break;
                                        else if (rc != EMS_I_NoIntersection)
                                            have_open_connect = TRUE;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        while (have_open_connect);

    }  /* if (num_open_sections) */

    /* create a list of the closed elements and note if there are still
     * any open elements
     */

    *num_closed_elems = 0;
    elem_osnum = construct_list->env_info->md_id.osnum;
    closed_grids = NULL;
    closed_grids = (struct GRid *) alloca(total_num_cmpnts *
                                                 sizeof(struct GRid));
    EMerr_hndlr (! closed_grids, *EMmsg, EMS_E_NoStackMemory, wrapup);

    for (i = 0; i < num_elems; i++)
    {
        for (j = 0; j < xsection_info[i].num_objects; j++)
        {
            if (xsection_info[i].xsect_obj[j].objid != NULL_OBJID)
            {
                if (xsection_info[i].xsect_obj[j].flags & CLOSED)
                {
                    closed_grids[*num_closed_elems].objid =
                                      xsection_info[i].xsect_obj[j].objid;
                    closed_grids[*num_closed_elems].osnum = elem_osnum;
                    (*num_closed_elems)++;
                }
                else
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup;
                }
            }
        }
    }

    /* allocate memory in which to return the grids of the closed elements
     */

    *closed_elems = (struct GRid *) om$malloc(size = *num_closed_elems *
                                                   sizeof(struct GRid));
    EMerr_hndlr (! *closed_elems, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

    OM_BLOCK_MOVE(closed_grids, *closed_elems, *num_closed_elems *
                                                    sizeof(struct GRid));

wrapup:

    /*
     * On failure, delete all the composite curves, belonging to the
     * cross sections. ---knap.
     */
    if (!(1 & OM_stat & *EMmsg) && owner_deleted)
    {
       for ( elem_index = 0; elem_index < num_elems; elem_index++ )
       {
          if (xsection_info[elem_index].xsect_obj)
          {
             for ( i = 0; i < xsection_info[elem_index].num_objects; i++ )
             {
               if ( xsection_info[elem_index].xsect_obj[i].objid )
               {
                   om$send(msg = message GRgraphics.GRdelete(&rc,
                                                    construct_list->env_info),
                       senderid = NULL_OBJID,
                       targetid = xsection_info[elem_index].xsect_obj[i].objid,
                       targetos = construct_list->env_info->md_id.osnum);

               }
             }
          }
       }
    }
    return(OM_stat);
}


/*
 * this function creates a composite curve from the objects in xsect1 and
 * xsect2 and places the object in xsect1 and removes the object in xsect2
 */

IGRint EFconnect_xsections(rc, xsect1, xsect2, module_env)

IGRlong               *rc;
struct xsect_obj_info *xsect1, *xsect2;
struct GRmd_env       *module_env;      /* module environment of xsect objs */
{
    IGRlong               msg, OMstat, num_components, bad_entry;
    IGRint                sts, have_match, index1, index_xsect1, index_xsect2;
    IGRdouble             distance, endpts_tolerance, connect_tolerance;
    IGRpoint              compcrv_endpoints[2];
    struct GRid           add_GRid;
    struct GRlc_info      curve_info[2];
    struct xsect_obj_info *xsect_ptr;

    sts = TRUE;
    *rc = EMS_S_Success;

    BSEXTRACTPAR(&msg, BSTOLCHRDHT, endpts_tolerance);
    EMerr_hndlr ((msg != BSSUCC), sts, FALSE, wrapup);

    endpts_tolerance *= 2;  /* this is the tolerance used for intersections */

    BSEXTRACTPAR(&msg, BSTOLLENVEC, connect_tolerance);
    EMerr_hndlr ((msg != BSSUCC), sts, FALSE, wrapup);

    /* first determine if the two curves have endpoints close enought so that
     * they can be joined
     */

    for (index_xsect1 = 0, have_match = FALSE; (index_xsect1 < 2) && (! have_match); index_xsect1++)
    {
        for (index_xsect2 = 0; index_xsect2 < 2; index_xsect2++)
        {
            distance = BSdistptpt(&msg, xsect1->endpoints[index_xsect1],
                                  xsect2->endpoints[index_xsect2]);

            if (distance < endpts_tolerance)
            {
                have_match = TRUE;
                break;
            }
        }
    }

    if (have_match)
    {
        index_xsect1--;  /* it was incremented past the matching point */


        /* need a composite curve; if the object in xsect1 is a composite curve,
         * add the object in xsect2 to it, else if the object in xsect2 is a
         * composite curve add the object in xsect1 to it and move the composite
         * curve to xsect1, else create a composite curve from the objects in
         * xsect1 and xsect2 and replace the object in xsect1 with the
         * composite curve
         */

        if ((! (xsect2->flags & CURVE)) ||
            (! (xsect1->flags & CURVE)))
        {
            if (! (xsect1->flags & CURVE))
            {
                xsect_ptr = xsect1;
                add_GRid.objid = xsect2->objid;
            }
            else
            {
                xsect_ptr = xsect2;
                add_GRid.objid = xsect1->objid;
            }

            for (index1 = 0; index1 < 3; index1++)
            {
                compcrv_endpoints[0][index1] = xsect_ptr->endpoints[0][index1];
                compcrv_endpoints[1][index1] = xsect_ptr->endpoints[1][index1];
            }

            add_GRid.osnum = module_env->md_id.osnum;
            num_components = 0;

            OMstat = om$send(msg = message GRcompcurve.EMaddtocomp(&msg,
                                                    add_GRid,
                                                    module_env, module_env,
                                                    TRUE, endpts_tolerance,
                                                    connect_tolerance, TRUE,
                                                    compcrv_endpoints[0],
                                                    compcrv_endpoints[1],
                                                    &num_components),
                             senderid = NULL_OBJID,
                             targetid = xsect_ptr->objid,
                             targetos = module_env->md_id.osnum);
            EMerr_hndlr (!(1 & OMstat & msg), sts, FALSE, wrapup);

            if (xsect1->flags & CURVE)
            {
                /* the object in xsect1 is a curve; replace it with the
                 * composite curve and clear the CURVE bit to indicate it's
                 * a composite curve
                 */

                xsect1->objid = xsect2->objid;
                xsect1->flags &= ~CURVE;
            }

            /* determine if the cross section is closed and if it is set the
             * appropriate flag, else update the start and end points of the
             * composite curve
             */

            distance = BSdistptpt(&msg, compcrv_endpoints[0],
                                  compcrv_endpoints[1]);

            if (distance < endpts_tolerance)
            {
                xsect1->flags |= CLOSED;
                *rc = EMS_I_Closed;
            }
            else
            {
                /* copy the endpoint info. of the endpoint that did not match
                 * from xsect2 to xsect1
                 */

                index_xsect2 ^= 0x1;  /* toggle the index */

                OM_BLOCK_MOVE(xsect2->endpoints[index_xsect2],
                              xsect1->endpoints[index_xsect1], sizeof(IGRpoint));
            }
            xsect2->objid = NULL_OBJID;  /* it's been merged with xsect1 */
        }
        else  /* neither object is a composite curve; we need to create one */
        {
            curve_info[0].located_obj.objid = xsect1->objid;
            curve_info[0].located_obj.osnum = module_env->md_id.osnum;
            curve_info[0].module_info = *module_env;
            curve_info[1].located_obj.objid = xsect2->objid;
            curve_info[1].located_obj.osnum = module_env->md_id.osnum;
            curve_info[1].module_info = *module_env;

            OMstat = om$construct(classid = OPP_GRcompcurve_class_id,
                                  osnum = module_env->md_id.osnum,
                                  p_objid = &xsect1->objid,
                                  msg = message GRcompcurve.EMmakecomp(&msg,
                                                module_env, 2, curve_info,
                                                &bad_entry));
            EMerr_hndlr (!(1 & OMstat & msg), sts, FALSE, wrapup);

            /* determine if the composite curve is closed; we know which
             * endpoints the objects have in common so check the other
             * endpoints to see if they're within tolerance of one another
             */

            distance = BSdistptpt(&msg, xsect1->endpoints[index_xsect1 ^ 0x1],
                                  xsect2->endpoints[index_xsect2 ^ 0x1]);

            if (distance < endpts_tolerance)
            {
                xsect1->flags |= CLOSED;
                *rc = EMS_I_Closed;
            }
            else
            {
                /* copy the endpoint info. of the endpoint that did not match
                 * from xsect2 to xsect1
                 */

                index_xsect2 ^= 0x1;  /* toggle the index */

                OM_BLOCK_MOVE(xsect2->endpoints[index_xsect2],
                              xsect1->endpoints[index_xsect1], sizeof(IGRpoint));
            }

            xsect1->flags &= ~CURVE;  /* it's a composite curve now */
            xsect2->objid = NULL_OBJID;  /* it's been added to xsect1 */
        }
    }
    else
        *rc = EMS_I_NoIntersection;

wrapup:

    if (! sts)
        *rc = EMS_E_Fail;

    return(sts);
}

end implementation EMSsurface;
