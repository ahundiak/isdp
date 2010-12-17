#include <stdio.h>
#include "MEMstruct.h"
/* #include "NFMdb.h" */
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMstruct.h"
typedef struct items_on_tape
{
    char   catalog_name[40];
    char   item_name[60];
    char   revision[60];
    char   storage_area[15];
    char   label[10];
    char   saveset[10];
    char   archive_date[10];
    char   archive_state[10];
    struct items_on_tape *next;
} *it_list;

#include "CMDTproto.h"
