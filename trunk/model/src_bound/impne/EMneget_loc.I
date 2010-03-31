/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

#include "EMSbnddef.h"

method EMget_location(IGRlong *EMmsg;
                      IGRshort *location)
/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date

Algorithm

      This method gets the location of the natural edge from its
      instance data 
*/

{
  IGRlong stat_OM;
 
  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *location = (IGRshort)(ME.EMSnatedge->location & 0x3);

  return(stat_OM);
}

end implementation EMSnatedge;
