/* $Id: VDbatProcess.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/VDbatProcess.I
 *
 * Description:
 *	The selected objects need to be handle.
 *
 * Dependencies:
 *	
 *
 * Revision History:
 *	$Log: VDbatProcess.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/05/24  11:40:30  pinnacle
# Replaced: vdbatch/imp/VDbatProcess.I for:  by ksundar for vds.240
#
# Revision 1.6  1996/03/08  12:25:44  pinnacle
# Replaced: vdbatch/imp/VDbatProcess.I for:  by rgade for vds.240
#
# Revision 1.5  1995/09/29  19:51:06  pinnacle
# Replaced: ./vdbatch/imp/VDbatProcess.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/08/31  21:50:28  pinnacle
# Replaced: ./vdbatch/imp/VDbatProcess.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/07  20:29:32  pinnacle
# Replaced: vdbatch/imp/VDbatProcess.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/26  16:53:14  pinnacle
# Replaced: vdbatch/imp/VDbatProcess.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:02:40  pinnacle
# Created: vdbatch/imp/VDbatProcess.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/29/95	adz		First override.
 *	09/28/95	adz		Set filter_objects macro.
 *
 ***************************************************************************/

class implementation VDSroot;

#include "exmacros.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "growner.h"
#include "madef.h"
#include "EMSmsgdef.h"
#include "dpdef.h"
#include "parametric.h"
#include "v_drw.h"
#include "vdbatdrw.h"
#include "vdbatdrwmac.h"
#include "vdsetmacros.h"
#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * **************************************************************************
 */

long VDdrw_ApplyBatchPrc( msg, mdEnv, index, batch1_inter0, inCount, inList )

IGRlong			*msg ;
struct	GRmd_env	*mdEnv ;
IGRint			index ;		/* Control data index.	*/
IGRboolean		batch1_inter0;	/* batch or interactive */
IGRint			inCount ;	/* Number of objects	*/
struct	GRobj_env	*inList ;	/* List of objects	*/
{

	IGRint			sts = OM_S_SUCCESS ;
	IGRboolean		objenvsMALLOC = FALSE ;
	struct	GRid		*grids ;
	struct	GRobj_env	*objenvs ;
	int			count;
	VDdrwBatchInfo		info ;

	/*
	 * In interactive mode:
	 *	- Get the objects.
	 *	- Do the 2d visualization process.
	 *	- Inform control data.
	 *
	 * In batch mode:
	 *	- Get objects (control object/arguments).
	 *	- Do the section process.
	 *	- Inform control data.
	 *	- Get visualization info.
	 *	- Do the 2d visualization process.
	 *	- Inform control data.
	 */
  
	SetProc( VDdrw_ApplyBatchPrc ); Begin

	*msg = MSSUCC ;

	count		= 0 ;
	grids		= NULL ;
	objenvs		= NULL ;

	/*
	 * list is based on the VDdrw3dVw set.
	 */
	__DBGpr_int(" index ", index );

	info.procSts	= VD_B_drwSectProcess ;
	sts =
	vd$drw_batch_info( msg = msg, index = index, info = &info,	
			   set_inq = VD_B_drw_SET ,
		           type	= VD_B_drw_ProcSts );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	sts =
	vd$drw_batch_info( msg = msg, index = index, info = &info,
			   type	= VD_B_drw_3dVw	| VD_B_drw_SetupFile );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	if( ! inCount ){

		if( strlen( info.drw3dVw ) == 0 ){

			/*
			 * Error in processing.
			 */
			__DBGpr_com(" Error: drw3dVw not found ");
			*msg = MSFAIL ;
			goto wrapup ;
		}

		/*
		 * Get the VDdrw3dVw object as setup in preprocess and
		 * execute the intersection process.
		 */
		if( batch1_inter0 ){
		  sts =
		  VDdrwMgrGetInfo( msg,	mdEnv,
					VD_O_drw3dObj,
					info.drw3dVw,
					NULL,
					&count,
					&grids,
					NULL );
		  __CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

		  if( count && grids ){

		    /*
		     * do the internal computation for the
		     * section objects.
		     */
		    sts =
		    VDdrw_ProcessVDdrw_Objects(	msg,
						mdEnv,
						VD_O_drw3d,
						VD_P_drw_FEETPROCESS,
						count,
						grids );
		    __CheckRC( sts, *msg, "VDdrw_ProcessVDdrw_Objects", wrapup);
		    _FREE( grids );
		    grids = NULL ;
		  }
		}

		info.procSts	= VD_B_drwSectFinished ;
		sts =
		vd$drw_batch_info( msg = msg, index = index, info = &info,	
				   set_inq = VD_B_drw_SET ,
			           type	= VD_B_drw_ProcSts );
		__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

		/*
		 * get the information for the 2d visualization
		 * process.
		 */
		sts =
		VDdrwMgrGetInfo( msg,	mdEnv,
					VD_O_drw3dObj,
					info.drw3dVw,
					NULL,
					&count,
					NULL,
					&objenvs );
		__CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

		objenvsMALLOC = TRUE ;
	}
	else{

		count	= inCount ;
		objenvs	= inList ;
	}

	
	info.procSts	= VD_B_drwVisCreate ;
	sts =
	vd$drw_batch_info( msg = msg, index = index, info = &info,	
			   set_inq = VD_B_drw_SET ,
		           type	= VD_B_drw_ProcSts );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	/*
	 * In batch mode will delete the old information from the 
	 * data structure.
	 * In interactive mode the principle of associative dependent
	 * will be kept active. (Untill ....).
	 */

	/*
	 * Apply the cleanup process of VDdrw2d objects.
	 */
	sts =
	VDdrw_CleanupProcess( msg, mdEnv, index, VD_O_drw2d, batch1_inter0 );
	__CheckRC( sts, *msg, "VDdrw_CleanupProcess", wrapup );

	sts =
	VDdrw_2dCrtAndProcSet(	msg, index, mdEnv, count, objenvs );
	__CheckRC( sts, *msg, "VDdrw_ProcessInteractive", wrapup );

	info.procSts	= VD_B_drwVisFinished ;
	sts =
	vd$drw_batch_info( msg = msg, index = index, info = &info,	
			   set_inq = VD_B_drw_SET ,
		           type	= VD_B_drw_ProcSts );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	/*
	 * Apply the cleanup process of VDdrw3d objects.
	 */
	sts =
	VDdrw_CleanupProcess( msg, mdEnv, index, VD_O_drw3d, batch1_inter0 );
	__CheckRC( sts, *msg, "VDdrw_CleanupProcess", wrapup );

	wrapup:
		{

		  /*
		   * report the error.
		   */
		  IGRint	sts1 ;
		  IGRlong	msg1 ;
		  /*
		   * report the error.
		   */
		  sts1 =
		  vd$drw_batch_info( msg = &msg1, index = index, info = &info,
				     type = VD_B_drw_SolProp );

		  if( !(sts & *msg & 1 )){
		    info.props &= ~( VD_EXTR_NEW | VD_EXTR_OK ) ;
		    info.props |= VD_EXTR_ERR ;
		  }
		  else{
		    info.props &= ~( VD_EXTR_NEW | VD_EXTR_ERR );
		    info.props |= VD_EXTR_OK ;
		  }

		  sts1 =
		  vd$drw_batch_info( msg = &msg1, index = index, info = &info,
				     set_inq	= VD_B_drw_SET,
				     type	= VD_B_drw_SolProp );
		}
	

		_FREE( grids );
		if( objenvsMALLOC ) _FREE( objenvs );
		End ;
		return sts ;
}

/*
 * **************************************************************************
 */

long VDdrw_DefineProcess( msg, mdEnv, batch1_inter0, index, inCount, inList,
vd_vw0, vd_vw1 )
IGRlong			*msg;		/* return code.			*/
struct	GRmd_env	*mdEnv;		/* Local Environment		*/
IGRboolean		batch1_inter0;	/* Process type setting		*/
IGRint			index;		/* drawing view index in table	*/
IGRint			inCount;	/* number of imput objects.	*/
struct	GRobj_env	*inList;	/* List of found objects.	*/
IGRlong                 vd_vw0;         /* Current View                 */
IGRlong                 vd_vw1;         /* Total no.of Views            */
{
	/*
	 * This function will handle the located objects from the
	 * drawing-view and controls the following actions. 
	 *
	 * 1. batch1_inter0	: TRUE ;
	 * =============================
	 *	- Copy the objects in a VDdrw3d object.
	 *	- Check if the VDdrw3dVw exist in control data.
	 *	- 
	 *
	 * 2. batch1_inter0	: FALSE ;
	 * ==============================
	 *	- See if a solid is defined.
	 *	- Optional: - Copy the objects in a VDdrw3d object.
	 *		    - Check if the VDdrw3dVw exist in control data.
	 *
	 */

	IGRint			sts = OM_S_SUCCESS ,
				tp2d1_tp3d0,
				wkCount,
				outCount,
				count; 
	struct	GRid		*grids,
				drw3dVw ;
	struct	GRobj_env	*wkList ;
	IGRint			comp3dVw = FALSE ;	/* No VDdrw3Vw dep. */
	GRname			promptInfo ;
	VDpartAttr		attr ;
	VDdrwBatchInfo		info ;
		
	SetProc( VDdrw_DefineProcess ); Begin

	*msg = MSSUCC ;

	wkList		= NULL ;
	grids		= NULL ;
	wkCount		= 0 ;
	outCount	= 0 ;

	/*
	 * check input arguments.
	 */
	if(( ! inList ) ||
	   ( ! inCount  || inCount <= 0 )){
		/*
		 * Error in setup. Lets return an error.
		 */
		*msg	= MSFAIL ;
		goto wrapup ;
	}

	/*
	 * Check the support file.
	 */
	sts =
	vd$drw_batch_info( msg = msg, index = index, info = &info,
			  type = VD_B_drw_SetupFile );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	/*
	 * Filter out the input list.
	 * Based on setup file and on ownership.
	 */
	tp2d1_tp3d0	= 1; 

	sts =
	vd$filter_objects(	msg	= msg,
				iList	= inList,
				iCount	= inCount,
				oList	= &wkList,
				oCount	= &wkCount );
	__CheckRC( sts, *msg, "VD_CheckObjectFromListOrSet", wrapup );

	__DBGpr_int(" wkCount ", wkCount );

	/*
	 * Filter based on setup file.
	 */
	sts =
	VDdrw_FilterSelectList( msg,	wkCount,
					wkList, 
					info.setupFile,
					tp2d1_tp3d0,
					&outCount );
	__CheckRC( sts, *msg, "VDdrw_FilterSelectList", wrapup );

	wkCount = outCount ;

        sprintf(promptInfo, 
		"Processing %d Objects of View %d[%d] with '%s' ", 
			outCount, vd_vw0, vd_vw1, info.setupFile );

        sts =
        ex$message(     in_buff = promptInfo,
                        field   = PROMPT_FIELD,
                        justification   = CENTER_JUS );

	/*
	 * Locate is finished.
	 */
	info.procSts	= VD_B_drwLocFinished ;
	sts =
	vd$drw_batch_info( msg		= msg, index = index, info = &info,	
			   set_inq	= VD_B_drw_SET ,
			   type		= VD_B_drw_ProcSts );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	/*
	 * Get needed information to process.
	 */
	sts =
	vd$drw_batch_info(	msg	= msg, index = index, info = &info,
				type	= VD_B_drw_Solid	|
					  VD_B_drw_SolProp	|
					  VD_B_drw_SetupFile    |
					  VD_B_drw_Layer	|
					  VD_B_drw_3dVw		|
					  VD_B_drw_SolOffset );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );
	
	/*
	 * Check if we need to do the section-cut process.
	 * This is not needed in interactive mode, when selection
	 * was based on drawing-view.
	 */

	if( ( batch1_inter0 ) ||
	    ( !( info.props & VD_DV ))){

		__DBGpr_com(" Start with the section process.");

		drw3dVw.objid = NULL_OBJID ;
		drw3dVw.osnum = mdEnv->_MD_OS ;

		if( strlen( info.drw3dVw ) != 0 ){
		  /*
		   * Get the VDdrw3dVw object.
		   */
		  sts =
		  VDdrwMgrGetInfo( msg, mdEnv,
					VD_O_drw3dVw,
					info.drw3dVw,
					NULL,
					&count,
					&grids,
					NULL );
		  __CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

		  if( count == 1 ){
			__DBGpr_obj(" VDdrw3dVw ", grids[0] );
			drw3dVw = grids[0] ;
		  }
		  _FREE( grids );
		  grids = NULL ;
		}

		if( drw3dVw.objid != NULL_OBJID ){

		  /*
		   * delete the existing volume set. When the drawing set
		   * is associative with the volume set, it will be deleted
		   * as well.
		   * Inside the delete of the 'set' objects the control
		   * object will be updated.
		   */
		  sts =
		  vd_$bulk_delete(	count	= 1,
					grids	= &drw3dVw,
					theEnv	= mdEnv );
		}

		/*
		 * Start with copying the objects geometry.
		 */
		info.procSts = VD_B_drwCopyObjects ;
		sts =
		vd$drw_batch_info( msg	= msg, index = index, info = &info,	
				  set_inq = VD_B_drw_SET ,
				  type	  = VD_B_drw_ProcSts );
		__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );
                if( !wkCount ) { 
		    UI_status("No object are found in drawing view");
                    goto wrapup;
		}

		sts =
		VD_crtSectionObjects(	msg,
					mdEnv,
					&info.solid,
					info.offset,
					comp3dVw,
					info.layer,
					info.setupFile,	/* 2d support file */
					NULL,		/* 3d support file */
					wkCount,
					wkList,
					batch1_inter0,
					&drw3dVw );
		__CheckRC( sts, *msg, "VD_crtSectionObjects", wrapup );

		info.procSts = VD_B_drwCopyFinished ;
		sts =
		vd$drw_batch_info( msg	= msg, index = index, info = &info,	
				  set_inq = VD_B_drw_SET ,
				  type	  = VD_B_drw_ProcSts );
		__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

		/*
		 * Get internal name of VDdrw3dVw object.
		 */
		attr.Iwant = VD_I_drwInternalName ;
		sts =
		_VD_SEND_OBJN(	drw3dVw, GRvg.GRgetattr( msg, (char *)&attr ));
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

		/*
		 * Set the name of the section control object.
		 */
		strcpy( info.drw3dVw, attr.aString ); 
		info.procSts = ( batch1_inter0 ) ? VD_B_drwPreFinished
						 : VD_B_drwSectFinished ;
		
		sts =
		vd$drw_batch_info( msg = msg, index = index, info = &info ,
				   set_inq = VD_B_drw_SET,
				   type	= VD_B_drw_3dVw | VD_B_drw_ProcSts );
		__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

		/*
		 * The process will use the control object.
		 */
		_FREE( wkList );
		wkList	= NULL ;
		wkCount	= 0 ;

	}

	if( batch1_inter0 ){
		/*
		 * Batch mode preprocessing is finished.
		 */
		*msg = MSSUCC ;
		sts  = OM_S_SUCCESS ;
		goto wrapup ;
	}


	/*
	 * Compute the drawing objects, either based on the 
	 * located objects or on the volume set.
	 */
	sts =
	VDdrw_ApplyBatchPrc(	msg,
				mdEnv,
				index,
				batch1_inter0,
				wkCount,
				wkList );
	__CheckRC( sts, *msg, "VDdrw_ApplyBatchPrc", wrapup );

	wrapup:
		{

		  /*
		   * report the error status. When batch process is
		   * TRUE, we have finished preprocessing. Do not report
		   * end processing, this will be done in the function
		   * VDdrw_ApplyBatchPrc().
		   */
		  IGRint	sts1 ;
		  IGRlong	msg1 ;

		  sts1 =
		  vd$drw_batch_info( msg = &msg1, index = index, info = &info,
				     type	= VD_B_drw_SolProp );

		  if( !(sts & *msg & 1 )){
		    info.props &= ~(VD_EXTR_NEW | VD_EXTR_OK | VD_EXTR_EXTR);
		    info.props |= VD_EXTR_ERR ;
		  }
		  else{
		    info.props &= ~(VD_EXTR_NEW | VD_EXTR_ERR);
		    info.props |= VD_EXTR_OK ;
		  }

		  sts1 =
		  vd$drw_batch_info( msg = &msg1, index = index, info = &info,
				     set_inq	= VD_B_drw_SET,
				     type	= VD_B_drw_SolProp );
		}
	
		_FREE( wkList );
		_FREE( grids );

		End;
		return sts ;
}

end implementation VDSroot;
