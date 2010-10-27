/* $Id: ACpretdefi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ACpretdefi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACpretdefi.I,v $
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

class implementation ACpretdef;

/*
 * 04/20/94 :	Mallik:	crash prevention in ACfind_parent
 */

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


/* ========================================================================= */
method ACfind_parent(struct GRid *father;IGRshort *mat_type;IGRdouble *matrix)
{
int status,msg;

   if(!me->map_ptr)
    {
     status = om$send(msg = message ACpretdef.ACload_map_ptr(),
		       targetid = my_id);
     as$status( action = RET_STATUS );
    }

   if(!me->map_ptr) return (0);

  /*"pretdef, father %d ind %d \n",me->map_ptr[me->index].objid,me->index */
    *father = me->map_ptr[me->index];

  /* context now */

  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&msg,matrix);

return(1);
}

/* ========================================================================= */
 

end implementation ACpretdef;
