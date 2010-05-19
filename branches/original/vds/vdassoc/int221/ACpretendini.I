/* $Id: ACpretendini.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACpretendini.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACpretendini.I,v $
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
  ACpretendi.I
  robert patience
  21_jul_86
*/
class implementation ACpretendin;

#include "ASmacroi.h"

#include "macro.h"
#include "madef.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmatrix.h"

#define AS_DEBUG

#define ACin_graph 0


from GRcontext import GRgetinstance;
from GRnotify import GRntfyconn;

/* ========================================================================= */
method ACfind_parent(struct GRid *father;IGRshort *mat_type;IGRdouble *matrix)
{
int status;
long msg;
OM_S_OBJECT_LINKAGE go_link[2];
struct GRid context;
GRclassid go_classid;
OMuint count;

 status = om$get_channel_objects(object = me, p_chanselect = &AS_listeners,
                                 list = go_link,size = 2, count = &count);
 as$status(action = RET_STATUS);

 if(count<1 || count >2) return (OM_W_ABORT);

 status=om$get_classid( osnum = go_link[0].osnum, objid = go_link[0].S_objid,
        p_classid = &go_classid);
 as$status(action = RET_STATUS);

 if (count == 1 && 
          om$is_ancestry_valid(subclassid = go_classid,
        	  superclassid = OPP_GRcontext_class_id)!=OM_S_SUCCESS)
  {
   father->objid = go_link[0].S_objid;
   father->osnum = go_link[0].osnum;
   if(mat_type) *mat_type = MAIDMX;
   if(matrix)   MAidmx((int *) &msg,matrix);
  }

/*
   The channel is not ordered. Thus we can find the context at the first or
   at the second position
*/

 else 
  {
    if((om$is_ancestry_valid(subclassid = go_classid,
        superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
    {
      context.objid = go_link[0].S_objid;
      context.osnum = go_link[0].osnum;
      father->objid = go_link[1].S_objid;
      father->osnum = go_link[1].osnum;
    }
    else
    {
      father->objid = go_link[0].S_objid;
      father->osnum = go_link[0].osnum;
      context.objid = go_link[1].S_objid;
      context.osnum = go_link[1].osnum;
    }

  /* context now */

  if(mat_type != NULL || matrix != NULL)
    {
     struct GRid ctx_bis;
     GRspacenum ref_osnum;
     short ref_flag;
     short tmp_mat_type;
     double tmp_matrix[16];

     if(mat_type == NULL) mat_type = &tmp_mat_type;
     if(matrix == NULL) matrix = tmp_matrix;

     status = om$send(msg = message GRcontext.GRgetinstance(&msg,mat_type,
                                        matrix,&ref_osnum,&ref_flag,&ctx_bis),
                      targetid = context.objid,
                      targetos = context.osnum);
     }
   }

return(OM_S_SUCCESS);
}
end implementation ACpretendin;
