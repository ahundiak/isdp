/* $Id: VSqryRdbCmdi.I,v 1.1.1.1 2001/01/04 21:10:30 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmdsup/VSqryRdbCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSqryRdbCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:30  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/11/02  17:21:34  pinnacle
# Cache Fixes
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/02/97  ah      added header
 *                        Cache was having a problem when the part name
 *                        contained blanks, fixed this and made the cache
 *                        persistant.  Added VS_NO_LOGIN_CHECK=1 env var
 ***************************************************************************/

class implementation VSqryRdbCmd ;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "vscmddef.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsRISmacros.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"
#include "vsgrenvproto.h"
#include "vsstrngproto.h"

extern long	VSrdbCacheLs() ;
extern long	VSrdbCacheMkpath() ;
extern long	VSrdbCacheGetValue() ;

#define STRNCPY( To, From )\
	strncpy( (To), (From), VS_K_MAXDBNAME-1 )[VS_K_MAXDBNAME-1] = '\0'
/*----------------------------------------------------------------------------*/
method setQueryType( long *msg ; int qyType ) {

	switch( qyType ) {
		case VS_K_BEAM_QY  :
		case VS_K_PLATE_QY : me->queryType = qyType ;
				     *msg = MSSUCC ;
				     break ;
		default		   : *msg = MSSUCC ;
				     break ;
	}
	return OM_S_SUCCESS ;

} /* method setQueryType */
/*----------------------------------------------------------------------------*/
method initRDBdata() {

	me->matCount	= me->grdCount = me->famCount
			= me->prtCount = me->parCount = 0 ;

	me->matList	= me->grdList = me->famList
			= me->prtList = me->parList = me->namValList = NULL ;

	me->matIndex	= me->grdIndex= me->famIndex= me->prtIndex = 0 ;
	me->savMatIx	= me->savGrdIx= me->savFamIx= me->savPrtIx = 0 ;

	me->parVal	= NULL ;

	*me->actMat	= *me->actGrd	= *me->actFam = *me->actPrt = '\0' ;
	*me->savMat	= *me->savGrd	= *me->savFam = *me->savPrt = '\0' ;

	me->loadedMask	= 0 ;

	return OM_S_SUCCESS ;

} /* method initRDBdata */
/*----------------------------------------------------------------------------*/
method freeRDBdata() {

	VSfreeList( me->matCount, me->matList	   ) ;
	VSfreeList( me->grdCount, me->grdList	   ) ;
	VSfreeList( me->famCount, me->famList	   ) ;
	VSfreeList( me->prtCount, me->prtList	   ) ;
	VSfreeList( me->parCount, me->parList 	   ) ;
	VSfreeList( me->parCount, me->namValList   ) ;
	_FREE( me->parVal ) ;

	om$send(msg	= message VSqryRdbCmd.initRDBdata(),
		targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method freeRDBdata */
/*----------------------------------------------------------------------------*/
/*
 * 11/02/97 Art Hundiak
 * Add env var check to allow overriding
 * for quicker debugging.
 * Persistant cache allows placing and modifying struct
 * items without logging in to pdm
 */
method verifyLogin( long *msg ) {

  IGRchar *str = NULL;

  str = getenv("VS_NO_LOGIN_CHECK");
  if ((str != NULL) && (*str == '1')) {
    *msg = MSSUCC;
  }
  else *msg = VSisLoggedIntoRDB() ? MSSUCC : MSFAIL ;
  return OM_S_SUCCESS ;

} /* method verifyLogin */
/*----------------------------------------------------------------------------*/
method setActiveItems( char *mat, *grd, *fam, *prt ) {

	long	sts = OM_S_SUCCESS ;
	int	index ;

	if( mat ) {
		if( *mat && ( me->loadedMask & VS_m_mat_from_RDB ) ) {
			VSfind_string_in_list(	mat,
						me->matList,
						me->matCount,
						&index ) ;
			if( index == -1 ) {
				index	= 0 ;
				sts	= OM_I_NOMATCH ;
			}
			mat = me->matList[index] ;
		} else {
			index = 0 ;
		}
		me->matIndex = index ;
		STRNCPY( me->actMat, mat ) ;
	}
	if( grd ) {
		if( *grd && ( me->loadedMask & VS_m_grd_from_RDB ) ) {
			VSfind_string_in_list(	grd,
						me->grdList,
						me->grdCount,
						&index ) ;
			if( index == -1 ) {
				index	= 0 ;
				sts	= OM_I_NOMATCH ;
			}
			grd = me->grdList[index] ;
		} else {
			index = 0 ;
		}
		me->grdIndex = index ;
		STRNCPY( me->actGrd, grd ) ;
	}
	if( fam ) {
		if( *fam && ( me->loadedMask & VS_m_fam_from_RDB ) ) {
			VSfind_string_in_list(	fam,
						me->famList,
						me->famCount,
						&index ) ;
			if( index == -1 ) {
				index	= 0 ;
				sts	= OM_I_NOMATCH ;
			}
			fam = me->famList[index] ;
		} else {
			index = 0 ;
		}
		me->famIndex = index ;
		STRNCPY( me->actFam, fam ) ;
	}
	if( prt ) {
		if( *prt && ( me->loadedMask & VS_m_prt_from_RDB ) ) {
			VSfind_string_in_list(	prt,
						me->prtList,
						me->prtCount,
						&index ) ;
			if( index == -1 ) {
				index	= 0 ;
				sts	= OM_I_NOMATCH ;
			}
			prt = me->prtList[index] ;
		} else {
			index = 0 ;
		}
		me->prtIndex = index ;
		STRNCPY( me->actPrt, prt ) ;
	}

	if( prt && ( me->loadedMask & VS_m_par_from_RDB ) && me->parVal ) {
		/*
		 * Active thickness for plates.
		 */
		me->actPar = me->parVal[me->prtIndex] ;
	}
	return sts ;
	
} /* method setActiveItems */
/*----------------------------------------------------------------------------*/
method saveActiveItems() {

		me->savMatIx = me->matIndex ;
		me->savGrdIx = me->grdIndex ;
		me->savFamIx = me->famIndex ;
		me->savPrtIx = me->prtIndex ;

		strcpy( me->savMat, me->actMat ) ;
		strcpy( me->savGrd, me->actGrd ) ;
		strcpy( me->savFam, me->actFam ) ;
		strcpy( me->savPrt, me->actPrt ) ;

		me->savPar = me->actPar ;

		return OM_S_SUCCESS ;

} /* method saveActiveItems */
/*----------------------------------------------------------------------------*/
method restoreActiveItems() {

		me->matIndex = me->savMatIx ;
		me->grdIndex = me->savGrdIx ;
		me->famIndex = me->savFamIx ;
		me->prtIndex = me->savPrtIx ;

		strcpy( me->actMat, me->savMat ) ;
		strcpy( me->actGrd, me->savGrd ) ;
		strcpy( me->actFam, me->savFam ) ;
		strcpy( me->actPrt, me->savPrt ) ;

		me->actPar = me->savPar ;

		return OM_S_SUCCESS ;

} /* method restoreActiveItems */
/*----------------------------------------------------------------------------*/
method loadMaterials( long *msg ; char *errStr ) {

	/*
	 * Retrieve the materials from the RDB.
	 */
	int	row ;		/* Row index in associated list	*/
	char	**list ;	/* List of materials		*/

	*errStr = '\0' ;

	/*
	 * Free previous data.
	 */
	VSfreeList( me->matCount, me->matList ) ;
	me->matCount = 0 ; me->matList = NULL ;

	if( ( VSrdbCacheLs( VS_K_RDBtmp, NULL, &row, &list ) & 1 ) && row ) {
		me->matCount	= row ;
		me->matList	= list ;
	} else {
		/*
		 * Cache empty: query RDB.
		 */
		ex$message(	msgnumb		= VS_gI_QyRdbMat,
				justification	= CENTER_JUS,
				field		= KEYIN_FIELD ) ;
		ex$message(	msgnumb		= VS_gI_Processing,
				justification	= CENTER_JUS ) ;

		vs$extract_materials_from_RDB(	msg		= msg,
						errStr		= errStr,
						p_count		= &me->matCount,
						p_materials	= &list ) ;
		

		if( !( *msg & 1 ) ) {
			ex$message(	in_buff		= errStr,
					justification	= CENTER_JUS,
					field		= ERROR_FIELD ) ;
			VS_Wait_timer( 60 ) ;
			goto wrapup ;
		}
		me->matList = list ;
		/*
		 * Fill cache.
		 */
		for( row = 0 ; row < me->matCount ; row++ ) {
			VSrdbCacheMkpath( VS_K_RDBtmp, me->matList[row], NULL );
		}
	}

	me->loadedMask |= VS_m_mat_from_RDB ;

	if( *me->actMat ) {
		VSfind_string_in_list(	me->actMat, me->matList,
					me->matCount, &me->matIndex ) ;
		if( me->matIndex == -1 ) me->matIndex = 0 ;
	} else {
		me->matIndex = 0 ;
	}
	STRNCPY( me->actMat, me->matList[me->matIndex] ) ;

	*msg = MSSUCC ;

	wrapup :
		ex$message(	field	= KEYIN_FIELD,
				in_buff	= "" ) ;
		ex$message( 	field 	= ERROR_FIELD,
				in_buff	= "" ) ;

		return OM_S_SUCCESS ;

} /* method loadMaterials */
/*----------------------------------------------------------------------------*/
method loadGrades( long *msg ; char *errStr ) {

	/*
	 * Retrieves the grades from the RDB.
	 * Materials must have been loaded prior to this method.
	 */
	int	row,		/* Row index in associated list	*/
		i ;
	char	**list ;	/* List of grades		*/

	*errStr = '\0' ;

	/*
	 * Free previous list of grades.
	 */
	VSfreeList( me->grdCount, me->grdList ) ;
	me->grdCount = 0 ; me->grdList = NULL ;

	if( ( VSrdbCacheLs( VS_K_RDBtmp, me->actMat, "grade",
				NULL, &row, &list ) & 1 ) && row ) {
		me->grdCount	= row ;
		me->grdList	= list ;
	} else {
		ex$message(	msgnumb		= VS_gI_QyRdbGrd,
				justification	= CENTER_JUS,
				field		= KEYIN_FIELD ) ;
		ex$message(	msgnumb       = VS_gI_Processing,
			    	justification = CENTER_JUS ) ; 

		vs$extract_grades_from_RDB(
					msg		= msg,
					errStr		= errStr,
					material	= me->actMat,
					p_count		= &me->grdCount,
					p_grades	= &list ) ;
		
		if( !( *msg & 1 ) ) {
			ex$message(	in_buff		= errStr,
					justification	= CENTER_JUS,
					field		= ERROR_FIELD ) ;
			VS_Wait_timer( 60 ) ;
			goto wrapup ;
		}
		me->grdList = list ; list = NULL ;

		/*
		 * Fill cache.
		 */
		if(   ( VSrdbCacheLs( VS_K_RDBtmp, NULL, &row, &list ) & 1 )
		    && row ) {

			for( i = 0 ; i < me->grdCount ; i++ ) {
				VSrdbCacheMkpath(	VS_K_RDBtmp,
							me->actMat,
							"grade",
							me->grdList[i],
							NULL ) ;
			}
			VSfreeList( row, list ) ;
		}
	}

	me->loadedMask |= VS_m_grd_from_RDB ;

	if( *me->actGrd ) { 
		VSfind_string_in_list(	me->actGrd, me->grdList,
					me->grdCount, &me->grdIndex ) ;
		if( me->grdIndex == -1 ) me->grdIndex = 0 ;
	} else {
		me->grdIndex = 0 ;
	}
	STRNCPY( me->actGrd, me->grdList[me->grdIndex] ) ;

	*msg = MSSUCC ;

	wrapup :
		ex$message(	field	= KEYIN_FIELD,
				in_buff	= "" ) ;
		ex$message( 	field 	= ERROR_FIELD,
				in_buff	= "" ) ;
	
		return OM_S_SUCCESS ;

} /* method loadGrades */
/*----------------------------------------------------------------------------*/
method loadFamilies( long *msg ; char *errStr ) {

	/*
	 * Retrieves the families from the RDB.
	 * Materials must have been loaded prior to this method.
	 */

	int	row,		/* Row index in associated list	*/
		i ;
	char	**list,		/* List of families		*/
		*cacheDir ;

	*errStr = '\0' ;

	switch( me->queryType ) {
		case VS_K_BEAM_QY	: cacheDir = "beam" 	; break ;
		case VS_K_PLATE_QY	: cacheDir = "plate"	; break ;
		default			: *msg = MSINARG	; goto wrapup ;
	}
	/*
	 * Free previous list of families.
	 */
	VSfreeList( me->famCount, me->famList ) ;
	me->famCount = 0 ; me->famList = NULL ;

	if( ( VSrdbCacheLs( VS_K_RDBtmp, me->actMat, cacheDir,
				NULL, &row, &list ) & 1 ) && row ) {
		me->famCount	= row ;
		me->famList	= list ;
	} else {
		long	m = me->queryType == VS_K_BEAM_QY ? VS_gI_QyRdbBTy
							  : VS_gI_QyRdbPTy ;
		ex$message(	msgnumb		= m,
				justification	= CENTER_JUS,
				field		= KEYIN_FIELD ) ;
		ex$message(	msgnumb       = VS_gI_Processing,
				justification = CENTER_JUS ) ;

		if( me->queryType == VS_K_BEAM_QY ) {
			vs$extract_shapes_from_RDB(
						msg		= msg,
						errStr		= errStr,
						material	= me->actMat,
						p_count		= &me->famCount,
						p_shapes	= &list ) ;
		} else {
			vs$extract_plates_from_RDB(
						msg		= msg,
						errStr		= errStr,
						material	= me->actMat,
						p_count		= &me->famCount,
						p_plates	= &list ) ;
		}

		if( (*msg & 1) && !me->famCount ) {
			ex$message(	msgnumb		= VS_gW_NoFamilies,
					type		= "%s",
					var		= me->actMat,
					buff		= errStr ) ;
			*msg = MSFAIL ;
		}
		if( !( *msg & 1 ) ) {
			ex$message(	in_buff		= errStr,
					justification	= CENTER_JUS,
					field		= ERROR_FIELD ) ;
			VS_Wait_timer( 60 ) ;
			goto wrapup ;
		}

		me->famList = list ; list = NULL ;

		/*
		 * Fill cache.
		 */
		if(   ( VSrdbCacheLs( VS_K_RDBtmp, NULL, &row, &list ) & 1 )
		    && row  )  {
		
			for( i = 0 ; i < me->famCount ; i++ ) {
				VSrdbCacheMkpath(	VS_K_RDBtmp,
							me->actMat,
							cacheDir,
							me->famList[i],
							NULL ) ;
			}
			VSfreeList( row, list ) ;

		}
	}

	me->loadedMask |= VS_m_fam_from_RDB ;

	if( *me->actFam ) {
		VSfind_string_in_list(	me->actFam, me->famList,
					me->famCount, &me->famIndex ) ;
		if( me->famIndex == -1 ) me->famIndex = 0 ;
	} else {
		me->famIndex = 0 ;
	}
	STRNCPY( me->actFam, me->famList[me->famIndex] ) ;

	*msg = MSSUCC ;

	wrapup :
		ex$message( field = KEYIN_FIELD, in_buff = "" ) ;
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		return OM_S_SUCCESS ;

} /* method loadFamilies */
/*----------------------------------------------------------------------------*/
method loadParts( long *msg ; char *errStr ) {

	/*
	 * Retrieves the parts from the RDB.
	 * Materials and families must have been loaded prior to this
	 * method.
	 */

	int	row,		/* Row index in associated list	*/
		i ;
	char	**list,		/* List of parts		*/
		*cacheDir ;

	*errStr = '\0' ;

	switch( me->queryType ) {
		case VS_K_BEAM_QY	: cacheDir = "beam" 	; break ;
		case VS_K_PLATE_QY	: cacheDir = "plate"	; break ;
		default			: *msg = MSINARG	; goto wrapup ;
	}
	/*
	 * Free previous parts.
	 */
	VSfreeList( me->prtCount, me->prtList ) ;
	me->prtCount = 0 ; me->prtList = NULL ;

	if( ( VSrdbCacheLs( VS_K_RDBtmp, me->actMat, cacheDir,
				me->actFam, NULL, &row, &list ) & 1 ) && row ) {
		me->prtCount	= row ;
		me->prtList	= list ;

	} else {
		long	m = me->queryType == VS_K_BEAM_QY ? VS_gI_QyRdbSec
							  : VS_gI_QyRdbThk ;

		ex$message(	msgnumb		= m,
				justification	= CENTER_JUS,
				field		= KEYIN_FIELD ) ;
		ex$message(	msgnumb       = VS_gI_Processing,
				justification = CENTER_JUS ) ;

		vs$extract_parts_from_RDB(
					msg		= msg,
					errStr		= errStr,
					material	= me->actMat,
                        	        family	 	= me->actFam,
					p_count		= &me->prtCount,
					p_parts 	= &list ) ;

		if( (*msg & 1) && !me->prtCount ) {
			ex$message(	msgnumb		= VS_gW_NoParts,
					type		= "%s%s",
					var		= `me->actMat,me->actFam`,
					buff		= errStr ) ;
			*msg		= MSFAIL ;
		}
		if( !( *msg & 1 ) ) {
			ex$message(	in_buff		= errStr,
					justification	= CENTER_JUS,
					field		= ERROR_FIELD ) ;
			VS_Wait_timer( 60 ) ;
			goto wrapup ;
		}
		me->prtList = list ; list = NULL ;

		/*
		 * Fill cache.
		 */
		if(   ( VSrdbCacheLs( VS_K_RDBtmp, me->actMat,
				    cacheDir, NULL, &row, &list ) & 1 )
		    && row ) {
		
			for( i = 0 ; i < me->prtCount ; i++ ) {
				VSrdbCacheMkpath(	VS_K_RDBtmp,
							me->actMat,
							cacheDir,
							me->actFam,
							me->prtList[i],
							NULL ) ;
			}
			VSfreeList( row, list ) ;
		}
	}

	me->loadedMask |= VS_m_prt_from_RDB ;

	if( *me->actPrt ) {
		VSfind_string_in_list(	me->actPrt, me->prtList,
					me->prtCount, &me->prtIndex ) ;
		if( me->prtIndex == -1 ) me->prtIndex = 0 ;
	} else {
		me->prtIndex = 0 ;
	}
	STRNCPY( me->actPrt, me->prtList[me->prtIndex] ) ;

	*msg = MSSUCC ;

	wrapup :
		ex$message( field = KEYIN_FIELD, in_buff = "" ) ;
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		return OM_S_SUCCESS ;

} /* method loadParts */
/*----------------------------------------------------------------------------*/
method loadParms( long *msg ; char *errStr ) {

	/*
	 * Retrieves the active profile's parameters from RDB.
	 * Materials, beam families and parts must have been loaded prior to
	 * this method.
	 *
	 * Argument me->parList[i] contains the name of the profile parameter. 
	 * Argument me->parVal[i]  contains the value of the profile parameter.
	 * Argument me->namValList[i] contains the parameter name and value of
	 * the profile like this :
	 *
	 *	me->namValList[i] = "me->parList[i] = me->parVal[i]"
	 *
	 * Note : if the sub-directory ":transient:struct" doesn't exist, the
	 * sub-directory corresponding to the section parameter will not create.
	 */

	int	row,		/* Row index in associated list	*/
		i ;
	char	**list,		/* List of profile parameters	*/
		*cacheDir,
		buf[100] ;
	double	*List = NULL ;

	*errStr = '\0' ;

	switch( me->queryType ) {
		case VS_K_BEAM_QY	: cacheDir = "beam" 	; break ;
		case VS_K_PLATE_QY	:
		default			: *msg = MSINARG	; goto wrapup ;
	}

	/*
	 * Free previous values.
	 */
	VSfreeList( me->parCount, me->parList ) ;
	VSfreeList( me->parCount, me->namValList ) ;
	_FREE( me->parVal ) ;
	me->parCount = 0 ; me->parList = me->namValList = NULL ;
	me->parVal = NULL ;

	if(    ( VSrdbCacheLs( VS_K_RDBtmp, me->actMat, cacheDir,
			    me->actFam, me->actPrt, NULL, &row, &list ) & 1 )
	    && row ) {

		me->parCount	= row ;
		me->parList	= list ;

		if( !( me->parVal = _MALLOC( row, double ) ) ) {
			*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
		}

		for( i = 0 ; i < row ; i++ ) {
			VSrdbCacheGetValue(	VS_K_RDBtmp,
						me->actMat,
						cacheDir,
						me->actFam,
						me->actPrt,
 						NULL,
						me->parList[i],
						me->parVal + i ) ;
		}		

	} else {
		ex$message(	msgnumb		= VS_gI_QyRdbPar,
				justification	= CENTER_JUS,
				field		= KEYIN_FIELD ) ;
		ex$message(	msgnumb		= VS_gI_Processing,
				justification	= CENTER_JUS ) ;

		vs$extract_parms_from_RDB( msg		= msg,
					   errStr	= errStr,
					   material	= me->actMat,
					   family	= me->actFam,
					   part		= me->actPrt,
					   p_count	= &me->parCount,
				  	   p_names	= &list,
				  	   p_values	= &List ) ;

		if( !( *msg & 1 ) ) {
			ex$message(	in_buff		= errStr,
					justification	= CENTER_JUS,
					field		= ERROR_FIELD ) ;
			VS_Wait_timer( 60 ) ;
			goto wrapup ;
		}
		me->parList	= list ; list = NULL ;
		me->parVal	= List ; List = NULL ;

		/*
		 * Fill cache.
		 */
		if(    ( VSrdbCacheLs( VS_K_RDBtmp, me->actMat,
				    cacheDir, NULL, &row, &list ) & 1 )
		    && row ) {
		
			for( i = 0 ; i < me->parCount ; i++ ) {
	
				VSrdbCachePutValue(	VS_K_RDBtmp,
							me->actMat,
							cacheDir,
							me->actFam,
							me->actPrt,
							NULL,
							me->parList[i],
							me->parVal + i ) ;

			}
			VSfreeList( row, list ) ;

		}
	}

	me->namValList = _CALLOC( me->parCount, char * ) ;
			
	for( row = 0 ; row < me->parCount ; row++ ) {

		sprintf( buf, "%s = %g", me->parList[row], me->parVal[row] ) ;

		me->namValList[row] = VSstrdup( buf ) ;
	}

	*msg = MSSUCC ;

	me->loadedMask |= VS_m_par_from_RDB ;

	wrapup :
		ex$message( field = KEYIN_FIELD, in_buff = "" ) ;
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		return OM_S_SUCCESS ;

} /* method loadParms */
/*----------------------------------------------------------------------------*/
/* 
 * 11/02/97 Art Hundiak
 * Changed the query to get both n_itemname as well as thickness
 * Then match n_itemname against parts already loaded to assign
 * them a thickness.
 *
 * This eliminates a previous dependency which relied on two sep queries
 * (one for items and one for thickensss) always returning records
 * in the same order.
 */
method loadThkVals( long *msg ; char *errStr ) {

	/*
	 * Retrieve the thicknesses of plates from RDB.
	 * Materials, families and parts must have been loaded prior to this
	 * method.
	 */
	int	row,		/* Row index in associated list	*/
		i,j,		/* Must redisplay prompt ?	*/
		mustLoad ;
	char	**list,		/* List of thicknesses		*/
		*cacheDir,
		where[100] ;
	
	*errStr = '\0' ;

	if( !(    me->loadedMask
	       & (   VS_m_mat_from_RDB
	           | VS_m_fam_from_RDB
	           | VS_m_prt_from_RDB ) ) ) {
		*msg = MSFAIL ; goto wrapup ;
	}

	switch( me->queryType ) {
		case VS_K_PLATE_QY	: cacheDir = "plate" 	; break ;
		case VS_K_BEAM_QY	:
		default			: *msg = MSINARG	; goto wrapup ;
	}

	/*
	 * Free previous values.
	 */
	_FREE( me->parVal ) ; me->parVal = NULL ; me->parCount = 0 ;

	me->parCount = me->prtCount ;
	if( !( me->parVal = _CALLOC( me->parCount, double ) ) ) {
		*msg = EMS_E_NoDynamicMemory ;
		me->parCount = 0 ;
		goto wrapup ;
	}

	mustLoad = FALSE ;

	row = me->parCount ;

	for( i = 0 ; i < row ; i++ ) {
		if( ! ( VSrdbCacheGetValue(	VS_K_RDBtmp,
						me->actMat,
						cacheDir,
						me->actFam,
						me->prtList[i],
						NULL,
						"thickness",
						me->parVal + i ) & 1 ) ) {
			mustLoad = TRUE ;
			break ;
		}
	}

	if( !mustLoad ) {
		me->actPar = me->parVal[me->prtIndex] ;
		me->loadedMask |= VS_m_par_from_RDB ;

		*msg = MSSUCC ; goto wrapup ;
	}

	ex$message(	msgnumb		= VS_gI_QyRdbThk,
			justification	= CENTER_JUS,
			field		= KEYIN_FIELD ) ;
	ex$message(	msgnumb		= VS_gI_Processing,
			justification	= CENTER_JUS ) ;

	/*
	 * Query for thicknesses :
	 * SELECT	thickness
	 * FROM		<family>
	 * WHERE	p_revision="<material>"
	 */
	sprintf( where, "%s='%s'", PDU_REVISION_ATTR, me->actMat ) ;

	*msg = vs$RISquery(	table	= me->actFam,
				select	= "n_itemname,thickness",
				where	= where,
				p_count	= &row,
                                nbAttrs = 2,
				p_list	= &list ) ;

	if( !*msg ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyThkFailed,
					type	= "%s%s",
					var	= `me->actMat,me->actFam`,
					buff	= errStr ) ;
		}
	} else if(row == 0) {

/*
printf("ERROR: %d thickness values returned for %d items in %s\n",
  row,me->parCount,me->actFam);
printf("Might have duplicate rows in the family database table.\n");
*/
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoThicknesses,
					type	= "%s%s",
					var	= `me->actMat,me->actFam`,
					buff	= errStr ) ;

		}
		if( row ) VSfreeList( row * 2, list ) ;
	}

	if( !( *msg & 1 ) ) {
		ex$message(	in_buff		= errStr,
				justification	= CENTER_JUS,
				field		= ERROR_FIELD ) ;
		VS_Wait_timer( 60 ) ;
		goto wrapup ;
	}

/* Xfer over values, matching up part names */
  for(i = 0; i < row; i++) {

    for(j = 0; 
       (j < me->prtCount) && (strcmp(list[(i*2)+0],me->prtList[j]));
        j++);

    if (j < me->prtCount) me->parVal[j] = atof(list[(i*2)+1]);
  }

  VSfreeList( row * 2, list ) ;

	/*
	 * Fill cache.
	 */
	if(    ( VSrdbCacheLs( VS_K_RDBtmp, me->actMat, 
				    cacheDir, NULL, &row, &list ) & 1 )
	     && row ) {
		
		for( i = 0 ; i < me->parCount ; i++ ) {

			VSrdbCachePutValue(	VS_K_RDBtmp,
						me->actMat,
						cacheDir,
						me->actFam,
						me->prtList[i],
						NULL,
						"thickness",
						me->parVal + i ) ;
		}
		VSfreeList( row, list ) ;

	}

	me->actPar = me->parVal[me->prtIndex] ;

	*msg = MSSUCC ;

	me->loadedMask |= VS_m_par_from_RDB ;

	wrapup :
		ex$message( field = KEYIN_FIELD, in_buff = "" ) ;
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		return OM_S_SUCCESS ;

} /* method loadThkVals */
/*----------------------------------------------------------------------------*/
method loadAny( long *msg ; char *errStr ; int action, *executed ) {

	int	A,
		force ;
	int	matIndex = 0,
		grdIndex = 0,
		famIndex = 0,
		prtIndex = 0,
		matCount = 0,
		grdCount = 0,
		famCount = 0,
		prtCount = 0,
		parCount = 0 ;
	char	**matList	= NULL,
		**grdList	= NULL,
		**famList	= NULL,
		**prtList	= NULL,
		**namValList	= NULL,
		**parList	= NULL,
		actMat[VS_K_MAXDBNAME],
		actGrd[VS_K_MAXDBNAME],
		actFam[VS_K_MAXDBNAME],
		actPrt[VS_K_MAXDBNAME] ;
		
	double	*parVal	= NULL,
		actPar	= 0. ;

	*msg = MSSUCC ;

	A = action ;

	if( A & VS_m_tot ) {
		A = VS_m_mat | VS_m_grd | VS_m_fam | VS_m_prt | VS_m_par ;
	}

	force = A & VS_m_force ;
	if( ( me->loadedMask & VS_m_mat_from_RDB ) && !force ) {
		A &= ~VS_m_mat ;
	}
	if( ( me->loadedMask & VS_m_grd_from_RDB ) && !force ) {
		A &= ~VS_m_grd ;
	}
	if( ( me->loadedMask & VS_m_fam_from_RDB ) && !force ) {
		A &= ~VS_m_fam ;
	}
	if( ( me->loadedMask & VS_m_prt_from_RDB ) && !force ) {
		A &= ~VS_m_prt ;
	}
	if( ( me->loadedMask & VS_m_par_from_RDB ) && !force ) {
		A &= ~VS_m_par ;
	}

	if( me->queryType == VS_K_PLATE_QY && ( A & VS_m_prt ) ) {
		A |= VS_m_par ;
	}

	/*
	 * Save all previous data.
	 */
	if( A & VS_m_mat ) {
		matIndex	= me->matIndex ;
		matCount	= me->matCount ;
		matList		= me->matList ;
		strcpy( actMat, me->actMat ) ;

		me->matList	= NULL ;
		me->matCount	= 0 ;
	}

	if( A & VS_m_grd ) {
		grdIndex	= me->grdIndex ;
		grdCount	= me->grdCount ;
		grdList		= me->grdList ;
		strcpy( actGrd, me->actGrd ) ;

		me->grdList	= NULL ;
		me->grdCount	= 0 ;
	}

	if( A & VS_m_fam ) {
		famIndex	= me->famIndex ;
		famCount	= me->famCount ;
		famList		= me->famList ;
		strcpy( actFam, me->actFam ) ;

		me->famList	= NULL ;
		me->famCount	= 0 ;
	}

	if( A & VS_m_prt ) {
		prtIndex	= me->prtIndex ;
		prtCount	= me->prtCount ;
		prtList		= me->prtList ;
		strcpy( actPrt, me->actPrt ) ;

		me->prtList	= NULL ;
		me->prtCount	= 0 ;
	}

	if( A & VS_m_par ) {
		namValList	= me->namValList ;
		parList		= me->parList ;
		parVal		= me->parVal ;
		parCount	= me->parCount ;
		actPar		= me->actPar ;

		me->namValList	= NULL ;
		me->parList	= NULL ;
		me->parVal	= NULL ;
		me->parCount	= 0 ;
	}

	if( A & VS_m_mat ) {
		om$send(msg	= message VSqryRdbCmd.loadMaterials(
							msg, errStr ),
			targetid= my_id ) ;
	}

	if( ( A & VS_m_grd ) && ( *msg & 1 ) ) {
		om$send(msg	= message VSqryRdbCmd.loadGrades(
							msg, errStr ),
			targetid= my_id ) ;
	}
	
	if( ( A & VS_m_fam ) && ( *msg & 1 ) ) {
		om$send(msg	= message VSqryRdbCmd.loadFamilies(
							msg, errStr ),
			targetid= my_id ) ;
	}
	
	if( ( A & VS_m_prt ) && ( *msg & 1 ) ) {
		om$send(msg	= message VSqryRdbCmd.loadParts(
							msg, errStr ),
			targetid= my_id ) ;
	}
	
	if( ( A & VS_m_par ) && ( *msg & 1 ) ) {
		if( me->queryType == VS_K_BEAM_QY ) {
			om$send(msg	= message VSqryRdbCmd.loadParms(
							msg, errStr ),
				targetid= my_id ) ;
		} else {
			om$send(msg	= message VSqryRdbCmd.loadThkVals(
							msg, errStr ),
				targetid= my_id ) ;
		}
	}	

	if( !( *msg & 1 ) ) {
		/*
		 * Free RDB-related instance data and roll back former data.
		 */
		if( A & VS_m_mat ) {
			VSfreeList( me->matCount, me->matList ) ;
			me->matIndex	= matIndex ;
			me->matCount	= matCount ;
			me->matList	= matList ;
			strcpy( me->actMat, actMat ) ;
			me->loadedMask &= ~VS_m_mat_from_RDB ;
		}
		
		if( A & VS_m_grd ) {
			VSfreeList( me->grdCount, me->grdList ) ;
			me->grdIndex	= grdIndex ;
			me->grdCount	= grdCount ;
			me->grdList	= grdList ;
			strcpy( me->actGrd, actGrd ) ;
			me->loadedMask &= ~VS_m_grd_from_RDB ;
		}

		if( A & VS_m_fam ) {
			VSfreeList( me->famCount, me->famList ) ;
			me->famIndex	= famIndex ;
			me->famCount	= famCount ;
			me->famList	= famList ;
			strcpy( me->actFam, actFam ) ;
			me->loadedMask &= ~VS_m_fam_from_RDB ;
		}

		if( A & VS_m_prt ) {
			VSfreeList( me->prtCount, me->prtList ) ;
			me->prtIndex	= prtIndex ;
			me->prtCount	= prtCount ;
			me->prtList	= prtList ;
			strcpy( me->actPrt, actPrt ) ;
			me->loadedMask &= ~VS_m_prt_from_RDB ;
		}

		if( A & VS_m_par ) {
			VSfreeList( me->parCount, me->namValList ) ;
			VSfreeList( me->parCount, me->parList ) ;
			me->parCount	= parCount ;
			me->namValList	= namValList ;
			me->parList	= parList ;
			me->parVal	= parVal ;
			me->actPar	= actPar ;
			me->loadedMask &= ~VS_m_par_from_RDB ;
		}
	} else {
		/*
		 * Free roll-back data.
		 */
		if( A & VS_m_mat ) {
			VSfreeList( matCount, matList ) ;
		}
		if( A & VS_m_grd ) {
			VSfreeList( grdCount, grdList ) ;
		}
		if( A & VS_m_fam ) {
			VSfreeList( famCount, famList ) ;
		}
		if( A & VS_m_prt ) {
			VSfreeList( prtCount, prtList ) ;
		}
		if( A & VS_m_par ) {
			VSfreeList( parCount, namValList ) ;
			VSfreeList( parCount, parList ) ;
			_FREE( parVal ) ;
		}
	}

	*executed = *msg & 1 ? A : 0 ;

	return OM_S_SUCCESS ;

} /* method loadAny */
/*----------------------------------------------------------------------------*/

end implementation VSqryRdbCmd ;
