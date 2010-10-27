/* $Id: pretendi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdassoc/pretendi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *
 *	09/18/95	Ad, rmn		Check for return status from
 *					ACfind_parent
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

/* states of pretends bad implementation but to late now */

method   ACreturn_foot(IGRlong *msg;char *footname;     
		struct GRid *foot_GRid;IGRshort *mat_type;IGRdouble *matrix)
{
  int	        i,status;
  char          feet_bloc[3000];
  struct 	GRid father;
  IGRshort	loc_mat_type1,loc_mat_type2;
  IGRmatrix     loc_matrix1,loc_matrix2;

/* 
  This returns the transformation matrix when the modification is accross
  object space 
*/
  /* START MODIFICATION */
  if( foot_GRid )	foot_GRid->objid = NULL_OBJID ;
  /* END   MODIFICATION */

  status = om$send(msg = message ACpretend.ACfind_parent
			(&father,&loc_mat_type1,loc_matrix1),
		       targetid = my_id);
/* START MODIFICATION */
  if( !(status&1)) return status ; 
/* END   MODIFICATION */

/*"me->down_scan >>%s<<, foot name >>%s<<\n",me->down_scan,footname */
  ACmkstring(feet_bloc,me->down_scan,footname);

  /*"return_foot >%s< to %d %d\n",feet_bloc,father.objid,father.osnum */
  status = om$send(msg = message NDmacro.ACreturn_foot ( msg,
					feet_bloc,foot_GRid,
					&loc_mat_type2,loc_matrix2),
        	     targetid = father.objid,
		     targetos = father.osnum );
   /*"msg %d status %d\n",*msg,status */
  as$status(  ); 

  if(loc_mat_type1 == MAIDMX)
   {
    if(mat_type) *mat_type = loc_mat_type2;
    if(matrix) for(i=0;i<16;i++) matrix[i] = loc_matrix2[i];
   }
  else if(loc_mat_type2 == MAIDMX)
   {
    if(mat_type) *mat_type = loc_mat_type1;
    if(matrix) for(i=0;i<16;i++) matrix[i] = loc_matrix1[i];
   }
  else
   {
    short four = 4;
    double tmp_matrix[16];
    MAmulmx( msg, &four, &four, &four, loc_matrix1, loc_matrix2, tmp_matrix );
    if(matrix) for(i=0;i<16;i++) matrix[i] = tmp_matrix[i];
    if(mat_type) MAtypemx(msg,tmp_matrix,mat_type);
   }
 

  /*"ACgive foot %d \n",foot_GRid->objid */
  return(status);
}

end implementation ACpretend;
