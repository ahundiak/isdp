/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/piperun.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: piperun.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1998/01/16  06:01:20  pinnacle
 * Replaced: vrrt/piperun.C for:  by impd for route
 *
 * Revision 1.1  1998/01/12  23:17:34  pinnacle
 * Loading RT functions
 *
 *
 * History:
 *	01/12/98	Onay	Integration date.
 *
 *************************************************************************/
		/* have to add treatment for olets */
#include "OMtypes.h"
#include "GM.h"
#include "GMndg.h"
#include "AS_status.h"
#include "nddef.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "GMerrordef.h"
#include "ACrg_collect.h"
#include "VRsize.h"
#include "rtiges.h"
#include "AS_status.h"
#include "vrmacros.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"

/* given a tip object in a pipeline, will return PipeRuns, CptFrom
   should be set to -1 for tip objects */

IGRint GetPipeRuns( CompId, FromCpt, PipeRun,
		    PiIndex, ModEnv, SavedRun )
struct GRid *CompId;		/* I 	the start component */
IGRint FromCpt;			/* I 	CP with which current component was
					accessed */
pipe_run_info PipeRun[];	/* O */
IGRint *PiIndex;		/* I/O */
struct GRmd_env *ModEnv;	/* I */
IGRshort  SavedRun; 		/* Internal, set it to -1 when calling */
{
  IGRint status = TRUE;
  IGRshort NextCptNum = -1;
  IGRint TmpCptNum = -1;
  struct GRid NextId;
  int NumbPar, StartCptNum;
  struct ACrg_coll AttList[5];	/* Array of parameters */
  IGRshort NbCpts, Loop = FALSE, ii, jj;
  IGRshort BegNbCpts;
  IGRlong msg;
  IGRboolean bStartRun   = FALSE;
  IGRboolean bBranchPort = FALSE;
  IGRboolean bEncounteredOlet = FALSE;
  IGRboolean bStopTraversal = FALSE;
  IGRchar PipeSpec[9], NextSpec[9];
  IGRchar CompCode[7], NextCompCode[7];
  IGRchar BegCompCode[7];
  IGRint  saverun = -1;
  IGRshort NextNbCpts;

   /*( "CompId->objid:%d\n", CompId->objid );*/

  /* Check to avoid going in Loops -
    If the end CompId of the current run matches with any of the
    preceding PipeRun-End CompIds, the component preceding the
    end Compenent of that run is the run termination component. */

  if( FromCpt == -1 )	/* Tip Component */
  /* find out which CP is connected to a Piping Component */
  {
	status = vr$review_topology (    pMsg = &msg,
                                pComponent = CompId,
                                CptNum = 0,
                                pNeighbor  = &NextId,
                                pNeighCpt  = &TmpCptNum,
                                pMdEnv = ModEnv );
	as$status( action = RET_STATUS );

        NextCptNum = (short)TmpCptNum;

    if( NextId.objid == NULL_OBJID )
    {
	StartCptNum = 1;
	status = vr$review_topology (    pMsg = &msg,
                                pComponent = CompId,
                                CptNum = 1,
                                pNeighbor  = &NextId,
                                pNeighCpt  = &TmpCptNum,
                                pMdEnv = ModEnv );
	as$status( action = RET_STATUS );

        NextCptNum = (short)TmpCptNum;
    }
    else
     StartCptNum = 0;


    /* get piping spec */
    NumbPar = 1;
    strcpy( AttList[0].name, VR_N_CLASS_AN );

    status =
    vr$review_parameters(   		pMsg            = &msg,
                                        pComponent      = CompId,
                                        NbParams        = NumbPar,
                                        pList           = AttList,
                                        pMdEnv          = ModEnv );


	/*C Init First component of PipeRun */
	PipeRun[*PiIndex].run_start.comp_id = *CompId;
	PipeRun[*PiIndex].run_start.conn_pt_id = StartCptNum;
	PipeRun[*PiIndex].run_end.comp_id = NextId;
	PipeRun[*PiIndex].run_end.conn_pt_id = NextCptNum;
	strcpy( PipeRun[*PiIndex].pipe_spec,
		AttList[0].desc.value.att_txt );

	status =
	GetPipeRuns( &NextId, NextCptNum, PipeRun,
			PiIndex, ModEnv, SavedRun );
	return status;
  }

	/* conventional case */

  /* get piping spec & number of CPs */
   NumbPar = 2;
   strcpy( AttList[0].name, VR_N_COMP_CODE_AN );
   strcpy( AttList[1].name, VR_N_NB_CONNECT_IN );


   status =
   vr$review_parameters(   pMsg            = &msg,
                           pComponent      = CompId,
                           NbParams        = NumbPar,
                           pList           = AttList,
                           pMdEnv          = ModEnv );


   NbCpts = (IGRint)AttList[1].desc.value.att_exp;
   strcpy( CompCode, AttList[0].desc.value.att_txt );


  /* If greater than 2, it is a Tee. If less than 2( i.e. 1), it is a dangle */

  if( NbCpts != 2 )
  {
    if( strcmp(CompCode, "PIPING") == 0 &&
	NbCpts	>  2 )
    {
      bBranchPort = TRUE;
      saverun = *PiIndex;
    }
    else
    {
      if( SavedRun != -1 )
      {
        /* save RunEnd information in appropriate piperun */
        PipeRun[SavedRun].run_end.comp_id = *CompId;
        PipeRun[SavedRun].run_end.conn_pt_id = FromCpt;
	SavedRun = -1;
        bStartRun = TRUE;
      }
      else
      {
        /* save RunEnd information */
        PipeRun[*PiIndex].run_end.comp_id = *CompId;
        PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt;
        bStartRun = TRUE;
      }
    }
  }

  if( strcmp(&CompCode[1], "OLET" ) == 0 )
  {
    bEncounteredOlet = TRUE;
  }

  for( ii=0; ii < NbCpts; ++ii )
  {
	/*C Skip the from connection point */
	if ( ii == FromCpt ) continue;

	/*C Find neighbor to propagate */
	status =
	vr$review_topology (    pMsg = &msg,
                                pComponent = CompId,
                                CptNum = ii,
                                pNeighbor  = &NextId,
                                pNeighCpt  = &TmpCptNum,
                                pMdEnv = ModEnv );
	as$status( action = RET_STATUS );

        NextCptNum = (short)TmpCptNum;


	if( NextId.objid == NULL_OBJID )
        {/* End run for non terminating components */
		if( SavedRun != -1 )
		{
	   		PipeRun[SavedRun].run_end.comp_id= *CompId;
	   		PipeRun[SavedRun].run_end.conn_pt_id = FromCpt;
		}
		else
		{
	   		PipeRun[*PiIndex].run_end.comp_id= *CompId;
	   		PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt;
		}
		SavedRun = -1;
		bStartRun = TRUE;
                continue;
         }

	/* Check next component for change in piping spec */
        NumbPar = 3;

        strcpy( AttList[0].name, VR_N_CLASS_AN );
	strcpy( AttList[1].name, VR_N_COMP_CODE_AN );
	strcpy( AttList[2].name, VR_N_NB_CONNECT_IN );

        status =
        vr$review_parameters( pMsg            = &msg,
                              pComponent      = &NextId,
                              NbParams        = NumbPar,
                              pList           = AttList,
                              pMdEnv          = ModEnv );

        strcpy( PipeSpec, PipeRun[*PiIndex].pipe_spec );
        strcpy( NextSpec, AttList[0].desc.value.att_txt );
	strcpy( NextCompCode, AttList[1].desc.value.att_txt );
	NextNbCpts = (IGRint)AttList[2].desc.value.att_exp;

	if( bEncounteredOlet &&
	    (strcmp(NextCompCode, "PIPING") ==0) &&
	    NextNbCpts > 2 )
	{
          NumbPar = 2;
	  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );
	  strcpy( AttList[1].name, VR_N_COMP_CODE_AN );
	  status =
	  vr$review_parameters( pMsg            = &msg,
				pComponent	=
				     &(PipeRun[*PiIndex].run_start.comp_id),
				NbParams        = NumbPar,
				pList           = AttList,
				pMdEnv          = ModEnv );
	  BegNbCpts = (IGRint)AttList[0].desc.value.att_exp;
	  strcpy( BegCompCode, AttList[1].desc.value.att_txt );

	  if( BegNbCpts == 1 )
	  {
	   return ErrDangleLeadsToOlet;
	  }
	  else
	  {
	   /* save run end info & avoid propogation */
	   PipeRun[*PiIndex].run_end.comp_id= *CompId;
	   PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt;
	   bStopTraversal = TRUE;
	  }
	}

	if( bBranchPort )
	{
	  if( strcmp(&NextCompCode[1], "OLET") == 0 )
	  {
	    /* start a new run for olets */
	    (*PiIndex)++;
	    PipeRun[*PiIndex].run_start.comp_id = *CompId;
	    PipeRun[*PiIndex].run_start.conn_pt_id = ii;
	    PipeRun[*PiIndex].run_end.comp_id = NextId;
	    PipeRun[*PiIndex].run_end.conn_pt_id = NextCptNum;

	    strcpy(	PipeRun[*PiIndex].pipe_spec,
			AttList[0].desc.value.att_txt );

	    /* Do not use saved run for branch ports - 21 Sep 95 */
	    SavedRun = -1;
	  }
	  else
	  {
	    /* Propogate on neighbor with last argument set to
	       saverun */
	    SavedRun = saverun;
	  }
	}

	if( !bStartRun &&	/* a run is going to start anyway */
	    (strcmp(NextSpec, PipeSpec) != 0) )
	{
	  if( SavedRun != -1 )
	  {
	    /* save run end info, using the saved run */
            PipeRun[SavedRun].run_end.comp_id = *CompId;
            PipeRun[SavedRun].run_end.conn_pt_id = FromCpt;
            bStartRun = TRUE;
	    SavedRun = -1;
	  }
	  else
	  {
	    /* save run end info */
            PipeRun[*PiIndex].run_end.comp_id = *CompId;
            PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt;
            bStartRun = TRUE;
	  }
	}


	/*C if CompId ends a run : it begins all the next ones */
	if ( bStartRun )
	{
		(*PiIndex)++;
		PipeRun[*PiIndex].run_start.comp_id = *CompId;
		PipeRun[*PiIndex].run_start.conn_pt_id = ii;
		PipeRun[*PiIndex].run_end.comp_id = NextId;
		PipeRun[*PiIndex].run_end.conn_pt_id = NextCptNum;

		strcpy(	PipeRun[*PiIndex].pipe_spec,
			AttList[0].desc.value.att_txt );
		
	}

	/*C Make sure that neighbor is not already processed */
	for( jj=0; jj < *PiIndex; ++jj )
	{
		if( PipeRun[jj].run_end.comp_id.objid == NextId.objid &&
		    PipeRun[jj].run_end.comp_id.osnum == NextId.osnum )
		{
			/* This pipe run ends with CompId */
			Loop = TRUE;
		}
	}

	if( Loop )
	{
		/* save RunEnd information */
		PipeRun[*PiIndex].run_end.comp_id = *CompId;
		PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt;

		/* if Loop && run_start == run_end, remove pipe run.
		   takes care of dummy runs */
		if( PipeRun[*PiIndex].run_start.comp_id.objid
		    == PipeRun[*PiIndex].run_end.comp_id.objid )
		 --(*PiIndex);

		Loop = FALSE;
	}
	else if( bStopTraversal )
	      ;
	else
	{
		/*C Propagate on neighbor */
		status =
		GetPipeRuns( &NextId, NextCptNum, PipeRun,
				PiIndex, ModEnv, SavedRun );
	}
  }

  return status;
}
