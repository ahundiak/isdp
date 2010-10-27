 /* $Id: VDpdmNotebook.C,v 1.6 2002/02/28 16:13:56 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdm/VDpdmNotebook.C
 *
 * Description: Posting Notebook functions
 *
 * Dependencies:
 *
 * Revision History:
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/08/01  js      Creation
 ***************************************************************************/

#include "VDtypedef.h"
#include "VDnfmc.h"
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "time.h"
#include "VDDbDef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include <sys/stat.h>
#include "VDexp.h"

VDASSERT_FFN("vdpdm/func/VDpdmNotebook.C");

//from VDnb import setText;



/* ----------------------------------------------
 * alter the filename, and possibly the header to assure
 * that it will work with system calls.  IE take out any 
 * bad characters that Solaris would not like
 * **/
IGRstat VDpdmGetValidFilename(IGRchar *header, 
	                      IGRint  filekey,
			      IGRchar *filename,
			      IGRint  cln_hdr)
{
    VDASSERT_FN("VDpdmGetValidFilename");
    IGRstat retFlag = 0;

    IGRchar *p;
    IGRchar buf[256];

    VDASSERTW(header && *header != 0);
    VDASSERTW(filekey > 0);
    VDASSERTW(filename); *filename = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    strcpy(buf,header);

    // Scan Through
    for(p = buf; *p; p++) {
	if ( ((*p < '0') || (*p > '9')) &&
	     ((*p < 'A') || (*p > 'Z')) &&
	     ((*p < 'a') || (*p > 'z'))  ){
	    *p = '_';
	}
    }

    // set the filename
    sprintf(filename,"%s.%d.nb",buf,filekey);
    if (*filename != 0) retFlag = 1;

    // if header needs to be cleaned as well
    if (cln_hdr) {
	strcpy(buf,header);
	for(p = buf; *p; p++) {
	    if ( (*p != ' ')                &&
		 ((*p < '0') || (*p > '9')) &&
		 ((*p < 'A') || (*p > 'Z')) &&
		 ((*p < 'a') || (*p > 'z'))  ){
		*p = '_';
	    }
	}
	// set the new header
	strcpy(header,buf);
	if (*header != 0) retFlag = 1;
    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------
 * Get the notebook info from the database and store
 * into TVDrisInfo buf structure
 * **/
IGRstat VDpdmGetNbDataFromDatabase(IGRint      filekey,
	                           TVDrisInfo *ris)
{
    VDASSERT_FN("VDpdmGetNbDataFromDatabase");
    IGRstat retFlag = 0;
    IGRstat sts;

    // arg check
    VDASSERTW(filekey > 0);
    VDASSERTW(ris);

    // logged in?
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;

    // does the table exist?
    if ( VdsVerifyRisTable( VDPDM_NB_TABLE_NAME ) != VDS_DBTABLE_FOUND ) goto wrapup;

    // get the headers from the database
    sprintf(ris->sql,
	    "Select * from %s where %s=%d;",
	    VDPDM_NB_TABLE_NAME, 
	    VDPDM_NB_COLN_FILE_KEY, filekey );

    VDrisQuery( ris, NULL );
    if (ris->rows < 1) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ---------------------------------------
 * Get path for notebook
 */
IGRstat VDpdmGetNbPathOS( VDosnum   osnum,
                          IGRchar   *path )
{
    VDASSERT_FN("VDpdmGetNbPath");

    IGRstat retFlag = 0;
    IGRchar name[1024];
    IGRchar pathx[1024];

    VDosnum activeOS;

    // Arg check
    if (path == NULL) goto wrapup;
    *path = 0;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Default to active space
    ex$get_cur_mod(osnum = &activeOS);
    if (osnum == OM_K_NOT_AN_OS) osnum = activeOS;

    // Always start in current file
    di$give_pathname(osnum = activeOS, pathname = path);
    VDASSERTW(*path);

    // Might be in a reference file
    if (osnum != activeOS) {
	di$give_pathname(osnum = osnum, pathname = pathx);
	VDASSERTW(*pathx);
	DIstrcpy(path,pathx);
    }

    // add notebook
    DIstrcat(path,"NoteBook");

    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    if (retFlag != 1) *path = 0;
    return retFlag;
}
/* -----------------------------------------------
 * Get an existing doom object
 */
IGRstat VDpdmGetNbTextByNameOS(VDosnum osnum, IGRchar *name, IGRchar *text)
{
  
  VDASSERT_FN("VDpdmGetDoomNbObjectByNameOS");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar path[DI_PATH_MAX];
  
  // Arg check
  VDASSERTW(name && *name);
  VDASSERTW(text);
  
  // Pick os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);

  // Generate path
  VDpdmGetNbPathOS(osnum,path);
  VDASSERTW(*path);

  DIstrcat(path,name); 


  VDnbGetTextFromPath( path, 32768, text );
  if (*text == 0) goto wrapup;
  
 
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}



/* ---------------------------------------------------
 * Get nth notebook name from GRnotebook
 * **/
IGRstat VDpdmGetNthNbNameOS(VDosnum osnum,
	                    IGRint  nth,
	                    IGRchar *name)
{
    VDASSERT_FN("VDpdmGetNthNbName");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRint  NbCnt = 0;
    IGRchar NbPath[DI_PATH_MAX];

    // arg check
    VDASSERTW(name); *name = 0;
    *NbPath = 0;

    // get the notebook path
    VDpdmGetNbPathOS( osnum, NbPath );
    if (*NbPath == 0) goto wrapup;

    // find the nb paths
    di$start_find( start_dir = NbPath,
        	   ptr       = &NbCnt );

    if (nth >= NbCnt) goto wrapup;

    // fetch it, and set it
    di$fetch_find(index = nth, line = name);

    if (*name) retFlag = 1;

wrapup:
    return retFlag;
}

#if 0
static IGRstat replaceNbText(TGRid   *nbID,
		             IGRchar *filename)
{
    VDASSERT_FN("replaceNbText");
    IGRstat retFlag = 0;
    IGRstat sts;

    FILE *file = NULL;
    int  size, line, i;
    char buf1[256];
    char *ptr = NULL;
    char *ptr_tmp = NULL; 

    TGRid  objID;
    VDclassid nbClass;


    VDASSERTW(nbID->objid != NULL_OBJID);
    VDASSERTW(*filename != 0);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    objID = *nbID;
    // check the class
    om$get_classid(objid = objID.objid,
	           osnum = objID.osnum,
		   p_classid = &nbClass );

    if ( (nbClass != OPP_GRnb_class_id) && (nbClass != OPP_VDnb_class_id) ) 
								goto wrapup;

    if ( nbClass == OPP_GRnb_class_id ) {
	// change the class
	sts = om$change_class( objid = objID.objid,
		               osnum = objID.osnum,
			       classname = "VDnb" );
	if (!(sts & 1)) goto wrapup;
    }

    // Open file
    file = fopen(filename,"r");
    if (file == NULL) {
	printf("Error Opening ASCII File %s\n",filename);
	goto wrapup;
    }
    
    // get the size of the file
    size = 0;
    line = 0;
    while(fgets(buf1,sizeof(buf1),file)) {
	size = size+ strlen ( buf1 );
	line = line+1;
    }
    size++;


    ptr = (char *) malloc(size * sizeof(char));
    if (ptr == NULL) goto wrapup;

    fseek(file,0,SEEK_SET);
#if 0
    // Open file again
    file = fopen(filename,"r");
    if (file == NULL) {
	printf("Error Opening ASCII File %s\n",filename);
	goto wrapup;
    }
#endif
    //record the file contents
    printf("## record file contents\n");
    i=0;
    while(fgets(buf1,sizeof(buf1),file)) {
	for (ptr_tmp = buf1; *ptr_tmp!='\n';){
	    ptr[i++] = *ptr_tmp++;
	}
	ptr[i++] = '\0'; 
    }
    ptr[i++] = 0;
    fclose(file);

    // Set the buffer
    sts = om$send(
	    msg = message VDnb.setText(ptr,size),
	    senderid = NULL_OBJID,
	    targetid = objID.objid,
	    targetos = objID.osnum);
    if (!(sts & 1)) {
	printf("Problem setting text for [%d,%d]\n",objID.objid,objID.osnum);
	goto wrapup;
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    if (ptr) free( ptr ); ptr = NULL;
    if (file) fclose(file);
    return retFlag;
}
#endif
    
/* -----------------------------------------------------------------------
 * Update the EMS Notebook buffer
 * **/
IGRstat VDpdmUpdateNbBuffer(VDosnum osnum,
	                    IGRchar *header,
			    IGRchar *filename)
{
    VDASSERT_FN("VDpdmUpdateNbBuffer");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar nbTitle[DI_PATH_MAX];

    TGRid  nbID, exstnbID;

    // init
    nbID.objid     = NULL_OBJID;
    exstnbID.objid = NULL_OBJID;

    // arg check
    VDASSERTW(osnum != OM_K_NOT_AN_OS);
    VDASSERTW(*header != 0);
    VDASSERTW(*filename != 0);

    strcpy(nbTitle,header);

    // see if there is an existing notebook header
    sts = VDpdmGetDoomNbObjectByNameOS(osnum, nbTitle, &nbID);
    
    if ( !(sts & 1) && (nbID.objid == NULL_OBJID) ) {

	// create one
	VDpdmCreateDoomNbObjectOS(osnum, nbTitle, &nbID);
    }

    VDASSERTW(nbID.objid != NULL_OBJID);

    // set the text within
    sts = VDdoomLoadFile(0, &nbID, filename);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ------------------------------------------------------------------------
 * check to see if a notebook header has been changed by an external app
 * **/
IGRstat VDpdmNbIsDbChanged(IGRint   filekey,
	                   IGRchar *header)
{
    VDASSERT_FN("VDpdmNbIsDbChanged");
    IGRstat retFlag = 0;

    TVDrisInfo  ris;

    // init
    VDrisInitInfo( &ris );

    // arg check
    VDASSERTW(*header != 0);
    VDASSERTW(filekey > 0);

    // logged in
    if (!VDpdmVerifyLogin()) goto wrapup;

    // does the table exist?
    if ( VdsVerifyRisTable( VDPDM_NB_TABLE_NAME ) != VDS_DBTABLE_FOUND ) goto wrapup;

    // if nb_inc = 1, then it has been changed, otherwise it has not.

    // query
    sprintf(ris.sql,
	    "Select %s from %s where %s=%d and %s='%s';",
	    VDPDM_NB_COLN_NB_INC,VDPDM_NB_TABLE_NAME,
	    VDPDM_NB_COLN_FILE_KEY, filekey,
	    VDPDM_NB_COLN_NB_HEADER, header);

    // do it
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // should only get one record
    if (!strcmp(ris.buf[0],"1")) retFlag = 1;

    // done

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}


/* ------------------------------------------------------------------------
 * Returns the path of the vddbnb_posted expression
 */
static IGRstat VDpdmGetVddbNbPostedPath(VDosnum osnum, IGRchar *path)
{
  IGRstat retFlag = 0;
  IGRchar name[1024];
  IGRchar activeName[1024];
  
  VDosnum activeOS;
  
  // Arg check
  if (path == NULL) goto wrapup;
  *path = 0;

  // Default to active space
  ex$get_cur_mod(osnum = &activeOS);
  if (osnum == OM_K_NOT_AN_OS) osnum = activeOS;
  VDosGetFileName(osnum,name);
  if (*name == 0) goto wrapup;

  // No need to deal with transient spaces, assume active space is lowest
  if (osnum <= activeOS) {
    sprintf(path,":%s:IGENOD:vddbnb_posted",name);
    retFlag = 1;
    goto wrapup;
  }
  // Build off of the active
  VDosGetFileName(activeOS,activeName);

  sprintf(path,":%s:ref:%s:IGENOD:vddbnb_posted",activeName,name);
  //printf("Path '%s'\n",path);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------------------
 * Get the vddbnb_posted expression if it exists
 */
static IGRstat VDpdmGetVddbNbPostedExp(VDosnum  a_osnum, 
			               TGRid   *a_expID,
			               IGRchar *a_expPath,
			               IGRchar *a_expText)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   expID;
  IGRchar path[128];
  
  // Arg check
  if (a_expID) a_expID->objid = NULL_OBJID;
  if (a_expText) *a_expText = 0;
  if (a_expPath) *a_expPath = 0;
  
  // Get the path
  if (a_osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &a_osnum);
  VDpdmGetVddbNbPostedPath(a_osnum,path);
  if (*path == 0) goto wrapup;
  if (a_expPath) strcpy(a_expPath,path);
  
  // Get the expression
  expID.osnum = a_osnum;
  expID.objid = NULL_OBJID;
  sts = di$translate(objname = path,
		     p_objid = &expID.objid);
  if (!(sts & 1)) goto wrapup;
  if (expID.objid == NULL_OBJID) goto wrapup;
  
  if (a_expID) *a_expID = expID;
  
  // Get the text
  if (a_expText) {  
    vdexp$Get(objID = &expID, txt = a_expText);
    if (*a_expText == 0) goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------------------
 * Creates, validates or updates the vddbnb_posted expression
 */
IGRstat VDpdmUpdateVddbNbPosted(VDosnum osnum,
	                        IGRchar *value)
{
    VDASSERT_FN("VDpdmUpdateVddbNbPosted");
    IGRstat retFlag = 1;
    IGRstat sts;

    IGRchar expPath[128];
    IGRchar expText[128];
    TGRid   expID;

    IGRchar    pdmText[128];
    VDosnum    cur_os;

    IGRchar    msg[80];

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Init
    expID.objid = NULL_OBJID;

    // arg check
    if (*value == 0) strcpy(value,"NO");

    // get the current os
    ex$get_cur_mod(osnum = &cur_os);

    // Get the pdm info expression
    if (osnum == OM_K_NOT_AN_OS) osnum = cur_os;
    VDpdmGetVddbNbPostedExp(osnum, &expID, expPath, expText);

    // If the expression does not exist, create it
    if (expID.objid == NULL_OBJID) {

	vdexp$CreateTextExp(osnum = osnum,
		name  = expPath,
		text  = value,
		objID = &expID);

	//vdobj$Print(objID = &expID);
	retFlag = 1;
	goto wrapup;
    }

    // If the expression exists then see if it's valid
    if (!strcmp(expText,value)) {
	//printf("Expression is ok\n");
	retFlag = 1;
	goto wrapup;
    }

    // Update it
    vdexp$ModifyTextExp(objID = &expID, text = value);


    // Done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -----------------------------------------------
 * Standard interface for getting pdm info
 */
IGRstat VDpdmGetVddbNbPosted(VDosnum osnum, IGRchar *nb_posted)
{
  IGRstat retFlag = 0;
  IGRchar expPath[256],expText[256];
  TGRid   expID;
  IGRchar *p;
  
  // Arg check
  if (nb_posted == NULL) goto wrapup;
  *nb_posted = 0;
  
  // Default to active
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  VDpdmGetVddbNbPostedExp(osnum,&expID,expPath,expText);
  
  if ( (*expText == 0) || (*expPath == 0) ) {   
    // set it to NO 
    VDpdmUpdateVddbNbPosted(osnum,"NO");
    strcpy(nb_posted,"NO");
    retFlag = 1;
    goto wrapup;
  }

  // Set it
  strcpy(nb_posted,expText);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* ---------------------------------------
 * clean up the existing blob record and index
 */
static void cleanBlobRecords(IGRint  key,
                             IGRchar *name)
{
    VDASSERT_FN("cleanBlobRecords");

    IGRstat sts;
    IGRint blob_key;
    IGRchar sql[1024];

    TVDrisInfo  ris;

    // init
    VDrisInitInfo( &ris );
    VDASSERTW(*name != 0);

    // do any records exist
    sprintf(ris.sql,"Select %s from %s where %s=%d and %s='%s';",
            VDPDM_NB_COLN_BLOB_KEY, VDPDM_NB_TABLE_NAME,
	    VDPDM_NB_COLN_FILE_KEY, key,
	    VDPDM_NB_COLN_NB_HEADER, name);

    // query it
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // remove the blob record
    blob_key = atoi(ris.buf[0]);
    VDrisDeleteBlobRecord(blob_key,UI_status);

    // remove the index
    sprintf(sql,"Delete from %s where %s=%d and %s='%s';",
            VDPDM_NB_TABLE_NAME, 
	    VDPDM_NB_COLN_FILE_KEY, key,
	    VDPDM_NB_COLN_NB_HEADER, name);

    VDrisExecute( sql );

    // done
wrapup:
    VDrisFreeInfo( &ris );
    return;
}
    

    
/* ---------------------------------------
 * Insert the record into the vdpdm_notebook table
 */
IGRstat VDpdmInsertNbRecord(IGRint  key,
                            IGRint  blob_key,
			    IGRchar *NbName)
{
    VDASSERT_FN("VDpdmInsertNbRecord");
    IGRstat retFlag = 0;
    IGRstat sts;

    time_t current_time;
    struct tm *tm;
    IGRchar cur_date[40];
    IGRchar sql[1024];


    VDASSERTW(*NbName != 0);

    /* Clean up the existing blob record, and index first */
    cleanBlobRecords(key,NbName);

    // set it up
    time(&current_time);
    tm = localtime(&current_time);
    sprintf(cur_date,
	    "%4d-%02d-%02d %02d:%02d:%02d",
	    tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	    tm->tm_hour,tm->tm_min,tm->tm_sec);

    // the sql
    sprintf(sql,"Insert into %s values (%d,%d,'%s',0,'%s');",
	    VDPDM_NB_TABLE_NAME, key, blob_key, NbName, cur_date );

    // do it
    sts = VDrisExecute( sql );
    if (!(sts & 1)) goto wrapup;

    // put the timestamp on the post date table
    VDpdmPostTableTimestamp(VDPDM_NB_TABLE_NAME);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}
 
/* ---------------------------------------
 * Convert the NB text buf to a file
 */
static IGRstat convertBufToFile( IGRint  key,
                                 IGRchar *header,
				 IGRchar *buf,
				 IGRchar *filename )
{
    VDASSERT_FN("convertBufToFile");

    IGRstat retFlag = 0;
    IGRstat sts;

    FILE  *file = NULL;

    // Arg Check
    VDASSERTW(*header != 0);
    VDASSERTW(*buf    != 0);
    VDASSERTW(filename);  *filename = 0;

    // set it up
    sprintf(filename,"/usr/tmp/%c.%d.buf",*header,key);
    if (*filename == 0) goto wrapup;

    // the file
    file = fopen(filename,"wt");
    if (file == NULL) goto wrapup;

    // write it
    fprintf(file,"%s",buf);

    // done
    retFlag = 1;

wrapup:
    if (file) fclose(file);
    return retFlag;
}
    
/* -----------------------------------------------
 * Given a file key, notebook title, and text file, post
 * it to the blob notebook
 * **/
IGRstat VDpdmPostNbFile( IGRint  key,
	                 IGRchar *NbName,
			 IGRchar *filename )
{
    VDASSERT_FN("VDpdmPostNbFile");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  blob_key;
    struct stat f_stat;
    IGRchar cmd[128];

    // init
    blob_key = 0;

    // arg check
    VDASSERTW(key != 0);
    VDASSERTW(*NbName != 0);
    VDASSERTW(*filename != 0);

    // make sure the file exists
    sts = stat(filename,&f_stat);
    if ( (sts != 0) || (f_stat.st_size < 1) ) {
	printf("## ERROR: File <%s> does not exist\n",filename);
	goto wrapup;
    }

    // get the blob key
    VDrisGetNextKey(VDRIS_TBLN_BLOBS, &blob_key);
    if (blob_key == 0) goto wrapup;

    // Insert the blob record
    sts = VDrisInsertBlobRecord(blob_key,filename,1,UI_status);
    if (!(sts & 1)) goto wrapup;

    // update the notebook index table
    sts = VDpdmInsertNbRecord(key,blob_key,NbName);
    if (!(sts & 1)) goto wrapup;

    // remove the filename
    sprintf(cmd,"rm %s",filename);
    system( cmd );

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}
				 
/* ---------------------------------------
 * Post the text from each notebook header
 */
IGRstat VDpdmPostNbText( IGRint   key,
                         IGRchar *NbName,
			 IGRchar *NbText )
{
    VDASSERT_FN("VDpdmPostNbText");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  blob_key;
    IGRchar filename[80];

    // Arg check
    if (key    == 0)    goto wrapup;
    if (NbName == NULL) goto wrapup;
    if (NbText == NULL) goto wrapup;

    // init
    blob_key   = 0;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // get the blob key
    VDrisGetNextKey(VDRIS_TBLN_BLOBS, &blob_key);
    if (blob_key == 0) goto wrapup;

    // conver the NbText to a filename in /usr/tmp
    sts = convertBufToFile(key,NbName,NbText,filename);
    if (!(sts & 1)) goto wrapup;
    
    // Insert the blob record
    sts = VDrisInsertBlobRecord(blob_key,filename,1,UI_status);
    if (!(sts & 1)) goto wrapup;

    // update the notebook index table
    sts = VDpdmInsertNbRecord(key,blob_key,NbName);
    if (!(sts & 1)) goto wrapup;
    
    // done
    retFlag = 1;

    // just print it out
    //printf("header<%s>\n<<<%s>>>\n",NbName,NbText);

wrapup:
     if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    
/* ----------------------------------------
 * change NbName to a simpe header.  get rid of the 
 * filename:Notebook:
 */
IGRstat VDpdmChangeNbNameToNbHeader(IGRchar *NbName,
                                    IGRchar *nb_header)
{
    VDASSERT_FN("VDpdmChangeNbNameToNbHeader");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar *p;
    IGRchar buf[DI_PATH_MAX];

    VDASSERTW(*NbName != 0);
    VDASSERTW(nb_header); *nb_header = 0;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // set it up
    strcpy(buf,NbName);

    while (p = strchr(buf,':')) {
	*p = 0;
	strcpy(buf,p+1);
    }
    strcpy(nb_header,buf);

    if (*nb_header == 0) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

    

/* ----------------------------------------
 * Post notebook for file key
 */
IGRstat VDpdmPostNbForFile( VDosnum    osnum,
                            IGRint     key )
{
    VDASSERT_FN("VDpdmPostNbForFile");
    
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar NbPath[DI_PATH_MAX],
            NbName[DI_PATH_MAX],
	    NbText[32768];
    IGRchar nb_header[DI_PATH_MAX];
    IGRint  i, NbCnt;


    VDASSERTW(key > 0);
    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // get the notebook path
    VDpdmGetNbPathOS( osnum, NbPath );
    if (*NbPath == 0) goto wrapup;

    // list the headers, loop through
    di$start_find( start_dir = NbPath,
                   ptr       = &NbCnt );

    for (i = 0; i < NbCnt; i++) {
        
	*NbName = 0;
	di$fetch_find(index = i, line = NbName);

	if (*NbName) {
	    *NbText = 0;
	    VDnbGetTextFromPath( NbName, 32768, NbText );

	    if (*NbText) {
	        sts = VDpdmChangeNbNameToNbHeader(NbName,nb_header);
		if (!(sts & 1)) goto wrapup;
		
		sts = VDpdmPostNbText( key, nb_header, NbText );
		if (!(sts & 1)) goto wrapup;
	    }

	}
     }

     // done
     retFlag = 1;

wrapup:
     if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
     return retFlag;
}

/* ----------------------------------------
 * Check to see if the file is available for posting.
 * File can only be posted if it is retrieved for design
 * or if it is checked out
 **/
static IGRstat isFileOutForPosting( IGRint filekey )
{
    VDASSERT_FN("isFileOutForPosting");
    IGRstat retFlag = 0;
    IGRstat sts;

    VDASSERTW(filekey > 0);

    // must be a pdm function that will tell me this, use it

wrapup:
    return 1;
}
    
/* -----------------------------------------
 * Post Notebook to database
 */
IGRstat VDpdmPostNb( VDosnum  cur_os )
{
    VDASSERT_FN("VDpdmPostNb");
    
    IGRstat    retFlag = 0;
    IGRstat    sts;
    IGRint     filekey;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    filekey   = 0;

    // Does the table exist
    if ( VdsVerifyRisTable (VDPDM_NB_TABLE_NAME)  != VDS_DBTABLE_FOUND )
        goto wrapup;

    // do it
    sts = VDpdmGetFilekeyForOS(cur_os, &filekey);
    if ( (!(sts & 1)) || (filekey < 1) ) goto wrapup;

    sts = isFileOutForPosting( filekey );
    if (!(sts & 1)) goto wrapup;

    sts = VDpdmPostNbForFile( cur_os, filekey );
    if (!(sts & 1)) goto wrapup;

    VDpdmPostTableTimestamp(VDPDM_NB_TABLE_NAME);

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

//end implementation Root;

    
