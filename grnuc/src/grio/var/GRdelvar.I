/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvar;

#include "grimport.h"
#include "igrmacros.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include <stdio.h>

%safe
#include <math.h>
%endsafe

IGRint GRdelvar(msg,
		osnum,
		num_alias,
		alias_list)
     
     IGRlong            *msg;  
     OMuword             osnum;
     GRIOalias_name     *num_alias; 
     struct GRIOvar_def *alias_list;
{
  IGRlong           status;
  struct GRid       alias_grid;
  GRobjid           mod_id;
    
  *msg = MSSUCC;                    /* assume success               */
  status = OM_S_SUCCESS;        
  
  alias_grid.osnum = osnum;
  alias_grid.objid = NULL_OBJID;
  
  status = ex$get_modid(mod_osnum = osnum,
			mod_id = &mod_id);
  
  status = ex$get_objid_from_NOD(modid = mod_id,
				 mod_osnum = osnum,
				 objname = "ALIAS_TABLE",
				 NODname = "IGENOD",
				 pobjid = &alias_grid.objid);
  _m_check(status,*msg=MSFAIL;);
  _m_checkq(status);
  
  /*
   *   convert value
   */
  status = om$send(msg = message GRvar.GRvardel(msg,
						(IGRshort *)num_alias,
						(GRIOalias_name *)alias_list),
		   senderid = NULL_OBJID,
		   targetid = alias_grid.objid,
		   targetos = alias_grid.osnum  );

  if(!(*msg&1) ) status = OM_E_ABORT;

 quit: 
  return ( status );
}

end implementation GRvar;

