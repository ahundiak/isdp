/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACset_db_info(	long			*msg ;
			struct ACdb_info	*dbInfo ; ) {

	long			sts,		/* OM return code	*/
				VSrc ;		/* Self-explanatory	*/

	/*
	 * Traverse the graph up through all the consumed parts till you
	 * find a source part.
	 */
	sts = om$send(	msg	= message VSfeature.VSsendToEveryoneUp(
					&VSrc, OM_e_wrt_message, OPPmargs ),
			targetid= my_id ) ;

	return sts ;

} /* method ACset_db_info */
/*----------------------------------------------------------------------------*/
method ACget_db_info(	long			*msg ;
			struct ACdb_info	*dbInfo ; ) {

	long			sts,		/* OM return code	*/
				VSrc ;		/* Self-explanatory	*/

	*dbInfo->catalog	= *dbInfo->part_num	= *dbInfo->revision
				= *dbInfo->usage	= '\0' ;
	/*
	 * Traverse the graph up through all the consumed parts till you
	 * find a source part.
	 */
	*msg = MSFAIL ;
	sts = om$send(	msg 	= message VSfeature.VSforwardToOriginal(
					&VSrc,
					OM_e_wrt_message,
					message ACdb_info.ACget_db_info(
								 msg, dbInfo )),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;

	dbInfo->serial_no = my_id ;

	wrapup : return sts ;

} /* method ACget_db_info */
/*----------------------------------------------------------------------------*/
method ACcheckin_candidate( int CheckinType, *p_CheckinCandidate ) {

	long	msg,
		sts ;
	int	consumed ;

	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &msg ),
			targetid= my_id ) ;
	consumed = msg & 1 ;

	*p_CheckinCandidate = consumed ? FALSE : TRUE ;

	return sts ;

} /* method ACcheckin_candidate */
/*----------------------------------------------------------------------------*/
method ACadd_to_list_1( struct ACobj_info_1 *p_obj_info ; int size, *p_count ) {

	long		sts ;
	int		amIcandidate ;
	struct GRid	moi ;

	moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;

	sts = om$send(	msg	= message ACdb_info.ACcheckin_candidate(
							0, &amIcandidate ),
			targetid= my_id ) ;
	if( !( sts & 1 ) || !amIcandidate ) goto wrapup ;

	if( p_obj_info && *p_count < size ) {

		long			msg ;
		int			serial_no,
					quantity ;
		struct ACdb_info	dbInfo ;

		sts = om$send(	msg	= message ACdb_info.ACget_db_info(
								&msg, &dbInfo ),
				targetid= my_id ) ;
		serial_no = sts & 1 & msg ? dbInfo.serial_no : -1 ;
		quantity  = dbInfo.quantity ;

		p_obj_info[*p_count].obj	= moi ;
		p_obj_info[*p_count].serial_no	= serial_no ;
		p_obj_info[*p_count].quantity	= quantity ;
		(*p_count)++ ;
	} else {
		(*p_count)++ ;
	}
	wrapup :
		return OM_S_SUCCESS ;
	
} /* method ACadd_to_list_1 */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
