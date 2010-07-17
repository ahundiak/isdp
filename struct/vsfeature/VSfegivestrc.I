/* $Id: VSfegivestrc.I,v 1.1.1.1 2001/01/04 21:10:37 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsfeature/VSfegivestrc.I
 *
 * Description: Main struct give structure
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfegivestrc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/22  13:38:46  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/98  ah      Redirect control to VDSroot.ACgive_structure to allow
 *                   for standard vds processing (Before it went to ACncpx)      
 ***************************************************************************/

class implementation VSfeature ;

#include <string.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "vsRDBdef.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

#define EQ_STRING( s1, s2 ) !strcmp( (s1), (s2) )
#define XCOORD	0
#define YCOORD	1
#define ZCOORD	2
/*----------------------------------------------------------------------------*/
method	ACgive_structure(	int			*ok,
							*notUsed ;
				char			*attrName ;
				struct ret_struct	*attrVal ;
				struct GRmd_env		*myEnv ) {

	long		sts,		/* OM completion code		*/
			msg ;		/* Return status		*/
	VSintegral	myMP ;		/* My mass properties		*/
	VSpartAttr	myAttr ;	/* My part attributes		*/
	enum {
		getAttrStr,		/* Use GRvg.GRgetattr		*/
		getAttrDbl,
		getAttrInt,
		getMassProps,		/* Use VSgetMassProperties	*/
		getNothing,		/* Don't do anything		*/
		wrtMsg			/* Use ancestor's method	*/
	} msgType ;
	int		maxSize= 0,	/* Of string attribute		*/
			*frInt = NULL ;	/* Ptr to int    attribute	*/
	char		*frStr = NULL ;	/* Ptr to string attribute	*/
	double		*frDbl = NULL ;	/* Ptr to double attribute	*/

	/*
	 * Get value for "virtual foot".
	 * Note that strings are truncated to fit RDB's specification of
	 * character string sizes (size=1+length) as forced in `maxSize'.
	 */
	
	if( EQ_STRING( attrName, VS_K_prChgNumAttr ) ) {

		myAttr.Iwant 	= VS_m_ChgNum ;
		frInt		= &myAttr.mto.chgnum ;
		msgType		= getAttrInt ;

	} else if( EQ_STRING( attrName, VS_K_prFpThckAttr ) ) {

		myAttr.Iwant 	= VS_m_FpThck ;
		frDbl		= &myAttr.info.fpthickness ;
		msgType		= getAttrDbl ;

	} else if( EQ_STRING( attrName, VS_K_prMbrClsAttr ) ) {

		myAttr.Iwant 	= VS_m_MbrClass ;
		frInt		= &myAttr.info.memberClass ;
		msgType		= getAttrInt ;

	} else if( EQ_STRING( attrName, VS_K_prMbrTypAttr ) ) {

		myAttr.Iwant 	= VS_m_MbrType ;
		frInt		= &myAttr.info.memberType ;
		msgType		= getAttrInt ;

	} else if( EQ_STRING( attrName, VS_K_prMbrNamAttr ) ) {
		GRname	myFullName;
		int	truncated ;
		char	*p ;

		maxSize	= 1 + VS_K_rdbMbrNameLen ;
		msgType	= getNothing ;
	
		sts = om$send(	msg	= message GRgraphics.GRgetname(
							&msg, myFullName ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "GRgraphics.GRgetname", wrapup ) ;

		if( p = strrchr( myFullName, DIR_G_car_dir ) )
			p++ ;
		else	p = myFullName ;

		attrVal->type = text_type ;
		VSstrncpy(	attrVal->var.text_st.text_string,
				p,
				maxSize,
				&truncated )  ;

	} else if( EQ_STRING( attrName, VS_K_prPnlNamAttr ) ) {
		GRname	myFullName;
		int	truncated ;
		char	*p ;

		maxSize	= 1 + VS_K_rdbMbrNameLen ;
		msgType	= getNothing ;
	
		sts = om$send(	msg	= message GRgraphics.GRgetname(
							&msg, myFullName ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "GRgraphics.GRgetname", wrapup ) ;

		if( p = strrchr( myFullName, DIR_G_car_dir ) ) {
			*p = '\0' ;
			if( p = strrchr( myFullName, DIR_G_car_dir ) ) {
				*p = '\0' ;
				if( p = strrchr( myFullName, DIR_G_car_dir ) )
					p++ ;
			}
		}
		if( !p ) p = "" ;

		attrVal->type = text_type ;
		VSstrncpy(	attrVal->var.text_st.text_string,
				p,
				maxSize,
				&truncated )  ;

	} else if( EQ_STRING( attrName, VS_K_prPrtFamAttr ) ) {

		maxSize		= 1 + VS_K_rdbFamNameLen ;
		msgType		= getAttrStr ;
		myAttr.Iwant	= VS_m_PartFam ;
		frStr		= myAttr.info.family ;

	} else if(    EQ_STRING( attrName, VS_K_prPrtNumAttr )
		   || EQ_STRING( attrName, VS_K_prFPtNumAttr ) ) {

		maxSize		= 1 + VS_K_rdbPartNumLen ;
		msgType		= getAttrStr ;
		myAttr.Iwant	= VS_m_PartNum ;
		frStr		= myAttr.info.partNum ;

	} else if(    EQ_STRING( attrName, VS_K_prMatTypAttr )
		   || EQ_STRING( attrName, VS_K_prPrtRevAttr ) ) {

		maxSize		= 1 + VS_K_rdbMatNameLen ;
		msgType		= getAttrStr ;
		myAttr.Iwant	= VS_m_MatType ;
		frStr		= myAttr.info.material ;

	} else if( EQ_STRING( attrName, VS_K_prMatGrdAttr ) ) {

		maxSize		= 1 + VS_K_rdbGrdNameLen ;
		msgType		= getAttrStr ;
		myAttr.Iwant	= VS_m_MatGrade ;
		frStr		= myAttr.info.grade ;

	} else if( EQ_STRING( attrName, VS_K_prUsrNotAttr ) ) {

		maxSize		= sizeof attrVal->var.text_st.text_string ;
		msgType		= getAttrStr ;		
		myAttr.Iwant	= VS_m_Notes ;
		frStr		= myAttr.info.notes ;

	} else if( EQ_STRING( attrName, VS_K_prMTOSrcAttr ) ) {

		maxSize		= 1 + VS_K_rdbMTOSrceLen ;
		msgType		= getAttrStr ;		
		myAttr.Iwant	= VS_m_MtoSrc ;
		frStr		= myAttr.mto.source ;

	} else if( EQ_STRING( attrName, VS_K_prMTOStkAttr ) ) {

		maxSize		= 1 + VS_K_rdbMTOStckLen ;
		msgType		= getAttrStr ;		
		myAttr.Iwant	= VS_m_MtoStk ;
		frStr		= myAttr.mto.stock ;

	} else if( EQ_STRING( attrName, VS_K_prApprvlAttr ) ) {

		maxSize		= 1 + VS_K_rdbAppStatLen ;
		msgType		= getAttrStr ;		
		myAttr.Iwant	= VS_m_AppStat ;
		frStr		= myAttr.info.apprvstat ;

	} else if( EQ_STRING( attrName, VS_K_prConstrAttr ) ) {

		maxSize		= 1 + VS_K_rdbCstStatLen ;
		msgType		= getAttrStr ;		
		myAttr.Iwant	= VS_m_CstStat ;
		frStr		= myAttr.info.conststat ;

	} else if( EQ_STRING( attrName, VS_K_prVolumeAttr ) ) {

		frDbl	= &myMP.volume ;
		msgType	= getMassProps ;

	} else if( EQ_STRING( attrName, VS_K_prMassAttr ) ) {

		frDbl	= &myMP.mass ;
		msgType	= getMassProps ;

	} else if( EQ_STRING( attrName, VS_K_prSfAreaAttr ) ) {

		frDbl	= &myMP.area ;
		msgType	= getMassProps ;

	} else if( EQ_STRING( attrName, VS_K_prXGvCtrAttr ) ) {

		frDbl	= myMP.centroid + XCOORD ;
		msgType	= getMassProps ;

	} else if( EQ_STRING( attrName, VS_K_prYGvCtrAttr ) ) {

		frDbl	= myMP.centroid + YCOORD ;
		msgType	= getMassProps ;

	} else if( EQ_STRING( attrName, VS_K_prZGvCtrAttr ) ) {

		frDbl	= myMP.centroid + ZCOORD ;
		msgType	= getMassProps ;

	} else {
		struct GRid	usrAttr ;
		char		uattName[DI_PATH_MAX],
				membName[DI_PATH_MAX],
				*p ;

		if( p = strchr( attrName, DIR_G_car_dir ) ) {
			*p = '\0' ;
			strcpy( uattName, attrName ) ;
			strcpy( membName, p + 1 ) ;
			*p = DIR_G_car_dir ;
		} else {
			strcpy( uattName, attrName ) ;
			*membName = '\0' ;
		}

		if( *membName ) {
			/*
			 * Path given of type <name1>:<name2> then <name1>
			 * must be VS_K_prUsrAttr.
			 */
			if( !EQ_STRING( uattName, VS_K_prUsrAttr ) ) {
				msgType		= wrtMsg ;
				goto SWITCH ;
			}
		} else {
			/*
			 * Path given of type <name1>, we suppose it is a short
			 * cut to VS_K_prUsrAttr:<name1>.
			 */
			strcpy( membName, uattName ) ;
		}

		/*
		 * Is it a field of the collection of user attributes ?
		 */
		sts = om$send(	msg	= message VSfeature.VSgetUsrAttributes(
							&msg, &usrAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "VSfeature.VSgetUsrAttribute", wrapup ) ;

		if( IF_NULL_OBJID( usrAttr.objid ) ) {
			/*
			 * No user attributes. Attribute not recognized: use
			 * ancestor's method.
			 */
			msgType		= wrtMsg ;
		} else {
			if( *membName ) {
				sts = om$send(
					msg	= message NDmacro.ACgive_structure(
							ok, notUsed, membName,
							attrVal, myEnv ),
					targetid= usrAttr.objid,
					targetos= usrAttr.osnum ) ;
				msg = (*ok & 1) ? MSSUCC : MSFAIL ;
			} else {
				sts = om$send(
					msg	= message NDnode.NDgive_structure(
							&msg, attrVal, myEnv ),
					targetid= usrAttr.objid,
					targetos= usrAttr.osnum ) ;
			}
			if( sts & 1 & msg ) {
				/*
				 * Field was recognized by user collection.
				 */
				msgType		= getNothing ;
			} else {
				/*
				 * Field was not recognized by user collection,
				 * use ancestor's method.
				 */
				msgType		= wrtMsg ;
			}
		}
	}

	SWITCH :
	switch( msgType ) {

	  case getMassProps	:
		sts = om$send(	msg	= message VSpart.VSgetMassProperties(
							&msg, myEnv, &myMP ),
				targetid= my_id ) ;
		if( !( sts & 1 & msg ) ) {
			*frDbl = 0 ; sts = OM_S_SUCCESS ; msg = MSSUCC ;
		}
		attrVal->type			= double_type ;
		attrVal->var.root_pm_st.value	= *frDbl ;
		break ;

	  case getAttrStr		:
	  case getAttrDbl		:
	  case getAttrInt		:
		sts = om$send(	msg	= message GRvg.GRgetattr(
						&msg, (char *) &myAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "GRvg.GRgetattr", wrapup ) ;

		switch( msgType ) {
			int truncated ;

			case getAttrStr		:
				attrVal->type = text_type ;
				VSstrncpy(	attrVal->var.text_st.text_string,
						frStr,
						maxSize,
						&truncated ) ;
				break ;

			case getAttrDbl		:
				attrVal->type			= double_type ;
				attrVal->var.root_pm_st.value	= *frDbl ;
				break ;

			case getAttrInt		:
				attrVal->type			= double_type ;
				attrVal->var.root_pm_st.value	= *frInt ;
				break ;
		}

		break ;

	  case wrtMsg	:
	    // 22 Mar 1998 - ah - Used to pass to ACncpx
		sts = om$send(	msg	= message VDSroot.ACgive_structure(
								ok,
								notUsed,
								attrName,
								attrVal,
								myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		msg = (*ok & 1) ? MSSUCC : MSFAIL ;
		break ;

	  case getNothing: msg = MSSUCC ; sts = OM_S_SUCCESS ; break ;

	  default	 : msg = MSINARG ; sts = OM_E_INVARG ; break ;
	}
	
	wrapup :
		*ok = ( msg & 1 ) != 0 ;
		return sts ;

} /* method ACgive_structure */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

