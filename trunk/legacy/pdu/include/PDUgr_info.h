#include        <igetypedef.h>
#include        <igrtypedef.h>
#include        <gr.h>

struct PDU_GRpart_info
        {
         struct  GRid           part_id;
         char                   *catalog;
         char                   *partnum;
         char                   *revision;
         char                   **attributes;
         char                   **values;
         int                    *attribute_types;
         int                    attribute_count;
         struct  GRid           *component_ids;
         int                    max_comp_count; 
         struct  PDU_GRpart_info *next; 
        };

