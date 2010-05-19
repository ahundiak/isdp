/* $Id: NDMacCons.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / NDMacCons.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: NDMacCons.I,v $
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
   override message declared in NDmacro
   Design jla 11 July 1988
*/


/*  Just Override of ACconsume to avoid a memory fault when the consumed
 *  object is an sourcein (go with a dif osnum that current).
 *
 *  Modification done 18-Mar-93.
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
from GRgraphics  import GRcopy;



/* ========================================================================= */

method ACconsume(IGRlong *msg;char *footname;
	int cpy_req;struct GRid *cpy_GRid;struct GRmd_env *md_env)
{
int status;
short           action, mask;
struct GRid go;
char            old_ASbroad;
extern char     ASbroadcast_in_progress;

IGRmatrix     tmp_matrix;
short         tmp_matrix_type;
struct GRmd_env from_env,to_env;
short four;


  /* default consume for single foot objects */

  *msg=0;
  status = om$send(msg = message NDmacro.ACreturn_foot(msg,
                                     footname,&go,&tmp_matrix_type,tmp_matrix),
                targetid = my_id );
  as$status( );

  if(*msg !=0 && cpy_req)
   {
  /* Initialize md_env for copy */

    four = 4;
    MAmulmx(msg,&four,&four,&four,md_env->md_env.matrix,tmp_matrix,
                                from_env.md_env.matrix);
    MAtypemx(msg,from_env.md_env.matrix,
               &from_env.md_env.matrix_type);
    from_env.md_id.objid = md_env->md_id.objid;
    from_env.md_id.osnum = go.osnum;
 

    to_env.md_id = md_env->md_id;
    MAidmx(msg,to_env.md_env.matrix);
    to_env.md_env.matrix_type = MAIDMX;

    old_ASbroad = ASbroadcast_in_progress;
    ASbroadcast_in_progress = 1;
     {

/* NO LONGER NECESSARY 
/*     GRclassid 		target_cl;
/*     om$get_classid(objid = go.objid,
/*		    osnum = go.osnum,
/*		    p_classid = &target_cl);
/*     if(om$is_ancestry_valid(subclassid =target_cl ,
/*                          superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
/*      {
/*      status = om$send( msg = message NDnode.NDcopy_to_root(msg,0, 
/* 		   &from_env,&to_env,cpy_GRid),
/*                   targetid = go.objid  );
/*      as$status();
/*      }
/*     else
/*      {
/**********/
      status = om$send( msg = message GRgraphics.GRcopy
        (msg,&from_env,&to_env,&(cpy_GRid->objid)),
                targetid = go.objid,targetos = go.osnum );
      as$status( );
      cpy_GRid->osnum=to_env.md_id.osnum;

/* } */
     }
    /*" go.objid %d cpy.objid %d \n",go.objid,cpy_GRid->objid  */
    ASbroadcast_in_progress = old_ASbroad;

    action = 1;    
    mask   = GRIS_LOCATABLE|GRIS_DISPLAYABLE; 
    status = om$send( msg = message GRgraphics.GRchgprops( msg, &action, &mask),
               targetid = cpy_GRid->objid,targetos = cpy_GRid->osnum );
    as$status( );

   }
   action = 0;    
   mask   = GRIS_LOCATABLE|GRIS_DISPLAYABLE; 
   status = om$send( msg = message GRgraphics.GRchgprops( msg, &action, &mask),
                targetid = go.objid,targetos = go.osnum );
   as$status( );

  return (  OM_S_SUCCESS );
}


end implementation NDnodein;
