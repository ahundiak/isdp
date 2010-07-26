/*
 * Class Implementation:
 *
 *      GRtable
 *
 * Abstract :
 *
 *      This file defines all Method for the GRtable class.
 *
 * History :
 *
 *      Jay Wallingford     9/22/93  Creation date.
 *      jhw                 11/22/93 Remove union structure.
 *
 */
class implementation GRtable;

#include <OMerrordef.h>
#include <OMmacros.h>
#include <msdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <nddef.h>
#include <ndmacros.h>
#include <expression.h>
#include <expmacros.h>
#include <alloca.h>
#include <godef.h>

from GRnotify import GRntfyconn, GRntfydisconn;

extern OMuword OPP_expression_class_id, OPP_text_exp_class_id;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRcreate                                                          |
 |                                                                           |
 | This method creates a table.                                              |
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
method GRcreate (IGRlong             * msg;
                 IGRint                num_columns;
                 GRtable_column_info * columns;
                 IGRint                num_rows;
                 GRtable_row_info    * rows;
                 GRtable_cell_info   * cells)
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          i, j, count, index;
    
    *msg = MSSUCC;

    if (num_columns > 0)
    {
        /*
         * Set the column information.
         */
        om_msg = om$vla_set_dimension (varray = me->columns, 
                                       size = num_columns);
        
        if (!(om_msg & 1))
        {
            goto quit;
        }
        
        for (i=0; i<num_columns; ++i)
        {
            strcpy (me->columns[i].name, columns[i].name);
            
            /*
             * Attach the expression to the listener channel and
             * save the index.
             */ 
            om_msg = om$send (msg = message GRtable.GRconnect_expression    
                                                   (msg,
                                                    &columns[i].expression_id,
                                                    &index,
                                                    &me->columns[i].type),
                              targetid = my_id);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            /*
             * This should never occur since the columns index into the
             * vla should always equal the expression index on the channel.
             */
            if (index != i)
            {
                *msg = MSFAIL;
                goto quit;
            }
        }
        
        if (num_rows > 0)
        {
            /*
             * Set the row information.
             */
            om_msg = om$vla_set_dimension (varray = me->rows, 
                                           size = num_rows);
            
            if (!(om_msg & 1))
            {
                goto quit;
            }
        
            /*
             * It's OK to blkcpy from a GRtable_row_info to a GRtable_row
             * since it's the same structure.
             */
            OM_BLOCK_MOVE (rows, 
                           &me->rows[0], 
                           num_rows * sizeof(GRtable_row));


            /*
             * Setup the cell entries.
             */
            om_msg = om$vla_set_dimension (varray = me->cells, 
                                           size = num_rows * num_columns);
        
            if (!(om_msg & 1))
            {
                goto quit;
            }

            /*
             * Initialize the cells ...
             */
            count = num_columns * num_rows;
            
            for (i=0; i<num_rows; ++i)
            {
                for (j=0; j<num_columns; ++j)
                {
                    index = (i * num_columns) + j;
                    
                    if (me->columns[j].type == GRTBL_DOUBLE)
                    {
                        me->cells[index].d = (cells) ? cells[index].d : 0.0;
                    }
                    else
                    {
                        IGRint strndx;
                        
                        om_msg = om$send (msg = message GRtable.GRadd_string
                                                 (msg, 
                                                  (cells) ? cells[index].s : "",
                                                  &strndx),
                                          targetid = my_id);
            
                        if (!(om_msg & *msg & 1))
                        {
                            goto quit;
                        }
                    
                        me->cells[strndx].d = index;
                    }
                }
            }
        }
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRconnect_expression                                              |
 |                                                                           |
 | This method connects an expression object to the listeners channel.       |
 |                                                                           |
 | Input:   struct GRid         * expression_id    Expression id.            |
 |                                                                           |
 | Output:  IGRlong             * msg              Return code.              |
 |          IGRint              * index            Index on channel.         |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column already exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method GRconnect_expression (IGRlong     * msg;
                             struct GRid * expression_id;
                             IGRint      * index;
                             IGRint      * type)
{
    IGRlong         om_msg;
    OM_S_CHANSELECT chansel;
    IGRint          loc_index = OM_K_MAXINT;
    struct GRid     my_grid;
    IGRboolean      tagged = FALSE;
    GRspacenum      osnum;

    om_msg = om$make_chanselect (channame = "GRtable.to_notify",
                                 p_chanselect = &chansel);
        
    if (!(om_msg & 1))
    {
        goto quit;
    }

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    osnum = OM_Gw_current_OS;
    
    /*
     * Connect to the listener channel.
     */
    om_msg = om$send (msg = message GRnotify.GRntfyconn (msg,
                                                         &my_grid,
                                                         &chansel,
                                                         &loc_index,
                                                         &tagged,
                                                         &osnum),
                      targetid = expression_id->objid,
                      targetos = expression_id->osnum);

    if (!(om_msg & *msg & 1))
    {
        *msg = MSFAIL;
        goto quit;
    }

    if (index)
    {
        OMuint u_index;

        /*
         * Save the index.
         */
        om_msg = om$get_index (objid_c = my_id,
                               p_chanselect = &chansel,
                               objid = expression_id->objid,
                               osnum2 = expression_id->osnum,
                               indexaddr = &u_index);
        if (!(om_msg & 1))
        {
            goto quit;
        }

        *index = u_index;
    }
    
    if (type)
    {
        OMuword classid;
        
        /*
         * Determine the column type from the expression.
         */
        om_msg = om$get_classid (objid = expression_id->objid,
                                 osnum = expression_id->osnum,
                                 p_classid = &classid);
        if (!(om_msg & 1))
        {
            goto quit;
        }
        
        if (om$is_ancestry_valid (superclassid = OPP_expression_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            if (om$is_ancestry_valid (superclassid = OPP_text_exp_class_id,
                                      subclassid = classid) == OM_S_SUCCESS)
            {
                *type = GRTBL_STRING;
            }
            else
            {
                *type = GRTBL_DOUBLE;
            }
        }
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRget_expression                                                  |
 |                                                                           |
 | This method returns the expression object at the specified index.         |
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
method GRget_expression (IGRlong     * msg;
                         IGRint        index;
                         struct GRid * expression_id)
{
    IGRlong                 om_msg;
    OM_S_CHANSELECT         chansel;
    OMuint                  count;
    OM_S_OBJECT_LINKAGE   * objects;
    
    *msg = MSSUCC;
    
    om_msg = om$make_chanselect (channame = "GRtable.to_notify",
                                 p_chanselect = &chansel);
        
    if (!(om_msg & 1))
    {
        goto quit;
    }

    om_msg = om$get_channel_count (objid = my_id,
                                   p_chanselect = &chansel,
                                   count = &count);
    
    if (!(om_msg & 1) || (count == 0) || (index < 0) || (index >= count))
    {
        *msg = MSFAIL;
        goto quit;
    }

    objects = (OM_S_OBJECT_LINKAGE*)alloca(count * sizeof(OM_S_OBJECT_LINKAGE));
    
    om_msg = om$get_channel_objects (objid = my_id,
                                     p_chanselect = &chansel,
                                     list = objects,
                                     size = count,
                                     count = &count);
    
    if (!(om_msg & 1))
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    expression_id->objid = objects[index].S_objid;
    expression_id->osnum = objects[index].osnum;

 quit:
    
    return om_msg;
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRdisconnect_expression                                           |
 |                                                                           |
 | This method disconnects an expression object to the listeners channel.    |
 |                                                                           |
 | Input:   struct GRid         * expression_id    Expression id.            |
 |          IGRint                index            Index on channel.         |
 |                                                                           |
 | Output:  IGRlong             * msg              Return code.              |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column already exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method GRdisconnect_expression (IGRlong     * msg;
                                struct GRid * expression_id;
                                IGRint        index)
{
    IGRlong                 om_msg;
    OM_S_CHANSELECT         chansel;
    struct GRid             my_grid, loc_expression_id;
    GRspacenum              osnum;
    
    *msg = MSSUCC;
    
    om_msg = om$make_chanselect (channame = "GRtable.to_notify",
                                 p_chanselect = &chansel);
        
    if (!(om_msg & 1))
    {
        goto quit;
    }

    if (!expression_id)
    {
        expression_id = &loc_expression_id;
        
        om_msg = om$send (msg = message GRtable.GRget_expression (msg,
                                                                  index,
                                                                  expression_id),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    osnum = OM_Gw_current_OS;
    
    /*
     * Disconnect expression.
     */
    om_msg = om$send (msg = message GRnotify.GRntfydisconn (msg,
                                                            &my_grid,
                                                            &chansel),
                      targetid = expression_id->objid,
                      targetos = expression_id->osnum);

    if (!(om_msg & *msg & 1))
    {
        *msg = MSFAIL;
        goto quit;
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRrun_row                                                         |
 |                                                                           |
 | This method updates the expressions that are related to table columns     |
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
method GRrun_row (IGRlong * msg; IGRint * number; IGRchar * name)
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          i, col_count, row_count, batch_mode, index;
    IGRchar         syntax[EXP_LIM];
    struct GRid     expression_id;
    
    *msg = MSSUCC;
    
    col_count = om$dimension_of (varray = me->columns);
    row_count = om$dimension_of (varray = me->rows);
    
    if (name)
    {
        om_msg = om$send (msg = message GRtable.GRget_row_number (msg,
                                                                  name,
                                                                  &index),
                          targetid = my_id);
    }
    else if (number && (*number >= 0) && (*number < row_count))
    {
        index = *number;
    }
    else
    {
        *msg = MSFAIL;
    }
    
    if (om_msg & *msg & 1)
    {
        /*
         * For all the columns ...
         */
        for (i=0; i<col_count; ++i)
        {
            /*
             * Get the expression.
             */
            om_msg = om$send (msg = message GRtable.GRget_expression 
                                            (msg, i, &expression_id),
                              targetid = my_id);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            /*
             * Get the syntax.
             */
            if (me->columns[i].type == GRTBL_DOUBLE)
            {
                sprintf (syntax, 
                         "%lf", 
                         me->cells[(index * col_count) + i].d);
            }
            else
            {
                IGRint strndx = me->cells[(index * col_count) + i].d;
                
                sprintf (syntax, "\"%s\"", me->strings[strndx]);
            }
            
            /*
             * Modify the expression.
             */
            exp$modify (exp_id = expression_id.objid, 
                        osnum = expression_id.osnum, 
                        exp_syntax = syntax);
        }

        /*
         * Run the batch if necessary.
         */
        nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
    
        if (batch_mode == ND_IMMEDIATE)
        {
            nd$exec_batch ();
        }
    }
    
 quit:
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRadd_column                                                      |
 |                                                                           |
 | This method adds a column to the GRtable.                                 |
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
method  GRadd_column (IGRlong             * msg;
                      GRtable_column_info * column;
                      IGRint              * number)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  col_count, row_count, cell_count, i, j, type;
    IGRint  new_index, old_index, index;
    GRtable_cell * p_cell;
    
    *msg = MSSUCC;
    
    /*
     * Get the dimension of the arrays.
     */
    col_count  = om$dimension_of (varray = me->columns);
    row_count  = om$dimension_of (varray = me->rows);
    cell_count = om$dimension_of (varray = me->cells);
    
    /*
     * Make sure the column name is unique.
     */
    om_msg = om$send (msg = message GRtable.GRget_column (msg, 
                                                          NULL,
                                                          column->name,
                                                          NULL),
                      targetid = my_id);
    
    if (om_msg & *msg & 1)
    {
        *msg = MSFAIL;
    }
    else
    {
        *msg = MSSUCC;
        om_msg = OM_S_SUCCESS;
    }
    
    /*
     * Connect the expression and save the index.
     */
    om_msg = om$send (msg = message GRtable.GRconnect_expression 
                                       (msg,
                                        &column->expression_id,
                                        &index,
                                        &type),
                      targetid = my_id);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * This should never happen.
     */
    if (index != col_count)
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    /*
     * Add the column to the array.
     */
    om$vla_set_dimension (varray = me->columns, size = col_count + 1);
    strcpy (me->columns[col_count].name, column->name);
    me->columns[col_count].type = type;

    /*
     * Adjust the cell structure to account for the new array.
     */
    p_cell = (GRtable_cell *)alloca(cell_count * sizeof(GRtable_cell));
    memcpy (p_cell, &me->cells[0], cell_count * sizeof(GRtable_cell));
    om$vla_set_dimension (varray = me->cells, 
                          size = row_count * (col_count + 1));
    
    for (new_index = 0, old_index = 0, i=0; i<row_count; ++i)
    {
        for (j=0; j<col_count; ++j)
        {
            me->cells[new_index++] = p_cell[old_index++];
        } 

        if (type == GRTBL_DOUBLE)
        {
            me->cells[new_index++].d = 0.0;
        }
        else /* GRTBL_STRING */
        {
            IGRint strndx;
            
            om_msg = om$send (msg = message GRtable.GRadd_string 
                                       (msg, "", &strndx),
                              targetid = my_id);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            me->cells[new_index++].d = strndx;
        }
    }

 quit:
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRnum_columns                                                    |
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
method  GRnum_columns (IGRlong * msg; 
                       IGRint  * num_columns)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = MSSUCC;

    /*
     * Return the size of the array.
     */
    *num_columns = om$dimension_of (varray = me->columns);
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRget_column                                                     |
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
method  GRget_column (IGRlong             * msg; 
                      IGRint              * number;
                      IGRchar             * name;
                      GRtable_column_info * column)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  count, loc_number;

    *msg = MSSUCC;
    
    if (name)
    {
        number = &loc_number;
        
        om_msg = om$send (msg = message GRtable.GRget_column_number (msg,
                                                                     name,
                                                                     number),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

    count = om$dimension_of (varray = me->columns);

    if ((number) && (*number >= 0) && (*number < count))
    {
        if (column)
        {
            strcpy (column->name, me->columns[*number].name);
            column->type = me->columns[*number].type;
            om_msg = om$send (msg = message GRtable.GRget_expression
                                            (msg,
                                             *number,
                                             &column->expression_id),
                              targetid = my_id);
        }
    }

 quit:
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRget_column_number                                              |
 |                                                                           |
 | This method returns the number that cooresponds to a column name.         |
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
method  GRget_column_number (IGRlong        * msg; 
                             IGRchar        * name;
                             IGRint         * number)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  count = 0, index;
    
    *msg = MSFAIL;

    count = om$dimension_of (varray = me->columns);
    
    for (index=0; index<count; ++index)
    {
        if (!strcmp(name, me->columns[index].name))
        {
            if (number)
            {
                *number = index;
            }
            *msg = MSSUCC;
            break;
        }
    }
    
    return om_msg;
}                      
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRmod_column                                                     |
 |                                                                           |
 | This message modifies a column in the GRtable.                            |
 |                                                                           |
 | Input:   IGRint              * number       Number of column.             |
 |          IGRchar             * name         Name of the column.           |
 |          GRtable_column_info * column       New column.                   |
 |                                                                           |
 | Output:  IGRlong             * msg          Return code.                  |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method  GRmod_column (IGRlong             * msg; 
                      IGRint              * number;
                      IGRchar             * name;
                      GRtable_column_info * column)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  index, count;
    
    *msg = MSSUCC;
    
    count = om$dimension_of (varray = me->columns);
        
    if (name)
    {
        om_msg = om$send (msg = message GRtable.GRget_column_number (msg,
                                                                     name,
                                                                     &index),
                          targetid = my_id);
    }
    else if ((number) && (*number >= 0) && (*number < count))
    {
        index = *number;
    }
    else
    {
        *msg = MSFAIL;
    }

    if (om_msg & *msg & 1)
    {
        /*
         * Only allow the column name to be changed.
         */
        strcpy (me->columns[index].name, column->name);
    }
        
    return om_msg;
}
                      
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRrem_column                                                     |
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
method  GRrem_column (IGRlong * msg; IGRint * number; IGRchar * name)
{
    IGRlong om_msg = OM_S_SUCCESS, ok;
    IGRint  col_count, row_count, index, i, j;
    
    *msg = MSSUCC;
    
    col_count  = om$dimension_of (varray = me->columns);
    row_count  = om$dimension_of (varray = me->rows);

    if (name)
    {
        om_msg = om$send (msg = message GRtable.GRget_column_number (msg,
                                                                     name,
                                                                     &index),
                          targetid = my_id);
        
    }            
    else if ((number) && (*number >=0) && (*number < col_count))
    {
        index = *number;
    }
    else
    {
        *msg = MSFAIL;
    }
    
    if (om_msg & *msg & 1)
    {
        IGRint old_index, new_index;

        /*
         * If this is the last expression object ...
         */
        if (col_count == 1)
        {
            /*
             * Delete the table.
             */
            om$send (msg = message Root.delete(0),
                     targetid = my_id);
            goto quit;
        }

        /*
         * Disconnect the expression object if it's still connected.
         */
        om$send (msg = message GRtable.GRdisconnect_expression (&ok, 
                                                                index, 
                                                                NULL),
                 targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Fix up the cells array.
         */
        for (i=0, old_index = 0, new_index = 0; i<row_count; ++i)
        {
            for (j=0; j<col_count; ++j)
            {
                if (j != index)
                {
                    me->cells[new_index++] = me->cells[old_index];
                }
                else if (me->columns[index].type == GRTBL_STRING)
                {
                    om_msg = om$send (msg = message GRtable.GRrem_string 
                                                (msg, 
                                                 (IGRint)me->cells[old_index].d),
                                      targetid = my_id);

                    if (!(om_msg & *msg & 1))
                    {
                        goto quit;
                    }
                }
                    
                old_index++;
            }
        }

        /*
         * Reduce the size of the cells array.
         */
        om$vla_set_dimension (varray = me->cells, size = new_index);

        /*
         * Fix up the column array.
         */
        --col_count;
        
        for (i=index; i<col_count; ++i)
        {
            me->columns[i] = me->columns[i+1];
        }
        
        /*
         * Reduce the size of the column array.
         */
        om$vla_set_dimension (varray = me->columns, size = col_count);
    }

 quit:
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRadd_row                                                        |
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
method  GRadd_row (IGRlong     * msg;
                   GRtable_row * row;
                   IGRint      * number)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  i;
    
    *msg = MSSUCC;
    
    /*
     * Make sure the row is unique.
     */
    om_msg = om$send (msg = message GRtable.GRget_row (msg, 
                                                       NULL,
                                                       row->name,
                                                       NULL),
                      targetid = my_id);
    
    if (om_msg & *msg & 1)
    {
        *msg = MSFAIL;
    }
    else
    {
        *msg = MSSUCC;
        om_msg = OM_S_SUCCESS;
    }
    
    if (om_msg & *msg & 1)
    {
        IGRint size, row_count, col_count, cell_count;
        
        /*
         * Get the dimension sizes.
         */
        row_count  = om$dimension_of (varray = me->rows);
        col_count  = om$dimension_of (varray = me->columns);
        cell_count = row_count * col_count;
        
        /*
         * Add the row.
         */
        om$vla_set_dimension (varray = me->rows, size = row_count + 1);
    
        me->rows[row_count] = *row;
        
        /*
         * Add the default cell.
          */
        om$vla_set_dimension (varray = me->cells, 
                              size = (size = (row_count + 1) * col_count));
        
        for (i=cell_count; i<size; ++i)
        {
            if (me->columns[i-cell_count].type == GRTBL_DOUBLE)
            {
                me->cells[i].d = 0.0;
            }
            else
            {
                IGRint strndx;
                
                om_msg = om$send (msg = message GRtable.GRadd_string 
                                               (msg, "", &strndx),
                                  targetid = my_id);

                me->cells[i].d = strndx;
            }
        }
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRnum_rows                                                       |
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
method  GRnum_rows (IGRlong * msg; 
                    IGRint  * num_rows)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = MSSUCC;

    *num_rows = om$dimension_of (varray = me->rows);
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRget_row                                                        |
 |                                                                           |
 | This message returns a row from the GRtable.                              |
 |                                                                           |
 | Input:   IGRint           * number        Number of row [0 ... n].        |
 |          IGRchar          * name          Name of row.                    |
 |                                                                           |
 | Output:  IGRlong          * msg           Return code.                    |
 |          GRtable_row_info * row           Row.                            |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row doesn't exist.                             |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method  GRget_row (IGRlong          * msg; 
                   IGRint           * number;
                   IGRchar          * name;
                   GRtable_row_info * row)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  count, index;
    
    *msg = MSSUCC;
    
    count = om$dimension_of (varray = me->rows);
    
    if (name)
    {
        om_msg = om$send (msg = message GRtable.GRget_row_number (msg,
                                                                  name,
                                                                  &index),
                          targetid = my_id);
    }
    else if (number && (*number >= 0) && (*number < count))
    {
        index = *number;
    }
    else
    {
        *msg = MSFAIL;
    }
    
    if (om_msg & *msg & 1)
    {
        if (row)
        {
            *row = me->rows[index];
        }
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRget_row_number                                                 |
 |                                                                           |
 | This method returns the number that cooresponds to a row name.            |
 |                                                                           |
 | Input:   IGRchar         * name             Name of row                   |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |          IGRint          * number           Number of row.                |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Expression/column doesn't exists.              |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method  GRget_row_number (IGRlong        * msg; 
                          IGRchar        * name;
                          IGRint         * number)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  count = 0, index;
    
    *msg = MSFAIL;

    count = om$dimension_of (varray = me->rows);
    
    for (index=0; index<count; ++index)
    {
        if (!strcmp(name, me->rows[index].name))
        {
            if (number)
            {
                *number = index;
            }
            *msg = MSSUCC;
            break;
        }
    }
    
    return om_msg;
}                      
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRmod_row                                                        |
 |                                                                           |
 | This message modifies a row in the GRtable.                               |
 |                                                                           |
 | Input:   IGRint           * number       Number of row.                   |
 |          IGRchar          * name         Name of row.                     |
 |          GRtable_row_info * row          New row.                         |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row doesn't exists.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method  GRmod_row (IGRlong          * msg; 
                   IGRint           * number;
                   IGRchar          * name;
                   GRtable_row_info * row)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  count, index;
    
    *msg = MSSUCC;

    count = om$dimension_of (varray = me->rows);
    
    if (name)
    {
        om_msg = om$send (msg = message GRtable.GRget_row_number (msg,
                                                                  name,
                                                                  &index),
                          targetid = my_id);
    }
    else if (number && (*number >= 0) && (*number < count))
    {
        index = *number;
    }
    else
    {
        *msg = MSFAIL;
    }
    
    if (om_msg & *msg & 1)
    {
        me->rows[index] = *row;
    }
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRrem_row                                                        |
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
method  GRrem_row (IGRlong * msg; IGRint * number; IGRchar * name)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  col_count, row_count, index, i;
    
    *msg = MSSUCC;
    
    row_count = om$dimension_of (varray = me->rows);
    col_count = om$dimension_of (varray = me->columns);
    
    if (name)
    {
        om_msg = om$send (msg = message GRtable.GRget_row_number (msg,
                                                                  name,
                                                                  &index),
                          targetid = my_id);
        
    }            
    else if ((number) && (*number >=0) && (*number < row_count))
    {
        index = *number;
    }
    else
    {
        *msg = MSFAIL;
    }
    
    if (om_msg & *msg & 1)
    {
        IGRint row_count = om$dimension_of (varray = me->rows);

        /*
         * If this isn't the last row...
         */
        if (index < row_count - 1)
        {
            IGRint new_index, old_index;

            /*
             * Fix up the data array.
             */
            new_index = index * col_count;
            old_index = new_index + col_count;

            for (i=0; i<col_count; ++i)
            {
                if (me->columns[i].type == GRTBL_STRING)
                {
                    om_msg = om$send (msg = message GRtable.GRrem_string 
                                              (msg, 
                                               (IGRint)me->cells[new_index].d),
                                      targetid = my_id);
                }
                
                me->cells[new_index++] = me->cells[old_index++];
            }
        }

        /*
         * Reduce the size of the cells array.
         */
        om$vla_set_dimension (varray = me->cells,
                              size = om$dimension_of (varray = me->cells) + 1);

        /*
         * Fix up the row array.
         */
        --row_count;
            
        for (i=index; i<row_count; ++i)
        {
            me->rows[i] = me->rows[i+1];
        }
        
        /*
         * Reduce the size of the row array.
         */
        om$vla_set_dimension (varray = me->rows, size = row_count);
    }

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRmod_cell                                                       |
 |                                                                           |
 | This message modifies data for a row and column in the GRtable.           |
 |                                                                           |
 | Input:   IGRint              row           Number of the row.             |
 |          IGRint              column        Number of the column.          |
 |          GRtable_cell_info * cell          Data.                          |
 |                                                                           |
 | Output:  IGRlong           * msg           Return code.                   |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row or column doesn't exist.                   |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method  GRmod_cell (IGRlong           * msg;
                    IGRint              row;
                    IGRint              column;
                    GRtable_cell_info * cell)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  col_count = om$dimension_of (varray = me->columns);
    IGRint  row_count = om$dimension_of (varray = me->rows);
    
    *msg = MSSUCC;

    if ((row >= 0)    && (row < row_count) &&
        (column >= 0) && (column < col_count))
    {
        if (me->columns[column].type == GRTBL_DOUBLE)
        {
            me->cells[(row * col_count) + column].d = cell->d;
        }
        else
        {
            om_msg = om$send (msg = message GRtable.GRmod_string 
                                     (msg, 
                                      (IGRint)me->cells[(row * col_count) + column].d,
                                      cell->s),
                              targetid = my_id);
        }
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  GRget_cell                                                       |
 |                                                                           |
 | This method gets data for a row and column in the GRtable.                |
 |                                                                           |
 | Input:   IGRint              row         Number of the row.               |
 |          IGRint              column      Number of the column.            |
 |                                                                           |
 | Output:  IGRlong           * msg         Return code.                     |
 |          GRtable_cell_info * data        Data.                            |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Row or column doesn't exist.                   |
 |                                                                           |
 *---------------------------------------------------------------------------*/
method  GRget_cell (IGRlong           * msg;
                    IGRint              row;
                    IGRint              column;
                    GRtable_cell_info * cell)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  col_count = om$dimension_of (varray = me->columns);
    IGRint  row_count = om$dimension_of (varray = me->rows);
    
    *msg = MSSUCC;

    /*
     * KLUDGE: Only support doubles for now.
     */
    if ((row >= 0)    && (row < row_count) &&
        (column >= 0) && (column < col_count))
    {
        if (me->columns[column].type == GRTBL_DOUBLE)
        {
            cell->d = me->cells[(row * col_count) + column].d;
        }
        else
        {
            strcpy (cell->s, 
                    me->strings[(IGRint)me->cells[(row * col_count) + column].d]);
        }
    }
    
    return om_msg;
}
                      
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRadd_string                                                      |
 |                                                                           |
 | This method adds a string to the string storage array and returns the     |
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
method GRadd_string (IGRlong * msg; IGRchar * string; IGRint * index)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = MSSUCC;

    *index = om$dimension_of (varray = me->strings);
    
    om_msg = om$vla_set_dimension (varray = me->strings, 
                                   size = *index + 1);

    if (!(om_msg & 1))
    {
        goto quit;
    }

    strcpy (me->strings[*index], string);
    
 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRmod_string                                                      |
 |                                                                           |
 | This method modifies a string in the string storage array.                |
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
method GRmod_string (IGRlong * msg; IGRint index; IGRchar * string)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  num_strings = om$dimension_of (varray = me->strings);

    if ((index < 0) || (index >= num_strings))
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    *msg = MSSUCC;
    
    strcpy (me->strings[index], string);
 
 quit:
                
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: GRrem_string                                                      |
 |                                                                           |
 | This method removes a string from the string storage array. It will       |
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
method GRrem_string (IGRlong * msg; IGRint index)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  i, j, num_strings = om$dimension_of (varray = me->strings);
    IGRint  num_columns = om$dimension_of (varray = me->columns);
    IGRint  num_rows = om$dimension_of (varray = me->rows);
    
    if ((index < 0) || (index >= num_strings))
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    *msg = MSSUCC;

    num_strings--;
    
    for (i=index; i<num_strings; ++i)
    {
        strcpy (me->strings[index], me->strings[index+1]);
    }
    
    om$vla_set_dimension (varray = me->strings, size = num_strings);
    
    if (index == num_strings)
    {
        goto quit;
    }
    
    for (i=0; i<num_rows; ++i)
    {
        for (j=0; j<num_columns; ++j)
        {
            if (me->columns[j].type == GRTBL_STRING)
            {
                if (me->cells[(i * num_columns) + j].d > index)
                {
                    me->cells[(i * num_columns) + j].d -= 1.0;
                }
            }
        }
    }

 quit:        

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRnotifylis                                                     |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/24/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRnotifylis (IGRlong         * msg; 
                    IGRlong         * OMmsg;
                    IGRlong         * mask;
                    OM_S_MESSAGE    * graphics_msg)
{
    IGRlong         ok;
    IGRint          index;
    OM_S_CHANSELECT chansel;
    
    switch (*mask)
    {
    case GR_DELETED:
        printf ("GRtable.GRnotifylis: GR_DELETED\n");
        if (om$make_chanselect (channame = "GRtable.to_notify",
                                p_chanselect = &chansel) & 1)
        {
            OMuint u_index;
            
            if (om$get_index (objid_c = my_id,
                              p_chanselect = &chansel,
                              objid = sender_id,
                              osnum2 = sender_os,
                              indexaddr = &u_index) & 1)
            {
                index = u_index;
                
                om$send (msg = message GRtable.GRrem_column (&ok, 
                                                             &index,
                                                             NULL),
                         targetid = my_id);
            }
        }
        break;

    case GR_ATTR_MODIFIED:
        printf ("GRtable.GRnotifylis: GR_ATTR_MODIFIED\n");
        break;
        
    case GR_CHANGED:
        printf ("GRtable.GRnotifylis: GR_CHANGED\n");
        break;
    }

    return *OMmsg;
}        

end implementation GRtable;



