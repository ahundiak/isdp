/*
 * DESCRIPTION:
      This method is typically invoked by init associative, to perform the
      computation of round, under associativity.  It accepts a parent list,
      other re-compute information, and performs the rounding.  On error,
      it passes back an error packet through a global.  The nature of the
      parents is described in the placement function, EMround_chamfer_edges().

 * INPUT: 
      options		valid ones are:
                   	  EMSascons_recompute
      old_objid		unused.
      num_parents	Number of parents in 'parent_info'.
      parent_info	Parents of 'my_id' as an array of struct GRid.  These
                        are not the true parents (i.e. they are not radii,
                        loops, or edges objects, but their associative 
                        eqivalents, as created by init associative).
                        The nature of the parents is described within
                        EMround_chamfer_edges().
      type		The type of the operation 'my_id'.  Valid ones are:
                        EMS_ASchamfer, EMS_ASround.
      other_recomp_info Information needed for re-computation.  This is
                        an instance of EMSround_chamfer structure.
      construct_list	Construction environment.

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      EMrnd_error_info	In case of an error in EMround(),  this GLOBAL
                        (ouch) carries back the error packet.

 * ALGORITHM:
      . Utilizing the information encoded within the parent list [see comments
        within EMround_chamfer_edges() for a description of what information
        is encoded within the parent list], construct an array of edges as
        instances of struct EMSrnd_boundary_input.  Using these edges, perform
        the rounding.
        See comments within individual STEPs for further information.

 * HISTORY:
       ?          ?        :Original.
      Siki   : during 1992 : Re-write.
      Janaka : 01/07/1993  : Re-write for Phoenix.
      Jack   : 06/18/1993  : if "type" happens to equal the old type EMS_ASchamfer_uniform,
                             go ahead and set local_options = EMS_RND_CHAMFER.  Need to
                             do this to support pre-240 chamfers.
      Sudha    06/23/93      Modified for BSprototype ansification
      WBC    : 12/17/93    : Update the display_ids in the EMSdprparam object
                             at the end of the method if necessary.
                             Currently, if an error is returned by certain
                             method/function calls, the display_ids may not
                             be posted.
*/

class implementation EMSsfrndbool;

#include <math.h>
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bschangepar.h"
#include "msmacros.h"
#include "bsconic.h"
#include "emsedgedef.h"
#include "EMSbnd.h"
#include "bsgeom_cvsf.h"
#include "EMSrndprotyp.h"


from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSedge	 import EMxyz_endpt, EMchkconvex, EMget_props;

#define FIRST      0
#define LAST       1
#define START      0
#define STOP       1
#define UNDEFINED -1

%safe
/*
 * The following is used to pass back the round error packet to
 * EMround_chamfer_edges() [there is no way to pass operation
 * specific arguments through init_associative()].
 */

   struct EMSrnd_error  *EMrnd_error_info = NULL;
%endsafe

#argsused

method EMconstruct_associative( IGRlong *EMmsg; IGRushort options;
                                GRobjid old_objid;
                                IGRint num_parents; IGRchar *parent_info;
                                IGRint type;
                                IGRchar *other_recomp_info;
                                struct GRvg_construct *construct_list )
{
  IGRboolean		recompute, is_neutral, update_display_ids = FALSE;
  IGRushort		local_options;
  IGRint		i, j, k, m, n, num_edges, local_num_parents,
                        edge_count, num_loop_edges, display_count,
                        chain_free_ends[2], edge_end_index;
  IGRuint       	*parent_types, active_id_parent_type;
  OMuint		count;
  IGRlong		msg, OM_stat;
  IGRdouble     	save_cht;
  GRobjid		*display_ids, paramobj;
  GRclassid		parent_class;
  OM_S_CHANSELECT	to_comps;

  union  EMSparent_info  	*parents, active_id_parent;
  struct GRid		 	*parent_GRids, *loop_edges, edge_out,
                                *chain_eds;
  struct EMSrnd_boundary_input	*edges;
  struct GRmd_env		*md_env;
  struct EMSrnd_error   	*rnd_error;

  extern GRclassid	OPP_expression_class_id,
                        OPP_EMSloop_class_id;
  extern IGRlong	EMgenerate_missing_radii();
  extern IGRlong	EMget_loop_dominant_non_neutral_edges();
  

 /*
  * STEP 0: Initialize.
  */
     *EMmsg = EMS_S_Success;
     OM_stat = OM_S_SUCCESS;
     local_options = 0;
     parent_GRids = ( struct GRid * ) parent_info;
     md_env = construct_list->env_info;
     EMmake_chanselect( EMSbd_owner_to_comps, &to_comps );
     save_cht = 0;
     rnd_error = NULL;
     rnd_error = ( struct EMSrnd_error * ) om$malloc
                      ( size = sizeof( struct EMSrnd_error ) );
     EMerr_hndlr( !rnd_error, *EMmsg, EMS_E_NoDynamicMemory, wrapup );
     rnd_error->fail_edges = NULL;
     rnd_error->kind_of_failure = NULL;
     rnd_error->start_vtx = NULL;
     rnd_error->stop_vtx = NULL;

 /*
  * STEP 1:
  *
  * . Determine the operation type (round or chamfer).
  * . Determine the parent types (EMSdistance for radius, and EMSgrid
  *   for a loop or an edge), and the true parents (i.e. the radii values,
  *   loop grids, and edge grids).
  * . Count the number of edges (excluding neutral edges within loops).
  * . Construct the array of round edges, utilizing the information
  *   encoded within the parent list.
  */
     if( ( type == EMS_ASchamfer ) || ( type == EMS_ASchamfer_uniform ) )
        local_options = EMS_RND_CHAMFER;

     local_num_parents = num_parents - 1; /* Avoid the active id */
     parent_types = ( IGRuint * ) alloca
                      ( local_num_parents * sizeof( IGRuint ) );
     for( i = 0; i < local_num_parents; i++ )
     {
        OM_stat = om$get_classid( objid = parent_GRids[i].objid,
                              osnum = parent_GRids[i].osnum,
                              p_classid = &parent_class );
        EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );
        OM_stat = om$is_ancestry_valid( subclassid = parent_class,
                       superclassid = OPP_expression_class_id );
        EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );
        if( OM_stat != OM_I_INVANCESTRY )
           parent_types[i] = EMSdistance;
        else
           parent_types[i] = EMSgrid;
     }

     parents = ( union EMSparent_info * ) alloca
                 ( local_num_parents * sizeof( union EMSparent_info ) );
     OM_stat = om$send( msg = message EMSassoc.EMget_parent_info
                               ( &msg,
                                 ( IGRushort ) 0,
                                 ( IGRuint ) local_num_parents,
                                 parent_info,
                                 parent_types,
                                 parents ),
                        targetid = my_id );

     EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

     /* Count the edges */
     for( i = 0, num_edges = 0; i < local_num_parents; i++ )
     {
        if( parent_types[i] != EMSdistance )
        {
           /* Parent must be either a loop or an edge */
           count = 1;  /* Assume the parent to be an edge */
           OM_stat = om$get_classid( objid = parents[i].grobj.grid.objid,
                               osnum = parents[i].grobj.grid.osnum,
                               p_classid = &parent_class );

           EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );
           if( parent_class == OPP_EMSloop_class_id )
           {
              /* Obtain the edge count for this loop, leaving out the
               * neutral edges.
               */
              OM_stat = EMget_loop_dominant_non_neutral_edges(
                                    &msg, ( IGRushort ) 0,
                                    md_env, &parents[i].grobj.grid,
                                    0, NULL, &num_loop_edges );
              EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, msg, wrapup );
              count = num_loop_edges;
           }
           num_edges += count;
        }
     }

     /*
      * Create the 'edges' array and initialize.
      */
         edges = ( struct EMSrnd_boundary_input * ) alloca
                  ( num_edges * sizeof( struct EMSrnd_boundary_input ) );
         for( i = 0; i < num_edges; i++ )
         {
            edges[i].boundary_id.objid = NULL_OBJID;
            edges[i].other_radius.type =
            edges[i].radius.type =
            edges[i].rho_value.type =  EMSdatainfo_undefined;
            edges[i].props = 0;
            edges[i].options = 0;
         }

     /* Create an array to hold edges for free edges. */
         chain_eds = ( struct GRid * ) alloca
                                ( num_edges * sizeof( struct GRid ) );

     /* Traverse the parents list, looking for groups of edges [the acceptable
      * edge groupings are commented within EMround_chamfer_edges()], and
      * construct the 'edges' array based on the information encoded within
      * each edge group.
      * At the start of each boundary element group, there will be at least
      * one radius, and at most two radii.  If the boundary element is a loop,
      * then it will be preceeded by a single radius.  If the boundary element
      * is an edge (or a collection of edges), then it may be preceeded by one
      * or two radius values.  The latter indicates either a single edge
      * variable radius rounding, or multiple edge variable radius rounding
      * (for which only two radii are available).  In the case of multiple
      * edge variable radius rounding, the intermediate radii are generated
      * by interpolating along the edge length.
      * The occurance of a single radius implies constant radius rounding.
      * Recall that array 'parents' has the true parents, and the type of
      * information stored within that array is encoded within 'parent_types'
      * array.
      * i .. index into parent list.  It increments over each edge group.
      * j .. index into edges list.
      */
         for( i = 0, j=0; i < local_num_parents; )
         {
            /* Look for at least one radius at the start of the edge
             * group.
             */
                if( parent_types[i] == EMSdistance )
                {
                  /* Look for the second radius. Its presence indicates
                   * variable radius rounding.
                   */
 
                  if( parent_types[i+1] == EMSdistance )
                  {
                     /* Variable radius rounding.  Need to differentiate
                      * between a single edge case, and a group of edges case.
                      * Count the number of edges in this group.
                      */
                     for( k = i+3 /* i+2 MUST be an edge */;
                          k < local_num_parents &&
                                  parent_types[k] != EMSdistance;
                          k++ );

                     if( ( k - 3 ) == i )
                     {
                        /* There is only one edge in this group */
                        OM_BLOCK_MOVE( &parents[i+2].grobj.grid,
                                       &edges[ j ].boundary_id,
                                       sizeof( struct GRid ) );
                        edges[j].radius.val = parents[i].value;
                        edges[j].other_radius.val = parents[i+1].value;
                        edges[j].radius.type =
                        edges[j].other_radius.type = EMSdatainfo_numeric;
                        edges[j].props = EMSfillet_is_variable_radius;
                        ++j;
                        i = k; /* Two radii and the edge */
                     }
                     else
                     {
                        /* Multiple edge case:
                         * . Determine to which logical ends of edge_1, and
                         *   edge_n does the two radii apply, and assign them.
                         * . Generate the intermediate radii.
                         */

                        /* This edge group within the 'edges' array is marked
                         * by the start index 'j', and the following end
                         * index.
                         */
                            edge_end_index = j + ( k - 1 ) - ( i + 2 );

                        for( m = 0, n = i+2; n <= k-1; n++, m++ )
                         OM_BLOCK_MOVE( &parents[n].grobj.grid,
                                        &chain_eds[m],
                                        sizeof( struct GRid ) );

                        OM_stat = EMget_chain_free_ends( &msg,
                                      ( IGRushort ) 0, md_env,
                                      chain_eds, m, chain_free_ends );
                        EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                     EMS_E_Fail, wrapup );
                        /* Assign the two radii to the start and end edges of
                         * the chain, and assign the edge ids.
                         */
                          edges[j].radius.type = EMSdatainfo_numeric;
                          edges[j].radius.val = parents[i].value;
                          edges[edge_end_index].other_radius.type=EMSdatainfo_numeric;
                          edges[edge_end_index].other_radius.val = 
                                          parents[i+1].value;
/*
                            for( m = 0; m <= 1; m++ )
                            {
                               n = m ? edge_end_index : j;
                               if( chain_free_ends[m] == START )
                               {
                                  edges[n].radius.type = EMSdatainfo_numeric;
                                  edges[n].radius.val = parents[i+m].value;
                               }
                               else
                               {
                                  edges[n].other_radius.type =
                                                     EMSdatainfo_numeric;
                                  edges[n].other_radius.val =
                                                     parents[i+m].value;
                               }
                            }
*/
                        /* Assign all the edge ids */
                           for( m=j, n = i+2; m <= edge_end_index; m++, n++ )
                           {
                              OM_BLOCK_MOVE( &parents[n].grobj.grid,
                                             &edges[m].boundary_id,
                                             sizeof( struct GRid ) );
                              edges[m].props = EMSfillet_is_variable_radius;
                           }
                       
                        /* Now, generate the intermediate radii */
                            OM_stat = EMgenerate_missing_radii( &msg,
                                       ( IGRushort ) 0, md_env, edges,
                                       j, edge_end_index );
                            EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                         EMS_E_Fail, wrapup );

                        j = ++edge_end_index;
                        i = k; /* Skip the two radius parents and the edge
                                * parents in this group.
                                */
                     }
                  }
                  else
                  {
                     /* Constant radius rounding. The possibilities are:
                      *  . single edge.
                      *  . a group of edges.
                      *  . a loop.
                      */
                     OM_stat = om$get_classid(
                                 objid = parents[i+1].grobj.grid.objid,
                                 osnum = parents[i+1].grobj.grid.osnum,
                                 p_classid = &parent_class );
                     EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror,
                                  wrapup );
                     if( parent_class == OPP_EMSloop_class_id )
                     {
                        OM_stat = om$get_channel_count(
                                  osnum = parents[i+1].grobj.grid.osnum,
                                  objid = parents[i+1].grobj.grid.objid,
                                  p_chanselect = &to_comps,
                                  count = &count );
                        EMerr_hndlr( !( 1 & OM_stat ), *EMmsg,
                                     EMS_E_LoopError, wrapup );
                        loop_edges = ( struct GRid * ) alloca
                                       ( count * sizeof( struct GRid ) );
                        OM_stat = EMget_loop_dominant_non_neutral_edges(
                                       &msg, ( IGRushort ) 0,
                                       md_env,
                                       &parents[i+1].grobj.grid,
                                       ( IGRint ) count, loop_edges,
                                       &edge_count );
                        EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg,
                                     wrapup );
                        /* 'edge_count' = count - number of neutral loop
                         * edges.
                         */
                        for( k = 0; k < edge_count; k++ )
                        {
                           OM_BLOCK_MOVE( &loop_edges[k],
                                          &edges[ j ].boundary_id,
                                          sizeof( struct GRid ) );
                           edges[j].radius.val = parents[i].value;
                           edges[j].radius.type = EMSdatainfo_numeric;
                           ++j;
                        }
                        i += 2; /* Skip the radius and the loop parent */
                     }
                     else
                     {
                        /* All parents from i+1 till either end of the parent
                         * list or till the next radius, belong to one group.
                         * Do that group of edges.
                         */
                        for( k = i+1; k < local_num_parents &&
                                 parent_types[k] != EMSdistance; k++ )
                        {
                           OM_BLOCK_MOVE( &parents[k],
                                          &edges[ j ].boundary_id,
                                          sizeof( struct GRid ) );
                           edges[j].radius.val = parents[i].value;
                           edges[j].radius.type = EMSdatainfo_numeric;
                           ++j;
                        }
                        i = k; /* Skip the radius parent, and all the edge
                                * parents in this group.
                                */
                     }
                  }
                }
                else
                {
                  *EMmsg = EMS_E_Fail;
                  goto wrapup;
                }
         }
     
  /* STEP 2 : Perform the computation. */
     recompute =  options & EMSasconst_recompute;
     if( recompute )
     {
       /* Old design files (pre 2.2) may pass in non-diminant round edges.
        * Need to do the edge filtering (i.e. get its dominant edge), since
        * otherwise anything off of a round produced edge (e.g. fillet u0)
        * may not recompute, since that edge may now be on a different surface
        * (note that during recomputation, it is impossible for an edge
        * to be neutral).  Also note that variable radius rounding did not
        * exists prior to 2.4.
        * 
        * Make the following check irrespective of version.
        * Design per se we should always be processing the dominant edges,
        * but it in the best interest of rounding to validate the edges
        * formed in the recompute  -- KNAP (4/13/94).
        */
        
        /* start of fix */
        for( i = 0; i < num_edges; i++ )
        {
          OM_stat = EMvalidate_round_edge( &msg, ( IGRushort ) 0,
                      md_env, &edges[i].boundary_id, &is_neutral,
                      &edge_out );
          EMerr_hndlr( !( 1 & OM_stat & msg ) || is_neutral == TRUE, *EMmsg,
                       EMS_E_EdgeError, wrapup );
          edges[i].boundary_id.objid = edge_out.objid;
        }
       /* end of fix */

       BSEXTRACTPAR( &msg, BSTOLCHRDHT, save_cht );
       BSchangepar( &msg, BSTOLCHRDHT,
              ( ( struct EMSround_chamfer * ) other_recomp_info )->cht );

       display_count = 0;
       OM_stat = EFsend_to_param( &msg,
              message EMSdprparam.EMget_display_ids
                    ( &msg, &display_count, &display_ids, NULL ), 
              my_id, OM_Gw_current_OS, &paramobj, NULL); 
       EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

       update_display_ids = TRUE;
     } 
     active_id_parent_type = EMSgrid;
     OM_stat = om$send( msg = message EMSassoc.EMget_parent_info
                            ( &msg,
                              ( IGRushort ) 0,
                              ( IGRuint ) 1,
                              ( IGRchar* ) &parent_GRids[num_parents - 1],
                              &active_id_parent_type,
                              &active_id_parent ),
                        targetid = my_id );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );
 
      OM_stat = om$send( msg = message EMSsfrndbool.EMround
                                 ( &msg, local_options,
                                   construct_list,
                                   &active_id_parent.grobj.grid,
                                   num_edges, edges, NULL,
                                   recompute ? &display_count : NULL, 
                                   recompute ? &display_ids : NULL,
                                   rnd_error ),
                         targetid = my_id );
      if( !( 1 & OM_stat & msg ) )
      {
       *EMmsg = EMS_E_Fail;
       EMrnd_error_info = rnd_error;
/* to fix mlk ,since right now this structure not being filled nor used 
       rnd_error = NULL;*/
       goto wrapup;
      }

      if( recompute )
      {
         BSchangepar( &msg, BSTOLCHRDHT, save_cht );
         OM_stat = om$send( msg = message EMSdprparam.EMput_display_ids
                                 ( &msg,
                                   display_count, display_ids, NULL ),
                            targetid = paramobj );
         display_ids = NULL;
         update_display_ids = FALSE;
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );
      }

wrapup:

  if (update_display_ids)
  {
    OM_stat = om$send( msg = message EMSdprparam.EMput_display_ids
                                      ( &msg,
                                        display_count, display_ids, NULL ),
                       targetid = paramobj );
  }

  if( rnd_error )  om$dealloc( ptr = rnd_error );

  EMWRAPUP( *EMmsg, OM_stat, "EMsfrndbool.EMconst_assoc" );
  return( OM_stat );
}




end implementation EMSsfrndbool;
