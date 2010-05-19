/* $Id: VDpretendi.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/imp / VDpretendi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDpretendi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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

class implementation VDpretend;

#include "AS_status.h"
#include "asmacros.h"
#include "exmacros.h"
#define AS_DEBUG

VDmake_VDpretend(located_obj,located_env,nb_obj,pretend,pretend_env)
struct GRid *located_obj,*pretend;
struct GRmd_env *located_env,*pretend_env;
int nb_obj;

{ 
 struct GRid source;
 struct GRid cur_mod;
 long msg,status;
 int i_obj,j_obj;

 
   ex$get_cur_mod(osnum = &cur_mod.osnum, id = &cur_mod.objid);

 /* search duplicated elements */
 for(i_obj=0;i_obj<nb_obj;i_obj++)
  {
   pretend[i_obj] = located_obj[i_obj];
   pretend_env[i_obj] =  located_env[i_obj];

   for(j_obj=i_obj+1;j_obj<nb_obj;j_obj++)
    {
     if(located_obj[i_obj].objid != located_obj[j_obj].objid ||
        located_obj[i_obj].osnum != located_obj[j_obj].osnum ) continue;

   /* Not really correct, should also test if the module matrix are different */
   /* Not to bad, it just ends uo creating not necessary pretend */
       

     /* make source or pretend in the current OS */
     status = as$make_source(go_grid = located_obj[i_obj],
			   mod_env = located_env+i_obj,
			   as_os = cur_mod.osnum,
			   as_grid = &source);
     as$status(action = RET_STATUS);

     /* construct a VRpretend on it */

     status = om$construct(classid = OPP_VDpretend_class_id,
                           osnum   = cur_mod.osnum,
                           p_objid = &pretend[i_obj].objid,
                           msg = message ACpretend.ACpconnect(1,source,"."));
     as$status(action = RET_STATUS);
     pretend[i_obj].osnum = cur_mod.osnum;

     /* md env now */

     pretend_env[i_obj].md_id = cur_mod;
     MAidmx(&msg,pretend_env[i_obj].md_env.matrix);
     pretend_env[i_obj].md_env.matrix_type = MAIDMX;
     break;
    }
   }
    
  return OM_S_SUCCESS;
}

end implementation VDpretend;
