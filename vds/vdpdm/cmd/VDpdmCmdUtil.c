/* $Id: VDpdmCmdUtil.c,v 1.4 2002/05/10 19:33:50 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmCmdUtil.c
 *
 * Description: Common Gadgets for VDpdm forms
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/02/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmCmdUtil.c");

/* --------------------------------------
 * fill a list gadget
 * ***/
IGRstat VDpdmFillGadgetList( Form       form,
                             IGRint     gadget,
			     TVDrisInfo *ris )
{
    VDASSERT_FN("VDpdmFillGadgetList");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;

    VDASSERTW(form);
    VDASSERTW(gadget);
    VDASSERTW(ris->rows > 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // do it
    for(i = 0; i < ris->rows; i++) {
	VDfrmSetgListText( form, gadget, i, ris->buf[i] );
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------
 * clear gadget for list
 * ***/
IGRstat VDpdmClearGadgetList( Form   form,
	                      IGRint gadget )
{
    VDASSERT_FN("VDpdmClearGadgetList");

    IGRstat retFlag = 1;
    IGRstat sts;

    VDASSERTW(form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // clear the gadget itself
    VDfrmSetgText( form, gadget, "" );
    
    // set the num of rows to 0
    VDfrmSetListNumRows( form, gadget, 0, 0 );

    // done
wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

/* --------------------------------------
 * Clear a multicolumn display gadget
 * **/
IGRstat VDpdmClearGadgetColumn( Form   form,
	                        IGRint gadget)
{
    VDASSERT_FN("VDpdmClearGadgetColumn");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i,j;
    IGRint  rows,cols;

    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get rows and columns
    FImcf_get_num_cols( form, gadget, &cols );
    FIfld_get_num_rows( form, gadget, &rows );

    // clear it up
    for (i = 0; i < rows; i++ ) {

	for (j = 0; j < cols; j++ ) {
	    FIfld_set_text(form, gadget, i, j, "", 0);    
	}
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------
 * Fill the purpose list gadget
 * ***/
IGRstat VDpdmFillPurposeListGadget( Form   form,
	                            IGRint gadget )
{
    VDASSERT_FN("VDpdmFillPurposeListGadget");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar *p;
    IGRint  cnt,i;
    IGRchar buf[80];

    FILE    *file = NULL;

    VDASSERTW(form);
    VDASSERTW(gadget > 0);


    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // open the file
    file = VDpdmOpenPurpListFile();
    if (file == NULL) goto wrapup;

    // clear existing data in form
    VDfrmSetgListNumRows( form, gadget, 0 );

    // cycle through file and fill the gadget
    i = 0;
    while(fgets(buf,sizeof(buf),file)) {

	// comments of # are allowed
	if (strncmp(buf,"#",1)) {

	    // no empty lines or spaces
	    for(p = buf; *p > ' '; p++); *p = 0;
	    if (*buf) {
		VDfrmSetgListText( form, gadget, i, buf );
		i++;
	    }
	}
    } // end of file

    
    // done
    retFlag = 1;

wrapup:
    if (file) fclose(file);
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

/* -------------------------------------------------
 * Fill the revision gadget.
 * I - Form, gadget, catalog, and part
 * **/
IGRstat VDpdmFillGadgetRev(Form    form,
                           IGRint  gadget,
			   IGRchar *catalog,
			   IGRchar *part)
{
    VDASSERT_FN("VDpdmFillGadgetRev");

    IGRstat retFlag = 0;
    IGRstat sts;

    TVDrisInfo  ris;

    // Arg check
    VDrisInitInfo( &ris );

    VDASSERTW(form);
    VDASSERTW(gadget);
    VDASSERTW(*catalog != 0);
    VDASSERTW(*part    != 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // set the query
    sprintf(ris.sql,
	    "Select n_itemrev from %s where n_itemname = '%s';",
	    catalog, part);

    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // fill the form
    sts = VDpdmFillGadgetList( form, gadget, &ris );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    if(traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -------------------------------------------------------
 * Fill the part gadget
 * I - form, gadget, catalog
 * **/
IGRstat VDpdmFillGadgetPart( Form    form,
                             IGRint  gadget,
			     IGRchar *catalog)
{
    VDASSERT_FN("VDpdmFillGadgetPart");

    IGRstat retFlag = 0;
    IGRstat sts;

    TVDrisInfo  ris;

    // Arg check
    VDrisInitInfo( &ris );

    VDASSERTW(form);
    VDASSERTW(gadget);
    VDASSERTW(*catalog != 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // do it
    sprintf(ris.sql,
	    "Select distinct n_itemname from %s;", catalog);

    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // Set the form values
    sts = VDpdmFillGadgetList( form, gadget, &ris );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -------------------------------------------------------
 * Fill the catalog gadget
 * I - form, gadget, classifications
 * **/
IGRstat VDpdmFillGadgetCatalog( Form        form,
                                IGRint      gadget,
			        TVDpdmClass *class)
{
    VDASSERT_FN("VDpdmFillGadgetCatalog");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar     buf[1024],
	        sql[1024];
    TVDrisInfo  ris;

    // Arg check
    VDrisInitInfo( &ris );

    VDASSERTW(form);
    VDASSERTW(gadget);
    VDASSERTW(class);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // do it
        // Start building the sql
    strcpy(sql,
	   "Select nfmcatalogs.n_catalogname from nfmcatalogs, pdmcatalogs where ");
    strcat(sql,"nfmcatalogs.n_catalogno=pdmcatalogs.n_catalogno and ");
   
    // get the classifications
    sprintf(buf,"pdmcatalogs.p_level1='%s'",class->l1);
    strcat( sql, buf );
    
    if (*class->l2 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level2='%s'",class->l2);
    strcat (sql, buf);

    if (*class->l3 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level3='%s'",class->l3);
    strcat (sql, buf);

    if (*class->l4 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level4='%s'",class->l4);
    strcat (sql, buf);

    if (*class->l5 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level5='%s'",class->l5);
    strcat (sql, buf);

    if (*class->l6 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level6='%s'",class->l6);
    strcat (sql, buf);

    if (*class->l7 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level7='%s'",class->l7);
    strcat (sql, buf);

    if (*class->l8 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level8='%s'",class->l8);
    strcat (sql, buf);

    if (*class->l9 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level9='%s'",class->l9);
    strcat (sql, buf);

    if (*class->l10 == 0) goto finalSQL;
    sprintf(buf,"and pdmcatalogs.p_level10='%s'",class->l10);
    strcat (sql, buf);

finalSQL:
    // build query to get n_catalogno
    strcat(sql,";");

    // get the catalogs
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // Set the form values
    sts = VDpdmFillGadgetList( form, gadget, &ris );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -------------------------------------------
 * Fill the list of local files gadget
 * I - form, gadget, filename column, filekey column
 * **/
IGRstat VDpdmFillMCFActiveFile( Form    form,
                                IGRint  gadget,
				IGRint  colName,
				IGRint  colKey )
{
    VDASSERT_FN("VDpdmFillMCFActiveFile");

    IGRstat retFlag = 1;
    IGRstat sts;
    IGRint  i;
    IGRchar fkey[20];

    TVDpdmRefList  list;
    TVDpdmInfo     info;
    VDosnum        osnum = OM_K_NOT_AN_OS;

    // init
    VDpdmInitRefList( &list );

    VDASSERTW(form);
    VDASSERTW(gadget);

    // get the info of the active file
    sts = VDpdmGetPdmInfo( osnum, &info );
    if (!(sts & 1)) goto wrapup;

    // Add this info to reflist
    sts = VDpdmAddPartToRefList( &list, &info );
    if (!(sts & 1)) goto wrapup;

    // get the reflist
    sts = VDpdmGetRefList( osnum, &list );
    VDASSERTW(list.cnt > 0);

    // fill the form
    for (i = 0; i < list.cnt; i++) {
	VDfrmSetfText(form, gadget, i, colName, list.infos[i].filename);	
	sprintf(fkey,"%d",list.infos[i].filekey);
	VDfrmSetfText(form, gadget, i, colKey, fkey);	
    }

    // done

wrapup:
    VDpdmFreeRefList( &list );
    return retFlag;
}


