// -----------------------------------------------------------------------------
//      Class    :      VLctrLine.S
//
//      Abstract :      Store data corresponding to a I/LOFT control line.
//
//      History  :      Created 		Ghassan JAHMI
//                      Updated 11-APR-1994     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLctrLine(0:0) of VLgenLine;

#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"

override	ACconstruct_feet;

override	VDgetObjDef;

message         VLcreate (IGRlong *msg; IGRchar axis; IGRchar *name; IGRint flag;
			IGRint count; struct GRobj_env *list; IGRdouble *normal;
                    	struct GRmd_env  *md_env);
/*
Abstract
        This routine creates a control line.
Arguments
      O : msg         completion code
      I : axis         Ship axis : x, y or z.
      I : flag         0 : one line per plate,
		       1 : one line for all plates.
      I : count        number of parents.
      I : list         list of parents.
      I : normal       normal on all plates.
      I : md_env       current environment.
Return Values
        MSSUCC or MSFAIL.
*/

message         VLget_attributes(IGRlong *msg; IGRchar *plate_side;
                               IGRint *one_or_all; IGRchar *axis;
                               struct GRid *box);
/*
Abstract
        This routine gets attributes from control line.
Arguments
      O : msg     		  completion code
      O : plate_side		  TOP or BOTTOM 
      O : one_or_all               control line per plate or on all plates. 
      O : axis                     Ship axis (x, y or z)
      O : box                      ACrg collection containing attributes

Return Values
        MSSUCC or MSFAIL.
*/

message        VLget_surf (IGRlong *msg; struct GRobj_env *listobj;IGRint *nbobj);
/*
Abstract
        This routine gets parents of a control line. It should be called twice,
        first (with listobj == NULL) to get the number of parents, 
        second to get parents.
Arguments
      O : msg     		  completion code
      O : listobj		  List of parents
      O : nbobj                   number of parents
Return Values
        MSSUCC or MSFAIL.
*/

message         VLset_attributes(IGRlong *msg; IGRchar *plate_side;
                               IGRint one_or_all;IGRchar axis;struct GRid *box);
/*
Abstract
        This routine sets attributes of a control line. 
Arguments
      O : msg     		  completion code
      I : plate_side		  attribute2 : TOP or BOTTOM side of plates. 
      I : one_or_all              attribute2 : line per plate or for all plates.
      I : axis                    attribute3 : Ship Axis (x,y or z)
      I : box                     ACrg collection containing attributes.
Return Values
        MSSUCC or MSFAIL.
*/

message         VLset_surf (IGRlong *msg; IGRint old_nb; struct GRid *old_list;
                          IGRint nb; struct GRid *list);

/*
Abstract
        This routine changes parent surfaces of a control line. 
Arguments
      O : msg     		  completion code
      I : old_nb		  old number of parents.
      I : old_list                old parents.
      I : nb                      new number of parents.
      I : list                    new parents.
Return Values
        MSSUCC or MSFAIL.
*/

end specification VLctrLine;
