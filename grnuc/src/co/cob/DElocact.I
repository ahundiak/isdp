class implementation Root;

#include "grimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "exdef.h"
#include "lcdef.h"
#include "OMerrordef.h"
#include "codef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "lc.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grmacros.h"
#include "grgsmacros.h"
#include "igrmacros.h"
#include "msdef.h"

from GRgraphics import GRgetprops;

IGRint DElocact( args, new_entry, locate_args, action )

    struct LC_action_args  *locate_args;
    enum   GRlocate_action *action;
    IGRchar                *args;
    struct GRlc_info       *new_entry;

{
    IGRlong                 msg,
                            status = OM_S_SUCCESS,
                            string_status;
    short                   prop_mask;
    IGRchar                 class_name[80];

    switch (*action)
    {
       case end_transition:
       case start_transition:
       case post_object:
       case check_object:
                         break;

       default:

          status = om$get_classname( classname = class_name,
                                     objid = new_entry->located_obj.objid,
                                     osnum = new_entry->located_obj.osnum );

          status = om$is_ancestry_valid( subclassname = class_name,
                                         superclassname = "GRgrgrp" );

          string_status = strcmp( class_name, "GRgrgrp" ) == 0;

          if ( (status == OM_I_INVANCESTRY) && (!string_status) )
	  { /* we have a GO not a graphic set or graphic group. */
              
              /* we have a GO, not a graphic set or graphic group */
               status = om$send (
                           msg = message GRgraphics.GRgetprops(&msg,&prop_mask),
                      senderid = new_entry->located_obj.objid,
                      targetid = new_entry->located_obj.objid,
                      targetos = new_entry->located_obj.osnum);
                                    
              /*
               * If the GO doesn't have an SO, then it should not
               * be ineligible for locating.  If an error is returned,
               * the locate will not find another GO, therefore we
               * pass back a success message so the locate code will 
               * attempt to find another object.
               */
               if ( ! (prop_mask & DEHAS_OVERRIDE) )
               {
                 status = OM_S_SUCCESS;
                 break;
               }

               if ( args )
               {
                 status = DEshow_only_one_soo(
                                 &msg,
                                 &new_entry->located_obj,
                                  new_entry->geom_parms.u,
                                 &locate_args->stack[0].window,
                                 &new_entry->module_info );
                                 
                 if ( msg != MSSUCC )
                 {
                   status = OM_S_SUCCESS;
                   break;
                 }
               
                 status = DEshow_all();
               }
          }

          /* call LCptlocact */
          status = LCptlocact( args, new_entry, locate_args, action );

          break;
    }

 quit:
    return( status );
}
end implementation Root;
