/*
/* $Id: ACncpx_pass.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdassoc/ACncpx_pass.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: ACncpx_pass.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/01/25  16:40:08  pinnacle
# Created: vdassoc/ACncpx_pass.I by tdumbach r#
#
# Revision 1.1  1994/12/21  21:47:42  pinnacle
# Created:   vdassoc/ACncpx_pass.I r#
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	12/21/94	adz		No check on list within bubble_up.
 */

class implementation ACncpx;

/*
 *	Correction in ACpass_up method.
 *	The argument list (input parameter) can be equal to "ZERO" 
 *	when the parent list not found. The method ACpass_up does
 *	not check if the allocated list is defined. 
 *	The system crash when the one list was found. (list = NULL ).
 *
 *	The problem occurs before, but this is the most appropiate
 *	location to check.
 *
 *	Adz.	11/28/94
 */

#define AS_DEBUG

#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "godef.h"
#include "grownerdef.h"
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "gocmacros.h"
#include "ASmsg.h"
#include "msmacros.h"
#include <alloca.h>


/* ========================================================================= */
method ACpass_up (long *msg;
		int count; struct GRid list [];		
		int up_index;OM_p_MESSAGE Condition,Action;
		     enum OM_e_wrt_flag delAction)
{
int f;
#define _execute_ 1
#define _pass_up_ 2
long status;

 status = OM_S_SUCCESS;

 if(!Condition)
  f=_pass_up_;
 else
  {
  f=0;
  status =om$send(msg=Condition,targetid=my_id);
  }

 switch(status) 
	{
	case OM_S_SUCCESS 	: f=_execute_ | _pass_up_	; 	break;
	case OM_I_STOP_SENDING 	: f=_execute_ ;status=OM_S_SUCCESS; 	break;
	case OM_W_ABORT 	: f=_pass_up_;status=OM_S_SUCCESS; 	break;
	case OM_E_ABORT 	: status=OM_S_SUCCESS		; 	break;
	default:
	case OM_E_ERROR 	: status=OM_E_ABORT		; 	break;
    	}

 if(f & _execute_)
 {
 	status =om$send(msg=Action,targetid=my_id,mode=delAction);
  	as$status();
 }

 if( (f & _pass_up_ ) && (status &1) )
 {

	if( list ){
  		status =
		om$send(msg = message ACncpx.ACbubble_up
				(msg,"",up_index,Condition,Action,delAction), 
			targetid = list[up_index].objid,
			targetos = list[up_index].osnum );
  		as$status();
	}
 }
 
  return ( status  );
}

end implementation ACncpx;
