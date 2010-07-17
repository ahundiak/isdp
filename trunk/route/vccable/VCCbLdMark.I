/* $Id: VCCbLdMark.I,v 1.3 2002/05/29 20:25:43 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vccable/VCCbLdMark.I
 *
 * Description:
 *
 *      Methods for instance management
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCbLdMark.I,v $
 *      Revision 1.3  2002/05/29 20:25:43  anand
 *      Third set of bug fixes for the split cable functionality.
 *      Merge does not corrupt the model. The marker information is
 *      now propagated to newly sketched cables/sub-cables. Changed
 *      interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *      Revision 1.2  2002/05/17 19:23:35  anand
 *      Misc. bug fixes. Covers change rejects CR 5846 and 6040.
 *      Ensures that new sub-cables carry over signals of parent
 *      cables.
 *
 *      Revision 1.1  2002/05/08 15:48:22  anand
 *      Files added/modified for sub-cable functionality.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

class implementation VCCable;

#include "ACrg_collect.h"
#include "VDmem.h"
#include "VCLead.h"
#include "vrdbgmacros.h"

method VCDataTypeSize( IGRint *Size )
{
    switch( me->DataType )
    {
        case VC_LEGACY_JUN02 :
	    *Size =  0;
	    break;
	case VC_ACRG_COLLECT :
	    *Size =  sizeof( struct ACrg_coll );
	    break;
//      case 2 :    *Size =  sizeof( struct XX );
                    /* Alternative structure when needed after 2.7 */
        default :   *Size = 0 ;
    }
    __DBGpr_int("Size returned by VCDataTypeSize", *Size);
    return OM_S_SUCCESS;
}
 

method VCSetDataVLA( void	*InstanceAttr;
		     IGRint	NbInstAttr;
		     IGRshort	DataType )
{
    IGRint status,size;
    IGRint PacketSize;
 
    SetProc( VCCable_VCCSetDataVLA ); Begin
 
    __DBGpr_me();
 
    /* memory allocation */
    me->DataType = DataType;
    status = om$send( msg = message VCRoot.VCDataTypeSize( &PacketSize ),
		      targetid = my_id );
    size = NbInstAttr * PacketSize;
    __DBGpr_int("Packet size", PacketSize);

    /* Allocate memory in the vla */
    status = om$vla_set_dimension( varray = me->Data, size = size  );
    as$status(action = RET_STATUS);

    if( ! size )
	goto quit;
    __DBGpr_int(" Size of me->Data",size);
 
    __DBGpr_com("Doing memcpy");
    memcpy(me->Data, InstanceAttr, size);

#if 0
    // Retaining this FWIW
    switch( me->DataType )
    {
        case VC_LEGACY_JUN02:
	    End;
	    return OM_S_SUCCESS;
	case VC_ACRG_COLLECT:
	    __DBGpr_com("Doing memcpy");
            memcpy(me->Data, InstanceAttr, size);
            break;
//      case 2:
//          memcpy( me->Data, &XX, size );
			/* Alternative structure when needed after 2.7 */
//          break;
        default:
	    End;
            return OM_E_ABORT;
    }
#endif

    __DBGpr_int( " Dimension of the Offset array ",
                        om$dimension_of( varray = me->Data ) );
quit:
    End;
    return(OM_S_SUCCESS);
}
 

method VCGetDataVLA( void	*InstAttr;
		     IGRint	*nNbAttr;
		     IGRshort	*DataType )
{
    IGRint status;

    SetProc(VCCable_VCGetDataVLA); Begin

    status = om$send( msg = message VCRoot.VCGetDataVLA( InstAttr,
							 nNbAttr,
							 DataType ),
		      targetid = my_id,
		      mode = OM_e_wrt_message );

#ifdef vdsDEBUG
    if( *DataType == VC_ACRG_COLLECT )
    {
	// Debug purpose only.
	int i;
	struct ACrg_coll *AttrPtr;

	AttrPtr = (struct ACrg_coll *) InstAttr;

	for( i=0 ; i<*nNbAttr ; i++ )
	{
	    __DBGpr_int("Index of Attribute",i);
	    __DBGpr_str("Attribute",AttrPtr[i].name);
	    __DBGpr_str("Value",AttrPtr[i].desc.value.att_txt);
	}
    }
#endif

    End;
    return status;
} 

/* 
 * Function for initializing marker information in a cable (whether Trunk or
 * Sub).
 *
 * Inputs: Cable object ID.
 *
 * Process:
 *
 * 1. Get the number of leads in cable, the lead names, and get con_num for
 * each leadname.
 *
 * 2. Check if the DataVLA has been set for this cable; get type.
 *
 * 3. If DataVLA has not been set (VLA size is zero), it is a legacy file. Set
 * the DataVLA for:
 * 	o  Number of attributes = Number of leads in cable
 * 	o  Each attribute name being prepared as "Marker_%.3d"
 * 	o  Each attribute value being set as "" (null string)
 *
 * 4. If DataVLA has been set:
 * 	o  Get the number of attributes.
 * 	o  Prepare an array of ACrg_coll structures based on actual lead
 * 	information of cable.
 * 	o  Do a match of the array of attributes prepared in previous step
 * 	versus the instance array of attributes.
 * 	o  If there is an element in the "prepared" attribute that is not there
 * 	in the instance array, set the attribute value to "null" string;
 * 	otherwise, copy the instance attribute value over to the "prepared"
 * 	attribute value.
 *
 *      Synchronize the lead->attribute info for a cable object
 *      The user may have dropped/introduced leads for the cable
 */

IGRlong VCsyncLdAttrInfo( struct GRid *cableID)
{
  IGRlong          retFlag = 0, msg, sts;
  IGRint           i, j, k, nAttr, nCurAttr;
  IGRshort         nEnt, nTab, nLeads;
  IGRshort         dType, *conNum;
  GRname           *ldNames, buff;
  struct VClayout  *Layout;
  struct ACrg_coll *coll, *priv_coll;// priv_collector will be posted 
  IGRint           nDataVLA;        // size to the posted to object
  
  if(!cableID) goto wrapup;

  retFlag       = 0;
  Layout        = NULL;
  conNum        = NULL;
  ldNames       = NULL;
  coll          = NULL;
  priv_coll     = NULL;
  nLeads        = 0; 
  nAttr         = 0; 
  nCurAttr      = 0; 
  nDataVLA      = 0; 

  // Get all the leads for the cable
  nEnt   = nTab = 0;
  sts =
  om$send (msg = message VCDB.VCGetLayout
                              (&msg, NULL, &nLeads, &nTab, NULL),
      senderid = NULL_OBJID,
      targetid = cableID->objid,
      targetos = cableID->osnum);
  if(!(sts&msg&1))
  {
    __DBGpr_obj(" VCDB.VCGetLayout failed for ", *cableID);
    goto wrapup;
  }
  Layout  = _MALLOC(nLeads, struct VClayout);

  sts =
  om$send (msg = message VCDB.VCGetLayout
                              (&msg, NULL, &nLeads, &nTab, Layout),
      senderid = NULL_OBJID,
      targetid = cableID->objid,
      targetos = cableID->osnum);
  if(!(sts&msg&1))
  {
    __DBGpr_obj(" VCDB.VCGetLayout failed for ", *cableID);
    goto wrapup;
  }

  ldNames = _MALLOC(nLeads, GRname);
  conNum  = _MALLOC(nLeads, IGRshort);

  for(j=0; j<nLeads; j++) conNum[j] = -1;
  for(j=0; j<nLeads; j++)
    strcpy(ldNames[j], Layout[j].pDef.Conn.Cable.szLeadId); 

  for(j=0; j<nLeads; j++)
  {
    __DBGpr_int("VC_ConNum_LeadName before msg",msg);
    VC_ConNum_LeadName(&msg, cableID, ldNames[j], &conNum[j]);
    __DBGpr_int("VC_ConNum_LeadName return msg",msg);
    __DBGpr_int("Con num",conNum[j]);
    if((!(msg&1)) || (conNum[j] == -1))
    {
      __DBGpr_obj(" VC_ConNum_LeadName failed for", *cableID);
      __DBGpr_str(" VC_ConNum_LeadName failed for lead", ldNames[j]); 
      goto wrapup;
    }
  }
  // Check if the DataVLA has been set for this cable; get type.
  nAttr = dType = 0;
  sts =
  om$send (msg = message VCRoot.VCGetDataVLA
                         (NULL, &nAttr, &dType),
      senderid = NULL_OBJID,
      targetid = cableID->objid,
      targetos = cableID->osnum);
  if(!(sts&1))
  {
    __DBGpr_obj(" VCCable.VCGetDataVLA failed for ", *cableID);
    goto wrapup;
  }
  __DBGpr_int(" dType ", dType);
  __DBGpr_int(" nAttr ", nAttr);

  switch(dType)
  {
    case VC_LEGACY_JUN02 : // Legacy data
                           break;
    case VC_ACRG_COLLECT : // struct ACrg_collect
                           coll       = _MALLOC(nAttr, struct ACrg_coll);
                           sts =
                           om$send (msg = message VCRoot.VCGetDataVLA
                                          ((void *)coll, &nAttr, &dType),
                               senderid = NULL_OBJID,
                               targetid = cableID->objid,
                               targetos = cableID->osnum);
                           if(!(sts&1))
                           {
                             __DBGpr_obj(" VCCable.VCGetDataVLA failed for ", 
                                           *cableID);
                             goto wrapup;
                           }
                           break;

    default              : break;    
  }
  /*
   * Prepare the attribute names for the marker
   * Currently i have only "1" attribute and may
   * have more in the future
   * Prepare the master private collector to be
   * super-imposed on the existing leadAttr info
   * in the DataVLA
   */
  nCurAttr   = 1; 
  nDataVLA   = (nLeads*nCurAttr);
  priv_coll  = _MALLOC(nDataVLA, struct ACrg_coll);

  for(i=0, j=0; j<nDataVLA; j+=nCurAttr, i++)
  {
    sprintf(buff,"Marker_%.4d",conNum[i]);
    priv_coll[j].desc.type = AC_ATTRIB_TEXT;
    strcpy(priv_coll[j].name, buff);
    strcpy(priv_coll[j].desc.value.att_txt, "");
#if 0
    for(k=j+1; k<nCurAttr; k++)
    {
      sprintf(buff,"Future%d_%.4d",k,conNum[i]);
      priv_coll[k].desc.type = AC_ATTRIB_TEXT;
      strcpy(priv_coll[k].name, buff);
      strcpy(priv_coll[k].desc.value.att_txt, "");
    }
#endif
  }

  /*
   * attribute match and all the below processing is to be
   * done only for non-legacy data
   */
  if(dType != VC_LEGACY_JUN02)
  { 
    for(i=0; i<nDataVLA; i++)
    {
      for(j=0; j<nAttr; j++)
      {
        if(!strcmp(priv_coll[i].name, coll[j].name))
        {
          strcpy(priv_coll[i].desc.value.att_txt,
                 coll[j].desc.value.att_txt);
          break;
        }
      }   
    }
  }
  sts =
  om$send (msg = message VCRoot.VCSetDataVLA
                     ((void *)priv_coll, nDataVLA, VC_ACRG_COLLECT ),
                 senderid = NULL_OBJID,
                 targetid = cableID->objid,
                 targetos = cableID->osnum);
  if(!(sts&1))
  {
    __DBGpr_obj(" VCCable.VCSetDataVLA failed for ", 
                  *cableID);
    goto wrapup;
  }
  //Done
  retFlag = 1;

wrapup:

  _FREE(Layout);
  _FREE(conNum);
  _FREE(ldNames);
  _FREE(coll);
  _FREE(priv_coll);

  return retFlag;
}
/*
 * This function will set the attribute information for the lead
 * as supplied by the user
 */
IGRlong VCSetMarkerInfoForLead(
				struct GRid     *cableID, // I
				struct VCLdInfo *ldInfo,  // I
				IGRint          nbLeads   // I
		              )		 
{
  IGRlong          retFlag = 0, sts, msg;
  IGRint           i, j, k, nAttr, nCurAttr;
  IGRshort         dType, *conNum;
  struct ACrg_coll *attrs;
  GRname           *ldNames, buff;
  GRname           *marker;
  struct VClayout  *Layout;
  IGRshort         nEnt, nTab, nCabLeads;
  IGRint           nDataVLA;

  if(nbLeads == 0) goto wrapup;
  if(!ldInfo)     goto wrapup;
  if(!cableID)    goto wrapup;

  retFlag      = 0;
  nAttr        = 0;
  nCurAttr     = 0;
  dType        = 0;
  nCabLeads    = 0;
  nEnt         = 0;
  nTab         = 0;
  nDataVLA     = 0;
  attrs        = NULL;
  ldNames      = NULL;
  conNum       = NULL;
  Layout       = NULL;
  marker       = NULL;

  // synchronize the lead->Attribute data for the cable
  sts = VCsyncLdAttrInfo(cableID);
  if(!(sts&1))
  {
    __DBGpr_obj("VCsyncLdAttrInfo failed for", *cableID);
    goto wrapup;
  }
  // Get all the leads for the cable
  nEnt   = nTab = 0;
  sts =
  om$send (msg = message VCDB.VCGetLayout
                              (&msg, NULL, &nCabLeads, &nTab, NULL),
      senderid = NULL_OBJID,
      targetid = cableID->objid,
      targetos = cableID->osnum);
  if(!(sts&msg&1))
  {
    __DBGpr_obj(" VCDB.VCGetLayout failed for ", *cableID);
    goto wrapup;
  }
  Layout  = _MALLOC(nCabLeads, struct VClayout);

  sts =
  om$send (msg = message VCDB.VCGetLayout
                              (&msg, NULL, &nCabLeads, &nTab, Layout),
      senderid = NULL_OBJID,
      targetid = cableID->objid,
      targetos = cableID->osnum);
  if(!(sts&msg&1))
  {
    __DBGpr_obj(" VCDB.VCGetLayout failed for ", *cableID);
    goto wrapup;
  }

  ldNames = _MALLOC(nCabLeads, GRname);

  for(j=0; j<nCabLeads; j++)
    strcpy(ldNames[j], Layout[j].pDef.Conn.Cable.szLeadId); 

  conNum  = _MALLOC(nCabLeads, IGRshort);

  for(j=0; j<nCabLeads; j++) conNum[j] = -1;

  for(j=0; j<nCabLeads; j++)
  {
    VC_ConNum_LeadName(&msg, cableID, ldNames[j], &conNum[j]);
    if((!(msg&1)) || (conNum[j] == -1))
    {
      __DBGpr_obj(" VC_ConNum_LeadName failed for", *cableID);
      __DBGpr_str(" VC_ConNum_LeadName failed for lead", ldNames[j]); 
      goto wrapup;
    }
  }

  nCurAttr = 1;
  nDataVLA = (nCabLeads * nCurAttr);
  marker = _MALLOC(nCabLeads, GRname);
 
  for(j=0; j<nCabLeads; j++)
  {
    sprintf(buff,"Marker_%.4d",conNum[j]);
    strcpy(marker[j], buff);
  }
  nAttr = dType = 0;
  sts =
  om$send (msg = message VCRoot.VCGetDataVLA
                         (NULL, &nAttr, &dType),
      senderid = NULL_OBJID,
      targetid = cableID->objid,
      targetos = cableID->osnum);
  if(!(sts&1))
  {
    __DBGpr_obj(" VCCable.VCGetDataVLA failed for ", *cableID);
    goto wrapup;
  }

  switch(dType)
  {
    case VC_LEGACY_JUN02 : //Legacy data
			   goto wrapup;

    case VC_ACRG_COLLECT : // struct ACrg_collect
                           attrs      = _MALLOC(nAttr, struct ACrg_coll);
                           sts =
                           om$send (msg = message VCRoot.VCGetDataVLA
                                          ((void *)attrs, &nAttr, &dType),
                               senderid = NULL_OBJID,
                               targetid = cableID->objid,
                               targetos = cableID->osnum);
                           if(!(sts&1))
                           {
                             __DBGpr_obj(" VCCable.VCGetDataVLA failed for ", 
                                           *cableID);
                             goto wrapup;
                           }
                           break;

    default              : break;    
  }

  /*
   * loop on the leadInfo struct sent by the client 
   *        ldInfo[i].LeadNam  (0<i<nbLeads)
   * get the matching leadname in the cable instance data 
   *        ldName[j]          (0<j<nCabLeads)
   * get the marker attribute name from the prepared list 
   *        marker[j]          (0<j<nCabLeads)
   * loop on the cable attribute list to find match for marker[j]
   *        attrs[k]           (0<k<nAttr)
   * change the value for the cable attribute like -
   *        strcpy( attrs[k].desc.value.att_txt, ldInfo[i].Marker )
   * After done with all the leads supplied by the client, set the DataVLA
   * on the cable object
   */
  for(i=0; i<nbLeads; i++)
  {
    for(j=0; j<nCabLeads; j++)
    {
      if(!strcmp(ldInfo[i].LeadNam, ldNames[j]))
      {
        for(k=0; k<nAttr; k++)
        { 
	  if(!strcmp(marker[j], attrs[k].name))
	  {
	    attrs[k].desc.type = AC_ATTRIB_TEXT;
            strcpy(attrs[k].desc.value.att_txt, ldInfo[i].Marker);
	    goto foundMatch;
          }
        }
        
      }
    }
      foundMatch: continue;  // continue to the next lead
  }
  sts =
  om$send (msg = message VCRoot.VCSetDataVLA
                     ((void *)attrs, nAttr, VC_ACRG_COLLECT ),
                 senderid = NULL_OBJID,
                 targetid = cableID->objid,
                 targetos = cableID->osnum);
  if(!(sts&1))
  {
    __DBGpr_obj(" VCCable.VCSetDataVLA failed for ", 
                  *cableID);
    goto wrapup;
  }

  //Done
  retFlag = 1;
wrapup:
  _FREE(attrs);
  _FREE(ldNames);
  _FREE(conNum);
  _FREE(Layout);
  _FREE(marker);

  return retFlag;
}

// FWIW, Throwing this in as a separate function. - Anand
IGRint VCGetSignalForLead( IGRlong	*msg,
			   struct GRid	*CabId,
			   IGRchar	szLeadName[VC_MAX_LEAD_ID],
			   IGRchar	szSignal[VC_MAX_SIG_ID] )
{
    IGRint	status = OM_S_SUCCESS;
    struct GRid		TrunkCabId;
    struct VCpos	ConId;

    SetProc( VCGetSignalForLead ); Begin;

    *msg = MSSUCC;

    __DBGpr_obj("Getting trunk cable for",*CabId);
    status = VC$GetTrunkCab( msg		= msg,
			     p_gridCabId	= CabId,
			     p_gridTrunkCabId	= &TrunkCabId );
    __DBGpr_obj("Trunk cable",TrunkCabId);

    strcpy( ConId.Conn.Cable.szLeadId, szLeadName );
    __DBGpr_str("Getting signal for lead",ConId.Conn.Cable.szLeadId);
    status = om$send( msg	= message VCCon.VCGetSignal( msg, &ConId,
							      szSignal ),
		      senderid	= NULL_OBJID,
		      targetid	= TrunkCabId.objid,
		      targetos	= TrunkCabId.osnum );
    __DBGpr_str("Signal on lead",szSignal);

    End;
    return status;
}

/*
 * This function will get the (leadname,attribute) attrinfo for cableID 
 *
 * It is the responsibility of the user to allocate/free for the
 * ldInfo pointer
 *
 */
IGRlong VCGetAttrInfoForLead( struct GRid     *cableID,   // I
			      struct VCLdInfo *ldInfo,    // I/O 
			      IGRint          nbLeads,    // I
			      IGRshort        AttrType,   // I
			      IGRboolean      *legacy     // O 
			    )		 
{
  IGRlong          retFlag = 0, msg, sts;
  GRname           *ldNames;
  IGRint           i, j, k, nAttr, nCurAttr;
  IGRshort         dType, *conNum;
  struct ACrg_coll *attrs;
  GRname           *marker;
  struct VClayout  *Layout;
  IGRshort         nEnt, nTab, nCabLeads;
  IGRint           nDataVLA;

  if(!cableID)                 goto wrapup;
  if(!ldInfo)                  goto wrapup;
  if(nbLeads == 0)             goto wrapup;
 
  *legacy      = FALSE;
  retFlag      = 0;
  nAttr        = 0;
  nCurAttr     = 0;
  dType        = 0;
  nCabLeads    = 0;
  nEnt         = 0;
  nTab         = 0;
  nDataVLA     = 0;
  conNum       = NULL;
  marker       = NULL;
  ldNames      = NULL;
  attrs        = NULL;

  // make sure that you have data in the cable
  nAttr = dType = 0;
  sts =
  om$send (msg = message VCRoot.VCGetDataVLA
                         (NULL, &nAttr, &dType),
      senderid = NULL_OBJID,
      targetid = cableID->objid,
      targetos = cableID->osnum);
  if(!(sts&1))
  {
    __DBGpr_obj(" VCCable.VCGetDataVLA failed for ", *cableID);
    goto wrapup;
  }

  switch(dType)
  {
    case VC_LEGACY_JUN02 : //Legacy data
			   *legacy = TRUE;
    			   retFlag = 1;
    			   goto wrapup;  

    case VC_ACRG_COLLECT : // struct ACrg_collect
                           attrs      = _MALLOC(nAttr, struct ACrg_coll);
                           sts =
                           om$send (msg = message VCRoot.VCGetDataVLA
                                          ((void *)attrs, &nAttr, &dType),
                               senderid = NULL_OBJID,
                               targetid = cableID->objid,
                               targetos = cableID->osnum);
                           if(!(sts&1))
                           {
                             __DBGpr_obj(" VCCable.VCGetDataVLA failed for ", 
                                           *cableID);
                             goto wrapup;
                           }
                           break;

    default              : break;    
  }

  conNum  = _MALLOC(nbLeads, IGRshort);
  for(j=0; j<nbLeads; j++) conNum[j] = -1;

  for(j=0; j<nbLeads; j++)
  {
    VC_ConNum_LeadName(&msg, cableID, ldInfo[j].LeadNam, &conNum[j]);
    if((!(msg&1)) || (conNum[j] == -1))
    {
      __DBGpr_obj(" VC_ConNum_LeadName failed for", *cableID);
      __DBGpr_str(" VC_ConNum_LeadName failed for lead", ldInfo[j].LeadNam); 
      goto wrapup;
    }
  }

  if( AttrType & VC_MARKER_TYPE )
  {
    /*
     * prepare the marker attribute name list
     * to match against the object attribute name
     * to copy the attribute value
     */
    marker = _MALLOC(nbLeads, GRname);

    for(j=0; j<nbLeads; j++)
      sprintf(marker[j],"Marker_%.4d",conNum[j]);

    for(i=0; i<nbLeads; i++)
    {
      for(j=0; j<nAttr; j++)
      {
	if(!strcmp(marker[i], attrs[j].name))
	{
	  strcpy(ldInfo[i].Marker,  attrs[j].desc.value.att_txt);
	  break;
	}
      }
      if(j == nAttr)
      {
	__DBGpr_obj("ERROR CONDITION for CABLE ", *cableID);
	__DBGpr_str("MARKER ", marker[i]);
	__DBGpr_str("NOT FOUND FOR LEAD ", ldInfo[i].LeadNam);
	goto wrapup;
      }
    }
  }

  //Done
  retFlag = 1;
wrapup:
  _FREE(marker);
  _FREE(conNum);
  _FREE(ldNames);
  _FREE(attrs);

  return retFlag;
}
/*
 * This function sets the lead->attribute (marker/signal/other) info 
 * for  all the cables in the network thru which this lead passes
 */
IGRlong VCSetLeadAttrInfo(
			   struct GRid          *cableID,
			   struct VCLdInfo      *ldInfo,
			   IGRint               nLeads,
			   IGRshort             AttrType
                         )
{
  IGRlong         retFlag = 0, sts, msg;
  IGRint          i, j, nCables, nConNum;
  struct GRid     *cables;
  struct VCLdInfo leadInfo;
  struct VCpos    pos;

  if(!ldInfo) goto wrapup;

  nCables        = 0;
  cables         = NULL;
  nConNum        = 0;   //current not being used

  for(i=0; i<nLeads; i++)
  {
    // get a list of cables in network through which this lead passes
    sts = VC$GetNetworkForLead( 
			      msg            = &msg,
			      szLeadName     = ldInfo[i].LeadNam,
			      p_gridCabId    = cableID,
			      p_nNbCab       = &nCables
                              );
    if(!(sts&msg&1) || (nCables == 0))
    {
      __DBGpr_obj(" VC$GetNetworkForLead failed for", *cableID);
      __DBGpr_str(" Lead Name ", ldInfo[i].LeadNam);
      __DBGpr_int(" nCables   ", nCables);
      goto wrapup;
    }
    cables = _MALLOC(nCables, struct GRid);
    sts = VC$GetNetworkForLead( 
			      msg            = &msg,
			      szLeadName     = ldInfo[i].LeadNam,
			      p_gridCabId    = cableID,
			      p_nNbCab       = &nCables,
			      p_gridCabList  = cables
                            );
    if(!(sts&msg&1))
    {
      __DBGpr_obj(" VC$GetNetworkForLead failed for", *cableID);
      __DBGpr_str(" Lead Name ", ldInfo[i].LeadNam);
      goto wrapup;
    }

    for(j=0; j<nCables; j++)
    {
      if(AttrType & VC_MARKER_TYPE)
      {
        strcpy(leadInfo.LeadNam, ldInfo[i].LeadNam);
        strcpy(leadInfo.Marker, ldInfo[i].Marker);

        nLeads = 1;
        sts = VCSetMarkerInfoForLead(&cables[j], &leadInfo, nLeads);  
        if(!(sts&1))
	{
          __DBGpr_obj(" VCSetMarkerInfoForLead failed for", cables[j]);
	  goto wrapup;
	}
      }
      if(AttrType & VC_SIGNAL_TYPE)
      {
        strcpy(pos.Conn.Cable.szLeadId,ldInfo[i].LeadNam); 
        sts =
        om$send ( msg = message VCCable.VCPutSignal
                        ( &msg, &pos, ldInfo[i].SigNam),
                  senderid = NULL_OBJID,
                  targetid = cables[j].objid,
                  targetos = cables[j].osnum );
        if(!(sts&msg&1))
	{
          __DBGpr_obj(" VCCable.VCPutSignal failed for", *cableID);
	  goto wrapup;
	}

      }
    }
  }
  // Done
  retFlag = 1;
wrapup:
  _FREE(cables);
  return retFlag;
}
end implementation VCCable;
