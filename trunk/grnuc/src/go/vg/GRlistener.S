/* 
  ABSTRACT

  The GRlistener class is a subclass of Root. Objects
  Subclassed under this class will receive notification
  from graphic objects about what operations were 
  performed on the object.  The objects subclassed under
  GRlistener are connected to the graphics objects by 
  channels defined in their classes.  The objects classed
  under GRlistener should in no way interfere with the 
  message flow of the graphic object.


  HISTORY
	
  MAS 09/03/87 : Creation date
*/

class specification GRlistener (1:1) of Root;

#include "igrtypedef.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message GRnotifylis
(
  IGRlong *msg;
  IGRlong *OMmsg;
  IGRlong *mask;
  OM_S_MESSAGE *graphics_msg;
);

reject  
  GRnotifylis;

#endif

end specification GRlistener;
