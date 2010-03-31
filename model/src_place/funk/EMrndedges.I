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


from EMSboundary import EMgetsurface_info;

%safe
static IGRlong	expand_loop();
static IGRlong  convert_edge_radii_to_numeric();
%endsafe

#define START	0
#define STOP	1
#define FIRST   0
#define SECOND  1




/*
 * DESCRIPTION:
      This function is to be the programatic interface to associative and
      non-associative rounding, in the construction mode (recompute is
      performed through another function, which invokes construct_associative
      directly).

 * INPUT:
     options	Valid options are (defined in EMSrnddef.h):
		   EMS_RND_DONOT_MODIFY_SOLID
                      This indicates that rounding is to generate all fillets
                      and vertex patches/blends, with all boundaries imposed,
                      but do not generate any boundaries on the solid.
                      Typically, the use of this options is followed by a
                      manual rounding.
                   EMS_RND_CHAMFER
                      If set, chamfers are generated, and the radius fields
                      in the input array are interpreted as set back
                      distances.
                   EMS_RND_NON_ASSOCIATIVE
                      Non associative mode rounding.
     md_env	Module information.
     num_edges	Number of entries in the 'boundary_elements' array.
     boundary_elements
                Boundary elements of a surface on which the fillets are to be
                applied, as an array of EMSrnd_boundary_input instances.  The
                valid boundary elements are edges (MUST be dominant) and
                loops (internally, loops are expanded into their dominant
                edges).
                Neutral edges may be included.  However, these are not rounded
                (for example, if a loop has n edges, and of these m are
                neutral, then the n-m non-neutral edges of that loop will be
                rounded ). The acceptence of neutral edges are justified under
                the following.
                  . The removal of such edges are concentrated within the
                    round algorithm, reducing the complexity of the calling
                    function (recall that this function can be envoked not
                    only by the command object, but also by any other
                    function).
                  . An alternate rounding algorithm may provide a round
                    solution that is not based on edges.

                The elements in the boundary elements array must be grouped
                into one of the cases mentioned below (parents and editable
                dimension refer to associative information.  Any references
                within ' ' are to fields within EMSrnd_boundary_input
                structure).  The element grouping within this array is
                accomplished through the EMSrnd_input_ed_grp_start property.
                i.e. this property must be set for the first element of a
                group of contiguous boundary elements.

      Boundary element cases supported (these may be repeated any number of
      times, during a call to EMround_chamfer_edges()).

      1. A constant radius fillet on a single edge.
         Parents: the radius, and the edge.
         Editable dimension: the radius.

         The single radius must be in 'radius'.
                
      2. A collection of constant radius fillet edges, with the same
         radius (ex: radius expression 'default_radius') applied to a
         collection of edges.  The radius must be in 'radius' of each edge.
         Parents: a single radius, and each edge.
         Editable dimension: the radius.
         
      3. A variable radius fillet on a single edge.
         Parents: the two radii, and the edge.
         Editable dimension: the two radii.
         The two radii must be in 'radius', and 'other_radius'.
         Set property EMSfillet_is_variable_radius.

      4. Variable radius filleting accross a collection of edges
         e1, e2, ...., en.  The radii are specified at the start of the
         chain, and at the end of the chain.
         Parents: two radii, one at the start of the chain, and the
                  other at the end of the chain, and the edges e1, e2, ...,
                  en.
         Editable_dimension: the two radii.

         Set property EMSfillet_is_variable_radius for ALL edges.

      5. A constant radius applied to edges in a loop.
         Parents: the radius, and the loop.
         Editable dimension: the radius.
         The single radius must be in 'radius'.

     round_error	If the round operation failed, then this containes
                        a packet of information on the failure.  If
                        *round_error = NULL then memory will be allocated
                        by this function.  Else caller should have
                        allocated memory.
     rnd_dpr		The dpr state created for the rounding operation.
                        Can be NULL.
                        Under option EMS_RND_DONOT_MODIFY_MODEL,
                        rnd_dpr will be unchanged from its input value.

  * OUTPUT:
      *EMmsg	   EMS errors.
      return value OM errors.

  * ALGORITHM:
     . Obtain the root of the dpr.  Obtain its type (solid/surface), and
       create the new dpr state for the round operation.  Set the global,
       current creator.  Generate the construction environment.
     . If associative:
         . Determine the number of parents, and form the parent list (any
           neutral edges are filtered out, including those that may occur
           within a loop).
         . Establish the recompute info, and the type of rounding
           (latter being either a chamfer or round).
         . Send message init associative to the new dpr state.
       Else
         . Expand out any loops in the boundary_elements array.  Only
           non-neutral edges of the loop are accepted for rounding. Also,
           filter out anu neutral edges in the boundary elements array.
         . For each boundary element case 4, generate the intermediate radii
           by interpolating along the chained edge length.
         . Convert all radii to numeric values.
         . Send message EMround to the new dpr state.
         . If EMS_RND_DONOT_MODIFY_SOLID option is set, then delete the
           new round dpr state (preferably, in this case, the creation of
           round dpr state should have been avoided, but that requires
           the migration of EMround message, to a function. Time permitting,
           will do this later).
     . Set the current creator to NULL_OBJID.

     For detailes, refer comments at each STEP within the function. 

  * HISTORY
     ?? : ?? : Original.
     Janaka : 08/06/92 : Added local_options, so that rounding works
                         in non-associative mode.
     Janaka : 12/19/92 : Re-wrote for Phoenix.
*/


#argsused

IGRlong EMround_chamfer_edges( EMmsg, options, md_env, num_edges,
                               boundary_elements, round_error,
                               rnd_dpr )

IGRlong               		*EMmsg;
IGRushort     			options;
struct GRmd_env	      		*md_env;
IGRint                		num_edges;
struct EMSrnd_boundary_input	*boundary_elements;   
struct EMSrnd_error		**round_error;
struct GRid			*rnd_dpr;
{
 IGRushort	        local_options;
 IGRlong                OM_stat, msg, i, j, k, m, n;
 IGRint                 obj_type, rnd_type, num_parents, num_bdry_elems;
 GRobjid                surf_id, dpr_state_for_rnd;
 IGRboolean             status, is_neutral;
 GRspacenum             osnum;
 GRclassid		boundary_class;

 struct GRid             active_state_GRid, new_edge, *chain_eds;
 struct EMSobject_info   *parent_list;
 struct EMSround_chamfer r_c_info;
 struct GRvg_construct   construct_list;
 struct GRsymbology      symb;
 struct GRmd_env         loc_md_env;
 struct IGRdisplay       loc_display_attr;
 struct EMSrnd_error	 *local_round_error;
 struct EMSvalue_info	 *radius_1, *radius_2;
 struct	EMSrnd_boundary_input	*local_boundary_elements;

 extern OMuword             OPP_EMSsfrndbool_class_id,
                            OPP_EMSslrndbool_class_id,
                            OPP_EMSloop_class_id;

 extern struct EMSrnd_error *EMrnd_error_info;

 extern OM_S_OBJID          current_creator;

 extern	IGRlong		EMgetparval_numeric(), EMgenerate_missing_radii();
 extern void		EMinitvgcnstr();
 extern IGRlong		EMvalidate_round_edge();




 /*
  * STEP 0: Initialize, and check for obvious input errors.
  */
     *EMmsg = EMS_S_Success;
     OM_stat = OM_S_SUCCESS;
     osnum = md_env->md_id.osnum;
     parent_list = NULL;
     local_round_error = NULL;

     EMerr_hndlr( !num_edges, *EMmsg, EMS_E_InvalidArg, wrapup );

 /*
  * STEP 1:
  *
  * . Determine the objid of the root of the dpr tree (refered to as the
  *   'active_id').  This becomes a component of the round operation (round
  *   being a binary operation, the other component of it is the composite
  *   surface to which all the fillet surfaces and the patches belong).
  *   If the operation is associative, then the owner component channel
  *   between the round dpr state, and the active id is also interpreted as
  *   a father/child channel.  Under this interpretation, the active id is
  *   a father of the round dpr state.
  * . Create a new dpr state for the round operation.
  * . Set the current creator.
  * . Create the construction environment.
  */
     OM_stat = om$send( msg = message EMSboundary.EMgetsurface_info( &msg,
                           &surf_id, NULL),
                        senderid = NULL_OBJID,
                        targetid = boundary_elements[0].boundary_id.objid,
                        targetos = osnum );
     EMerr_hndlr( !(1 & OM_stat & msg), *EMmsg, EMS_E_EdgeError, wrapup );
  
     OM_stat = om$send( msg = message EMSsurface.EMgetactiveid( &msg,
                                             &active_state_GRid, NULL ),
                        senderid = NULL_OBJID,
                        targetid = surf_id,
                        targetos = osnum);
     EMerr_hndlr( !(1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError, wrapup );

     /*
      * Create either a surface, or solid class instance as the round dpr
      * state for this operation.
      */
         EFclassify_obj_type( &msg, &obj_type, &active_state_GRid );
         if( !( 1 & msg ) ) goto wrapup;

         OM_stat = om$construct( classid = ( obj_type 
                                               ? OPP_EMSslrndbool_class_id
                                               : OPP_EMSsfrndbool_class_id),
                                 osnum = osnum,
                                 p_objid = &dpr_state_for_rnd );
         if ( !( 1 & OM_stat ) ) goto wrapup;
         if( rnd_dpr && !( options & EMS_RND_DONOT_MODIFY_MODEL ) )
         {
            rnd_dpr->objid = dpr_state_for_rnd;
            rnd_dpr->osnum = osnum;
         }

     /*
      * REMEMBER to reset this to NULL_OBJID on completion of round operation.
      * Also under EMS_RND_DONOT_MODIFY_MODEL option, 'dpr_state_for_round'
      * does not exist on completion of the operation.  Consequently, the
      * creator of the entities created during the operation under this
      * option, would be NULL_OBJID.
      */
         if( options & EMS_RND_DONOT_MODIFY_MODEL )
            current_creator = NULL_OBJID;
         else
            current_creator = dpr_state_for_rnd;           
     /*
      * Create the construction environment.
      */
         OM_stat = om$send( msg = message GRvg.GRgetsymb
                                               ( &msg, &symb ),
                            targetid = active_state_GRid.objid,
                            targetos = active_state_GRid.osnum,
                            senderid = NULL_OBJID);
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail,
                      wrapup );

         EMinitvgcnstr( &msg, &loc_md_env, &loc_display_attr, NULL,
                        &construct_list);
         EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
         EMgetvgcnstr( NULL, NULL, md_env, symb.level,
                       &symb.display_attr, NULL,
                       NULL, &construct_list );
 /*
  * STEP 2: Do the round operation.
  */
     if( !( options & EMS_RND_NON_ASSOCIATIVE ) &&
         !( options & EMS_RND_DONOT_MODIFY_MODEL ) )
     {
        /* Filter out neutral edges */
           local_boundary_elements = ( struct EMSrnd_boundary_input * )
               alloca ( num_edges * sizeof( struct EMSrnd_boundary_input ) );
           for( i = 0, j = 0; i < num_edges; i++ )
           {
              OM_stat = om$get_classid(
                              objid = boundary_elements[i].boundary_id.objid,
                              osnum = boundary_elements[i].boundary_id.osnum,
                              p_classid = &boundary_class );
              EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_OMerror,
                           wrapup );
              if( boundary_class != OPP_EMSloop_class_id )
              {
                 OM_stat = EMvalidate_round_edge( &msg, ( IGRushort ) 0,
                             md_env, &boundary_elements[i].boundary_id,
                             &is_neutral, &new_edge );
                 EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
                 if( is_neutral == TRUE )
                    continue;

                 /* Get the dominant edge. */
                    boundary_elements[i].boundary_id.objid = new_edge.objid;
              }
              OM_BLOCK_MOVE( &boundary_elements[i],
                             &local_boundary_elements[j],
                             sizeof( struct EMSrnd_boundary_input ) );
              j++;
           }
           num_bdry_elems = j; /* num_edges - number of neutral edges */

        /* Create a buffer for chains, to be used if needed. */
           chain_eds = ( struct GRid * ) alloca
                           ( num_bdry_elems * sizeof( struct GRid ) );

        /* associative round */
        
        /*
         * . Construct the parent list based on the information within the
         *   boundary elements array.  The following parent order correspond
         *   to the cases supported (see INPUT section comments).
         *   
         *    1. radius, edge.
         *    2. radius, edge_1, edge_2, ....., edge_n.
         *    3. radius_1, radius_2, edge.
         *    4. radius_1, radius_2, edge1, edge_2, ......, edge_n.
         *    5. radius_1, loop.
         *
         *    A given parent list may consist of any combination of 1 ~ 5.
         *    The active id will be the last parent on the list.
         *    Note w.r.t. the old algorithm:
         *    uniform rounding is case 2.
         *    non-uniform rounding is a repeated application of case 1.
         *    single edge rounding is a single occurance of case 1.
         */

        /*      
         * Determine the number of parents.
         */
            for( i = 0, num_parents = 1 /* count the active id */;
                 i < num_bdry_elems; )
            {
               /*
                * Count the number of edges in this sub group.
                */
                   for( j = i + 1; j < num_bdry_elems; )
                      if( local_boundary_elements[j].props
                                    & EMSrnd_input_ed_grp_start )
                       break;
                      else
                       ++j;

               num_parents += j - i /* number of edges in this group */;

               /*
                * Now, to the above, add the number of radius parents.
                */
                   num_parents +=
                      local_boundary_elements[i].props &
                                         EMSfillet_is_variable_radius
                           ? 2 : 1;
               i = j; /* Go to the next sub-group */
            }

         /* Form the parents */
            parent_list = ( struct EMSobject_info * ) alloca
                       ( num_parents * sizeof( struct EMSobject_info ) );

            /* j .. index for the parent list.
             * i .. index for the local boundary elements list.
             */
            for( i=0, j=0; j<num_parents-1 /* don't do the active id here */;)
            {
               for( k = i + 1; k < num_bdry_elems; )
                  if( local_boundary_elements[k].props &
                                EMSrnd_input_ed_grp_start )
                   break;
                  else
                   ++k;

                /* Make the radius parents.  This will depend on whether a
                 * chain or a single edge is being done.
                 */
                   if( local_boundary_elements[i].props &
                                            EMSfillet_is_variable_radius )
                   {
                    radius_1 = &local_boundary_elements[ i ].radius;
                    radius_2 = &local_boundary_elements[ i ].other_radius;
                    if( k-1 != i )
                    {
                     /* Dealing with a chain of edges. Need to determine
                      * the correct radius for the first and the last edges
                      * of the chain.
                      */

                     for( m = 0, n = i; n < k; n++, m++ )
                      OM_BLOCK_MOVE( &local_boundary_elements[n].boundary_id,
                                     &chain_eds[m],
                                     sizeof( struct GRid ) );
                      radius_1 = &local_boundary_elements[ i ].radius;
                      radius_2 = &local_boundary_elements[k-1].other_radius; 
                    }

                    OM_stat = EMgetparval_object( &msg, osnum,
                                    NULL, radius_1, &parent_list[j] );
                    EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                  EMS_E_Fail, wrapup );
                    ++j;

                    OM_stat = EMgetparval_object( &msg, osnum,
                                    NULL, radius_2, &parent_list[j] );
                    EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                  EMS_E_Fail, wrapup );
                    ++j;
                   }
                   else
                   {
                      /* Constant radius */
                      OM_stat = EMgetparval_object( &msg, osnum,
                            NULL, &local_boundary_elements[i].radius,
                            &parent_list[j] );
                      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                   EMS_E_Fail, wrapup );
                      ++j;
                   }

               /* Do the edge parents */
                  for( ; i < k; i++ )
                  {
                     OM_BLOCK_MOVE( &local_boundary_elements[i].boundary_id,
                                    &parent_list[j].grid,
                                    sizeof( struct GRid ) );
                     OM_BLOCK_MOVE( md_env, &parent_list[j].env,
                                    sizeof( struct GRmd_env ) );
                     ++j;
                  }
            }
   
            /* Do the active id */
               OM_BLOCK_MOVE( &active_state_GRid, &parent_list[j].grid,
                              sizeof( struct GRid ) );
               OM_BLOCK_MOVE( md_env, &parent_list[j].env,
                              sizeof( struct GRmd_env ) );

            /* Recompute information */
               r_c_info.num_views = 0;
               status = BSEXTRACTPAR( &msg, BSTOLCHRDHT, r_c_info.cht);
               if (! status) { *EMmsg = EMS_E_BSerror; goto wrapup; }

            /* Type of the operation */
               if( options & EMS_RND_CHAMFER )
                  rnd_type = EMS_ASchamfer;
               else
                  rnd_type = EMS_ASround;

            /* Initializes and constructs the associative round object */
               local_options = 0;
               OM_stat = om$send( msg = message EMSassoc.EMinit_associative
                                     ( &msg,
                                       local_options, 
                                       num_parents,
                                       parent_list,
                                       rnd_type,
                                       sizeof(struct EMSround_chamfer),
                                       (IGRchar *) &r_c_info,
                                       &construct_list ),
                                 senderid = NULL_OBJID,
                                 targetid = dpr_state_for_rnd,
                                 targetos = osnum);
               if( !( 1 & OM_stat & msg ) )
               {
                  *EMmsg = EMS_E_Fail;
                  if( *round_error )
                  {
                     OM_BLOCK_MOVE( EMrnd_error_info,
                                    ( *round_error ),
                                    sizeof( struct EMSrnd_error ) );
                     EMrnd_error_info->fail_edges = NULL;
                     EMrnd_error_info->kind_of_failure = NULL;
                     EMrnd_error_info->start_vtx = NULL;
                     EMrnd_error_info->stop_vtx = NULL;
                     local_round_error = EMrnd_error_info;
                     EMrnd_error_info = NULL;
                  }
                  else
                  {
                     *round_error = EMrnd_error_info;
                     EMrnd_error_info = NULL;
                  }
                  goto wrapup;
               }
     }
     else
     {
        /* The following cases fall into this category:
         *   . non-associative round OR
         *   . Generation of fillets and patches, with all boundaries imposed
         *     on these entities, but with no boundaries imposed on the
         *     original model (associativeness is irrelevant).
         */

        if( !( *round_error ) )
        {
           local_round_error = ( struct EMSrnd_error * ) om$malloc
                        ( size = sizeof( struct EMSrnd_error ) );
           EMerr_hndlr( !local_round_error, *EMmsg, EMS_E_NoDynamicMemory,
                        wrapup );

           local_round_error->fail_edges = NULL;
           local_round_error->kind_of_failure = NULL;
           local_round_error->start_vtx = NULL;
           local_round_error->stop_vtx = NULL;
        }

        /* Expand all loop boundary elements, and ensure that all boundary
         * elements are dominant, non-neutral edges.
         */
            /* First get the count of actual round edges */
            OM_stat = expand_loop( &msg, ( IGRushort ) 0, md_env,
                   num_edges, boundary_elements, &num_bdry_elems, NULL );
            
            EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
            if( num_bdry_elems == num_edges )
               local_boundary_elements = boundary_elements;
            else
            {
               local_boundary_elements = ( struct EMSrnd_boundary_input * )
                alloca
                  ( num_bdry_elems * sizeof( struct EMSrnd_boundary_input ) );

               OM_stat = expand_loop( &msg, ( IGRushort ) 0, md_env,
                        num_edges, boundary_elements,
                        &num_bdry_elems, local_boundary_elements );
            
               EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
            }

        /*
         * . Generate the missing radii for each and every edge case 4.
         * . Convert the radii of all edges to numeric values.
         * . Call the EMround method.
         */
            for( i = 0; i < num_bdry_elems; )
            {
               if( local_boundary_elements[i].props &
                                          EMSfillet_is_variable_radius )
               {
                  /*
                   * Need to discriminate between a single variable radius
                   * case, and a chain of edges case.
                   */
                  for( j = i + 1; j < num_bdry_elems; )
                     if( local_boundary_elements[j].props &
                                          EMSrnd_input_ed_grp_start )
                      break;
                     else
                      ++j;

                  if( ( j-1 ) != i )
                  {
                     OM_stat = EMgenerate_missing_radii( &msg,
                                   ( IGRushort ) 0, md_env,
                                   local_boundary_elements, i, j-1 );
                     EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                  EMS_E_Fail, wrapup );
                  }

                  i = j;
               }
               else
                     i++;
            }

            OM_stat = convert_edge_radii_to_numeric( &msg,
                                ( IGRushort ) 0, num_bdry_elems,
                                local_boundary_elements );
            EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail,
                         wrapup );

            local_options = ( options & EMS_RND_CHAMFER ) | 
                            ( options & EMS_RND_DONOT_MODIFY_MODEL );

            OM_stat = om$send( msg = message EMSsfrndbool.EMround
                                  ( &msg,
                                    local_options,
                                    &construct_list,
                                    &active_state_GRid,
                                    num_bdry_elems,
                                    local_boundary_elements,
                                    NULL,  /* status string */
                                    NULL,  /* display -count */
                                    NULL,  /* display ids */
                                    ( *round_error ) ? *round_error
                                                     : local_round_error ),
                           targetid = dpr_state_for_rnd,
                           targetos = osnum,
                           senderid = NULL_OBJID );
            if( !( 1 & OM_stat & msg ) )
            {
               *EMmsg = EMS_E_Fail;
               if( !( *round_error ) )
               {
                  *round_error = local_round_error;
                  local_round_error = NULL;
               }
               goto wrapup;
           }

           if( options & EMS_RND_DONOT_MODIFY_MODEL )
           {
              OM_stat = om$send( msg = message Root.delete( ( IGRint ) 0 ),
                                 targetid = dpr_state_for_rnd,
                                 targetos = osnum,
                                 senderid = NULL_OBJID );
              EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_Fail, wrapup );
           }
     }

wrapup:

 if( local_round_error )  om$dealloc( ptr = local_round_error );
 current_creator = NULL_OBJID;
 EMWRAPUP( *EMmsg, OM_stat, "EMround_chamfer_edges" )
 return( OM_stat );

}



/*
 * DESCRIPTION:
      Given a collection of boundary elements, where the boundary elements
      are edges or loops, expand out the loops by replacing each occurance
      of a loop by its non-neutral, dominant edges.  Further more, filter
      out all the neutral edges, and ensure that the remaining edges are
      dominant.

 * INPUT:
      options		 Unused.
      md_env		 Module environment.
      num_org_bdry_elems Number of elements in the 'org_bdry_elems' array.
      org_bdry_elems     Array of boundary elements consisting of edges
                         and loops.

 * OUTPUT:
      EMmsg		 EMS errors.
      return value	 OM errors.
      num_act_bdry_elems Number of edges in 'act_bdry_elems' array.
      act_bdry_elems	 Dominant, non-neutral edges obtained by processing
                         the input boundary elements.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 01/13/93 : Original.
*/

#argsused

static IGRlong expand_loop( EMmsg, options, md_env, num_org_bdry_elems,
                 org_bdry_elems, num_act_bdry_elems, act_bdry_elems )
IGRlong				*EMmsg;
IGRushort			options;
struct GRmd_env			*md_env;
IGRint				num_org_bdry_elems, *num_act_bdry_elems;
struct EMSrnd_boundary_input	*org_bdry_elems, *act_bdry_elems;
{
   IGRboolean	is_neutral;
   IGRint	i, j, k, num_loop_edges, loc_num_act_bdry_elems;
   IGRlong	msg, OM_stat;
   GRclassid	boundary_class;

   struct GRid	new_edge, *loop_edges;

   extern GRclassid	OPP_EMSloop_class_id;
   extern IGRlong	EMvalidate_round_edge();

   /* STEP 0: Initialize and error check. */
      *EMmsg = EMS_S_Success;
      OM_stat = OM_S_SUCCESS;
      EMerr_hndlr( !num_act_bdry_elems && !act_bdry_elems, *EMmsg,
                   EMS_E_InvalidArg, wrapup );

   /* STEP 1:
    *   Iterate through the input array of boundary elements.  Determine
    *   whether each element is a loop or an edge.  For loop elements,
    *   obtain all its dominant, non-neutral edges.  For edges, validate
    *   the edge by ensuring that it is a dominant, non-neutral edge.
    */
       for( i = 0, loc_num_act_bdry_elems = 0, j = 0;
            i < num_org_bdry_elems; i++ )
       {
           OM_stat = om$get_classid(
                           objid = org_bdry_elems[i].boundary_id.objid,
                           osnum = org_bdry_elems[i].boundary_id.osnum,
                           p_classid = &boundary_class );
           EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror,
                        wrapup );
           if( boundary_class == OPP_EMSloop_class_id )
           {
               OM_stat = EMget_loop_dominant_non_neutral_edges( &msg,
                                         ( IGRushort ) 0, md_env, 
                                         &org_bdry_elems[i].boundary_id,0,
                                         NULL, &num_loop_edges );
               EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
               if( num_loop_edges != 0 )
               {
                  loop_edges = ( struct GRid * ) alloca
                                 ( num_loop_edges * sizeof( struct GRid ) );
                  OM_stat = EMget_loop_dominant_non_neutral_edges( &msg,
                                     ( IGRushort ) 0, md_env, 
                                     &org_bdry_elems[i].boundary_id,
                                     num_loop_edges,
                                     loop_edges, &num_loop_edges );
                  EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
                  loc_num_act_bdry_elems += num_loop_edges;
                  if( act_bdry_elems )
                     for( k = 0; k < num_loop_edges; k++, j++ )
                     {
                        OM_BLOCK_MOVE( &loop_edges[k],
                                       &act_bdry_elems[j].boundary_id,
                                       sizeof( struct GRid ) );
                        OM_BLOCK_MOVE( &org_bdry_elems[i].radius,
                                       &act_bdry_elems[j].radius,
                                       sizeof( struct EMSvalue_info ) );
                        act_bdry_elems[j].rho_value.type =
                        act_bdry_elems[j].other_radius.type =
                                                       EMSdatainfo_undefined;
                        act_bdry_elems[j].props =
                        act_bdry_elems[j].options = 0;
                     }
               }
           }
           else
           {
               OM_stat = EMvalidate_round_edge( &msg, ( IGRushort ) 0,
                              md_env, &org_bdry_elems[i].boundary_id,
                              &is_neutral, &new_edge );
               EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
               if( is_neutral != TRUE )
               {
                  loc_num_act_bdry_elems++;
                  if( act_bdry_elems )
                  {
                    OM_BLOCK_MOVE( &org_bdry_elems[i],
                                    &act_bdry_elems[j],
                                    sizeof( struct EMSrnd_boundary_input ) );

                    OM_BLOCK_MOVE( &new_edge,
                                   &act_bdry_elems[j].boundary_id,
                                   sizeof( struct GRid ) );
                    ++j;
                  }
               }
            }
       }

    /* STEP 2: Assign output */
       if( num_act_bdry_elems )
          *num_act_bdry_elems = loc_num_act_bdry_elems;

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "expand_loop" );
   return( OM_stat );
}



#argsused
static IGRlong convert_edge_radii_to_numeric( EMmsg, options, num_edges, edges)
IGRlong				*EMmsg;
IGRushort			options;
IGRint				num_edges;
struct EMSrnd_boundary_input	*edges;
{
   IGRlong	msg, OM_stat;
   IGRint 	i;
   extern IGRlong EMgetparval_numeric();

   *EMmsg = EMS_S_Success;
   OM_stat= OM_S_SUCCESS;

   for( i = 0; i < num_edges; i++ )
   {
      if( edges[i].radius.type != EMSdatainfo_numeric )
      {
         OM_stat = EMgetparval_numeric( &msg, &edges[i].radius,
                       &edges[i].radius.val );
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );
      }
      if( ( edges[i].props & EMSfillet_is_variable_radius ) &&
          ( edges[i].other_radius.type != EMSdatainfo_numeric ) )
      {
         OM_stat = EMgetparval_numeric( &msg, &edges[i].other_radius,
                       &edges[i].other_radius.val );
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );
      }
   }

 wrapup:

    EMWRAPUP( *EMmsg, OM_stat, "convert_edge_radii_to_numeric" );
    return( OM_stat );
}



end implementation EMSsfrndbool;
