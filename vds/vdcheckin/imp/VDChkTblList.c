 /* $Id: VDChkTblList.c,v 1.1 2001/04/24 20:34:06 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdcheckin/imp/VDChkTblList.C
 *
 * Description: Table list functions for timestamping posted tables
 *
 * Dependencies:
 *
 * Revision History:
 *       
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/24/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDpdm.h"
#include "VDChkTblLst.h"

static VDTableList tables;

/* -------------------------------------------------
 * initialize the VDTableList structure
 * **/
void VDChkInitTableList()
{
    //printf(">>> VDChkInitTableList Art\n");

    // do it
    memset(&tables,0,sizeof(VDTableList));
    tables.cnt = 0;
    tables.init = 1;

wrapup:
    //printf("<<< VDChkInitTableList\n");
    return;
}

/* ------------------------------------------------
 * free the VDTableList structure
 * **/
void VDChkFreeTableList()
{
    int i;


    //printf(">>> VDChkFreeTableList\n");
    
    // free each entry
    for (i = 0; i < tables.cnt; i++) free(tables.list[i]);

    // reset some values
    tables.cnt = 0;
    tables.init = 0;

    // free the list
    free(tables.list);

wrapup:
    //printf("<<< VDChkFreeTableList\n");
    return;
}

/* ------------------------------------------------
 * add a table to the VDTableList structure
 * **/
void VDChkAddTableToList( char  *table)
{
    int i;


    // Arg check
    if ( (!table) || (*table == 0) ) goto wrapup;
    
    //printf(">>> VDChkAddTableToList <%s>\n",table);
    
    // make sure a table of the same name is not already in the list
    for (i = 0; i < tables.cnt; i++) {
	if (!strcmp(tables.list[i],table)) goto wrapup;
    }

    //printf("### VDChkAddTableToList <%s>\n",table);
    // none found, add it
    tables.list = (char**) realloc( tables.list, (tables.cnt + 1) * sizeof(char*) );
    if (tables.list == NULL) {
	printf("### problem allocating table list\n");
	goto wrapup;
    }
    
    tables.list[tables.cnt] = (char*) malloc( 80 * sizeof(char) );
    
    strcpy(tables.list[tables.cnt],table);
    tables.cnt++;

    // done
wrapup:
    //printf("<<< VDChkAddTableToList\n");
    return;
}

/* ------------------------------------------------
 * Returns the table list, and count
 * */
void VDChkGetTableList(int     *cnt,
                       char  ***list)
{
    if (cnt == NULL)  goto wrapup;
    if (list == NULL) goto wrapup;

    // just set it
    *cnt = tables.cnt;
    *list = tables.list;

    // done
wrapup:
    return;
}
