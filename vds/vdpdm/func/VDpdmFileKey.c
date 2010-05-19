 /* $Id: VDpdmFileKey.c,v 1.16 2002/05/10 19:33:50 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdm/VDpdmFileKey.C
 *
 * Description: File Key functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmFileKey.c,v $
 *      Revision 1.16  2002/05/10 19:33:50  ahundiak
 *      ah
 *
 *      Revision 1.15  2002/03/13 16:17:07  ahundiak
 *      ah
 *
 *      Revision 1.14  2001/11/19 18:27:01  jdsauby
 *      did not free risInfo structure, resolved - jds
 *
 *      Revision 1.13  2001/11/08 20:11:12  jdsauby
 *      JTS MP TR 5764, added caching of DB queries into DOM tree - jds
 *
 *      Revision 1.12  2001/10/03 14:06:19  jdsauby
 *      Utilize COset_trace for debug
 *
 *      Revision 1.11  2001/07/16 13:54:05  jdsauby
 *      VDassert working with Z D F
 *
 *      Revision 1.10  2001/04/13 20:44:24  jdsauby
 *      Post NB adjusted
 *
 *      Revision 1.9  2001/04/12 20:42:44  jdsauby
 *      sp 11
 *
 *      Revision 1.8  2001/03/29 19:38:48  jdsauby
 *      Added GetFilekeyforOS
 *
 *      Revision 1.7  2001/03/16 20:30:36  jdsauby
 *      Fixed a potential memory violation, AKA core dump.
 *
 *      Revision 1.6  2001/03/05 19:43:53  jdsauby
 *      Finish Purpose Info
 *
 *      Revision 1.5  2001/03/05 04:21:09  jdsauby
 *      Argument check for VDpdmGetFileKeyforCPR was incorrect
 *
 *      Revision 1.4  2001/03/02 21:45:07  jdsauby
 *      Added purpose Info
 *
 *      Revision 1.3  2001/02/21 13:02:23  jdsauby
 *      CR4088
 *
 *      Revision 1.2  2001/02/11 17:09:23  ahundiak
 *      Renamed VDnfmx to VDnfmc
 *
 *      Revision 1.1  2001/02/05 16:38:44  jdsauby
 *      JTS MP CR4088
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDnfmc.h"
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "time.h"
#include "VDDbDef.h"

VDASSERT_FFN("vdpdm/func/VDpdmFileKey.c");

/* ----------------------------------------
 * Static variable so the file key table only has to be
 * checked once to see if it is available
 * **/
static IGRint FILE_KEY_TABLE_EXISTS = 0;


/* ---------------------------------------------
 * Simply returns the current available file key
 * 13 Mar 2002 - See comments in getNextFileKey
 * */
static IGRstat getCurFileKey( fileKey )
   IGRint  *fileKey;
{
   VDASSERT_FN("getCurFileKey");

   IGRstat retFlag = 1;
   TVDrisInfo  ris;

   VDrisInitInfo( &ris );
   // Arg check
   VDASSERTW( fileKey );

   traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_FILE_KEY);
   if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
   
   // init
   *fileKey = 0;

   if (1) {
     retFlag = VDrisPdmGetCurFileKey(fileKey);
     goto wrapup;
   }
   
   // build the query
   sprintf(ris.sql, "Select %s from %s where %s='%s';",
	   VDPDM_KEY_TABLE_COLN_VALUE,
	   VDPDM_KEY_TABLE_TABLE_NAME,
	   VDPDM_KEY_TABLE_COLN_KEY_NAME,
	   VDPDM_FILE_KEY_COLN_FILE_KEY );

   // do the query
   VDrisQuery( &ris, NULL );
   if (ris.rows < 1) goto wrapup;
   
   // set it
   *fileKey = atoi( ris.buf[0] );
   if (traceFlag) printf("### fileKey = %d\n",*fileKey);
   
   // done


wrapup:
   VDrisFreeInfo( &ris );
   if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
   return retFlag;
}

/* -------------------------------------------------
 * Gets the next available file key, and increments
 * the next available file key by 1
 *
 * 13 Mar 2002
 * This routine does not work quite right
 * The insert does not return an error if the no matching
 * records are found.  Replace with the lower level ris routine
 *
 * Also, might be cleaner to just go with the vdat_keys table
 * Need something to deal with the syncing though so maybe not
 * */
static IGRstat getNextFileKey( fileKey )
   IGRint  *fileKey;
{
   VDASSERT_FN("getNextFileKey");

   IGRstat retFlag = 0;
   IGRstat sts;

   //TVDrisInfo  ris;

   time_t current_time;
   struct tm *tm;
   IGRchar cur_date[40];

   IGRchar sqlx[128];

   IGRint keyx, key_try;


   // say hi
   traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_FILE_KEY);
   if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

   // arg check
   VDASSERTW( fileKey ); *fileKey = 1;
   if (1) {
     retFlag = VDrisPdmGetNextFileKey(fileKey);
     goto wrapup;
   }
   
   // init
   time(&current_time);
   tm = localtime(&current_time);
   sprintf(cur_date,
           "%4d-%02d-%02d %02d:%02d:%02d",
	   tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	   tm->tm_hour,tm->tm_min,tm->tm_sec);


   // Get the current key
   getCurFileKey( &keyx );
   
   // set it to 1 if not found
   if ( keyx < 1 ) {
      sprintf( sqlx, "Insert into %s values ('%s',1,'%s');",
                     VDPDM_KEY_TABLE_TABLE_NAME,
		     VDPDM_FILE_KEY_COLN_FILE_KEY,
		     cur_date );
      VDrisExecute( sqlx );
      *fileKey = 1;
      retFlag = 1;
      return retFlag;
   }

   // got the key, need to update the table
   key_try = 0;

key_loop:
   keyx++;

   /* Update the table.  It is possible that this is being called from
    * multiple locations, and this is being updated at the same time
    */
    sprintf(sqlx,
            "Update %s set %s=%d, %s='%s' where %s='%s' and %s=%d;",
	    VDPDM_KEY_TABLE_TABLE_NAME,
	    VDPDM_KEY_TABLE_COLN_VALUE, keyx,
	    VDPDM_KEY_TABLE_COLN_UPD_DATE, cur_date,
	    VDPDM_KEY_TABLE_COLN_KEY_NAME, VDPDM_FILE_KEY_COLN_FILE_KEY,
	    VDPDM_KEY_TABLE_COLN_VALUE, keyx-1);


    sts = VDrisExecute( sqlx );
    if ( !(sts & 1) ) goto key_num_not_found;

   // done
   *fileKey = keyx;
   retFlag = 1;
   return retFlag;

   // Someone is trying to update at the same time
key_num_not_found:

   if (key_try < 10) {
      key_try++;
      goto key_loop;
   }
   printf("*** Giving up getting file key after %d attempts\n",key_try);

wrapup:
   return retFlag;

}
IGRstat VDpdmGetNextFileKey(IGRint *key)
{
  if (key) *key = 0;
  return getNextFileKey(key);
}


/* --------------------------------------------------
 * Sets the fileKey for a given catalog, part, and revision
 * */
IGRstat VDpdmSetFileKeyForCPR( IGRchar *catalog,
                               IGRchar *part,
			       IGRchar *revision,
			       IGRint  *a_fileKey )
{
   VDASSERT_FN("VDpdmSetFileKeyForCPR");

   IGRstat retFlag = 0;
   IGRstat sts;
   IGRint  fileKey;
   IGRchar sql[1024];

   // arg Check
   VDASSERTW( catalog[0]  != '\0' );
   VDASSERTW( part[0]     != '\0' );
   VDASSERTW( revision[0] != '\0' );
   VDASSERTW( a_fileKey ); *a_fileKey = 0;

   // say hi
   traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_FILE_KEY);
   if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

   // get the next available file_key
   sts = getNextFileKey( &fileKey );
   if ( !(sts & 1) ) goto wrapup;
   
   // update file key table

   // build the input string
   sprintf(sql,
           "Insert into %s values ('%s','%s','%s',%d);",
	   VDPDM_FILE_KEY_TABLE_NAME,
	   catalog, part, revision,
	   fileKey );
   
   // do it
   sts = VDrisExecute( sql );
   VDASSERTW( sts & 1 );
   
   // done
   *a_fileKey = fileKey;
   retFlag = 1;

wrapup:
   // say by
   if (traceFlag) printf("<<< %s %s %d <%d>\n",ffn(),fn,retFlag,*a_fileKey);
   return retFlag;
}

/* -------------------------------------------------------
 * Returns the fileKey for a given Catalog, Part, and Revision
 * if one is not found, it will be set.
 * */
IGRstat VDpdmGetFileKeyForCPR( IGRchar *catalog,
                               IGRchar *part,
			       IGRchar *revision,
			       IGRint  *a_fileKey )
{
   VDASSERT_FN("VDpdmGetFileKeyForCPR");

   IGRstat retFlag = 0;
   IGRstat sts;
   IGRint  fileKey;
   IGRchar sql[1024];

   TVDrisInfo  ris;

   VDrisInitInfo( &ris );
   // arg Check
   if( catalog[0]  == '\0' ) goto wrapup;
   if( part[0]     == '\0' ) goto wrapup;
   if( revision[0] == '\0' ) goto wrapup;
   if( a_fileKey == NULL ) goto wrapup; 
   *a_fileKey = 0;

   // init
   fileKey = 0;
   
   // say hi
   traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_FILE_KEY);
   if (traceFlag) printf(">>> %s %s <%s><%s><%s>\n",ffn(),fn,catalog,part,revision);

   // try the cache first
   sts = VDpdmCgetFilekeyForCPR(catalog,part,revision,a_fileKey);
   if (sts & 1) {
       VDASSERTW(*a_fileKey > 0);
       retFlag = 0;
       goto wrapup;
   }
   
   // logged in
   if (!VDpdmVerifyLogin()) goto wrapup;

   // make sure the table exists
   if (FILE_KEY_TABLE_EXISTS == 0) {
       if (VdsVerifyRisTable( VDPDM_FILE_KEY_TABLE_NAME ) != VDS_DBTABLE_FOUND ) 
	   goto wrapup;
       FILE_KEY_TABLE_EXISTS = 1;
   }


   // build the query
   sprintf(sql,
           "select %s from %s where %s='%s' and %s='%s' and %s='%s';",
	   VDPDM_FILE_KEY_COLN_FILE_KEY, VDPDM_FILE_KEY_TABLE_NAME,
	   VDPDM_FILE_KEY_COLN_CATALOG,  catalog, 
	   VDPDM_FILE_KEY_COLN_PART,     part, 
	   VDPDM_FILE_KEY_COLN_REVISION, revision );
   
   // do it
   VDrisQuery( &ris, sql );
   if ( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) {
       sts = VDpdmSetFileKeyForCPR( catalog, part, revision, &fileKey);
       VDASSERTW( fileKey != 0 );
       *a_fileKey = fileKey;
       retFlag = 1;
       goto wrapup;
   }
   
   // done
   *a_fileKey = atoi( ris.buf[0] );

   // set it in the cache for future use
   VDpdmCsetCPRForFilekey(a_fileKey,catalog,part,revision);

   retFlag = 1;

wrapup:
   // say by
   VDrisFreeInfo( &ris );
   if (traceFlag) printf("<<< %s %s %d <%d>\n",ffn(),fn,retFlag,*a_fileKey);
   return retFlag;
}

/* ---------------------------------------------------
 * Get the filekey for an osnum
 * */
IGRstat VDpdmGetFilekeyForOS(VDosnum  osnum,
                             IGRint   *filekey)
{
    VDASSERT_FN("VDpdmGetFilekeyForOS");

    IGRstat retFlag = 0;
    IGRstat sts;

    TVDpdmInfo  pdmInfo;

    IGRchar catalog [80];
    IGRchar part    [80];
    IGRchar rev     [80];
    IGRchar filename[80];
    IGRint  fkey;

    VDosnum cur_os;

    // Arg Check
    VDASSERTW(filekey); *filekey = 0;

    *filename = 0;
    *catalog  = 0;

    // default to active OS
    VDosGetCurrentOS(&cur_os);
    if (osnum == OM_K_NOT_AN_OS) osnum = cur_os; 

    // try getting it from pdmInfo
    VDpdmGetPdmInfo(osnum, &pdmInfo);
    if (pdmInfo.filekey > 0) {
	*filekey = pdmInfo.filekey;
	retFlag = 1;
	goto wrapup;
    }

    // Do it the hard way
    // try updating PDMinfo, then get it again.
    VDpdmUpdatePdmInfo(osnum);

    VDpdmGetPdmInfo(osnum, &pdmInfo);
    if (pdmInfo.filekey > 0) {
	*filekey = pdmInfo.filekey;
	retFlag = 1;
	goto wrapup;
    }

    
#if 0
    // get the filename
    VDosGetFileName(osnum,filename);
    if (*filename == 0) goto wrapup;
  
    PDMGetPartInfoGivenFileName(filename,catalog,part,rev);
    if (*catalog == 0) goto wrapup;

    sts = VDpdmGetFileKeyForCPR(catalog,part,rev,&fkey);
    if (!(sts & 1)) goto wrapup;
    // done
    *filekey = fkey;
    retFlag = 1;
#endif

wrapup:
    return retFlag;
}

/* ----------------------------------------------------
 * Get the Catalog, part, and revision for a filekey
 * ***/
IGRstat VDpdmGetCPRForFilekey(IGRint  *fileKey,
	                      IGRchar *catalog,
			      IGRchar *part,
			      IGRchar *rev)
{
    VDASSERT_FN("VDpdmGetCPRForFilekey");

    IGRstat retFlag;
    IGRstat sts;

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_FILE_KEY);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Arg check
    VDASSERTW(*fileKey != 0);
    VDASSERTW(catalog); *catalog = 0;
    VDASSERTW(part);    *part    = 0;
    VDASSERTW(rev);     *rev     = 0;

    // try the cache first
    sts = VDpdmCgetCPRForFilekey(fileKey,catalog,part,rev);
    if (sts & 1) {
	VDASSERTW(*catalog);
	VDASSERTW(*part);
	VDASSERTW(*rev);
	retFlag = 1;
	goto wrapup;
    }

    // logged in
    if (!VDpdmVerifyLogin()) goto wrapup;

    // does the table exist
    if (FILE_KEY_TABLE_EXISTS == 0) {
       if (VdsVerifyRisTable( VDPDM_FILE_KEY_TABLE_NAME ) != VDS_DBTABLE_FOUND ) 
	   goto wrapup;
       FILE_KEY_TABLE_EXISTS = 1;
    }

    // the query
    sprintf(ris.sql,
	    "Select %s, %s, %s from %s where %s=%d;",
	    VDPDM_FILE_KEY_COLN_CATALOG,
	    VDPDM_FILE_KEY_COLN_PART,
	    VDPDM_FILE_KEY_COLN_REVISION,
	    VDPDM_FILE_KEY_TABLE_NAME,
	    VDPDM_FILE_KEY_COLN_FILE_KEY, *fileKey );

    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // set them
    strcpy( catalog, ris.buf[VDPDM_FILE_KEY_COLI_CATALOG] );
    strcpy( part,    ris.buf[VDPDM_FILE_KEY_COLI_PART]    );
    strcpy( rev,     ris.buf[VDPDM_FILE_KEY_COLI_REVISION]);

    // set it in the cache for future use
    VDpdmCsetCPRForFilekey(fileKey,catalog,part,rev);
    
    // done
    retFlag = 1;

wrapup:
    // say bye
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s <%s,%s,%s>\n",ffn(),fn,catalog,part,rev);
    return retFlag;
}
