/* $Id: VDrisBlob.c,v 1.1 2001/02/17 14:18:23 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdris/c/VDrisBlob.c
 *
 * Description: Blob utility routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDrisBlob.c,v $
 * Revision 1.1  2001/02/17 14:18:23  ahundiak
 * *** empty log message ***
 *
 * Revision 1.1  2001/02/01 21:58:19  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/11/01  ah      Header
 *
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDrisc.h"

VDASSERT_FFN("VDrisBlob.c");

/* ----------------------------------------
 * Main query for blob index table
 */
IGRstat VDrisQryBlobIndex(TVDrisInfo *info)
{
  VDASSERT_FN("VDrisQryBlobIndex");
  IGRstat retFlag = 0;
  
  IGRchar qry[512];
  
  // Arg check
  VDASSERTW(info);
  
  // Build Query
  sprintf(qry,
	  "Select %s,%s,%s,%s,%s,%s,%s,%s,%s from %s "
	  "Order by  %s,%s,%s,%s,%s ",

	  VDRIS_COLN_BLOBI_FILE_KEY,
	  VDRIS_COLN_BLOBI_PURPOSE,
	  VDRIS_COLN_BLOBI_HULL,
	  VDRIS_COLN_BLOBI_SET_TYPE,
	  VDRIS_COLN_BLOBI_SET_NAME,
	  VDRIS_COLN_BLOBI_SET_VER,
	  VDRIS_COLN_BLOBI_SET_CUR,
	  VDRIS_COLN_BLOBI_POST_DATE,
	  VDRIS_COLN_BLOBI_BLOB_KEY,

	  VDRIS_TBLN_BLOBI,

	  VDRIS_COLN_BLOBI_PURPOSE,
	  VDRIS_COLN_BLOBI_HULL,
	  VDRIS_COLN_BLOBI_SET_TYPE,
	  VDRIS_COLN_BLOBI_SET_NAME,
	  VDRIS_COLN_BLOBI_SET_VER);
  
  // Doit
  VDrisQuery(info,qry);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Given a pointer to a buffer retrieved
 * from ris, xfer into to the blob record
 */
IGRstat VDrisBlobIndexBufToRecord(IGRchar *buf[], TVDblobiRecord *record)
{
  VDASSERT_FN("VDblobBufToRecord");
  IGRstat retFlag = 0;
  
  IGRchar qry[512];
  
  // Arg check
  VDASSERTW(record);
  VDASSERTW(buf);

  // Xfer
  record->file_key =  atoi(buf[VDRIS_COLI_BLOBI_FILE_KEY]);
  strcpy(record->purpose,  buf[VDRIS_COLI_BLOBI_PURPOSE]);
  strcpy(record->hull,     buf[VDRIS_COLI_BLOBI_HULL]);
  strcpy(record->set_type, buf[VDRIS_COLI_BLOBI_SET_TYPE]);
  strcpy(record->set_name, buf[VDRIS_COLI_BLOBI_SET_NAME]);
  record->set_ver   = atoi(buf[VDRIS_COLI_BLOBI_SET_VER]);
  record->set_cur   = atoi(buf[VDRIS_COLI_BLOBI_SET_CUR]);
  strcpy(record->post_date,buf[VDRIS_COLI_BLOBI_POST_DATE]);
  record->blob_key  = atoi(buf[VDRIS_COLI_BLOBI_BLOB_KEY]);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

