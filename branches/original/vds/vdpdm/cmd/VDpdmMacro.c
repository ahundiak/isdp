 /* $Id: VDpdmMacro.c,v 1.4 2002/05/08 14:46:59 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmMacro.c
 *
 * Description: Macros from database browser
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/18/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmMacro.c");

static TVDpdmClass class;
static Form        s_form;

/* ---------------------------------------------
 * Fill the macro libraries gadget
 * **/
static void fillGadgetLibrary(IGRchar  *mac_name)
{
    VDASSERT_FN("fillGadgetLibrary");
    IGRstat sts;

    IGRchar    sql[1024];
    IGRchar    buf[256];
    TVDrisInfo ris;

    VDrisInitInfo( &ris );
    
    VDASSERTW(s_form);

    // clear the gadget first
    VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_LIBRARY);

    // build the query
    sprintf(sql,
	    "Select distinct %s from %s order by %s;", 
	    VDPDM_MACRO_COLN_MACRO_LIB,
	    VDPDM_MACRO_TABLE_NAME, VDPDM_MACRO_COLN_MACRO_LIB );

    // query it
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // fill the gadget
    VDpdmFillGadgetList(s_form,VDPDM_MACRO_L_LIBRARY,&ris);

    // put a library name in the gadget
    if( (mac_name) && (*mac_name) ) {
	VDrisFreeInfo( &ris );
	VDrisInitInfo( &ris );
	sprintf(sql,
		"Select distinct %s from %s where %s='%s';",
		VDPDM_MACRO_COLN_MACRO_LIB, VDPDM_MACRO_TABLE_NAME,
		VDPDM_MACRO_COLN_MACRO_NAME, mac_name );
	VDrisQuery( &ris, sql );
	if (ris.rows < 1) goto wrapup;

	VDfrmSetgText(s_form,VDPDM_MACRO_L_LIBRARY,ris.buf[0]);
    }

    // done
wrapup:
    VDrisFreeInfo( &ris );
    return;
}
    
/* ---------------------------------------------
 * Fill the macro names gadget
 * **/
static void fillGadgetName(IGRchar  *mac_lib)
{
    VDASSERT_FN("fillGadgetName");
    IGRstat sts;

    IGRchar    sql[1024];
    IGRchar    buf[256];
    TVDrisInfo ris;

    VDrisInitInfo( &ris );
    
    VDASSERTW(s_form);

    // clear the gadget first
    VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_NAME);

    // build the query
    sprintf(sql,
	    "Select distinct %s from %s ",
	    VDPDM_MACRO_COLN_MACRO_NAME,
	    VDPDM_MACRO_TABLE_NAME );

    if( (mac_lib) && (*mac_lib) ) {
	sprintf(buf,"where %s='%s' ",
		VDPDM_MACRO_COLN_MACRO_LIB, mac_lib);
	strcat (sql,buf);
    }

    sprintf(buf,"order by %s;",VDPDM_MACRO_COLN_MACRO_NAME);
    strcat (sql,buf);

    // query it
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // fill the gadget
    VDpdmFillGadgetList(s_form,VDPDM_MACRO_L_NAME,&ris);

    // put a macro name in the gadget
    if( (mac_lib) && (*mac_lib) ) {
	VDfrmSetgText(s_form,VDPDM_MACRO_L_NAME,ris.buf[0]);
    }
    

    // done
wrapup:
    VDrisFreeInfo( &ris );
    return;
}


/* ---------------------------------------------
 * Initialize the form settings
 * **/
static void initMacroFormSettings()
{
    VDASSERT_FN("initMacroFormSettings");
    IGRstat sts;

    IGRint  by_part;

    VDASSERTW(s_form);

    // get the macro toggle status
    VDfrmGetState(s_form,VDPDM_MACRO_T_MACRO,&by_part);

    // if by_macro, fill the library and macro fields
    if (!by_part) {

	// disable the local and pdm gadgets
	VIg_disable(s_form,VDPDM_MACRO_B_CLASS);
	VIg_disable(s_form,VDPDM_MACRO_L_CATALOG);
	VIg_disable(s_form,VDPDM_MACRO_L_PART);
	VIg_disable(s_form,VDPDM_MACRO_L_REVISION);
	VIg_disable(s_form,VDPDM_MACRO_G_FILEKEY);
	VIg_disable(s_form,VDPDM_MACRO_F_ACTIVE);

	// enable the library and macro gadgets
	VIg_enable(s_form,VDPDM_MACRO_L_LIBRARY);
	VIg_enable(s_form,VDPDM_MACRO_L_NAME);

	// fill library and name gadgets
	fillGadgetLibrary(NULL);
	fillGadgetName(NULL);

    }

    if (by_part) {

	// disable the library and macro gadgets
	VIg_disable(s_form,VDPDM_MACRO_L_LIBRARY);
	VIg_disable(s_form,VDPDM_MACRO_L_NAME);
	
	// enable the local and pdm gadgets
	VIg_enable(s_form,VDPDM_MACRO_B_CLASS);
	VIg_enable(s_form,VDPDM_MACRO_L_CATALOG);
	VIg_enable(s_form,VDPDM_MACRO_L_PART);
	VIg_enable(s_form,VDPDM_MACRO_L_REVISION);
	VIg_enable(s_form,VDPDM_MACRO_G_FILEKEY);
	VIg_enable(s_form,VDPDM_MACRO_F_ACTIVE);

	// fill the local gadget
	VDpdmFillMCFActiveFile( s_form, VDPDM_MACRO_F_ACTIVE, 
		VDPDM_MACRO_COLI_ACT_FILE ,VDPDM_MACRO_COLI_ACT_KEY );	

    }

    // done

wrapup:
    return;
}

/* ---------------------------------------
 * write out results of query
 * **/
static IGRstat writeMacroResults(FILE *file)
{
    VDASSERT_FN("writeMacroResults");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRint  rows;
    IGRint  i, gadget;

    IGRchar cat[80],
            prt[80],
	    rev[80],
	    lib[80],
	    mac[80],
	    qty[80],
	    key[80];

    // Arg Check
    VDASSERTW(s_form);
    VDASSERTW(file);
    gadget = VDPDM_MACRO_F_RESULTS;

    // get the number of rows
    VDfrmGetNumRows(s_form, gadget, &rows, NULL, NULL);
    if (rows < 1) goto wrapup;

    // write out a header
    fprintf(file,
	    "%-20s %-20s %-3s %-20s %-16s %-10s %-10s\n\n",
	    "CATALOG","PART","REV","LIBRARY","MACRO","QTY","KEY");

    // write out the rest
    for (i = 0; i < rows; i++) {
	VDfrmGetfText(s_form,gadget,i,VDPDM_MACRO_COLI_RES_CAT,cat);
	VDfrmGetfText(s_form,gadget,i,VDPDM_MACRO_COLI_RES_PART,prt);
	VDfrmGetfText(s_form,gadget,i,VDPDM_MACRO_COLI_RES_REV,rev);
	VDfrmGetfText(s_form,gadget,i,VDPDM_MACRO_COLI_RES_LIB,lib);
	VDfrmGetfText(s_form,gadget,i,VDPDM_MACRO_COLI_RES_MAC,mac);
	VDfrmGetfText(s_form,gadget,i,VDPDM_MACRO_COLI_RES_QTY,qty);
	VDfrmGetfText(s_form,gadget,i,VDPDM_MACRO_COLI_RES_KEY,key);

	fprintf(file,
		"%-20s %-20s %-3s %-20s %-16s %-10s %-10s\n",
		cat,prt,rev,lib,mac,qty,key);
    }
    
    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ----------------------------------------
 * Write file by Macro
 * **/
static IGRstat writeFileByMacro(IGRchar *msg)
{
    VDASSERT_FN("writeFileByMacro");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar mac_lib[80], mac_name[80];

    FILE    *file = NULL;
    IGRchar  filename[84];

    // Init / Arg Check
    *mac_lib  = 0;
    *mac_name = 0;
    VDASSERTW(s_form);
    VDASSERTW(msg);

    // get mac_lib and mac_name
    VDfrmGetgText(s_form,VDPDM_MACRO_L_LIBRARY,mac_lib);
    if (*mac_lib == 0) {
	strcpy(msg,"Need a library, No file written");
	goto wrapup;
    }
    VDfrmGetgText(s_form,VDPDM_MACRO_L_NAME,mac_name);
    if (*mac_name == 0) {
	strcpy(msg,"Need a macro, No file written");
	goto wrapup;
    }

    // filename = mac_name.cnt
    sprintf(filename,"%s.cnt",mac_name);

    // open it up
    file = fopen(filename,"wt");
    if (file == NULL) {
	sprintf(msg,"Could not open %s for writing",filename);
	goto wrapup;
    }

    // write it out
    fprintf(file,"Summary of Parts containing:\n"
	         "library <%s> macro <%s>\n\n",
		 mac_lib, mac_name);
    
    sts = writeMacroResults(file);
    if (!(sts & 1)) {
	strcpy(msg,"Could not write query results");
	goto wrapup;
    }

    // done
    sprintf(msg,"%s written",filename);
    retFlag = 1;

wrapup:
    if (file) fclose(file);
    return retFlag;
}
  
/* ----------------------------------------
 * Write file by Part
 * **/
static IGRstat writeFileByPart(IGRchar *msg)
{
    VDASSERT_FN("writeFileByPart");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar catalog[80], part[80], rev[80];

    FILE    *file = NULL;
    IGRchar  filename[84];

    // Init / Arg Check
    *catalog = 0;
    *part    = 0;
    *rev     = 0;
    VDASSERTW(s_form);
    VDASSERTW(msg);

    // get catalog, part, and rev
    VDfrmGetgText(s_form,VDPDM_MACRO_L_CATALOG,catalog);
    if (*catalog == 0) {
	strcpy(msg,"Need a catalog, No file written");
	goto wrapup;
    }
    VDfrmGetgText(s_form,VDPDM_MACRO_L_PART,part);
    if (*part == 0) {
	strcpy(msg,"Need a part, No file written");
	goto wrapup;
    }
    VDfrmGetgText(s_form,VDPDM_MACRO_L_REVISION,rev);
    if (*rev == 0) {
	strcpy(msg,"Need a rev, No file written");
	goto wrapup;
    }

    // filename = part.macs
    sprintf(filename,"%s.macs",part);

    // open it up
    file = fopen(filename,"wt");
    if (file == NULL) {
	sprintf(msg,"Could not open %s for writing",filename);
	goto wrapup;
    }

    // write it out
    fprintf(file,"Summary of Macros contained in:\n"
	         "cat <%s> part <%s> rev <%s>\n\n",
		 catalog, part, rev);
    
    sts = writeMacroResults(file);
    if (!(sts & 1)) {
	strcpy(msg,"Could not write query results");
	goto wrapup;
    }

    // done
    sprintf(msg,"%s written",filename);
    retFlag = 1;

wrapup:
    if (file) fclose(file);
    return retFlag;
}
    
/* -----------------------------------------
 * Write button was pushed
 * **/
static IGRstat notifyWrite()
{
    VDASSERT_FN("notifyWrite");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRint  by_part;
    IGRint  rows;
    IGRchar msg[80];

    // Arg check
    VDASSERTW(s_form);
    *msg = 0;

    // check if query has been done
    VDfrmGetNumRows(s_form, VDPDM_MACRO_F_RESULTS, &rows, NULL, NULL);
    if (rows < 1) {
	strcpy(msg,"Must do a Query first");
	goto wrapup;
    }

    // get the type of Write file
    VDfrmGetState(s_form,VDPDM_MACRO_T_MACRO,&by_part);

    if (by_part) {
	sts = writeFileByPart(msg);
	if (!(sts & 1)) {
	    goto wrapup;
	}
    }

    if (!by_part) {
	sts = writeFileByMacro(msg);
	if (!(sts & 1)) {
	    goto wrapup;
	}
    }

    // done
    retFlag = 1;

wrapup:
    if (*msg) VDfrmSetgText(s_form,VDPDM_MACRO_STATUS,msg);
    return retFlag;
}



/* -------------------------------------------
 * Fill the results gadget for a query by macro
 * **/
static IGRstat fillResultsByMacro(IGRchar *msg)
{
    VDASSERT_FN("fillResultsByMacro");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar mac_lib [80];
    IGRchar mac_name[80];

    IGRint  i,j,gadget;

    IGRchar     sql[1024];
    IGRchar     buf[256];
    TVDrisInfo  ris;

    // Arg check / init
    VDrisInitInfo( &ris );
    *mac_lib        = 0;
    *mac_name       = 0;
    gadget          = VDPDM_MACRO_F_RESULTS;
    
    VDASSERTW(s_form);
    VDASSERTW(msg);

    // clear the form
    VDpdmClearGadgetColumn(s_form, gadget);

    // get the mac_lib
    VDfrmGetgText(s_form,VDPDM_MACRO_L_LIBRARY,mac_lib);

    // get the mac_name
    VDfrmGetgText(s_form,VDPDM_MACRO_L_NAME,mac_name);

    if ( (*mac_lib == 0) && (*mac_name == 0) ) {
	strcpy(msg,"Must at least have a macro library or name");
	goto wrapup;
    }
    
    // build the query
    sprintf(sql,
	    "Select K.%s, K.%s, K.%s, M.%s, M.%s, M.%s, M.%s from "
	    "%s K, %s M where K.%s = M.%s",
	    VDPDM_FILE_KEY_COLN_CATALOG,  VDPDM_FILE_KEY_COLN_PART,
	    VDPDM_FILE_KEY_COLN_REVISION, VDPDM_MACRO_COLN_MACRO_LIB,
	    VDPDM_MACRO_COLN_MACRO_NAME,  VDPDM_MACRO_COLN_MACRO_QTY,
	    VDPDM_MACRO_COLN_FILE_KEY,
	    VDPDM_FILE_KEY_TABLE_NAME, VDPDM_MACRO_TABLE_NAME,
	    VDPDM_FILE_KEY_COLN_FILE_KEY, VDPDM_MACRO_COLN_FILE_KEY);

    if (*mac_lib) {
	sprintf(buf,
		" and M.%s = '%s'",
		VDPDM_MACRO_COLN_MACRO_LIB, mac_lib);
	strcat (sql,buf);
    }

    if (*mac_name) {
	sprintf(buf,
		" and M.%s = '%s'",
		VDPDM_MACRO_COLN_MACRO_NAME, mac_name);
	strcat (sql,buf);
    }

    strcat(sql,";");

    VDrisQuery( &ris, sql );
    if (ris.rows < 1) {
	strcpy(msg,"Query Failed, no data found");
	goto wrapup;
    }

    // fill the form
    for (i = 0; i < ris.rows; i++) {
	j = i * ris.cols;

	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_CAT,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_CAT]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_PART,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_PART]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_REV,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_REV]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_LIB,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_LIB]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_MAC,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_MAC]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_QTY,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_QTY]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_KEY,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_KEY]);

    }

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}
	
/* --------------------------------------------
 * Fill the results gadget for a query by part
 * **/
static IGRstat fillResultsByPart(IGRchar *msg)
{
    VDASSERT_FN("fillResultsByPart");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar filekey[80];
    IGRint  fkey;

    IGRint  i,j,gadget;

    IGRchar     sql[1024];
    TVDrisInfo  ris;

    // Arg check / init
    VDrisInitInfo( &ris );
    *filekey        = 0;
    gadget          = VDPDM_MACRO_F_RESULTS;
    
    VDASSERTW(s_form);
    VDASSERTW(msg);

    // clear the form
    VDpdmClearGadgetColumn(s_form, gadget);

    // get the filekey
    VDfrmGetgText(s_form,VDPDM_MACRO_G_FILEKEY,filekey);
    if (*filekey == 0) {
	strcpy(msg,"Must have a filekey");
	goto wrapup;
    }
    fkey = atoi(filekey);

    // build the query
    sprintf(sql,
	    "Select K.%s, K.%s, K.%s, M.%s, M.%s, M.%s, M.%s from "
	    "%s K, %s M where K.%s = M.%s and M.%s = %d;",
	    VDPDM_FILE_KEY_COLN_CATALOG,  VDPDM_FILE_KEY_COLN_PART,
	    VDPDM_FILE_KEY_COLN_REVISION, VDPDM_MACRO_COLN_MACRO_LIB,
	    VDPDM_MACRO_COLN_MACRO_NAME,  VDPDM_MACRO_COLN_MACRO_QTY,
	    VDPDM_MACRO_COLN_FILE_KEY,
	    VDPDM_FILE_KEY_TABLE_NAME, VDPDM_MACRO_TABLE_NAME,
	    VDPDM_FILE_KEY_COLN_FILE_KEY, VDPDM_MACRO_COLN_FILE_KEY,
	    VDPDM_MACRO_COLN_FILE_KEY,    fkey );

    VDrisQuery( &ris, sql );
    if (ris.rows < 1) {
	strcpy(msg,"Query Failed, no data found");
	goto wrapup;
    }

    // fill the form
    for (i = 0; i < ris.rows; i++) {
	j = i * ris.cols;

	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_CAT,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_CAT]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_PART,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_PART]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_REV,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_REV]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_LIB,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_LIB]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_MAC,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_MAC]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_QTY,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_QTY]);
	VDfrmSetfText(s_form, gadget, i, VDPDM_MACRO_COLI_RES_KEY,
		                         ris.buf[j+VDPDM_MACRO_COLI_RES_KEY]);

    }

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}
	

/* -----------------------------------------
 * Query button was pushed
 * **/
static IGRstat notifyQuery()
{
    VDASSERT_FN("notifyQuery");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRint  by_part;
    IGRchar msg[80];

    // Arg check
    VDASSERTW(s_form);

    // get the type of query
    VDfrmGetState(s_form,VDPDM_MACRO_T_MACRO,&by_part);

    if (by_part) {
	sts = fillResultsByPart(msg);
	if (!(sts & 1)) {
	    VDfrmSetgText(s_form,VDPDM_MACRO_STATUS,msg);
	    goto wrapup;
	}
    }

    if (!by_part) {
	sts = fillResultsByMacro(msg);
	if (!(sts & 1)) {
	    VDfrmSetgText(s_form,VDPDM_MACRO_STATUS,msg);
	    goto wrapup;
	}
    }

    // done
    VDfrmSetgText(s_form,VDPDM_MACRO_STATUS,"Done");
    retFlag = 1;

wrapup:
    return retFlag;
}
/* -----------------------------------------
 * Macro Library was selected
 * **/
static IGRstat notifyLibrary()
{
    VDASSERT_FN("notifyLibrary");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar mac_lib[80];

    // Arg check
    *mac_lib = 0;
    VDASSERTW(s_form);

    // get the library name
    VDfrmGetgText(s_form,VDPDM_MACRO_L_LIBRARY,mac_lib);
    if (*mac_lib == 0) goto wrapup;

    // fill the macro library list
    fillGadgetName(mac_lib);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* -----------------------------------------
 * Macro Name was selected
 * **/
static IGRstat notifyName()
{
    VDASSERT_FN("notifyName");
    IGRstat retFlag = 1;
    IGRstat sts;

    IGRchar mac_lib [80];
    IGRchar mac_name[80];

    // Arg check
    *mac_lib  = 0;
    *mac_name = 0;
    VDASSERTW(s_form);

    // get the macro name
    VDfrmGetgText(s_form,VDPDM_MACRO_L_NAME,mac_name);
    if (*mac_name == 0) goto wrapup;
    
    // fill the macro library list
    fillGadgetLibrary(mac_name);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
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
    VDfrmGetgText( s_form, VDPDM_MACRO_G_FILEKEY, fileKey);

    if (fileKey[0] != '\0') {
	fkey = atoi(fileKey);
	sts = VDpdmGetCPRForFilekey(&fkey, catalog, part, rev);
	if (sts) {
	    VDfrmSetgText(s_form, VDPDM_MACRO_L_CATALOG, catalog);
	    VDfrmSetgText(s_form, VDPDM_MACRO_L_PART,    part);
	    VDfrmSetgText(s_form, VDPDM_MACRO_L_REVISION,     rev);
	}
    }

    if (fileKey[0] == '\0') {
	// get it from catalog, part, rev
	VDfrmGetgText(s_form, VDPDM_MACRO_L_CATALOG, catalog);
	if (catalog[0] == '\0') goto wrapup;

	VDfrmGetgText(s_form, VDPDM_MACRO_L_PART, part);
	if (part[0] == '\0') goto wrapup;

	VDfrmGetgText(s_form, VDPDM_MACRO_L_REVISION, rev);
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
    VDfrmSetgText( s_form, VDPDM_MACRO_G_FILEKEY, fileKey );

    // set the headers and blob_key gadget
    //setHeaderGadget( fkey );

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
    VDfrmGetActiveRow(s_form,VDPDM_MACRO_F_ACTIVE,&row,NULL);

    // is it selected
    VDfrmGetSelect(s_form,VDPDM_MACRO_F_ACTIVE,row,0,&sel);
    if (!sel) goto wrapup;

    // get the filekey from the selected file
    VDfrmGetfText(s_form,VDPDM_MACRO_F_ACTIVE,row,
	          VDPDM_MACRO_COLI_ACT_KEY,filekey);
    if (*filekey == 0) goto wrapup;

    // set the filekey on the form
    VDfrmSetgText(s_form,VDPDM_MACRO_G_FILEKEY,filekey);

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
    VDfrmGetgText( s_form, VDPDM_MACRO_L_CATALOG, catalog);
    if (catalog[0] == '\0') goto wrapup;
    
    VDfrmGetgText( s_form, VDPDM_MACRO_L_PART, part );
    if (part[0] == '\0') goto wrapup;

    // Query for revisions
    sts = VDpdmFillGadgetRev( s_form, VDPDM_MACRO_L_REVISION, catalog, part );
    if (!(sts & 1)) goto wrapup;

    // tell the user what to do
    VDfrmSetgText( s_form, VDPDM_MACRO_STATUS, "Select Revision" );

    // clear, then notify file key
    VDfrmSetgText( s_form, VDPDM_MACRO_G_FILEKEY, "");
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
    VDfrmGetgText( s_form, VDPDM_MACRO_L_CATALOG, catalog );
    if (catalog[0] == '\0') goto wrapup;

    // query for parts
    sts = VDpdmFillGadgetPart( s_form, VDPDM_MACRO_L_PART, catalog );
    if (!(sts & 1)) goto wrapup;
    
    // tell the user what to do
    VDfrmSetgText( s_form, VDPDM_MACRO_STATUS, "Select Part" );

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
    VDfrmGetgText( s_form, VDPDM_MACRO_L_CATALOG, catalog );
    if (catalog[0] != '\0') {
	notifyPart();
	retFlag = 1;
	goto wrapup;
    }

    // fill the gadget
    sts = VDpdmFillGadgetCatalog( s_form, VDPDM_MACRO_L_CATALOG, &class );
    if (!(sts & 1)) goto wrapup;
    
    // notify part
    notifyPart();

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
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
	  initMacroFormSettings();
	  break;
      
      case FI_CANCEL:
	  VDpdmKillMacroForm();
	  break;

      //case FI_EXECUTE:
	  //sts = notifyDoit(form);
	  //break;

      case VDPDM_MACRO_T_MACRO:
	  initMacroFormSettings();
	  break;

      case VDPDM_MACRO_B_CLASS:
	  sts = VDpdmCmdGetClassLevels(&class);
	  VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_CATALOG);
	  VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_PART);
	  VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_REVISION);
	  VDfrmSetgText( s_form,VDPDM_MACRO_G_FILEKEY,"");
	  notifyCatalog();
	  break;

      case VDPDM_MACRO_L_CATALOG:
	  VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_PART);
	  VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_REVISION);
	  VDfrmSetgText( s_form,VDPDM_MACRO_G_FILEKEY,"");
	  sts = notifyCatalog();
	  break;

      case VDPDM_MACRO_L_PART:
	  VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_REVISION);
	  VDfrmSetgText( s_form,VDPDM_MACRO_G_FILEKEY,"");
	  sts = notifyPart();
	  break;

      case VDPDM_MACRO_L_REVISION:
	  VDfrmSetgText( s_form,VDPDM_MACRO_G_FILEKEY,"");
	  sts = notifyRev();
	  break;

      case VDPDM_MACRO_G_FILEKEY:
	  sts = notifyFileKey();
	  break;

      case VDPDM_MACRO_F_ACTIVE:
	  sts = notifyActive();
	  break;

      case VDPDM_MACRO_L_LIBRARY:
	  VDpdmClearGadgetList(s_form,VDPDM_MACRO_L_NAME);
	  sts = notifyLibrary();
	  break;

      case VDPDM_MACRO_L_NAME:
	  sts = notifyName();
	  break;

      case VDPDM_MACRO_B_QUERY:
	  sts = notifyQuery();
	  break;

      case VDPDM_MACRO_B_WRITE:
	  sts = notifyWrite();
	  break;


    }

wrapup:
    return retFlag;
}

/* ---------------------------------------------
 * Called by the Main form gadget.
 * ***/
IGRstat VDpdmInitMacro()
{
    VDASSERT_FN("VDpdmInitMacro");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    traceFlag = traceFlagx = VDdbgGetTraceFlag(VDPDM_TRACE_MACRO);

    // should not be called again
    VDASSERTW(!s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // statics
    memset(&class,0,sizeof(TVDpdmClass));

    // wakeup the form
    sts = VDfrmNewForm(VDPDM_MACRO_F_NUM,VDPDM_MACRO_F_NAME,notifyForm,0,&s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // Initialize the form settings.
    initMacroFormSettings();
    



wrapup:
    return 0;

}

/* -----------------------------------
 * Form Killer
 * **/
IGRstat VDpdmKillMacroForm()
{
    VDASSERT_FN("VDpdmKillMacroForm");

    if (s_form) {
	VDfrmDeleteForm( s_form, 1);
	s_form = NULL;
    }

wrapup:
    return 1;
}
