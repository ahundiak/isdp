/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt_STEP/piperun.C
 *
 * Description:
 *      This is another copy of the vrrt/piperun.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reason these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: piperun.C,v $
 *	Revision 1.2  2001/02/20 01:16:58  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *	Initial import to CVS
 *	
 * Revision 1.3  1999/04/10  21:00:36  pinnacle
 * Replaced: vrrt_STEP/piperun.C for:  by apazhani for route
 *
 * Revision 1.1  1998/11/06  19:24:28  pinnacle
 * initial revision
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *      04/11/99        Alwin     Modified to incorporate the change in piperun
 *				  whenever there's a change in "seq_no" 
 *
 *************************************************************************/
		/* have to add treatment for olets */
#include "VDtypedef.h"
/*
#include <stdio.h>
#include "OMtypes.h"
#include "AS_status.h"
#include "nddef.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "ACrg_collect.h"
*/
#include "GM.h"
#include "GMndg.h"
#include "GMerrordef.h"
#include "VRsize.h"
#include "rtiges.h"
#include "AS_status.h"
#include "vrmacros.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "vrdbgmacros.h"

IGRint RT_IsSpecialComp( CompId, NextId, ModEnv, PipeRun, PiIndex, FirstCptNum, NextCptNum )
struct GRid *CompId, *NextId;
struct GRmd_env *ModEnv;
pipe_run_info PipeRun[];	/* Output */
IGRint *PiIndex;		/* Output */
IGRint *FirstCptNum, *NextCptNum;
{
  IGRint NumbPar, TmpCptNum=-1, FromCpt=-1;
  IGRint NbCpts = -1, status;
  IGRlong msg;
  struct ACrg_coll AttList[5];
  struct GRid NewNextId;

  SetProc( Fn RT_IsSpecialComp ); Begin 

  __DBGpr_obj( " Component Id ", *NextId );

  NumbPar = 2;
  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );
  strcpy( AttList[1].name, VR_N_COMP_TYPE_IN );

  status =
  vr$review_parameters(   pMsg            = &msg,
                          pComponent      = NextId,
                          NbParams        = NumbPar,
                          pList           = AttList,
                          pMdEnv          = ModEnv );

  NbCpts = (IGRint)AttList[0].desc.value.att_exp;

  /* added by alwin ...to account for VALVES...check the "comp_type of the
  component = 4 ( VALVE ). If so add that as a separate run and continue
  further. */

  FromCpt = (short)*FirstCptNum;
  if( NbCpts == 2 ) 
  {
      __DBGpr_int( " Nb. of Pipe runs ", *PiIndex );
      __DBGpr_dbl( " Comp_type ", AttList[1].desc.value.att_exp );

      if( AttList[1].desc.value.att_exp == VRP_V_VALVE_TYPE ) 
      {
         /* Then treat this component as a separate run, per MariSTEP request.
         Alwin */
         __DBGpr_com( " Its a VALVE..." );

         /* get piping spec */
         NumbPar = 1;
         strcpy( AttList[0].name, VR_N_CLASS_AN );

         status =
         vr$review_parameters(             pMsg            = &msg,
                                           pComponent      = CompId,
                                           NbParams        = NumbPar,
                                           pList           = AttList,
                                           pMdEnv          = ModEnv );

	 /* If the next component is VALVE then this component may be 
	 FLANGE component ( not true always ). And this should be the last
	 component of the run. B'cas VALVE itself is considered as a single
	 run. */

         PipeRun[*PiIndex].run_end.comp_id = *CompId;
         PipeRun[*PiIndex].run_end.conn_pt_id = (short)FromCpt;
         strcpy( PipeRun[*PiIndex].pipe_spec, AttList[0].desc.value.att_txt );

         status =
         vr$review_parameters(             pMsg            = &msg,
                                           pComponent      = NextId,
                                           NbParams        = NumbPar,
                                           pList           = AttList,
                                           pMdEnv          = ModEnv );

	 TmpCptNum = -1;
	 status = vr$review_topology (
                            pMsg 	= &msg,
                            pComponent 	= CompId,
                            CptNum 	= FromCpt,
                            pNeighbor  	= NextId, 
                            pNeighCpt  	= &TmpCptNum,
                            pMdEnv 	= ModEnv );
	 //as$status( action = RET_STATUS );
	 __DBGpr_int( " Starting Cpt of VALVE ", (IGRshort)TmpCptNum );

	 *FirstCptNum = (short)TmpCptNum;

         (*PiIndex)++;
         PipeRun[*PiIndex].run_start.comp_id = *NextId;
         PipeRun[*PiIndex].run_start.conn_pt_id = *FirstCptNum;
         PipeRun[*PiIndex].run_end.comp_id = *NextId;
         PipeRun[*PiIndex].run_end.conn_pt_id = ( (*FirstCptNum) ? 0 : 1 );
         strcpy( PipeRun[*PiIndex].pipe_spec, AttList[0].desc.value.att_txt );

	 FromCpt = ( (*FirstCptNum) ? 0 : 1 );

         __DBGpr_int( " Nb. of Pipe runs ", *PiIndex );

	 /* Get the next component adjacent to the VALVE */
	 CompId->objid = NULL_OBJID;
	 status = vr$review_topology (
                            pMsg 	= &msg,
                            pComponent 	= NextId,
                            CptNum 	= FromCpt,
                            pNeighbor  	= CompId,
                            pNeighCpt  	= &TmpCptNum,
                            pMdEnv 	= ModEnv );
	 __DBGpr_obj( " Component Id next to Valve ", *CompId );

	 if( CompId->objid != NULL_OBJID )
	 {
	     *FirstCptNum = (short)TmpCptNum;
	     __DBGpr_int( " Cpt num of VALVE's next comp ", *FirstCptNum );

	     FromCpt = ( *FirstCptNum ) ? 0 : 1;

	     *NextCptNum = -1;
	     status = vr$review_topology (
				pMsg 	= &msg,
				pComponent 	= CompId,
				CptNum 	= FromCpt,
				pNeighbor  	= NextId, 
				pNeighCpt  	= NextCptNum,
				pMdEnv 	= ModEnv );
	     //as$status( action = RET_STATUS );
	     __DBGpr_int( " Cpt of VALVE's 2nd next comp", (short)*NextCptNum );
	     __DBGpr_obj( " Valve's 2 nd comp id ", *NextId );
	 }
	 else
	 { 
	     End
	     return 0; 
	 }

	 End
	 return VRP_V_VALVE_TYPE;
      }
      else if( AttList[1].desc.value.att_exp == VRP_V_REDUCER_TYPE ) 
      { 
	 IGRint SaveRun;

         /* get piping spec */
	 __DBGpr_com( " Its a REDUCER " );
         NumbPar = 1;
         strcpy( AttList[0].name, VR_N_CLASS_AN );

         status =
         vr$review_parameters(             pMsg            = &msg,
                                           pComponent      = NextId,
                                           NbParams        = NumbPar,
                                           pList           = AttList,
                                           pMdEnv          = ModEnv );

	 /* to obtain the next_cpt_num */
	 *NextCptNum = -1;
	 __DBGpr_int( " From Connect Point no ", FromCpt );
	 status = vr$review_topology (
                            pMsg 	= &msg,
                            pComponent 	= CompId,
                            CptNum 	= FromCpt,
                            pNeighbor  	= NextId,
                            pNeighCpt  	= &TmpCptNum,
                            pMdEnv 	= ModEnv );
	 //as$status( action = RET_STATUS );

	 __DBGpr_int( " Run ending @ REDUCER...CptNum ", (short)TmpCptNum );
	 __DBGpr_obj( " Reducer Id ", *NextId );

	 *NextCptNum = ( (short)TmpCptNum ) ? 0 : 1;
         PipeRun[*PiIndex].run_end.comp_id = *NextId;
         //PipeRun[*PiIndex].run_end.conn_pt_id = (short)TmpCptNum; //changed NextCptNum -> TmpCptNum
         PipeRun[*PiIndex].run_end.conn_pt_id = *NextCptNum; 
         strcpy( PipeRun[*PiIndex].pipe_spec, AttList[0].desc.value.att_txt );

	 /* Get the First component from the list ...*/
         status = vr$review_topology (
                            pMsg        = &msg,
                            pComponent  = NextId,
                            CptNum      = *NextCptNum,
                            pNeighbor   = &NewNextId,
                            pNeighCpt   = &TmpCptNum,
                            pMdEnv      = ModEnv );
         as$status( action = RET_STATUS );

         __DBGpr_obj( " Component Id next to REDUCER ", NewNextId );
	 __DBGpr_int( " Connect point ...", (short)TmpCptNum );

         *FirstCptNum = (short)TmpCptNum;
	 *CompId = NewNextId;

	 /* Get the next component from the list ...*/
         status = vr$review_topology (
                            pMsg        = &msg,
                            pComponent  = CompId,
                            CptNum      = ( (*FirstCptNum) ? 0 : 1 ),
                            pNeighbor   = NextId,
                            pNeighCpt   = &TmpCptNum,
                            pMdEnv      = ModEnv );
         as$status( action = RET_STATUS );

	 *NextCptNum = (short)TmpCptNum;

         status =
         vr$review_parameters(             pMsg            = &msg,
                                           pComponent      = CompId,
                                           NbParams        = NumbPar,
                                           pList           = AttList,
                                           pMdEnv          = ModEnv );

	 SaveRun = *PiIndex;

	 SaveRun++;
         PipeRun[SaveRun].run_start.comp_id = *CompId;
         PipeRun[SaveRun].run_start.conn_pt_id = (short)(*FirstCptNum);
         strcpy( PipeRun[SaveRun].pipe_spec, AttList[0].desc.value.att_txt );

	 /* Call again to check whether the next component is VALVE or not */
	 TmpCptNum = (*FirstCptNum) ? 0 : 1;
	 status = RT_IsSpecialComp( CompId, NextId, ModEnv, 
	 			 PipeRun, &SaveRun, 
				 &TmpCptNum, NextCptNum );

	 if( ( status == VRP_V_VALVE_TYPE ) || 
	     ( status == VRP_V_REDUCER_TYPE ) ) 
	 {
	      __DBGpr_com( " Yes the next component is VALVE/REDUCER " );
	      *PiIndex = SaveRun;
	      *FirstCptNum = TmpCptNum;

	      __DBGpr_obj( " New CompId ", *CompId );
	      __DBGpr_obj( " New NextId ", *NextId );
	      End
	      return status;
	 }

	 End
	 return VRP_V_REDUCER_TYPE;
      }
      else 
      { 
	__DBGpr_com( " Its not a Special component " );
	End
	return RTERR;
      }
  }
/***********************
  else if( NbCpts == 1 )
  {
	 __DBGpr_com( " Single Connect Point component..so end Run " );
         NumbPar = 1;
         strcpy( AttList[0].name, VR_N_CLASS_AN );

         status =
         vr$review_parameters(             pMsg            = &msg,
                                           pComponent      = NextId,
                                           NbParams        = NumbPar,
                                           pList           = AttList,
                                           pMdEnv          = ModEnv );

         PipeRun[*PiIndex].run_end.comp_id = *NextId;
         PipeRun[*PiIndex].run_end.conn_pt_id = (short)FromCpt;
         strcpy( PipeRun[*PiIndex].pipe_spec, AttList[0].desc.value.att_txt );
	 (*PiIndex)++;
	 End
	 return RTERR;
  }
***********************/
  else
  {
     __DBGpr_com( " Its not a two-cpt component " );
    End
    return RTERR;
  }
}

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
  IGRboolean bStartRun = FALSE, bIsPrevComp_single_cpt = FALSE;
  IGRshort NextCptNum = -1;
  IGRint TmpCptNum = -1;
  struct GRid NextId;
  int NumbPar, StartCptNum;
  struct ACrg_coll AttList[10];	/* Array of parameters */
  IGRshort NbCpts, Loop = FALSE, ii, jj=0;
  IGRshort BegNbCpts;
  IGRlong msg;
  IGRboolean bBranchPort = FALSE;
  IGRboolean bEncounteredOlet = FALSE;
  IGRboolean bIsBranchComponent = FALSE;
  IGRboolean bStopTraversal = FALSE;
  IGRchar PipeSpec[9], NextSpec[9];
  IGRchar PipeSeqNo[20], NextSeqNo[20];
  IGRchar CompCode[7], NextCompCode[7];
  IGRchar BegCompCode[7];
  IGRint  saverun = -1;
  IGRshort NextNbCpts, CptNum, FirstCptNum;

  TGRid       TeeCompId; // TEE component tracer ... AAAA

  SetProc( Fn GetPipeRuns ); Begin

  TeeCompId.objid = NULL_OBJID;

  __DBGpr_obj( " CompId ", *CompId );
  __DBGpr_int( " Nb. of Pipe Runs ", *PiIndex );

  /*Check to avoid going in Loops -
    If the end CompId of the current run matches with any of the
    preceding PipeRun-End CompIds, the component preceding the
    end Compenent of that run is the run termination component. */

  if( FromCpt == -1 )	/* Tip Component */
  /* find out which CP is connected to a Piping Component */
  {
    __DBGpr_com( " Its a Beginning of the Pipe Run..." );
    status = vr$review_topology (    
			    pMsg = &msg,
			    pComponent = CompId,
			    CptNum = 0,
                            pNeighbor  = &NextId,
                            pNeighCpt  = &TmpCptNum,
                            pMdEnv = ModEnv );
    as$status( action = RET_STATUS );

    __DBGpr_obj( " Next Component Id ", NextId );
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

    bStartRun = FALSE;
    status =
    GetPipeRuns( &NextId, NextCptNum, PipeRun,
			PiIndex, ModEnv, SavedRun );
    End
    return status;
  }

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

  __DBGpr_int( " Nb. of Connect points ", NbCpts );

  /* If greater than 2, it is a Tee. If less than 2( i.e. 1), it is a dangle */
  /* conventional case. Get piping spec & number of CPs. */

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
	__DBGpr_com( "0 bStartRun set to TRUE " );
      }
      else
      {
	NumbPar = 1;
	strcpy( AttList[0].name, VR_N_CLASS_AN );

	status =
	vr$review_parameters(  		pMsg            = &msg,
				    	pComponent      = CompId,
				    	NbParams        = NumbPar,
				    	pList           = AttList,
				    	pMdEnv          = ModEnv );

        /* save RunEnd information */
        PipeRun[*PiIndex].run_end.comp_id = *CompId;
        PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt;
	strcpy( PipeRun[*PiIndex].pipe_spec, AttList[0].desc.value.att_txt );
	__DBGpr_com( " Run closed " );
        //bStartRun = TRUE;

	if( NbCpts == 1 )
	{
	   (*PiIndex)++; 
	   bIsPrevComp_single_cpt = TRUE;
	   SavedRun = -1;
           bStartRun = TRUE;
	}

	/* AAAA For components having more than 2 cpts should be handled with
	care. We should ensure that the components are not repeated in the TREE.
	In this case, we should not start the Run with a TEE; when that TEE 
	was the end of the previous run. Alwin */

	if( NbCpts > 2 )
	{
	  __DBGpr_com( " It's a TEE " );
	  bIsBranchComponent = TRUE; /* added mainly for TEE, CROSS, etc */
	  TeeCompId = *CompId;
	  (*PiIndex)++;
	}
      }
    }
  }

  if( strcmp(&CompCode[1], "OLET" ) == 0 )
  {
    bEncounteredOlet = TRUE;
  }

  /* AAAA for line_sequence number. Alwin */
  NumbPar = 1;
  strcpy( AttList[0].name, VR_N_CLASS_AN );

  status =
  vr$review_parameters( pMsg            = &msg,
			pComponent      = CompId,
			NbParams        = NumbPar,
			pList           = AttList,
			pMdEnv          = ModEnv );
  strcpy( PipeSpec, AttList[0].desc.value.att_txt );

#ifdef vdsDEBUG
  for( ii=0; ii<*PiIndex; ii++ )
  {
          printf( "%2d)  %3d %3d     %3d %3d         %s\n",
                            ii,
                            PipeRun[ii].run_start.comp_id.objid,
                            PipeRun[ii].run_start.conn_pt_id,
                            PipeRun[ii].run_end.comp_id.objid,
                            PipeRun[ii].run_end.conn_pt_id,
                            PipeRun[ii].pipe_spec );
  }
#endif

  __DBGpr_int( " Nb. of Connect Points for the Comp. ", NbCpts );
  for( ii=0; ii < NbCpts; ++ii )
  {
	IGRboolean bIsRepetition = FALSE;

	__DBGpr_int( " Index, ii ", ii );
	__DBGpr_int( " FromCpt ", FromCpt );

	/*C Skip the from connection point */
	if ( ii == FromCpt ) continue;

	/* this is to ensure to continue the traversing with the remaining 
	cpt's */
	if( bIsBranchComponent )
	   *CompId = TeeCompId;

	/* AAAA for line_sequence number. Alwin */
	NumbPar = 1;
	strcpy( AttList[0].name, VR_N_SEQ_NUMBER_AN );

        status =
        vr$review_parameters( pMsg            = &msg,
                              pComponent      = CompId,
                              NbParams        = NumbPar,
                              pList           = AttList,
                              pMdEnv          = ModEnv );

        strcpy( PipeSeqNo, AttList[0].desc.value.att_txt );
	__DBGpr_str( " Pipe Sequence Number ", PipeSeqNo );
	/* AAAA for line_sequence number. Alwin */

	__DBGpr_int( " Proceeding through the Cpt ", ii );
	status =
	vr$review_topology (    pMsg = &msg,
                                pComponent = CompId,
                                CptNum = ii,
                                pNeighbor  = &NextId,
                                pNeighCpt  = &TmpCptNum,
                                pMdEnv = ModEnv );
	as$status( action = RET_STATUS );

	__DBGpr_obj( " Next Component Id ", NextId );

        NextCptNum = (short)TmpCptNum;
	__DBGpr_int( " Next Comp CptNum ", NextCptNum );

	/* AAAAA additional check added to prevent repetition in the case of
	networks with loop */
	/*C Make sure that neighbor is not already processed */

	__DBGpr_com( " Additional check made ... " );
	__DBGpr_int( " Nb. of Runs ", *PiIndex );
	//if( bIsBranchComponent )
	for( jj=0; jj < *PiIndex; ++jj )
	{
	    if( ( PipeRun[jj].run_end.comp_id.objid == NextId.objid ) &&
		( PipeRun[jj].run_end.comp_id.osnum == NextId.osnum ) )
	    {
		  jj=*PiIndex;
		  bIsRepetition = TRUE;
	    }
	}

	if( bIsRepetition ) continue; /* If there is a repitition then
					continue with the next Cpt. Alwin */

	/*C Find neighbor to propagate */

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
		__DBGpr_com( " End run terminating " );
                continue;
        }

	/* Check next component for change in piping spec */
        NumbPar = 4;

        strcpy( AttList[0].name, VR_N_CLASS_AN );
	strcpy( AttList[1].name, VR_N_COMP_CODE_AN );
	strcpy( AttList[2].name, VR_N_NB_CONNECT_IN );

	/* AAAA for line_sequence number. Alwin */
	strcpy( AttList[3].name, VR_N_SEQ_NUMBER_AN );

        status =
        vr$review_parameters( pMsg            = &msg,
                              pComponent      = &NextId,
                              NbParams        = NumbPar,
                              pList           = AttList,
                              pMdEnv          = ModEnv );

        /***strcpy( PipeSpec, PipeRun[*PiIndex].pipe_spec ); Its done earlier*/
        strcpy( NextSpec, AttList[0].desc.value.att_txt );
	strcpy( NextCompCode, AttList[1].desc.value.att_txt );
	NextNbCpts = (IGRint)AttList[2].desc.value.att_exp;

	/* AAAA for line_sequence number. Alwin */
        strcpy( NextSeqNo, AttList[3].desc.value.att_txt );
	__DBGpr_str( " Pipe Spec Name ", PipeSpec );
	__DBGpr_str( " Next Pipe Spec Name ", NextSpec );
	__DBGpr_str( " Next Pipe Sequence Number ", NextSeqNo );

	if( bEncounteredOlet &&
	    ( strcmp(NextCompCode, "PIPING") ==0 ) &&
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
	   End
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
		 strcmp(NextSpec, PipeSpec) != 0 ) 
	    {
	      __DBGpr_com( " There's a difference in spec " );
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

	    /* added by alwin ...*/
	    CptNum = ii; /* backup the old connect point ...*/
	    FirstCptNum = ii;

        {
            /* This says that the previous Run has ended up with a TEE comp. */
            /* See to that we don't start the next RUN with the same TEE 
	    component */

            if( bIsBranchComponent )
            {
	      TeeCompId = *CompId;
              *CompId = NextId;

	      //(*PiIndex)++;
	      __DBGpr_int( " No. of Pipe Runs ", *PiIndex );
	      PipeRun[*PiIndex].run_start.comp_id = *CompId;
	      PipeRun[*PiIndex].run_start.conn_pt_id = NextCptNum; 
	      strcpy( PipeRun[*PiIndex].pipe_spec, NextSpec ); 

	      goto process_differ_seqno;

	      /* If this component happens to be Single Connect Pt. component
	      then I need to end the run and exit the function */
	      {
		  NumbPar = 1;
		  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

		  status =
		  vr$review_parameters( pMsg            = &msg,
					pComponent	= CompId,
					NbParams        = NumbPar,
					pList           = AttList,
					pMdEnv          = ModEnv );

		  if( (int) AttList[0].desc.value.att_exp == 1 )
		  {
		      goto skip_everything;
		  }
	      }

              FirstCptNum = ( (short) NextCptNum )  ? 0 : 1;

              vr$review_topology (    pMsg = &msg,
                                      pComponent = CompId,
                                      CptNum = FirstCptNum,
                                      pNeighbor  = &NextId,
                                      pNeighCpt  = (IGRint*)&NextCptNum,
                                      pMdEnv = ModEnv );
              as$status( action = RET_STATUS );

              NumbPar = 3;
              strcpy( AttList[0].name, VR_N_CLASS_AN );
              strcpy( AttList[1].name, VR_N_NB_CONNECT_IN );
	      strcpy( AttList[2].name, VR_N_SEQ_NUMBER_AN );

              status =
              vr$review_parameters( pMsg            = &msg,
                                    pComponent      = &NextId,
                                    NbParams        = NumbPar,
                                    pList           = AttList,
                                    pMdEnv          = ModEnv );
	      bStartRun = FALSE;

	      if( strcmp( NextSpec, AttList[2].desc.value.att_txt ) )
	      {
		 strcpy( PipeSpec, AttList[2].desc.value.att_txt );
		 bIsBranchComponent = FALSE;
		 goto process_differ_seqno;
	      }

	      PipeRun[*PiIndex].run_end.comp_id = NextId;
	      PipeRun[*PiIndex].run_end.conn_pt_id = NextCptNum;
	      strcpy( PipeRun[*PiIndex].pipe_spec,
		      AttList[0].desc.value.att_txt );

	      if( (IGRint)AttList[0].desc.value.att_exp == 1 )
	      {
	        goto skip_everything;
		*CompId = TeeCompId; 		
		continue;
              }
            }
        }

process_differ_seqno :
	    /* AAAA for line_sequence number. Alwin */
	    if( !bIsBranchComponent ) /* If the first component is a branch
					component then we don't to perform
					this line_sequence number check. B'cas
					anyway a new run would've started */
	    if( strcmp(NextSeqNo, PipeSeqNo) )
	    {
	       for( jj=0; jj < *PiIndex; ++jj )
	       {
		 if( PipeRun[jj].run_end.comp_id.objid == CompId->objid &&
		     PipeRun[jj].run_end.comp_id.osnum == CompId->osnum )
		 {
		    __DBGpr_obj( "Component is already processed", *CompId );
		    Loop = TRUE;
		 }
		 else Loop = FALSE;
	       }

	       if( !Loop )
	       {
		  strcpy( AttList[0].name, VR_N_COMP_TYPE_IN );

		  status =
		  vr$review_parameters(   pMsg            = &msg,
					  pComponent      = &NextId,
					  NbParams        = NumbPar,
					  pList           = AttList,
					  pMdEnv          = ModEnv );

		  if((IGRint)AttList[0].desc.value.att_exp != VRP_V_VALVE_TYPE )
		  {
		    /* They're different. So end the old run and create a 
		    New Pipe Run */ 
		    PipeRun[*PiIndex].run_end.comp_id = *CompId;
		    /*PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt; */
		    PipeRun[*PiIndex].run_end.conn_pt_id = (short)ii;
		    strcpy( PipeRun[*PiIndex].pipe_spec, PipeSpec );
		    SavedRun = -1;

		    //if( !bIsBranchComponent )
		    {
		      ++(*PiIndex);

		      /*fill in the run starting component information. 
			01/27/99*/
		      __DBGpr_com( " Filling the New Run Information ..." );
		      PipeRun[*PiIndex].run_start.comp_id = NextId;
		      PipeRun[*PiIndex].run_start.conn_pt_id =(short)NextCptNum;
		      strcpy( PipeRun[*PiIndex].pipe_spec, NextSpec );

		      *CompId = NextId;
		      FirstCptNum = (short)NextCptNum;
		    }
		  }
	       }
	       else Loop = FALSE;
	    }

	/* Check for special components like VALVE/REDUCER ...*/
	if( 1 )
	{
	   __DBGpr_int( " Connect Point No. ", FirstCptNum );
	   __DBGpr_obj( " Component Id ", *CompId );
	   __DBGpr_obj( " Next Comp. Id ", NextId );

	   __DBGpr_com( " Calling Fn RT_IsSpecialComp ..." );
	   status = RT_IsSpecialComp( CompId, &NextId, ModEnv, PipeRun,
				       PiIndex, &FirstCptNum, &NextCptNum );

	   if( ( status == VRP_V_VALVE_TYPE ) || 
	       ( status == VRP_V_REDUCER_TYPE ) )
	   {
		 __DBGpr_com( " It's a VALVE or REDUCER " );
		 bStartRun = TRUE;
	   }
	   else if( CompId->objid == NULL_OBJID )
	   {
	      continue;
	   }
	}

	/*C if CompId ends a run : it begins all the next ones */
	if ( bStartRun )
	{
	    __DBGpr_com( " New Run is beginning ..." );
	    (*PiIndex)++;
	    __DBGpr_int( " No. of Pipe Runs ", *PiIndex );
	    PipeRun[*PiIndex].run_start.comp_id = *CompId;

	    /*changed ii->FirstCptNum */
	    PipeRun[*PiIndex].run_start.conn_pt_id = FirstCptNum; 

	    PipeRun[*PiIndex].run_end.comp_id = NextId;
	    PipeRun[*PiIndex].run_end.conn_pt_id = NextCptNum;

	    strcpy( PipeRun[*PiIndex].pipe_spec,
		    AttList[0].desc.value.att_txt );
	}

skip_everything :

	/*C Make sure that neighbor is not already processed */
	for( jj=0; jj < *PiIndex; ++jj )
	{
		if( PipeRun[jj].run_end.comp_id.objid == NextId.objid &&
		    PipeRun[jj].run_end.comp_id.osnum == NextId.osnum )
		{
			/* This pipe run ends with CompId */
			__DBGpr_obj( "Component is already processed", NextId);
			Loop = TRUE;
		}
	}

Check_for_looping :
	if( Loop )
	{
		/* save RunEnd information */
		PipeRun[*PiIndex].run_end.comp_id = *CompId;
		PipeRun[*PiIndex].run_end.conn_pt_id = FromCpt;

		/* if Loop && run_start == run_end, remove pipe run.
		   takes care of dummy runs */

#ifdef UNWANTED_DELETION
		if( PipeRun[*PiIndex].run_start.comp_id.objid
		    == PipeRun[*PiIndex].run_end.comp_id.objid )
		{
		     __DBGpr_com( " ###Decreasing the count by one### " );
		     --(*PiIndex);
		}
#endif

		Loop = FALSE;
	}
	else if( bStopTraversal )
	      ;
	else
	{
		/*C Propagate on neighbor */
		__DBGpr_com( " propagate on neighbour ..." );
		status =
		GetPipeRuns( &NextId, NextCptNum, PipeRun,
				PiIndex, ModEnv, SavedRun );
	}

	if( TeeCompId.objid != NULL_OBJID )
	  *CompId = TeeCompId; // for the TEE component let it procee through
			       // next connect point. AAAA 
  }

#ifdef vdsDEBUG
  __DBGpr_int( " Nb. of PipeRuns ", *PiIndex );
  for( ii=0; ii < *PiIndex; ++ii )
  {
          printf( "%2d)  %3d %3d     %3d %3d         %s\n",
                            ii,
                            PipeRun[ii].run_start.comp_id.objid,
                            PipeRun[ii].run_start.conn_pt_id,
                            PipeRun[ii].run_end.comp_id.objid,
                            PipeRun[ii].run_end.conn_pt_id,
                            PipeRun[ii].pipe_spec );
  }
#endif

  End
  return status;
}
