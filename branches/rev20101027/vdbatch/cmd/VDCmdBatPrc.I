/* $Id: VDCmdBatPrc.I,v 1.1.1.1 2001/01/04 21:07:53 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/cmd/VDCmdBatPrc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdBatPrc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:53  cvs
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
# Revision 1.9  1996/06/12  11:19:40  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatPrc.I for:  by apazhani for vds.240
#
# Revision 1.8  1996/06/07  12:31:16  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatPrc.I for:  by apazhani for vds.240
#
# Revision 1.7  1996/05/24  11:38:10  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatPrc.I for:  by ksundar for vds.240
#
# Revision 1.6  1995/09/18  19:04:54  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatPrc.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/09/11  22:17:08  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatPrc.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/31  21:47:40  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatPrc.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/26  16:52:18  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatPrc.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:01:28  pinnacle
# Created: vdbatch/cmd/VDCmdBatPrc.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	raju		creation date
 *	09/../95	raju		add IGEstop()
 *
 ***************************************************************************/

class implementation  VDCmdBatDrw;

/*----------------------------------------------------------------------------
Method : StartProcess

	User defines input data,  selects drawing views and then defines
queue, login etc. Then user selects process type ( interactive or batch ).
Then the following action will be executed.

	This action gets solid for locating objects, locates objects
inside and overlapping drawing view using the solid and then does the
drawing extraction process.


	Raju	7/13/1995   creation

-----------------------------------------------------------------------------*/

#include <stdio.h>

#include "msdef.h"
#include "msmacros.h"

#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "vdbatdrw.h"
#include "vdbatdrwmac.h"
#include "vdsollocdef.h"
#include "vderrmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from VDbatData	  import   VDretrieveData;
from VDmdlview    import   VDmv_give_vv_qry;

/*
 * Test the stop signal.
 */
extern  IGRboolean              IGEstop();

method VDstartProcess ( long *sts )
{
	long			sts1, msg,
				totalProcess,
				indexProcess,
				nbObj,
				nbDv, ii;
	struct GRid		dataObj;
	struct GRobj_env	off_solid;
	struct GRid		locateWin;
	VDdrwBatchInfo		*batchInfo = NULL;
	struct GRobj_env	*objList = NULL;
	GRname			promptInfo;

	int                     num_qry, nb_tot_root;
        int                     nb_root_fnd, num_vvol;
        struct GRid             *qry_list = NULL ;
 

	SetProc( VDCmdBatDrw_VDstartProcess ); Begin

	*sts = MSSUCC;

	/*
	 * get batch control data object
	 */
	dataObj.objid = NULL_OBJID ;
	sts1 = VDgetBatDataObj ( &msg, &dataObj );
	if( !( sts1 & msg & 1 ) || dataObj.objid == NULL_OBJID ){
		__DBGpr_com(" Error in getting VDgetBatDataObj ");
		goto wrapup ;
	}

	/*
	 * get control data
	 */
	sts1 =
	_VD_SEND_OBJ(	dataObj,
			VDbatData.VDretrieveData (
						&msg,
						&nbDv,
						&batchInfo,
						NULL,
						NULL,
						NULL,
						NULL,
						&locateWin ));
	if( !( sts1 & msg & 1 )){
		__DBGpr_com(" Error in retrieving data");
		UI_status("Error retrieving drawing control data");
		goto wrapup ;
	}

	__DBGpr_int( "Number Drawing Views ", nbDv );

	/*
	 * Count the number of drawing-views to process.
	 */
	totalProcess = 0 ;
	indexProcess = 0 ;
	for( ii=0; ii<nbDv; ii++){
		if ( !(me->batchInfo[ii].props & VD_EXTR_EXTR) )  continue;
		totalProcess ++ ;
	}

	for( ii=0; ii<nbDv; ii++){

	  if ( IGEstop() ) break;

	  __DBGpr_int( "Current Drawing Views ", ii );
	  /*
	   * see if the drawing view needs to be processed
	   */
	  if( !(me->batchInfo[ii].props & VD_EXTR_EXTR) )  continue;

	  indexProcess ++ ;

	  sprintf( promptInfo, "Process View %d [%d]",	indexProcess,
							totalProcess );

	  sts1 =
	  ex$message(	in_buff	= promptInfo,
			field	= PROMPT_FIELD,
			justification	= CENTER_JUS );

	  sts1 =
	  vd$drw_solids_from_index(	msg	    = &msg,
					index	    = ii,
					offsetSol = &off_solid );
	  VDS_ERR_CONTINUE( "vd$drw_solids_from_index", sts1, msg, VD_VERBOSE );

	  num_qry = 0 ;
 
          if ( me->props[ii] & VD_MDLV  )
          {
            sts1 = om$send( msg = message VDmdlview.VDmv_give_vv_qry( &msg,
                                        &nb_tot_root,
                                        &nb_root_fnd,
                                        &num_vvol,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &num_qry,
                                        &qry_list,
                                        NULL,
                                        NULL,
                                        NULL ),
                        targetid = me->solid[ii].obj_id.objid,
                        targetos = me->solid[ii].obj_id.osnum );
	    VDS_ERR_CONTINUE("VDmdlview.VDmv_give_vv_qry", sts1, msg,VD_VERBOSE );
           }
 

	  /*
	   * get objects which are inside and overlapping offset solid
	   */
	  nbObj = 0;
	  sts1 = VDlocateWithSolid2 (	&msg,
					1,
					&off_solid.obj_id,
					&off_solid.mod_env,
					num_qry,
					qry_list,
					VD_EL_INSIDE_OVERLAP,
					VD_LIST_OF_OBJS,
					&locateWin,
					"Processing",
					&me->located_chansel,
					my_id,
					&nbObj,
					&objList );
	  _FREE( qry_list ) ;

	  /*
	   * set display depths to old display depths before
	   * doing anything like testing return status.
	   */
	  {
	     long sts2, msg1;

	     sts2 = _VD_SEND_MY( VDCmdBatDrw.set_old_display_depths( &msg1 ));
	     VDS_ERR_RPT ( "set_old_dds", sts2, msg1, VD_VERBOSE );
	  }

	  if(!( sts1 & msg & 1 )){
		UI_status("Error LOCATE WITH SOLID");
		VDS_ERR_CONTINUE( "VDlocateWithSolid2", sts1, msg, VD_VERBOSE );
	  }

	  if( nbObj ){

		__DBGpr_mat( "obj_matrix", objList[0].mod_env.md_env.matrix );

		sprintf(promptInfo,
			"Process View %d [%d] ; Found %d Objects",
				indexProcess, totalProcess, nbObj );

		sts1 =
		ex$message(	in_buff	= promptInfo,
				field	= PROMPT_FIELD,
				justification	= CENTER_JUS );

		VDdrw_DefineProcess(
				&msg,
				&me->ModuleInfo, /* Fucking Env. */
				( me->processTgl == VD_BATCH_PROC ) 
					? TRUE : FALSE , /* batch1_inter0 */
				ii,             /* Control data index. */
				nbObj,          /* Location objects    */
                                objList,
				indexProcess,
				totalProcess );

		/* 
		 * delete offset solid when not needed
		 */
		_FREE( objList );
		objList = NULL ;
	  } /* if ( nbObj ) */
	} /* for( ii=0; ii<nbDv; ii++) */

	wrapup :

		_FREE( batchInfo );
		_FREE( objList );
		End ;

		return OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/

end implementation  VDCmdBatDrw;

