/* $Id: VDFncCpSurf.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdgraphics/func / VDFncCpSurf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDFncCpSurf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:50  cvs
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
  copy of ACcpxloc.I to modify the ACSget_cmp_leave function.
  Bruno Demars
  3-Oct-91
*/

class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "ex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"


#define AS_DEBUG

extern	OM_S_CHANSELECT 	AS_to_comp;

/* ****************** FCT VDGetNodes () **************************	*/

IGRint	VDcp_GetNodes (	msg,
			ind_cmp,
			list_len,
			cmp_list,
			nb_cmp,
			LeavesClassId )


IGRlong		*msg;	/* returns MSFAIL when the input object is a leave */
IGRint		ind_cmp;
IGRint		*list_len;
struct GRid	**cmp_list;
IGRint		*nb_cmp;
GRclassid	LeavesClassId;

/*.VDcp_GetNodes*/
{
IGRlong		sts;
OMuint		node_nb;
IGRint		i;
struct	GRid	COMP;
GRclassid	cid;
struct	GRid	CMP;
struct GRid	*LIST;
IGRint		j;


	*msg = MSFAIL;

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
		return OM_S_SUCCESS;		
	}

	if( node_nb == 0 )
	{
		/*" CMP : id/os = (%d/%d) is a leave \n", CMP.objid, CMP.osnum */
		return	OM_S_SUCCESS;
	}

	/* else go down in the graph */

	if( *list_len - *nb_cmp < node_nb ){

		*list_len += (node_nb + 20);

		/*" realloc the list : %d\n", list_len */
		LIST = (struct GRid *) realloc ( LIST, 
					sizeof( struct GRid ) * *list_len );
		if( LIST == NULL ){
			printf(" Error not enougth memory to reallocate LIST\n");
			*cmp_list = NULL;
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

return	OM_S_SUCCESS;
}


/******************************************************************************

		   return active display and level 

******************************************************************************/

VDcp_get_active_symb( level, display )

IGRshort 		*level;
struct 	IGRdisplay 	*display;
{
  IGRlong NumberOfBytes;
  IGRlong BytesReceived;
  IGRlong msg;
 
  /* get the default symbology data from the DPB */

  NumberOfBytes = sizeof( IGRshort );

  gr$get_active_level( msg    = &msg,
                       sizbuf = &NumberOfBytes,
                       buffer = level,
                       nret   = &BytesReceived);
  as$status( sts = msg, action = RET_STATUS );

  /* get the default display symbology data from the DPB */

  NumberOfBytes = sizeof( struct IGRdisplay );

  gr$get_active_display( msg    = &msg,
                         sizbuf = &NumberOfBytes,
                         buffer = display,
                         nret   = &BytesReceived);
  as$status( sts = msg, action = RET_STATUS );

  return( OM_S_SUCCESS );

}


end implementation Root;

