/* $Id: ASsourcei.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ASsourcei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ASsourcei.I,v $
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
# Revision 1.2  1995/10/25  17:26:20  pinnacle
# Replaced: vdassoc/int221/ASsourcei.I for:  by tlbriggs for vds.240
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
 *	10/25/95	tlb		EMS 3.2: changed cs.h to grcoordsys.h
 *
 * -------------------------------------------------------------------*/

/*
   ASsource implementation file

HISTORY :
   jla nov 86  : design date
   ch  dec 87  : update for version 1.1
*/

class implementation ASsource;

#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "madef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "batch.h"
#include "csdef.h"
#include "griodef.h"
#include "grcoordsys.h"



#define AS_DEBUG

from GRnotify    import GRntfyconn;
from GRgraphics  import GRconstruct, GRaltconstruct, GRcopy, GRdisplay,
			GRdelete, GRremwrng, GRchgprops;
from GRconnector import GRflexconn,GRdisconn;
from GRcontext   import GRgetinstance;

from ACpretgo    import ACgive_info;

extern IGRboolean ASbroadcast_in_progress;

extern GRclassid  OPP_AScontents_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* return structure of an element waiting delete 			      */
/* (the graphic object is already deleted)				      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDupdate(int *msg, cn_type, count;
                struct GRid *parents;
                int *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
 struct GRid my_grid,my_go;
 int i;
 GRclassid obj_class,obj_class1;
 extern GRclassid OPP_GRgrgrp_class_id,OPP_ASgroup_class_id;
 long status;

/* If context compute, transfer symbology */
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if(context && context->objid != NULL_OBJID)
 {

/* jla march 93 when a graphic is in a macro
  - 1.4 behaviour does not transfer symbology 
  - 2.2 behaviour the graphic group is transformed to ASgroup during
    message ACcopy_to_Groot. Transfer symbology of components
*/

 status=om$get_classid(objid = context->objid,osnum = context->osnum,
                       p_classid = &obj_class);
 status = om$send(msg = message NDnode.ASreturn_go(&my_go,NULL,NULL),
		   targetid = my_id);
 status=om$get_classid(objid = my_go.objid,osnum = my_go.osnum,
                       p_classid = &obj_class1);

 if(om$is_ancestry_valid(subclassid = obj_class1,
 			 superclassid = OPP_GRgrgrp_class_id) == OM_S_SUCCESS)
   {
    if(om$is_ancestry_valid(subclassid = obj_class,
 			 superclassid = OPP_ASgroup_class_id) == OM_S_SUCCESS)
     {
      struct GRid context_cmp,my_cmp;
      extern OM_S_CHANSELECT AS_to_comp;

      for (i=0;i<OM_K_MAXINT;i++)
      {
        status = om$get_objid_at_index(objid = context->objid,
                                     osnum = context->osnum,
                                     objidaddr = &context_cmp.objid,
                                     osnumaddr = &context_cmp.osnum,
                                     p_chanselect = &AS_to_comp,
                                     index = i);
        if(!(status&1)) break;

        status = om$get_objid_at_index(objid = my_go.objid,
                                     osnum = my_go.osnum,
                                     objidaddr = &my_cmp.objid,
                                     osnumaddr = &my_cmp.osnum,
                                     p_chanselect = &AS_to_comp,
                                     index = i);
        if(!(status&1)) break;
        ACtrans_symb(context_cmp,my_cmp);
       }
     }
   }
 else
   {
    ACtrans_symb(*context,my_grid);
   }
 }
 return om$send(msg = message NDnodein.NDupdate(msg,cn_type,count,parents,
					parent_state,context,new_objid,md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
}
end implementation ASsource;
