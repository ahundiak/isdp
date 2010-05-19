 /* $Id: VDpdmRefList.C,v 1.9 2002/02/28 16:13:58 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdmRefList.C
 *
 * Description: Functions required to check hull approved configuration
 *              on startup of VDS.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmRefList.C,v $
 *      Revision 1.9  2002/02/28 16:13:58  jdsauby
 *      TR 6059 and 6053
 *
 *      Revision 1.8  2001/10/29 17:19:19  jdsauby
 *      performance upgrades for "Updating PDM Information" status msg - jds
 *
 *      Revision 1.7  2001/10/16 15:26:14  jdsauby
 *      speed up the check approved config validation
 *
 *      Revision 1.6  2001/10/03 14:06:23  jdsauby
 *      Utilize COset_trace for debug
 *
 *      Revision 1.5  2001/07/16 13:54:11  jdsauby
 *      VDassert working with Z D F
 *
 *      Revision 1.4  2001/04/12 20:42:46  jdsauby
 *      sp 11
 *
 *      Revision 1.3  2001/03/02 21:45:09  jdsauby
 *      Added purpose Info
 *
 *      Revision 1.2  2001/02/21 21:58:20  jdsauby
 *      Just keeping the server up to date
 *
 *      Revision 1.1  2001/02/21 13:01:42  jdsauby
 *      CR4088
 *
 *
 *      Revision 1.1  2001/02/05 16:38:42  jdsauby
 *      JTS MP CR4088, initial creation
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/13/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedef.h"
#include "VDpdm.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "vdrefmacros.h"
//#include "time.h"
//#include "VDrisc.h"
//#include "DIdef.h"          /* DI_PATH_MAX                                  */
//#include "DItypedef.h"
//#include "DIglob.h"
//#include "DIprims.h"

VDASSERT_FFN("vdpdm/func/VDpdmRefList.C");

/* --------------------------------------------------
 * Initializes a VDpdmRefList structure
 */
IGRstat VDpdmInitRefList( TVDpdmRefList  *list )
{
    VDASSERT_FN("VDpdmInitRefList");

    IGRstat retFlag = 0;
    

    // Argcheck
    if (list == NULL) goto wrapup;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf (">>> VDpdmInitRefList\n");

    // Clear
    memset(list,0,sizeof(TVDpdmRefList));

    // Setup
    list->max = 100;
    list->inc = 100;
    list->infos = malloc(list->max * sizeof(TVDpdmInfo));

    if (list->infos == NULL) {
	printf("*** Problem allocating memory for TVDpdmRefList\n");
	goto wrapup;
    }

    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf ("<<< VDpdmInitRefList <%d>\n",retFlag);
    return retFlag;
}

/* ------------------------------------------------
 * Adds a part to the TVDpdmRefList structure
 */
IGRstat VDpdmAddPartToRefList( TVDpdmRefList  *list,
                               TVDpdmInfo     *part )
{
    VDASSERT_FN("VDpdmAddPartToRefList");
    IGRstat retFlag = 0;
    
    TVDpdmInfo  *parts;

    // Arg check
    if (part == NULL)        goto wrapup;
    if (list == NULL)        goto wrapup;
    if (list->infos == NULL) goto wrapup;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> VDpdmAddPartToRefList\n");

    // Expand list if necessary
    if (list->cnt == list->max) {

	parts = realloc(list->infos,(list->max + list->inc) * sizeof(TVDpdmInfo));

	if (parts == NULL) {
	    printf("*** Problem allocating TVDpdmRefList list\n");
	    goto wrapup;
	}
	list->infos = parts;
	list->max  += list->inc;
    }

    // Add it
    list->infos[list->cnt] = *part;
    list->cnt++;

    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< VDpdmAddPartToRefList <%d>\n",retFlag);
    return retFlag;
}

/* -----------------------------------------------
 * Frees a TVDpdmRefList structure
 */
IGRstat VDpdmFreeRefList( TVDpdmRefList *list )
{
    VDASSERT_FN("VDpdmFreeRefList");
    IGRstat retFlag = 0;
    
    IGRint  i;

    // Argcheck
    if (list == NULL) goto wrapup;
    if (list->infos == NULL) goto wrapup;

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);
    if (traceFlag) printf(">>> VDpdmFreeRefList\n");
    
    // Free the array of pointers
    free(list->infos);

    // Done
    retFlag = 1;

wrapup:
    if (list) memset(list,0,sizeof(TVDpdmRefList));
    if (traceFlag) printf("<<< VDpdmFreeRefList <%d>\n",retFlag);

    return retFlag;
}

/* -----------------------------------------------
 * Get the list of reference files from the directory commands form
 * Store them into the refList structure
 */
IGRstat VDpdmGetRefList( VDosnum       osnum,
                         TVDpdmRefList *reflist )
{
    IGRstat     retFlag = 0;
    IGRstat     sts,msg;
    IGRint      NbOs,i;
    VDosnum     *osList  = NULL;
    TGRmd_env   *envList = NULL;
    TVDpdmInfo  info;

    // arg check
    if (!reflist) goto wrapup;

    // check the osnum, set to active if not given
    if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod( osnum = &osnum );

    // get the reflist
    NbOs = 0;
    sts = vd$get_ref_os_list(
	    msg          = &msg,
	    main_os      = &osnum,
	    num_ref_os   = &NbOs,
	    ref_os_list  = &osList,
	    ref_env_list = &envList );
    if (sts == MSFAIL) goto wrapup;

    // loop through and add
    for (i = 0; i < NbOs; i++) {

	// init info
	memset(&info,0,sizeof(info));

	// update PDMinfo of ref os
	//sts = VDpdmUpdatePdmInfo( osList[i] );
	//if (!(sts & 1)) goto wrapup;
	
	// get the pdmInfo of the ref os
	sts = VDpdmGetPdmInfo( osList[i], &info );
	if (info.filekey < 1) {
	    // update, and try again
	    sts = VDpdmUpdatePdmInfo( osList[i] );
	    if (!(sts & 1)) goto wrapup;

	    sts = VDpdmGetPdmInfo( osList[i], &info );
	    if (!(sts & 1)) goto wrapup;
	}

	// add it to reflist
	sts = VDpdmAddPartToRefList( reflist, &info );
	if (!(sts & 1)) goto wrapup;	
    }

    // done
    retFlag = 1;

wrapup:
    // Free
    if (osList)  free(osList);
    if (envList) free(envList);
    return retFlag;
}

/* -------------------------------------------
 * check to see if a revision is valid.  A valid
 * revision is defined as one with only numeric characters.
 */
IGRstat VDpdmIsRevisionValid(IGRchar *revision)
{
    VDASSERT_FN("VDpdmIsRevisionValid");

    IGRstat retFlag = 0;

    IGRchar rev[80];
    IGRint  i;

    // Arg Check
    VDASSERTW(revision);

    // check if any alpha characters.
    strcpy(rev,revision);

    for (i = 0; i < strlen(rev); i++) {
	if ( (rev[i] < '0') || (rev[i] > '9') ) goto wrapup;
    }

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

   



