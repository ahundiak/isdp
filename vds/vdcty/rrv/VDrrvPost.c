/* $Id: VDrrvPost.c,v 1.4 2001/10/19 18:20:55 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvPost.c
 *
 * Description: Post Snapshot XML file from Create form
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/01  js      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDdoom.h"
#include "VDxml.h"
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDDbDef.h"
#include "VDss.h"

#include "VDrrvCmd.h"


VDASSERT_FFN("vdcty/rrv/VDrrvPost.c");

/* ---------------------------------------------
 * Post the xml file into isdp_blobs and into vdat_blobs
 * **/
static IGRstat postXmlFile(IGRint         *f_key,
	                   IGRint         *b_key,
			   TVDctxBaseInfo *info,
			   IGRchar        *ts,
			   IGRchar        *purpose,
			   IGRchar        *xmlFile)
{
  VDASSERT_FN("postXmlFile");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar sql[1024];
  IGRchar *envVar;
  IGRstat flag;

  VDpdmHullApp ships;
  IGRint       i;

  VDASSERTW(info);
  VDASSERTW(*info->setType    != 0);
  VDASSERTW(*info->setName    != 0);
  VDASSERTW(*ts               != 0);
  VDASSERTW(*purpose          != 0);
  VDASSERTW(*xmlFile          != 0);

   // insert the blob record
  sts = VDrisInsertBlobRecord(*b_key,xmlFile,1,UI_status);
  if (!(sts & 1)) goto wrapup;
 
  // Insert one record for each hull that the file is approved for.
  sts = VDpdmGetApprCfgforFilekey(f_key, &ships);
  if (!(sts & 1)) {
      // no approved cfg, so index against LPD.
      sprintf(sql,
	      "Insert into %s values (%d,'%s','%s','%s','%s',%d,%d,'%s',%d);",
	      VDRIS_TBLN_BLOBI, *f_key,
	      purpose, "LPD", info->setType, info->setName,
	      atoi(info->setTypeRev), 1, ts, *b_key );
      sts = VDrisExecute( sql );
      retFlag = 1;
      goto wrapup;
  }

 
  // fill the index table, one record for each hull.
  for (i = 0; i < ships.cnt; i++) {
      sprintf(sql,
	      "Insert into %s values (%d,'%s','%s','%s','%s',%d,%d,'%s',%d);",
	      VDRIS_TBLN_BLOBI, *f_key,
	      purpose, ships.hulls[i], info->setType, info->setName,
	      atoi(info->setTypeRev), 1, ts, *b_key );

      VDrisExecute( sql );
  }

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}
  
/* ---------------------------------------------
 * Check to see if xmlFile has already been posted
 * **/
static IGRstat isXmlFilePosted(TVDctxBaseInfo *info,
                               IGRchar        *ts,
			       IGRchar        *purpose)
{
  VDASSERT_FN("isXmlFilePosted");

  IGRstat    retFlag = 1;
  TVDrisInfo ris;
  IGRchar    sql[1024];

  // init
  VDrisInitInfo( &ris );

  // Arg check
  VDASSERTW(info);
  VDASSERTW(*ts);
  VDASSERTW(*purpose);

  // build the sql
  sprintf(sql,
	  "Select * from %s where "
	  "%s='%s' and %s='%s' and %s='%s' and %s=%d and %s='%s';",
          VDRIS_TBLN_BLOBI,
	  VDRIS_COLN_BLOBI_PURPOSE,  purpose,
	  VDRIS_COLN_BLOBI_SET_TYPE, info->setType,
	  VDRIS_COLN_BLOBI_SET_NAME, info->setName,
	  VDRIS_COLN_BLOBI_SET_VER,  atoi(info->setTypeRev),
	  VDRIS_COLN_BLOBI_POST_DATE,ts );

  // verify the table
  if ( VdsVerifyRisTable(VDRIS_TBLN_BLOBI) != VDS_DBTABLE_FOUND )
    goto wrapup;
  
  // query it
  VDrisQuery( &ris, sql );
  if (ris.rows < 1) retFlag = 0;

  // done

wrapup:
  VDrisFreeInfo( &ris );
  return retFlag;
}

/* ----------------------------------------------
 * Post the already created xml file to the database
 * **/
IGRstat VDrrvPostXmlSnapshotFile(IGRchar *xmlFile,
                                 IGRchar *msg)
{
  VDASSERT_FN("VDrrvPostXmlSnapshotFile");
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid           rootID;
  TVDctxBaseInfo  baseInfo;
  TVDpdmInfo      pdmInfo;
  IGRchab         attrInfo;

  IGRchab         ts,
                  purpose;
  IGRint          b_key, f_key;

  // arg check
  VDASSERTW( (xmlFile != NULL) && (*xmlFile != 0) );
  VDASSERTW(msg); *msg = 0;
  
  rootID.objid = NULL_OBJID;
  strcpy(msg,"XML File not Posted");
  *ts       = 0;
  *purpose  = 0;
  *attrInfo = 0;

  // logged in
  sts = VDpdmVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // get rootID
  VDdoomXmlParseFileForRoot(xmlFile, &rootID);
  if (rootID.objid == NULL_OBJID) goto wrapup;

  // get baseInfo
  VDctxGetBaseInfo(&rootID,&baseInfo);
  if (*baseInfo.setType    == 0) goto wrapup;
  if (*baseInfo.setName    == 0) goto wrapup;
  
  // timestamp
  VDctxGetTxtAtr(&rootID,VDCTX_ATR_CREATION_TIMESTAMP,ts);
  if (*ts == 0) goto wrapup;

  // purpose
  VDctxGetTxtAtr(&rootID,VDCTX_ATR_PURPOSE,purpose);
  if (*purpose == 0) goto wrapup;
   
  // has this already been posted
  if( isXmlFilePosted(&baseInfo,ts,purpose) ) {
      strcpy(msg,"XML file has already been posted");
      retFlag = 1;
      goto wrapup;
  }

  // need a blob key
  b_key = 0;
  VDrisGetNextKey(VDRIS_TBLN_BLOBS, &b_key);
  if (b_key == 0) goto wrapup;

  // need a file key
  f_key = 0;
  VDctxGetTxtAtr(&rootID,VDCTX_ATR_SS_PDM_INFO,attrInfo);
  
  VDrrvPdmAttrToInfo(attrInfo,&pdmInfo);
  if (pdmInfo.filekey != 0) f_key = pdmInfo.filekey;

  // finally, do it
  sts = postXmlFile(&f_key,&b_key,&baseInfo,ts,purpose,xmlFile);
  if (!(sts & 1)) goto wrapup;

  // set a successful message
  strcpy(msg,"XML File posted");
  retFlag = 1;

wrapup:
   return retFlag;
}

