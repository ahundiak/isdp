/*
  DESCRIPTION:

    This is a special purpose function, that takes as input closed groups
    (when taken to world space) of parametric-curve elements and builds
    surface edges (if they aren't already constructed) and loops out of
    them. Each element is the edge and each subgroup forms a loop. 

    The input information to this function is closely related to the output
    of the EMsfinttrace function. This, with the view that one of the things
    that the user might want to do after calling surface-intersection and
    the trace function is to build the boundary elements. 
  
    Each of these curve elements might have a corresponding curve element on 
    the "other" surface that was involved in the intersection. The two edges 
    are hooked up via the "common_edge" channel if the "connect_to_comedge" 
    flag is set. In case this function determines that there is no common_edge,
    this part of the operation is simply skipped.
  
    If the "reverse_dir" flag is set, the trace of each of the groups is
    reversed in direction. This is achieved by edges on the input list
    being reversed in direction by simply setting their properties bit
    appropriately. The loop is formed in the reverse direction. The control
    information on the trace (num_elems_subgrp, etc.) is NOT updated and
    is now inconsistent with the output.

    The output consists of three two-dimensional arrays - 1) loop-surfaceid
    pairs, 2) pairs of edge-objids which lie at either end of the loopends
    and 3) pairs of pointers to EMsfintedge-structures corresponding to
    the two edges in 2). This last piece of information gives information 
    about where the loop endpoints are incident on the corresponding 
    surface boundary elements.

    During construction of the loops, it's properties is set to active
    and if the loop is closed, the corresponding bit is correctly set.

    The interpretation of the output:
    --------------------------------

    loop_sf[i][j*2] - gives the loopid corresponding to the jth subgroup of the
                      ith group.
    loop_sf[i][j*2+1] - gives the surfaceid on which this loop is created.

    endedges[i][j*2] and
    endedges[i][j*2+1] - are the edges at the ends of the loop, above. The
                         first edge is the start-edge and the second edge is
                         the stop-edge.

    intparms[i][j*2] and 
    intparms[i][j*2+1] - gives the pointers to the pair of EMSsfintedpar that
                         relate to the endpoints (begin, end in that order) of
                         the jth subgroup of the ith group. Consequently,
                         relate to the start of the start-edge and the stop
                         of the stop-edge.

  NOTE
   
    It is very important that the memory allocated for output in this
    function is deallocated solely by the function EMsfintloops_free. The
    manner in which this output memory was allocated is known to it and
    will free it accordingly.

    Also, if the data constructed as output of this function has to be
    freed (EMSloops), then these should be freed using the function -
    EMsfintloops_data_free.

  RETURN VALUE

    Upon exit the completion code will be one of the following:

      Success codes:
      - EMS_S_Success 
          if succeeded

      Error codes:
      - EMS_E_InvalidArg
          if the parmatric-space data is not in object-form or,
          if the object-space of such objects is not the construction
           object space specified as input.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_SurfaceError
          Invocation of a surface method failed.
      - EMS_E_LoopError
          Invocation of a surface method failed.
      - EMS_E_EdgeError
          Invocation of a surface method failed.
      - EMS_E_OMerror
          Call to an OM-primitive failed or,
          Invocation of a method on some object failed.

  BUGS

    In the current version of this function:
      1) The input arguments - "subgrp_rev" and "elem_rev" are ignored.
         This will change as soon as a meaningful interpretation can be
         found which will affect the output.
      2) If the input element does not contain a pre-formed edge (any
         element's "this_uvintobj.datatype" field indicates a
         non-EMSdata_object data) this function will quit with an invalid-
         argument status as the message.
      3) The more_info field in the intersection list is of type EMsfintedpar.
      4) The assumption has been made in this function that if an element
         has a certain characteristic, then all the elements that are at all
         accessible to this function, have the same characteristic. For 
         example, if the first element in the first subgroup of the first
         group has an edge-object as storage mode for the uv-intersection
         curve, then every element has the data stored in this same mode,
         including the counterpart element on the other intersecting surface,
         if such an element exists.

  HISTORY

    SS  : 03/01/87  : Creation
    SM  : 11-Nov-87 : Modified due to argument change
		      in 'EMmodify_edge'. The call to this method sets the
		      'update_range' flag to TRUE.
    SM  : 13-Oct-88 : Fixed the following -
                      1)Made 'outmemptrptr' a double pointer (it
                        was a single pointer).
                      2)Initialized it to NULL.
		      3)Specify 'osnum = construct_os' in om$get_classid.
   Inasu: May 30,91 : Modified file to check for common edge connection 
		      of an edge in the intobj list. If a common edge
		      edge exists means that this edge has been already 
		      traversed as other_uvintobj of its common edge. So the
		      common edge connection part and setting the props is 
	    	      skipped for this edge. 
*/

class implementation Root;

#include "EMS.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrdp.h"
#include "godef.h"
#include "dp.h"
#include "gr.h"
#include "go.h"

#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "OMerrordef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "emssfint.h"
#include "emssfintdef.h"
#include "emsedgedef.h"

#define START 0
#define STOP  1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSpartedge_class_id;

from EMSsubbs import EMpartolbasis, EMgetbsdef;
from EMSloop import EMreverse, EMmodify_edge, EMset_props;
from EMSloop import EMsetrange;
from EMSedge import EMset_props, EMgetbounds;
from EMSpartedge import EMputbounds;

IGRint EMsfintloops (msg, mattyp, mat, construct_os, alttol,
                     num_grps, num_subgrps_grp, num_elems_subgrp,
                     elems, subgrp_rev, elem_rev, grp_closed, subgrp_closed,
                     connect_to_comedges, reverse_dir, 
                     loop_sf, endedges, intparms, sfpartolb)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
GRspacenum construct_os;
IGRdouble *alttol;
IGRint num_grps, *num_subgrps_grp, **num_elems_subgrp;
struct EMSintobj ***elems;
IGRboolean **subgrp_rev, ***elem_rev, *grp_closed, **subgrp_closed;
IGRboolean connect_to_comedges, reverse_dir;
GRobjid ***loop_sf, ***endedges;
struct EMSsfintedpar ****intparms;
IGRdouble ***sfpartolb;
{
  IGRboolean in_world, this_edge_reversed, other_edge_reversed;
  IGRboolean surf1_simpler;
  IGRchar *intparms_ptr;
  IGRushort props, props1, props2;
  IGRint i, j, k, l, blksize, blksize1, blksize2, inxlim, endinx;
  IGRint totnum_subgrps_grp, padding, comm_edge_exists;
  IGRlong stat_OM, msg_loc;
  IGRdouble temp_double;
  GRobjid this_edgeid, other_edgeid, lpid;
  GRobjid **outmemptrptr, *outmemptr, temp_objids[2];
  GRclassid edge_classid;
  struct GRid sfgrid1, sfgrid2;
  struct EMSintobj *intobj_loc;
  struct EMSinters *inters_loc;
  struct EMSpartolbasis partol_basis;
  struct EMSsfintedpar *temp_intparms[2];
  struct IGRbsp_surface sfdef1, sfdef2, *sfptr1, *sfptr2;
  struct EMSedgebound bounds[2], tmpbound;
  OM_S_CHANSELECT chan_to_common_edge;
  IGRboolean EMfirst_surf_simpler();
  IGRboolean update_range = TRUE;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *loop_sf = NULL;
  *endedges = NULL;
  *intparms = NULL;
  *sfpartolb = NULL;
  outmemptr = NULL;
  outmemptrptr = NULL;

  EMerr_hndlr (elems[0][0]->this_uvintobj.datatype != EMSdata_object, 
   *msg, EMS_E_InvalidArg, ret_end);
  EMerr_hndlr (elems[0][0]->this_uvintobj.data.object->osnum != construct_os,
   *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Allocate the memory for
   * output and partition it.
   */

  totnum_subgrps_grp = 0;
  for (i=0; i<num_grps; i++)
    totnum_subgrps_grp += num_subgrps_grp[i];
  padding = 10; /* bytes */

  blksize = /* For the (*loops_sf) array */
              (num_grps * sizeof (GRobjid *)) +
            /* For the (*endedges) array */
              (num_grps * sizeof (GRobjid *)) +
            /* For the (*intparms) array */
              (num_grps * sizeof (struct EMSsfintedpar **)) +
            /* For the (*sfpartolb) array */
              (num_grps * sizeof (IGRdouble *)) +
            /* For all the (*loops_sf)[i] arrays */
              (totnum_subgrps_grp * 2 * sizeof (GRobjid)) +
            /* For all the (*endedges)[i] arrays */
              (totnum_subgrps_grp * 2 * sizeof (GRobjid)) +
            /* For all the (*intparms)[i] arrays */
              (totnum_subgrps_grp * 2 * sizeof (struct EMSsfintedpar *)) +
            /* For all the (*sfpartolb)[i] arrays */
              (totnum_subgrps_grp * sizeof (IGRdouble)) +
            /* Padding to give room for memory allignment */
              padding;

  outmemptrptr = (GRobjid **) om$malloc (size = blksize);
  EMerr_hndlr (!outmemptrptr, *msg, EMS_E_NoDynamicMemory, ret_end);

  *loop_sf = (GRobjid **) outmemptrptr;
  *endedges = (GRobjid **) &(*loop_sf)[num_grps];
  *intparms = (struct EMSsfintedpar ***) &(*endedges)[num_grps];
  *sfpartolb = (IGRdouble **) &(*intparms)[num_grps];
  outmemptr = (GRobjid *) &(*sfpartolb)[num_grps];
  for (i=0; i<num_grps; i++)
    {
    (*loop_sf)[i] = 
         (GRobjid *) outmemptr;
    (*endedges)[i] = 
         (GRobjid *) &((*loop_sf)[i])[num_subgrps_grp[i]*2];
    (*intparms)[i] = 
         (struct EMSsfintedpar **) &((*endedges)[i])[num_subgrps_grp[i]*2];
    (*sfpartolb)[i] = 
         (IGRdouble *) &((*intparms)[i])[num_subgrps_grp[i]*2]; 
    outmemptr = 
         (GRobjid *) &((*sfpartolb)[i])[num_subgrps_grp[i]]; 
    }

  /*
   * Do the construction of the loops and connect up
   * the edges. Reverse the loop if necessary. Then
   * fill up the output arrays. Some initialization
   * is carried out outside the loop as it is invariant.
   */

  partol_basis.is_valid = TRUE;
  partol_basis.in_world = TRUE;
  partol_basis.mattyp = mattyp;
  partol_basis.mat = mat;

/************The channel is always initialized
  if (connect_to_comedges)
    {
    stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common_edge);
    EMomerr_exit (stat_OM, ret_end);
    }
 */

    stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common_edge);
    EMomerr_exit (stat_OM, ret_end);

  for (i=0; i<num_grps; i++)
    {
    for (j=0, k=0; j<num_subgrps_grp[i]; j++, k+=2)
      {
      /*
       * Obtain the surface-id of the surface for this loop,
       * by looking at the first element in this list of intersections.
       * The way to obtain the element's surface is to look at
       * the corresponding EMSinters-node.
       */

      if (elems[i][j]->this_obj_node)
       {
        sfgrid1 = elems[i][j]->this_obj_node->this_obj;
        sfptr1 = (struct IGRbsp_surface *) elems[i][j]->this_obj_node->more_info;
       }
      else
       {
        sfgrid1.objid = NULL_OBJID;
        sfptr1 = NULL;
       }

      (*loop_sf)[i][k+1] = sfgrid1.objid;

      if (connect_to_comedges && ! IF_NULL_OBJID (sfgrid1.objid) &&
	  !sfptr1)
        {
        stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc,
                   &sfdef1), targetid = sfgrid1.objid, 
                   targetos = sfgrid1.osnum, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
        }
      /*
       * Obtain the surface's parametric basis tolerance. This
       * is a part of the final output. It is also useful for
       * further computations within this function itself.
       */

      if (alttol)
        partol_basis.tol = *alttol;
      else if (!IF_NULL_OBJID (sfgrid1.objid) && !sfptr1)
        {
        in_world = TRUE;
        stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                   mattyp, mat, &in_world, FALSE, &partol_basis.tol), 
                   targetid = sfgrid1.objid, targetos = sfgrid1.osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
        }
      else if(sfptr1)
        {
	 stat_OM = EFsspbtol_by_geom(&msg_loc, sfptr1, &partol_basis.tol);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
        }
      else
        partol_basis.tol = 0.0;
      (*sfpartolb)[i][j] = partol_basis.tol;

      props = EMLP_ACTIVE | EMLP_NEW;
      if (! subgrp_closed[i][j])
        props |= EMLP_OPEN;

      stat_OM = om$construct (classname = "EMSloop", p_objid = &lpid, 
                 msg = message EMSloop.EMset_props (&msg_loc, props,
                 EMS_O_SET), osnum = construct_os);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_OMerror, ret_end);
      (*loop_sf)[i][k] = lpid;

      intobj_loc = elems[i][j];
      inxlim = num_elems_subgrp[i][j];
      for (l=0; l<inxlim; l++)
        {
        props1 = NULL;
        props2 = NULL;

        /*
         * If this edge is close in model-space, set the property bit
         * indicating the same.
         */

        if (grp_closed[i] && num_subgrps_grp[i] == 1 && inxlim == 1)
          props1 |= EMED_XYZ_CLOSED;
            
        /*
         * If this edge is indicated as a tangent edge by the EMSintobj
         * property, set this.
         */
        if (intobj_loc->props & EMSintobj_xyz_closed)
          {
          props1 |= EMED_XYZ_CLOSED; 
          props2 |= EMED_XYZ_CLOSED; 
          }

        if (intobj_loc->props & EMSintobj_tangent)
          {
          props1 |= EMED_TANGENT;
          props2 |= EMED_TANGENT;
          }

        if (intobj_loc->props & EMSintobj_seam)
          {
          props1 |= EMED_SEAM;
          props2 |= EMED_SEAM;
          }

        /*
         * Check if this edge has to be reversed. If so, then perform
         * the necessary action
         */

        this_edgeid = intobj_loc->this_uvintobj.data.object->objid;
        this_edge_reversed = intobj_loc->reversed;
        if (this_edge_reversed)
          {
          /*
           * In the case of all edges, except partedges, it suffices to
           * toggle the reverse bit in the properties field. But for a
           * partedge, it's boundary needs to be reversed too.
           */

          stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                     EMED_REVERSED, EMS_O_TOGGLE), targetid = this_edgeid,
                     targetos = construct_os, senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);

          stat_OM = om$get_classid (osnum = construct_os, 
		     objid = this_edgeid, 
                     p_classid = &edge_classid);
          EMomerr_exit (stat_OM, ret_end);

          stat_OM = om$is_ancestry_valid (subclassid = edge_classid,
                     superclassid = OPP_EMSpartedge_class_id);
          EMomerr_exit (stat_OM, ret_end);

          if (stat_OM == OM_S_SUCCESS)
            {
            stat_OM = om$send (msg = message EMSedge.EMgetbounds (&msg_loc,
                       bounds), targetid = this_edgeid, 
                       targetos = construct_os, senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);

            tmpbound = bounds[START];
            bounds[START] = bounds[STOP];
            bounds[STOP] = tmpbound;

            stat_OM = om$send (msg = message EMSpartedge.EMputbounds (&msg_loc,
                       bounds), targetid = this_edgeid, 
                       targetos = construct_os, senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);
            }
          }

	/* 
         * check whether edge have a common edge. If true, 
         * then skip the common edge connection.
         */

        other_edgeid = NULL_OBJID;
        comm_edge_exists = 0;
        om$get_channel_count (objid = this_edgeid, osnum = construct_os,
         p_chanselect =  &chan_to_common_edge, count = (OMuint *)&comm_edge_exists);

        if (!comm_edge_exists)
          {
          if (connect_to_comedges && intobj_loc->other_intobj_node)
            {
            other_edgeid = intobj_loc->other_intobj_node->this_uvintobj.
                            data.object->objid;
            other_edge_reversed = intobj_loc->other_intobj_node->reversed;
            
            stat_OM = om$send (msg = message Root.connect (chan_to_common_edge,
                       0, this_edgeid, construct_os, chan_to_common_edge, 0),
                       targetid = other_edgeid, targetos = construct_os,
                       senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);

            if ((this_edge_reversed && !other_edge_reversed) ||
                (!this_edge_reversed && other_edge_reversed))
              {
              props1 |= EMED_REVERSE_CONNECT;
              props2 |= EMED_REVERSE_CONNECT;
              }

            props2 |= EMED_SUBORDINATE;
            if ((! IF_NULL_OBJID (sfgrid1.objid)) &&
                (inters_loc = intobj_loc->other_intobj_node->this_obj_node))
              {
              sfgrid2 = inters_loc->this_obj;
              sfptr2 = (struct IGRbsp_surface *) inters_loc->more_info;
	  
              if (!IF_NULL_OBJID  (sfgrid2.objid))
                {
                if (!sfptr2)
                  {
                  stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef
                             (&msg_loc, &sfdef2), targetid = sfgrid2.objid, 
                             targetos = sfgrid2.osnum, senderid = NULL_OBJID);
                  EMomerr_exit (stat_OM, ret_end);
                  EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_SurfaceError,
                   ret_end);
                  }
                surf1_simpler = EMfirst_surf_simpler (
                                 sfptr1 ? sfptr1 : &sfdef1, 
			         sfptr2 ? sfptr2 : &sfdef2);
                if (surf1_simpler)
                  {
                  props1 &= ~EMED_SUBORDINATE;
                  props2 |= EMED_SUBORDINATE;
                  }
                else
                  {
                  props1 |= EMED_SUBORDINATE;
                  props2 &= ~EMED_SUBORDINATE;
                  }
                }
              }
            }
          }

        /*
         * Set the properties for the edges
         */

        if (props1)
          {
          stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                     props1, EMS_O_ON), targetid = this_edgeid,
                     targetos = construct_os, senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
          }
        if (props2 && !IF_NULL_OBJID (other_edgeid))
          {
          stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                     props2, EMS_O_ON), targetid = other_edgeid,
                     targetos = construct_os, senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
          }

        stat_OM = om$send (msg = message EMSloop.EMmodify_edge (&msg_loc,
                   EMS_INS_ATEND, 1, NULL_OBJID, &this_edgeid, update_range), 
                   targetid = lpid, targetos = construct_os, 
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_LoopError, ret_end);

        /*
         * the endedges-array is initialized when either
         * the first or the last edge of the loop is being
         * processed. The reverse_dir is important here. The field
         * 'more_info' is with respect to the original edge-direction;
         * so if the edge is actually reversed, this has to be taken
         * into account.
         */

        if (l == 0)
          {
          if (intobj_loc->more_info)
            intparms_ptr = this_edge_reversed ? (IGRchar *) 
                     ((struct EMSsfintedpar *) intobj_loc->more_info)->next : 
                     intobj_loc->more_info;
          else
            intparms_ptr = NULL;

          if (!reverse_dir)
            endinx = k;
          else
            endinx = k+1;

          (*endedges)[i][endinx] = this_edgeid;
          (*intparms)[i][endinx] = (struct EMSsfintedpar *) intparms_ptr;
          }

        if (l == inxlim - 1)
          {
          if (intobj_loc->more_info)
            intparms_ptr = !this_edge_reversed ? (IGRchar *) 
                     ((struct EMSsfintedpar *) intobj_loc->more_info)->next :
                     intobj_loc->more_info;
          else
            intparms_ptr = NULL;

          if (!reverse_dir)
            endinx = k+1;
          else
            endinx = k;

          (*endedges)[i][endinx] = this_edgeid;
          (*intparms)[i][endinx] = (struct EMSsfintedpar *) intparms_ptr;
          }

        intobj_loc = intobj_loc->next;
        }

      stat_OM = om$send (msg = message EMSloop.EMsetrange (&msg_loc),
                 targetid = lpid, targetos = construct_os,
                 senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_LoopError, ret_end);

      if (reverse_dir)
        {
        stat_OM = om$send (msg = message EMSloop.EMreverse (&msg_loc),
                   targetid = lpid, targetos = construct_os,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_LoopError, ret_end);
        }
      }

    if (reverse_dir)
      {
      /*
       * Arrays that contain information on the subgroups
       * in this group must be reversed. These arrays are:
       * 'loop_sf', 'endedges', 'intparms', 'sfpartolb'.
       */

      inxlim = (num_subgrps_grp[i] / 2) * 2;
      endinx = (num_subgrps_grp[i]-1) * 2;
      blksize1 = 2 * sizeof (GRobjid);
      blksize2 = 2 * sizeof (struct EMsfintedpars *);
      for (j=0, k=endinx; j<inxlim; j+=2, k-=2)
        {
        OM_BLOCK_MOVE (&(*loop_sf)[i][j], temp_objids, blksize1);
        OM_BLOCK_MOVE (&(*loop_sf)[i][k], &(*loop_sf)[i][j], blksize1);
        OM_BLOCK_MOVE (temp_objids, &(*loop_sf)[i][k], blksize1);

        OM_BLOCK_MOVE (&(*endedges)[i][j], temp_objids, blksize1);
        OM_BLOCK_MOVE (&(*endedges)[i][k], &(*endedges)[i][j], blksize1);
        OM_BLOCK_MOVE (temp_objids, &(*endedges)[i][k], blksize1);

        OM_BLOCK_MOVE (&(*intparms)[i][j], temp_intparms, blksize2);
        OM_BLOCK_MOVE (&(*intparms)[i][k], &(*intparms)[i][j], blksize2);
        OM_BLOCK_MOVE (temp_intparms, &(*intparms)[i][k], blksize2);
        }
      inxlim = num_subgrps_grp[i] / 2;
      endinx = num_subgrps_grp[i] - 1;
      for (j=0, k=endinx; j<inxlim; j++, k--)
        {
        temp_double = (*sfpartolb)[i][j];
        (*sfpartolb)[i][j] = (*sfpartolb)[i][k];
        (*sfpartolb)[i][k] = temp_double;
        }
      }
    }
  
ret_end:
  if (EMSerror (*msg))
    {
    /*
     * Deallocate any output-memory allocated,
     * as error has occurred.
     */

    if (outmemptrptr)
      om$dealloc (ptr = outmemptrptr);
    }
  EMWRAPUP (*msg, stat_OM, "EMsfintloops");
  return (stat_OM);
}

void EMsfintloops_data_free (num_grps, num_subgrps_grp, loop_sf, loop_os)
IGRint num_grps;
IGRint *num_subgrps_grp;
GRobjid **loop_sf;
GRspacenum loop_os;
{
  IGRint i, j, k;

  if (loop_sf)
    for (i=0; i<num_grps; i++)
      for (j=0, k=0; j<num_subgrps_grp[i]; j++, k+=2)
        om$send (msg = message Root.delete (TRUE), targetid = loop_sf[i][k],
         targetos = loop_os, senderid = NULL_OBJID);
}


void EMsfintloops_free (loop_sf, endedges, intparms, sfpartolb)
GRobjid **loop_sf, **endedges;
struct EMsfintedpar ***intparms;
IGRdouble **sfpartolb;
{
  if (loop_sf)
    om$dealloc (ptr = loop_sf);
}

end implementation Root;

