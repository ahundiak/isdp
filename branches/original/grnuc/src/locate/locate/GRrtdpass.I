class implementation GRrtree;

#include "OMDB.h"
#include "OMindex.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "DPdlist.h"

struct GRdisyourself_args
{
   IGRlong *msg;
   IGRshort *mx_type;
   IGRdouble *matrix;
   enum GRdpmode *mode;
   struct IGRaltdisplay *alt_symb;
   struct DP_information *sp_info;
   OM_p_KEY_DESC key;
};

struct dead_key_str
{
   OM_S_KEY_DESC corpse;
   OM_S_OBJID objid;
   struct dead_key_str *p_next;
};

struct context_str
{
   OM_p_MESSAGE msg;
   int tree_type;
   OM_p_KEY_DESC p_target_key;
   OM_S_OBJID senderid;
   struct dead_key_str *p_dead_keys;
   int ret;
};


extern IGRboolean DPdlist_use_display_list;

static int DPdlist_rtree_action( p_lfkey, p_context )
   char *p_lfkey;
   struct context_str *p_context;

{
   int status;
   OM_p_OBJID p_objid;
   struct GRdisyourself_args *disyours_args;

   disyours_args = ( struct GRdisyourself_args * ) p_context->msg->p_arglist;

   p_objid = ( OM_p_OBJID ) ( &( ( R_PACKED_KEYENTRY_3D_FLT * ) ( p_lfkey ) )->Objid );

   if ( p_context->p_target_key != NULL )
   {
      p_context->p_target_key->type = KEY_3D_DBL;
      p_context->p_target_key->key.p_3ddbl->xmin =
         ( double ) ( ( ( DB_3D_FLT_BOX * ) p_lfkey )->xmin );
      p_context->p_target_key->key.p_3ddbl->ymin =
         ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->ymin;
      p_context->p_target_key->key.p_3ddbl->zmin =
         ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->zmin;
      p_context->p_target_key->key.p_3ddbl->xmax =
         ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->xmax;
      p_context->p_target_key->key.p_3ddbl->ymax =
         ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->ymax;
      p_context->p_target_key->key.p_3ddbl->zmax =
         ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->zmax;

   }

   /* call dislplay list function */
   *( disyours_args->msg ) = MSSUCC;
   status = DPdlist_display_element_update( *p_objid, OM_Gw_current_OS,
                                            disyours_args->sp_info,
                                            disyours_args->matrix, *(disyours_args->mx_type),
                                            *(disyours_args)->mode, disyours_args->alt_symb,
                                            (disyours_args)->key, DP_DLIST_DISPLAY_FROM_RTREE );

   p_context->ret = (status & 1) ? OM_S_SUCCESS : OM_E_ERROR;

   if ( status == OM_E_NOSUCHCLASS )
   {
      return ( DB_CONTINUE );
   }

   if ( ( status == OM_I_STOP_SENDING ) ||
        ( ( !( 1 & status ) ) && ( status & SEV_LEV ) ) && ( status != OM_E_NOSUCHCLASS ) )
   {
      if ( status == OM_E_NOSUCHOBJ )
      {
         struct dead_key_str *p_temp;

         p_temp = p_context->p_dead_keys;
         p_context->p_dead_keys = ( struct dead_key_str * ) om$malloc( size = sizeof( struct dead_key_str ) );

         p_context->p_dead_keys->corpse.type = KEY_3D_DBL;
         if ( ( p_context->p_dead_keys->corpse.key.p_3ddbl =
                ( DB_3D_DBL_BOX * ) om$malloc( size = sizeof( DB_3D_DBL_BOX ) ) ) == NULL )
            return ( DB_TERMINATE );

         p_context->p_dead_keys->corpse.key.p_3ddbl->xmin =
            ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->xmin;
         p_context->p_dead_keys->corpse.key.p_3ddbl->ymin =
            ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->ymin;
         p_context->p_dead_keys->corpse.key.p_3ddbl->zmin =
            ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->zmin;
         p_context->p_dead_keys->corpse.key.p_3ddbl->xmax =
            ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->xmax;
         p_context->p_dead_keys->corpse.key.p_3ddbl->ymax =
            ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->ymax;
         p_context->p_dead_keys->corpse.key.p_3ddbl->zmax =
            ( double ) ( ( DB_3D_FLT_BOX * ) p_lfkey )->zmax;


         p_context->p_dead_keys->objid = *p_objid;
         p_context->p_dead_keys->p_next = p_temp;
         p_context->ret = OM_S_SUCCESS;
         return ( DB_CONTINUE );
      }
      else
         return ( DB_TERMINATE );
   }
   else
   {
      return ( DB_CONTINUE );
   }

}/* DPdlist_rtree_action */

method display_pass( 
   OM_p_MESSAGE msg;
   OM_p_KEY_DESC p_select_key;
   OM_p_CLASSLIST classlist;
   OM_p_KEY_DESC p_target_key;
   int ( *user_compare ) (  );
   int *ret )      /* +medesc */

/*
NAME
   GRrtree.display_pass

DESCRIPTION
   This message is used to display objects within a volume in the
   Rtree using the display list.
        
HISTORY
   06/15/93 S.P. Rogers
      Creation Date
*/


{
   int status;
   struct context_str user_context;
   struct dead_key_str *p_next_corpse;
   OMbyte *classStatMap;
   struct GRdisyourself_args *disyours_args;

   disyours_args = ( struct GRdisyourself_args * ) msg->p_arglist;


   if ( (! DPdlist_use_display_list) ||
        (disyours_args->sp_info->is_fit) ||
        (disyours_args->sp_info->gragad->flags & DPVIEW_DYNAMICS) )
   {
      /* display lists are not enabled, or we are doing a fit */
      /* or a filling the feedback buffer                     */
      status = om$send( msg = message OMrtree.pass( msg,
                                                    p_select_key,
                                                    classlist,
                                                    p_target_key,
                                                    user_compare,
                                                    ret ),
                        targetid = my_id );

      return( status );
   }

   if     ( !( ME.OMrtree->tree_page[0] == R_LF_RT_PAGE || ME.OMrtree->tree_page[0] == R_NL_RT_PAGE ) )
   {
      return ( OM_E_NOTTREEROOT );
   }

       user_context.msg = msg;

   user_context.tree_type = ( int ) ( ME.OMrtree->tree_page[1] );       /* Only till opp works */
   user_context.p_target_key = p_target_key;
   user_context.senderid = sender_id;
   user_context.p_dead_keys = NULL;
   user_context.ret = OM_S_SUCCESS;

   if ( ( classlist ) && ( classlist->w_count ) )
   {
      if ( !( 1 & ( status = som_build_internal_classlist( classlist, &classStatMap ) ) ) )
         return ( status );
   }
   else
      classStatMap = NULL;

   *ret = DB_rtree_search( ME.OMrtree->tree_page, p_select_key->key.p_3ddbl, 0, 0,
                        DPdlist_rtree_action, &user_context, classStatMap );

   while ( user_context.p_dead_keys != NULL )
   {
      if ( OM_Gf_verbose_warning )
      {
         printf( "WARNING - removing invalid object %d from the rtree\n",
                 user_context.p_dead_keys->objid );
      }

      status = om$send( msg = message OMrtree.remove( 
                                          &user_context.p_dead_keys->corpse,
                                           &user_context.p_dead_keys->objid,
                                               0, ret ), targetid = my_id );

      if ( !( status & 1 ) )
      {
         printf( "\nSomething went wrong in sending remove message to rtree during pass.\n" );
         printf( "OSnum: %d   Oid-of-Rtree: %d\n", OM_Gw_current_OS, my_id );
      }

      p_next_corpse = user_context.p_dead_keys->p_next;
      om$dealloc( ptr = user_context.p_dead_keys->corpse.key.p_3ddbl );
      om$dealloc( ptr = user_context.p_dead_keys );
      user_context.p_dead_keys = p_next_corpse;
   }

   om$dealloc( ptr = ( char * ) classStatMap );

   return ( user_context.ret );

}/* pass */


method skew_display_pass( 
   OM_p_MESSAGE msg;
   OM_p_SKEW_DESC p_key;
   OM_p_KEY_DESC p_target_key;
   OM_p_CLASSLIST classlist;
   int ( *user_compare ) (  );
   int *ret )

/*
NAME
   GRrtree.skew_display_pass

DESCRIPTION
   This message is used to display objects within a volume in the
   Rtree using the display list.
        
HISTORY
   06/15/93 S.P. Rogers
      Creation Date
*/

{
   int status;
   struct context_str user_context;
   OMbyte *classStatMap;
   struct GRdisyourself_args *disyours_args;

   disyours_args = ( struct GRdisyourself_args * ) msg->p_arglist;


   if ( (! DPdlist_use_display_list) ||
        (disyours_args->sp_info->is_fit) ||
        (disyours_args->sp_info->gragad->flags & DPVIEW_DYNAMICS) )
   {
      /* display lists are not enabled */
      status = om$send( msg = message OMrtree.skew_pass( msg,
                                                         p_key,
                                                         p_target_key,
                                                         classlist,
                                                         user_compare,
                                                         ret ),
                        targetid = my_id );

      return( status );
   }

   if     ( !( ME.OMrtree->tree_page[0] == R_LF_RT_PAGE || ME.OMrtree->tree_page[0] == R_NL_RT_PAGE ) )
   {
      return ( OM_E_NOTTREEROOT );
   }

       user_context.msg = msg;

   user_context.tree_type = ( int ) ( ME.OMrtree->tree_page[1] );       /* Only till opp works */
   user_context.p_target_key = p_target_key;
   user_context.senderid = sender_id;
   user_context.ret = OM_S_SUCCESS;

   if ( ( classlist ) && ( classlist->w_count ) )
   {
      if ( !( 1 & ( status = ( int ) som_build_internal_classlist( classlist, &classStatMap ) ) ) )
         return ( status );
   }
   else
      classStatMap = NULL;

   *ret = DB_rtree_search( ME.OMrtree->tree_page,
                           &( p_key->key.p_skew_3ddbl->range1 ),
                           &( p_key->key.p_skew_3ddbl->range2 ),
                           &( p_key->key.p_skew_3ddbl->sx ),
                        DPdlist_rtree_action, &user_context, classStatMap );

   om$dealloc( ptr = ( char * ) classStatMap );
   return ( user_context.ret );

}/* skew_pass */


end implementation GRrtree;
