/* $Id: ACrep_sup.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACrep_sup.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACrep_sup.I,v $
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

class implementation ACncpx;

#define AS_DEBUG

extern char *regcmp();
extern char *regex();
extern char *strpbrk();


#include "ASmacroi.h"
#include "acrepdef.h"
#include "expression.h"
#include "expmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

from ACrg_collect import ACset_list_attribute,ACcreate,
 		         ACadd_attribute_by_type, AClist_attribute;
from expression import NDgive_value,create;

extern GRclassid OPP_expression_class_id;
/* ========================================================================= */
/*
   This function evaluates the representation of the entity
   from its own representation 
   and eventualy from its parents representation
*/

ACcompute_rep_value(rep_in,root,count,rep_out)
int rep_in,*rep_out;
struct GRid *root;
int count;
/*.ACcompute_rep_value*/
{
 int i,temp_rep,union_rep;
 int status;
 long loc_msg;

 if(rep_in&AC_FREE_REP)
   { /*| representation of the entity is free */
      *rep_out = rep_in;
   }
 else
   { /*" Check root representation consistency count %d\n",count */
    union_rep = 0;
    for(i=0;i<count;i++)
     {
      struct GRid go;
      /* jla 3.dec.92 didn't work accross reference file */
      status = om$send(msg = message NDmacro.ACreturn_foot
					(&loc_msg,"",&go,NULL,NULL),
		       senderid = NULL_OBJID,
		       targetid = root[i].objid,
		       targetos = root[i].osnum);

  
      if(status&1)
      status = om$send(msg = message ACncpx.ACget_rep(&temp_rep),
		       senderid = NULL_OBJID,
		       targetid = go.objid,
		       targetos = go.osnum);
      if(!(status&1)) continue;
      if(!(temp_rep)) continue;
      if(temp_rep&AC_SUB_REP) goto error;
      if(union_rep)
       {
        /*"union_rep %x temp_rep %x\n",union_rep, temp_rep&AC_VDS_REP */
	if(union_rep != (temp_rep&AC_VDS_REP)) goto error;
       }
      else
       {
	 union_rep = temp_rep&AC_VDS_REP;
       }
     }
    /* What to do with the parent representation */
    /*"union_rep %x\n",union_rep*/

    if(rep_in&AC_DEP_REP)
      {
       if(!union_rep) goto error;
       *rep_out = AC_DEP_REP | union_rep;
      }

    else 
      {
       if(union_rep) *rep_out = AC_DEP_REP | union_rep;
       else 	     *rep_out = AC_FREE_REP;
      }
   }
  /*"rep in %x rep_out %x\n",rep_in,*rep_out*/
  return 1;

error :

  *rep_out = AC_ERROR_REP;
  /*"rep in %x rep_out %x\n",rep_in,*rep_out*/
  return 1;
}
end implementation ACncpx;
