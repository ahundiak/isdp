/* $Id: VDfndftinmc.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:   vds/vdmisc/VDfndftinmc.I
 *
 * Description:
 *	Given an macro object and a matching feetname, this function returns
 *	either all the feet objects matching to the feetname or all the
 *	feet names NOT matching to the feetname.
 *
 *	Matching criteria:
 *
 *
 *		 match flag      ASmatchRE	Take feet.
 *		------------------------------------------
 *     		 TRUE            TRUE            Yes
 *     		 TRUE            FALSE           continue ;
 *     		 FALSE           TRUE            continue ;
 *     		 FALSE           FALSE           Yes
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDfndftinmc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/09/04  16:07:26  pinnacle
# CR179701702: Add post placement of plates to structural detail macros; needed to add check for VSselector class
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/26  16:54:10  pinnacle
# Replaced: ./vdmisc/VDfndftinmc.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/04/06  13:42:52  pinnacle
# Replaced: vdmisc/VDfndftinmc.I by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/01/95   adz		creation date
 *	04/06/95   adz		Correction for nested calls.
 *	09/01/97   adz,ejm	CR179701702: Post placement of non-parametric
 *				plates. Check for VSselector class macro feet.
 ***************************************************************************/

class implementation ACncpx ;

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_getmacinfo.h"
#include "v_strngproto.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"

extern	OMuword		OPP_ci_macro_class_id ;
/* extern	OMuword		OPP_VSselector_class_id ; */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VD_findMatchFtNameSlSfInMacro(	msg,
					macId, macEnv,
					feetName,
					match,
					listOfSolSfs, 
				        countOfSolSfs )

long			*msg ;
struct GRid		*macId ;
struct GRmd_env		*macEnv ;
IGRchar			*feetName ;
IGRint			match ;			/* if match type	*/
struct GRobj_env	**listOfSolSfs ;
int			*countOfSolSfs ; {

	long			sts ;		/* OM return code	*/
	struct GRid		macroDef ;	/* Id of macro def	*/
	struct myfeet		*feetInfo ;	/* Names of feet	*/
	int			nbFeet,		/* Count of feet	*/
				i,		/* Loop index		*/
				ftIndex ;	/* For ACgive_structure	*/
	struct GRobj_env	ftId ;		/* Id of one foot	*/
	IGRmatrix		ftMx ;		/* Matrix of one foot	*/
	short			ftMxType ;	/* Type of the above	*/
	struct ret_struct	ftInfo ;	/* Info about one foot	*/
	struct GRobj_env	**ssList ;
	int			*ssCount,
				totCount;

	GRclassid		selector;       /* OMuword              */

	SetProc( VD_findMatchFtNameSlSfInMacro ); Begin

	*msg = MSSUCC ;

	*listOfSolSfs	= NULL ;
	*countOfSolSfs	= 0 ;
	ssList		= NULL ;
	ssCount		= NULL ;

	sts = om$send(	msg	= message ACcpx.find_macro( &macroDef ),
			senderid= NULL_OBJID,
			targetid= macId->objid,
			targetos= macId->osnum ) ;
	if( !( sts & 1 ) ) vd_$inv_arg() ;

	sts = VD_getMacroInformation(	msg,
					NULL,
					&macroDef,
					NULL,
					NULL,
					NULL,
					&nbFeet,
					&feetInfo,
					NULL ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( !( ssList = _MALLOC( nbFeet, struct GRobj_env * ) ) )
		vd_$mem_fail() ;
	if( !( ssCount= _MALLOC( nbFeet, int ) ) )
		vd_$mem_fail() ;

	__DBGpr_int(" --> match    ", match );
	__DBGpr_str(" --> feetName ", feetName );
	__DBGpr_int(" --> nbFeet   ", nbFeet );

	for( i = 0 ; i < nbFeet ; i++ ) {

		ssCount[i]	= 0 ;
		ssList[i]	= NULL ;
		ftIndex		= -1 ;

		__DBGpr_str(" --> Check feet ", feetInfo[i].name );

                __DBGpr_int(" --> Match Value",
                                ASmatchRE( feetName, feetInfo[i].name ) );

		sts = om$send(	msg	= message NDmacro.ACgive_structure(
							(int *) msg,
							&ftIndex,
							feetInfo[i].name,
							&ftInfo,
							macEnv ),
				senderid= NULL_OBJID,
				targetid= macId->objid,
				targetos= macId->osnum ) ;
		if( !( sts & 1 & *msg ) ){
			__DBGpr_com(" XXX FAILED ACgive_structure " );
			continue;
		}

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							feetInfo[i].name,
							&ftId._grid,
							&ftMxType,
							ftMx ),
				senderid= NULL_OBJID,
				targetid= macId->objid,
				targetos= macId->osnum ) ;
		if( !( sts & 1 & *msg ) ){
			__DBGpr_com(" XXX FAILED ACgive_structure " );
			continue;
		}

		ftId.mod_env.md_id = macEnv->md_id ;
		VD_mulmx( macEnv->_MATRIX, ftMx,
			 ftId._matrix, &ftId._matrix_type ) ;

		if( ftInfo.type & macro_generic ) {

		    /*
		     * Filter out the ci_macro subclass objects. These
		     * objects has own names which need to be checked and
		     * not there feetnames.
		     */

		    /* Added om$get_classid to avoid having to duplicate and  */
		    /* insert this file under Struct.                         */

		    sts = om$get_classid( classname = "VSselector",
					  p_classid = &selector );
                    if( sts&1 )
		    {
		      if( vd_$is_ancestry_valid( object	 = &ftId._grid,
				                 classid = selector )){

		        __DBGpr_str(" FOUND SELECTOR ", feetInfo[i].name );
		        if( 
			  !( match == ASmatchRE( feetName, feetInfo[i].name ))){
		   	  __DBGpr_str(" CANCELED ", feetInfo[i].name );
			  continue ;
		        }	

		        __DBGpr_str(" ACCEPTED ", feetInfo[i].name );
		        __DBGpr_obj(" Added ", ftId._grid );
			
		        ssCount[i] = 1 ;
		        ssList[i]  = (struct GRobj_env *)
		    		VD_memdup( &ftId, sizeof( struct GRobj_env ) );
		        continue ;
		      } 
		    }

		    if( ! (vd_$is_ancestry_valid(
				object	= &ftId._grid,
				classid	= OPP_ci_macro_class_id ))){

		      __DBGpr_str(" CHEKC INSIDE ", feetInfo[i].name );

		      sts = VD_findMatchFtNameSlSfInMacro(msg,
							&ftId._grid,
							&ftId.mod_env,
							feetName,
							match,
							ssList + i,
							ssCount + i ) ;
		      if(( sts & 1 & *msg ) && ssCount[i] != 0 ) {
			continue ;
		      }
		    }
		    else{
		
		      ssList[i]	= NULL ;
		      ssCount[i] = 0 ;

		      if( !( match == ASmatchRE( feetName, feetInfo[i].name ))){
			__DBGpr_str(" CANCELED ", feetInfo[i].name );
			continue ;
		      }	

		      __DBGpr_str(" ACCEPTED ", feetInfo[i].name );
		      __DBGpr_obj(" Added ", ftId._grid );
			
		      ssCount[i] = 1 ;
		      ssList[i]  = (struct GRobj_env *)
				VD_memdup( &ftId, sizeof( struct GRobj_env ) );
		    }
		} else if( ftInfo.type & ref_generic ){

			__DBGpr_com(" ftInfo.type & ref_generic " );
			continue ;

		} else if( ftInfo.type & geom_mask ||
			   ftInfo.type & other_generic ) {
		           	/* 'debug_type' is only for plane.
		           	   (Because of Robert Patience's need) */

			if( !(  match == ASmatchRE(	feetName,
							feetInfo[i].name ))){

				__DBGpr_str(" CANCELED ", feetInfo[i].name );
				continue ;
			}

			__DBGpr_str(" ACCEPTED ", feetInfo[i].name );
			__DBGpr_obj(" Added ", ftId._grid );
			
			ssCount[i] = 1 ;
			ssList[i]  = (struct GRobj_env *)
					VD_memdup(
						&ftId,
						sizeof( struct GRobj_env ) );
			if( !( ssList[i] ) ) vd_$mem_fail() ; 
		}
	}

	totCount = 0 ;
	for( i = 0 ; i < nbFeet ; i++ ) {
		totCount += ssCount[i] ;
	}

	if( totCount ) {
		int	j,
			k ;

		if( !( *listOfSolSfs = _MALLOC( totCount, struct GRobj_env ) ) )
			vd_$mem_fail() ;

		for( i = k = 0 ; i < nbFeet ; i++ ) {
			for( j = 0 ; j < ssCount[i] ; j++ ) {
				(*listOfSolSfs)[k++] = ssList[i][j] ;
			}
		}
		*countOfSolSfs = totCount ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( ssCount ) ;
		if( ssList ) {
			for( i = 0 ; i < nbFeet ; i++ ) {
				_FREE( ssList[i] ) ;
			}
			free( ssList ) ;
		}

		__DBGpr_int(" countOfSolSfs ", *countOfSolSfs );

		End
		return sts ;

} /* VD_findMatchFtNameSlSfInMacro */
/*----------------------------------------------------------------------------*/

end implementation ACncpx ;
