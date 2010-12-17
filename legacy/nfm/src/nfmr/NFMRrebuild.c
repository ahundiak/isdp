#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRrebuild_data_buffer
 
 Abstract:
     This function will rebuild a data buffer returned from a 
     NFMRquery_catalog_template.  When user attributes have been added,
     the data buffer must be rebuilt with a new column for each user
     attributes added.

     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    1-15-1990    Creation
     
 */
 
long NFMRrebuild_data_buffer (attr_list, data_list)

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

static char *fname = "NFMRrebuild_data_buffer";

    status = MEMopen (&new_data_list, 1028);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    NFMRfill_index (attr_list, &index);

    status = MEMbuild_array (*data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
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
            _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
            }
        }  /* end for */

    status = MEMbuild_array (new_data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&new_data_list);
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    for (k=0; k<(*data_list)->rows; ++k)
        {
        str[0] = 0;

        for (i=0; i<(*data_list)->columns; ++i)
            {
            strcat (str, ddata_ptr[i]);
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
            _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
            }
        }

    MEMclose (data_list);

    *data_list = new_data_list;

    return (NFM_S_SUCCESS);
}
