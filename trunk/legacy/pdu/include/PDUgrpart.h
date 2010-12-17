#include        <igetypedef.h>
#include        <igrtypedef.h>
#include        <gr.h>
#include        <MEMerrordef.h>

struct PDUpart_node
        {
         struct GRid part_id;
         struct PDUpart_node  *next;
        };

struct PDUref_node
        {
         IGRchar              *filename;
         IGRchar              *description;
         struct GRid          ref_id;
         struct  PDUref_node  *next;
        };

struct PDUattach_node
        {
         IGRchar              *catalog_no;
         IGRchar              *item_no;
         IGRchar              *file_name;
         struct  PDUattach_node  *next;
        };

struct PDUpart_dyn_node
        {
         IGRchar              *catalog;
         MEMptr               data_buffer;
         struct  PDUpart_dyn_node *next; 
        };

