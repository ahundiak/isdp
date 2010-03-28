/*******************************************************************************

partdef.h

General Description:

    This file contains all defines used by the GRpart class, including
    defines for the part macros.

Dependencies:

    None

History:

     2/9/90   Jay Wallingford     Creation Date
   10/10/91   Shelley Heard       Added #defines for standard attribute names

*******************************************************************************/

#ifndef partdef_include
#define partdef_include

/*
 * Function indexes for COpart_attr_func.
 */
#define CO_part_put         0
#define CO_part_get         1
#define CO_part_rem         2
#define CO_part_all         3
#define CO_part_template    4

/*
 * Function indexes for COpart_list_func.
 */
#define CO_part_write_to_file       0
#define CO_part_add_to_partslist    1
#define CO_part_update_partslist    2

/*
 * Misc error messages.
 */
#define CO_E_NO_CELL            ( 0x00005550 )
#define CO_E_NOTPARTCELL        ( 0x00005552 )
#define CO_E_NO_PARTSLIST       ( 0x00005554 )
#define CO_E_PART_ON_LIST       ( 0x00005556 )
#define CO_E_PARTSLIST_ERROR    ( 0x00005558 )
#define CO_E_PART_IS_LIST       ( 0x00005560 )

/*
 * Standard attribute names
 */
#define CATALOG_NAME            "CATALOG"
#define NUMBER_NAME             "NUMBER"
#define REVISION_NAME           "REVISION"
#define DESCRIPTION_NAME        "NAME"

#define  _is_unique_attr(attr) ( !strcmp (attr, CATALOG_NAME )   || \
                                 !strcmp (attr, NUMBER_NAME)     || \
                                 !strcmp (attr, REVISION_NAME)   || \
                                 !strcmp (attr, DESCRIPTION_NAME ))

#endif
