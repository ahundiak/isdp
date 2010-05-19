/*
  ACcpxi.I
  robert patience
  21_jul_86
*/
class implementation ACcpx;

#define AS_DEBUG

#include "ASmacroi.h"

#include <limits.h>
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"


from ACcpx_defn import ACreturn_real_def,ACreturn_symb_def;


method NDsleep(struct GRmd_env *md_env)
{
  int			status;
  int traceFlag = 1;
  
  if (traceFlag) {  
    printf(">>> ACcpx.NDsleep %d,%d\n",OM_Gw_current_OS,my_id);
  }
  
  if( me->STATE & sym_rtn_built)
  {
    status = om$send( msg = message ACcpx.ACfree_rtn_str(),
		      senderid=my_id,targetid=my_id);
    as$status( action = RET_STATUS );
  }

/* Modif jla 25-jul-89 
   Does the NDnode.NDsleep before changing real definition to tmp def
   because if the element is support only without dependency it will need
   its definition to implement its delete method (ci_macro)
*/

  status = om$send( mode = OM_e_wrt_message,
		    msg = message ASnode.NDsleep(md_env),
		    targetid = my_id ); 
  as$status() 

/* replace my definition by a symbolic one if not in the same object space */

/*" mac_def was %d %d\n",me->mac_def.objid,me->mac_def.osnum*/
  if(OM_Gw_current_OS != me->mac_def.osnum)
    {
     struct GRid symb_def;
     GRspacenum osnum;
     if (me->mac_def.osnum != 0) osnum = me->mac_def.osnum;
     else 			 osnum = OM_Gw_current_OS;
     status = om$send(msg = message ACcpx_defn.ACreturn_symb_def
						   (&symb_def,OM_Gw_current_OS),
		      targetid = me->mac_def.objid,
		      targetos = osnum);
     as$status();

     if(status&1) me->mac_def = symb_def;
    }
	

/* change the osnum of my definition to know that I am in a sleep state */

    me->mac_def.osnum = 0;

    if (traceFlag) {      
      printf("<<< ACcpx.NDsleep %d,%d\n",OM_Gw_current_OS,my_id);
    }
    
/*" mac_def is now %d %d\n",me->mac_def.objid,me->mac_def.osnum*/
  return ( OM_S_SUCCESS );
}
end implementation ACcpx;
