/* $Id: VRconci.I,v 1.2 2001/02/20 01:12:58 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconstrain / VRconci.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRconci.I,v $
 *	Revision 1.2  2001/02/20 01:12:58  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/03/01  20:18:56  pinnacle
# Replaced: vrconstrain/VRconci.I for:  by azuurhou for route240
#
# Revision 1.2  1996/01/16  22:11:58  pinnacle
# Replaced: vrconstrain/VRconci.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add prototypes
 *	03/01/96	adz	Control error messages.
 *
 *************************************************************************/

class implementation VRconc;

#include "OMmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "vrdbgmacros.h"

#include "vrconstr_pto.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

from VRcons import VRadd_constrain,VRinit_constrain;

extern struct GRid *NDrealloc_object_buffer();


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* Add the constraint solver GRid to the list of dependent objects */
method NDget_virtual_objects(int type;struct GRid *list;int size;
                         struct GRid **buffer; int ifrom,ito,*count,*virt_count)
{

	int		status;
	struct GRid	my_grid,solver;

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;


	/* Get real roots or real dependent */

	status =
	om$send(msg = message NDnode.NDget_objects
                                (type,list,size,buffer,ifrom,ito,count),
                targetid = my_id);

	*virt_count = *count;

	__CheckRC( 1, status, "NDnode.NDget_objects", wrapup );

	/*
	 * Retrieve constraint solver and add it as dependent or as root
	 */
	status = VRreturn_solver(&solver,OM_Gw_current_OS);

	__DBGpr_obj( " Solver ", solver );

	if( status&1 ){

	  /*
	   * Tell the solver that it has to solve the constrain I define
	   */
	  status =
	  om$send(msg = message VRcons.VRadd_constrain(&my_grid),
		  targetid = solver.objid,
		  targetos = solver.osnum);
	  CheckRC( 1, status );

	  if(type & ND_IN_BUF){
	    *buffer = NDrealloc_object_buffer(*virt_count+1);
	    (*buffer)[*virt_count] = solver;
	  }
	  else if(ito>=*virt_count-1 && *virt_count-ifrom >= size){

	    list[*virt_count-ifrom] = solver;
	  }

	  *virt_count +=1;
	}

wrapup:
	return status;
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method NDcompute_node(IGRlong *msg; IGRint cn_type;
                           IGRint count; struct GRid list [];
                           struct GRmd_env *md_env)
{
	/* Check if the constrain is verified TBD */
	return(OM_S_SUCCESS);

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env;
                IGRchar *go_cnst_lis)
{
	int		status;

	status =
	om$send(msg      = message NDnode.NDchg_state
                                              ( ND_DONT_MVRT, ND_DONT_MVRT ),
                targetid =  my_id);
	__CheckRC( 1, status, "NDnode.NDchg_state", wrapup );

	status=
	om$send(msg = message NDnode.NDconnect(asso_lis->num_parents,
					       asso_lis->parents,
					       NULL_GRID,ND_NEW),
                targetid =  my_id);
	__CheckRC( 1, status, "NDnode.NDconnect", wrapup );

	return OM_S_SUCCESS;

wrapup:
	return status ;
}

end implementation VRconc;
