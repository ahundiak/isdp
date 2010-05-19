 /* $Id: VDpdmMacros.I,v 1.4 2001/10/03 14:06:21 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdm/VDpdmMacros.I
 *
 * Description: Posting Macros functions
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
class implementation Root;

#include "VDtypedef.h"
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "time.h"
#include "VDDbDef.h"
#include "VDmac.h"

VDASSERT_FFN("vdpdm/func/VDpdmMacros.I");

/* ------------------------------------------
 * Clean the existing macro records for a given filekey
 * **/
IGRstat VDpdmCleanMacroRecord( IGRint filekey )
{
    VDASSERT_FN("VDpdmCleanMacroRecord");
    IGRstat retFlag = 1;
    IGRstat sts;

    TVDrisInfo  ris;
    IGRchar     sql[256];

    // Arg Check
    VDrisInitInfo( &ris );
    VDASSERTW(filekey > 0);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_MACRO);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // is there any existing records
    sprintf(ris.sql,
	    "Select * from %s where %s=%d;",
	    VDPDM_MACRO_TABLE_NAME,
	    VDPDM_MACRO_COLN_FILE_KEY, filekey);

    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // records were found, clean them
    sprintf(sql, "Delete from %s where %s=%d;",
	    VDPDM_MACRO_TABLE_NAME,
	    VDPDM_MACRO_COLN_FILE_KEY, filekey);

    sts = VDrisExecute( sql );
    if (!(sts & 1)) {
	retFlag = 0;
	goto wrapup;
    }

    // done
wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
/* ------------------------------------------
 * post the macro record.
 * **/
static IGRstat postMacroRecord( IGRint       filekey,
                                VDdgnMcInfo *mac_info )
{
    VDASSERT_FN("postMacroRecord");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar     sql[1024];
    IGRint      symbol;

    time_t current_time;
    struct tm *tm;
    IGRchar cur_date[40];
    
    // Arg Check
    VDASSERTW(mac_info);
    VDASSERTW(*mac_info->macro_name != 0);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_MACRO);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the cur_date
    time(&current_time);
    tm = localtime(&current_time);
    sprintf(cur_date,
	    "%4d-%02d-%02d %02d:%02d:%02d",
	    tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	    tm->tm_hour,tm->tm_min,tm->tm_sec);
    
    // in with the new
    if (mac_info->is_symbol == TRUE) symbol = 1;
    else                             symbol = 0;
    
    sprintf(sql,
	    "Insert into %s values (%d,'%s','%s',%d,%d,'%s');",
	    VDPDM_MACRO_TABLE_NAME,
	    filekey, mac_info->library_name,
	    mac_info->macro_name, mac_info->occurrence_count,
	    symbol, cur_date );

    // do it
    sts = VDrisExecute( sql );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

    

/* -------------------------------------------
 * Called from Post Attributes command.  Standalone 
 * posting of all macros in the os.
 * **/
IGRstat VDpdmPostMacro( VDosnum cur_os )
{
    VDASSERT_FN("VDpdmPostMacro");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;

    IGRint       filekey;
    VDdgnMcInfo  *mac_list;
    IGRlong      msg;
    IGRint       mac_cnt;


    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_MACRO);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // does the table exist for posting
    if ( VdsVerifyRisTable( VDPDM_MACRO_TABLE_NAME ) != VDS_DBTABLE_FOUND )
           goto wrapup;

    // need a filekey
    VDpdmGetFilekeyForOS( cur_os, &filekey );
    if (filekey < 1) goto wrapup;

    // get the macros
    VDdgnGetActiveMacros(&msg, &mac_cnt, &mac_list);
    if (msg != MSSUCC) goto wrapup;

    // out with the old stuff
    VDpdmCleanMacroRecord( filekey );

    // post each macro_info
    for (i = 0; i < mac_cnt; i++) {
	sts = postMacroRecord( filekey, &mac_list[i] );
	if (!(sts & 1)) {
	    printf("Macro %s did not post\n",mac_list[i].macro_name);
	}
    }

    // timestamp the table
    VDpdmPostTableTimestamp(VDPDM_MACRO_TABLE_NAME);

    // done
    retFlag = 1;

wrapup:
    if (mac_list) free(&mac_list);
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

end implementation Root;
