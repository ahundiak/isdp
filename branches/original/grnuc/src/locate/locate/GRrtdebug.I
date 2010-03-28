/*
Name
        GRrtree.debug

Description
        The debug method is overridden to dump the rtree object's instance
        data to the screen.

History
        mrm     02/24/92    creation
*/

class implementation GRrtree;

#include <stdio.h>
#include "OMrtreedef.h"

method debug()
{
    int i, j, count, dup, valid;
    char *c, buf[16];
    R_PAGE_3D_FLT *page;

    printf("GRrtree.debug\n");
    printf("me->count = %d\n", me->count);
    printf("me->objid = %d\n", me->objid);
    page = (R_PAGE_3D_FLT *)me->tree_page;
    if (page->Header.Page_type == DATA_PAGE)            c = "DATA_PAGE";
    else if (page->Header.Page_type ==  R_LF_RT_PAGE)   c = "R_LF_RT_PAGE";
    else if (page->Header.Page_type ==  R_NL_RT_PAGE)   c = "R_NL_RT_PAGE";
    else if (page->Header.Page_type ==  R_LF_NR_PAGE)   c = "R_LF_NR_PAGE";
    else if (page->Header.Page_type ==  R_NL_NR_PAGE)   c = "R_NL_NR_PAGE";
    else if (page->Header.Page_type ==  B_LF_RT_PAGE)   c = "B_LF_RT_PAGE";
    else if (page->Header.Page_type ==  B_NL_RT_PAGE)   c = "B_NL_RT_PAGE";
    else if (page->Header.Page_type ==  B_LF_NR_PAGE)   c = "B_LF_NR_PAGE";
    else if (page->Header.Page_type ==  B_NL_NR_PAGE)   c = "B_NL_NR_PAGE";
    else c = "Unknown";
    printf("page->Header.Page_type = %s (%d)\n", c, page->Header.Page_type);
    if (page->Header.Rtree_type == RTREE_3D_DBL)        c = "RTREE_3D_DBL";
    else if (page->Header.Rtree_type == BTREE_STRING)   c = "BTREE_STRING";
    else if (page->Header.Rtree_type == BTREE_INTEGER)  c = "BTREE_INTEGER";
    else if (page->Header.Rtree_type == BTREE_DOUBLE)   c = "BTREE_DOUBLE";
    else c = "Unknown";
    printf("page->Header.Rtree_type = %s (%d)\n", c, page->Header.Rtree_type);
    printf("page->Header.Key_count = %d\n", page->Header.Key_count);
    printf("page->Header.Page_count = %d\n", page->Header.Page_count);
    count = MIN(page->Header.Key_count, R_MAX_KEYS_3D_FLT);
    for (i = 0; i < count; i++)
    {
        /* check for valid object id */
        valid = (om$is_objid_valid(objid = page->Objid[i]) == OM_S_SUCCESS);

        /* check for duplicate entries on this page */
        for (j = 0, dup = 0; j < count; j++)
            if (i != j && page->Objid[i] == page->Objid[j])
                dup++;

        /* print the info */
        printf("%2d %4d %c %s %9.3f, %9.3f, %9.3f; %9.3f, %9.3f, %9.3f\n",
               i, page->Objid[i], (valid) ? ' ' : 'I',
               (dup) ? (sprintf(buf, "%d", ++dup) ? buf : "") : "", 
               page->Key[i].xmin, page->Key[i].ymin, page->Key[i].zmin,
               page->Key[i].xmax, page->Key[i].ymax, page->Key[i].zmax);
    }
    return(OM_S_SUCCESS);
}

end implementation GRrtree;
