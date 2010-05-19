/* $Id: NDmacro_over.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / NDmacro_over.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: NDmacro_over.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
   override message declared in NDmacro
   Design jla 11 July 1988
*/

class implementation NDnodein;


#include "AS_status.h"
#include "OMminimum.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "nddef.h"
#include "macro.h"
#include "godef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "igrdp.h"
#include "madef.h"
#include "exmacros.h"
#include "grerr.h"
#define AS_DEBUG

from GRgraphics  import GRchgprops;
from GRgraphics  import GRgetprops;
from GRvg  import GRputsymb, GRgetsymb, GRchgdp, GRgetattr, GRputattr;
from GRgraphics  import GRcopy;
from GRtext import GRgettxattr, GRreplace_text;


/* ========================================================================= */

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *md_env,*new_info;
  			 struct GRid *newobjid)
{
 GRclassid obj_class;
 extern GRclassid OPP_ASsource_class_id;
 /* that should be in ASsource */
 om$get_classid(objid = my_id,
		p_classid = &obj_class);

/* jla march 93 transform GRgrgrp into ASgroup when they become foot of a 
   macro. It allows future symbology tranfer and does not mess up foot
   indexing fo the macro 
*/

if(obj_class == OPP_ASsource_class_id)
{
 extern OM_S_CHANSELECT AS_to_comp, AS_notification;
 long status,loc_msg;
 struct GRid go,newgo;
 extern GRclassid  OPP_GRgrgrp_class_id, OPP_ASgroup_class_id;
 short set,props;
 set = 1;
 props = GR_RIGID_RELATIONSHIP;

/* regular copy */
 status = om$send( msg = message NDnode.NDcopy_to_root(msg,cp_type,  
 		   md_env,new_info,newobjid),
                   targetid = my_id);
 as$status(action = RET_STATUS);

/* test class of graphic */
 status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
		  targetid = newobjid->objid,
		  targetos = newobjid->osnum);
 as$status(action = RET_STATUS);

 status = om$get_classid(objid = go.objid, osnum = go.osnum,
			p_classid = &obj_class);
 as$status(action = RET_STATUS);

 if(om$is_ancestry_valid(superclassid = OPP_GRgrgrp_class_id,
			 subclassid = obj_class) != OM_S_SUCCESS) return status;

/* transform it to ASgroup */

 status = om$construct(classid = OPP_ASgroup_class_id,
		       osnum = go.osnum,
		       p_objid = &newgo.objid);
 as$status(action = RET_STATUS);
 newgo.osnum = go.osnum;

 status = om$send(msg = message Root.move_chan(AS_to_comp,go.objid,
					go.osnum,AS_to_comp),
		  targetid = newgo.objid,
		  targetos = newgo.osnum);
 as$status(action = RET_STATUS);

 status = om$send(msg = message Root.move_chan(AS_notification,go.objid,
					go.osnum,AS_notification),
		  targetid = newgo.objid,
		  targetos = newgo.osnum);
 as$status(action = RET_STATUS);

 status = om$send(msg = message GRgraphics.GRchgprops(&loc_msg,&set,&props),
		  p_chanselect = &AS_to_comp,
		  senderid = newgo.objid,
		  targetos = newgo.osnum);
 as$status();
 status = om$send(msg = message Root.delete(1),
		  targetid = go.objid,
		  targetos = go.osnum);
 as$status();

 om$send( msg = message NDnodein.NDchg_state(ND_SUP_ONLY,0),
                     targetid = newobjid->objid,
                     targetos = newobjid->osnum);

 return ( OM_S_SUCCESS  );
}
else
{
 int status;
 status = om$send( msg = message NDnode.NDcopy_to_root(msg,cp_type,  
 		   md_env,new_info,newobjid),
                   targetid = my_id);
 as$status();

 if( status )
   om$send( msg = message NDnodein.NDchg_state(ND_SUP_ONLY,0),
                     targetid = newobjid->objid,
                     targetos = newobjid->osnum);

 return ( status  );
}
}
end implementation NDnodein;
