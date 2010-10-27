 /* $Id: VDpdmGetDesc.c,v 1.1 2001/03/02 21:44:03 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/ppl/VDpdmUpdFileKey.C
 *
 * Description: Update File Key for all files in PDM
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmGetDesc.c,v $
 *      Revision 1.1  2001/03/02 21:44:03  jdsauby
 *      Added purpose Info
 *
 *      Revision 1.3  2001/02/21 13:17:05  jdsauby
 *      CR4088, changed VDpdm2.h to VDpdm.h
 *
 *      Revision 1.2  2001/02/16 22:27:58  build
 *      Changed VDris2.h to VDrisc.h
 *
 *      Revision 1.1  2001/02/05 16:39:35  jdsauby
 *      JTS MP CR4088
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdm.h"

VDASSERT_FFN("vdpdm/ppl/VDpdmUpdFileKey.C");

/* ------------------------------------------------
 * given a catalog, returns a list of all parts within
 * the catalog into ris->buf
 * ****/
static IGRstat getNameDescForCatalog( catalog, file )
  IGRchar     *catalog;
  FILE        *file;
{
    VDASSERT_FN("getNameDescForCatalog");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i,j;
    TVDrisInfo ris;

    // arg check
    VDrisInitInfo( &ris );
    VDASSERTW( catalog[0] != '\0' );

    // say hi
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,catalog);

    // build the query
    sprintf(ris.sql,
            "select distinct n_itemname, n_itemdesc from %s;",
	    catalog );
    
    
    // do the query
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // write to the file
    for (i = 0; i < ris.rows; i++) {
	j = i * ris.cols;
	fprintf(file,
		"%-18s %-16s %-45s\n",
		catalog,ris.buf[j],ris.buf[j+1]);
    }

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf(">>> %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* -----------------------------------------------------------
 * Get all catalogs of n_type = 'C'.
 * returned in ris.buf
 * ****/
static IGRstat getNFMcatalogs( ris )
  TVDrisInfo   *ris;
{
    VDASSERT_FN("getNFMcatalogs");

    IGRstat retFlag = 0;
    IGRstat sts;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // build the qry
    strcpy(ris->sql,
	    "select n_catalogname from nfmcatalogs where n_type = 'C';");

    // do the qry
    VDrisQuery( ris, NULL );
    if (ris->rows < 1) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* ----------------------------------------------------
 * function to set file keys for a file.  Cycle through all
 * catalogs and parts in the database, and set a file_key for
 * them.
 */
IGRstat VDpdmGetDesc()
{
    VDASSERT_FN("VDpdmGetDesc");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i, j;
    IGRchar buf[64];

    TVDrisInfo  ris;

    FILE  *file = NULL;

    // set tracing
    traceFlag = traceFlagx = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // open the file for the first time
    file = fopen("n_descr.txt","wt");
    if (file == NULL) file = stdout;
    // init
    VDrisInitInfo( &ris );

    // get all the catalogs
    sts = getNFMcatalogs( &ris );
    if (ris.rows < 1) goto wrapup;

    // print file header
    fprintf(file,
	    "%-18s %-16s %-45s\n","Catalog","Name","Description");

    // loop through the catalogs to set file key
    for (i = 0; i < ris.rows; i++ ) {

	sts = getNameDescForCatalog( ris.buf[i] ,file );
	if ( !(i % 10) ) {
	    sprintf (buf,"Processing %d of %d Catalogs",i,ris.rows);
	    UI_status(buf);
	    printf("%s\n",buf);
	}

    }

    // done
    retFlag = 1;

    
wrapup:
    VDrisFreeInfo( &ris );
    if ((file) && (file != stdout)) fclose(file);
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
  
