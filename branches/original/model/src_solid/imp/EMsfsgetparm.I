/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsolid;

#include "EMS.h"
#include "EMSsfparms.h"
#include "EMSerrordef.h"

method EMget_params (IGRlong *EMmsg; /* Completion code */
		     struct IGRbsp_surface *geom; /* Geom of the dominant
							surface */
                     struct GRmd_env *env ; /* Module environment of the 
                                               solid */
                     IGRushort *type;  /* type of the dominant
                                                 surface */
                     struct EMsurface_params *param) /* Parameters of the
                                                       dominant surface */
                     
/* *************************************************************************

Description
         This method gets the parameters of the dominant surface, in the
         space pointed to by the EMsurface_param structure. Module
         environment of the solid needs to be supplied.

         Input
           env
		
	   geom - Geometry of the dominant surface,if known.
         Output
           param - parameters of the dominant surface.Should be set to NULL
                   if not interested in the same.
           type - type of the dominant surface. Should be set to NULL if
                  not interested in the same. 
           EMmsg - Completion code

Notes
         Upon exit the completion code will be one of the following:
         EMS_S_Success : if all goes well
         EMS_E_Fail : if there is failure

Algorithm
         This method essentially passes on the message to the dominant
         surface
See also
          EMSsfparams.h, emssfdef.h
History
	 06/30/88 : SAM : Added geometry argument to the message.
         01/16/88 : PP  : Modified the argument list to support
                          return of dominant surface type and
                          the parameters seperately. 
         12/03/87 : PP  : Creation

  ************************************************************************** */ 
{

 IGRlong	status;
 OM_S_CHANSELECT to_components;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 
 to_components.type = OM_e_addr;
 to_components.u_sel.addr = &me^^GRcmpowner.to_components;
 
 status = om$send (msg = OPPmargs,
                   p_chanselect = &to_components,
                   from = 0,
                   to = 0);
 return (status);
}

end implementation EMSsfsolid;
