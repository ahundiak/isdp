/* $Id: VDbatFilter.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/VDbatFilter.I
 *
 * Description:
 *		The selected objects need to be filtered aginst the input set
 *		of the drawing process. No needed objects need to be
 *		excluded from processing.
 *
 * Dependencies:
 *	
 *
 * Revision History:
 *	$Log: VDbatFilter.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/05  19:13:18  pinnacle
# Replaced: vdbatch/imp/VDbatFilter.I for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/26  05:31:50  pinnacle
# Replaced: vdbatch/imp/VDbatFilter.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/05/29  22:55:18  pinnacle
# Replaced: vdbatch/imp/VDbatFilter.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/09/29  19:51:18  pinnacle
# Replaced: ./vdbatch/imp/VDbatFilter.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:03:08  pinnacle
# Created: vdbatch/imp/VDbatFilter.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/29/95	adz		First override.
 *
 ***************************************************************************/

class implementation VDSroot;

#include "exmacros.h"
#include "dpmacros.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "growner.h"
#include "madef.h"
#include "EMSmsgdef.h"
#include "dpdef.h"
#include "parametric.h"
#include "v_drw.h"
#include "vddrwattr.h"
#include "vdbatdrw.h"
#include "vdbatdrwmac.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from	IGEgragad	import	DPinquire;


extern	GRclassid	OPP_GRsmhdr_class_id ;
extern	GRclassid	OPP_GRclhdr_class_id ;

long VDdrw_FilterSelectList( msg, inCount, inList, file, tp2d1_tp3d0, outCount )

IGRlong			*msg;		/* return code.			*/
IGRint			inCount;	/* number of imput objects.	*/
struct	GRobj_env	*inList;	/* List of found objects.	*/
IGRchar			*file;		/* Select File for process	*/
IGRint			tp2d1_tp3d0;	/* 2d/3d process type		*/
IGRint			*outCount;	/* Number of output objects	*/
{
	/*
	 * This function will filter out objects, not needed for further
	 * processing. The filtering is done in the beginning of the 
	 * process to eliminate the maximum number of objects.
	 *
	 * To filter out the support file is a long process to duplicate,
	 * therefor we wil check inside this function for cell 
	 * symbol objects. People who like to use this function need to
	 * be aware of this.
	 */
	IGRlong			sts = OM_S_SUCCESS ;
	IGRint			typeGeneric ,
				count, i; 
	IGRchar			*locType = NULL ;
	GRname			stsMessBuf ;
	VD_drwMacInfo		*drwMacInfo = NULL ;
	IGRboolean		CellFlag = TRUE ,
				SymbolFlag = TRUE ;
		
	SetProc( VDdrw_FilterSelectList ); Begin

	*msg = MSSUCC ;
	*outCount	= 0 ;

	/*
	 * check input arguments.
	 */
	if(( ! inList ) ||
	   ( ! inCount  || inCount < 0 )){
		/*
		 * Error in setup. Lets return an error.
		 */
		*msg	= MSFAIL ;
		goto wrapup ;
	}

	/*
	 * Check the support file.
	 */
	if( (! file ) || (strlen( file ) == 0 )){
		/*
		 * No support file given; Output list in input list.
		 */
		*outCount = inCount ;
		goto wrapup ;
	}

	/*
	 * Check the setup file on validity.
	 */
        if( strlen( file )){

	    sts = ( tp2d1_tp3d0 )	? VD_drwExecConfigAddFunctions()
					: VD_drwExecSectAddFunctions() ;
	    if( !(1&sts) ){ goto wrapup; }

	    /*
	     * Check the function and get the macro defintion of the
	     * available objects.
	     */

            if( ! VD_drw_init_from_drawing_setup(  file, &drwMacInfo )){
		/*
		 * The setup file is not found.
		 */
		sprintf( stsMessBuf, "Syntax error in setup file: '%s'", file );
		UI_error (stsMessBuf);
		*msg = MSFAIL ;
		goto wrapup;
	    }
        }

	typeGeneric	= macro_generic | set_generic | other_generic ;

	/*
	 * setup the search criteria for locatable objects.
	 */
	if( drwMacInfo ){

                VD_drwMacInfo   *m ;
		IGRint		len = 0,
				space = 0 ;

		/*
		 * Get total needed buffer length.
		 */
                for( m = drwMacInfo ; m ; m = m->next ) {
		    if( m->macDefName ){
			len += strlen( m->macDefName ) ;
			space += 3 ;
		    }
		}

		if( !( locType = _MALLOC( len + space + 2, IGRchar )))
			 vd_$mem_fail();
		locType[0] = '\0'; 

		if( len ){
			/*
			 * Copy the section-cut object first.
			 */
			for( m = drwMacInfo ; m ; m = m->next ) {
				if( m->macDefName ){
					strcat(	locType, m->macDefName ) ;
					strcat( locType, "|" );
				}
			}
		}
	}
	else{
		/*
		 * Create an empty string.
		 */
		if( !( locType = _MALLOC( 5, IGRchar )))
			vd_$mem_fail();
		strcpy( locType,"*" );
	}

	if( drwMacInfo ){
		VD_drwFreeExtractMacInfo( drwMacInfo ) ;
                drwMacInfo = NULL ;
	}

	__DBGpr_str("LOCATE TYPE  ", locType );
	__DBGpr_int("TYPE_GENERIC ", typeGeneric );

	/*
	 * Check each object and reorganiza the input buffer for output
	 * buffer.
	 */

        if( ! ASmatchRE( locType, "Cell" ) ){
                __DBGpr_com(" Filter Out Cell Objects.");
		CellFlag = FALSE ;
        }

        if( ! ASmatchRE( locType, "Symbol" ) ){
                __DBGpr_com(" Filter Out Symbol Objects.");
		SymbolFlag = FALSE ;
        }

	count = 0 ;
	for( i=0 ; i<inCount ; i++ ){

#ifdef	vdsDEBUG
		VD_ShowObj( &inList[i]._grid );
#endif
		/*
		 * Check if symbol or cell object.
		 */
		if( ! SymbolFlag ){
		  if( vd_$is_ancestry_valid(
                                object  = & inList[i]._grid,
                                classid = OPP_GRsmhdr_class_id )){
			__DBGpr_com(" Skip Symbol ");
			continue ;
		  }
		}
		if( ! CellFlag ){
		  if( vd_$is_ancestry_valid(
                                object  = & inList[i]._grid,
                                classid = OPP_GRclhdr_class_id )){
			__DBGpr_com(" Skip Cell ");
			continue ;
		  }
		}

		/*
		 * Check the object type.
		 */
		sts =
		NDctl_parent_type( msg, typeGeneric, locType,
					&inList[i]._grid,
					&inList[i].mod_env );
		if( !( sts&*msg&1 )){
			__DBGpr_com(" Skip Object ");
			continue ;
		}
		inList[count++] = inList[i] ;
	}
	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	__DBGpr_int(" Found Objects ", count );

	*outCount	= count ;

	wrapup:
		sts = ( tp2d1_tp3d0 )	? VD_drwExecConfigRmFunctions() 
					: VD_drwExecSectRmFunctions() ;

		_FREE( locType );
		End ;
		return sts ;
}

/*--------------------------------------------------------------------------*/
long VDdrw_MakeSourceFromInput( msg, mdEnv, count, list )

IGRlong			*msg ;
struct	GRmd_env	*mdEnv ;
IGRint			count ;
struct	GRobj_env	*list ;
{
	/*
	 * make source of the input objects..
	 */
	IGRint			sts = OM_S_SUCCESS ,
				i ;
	struct	GRid		ctx ;

	SetProc( VDdrw_MakeSourceFromInput ); Begin

	*msg = MSSUCC ;

	for( i=0 ; i<count; i++ ){

		sts =
		GRfindcontext(	msg,
				&list[i]._matrix_type,
				list[i]._matrix,
				&list[i]._osnum,
				&ctx );
		if( sts != OM_S_SUCCESS || *msg != MSSUCC )
			ctx.objid = NULL_OBJID ;

		sts =
		as$make_source(	go_grid      = list[i].obj_id,
				context_grid = ctx,
				as_os        = mdEnv->_MD_OS,
				as_grid      = &list[i].obj_id );
	}

	sts = OM_S_SUCCESS ;
	*msg = MSSUCC ;
	
	goto wrapup ;

	wrapup :

		End ;
		return sts ;
}



/*--------------------------------------------------------------------------*/

long VDdrw_2dCrtAndProcSet(	msg, index, mdEnv, inCount, inList )

IGRlong			*msg ;
IGRint			index ;
struct	GRmd_env	*mdEnv ;
IGRint			inCount ;
struct	GRobj_env	*inList ;
{

	/*
	 * Process the VDdrw2dVw and the VDdrw2d objects.
	 */

	IGRlong			sts = OM_S_SUCCESS ;
	IGRdouble		vec[3], pnt[3];
	IGRint			i, levels[32];
	IGRboolean		Select0_Trans1	= FALSE ;
	IGRboolean		dbPosting	= FALSE ;
	IGRint			tp2d1_tp3d0	= TRUE ;
	IGRint			selCnt, outCnt ;
	struct	GRid		*outList,
                                *grids,
				winId,
				vwId ;
        VDdrwBatchInfo          info ;
	VDpartAttr		attr ;

	SetProc( VDdrw2dCrtAndProcSet ); Begin

	*msg	= MSSUCC ;
	grids	= NULL ;
	outList	= NULL ;
	outCnt	= 0 ;

	/*
	 * Get window Id object.
	 */
	winId.objid	= NULL_OBJID ;
	sts =
	vd$drw_get_globInfo( msg = msg, locate_win = &winId );
	if( !(sts & *msg & 1 )){
		 winId.objid = NULL_OBJID ;
	}

	vwId.objid	= NULL_OBJID ;
	vwId.osnum	= mdEnv->_MD_OS ;

        /*
         * list is based on the VDdrw3dVw set.
         */
        sts =
        vd$drw_batch_info( msg = msg, index = index, info = &info,
                           type = VD_B_drw_2dVw | VD_B_drw_SetupFile );
        __CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

        /*
         * Check if an VDdrw2dVw object exist.
         */
        sts =
        VDdrwMgrGetInfo( msg,   mdEnv,
                                VD_O_drw2dVw,
                                info.drw2dVw,
                                NULL,
                                &selCnt,
                                &grids,
                                NULL );
        __CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

        if( selCnt == 1 ) vwId = grids[0] ;

	_FREE( grids );
	grids = NULL ;

	/*
	 * Correction for TR#179602851  -Ravi 09/25/96
	 * If VDdrw2dVw object exist, update the flexible information,
	 * like:
	 *	- Setup file.
	 */
	if( vwId.objid != NULL_OBJID ){

		attr.Iwant       = VD_I_drwVisual ;
		strcpy( attr.aString, info.setupFile );
		__DBGpr_str(" SetupFile" , info.setupFile );
		
		sts =
		_VD_SEND_OBJN(  vwId, GRvg.GRputattr( msg, (char *)&attr ));
                CheckRC( sts, *msg );
	}


	/*
	 * Get window information.
	 *	- projection vector.
	 *	- projection point.
	 *	- active window levels.
	 */
	vec[0] = 0 ;	vec[1] = 0 ;	vec[2] = 1 ;
	pnt[0] = 0 ;	pnt[1] = 0 ;	pnt[2] = 0 ;

#ifdef	NO_WINDOW_NEEDED 

	if( winId.objid != NULL_OBJID ){

		IGRlong		error,
                                bytes_returned;

		struct var_list	w_info[2];

		w_info[0].var            = LEVELS;
		w_info[0].num_bytes      = 32*sizeof(int);
		w_info[0].bytes_returned = &bytes_returned;
		w_info[0].var_ptr        = (char *) levels;
		w_info[1].var            = END_PARAM; 

		sts =
		_VD_SEND_OBJN(	winId,
				IGEgragad.DPinquire( msg, &error, w_info));
		__CheckRC( sts, *msg, "IGEgragad.DPinquire", wrapup );
	}
#endif
	for( i=0 ; i<32 ; i++ ) levels[i] = ~0; 

	/*
	 * Reduce the input list with non-needed objects.
	 */
	__DBGpr_int(" Before Filtering ", inCount );

	sts =
	VDdrw_FilterSelectList(	msg,
				inCount,
				inList,
				info.setupFile,
				tp2d1_tp3d0,
				&selCnt );
	__CheckRC( sts, *msg, "VDdrw_FilterSelectList", wrapup );

	__DBGpr_int(" After Filtering ", selCnt );

	sts =
	VDdrw_MakeSourceFromInput(	msg,
					mdEnv,
					selCnt,
					inList );
	__CheckRC( sts, *msg, "VDdrw_MakeSourceFromInput", wrapup );

        sts =
        VDdrw_Create2dObjects(	msg,                    /* Return code  */
				index,			/* Batch index  */
                                mdEnv,			/* Environment  */
                                selCnt, 	        /* Number objs  */
                                inList,			/* List of objs */
                                pnt,                    /* Project pnt  */
                                vec,                    /* Project vec  */
                                levels,                 /* PRoject Lev  */
                                info.setupFile,		/* visualizatio */
				NULL,			/* transparent  */
                                Select0_Trans1,         /* Select/Trans */
                                dbPosting,              /* Like To Post */
                                &outCnt,                /* Nb found     */
                                &outList );             /* new VDdrw2d  */
        __CheckRC( sts, *msg, "VDdrw_CreateVDdrw2dObjects", wrapup );

	__DBGpr_int("After Preprocessing", outCnt );

	UI_echo( "" );

	sts =
	VDdrw_ProcessVDdrw_Objects(	msg,
					mdEnv,
					VD_O_drw2d,
					VD_P_drw_INTERACTIVE,
					outCnt,
					outList );
	__CheckRC( sts, *msg, "VDdrw_ProcessVDdrw_Objects", wrapup );

	__DBGpr_int("After processing", outCnt );

	/*
	 * get the owner object to inform.
	 */
	

	wrapup:

		_FREE( outList );
		End ;
		return sts ;
}

end implementation VDSroot;
