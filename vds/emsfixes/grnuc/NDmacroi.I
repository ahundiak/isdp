/* $Id: NDmacroi.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        emsfixes/grnuc/NDmacroi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: NDmacroi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/10/15  16:23:56  pinnacle
# Created: emsfixes/grnuc/NDmacroi.I by jwfrosch for vds.241
#
 *
 * History:
 *      MM/DD/YY	AUTHOR	DESCRIPTION
 *
 *	10/15/96	HF	Overwrite of method NDmacro.ACgive_structure
 *				The ONLY change that has been introduced, is
 *					as$status(action = RET_STATUS);	// line 79 error msg
 *				is replaced by
 *					if ( ! ( status & 1 ) ) { return ( status ) ; }
 *				this, in order to suppress the message:
 *				"Error at line 79 of the file grnuc/src/node/NDmacroi.I"
 *
 *				This overwrite should be removed after I/EMS has modified
 *				the as$status macro to ONLY print error messages when the
 *				global variable OMVERBOSE_WARNING=TRUE
 *
 *				In order to introduce as little change as possible, the
 *				other methods originally in this file, HAVE BEEN REMOVED !!!
 *
 *************************************************************************/

class implementation NDmacro;
/*
   This file implements the methods used by the macros.
*/

#include "AS_status.h"
#include "nddef.h"
#include "madef.h"
#define AS_DEBUG

/* ========================================================================= */

method ACgive_structure( int *suc,*direct_index; char *feet_name;
			 struct ret_struct  *ptr_rst; struct GRmd_env *md_env )
{
  struct GRid 		feet_obj;
  IGRint   		status,loc_msg;
  struct GRmd_env loc_env;
  IGRdouble matrix[16];
  short matrix_type;
  short four = 4;
  char *c,*strchr();

/*"feet name%s \n",feet_name */

/* Does the recusion on ACgive_structure to beheave well on virtual feet */


/*| Is there nesting */

  c=strchr(feet_name,':');
  if(c)
   { /*| yes */
     *c = '\0';

     /*" Retrieve my direct foot %s\n",feet_name */

     status=om$send(msg = message NDmacro.ACreturn_foot((IGRlong *)suc,
				       feet_name,&feet_obj,&matrix_type,matrix),
		    targetid = my_id );
     *c = ':';
     if(status&1 && *suc&1)
      {
       /*"nesting --> send to col %d %d\n",feet_obj.objid,feet_obj.osnum*/

       status = om$send(msg = message NDmacro.ACgive_structure
			           (suc,NULL,c+1,ptr_rst,md_env),
		       targetid = feet_obj.objid,
		       targetos = feet_obj.osnum);
/*       as$status(); */
      }
     if(status&1 && *suc&1) return OM_S_SUCCESS;
    }

/*| No nesting or the ACgive_structure of my component fails */

   status=om$send(msg = message NDmacro.ACreturn_foot((IGRlong *)suc,
				       feet_name,&feet_obj,&matrix_type,matrix),
		  targetid = my_id );
/*"suc %d mat_t %d ft %d %d\n",*suc,matrix_type,feet_obj.objid,feet_obj.osnum */
   if ( ! ( status & 1 ) ) { return ( status ) ; }
//   as$status(action = RET_STATUS);	// Supress: Error at line 79 of NDmacroi.I (HF:10/15/96 TR#179603359)
   if(!(*suc&1)) return OM_S_SUCCESS;

/* Get geometry of the component */

   if(matrix_type != MAIDMX)
      {
       MAmulmx(&loc_msg,&four,&four,&four,md_env->md_env.matrix,matrix,
	      loc_env.md_env.matrix);
       MAtypemx(&loc_msg,loc_env.md_env.matrix,&loc_env.md_env.matrix_type);
       loc_env.md_id = md_env->md_id;
       md_env = &loc_env;
      }

   status=ASany_give_struct( feet_obj.objid,feet_obj.osnum,md_env,ptr_rst );
   as$status();
   if(status&1) *suc=1;

  return ( status );
}

end implementation NDmacro;
