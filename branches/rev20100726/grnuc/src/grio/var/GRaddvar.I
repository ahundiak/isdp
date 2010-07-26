/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvar;

#include "grimport.h"
#include "igrmacros.h"
#include "griodef.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include <stdio.h>

%safe
#include <math.h>
%endsafe

IGRint GRaddvar(msg,
		input_alias,
		osnum,
		input_variable)

  IGRlong             *msg;          /* return code from function           */
  GRIOalias_name      *input_alias;  /* alias to be added                   */
  OMuword              osnum;
  struct GRIOvar_def  *input_variable;

{
    IGRlong           status;
    struct GRid       alias_grid;
    GRobjid           mod_id;

    *msg = MSSUCC;       
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
     /*
      *  No table exist so create it
      */
     if(alias_grid.objid == NULL_OBJID)  
      {       
           status = om$construct( osnum = osnum,
                                  classname = "GRvar",
                                  p_objid = &alias_grid.objid );

           _m_check(status,*msg=MSFAIL;);
           _m_checkq(status);

	   /* name object     */
	   ex$add_name_to_NOD(NODname = "IGENOD",
			      objname = "ALIAS_TABLE",
			      objid = alias_grid.objid,
			      mod_osnum = osnum);
	   
	   _m_check(status,*msg=MSFAIL;);
	   _m_checkq(status);
	   
      }

     /*
      *   add to table
      */
      status = om$send(msg = message GRvar.GRvaradd(msg,
                                                    input_alias,
                  		                    input_variable),
                        senderid = NULL_OBJID,
                        targetid = alias_grid.objid,
                        targetos = alias_grid.osnum  );
quit: 
    return ( status );
}

end implementation GRvar;
