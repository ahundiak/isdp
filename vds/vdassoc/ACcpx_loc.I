/* $Id: ACcpx_loc.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ACcpx_loc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACcpx_loc.I,v $
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

/*
  ACcpxi.I
  ludovic le corvec
  7-jan-91
*/

class implementation ACcpx;

#define AS_DEBUG

#include "asbox.h"
#include "AS_status.h"

#define	ACS_CMP_LEAVE	0x3

extern	GUprocessplot();

/* ********************** MSG GRlocate () *****************************	*/

method GRlocate( struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key )

{
IGRlong		sts;
OMuint		nb_foot;
OMuint		i;
IGRint		j;
OM_S_OBJID	*cmp_list;
IGRint		list_len;
IGRint		nb_cmp;
IGRint		resp;
IGRshort	loc_os;


	/*| initialization */
	cmp_list	= NULL;

	if( cvl->attributes.type == GR_nam_loc ){

		/*| loacate obj by name */
		sts = om$send(	msg	= message ASnode.GRlocate
					( cvl, range_key ),
				mode	= OM_e_wrt_message,
				targetid = my_id );
		as$status( sts = sts );

	} else {

		sts = om$get_channel_count(	objid	= my_id,
						p_chanselect = &AS_to_comp,
						count	= &nb_foot );
		as$status( sts = sts );
		/*" nb_foot : %d\n", nb_foot */

		/*| allocation of array of cmp */
		list_len = nb_foot + 20;
		cmp_list = (OM_S_OBJID *) malloc( 
				sizeof( OM_S_OBJID ) * list_len );
		if( cmp_list == NULL ){
			printf(" Error not enougth memory to allocate cmp\n");
			return 	OM_E_ABORT;
		}

		for( i=0; i<nb_foot; i++ ){
 
			sts = om$get_objid_at_index(	
					p_chanselect	= &AS_to_comp,
					object		= me,
					index		= i,
					objidaddr	= &cmp_list[0],
					osnumaddr	= (OMuword *)&loc_os );
			as$status( sts = sts );
			/*" cmp_list : id = %d\n", cmp_list[0] */

			nb_cmp = 1;

			for( j=0; j<nb_cmp; j++ ){

				resp = ACSget_cmp_leave(	loc_os,
								j, 
								&list_len, 
								&cmp_list, 
								&nb_cmp );
				if( ! resp ){
					printf(" Error in fct ACSget_cmp_leave\n");
					return	OM_E_ABORT;
				}

				if( resp == ACS_CMP_LEAVE ){

					sts = om$send(	msg	= message 
							GRgraphics.GRlocate 
								( cvl, range_key ),
							targetid = cmp_list[j] );
/* Fix for the error messages displayed on the screen : there may
   be some objects which may not understand this message : Manyam 
						as$status( sts = sts );*/
					if( sts == OM_I_STOP_SENDING )	goto wrapup;
				}
			}/*end for*/
		}/*end for*/
	  }/*end else*/

wrapup :

	/*| free memory */
	if( cmp_list != NULL )	free( cmp_list );

return	sts;
}


end implementation ACcpx;

