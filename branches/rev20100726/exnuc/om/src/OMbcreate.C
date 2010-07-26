/********************** DB_btree_create **************************/
  
#include "OMDB.h"
#include "OMindex.h"
#include "OMbtreedef.h"

DB_btree_create( key_type, root_page_p )

unsigned char   key_type;
B_LF_PAGE *root_page_p;

{
char	key_mask;

/* Initialize the number of keys in tree to 0 */

*((int *)((char *)root_page_p-sizeof(OM_S_OBJID)-sizeof(int))) = 0;
root_page_p->Page_type = B_LF_RT_PAGE;
root_page_p->Key_type = key_type;
root_page_p->Offset_entry_count = 0;
root_page_p->Space_used = BYTES_B_LF_HEADER;
root_page_p->Key_start = DB_BYTES_BPAGE;
root_page_p->Next_p = NULL_OBJID;
root_page_p->Prior_p = NULL_OBJID;
key_mask = key_type & ( ~ BTREE_NODUP );

if( key_mask == BTREE_INTEGER )
    root_page_p->Nl_key_length = 4;
else if ( key_mask  == BTREE_DOUBLE )
    root_page_p->Nl_key_length = 8;
else if ( key_mask == BTREE_FLOAT )
    root_page_p->Nl_key_length = 4;
else if ( key_mask == BTREE_STRING )
    root_page_p->Nl_key_length = 8;

return( DB_SUCCESS );

}
