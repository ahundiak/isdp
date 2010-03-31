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
#include "EMSlcdef.h"
#include "grmsg.h"        /* for error/return codes */
#include "msdef.h"        /* for error/return codes */
#include "bsmdptcvbx.h"

#define NUM_LOOP_TYPES 4

#define LOOPSET_EDGES  0
#define HRZLOOP_EDGES  1
#define GRALOOP_EDGES  2
#define CUSPLOOP_EDGES 3

/*

Name
    EFsurface_edge_locate

History
    WBC      05/20/93      Creation Date.
    Sudha    07/09/93      Modified for BSprototypes anisfication
    S.Heard  07/18/93      Major overhaul of code to 
    WBC      01/20/94      Fixed a problem where the address of
                           common_edge_grid was used outside the scope of
                           it definition.

Abstract
  This function locates edges on a specified surface and returns a model
space counterpart of the first non-subordinate displayable edge that is
within tolerance of the input boreline.  After each edge is processed an
user specified function will be called to determine if this function should
stop processing.

Synopsis

  struct GRid     *surf_grid           Input:  the surface from which to
                                               select an edge
  struct IGRline  *boreline            Input:  boreline to be used in selecting
                                               edges of the surface
  IGRint           (*stopproc_func)()  Input:  if not NULL, points to the
					       function which is called
                                               periodically to determine if
                                               this routine should stop
                                               processing and return
  struct GRmd_env *md_env              Input:  module environment of the
                                               surface
  IGRdouble        tolerance           Input:  tolerance to be used with the
                                               boreline when determining if
                                               an edge is "hit"
  struct GRid     *msc_grid            Output: the id of a model space
                                               counterpart representing the
                                               selected edge; objid set to
					       NULL_OBJID when not found.

Return Values
    MSSUCC           -  an edge of the specified surface is within tolerance of
                        the specified boreline and its model space counterpart
                        is being returned
    GR_I_EleNotFound - Either none of the surface's edges were within tolerance
                       of the specified boreline or if any edges were within
                       tolerance they were either subordinate or not displayed.
    GR_I_Stopped     - The specified function indicated processing should stop.
    MSFAIL           - A method of function called by this function failed.
*/

from EMSsubbs import    EMget_edges;
from EMSedge  import    EMget_props_type,
                        EMget_bcxyz_geom;
from EMSboundary import EMgetxyzobj;
from EMShelper import   EMget_the_edges;


IGRint EFsurface_edge_locate( surf_grid, 
			      boreline, 
			      stopproc_func,
			      md_env,
                              tolerance, 
			      msc_grid)

struct GRid     *surf_grid;
struct IGRline  *boreline;
IGRint           (*stopproc_func)();
struct GRmd_env *md_env;
IGRdouble        tolerance;
struct GRid     *msc_grid;
{
  void                   BSmdptcvbx();
  IGRboolean             EMhitcvbuff();
  struct GRid           *edge_grids,
                       **graloop_edges,
                       **hrzloop_edges,
                       **cusploop_edges;
  struct IGRbsp_curve    curve_geom;
  OM_S_CHANSELECT        to_helpers;
  OM_S_CHANSELECT        to_common_edge;
  IGRdouble              param,
                         z_vector[3];
  IGRpoint               isect_point;
  IGRlong                OM_stat,
                         mthd_stat;
  IGRint                 sts,
                         array_size,
                         num_edges,
                         edge_index,
                         loop_index,
                         num_gralp_edges,
                         num_horiz_edges,
                         num_cusp_edges;
  BSrc                   rc;
  IGRshort               options;
  IGRushort              curve_props;
  IGRboolean             found;
  IGRuchar               curve_type;

  OM_stat = OM_S_SUCCESS;

  /* initialize to "not found" state */
  sts =  GR_I_EleNotFound;
  array_size = 0;
  edge_grids = NULL;
  curve_geom.poles = curve_geom.knots = curve_geom.weights = NULL;
  found = FALSE;
  msc_grid->osnum = surf_grid->osnum;
  msc_grid->objid = NULL_OBJID;

  /*
   * For each helper, get it's edge(s)
   */
  EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);

  for (loop_index = 0; (loop_index < NUM_LOOP_TYPES) && !found; loop_index++)
  {
    if (stopproc_func)
    {
      if ((*stopproc_func)())
      {
        sts = GR_I_Stopped;
        goto wrapup;
      }
    }
    num_edges = 0;

    if (loop_index == LOOPSET_EDGES)
    {
      OM_stat = om$send(msg = message EMSsubbs.EMget_edges(&mthd_stat,
                                                           OM_K_MAXINT,
                                                           EMS_OPT_ALL,
                                                           md_env,
                                                           &edge_grids,
                                                           &array_size,
                                                           &num_edges),
                            senderid = NULL_OBJID,
                            targetid = surf_grid->objid,
                            targetos = surf_grid->osnum);
      EMerr_hndlr(!(1 & OM_stat & mthd_stat), sts, MSFAIL, wrapup);
    }
    else
    {
      if (edge_grids)
      {
          om$dealloc(ptr = edge_grids);
          edge_grids = NULL;
      }

      /* loop through to get the helper loop edges one type at a time */

      edge_grids = (struct GRid *) om$malloc(size = 32 *
                                           sizeof(struct GRid));
      if (edge_grids)
      {
        if (loop_index == HRZLOOP_EDGES)
        {
          /* the z vector is defined by the input boreline; this
           * vector is needed to determine which horizon edges are
           * to be accepted since horizon edges are view dependent
           */
          z_vector[0] = boreline->point2[0] - boreline->point1[0];
          z_vector[1] = boreline->point2[1] - boreline->point1[1];
          z_vector[2] = boreline->point2[2] - boreline->point1[2];

          options = EMS_OPT_HORIZON;
          hrzloop_edges = &edge_grids;
          graloop_edges = NULL;
          cusploop_edges = NULL;
        }
        else if (loop_index == GRALOOP_EDGES)
        {
          options = EMS_OPT_GRALOOP;
          graloop_edges = &edge_grids;
          hrzloop_edges = NULL;
          cusploop_edges = NULL;
        }
        else /* loop_index == CUSPLOOP_EDGES */
        {
          options = EMS_OPT_CUSP;
          cusploop_edges = &edge_grids;
          graloop_edges = NULL;
          hrzloop_edges = NULL;
        }

        num_gralp_edges = 0;
        num_horiz_edges = 0;
        num_cusp_edges = 0;

        OM_stat = om$send(msg = message EMShelper.EMget_the_edges(
                                                 &mthd_stat,
                                                 options,
                                                 z_vector,
                                                 &md_env->md_env,
                                                 &num_gralp_edges,
                                                 &num_horiz_edges,
                                                 &num_cusp_edges,
                                                 graloop_edges,
                                                 hrzloop_edges,
                                                 cusploop_edges),
                          senderid = surf_grid->objid,
                          targetos = surf_grid->osnum,
                          p_chanselect = &to_helpers);

        if (1 & OM_stat & mthd_stat)
        {
          if (loop_index == GRALOOP_EDGES)
            num_edges = num_gralp_edges;
          else if (loop_index == HRZLOOP_EDGES)
            num_edges = num_horiz_edges;
          else /* loop_index == CUSPLOOP_EDGES */
            num_edges = num_cusp_edges;
        }
      }
    }

    for (edge_index = 0; (edge_index < num_edges) && !found; edge_index++)
    {
      if (stopproc_func)
      {
        if ((*stopproc_func)())
        {
          sts = GR_I_Stopped;
          goto wrapup;
        }
      }

      OM_stat = om$send(
         msg = message EMSedge.EMget_props_type( &mthd_stat,
                                                 &curve_props,
                                                 &curve_type),
         senderid = NULL_OBJID,
         targetid = edge_grids[edge_index].objid,
         targetos = edge_grids[edge_index].osnum );

      /*
       * Since we will only be investigating the first curve we hit, we
       * don't care if the edge is subordinate (EMED_SUBORDINATE), just
       * as long as it is displayed.
       */
      if ((1 & OM_stat & mthd_stat) && !(curve_props & EMED_NO_DISPLAY))
      {
        OM_stat = om$send(
           msg = message EMSedge.EMget_bcxyz_geom( &mthd_stat,
                                                   &md_env->md_env,
                                                    surf_grid,
                                                    NULL,
                                                    0,
                                                    MAXINT,
                                                    FALSE,
                                                    NULL,
                                                   &curve_geom),
           senderid = NULL_OBJID,
           targetid = edge_grids[edge_index].objid,
           targetos = edge_grids[edge_index].osnum);

        if (1 & OM_stat & mthd_stat)
        {
          /*
           * determine if the boreline is within tolerance of the
           * curve
           */

          BSmdptcvbx( &curve_geom,
                       boreline->point1,
                       boreline->point2,
                       tolerance,
                      &param,
                       isect_point,
                      &found,
                      &rc );

          if (rc != BSSUCC)
          {
            found = FALSE;
          }
          else if (found)
          {
            struct GRid  *p_grid,
                          common_edge_grid;
            OM_S_OBJECT_LINKAGE obj_list;
            OMuint count;

            /*
             * If it is subordinate, see if the common (dominant) edge
             * has a MSC.  If it does, return it.  Otherwise, use the
             * one found.
             */
            if (curve_props & EMED_SUBORDINATE)
            {
              EMmake_chanselect ( EMSedge_to_common_edge,
                                  &to_common_edge );

              sts = om$get_channel_objects(
                      p_chanselect = &to_common_edge,
                      osnum        =  edge_grids[edge_index].osnum,
                      objid        =  edge_grids[edge_index].objid,
                      list         = &obj_list,
                      size         =  1,
                      count        = &count );
              if (!(1&sts) || count == 0 )
              {
                sts = GR_I_EleNotFound;
                goto wrapup;
              }
	      else
	      {

                common_edge_grid.objid = obj_list.S_objid;
                common_edge_grid.osnum = obj_list.osnum;

                OM_stat = om$send(
                   msg = message EMSedge.EMget_props_type( &mthd_stat,
                                                           &curve_props,
                                                           &curve_type ),
                   senderid = NULL_OBJID,
                   targetid = common_edge_grid.objid,
                   targetos = common_edge_grid.osnum );

                if (!(1&OM_stat))
                {
                  sts = GR_I_EleNotFound;
                  goto wrapup;
                }
                else
                {
                  p_grid = &common_edge_grid;
                }
	      }
            }
            else
            {
              p_grid = &edge_grids[edge_index];
            }


            OM_stat = om$send(
                msg = message EMSboundary.EMgetxyzobj(
                         &mthd_stat,
                          NULL, /* create MSC if necessary */
                         &md_env->md_env,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          p_grid->osnum,
                         &msc_grid->objid ),
                senderid = NULL_OBJID,
                targetid = p_grid->objid,
                targetos = p_grid->osnum );

            if ((1 & OM_stat) && (mthd_stat != EMS_I_NotFound))
            {
              sts = MSSUCC;
              msc_grid->osnum = p_grid->osnum;
            }
            else
            {
              msc_grid->osnum = p_grid->osnum;
              msc_grid->objid = NULL_OBJID;
              sts = GR_I_EleNotFound;
              goto wrapup;
            }
          }

          /* deallocate the memory for the b-spline curve */
          if (curve_geom.poles)
          {
            om$dealloc(ptr = curve_geom.poles);
            curve_geom.poles = NULL;
          }

          if (curve_geom.knots)
          {
            om$dealloc(ptr = curve_geom.knots);
            curve_geom.knots = NULL;
          }

          if (curve_geom.weights)
          {
            om$dealloc(ptr = curve_geom.weights);
            curve_geom.weights = NULL;
          }

          if ( found && ( msc_grid->objid != NULL_OBJID ) )
	  {
	    /* HAVE WHAT WE WANT! */
	    goto wrapup;
	  }
        }
      }
    }
  }

wrapup:

  /* deallocate the array of edges as well as the bspline curve info */

  if (edge_grids)
      om$dealloc(ptr = edge_grids);

  if (curve_geom.poles)
      om$dealloc(ptr = curve_geom.poles);

  if (curve_geom.knots)
      om$dealloc(ptr = curve_geom.knots);

  if (curve_geom.weights)
      om$dealloc(ptr = curve_geom.weights);

  return(sts);
}

end implementation EMSsurface;
