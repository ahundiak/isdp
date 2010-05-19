/* $Id: NDnodei.I,v 1.4 2002/05/01 20:53:16 louis Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / NDnodei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: NDnodei.I,v $
 *	Revision 1.4  2002/05/01 20:53:16  louis
 *	Remove kudges for tr5415
 *	
 *	Revision 1.3  2001/07/09 23:18:11  anand
 *	No TR.
 *	
 *	Revision 1.2  2001/01/22 19:17:25  ahundiak
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  20:10:38  pinnacle
# Fixed Warnings
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
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/30/97  ah	     Fixed warnings
 * 01/22/01  ah      Removed ACconst_VDputSymbAndNameFromTransTable,
 *                   Implemented in vdroot
 * 07/09/01  Anand   Put an exception in NDchildren_deleted - Ensure that
 *		     VRplane objects with only VRcompoints as children also get
 *		     deleted.
 * -------------------------------------------------------------------*/

class implementation NDnode;

#include "AS_status.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "godef.h"
#include "exmacros.h"
#define AS_DEBUG
#include "madef.h"

#include "v_dbgmacros.h"

/*----------------------------------------------------------------------------*/
/*
 * EF 04/15/94 Symbology and name will come from the Trans Table
 * ( Only used with 'Copy/Move Dependency Graph' ).
 *
 * EF ----- Begin -----
 */

#argsused	// Fix warnings
#if 0
long ACconst_VDputSymbAndNameFromTransTable( msg, object, md_env )

long		*msg ;
struct GRid	*object ;
struct GRmd_env *md_env ; {
	
	*msg = MSFAIL ;
	return OM_E_ABORT ;
}
#endif

/*
 * EF ----- End -----
 */
/*----------------------------------------------------------------------------*/
method NDconnect_graph(IGRlong *msg; IGRint cp_type;
                 struct GRmd_env *fr_env,*to_env;
                 struct NDcp_list *copied_element; int copied_size;
                 int nb_root, *root_index;
                 int my_index)
{
 struct GRid *his_root,my_grid;
 int i;
 long status = OM_S_SUCCESS;

 *msg = MSSUCC;
 if(nb_root == 0) return OM_S_SUCCESS;

 /* Get the element I have to connect my clone to */

 /*"nb_root %d\n",nb_root */

 his_root = (struct GRid *) malloc(nb_root*sizeof(struct GRid));
 if(!his_root){*msg = MSFAIL; return OM_W_ABORT;}
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 for(i=0 ; i<nb_root ; i++)
 {
  his_root[i].objid = copied_element[root_index[i]].clone;
  his_root[i].osnum = to_env->md_id.osnum; 
  /*"his root %d %d\n",his_root[i].objid,his_root[i].osnum*/

 }

 status = om$send(msg = message NDnode.NDconnect
					(nb_root,his_root,my_grid,ND_NEW),
		  targetid = copied_element[my_index].clone,
		  targetos = to_env->md_id.osnum);
 as$status();
 if(!(status&1)) *msg = MSFAIL;

/*
 * EF 04/15/94 Symbology and name will come from the Trans Table
 * ( Only used with 'Copy/Move Dependency Graph' ).
 *
 * EF ----- Begin -----
 */
if( cp_type == 0 ) {
	int 		rc ;
	struct GRid 	object ;
	OMuword		classid ;
	extern OMuword  OPP_ACconst_class_id ;

	object.objid = copied_element[my_index].clone ;
	object.osnum = to_env->md_id.osnum ;
	
	rc = om$get_classid( osnum     = object.osnum,
			     objid     = object.objid,
			     p_classid = &classid ) ;
			     
	if( ( rc & 1 ) && 
	    om$is_ancestry_valid( subclassid   = classid,
				  superclassid = OPP_ACconst_class_id ) == OM_S_SUCCESS ) {

		status = ACconst_VDputSymbAndNameFromTransTable( msg, 
							         &object,
							         to_env ) ;

		if( !( status & 1 & *msg ) ) {
			printf( "Trans Table Error for [%d,%d]\n", object.osnum, object.objid ) ;

			status  = OM_S_SUCCESS ;
			*msg    = MSSUCC ;
		}
		
	}
}
/*
 * EF ----- End -----
 */

 return status;
}
/*----------------------------------------------------------------------------*/

end implementation NDnode;
