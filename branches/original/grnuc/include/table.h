#ifndef TABLE_H
#define TABLE_H

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Include File: table.h                                                     |
 |                                                                           |
 | The file contains all structure definitions for the GRtable               |
 | class.                                                                    |
 |                                                                           |
 | Dependencies:                                                             |
 |                                                                           |
 | tabledef.h                                                                |
 | DIdef.h                                                                   |
 | igrtypedef.h                                                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: Table Column Structure                                           |
 |                                                                           |
 | The following typdef defines a structure which represents the column in a |
 | GRtable.                                                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct GRtable_column_st
{
    IGRint  type; /* GRTBL_DOUBLE or GRTBL_STRING */
    IGRchar name[GRTBL_MAX_NAME]; /* Column name */
} GRtable_column;

typedef struct GRtable_column_info_st
{
    IGRint      type; /* GRTBL_DOUBLE or GRTBL_STRING */
    struct GRid expression_id; /* Expression id */
    IGRchar     name[GRTBL_MAX_NAME]; /* Column name */
} GRtable_column_info; 

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: Table Row Structure                                              |
 |                                                                           |
 | The following typdef defines a structure which represents the row in a    |
 | GRtable.                                                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct GRtable_row_st
{
    IGRchar name[GRTBL_MAX_NAME];
} GRtable_row;

typedef GRtable_row GRtable_row_info;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: Table Cell Structure                                             |
 |                                                                           |
 | The following typdef defines a struct which either store the value of a   |
 | double expression or an index into a string table for a text expression.  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef union GRtable_cell_st
{
    IGRdouble   d;  /* Double or Index into String Table */
} GRtable_cell;

typedef union GRtable_cell_info_un
{
    IGRdouble   d;       /* Double  */
    IGRchar     s[256];  /* String  */
} GRtable_cell_info;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: Table String Structure                                           |
 |                                                                           |
 | The following typdef defines a string structure which is used in storing  |
 | a string expression.                                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef IGRchar GRtable_string[80];

#endif
