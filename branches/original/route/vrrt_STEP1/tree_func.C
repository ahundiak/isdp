/* $Id: tree_func.C,v 1.5 2001/02/20 01:17:06 build Exp $ */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP1/tree_func.C
 *
 * Description:
 *      This was initially called as temp.C. Also delivered to MariSTEP 
 *	with the same name. Mainly consists of functions which are used by the
 *	VDmt_tree_init(). If MariSTEP loads the new version there is no need
 *	for them to load the temp.C file.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: tree_func.C,v $
 *      Revision 1.5  2001/02/20 01:17:06  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.4  2001/01/25 15:07:59  anand
 *      Original file
 *
 *      Revision 1.1  2001/01/04 21:13:08  cvs
 *      Initial revision
 *
 * Revision 1.4  1999/04/20  07:57:26  pinnacle
 * Replaced: vrrt_STEP1/tree_func.C for:  by apazhani for route
 *
 * Revision 1.3  1999/04/10  21:10:00  pinnacle
 * Replaced: vrrt_STEP1/tree_func.C for:  by apazhani for route
 *
 * Revision 1.1  1998/12/14  20:59:32  pinnacle
 * 'Intially created for MariSTEP, later to be used in PIPING tree Construction'
 *
 *
 * History:
 *       Date            Name     Description
 *      12/14/98        Alwin     Creation
 *      04/11/99        Alwin     Added two functions. One to get the proper
 *				  Lines out of the piping runs. Another
 *				  one was to redesign the Construction joints
 *				  between RUNs.
 *      04/20/99        Alwin     Modified the functions calls. 
 *
 *************************************************************************/

#include <stdio.h>
#include "nddef.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "GMerrordef.h"
#include "ACrg_collect.h"
#include "OMlimits.h"

#include "VDsa.h"
#include "VDatMaster.h"
#include "VDmem.h"
#include "VDppl1.h"
#include "vrmacros.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "vrdbgmacros.h"
#include "rtiges.h"

extern VDmt_create_GUID();
extern VDatGetObjectLeaf();

/* This is function is implemented in MariSTEP portion of the code. For the
compilation sake we use this dummy function which returns a constant string.
While delivering the product this function should be commented, so that the
MariSTEP implemented functions will take effect. Alwin
*/

int VDmt_create_GUID( struct GRobj_env *md_env, IGRchar *GUID )
{
  strcpy( GUID, "Ingr:solimpd" );

  return 1;
}

/* The following two functions are called only by the MariSTEP code */

/* This functions returns the flow_direction for the component. As far as I know
they used this function to find out the flow_direction for the VALVE alone */
IGRboolean VDmt_tree_get_flow_dir( IGRlong *msg, TGRobj_env app_objid, 
				   IGRint CptNum, IGRshort *flow_dir )
{
   IGRlong 	sts;
   TGRobj_env	pieceOE;

   SetProc( Fn VDmt_tree_get_flow_dir ); Begin 

   /* Get the Original object from the "seg_id". */

   __DBGpr_com( " In flow_dir, ready to get Leaf Object ");

   pieceOE.mod_env = app_objid.mod_env;

   sts = VDatGetLeafObject( &app_objid.obj_id, &pieceOE );

   __DBGpr_obj( " Original object ", pieceOE.obj_id );

   sts = vr$review_flowdir( 	pMsg = msg,
				pComponent = &pieceOE.obj_id,
				CptNum = CptNum,
				pFlowdir = flow_dir,
				pMdEnv = &app_objid.mod_env );
   
   __DBGpr_int( " Flow direction ", *flow_dir );

   End
   return sts;
}

/* This functions returns the Geometry of the Component */
IGRboolean VDmt_tree_get_seg_geometry( IGRlong *msg, TGRobj_env seg_id, 
				IGRint part_type, IGRint seg_type,
				IGRdouble **pt_coords, IGRint *num_directions,
				IGRdouble **directions )
{
   IGRint	sts;
   IGRdouble	dBeginPt[3], dCenterPt[3], dEndPt[3];
   IGRdouble	matrix[16];
   TGRobj_env	pieceOE;

   SetProc( Fn VDmt_tree_get_seg_geometry ); Begin 

   /* Get the Original object from the "seg_id". */
   sts = VDatGetLeafObject( &seg_id.obj_id, &pieceOE ); 

   __DBGpr_obj( " Original object ", pieceOE.obj_id );

   dBeginPt[0] = dBeginPt[1] = dBeginPt[2] = 0.0;
   dCenterPt[0] = dCenterPt[1] = dCenterPt[2] = 0.0;
   dEndPt[0] = dEndPt[1] = dEndPt[2] = 0.0;

   /* Any components other than "components belonging to the BENT_PIPE fall
   into this category. */
   if( seg_type == 0 )
   {
      /* this could be either  pipe being a part of "BENT-PIPE PART" or just a 
      PIPE itself as a PART */
      if( part_type == 0 || part_type == 12 )
      {
	 IGRdouble dVector[3];

	 /* We need to return the "End Points and the direction vector */

	 /* Get the 0-connect point coordinates */
         sts = vr$review_topology( pMsg = msg,
                                   pComponent = &pieceOE.obj_id,
                                   CptNum = 0,
                                   pMatrix = matrix,
                                   pMdEnv = &pieceOE.mod_env );

/*
	 sts = vr$get_cpt_prop( pMsg = msg,
				pComponent = &pieceOE.obj_id,
				nCptNum	= 0,
				pCptOffSet = dBeginPt,
				pMdEnv = &pieceOE.mod_env );
*/
         __DBGpr_mat( " Cpt 0 Matrix ", matrix );

         dBeginPt[0] = matrix[3];
         dBeginPt[1] = matrix[7];
         dBeginPt[2] = matrix[11];

         __DBGpr_vec( " Begin Point ", dBeginPt );

	 /* Get the 1-connect point coordinates */
         sts = vr$review_topology( pMsg = msg,
                                   pComponent = &pieceOE.obj_id,
                                   CptNum = 1,
                                   pMatrix = matrix,
                                   pMdEnv = &pieceOE.mod_env );
         __DBGpr_mat( " Cpt 0 Matrix ", matrix );
         dEndPt[0] = matrix[3];
         dEndPt[1] = matrix[7];
         dEndPt[2] = matrix[11];

/*
	 sts = vr$get_cpt_prop( pMsg = msg,
				pComponent = &pieceOE.obj_id,
				nCptNum	= 1,
				pCptOffSet = dEndPt,
				pMdEnv = &pieceOE.mod_env );
*/
	 *num_directions = 1;
	 BSmkvec( msg, dVector, dBeginPt, dEndPt );
	 BSnorvec( msg, dVector );
         __DBGpr_vec( " Normalized Direction Vector ", dVector );

	 if( directions )
	     *directions = dVector;
      }
      else /* Its a normal component */
      {
	 IGRdouble matrix[16];

	 /* Get the Center point coordinates */
	 sts = vr$review_topology( pMsg = msg,
				   pComponent = &pieceOE.obj_id,
				   CptNum = -1,
				   pMatrix = matrix,
				   pMdEnv = &pieceOE.mod_env );
	 dCenterPt[0] = matrix[3];
	 dCenterPt[1] = matrix[7];
	 dCenterPt[2] = matrix[11];

	 *num_directions = 2;
	 if( directions )
	 {
	     directions[0][0] = matrix[0];
	     directions[0][1] = matrix[4];
	     directions[0][2] = matrix[8];

	     directions[1][0] = matrix[1];
	     directions[1][1] = matrix[5];
	     directions[1][2] = matrix[9];
	 }
      }
   }
      /* this means BEND component in a BENT_PIPE */
   else if( seg_type == 12 )
   {
     IGRint comp_type;
     IGRdouble matrix[16];

     /* Get the 0-connect point coordinates */
      sts = vr$review_topology( pMsg = msg,
                                pComponent = &pieceOE.obj_id,
                                CptNum = 0,
                                pMatrix = matrix,
                                pMdEnv = &pieceOE.mod_env );

      __DBGpr_mat( " Cpt 0 Matrix ", matrix );

         dBeginPt[0] = matrix[3];
         dBeginPt[1] = matrix[7];
         dBeginPt[2] = matrix[11];

/*
     sts = vr$get_cpt_prop( pMsg = msg,
			    pComponent = &pieceOE.obj_id,
			    nCptNum	= 0,
			    pCptOffSet = dBeginPt,
			    pMdEnv = &pieceOE.mod_env );
*/

     /* Get the 1-connect point coordinates */
     sts = vr$get_cpt_prop( pMsg = msg,
			    pComponent = &pieceOE.obj_id,
			    nCptNum	= 1,
			    pCptOffSet = dEndPt,
			    pMdEnv = &pieceOE.mod_env );

     /* Get the Center Point ( CptNum=-1 ) coordinates */

       sts = vr$review_topology( pMsg = msg,
                                   pComponent = &pieceOE.obj_id,
                                   CptNum = 1,
                                   pMatrix = matrix,
                                   pMdEnv = &pieceOE.mod_env );
         __DBGpr_mat( " Cpt 0 Matrix ", matrix );
         dEndPt[0] = matrix[3];
         dEndPt[1] = matrix[7];
         dEndPt[2] = matrix[11];

/*
     sts = vr$review_topology (
			pMsg        = msg,
			pComponent  = &pieceOE.obj_id,
			CptNum      = -1,
			pMatrix	    = matrix,
			pMdEnv      = &pieceOE.mod_env );
*/

     dCenterPt[0] = matrix[3];
     dCenterPt[1] = matrix[7];
     dCenterPt[2] = matrix[11];
   }

   /* return the results */
   if( pt_coords )
   {
     pt_coords[0][0] = dBeginPt[0];
     pt_coords[0][1] = dBeginPt[1];
     pt_coords[0][2] = dBeginPt[2];

     pt_coords[1][0] = dCenterPt[0];
     pt_coords[1][1] = dCenterPt[1];
     pt_coords[1][2] = dCenterPt[2];

     pt_coords[2][0] = dEndPt[0];
     pt_coords[2][1] = dEndPt[1];
     pt_coords[2][2] = dEndPt[2];
   }

   End
   return sts;
}

/* This funcion Sum's up the Length of the pipe for each node, by finding
out the individual child's length. */
IGRint VDRTSumTreeNode( TGRid *nodeID )
{
  IGRstat retFlag = 0;
  IGRstat sts;
 
  TGRid    childID;
  TGRid    parentID;
  TVDatFld fld;

  IGRint   i;
  IGRint   j;
  IGRdouble dLength=0.0;

  SetProc( Fn VDRTSumTreeNode ); Begin 

  // Verify Node
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Pull data from each child
  for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) 
  {
    __DBGpr_obj( " Child Id ", childID );
    fld.valueDbl = 0.0;
    VDatFldGetAttrByName( &childID, "est_run_len", &fld );

    __DBGpr_dbl( " est_run_length ", fld.valueDbl );
    dLength += fld.valueDbl;
  }
  __DBGpr_dbl( " est_run_length ", dLength );

  VDatFldSetDbl( &fld, "est_run_len", dLength );
  VDatFldUpdAllAttrs( nodeID, &fld, 1 );

  /* This is for FUTURE, while updating the Piping system, the coordinates
  information for the PORT details also need updating. */
#if 0

  /* If the nodeID we have is PART id then we may have to ensure that the
  PORT information stored in there is intact and up-to-date. B'cas when the
  Component length increase or decrease, the coordinates get changes. So the
  node_x, node_y and node_z informations of the PORT needs to be updated
  accordingly. */

  sts = VDatFldGetAttrByName( nodeID, "node_type", &fld );
  if( !strcmp(fld.valueTxt, "PART") )
  {
     /* get the PART's chidlren ( i.e. PORT's and SEGMENT's ) */
     sts = VDatGetChildren( &runID, &partIDs );
     __DBGpr_int( " Nb. of Childrens ", partIDs.cnt );

     for( i=0; i<partIDs.cnt; i++ )
       __DBGpr_obj( " Child object of Run ", partIDs.list[i] );
     
     for( i=0; i<childIDs.cnt; i++ )
     {
          /* Get the "node_type" attribute, so that we can identify PORT
          object among childrens */
          sts = VDatFldGetAttrByName( &childIDs.list[i], "node_type", &fld );

          if( !strcmp(fld.valueTxt, "PORT") )
          {
             /* Pick up the second PORT id, for the FirstCmp */
             portID_0 = childIDs.list[i];
          }
     }
  }
#endif

wrapup:
  End
  return 1;
}

/* This is an supporting function called to return the "node_name & node_guid"
of a particular PART */
IGRint VDRTGetPortInfo_FromParts( TGRid partID, TGRid SecPartID,
				IGRchar *node1_guid, IGRchar *node1_name,
				IGRchar *node2_guid, IGRchar *node2_name,
				TGRmd_env mod_env )
{
      IGRint 	j, sts, NextCpt, port_no; 
      IGRdouble FirstNodeFlag = -1, SecNodeFlag=-1;
      IGRint	firstPortNo, secondPortNo;
      IGRlong	msg, status;
      IGRchar	GUID[128];
      IGRchar 	szNodeType[64];
      TGRid	portID_0, leafID;
      TGRid 	prevleafID, lastleafID;
      TGRid	firstPortID, secondPortID, NextId;
      TVDvlaID 	childIDs, sec_childIDs;
      TGRobj_env prevObjOE, lastObjOE;
      TGRobj_env objOE;

      SetProc( Fn VDRTGetPortInfo_FromParts ); Begin 

      /* Get the node_flag...this is to track down the BENT PIPE and to retrieve
      proper information. Node_flag for BENT PIPE is set to 12 */
      vdsa$GetStruct( objID = &partID, 
		      name = "node_flag",
		      dbl = &FirstNodeFlag );
      __DBGpr_dbl( " node_flag of partId ", FirstNodeFlag );

      vdsa$GetStruct( objID = &SecPartID, 
		      name = "node_flag",
		      dbl = &SecNodeFlag );
      __DBGpr_dbl( " node_flag of SecPartID ", SecNodeFlag );

      /* Get all the childrens of partID, from which we can obtain PORT 
      objects of the partID */
      childIDs.cnt = 0;

      sts = VDatGetChildren( &partID, &childIDs );
      __DBGpr_int( " Nb. of Childrens for First Part ", childIDs.cnt );

      sec_childIDs.cnt = 0;

      sts = VDatGetChildren( &SecPartID, &sec_childIDs );
      __DBGpr_int( " Nb. of Childrens  for Second Part", sec_childIDs.cnt );

      /* In the case of the BENT PIPE obtain the last leaf component so as to
      obtain the adjacent component of that to obtain the correct PORT info,
      from the Next PART to construct a JOINT */
      if( (int)FirstNodeFlag == 12 )
      {
	  __DBGpr_com( " PART is a BENT PIPE " );

	  prevleafID = childIDs.list[childIDs.cnt-4];
	  __DBGpr_obj( " Prev. LeafID ", prevleafID );

	  sts = VDatGetLeafObject( &prevleafID, &prevObjOE );
	  __DBGpr_obj( " prev. Route Component Id ", prevObjOE.obj_id );

	  lastleafID = childIDs.list[childIDs.cnt-3];
	  __DBGpr_obj( " Last Leaf Id ", lastleafID );

	  sts = VDatGetLeafObject( &lastleafID, &lastObjOE );
	  __DBGpr_obj( " last Route Component Id ", lastObjOE.obj_id );

	  /* to find out the actual port_no, we do the reverse way by checking
	  with neighbouring component Object ID */

	  port_no = 0;
	  sts = vr$review_topology( pMsg = &msg,
				    pComponent = &lastObjOE.obj_id,
				    CptNum = port_no,
				    pNeighbor = &NextId,
				    pMdEnv = &lastObjOE.mod_env );

	  __DBGpr_obj( " Adjacent Route Comp ", NextId );

	  if( ( NextId.objid != prevObjOE.obj_id.objid ) ||
	      ( NextId.osnum != prevObjOE.obj_id.osnum ) )
	      port_no = 1;

	  firstPortID = childIDs.list[childIDs.cnt-1];

	  __DBGpr_obj( " First PORT Id ", firstPortID );
	  firstPortNo = port_no;
	  objOE = lastObjOE;
      }
      else /* otherwise the last child is nothing but the leaf object */
      {
	  lastleafID = childIDs.list[childIDs.cnt-1];
	  __DBGpr_obj( " Last Leaf Object ", lastleafID );

	  sts = VDatGetLeafObject( &lastleafID, &lastObjOE );
	  __DBGpr_obj( " Route Component Id ", lastObjOE.obj_id );

	  if( (int)SecNodeFlag != 12 )
	  {
	     prevleafID = sec_childIDs.list[sec_childIDs.cnt-1];
	     __DBGpr_obj( " Prev. Leaf Id ", prevleafID );

	     sts = VDatGetLeafObject( &prevleafID, &prevObjOE );
	     __DBGpr_obj( " Prev. Route Component ", prevObjOE.obj_id );
	  }
	  else
	  {
	    /* If the Second PART Id happens to be a BENT PIPE */
	    IGRboolean bCorrectLeafId=FALSE;
	    IGRint     i, NumbPar;
	    TGRid      firstleafID;
	    TACrg_coll	AttList[1];

	    __DBGpr_com( " Second PART is a BENT PIPE " );
	    firstleafID = sec_childIDs.list[0];

	    sts = VDatGetLeafObject( &firstleafID, &prevObjOE );
	    __DBGpr_obj( " First. Route Component ", prevObjOE.obj_id );

	    NumbPar = 1;
	    strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

	    status =
	    vr$review_parameters(   pMsg            = &msg,
				    pComponent      = &prevObjOE.obj_id,
				    NbParams        = NumbPar,
				    pList           = AttList,
				    pMdEnv          = &prevObjOE.mod_env );

	    /* Run through all the connect points to check whether its correct
	    Leaf Id that we've selected or not. If the Next Component obtained
	    from the Component doesn't match up with the "LastObj Id" then pick
	    up the Other leaf ( end ) Id for processing */

	    __DBGpr_int( " Nb of Cpts ", (int)AttList[0].desc.value.att_exp );

	    for( i=0; i<(int)AttList[0].desc.value.att_exp; i++ )
	    {
	       TGRid tempNextId;

	       tempNextId.objid = NULL_OBJID;

	       sts = vr$review_topology( pMsg = &msg,
					 pComponent = &prevObjOE.obj_id,
					 CptNum = i,
					 pNeighbor = &tempNextId,
					 pMdEnv = &prevObjOE.mod_env );
	       
	       __DBGpr_obj( " TempNext Id ", tempNextId );

	       if( ( tempNextId.objid == lastObjOE.obj_id.objid ) &&
		   ( tempNextId.osnum == lastObjOE.obj_id.osnum ) )
	       {
		   __DBGpr_com( " Found the correct leaf Id " );
		   bCorrectLeafId = TRUE;
	       }
	    }

	    /* If we haven't found the correct leafId, try with the other leafId
	    of the other end of the BENT PIPE */
	    if( !bCorrectLeafId )
	    {
	       firstleafID = sec_childIDs.list[sec_childIDs.cnt-1];
	       __DBGpr_obj( "  Other ends leaf Id ", firstleafID );

	       sts = VDatGetLeafObject( &firstleafID, &prevObjOE );
	       __DBGpr_obj( " 1 First. Route Component ", prevObjOE.obj_id );
	    }
	  }

	  port_no = 0;
	  sts = vr$review_topology( pMsg = &msg,
				    pComponent = &lastObjOE.obj_id,
				    CptNum = port_no,
				    pNeighbor = &NextId,
				    pMdEnv = &lastObjOE.mod_env );

	  __DBGpr_obj( " Next Comp. Id ", NextId );

	  if( ( NextId.objid != prevObjOE.obj_id.objid ) ||
	      ( NextId.osnum != prevObjOE.obj_id.osnum ) )
	      port_no = 1;

	  firstPortID = childIDs.list[port_no];
	  firstPortNo = port_no;
	  objOE = lastObjOE;
	  __DBGpr_int( " Post No. ", port_no );
      }

      /* find out the Next/Neighbouring Component's Connect point, to which
      the First Component is connected. So as to get the correrct PORT no. from
      the Next Object */
      __DBGpr_obj( " Get the Comp. Next Cpt. ", objOE.obj_id );

      /********** AAAAAAAAAAAAA
	  sts = vr$review_topology( pMsg = &msg,
				    pComponent = &lastObjOE.obj_id,
				    CptNum = port_no,
				    pNeighbor = &NextId,
				    pMdEnv = &lastObjOE.mod_env );

      ********* AAAAAAAAAAAAA*/
      sts = vr$review_topology( pMsg = &msg,
				pComponent = &objOE.obj_id,
				CptNum = (int)port_no,
				pNeighCpt = &NextCpt,
				pNeighbor = &NextId,
				pMdEnv = &objOE.mod_env );
       
      __DBGpr_int( " 0 Second PORT No ", (short)NextCpt );

      secondPortNo = (short) NextCpt;
      __DBGpr_int( " Second PORT No ", secondPortNo );

      if( (int)SecNodeFlag != 12 )
      {
	 secondPortID = sec_childIDs.list[secondPortNo];
      }
      else /* If the second partId happends to be a BENT PIPE */
      {
	 __DBGpr_com( " Second Part is a BENT PIPE " );
	 //for the Bent pipe(sec. PART) always the the first PORT has to be
	 //considered
	 secondPortID = sec_childIDs.list[sec_childIDs.cnt-2]; 
      }

      __DBGpr_obj( " PORT Id ", firstPortID );
      __DBGpr_obj( " PORT Id ", secondPortID );

      /* Get the attributes "node_guid" and "port_name" form the PortIDs */
      sts = vdsa$GetStruct( objID = &firstPortID, name = "node_guid",
                            txt = szNodeType );
      strcpy( node1_guid, szNodeType );

      sts = vdsa$GetStruct( objID = &secondPortID, name = "node_guid",
                            txt = szNodeType );
      strcpy( node2_guid, szNodeType );

      szNodeType[0] = '\0';
      sts = vdsa$GetStruct( objID = &firstPortID, name = "node_name",
                            txt = szNodeType );
      strcpy( node1_name, szNodeType );

      szNodeType[0] = '\0';
      sts = vdsa$GetStruct( objID = &secondPortID, name = "node_name",
                            txt = szNodeType );
      strcpy( node2_name, szNodeType );

      __DBGpr_str( " node1_name ", node1_name );
      __DBGpr_str( " node2_name ", node2_name );

      End
      return OM_S_SUCCESS;
}

/* This functions constructs the PART joints object, under the RUN */
IGRint VDRTConstPartJoints( 	TGRid runID, TGRid rdbJointsID, 
				TGRobj_env fc_id  )
{
   IGRint 	i, sts;
   TVDvlaID 	partIDs;

   SetProc( Fn VDRTConstPartJoints ); Begin 

   /* Get all the childrens connected to the RUNs */
   sts = VDatGetChildren( &runID, &partIDs );
   __DBGpr_int( " Nb. of Childrens ", partIDs.cnt );

   for( i=0; i<partIDs.cnt; i++ )
     __DBGpr_obj( " Child object of Run ", partIDs.list[i] );

   for( i=0; i< (partIDs.cnt-1); i++ )
   {
      IGRint 	j;
      IGRchar	jointName[128], GUID[128];
      IGRchar	node1_name[64], node2_name[64];
      IGRchar	node1_guid[128], node2_guid[128];
      IGRchar 	szNodeType[64];
      TVDatFld	fld, fld_joint[3];
      TGRid	FirstCmp, SecondCmp;
      TGRid	jointsID;
      TVDvlaID 	childIDs;
      TGRobj_env jointsOE;

      /* The joint object will be created between these PARTs */
      FirstCmp = partIDs.list[i];
      SecondCmp = partIDs.list[i+1];

      sts = VDRTGetPortInfo_FromParts( FirstCmp, SecondCmp, 
				node1_guid, node1_name,
				node2_guid, node2_name, fc_id.mod_env );

      /****
      sts = VDRTGetPortInfo_FromPart( SecondCmp, TRUE,
				node2_guid, node2_name );
      ****/

      jointName[0] = '\0';
      sprintf( jointName, "%s-%s", node1_name, node2_name );
      sts = VDatCreateNode( &runID, &rdbJointsID,
			 jointName, &jointsID );

      /* create the GUID for the JOINT object */
      sts = VDmt_create_GUID( &fc_id, GUID );

      /* Set the Attributes into the JOINT object */

      VDatFldSetTxt( &fld_joint[0], "node_guid", GUID );
      VDatFldSetTxt( &fld_joint[1], "node_guid1", node1_guid );
      VDatFldSetTxt( &fld_joint[2], "node_guid2", node2_guid );

      VDatFldUpdAllAttrs( &jointsID, fld_joint, 3 );
   }

   End
   return OM_S_SUCCESS;
}

/* Given a runID this function returns the "last" or "first" partID, among the
list of PARTs in the RUN */
IGRint VDRTGetRunEndComp( TGRid runID, TGRid *end_partid, 
			  IGRboolean bSecondRunCmp )
{
   IGRint 	j, sts;
   TVDvlaID 	partIDs;

   SetProc( Fn VDRTGetRunEndComp ); Begin 

   partIDs.cnt = 0;

   /* Get all the childrens connected to the RUNs */
   sts = VDatGetChildren( &runID, &partIDs );
   __DBGpr_int( " Nb. of Childrens ", partIDs.cnt );

   for( j=0; j< (partIDs.cnt-1); j++ )
   {
      IGRchar 	szNodeType[64];

      szNodeType[0] = '\0';
      __DBGpr_obj( " PART's ID ", partIDs.list[j] );

      vdsa$GetStruct( objID = &partIDs.list[j], 
		      name = "node_type",
		      txt = szNodeType );
      __DBGpr_str( " node_type of PART ", szNodeType );

      if( !strcmp(szNodeType, "PART") )
      {
	 /* Pick up the second PORT id, for the FirstCmp */
	 *end_partid = partIDs.list[j];

	 /* If the firstport information needed skip the remaining loop */
	 if( bSecondRunCmp )
	 {
	   j=partIDs.cnt;
	 }
      }
  }

  /* There are cases, where a RUN could end up with one PART. for example
  VALVE */
  if( partIDs.cnt == 1 )
  {
     *end_partid = partIDs.list[0];
  }

  End
  return OM_S_SUCCESS;
}

/* Given a lineID this function returns the "last" or "first" runID, among the
list of RUNs in the line */
IGRint VDRTGetLineEndRun( TGRid lineID, TGRid *end_runid, 
			  IGRboolean bSecondLineRun )
{
   IGRint 	j, sts;
   TVDvlaID 	runIDs;

   SetProc( Fn VDRTGetLineEndRun ); Begin 

   runIDs.cnt = 0;

   /* Get all the childrens connected to the LINEs */
   sts = VDatGetChildren( &lineID, &runIDs );
   __DBGpr_int( " Nb. of Childrens ", runIDs.cnt );

   for( j=0; j< (runIDs.cnt-1); j++ )
   {
      IGRchar 	szNodeType[64];

      szNodeType[0] = '\0';
      __DBGpr_obj( " RUN's ID ", runIDs.list[j] );

      vdsa$GetStruct( objID = &runIDs.list[j], 
		      name = "node_type",
		      txt = szNodeType );
      __DBGpr_str( " node_type of PART ", szNodeType );

      if( !strcmp(szNodeType, "RUN") )
      {
	 /* Pick up the second PORT id, for the FirstCmp */
	 *end_runid = runIDs.list[j];

	 /* If the firstport information needed skip the remaining loop */
	 if( bSecondLineRun )
	 {
	   j=runIDs.cnt;
	 }
      }
   }

   /* There are cases, where a LINE could end up with one RUN. */
   if( runIDs.cnt == 1 )
   {
      *end_runid = runIDs.list[0];
   }

   End
   return OM_S_SUCCESS;
}

#ifdef THIS_FUNCTION_HAS_NOT_BEEN_DEFINED
/* This functions constructs the joints between RUN object, under the LINE */
IGRint VDRTConstRunJoints( TGRid lineID, TGRid rdbJointsID, TGRobj_env fc_id )	
{
   IGRint	sts, j, run_no;
   IGRchar	jointName[128], GUID[128];
   IGRchar	node1_name[64], node2_name[64];
   IGRchar	node1_guid[128], node2_guid[128];
   TGRid	setID, leafID, partID, jointsID;
   TGRobj_env	objOE;
   TGRobj_env 	jointsOE;
   TVDatFld	fld_joint[3];
   TVDvlaID  	runIDs;

   SetProc( Fn VDRTConstRunJoints ); Begin 

   runIDs.cnt = 0;

   /* Get all the childrens connected to the LINEs */
   sts = VDatGetChildren( &lineID, &runIDs );
   __DBGpr_int( " Nb. of Childrens ", runIDs.cnt );

   for( run_no=0; run_no< (runIDs.cnt-1); run_no++ )
   {
       TGRid	FirstRunId, SecondRunId;
       TGRid	firstrun_end__part, secondrun_end__part;

       FirstRunId = runIDs.list[run_no];
       SecondRunId = runIDs.list[run_no+1];

       /* First get the "PORT" information for the First run's last PART's
       second PORT information. */

       /*pass FALSE for the last argument to fetch the last_part from the RUN*/
       sts = VDRTGetRunEndComp( FirstRunId, &firstrun_end__part, FALSE );
       __DBGpr_obj( " First Run's Last PART Id ", firstrun_end__part );

       sts = VDRTGetPortInfo_FromParts( firstrun_end__part, 
				secondrun_end__part, node1_guid, node1_name,
				node2_guid, node2_name, fc_id.mod_env );

#if 0
       /* Get the second port information from the firstrun's last part */
       sts = VDRTGetPortInfo_FromPart( firstrun_end__part, FALSE, 
				node1_guid, node1_name );

       /* Secondly get the "PORT" information for the Second run's First PART's
       First PORT information */

       /*pass TRUE for the last argument to fetch the last_part from the RUN*/
       sts = VDRTGetRunEndComp( SecondRunId, &secondrun_end__part, TRUE );
       __DBGpr_obj( " Second Run's First PART Id ", secondrun_end__part );

       /* Get the second port information from the firstrun's last part */
       sts = VDRTGetPortInfo_FromPart( secondrun_end__part, TRUE, 
				node2_guid, node2_name );
#endif

       jointName[0] = '\0';
       sprintf( jointName, "%s-%s", node1_name, node2_name );
       sts = VDatCreateNode( &lineID, &rdbJointsID,
			  jointName, &jointsID );

       /* create the GUID for the JOINT object */
       sts = VDmt_create_GUID( &fc_id, GUID );

       /* Set the Attributes into the JOINT object */
       VDatFldSetTxt( &fld_joint[0], "node_guid", GUID );
       VDatFldSetTxt( &fld_joint[1], "node_guid1", node1_guid );
       VDatFldSetTxt( &fld_joint[2], "node_guid2", node2_guid );

       VDatFldUpdAllAttrs( &jointsID, fld_joint, 3 );
   }

   End
   return OM_S_SUCCESS;
}
#endif THIS_FUNCTION_HAS_NOT_BEEN_DEFINED

/* This functions constructs the LINE joints object, under the SYSTEM */
IGRint VDRTConstLineJoints( TGRid systemID, TGRid rdbJointsID, 
			    TGRobj_env fc_id )	
{
   IGRint	sts, j, sys_no, line_no;
   IGRchar	jointName[128], GUID[128];
   IGRchar	node1_name[64], node2_name[64];
   IGRchar	node1_guid[128], node2_guid[128];
   TGRid	setID, leafID, partID, jointsID;
   TGRobj_env	objOE;
   TGRobj_env 	jointsOE;
   TVDatFld	fld_joint[3];
   TVDvlaID  	runIDs, lineIDs;

   SetProc( Fn VDRTConstLineJoints ); Begin 

   lineIDs.cnt = 0;
   /* Get all the childrens connected to the LINEs */
   sts = VDatGetChildren( &systemID, &lineIDs );
   __DBGpr_int( " Nb. of Childrens ", lineIDs.cnt );

   for( line_no=0; line_no< (lineIDs.cnt-1); line_no++ )
   {
       TGRid	FirstLineId, SecondLineId;
       TGRid	FirstRunId, SecondRunId;
       TGRid	firstrun_end__part, secondrun_end__part;

       FirstLineId = lineIDs.list[line_no];
       SecondLineId = lineIDs.list[line_no+1];

       /* First get the "PORT" information for the First line's First run's 
       last PART's second PORT information. */

       /*pass FALSE for the last argument to fetch the last_run from the LINE*/
       sts = VDRTGetLineEndRun( FirstLineId, &FirstRunId, FALSE );
       __DBGpr_obj( " First Line's Last RUN Id ", FirstRunId );

       /*pass FALSE for the last argument to fetch the last_part from the RUN*/
       sts = VDRTGetRunEndComp( FirstRunId, &firstrun_end__part, FALSE );
       __DBGpr_obj( " First Run's Last PART Id ", firstrun_end__part );

       sts = VDRTGetPortInfo_FromParts( firstrun_end__part, 
				secondrun_end__part, node1_guid, node1_name,
				node2_guid, node2_name, fc_id.mod_env );
#if 0
       /* Get the second port information from the firstrun's last part */
       sts = VDRTGetPortInfo_FromPart( firstrun_end__part, FALSE, 
				node1_guid, node1_name );

       /* Having got the First Line end PORT information, now we'll obtain the
       Second Line start PORT information */

       /*pass TRUE for the last argument to fetch the first_run from the LINE*/
       sts = VDRTGetLineEndRun( SecondLineId, &SecondRunId, TRUE );
       __DBGpr_obj( " Second Line's First RUN Id ", SecondRunId );

       /*pass TRUE for the last argument to fetch the first_part from the RUN*/
       sts = VDRTGetRunEndComp( SecondRunId, &secondrun_end__part, TRUE );
       __DBGpr_obj( " Second Run's First PART Id ", secondrun_end__part );

       /* Get the second port information from the secondrun's first part */
       sts = VDRTGetPortInfo_FromPart( secondrun_end__part, TRUE, 
				node2_guid, node2_name );
#endif

       jointName[0] = '\0';
       sprintf( jointName, "%s-%s", node1_name, node2_name );
       sts = VDatCreateNode( &systemID, &rdbJointsID,
			  jointName, &jointsID );

       /* create the GUID for the JOINT object */
       sts = VDmt_create_GUID( &fc_id, GUID );

       /* Set the Attributes into the JOINT object */
       VDatFldSetTxt( &fld_joint[0], "node_guid", GUID );
       VDatFldSetTxt( &fld_joint[1], "node_guid1", node1_guid );
       VDatFldSetTxt( &fld_joint[2], "node_guid2", node2_guid );

       VDatFldUpdAllAttrs( &jointsID, fld_joint, 3 );
   }

   End
   return OM_S_SUCCESS;
}

IGRint VDRTGetPipeLines_From_Runs( pipe_run_info **PipeRun, IGRint PiIndex, 
				    struct PipeLine_Info *line_info, 
				    IGRint *NbLine,
				    TGRmd_env mod_env ) 
{
   IGRint	run_no, line_no, NumbPar;
   IGRlong	msg, status;
   IGRchar	PipeSeqNo[20];
   TACrg_coll 	AttList[2];
   TGRid	first_comp;

   SetProc( Fn VDRTGetPipeLines_From_Runs ); Begin 

   if( PiIndex <= 0 ) 
   { 
      __DBGpr_int( " No. of runs ", PiIndex );
      *NbLine = -1;
      End
      return 0; 
   }

   first_comp = PipeRun[0]->run_start.comp_id;

   /* for line_sequence number */
   NumbPar = 1;
   strcpy( AttList[0].name, VR_N_SEQ_NUMBER_AN );

   status =
   vr$review_parameters( pMsg            = &msg,
			 pComponent      = &first_comp,
			 NbParams        = NumbPar,
			 pList           = AttList,
			 pMdEnv          = &mod_env );

   strcpy( line_info[0].seq_no, AttList[0].desc.value.att_txt );
   line_info[0].run_info[0].run_start.comp_id = PipeRun[0]->run_start.comp_id;
   line_info[0].run_info[0].run_start.conn_pt_id = PipeRun[0]->run_start.conn_pt_id;

   line_info[0].run_info[0].run_end.comp_id = PipeRun[0]->run_end.comp_id;
   line_info[0].run_info[0].run_end.conn_pt_id = PipeRun[0]->run_end.conn_pt_id;
   line_info[0].NbRuns = 1;
   *NbLine = 1;

   __DBGpr_str( " Pipe Sequence Number ", line_info[0].seq_no );
   __DBGpr_int( " Line No : ", *NbLine );
   __DBGpr_obj( " Line Start CompId ", line_info[0].run_info[0].run_start.comp_id );
   __DBGpr_obj( " Line End CompId ", line_info[0].run_info[0].run_end.comp_id );

   __DBGpr_int( " Nb. of Runs ", PiIndex );
   for( run_no=1; run_no<PiIndex; run_no++ )
   {
     IGRboolean bRunFound;
     IGRint 	runIndex=0;
     IGRchar	RunSeqNo[20];

     first_comp = PipeRun[run_no]->run_start.comp_id;
     __DBGpr_obj( " New Run Component Id ", first_comp );

     status =
     vr$review_parameters( pMsg            = &msg,
			   pComponent      = &first_comp,
			   NbParams        = NumbPar,
			   pList           = AttList,
			   pMdEnv          = &mod_env );

     strcpy( RunSeqNo, AttList[0].desc.value.att_txt );
     __DBGpr_str( " New Run Sequence Number ", RunSeqNo );

     bRunFound = FALSE;

     for( line_no=0; ( line_no<*NbLine && !bRunFound ); line_no++ )
     {
        __DBGpr_int( " Nb. of Runs in the Line ", line_info[line_no].NbRuns );
	runIndex = line_info[line_no].NbRuns;

	/* If the sequence numbers are same then add the RUN under the same
	LINE. If not we have to create a new line for this particular sequence
	number. */
	__DBGpr_str( " Run Sequence Number ", RunSeqNo );
	__DBGpr_str( " Existing Run Seq no. ", line_info[line_no].seq_no );

	if( !strcmp( line_info[line_no].seq_no, RunSeqNo ) )
	{
	   bRunFound = TRUE;

	   __DBGpr_com( " Adding the RUN to the existing LINE ... " );
	   strcpy( line_info[line_no].seq_no, RunSeqNo );

	   line_info[line_no].run_info[runIndex].run_start.comp_id = 
					PipeRun[run_no]->run_start.comp_id;
	   line_info[line_no].run_info[runIndex].run_start.conn_pt_id =
					PipeRun[run_no]->run_start.conn_pt_id;

	   line_info[line_no].run_info[runIndex].run_end.comp_id = 
					PipeRun[run_no]->run_end.comp_id;
	   line_info[line_no].run_info[runIndex].run_end.conn_pt_id = 
					PipeRun[run_no]->run_end.conn_pt_id;

	   (line_info[line_no].NbRuns)++;

	   __DBGpr_int( " Line No : ", *NbLine );
	   __DBGpr_obj( " Line Start CompId ", line_info[line_no].run_info[runIndex].run_start.comp_id );
	   __DBGpr_obj( " Line End CompId ", line_info[line_no].run_info[runIndex].run_end.comp_id );
	}
     }

     /* This line sequence number is new, so add a New Line and store the
     information and increment the count by one */
     if( !bRunFound )
     {
	 __DBGpr_com( " Adding the RUN to the New LINE ... " );

	 runIndex = 0;

	 __DBGpr_str( " New Sequence Number ", RunSeqNo );
	 strcpy( line_info[*NbLine].seq_no, RunSeqNo );
	 line_info[*NbLine].run_info[runIndex].run_start.comp_id = 
					PipeRun[run_no]->run_start.comp_id;
	 line_info[*NbLine].run_info[runIndex].run_start.conn_pt_id = 
					PipeRun[run_no]->run_start.conn_pt_id;

	 line_info[*NbLine].run_info[runIndex].run_end.comp_id = 
					PipeRun[run_no]->run_end.comp_id;
	 line_info[*NbLine].run_info[runIndex].run_end.conn_pt_id = 
					PipeRun[run_no]->run_end.conn_pt_id;

	 line_info[*NbLine].NbRuns = 1;

	   __DBGpr_int( " Line No : ", *NbLine );
	   __DBGpr_obj( " Line Start CompId ", line_info[*NbLine].run_info[runIndex].run_start.comp_id );
	   __DBGpr_obj( " Line End CompId ", line_info[*NbLine].run_info[runIndex].run_end.comp_id );
	 (*NbLine)++;
     }
   }

   __DBGpr_int( " Nb. of Lines ", *NbLine );
   for( line_no=0; line_no<*NbLine; line_no++ )
      __DBGpr_int( " Nb. of RUNs in a Line ", line_info[line_no].NbRuns );

   End
   return OM_S_SUCCESS;
}

IGRint VDRTGetPortInfo_AtCpt( TGRid partID, IGRint CptNo, 
				IGRchar *node_guid, IGRchar *node_name )
{
      IGRint 	j, sts;
      IGRchar	GUID[128];
      IGRchar 	szNodeType[64];
      TGRid	portID_0;
      TVDvlaID 	childIDs;

      SetProc( Fn VDRTGetPortInfo_AtCpt ); Begin 

      childIDs.cnt = 0;

      /* Get all the childrens of partID, from which we can obtain PORT
      objects of the partID */
      sts = VDatGetChildren( &partID, &childIDs );
      __DBGpr_int( " Nb. of Childrens ", childIDs.cnt );

      portID_0.objid = NULL_OBJID;

      node_name[0] = '\0';

      for( j=0; j<childIDs.cnt; j++ )
      {
          /* Get the "node_type" attribute, so that we can identify PORT
          object among childrens. */

          szNodeType[0] = '\0';
          __DBGpr_obj( " PART's child ID ", childIDs.list[j] );

          vdsa$GetStruct( objID = &childIDs.list[j],
                          name = "node_type",
                          txt = szNodeType );
          __DBGpr_str( " node_type of Childrens ", szNodeType );

          if( !strcmp(szNodeType, "PORT") )
          {
             /* Pick up the second PORT id, for the FirstCmp */
	     IGRint portNo;

             portID_0 = childIDs.list[j];

	     szNodeType[0] = '\0';
	     sts = vdsa$GetStruct( objID = &portID_0, name = "node_name",
				   txt = szNodeType );

	     __DBGpr_str( " PORT number ", &szNodeType[strlen(szNodeType)-1] );
	     portNo = atoi( &szNodeType[strlen(szNodeType)-1] );
	     __DBGpr_int( " 1 Port Number  ", portNo );

	     if( CptNo == portNo )
	     {
		  strcpy( node_name, szNodeType );
		  j = childIDs.cnt;
	     }
          }
      }

      /* Get the attributes "node_guid" and "port_name" form the portID_0 */
      sts = vdsa$GetStruct( objID = &portID_0, name = "node_guid",
                            txt = szNodeType );
      strcpy( node_guid, szNodeType );

      __DBGpr_str( " PORT Node Name ", node_name );

   End
   return OM_S_SUCCESS;
}

/* This function has been redesigned to consider the inclusion of the 
"piping_lines" code also. Jan 25 1999 */

/* This functions constructs the joints between RUN object, under the LINE */
IGRint VDRTConstRunJoints( TGRid lineID, struct PipeLine_Info line_info,
			   TGRid rdbJointsID, TGRid systemID,
			   TGRid setID, TGRobj_env fc_id, TGRmd_env mod_env )	
{
   IGRboolean	bIsCompWeld=FALSE;
   IGRint	sts, j, run_no, weld_cpt;
   IGRlong	msg;
   IGRchar	jointName[128], GUID[128];
   TGRobj_env	objOE;
   TGRobj_env 	jointsOE;
   TVDatFld	fld_joint[3];

   SetProc( Fn VDRTConstRunJoints ); Begin 

   UI_status( " Constructing Joints ... " );
   __DBGpr_int( " Nb. of Runs in this line ", line_info.NbRuns );

   /*** 
   if( line_info.NbRuns <= 1 ) 
   {
     __DBGpr_com( " We don't need to construct RUN Joints for this line " );
     End
     return OM_S_SUCCESS;
   }
   ***/ 

   for( j=0; j<line_info.NbRuns; j++ )
   {
     IGRint	cpt_no, NumbPar, NbCpts;
     IGRshort 	end_cpt, start_cpt;
     TGRid 	end_compid, start_compid, partID; 
     TGRid	leafID, jointsID;
     TGRobj_env objOE;
     TACrg_coll	AttList[5];
     IGRchar	endcmpSeqNo[20];
     IGRchar 	node1_guid[128], node1_name[64];
     IGRchar 	node2_guid[128], node2_name[64];

     bIsCompWeld = FALSE;

     __DBGpr_obj( " Start Comp. Id ", line_info.run_info[j].run_start.comp_id );
     __DBGpr_int( " Start Cpt ", line_info.run_info[j].run_start.conn_pt_id );

     start_compid = line_info.run_info[j].run_start.comp_id;

     __DBGpr_obj( " End Comp. Id ", line_info.run_info[j].run_end.comp_id );
     __DBGpr_int( " End Cpt ", line_info.run_info[j].run_end.conn_pt_id );

     end_compid = line_info.run_info[j].run_end.comp_id;
     end_cpt = (IGRshort)line_info.run_info[j].run_end.conn_pt_id;

     NumbPar = 2;
     strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );
     strcpy( AttList[1].name, VR_N_SEQ_NUMBER_AN );

     sts = 
     vr$review_parameters(
                            pMsg = &msg,
                            pComponent = &start_compid,
                            NbParams   = NumbPar,
                            pList      = AttList,
                            pMdEnv     = &mod_env );
     
     NbCpts = (IGRint)AttList[0].desc.value.att_exp;
     __DBGpr_int( " Nb. of Connect Points ", NbCpts );

     strcpy( endcmpSeqNo, AttList[1].desc.value.att_txt );

     /* If the RUN has only one component and also if it has only one connect
     point, then it would've been accounted while constructing the other RUN
     joints, so skip this RUN. This condition is mainly written to skip 
     components like DANGLE, CAP, etc which sometimes RUN by itself and trying
     form a JOINT and ultimately leading to more uncessary joints */
     if( NbCpts == 1 ) 
     {
	if( ( start_compid.objid == end_compid.objid ) &&
	    ( start_compid.osnum == end_compid.osnum ) ) continue;
     }

     NumbPar = 2;
     strcpy( AttList[0].name, VR_N_COMP_CODE_AN );
     strcpy( AttList[1].name, VR_N_NB_CONNECT_IN );

     sts = 
     vr$review_parameters(
                            pMsg = &msg,
                            pComponent = &end_compid,
                            NbParams   = NumbPar,
                            pList      = AttList,
                            pMdEnv     = &mod_env );
     
     /* In the case of the "WELD" component being the last/end component of the
     RUN, we should obtaining the previous PIPE information to construct the
     JOINT */

     if( !strcmp( AttList[0].desc.value.att_txt, "WELD" ) )
     {
	IGRint temp_cpt;
	TGRid temp_compid;

	sts = vr$review_topology( pMsg        = &msg,
                                    pComponent  = &end_compid,
                                    CptNum      = ( end_cpt ) ? 0 : 1,
                                    pNeighbor   = &temp_compid,
                                    pNeighCpt   = &temp_cpt,
                                    pMdEnv      = &mod_env );

	weld_cpt = (IGRshort)temp_cpt;
	bIsCompWeld = TRUE;
	__DBGpr_com( " ## Its a WELD component ## " );

	objOE.obj_id = temp_compid;
	objOE.mod_env = mod_env;
     }
     else
     {
	 objOE.obj_id = end_compid;
	 objOE.mod_env = mod_env;
     }

     NbCpts = (IGRint)AttList[1].desc.value.att_exp;
     __DBGpr_int( " Nb. of Connect Points ", NbCpts );

     /* If the end component happens to be a Single connect pt component,
     it means you've reached the end of the network...and there is no need for
     Joints */
     if( NbCpts == 1 ) 
     {
       continue;
     }

     /* Get the corresponding leafId for the ROUTE object */
     sts = VDatGetObjectLeaf( &objOE, &setID, &leafID );
     __DBGpr_obj( " Leaf Object Id ", leafID );

     /* Get the parent NODE of the leaf object ( i.e. PART id ) */
     sts = VDatGetParentNode( &leafID, &partID );
     __DBGpr_obj( " Node Object Id ", partID );

     if( NbCpts > 2 )
     {
	for( cpt_no=0; cpt_no<NbCpts; cpt_no++ )
	{
	  TGRid	     sec_partID;

	  if( cpt_no == end_cpt ) continue;

	  /* for the TEE component the way of storing the end run is different*/
	  /* Get the information from the PORT */
	  __DBGpr_com( " Calling VDRTGetPortInfo_AtCpt ..." );
	  __DBGpr_int( " cpt_no ", cpt_no );
	  sts = VDRTGetPortInfo_AtCpt( partID, cpt_no, 
				       node1_guid, node1_name );

	  __DBGpr_str( " node guid ", node1_guid );
	  __DBGpr_str( " node name ", node1_name );

	  sts = vr$review_topology( pMsg        = &msg,
                                    pComponent  = &end_compid,
                                    CptNum      = cpt_no,
                                    pNeighbor   = &start_compid,
                                    pNeighCpt   = (IGRint*)&start_cpt,
                                    pMdEnv      = &mod_env );

	  __DBGpr_obj( " Component adjacent to TEE ", start_compid );

	  NumbPar = 2;
	  strcpy( AttList[0].name, VR_N_COMP_TYPE_IN );
	  strcpy( AttList[1].name, VR_N_SEQ_NUMBER_AN );
	  sts =
	  vr$review_parameters(   pMsg            = &msg,
				  pComponent      = &start_compid,
				  NbParams        = NumbPar,
				  pList           = AttList,
				  pMdEnv          = &mod_env );

	  /* If the component adjacent to the TEE component is DANGLE then
	  don't construct the Joint between them. B'cas Dangle won't appear
	  in the TREE. */
	  if( AttList[0].desc.value.att_exp == -1 ) continue;

	  objOE.obj_id = start_compid;
	  objOE.mod_env = mod_env;

	  /* Get the corresponding leafId for the ROUTE object */
	  sts = VDatGetObjectLeaf( &objOE, &setID, &leafID );

	  __DBGpr_obj( " Leaf Id ", leafID );

	  /* Get the parent NODE of the leaf object ( i.e. PART id ) */
	  sts = VDatGetParentNode( &leafID, &sec_partID );
	  __DBGpr_obj( " PART Id ", partID );

	  sts = VDRTGetPortInfo_AtCpt( sec_partID, start_cpt, 
					  node2_guid, node2_name );

	  sprintf( jointName, "%s-%s", node1_name, node2_name );
	  __DBGpr_str( " RUN Joint Name ", jointName );

	  {
	      TGRid parentID;

	      __DBGpr_str( " First Cmp Seq No ", endcmpSeqNo );
	      __DBGpr_str( " Second Cmp Seq No ", AttList[1].desc.value.att_txt );
	      if( !strcmp( endcmpSeqNo, AttList[1].desc.value.att_txt ) )
	      {
		  __DBGpr_com( " Cons. JOINTS under LINE " );
		  parentID = lineID;
	      }
	      else
	      {
		  __DBGpr_com( " Cons. JOINTS under SYSTEM " );
		  parentID = systemID;
	      }

	      sts = VDatCreateNode( &parentID, &rdbJointsID,
				 jointName, &jointsID );
	  }
			    
	  /* create the GUID for the JOINT object */
	  sts = VDmt_create_GUID( &fc_id, GUID );

	  /* Set the Attributes into the JOINT object */
	  VDatFldSetTxt( &fld_joint[0], "node_guid", GUID );
	  VDatFldSetTxt( &fld_joint[1], "node_guid1", node1_guid );
	  VDatFldSetTxt( &fld_joint[2], "node_guid2", node2_guid );

          VDatFldUpdAllAttrs( &jointsID, fld_joint, 3 );
	}
     }
     else if( NbCpts != 1 )
     {
	  /* Get the information from the PORT */
	  __DBGpr_com( " Calling VDRTGetPortInfo_AtCpt ...." );
	  __DBGpr_int( " Connect Point (end ) ", end_cpt );

	  sts = VDRTGetPortInfo_AtCpt( partID, (bIsCompWeld)? weld_cpt:end_cpt, 
				       node1_guid, node1_name );

	  __DBGpr_str( " Node name ", node1_name );

	  sts = vr$review_topology( pMsg        = &msg,
                                    pComponent  = &end_compid,
                                    CptNum      = end_cpt,
                                    pNeighbor   = &start_compid,
                                    pNeighCpt   = (IGRint*)&start_cpt,
                                    pMdEnv      = &mod_env );

	  objOE.obj_id = start_compid;
	  objOE.mod_env = mod_env;

	  /* Get the corresponding leafId for the ROUTE object */
	  sts = VDatGetObjectLeaf( &objOE, &setID, &leafID );

	  /* Get the parent NODE of the lead object ( i.e. PART id ) */
	  sts = VDatGetParentNode( &leafID, &partID );

	  sts = VDRTGetPortInfo_AtCpt( partID, start_cpt, 
					  node2_guid, node2_name );

	  sprintf( jointName, "%s-%s", node1_name, node2_name );
	  __DBGpr_str( " RUN Joint Name ", jointName );

	  {
	      TGRid parentID;

	      NumbPar = 1;
	      strcpy( AttList[0].name, VR_N_SEQ_NUMBER_AN );

	      sts =
	      vr$review_parameters(   pMsg            = &msg,
				      pComponent      = &start_compid,
				      NbParams        = NumbPar,
				      pList           = AttList,
				      pMdEnv          = &mod_env );

	      __DBGpr_str( " First Cmp Seq No ", endcmpSeqNo );
	      __DBGpr_str( " Second Cmp Seq No ", AttList[0].desc.value.att_txt );
	      if( !strcmp( endcmpSeqNo, AttList[0].desc.value.att_txt ) )
	      {
		  __DBGpr_com( " Cons. JOINTS under LINE " );
		  parentID = lineID;
	      }
	      else
	      {
		  __DBGpr_com( " Cons. JOINTS under SYSTEM " );
		  parentID = systemID;
	      }

	      sts = VDatCreateNode( &parentID, &rdbJointsID,
				 jointName, &jointsID );
	  }

	  /***** Not needed anymore 
	  sts = VDatCreateNode( &lineID, &rdbJointsID,
			     jointName, &jointsID );
	   Not needed anymore ***** / 
			    
	  /* create the GUID for the JOINT object */
	  sts = VDmt_create_GUID( &fc_id, GUID );

	  /* Set the Attributes into the JOINT object */
	  VDatFldSetTxt( &fld_joint[0], "node_guid", GUID );
	  VDatFldSetTxt( &fld_joint[1], "node_guid1", node1_guid );
	  VDatFldSetTxt( &fld_joint[2], "node_guid2", node2_guid );

          VDatFldUpdAllAttrs( &jointsID, fld_joint, 3 );
     }
   }

   UI_status( " Completed Joints Constr ... " );
   End
   return OM_S_SUCCESS;
}
