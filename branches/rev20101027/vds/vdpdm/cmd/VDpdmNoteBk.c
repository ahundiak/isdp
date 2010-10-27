 /* $Id: VDpdmNoteBk.c,v 1.6 2002/02/28 16:13:27 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmNoteBk.c
 *
 * Description: Notebooks from database browser
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/03/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmNoteBk.c");

static TVDpdmClass class;
static Form        s_form;
static IGRchar     s_filename[128];
static VDosnum     s_osnum;

		
/* -----------------------------------
 * Header was selected
 * */
static IGRstat notifyHeader()
{
    VDASSERT_FN("notifyHeader");

    IGRstat retFlag = 0;
    IGRstat sts;
    
    IGRchar buf     [128];
    IGRchar header  [80],
            blobkey [80],
	    filekey [80],
	    filename[256],
	    filenamx[256];
    IGRchar nbText[32768];

    IGRint  row, bkey, fkey, i, sel;

    FILE  *file = NULL;
    TGRid  nbID;


    // Arg check
    VDASSERTW(s_form);

    *header  = 0;
    *blobkey = 0;
    *filekey = 0;
    *filename = 0;
    *filenamx = 0;
    nbID.objid = NULL_OBJID;

    // get the selected record
    VDfrmGetActiveRow(s_form,VDPDM_NOTEBK_F_HEADERS,&row,NULL);

    // is it selected
    VDfrmGetSelect(s_form,VDPDM_NOTEBK_F_HEADERS,row,0,&sel);
    if (!sel) goto wrapup;

    // need blob_key, header, and filekey to get the blobfile
    VDfrmGetgText(s_form,VDPDM_NOTEBK_G_FILEKEY,filekey);
    if (*filekey == 0) goto wrapup;
    fkey = atoi(filekey);

    VDfrmGetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,VDPDM_NOTEBK_COLI_HDR_TITLE,header);
    if (*header == 0) goto wrapup;

    VDfrmGetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,VDPDM_NOTEBK_COLI_HDR_BLOB,blobkey);
    if (*blobkey == 0) goto wrapup;

    // get the file
    VDpdmGetValidFilename(header,fkey,filenamx,0);
    if (*filenamx == 0) goto wrapup;
    sprintf(filename,"/usr/tmp/%s",filenamx);
    if (*filename == 0) goto wrapup;

    // depending on the blob key setting, get the file from the database,
    // the doom, or the ems notebook
    if (!strcmp(blobkey,"DOOM")) {
	// get the notebook file from the doom
	sts = VDpdmGetDoomNbObjectByNameOS(s_osnum, header, &nbID);
	if (nbID.objid != NULL_OBJID) {
	    VDdoomSaveFile(0, &nbID, filename);
	}
	else goto wrapup;
    }
    else if (!strcmp(blobkey,"EMS")) {

	sts = VDpdmGetNbTextByNameOS(s_osnum, header, nbText);

	if (*nbText) {

	    // the file
	    file = fopen(filename,"wt");
	    if (file == NULL) goto wrapup;

	    // write it
	    fprintf(file,"%s",nbText);

	    fclose(file);
	}
	else goto wrapup;
    }
    else {
	bkey = atoi(blobkey);

	sts = VDrisSelectBlobRecord(bkey,filename,1,1,UI_status);
	if (!(sts & 1)) goto wrapup;
    }
    //printf("### <%d> <%s> <%d>\n",fkey,header,bkey);
    VDlogShowCat(filename);
#if 0

    // open the file
    file = fopen(filename,"rt");
    if (file == NULL) goto wrapup;


    printf("###opened the file\n");

    // diplay it on the form
    // cycle through file and fill the gadget
    //
    
    i = 0;
    while(fgets(buf,sizeof(buf),file)) {

	printf("<<%s>>\n",buf);
	VDfrmSetfText(s_form,VDPDM_NOTEBK_G_VIEW,i,0,buf);
	i++;

    } // end of file
#endif
    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ------------------------------------
 * No data found in the database or DoomNB, fill gadget from
 * the GRnotebook object
 * **/
static void setHeaderGadgetEMS(IGRint filekey)
{
    VDASSERT_FN("setHeaderGadgetEMS");

    IGRstat sts = 0;
    IGRint  i,row;

    IGRchar nbName[128];
    IGRchar nb_header[128];
    IGRchar nbFile[128];

    // arg check
    VDASSERTW(s_form);
    VDASSERTW(filekey > 0);
    VDASSERTW(*s_filename);
    VDASSERTW(s_osnum != OM_K_NOT_AN_OS);

    // init
    *nbName = 0;
    *nbFile = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    if (traceFlag) {
	printf("### s_osnum <%d>\n",s_osnum);
	printf("### s_filename <%s>\n",s_filename);
	printf("### filekey <%d>\n",filekey);
    }

    // loop through
    row = 0;
    for (i = 0; VDpdmGetNthNbNameOS(s_osnum,i,nb_header); i++) {

	// convert the full path name to an actual name
	VDpdmChangeNbNameToNbHeader(nb_header,nbName);

	// generate the filename
	VDpdmGetValidFilename(nbName,filekey,nbFile,0);

	// now fill up the form
	if ( (*nbName) && (*nbFile) ) {

	    VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
		    VDPDM_NOTEBK_COLI_HDR_TITLE,nbName);
	    VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
		    VDPDM_NOTEBK_COLI_HDR_BLOB,"EMS");
	    VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
		    VDPDM_NOTEBK_COLI_HDR_DATE,"NA");
	    VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
		    VDPDM_NOTEBK_COLI_HDR_FILE,nbFile);

	    row++;
	}
    }


wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

/* ------------------------------------
 * No data found in the database, fill gadget from
 * the VDNbDoom object
 * **/
static void setHeaderGadgetDoomNb(IGRint filekey)
{
    VDASSERT_FN("setHeaderGadgetDoomNb");

    IGRstat sts = 0;
    IGRint  i,row;

    TGRid   nbID;
    IGRchar nbName[128];
    IGRchar nbFile[128];

    // arg check
    VDASSERTW(s_form);
    VDASSERTW(filekey > 0);
    if (*s_filename == 0) goto wrapup;
    if (s_osnum == OM_K_NOT_AN_OS) goto wrapup;

    // init
    nbID.objid = NULL_OBJID;
    *nbName = 0;
    *nbFile = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    if (traceFlag) {
	printf("### s_osnum <%d>\n",s_osnum);
	printf("### s_filename <%s>\n",s_filename);
	printf("### filekey <%d>\n",filekey);
    }

    // loop through
    row = 0;
    for (i = 0; VDpdmGetNthDoomNbObjectOS(s_osnum, i, &nbID); i++) {

	if (nbID.objid != NULL_OBJID) {
	    sts = 1;
	    
	    // get the notebook title
	    VDobjGetName(NULL,&nbID,nbName);
	    
	    // generate the filename
	    VDpdmGetValidFilename(nbName,filekey,nbFile,0);

	    // now fill up the form
	    if ( (*nbName) && (*nbFile) ) {

		VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
			VDPDM_NOTEBK_COLI_HDR_TITLE,nbName);
		VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
			VDPDM_NOTEBK_COLI_HDR_BLOB,"DOOM");
		VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
			VDPDM_NOTEBK_COLI_HDR_DATE,"NA");
		VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,row,
			VDPDM_NOTEBK_COLI_HDR_FILE,nbFile);

		row++;
	    }
	}
    }

    if (!(sts & 1)) setHeaderGadgetEMS(filekey);

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

	    
/* -----------------------------------
 * Fill the header gadget
 * **/
static void setHeaderGadget(IGRint filekey)
{
    VDASSERT_FN("setHeaderGadget");

    IGRstat sts;
    IGRint  i,j;

    IGRchar filename[128];

    TVDrisInfo ris;
    
    //init
    VDrisInitInfo( &ris );
    VDASSERTW(filekey > 0);
    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // clear any existing
    VDfrmSetNumRows(s_form,VDPDM_NOTEBK_F_HEADERS,0);

    // get the headers from the database
    sts = VDpdmGetNbDataFromDatabase(filekey, &ris);

    // if not found, try the dooms
    if ( (!(sts & 1)) || (ris.rows < 1) ) {
	setHeaderGadgetDoomNb(filekey);
	goto wrapup;
    }

    VDfrmSetgText(s_form,VDPDM_NOTEBK_STATUS,"Notebook Data From Database Found");

    // set it on the form
    for (i = 0; i < ris.rows; i++) {
	j = i * ris.cols;

	VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,i,
		VDPDM_NOTEBK_COLI_HDR_TITLE,ris.buf[j+VDPDM_NB_COLI_NB_HEADER]);
	VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,i,
		VDPDM_NOTEBK_COLI_HDR_BLOB,ris.buf[j+VDPDM_NB_COLI_BLOB_KEY]);
	VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,i,
		VDPDM_NOTEBK_COLI_HDR_DATE,ris.buf[j+VDPDM_NB_COLI_POST_DATE]);
	sts = 
	   VDpdmGetValidFilename(ris.buf[j+VDPDM_NB_COLI_NB_HEADER], filekey, filename,0);
	//sprintf(filename,"%c_%s_%d.txt",*ris.buf[j],ris.buf[j+1],filekey);
	if (sts & 1) VDfrmSetfText(s_form,VDPDM_NOTEBK_F_HEADERS,i,
		                          VDPDM_NOTEBK_COLI_HDR_FILE,filename);
	
    }

    // done
wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

/* -----------------------------------
 * Get the filekey based on part,catalog, and rev
 *      - AND / OR - 
 * Key in the fileKey.
 * Regardless, once the filekey has been established, need
 * to fill up the rest of the form
 * ***/
static IGRstat notifyFileKey()
{
    VDASSERT_FN("notifyFileKey");

    IGRstat  retFlag = 0;
    IGRstat  sts;

    IGRchar  catalog[64],
             part   [64],
	     rev    [64],
	     fileKey[64];
    IGRint   i,fkey;

    // init
    catalog[0] = '\0';
    part[0]    = '\0';
    rev[0]     = '\0';
    fileKey[0] = '\0';

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // fileKey was keyed in, get it
    VDfrmGetgText( s_form, VDPDM_NOTEBK_G_FILEKEY, fileKey);

    if (fileKey[0] != '\0') {
	fkey = atoi(fileKey);
	sts = VDpdmGetCPRForFilekey(&fkey, catalog, part, rev);
	if (sts) {
	    VDfrmSetgText(s_form, VDPDM_NOTEBK_L_CATALOG, catalog);
	    VDfrmSetgText(s_form, VDPDM_NOTEBK_L_PART,    part);
	    VDfrmSetgText(s_form, VDPDM_NOTEBK_L_REVISION,     rev);
	}
    }

    if (fileKey[0] == '\0') {
	// get it from catalog, part, rev
	VDfrmGetgText(s_form, VDPDM_NOTEBK_L_CATALOG, catalog);
	if (catalog[0] == '\0') goto wrapup;

	VDfrmGetgText(s_form, VDPDM_NOTEBK_L_PART, part);
	if (part[0] == '\0') goto wrapup;

	VDfrmGetgText(s_form, VDPDM_NOTEBK_L_REVISION, rev);
	if (rev[0] == '\0') goto wrapup;
	
	// get the filekey
	VDpdmGetFileKeyForCPR(catalog, part, rev, &fkey);
	if (fkey == 0) goto wrapup;

	// set fileKey for form
	sprintf(fileKey,"%d",fkey);
    }

    // better have a fileKey now
    if (fileKey[0] == '\0') goto wrapup;

    // display it on the form
    VDfrmSetgText( s_form, VDPDM_NOTEBK_G_FILEKEY, fileKey );

    // set the headers and blob_key gadget
    setHeaderGadget( fkey );

    // set the purpose info
    //setPurposeInfo( form, &fkey );

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------
 * Active or Local file was selected
 * **/
static IGRstat notifyActive()
{
    VDASSERT_FN("notifyActive");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar filekey [80];

    IGRint  row,sel;

    VDASSERTW(s_form);
    *filekey = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the selected record
    VDfrmGetActiveRow(s_form,VDPDM_NOTEBK_F_ACTIVE,&row,NULL);

    // is it selected
    VDfrmGetSelect(s_form,VDPDM_NOTEBK_F_ACTIVE,row,0,&sel);
    if (!sel) goto wrapup;

    // get the filekey from the selected file
    VDfrmGetfText(s_form,VDPDM_NOTEBK_F_ACTIVE,row,
	          VDPDM_NOTEBK_COLI_ACT_FILEKEY,filekey);
    if (*filekey == 0) goto wrapup;

    // set the static s_filename
    VDfrmGetfText(s_form,VDPDM_NOTEBK_F_ACTIVE,row,
	          VDPDM_NOTEBK_COLI_ACT_FILENAME,s_filename);
    if (*s_filename == 0) goto wrapup;

    // set the static s_osnum
    VDosGetFileNameOS(s_filename, &s_osnum);
    if (s_osnum == OM_K_NOT_AN_OS) goto wrapup;

    // set the filekey on the form
    VDfrmSetgText(s_form,VDPDM_NOTEBK_G_FILEKEY,filekey);

    // notify filekey
    notifyFileKey();

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* ------------------------------------
 * Get revisions based on part and catalog
 * ***/
static IGRstat notifyRev()
{
    VDASSERT_FN("notifyRev");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar catalog[64],
            part   [64];


    // init
    catalog[0] = '\0';
    part[0]    = '\0';

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the catalog and part
    VDfrmGetgText( s_form, VDPDM_NOTEBK_L_CATALOG, catalog);
    if (catalog[0] == '\0') goto wrapup;
    
    VDfrmGetgText( s_form, VDPDM_NOTEBK_L_PART, part );
    if (part[0] == '\0') goto wrapup;

    // Query for revisions
    sts = VDpdmFillGadgetRev( s_form, VDPDM_NOTEBK_L_REVISION, catalog, part );
    if (!(sts & 1)) goto wrapup;

    // tell the user what to do
    VDfrmSetgText( s_form, VDPDM_NOTEBK_STATUS, "Select Revision" );

    // clear, then notify file key
    VDfrmSetgText( s_form, VDPDM_NOTEBK_G_FILEKEY, "");
    notifyFileKey();
    
    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* -------------------------------------
 * Get parts based on catalog selected
 * ***/
static IGRstat notifyPart()
{
    VDASSERT_FN("notifyPart");

    IGRstat    retFlag = 0;
    IGRstat    sts;
    IGRchar    catalog[64];
    
    // init
    catalog[0] = '\0';

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the catalog
    VDfrmGetgText( s_form, VDPDM_NOTEBK_L_CATALOG, catalog );
    if (catalog[0] == '\0') goto wrapup;

    // query for parts
    sts = VDpdmFillGadgetPart( s_form, VDPDM_NOTEBK_L_PART, catalog );
    if (!(sts & 1)) goto wrapup;
    
    // tell the user what to do
    VDfrmSetgText( s_form, VDPDM_NOTEBK_STATUS, "Select Part" );

    // notify rev
    notifyRev();
    
    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* --------------------------------------
 * Get catalogs based on classifications selected
 * **/
static IGRstat notifyCatalog()
{
    VDASSERT_FN("notifyCatalog");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar     catalog[80];
    
    // init
    catalog[0] = '\0';

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // see if catalog was just keyed in
    VDfrmGetgText( s_form, VDPDM_NOTEBK_L_CATALOG, catalog );
    if (catalog[0] != '\0') {
	notifyPart();
	retFlag = 1;
	goto wrapup;
    }

    // fill the gadget
    sts = VDpdmFillGadgetCatalog( s_form, VDPDM_NOTEBK_L_CATALOG, &class );
    if (!(sts & 1)) goto wrapup;
    
    // notify part
    notifyPart();

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------------
 * remove the local files
 * **/
static void removeLocalFiles()
{
    VDASSERT_FN("removeLocalFiles");

    IGRchar cmd[256];


    sprintf(cmd,"rm /usr/tmp/%s 2> /dev/null","*.nb");
    system(cmd);

    // done

wrapup:
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

    VDosnum  cur_os = OM_K_NOT_AN_OS;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    VDASSERTW(s_form);

    // switch on gadget
    switch(g_label) {

      case FI_RESET:
	  VDpdmFillMCFActiveFile( s_form, VDPDM_NOTEBK_F_ACTIVE, 
               VDPDM_NOTEBK_COLI_ACT_FILENAME ,VDPDM_NOTEBK_COLI_ACT_FILEKEY );
	  // hide a couple of buttons that aren't used at this time
	  VIg_erase(s_form,VDPDM_NOTEBK_B_EDIT);
	  VIg_erase(s_form,VDPDM_NOTEBK_B_ADD_TITLE);
	  VIg_erase(s_form,VDPDM_NOTEBK_B_POST);

	  break;
      
      case FI_ACCEPT:
      case FI_CANCEL:
	  removeLocalFiles();
	  VDpdmKillNoteBkForm();
	  break;

      //case FI_EXECUTE:
	  //sts = notifyDoit(form);
	  //break;

      case VDPDM_NOTEBK_B_CLASS:
	  sts = VDpdmCmdGetClassLevels(&class);
	  VDpdmClearGadgetList(s_form,VDPDM_NOTEBK_L_CATALOG);
	  VDpdmClearGadgetList(s_form,VDPDM_NOTEBK_L_PART);
	  VDpdmClearGadgetList(s_form,VDPDM_NOTEBK_L_REVISION);
	  VDfrmSetgText( s_form,VDPDM_NOTEBK_G_FILEKEY,"");
	  notifyCatalog();
	  break;

      case VDPDM_NOTEBK_L_CATALOG:
	  VDpdmClearGadgetList(s_form,VDPDM_NOTEBK_L_PART);
	  VDpdmClearGadgetList(s_form,VDPDM_NOTEBK_L_REVISION);
	  VDfrmSetgText( s_form,VDPDM_NOTEBK_G_FILEKEY,"");
	  sts = notifyCatalog();
	  break;

      case VDPDM_NOTEBK_L_PART:
	  VDpdmClearGadgetList(s_form,VDPDM_NOTEBK_L_REVISION);
	  VDfrmSetgText( s_form,VDPDM_NOTEBK_G_FILEKEY,"");
	  sts = notifyPart();
	  break;

      case VDPDM_NOTEBK_L_REVISION:
	  VDfrmSetgText( s_form,VDPDM_NOTEBK_G_FILEKEY,"");
	  sts = notifyRev();
	  break;

      case VDPDM_NOTEBK_G_FILEKEY:
	  sts = notifyFileKey();
	  break;

      case VDPDM_NOTEBK_F_HEADERS:
	  sts = notifyHeader();
	  break;

      case VDPDM_NOTEBK_F_ACTIVE:
	  sts = notifyActive();
	  break;

      case VDPDM_NOTEBK_B_POST:
	  // This button is disengaged due to the new notebook database command.
#if 0
	  VDosGetCurrentOS(&cur_os);
	  sts = VDpdmPostNb(cur_os);
	  if (!(sts & 1)) {
	      VDfrmSetgText(s_form,VDPDM_NOTEBK_STATUS,"Notebooks not posted");
	      goto wrapup;
	  }
	  else VDfrmSetgText(s_form,VDPDM_NOTEBK_STATUS,"Notebook for Checked Out file posted");
#endif
	 break;


    }

wrapup:
    return retFlag;
}

/* ---------------------------------------------
 * Called by the Main form gadget.
 * ***/
IGRstat VDpdmInitNoteBk()
{
    VDASSERT_FN("VDpdmInitNoteBk");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    traceFlag = traceFlagx = VDdbgGetTraceFlag(VDPDM_TRACE_NOTEBOOK);

    // should not be called again
    VDASSERTW(!s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // statics
    memset(&class,0,sizeof(TVDpdmClass));
    *s_filename = 0;
    s_osnum     = OM_K_NOT_AN_OS;

    // wakeup the form
    sts = VDfrmNewForm (VDPDM_NOTEBK_F_NUM, VDPDM_NOTEBK_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // set the list of active/local files
    VDpdmFillMCFActiveFile( s_form, VDPDM_NOTEBK_F_ACTIVE, 
               VDPDM_NOTEBK_COLI_ACT_FILENAME ,VDPDM_NOTEBK_COLI_ACT_FILEKEY );

    if (traceFlag) printf("### Hide some buttons\n");

    // hide a couple of buttons that aren't used at this time
    VIg_erase(s_form,VDPDM_NOTEBK_B_EDIT);
    VIg_erase(s_form,VDPDM_NOTEBK_B_ADD_TITLE);
    VIg_erase(s_form,VDPDM_NOTEBK_B_POST);


wrapup:
    return 0;

}

/* -----------------------------------
 * Form Killer
 * **/
IGRstat VDpdmKillNoteBkForm()
{
    VDASSERT_FN("VDpdmKillNoteBkForm");

    if (s_form) {
	VDfrmDeleteForm( s_form, 1);
	s_form = NULL;
    }

wrapup:
    return 1;
}
