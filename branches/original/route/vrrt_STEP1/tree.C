/* $Id: tree.C,v 1.2 2001/02/20 01:17:04 build Exp $ */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP1/tree.C
 *
 * Description:
 *      This is copy of the file vrrt/fun.C and modified to build the StepTree.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: tree.C,v $
 *      Revision 1.2  2001/02/20 01:17:04  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  1999/04/10  21:06:14  pinnacle
 * Replaced: vrrt_STEP1/tree.C for:  by apazhani for route
 *
 * Revision 1.2  1998/12/14  20:41:28  pinnacle
 * Replaced: vrrt_STEP1/tree.C for:  by apazhani for route
 *
 * Revision 1.1  1998/11/06  20:15:02  pinnacle
 * Alwin
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *      12/14/98        Alwin     Added some functions and modified
 *				  the original VDmt_tree_init() function.
 *      04/11/99        Alwin     Fixed the infinite looping problems. Fixed
 *				  all the node_flag issues. Wrote the code
 *				  for the "node_flag" setting for "lines".
 *
 *************************************************************************/

#include <stdio.h>
#include "GM.h"
#include "GMndg.h"
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
#include "vrmacros.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "OMlimits.h"
#include "vrdbgmacros.h"

#include "VDsa.h"
#include "VDatMaster.h"
#include "VDmem.h"
#include "VDppl1.h"

#define VR_CMP_TYP_PIPE_BEND		12
#define VR_CMP_TYP_PIPE_DANGLE		-1
#define VR_CMP_TYP_PIPE_STRAIGHT 	 0
#define VR_CMP_TYP_PIPE_FLANGE 		 5

/* These variables are defined as Global variables. As I need this information
while filling up the "PORT" Node Attributes in finding out whether a port
"Originates/End" of a RUN/LINE/SYSTEM. */

static int 		PiRunCount;
static pipe_run_info 	**p_rbuff_ptr;
static TGRobj_env	fc_id; /* To keep track of the "collector" id in which
				GUID are accounted */

extern int VDmt_create_GUID();
extern int VDRTConstPartJoints(); /* Implemented in temp.C file */
extern int VDRTConstRunJoints(); /* Implemented in temp.C file */
extern int VDRTConstLineJoints(); /* Implemented in temp.C file */

/* This function gets the Components name, given the Component Id. This name
is obtained by Calling the PPL. */

IGRint VDRTGetCompName( struct GRid part_id, struct GRmd_env md_env,
			IGRchar *szObjName )
{
  IGRint pplRET;
  IGRint NumbPar;
  TGRid pplID, COMP_ID;
  TACrg_coll AttList[2];
  IGRchar COMP_NAME[128];
  IGRlong msg;

  SetProc( Fn VDRTGetCompName ); Begin 

   /* where the RTgetname is the name of the PPL. Alwin */
   /* Load the ppl */

   vdppl$Load(name = "RTgetname", pplID = &pplID);
   if (pplID.objid == NULL_OBJID) goto end;

   /* Set the Object ID in the ppl by calling the SetData on
   "COMP_ID" */
   vdppl$SetData( 
      pplID = &pplID,
      name  = "COMP_ID",
      size  = sizeof(struct GRid),
      data  = (IGRchar*) &part_id );

   /* Set the Object ID in the ppl by calling the SetData on
   "MOD_ENV" */
   vdppl$SetData( 
      pplID = &pplID,
      name  = "MOD_ENV",
      size  = sizeof(struct GRmd_env),
      data  = (IGRchar*) &part_id );

   /* Set the variable to get the Object Name which is our
   output from the PPL */
   vdppl$SetData( 
      pplID = &pplID,
      name  = "COMP_NAME",
      size  = 64,
      data  = szObjName );

   vdppl$Run( pplID = &pplID, name = "getNameOfComponent",
	      ret = &pplRET );

   vdppl$GetData( 
      pplID = &pplID,
      name  = "COMP_NAME",
      size  = 64,
      data  = szObjName );

   __DBGpr_str( " Object Name ", szObjName );

   vdppl$Delete(pplID =&pplID);

end:
   End
   return 1;
}

IGRint VDRTConstructLeaf( TGRid CompID, TGRmd_env mod_env,
			  TGRid sysSetID, TGRid partID )
{
  IGRint 	sts, NumbPar;
  IGRlong	msg;
  IGRchar 	szObjName[128];
  TGRid		LeafID;
  TGRobj_env 	objEnv;
  TVDatFld   	fld;
  TACrg_coll    AttList;

  SetProc( Fn VDRTConstructLeaf ); Begin 

  objEnv.obj_id = CompID;
  objEnv.mod_env = mod_env;

  /* Get the components name */
  /****
  sts = VDRTGetCompName( CompID, mod_env, szObjName );
  __DBGpr_str( " Component Name ", szObjName );
  ****/

  /* Create the Component Leaf and place it under PART node */
  sts = VDatCreateLeaf( &sysSetID, &objEnv,
			 &LeafID );

  __DBGpr_obj( " Leaf Id ", LeafID );

  {
     strcpy( AttList.name, VR_N_COMP_CODE_AN );

     sts =
     vr$review_parameters(   pMsg            = &msg,
			     pComponent      = &CompID,
			     NbParams        = 1,
			     pList           = &AttList,
			     pMdEnv          = &mod_env );
     strcpy( szObjName, AttList.desc.value.att_txt );
  }

  // Save it internally if this is a leaf
  VDatFldSetTxt( &fld, "leaf_name", szObjName );
  VDatFldUpdAllAttrs( &LeafID, &fld, 1 );

  /* This is the one which establishes the parent child
  connection with the pipe LINE */
  sts = VDatAddParent( &LeafID, &partID );

  /* to set the "node_flag" attribute value correctly for the SEGMENTS( leafs )
  we should know whether the segment belongs to BENT_PIPE or not. If it belongs
  to BENT_PIPE set it to 12 or else 0 */
  {
     IGRint 	node_flag=0;
     IGRdouble	dLength=0.0;
     IGRint	comp_type;
     TVDatFld 	part_info[2];
     TACrg_coll	AttList;

     /* Get the comp_type of the Component, if its 12 then set the node_flag
     of the leadID to 12 */
     strcpy( AttList.name, VR_N_COMP_TYPE_IN );
     sts =
     vr$review_parameters( pMsg            = &msg,
			   pComponent      = &CompID,
			   NbParams        = 1,
			   pList           = &AttList,
			   pMdEnv          = &mod_env );

     if( (IGRint)AttList.desc.value.att_exp == VR_CMP_TYP_PIPE_BEND )
	  node_flag = (IGRint)AttList.desc.value.att_exp;
     
     VDatFldSetInt( &fld, "node_flag", node_flag );
     VDatFldUpdAllAttrs( &LeafID, &fld, 1 );

     /* The "est_run_len" is a frequently changeable attribute ( i.e. When the
     component attached to the leaf changes its length, it needs update the
     Tree ). So this will be handled separately by calling VDatSummarizeLeaf
     funciton. */

     sts = VDatSummarizeLeaf ( &LeafID );
  }

  End
  return OM_S_SUCCESS;
}

IGRint VDRTFillPortInfo( TGRid CompId, TGRmd_env mod_env, 
			 IGRint port_no, IGRint *node_flag )
{
  IGRint  	i, sts, NumbPar;
  IGRlong 	msg;
  TACrg_coll	AttList;
  TGRid		NextId;

  SetProc( Fn VDRTFillPortInfo ); Begin 

  /* the criteria behind this is...if the CompId == start/end component of the
  run and "cpt_pt infor should be the same. Then it means that the component
  is an end of the run/origin of a pipe run. Remember a origin/end of a run
  can also be origin/end of a Line/System. If so the value assigned inside will
  be overriden at the later stage. */
  for( i=0; i<PiRunCount; i++ )
  {
      if( ( ( CompId.objid == p_rbuff_ptr[i]->run_start.comp_id.objid ) &&
	    ( CompId.osnum == p_rbuff_ptr[i]->run_start.comp_id.osnum ) ) ||
	  ( ( CompId.objid == p_rbuff_ptr[i]->run_end.comp_id.objid ) &&
	    ( CompId.osnum == p_rbuff_ptr[i]->run_end.comp_id.osnum ) ) )
      {
	 *node_flag = 1;
	 continue;
      }
      else
	 *node_flag = 0;
  }

  /* the criteria for the origin/end of Piping lines is such that, whenever 
  there is a change of Specification( diameter, dgn_pressure, dgn_temperature ).
  It should be origin/end of Piping line, as such; this has not been 
  implemented yet. So there mayn't be a run which will result into this 
  category, once its implemented, then we can bother about this.*/
  if( 0 )
  {
     *node_flag = 3;
  }

  /* The criteria is, all the single connect point component 
  should be a origin/end component of the Piping System. */

  sts = vr$review_topology( 	pMsg = &msg,
				pComponent = &CompId,
				CptNum = port_no,
				pNeighbor = &NextId,
				pMdEnv = &mod_env );

  if( NextId.objid != NULL_OBJID )
  {
      strcpy( AttList.name, VR_N_NB_CONNECT_IN );
      sts = vr$review_parameters(   pMsg = &msg,
				    pComponent = &NextId,
				    NbParams = 1,
				    pList = &AttList,
				    pMdEnv = &mod_env );

      if( (IGRint)AttList.desc.value.att_exp == 1 )
	 *node_flag = 7;
  }
  else *node_flag = 7;

  End
  return OM_S_SUCCESS;
}

IGRint VDRTConstBendPorts( TGRid partID, TGRid rdbPartID, TGRid *BendCompIds,
			   IGRint *Bend_cpts, TGRmd_env mod_env )
{
  IGRint 	sts, NbCpts=2; 
  IGRint	port_no, NumbPar;
  IGRchar	short_code[64];
  IGRlong	msg;
  TACrg_coll	AttList[2];
  TGRid		rdbPortID, portID;

  SetProc( Fn VDRTConstBendPorts ); Begin 

  strcpy( short_code, "PIPE" );

  /* Get the rdb Id for the PORT node */
  sts = VDatRDBGetNodeByType( &rdbPartID, "PORT",
			       &rdbPortID );
  __DBGpr_obj( " PORT RDB Id ", rdbPortID );

  for( port_no=0; port_no<NbCpts; port_no++ )
  {
      IGRint    end_prep, node_flag=0;
      IGRchar   port_name[64], GUID[128];
      IGRdouble matrix[16];
      TVDatFld  PortInfo[6];
      TGRobj_env port_obj_info;

      port_name[0] = '\0';

      sprintf( port_name, "%s:%d", short_code, port_no );
      sts = VDatCreateNode( &partID, &rdbPortID,
                          port_name, &portID );

      /* Under each and every port we need to put all the informations
      like "node_x, node_y, node_z ( Coordinates ) and end_prep */

      sts = vr$review_topology (
                         pMsg        = &msg,
                         pComponent  = &BendCompIds[port_no],
                         CptNum      = (IGRshort)Bend_cpts[port_no],
                         pMatrix     = matrix,
                         pMdEnv      = &mod_env );

      VDatFldSetDbl( &PortInfo[0], "node_x", matrix[3] );
      VDatFldSetDbl( &PortInfo[1], "node_y", matrix[7] );
      VDatFldSetDbl( &PortInfo[2], "node_z", matrix[11] );

      sts = vr$get_cpt_prop (   pMsg = &msg,
                                pComponent = &BendCompIds[port_no],
                                nCptNum = (IGRshort)Bend_cpts[port_no],
                                pEndPrep = &end_prep,
                                pMdEnv = &mod_env );

      VDatFldSetInt( &PortInfo[3], "end_prep", end_prep );

      sts = VDmt_create_GUID( &fc_id, GUID );

      VDatFldSetTxt( &PortInfo[4], "node_guid", GUID );

      /* Fill up the PORT node_flag info */
      sts = VDRTFillPortInfo( BendCompIds[port_no], mod_env, 
			      Bend_cpts[port_no], &node_flag );

      VDatFldSetInt( &PortInfo[5], "node_flag", node_flag );
      sts = VDatFldUpdAllAttrs( &portID, PortInfo, 6 );
  }

  End
  return OM_S_SUCCESS;
}

IGRint VRRTConst_Ports( TGRid partID, TGRid rdbPartID, 
			TGRid CompId, TGRmd_env mod_env ) 
{
  IGRint 	sts, NbCpts=-1; 
  IGRint	port_no, NumbPar;
  IGRchar	short_code[64];
  IGRlong	msg;
  TACrg_coll	AttList[2];
  TGRid		rdbPortID, portID;

  SetProc( Fn VRRTConst_Ports ); Begin 

  NumbPar = 2;
  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );
  strcpy( AttList[1].name, VR_N_SHORT_CODE_AN );

  sts =
  vr$review_parameters(   pMsg            = &msg,
			  pComponent      = &CompId,
			  NbParams        = NumbPar,
			  pList           = AttList,
			  pMdEnv          = &mod_env );
  
  short_code[0] = '\0';
  NbCpts = (IGRint)AttList[0].desc.value.att_exp;
  strcpy( short_code, AttList[1].desc.value.att_txt );

  /* Get the rdb Id for the PORT node */
  sts = VDatRDBGetNodeByType( &rdbPartID, "PORT",
			       &rdbPortID );
  __DBGpr_obj( " PORT RDB Id ", rdbPortID );

  for( port_no=0; port_no<NbCpts; port_no++ )
  {
      IGRint	end_prep, node_flag=0;
      IGRchar 	port_name[64], GUID[128];
      IGRdouble	matrix[16];
      TVDatFld	PortInfo[6];
      TGRobj_env port_obj_info;

      port_name[0] = '\0';

      sprintf( port_name, "%s:%d", short_code, port_no );
      sts = VDatCreateNode( &partID, &rdbPortID,
                          port_name, &portID );
      
      /* Under each and every port we need to put all the informations 
      like "node_x, node_y, node_z ( Coordinates ) and end_prep */

      sts = vr$review_topology (
			 pMsg        = &msg,
			 pComponent  = &CompId,
			 CptNum      = port_no,
			 pMatrix     = matrix,
			 pMdEnv      = &mod_env );

      VDatFldSetDbl( &PortInfo[0], "node_x", matrix[3] );
      VDatFldSetDbl( &PortInfo[1], "node_y", matrix[7] );
      VDatFldSetDbl( &PortInfo[2], "node_z", matrix[11] );

      sts = vr$get_cpt_prop ( 	pMsg = &msg,
				pComponent = &CompId,
				nCptNum = port_no,
				pEndPrep = &end_prep,
				pMdEnv = &mod_env );

      VDatFldSetInt( &PortInfo[3], "end_prep", end_prep );

      sts = VDmt_create_GUID( &fc_id, GUID );

      VDatFldSetTxt( &PortInfo[4], "node_guid", GUID );

      /* Fill up the PORT node_flag info */
      sts = VDRTFillPortInfo( CompId, mod_env, port_no, &node_flag );

      VDatFldSetInt( &PortInfo[5], "node_flag", node_flag );
      sts = VDatFldUpdAllAttrs( &portID, PortInfo, 6 );
  }

  End
  return sts;
}

IGRint VDRT_Const_Part( TGRid sysSetID, TGRid runID, 
			TGRid rdbPartID, TGRmd_env mod_env,
			TGRid CompId, TGRid *partID )
{
  IGRlong	sts, msg;
  TGRobj_env	GUID_objinfo;
  IGRchar	guid[128];
  IGRchar	szPartId[64];
  TGRid		rdbPortID, rdbSegmentID, SegmentID;
  TVDatFld	part_info[2];
  TACrg_coll	AttList;

      SetProc( Fn VDRT_Const_Part ); Begin 

      /* Get the components name */
      sts = VDRTGetCompName( CompId, mod_env, szPartId );
      __DBGpr_str( " Component Name ", szPartId );

      sts = VDatCreateNode( &runID, &rdbPartID,
                          szPartId, partID );

      /*Call this function to create a GUID for each part */
      sts = VDmt_create_GUID( &fc_id, guid );

      /*Set the attributes for the PART node */
      VDatFldSetTxt( &part_info[0], "node_guid", guid );

      strcpy( AttList.name, VR_N_COMP_TYPE_IN );
      sts =
      vr$review_parameters( pMsg            = &msg,
			    pComponent      = &CompId,
			    NbParams        = 1,
			    pList           = &AttList,
			    pMdEnv          = &mod_env );

      VDatFldSetInt( &part_info[1], "node_flag", 
			(IGRint)AttList.desc.value.att_exp );

      VDatFldUpdAllAttrs( partID, part_info, 2 );

      /* Underneath the PART we need to create two nodes, one for PORT 
      ( actually its two ports one for each end ) and the other one for SEGMENT.
      The PORT node will hold all the geometric informations like coordinates, 
      end_prep of a particular connect point information of a Component. 
      SEGMENT node will have the listed of components ( in the case of BEND it 
      can be more than 1 ). */

      sts = VRRTConst_Ports( *partID, rdbPartID, CompId, mod_env );

      sts = VDRTConstructLeaf( CompId, mod_env,
                               sysSetID, *partID );
      End
      return sts;
}

/* This function will contruct all the Pipe Runs in the StepTree */
IGRint VDRT_Const_RunParts( TGRid sysSetID, TGRid runID, 
			TGRid rdbPartID, TGRmd_env mod_env,
			TGRid start_cmpid, IGRint start_cpt,
			TGRid end_cmpid, IGRint end_cpt )
{
  IGRboolean	bLastComp=TRUE;
  IGRboolean	bIsPrevCompBend = FALSE, bIsPrevCompPipe = FALSE; 
  IGRint 	status, sts, NumbPar, nPart=0;
  IGRint	FromCpt, NextCpt, Bend_cpts[2];
  IGRlong	msg;
  TACrg_coll 	AttList[2];
  TGRid		CompId, NextId, partID, prev_partID; 
  TGRid		BendCompIds[2];
  TGRobj_env	GUID_objinfo;
  IGRchar	guid[128];

  SetProc( Fn VDRT_ConstructRuns ); Begin 

  /* This component could be either FLANGE or VALVE. I don't see any other
  component could fall in this category. */
  if( ( start_cmpid.objid == end_cmpid.objid ) &&
      ( start_cmpid.osnum == end_cmpid.osnum ) )
  {
      CompId = start_cmpid;
      /* Single component RUN */
      sts = VDRT_Const_Part( sysSetID, runID, rdbPartID, mod_env, 
				CompId, &partID );

      End
      return OM_S_SUCCESS;
  }

  CompId = start_cmpid;

  NumbPar = 1;
  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

  status =
  vr$review_parameters( pMsg            = &msg,
			pComponent      = &CompId,
			NbParams        = NumbPar,
			pList           = AttList,
			pMdEnv          = &mod_env );

  if( AttList[0].desc.value.att_exp > 1 )
      FromCpt = ( start_cpt ) ? 0 : 1;

last_component:
  do
  {
      NumbPar = 2;
      strcpy( AttList[0].name, VR_N_COMP_TYPE_IN );
      strcpy( AttList[1].name, VR_N_COMP_CODE_AN );

      __DBGpr_obj( " Component Id in process ", CompId );
      status =
      vr$review_parameters( pMsg            = &msg,
			    pComponent      = &CompId,
			    NbParams        = NumbPar,
			    pList           = AttList,
			    pMdEnv          = &mod_env );

      if( AttList[0].desc.value.att_exp == VR_CMP_TYP_PIPE_BEND )
      {
	 if( !bIsPrevCompBend  &&  !bIsPrevCompPipe )
	 {
	    BendCompIds[0] = CompId;
	    Bend_cpts[0] = FromCpt;

	    sts = VDRT_Const_Part( sysSetID, runID, rdbPartID, mod_env, 
				      CompId, &prev_partID );
	 }
	 else 
	 {
	    /* Previous component was either a BEND or a PIPE. So we need to 
	    construct the BEND component under the same part. */
	    sts = VDRTConstructLeaf( CompId, mod_env, sysSetID, prev_partID );

	    BendCompIds[1] = CompId;
	    Bend_cpts[1] = FromCpt;
	 }
	 bIsPrevCompBend = TRUE;
      }
      else if( AttList[0].desc.value.att_exp == VR_CMP_TYP_PIPE_STRAIGHT ) 
      {
	 if( bIsPrevCompBend )
	 {
	     /* Construct a leaf under the same BEND part */
	     sts = VDRTConstructLeaf( CompId, mod_env, sysSetID, prev_partID );

	     BendCompIds[1] = CompId;
	     Bend_cpts[1] = FromCpt;
	 }
	 else
	 {
	    IGRint tempNextCpt;
	    TGRid tempNextId;

	    status = vr$review_topology (
			       pMsg        = &msg,
			       pComponent  = &CompId,
			       CptNum      = FromCpt,
			       pNeighbor   = &tempNextId,
			       pNeighCpt   = &tempNextCpt,
			       pMdEnv      = &mod_env );
	    NumbPar = 1;
	    strcpy( AttList[0].name, VR_N_COMP_TYPE_IN );

	    status =
	    vr$review_parameters( pMsg            = &msg,
				  pComponent      = &tempNextId,
				  NbParams        = NumbPar,
				  pList           = AttList,
				  pMdEnv          = &mod_env );

	    if( AttList[0].desc.value.att_exp == VR_CMP_TYP_PIPE_BEND )
	    {
	       /* Since the next component happens to be a BEND construct the
	       Part with a Name "STRAIGHT_PIPE" */

	       IGRchar szPartId[20];

	       strcpy( szPartId, "STRAIGHT_PIPE" );
	       sts = VDatCreateNode( &runID, &rdbPartID,
				   szPartId, &prev_partID );

	       /*Call this function to create a GUID for each part */
	       sts = VDmt_create_GUID( &fc_id, guid );

	       BendCompIds[0] = CompId;
	       Bend_cpts[0] = ( FromCpt ) ? 0: 1;

	       sts = VDRTConstructLeaf( CompId, mod_env,
					sysSetID, prev_partID );
	    }
	    else 
	    {
	       /* Construct the PIPE part under a different part*/
	       sts = VDRT_Const_Part( sysSetID, runID, rdbPartID, mod_env, 
				      CompId, &partID );
	    }
	 }

	 bIsPrevCompPipe = TRUE;
      }
      else if( AttList[0].desc.value.att_exp == VR_CMP_TYP_PIPE_DANGLE ) 
      {
	 /* Do nothing for DANGLE, this should not be included in the TREE */
	 __DBGpr_com( " Do nothing for dangle " );
	 bIsPrevCompBend = bIsPrevCompPipe = FALSE;
      }
      else if( ( AttList[0].desc.value.att_exp == VR_CMP_TYP_PIPE_FLANGE ) &&
	       ( !strcmp( AttList[1].desc.value.att_txt, "WELD" ) ) )
      {
	 /* Do nothing this is just to split the pipe network
	 without Dangles. */
	 bIsPrevCompBend = bIsPrevCompPipe = FALSE;
      }
      else 
      {
	 /* Construct this stand alone part */
	 sts = VDRT_Const_Part( sysSetID, runID, rdbPartID, mod_env, 
				CompId, &partID );

	 bIsPrevCompBend = bIsPrevCompPipe = FALSE;
      }

      if( !bLastComp )
      {
	End
	return OM_S_SUCCESS;
      }

      status = vr$review_topology (
			 pMsg        = &msg,
			 pComponent  = &CompId,
			 CptNum      = FromCpt,
			 pNeighbor   = &NextId,
			 pNeighCpt   = &NextCpt,
			 pMdEnv      = &mod_env );

      __DBGpr_obj( " Next Component Id ", NextId );
      __DBGpr_int( " CptNum of Next Comp ", (short)NextCpt );

      CompId = NextId;
      FromCpt = (short) NextCpt;
      FromCpt = ( FromCpt ) ? 0 : 1;

  }while( ( CompId.objid != end_cmpid.objid  ) ||
	 ( CompId.osnum != end_cmpid.osnum  ) );

  /* If the following condition is TRUE, then we need to construct the PORT
  informations for the BEND component. */

  if( ( BendCompIds[0].objid != NULL_OBJID ) && 
      ( BendCompIds[1].objid != NULL_OBJID ) )
  {
     TVDatFld	part_info[2];

     /*Call this function to create a GUID for each part */
     sts = VDmt_create_GUID( &fc_id, guid );

     /* Set the attributes for the PART node */
     VDatFldSetTxt( &part_info[0], "node_guid", guid );

     /* node_flag for BENT_PIPE is 12 */
     VDatFldSetInt( &part_info[1], "node_flag", 12 );

     VDatFldUpdAllAttrs( &prev_partID, part_info, 2 );

     Bend_cpts[2] = (short)NextCpt;
     sts = VDRTConstBendPorts( prev_partID, rdbPartID, BendCompIds, 
				Bend_cpts, mod_env );
  }

  if( bLastComp )
  {
   CompId = end_cmpid;
   bLastComp = FALSE;
   goto last_component;
  }

  End
  return OM_S_SUCCESS;
}

IGRlong VDmt_tree_init( IGRlong *retmsg, IGRchar  *tree_type, 
			TGRobj_env in_fc_id  )
{
	int sts, ret, n_s, ii;
	int batch;
	char* fname;
	char* dbname;
	char* dbuser;
	char* dbpasswd;
	int units, jj;
	int nsy=0; char** syida;
	int i, part_type, PiLinCount = 0;
	part_info *partinfo = NULL;
	void *part_data = NULL;
	/*int *csg_types, num_csgs;
	void **csgs;*/
	struct GRid part_id, comp_id;
	pipe_attr *PipeAttr;
	piping_component_attr *PiCompAttr;

	char system[30], pipeline[30], filename[OM_K_MAXOSNAME_LEN];
	connect_pt_id cpi;
	short bFlag = FALSE;

	/* can be a ptr to LinPiInfo, BtPiInfo or CmpInfo */
	pipeline_info pipeline_info_buff, *buff_ptr, **p_buff_ptr;
	pipe_run_info piperun_info_buff, *rbuff_ptr; 

	 /* added by alwin */
	IGRint size, ret_size;
	IGRlong msg;
	struct GRid AssemManagerId, systemSetID;
	struct GRid rdbSetID, rdbSystemsID, rdbSysID, rdbLineID, rdbRunID; 
	struct GRid rdbPartID, rdbJointsID;
	struct GRid *sysSetID=NULL, lineID, treeID, LeafID, runID, jointsID;
	struct GRmd_env mod_env;
	struct GRobj_env objEnv;
	IGRint NbSysParams=0;
	IGRchar system_name[2][20];

	SetProc( Fn fun ); Begin 

	/* store the file_collector id in the Global variable */
	fc_id = in_fc_id;

	/* Delete the Existing Assembly Manager, to avoid over writing of the
	stuffs */
	{
	   TGRid mgrID;

	   vdat$GetSetMgr (mgrID = &mgrID);
	   if (mgrID.objid == NULL_OBJID) UI_status("No Set Manager Found");
	   else {
	     vdat$DeleteBase(baseID = &mgrID);
	     UI_status("Set Manager Deleted");
	   }
	}

	buff_ptr = &pipeline_info_buff;
        p_buff_ptr = &buff_ptr;

	rbuff_ptr = &piperun_info_buff;
        p_rbuff_ptr = &rbuff_ptr;

	part_id.objid = NULL_OBJID;
	comp_id.objid = NULL_OBJID;

	strcpy( system, "" );
	strcpy( pipeline, "" );
	cpi.comp_id.objid = NULL_OBJID;

	batch = 0;
	fname = NULL;
	dbname = NULL;
	dbuser = NULL;
	dbpasswd = NULL;
	units = 1;

	NbSysParams = 1; /* Currently only system_name will be used for
			classifying the systems, later in future we may have to
			add "fluid_code" also. Alwin */
	strcpy( system_name[0], VR_N_SYST_NAME_AN );
	strcpy( system_name[1], VR_N_FLUID_CODE_AN );

	__DBGpr_com( " Calling the RT_init_read..." );
	sts = RT_init_read( batch, fname, dbname, dbuser,
/*			    dbpasswd, units, system_name, NbSysParams ); */
			    dbpasswd, units, "system_name" );

	if( sts == RTERR_DB_LOGIN )
	{
	     __DBGpr_com( " Error occurred " );
	     printf( "error status is RTERR_DB_LOGIN\n" );
	     UI_status( "Usert not logged into DB" );
	}

	if ( sts != RTSUCC ) goto end;

	/* Call the VD$GetSetMgr to check whether Assembly Manager is 
	constructed already or not. If not call the Create Manager to create.*/

	sts = vdat$GetSetMgr( osnum = 2, 
			      mgrID = &AssemManagerId );
	__DBGpr_obj( " Assembly Manager Id", AssemManagerId );

	if( AssemManagerId.objid == NULL_OBJID )
	{
	   sts = vdat$CreateSetMgr( osnum = 2, 
				 mgrID = &AssemManagerId );
	   __DBGpr_obj( " Assembly Manager Id", AssemManagerId );
	}

	__DBGpr_com( " Calling the RT_get_piping_systems... " );
	sts = RT_get_piping_systems( &nsy, &syida );

	__DBGpr_int( " Nb. of Piping Systems ", nsy );

	if( nsy )
	{
	    sysSetID = _MALLOC( nsy, struct GRid );

	    if( ! sysSetID ) 
	    {
	       __DBGpr_com( " Memory Allocation error " );
	       UI_status ( " Memory Allocation Error " );
	       End
	       return OM_S_SUCCESS;
	    }
	}

/*	sts = VDatRDBGetSetByType( &AssemManagerId, "StepTree", &rdbSetID ); */
	sts = VDatRDBGetSetByType( &AssemManagerId, tree_type, &rdbSetID );
	__DBGpr_obj( " System Manager RDB Id ", rdbSetID );

	sts = VDatCreateSet( &AssemManagerId, &rdbSetID,
			     "MariSTEP", &systemSetID );
	__DBGpr_obj( " Create Set Id ", systemSetID );

	/* Get the rdb Id for the SYSTEMS node */
	sts = VDatRDBGetNodeByType( &rdbSetID, "SYSTEMS",
				  &rdbSystemsID );
	__DBGpr_obj( " System RDB Id ", rdbSystemsID );

	/* Get the Tree Node... from the systemSetID...to which we'll be 
	attaching all the SYSTEMS of the system */
	sts = VDatCreateTree( &systemSetID, &rdbSystemsID, " ",
			      &treeID );
	__DBGpr_obj( " Tree ID of the System ", treeID );

	/* Get the rdb Id for the SYSTEM node */
	sts = VDatRDBGetNodeByType( &rdbSystemsID, "SYSTEM",
				  &rdbSysID );
	__DBGpr_obj( " System RDB Id ", rdbSysID );

	/* Get the rdb Id for the LINE node */
	sts = VDatRDBGetNodeByType( &rdbSysID, "LINE", 
				     &rdbLineID );
	__DBGpr_obj( " Line RDB Id ", rdbLineID );

	/* Get the rdb Id for the JOINT node */
	sts = VDatRDBGetNodeByType( &rdbSysID, "JOINT", 
				     &rdbJointsID );
	__DBGpr_obj( " Line RDB Id ", rdbJointsID );

	/* Get the rdb Id for the RUN node */
	sts = VDatRDBGetNodeByType( &rdbLineID, "RUN", 
				     &rdbRunID );
	__DBGpr_obj( " Run RDB Id ", rdbRunID );

	/* Get the rdb Id for the PART node */
	sts = VDatRDBGetNodeByType( &rdbRunID, "PART", 
				     &rdbPartID );
	__DBGpr_obj( " Part RDB Id ", rdbPartID );

	/*
	 * Retrieve module env.
	 */
	size = sizeof( struct GRmd_env ) ;

	gr$get_module_env( msg    = &msg,
			   sizbuf = &size,
			   buffer = &mod_env,
			   nret   = &ret_size );

	for( n_s = 0; n_s < nsy; n_s = n_s+1 )
	{
	   char guid[128];

	   sts = VDatCreateNode( &treeID, &rdbSysID, 
				    syida[n_s], &sysSetID[n_s] );

	   /*Call this function to create a GUID for each system */
	   sts = VDmt_create_GUID( &fc_id, guid );
	   {
	      TVDatFld  PortInfo;

	      sts = VDatFldSetTxt( &PortInfo, "node_guid", guid );
	      sts = VDatFldUpdAllAttrs( &sysSetID[n_s], &PortInfo, 1 );
	   }

	   __DBGpr_com( " Calling the RT_get_pipelines..." );
	   sts = RT_get_pipelines( syida[n_s],  &PiLinCount, &p_buff_ptr );

	   __DBGpr_int( " Nb. of Pipe lines ", PiLinCount );

	   if( ! PiLinCount ) 
	   {
	      __DBGpr_com( " Zero Pipelines found " );
	      End
	      return OM_S_SUCCESS;
	   }

	   /* for each PipeLine */
	   for( jj=0; jj<PiLinCount; ++jj )
	   {
	       /* Using the above treeID, and the rdbLineId now create all the 
	       LINE objects one by one under the system */

	       sts = VDatCreateNode( &sysSetID[n_s], &rdbLineID, 
				     p_buff_ptr[jj]->pipeline_id, &lineID );
	       __DBGpr_obj( " Line ID ", lineID );

	       /*Call this function to create a GUID for each line */
	       sts = VDmt_create_GUID( &fc_id, guid );
	       {
		  TVDatFld  PortInfo;

		  sts = VDatFldSetTxt( &PortInfo, "node_guid", guid );
		  sts = VDatFldUpdAllAttrs( &lineID, &PortInfo, 1 );
	       }

	       __DBGpr_com( " Calling the RT_get_pipe_runs ..." );
	       PiRunCount = 0;
	       sts = RT_get_pipe_runs( syida[n_s], p_buff_ptr[jj]->pipeline_id,
				   &PiRunCount, &p_rbuff_ptr );

	       if( sts == RTERR_PRUN )
	       {
		  __DBGpr_com( " Error while RT_get_pipe_runs..." );
		  End
		  return OM_S_SUCCESS;
	       }

#if 0
	       __DBGpr_int( " Nb. of Pipe Runs ", PiRunCount );
	       printf( "\t Run  Start        End        Spec\n" );
	       for( i=0; i<PiRunCount; ++i )
	       {
		   printf( "\t%2d) ", i+1 );
		   printf( " %3d ", p_rbuff_ptr[i]->run_start.comp_id.objid );
		   printf( " %3d ", p_rbuff_ptr[i]->run_start.conn_pt_id );
		   printf( " %3d ", p_rbuff_ptr[i]->run_end.comp_id.objid );
		   printf( " %3d ", p_rbuff_ptr[i]->run_end.conn_pt_id );
		   printf( " %s\n", p_rbuff_ptr[i]->pipe_spec );
	       }
#endif

	       ret = RTSUCC;
	       /* for each pipe run */
	       for( i=0; i<PiRunCount; ++i )
	       {
		 IGRchar 	szRunid[10];
		 IGRint  	nPart=0;
		 IGRchar 	szPartId[10];
		 IGRchar 	szObjName[64];
		 TGRid 		partID;

		 /* Using the lineID, and the rdbRunId now create all 
		 the RUN objects one by one under the pipe line. */

		 szRunid[0] = '\0';
		 sprintf ( szRunid, "%d", i );
		 sts = VDatCreateNode( &lineID, &rdbRunID, 
				       szRunid, &runID );

		 __DBGpr_obj( " Run ID ", runID );

		 /*Call this function to create a GUID for each run */
		 sts = VDmt_create_GUID( &fc_id, guid );
		 {
		    IGRint 	NumbPar;
		    TACrg_coll 	AttList;
		    TVDatFld  	PortInfo[2];

		    sts = VDatFldSetTxt( &PortInfo[0], "node_guid", guid );

		    NumbPar = 1;
		    /* Specifically for defined MariSTEP */
		    strcpy( AttList.name, "pipe_run_spec" );

		    sts =
		    vr$review_parameters( pMsg            = &msg,
					  pComponent      = 
					     &p_rbuff_ptr[i]->run_start.comp_id,
					  NbParams        = NumbPar,
					  pList           = &AttList,
					  pMdEnv          = &mod_env );

		    sts = VDatFldSetTxt( &PortInfo[1], "node_spec_name", 
					AttList.desc.value.att_txt );

		    sts = VDatFldUpdAllAttrs( &runID, PortInfo, 2 );
		 }

		 printf( "Start run %2d) - %d %d\n", i+1,
		      p_rbuff_ptr[i]->run_start.comp_id.objid,
		      p_rbuff_ptr[i]->run_start.conn_pt_id );

		 sts = VDRT_Const_RunParts( systemSetID, runID, 
					 rdbPartID, mod_env, 
					 p_rbuff_ptr[i]->run_start.comp_id,
					 p_rbuff_ptr[i]->run_start.conn_pt_id,
					 p_rbuff_ptr[i]->run_end.comp_id,
					 p_rbuff_ptr[i]->run_end.conn_pt_id );

		/*	Construct the JOINT objects between the PARTS */
		sts = 
		VDRTConstPartJoints( runID, rdbJointsID, fc_id );

	       }/* for each pipe run */

	       /*	Place the code which creates the JOINT 	*/
	       /*	objects between the RUNs.		*/
	       sts = 
	       VDRTConstRunJoints( lineID, rdbJointsID, fc_id  );

	   }/* for each pipe line */
		/*	Place the code which creates the JOINT 	*/
		/*	objects between the LINEs.		*/
	        sts = 
	        VDRTConstLineJoints( sysSetID[n_s], rdbJointsID, fc_id );

	}/* for each pipe system */

	_FREE( sysSetID );
	
	sts = 100;

	if( bFlag )
	{
	     __DBGpr_com( " Calling RT_get_pipe_attributes ..." );
	     sts = RT_get_pipe_attributes( &part_id, &PipeAttr );
	}

#if 0
	if( sts == RTSUCC )
	{
	 printf( "size:%lf\n", ((pipe_attr *)PipeAttr)->nom_pipe_size );
	 printf( "s-type:%s\n", ((pipe_attr *)PipeAttr)->nom_pipe_size_type );
	 printf( "material:%s\n", ((pipe_attr *)PipeAttr)->material_name );
	 printf( "schedule:%s\n", 
		((pipe_attr *)PipeAttr)->wall_thickness_or_schedule );
	 printf( "prs_rtng:%lf\n", ((pipe_attr *)PipeAttr)->pressure_rating );
	 printf( "units:%s\n", ((pipe_attr *)PipeAttr)->pressure_rating_units );
	 printf( "outside-dia:%lf\n",
		 ((pipe_attr *)PipeAttr)->pipe_outside_diameter );
	 printf( "comp-code:%s\n", ((pipe_attr *)PipeAttr)->comp_code );
	 printf( "g_size:%lf\n", ((pipe_attr *)PipeAttr)->g_size );
	 printf( "opt-code:%d\n", ((pipe_attr *)PipeAttr)->opt_code );
	}
#endif 

	if( bFlag )
	{
	     __DBGpr_com( " Calling RT_get_piping_component_attr ..." );
	     sts = RT_get_piping_component_attr( &comp_id, &PiCompAttr );
	}

#if 0
	if( sts == RTSUCC )
	{
	  printf( "\n" );
	  printf( "num_ports:%d\n", PiCompAttr->num_ports );
	  printf( "cp_coord[0]:%lf\n",
		 PiCompAttr->comp_port_defs[0]->cp_coord[0] );
	  printf( "nom_pipe_size:%lf\n",
			 PiCompAttr->comp_port_defs[0]->nom_pipe_size );
	  printf( "g_size:%lf\n",
			 PiCompAttr->g_size );
	  printf( "r_size:%lf\n",
			 PiCompAttr->r_size );
	  printf( "nom_pipe_size_type:%s\n",
			 PiCompAttr->comp_port_defs[0]->nom_pipe_size_type );
	  printf( "end_prep:%s\n",
			 PiCompAttr->comp_port_defs[0]->port_end_prep );
	  printf( "prs-rtng:%lf\n",
			 PiCompAttr->comp_port_defs[0]->pressure_ratings );
	  printf( "comp-type:%d\n", PiCompAttr->component_type );
	  printf( "part_class:%s\n", PiCompAttr->part_class );
	}
#endif
#ifdef CSG
	printf( "calling RT_get_entity_csg\n" );
        sts = RT_get_entity_csg( part_id, 0,
				 &num_csgs, &csg_types, &csgs );

	printf( "out of RT_get_entity_csg\n" );

	if( sts > 0 )
	{
	   printf( "num_csgs:%d\n",num_csgs);
	   printf("   csg_types: " );
	   for (i = 0; i < num_csgs; i++)
	   {
	       printf("%d, ",csg_types[i]);
	   }
	printf ("\n");
	} 
	else 
	{
	    printf ( "NO CSGS Processed \n");
	}
#endif

#ifdef vdsDEBUG
	printf( "\nNo of PipingSystems:%d\n", nsy );
	for( i=0; i < nsy; ++i )
	   printf( "Sys[%d]:%s\n", i, syida[i] );

	printf( "No of PipeLines:%d\n", PiLinCount );
	for( i=0; i < PiLinCount; ++i )
	   printf( "p_buff_ptr[%d]->pipeline_id:%s\n",
		 i, p_buff_ptr[i]->pipeline_id );

	__DBGpr_int( " Nb. of Pipe Runs ", PiRunCount );
	printf( "\t Run  Start        End        Spec\n" );
	for( i=0; i<PiRunCount; ++i )
	{
	   printf( "\t%2d) ", i+1 );
	   printf( " %3d ", p_rbuff_ptr[i]->run_start.comp_id.objid );
	   printf( " %3d ", p_rbuff_ptr[i]->run_start.conn_pt_id );
	   printf( " %3d ", p_rbuff_ptr[i]->run_end.comp_id.objid );
	   printf( " %3d ", p_rbuff_ptr[i]->run_end.conn_pt_id );
	   printf( " %s\n", p_rbuff_ptr[i]->pipe_spec );
	}
#endif

sts = RT_get_file_name( filename );

	if( sts == RTSUCC )
	     printf( "filename: %s\n", filename );

	/* do an RT_exit_read only after retrieving all info */
	RT_exit_read();
end:
	End
	return OM_S_SUCCESS;
}
