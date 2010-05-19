/* $Id: VDCmdExPrc.I,v 1.2 2001/09/04 14:30:23 ramarao Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/func/VDCmdExPrc.I
 *
 * Description:
 *	Associative Visualization Process command object implementation
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdExPrc.I,v $
 *	Revision 1.2  2001/09/04 14:30:23  ramarao
 *	Fixed TR# 5534.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/05  19:14:04  pinnacle
# Replaced: vddraw/func/VDCmdExPrc.I for:  by v250_int for vds
#
# Revision 1.3  1997/10/27  16:39:36  pinnacle
# Replaced: vddraw/func/VDCmdExPrc.I for:  by v250_int for vds
#
# Revision 1.2  1997/10/23  16:43:28  pinnacle
# Replaced: vddraw/func/VDCmdExPrc.I for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/18  19:18:28  pinnacle
# Replaced: ./vddraw/func/VDCmdExPrc.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/08/07  20:34:10  pinnacle
# Replaced: vddraw/func/VDCmdExPrc.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/28  20:36:16  pinnacle
# Created: vddraw/func/VDCmdExPrc.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		creation date
 *	09/17/95	adz		change loop to continue process.
 *
 *************************************************************************/

class implementation VDCmdExDr;

#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "AS_status.h"
#include "msmacros.h"
#include "msdef.h"
#include "ASmessages.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "ACattrib.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "parametric.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"

#include "VDmsg.h"
#include "VDSstatus.h"

/*
 * external stop request access function.
 */

extern	IGRboolean		IGEstop();

/*
 * Use or not use the internal set buffer to gain process performance.
 */

#define	INTERNAL_SET_BUFFER	1

#ifdef	INTERNAL_SET_BUFFER
extern	IGRboolean		VDdrwUseSetBuffer ;
#endif

/* 
 * The no of dots that can be displayed in the status field, is not equal to 
 * the no of characters; approximately, 2 dots are equivalent to 1 alpha
 * numeric character
 */

from    NDnode      import	NDget_objects,
				NDs_compute_node;
from    ACncpx      import	ACchange_feet,
				ACconstruct_feet;
from    NDmacro     import	ACreturn_foot;
from    GRgraphics  import	GRdisplay,
				GRremwrng,
				GRaddwrng,
				GRdelete;
from    GRvg        import	GRputattr;
from	GRowner	    import	GRget_components;
from    ACdb_info   import	ACget_db_info,
				ACset_db_info,
				ACput_serial_no,
				ACcheckin_candidate;
from    IGEgragad   import	DPinrot, DPinquire;
from    GRreffile   import	GRgetlevels, GRinquireref;
from	VDSroot     import	VDcreate;
from	VDcontext   import	VDget_osname;
from	GRcontext   import	GRgetmodule_env;

extern   GRclassid   OPP_VDdrw2d_class_id;

long	VDdrw_Create2dObjects(	msg, index, mdEnv,
				inCount, inList,
				prjPnt, prjVec, objLevels,
				fileName, transName,
				Select0_Trans1,
				dbPosting,
				outCount, outList ) 

long			*msg ;			/* Return Code.		*/
int			index ;			/* Batch index		*/
struct	GRmd_env	*mdEnv ;		/* module Environment	*/
IGRint			inCount ;		/* Number of objects	*/
struct	GRobj_env	*inList ;		/* List of objects.	*/
IGRdouble		*prjPnt ;		/* Projection Point	*/
IGRdouble		*prjVec ;		/* PRojection Vector	*/
IGRint			*objLevels ;		/* Object Process Level */
IGRchar			*fileName ;		/* Visualization File   */
IGRchar			*transName ;		/* Transparent File	*/
IGRboolean		Select0_Trans1 ;	/* Object process type	*/
IGRboolean		dbPosting ;		/* Like to post objects */
IGRint			*outCount ;		/* Number of VDdrw2d obs*/
struct	GRid		*outList[] ;		/* List of VDdrw2d objs */

{

	IGRint			sts = OM_S_SUCCESS,
				rc, i, 
				addTo2dVw = FALSE, /* local process saving */
				processMode,
				nbRoots = 1,	/* only 3d-model is parent */
				drwExist,
				inCnt,		/* internal Processed count */
				nbAttach,
				nbAttr = 0,	/* number of attr for coll */
				drwVwCount,	/* Number to connect       */
				drwCount ;
	struct	ACrg_coll	*Attr = NULL ;		/* attr for coll   */	
	struct	GRobj_env	modObj, 	/* parent object of draw   */
				*pInList;	/* Pointer of active list  */
	struct	GRid		drwObj,
				*drwList,	/* Object to process.      */
				*drwVwList,	/* Object to connect.      */
				Roots[3] ;
	VDpartAttr		attr ;
	VD_drwMacInfo           *drwMacInfo ;
	GRname			echoProc ;

	SetProc( VDdrw_Create2dObjects ); Begin

	*msg = MSSUCC ;
	
	*outCount	= 0 ;
	*outList	= NULL ;
	pInList		= NULL ;	/* Control list pointer.	*/
	drwMacInfo	= NULL ;	/* Visual support file info	*/
        drwCount	= 0 ;		/* Number of created objects	*/
	drwList		= NULL ;	/* List of created objects	*/
        drwVwCount	= 0 ;		/* Number of to connect objects	*/
	drwVwList	= NULL ;	/* List of to connect objects	*/

	processMode	= ( ! ex$is_batch() );

	__DBGpr_int( " Process MODE ", processMode );

	/*
	 * Check the input data. If one type of information is missing
	 * nothing will be processed.
	 */
	if( 	! inCount	||	/* Unknown number of objects.	*/
		! inList	||	/* No list of objects.		*/
		! fileName	||	/* No support file		*/
		strlen( fileName ) == 0 )	goto wrapup ;

	sts = VD_drwExecConfigAddFunctions();
	if ( !(1 & sts)) {
		VD_drwExecConfigRmFunctions();
		goto wrapup;
	}

	if( ! VD_drw_init_from_drawing_setup( fileName, &drwMacInfo )){

		/*
		 * The setup file is not found.
		 */
		if( ! ex$is_batch() ){
			sprintf( echoProc, "Syntax error in setup file: '%s'",
				fileName );
			UI_error( echoProc );
		}
		VD_drwExecConfigRmFunctions();
		*msg = OM_E_ABORT;
		goto wrapup;
	}

	VD_drwExecConfigRmFunctions();

	attr.Iwant = VD_I_drwSetStsMask ;
	if( Select0_Trans1 ){
		__DBGpr_com(" PROCESS TRANSPARENT ");
		//attr.aType = VD_B_drwTransParent ;
		attr.aType = VD_K_drwTrans ;
	}	
	else{	__DBGpr_com(" PROCESS SELECT/HIDDEN ");
		attr.aType = VD_B_drwDefaultMask ;
	}

	pInList	= inList ;

	/*
	 * Setup process buffers.
	 */
	modObj._md_id = NULL_OBJID;

	inCnt = inCount ;		/* Number of input objects	*/

	if( !( drwList = _MALLOC( inCnt, struct GRid )))
		vd_$mem_fail();

	if( !( drwVwList = _MALLOC( inCnt, struct GRid )))
		vd_$mem_fail();

	/*
	 * Pre-process the input objects per context group. This will
	 * automate the process and keep all objects from one drawing-view
	 * together.
	 */

	while( TRUE ){

          /*
	   * works one reference file attachement at the time
	   */

	  sts =
          VD_drw_SortPerContext( msg, inCnt, pInList, &nbAttach );

          if( !( nbAttach )) break;

	  __DBGpr_int(	"nbAttach", nbAttach );

          /* 
           * add in the context object info like model file name, displayable 
           * level and view definition by changing its class to VDcontext
           */
          sts =
	  VD_drw_StoreLevelsAndVol(	msg, pInList, nbAttach, 
                                        objLevels, prjPnt, prjVec, mdEnv );
	  if( !( sts & *msg & 1 )){
		__DBGpr_com(" Add info in the VDdrw2dVw object.");
		addTo2dVw = TRUE ;
	  }

          for( i=0 ; i<nbAttach ; i++ )
          {
	        /*
		 * Information processing.
		 */
	        if( processMode ){

		  /*
		   * Ask for signal.
		   */
		  if( IGEstop()){
			/*
			 * Request to stop process.
			 */
			*msg = MSFAIL ;
			goto wrapup ;
		  }

		  sprintf(echoProc, "Pre-Processing %.0f%% ",
				(double)(i*100./(double)nbAttach) );
		  UI_echo( echoProc );
		}

		/* 
                 * Get macro definition of the selected object and search if 
                 * there is a drawing macro definition valid for this type of 
                 * macro to know which attributes should be extracted
                 */
		sts =
		_VD_SEND_OBJN( 	pInList[i]._grid,
				NDmacro.ACreturn_foot(
                                                  msg,
						  "",
                                                  &modObj._grid,
                                                  &modObj._matrix_type,
                                                  modObj._matrix ));
		if( !( sts & *msg & 1 ) ) 
                    continue;

		modObj._md_os = modObj._osnum;

		/*
		 * initialize the drawing macro with this
		 */
		drwObj.objid = NULL_OBJID;
		drwObj.osnum = mdEnv->_MD_OS;

		/*
		 * The object in the list "pInList" are already generated
		 * the "as$make_source". They are all "ACpretend" objects.
		 * Check if the object has already a "VDdraw" objects 
		 * connected to him.
		 */

		sts =
		VDchk_child_on_class(	msg,
					&modObj._grid,		/* model */
					&(pInList[i]._grid),	/* pretend */
					"VDdrw2d",		/* class */
					&drwObj );

		drwExist = ( drwObj.objid == NULL_OBJID ) ? FALSE : TRUE ;

		/*
		 * Construct a new object.
		 */
		sts =
		VDdrw_ConstructVDdrw( msg, VD_O_drw2d, &drwObj, mdEnv, &modObj);
		CheckRC( sts, *msg );
                if( !(sts & *msg & 1)){

			if( drwObj.objid == NULL_OBJID ) continue ;
                        sts =
                        vd_$bulk_delete(count   = 1,
                                        grids   = &drwObj,
                                        theEnv  = mdEnv );
                        continue ;
                }


		/*
		 * Put the mask in the object.
		 */
		sts =
		_VD_SEND_OBJN( drwObj, GRvg.GRputattr( msg, (char *) &attr ));
                CheckRC( sts, *msg );
                if( !(sts & *msg & 1)){

			if( drwObj.objid == NULL_OBJID ) continue ;
                        sts =
                        vd_$bulk_delete(count   = 1,
                                        grids   = &drwObj,
                                        theEnv  = mdEnv );
                        continue ;
                }

		/*
		 * add roots to object.
		 */
		if( ! drwExist ){

			/*
			 * check the parent attributes and set them in the 
			 * collector. Find the macro definition of parent and
			 * check with attribute list from the setup files.
			 */
			sts =
			VD_drw_GiveObjAttrList(	msg, &modObj, drwMacInfo,
						&nbAttr, &Attr );

			Roots[0] = pInList[i]._grid ;
			sts =
			_VD_SEND_OBJN(	drwObj, 
					VDSroot.VDcreate(
						msg,
						nbAttr,
						Attr,
						"VDdrw2d",
						AChdr_nodisplay|AChdr_nocompute,
						nbRoots,
						Roots ));

			/*
			 * Free the memory for the attributes.
			 */
			_FREE(	Attr );
			nbAttr = 0 ;
			Attr = NULL ;

			if( ! (sts&*msg&1)){

				sts =
				vd_$bulk_delete(count	= 1,
						grids	= &drwObj,
						theEnv	= mdEnv );

				continue;
			}
			/*
			 * Add in list to connect.
			 */
			drwVwList[drwVwCount++] = drwObj ;
		}
		/*
		 * Add in list to process.
		 */
		drwList[drwCount++] = drwObj;

		/*
		 * Initialize db_info for the drawing part
		 * See if we need to post the drawing objects.
		 */

		if( ! dbPosting )	continue ;

		sts =
		VDdbInfo_AlignModel_Prod( msg, &modObj._grid, drwObj );
	  }

	  /*
	   * Prepare extraction of following elements
	   */

	  OM_BLOCK_MOVE( pInList + nbAttach, pInList,
                        (inCnt - nbAttach) * sizeof(struct GRobj_env) );
          inCnt -= nbAttach;

	} /* while( 1 ) */

	/*
	 * create a set of this group of objects.
	 * The set are based per context. When in later stage objects are
	 * extracted, they can be added to this context group.
	 * The set will only be created by objects of the set process;
	 */
	sts =
	VDdrw_CrtViewSetOfList(	msg,
				index,		/* Batch index value	*/
				mdEnv,		/* local environment	*/
				drwVwCount,	/* Object to connect	*/
				drwVwList,	/* List to connect	*/
				fileName,	/* support file 	*/
				transName,	/* TransP filename 	*/
				prjPnt,		/* Project Point.	*/
				prjVec,		/* Project Vector	*/
				objLevels,	/* WIndow levels	*/
				addTo2dVw );	/* New/check with exist	*/
	__CheckRC( sts, *msg, "VD_drw_CrtViewSetOfList", wrapup );

	/*
	 * The total list will be given back to the caller function.
	 */
	*outCount	= drwCount ;
	*outList	= drwList  ;

	drwList		= NULL ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :

		if( !( sts & *msg & 1 )){
			/*
			 * Error in processing.
			 */
			vd_$bulk_delete(count	= drwCount,
					grids	= drwList ,
					theEnv	= mdEnv );
		}

		VD_drwFreeExtractMacInfo( drwMacInfo ) ;

		_FREE( drwList );
		_FREE( drwVwList );
		_FREE( Attr );

		End ;
		return sts ;
}

/* -------------------------------------------------------------------------- */

long	VDdrw_ProcessVDdrw_Objects(	msg, mdEnv, type, 
					cn_type, 	/* Process Type	*/
					inCount, inList )

long			*msg ;
struct	GRmd_env	*mdEnv ;
int			type ;		/* Object Process Type	*/
IGRint			cn_type ;	/* Process Type		*/
IGRint			inCount ;
struct	GRid		*inList ;
{
	/* 
	 * The compute of VDdrw2d and VDdrw3d objects can be done in 
	 * interactive mode and in batch mode. The batch mode for the
	 * VDdrw3d objects has a different functionality.
	 * 	For detaults see VDdrw3d.ACconstruct_feet().
	 * The compute flags is default equal to 'zero' and is not used. 
	 * For batch processing we will change the flag to do special
	 * processing.
	 * 
	 */
	IGRint			sts = OM_S_SUCCESS,
				i, 
				processMode,
				nbFeets ,
				nbRoots ;
	struct	GRid		Roots[20],
				Feets[20];	/* VDdrw2d has 1 feet(s)  */
	GRname			echoProc ;

	SetProc( VDdrw_ProcessVDdrw_Objects ); Begin 

	*msg = MSSUCC ;
	
	processMode	= ( ! ex$is_batch() );

	__DBGpr_int(" Process Type    ", cn_type );
	__DBGpr_int(" inCount         ", inCount );

	/*
	 * Make use of the internal "set" buffer to improve process time.
	 */
	if( type & VD_O_drw2d ){
		/*
		 * Handle the set-buffer for the extraction process.
		 */
		VDdrwUseSetBuffer = TRUE ;
	}

	UI_echo( "" );
	UI_status( "" );

	for( i=0 ; i<inCount ; i++ ){

	    /*
	     * Ask for signal.
	     */
	    if( IGEstop()){

		/*
		 * Request to stop process.
		 * For the VDdrw3d objects : Delete the objects.
		 *	   VDdrw2d objects : Stop Processing.
		 */
		if( type & VD_O_drw3d ){

			struct	GRid	drw3dVw ;
			/*
			 * Get the owner object of the VDdrw3d.
			 */
			sts = VDdrw_GetChannelOwner(	msg, inList,
							type, &drw3dVw );
			__CheckRC( sts, *msg, "VDdrw_GetChannelOwner", wrapup );

			vd_$bulk_delete(count	= 1,
					theEnv	= mdEnv,
					grids	= &drw3dVw );
		}

		*msg = MSSUCC ;
		goto wrapup ;
	    }

	    if( processMode ){
	    	sprintf(echoProc,	"Processing %.0f%% ",
			(double)(i*100./(double)inCount));
		UI_echo( echoProc );
	    }

	    nbRoots = 0 ;

	    if( cn_type != VD_P_drw_FEETPROCESS ){

		sts =
		_VD_SEND_OBJN(	inList[i],
				NDnode.NDget_objects(	ND_ROOT,
                                                        Roots,
                                                        20,
							NULL,
                                                        0,
							OM_K_MAXINT,
                                                        &nbRoots ));
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;
	    }

	    __DBGpr_obj( "DrawObj ", inList[i] );

            sts =
	    _VD_SEND_OBJN(	inList[i],
				ACncpx.ACconstruct_feet(msg,
							cn_type,
                                                        nbRoots,
							Roots,
                                                        mdEnv,
                                                        &nbFeets,
                                                        Feets ));

            if( sts&*msg&1 ){
		sts =
		_VD_SEND_OBJN(	inList[i],
				ACncpx.ACchange_feet(	nbFeets,
							Feets,
							mdEnv ));

		sts =
		vd_$bulk_display(	dpmode	= GRbd,
					count	= 1,
					grids	= inList +i,
					theEnv	= mdEnv );
	    }
            else{ 
		sts =
		vd_$bulk_delete(	count	= 1,
					grids	= inList +i,
					theEnv	= mdEnv );
		inList[i].objid	= NULL_OBJID ;
	    }
	} /* for ( .. inCount ) */

	UI_echo("");

	*msg = MSSUCC ;

	wrapup:

		if( type & VD_O_drw2d ){
			VD_drwClearSetBuffer();
			VDdrwUseSetBuffer = FALSE ;
		}

		End ;
		return sts ;
}

/* -------------------------------------------------------------------------- */

long	VDdrw_ProcessRangeObject( msg, mdEnv, inCount, inList )

long			*msg ;
struct	GRmd_env	*mdEnv ;
IGRint			inCount ;
struct	GRid		*inList ;
{
	/* 
	 * Delete the existing object from the range tree and recompute
	 * the object, followed by adding the new version into the
	 * range tree.
	 */
	IGRint			sts = OM_S_SUCCESS,
				i ;
	OM_S_OBJID		md_id ;
	struct	GRmd_env	locEnv ;

	SetProc( VDdrw_ProcessRangeObject ); Begin

	locEnv = *mdEnv ;
	md_id  = mdEnv->_MD_ID ;

	for( i=0 ; i<inCount ; i++ ){

		__DBGpr_obj(" Computed ", inList[i] );

                sts = 
                 _VD_SEND_OBJN(	inList[i],
				GRgraphics.GRremwrng( msg, &locEnv ));

		locEnv._MD_ID = NULL_OBJID;
		sts = 
                _VD_SEND_OBJN(	inList[i],
				NDnode.NDs_compute_node( msg, 0, &locEnv ));

                if( sts & *msg & 1 ){

			locEnv._MD_ID = md_id ;
                        sts = 
                        _VD_SEND_OBJN(	inList[i],
					GRgraphics.GRaddwrng( msg, &locEnv ));
		}
	}

	End ;
	return sts ;
}

/* -------------------------------------------------------------------------- */

VDdbInfo_AlignModel_Prod( msg, modObj, prdObj )

long                    *msg ;
struct GRid		*modObj ;
struct GRid		*prdObj ;
{
	IGRint			rc = OM_S_SUCCESS,
				sts = OM_S_SUCCESS ;
	struct ACdb_info	dbInfo ;

	SetProc( VDdbInfo_AlignModel_Prod ); Begin

	__DBGpr_obj(" modObj ", modObj );
	__DBGpr_obj(" prdObj ", prdObj );

	sts =
	_VD_SEND_OBJN(	*modObj,
			ACdb_info.ACcheckin_candidate(
						VDS_NORMAL_CHECKIN, &rc ));
	if( !( sts&rc&1 )){
	  sts =
	  _VD_SEND_OBJN(*modObj,
			ACdb_info.ACcheckin_candidate(
						VDS_FAST_CHECKIN, &rc ));
	}

	/* 
	 * When OK, fill in the reference information from model object
	 * into the production object.
	 */
	if( sts&rc&1 ){

	    /*
	     * get database information of parent object.
	     */

	    sts =
	    _VD_SEND_OBJN(*modObj, ACdb_info.ACget_db_info( msg, &dbInfo ));
	    if( !( sts&*msg&1 )){

		/*
		 * ad/alain:
		 * Instead of stopping the drawing extraction, give 
	         * warning for current object without database
		 * information and continue with drawing extraction.
		 */
		printf(" WARNING: No db_info found -> ");
		VD_ShowObj( modObj );
                goto quit ;
	    }

	    __DBGpr_com(" Object has db_info set ");

	    sts =
	    _VD_SEND_OBJN( *prdObj,ACdb_info.ACset_db_info( msg, &dbInfo));

	    sts =
	    _VD_SEND_OBJN( *prdObj,ACdb_info.ACput_serial_no( dbInfo.serial_no));
	}

quit:
	End
	return ( 1&sts&rc );
}

end implementation VDCmdExDr;
