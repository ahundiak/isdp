/* $Id: ACfind_temp.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/ACfind_temp.I
 *
 * Description:
 *
 * Dependencies:
 *		GRNUCSRC/assoc/macro/ACcpxi.I
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 ***************************************************************************/

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

method ACfind_temp_struct(int *suc;char *name;struct ret_struct  *ptr_rst;
			  struct GRmd_env *md_env)
{
  int 			temp_num, status,i;
  struct stemp 		*dtemp;
  struct GRid mac_def;

  *suc=0; 

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
/* START VDS CORRECTION */
  if( !(status&1)) return status ;
/* END   VDS CORRECTION */

  status = om$send( msg = message ACcpx_defn.ACgive_temp_desc(&temp_num,&dtemp),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  for(i=0;i<temp_num;i++)
  {
    if(!strcmp(name,dtemp[i].name))
    {
      status = om$send(msg = message ACcpx.ACfind_exp_temp_struct(suc,i,
							ptr_rst, md_env),
		     targetid = my_id );
      as$status(action = RET_STATUS );
      return(1);
    }
  }
  return(1);
}

end implementation ACcpx;
