/* #######################    APOGEE COMPILED   ######################## */

/*
Abstract
	This function returns the object id and the osnum of the 
	currently active module.  It  does not depend on which space
	is active when it is called.

Notes
	The same functionality is supported by ex$findmod.


History
	7/20/87	Started documentation.
  scw  07/13/92 Ansi conversion:w

*/
extern struct module_params *module_data[];
extern unsigned short int OM_Gw_current_OS;

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMlimits.h"
#include "ex.h"
#include "godef.h"
#include "igrdp.h"
#include "gr.h"
#include "igr.h"
#include "go.h"

extern OM_S_OBJID EX_active_module;
extern OMuword EX_active_OS_num;

int GRfindmod ( id )

struct GRid *id;

{
  id->objid = EX_active_module;
  id->osnum = EX_active_OS_num;

  return (1);
}
