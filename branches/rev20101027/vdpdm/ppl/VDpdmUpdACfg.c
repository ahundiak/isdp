 /* $Id: VDpdmUpdACfg.c,v 1.5 2001/03/22 15:14:03 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/ppl/VDpdmUpdACfg.c
 *
 * Description: Update File Key for all files in PDM
 *     This will get all of the files from the vdpdm_file_keys table.
 *     For each file_key, query for the LPD17, LPD18, ... attributes
 *     to determine the files hull_applicability.
 *     for every hull on which a file is applicable, set the is_approved flag to
 *     0 in the vdpdm_hull_cfg table.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmUpdACfg.c,v $
 *      Revision 1.5  2001/03/22 15:14:03  jdsauby
 *      Added some status prints so the user would know what is happening
 *
 *      Revision 1.4  2001/03/09 15:16:22  jdsauby
 *      removed VDpdmACfg.h
 *
 *      Revision 1.3  2001/02/21 13:15:36  jdsauby
 *      CR4088
 *
 *      Revision 1.2  2001/02/16 22:27:58  build
 *      Changed VDris2.h to VDrisc.h
 *
 *      Revision 1.1  2001/02/05 16:39:33  jdsauby
 *      JTS MP CR4088
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDpdm.h"
#include "VDrisc.h"

VDASSERT_FFN("vdpdm/ppl/VDpdmUpdACfg.c");

/* ----------------------------------------------------
 * get a list of all parts and file_keys
 * ***/
static IGRstat getListOfCPR( TVDrisInfo *ris )
{
    VDASSERT_FN("getListOfCPR");
    
    IGRstat retFlag = 1;
    IGRstat sts;

    // arg check
    VDASSERTW( ris );

    // build the query
    sprintf( ris->sql,
	     "Select %s,%s,%s,%s from %s order by %s;",
	     VDPDM_FILE_KEY_COLN_CATALOG,
	     VDPDM_FILE_KEY_COLN_PART,
	     VDPDM_FILE_KEY_COLN_REVISION,
	     VDPDM_FILE_KEY_COLN_FILE_KEY,
	     
	     VDPDM_FILE_KEY_TABLE_NAME,
	     VDPDM_FILE_KEY_COLN_FILE_KEY );

    // doit
    VDrisQuery( ris, NULL );
    
wrapup:
    // say bye
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    return retFlag;
}

/* ----------------------------------------------------
 * function to set approved configurations for all file_keys
 */
IGRstat VDpdmUpdAppConfig()
{
    VDASSERT_FN("VDpdmUpdAppConfig");

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
    
    // get the list of catalog, part, rev and file_key
    UI_status("Getting List of Parts");
    sts = getListOfCPR( &ris );
    if (ris.rows < 1) goto wrapup;

    // cycle through list to set approved hull configurations
    for( i = 0; i < ris.rows; i++ ) {
	j = i * ris.cols;
	VDpdmSetDefaultApprCfgForCPR( ris.buf[j], ris.buf[j+1], ris.buf[j+2] );

	if ( !(i % 100) ) {
	    sprintf (buf,"Processing %d of %d Parts",i,ris.rows);
	    UI_status(buf);
	    printf("%s\n",buf);
	}

    }
    // done
    printf("Processed %d Parts\n",ris.rows);
    retFlag = 1;

    
wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
  
