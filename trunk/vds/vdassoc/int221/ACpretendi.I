/* $Id: ACpretendi.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACpretendi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACpretendi.I,v $
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
class implementation ACpretend;

#include "ASmacroi.h"

#include "macro.h"
#include "madef.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#define AS_DEBUG

from ACmacro_defn import ACfind_map;
from ACpreroot 	import 	ACplace;

/* states of pretends bad implementation but to late now */
extern GRclassid OPP_ACcpx_class_id;

/* ========================================================================= */

method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)
{
  int 		i, status;
  IGRlong	msg;
  struct GRid 	target;
  struct GRid 	father;
  double mat1[16],mat2[16];
  short mat_typ1,mat_typ2;

  /*"down_scan %s index %d \n",  me->down_scan,me->direct_index */

  status = om$send(msg = message ACpretend.ACfind_parent(&father,
							 &mat_typ1,mat1),
		       targetid = my_id);
     as$status( action = RET_STATUS );

  if('.'==me->down_scan[0])
  {
    status = om$send(msg = message NDnode.ASreturn_go(go,&mat_typ2,mat2),
		       targetid = father.objid,
		       targetos = father.osnum);
    as$status( action = RET_STATUS ); 
  }
  else
  {
   status = om$send(msg = message NDmacro.ACreturn_foot
				(&msg,me->down_scan,&target,&mat_typ2,mat2),
      		     targetid = father.objid,
		     targetos = father.osnum );
   if(!msg || !(status&1))
    {
     printf("ACpretends %d %d return_go unable to find feet %s \n",
            my_id,OM_Gw_current_OS,me->down_scan);
     return(OM_W_ABORT);
    }
    *go=target; 
  }

 if(mat_typ1 == MAIDMX)
  {
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = mat2[i];
   if(mat_type != NULL) *mat_type = mat_typ2;
  }
 else if(mat_typ2 == MAIDMX)
  {
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = mat1[i];
   if(mat_type != NULL) *mat_type = mat_typ1;
  }
 else
  {
   short four = 4;
   double tmp_matrix[16];
   MAmulmx(&msg,&four,&four,&four,mat1,mat2, tmp_matrix);
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = tmp_matrix[i];
   if(mat_type != NULL) MAtypemx(&msg,tmp_matrix, mat_type);
  }

 /*^ 
 printf("go %d %d mat_type %d\n",go->objid,go->osnum,*mat_type);
 pr_mat("matrix",4,4,matrix);
 */
 return(OM_S_SUCCESS);
}

/* ========================================================================= */

end implementation ACpretend;
