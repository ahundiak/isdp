/* $Id: VSbpcnst2Drp.I,v 1.2 2001/01/16 23:59:49 ramarao Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsplate/VSbpcnst2Drp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSbpcnst2Drp.I,v $
 *  Revision 1.2  2001/01/16 23:59:49  ramarao
 *  *** empty log message ***
 *
# Revision 1.6  2000/05/15  14:51:36  pinnacle
# Replaced: struct/vsplate/VSbpcnst2Drp.I for:  by rchennup for Service Pack
#
# Revision 1.5  2000/05/05  13:57:38  pinnacle
# Replaced: struct/vsplate/VSbpcnst2Drp.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/05/04  13:28:00  pinnacle
# Replaced: struct/vsplate/VSbpcnst2Drp.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/04/28  18:56:44  pinnacle
# Replaced: struct/vsplate/VSbpcnst2Drp.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/12  13:43:06  pinnacle
# Created: struct/vsplate/VSbpcnst2Drp.I by mdong for Service Pack
#
# Revision 1.2  2000/02/18  14:03:16  pinnacle
# Replaced: vsplate/VSbpcnst2Drp.I for:  by impd252 for struct
#
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 *      02/18/00    adz       	Migrate on plate failed. TR #179701926
 *	04/11/00    Ming	Modified for cmd Process Cutouts
 *      04/28/00    Jayadev     Modified for TR179901213 and TR179901271
 *      05/15/00    Jayadev     Modified for TR179901014 - redundant graphics
 ***************************************************************************/
class implementation VSbooPlate ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "EMSsffmacros.h"
/*----------------------------------------------------------------------------*/
method VSconstruct_2D_rep(	long			*msg ;
				int			optrCount ;
				struct GRobj_env	optrList[],
							*operand ;
				struct GRvg_construct	*resCst ;
				struct GRid		*result ) {

#define MAX VS_K_MAX_BOUNDARIES

	long			sts,sts1;	/* OM return code	*/
	struct GRlc_info 	oprndInfo,	/* Operand info		*/
			 	oprtrinfo ;	/* Info of one operator	*/
	struct GRid		*interList ;	/* List of intersections*/
	struct GRobj_env	bndryList[MAX] ;/* Total list of inters.*/
	int			interCount,	/* Count of inters.	*/
				bndryCount,	/* Total count of intrs.*/
				i,		/* Loop index		*/
				j ;		/* Loop index		*/
	struct GRmd_env		*cstEnv ;	/* Unburdens compiler	*/

	SetProc( VSbooPlate_VSconstruct_2D_rep ); Begin

	result->objid	= NULL_OBJID ;
	cstEnv		= resCst->env_info ;
	bndryCount	= 0 ;
	for( i = 0 ; i < MAX ; i++ ) bndryList[i]._objid = NULL_OBJID ;

	oprndInfo.located_obj = operand->_grid ;
	oprndInfo.module_info = operand->mod_env ;

	/*
	 * Set the result equal to the input. This to ensure that the 
	 * system will return any graphics when one of the operands fail.
	 */
	*result = operand->_grid ;

	for( i = 0 ; i < optrCount ; i++ ) {

		interList = NULL ;
		bndryCount = 0 ;
		/* Added by Ming */
		interCount = 0 ;

		oprtrinfo.located_obj = optrList[i]._grid ;
		oprtrinfo.module_info = optrList[i].mod_env ;
		sts = EMintersect_two_element(	&oprndInfo,
						&oprtrinfo,
						TRUE,
						resCst,
						&interCount,
						&interList,
						msg ) ;
		// __CheckRC( sts, *msg, "EMintersect_two_element", wrapup ) ;
		if( (!(sts & *msg & 1)) || ( ! interCount ) ){
			/*
			 * We skip invalid input object to avoid no construction 			 * of consumed 2D graphics of plates.
			 */
			printf("Warning compute 2D construction failed partial %d, %d \n",OM_Gw_current_OS, my_id);
			sts1 = OM_W_ABORT;
		// clean up before continue - TR179901014
			for( j = 0 ; j < interCount ; j++ ) {

				bndryList[bndryCount  ]._grid   = interList[j] ;
				bndryList[bndryCount++].mod_env	= *cstEnv ;
			}
			vs$bulk_delete(	count	= bndryCount,
					objenvs = bndryList ) ;
			continue ;
		}

		if( interCount < MAX ) {
			
			for( j = 0 ; j < interCount ; j++ ) {

				bndryList[bndryCount  ]._grid   = interList[j] ;
				bndryList[bndryCount++].mod_env	= *cstEnv ;
			}
		} else {
			/*
			 * Overflow: delete intersections.
			 */
			vs$bulk_delete(	count	= interCount,
					grids	= interList,
					theEnv	= cstEnv ) ;
			/*
			 * Will get us out of the loop.
			 */
			i = optrCount ;
		}
		if( interCount ) {
			_FREE( interList ) ; interList = NULL ; interCount = 0 ;
		}

		/*
		 * perform the impose boundary directly.
		 */
		sts = vs$imposeBoundaries(	msg		= msg,
						surface		= operand,
						bndryCount	= bndryCount,
						bndryList	= bndryList ) ;
		//__CheckRC( sts, *msg, "vs$imposeBoundaries", wrapup ) ;
		if (!(sts & *msg & 1)){
			printf("Warning compute impose 2D construction failed partial %d, %d \n",OM_Gw_current_OS, my_id);
			continue ;
		}

		vs$bulk_delete(	count	= bndryCount,
				objenvs = bndryList ) ;

		bndryCount = 0 ;

		*result = operand->_grid ;
	}

	wrapup :
		/*
		 * Delete boundaries. Even when the process failed.
		 */
		if( bndryCount )
			vs$bulk_delete(	count	= bndryCount,
					objenvs = bndryList ) ;
	// this bad status will retain the parent output
	if(!(sts1&1)) sts = OM_W_ABORT;
	End
	return sts ;

} /* method VSconstruct_2D_rep */
/*----------------------------------------------------------------------------*/

end implementation VSbooPlate ;


