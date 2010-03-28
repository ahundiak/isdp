/*
 * Class :
 *
 *      GRtable
 *
 * Abstract :
 *
 *      This class provides way to associate a list of value sets with
 *      a set of expression objects.
 *
 *      A table consists of n rows, m columns, and n*m cells. Each column
 *      relates an expression object with a name and a list of possible 
 *      expression values, each row associates a name with a set of values
 *      for a particular set of expression objects, each cell stores a 
 *      value for a particular row and column.
 *
 *      Once the table has been created the GRrun_row message may be sent
 *      to use the rows particular set of values to update the expression
 *      object that that each of it's cells are associated with.
 *
 *      The table will listen to the expression objects that are related to
 *      the columns. If one of the expressions is deleted the column that 
 *      that expression object is related to will automatically be removed.
 *
 * History :
 *
 *      Jay Wallingford     9/22/93  Creation date.
 *      jhw                 11/22/93 Remove union structure.
 *
 */
class specification GRtable (1:1) of GRlistener;

#include <igetypedef.h>
#include <igrtypedef.h>
#include <gr.h>
#include <DIdef.h>
#include <tabledef.h>
#include <table.h>

instance GRtable
{
    variable GRtable_column   columns[0];   /* Columns in table    */
    variable GRtable_row      rows[0];      /* Rows in table       */
    variable GRtable_cell     cells[0];     /* Data entries        */
    variable GRtable_string   strings[0];   /* String data storage */
    channel {(many_to_many,
              rel_ordered,
              initial = 0,
              increment = 1)} to_notify;    /* Column expressions */
};

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRcreate                                                         |
 |                                                                           |
 | This message creates a table.                                             |
 |                                                                           |
 | Input:   IGRint                num_columns      Number of columns.        |
 |          GRtable_column_info * columns          Column information.       |
 |          IGRint                num_rows         Number of rows.           |
 |          GRtable_row_info    * rows             Row information.          |
 |          GRtable_cell_info   * cells            Cell Data.                |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Catostrophic error.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRcreate (IGRlong              * msg;
                  IGRint                 num_columns;
                  GRtable_column_info  * columns;
                  IGRint                 num_rows;
                  GRtable_row_info     * rows;
                  GRtable_cell_info    * cells);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRadd_column                                                     |
 |                                                                           |
 | This message adds a column to the GRtable.                                |
 |                                                                           |
 | Input:   GRtable_column_info * column           Column to add.            |
 |                                                                           |
 | Output:  IGRlong             * msg              Return code.              |
 |          IGRint              * number           Column number [0...n].    |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column already exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRadd_column (IGRlong             * msg;
                      GRtable_column_info * column;
                      IGRint              * number);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRnum_columns                                                    |
 |                                                                           |
 | This message returns the number of columns in the GRtable.                |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |          IGRint          * num_columns      Number of columns.            |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRnum_columns (IGRlong * msg; 
                       IGRint  * num_columns);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRget_column                                                     |
 |                                                                           |
 | This message returns a column from the GRtable.                           |
 |                                                                           |
 | Input:   IGRint              * number       Number of column.             |
 |          IGRchar             * name         Name of column                |
 |                                                                           |
 | Output:  IGRlong             * msg          Return code.                  |
 |          GRtable_column_info * column       Column.                       |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRget_column (IGRlong             * msg; 
                      IGRint              * number;
                      IGRchar             * name;
                      GRtable_column_info * column);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRget_column_number                                              |
 |                                                                           |
 | This message returns the number that cooresponds to a column name.        |
 |                                                                           |
 | Input:   IGRchar         * name             Name of column                |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |          IGRint          * number           Number of column.             |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRget_column_number (IGRlong        * msg; 
                             IGRchar        * name;
                             IGRint         * number); 
                     
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRmod_column                                                     |
 |                                                                           |
 | This message modifies a column in the GRtable.                            |
 |                                                                           |
 | Input:   IGRint              * number       Number of column.             |
 |          IGRchar             * name         Name of the column.           |
 |          GRtable_column_info * column       New column.                   |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRmod_column (IGRlong             * msg; 
                      IGRint              * number;
                      IGRchar             * name;
                      GRtable_column_info * column);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRrem_column                                                     |
 |                                                                           |
 | This message removes a column from the GRtable.                           |
 |                                                                           |
 | Input:   IGRint          * number           Number of column.             |
 |          IGRchar         * name             Name of column.               |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRrem_column (IGRlong * msg; IGRint * number; IGRchar * name);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRconnect_expression                                             |
 |                                                                           |
 | This message connects an expression object to the listeners channel.      |
 |                                                                           |
 | Input:   struct GRid         * expression_id    Expression id.            |
 |                                                                           |
 | Output:  IGRlong             * msg              Return code.              |
 |          IGRint              * index            Index on channel.         |
 |          IGRint              * type             Type of expression.       |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column already exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRconnect_expression (IGRlong     * msg;
                              struct GRid * expression_id;
                              IGRint      * index;
                              IGRint      * type);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRget_expression                                                 |
 |                                                                           |
 | This message returns an expression object from the listeners channel.     |
 |                                                                           |
 | Input:   IGRint                index            Index on channel.         |
 |                                                                           |
 | Output:  IGRlong             * msg              Return code.              |
 |          struct GRid         * expression_id    Expression id.            |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column already exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRget_expression (IGRlong     * msg;
                          IGRint        index;
                          struct GRid * expression_id);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRdisconnect_expression                                          |
 |                                                                           |
 | This message disconnects an expression object to the listeners channel.   |
 |                                                                           |
 | Input:   IGRint                index            Index on channel.         |
 |          struct GRid         * expression_id    Expression id.            |
 |                                                                           |
 | Output:  IGRlong             * msg              Return code.              |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column already exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRdisconnect_expression (IGRlong     * msg;
                                 IGRint        index;
                                 struct GRid * expression_id);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRrun_row                                                        |
 |                                                                           |
 | This message updates the expressions that are related to table columns    |
 | with the values of the specified row.                                     |
 |                                                                           |
 | Input:   IGRint          * number        Number of the row.               |
 |          IGRchar         * name          Name of the row.                 |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Catostrophic error.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRrun_row (IGRlong * msg; IGRint * number; IGRchar * name);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRadd_row                                                        |
 |                                                                           |
 | This message adds a row to the GRtable.                                   |
 |                                                                           |
 | Input:   GRtable_row     * row           Row to add.                      |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |          IGRint          * number        Row number [0...n].              |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRadd_row (IGRlong          * msg;
                   GRtable_row_info * row;
                   IGRint           * number);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRnum_rows                                                       |
 |                                                                           |
 | This message returns the number of rows in the GRtable.                   |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |          IGRint          * num_rows      Number of rows.                  |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/row doesn't exists.                 |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRnum_rows (IGRlong * msg; 
                    IGRint  * num_rows);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRget_row                                                        |
 |                                                                           |
 | This message returns a row from the GRtable.                              |
 |                                                                           |
 | Input:   IGRint           * number       Number of row [0 ... n].         |
 |          IGRchar          * name         Name of row.                     |
 |                                                                           |
 | Output:  IGRlong          * msg          Return code.                     |
 |          GRtable_row_info * row          Row.                             |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row doesn't exist.                             |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRget_row (IGRlong          * msg; 
                   IGRint           * number;
                   IGRchar          * name;
                   GRtable_row_info * row);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRget_row_number                                                 |
 |                                                                           |
 | This message returns the number that cooresponds to a row name.           |
 |                                                                           |
 | Input:   IGRchar         * name             Name of row.                  |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |          IGRint          * number           Number of row.                |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRget_row_number (IGRlong        * msg; 
                          IGRchar        * name;
                          IGRint         * number);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRmod_row                                                        |
 |                                                                           |
 | This message modifies a row in the GRtable.                               |
 |                                                                           |
 | Input:   IGRint           * number       Number of row.                   |
 |          IGRchar          * name         Name of row.                     |
 |          GRtable_row_info * row          New row.                         |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row doesn't exists.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRmod_row (IGRlong          * msg; 
                   IGRint           * number;
                   IGRchar          * name;
                   GRtable_row_info * row);
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRrem_row                                                        |
 |                                                                           |
 | This message removes a row from the GRtable.                              |
 |                                                                           |
 | Input:   IGRint          * number        Number of row.                   |
 |          IGRchar         * name          Name of row.                     |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row doesn't exist.                             |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRrem_row (IGRlong * msg; IGRint * number; IGRchar * name);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRmod_cell                                                       |
 |                                                                           |
 | This message modifies data for a row and column in the GRtable.           |
 |                                                                           |
 | Input:   IGRint              row         Number of the row.               |
 |          IGRint              column      Number of the column.            |
 |          GRtable_cell_info * cell        Data.                            |
 |                                                                           |
 | Output:  IGRlong           * msg         Return code.                     |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row or column doesn't exist.                   |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRmod_cell (IGRlong           * msg;
                    IGRint              row;
                    IGRint              column;
                    GRtable_cell_info * cell);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRget_cell                                                       |
 |                                                                           |
 | This message gets data for a row and column in the GRtable.               |
 |                                                                           |
 | Input:   IGRint              row         Number of the row.               |
 |          IGRint              column      Number of the column.            |
 |                                                                           |
 | Output:  IGRlong           * msg         Return code.                     |
 |          GRtable_cell_info * cell        Data.                            |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row or column doesn't exist.                   |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRget_cell (IGRlong           * msg;
                    IGRint              row;
                    IGRint              column;
                    GRtable_cell_info * cell);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRadd_string                                                     |
 |                                                                           |
 | This message adds a string to the string storage array and returns the    |
 | index of that string in the storage.                                      |
 |                                                                           |
 | Input:   IGRchar           * string      String to add.                   |
 |                                                                           |
 | Output:  IGRlong           * msg         Return code.                     |
 |          IGRint            * index       Index into string storage.       |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row or column doesn't exist.                   |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRadd_string (IGRlong * msg; IGRchar * string; IGRint * index);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRmod_string                                                     |
 |                                                                           |
 | This message modifies a string in the string storage array.               |
 |                                                                           |
 | Input:   IGRint              index       Index into string storage.       |
 |          IGRchar           * string      New string.                      |
 |                                                                           |
 | Output:  IGRlong           * msg         Return code.                     |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row or column doesn't exist.                   |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRmod_string (IGRlong * msg; IGRint index; IGRchar * string);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: GRrem_string                                                     |
 |                                                                           |
 | This message removes a string from the string storage array. It will      |
 | automatically adjust the indexes stored in the cells array.               |
 |                                                                           |
 | Input:   IGRint              index       Index into string storage.       |
 |                                                                           |
 | Output:  IGRlong           * msg         Return code.                     |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row or column doesn't exist.                   |
 |                                                                           |
 *---------------------------------------------------------------------------*/
message GRrem_string (IGRlong * msg; IGRint index);

override GRnotifylis;

end specification GRtable;






