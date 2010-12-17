#include "machine.h"
#include <stdio.h>
#include "DEBUG.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "NDXstruct.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMrebuild_data_buffer
 
 Abstract:
     This function will rebuild a data buffer returned from a 
     NFMRquery_catalog_template.  When user attributes have been added,
     the data buffer must be rebuilt with a new column for each user
     attributes added.

     
 Returns:
       NFM_S_SUCCESS - Success
       Other - Failure
*/
 
long NFMrebuild_data_buffer (attr_list, data_list)

MEMptr  attr_list;   /* i - an attribute buffer containing a row for all old
                            attributes plus any user defined ones */
MEMptr  *data_list;  /* o - the rebuilt data buffer (a new column for each new
                            user attribute in the attribute buffer) */

{
int  i, j, k;
long status;
char str[1024];
char **data_ptr;
char **column_ptr;
char **ddata_ptr;
char **dcolumn_ptr;
MEMptr new_data_list = NULL;
NDXptr index;
static char *fname = "NFMrebuild_data_buffer";

    _NFMdebug ((fname, "Enter.\n"));

    status = MEMopen (&new_data_list, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMdebug ((fname, "MEMopen : <0x%.8x>\n", status));
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
        }

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    NFMfill_index (attr_list, &index);

    status = MEMbuild_array (*data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
        }

    ddata_ptr = (char **) (*data_list)->data_ptr;
    dcolumn_ptr = (char **) (*data_list)->column_ptr;

    for (i=0; i<attr_list->rows; ++i)
        {
        j = i * attr_list->columns;
        status = MEMwrite_format (new_data_list, data_ptr[j+index.nfm],
                                  data_ptr[j+index.dt]);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&new_data_list);
            _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status));
            return (status);
            }
        }  /* end for */

    status = MEMbuild_array (new_data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
        }

    for (k=0; k<(*data_list)->rows; ++k)
        {
        str[0] = 0;

        j = k * (*data_list)->columns;

        for (i=0; i<(*data_list)->columns; ++i)
            {
            strcat (str, ddata_ptr[j++]);
            strcat (str, "\1");
            }

        j = i;

        for (i=j; i<new_data_list->columns; ++i)
            strcat (str, "\1");

        /* Write the data row */
    
        status = MEMwrite (new_data_list, str);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&new_data_list);
            _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status));
            return (status);
            }
        }

    MEMclose (data_list);

    *data_list = new_data_list;
    return (NFM_S_SUCCESS);
}

/* 
 Doc: _NFMfilter_sort_buffer
 
 Abstract:
     This function will filter a buffer returned from
     NFMRquery_table_definition. The reason is to weed out n_aclno, 
     n_stateno, and n_prevstateno as possible attributes to define a 
     sort criteria on. The internal display function has a join with 
     the nfmacl and nfmstates tables to return the acl name and state 
     name instead of the acl number and state number. However, you 
     cannot sort on a value that is not in the select list.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other - Failure
*/
 
long _NFMfilter_sort_buffer (attr_list)

MEMptr  *attr_list;  /* i - an attribute buffer containing a row for all old
                            attributes minus n_aclno, n_stateno, and
                            n_prevstateno */

{
int  i, j, k;
long status;
char str[1024];
char **data_ptr;
char **column_ptr;
char **format_ptr;
MEMptr tmp_attr_list = NULL;
NDXptr index;
static char *fname = "NFMfilter_sort_buffer";

    _NFMdebug ((fname, "Enter.\n"));

    status = MEMopen (&tmp_attr_list, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&tmp_attr_list);
        _NFMdebug ((fname, "MEMopen : <0x%.8x>\n", status));
        return (status);
        }

    status = MEMbuild_array (*attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&tmp_attr_list);
        MEMclose (attr_list);
        _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
        }

    data_ptr = (char **) (*attr_list)->data_ptr;
    column_ptr = (char **) (*attr_list)->column_ptr;
    format_ptr = (char **) (*attr_list)->format_ptr;

    for (i=0; i<(*attr_list)->columns; ++i)
        {
        status = MEMwrite_format (tmp_attr_list, column_ptr[i],
                                  format_ptr[i]);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&tmp_attr_list);
            MEMclose (attr_list);
            _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status));
            return (status);
            }
        }  /* end for */

    status = MEMbuild_array (tmp_attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&tmp_attr_list);
        MEMclose (attr_list);
        _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
        }

    NFMfill_index (*attr_list, &index);

    for (j=0; j<(*attr_list)->rows; ++j)
        {
        k = j * (*attr_list)->columns;

        if ((strcmp (data_ptr[k+index.nfm], "n_aclno") != 0) &&
            (strcmp (data_ptr[k+index.nfm], "n_stateno") != 0) &&
            (strcmp (data_ptr[k+index.nfm], "n_prevstateno") != 0))

            {
            str[0] = 0;
            for (i=0; i<(*attr_list)->columns; ++i)
                {
                strcat (str, data_ptr[k+i]);
                strcat (str, "\1");
                }

            /* Write the data row */
    
            status = MEMwrite (tmp_attr_list, str);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&tmp_attr_list);
                MEMclose (attr_list);
                _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status));
                return (status);
                }
            }
        }

    MEMclose (attr_list);
    *attr_list = tmp_attr_list;

    return (NFM_S_SUCCESS);
}

