 /* $Id: VDpdmDbNb.C,v 1.2 2002/02/28 16:13:25 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmDbNb.c
 *
 * Description: Notebooks from database browser
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDpdmDbNb.C,v $
 * Revision 1.2  2002/02/28 16:13:25  jdsauby
 * TR 6059 and 6053
 *
 * Revision 1.1  2001/10/03 13:52:12  jdsauby
 * JTS MP CR5448, Database Notebooks
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/03/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedef.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDDbDef.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include <sys/stat.h>

VDASSERT_FFN("vdpdm/cmd/VDpdmDbNb.c");

static Form        s_form;
static TVDpdmInfo  s_pdmInfo;
static IGRstat     loop;
static VDosnum     s_osnum;
static IGRchar     previously_posted[24];

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* ----------------------------------------------
 * Add title button was pushed, this will pop up the
 * VDpdmNbTitle.F subform
 * **/
static IGRstat notifyAddTitle()
{
    VDASSERT_FN("notifyAddTitle");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar header[256];
    IGRchar filename[256];
    IGRchar filenamx[256];
    IGRint  rows;

    struct stat f_stat;
    IGRchar ftime[40];

    IGRchar cmd[256];

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // pop up form for title
    *header = 0;
    sts = VDpdmDbNbAddTitle(header);
    if (*header == 0) goto wrapup;

    // get a valid filename
    VDpdmGetValidFilename(header, s_pdmInfo.filekey, filenamx, 1);
    if (*filenamx == 0) goto wrapup;

    // filename for this is in the local directory
    sprintf(filename,"./%s",filenamx);

    // create the file
    sprintf(cmd,"touch %s",filename);
    sts = system( cmd );
    if (sts < 0) goto wrapup;

    // put it on the form
    VDfrmGetNumRows(s_form,VDPDM_DBNB_MCF_NB_INFO,&rows,NULL,NULL);
    if (rows < 1) goto wrapup; 

    //rows++;

    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,rows,
	    VDPDM_DBNB_MCF_COL_TITLE,header);
    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,rows,
	    VDPDM_DBNB_MCF_COL_TEXT_FILE,filename);
    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,rows,
	    VDPDM_DBNB_MCF_COL_POST_DATE,"NA");
    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,rows,
	    VDPDM_DBNB_MCF_COL_BLOB_KEY,"0");
    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,rows,
	    VDPDM_DBNB_MCF_COL_NB_INC,"0");
    stat(filename,&f_stat);
    sprintf(ftime,"%d",f_stat.st_ctime);
    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,rows,
	    VDPDM_DBNB_MCF_COL_F_TIME,ftime);

    // bring it up so that it can be edited
    UI_status("Close Editor When Finished Editing");
    VDlogShowCat( filename );

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -----------------------------------------------------
 * Make the decision to post, delete, or just unlock
 * a notebook, and do it
 * **/
static IGRstat postNbHeader(IGRchar *header,
	                    IGRchar *filename,
			    IGRchar *post_date,
			    IGRint  filetime,
			    IGRint  blob_key)
{
    VDASSERT_FN("postNbHeader");
    IGRstat retFlag = 0;
    IGRstat sts;
    TGRid   nbID;

    IGRchar cmd[256], sql[256];

    struct stat f_stat;

    VDASSERTW(*header != 0);
    VDASSERTW(*filename != 0);
    VDASSERTW(*post_date != 0);
    VDASSERTW(filetime > 0);
    VDASSERTW(s_pdmInfo.filekey > 0);

    nbID.objid = NULL_OBJID;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    //if file has changed, update and post, otherwise, just delete it.
    stat(filename,&f_stat);

    
    if ( (!strcmp(post_date,"DELETE")) && (blob_key > 0) ) {
	// title has been marked for delete, so delete it from the db
	// unfortunately, It cannot be removed from the EMS notebook as well
	// that requires use of the command interface to GRNtBk

	// remove the blob notebook record
	VDrisDeleteBlobRecord(blob_key,UI_status);

	// remove the index
	sprintf(sql,"Delete from %s where %s=%d;",
		VDPDM_NB_TABLE_NAME, 
		VDPDM_NB_COLN_BLOB_KEY, blob_key);

	VDrisExecute( sql );

	// remove the doomNb
	VDpdmGetDoomNbObjectByNameOS(s_osnum,header,&nbID);
	if (nbID.objid != NULL_OBJID) {
	    gr$delete_object(msg          = &sts,
		             object_id    = &nbID,
			     display_flag = 0 );
	}

	// remove the file
	sprintf(cmd,"rm %s 2> /dev/null",filename);
	system( cmd );
    }
    else if ( (f_stat.st_mtime > filetime) || (!strcmp(previously_posted,"NO")) ) {
	// file has changed or not previously_posted, so post it.

	// update the notebook buffer
	sts = VDpdmUpdateNbBuffer(s_osnum, header, filename);
	if (!(sts & 1)) goto wrapup;

	// post it
	sts = VDpdmPostNbFile(s_pdmInfo.filekey, header, filename);
	if (!(sts & 1)) goto wrapup;
    }
    else {
	// nothing has changed with this nb header (title), just pretend it was posted

	// set the nb_inc to 0
	sprintf(sql,
		    "Update %s set %s=0 where %s=%d and %s='%s';",
		    VDPDM_NB_TABLE_NAME,
		    VDPDM_NB_COLN_NB_INC, 
		    VDPDM_NB_COLN_FILE_KEY, s_pdmInfo.filekey,
		    VDPDM_NB_COLN_NB_HEADER, header );

	VDrisExecute( sql );

	// and remove the file
	sprintf(cmd,"rm %s 2> /dev/null",filename);
	system( cmd );
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------
 * do it = post it
 * **/
static IGRstat notifyDoit()
{
    VDASSERT_FN("notifyDoit");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar   header  [256],
	      filename[256],
	      post_date[256],
	      filetime[256],
	      blobKey[256],
	      cmd     [256];

    IGRint    rows, i, ftime, blob_key;

    ftime = 0;
    blob_key = 0;

    VDASSERTW(s_pdmInfo.filekey > 0);
    VDASSERTW(s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // tell the user it came from the db
    VDfrmSetgText(s_form,VDPDM_DBNB_STATUS,"Updating Database Records");
    UI_status("Updating Database Records");

    // process each row on the form
    VDfrmGetNumRows(s_form,VDPDM_DBNB_MCF_NB_INFO,&rows,NULL,NULL);
    if (rows < 1) goto wrapup;

    retFlag = 1;
    for (i = 0; i < rows; i++) {
	
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_TITLE,header);
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_TEXT_FILE,filename);
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_POST_DATE,post_date);
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_BLOB_KEY,blobKey);
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_F_TIME,filetime);
	if (strcmp(filetime,"NULL")) ftime = atoi(filetime);
	if (*blobKey != 0)           blob_key = atoi(blobKey);

	if ( (*header != 0) && (*filename != 0) && (strcmp(filename,"NULL")) ) {

	    // post it, delete it, or unlock it
	    sts = postNbHeader(header,filename,post_date,ftime,blob_key);
	    if (!(sts & 1)) retFlag = 0;

	}
    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
		
/* -----------------------------------
 * Header was selected
 * */
static IGRstat notifyNbInfo()
{
    VDASSERT_FN("notifyNbInfo");

    IGRstat retFlag = 0;
    IGRstat sts;
    
    IGRchar filename [256],
	    header   [80];

    IGRint  row, sel, dlete;

    // Arg check
    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    *header    = 0;
    *filename  = 0;

    VDfrmGetState(s_form,VDPDM_DBNB_B_DEL_TITLE,&dlete);

    // get the selected record
    VDfrmGetActiveRow(s_form,VDPDM_DBNB_MCF_NB_INFO,&row,NULL);

    // is it selected
    VDfrmGetSelect(s_form,VDPDM_DBNB_MCF_NB_INFO,row,0,&sel);
    if (!sel) goto wrapup;

    if (dlete) {
	VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,VDPDM_DBNB_MCF_COL_POST_DATE,"DELETE");
	VDfrmSetgText(s_form,VDPDM_DBNB_STATUS,"Select Something");
	retFlag = 1;
	goto wrapup;
    }

    else {

	// display data integrity message to user if applicable

	// first, need the header
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,VDPDM_DBNB_MCF_COL_TITLE,header);
	if (*header == 0) goto wrapup;

	if ( VDpdmNbIsDbChanged(s_pdmInfo.filekey,header) ) {

	    if (!strcmp(previously_posted,"NO")) {
		EX_error_box(FI_CURRENT_SCREEN,"Please merge DB Notebook into local copy","Data Discrepancy");
	    }
	    else  {
		EX_error_box(FI_CURRENT_SCREEN,"DB Notebook has been merged into local copy","Database Has Changed");
	    }
	}

	// need filename
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,VDPDM_DBNB_MCF_COL_TEXT_FILE,filename);
	if (*filename == 0) goto wrapup;

	//printf("### <%d> <%s> <%d>\n",fkey,header,bkey);
	UI_status("Close Editor When Finished Editing");
	VDlogShowCat(filename);
	VDfrmSetgText(s_form,VDPDM_DBNB_STATUS,"Select Something");

	// done
	retFlag = 1;
    }

    // should not get to here
    

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------
 * Restores the vdpdm_notebook, nb_inc column to it's
 * original unlocked value.
 * **/
static void restoreNbDbTable()
{
    VDASSERT_FN("restoreNbDbTable");

    IGRstat   sts;
    IGRchar   header [80],
	      nbinc  [80],
	      filenm [256],
	      cmd    [256],
	      sql    [256];

    IGRint    rows, i;

    VDASSERTW(s_pdmInfo.filekey > 0);
    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // process each row on the form
    VDfrmGetNumRows(s_form,VDPDM_DBNB_MCF_NB_INFO,&rows,NULL,NULL);
    if (rows < 1) goto wrapup;

    for (i = 0; i < rows; i++) {
	
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_TITLE,header);
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_NB_INC,nbinc);
	VDfrmGetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		             VDPDM_DBNB_MCF_COL_TEXT_FILE,filenm);

	if ( (*header != 0) && (*nbinc != 0) &&
	     (VDpdmVerifyLogin()) &&
	     (VdsVerifyRisTable( VDPDM_NB_TABLE_NAME ) == VDS_DBTABLE_FOUND) ) {

	    sprintf(sql,
		    "Update %s set %s=%d where %s=%d and %s='%s';",
		    VDPDM_NB_TABLE_NAME,
		    VDPDM_NB_COLN_NB_INC, atoi(nbinc),
		    VDPDM_NB_COLN_FILE_KEY, s_pdmInfo.filekey,
		    VDPDM_NB_COLN_NB_HEADER, header );

	    VDrisExecute( sql );
	}

	if ( (*filenm != 0) && (strcmp(filenm,"NULL")) ) {
	    sprintf(cmd,"rm %s 2> /dev/null",filenm);
	    system( cmd );
	}
    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

/* -------------------------------------------------
 * Set the nb_inc column in the table vdpdm_notebook to 2
 * 2 identifies this notebook a out.
 * **/
static void lockNbDbTable()
{
    VDASSERT_FN("lockNbDbTable");

    IGRchar sql[256];
    
    VDASSERTW(s_pdmInfo.filekey > 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // logged in
    if (!VDpdmVerifyLogin()) goto wrapup;

    // does the table exist
    if ( VdsVerifyRisTable( VDPDM_NB_TABLE_NAME ) != VDS_DBTABLE_FOUND ) goto wrapup;
    

    // build the sql
    sprintf(sql,
	    "Update %s set %s=2 where %s=%d;",
	    VDPDM_NB_TABLE_NAME, VDPDM_NB_COLN_NB_INC,
	    VDPDM_NB_COLN_FILE_KEY, s_pdmInfo.filekey );

    // do it
    VDrisExecute( sql );

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

/* -----------------------------------
 * fill the header gadget from the doom NB object
 * **/
static void fillDbNbFormFromDoomNb()
{
    VDASSERT_FN("fillDbNbFormFromDoomNb");
    IGRstat sts;

    IGRint i,row;
    TGRid  nbID;
    IGRchar nbTitle[DI_PATH_MAX];
    IGRchar filename[DI_PATH_MAX];
    IGRchar filenamx[DI_PATH_MAX];
    IGRchar ftime[DI_PATH_MAX];
    struct stat f_stat;

    // arg check
    VDASSERTW(s_form);
    nbID.objid = NULL_OBJID;
    *nbTitle   = 0;
    *filename  = 0;
    *filenamx  = 0;

    // say hit
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // if we are here, can not post, so disable FI_ACCEPT
    //VIg_disable(s_form,FI_ACCEPT);

    // put the doom stuff on the form
    row = 0;
    for (i = 0; VDpdmGetNthDoomNbObjectOS(s_osnum, i, &nbID); i++) {
	
	if (nbID.objid != NULL_OBJID) {

	    // get the notebook title
	    VDobjGetName(NULL,&nbID,nbTitle);
	    
	    // generate the filename
	    VDpdmGetValidFilename(nbTitle,s_pdmInfo.filekey,filenamx,0);
            if (*filenamx != 0) sprintf(filename,"./%s",filenamx);

	    // create the file
	    sts = VDdoomSaveFile(0, &nbID, filename);

	    // now fill up the form
	    if ( (*nbTitle) && (*filename) && (sts & 1) ) {
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,
			VDPDM_DBNB_MCF_COL_TITLE,nbTitle);
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,
			VDPDM_DBNB_MCF_COL_TEXT_FILE,filename);
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,
			VDPDM_DBNB_MCF_COL_POST_DATE,"NA");
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,
			VDPDM_DBNB_MCF_COL_BLOB_KEY,"NULL");
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,
			VDPDM_DBNB_MCF_COL_NB_INC,"0");
		stat(filename,&f_stat);
		sprintf(ftime,"%d",f_stat.st_ctime);
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,row,
			VDPDM_DBNB_MCF_COL_F_TIME,ftime);

		row++;
	    }
	}
    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}
    
/* -----------------------------------
 * Fill the header gadget from the database
 * **/
static void fillDbNbFormFromDb()
{
    VDASSERT_FN("fillDbNbFormFromDb");

    IGRstat sts;
    IGRint  i,j,bkey;

    IGRchar filename[128];
    IGRchar filenamx[128];
    IGRchar ftime   [40];

    struct stat f_stat;

    TVDrisInfo ris;
    
    //init
    VDrisInitInfo( &ris );
    VDASSERTW(s_form);

    *filename = 0;
    *filenamx = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the notebook stuff from the database
    sts = VDpdmGetNbDataFromDatabase(s_pdmInfo.filekey, &ris);
    if ( (!(sts & 1)) || (ris.rows < 1) ) {
	fillDbNbFormFromDoomNb();
	goto wrapup;
    }

    // tell the user it came from the db
    VDfrmSetgText(s_form,VDPDM_DBNB_STATUS,"Getting Notebook From Database");
    UI_status("Notebook Info From Database");
    
    
    // set it on the form
    for (i = 0; i < ris.rows; i++) {
	j = i * ris.cols;

	VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		VDPDM_DBNB_MCF_COL_TITLE,ris.buf[j+VDPDM_NB_COLI_NB_HEADER]);
	VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		VDPDM_DBNB_MCF_COL_BLOB_KEY,ris.buf[j+VDPDM_NB_COLI_BLOB_KEY]);
	bkey = atoi(ris.buf[j+VDPDM_NB_COLI_BLOB_KEY]);
	VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		VDPDM_DBNB_MCF_COL_POST_DATE,ris.buf[j+VDPDM_NB_COLI_POST_DATE]);
	
	VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		VDPDM_DBNB_MCF_COL_NB_INC,ris.buf[j+VDPDM_NB_COLI_NB_INC]);

	// get the blob record from the db
	VDpdmGetValidFilename(ris.buf[j+VDPDM_NB_COLI_NB_HEADER],
		                     s_pdmInfo.filekey,filenamx,0);
	if (*filenamx != 0) {
	    sprintf(filename,"./%s",filenamx);

	    // bring down the file
	    sts = VDrisSelectBlobRecord(bkey,filename,1,1,UI_status);
	    if (sts & 1) {
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
			VDPDM_DBNB_MCF_COL_TEXT_FILE,filename);
		stat(filename,&f_stat);
		sprintf(ftime,"%d",f_stat.st_ctime);
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
			VDPDM_DBNB_MCF_COL_F_TIME,ftime);
	    }
	}
	else {
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
			VDPDM_DBNB_MCF_COL_TEXT_FILE,"NULL");
		VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
			VDPDM_DBNB_MCF_COL_F_TIME,"NULL");
	}


    }

    // lock the database table
    lockNbDbTable();

    // done
    UI_status("Notebook Info From Database");
wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

/* ---------------------------------------
 * Convert the NB text buf to a file
 */
static IGRstat convertBufToFile( IGRchar *header,
				 IGRchar *buf,
				 IGRchar *filename )
{
    VDASSERT_FN("convertBufToFile");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar filenamx[128];

    FILE  *file = NULL;

    // Arg Check
    VDASSERTW(*header != 0);
    VDASSERTW(*buf    != 0);
    VDASSERTW(filename);  *filename = 0;
    *filenamx = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // set it up
    VDpdmGetValidFilename(header, s_pdmInfo.filekey, filenamx,0);
    //sprintf(filename,"./%s.%d.nb",header,s_pdmInfo.filekey);
    if (*filenamx == 0) goto wrapup;

    sprintf(filename,"./%s",filenamx);

    // the file
    file = fopen(filename,"wt");
    if (file == NULL) goto wrapup;

    // write it
    fprintf(file,"%s",buf);

    // done
    retFlag = 1;

wrapup:
    if (file) fclose(file);
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------
 * File has not been previously posted, so convert the 
 * Notebook buffer to a text file, and display this info
 * on the form
 * **/
static void fillDbNbFormFromFile()
{
    VDASSERT_FN("fillDbNbFormFromFile");

    IGRstat sts;

    IGRchar NbPath[DI_PATH_MAX],
            NbName[DI_PATH_MAX];
    IGRchar *NbText;
    IGRchar nb_header[DI_PATH_MAX];
    IGRchar filename[DI_PATH_MAX];
    IGRchar ftime[40];
    IGRint  i, NbCnt;

    struct stat f_stat;


    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // tell the user it came from the file
    VDfrmSetgText(s_form,VDPDM_DBNB_STATUS,"Getting Notebook From File");
    UI_status("Notebook Info From File");
    

    for (i = 0; VDpdmGetNthNbNameOS(s_osnum,i,NbName); i++) {

	NbText = malloc(32768 * sizeof(IGRchar));
	VDnbGetTextFromPath( NbName, 32768, NbText );

	if (*NbText) {
	    sts = VDpdmChangeNbNameToNbHeader(NbName,nb_header);
	    if (!(sts & 1)) goto wrapup;

	    sts = convertBufToFile( nb_header, NbText, filename );
	    if (!(sts & 1)) goto wrapup;

	    // display on form
	    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		    VDPDM_DBNB_MCF_COL_TITLE,nb_header);
	    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		    VDPDM_DBNB_MCF_COL_TEXT_FILE,filename);
	    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		    VDPDM_DBNB_MCF_COL_POST_DATE,"NA");
	    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		    VDPDM_DBNB_MCF_COL_BLOB_KEY,"NULL");
	    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		    VDPDM_DBNB_MCF_COL_NB_INC,"0");
	    stat(filename,&f_stat);
	    sprintf(ftime,"%d",f_stat.st_ctime);
	    VDfrmSetfText(s_form,VDPDM_DBNB_MCF_NB_INFO,i,
		    VDPDM_DBNB_MCF_COL_F_TIME,ftime);
	    free(NbText);
	}

    }

     // done
    UI_status("Notebook Info From File");

wrapup:
     if (NbText) free(NbText);
     if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
     return;
}



/* -------------------------------------------
 * See if the part is checked out
 * **/
static IGRstat isPartCheckedOut()
{
    VDASSERT_FN("isPartCheckedOut");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  catno   = 0;
    IGRint  itemno  = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // logged in?
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;

    // get the catalog number
    VDpdmGetCatalogNo(s_pdmInfo.catalog, &catno);
    if (catno < 1) goto wrapup;

    // get the item number
    VDpdmGetItemNo(&s_pdmInfo, &itemno);
    if (itemno < 1) goto wrapup;

    // finally, is it checked out
    retFlag = VDpdmIsPartCheckedOut(&s_pdmInfo,catno,itemno);

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------
 * fill up the form with data, set some gadgets
 * **/
static void fillDbNbForm()
{
    VDASSERT_FN("fillDbNbForm");


    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    *previously_posted = 0;

    // is part checked out?
    if (!isPartCheckedOut()) {
	VIg_disable(s_form,FI_ACCEPT);
    }
    else VIg_enable(s_form,FI_ACCEPT);

    // get vddbnb_posted status
    VDpdmGetVddbNbPosted(s_osnum,previously_posted);
    if (!strcmp(previously_posted,"YES")) {
	fillDbNbFormFromDb();
    }
    else {
	fillDbNbFormFromFile();
    }
   
    // Select Something
    VDfrmSetgText(s_form,VDPDM_DBNB_STATUS,"Select Something");


wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

/* ----------------------------------------
 * form notification routine
 * ***/
static IGRint notifyForm(IGRint      f_label,
	                 IGRint      g_label,
			 IGRdouble   value,
			 Form        form)
{
    VDASSERT_FN("notifyForm");

    IGRstat retFlag = 1;
    IGRstat sts;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    VDASSERTW(s_form);

    // switch on gadget
    switch(g_label) {

      case FI_RESET:
	  fillDbNbForm();
	  break;

      case FI_CANCEL:
	  //VDpdmUpdateVddbNbPosted(s_osnum,"NO");
	  restoreNbDbTable();
	  VDpdmKillDbNbForm();
	  break;

      case FI_ACCEPT:
	  sts = notifyDoit();
	  if (sts & 1) {
	      VDpdmUpdateVddbNbPosted(s_osnum,"YES");
	      VDpdmKillDbNbForm();
	  }
	  break;
      
      case VDPDM_DBNB_MCF_NB_INFO:
	  notifyNbInfo();
	  break;

      case VDPDM_DBNB_B_BROWSE_DB:
	  VDpdmInitNoteBk();
	  break;

      case VDPDM_DBNB_B_ADD_TITLE:
	  sts = notifyAddTitle();
	  if (!(sts & 1)) {
	      VDfrmSetgText(s_form,VDPDM_DBNB_STATUS,"Title Not Added");
	  }
	  break;

    }

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -----------------------------------------------
 * Loop on events
 */
static void loopDbNbFrom()
{
  VDASSERT_FN("loopDbNbFrom");
  IGRstat sts;

  XEvent event;
  
  // Should not be called recursivily
  VDASSERTW(s_form);
  
  // Loop until form told to break out
  loop = 1;
  while(loop) {
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
  }
  
wrapup:
  return;
}

/* ---------------------------------------------
 * Called by the PPL (COpdmDbNb)
 * ***/
IGRstat VDpdmInitDbNb()
{
    VDASSERT_FN("VDpdmInitDbNb");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;
    VDosnum osnum = OM_K_NOT_AN_OS;

    traceFlag = traceFlagx = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);

    // should not be called again
    VDASSERTW(!s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // statics
    s_osnum = OM_K_NOT_AN_OS;
    VDosGetCurrentOS(&s_osnum);
    if (s_osnum == OM_K_NOT_AN_OS) goto wrapup;

    sts = VDpdmGetPdmInfo( s_osnum, &s_pdmInfo );
    if (s_pdmInfo.filekey < 1) goto wrapup;

    // wakeup the form
    sts = VDfrmNewForm (VDPDM_DBNB_F_NUM, VDPDM_DBNB_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);


    // set the list of active/local files
    fillDbNbForm();

    // loop on events
    loopDbNbFrom();

wrapup:
    return 0;

}

/* -----------------------------------
 * Form Killer
 * **/
IGRstat VDpdmKillDbNbForm()
{
    VDASSERT_FN("VDpdmKillDbNbForm");

    if (s_form) {
	VDfrmDeleteForm( s_form, 1);
	s_form = NULL;
	loop   = 0;
    }

    // kill the browse notebook form
    VDpdmKillNoteBkForm();

wrapup:
    return 1;
}
