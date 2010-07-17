/*
	I/STRUCT
*/
#include "msdef.h"
#include "vsRDBdef.h"
#include "vsglobalmsg.h"
/*----------------------------------------------------------------------------*/
long VSgetMbrClassesFromRDB( msg, errStr, clsList, keyList )

/*
 * This function is interfaced by macro vs$getMbrClassesFromRDB.
 */
long	*msg,
	keyList[VS_rdb_MAXCLASSES] ;
char	*errStr ;
int	clsList[VS_rdb_MAXCLASSES] ; {

	clsList[0] = VS_rdb_clUNDEFINED	; keyList[0] = VS_gI_rdbUNDEFINED ;
	clsList[1] = VS_rdb_clPRIMARY	; keyList[1] = VS_gI_clPRIMARY    ;
	clsList[2] = VS_rdb_clSECONDARY	; keyList[2] = VS_gI_clSECONDARY  ;
	clsList[3] = VS_rdb_clTERTIARY	; keyList[3] = VS_gI_clTERTIARY   ;
	clsList[4] = VS_rdb_clOTHER	; keyList[4] = VS_gI_rdbOTHER     ;
	clsList[5] = VS_rdb_clUSER_1	; keyList[5] = VS_gI_clUSER_1     ;
	clsList[6] = VS_rdb_clUSER_2	; keyList[6] = VS_gI_clUSER_2     ;
	clsList[7] = VS_rdb_clUSER_3	; keyList[7] = VS_gI_clUSER_3     ;
	clsList[8] = VS_rdb_clUSER_4	; keyList[8] = VS_gI_clUSER_4     ;
	clsList[9] = VS_rdb_clUSER_5	; keyList[9] = VS_gI_clUSER_5     ;

	*msg = MSSUCC ;
	if( errStr ) *errStr = '\0' ;

	return *msg & 1 ;

} /* VSgetMbrClassesFromRDB */
/*----------------------------------------------------------------------------*/
