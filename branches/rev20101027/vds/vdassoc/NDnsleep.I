/* $Id: NDnsleep.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/NDnsleep.I
 *
 * Description:
 *		Changed method NDsleep for savings process.
 *
 * Dependencies:
 *		GRNUCSRC/assoc/nmacro/ACncpxi.I
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 ***************************************************************************/

class implementation ACncpx;

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


from ACcpx_defn import 	ACgive_name, ACgive_temp_desc, ACgive_feet_desc;
from ACcpx_defn import 	ACintpt_foot,ACmax_graph_ft;
from ACmacro_defn import 	ACgive_upscan;
from ACpretend  import 	ACfind_parent;
from ACpretend  import 	ACrebind;
from ACconst  import 	ACget_foot_in_mac;

extern GRclassid OPP_ACpl_hold_class_id, OPP_ASsource_class_id,
		 OPP_ACpretend_class_id, OPP_expression_class_id;


method  NDsleep(struct GRmd_env *md_env)
{
 long loc_msg,status;
 int max_g_ft,nb_component,i;
 extern IGRboolean ASbroadcast_in_progress;
 IGRboolean save_br;
 OM_S_OBJID save_md;
 struct GRid mac_def,component;

/* Delete template-feet pl_hold that were created temporary for ACreturn_foot */

 if(!(me->STATE & ncpx_root))
  {
   status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
/* START VDS CORRECTION */
   if( !(status & 1)){ goto wrapup ; }
/* END   VDS CORRECTION */

   status = om$send(msg= message ACcpx_defn.ACmax_graph_ft(&max_g_ft),
                   targetid = mac_def.objid ,targetos =mac_def.osnum);
/* START VDS CORRECTION */
   if( !(status & 1)){ goto wrapup ; }
/* END   VDS CORRECTION */

   status = om$get_channel_count( objid = my_id,
				  p_chanselect = &AC_mto_graf_chns,
				  count = (OMuint *) &nb_component);
   save_br = ASbroadcast_in_progress;
   ASbroadcast_in_progress = TRUE;
 
   for(i=nb_component-1; i>= max_g_ft; i--)
     status = om$send(msg = message GRgraphics.GRremwrng(&loc_msg,md_env),
		      p_chanselect = &AC_mto_graf_chns,
		      from = i , to = i);

   save_md = md_env->md_id.objid;
   md_env->md_id.objid = NULL_OBJID;
   for(i=nb_component-1; i>= max_g_ft; i--)
     status = om$send(msg = message GRgraphics.GRdelete(&loc_msg,md_env),
		      p_chanselect = &AC_mto_graf_chns,
		      from = i , to = i);

   for(i=max_g_ft-1;i>=0;i--)
    {
     status = om$get_objid_at_index(objid = my_id,
		      p_chanselect = &AC_mto_graf_chns,
		      index = i,
		      objidaddr = &component.objid,
		      osnumaddr = &component.osnum);
     if(!(status&1) || !pl_hold(component)) break;
     status = om$send(msg = message GRgraphics.GRdelete(&loc_msg,md_env),
		      targetid = component.objid);
    }
   md_env->md_id.objid = save_md;
   ASbroadcast_in_progress = save_br;
  }

/* START VDS CORRECTION */
wrapup :
/* END   VDS CORRECTION */

 return om$send(msg = message ACcpx.NDsleep(md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
}
	
end implementation ACncpx;
