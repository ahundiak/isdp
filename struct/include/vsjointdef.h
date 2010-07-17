/* $Id: vsjointdef.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/include/vsjointdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsjointdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.4  1998/04/02  10:41:16  pinnacle
 * Replaced: include/vsjointdef.h for:  by svkadamb for struct
 *
 * Revision 1.3  1997/12/18  13:34:04  pinnacle
 * Replaced: include/vsjointdef.h for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/20  12:40:48  pinnacle
 * Replaced: include/vsjointdef.h for:  by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
#ifndef vsjointdef_include
#define vsjointdef_include

/*
 * Joining action after a division of a feature into sub-features (results of
 * the division).
 * VS_K_DO_NOT_JOIN		  : do not join sub-features.
 * VS_K_JOIN_RESULTS_TOGETHER     : place joint between sub-features.
 * VS_K_JOIN_RESULTS_WITH_DIVISOR : place joint between each sub-feature and
 *				    the feature use to perform the division.
 */
#define VS_K_JOIN_RESULTS_TOGETHER	0
#define VS_K_JOIN_RESULTS_WITH_DIVISOR	1
#define VS_K_DO_NOT_JOIN		2

/*
 * Junction type.
 * VS_K_J_PL_PL : plate-plate
 * VS_K_J_BM_BM : beam-beam
 * VS_K_J_PL_BM	: plate-beam
 * VS_K_J_BM_PL : beam-plate (functionally equivalent to plate-beam)
 * VS_K_J_ST_TP : stiffener with its support plate, stiffener being on top.
 * VS_K_J_ST_BT : stiffener with its support plate, stiffener being on bottom.
 * VS_K_J_TP_ST : same as VS_K_J_ST_TP but plate-stiffener.
 * VS_K_J_BT_ST : same as VS_K_J_ST_BT but plate-stiffener.
 */
#define VS_K_J_PL_PL	0
#define VS_K_J_BM_BM	1
#define VS_K_J_PL_BM	2
#define VS_K_J_BM_PL	3
#define VS_K_J_ST_TP	4
#define VS_K_J_ST_BT	5
#define VS_K_J_TP_ST	6
#define VS_K_J_BT_ST	7

/*
 * Trial flags for joint search between surfaces.
 */
#define VS_K_TRY_EDGE_EDGE	0
#define VS_K_TRY_EDGE_SF	1

#define VS_K_NO_OVERLAP		0
#define VS_K_COMMON_PORTION	1
#define VS_K_0_COVERS_1		2
#define VS_K_1_COVERS_0		3
#define VS_K_TOTAL_MATCH	4

/*
 * Base name of active collection of user attributes for joints.
 */
#	define VS_K_jointUA		"jointUA"

/*
 * Name of parent features of joints.
 */
#	define VS_K_jnFeature0		"feature0"
#	define VS_K_jnFeature1		"feature1"
#	define VS_K_jnGeometry		"jnCurve"

/*
 * Name of parent joint of a modified joint.
 */
#	define VS_K_jnParentJn		"parentJn"

/*
 * Name of graphic component for all joints.
 */
#	define VS_K_jnGrCmpName		"joint"

/*
 * Name of construction bundling all components of a joint.
 */
#	define VS_K_jnJointGroup	"jointGroup"

/*
 * Maximum size of character string value of user symbol (including trailing
 * '\0' ).
 */
#define VS_K_MAXUSRSYMSZ	30

/*
 * Names of joint attributes.
 */
#	define	VS_K_jnWldCodAttr	"weldCode"	/* Weld code	*/
#	define	VS_K_jnWldPrcAttr	"weldProcess"	/* Weld process	*/
#	define	VS_K_jnWldInfAttr	"weldInfo"	/* Weld info	*/
#	define	VS_K_jnWldSidAttr	"weldSide"	/* Weld side	*/
#	define	VS_K_jnAllwncAttr	"allowance"
#	define	VS_K_jnGrvAngAttr	"grooveAngle"
#	define	VS_K_jnPitchAttr	"pitch"
#	define	VS_K_jnIncrLnAttr	"lengthOfIncr"
#	define	VS_K_jnUsrSymAttr	"usrSymbol"
#	define	VS_K_jnWldLenAttr	"weld_length"	/* Computed	*/
#	define  VS_K_jnWldSizAttr	"weld_size"	/* Weld size    */
#	define	VS_K_jnWldPosAttr	"weld_position"	/* Weld position*/
#	define	VS_K_jnShrnkAttr	"shrinkage"	/* Shrinkage	*/
#	define	VS_K_jnFieldWeld	"field_weld"	/* field weld 	*/
#	define	VS_K_jnWldCodeDesc	"weldcode_desc"
#	define	VS_K_jnWldProcDesc	"weldprocess_desc"
#	define	VS_K_jnWldSideDesc	"weldside_desc"	
#	define	VS_K_jnWldPosDesc	"weldposition_desc"

/* Attribute names defined for posting joint info into database */

#	define	VS_D_jnWldCodAttr	"weldcode"	/* Weld code	*/
#	define	VS_D_jnWldPrcAttr	"weldprocess"	/* Weld process	*/
#	define	VS_D_jnWldInfAttr	"weldinfo"	/* Weld info	*/
#	define	VS_D_jnWldSidAttr	"weldside"	/* Weld side	*/
#	define	VS_D_jnAllwncAttr	"weldsize"
#	define	VS_D_jnGrvAngAttr	"grooveangle"
#	define	VS_D_jnIncrLnAttr	"lengthofincr"
#	define	VS_D_jnUsrSymAttr	"usrsymbol"

/*
 * Indices of joint data in private collection.
 */
#	define VS_K_jnWeldAttr		0
#	define VS_K_jnAllowance		1
#	define VS_K_jnGrooveAngle	2
#	define VS_K_jnPitch		3
#	define VS_K_jnIncrLength	4
#	define VS_K_jnUsrSymbol		5
#	define VS_K_jnSize		6
#	define VS_K_jnShrinkage		7
#	define VS_K_jnAddWeldAttr	8
#	define VS_K_jnMAXDATA		9

/*
 * Surface or Edge match of the joint
 */
#define         SURF    1 	/* Joint matches with the surface of plate  */
#define         EDGE    2	/* Joint matches with the edge of the plate */

/*
 * different Joint type between the two plates
 */

#define         VS_K_SURF_SURF  1	/* Surface-Surface type */
#define         VS_K_SURF_EDGE  2	/* Surface-Edge	type    */
#define         VS_K_EDGE_SURF  3	/* Edge-Surface type    */
#define         VS_K_EDGE_EDGE  4	/* Edge-Edge type 	*/

#endif
