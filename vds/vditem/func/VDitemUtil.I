/* $Id: VDitemUtil.I,v 1.2 2001/02/11 17:52:17 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdutil/VDutItemUtil.I
 *
 * Description: Misc Utilities for attribute collections
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDitemUtil.I,v $
 *      Revision 1.2  2001/02/11 17:52:17  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/10 18:04:41  art
 *      sp merge
 *
# Revision 1.1  2000/12/06  19:05:30  pinnacle
# Created: vds/vditem/func/VDitemUtil.I by jdsauby for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/29/00  js      Creation
 * 01/10/01  ah      sp merge
 ***************************************************************************/

class implementation Root;
#include "VDtypedef.h"
#include "VDris.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDvla.h"
#include "VDrisc.h"
#include "VDItemDBUtil.h"

/* -----------------------------------------------------------
 * Init TVDitemdbCollAttrs structure 
 * ***/
IGRstat VDitemdbInitCollAttrs(TVDitemdbCollAttrs *list)
{
    IGRstat retFlag = 0;
    IGRstat traceFlag = 0;

    // Argcheck
    if (list == NULL) goto wrapup;

    // say hi
    if (traceFlag) printf (">>> VDitemdbInitCollAttrs\n");
    
    // Clear
    memset(list,0,sizeof(TVDitemdbCollAttrs));

    // Setup
    list->max = 100;
    list->inc = 100;
    list->attrs = malloc(list->max * sizeof(struct ACrg_coll));

    if (list->attrs == NULL) {
	printf("*** Problem allocating memory for TVDitemdbCollAttrs\n");
	goto wrapup;
    }

    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf ("<<< VDitemdbInitCollAttrs <%d>\n",retFlag);
    return retFlag;
}

/* -----------------------------------------------
 * Frees a TVDitemdbCollAttrs structure
 */
IGRstat VDitemdbFreeCollAttrs(TVDitemdbCollAttrs *list)
{
    IGRstat retFlag = 0;
    IGRstat traceFlag = 0;
    
    IGRint  i;

    // Argcheck
    if (list == NULL) goto wrapup;
    if (list->attrs == NULL) goto wrapup;

    // say hi
    if (traceFlag) printf(">>> VDitemdbFreeCollAttrs\n");
    
    // Free the array of pointers
    free(list->attrs);

    // Done
    retFlag = 1;

wrapup:
    if (list) memset(list,0,sizeof(TVDitemdbCollAttrs));
    if (traceFlag) printf("<<< VDitemdbFreeCollAttrs <%d>\n",retFlag);

    return retFlag;
}

/* ----------------------------------------------------------
 * Add an attribute to the TVDitemdbCollAttrs structure
 * ***/
IGRstat VDitemdbAddCollAttr(TVDitemdbCollAttrs *list, struct ACrg_coll *attr)
{
    IGRstat retFlag = 0;
    IGRstat traceFlag = 0;
    
    struct ACrg_coll *attributes;

    // Arg check
    if (attr  == NULL)        goto wrapup;
    if (list == NULL)        goto wrapup;
    if (list->attrs == NULL) goto wrapup;

    // say hi
    if (traceFlag) printf(">>> VDitemdbAddCollAttr\n");

    // Expand list if necessary
    if (list->cnt == list->max) {

	attributes = realloc(list->attrs,(list->max + list->inc) * sizeof(struct ACrg_coll));

	if (attributes == NULL) {
	    printf("*** Problem allocating TVDitemdbCollAttrs list\n");
	    goto wrapup;
	}
	list->attrs = attributes;
	list->max  += list->inc;
    }

    // Add it
    list->attrs[list->cnt] = *attr;
    list->cnt++;

    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< VDitemdbAddCollAttr <%d>\n",retFlag);
    return retFlag;
}

end implementation Root;
