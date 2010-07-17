/*
	I/STRUCT
*/
#include "msdef.h"
#include "vsRDBdef.h"
#include "vsglobalmsg.h"
/*----------------------------------------------------------------------------*/
long VSgetMbrPlateTypesFromRDB( msg, errStr, typeList, keyList )

/*
 * This function is interfaced by macro vs$getMbrPlateTypesFromRDB.
 */
long	*msg,
	keyList[VS_rdb_MAXPLTYPES] ;
char	*errStr ;
int	typeList[VS_rdb_MAXPLTYPES] ; {

	typeList[0] = VS_rdb_plUNDEFINED ; keyList[0] = VS_gI_rdbUNDEFINED ;
	typeList[1] = VS_rdb_plSOLID	 ; keyList[1] = VS_gI_plSOLID	  ;
	typeList[2] = VS_rdb_plCLAD	 ; keyList[2] = VS_gI_plCLAD	  ;
	typeList[3] = VS_rdb_plCOATED	 ; keyList[3] = VS_gI_plCOATED	  ;
	typeList[4] = VS_rdb_plOTHER	 ; keyList[4] = VS_gI_rdbOTHER	  ;

	*msg = MSSUCC ;
	if( errStr ) *errStr = '\0' ;

	return *msg & 1 ;

} /* VSgetMbrPlateTypesFromRDB */
/*----------------------------------------------------------------------------*/
long VSgetMbrBeamTypesFromRDB( msg, errStr, typeList, keyList )

/*
 * This function is interfaced by macro vs$getMbrBeamTypesFromRDB.
 */
long	*msg,
	keyList[VS_rdb_MAXBMTYPES] ;
char	*errStr ;
int	typeList[VS_rdb_MAXBMTYPES] ; {

	typeList[0] = VS_rdb_bmUNDEFINED ; keyList[0] = VS_gI_rdbUNDEFINED ;
	typeList[1] = VS_rdb_bmBEAM	 ; keyList[1] = VS_gI_bmBEAM	  ;
	typeList[2] = VS_rdb_bmCOLUMN	 ; keyList[2] = VS_gI_bmCOLUMN	  ;
	typeList[3] = VS_rdb_bmBRACE	 ; keyList[3] = VS_gI_bmBRACE	  ;
	typeList[4] = VS_rdb_bmOTHER	 ; keyList[4] = VS_gI_rdbOTHER	  ;

	*msg = MSSUCC ;
	if( errStr ) *errStr = '\0' ;

	return *msg & 1 ;

} /* VSgetMbrBeamTypesFromRDB */
/*----------------------------------------------------------------------------*/

