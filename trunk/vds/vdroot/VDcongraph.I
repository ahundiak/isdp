/* $Id: VDcongraph.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDcongraph.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDcongraph.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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

class implementation VDSroot ;

#include "nd.h"

/*----------------------------------------------------------------------------*/
method NDconnect_graph( long			*msg ;
			int			cp_type ;
			struct GRmd_env 	*fr_env,
						*to_env ;
			struct NDcp_list	*copied_element ;
			int			copied_size ;
			int			nb_root,
						*root_index ;
			int			my_index ) {

	long		sts ;

	sts = om$send( msg	= message VDSroot.NDconnect_graph(
								 msg,
								 cp_type,
								 fr_env,
								 to_env,
								 copied_element,
								 copied_size,
								 nb_root,
								 root_index,
								 my_index ),
		       mode	= OM_e_wrt_parent,
		       targetid = my_id ) ;

	if( ( sts & 1 & *msg ) && cp_type == 0 ) {
		struct GRid object ;

		object.objid = copied_element[my_index].clone ;
		object.osnum = to_env->md_id.osnum ;

		sts = VDputSymbAndNameFromTransTable( msg, &object ) ;

		if( !( sts & 1 & *msg ) ) {
			printf( "Trans Table Error for [%d,%d]\n", object.osnum, object.objid ) ;

			sts  = OM_S_SUCCESS ;
			*msg = MSSUCC ;
		}
	}

	return sts ;

} /* NDconnect_graph */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
