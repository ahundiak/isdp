/* $Id: VDatRis.c,v 1.4 2001/02/17 14:08:26 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/post/VDatPdm.I
 *
 * Description: XML Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatRis.c,v $
 *      Revision 1.4  2001/02/17 14:08:26  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/02/11 17:44:09  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/02/01 21:25:10  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/11 21:06:42  art
 *      sp merge
 *
 * Revision 1.2  2000/12/15  20:02:26  pinnacle
 * ah
 *
 * Revision 1.1  2000/10/15  13:51:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/26/00  ah      creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDxml.h"
#include "VDrisc.h"
#include "VDat.h"
#include "VDassert.h"
#include "time.h"

VDASSERT_FFN("vdat/post/VDatRis.c");

/* -----------------------------------------------
 * Insert row into blob table
 */
IGRstat VDatRisInsertCurrentBlob(TVDatBlob *blob)
{
  VDASSERT_FN("VDatRisInsertCurrentBlob");
  
  IGRstat retFlag = 0;
  IGRchar sql[512];
  
  // Arg check
  VDASSERTW(blob);
  
  // First, clear the current flag for any existing entries
  sprintf(sql,
	  "Update %s Set %s=0 where "
	  "%s='%s' and %s='%s' and %s='%s' and %s='%s' and %s=1;",

	  VDAT_RIS_TBLN_BLOBS,
	  VDAT_RIS_FLDN_BLOBS_SET_CUR,

	  VDAT_RIS_FLDN_BLOBS_PURPOSE,
	  blob->purpose,
	  VDAT_RIS_FLDN_BLOBS_HULL,
	  blob->hull,
	  VDAT_RIS_FLDN_BLOBS_SET_TYPE,
	  blob->set_type,
	  VDAT_RIS_FLDN_BLOBS_SET_NAME,
	  blob->set_name,
	  VDAT_RIS_FLDN_BLOBS_SET_CUR);

  VDrisExecute(sql);
  
  // Now do the insert
  sprintf(sql,
	  "Insert into %s values (%d,'%s','%s','%s','%s',%d,%d,'%s',%d);",
	  VDAT_RIS_TBLN_BLOBS,
	  blob->file_key,
	  blob->purpose,
	  blob->hull,
	  blob->set_type,
	  blob->set_name,
	  blob->set_ver,
	  blob->set_cur,
	  blob->post_date,  
	  blob->blob_key);

  VDrisExecute(sql);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Query for the latest blob entry
 * purpose,hull,set_type,set_name already filled in
 */
IGRstat VDatRisSelectCurrentBlob(TVDatBlob *blob)
{
  VDASSERT_FN("VDatRisSelectCurrentBlob");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDrisInfo ris;
  IGRchar sql[512];
  
  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  VDASSERTW(blob);
  blob->blob_key   =  0;
  blob->set_ver    = -1;
  blob->set_cur    =  0;
  *blob->post_date =  0;
  
  // The query
  sprintf(sql,
	  "Select %s,%s,%s from %s where "
          "%s='%s' and %s='%s' and %s='%s' and %s='%s' and %s=1;",

	  VDAT_RIS_FLDN_BLOBS_SET_VER,
	  VDAT_RIS_FLDN_BLOBS_BLOB_KEY,
	  VDAT_RIS_FLDN_BLOBS_POST_DATE,
	  VDAT_RIS_TBLN_BLOBS,

	  VDAT_RIS_FLDN_BLOBS_PURPOSE,
	  blob->purpose,
	  VDAT_RIS_FLDN_BLOBS_HULL,
	  blob->hull,
	  VDAT_RIS_FLDN_BLOBS_SET_TYPE,
	  blob->set_type,
	  VDAT_RIS_FLDN_BLOBS_SET_NAME,
	  blob->set_name,
	  VDAT_RIS_FLDN_BLOBS_SET_CUR);

  VDrisQuery(&ris,sql);
  
  // Not having any is ok
  if (ris.rows == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // But should only be one
  VDASSERTW(ris.rows == 1);
  
  // Fill in data structure
  blob->set_ver   = atoi(ris.buf[0]);
  blob->blob_key  = atoi(ris.buf[1]);
  strcpy(blob->post_date,ris.buf[2]);
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
}


/* -----------------------------------------------
 * Decision has been made to post this file
 * blob purpose,hull,type and name are filled in
 *
 * Xml file is generated here
 */
IGRstat VDatPostBlob(TVDatBlob *blob)
{
  VDASSERT_FN("VDatPostBlob");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  time_t current_time;
  struct tm *tm;

  IGRchar file_name [] = "/usr/tmp/vdat_insert.xml";
  IGRchar file_namez[] = "/usr/tmp/vdat_insert.xml.gz";
  
  // Arg check
  VDASSERTW(blob);

  // Make the xml file
  sts = VDatWriteXmlFile(blob->set_type,blob->set_name,file_name);
  if (!(sts & 1)) goto wrapup;
    
  // See if already in the table
  VDatRisSelectCurrentBlob(blob);

  // Inc version, make it current
  blob->set_ver++;
  blob->set_cur = 1;
  
  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
  sprintf(blob->post_date,
	  "%4d-%02d-%02d %02d:%02d:%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,tm->tm_min,tm->tm_sec);
  
  // Get the blob key
  VDrisGetNextKey(VDRIS_TBLN_BLOBS,&blob->blob_key);
  
  // Do the table
  VDatRisInsertCurrentBlob(blob);
  
  // Do the file
  // VDatCompressFile(1,file_name);
  VDrisInsertBlobRecord(blob->blob_key,file_name,1,UI_status);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * See if the staging tree has changed since last posting
 * results = 0 - Error
 * results = 1 - No change
 * results = 3 - No changed because no previous tree
 * results = 5 - Change
 */
IGRstat VDatHasBlobChanged(TVDatBlob *blob, IGRint *results)
{
  VDASSERT_FN("VDatHasBlobChanged");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  resultsx;
  
  IGRchar fn1 [] = "/usr/tmp/vdat_select1.xml";
  IGRchar fn1z[] = "/usr/tmp/vdat_select1.xml.gz";
  IGRchar fn2 [] = "/usr/tmp/vdat_select2.xml";

  // Arg check
  VDASSERTW(results);
  *results = 0;
  VDASSERTW(blob);
  
  // Query to see if have any entries
  VDatRisSelectCurrentBlob(blob);
  if (blob->blob_key == 0) {
    *results = 3;  // No change because tree did not exist
    retFlag  = 1;
    goto wrapup;
  }

  // Get the file
  sts = VDrisSelectBlobRecord(blob->blob_key,fn1,1,1,UI_status);
  if (!(sts & 1)) goto wrapup;
  
  // Write out the existing xml file
  sts = VDatWriteXmlFile(blob->set_type,blob->set_name,fn2);
  if (!(sts & 1)) goto wrapup;

  // Diff em
  VDatCompareFiles(fn1,fn2,&resultsx);
  switch(resultsx) {
    case 0: goto wrapup;
    case 1: *results = 1; break;      
    case 3: *results = 5; break;
  }
  
  // Done
  retFlag  = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test the ris tree stuff
 */
IGRstat VDatTestHasBlobChanged()
{
  VDASSERT_FN("VDatTestHasBlobChanged");
  
  IGRstat retFlag = 0;
  IGRchar set_name[20];
  IGRchar set_type[20];
  IGRint  results;
  
  TVDatBlob blob;
  
  strcpy(set_type,"StagingTree");
  VDatGetSetNameForType(set_type,set_name);
  VDASSERTW(*set_name);
  
  printf("------------%s %s----------------------------\n",fn,set_name);
  VDrisOpenSchema(NULL);

  memset(&blob,0,sizeof(TVDatBlob));
  strcpy(blob.purpose,"spades");
  strcpy(blob.hull,   "lpd17");
  strcpy(blob.set_type,set_type);
  strcpy(blob.set_name,set_name);

  VDatHasBlobChanged(&blob,&results);

  VDatPostBlob(&blob);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}




