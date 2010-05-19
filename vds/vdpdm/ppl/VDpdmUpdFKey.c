 /* $Id: VDpdmUpdFKey.c,v 1.5 2001/03/22 17:14:01 jdsauby Exp $  */
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
 *      $Log: VDpdmUpdFKey.c,v $
 *      Revision 1.5  2001/03/22 17:14:01  jdsauby
 *      needed to update vdpdm_key_table instead of inserting into.
 *
 *      Revision 1.4  2001/03/22 15:14:05  jdsauby
 *      Added some status prints so the user would know what is happening
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
static IGRstat getPartsFromCatalog( ris, catalog )
  TVDrisInfo  *ris;
  IGRchar     *catalog;
{
    VDASSERT_FN("getPartsFromCatalog");

    IGRstat retFlag = 0;
    IGRstat sts;

    // arg check
    VDASSERTW( catalog[0] != '\0' );
    VDASSERTW( ris );

    // say hi
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,catalog);

    // build the query
    sprintf(ris->sql,
            "select n_itemname, n_itemrev from %s;",
	    catalog );
    
    
    // do the query
    VDrisQuery( ris, NULL );
    if (ris->rows < 1) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    // say bye
    if (traceFlag) printf(">>> %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -----------------------------------------------------------
 * If a CPR combination has already been assigned a file_key from
 * vdat_file_keys, then we want to use that existing file_key.
 * Given a CPR combo, get the existing file_key, if found, copy is over
 * if not found, set a new one.
 * ****/
static IGRstat copyFileKeyFromVdat( catalog, part, revision, fileKey )
  IGRchar *catalog, *part, *revision;
  IGRint  *fileKey;
{
    VDASSERT_FN("copyFileKeyFromVdat");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[1024];

    TVDrisInfo  ris;

    // Arg check
    VDASSERTW( catalog[0]  != '\0' );
    VDASSERTW( part[0]     != '\0' );
    VDASSERTW( revision[0] != '\0' );
    VDASSERTW( fileKey );

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // init
    VDrisInitInfo( &ris );

    // build the query
    sprintf( ris.sql,
	    "Select file_key from vdat_file_keys where %s='%s' and %s='%s' and %s='%s';",
	    "file_cat", catalog,
	    "file_nam", part,
	    "file_ver", revision );

    // get it
    VDrisQuery( &ris, NULL );

    // if not found, just set it
    if( ris.rows < 1 ) {
	sts = VDpdmSetFileKeyForCPR( catalog, part, revision, fileKey );
	if( !(sts & 1) ) goto wrapup;
	retFlag = 1;
	goto wrapup;
    }

    // One is found, copy it over
    *fileKey = atoi( ris.buf[0] );

    sprintf( sql,
	     "Insert into %s values ('%s','%s','%s',%d);",
	     VDPDM_FILE_KEY_TABLE_NAME,
	     catalog, part, revision, *fileKey );

    VDrisExecute( sql );

    // done
    printf("Processed %d Catalogs\n",ris.rows);
    retFlag = 1;

wrapup:
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,*fileKey);
    return retFlag;
}
    

    
/*----------------------------------------------------
 * See if a catalog has any parts which may have an existing
 * file key from vdat_file_keys
 * ****/
static IGRstat catalogHasPartsWithFileKey( catalog )
  IGRchar *catalog;
{
    VDASSERT_FN("catalogHasPartsWithFileKey");

    IGRstat retFlag = 0;
    IGRstat sts;

    TVDrisInfo  ris;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    VDrisInitInfo( &ris );

    // do it
    sprintf( ris.sql,
	    "Select * from vdat_file_keys where file_cat = '%s';",
	    catalog );

    if ( ris.rows < 0) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------------------
 * Cycle through all parts in a catalog, and set a file_key.
 * *****/
static IGRstat setFileKeysForCatalog( catalog )
  IGRchar *catalog;
{
    VDASSERT_FN("setFileKeysForCatalog");

    IGRstat retFlag = 0;
    IGRstat sts;
    TVDrisInfo   ris;
    IGRint fileKey,i,j;
    IGRint check;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    VDrisInitInfo( &ris );
    check = 0;

    // see if catalog contains parts that already have a file_key
    if ( catalogHasPartsWithFileKey( catalog ) ) check = 1;

    // get the parts
    sts = getPartsFromCatalog ( &ris, catalog );
    if (ris.rows < 1) goto wrapup;

    // set the file key for each part
    for (i = 0; i < ris.rows; i++) {
        
	j = i * ris.cols;
	//printf("catalog <%s>, part <%s>, revision <%s>\n",catalog, ris.buf[j], ris.buf[j+1]);
	if ( check == 1 ) {
	    copyFileKeyFromVdat( catalog, ris.buf[j], ris.buf[j+1], &fileKey );
	}
	else {         // no parts in catalog have a file key
	    VDpdmSetFileKeyForCPR( catalog, ris.buf[j], ris.buf[j+1], &fileKey );
	}

    }
   
    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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

/* -------------------------------------------------------------
 * Some files already have a file_key, which needs to be maintained.
 * This function will start the file_key numbering sequence based on
 * the number of files already having a key.
 * ****/
static IGRstat initFileKeyValue( )
{
    VDASSERT_FN("initFileKeyValue");
    
    IGRstat retFlag = 1;
    IGRstat sts;
    IGRint fileKey;

    TVDrisInfo  ris;

    // init
    fileKey = 0;
    VDrisInitInfo( &ris );

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // select key_num from vdat_keys where key_type = 'files'
    strcpy( ris.sql, "Select key_num from vdat_keys where key_type = 'files';" );

    // query it
    VDrisQuery( &ris, NULL );
    if( ris.rows < 1 ) goto wrapup;
    
    // set it
    fileKey = atoi( ris.buf[0] );
    if ( fileKey == 0 ) goto wrapup;

    // value found, is equal to the next key to be used.  Set vdpdm_key_table.
    VDrisInitInfo( &ris );
    sprintf( ris.sql,
	    "Update %s set %s=%d where %s='%s';",
	    VDPDM_KEY_TABLE_TABLE_NAME,
	    VDPDM_KEY_TABLE_COLN_VALUE, fileKey,
	    VDPDM_KEY_TABLE_COLN_KEY_NAME, VDPDM_FILE_KEY_COLN_FILE_KEY );

    sts = VDrisExecute( ris.sql );
    if ( !(sts & 1) ) {
	retFlag = 0;
	goto wrapup;
    }

    // done
wrapup:
    // say bye
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,fileKey);
    return retFlag;
}


/* ----------------------------------------------------
 * function to set file keys for a file.  Cycle through all
 * catalogs and parts in the database, and set a file_key for
 * them.
 */
IGRstat VDpdmUpdFileKeys()
{
    VDASSERT_FN("VDpdmUpdFileKeys");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i, j;
    IGRchar buf[64];

    TVDrisInfo  ris;

    // set tracing
    traceFlag = traceFlagx = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    VDrisInitInfo( &ris );

    /* Need to incorporate the files that already have a file key
     * based on the db table vdat_keys and key_type = files.
     * */
    sts = initFileKeyValue( );
    if ( !(sts & 1) ) goto wrapup;

    // get all the catalogs
    UI_status("Getting List of Catalogs");
    sts = getNFMcatalogs( &ris );
    if (ris.rows < 1) goto wrapup;

    // loop through the catalogs to set file key
    for (i = 0; i < ris.rows; i++ ) {
        
	sts = setFileKeysForCatalog( ris.buf[i] );

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
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
  
