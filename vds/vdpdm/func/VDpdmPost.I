/* $Id: VDpdmPost.I,v 1.2 2001/04/24 20:41:52 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdmPost.I
 *
 * Description:	Posting of Vdpdm stuff.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/08/01  js      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"

#include "VDobj.h"
#include "VDexp.h"
#include "VDdir.h"
#include "VDos.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "time.h"
#include "VDDbDef.h"

/* --------------------------------------------------
 * Routine called from vds/vdcheckin/imp/VDScheckin.I.
 * Calls the other specific post routines.
 * **/
IGRstat VDpdmPostAll()
{
    IGRstat retFlag = 1;
    IGRstat sts;

    VDosnum cur_os = OM_K_NOT_AN_OS;

    // get the cur_os
    ex$get_cur_mod(osnum = &cur_os);
    if (cur_os == OM_K_NOT_AN_OS) goto wrapup;
    
    // verify logged in
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;
    
    /* ------ Notebooks are posted via a seperate command ---- */
    // post notebooks
    //VDpdmPostNb( cur_os );

    // post macros
    VDpdmPostMacro( cur_os );

    // done

wrapup:
    return retFlag;
}

/* ------------------------------------------------
 * Insert or update the dynamic table timestamp record
 * **/
static IGRstat postTimestampRecord( IGRint   fkey,
                                    IGRchar  *table )
{
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[1024];

    time_t current_time;
    struct tm *tm;
    IGRchar cur_date[40];

    TVDrisInfo  ris;

    VDrisInitInfo( &ris );

    if (fkey < 1)    goto wrapup;
    if (*table == 0) goto wrapup;

    // verify that the table exists
    if (VdsVerifyRisTable(VDPDM_POST_DATE_TABLE_NAME) != VDS_DBTABLE_FOUND)
	goto wrapup;

    // is there an existing record
    sprintf(ris.sql,
	    "Select * from %s where %s=%d and %s='%s';",
	    VDPDM_POST_DATE_TABLE_NAME,
	    VDPDM_POST_DATE_COLN_FILEKEY, fkey,
	    VDPDM_POST_DATE_COLN_DB_TABLE, table);

    VDrisQuery( &ris, NULL );

    // set time stamp
    time(&current_time);
    tm = localtime(&current_time);
    sprintf(cur_date,
	    "%4d-%02d-%02d %02d:%02d:%02d",
	    tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	    tm->tm_hour,tm->tm_min,tm->tm_sec);

    
    if (ris.rows < 1) {
	// insert a record
	sprintf(sql,
		"Insert into %s values (%d,'%s','%s');",
		VDPDM_POST_DATE_TABLE_NAME, fkey, table, cur_date);
	sts = VDrisExecute( sql );
	if (!(sts & 1)) goto wrapup;
	retFlag = 1;
	goto wrapup;
    }
    
    // update it, done
    sprintf(sql,
	    "Update %s set %s='%s' where %s=%d and %s='%s';",
	    VDPDM_POST_DATE_TABLE_NAME,
	    VDPDM_POST_DATE_COLN_POST_DATE, cur_date,
	    VDPDM_POST_DATE_COLN_FILEKEY, fkey,
	    VDPDM_POST_DATE_COLN_DB_TABLE, table);

    sts = VDrisExecute( sql );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}

/* -------------------------------------------------
 * Places a post_date record for the input dynamic table
 * **/
IGRstat VDpdmPostTableTimestamp( IGRchar  *dyn_table )
{
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  fkey = 0;



    VDosnum  cur_os = OM_K_NOT_AN_OS;

    // Arg Check
    if (*dyn_table == 0) goto wrapup;

    // get the current OS
    ex$get_cur_mod(osnum = &cur_os);
    if (cur_os == OM_K_NOT_AN_OS) goto wrapup;

    // verify logged in
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;

    // get the filekey for the os
    VDpdmGetFilekeyForOS( cur_os, &fkey);
    if (fkey < 1) goto wrapup;

    // post the record
    sts = postTimestampRecord(fkey,dyn_table);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}


end implementation Root;






