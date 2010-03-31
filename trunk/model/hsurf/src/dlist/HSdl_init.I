class implementation Root;

#include <stdlib.h>
#include <stdio.h>

#include "OMerrordef.h"
#include "OMindex.h"

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
#include "HSdlist.h"

extern struct GRid DPdlist_sh_fb_gragad; 

/* New Prototypes */
PROTO_HSdlist_setup_feedback_gragad
PROTO_HSdlist_enter_reference_file
PROTO_HSdlist_exit_reference_file
PROTO_DPdlist_set_shading_reference_file_functions
PROTO_DPdlist_set_shading_display_function
PROTO_HSdlist_display_element

from HSviewdyn import DPsetup_for_dlist_feedback;

/*--- HSdlist_setup_feedback_gragad ------------------------------------------*/

int HSdlist_setup_feedback_gragad(
   void )

/*
NAME
   HSdlist_setup_feedback_gragad

DESCRIPTION
   This function sets up the shading feedback gragad.  It must be called
   after the font information in the module has been set up (i.e.,
   after the font manager has woken up).

SYNOPSIS
   int HSdlist_setup_feedback_gragad(
      void )

PARAMETERS
   none

GLOBALS USED
   DPdlist_sh_fb_gragad

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   07/13/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   IGRlong msg;

   if ( DPdlist_sh_fb_gragad.objid == NULL_OBJID )
   {
      /* construct a feedback gragad for wireframe in the transient object */
      /* space and send it a setup message (?? Does the transient object   */
      /* space get destroyed on a close/retrieve                           */
      DPdlist_sh_fb_gragad.osnum = OM_Gw_TransOSnum_0;
      sts = om$construct( classname = "HSviewdyn",
                          osnum = DPdlist_sh_fb_gragad.osnum,
                          p_objid = &DPdlist_sh_fb_gragad.objid );

      if ( ! (1 & sts) )
      {
          return( DLIST_E_ERROR );
      }

      sts = om$send( msg = message HSviewdyn.DPsetup_for_dlist_feedback( &msg, FALSE ),
                     targetid = DPdlist_sh_fb_gragad.objid,
                     targetos = DPdlist_sh_fb_gragad.osnum,
                     senderid = NULL_OBJID );

      if ( ! (1 & sts & msg) )
      {
          return( DLIST_E_ERROR );
      }

   }

   /* set the shading display function */
   sts = DPdlist_set_shading_display_function( HSdlist_display_element );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   /* set the shading reference enter/exit functions */
   sts = DPdlist_set_shading_reference_file_functions( HSdlist_enter_reference_file,
                                                       HSdlist_exit_reference_file );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* HSdlist_setup_feedback_gragad */

end implementation Root;
