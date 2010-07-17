/* $Id: VSbmdbintrfc.I,v 1.3 2001/03/07 01:35:59 ad Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbeam/VSbmdbintrfc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbmdbintrfc.I,v $
 *	Revision 1.3  2001/03/07 01:35:59  ad
 *	void crash on end_treats attribute
 *	
 *	Revision 1.2  2001/03/01 19:39:42  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:11  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1997/02/04  19:40:54  pinnacle
# Replaced: vsbeam/VSbmdbintrfc.I for:  by s241_int for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/04/97	adz		end_treatment macros for AVD do
 *					have VSselector information
 *	03/06/01	adz		Fix crash on 'end_treats'
 *
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vssectiondef.h"
#include "vsxsfrpldef.h"
#include "vsxsfrpl.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern int	VSisBeamComposite() ;
extern long	VSfindEndTreatments() ;
extern long	VSfindEndTreatmentsInfo() ;
extern long	VSgive_db_structureForBeamFrPlates() ;

/*----------------------------------------------------------------------------*/

method ACadd_to_list_1( struct ACobj_info_1 *p_obj_info ; int size, *p_count ) {

	long			sts,
				msg ;
	struct ACdb_info	dbInfo ;
	struct GRid		moi ;
	int			amIcandidate,
				i,
				n ;

	sts = om$send(	msg	= message ACdb_info.ACcheckin_candidate(
							0, &amIcandidate ),
			targetid= my_id ) ;
	if( !( sts & 1 ) || !amIcandidate ) goto wrapup ;

	moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;

	if( VSisBeamComposite( &moi ) ) {

		struct GRid	profileDef ;/* Profile definition	*/
		VSxsFrPlsAttr	prflAttr ;  /* Attributes of profile	*/

		sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
							&msg, &profileDef ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "VSbeam.VSgetProfileDef", wrapup ) ;

		memset( (char *) &prflAttr, 0, sizeof prflAttr ) ;
		sts = om$send(	msg	= message GRvg.GRgetattr(
						&msg, (char *) &prflAttr ),
				targetid= profileDef.objid,
				targetos= profileDef.osnum ) ;
		__CheckRC( sts, msg, "GRvg.GRgetattr", wrapup ) ;

		n = prflAttr.plCount ;
	} else {
		n = 1 ;
	}

	if( p_obj_info ) {

		int	serial_no,
			quantity ;

		sts = om$send(	msg	= message ACdb_info.ACget_db_info(
								&msg, &dbInfo ),
				targetid= my_id ) ;
		serial_no = sts & 1 & msg ? dbInfo.serial_no : -1 ;
		quantity  = dbInfo.quantity ;

		for( i = 0 ; i < n ; i++ ) {

			if( *p_count >= size ) break ; 

			p_obj_info[*p_count].obj	= moi ;
			p_obj_info[*p_count].serial_no	= serial_no ;
			p_obj_info[*p_count].quantity	= quantity ;
			(*p_count)++ ;
		}

	} else {
		*p_count += n ;
	}

	wrapup :
		return OM_S_SUCCESS ;
	
} /* method ACadd_to_list_1 */
/*----------------------------------------------------------------------------*/
method ACgive_db_structure(	int			*ok,
							*notUsed ;
				char			*keyWord ;
				struct ret_struct	*attr ;
				struct GRmd_env		*myEnv ) {
	long		sts,
			msg ;
	char		*et = NULL ;
	struct GRid	moi ;
	GRname		et0,
			et1 ;

	SetProc( VSbeam_ACgive_db_structure ); Begin

	moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;

	__DBGpr_str( " keyWord ", keyWord );

	if( VSisBeamComposite( &moi ) ) {
		GRname	nameOfAttr ;
		int	index ;

		*ok = FALSE ;

		__DBGpr_com( " VSisBeamComposite OK " );

		/*
		 * In this case, `keyWord' is in the form
		 * "<index of plate>:<nameOfAttr>"
		 * Should it not be so, then use the regular process as for
		 * non-composite beams.
		 */
		if( sscanf( keyWord, "%d:%s", &index, nameOfAttr ) ) {

			sts = VSgive_db_structureForBeamFrPlates(
							&msg,
							&moi,
							myEnv,
							index,
							nameOfAttr,
							attr ) ;
			__CheckRC( sts, msg, "VSgive_db_structureForBeamFrPlates",
				   wrapup ) ;

			if( !strcmp( nameOfAttr, VS_K_prMbrNamAttr ) ) {
				char	*s = attr->var.text_st.text_string ;
				sprintf( s + strlen( s ), "_plate%d", index ) ;
			}
			*ok = TRUE ;
			goto wrapup ;
		} /* else regular process performed below */
	}

	/*
	 * Check for the end-treatment related information.
	 *
	 * - end_treatment0	macro_name of side 0 
	 * - end_treatinfo0	attribute value of macro of side 0
	 * - end_treatment1	macro_name of side 1
	 * - end_treatinfo1	attribute value of macro of side 1
	 * - end_treat0		macro_name and attribute of macro of side 0
	 * - end_treat1		macro_name and attribute of macro of side 1
	 * - end_treats		macro_name and attribute of both macros
	 *
	 * Return format
	 *	end_treat0   :macro_name0:attr_value0
	 *	end_treat1   :macro_name1:attr_value1
	 *	end_treats   :macro_name0:attr_value0:macro_name1:attr_value1
	 */

	et0[0] = '\0' ;
	et1[0] = '\0' ;

	et = NULL ;

		if( !strcmp( keyWord, VS_K_bmEndTreatment0 ) ) et     = et0 ;
	else	if( !strcmp( keyWord, VS_K_bmEndTreatment1 ) ) et     = et1 ;

	if( et ) {

		struct GRid	moi ;

		__DBGpr_str(" Check for End Treatments", keyWord );

		moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;
		__DBGpr_obj(" Looking VS_K_bmEndTreatment ", moi );

		sts = VSfindEndTreatments( &msg, &moi, myEnv, et0, et1 ) ;
		if( !( sts & 1 & msg ) ) *et = '\0' ;

		attr->type = text_type ;
		__DBGpr_str(" et ", et );
		strcpy( attr->var.text_st.text_string, et ) ;

		*ok = TRUE ; sts = OM_S_SUCCESS ;
		
		goto wrapup ;
	}

	et = NULL ;

		if( !strcmp( keyWord, VS_K_bmEndTreatInfo0 ) ) et = et0 ;
	else	if( !strcmp( keyWord, VS_K_bmEndTreatInfo1 ) ) et = et1 ;
	if( et ) {

		struct GRid	moi ;

		__DBGpr_str(" Check for End Treatments Info", keyWord );
		moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;
		__DBGpr_obj(" Looking VS_K_bmEndTreatInfo ", moi );

		sts = VSfindEndTreatmentsInfo( &msg, &moi, myEnv, 
							et0, et1, FALSE ) ;
		if( !( sts & 1 & msg ) ) *et = '\0' ;

		attr->type = text_type ;
		__DBGpr_str(" etInfo ", et );
		strcpy( attr->var.text_st.text_string, et ) ;

		*ok = TRUE ; sts = OM_S_SUCCESS ;

		goto wrapup ;
	}

	et = NULL ;

		if( !strcmp( keyWord, VS_K_bmEndTreat0 ) ) et = et0 ;
	else	if( !strcmp( keyWord, VS_K_bmEndTreat1 ) ) et = et1 ;

	if( et ) {

		struct GRid	moi ;

		__DBGpr_str(" Check for End Treatments Data", keyWord );

		moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;
		__DBGpr_obj(" Looking VS_K_bmEndTreatInfo ", moi );

		sts = VSfindEndTreatmentsInfo( &msg, &moi, myEnv, 
							et0, et1, TRUE ) ;
		if( !( sts & 1 & msg ) ) *et = '\0' ;

		attr->type = text_type ;
		__DBGpr_str(" etInfo ", et );
		strcpy( attr->var.text_st.text_string, et ) ;

		*ok = TRUE ; sts = OM_S_SUCCESS ;

		goto wrapup ;
	}

	et = NULL ;

	if( !strcmp( keyWord, VS_K_bmEndTreats ) ){

		struct GRid	moi ;

		__DBGpr_str(" Check for End Treats Data", keyWord );

		moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;

		__DBGpr_obj(" Looking VS_K_bmEndTreatInfo ", moi );

		sts = VSfindEndTreatmentsInfo( &msg, &moi, myEnv, 
							et0, et1, TRUE ) ;
		if( !( sts & 1 & msg ) ) {
			et0[0] = '\0' ;
			et1[0] = '\0' ;
		}

		attr->type = text_type ;
		sprintf(attr->var.text_st.text_string, "%s%s", et0, et1 ) ;

		__DBGpr_str(" etInfo ", attr->var.text_st.text_string );

		*ok = TRUE ; sts = OM_S_SUCCESS ;

		goto wrapup ;
	}

	__DBGpr_com(" Looking the default option " );

	sts = om$send(	msg	= message VSfeature.ACgive_db_structure(
							ok,
							notUsed,
							keyWord,
							attr,
							myEnv ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	wrapup :
		End
		return sts ;

} /* method ACgive_db_structure */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
