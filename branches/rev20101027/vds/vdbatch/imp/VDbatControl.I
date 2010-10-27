/* $Id: VDbatControl.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/VDbatControl.I
 *
 * Description:
 *	The batch process is directed from this file.
 *
 * Dependencies:
 *	
 *
 * Revision History:
 *	$Log: VDbatControl.I,v $
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
# Revision 1.5  1996/06/07  05:49:36  pinnacle
# Replaced: vdbatch/imp/VDbatControl.I for:  by rgade for vds.240
#
# Revision 1.4  1996/02/13  22:36:54  pinnacle
# Replaced: vdbatch/imp/VDbatControl.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/31  21:50:00  pinnacle
# Replaced: ./vdbatch/imp/VDbatControl.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/08/07  20:28:46  pinnacle
# Replaced: vdbatch/imp/VDbatControl.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:04:10  pinnacle
# Created: vdbatch/imp/VDbatControl.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/12/95	adz		First version.
 *	02/13/96	adz		TR 179527351.
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
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "vdbatdrw.h"
#include "vdbatdrwmac.h"
#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * imported methods.
 */
from	VDbatData	import	VDretrieveData;

/*
 * **************************************************************************
 */

long VDdrw_BatchControl( msg, mdEnv )

IGRlong			*msg ;
struct	GRmd_env	*mdEnv ;
{
	/*
	 * The batch process starting function as called in the file
	 * batdrw.u. This function is called to process the batch part
	 * of the drawing process.
	 * It takes the control object, check whether process need to be
	 * done and call the function VDdrw_ApplyBatchPrc to process 
	 * a view.
	 */

	IGRint			sts = OM_S_SUCCESS ,
				totFound, totOke,
				index ;		/* Control data index.	*/
	IGRlong			dvCount;
	struct	GRid		cntlObj ;
	VDdrwBatchInfo		*info ,
				infoStr ;
	IGRboolean		batch1_inter0;	/* batch or interactive */

	SetProc( VDdrw_BatchControl ); Begin

	*msg	= MSSUCC ;
	info	= NULL ;

	/*
	 * get batch control data object
	 */
	cntlObj.objid = NULL_OBJID ;
	sts =
	VDgetBatDataObj ( msg, &cntlObj );

	if( cntlObj.objid == NULL_OBJID ){
		/*
		 * Nothing to do or there.
		 */
		goto wrapup;
	}

	/*
	 * get control data
	 */
	sts =
	_VD_SEND_OBJN(	cntlObj,
			VDbatData.VDretrieveData(msg,
						&dvCount,
						&info,
						NULL, NULL, NULL, 
						&batch1_inter0,
						NULL ));
	__CheckRC( sts, *msg, "VDbatData.VDretrieveData", wrapup );

	batch1_inter0 = TRUE ;
	
	/*
	 * Check each of the given drawing-views.
	 */

	totFound = 0 ;
	totOke   = 0 ;

	for( index=0; index<dvCount; index++ ){

	  /*
	   * see if the drawing view needs to be processed
	   */
	  if(( info[index].props & VD_EXTR_EXTR ) &&
	     ( info[index].procSts == VD_B_drwPreFinished )){

	    totFound++ ;
	
	    sts =
	    VDdrw_ApplyBatchPrc(	msg,
					mdEnv,
					index,
					batch1_inter0,
					0,
					NULL );
	    if( sts & *msg & 1 ){

	      infoStr.procSts = VD_B_drwVisFinished ;
	      totOke ++ ;

              sts =
              vd$drw_batch_info(msg     = msg,
             	                set_inq = VD_B_drw_SET,
				index   = index,
                                type    = VD_B_drw_ProcSts ,
                    		info    = &infoStr );

	      if( ex$is_batch() ){
		__DBGpr_com("Save File after View Process ");
		sts = EX_save_module( active_module_num, TRUE );
	      }
	    }
	  } /* VD_B_drwPreFinished */
	} /* for i<dvCount */

	/*
	 * When the result of processing is more than nothing procent we
	 * can save the file.
	 */
	if( totOke ){

		__DBGpr_int(" Number Found ", totFound );
		__DBGpr_int(" NUmber Oke   ", totOke );

		*msg = MSSUCC ;
		sts = OM_S_SUCCESS ;
	}
	else	*msg = MSFAIL ;

	wrapup :

		_FREE( info );
		End ;
		return sts ;
}

/*
 * **************************************************************************
 */

long VDbat_CrtSetupLstFile( msg, setName, count )

IGRlong			*msg ;
IGRchar			*setName ;
IGRint			*count ;
{
	/*
	 * This function creates a ASCII file, named 'setName', which
	 * check all exiting support files and will store the absolute
	 * paths of the individual setup files.
	 * The file 'setName' will be used for batch drawing process.
	 */

	IGRint			sts = OM_S_SUCCESS ,
				sys,
				i,
				index ;		/* Control data index.	*/
	IGRlong			dvCount ;
	GRname			sysAction ;
	GRname			filepath ;
	IGRchar			*hFile = "/usr/tmp/bat123.sup" ;
	struct	GRid		cntlObj ;
	FILE			*fPntr ;
	VD_drwInputData		inp ;
	VDdrwBatchInfo		*info ;
	VD_drwMacInfo		*macInfo ;

	SetProc( VDbat_CrtSetupLstFile ); Begin

	*msg	= MSSUCC ;
	info	= NULL ;
	*count	= 0 ;
	macInfo	= NULL ;
	fPntr	= NULL ;

	if( ! setName )	goto wrapup ;

	/*
	 * get batch control data object
	 */
	cntlObj.objid = NULL_OBJID ;
	sts = VDgetBatDataObj( msg, &cntlObj );

	if( cntlObj.objid == NULL_OBJID ){
		/*
		 * Nothing to do or there.
		 */
		sts = MSFAIL; goto wrapup;
	}

	/*
	 * get control data
	 */
	sts =
	_VD_SEND_OBJN(	cntlObj,
			VDbatData.VDretrieveData(msg,
						&dvCount,
						&info,
						NULL, NULL, NULL, 
						NULL, NULL ));
	__CheckRC( sts, *msg, "VDbatData.VDretrieveData", wrapup );

	/*
	 * Check if the file exist and delete it.
	 */
	__DBGpr_str(" SetName " , hFile );
	sprintf( sysAction, "rm -f %s \n", hFile );
	sys = system( sysAction );
	if( sys != 0 ){
		sprintf( sysAction, "Can't remove file \n");
		UI_status( sysAction );
		sts = MSFAIL; goto wrapup ;
	}

	if( (fPntr = (FILE *) fopen ( hFile, "w" )) == NULL ){
		sprintf( sysAction, "Can't open file : %s\n", setName );
		UI_status( sysAction );
		sts = MSFAIL; goto wrapup ;
	}

	/*
	 * Add the user keywords.
	 */
	VD_drwExecConfigAddFunctions();
	
	for( index=0; index<dvCount; index++ ){

	  /*
	   * see if the drawing view needs to be processed
	   */
	  if(( info[index].props & VD_EXTR_EXTR ) &&
	     ( info[index].procSts == VD_B_drwPreFinished )){

		__DBGpr_str(" Setup file : ", info[index].setupFile );

                sprintf( filepath, "%s/%s", VD_K_DRW_CONFIG_RELPATH,
					    info[index].setupFile );

		VD_drwInitStackOfInputFiles( &inp.inputFiles );
		inp.inputFiles.storage = TRUE ;
		if( VD_drwPushInputFile(	filepath,
						TRUE,
						&inp.inputFiles )){
		  /*
		   * add info to buffer.
		   */
		  sts =
		  vd_$drwInterpretConfigFile(   msg     = msg,
                                                input   = &inp,
						xinfo	= &macInfo,
                                                output  = NULL ) ;
		  if( sts == 0 ) sts = OM_S_SUCCESS ;

		  if( sts & *msg & 1 ){

		    __DBGpr_int(" NUmber Files ", inp.inputFiles.nFiles );
		    for( i=0 ; i<inp.inputFiles.nFiles ; i++ ){
		      *count += 1 ;
		      __DBGpr_str(" Files ",  inp.inputFiles.files[i] );
		      fprintf( fPntr, "%s\n", inp.inputFiles.files[i] );
		    }
		  }
		} /* VD_drwPushInputFile */

		VD_drwCloseInputFiles( &inp.inputFiles );
		VD_drwFreeExtractMacInfo( macInfo ) ;
		macInfo = NULL ;

	  } /* VD_B_drwPreFinished */
	} /* for i<dvCount */

	if( fPntr )	fclose( fPntr );
	fPntr = NULL ;

	/*
	 * Delete a possible existing file and sort the found result.
	 *
	 */
	__DBGpr_str(" Remove existing file " , setName );
	sprintf( sysAction, "rm -f %s \n", setName );
	sys = system( sysAction );
	if( sys != 0 ){
		sprintf( sysAction, "Can't remove file \n");
		UI_status( sysAction );
		sts = MSFAIL; goto wrapup ;
	}

	if( *count ){

	  __DBGpr_str(" Sort Input file " , setName  );

	  sprintf( sysAction, "sort < %s | uniq > %s", hFile, setName );
	  sys = system( sysAction );
	  if( sys != 0 ){
		sprintf( sysAction, "Can't sort setup list.\n");
		UI_status( sysAction );
		sts = MSFAIL; goto wrapup ;
	  }

	  __DBGpr_str(" Remove temp file " , hFile );
	  sprintf( sysAction, "rm -f %s \n", hFile );
	  sys = system( sysAction );
	  if( sys != 0 ){
		sprintf( sysAction, "Can't remove file \n");
		UI_status( sysAction );
		sts = MSFAIL; goto wrapup ;
	  }
	}
	

	wrapup :

		VD_drwExecConfigRmFunctions();
		if( fPntr )	fclose( fPntr );
		_FREE( info );
		End ;
		return sts ;
}

/*
 * **************************************************************************
 */

long VDdrw_VwDegrated( msg, mdEnv, type, name  )

IGRlong			*msg ;
struct	GRmd_env	*mdEnv ;
IGRushort		type ;
IGRchar			*name ;
{
	/*
	 * This function will change the object associative state. When
	 * parent objects are deleted, this object needs to stay.
	 * When 'name' is given, only this one will be processed. In case of
	 * a 'name' = NULL. All visualization set of type 'type' will be
	 * processed.
	 */

	IGRint			sts = OM_S_SUCCESS ,
				i,
				count;
	struct	GRid		*grids ;
	OM_S_CHANSELECT		*to_drw ;
	VDpartAttr		attr ;

	SetProc( VDdrw_VwDegrated ); Begin

	*msg	= MSSUCC ;
	grids	= NULL ;
	count	= 0 ;

	__DBGpr_int(" Type  ", type );
	if( name ) __DBGpr_str(" Name  ", name );

	/*
	 * Get the drawing/section set object.
	 */
	sts =
	VDdrwMgrGetInfo( msg, mdEnv, type, name,
			 NULL, &count, &grids, NULL );
	__CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

	if( count == 0 || ! grids )	goto wrapup ;

	__DBGpr_int(" Count ", count );

	/*
	 * Get the channel type.
	 */
	sts =
	VDdrw_GetToDrwChannel( type, &to_drw );

	/*
	 * Send the message to all the connected elements.
	 */
	attr.Iwant	= VD_I_drwAddStsMask ;
	attr.aType	= VD_B_drwNonAssociative ;

	for( i=0; i<count; i++ ){
		sts =
		om$send(msg	= message GRvg.GRputattr( msg, (char *)&attr ),
			senderid= grids[i].objid,
			targetos= grids[i].osnum,
			p_chanselect = to_drw );
	}

	wrapup:
		_FREE( grids );
		End;
		return sts ;
}

/*
 * **************************************************************************
 */

long VDdrw_CleanupProcess( msg, mdEnv, index, type, batch1_inter0  )

IGRlong			*msg ;
struct	GRmd_env	*mdEnv ;	/* Module Environment	      */
IGRint			index ;		/* Index in VDbatData object  */
IGRushort		type ;		/* Object process Type: 2d/3d */
IGRboolean		batch1_inter0 ;	/* Batch or Interactive mode  */
{
	/*
	 * In 'type' VD_O_drw3d the object state of the 2d visualization
	 * objects are changed and the 3d visualization objects are deleted.
	 *
	 * In 'type' VD_O_drw2d, the existing 2d visualization objects will
	 * be deleted.
	 */
	
	IGRint			sts = OM_S_SUCCESS,
				count ;
	struct	GRid		*grids ;
	VDdrwBatchInfo		info ;

	SetProc( VDdrw_CleanupProcess ); Begin

	*msg	= MSSUCC ;
	count	= 0 ;
	grids	= NULL ;

	/*
	 *  Get the VDdrw2dVw and VDdrw3dVw control objects.
	 */
	sts =
	vd$drw_batch_info( msg = msg, index = index, info = &info,
			   type	= VD_B_drw_2dVw |
				  VD_B_drw_3dVw |
				  VD_B_drw_SolProp );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	/*
	 * Check the 2d object to be deleted in batch mode.
	 */
	if(( type & VD_O_drw2d ) && ( batch1_inter0 )){

		if( ! strlen( info.drw2dVw )) goto wrapup ;

		__DBGpr_str(" Delete 2dVw ", info.drw2dVw );

		sts =	
                VDdrwMgrGetInfo( msg, mdEnv, VD_O_drw2dVw, info.drw2dVw,
                                 NULL, &count, &grids, NULL );
		__CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

		if( count == 1 ){
			UI_status ( "Deleting the Temporary Objects." );
			sts =
			vd_$bulk_delete(	count	= 1,
						grids	= grids,
						theEnv	= mdEnv );
		}

		_FREE( grids );
		grids = NULL ;

		/*
		 * The control object will be updated in the delete process.
		 */
	}

	/*
	 * When batch mode we delete the 3d visualization objects.
	 */
	if( ( type & VD_O_drw3d ) &&
	    (( batch1_inter0 ) || ( !( info.props & VD_DV ))) ){

		/*
		 * Modified status for the VDdrw2d objects.
		 */
		if( strlen( info.drw2dVw )){

		  __DBGpr_str(" Degrated 2dVw ", info.drw2dVw );

		  sts =
		  VDdrw_VwDegrated( msg, mdEnv, VD_O_drw2dVw, info.drw2dVw );
		  __CheckRC( sts, *msg, "VDdrw_VwDegrated", wrapup ); 
		}

		/*
		 * Get the VDdrw3dVw control object and delete it.
		 */
		if( ! strlen( info.drw3dVw )) goto wrapup ;

		__DBGpr_str(" Delete 3dVw ", info.drw2dVw );

		sts =	
                VDdrwMgrGetInfo( msg, mdEnv, VD_O_drw3dVw, info.drw3dVw,
                                 NULL, &count, &grids, NULL );
		__CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

		if( count == 1 ){
			UI_status ( "Deleting the Temporary Objects." );
			sts =
			vd_$bulk_delete(	count	= 1,
						grids	= grids,
						theEnv	= mdEnv );
		}

		_FREE( grids );
		grids = NULL ;

		/*
		 * The control object will be updated in the 
		 * delete process.
		 */
	}
		
	wrapup :
		_FREE( grids );
		End ;
		return sts ;
}

/*
 * **************************************************************************
 */

long VDbat_PrintInfo( msg )

IGRlong			*msg ;
{
	/*
	 * Print the VDbtData info on screen.
	 */

	IGRint			sts = OM_S_SUCCESS ,
				i ;
	IGRlong			dvCount ;
	struct	GRid		cntlObj ;
	VDdrwBatchInfo		*info ;
	IGRboolean		procType;
	struct	GRid		locWin ;
	GRname			queue, login, passwd ;

	SetProc( VDbat_PrintInfo ); Begin

	*msg	= MSSUCC ;
	info	= NULL ;

	/*
	 * get batch control data object
	 */
	cntlObj.objid = NULL_OBJID ;
	sts = VDgetBatDataObj( msg, &cntlObj );

	if( cntlObj.objid == NULL_OBJID ){
		/*
		 * Nothing to do or there.
		 */
		goto wrapup;
	}

	/*
	 * get control data
	 */
	sts =
	_VD_SEND_OBJN(	cntlObj,
			VDbatData.VDretrieveData(msg,
						&dvCount,
						&info,
						queue, login, passwd,
						&procType, &locWin ));
	__CheckRC( sts, *msg, "VDbatData.VDretrieveData", wrapup );

	/*
	 * Check if the file exist and delete it.
	 */
	printf("\n\n" );
	VD_ShowObj( &cntlObj );
	VD_ShowObj( &locWin );
	printf("\n\n" );
	printf("\tqueue	 :\t%s\n", queue );
	printf("\tlogin	 :\t%s\n", login );
	printf("\tpasswd :\t%s\n", passwd );
	printf("\tprType :\t%d\n\n", procType );
	printf("\tNumber :\t%d\n\n", dvCount );

	printf("\tSetup:\tLayer:\tOffset:\tError:\tProps:\t3dVw:\t2dVw\tProcSts\n" );

	for( i=0 ; i<dvCount ; i++ ){
	
	  printf("\t%s\t%d\t%.3f\t%d\t%d\t<%s>\t<%s>\t%d\n",
			info[i].setupFile,
			info[i].layer,
			info[i].offset,
			info[i].error,
			info[i].props,
			info[i].drw3dVw,
			info[i].drw2dVw,
			info[i].procSts );
	  VD_ShowObj( &info[i].dv );
	  VD_ShowObj( &info[i].solid.obj_id );
	}
	
	wrapup :

		_FREE( info );
		End ;
		return sts ;
}

end implementation VDSroot;
