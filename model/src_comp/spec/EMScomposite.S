/*
  ABSTRACT

  This is an abstract class for composite geometries.  All EMS
  compositing functionality should subclass from this class. General
  composite functionalities will be implemented by this class.


  HISTORY

  TGM 07/30/91    Un-Rejected GRkeypoint.
  DLB 12/11/90    Put #ifndef IDRAW around GRplotprep overrride.
  RC  01/03/90    Overrode GRplotprep to take care of symbol plotting
  rlw 03/02/89    Modified to add conditional compilation statements
                  for the I/DRAW product.
  rlw 02/15/89    Added GRgethprops and GRgeomprops overrides
  RC  02/14/89    Added GRgetsymb override.
  rlw 08/05/88    Modified to inherit GRidchanged from GRgraphics and
                  to override GRcomponent_idchanged methods.
  DLB 06/08/88    Added GRcomponent_disconnecting override because
                  the GRowner override may delete the owner!!!!
  AIC 23-Feb-88   Reject GRkeypoint for efficiency of tentative
                  keypoint snap.
  RC  1/28/88     Overrode GRlocaldp.
  DLB 9/22/87     1.1.0 class conversion.
  gk  28-may-87   override curve/surface intersect method
  JBK 06-May-1987 Added EMdrop override.
  AIC 03/16/87    Creation Date
*/

class specification EMScomposite (2:0) of GRowner;

# include "emserr.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override 
  GRgethprops,  
  GRgeomprops,  
  GRgetsymb,    
  GRgetattr;

#ifndef BASE_EMS

message EMcomponentchanged
(
  IGRlong *EMmsg;
  GRobjid old_id;
  IGRint num_newids;
  GRobjid *new_ids;
);

from GRgraphics inherit 
  GRidchanged;

override
  GRlocaldp,    
  GRplotprep,
  EMintplane,   
  debug,        
  GRputrang,    
  GRlnproject,
  GRcomponent_disconnecting,  
  GRcomponent_idchanged;	

#endif

end specification EMScomposite;
