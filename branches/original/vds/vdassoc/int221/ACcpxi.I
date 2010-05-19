/* $Id: ACcpxi.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACcpxi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACcpxi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *	Initial import to CVS
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
  ACcpxi.I
  robert patience
  21_jul_86
*/
class implementation ACcpx;

#define AS_DEBUG

extern char *regcmp();
extern char *regex();
extern char *strpbrk();

#include "ASmacroi.h"

#include <limits.h>
#include "macro.h"
#include "acmacros.h"
#include "grownerdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "grownmacros.h"
#include "grerr.h"
#include "acrepdef.h"

extern GRclassid OPP_ACtmp_defn_class_id;

from ACcpx_defn import 	ACintpt_foot, 
			ACgive_name, ACgive_temp_desc, ACgive_feet_desc,
			ACreturn_real_def;


from ci 	import 	f_execute;
from ACroot 	import 	ACmplace;
from ACmacro_defn import ACgive_upscan;
#if 0
from ACsym        import ACunmap_fr_defn;
#endif
from ACncpx      import ACget_rep;
/* ========================================================================= */

method NDctl_parent_type(long *msg;int type; char *info)
{
 char *macro_name;
 long status;
 struct GRid mac_def;

/* Is a macro required ? */

 *msg = MSFAIL;
 if(!(type&macro_generic)) return OM_S_SUCCESS;

/* Do we have to control its type */

 if(info == NULL || (info[0] == '*' && info[1] == '\0') || info[0] == '\0') 
  { *msg = MSSUCC; return OM_S_SUCCESS;}

 status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);

 if(status&1) status = om$send(
                         msg = message ACcpx_defn.ACgive_name ( &macro_name ),
                         targetid=mac_def.objid,
                         targetos=mac_def.osnum);
 if(ASmatchRE(info,macro_name)) *msg = MSSUCC;
 else 				*msg = MSFAIL;
 

 return OM_S_SUCCESS;
}
end implementation ACcpx;
