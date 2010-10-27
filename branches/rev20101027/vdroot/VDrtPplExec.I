/* $Id: VDrtPplExec.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vdroot/VDrtPplExec.I
 *
 * Description: Implementation of VDExecutePpl Method.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrtPplExec.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/25  06:35:18  pinnacle
# Replaced: vdroot/VDrtPplExec.I for:  by rchennup for vds
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      11/20/97   Rama Rao     File Creation
 *************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include "v_pplslc.h"

method  VDExecutePpl(   IGRlong         *msg;
                        IGRchar         *file_name;
                        IGRchar         *func_name;
			struct GRmd_env *md_env;
                        IGRint          IN_count;
                        VD_execRes      *IN_args;
			IGRint		*OUT_count;
			VD_execRes	**OUT_args   )
{
   IGRlong sts;
   struct GRid my_GRid;

	*msg = MSSUCC;

	my_GRid.objid = my_id;
	my_GRid.osnum = OM_Gw_current_OS;

	sts = vd$obj_ppl_exec( 	file_name   = file_name,
			       	func_name   = func_name,
			       	object      = &my_GRid,
			       	module_info = md_env,
				IN_count    = IN_count,
			       	IN_args     = IN_args,
				OUT_count   = OUT_count,
				OUT_args    = OUT_args   );
	return sts;
}

end implementation VDSroot;
