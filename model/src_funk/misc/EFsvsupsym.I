/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

/*
  ABSTRACT:  This function finds if the input drawing view is the parent of a
             Section View (EMSasectvw) object.  If it is, the solids owned by
             the Section View will either have all of their symbology
             overrides that are automatic and hidden changed to automatic and
             invisible overrides, or all the automatic and invisible symbology
             overrides changed to automatic and hidden, according to the
             specified flag.

  HISTORY
         
    WBC      10/08/92      Creation date.
    Sudha    07/08/93      Modified for BSprototypes ansification

*/

//%safe
#include <math.h>
//%endsafe

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
#include "OMprimitives.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "EMSopt.h"
#include "bs.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"
#include "madef.h"
#include "nddef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "EMdtmacros.h"
#include "EMSlcdef.h"
#include "DEso.h"
#include "DEsomacros.h"
#include <alloca.h>
#include "matypemx.h"

#define EDGE_ARRAY_SIZE  4
#define AUTOMATIC_SOOS   1  /* only want automatic symbology overrideds */

from NDnode      import NDget_objects;
from EMSsubbs    import EMget_graphics_edges;
from EMSboundary import EMgetxyzobj;
from DEso        import DEget;
from GRowner     import GRget_number_components,
                        GRget_components;

extern OMuword  OPP_EMSasectvw_class_id,
                OPP_ASsource_class_id,
                OPP_EMSsolid_class_id;


IGRint EFsv_suppress_symb(EMmsg, dvattach_grid, md_env, window_grid,
                          hidden_flag)

IGRlong            *EMmsg;          /* Output:  function return message */
struct GRid        *dvattach_grid;  /* Input:  cutting plane line object
                                       (can be a composite curve) */
struct GRmd_env    *md_env;         /* Input:  the module environment of the
                                       drawing view attachment */
struct GRid        *window_grid;    /* Input:  id of the window in which the
                                       drawing view attachment was located */
IGRshort            hidden_flag;    /* Input:  if TRUE, automatic invisible
                                       symbology overrides will be changed to
                                       hidden; if FALSE, automatic hidden
                                       symbology overrides will be changed
                                       to invisible */
{
    IGRdouble                  *p_parms;
    IGRlong                     OM_stat,
                                mthd_stat,
                                bytes_ret;
    IGRuint                     count;
    IGRint                      child_count,
                                so_count,
                                index1,
                                index2,
                                index3,
                                index4,
                                index5,
                                buf_size,
                                num_edges[4],
                                which_error,
                                num_parents,
                               *p_types,
                                check_clear_bit,
                                set_bit,
                                new_type,
                                num_surfaces,
                                num_surf_grids;
    struct GRid                *children_grid,
                               *edge_array[4],
                                sectvw_grid,
                                ref_pln_grid,
                                component_grid,
                                msc_grid,
                               *surface_grid;
    struct var_list             list[2];
    struct GRmd_env             rp_md_env;
    struct EMSobject_info       parents[2];
    struct GRsymbology          symbology;
    struct IGRdisplay          *p_attr;
    GRobjid                     soo_id;
    OM_S_OBJECT_LINKAGE        *listener_grid;
    OM_S_CHANSELECT	        chanselector;
    IGRshort                    props;
    OMuword                     classid;
    IGRboolean                  sts;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    sectvw_grid.objid = NULL_OBJID;
    edge_array[0] = edge_array[1] = edge_array[2] = edge_array[3] = NULL;
    num_surf_grids = 0;

    /* see if the specified drawing view attachment has a Section View as
     * a child - since a drawing view is not an associative object, it would
     * have to be connected to the Section View object through an ASsource
     * object via the listener channel
     */

    OM_stat = EMmake_chanselect(GRnotify_notification, &chanselector);
    EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$get_channel_count(osnum = dvattach_grid->osnum,
                                   objid = dvattach_grid->objid,
                                   p_chanselect = &chanselector,
                                   count = &count);
    EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    listener_grid = NULL;
    listener_grid = (OM_S_OBJECT_LINKAGE *)alloca(sizeof(OM_S_OBJECT_LINKAGE) *
                                                  count);
    EMerr_hndlr (!listener_grid, *EMmsg, EMS_E_NoStackMemory, wrapup);

    OM_stat = om$get_channel_objects(objid = dvattach_grid->objid,
                                     osnum = dvattach_grid->osnum,
                                     p_chanselect = &chanselector,
                                     count = &count,
                                     size = count,
                                     list = listener_grid);
    EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if (count)
    {
        for (index1 = 0; (index1 < count) && (sectvw_grid.objid == NULL_OBJID);
             index1++)
        {
            OM_stat = om$get_classid(osnum = listener_grid[index1].osnum,
                                     objid = listener_grid[index1].S_objid,
                                     p_classid = &classid);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            OM_stat = om$is_ancestry_valid(subclassid = classid,
                                           superclassid = OPP_ASsource_class_id);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            if (OM_stat == OM_S_SUCCESS)
            {
                OM_stat = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
                                                         NULL, 0,
                                                         &children_grid, 0,
                                                         OM_K_MAXINT,
                                                         &child_count),
                                  senderid = NULL_OBJID,
                                  targetid = listener_grid[index1].S_objid,
                                  targetos = listener_grid[index1].osnum);
                EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_Fail, wrapup);

                for (index2 = 0; index2 < child_count; index2++)
                {
                    OM_stat = om$get_classid(osnum = children_grid[index2].osnum,
                                             objid = children_grid[index2].objid,
                                             p_classid = &classid);
                    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

                    OM_stat = om$is_ancestry_valid(subclassid = classid,
                                                   superclassid = OPP_EMSasectvw_class_id);
                    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

                    if (OM_stat == OM_S_SUCCESS)
                    {
                        sectvw_grid.objid = children_grid[index2].objid;
                        sectvw_grid.osnum = children_grid[index2].osnum;
                        break;
                    }
                }
            }
        }
    }

    if (sectvw_grid.objid != NULL_OBJID)
    {
        /* find the number of objects owned by the Section View and get the
         * edges of each component - some of the components will be composite
         * curves which do not have edges so they are skipped
         */

        OM_stat = EMmake_chanselect(GRcmpowner_to_components, &chanselector);
        EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        OM_stat = om$get_channel_count(osnum = sectvw_grid.osnum,
                                       objid = sectvw_grid.objid,
                                       p_chanselect = &chanselector,
                                       count = &count);
        EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        if (count)
        {
            /* in order to get the graphic edges later, we must find the
             * reference plance that corresponds to the view in which the
             * drawing view attachment was located
             */

            list[0].var = WLD_TO_VIEW;
            list[0].var_ptr = (IGRchar *)rp_md_env.md_env.matrix;
            list[0].num_bytes = sizeof(IGRdouble) * 16;
            list[0].bytes_returned = &bytes_ret;

            list[1].var = END_PARAM;
            list[1].var_ptr = NULL;
            list[1].num_bytes = 0;
            list[1].bytes_returned = NULL;

            OM_stat = dp$inq_set_gragad(msg = &mthd_stat,
                                        osnum = window_grid->osnum,
                                        gragad_objid = window_grid->objid,
                                        which_error = &which_error,
                                        var_list = list);
            EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg, EMS_E_OMerror,
                        wrapup);

            sts = MAtypemx(&mthd_stat, rp_md_env.md_env.matrix,
                           &rp_md_env.md_env.matrix_type);
            EMerr_hndlr (!(1 & sts & mthd_stat), *EMmsg, EMS_E_OMerror, wrapup);

            ems$get_reference_plane_for_given_orientation(msg = &mthd_stat,
                                 env_info = md_env,
                                 refpln_mxtyp = &rp_md_env.md_env.matrix_type,
                                 refpln_mx = rp_md_env.md_env.matrix,
                                 pln_GRid = &ref_pln_grid);

            rp_md_env.md_id.objid = 0;
            rp_md_env.md_id.osnum = 0;   

            /* set up the parents of the horizon loop to send to 
             * EMget_graphics_edges.  
             */  

            num_parents = 2;

            parents[0].grid.objid = ref_pln_grid.objid;
            parents[0].grid.osnum = ref_pln_grid.osnum;
            parents[0].env = rp_md_env;
            parents[1].env = *md_env;
            msc_grid.osnum = md_env->md_id.osnum;

            /* set up the bits to be checked, cleared and set in for the
             * symbology overrides which are dependent on the specified
             * invisible flag
             */

            if (hidden_flag)
            {
                check_clear_bit = DE_INVIS;
                set_bit = DE_HIDDEN;
            }
            else
            {
                check_clear_bit = DE_HIDDEN;
                set_bit = DE_INVIS;
            }

            soo_id = NULL_OBJID;
        }

        for (index1 = 0; index1 < count; index1++)
        {
            OM_stat = om$get_objid_at_index(osnum = sectvw_grid.osnum,
                                            objid = sectvw_grid.objid,
                                            p_chanselect = &chanselector,
                                            index = index1,
                                            objidaddr = &component_grid.objid,
                                            osnumaddr = &component_grid.osnum);
            EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            /* check to make sure the object is a solid since it could be
             * either a solid or a composite surface
             */

            OM_stat = om$get_classid(osnum = component_grid.osnum,
                                     objid = component_grid.objid,
                                     p_classid = &classid);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            OM_stat = om$is_ancestry_valid(subclassid = classid,
                                           superclassid = OPP_EMSsolid_class_id);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            if (OM_stat == OM_S_SUCCESS)
            {
                /* get the surfaces owned by the solid */

                OM_stat = om$send(msg = message GRowner.GRget_number_components(
                                        &mthd_stat, &num_surfaces),
                                  senderid = NULL_OBJID,
                                  targetid = component_grid.objid,
                                  targetos = component_grid.osnum);

                EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg,
                            EMS_E_OMerror, wrapup);

                if (num_surfaces)
                {
                    if (num_surfaces > num_surf_grids)
                    {
                        surface_grid = NULL;
                        surface_grid = (struct GRid *) alloca(num_surfaces *
                                                         sizeof(struct GRid));
                        EMerr_hndlr(! surface_grid, *EMmsg,
                                    EMS_E_NoStackMemory, wrapup);
                        num_surf_grids = num_surfaces;
                    }

                    OM_stat = om$send(msg = message GRowner.GRget_components(
                                            &mthd_stat, md_env, surface_grid,
                                            num_surfaces, &num_surfaces,
                                            0, OM_K_MAXINT),
                                      senderid = NULL_OBJID,
                                      targetid = component_grid.objid,
                                      targetos = component_grid.osnum);

                    EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg,
                                EMS_E_OMerror, wrapup);
                }

                for (index2 = 0; index2 < num_surfaces; index2++)
                {
                    num_edges[0] = 0;
                    buf_size = 0;

                    OM_stat = om$send(msg = message EMSsurface.EMgetedges(
                                        &mthd_stat, EMS_OPT_ALL,
                                        &edge_array[0], &buf_size,
                                        &num_edges[0], NULL, NULL, NULL, NULL),
                                      senderid = NULL_OBJID,
                                      targetid = surface_grid[index2].objid,
                                      targetos = surface_grid[index2].osnum);

                    EMerr_hndlr (!(1 & OM_stat & mthd_stat), *EMmsg,
                                 EMS_E_OMerror, wrapup);

                    /* need to also get the surface's graphic edges
                     * (e.g. horizon edges)
                     */

                    parents[1].grid.objid = component_grid.objid;
                    parents[1].grid.osnum = component_grid.osnum;
                    num_edges[1] = 0;
                    num_edges[2] = 0;
                    num_edges[3] = 0;

                    OM_stat = om$send(msg = message EMSsubbs.EMget_graphics_edges(
                                            &mthd_stat,
                                            &num_parents,
                                            parents,
                                            EMS_OPT_GRALOOP |
                                            EMS_OPT_HORIZON |
                                            EMS_OPT_CUSP,
                                            &num_edges[1],
                                            &num_edges[2],
                                            &num_edges[3],
                                            &edge_array[1],
                                            &edge_array[2],
                                            &edge_array[3]),
                                      senderid = NULL_OBJID,
                                      targetos = surface_grid[index2].osnum,
                                      targetid = surface_grid[index2].objid);
                    EMerr_hndlr (!(1 & OM_stat & mthd_stat), *EMmsg,
                                 EMS_E_OMerror, wrapup);

                    for (index3 = 0; index3 < EDGE_ARRAY_SIZE; index3++)
                    {
                        /* find out if which edges (if any) have
                         * model-space counterparts
                         */

                        for (index4 = 0; index4 < num_edges[index3]; index4++)
                        {
                            OM_stat = om$send(msg = message EMSboundary.EMgetxyzobj(
                                                    &mthd_stat,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL, msc_grid.osnum,
                                                    &msc_grid.objid),
                                              senderid = NULL_OBJID,
                                              targetid = edge_array[index3][index4].objid,
                                              targetos = edge_array[index3][index4].osnum);

                            if ((1 & OM_stat & mthd_stat) &&
                                (msc_grid.objid != NULL_OBJID))
                            {
                                /* get the model-space counterpart's
                                 * graphic properties to determine if it
                                 * has a symbology override
                                 */

                                OM_stat = om$send(msg = message GRgraphics.GRgetprops(
                                                              &mthd_stat,
                                                              &props),
                                                  senderid = NULL_OBJID,
                                                  targetid = msc_grid.objid,
                                                  targetos = msc_grid.osnum);

                                EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg,
                                            EMS_E_OMerror, wrapup);

                                if (props & DEHAS_OVERRIDE)
                                {
                                    /* need to get all the symbology
                                     * overrides on this object; get
                                     * the soo (Symbology Override Object)
                                     * for the object space we are dealing
                                     * with - the model-space counterpart
                                     * object space
                                     */

                                    if (soo_id == NULL_OBJID)
                                    {
                                        de$create_soo(msg = &mthd_stat,
                                                      osnum = msc_grid.osnum,
                                                      p_objid = &soo_id);

                                        EMerr_hndlr((soo_id == NULL_OBJID),
                                                    *EMmsg, EMS_E_OMerror, wrapup);
                                    }

                                    OM_stat = om$send(msg = message GRvg.GRgetsymb
                                                           (&mthd_stat,
                                                            &symbology),
                                                      senderid = NULL_OBJID,
                                                      targetid = msc_grid.objid,
                                                      targetos = msc_grid.osnum);

                                    EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg,
                                                EMS_E_OMerror, wrapup);

                                    OM_stat = om$send(msg = message DEso.DEget( 
                                                        &mthd_stat,
                                                        &p_types,
                                                        &p_parms,
                                                        &so_count,
                                                        &p_attr,
                                                        &symbology.display_attr,
                                                        msc_grid.objid,
                                                        window_grid->objid,
                                                        &md_env->md_env.matrix_type,
                                                        md_env->md_env.matrix,
                                                        AUTOMATIC_SOOS,
                                                        TRUE), /* all soos */
                                                      senderid = NULL_OBJID,
                                                      targetid = soo_id,
                                                      targetos = msc_grid.osnum);

                                    EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg,
                                                EMS_E_OMerror, wrapup);

                                    for (index5 = 0; index5 < so_count; index5++)
                                    {
                                        if (p_types[index5] & check_clear_bit)
                                        {
                                            new_type = p_types[index5] | set_bit;
                                            new_type &= ~check_clear_bit;

                                            de$delete_override(msg = &mthd_stat,
                                                type = p_types[index5],
                                                symbology = &p_attr[index5],
                                                u1 = p_parms[index5 * 2],
                                                u2 = p_parms[(index5 * 2) + 1],
                                                go_grid = &msc_grid,
                                                window_grid = window_grid,
                                                module = md_env);

                                            if (1 & mthd_stat)
                                            {
                                                de$place_override(msg = &mthd_stat,
                                                    type = new_type,
                                                    symbology = &p_attr[index5],
                                                    u1 = p_parms[index5 * 2],
                                                    u2 = p_parms[(index5 * 2) + 1],
                                                    go_grid = &msc_grid,
                                                    window_grid = window_grid,
                                                    module = md_env);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    for (index5 = 0; index5 < EDGE_ARRAY_SIZE; index5++)
                    {
                        if (edge_array[index5])
                        {
                            om$dealloc(ptr = edge_array[index5]);
                            edge_array[index5] = NULL;
                        }
                    }
                }
            }
        }      /* end "for (index1 = 0; index1 < count; index1++)" */
    }

wrapup:

    for (index1 = 0; index1 < EDGE_ARRAY_SIZE; index1++)
    {
        if (edge_array[index1])
            om$dealloc(ptr = edge_array[index1]);
    }

    return(OM_stat);
}

end implementation EMSsurface;
