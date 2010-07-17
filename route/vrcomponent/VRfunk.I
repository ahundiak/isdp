/* $Id: VRfunk.I,v 1.3 2001/02/20 01:12:45 build Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrcomponent/VRfunk.I
 *
 * Description:
 * Dependencies:
 *
 * Log History:
 *      $Log: VRfunk.I,v $
 *      Revision 1.3  2001/02/20 01:12:45  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/12 15:38:01  anand
 *      SP merge
 *
# Revision 1.1  2000/05/23  17:26:54  pinnacle
# Created: route/vrcomponent/VRfunk.I by lawaddel for Service Pack
#
# Revision 1.2  2000/01/04  15:13:08  pinnacle
# Replaced: vrcomponent/VRfunk.I for:  by lawaddel for route
#
 *
 * History:
 *	01/04/00	law	TR179801414 -fix compile error,add file header
 ***********************************************************************/
/*
  copy of ACcpxloc.I to modify the ACSget_cmp_leave function.
  Bruno Demars
  3-Oct-91
*/

class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include <stdio.h> /* included in TR179801414 fixes */
#include "msdef.h"
#include "AS_status.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"

#define AS_DEBUG

extern	OM_S_CHANSELECT 	AS_to_comp;

/* ****************** FCT VRGetNodes () **************************	*/

IGRint	VRGetNodes ( msg, ind_cmp, list_len, cmp_list, nb_cmp, LeavesClassId )

IGRlong		*msg;	/* returns MSFAIL when the input object is a leave */
IGRint		ind_cmp;
IGRint		*list_len;
struct GRid	**cmp_list;
IGRint		*nb_cmp;
GRclassid	LeavesClassId;

/*.VRGetNodes*/
{
IGRlong		sts;
IGRuint		node_nb;
IGRint		i;
struct	GRid	COMP;
GRclassid	cid;
struct	GRid	CMP;
struct GRid	*LIST;
IGRint		j;

	SetProc( Root_VRGetNodes ); Begin

	*msg = MSFAIL;

	if( ind_cmp > *list_len-1 )
	{
		*msg = MSSUCC;
		End
		return OM_S_SUCCESS;		
	}

	/*| initialization */
	LIST	= *cmp_list;
	CMP	= LIST[ind_cmp];

	/*| test start_id */
	node_nb	= 0;
	sts = om$get_channel_count(	osnum		= CMP.osnum,
					objid		= CMP.objid,
					p_chanselect	= &AS_to_comp,
					count		= &node_nb );

	/*" node_nb : %d\n", node_nb */

	sts = om$get_classid(	osnum		= CMP.osnum,
				objid		= CMP.objid,
				p_classid	= &cid );
	as$status( sts = sts );

	/*" Object class = %d checked against %d\n",cid,LeavesClassId */

	if ( 	om$is_ancestry_valid( 	subclassid	= cid,
					superclassid	= LeavesClassId ) 
		== OM_S_SUCCESS )
	{
		*msg = MSSUCC;
		End
		return OM_S_SUCCESS;		
	}

	if( node_nb == 0 )
	{
		__DBGpr_obj(" CMP ", CMP );
		End
		return	OM_S_SUCCESS;
	}

	/* else go down in the graph */

	if( *list_len - *nb_cmp < node_nb ){

		*list_len += (node_nb + 20);

		/*" realloc the list : %d\n", list_len */
		LIST = _REALLOC( LIST, *list_len, struct GRid ); 
		if( LIST == NULL ){
			printf("ERROR not enougth memory to reallocate LIST\n");
			*cmp_list = NULL;
			*list_len = 0 ;
			End
			return	OM_E_NODYNMEM;
		}
	}

	for( i=0; i<node_nb; i++ ){

		sts = om$get_objid_at_index(	osnum	= CMP.osnum,
						objid	= CMP.objid,
						p_chanselect	= &AS_to_comp,
						index		= i,
						objidaddr	= &COMP.objid,
						osnumaddr	= &COMP.osnum );
		as$status( sts = sts );

		/* verify that COMP is not already in the list */
		for( j=0; j<*nb_cmp; j++ )
			if( LIST[j].objid == COMP.objid )	break;

		/* if index = max => COMP is not already in the list */
		if( j == *nb_cmp ){

			LIST[*nb_cmp]	= COMP;
			*nb_cmp +=1;
		}

	}/*end i*/

	*cmp_list = LIST;
	End
	return	OM_S_SUCCESS;
}

end implementation Root;

