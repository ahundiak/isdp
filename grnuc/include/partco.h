#ifndef partco_include
#define partco_include

struct format
{
    IGRchar attr[MAX_ATTR];
    IGRchar title[MAX_VALUE];
    IGRchar justification[MAX_VALUE];
};

#define CO_create_part          0
#define CO_edit_part            1
#define CO_review_parts         2
#define CO_place_part           3
#define CO_list_parts           4
#define CO_create_parts_list    5
#define CO_add_to_parts_list    6
#define CO_update_parts_list    7

#define CO_PARTS                15
#define CO_NUMBER               17
#define CO_NAME                 18
#define CO_STATIC               12
#define CO_DYNAMIC              19
#define CO_DELETE               20
#define CO_MESSAGE              10
#define CO_ACCEPT               1
#define CO_MODIFY               2
#define CO_CANCEL               4
#define CO_TITLE                11

#define TRUE                    1
#define FALSE                   0

#define CO_ARE_PARTS            0
#define CO_ACTIVE_CELL          1
#define CO_IS_PARTS_LIST        2

#define CO_RESPONSE_MASK        50
#define CO_ACCEPT_RESPONSE      51
#define CO_MODIFY_RESPONSE      52
#define CO_CANCEL_RESPONSE      54

#define CO_part_cell            0
#define CO_parts_list_block     1
#define CO_parts_list_title     2
#define CO_parts_list_divider   3
#define CO_part                 4
#define CO_parts_list           5

#endif
