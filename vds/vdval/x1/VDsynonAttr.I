/* $Id: VDsynonAttr.I,v 1.1 2001/10/23 16:37:22 ahundiak Exp $  */

/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdmisc/VDsynonAttr.I
 *
 * Description:
 *
 *      Function :
 *            VDgetSynonymAttribute
 *
 * History:
 *      02/16/95       Ad Z              Creation
 *
 * -------------------------------------------------------------------------
 */
class implementation Root;

#include "string.h"
#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "exmacros.h"
#include "vdparmacros.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"

typedef struct
{
  TGRid			synonymIDs;
  TGRid			findID;
  TVDctxNodeList	nameSynonymList;
}Tinfo;

/*
 * Global pointer to cache the XML file.
 */
static	Tinfo	*info;
	

VDASSERT_FFN("VDsynonAttr.I");

/* -----------------------------------------------
 * Get the synonyms from xml file
 */
void VDvalFileSynonyms(TGRid *synonymIDs)
{
  VDASSERT_FN("VDvalFileSynonyms");
  
  IGRchab path;

  SetProc( VDvalFileSynonyms ); Begin

  __DBGpr_com(" Arg check ");
  VDASSERTW(synonymIDs); 
  synonymIDs->objid = NULL_OBJID;

  __DBGpr_com(" Find the file ");
  *path = '\0';
  VDsysFindFile("config/xml","synonyms.xml",path);
  if (*path == 0) goto wrapup;

  __DBGpr_str(" XML path ", path );
  VDxdomCreateTreeFromXmlFile( path, synonymIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Index on name
 */
static IGRint compareName(const void *p1, const void *p2)
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;

  IGRchab name1,name2;

  VDctxGetTxtAtr(node1ID, "name", name1); strlwr(name1);
  VDctxGetTxtAtr(node2ID, "name", name2); strlwr(name2);

  return strcmp(name1,name2);
}

/* -----------------------------------------------
 * Sort synonym parts.
 *-------------------------------- */
static void indexSynonymPart()
{
  VDASSERT_FN("indexSynonymPart");
 

  __DBGpr_com("indexSynonymPart: Build the list ");
  VDctxGetNodeListByType( &info->synonymIDs, "synonym", &info->nameSynonymList);

  __DBGpr_int(" Synonym Count", info->nameSynonymList.cnt );

  __DBGpr_com("indexSynonymPart: Sort the list ");
  VDctxSortNodeList(&info->nameSynonymList, compareName );

  __DBGpr_com("indexSynonymPart: Add find index to list ");
  VDxdomCreateTree("find",&info->findID);

 wrapup:
  return;
}

/* -----------------------------------------------
 * get the synonym tree, create an internal one when not defined.
 */
void VDvalGetSynonyms(TGRid *synonymIDs)
{
  VDASSERT_FN("VDvalGetSynonyms");

  IGRint flag = 0;

  // Arg check
  VDASSERTW(synonymIDs); synonymIDs->objid = NULL_OBJID;

  // See if loaded
  if (info) {
    // Is it already loaded
    __DBGpr_com(" File is already loaded ");
    *synonymIDs = info->synonymIDs;
    if ((synonymIDs->objid != 0) && (synonymIDs->objid != NULL_OBJID)) goto wrapup;
  }

  if( info == NULL ){
    __DBGpr_com(" File is new; Create !!!");
    info = calloc(1,sizeof(Tinfo));
    VDASSERTW(info);
    flag = 1;
  }

  /*
   * The file may not exist. We need to set and error.
   */
  info->synonymIDs.objid = NULL_OBJID;
  VDvalFileSynonyms(synonymIDs);
  if( synonymIDs->objid != NULL_OBJID ) {
	info->synonymIDs = *synonymIDs ;
        if (flag){
		indexSynonymPart();
		goto wrapup;
	}
//  	VDlogPrintFmt(VDLOG_ERROR,1,"*** Unable to load synonym cache");
  }

wrapup:
	return;
}

/*
 * Main routine to call for the synonym attributes.
 */

IGRint	VDgetAttributeSynonym( 	struct GRid	*objId,
				IGRchar		*attrIn,
				IGRchar		*attrOut )
{
	IGRchar	attr[1024],
		nameXML[1024],valueXML[1024],
		*p = NULL ;
	TGRid 	toleranceIDs, toleranceID;
	TGRid	*foundID = NULL ;
	
	IGRint i;
	
	SetProc( VDgetAttributeSynonym ); Begin

	if( ! attrIn || ! attrOut ){
		__DBGpr_com(" Invalid Input ");
		goto wrapup ;
	}

	/*
	 * Check if the attribute is a concatenation.
	 * Ex: "SA_OBJ:collect:attr 1"
	 */

	__DBGpr_str(" attrIn ", attrIn );
	strcpy( attrOut, attrIn );

        attr[0] = '\0';
	p = NULL ;
	p = strrchr( attrOut, ':' );
	if( p ){ strcpy( attr, p+1 );     p = p+1 ; }
	else{    strcpy( attr, attrOut ); p = attrOut ; }

	if( *attr == 0 ) goto wrapup ;

	__DBGpr_str(" attr to Check", attr );

	/*
	 * Load in text file with the synonyms.
	 */
	toleranceIDs.objid = NULL_OBJID;
  	VDvalGetSynonyms(&toleranceIDs);
	if (toleranceIDs.objid == NULL_OBJID) {
    		goto wrapup;
	}

	/*
	 * Go through the index list to find synonym.
	 */
	VDctxAppTxtAtr(&info->findID,"name", attr );
	__DBGpr_str(" Search in Node List ", attr );
	foundID = VDctxSearchNodeList(&info->findID,&info->nameSynonymList,compareName);
	if (foundID == NULL) {
		// VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not find tolerance for %s",name);
    		goto wrapup;
	}

	VDctxGetTxtAtr( foundID,  "name",  nameXML);
	VDctxGetTxtAtr( foundID, "value", valueXML);
	__DBGpr_str(" XML name  ", nameXML );
	__DBGpr_str(" XML value ", valueXML );

	if( ! strcmp( attr, nameXML )){
		strcpy( p, valueXML );
		__DBGpr_com(" FOUND matching attribute ");
		goto found ;
	}

	goto wrapup;
found:
	__DBGpr_str(" attr ", attrOut );
	End;
	return TRUE;

wrapup:
	End;
	return FALSE ;
}

end implementation Root;

