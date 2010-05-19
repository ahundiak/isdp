/* $Id: exp_ovrdi.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / exp_ovrdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: exp_ovrdi.I,v $
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
   ABSTRACT :
   --------

   This file contains the methods that are overriden by expression.


   HISTORY :
   -------

   12/10/1987 : HGB - Design Date from a cupple of files.
   03/14/1988 : HGB - Support the new_id in copy_to_root
                      Define EXP_len_substitute & EXP_len_locate for
                      new syntax in CI (graph printer).
   03/25/1988 : HGB - No longer support syntax in returned structure
*/

class implementation expression;

#include <stdio.h>
#include <string.h>
#include <OMminimum.h>
#include <OMmacros.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "madef.h"
#include "AS_status.h"

#include "grdpbmacros.h"
#include "gocmacros.h"

#define AS_DEBUG

extern GRclassid OPP_Gexp_class_id;
method NDmake_source(IGRlong *msg; struct GRid *located_obj,*context;char *path;
                     GRspacenum as_osnum; struct GRid *as)
{
  long status;
  struct GRid my_grid,owner_grid;

/* jla 11-nov-92 fix dependent connection to expressions members of a macro  
   to be by pretend on the dependent channel of the macro occurence */ 

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  owner_grid.objid = NULL_OBJID;

  ASget_as_owner(&my_grid,&owner_grid);
  if(owner_grid.objid != NULL_OBJID)
   {
    /* assoc owner */
    status = om$send(msg = message NDnode.NDmake_source
                                   (msg,&my_grid,context,path,as_osnum,as),
                    targetid = owner_grid.objid,
                    targetos = owner_grid.osnum);
   }

  else if (as_osnum == OM_Gw_current_OS)
  {
    /* dependency in the same OS */
    status = om$send ( msg = message NDnode.NDmake_source
			      ( msg, located_obj, context, path, as_osnum, as ),
        mode = OM_e_wrt_message,
        targetid = my_id );
  }
  else
  {
    /* dependency in another OS */
    status = ASmake_source_from_go(msg,&my_grid,context,as_osnum,as);
  }

  return status;
}
end implementation expression ;
