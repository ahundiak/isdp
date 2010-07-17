/* $Id: VRPartFlow.I,v 1.1 2001/11/08 20:29:23 anand Exp $  */

/* -------------------------------------------------------------------------
 * I/Route
 *
 * File:        vrxml/VRPartFlow.I
 *
 * Motivation:	JTS CR MP 5542
 *
 * Description:
 * 	This file has routines for parsing the XML file flow_check.xml
 *
 * Function to be called by client:
 *		VRgetPartNumFlowData
 *		VRCleanupFlowXMLcache
 *
 * History:
 *      11/02/01       Anand              Creation
 *
 * -------------------------------------------------------------------------
 */
class implementation Root;

#include <string.h>
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"
#include "vrdbgmacros.h"

typedef struct
{
  TGRid			partnumIDs;
  TGRid			findID;
  TVDctxNodeList	namePartnumList;
}Tinfo;

/*
 * Global pointer to cache the XML file.
 */
static	Tinfo	*VRinfo;
	

VDASSERT_FFN("VRPartFlow.I");

/* -----------------------------------------------
 * Get the Partnums from xml file
 */
void VRvalFilePartnum(TGRid *partnumIDs)
{
  VDASSERT_FN("VRvalFilePartnum");
  
  IGRchab path;

  SetProc( VRvalFilePartnum ); Begin

  __DBGpr_com("Arg check");
  VDASSERTW(partnumIDs); 
  partnumIDs->objid = NULL_OBJID;

  __DBGpr_com(" Find the file ");
  *path = '\0';
  VDsysFindFile("config/xml","flow_check.xml",path);
  if (*path == 0)
      goto wrapup;

  __DBGpr_str("XML path", path);
  VDxdomCreateTreeFromXmlFile(path, partnumIDs);

wrapup:
  return;
}

/* -----------------------------------------------
 * Index on name
 */
static IGRint ComparePartNum(const void *p1, const void *p2)
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;

  IGRchab name1,name2;

  VDctxGetTxtAtr(node1ID, "pdm_part_num", name1); strlwr(name1);
  VDctxGetTxtAtr(node2ID, "pdm_part_num", name2); strlwr(name2);

  return strcmp(name1,name2);
}

/* -----------------------------------------------
 * Sort part_check parts.
 *-------------------------------- */
static void SortPartnumEntries()
{
  VDASSERT_FN("SortPartnumEntries");
 
  __DBGpr_com("SortPartnumEntries: Build the list ");
  VDctxGetNodeListByType( &VRinfo->partnumIDs, "part_check",
			  &VRinfo->namePartnumList);

  __DBGpr_int("Partnum Count", VRinfo->namePartnumList.cnt);

  __DBGpr_com("SortPartnumEntries: Sort the list ");
  VDctxSortNodeList(&VRinfo->namePartnumList, ComparePartNum);

  __DBGpr_com("SortPartnumEntries: Add find index to list");
  VDxdomCreateTree("find",&VRinfo->findID);

wrapup:
  return;
}

/* -----------------------------------------------
 * get the Partnum tree, create an internal one when not defined.
 */
void VRvalGetPartnums(TGRid *partnumIDs)
{
  VDASSERT_FN("VRvalGetPartnums");

  IGRint flag = 0;

  // Arg check
  VDASSERTW(partnumIDs); partnumIDs->objid = NULL_OBJID;

  // See if loaded
  if (VRinfo)
  {
    // Is it already loaded?
    __DBGpr_com(" File is already loaded ");
    *partnumIDs = VRinfo->partnumIDs;
    if ((partnumIDs->objid != 0) && (partnumIDs->objid != NULL_OBJID))
	goto wrapup;
  }

  if( VRinfo == NULL ){
    __DBGpr_com("File is new; Create!!!");
    VRinfo = calloc(1,sizeof(Tinfo));
    VDASSERTW(VRinfo);
    flag = 1;
  }

  /*
   * The file may not exist. We need to set and error.
   */
  VRinfo->partnumIDs.objid = NULL_OBJID;
  VRvalFilePartnum(partnumIDs);
  if( partnumIDs->objid != NULL_OBJID )
  {
      VRinfo->partnumIDs = *partnumIDs ;
      if(flag)
      {
	  SortPartnumEntries();
	  goto wrapup;
      }
      VDlogPrintFmt(VDLOG_ERROR,1,"*** Unable to load Partnum cache");
  }

wrapup:
	return;
}

/*
 * Main routine to call for the Partnum attributes.
 */

IGRboolean VRgetPartNumFlowData( IGRchar	*partNum,
				 IGRint	maxCpts,
				 IGRint	*numCpts,
				 IGRint	*cptsFlows )
{
    IGRchar	nameXML[32],valueXML[1024];
    IGRint	i,sts;
    TGRid 	partNumIDs;
    TGRid	*foundID = NULL ;
    
    SetProc( VRgetPartNumFlowData ); Begin

    if( ! partNum || ! numCpts || ! cptsFlows )
    {
	__DBGpr_com("Invalid Input");
	goto wrapup ;
    }

    __DBGpr_str("partNum for querying xml file", partNum );
    /*
     * Set Default Output values.
     */
    *numCpts = 0 ;

    /*
     * Load in text file with the Partnums.
     */
    partNumIDs.objid = NULL_OBJID;
    VRvalGetPartnums(&partNumIDs);
    if (partNumIDs.objid == NULL_OBJID)
	goto wrapup;

    /*
     * Go through the index list to find Partnum.
     */
    VDctxAppTxtAtr(&VRinfo->findID,"pdm_part_num",partNum);
    foundID = VDctxSearchNodeList( &VRinfo->findID,
				   &VRinfo->namePartnumList,
				   ComparePartNum );
    if (foundID == NULL)
    {
	// VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not find part Number info for %s",name);
	__DBGpr_str("Could not find pdm_part_num in flow_check.xml",partNum);
	goto wrapup;
    }

//    sts = VDctxGetTxtAtr( foundID, "cpts",  valueXML );
//    *numCpts = atoi(valueXML);
//    if( *numCpts > maxCpts ) goto wrapup;	

    for ( i=0,*numCpts=0 ; i<maxCpts ; i++ )
    {
	sprintf(nameXML,"cpt%d",i );
	__DBGpr_str(" CPT index ", nameXML );
	sts = VDctxGetTxtAtr( foundID, nameXML, valueXML);
	if( !(sts&1) )
	{
	    __DBGpr_str("No value in flow_check.xml for attribute",nameXML);
	    continue;
	}
    
	__DBGpr_str(" XML value ", valueXML );
	if( ! strncasecmp("I", valueXML, 1) )
	{
	    cptsFlows[i] = -1;
	    ++(*numCpts);
	    continue;
	}
	if( ! strncasecmp("O", valueXML, 1) )
	{
	    cptsFlows[i] =  1;
	    ++(*numCpts);
	    continue;
	}
	if( ! strncasecmp("B", valueXML, 1) )
	    cptsFlows[i] =  0;
    }

    __DBGpr_int("Num of cpts that are populated", *numCpts );
    for ( i=0 ; i<maxCpts ; i++ )
	__DBGpr_int("Flow at cpt", cptsFlows[i] );

found:
    End;
    return TRUE;

wrapup:
    End;
    return FALSE ;
}

void VRCleanupFlowXMLcache(void)
{
    SetProc(VRCleanupFlowXMLcache); Begin
    __DBGpr_com(" Calling VDctxFreeNodeList on VRinfo->namePartnumList");
    VDctxFreeNodeList( &(VRinfo->namePartnumList) );
    __DBGpr_com("Calling VDctxDeleteNode on VRinfo->partnumIDs");
    VDctxDeleteNode( &(VRinfo->partnumIDs) );
    __DBGpr_com("Calling VDctxDeleteNode on VRinfo->findID");
    VDctxDeleteNode( &(VRinfo->findID) );
    __DBGpr_com("Freeing VRinfo");
    free( VRinfo );
    VRinfo=NULL;
    End
}

end implementation Root;

