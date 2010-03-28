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


IGRint GRcvt_to_var(msg,
		    input_alias,
		    osnum,
		    var)

     IGRlong            *msg;  
     GRIOalias_name     *input_alias;
     OMuword             osnum;
     struct GRIOvar_def *var;  
{
  IGRint           *sts;
  IGRlong           status;
  struct GRid       alias_grid;
  GRobjid           mod_id;
  
  sts = (IGRint *)msg;
  *msg = MSSUCC;   
  status = OM_S_SUCCESS;        

  status = ex$get_modid(mod_osnum = osnum,
			mod_id = &mod_id);

  alias_grid.osnum = osnum;
  status = ex$get_objid_from_NOD(modid = mod_id,
				 mod_osnum = osnum,
				 objname = "ALIAS_TABLE",
				 NODname = "IGENOD",
				 pobjid = &alias_grid.objid);
  _m_check(status,*sts=MSFAIL;);
  _m_checkq(status);

  /*
   *   convert value
   */
  status = om$send(msg = message GRvar.GRvarcvrt(sts,
						 input_alias,
						 var),
		   senderid = NULL_OBJID,
		   targetid = alias_grid.objid,
		   targetos = alias_grid.osnum  );

 if(!(*sts&1) ) status = OM_E_ABORT;
  
 quit: 
  return ( status );
}

end implementation GRvar;


















