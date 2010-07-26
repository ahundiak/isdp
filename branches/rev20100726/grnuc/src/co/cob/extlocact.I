/*
Name
  extlocact

Abstract
   Extend elements to intersection command should not allow to extend
   SK objects such as SKline, SKcompcurve. This function returns success
   if SK objects are found. Otherwise default action handler is invoked.

Keywords
  

History
  05/21/93 : Mrudula Mangalvedhekar : Creation

*/
class implementation Root;

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "exdef.h"
#include "lcdef.h"
#include "OMerrordef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "lcmacros.h"
#include "dp.h"
#include "lc.h"

IGRint extlocact( args, new_entry, locate_args, action )

    struct LC_action_args  *locate_args;
    enum   GRlocate_action *action;
    IGRchar                *args;
    struct GRlc_info       *new_entry;

{
    IGRlong                 status = OM_S_SUCCESS;
    IGRchar                 class_name[80];

    switch (*action)
    {
       case end_transition:
       case start_transition:
       case post_object:
       case check_object:
                         break;

       default:
          /* 
             Any SK objects should not get extended. Avoid those objects
             from getting located.
          */
          status = om$get_classname( classname = class_name,
                                     objid = new_entry->located_obj.objid,
                                     osnum = new_entry->located_obj.osnum );

          status = om$is_ancestry_valid( subclassname = class_name,
                                         superclassname = "SKgeometry" );
          if (status == OM_I_INVANCESTRY)
	  { 
            /* call default action handler if not SK objects */
            status = lc$action( args = args, 
                                new_entry = new_entry,
                                locate_args = locate_args,
                                action = action );

            break;
          }
     }
    return( status );
}
end implementation Root;
