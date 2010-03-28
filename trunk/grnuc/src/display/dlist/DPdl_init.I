class implementation Root;

#include <stdlib.h>
#include <stdio.h>

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "msdef.h"
#include "gr.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "DPdlist.h"
#include "dpcodef.h"

#include "dpmacros.h"

%safe
extern struct DPdlist_hash_table *DPhash_tables /* = NULL */;

extern IGRdouble *DPdlist_fb_buffer /* = NULL */;

extern IGRboolean DPdlist_use_display_list /* = TRUE */;

extern IGRboolean DPdlist_feedback_in_progress /* = FALSE */;
extern IGRdouble DPdlist_stroke_tolerance /* = 0.01 */;

extern int DPdlist_wf_fb_pipe_id;

extern struct GRid DPdlist_wf_fb_gragad;
extern struct GRid DPdlist_sh_fb_gragad; 

extern IGRboolean DPdlist_display_tangent_edges /* = TRUE */;

extern IGRboolean DPdlist_performance_boost /* = FALSE */;
%endsafe

/* New Prototypes */
PROTO_DPdlist_initialize
PROTO_DPdlist_setup_feedback_gragad
PROTO_DPdlist_exit
PROTO_DPdlist_free_hash_table
PROTO_DPdlist_free_data_blocks
PROTO_DPdlist_get_status
PROTO_DPdlist_set_status
PROTO_DPdlist_set_tolerance_gragad
PROTO_DPdlist_set_object_space_scales;

from GRviewdyn import DPsetup_for_dlist_feedback;

/*--- DPdlist_initialize --------------------------------------------*/

int DPdlist_initialize(
   void )

/*
NAME
   DPdlist_initialize

DESCRIPTION
   This function intializes the internal structures of the display list.

SYNOPSIS
   int DPdlist_initialize(
      void )

PARAMETERS
   none

GLOBALS USED
   DPhash_tables
   DPdlist_wf_fb_gragad

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial Implementation
*/

{
   int ii;
   char *expansion;

   /* allocate hash table array */
   if ( ! DPhash_tables )
   {
      DPhash_tables = (struct DPdlist_hash_table *)
           malloc( OM_Gw_maxOS * sizeof( struct DPdlist_hash_table ) );
   }

   if ( ! DPhash_tables )
   {
      return( DLIST_E_ERROR );
   }

   /* allocate feedback buffer for stroking */
   if ( ! DPdlist_fb_buffer )
   {
      DPdlist_fb_buffer = (IGRdouble *) malloc( DP_DLIST_FB_BUFFER_SIZE );
   }

   if ( ! DPdlist_fb_buffer )
   {
      return( DLIST_E_ERROR );
   }

   for ( ii = 0; ii < OM_Gw_maxOS; ii++ )
   {
      DPhash_tables[ii].max_to_world_scale = 1.0;
      DPhash_tables[ii].size = DPhash_tables[ii].used = 0;
      DPhash_tables[ii].fixed_data = NULL;
   }

   DPdlist_wf_fb_gragad.objid = NULL_OBJID;
   DPdlist_sh_fb_gragad.objid = NULL_OBJID;

   expansion = getenv( "DONT_USE_DISPLAY_LIST" );
   if ( (expansion) && (expansion[0] == '1') )
   {
      DPdlist_use_display_list = FALSE;
   }

   return( DLIST_S_SUCCESS );
   
}  /* DPdlist_initialize */


%safe
static int	FirstCall = 0;
%endsafe

/*--- DPdlist_set_on_off_mode ------------------------------------------------*/

void	DPdlist_set_on_off_mode()

   {
   IGRushort	dvd_flags;
   char		*expr;

   /*
    *  WeveRetrieved() will return on first call after a new file has been 
    *  retrieved.  This allows us to retest the environment variable
    *  after closing then opening a file
    */

   if( !FirstCall || WeveRetrieved() )
      {
      FirstCall = 1;

      /*
       *  Get the on/off flag from the dpb and from the environment
       *  variable
       */

      DPcodpb_get_dvd_flags( &dvd_flags );
      expr = getenv( "DONT_USE_DISPLAY_LIST" );

      /*
       *  If the environment variable is set to one, everyone must
       *  think display list is off.  Otherwise, sync up the global
       *  flag with the dpb flag.
       */

      if ( (expr) && (expr[0] == '1') )
         {
         DPdlist_use_display_list = FALSE;
         dvd_flags &= ~DVD_DLIST_ON;
         }

      else
      if( dvd_flags & DVD_DLIST_ON )
         DPdlist_use_display_list = TRUE;
      else
         DPdlist_use_display_list = FALSE;

      /*
       *  put the dpb flag back, just in case it got changed
       */

      DPcodpb_set_dvd_flags( dvd_flags );
      }
   }

/*--- DPdlist_setup_feedback_gragad ------------------------------------------*/

int DPdlist_setup_feedback_gragad(
   void )

/*
NAME
   DPdlist_setup_feedback_gragad

DESCRIPTION
   This function sets up the feedback gragad.  It must be called
   after the font information in the module has been set up (i.e.,
   after the font manager has woken up).

SYNOPSIS
   int DPdlist_setup_feedback_gragad(
      void )

PARAMETERS
   none

GLOBALS USED
   DPdlist_wf_fb_gragad

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/01/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   IGRlong msg;
   IGRint total_found, total_ret;
   struct GRid gragad_ids[40];
   struct var_list var_list[2];
   IGRlong bytes_ret, which_error;
   IGRdouble vvol_scale, max_scale;
   int ii;
   int max_index;

   if ( ! DPhash_tables )
   {
      sts = DPdlist_initialize();
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }

   DPdlist_set_on_off_mode();

   if ( DPdlist_wf_fb_gragad.objid == NULL_OBJID )
   {
      /* construct a feedback gragad for wireframe in the transient object */
      /* space and send it a setup message (?? Does the transient object   */
      /* space get destroyed on a close/retrieve                           */
      DPdlist_wf_fb_gragad.osnum = OM_Gw_TransOSnum_0;
      sts = om$construct( classname = "GRviewdyn",
                          osnum = DPdlist_wf_fb_gragad.osnum,
                          msg = message GRviewdyn.DPsetup_for_dlist_feedback( &msg, TRUE ),
                          p_objid = &DPdlist_wf_fb_gragad.objid );

      if ( ! (1 & sts) )
      {
          return( sts );
      }

      /* initalize the stroking tolernace by finding */   
      /* the gragad with the largest view volueme to */
      /* viewport scale                              */
      dp$get_gragad_id( msg = &msg,
                        name = "*",
                        array_size = 40,
                        total_num = &total_found,
                        numberofids = &total_ret,
                        found_GRids = gragad_ids,
                        type_gragad = ALL_GG_CLASSES | GG_WIN_ON );

      max_scale = -1.0;
      max_index = 0;
      var_list[0].var = VVOL_VIEWPORT_SCALE;
      var_list[0].var_ptr = (char *) &vvol_scale;
      var_list[0].num_bytes = sizeof( IGRdouble );
      var_list[0].bytes_returned = &bytes_ret;
      var_list[1].var = END_PARAM;

      for ( ii = 0; ii < total_ret; ii++ )
      {
         dp$inq_set_gragad( msg = &msg,
                            osnum = gragad_ids[ii].osnum,
                            gragad_objid = gragad_ids[ii].objid,
                            which_error = &which_error,
                            var_list = var_list );

         if ( !(1 & msg) )
         {
            return( DLIST_E_ERROR );
         }

         if ( vvol_scale > max_scale )
         {
            max_scale = vvol_scale;
            max_index = ii;
         }
      }

      sts = DPdlist_set_tolerance_gragad( &gragad_ids[max_index] );
      if ( !(1 & sts ) )
      {
         return( DLIST_E_ERROR );
      }

      sts = DPdlist_set_object_space_scales();
      if ( !(1 & sts) )
      {
         return( sts );
      }

   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_setup_feedback_gragad */

/*--- DPdlist_exit ------------------------------------------------*/

int DPdlist_exit(
   void )

/*
NAME
   DPdlist_exit

DESCRIPTION
   This function disables display lists and frees all the memory
   used for the display list.

SYNOPSIS
   int DPdlist_exit(
      void )

PARAMETERS
   none

GLOBALS USED
   DPdlist_use_display_list

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/18/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   int ii;

   if ( ! DPhash_tables )
   {
      return( DLIST_S_SUCCESS );
   }

   if ( DPdlist_use_display_list )
   {
      /* free all the hash tables */
      for ( ii = 0; ii < OM_Gw_maxOS; ii++ )
      {
         sts = DPdlist_free_hash_table( ii );
         if ( !(1 & sts) )
         {
            return( DLIST_E_ERROR );
         }
      }

      /* free all the data blocks */
      sts = DPdlist_free_data_blocks();
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }

   DPdlist_use_display_list = FALSE;

   return( DLIST_S_SUCCESS );

} /* DPdlist_exit */

/*--- DPdlist_get_status ------------------------------*/

int DPdlist_get_status(
   IGRboolean *on_off )

/*
NAME
   DPdlist_get_status

DESCRIPTION
   This function gets the on/off status of display lists

SYNOPSIS
   int DPdlist_get_status(
      IGRboolean *on_off )

PARAMETERS
   on_off (OUT) - the on/off status, TRUE means display lists
                  are on

GLOBALS USED
   DPdlist_use_display_list

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   07/14/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   *on_off = DPdlist_use_display_list;
   return( DLIST_S_SUCCESS );
} /* DPdlist_get_status */

/*--- DPdlist_set_status ------------------------------*/

int DPdlist_set_status(
   IGRboolean on_off )

/*
NAME
   DPdlist_set_status

DESCRIPTION
   This function sets the on/off status of display lists

SYNOPSIS
   int DPdlist_set_status(
      IGRboolean *on_off )

PARAMETERS
   on_off (IN) - the on/off status, TRUE means display lists
                 are on

GLOBALS USED
   DPdlist_use_display_list

RETURN VALUES
   DLIST_S_SUCCESS
      Success
   DLIST_E_ERROR
      Failure

HISTORY
   07/14/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;

   if ( (DPdlist_use_display_list) && (!on_off) )
   {
      sts = DPdlist_exit();
      if ( !(1 & sts) )
      {
         return( sts );
      }
   }

   DPdlist_use_display_list = on_off;

#if defined(ENV5)
   if ( DPdlist_use_display_list )
   {
      DLsync_EG_window();
   }
#endif

   return( DLIST_S_SUCCESS );

} /* DPdlist_set_status */

end implementation Root;

