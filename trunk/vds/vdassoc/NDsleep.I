/* $Id: NDsleep.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/NDsleep.I
 *
 * Description:
 *		Avoiding error message in saving process.
 *
 * Dependencies:
 *		$GRNUCSRC/assoc/macro/ACcpx_tmp.I
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 ***************************************************************************/

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
/** START VDS CORRECTION */
	/**  as$status(); **/
/** END   VDS CORRECTION */

     if(status&1) me->mac_def = symb_def;
    }
	
    me->mac_def.osnum = 0;
		      
  return ( OM_S_SUCCESS );
}
end implementation ACcpx;
