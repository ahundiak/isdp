 /* $Id: VDpdmApprCfg.c,v 1.18.2.1 2004/03/29 16:12:59 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdm/VDpdmApprCfg.c
 *
 * Description: Approved configuration and hull applicability functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmApprCfg.c,v $
 *      Revision 1.18.2.1  2004/03/29 16:12:59  ahundiak
 *      ah
 *
 *      Revision 1.18  2002/01/07 18:20:53  jdsauby
 *      JTSMP CR 5952, new rules for hull applicability check and hull approval check.
 *
 *      Revision 1.17  2001/12/06 21:39:16  jdsauby
 *      JTSMP TR 5863
 *
 *      Revision 1.16  2001/11/19 18:26:58  jdsauby
 *      did not free risInfo structure, resolved - jds
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 * 02/18/04  ah      LHAR
 * 11/17/10  ah      SOL10 VDship Enhancements
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDnfmc.h"
#include "VDrisc.h"
#include "VDpdm.h"
//#include "VDpdmACfg.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "time.h"
#include "VDDbDef.h"
#include "VDship.h"

VDASSERT_FFN("vdpdm/func/VDpdmApprCfg.c");

/* ------------------------------------------------
 * Check to see if a particular ship is contained within
 * a list of ships
 * **/
static IGRstat shipIsInTheList(IGRchar *ship, VDpdmHullApp *ships)
{
    VDASSERT_FN("shipIsInTheList");
    IGRstat retFlag = 0;
    IGRint  i;

    VDASSERTW(ship && *ship);
    VDASSERTW(ships->cnt > 0);

    // loop it
    for (i = 0; i < ships->cnt; i++) {

	if (!strcmp(ship,ships->hulls[i])) {
	    retFlag = 1;
	    goto wrapup;
	}
    }

    // done, not found in list

wrapup:
    return retFlag;
}

    
/* ---------------------------------------------------
 * Compare the ship applicability of the reference part
 * to that of the active part.  It is valid if all of the
 * applicable ships active part are also applicable within
 * the reference part.
 * **/
IGRstat VDpdmIsShipApplicabilityValid(IGRint *fkey_part,
	                              IGRint *fkey_ref)
{
    VDASSERT_FN("VDpdmIsShipApplicabilityValid");

    IGRstat retFlag = 0;
    IGRstat sts;
    VDpdmHullApp ships_part;
    VDpdmHullApp ships_ref;
    IGRint  i, j;

    // arg check
    VDASSERTW(*fkey_part > 0);
    VDASSERTW(*fkey_ref  > 0);

    // get the list of applicable hulls for the part
    sts = VDpdmGetHullAppforFilekey(fkey_part,&ships_part);
    if (!(sts & 1)) goto wrapup;


    // get the list of applicable hulls for the ref part
    sts = VDpdmGetHullAppforFilekey(fkey_ref,&ships_ref);
    if (!(sts & 1)) goto wrapup;

    // loop through ref and compare to part
    // note: the ships within ships_ref must all be contained within
    // the ships within ships_part
    /* JTSMP CR 5952 new Lowest HULL rule */
    //for (i = 0; i < ships_part.cnt; i++) {

	    //if (!shipIsInTheList(ships_part.hulls[i],&ships_ref)) {
	    if (!shipIsInTheList(ships_part.hulls[0],&ships_ref)) {
		goto wrapup;
	    }
    //}

    // done. all ships are in the list
    retFlag = 1;

wrapup:
    return retFlag;
}

	    

/* ---------------------------------------------------
 * Set Approved configuration to not approved for one
 * file and one hull
 * ***/
static IGRstat setApprCfgforFile(IGRint  *fileKey,
	                         IGRchar *hull,
	                         IGRchar *catalog,
				 IGRchar *part,
				 IGRchar *revision,
				 IGRint  appr_stat,
				 IGRint  prod_stat)
{
    VDASSERT_FN("setApprCfgforFile");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[1024];
    
    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );

    //say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Arg Check
    VDASSERTW(*fileKey    != 0);
    VDASSERTW(hull[0]     != '\0');
    VDASSERTW(catalog [0] != '\0');
    VDASSERTW(part    [0] != '\0');
    VDASSERTW(revision != NULL);


    // check to see if an approved flag has been set
    sprintf(sql,
	    "Select * from %s where %s=%d and %s='%s';",
	    VDPDM_HULL_APP_TABLE_NAME,
	    VDPDM_HULL_APP_COLN_FILE_KEY, *fileKey,
	    VDPDM_HULL_APP_COLN_HULL_APP, hull);
    VDrisQuery( &ris, sql );

    if ( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) { 
	// no approved flag has been set
	sprintf(sql,
		"Insert into %s values (%d,'%s','%s','%s','%s',%d,%d);",
		VDPDM_HULL_APP_TABLE_NAME,
		*fileKey,hull,
		catalog,part,revision,
		appr_stat,prod_stat);

	sts = VDrisExecute( sql );
	if (!(sts & 1)) goto wrapup;

	retFlag = 1;
	goto wrapup;
    }

    // update the flag
    sprintf(sql,
	    "Update %s set %s=%d, %s=%d where %s=%d and %s='%s';",
	    VDPDM_HULL_APP_TABLE_NAME,
	    VDPDM_HULL_APP_COLN_IS_APPROVED, appr_stat,
	    VDPDM_HULL_APP_COLN_IS_PRODUCTION, prod_stat,
	    VDPDM_HULL_APP_COLN_FILE_KEY, *fileKey,
	    VDPDM_HULL_APP_COLN_HULL_APP, hull);
    
    sts = VDrisExecute( sql );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------------
 * Set Approved configuration to approved for one file
 * and one hull.  Make sure that only one catalog, part
 * combination is approved.  For any given catalog and
 * part, only one revision can be approved for any one ship.
 * ***/
static IGRstat setApprCfgtoApproved(IGRint  *fileKey,
	                            IGRchar *hull,
                                    IGRchar *catalog,
                                    IGRchar *part,
                                    IGRchar *revision,
                                    IGRint  appr_stat,
                                    IGRint  prod_stat)
{
    VDASSERT_FN("setApprCfgtoApproved");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[1024];

    TVDrisInfo  ris;

    // init
    VDrisInitInfo( &ris );

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Arg Check
    VDASSERTW(*fileKey    != 0);
    VDASSERTW(hull[0]     != '\0');
    VDASSERTW(catalog[0]  != '\0');
    VDASSERTW(part[0]     != '\0');
    VDASSERTW(revision[0] != '\0');

    // check if any catalog, part combination has an approved cfg set
    sprintf(sql,
	    "Select %s from %s where %s='%s' and %s='%s' and %s='%s';",
	    VDPDM_HULL_APP_COLN_FILE_KEY,
	    VDPDM_HULL_APP_TABLE_NAME,
	    VDPDM_HULL_APP_COLN_CATALOG, catalog,
	    VDPDM_HULL_APP_COLN_PART,    part,
	    VDPDM_HULL_APP_COLN_HULL_APP,hull);
    
    VDrisQuery( &ris, sql );
    
    if (ris.rows > 0) {
	// set them all to not approved
	sprintf(sql,
		"Update %s set %s=%d, %s=%d where %s='%s' and %s='%s' and %s='%s';",
		VDPDM_HULL_APP_TABLE_NAME,
		VDPDM_HULL_APP_COLN_IS_APPROVED,   VDPDM_IS_NOT_APPROVED,
		VDPDM_HULL_APP_COLN_IS_PRODUCTION, VDPDM_IS_NOT_PRODUCTION,
		VDPDM_HULL_APP_COLN_CATALOG,       catalog,
		VDPDM_HULL_APP_COLN_PART,          part,
		VDPDM_HULL_APP_COLN_HULL_APP,      hull);
	
	sts = VDrisExecute( sql );
	if (!(sts & 1)) goto wrapup;
    }

    // set this one to approved
    sts = setApprCfgforFile( fileKey, hull,
	                     catalog, part, revision,
	                     appr_stat, prod_stat);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------------------
 * Set approved configuration for one filekey and one hull
 * ***/
IGRstat VDpdmSetApprCfgForFileKeyHull(IGRint   *fileKey,
	                              IGRchar  *hull,
				      IGRint   appr_stat,
				      IGRint   prod_stat )
{
    VDASSERT_FN("VDpdmSetApprCfgForFilekeyHull");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRint      i,j;
    IGRchar     catalog[60],
                part   [40],
		rev    [12];

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,hull);

    // Arg check
    VDASSERTW(*fileKey != 0);
    VDASSERTW(hull[0]  != '\0');
    
    // init
    catalog[0]  = '\0';
    part[0]     = '\0';
    rev[0]      = '\0';
    
    // Get the CPR for the file Key
    sts = VDpdmGetCPRForFilekey(fileKey, catalog, part, rev);
    if(catalog[0] == '\0') goto wrapup;

    /*-----------------------------------------------
     * If appr_stat = VDPDM_IS_NOT_APPROVED, then the is_approved
     * flag can simply be set.  IF it is VDPDM_IS_APPROVED, then we must
     * assure that no other revision of the same catalog and part is approved
     * as only one revision of the same catalog and part can be approved
     * for a ship at any one time.
     * ***/
    switch(appr_stat) {

      //case VDPDM_IS_APPROVED_DEFAULT:
      case VDPDM_IS_NOT_APPROVED:
	  sts = setApprCfgforFile(fileKey, hull,
		                  catalog, part, rev,
				  appr_stat, prod_stat);
	  if ( !(sts & 1) ) goto wrapup;
	  retFlag = 1;
	  goto wrapup;

      case VDPDM_IS_APPROVED:
	  sts = setApprCfgtoApproved(fileKey, hull,
		                     catalog, part, rev, 
				     appr_stat, prod_stat);
	  if ( !(sts & 1) ) goto wrapup;
	  retFlag = 1;
	  goto wrapup;

    }  // end of switch appr_stat
	  
wrapup:
    // say by
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    
/* ---------------------------------------------------
 * verify that the catalog is not FAKE, and that it has
 * the hull app attributes
 * **/
static IGRstat verifyCatalogType(IGRchar *a_catalog)
{
    VDASSERT_FN("verifyCatalogType");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar catalog[80];

    TVDrisInfo ris;

    IGRchar appColName[32];

    // Init
    VDrisInitInfo( &ris );

    // Arg check
    VDASSERTW(*a_catalog != 0);
    if (!strcmp(a_catalog,"FAKE")) goto wrapup;

    strcpy(catalog,a_catalog);
    VDstrupr(catalog);

    /* Build the hull app column name to query for */
    VDshipGetFirstHull(appColName);
    if (*appColName == 0) goto wrapup;

    // query ris5columns to see if there hull app attributes exist
    // assume that if it has the first hull, then it has the rest.
    sprintf(ris.sql,
	    "Select * from ris5columns where upper_table_name = '%s' and "
	    "column_name = '%s';", catalog,appColName);

    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}
    
/* ----------------------------------------------------
 * Query the list of hulls from the catalog, return the Y or N
 * value into ris->buf.
 * ***/
static IGRstat qryHullAppForCPR(IGRchar   *catalog,
	                        IGRchar   *part,
				IGRchar   *revision,
				TVDrisInfo *ris )
{
    VDASSERT_FN("qryHullAppForCPR");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[1024];
    IGRchar hulls[256];

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Arg Check
    VDASSERTW(catalog[0]  != '\0');
    VDASSERTW(part[0]     != '\0');
    VDASSERTW(revision != NULL);
    VDASSERTW(ris);

    // check if catalog exists or has a hull app
    sts = verifyCatalogType(catalog);
    if (!(sts & 1)) goto wrapup;

    // build the qry
    VDshipGetHulls(hulls);
    if (*hulls == 0) goto wrapup;
    sprintf(sql,
            "Select %s from %s where n_itemname='%s' and n_itemrev='%s';",
	    hulls, catalog, part, revision );

    if (traceFlag) printf("SQL: <<%s>>\n",sql);

    // do the qry
    VDrisQuery( ris, sql );
    if (ris->rows < 1) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/*--------------------------------------------------
 * Check to see if a given ship is applicable to a filekey,
 * The ship was from a list of approved configuration ships.
 * This will help tidy up, if an applicability has been changed, and
 * the approved configuration has not been updated.
 * **/
IGRstat VDpdmIsShipApplicableToFilekey(IGRint  *filekey,
	                               IGRchar *ship)
{
    VDASSERT_FN("VDpdmIsShipApplicableToFilekey");
    IGRstat retFlag = 0;
    IGRstat sts;

    VDpdmHullApp ships;
    IGRint       i;

    // arg check
    VDASSERTW(ship && *ship);
    VDASSERTW(*filekey > 0);

    // get the hull applicability list for the filekey
    sts = VDpdmGetHullAppforFilekey(filekey,&ships);
    if (!(sts & 1)) goto wrapup;

    // loop through the list of ships, and compare
    for (i = 0; i < ships.cnt; i++) {

	if (!strcmp(ships.hulls[i],ship)) {
	    retFlag = 1;
	    goto wrapup;
	}
    }

    // none found

wrapup:
    return retFlag;
}

    

/* ----------------------------------------------------
 * Get the Approved For Hull Config given a filekey.
 * Put it into the VDpdmHullApp struct given a fileKey
 * ***/
IGRstat VDpdmGetApprCfgforFilekey(IGRint       *fileKey,
	                          VDpdmHullApp *ships)
{
    VDASSERT_FN("VDpdmGetApprCfgforFilekey");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[1024];

    IGRchar buf[80];

    TVDrisInfo  ris;
    IGRint      i;

    VDrisInitInfo( &ris );
    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Arg Check
    VDASSERTW(*fileKey != 0);
    VDASSERTW(ships);
    memset(ships,0,sizeof(VDpdmHullApp));

    // try the cache first
    ships->cnt      = 0;
    sts = VDpdmCgetApprCfgforFilekey(fileKey,ships);
    if (sts & 1) {
	VDASSERTW(ships->cnt > 0);
	VDASSERTW(ships->file_key == *fileKey);
	// check for an NA value on the first ship
	if (!strcmp(ships->hulls[0],"NA")) goto wrapup;
	retFlag = 1;
	goto wrapup;
    }
    
    // init
    ships->file_key = *fileKey;
    ships->cnt      = 0;
   
    // does the table exist
    if (VdsVerifyRisTable(VDPDM_HULL_APP_TABLE_NAME) != VDS_DBTABLE_FOUND)
	goto wrapup;

    // Query for approved config
    sprintf(sql,
	    "Select %s from %s where %s=%d and %s=%d order by %s;",
	    VDPDM_HULL_APP_COLN_HULL_APP,
	    VDPDM_HULL_APP_TABLE_NAME,
	    VDPDM_HULL_APP_COLN_FILE_KEY, *fileKey,
	    VDPDM_HULL_APP_COLN_IS_APPROVED, VDPDM_IS_APPROVED,
	    VDPDM_HULL_APP_COLN_HULL_APP);

    if (traceFlag) printf("### %s SQL:\n<%s>\n",fn,sql);

    // query it
    VDrisQuery( &ris, sql );
    if ( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) 
    {
	// set the cache to NA
	VDpdmCsetApprCfgforFilekey(fileKey,NULL);
	goto wrapup;
    }
	    
    // loop through ris.buf, fill ships

    for (i = 0; i < ris.rows; i++) {
	
	if (strcmp(ris.buf[i],"")) {

	    // is this ship still applicable
	    if (VDpdmIsShipApplicableToFilekey(fileKey,ris.buf[i])) {

		strcpy(ships->hulls[ships->cnt],ris.buf[i]);
		ships->cnt++;
	    }
	    else {
		// remove it from the list of approved config
		VDpdmSetApprCfgForFileKeyHull(fileKey,ris.buf[i],
		                      VDPDM_IS_NOT_APPROVED,VDPDM_IS_NOT_PRODUCTION);
	    }
	}
    }

    if (ships->cnt < 1) goto wrapup;

    // set it into the cache for future use
    VDpdmCsetApprCfgforFilekey(fileKey,ships);

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

   

/* ----------------------------------------------------
 * Fill the VDpdmHullApp struct given a fileKey
 * ***/
IGRstat VDpdmGetHullAppforFilekey(IGRint       *fileKey,
	                          VDpdmHullApp *ships)
{
    VDASSERT_FN("VDpdmGetHullAppforFilekey");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar catalog[60], part[40], rev[12];
    IGRchar buf[80];

    TVDrisInfo  ris;
    IGRint      i;

    IGRchar shipClassName[32];
    IGRint  hullNumMin;

    /* Init */
    VDrisInitInfo( &ris );

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Arg Check
    VDASSERTW(*fileKey > 0);
    VDASSERTW(ships);

    // try the cache first
    ships->cnt      = 0;
    sts = VDpdmCgetHullAppforFilekey(fileKey,ships);
    if (sts & 1) {
	VDASSERTW(ships->cnt > 0);
	VDASSERTW(ships->file_key == *fileKey);
	// check for an NA value on the first ship
	if (!strcmp(ships->hulls[0],"NA")) goto wrapup;
	retFlag = 1;
	goto wrapup;
    }
    
    // init
    catalog[0]  = '\0';
    part[0]     = '\0';
    rev[0]      = '\0';
    memset(ships,0,sizeof(VDpdmHullApp));
    
    // get catalog part and rev for filekey
    VDpdmGetCPRForFilekey(fileKey, catalog, part, rev);
    if (catalog[0] == '\0') goto wrapup;

    // query hull applicabilities
    qryHullAppForCPR(catalog, part, rev, &ris);
    if (ris.rows < 1) 
    {
	// set the cache to NA
	VDpdmCsetHullAppforFilekey(fileKey,NULL);
	goto wrapup;
    }

    // loop through ris.buf, fill ships
    ships->file_key = *fileKey;
    ships->cnt      = 0;

    VDshipGetClassName(shipClassName); strupr(shipClassName);
    VDshipGetMinHullNum(&hullNumMin);

    for (i = 0; i < ris.cols; i++) {

	if ( (!strcmp(ris.buf[i],"Y")) || (!strcmp(ris.buf[i],"y")) ) {
	    sprintf(buf,"%s%d",shipClassName,i+hullNumMin);
	    strcpy(ships->hulls[ships->cnt],buf);
	    ships->cnt++;
	}
    }

    if (ships->cnt < 1) goto wrapup;

    // set the cache for future use
    VDpdmCsetHullAppforFilekey(fileKey,ships);
    
    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

    

/*-----------------------------------------------------
 * Set defualt approved for configuration value for 
 * each ship that a CPR is applicable.  Default is not_approved
 * ***/
IGRstat VDpdmSetDefaultApprCfgForCPR( IGRchar *catalog,
	                              IGRchar *part,
				      IGRchar *revision )
{
    VDASSERT_FN("VDpdmSetDefaultApprCfgForCPR");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRint  fileKey, i;

    VDpdmHullApp ships;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s <%s,%s,%s>\n",ffn(),fn,catalog,part,revision);

    // Arg Check
    VDASSERTW(catalog[0]  != '\0');
    VDASSERTW(part[0]     != '\0');
    VDASSERTW(revision != NULL);

    // init
    fileKey = 0;
    
    // get the fileKey for CPR
    sts = VDpdmGetFileKeyForCPR(catalog, part, revision, &fileKey);
    if (fileKey == 0) goto wrapup;

    // get the hull applicability for file Key
    sts = VDpdmGetHullAppforFilekey(&fileKey, &ships);
    if (ships.cnt < 1) {
	retFlag = 1;
	goto wrapup;
    }

    // set the defualt for each hull
    for (i = 0; i < ships.cnt; i++) {
	VDpdmSetApprCfgForFileKeyHull(&fileKey, ships.hulls[i],
		                      VDPDM_IS_APPROVED_DEFAULT,
				      VDPDM_IS_PRODUCTION_DEFAULT);
    }

    // done
    retFlag = 1;

wrapup:
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------------------------
 * check a revision to see if it matches approved config
 * **/
static IGRstat isRevisionApproved(VDpdmHullApp *actShips,
	                          IGRchar      *catalog,
				  IGRchar      *part,
				  IGRchar      *rev)
{
    VDASSERT_FN("isRevisionApproved");

    IGRstat retFlag = 0;
    IGRint  filekey = 0;

    // assert
    VDASSERTW(actShips);
    VDASSERTW(*catalog != 0);
    VDASSERTW(*part    != 0);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the filekey for the CPR
    VDpdmGetFileKeyForCPR(catalog, part, rev, &filekey);
    if (filekey < 1) goto wrapup;

    // make sure the revision is valid
    if (!VDpdmIsRevisionValid(rev)) goto wrapup;

    // compare approved config of active to that of the filekey
    if (!VDpdmCompareCfgRefToActive(actShips,&filekey,rev)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------------------------------
 * Find a revision that matches approved hull configuration
 * **/
IGRstat VDpdmGetApprCfgRevision(VDpdmHullApp *actShips,   /* Input */
                                IGRint       *filekey,    /* Input */
				IGRchar      *app_rev)    /* Output */
{
    VDASSERT_FN("VDpdmGetApprCfgRevision");
    IGRstat retFlag = 0;
    IGRchar catalog[80],
            part   [80],
	    rev    [80];

    TVDrisInfo  ris;
    IGRchar     sql[1024];
    IGRint      i;

    VDrisInitInfo( &ris );

    // assert
    VDASSERTW(actShips);
    VDASSERTW(*filekey > 0);
    VDASSERTW(app_rev); *app_rev = 0;

    *catalog = 0;
    *part    = 0;
    *rev     = 0;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the CPR for the filekey
    VDpdmGetCPRForFilekey(filekey,catalog,part,rev);
    if (*catalog == 0) goto wrapup;

    // get list of possible revision greater than current rev 
    sprintf(sql,
	    "Select n_itemrev from %s where n_itemname='%s' and n_itemrev > '%s';",
	    catalog, part, rev );

    if (traceFlag) printf("SQL: <%s>\n",sql);

    VDrisQuery( &ris, sql );
    if (ris.rows > 0) {

	// loop through them to compare
	for (i = 0; i < ris.rows; i++) {
	    if (traceFlag) printf("ris.buf[%d] <%s>\n",i,ris.buf[i]);
	    
	    if ( isRevisionApproved(actShips,catalog,part,ris.buf[i]) ) {

		strcpy(app_rev,ris.buf[i]);
		retFlag = 1;
		goto wrapup;

	    }  // end of isRevisionApproved

	}  // end of for

    }  // end of ris.rows

    // made it to here, so none of the revision > current rev matches approved config,
    // check for revisions < current rev
    VDrisFreeInfo( &ris );
    VDrisInitInfo( &ris );

    sprintf(sql,
	    "Select n_itemrev from %s where n_itemname='%s' and n_itemrev < '%s';",
	    catalog, part, rev );

    VDrisQuery( &ris, sql );
    if (ris.rows > 0) {

	// loop through them to compare
	for (i = 0; i < ris.rows; i++) {

	    if ( isRevisionApproved(actShips,catalog,part,ris.buf[i]) ) {

		strcpy(app_rev,ris.buf[i]);
		retFlag = 1;
		goto wrapup;

	    }  // end of isRevisionApproved

	}  // end of for

    }  // end of ris.rows

    // done, no approved revisions found
    
wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn, retFlag);
    return retFlag;
}
