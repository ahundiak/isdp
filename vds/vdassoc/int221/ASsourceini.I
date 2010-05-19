/* $Id: ASsourceini.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ASsourceini.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ASsourceini.I,v $
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
   ASsource implementation file specific for  inter object space

HISTORY :
   jla feb-88 : design date
*/

class implementation ASsourcein;

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
#include "parametric.h"
#include "gr.h"

#define AS_DEBUG

from GRgraphics  import GRdisplay,GRconstruct,GRcopy;
from GRcontext   import GRgetinstance;
from GRvg        import GRchgprops;

extern IGRboolean ASbroadcast_in_progress;
extern GRclassid  OPP_ACpretend_class_id;

method ASreturn_go(struct GRid *go;short *mat_type;IGRdouble *matrix)
{
  IGRlong status,msg;
  OM_S_OBJECT_LINKAGE go_link[2];
  struct GRid context;
  OMuint count;
  GRclassid go_classid;

  /*| get graphic object */


  status = om$get_channel_objects(object = me, p_chanselect = &AS_listeners,
      list = go_link,size = 2, count = &count);

  as$status(action = RET_STATUS);

  if(count<1) return (OM_W_ABORT);

  /*
   The channel is not ordered. Thus we can find the context at the first or
   at the second position 
*/
  status=om$get_classid( osnum = go_link[0].osnum, objid = go_link[0].S_objid,
        		 p_classid = &go_classid);
  as$status(action = RET_STATUS);

  if (count == 1 && 
      om$is_ancestry_valid(subclassid = go_classid,
             superclassid = OPP_GRcontext_class_id)!=OM_S_SUCCESS)
  {
    go->objid = go_link[0].S_objid;
    go->osnum = go_link[0].osnum;
  }

  else if(count == 2)
  {
    if((om$is_ancestry_valid(subclassid = go_classid,
        superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
    {
      context.objid = go_link[0].S_objid;
      context.osnum = go_link[0].osnum;
      go->objid = go_link[1].S_objid;
      go->osnum = go_link[1].osnum;
    }
    else
    {
      go->objid = go_link[0].S_objid;
      go->osnum = go_link[0].osnum;
      context.objid = go_link[1].S_objid;
      context.osnum = go_link[1].osnum;
    }
  }
  else return OM_W_ABORT;


  /*| context now */

  if(mat_type != NULL || matrix != NULL)
  {
    if(count == 2)
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
      as$status(action = RET_STATUS);
    }
    else
    {
      /* no context */
      if(mat_type != NULL) *mat_type = MAIDMX;
      if(matrix != NULL) MAidmx(&msg,matrix);
    }
  }

  /*"Graphic object returned: %d, %d\n", go->objid, go->osnum */
  return (OM_S_SUCCESS);
}
end implementation ASsourcein;
