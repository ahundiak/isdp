#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSquery_change_sa_attributes
 
 Abstract:
     This function will query for the Node attributes
 */
 
long NFMSquery_change_sa_attributes (in_list)
    MEMptr in_list;

{
    long status;
    long ret_status;
    long user_id;

    char **data_ptr;
 
    MEMptr attr_list  = NULL;
    MEMptr data_list  = NULL;
    MEMptr value_list = NULL;

    static char *fname = "NFMSquery_change_sa_attributes";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char **) in_list->data_ptr;

    user_id = atol (data_ptr[0]);

    _NFMSdebug(( fname, "user_id <%s>\n", data_ptr[0]));
    _NFMSdebug(( fname, "sa_name, <%s>\n",data_ptr[1]));   

    ret_status = NFMquery_change_sa_attributes (user_id, data_ptr[1],
		 &attr_list, &data_list, &value_list);
    _NFMSdebug(( fname, "NFMquery_change_sa_attributes <0x%.8x>\n",
		 ret_status ));
    if (ret_status != NFM_S_SUCCESS)
    {
	MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	attr_list = NULL;
	data_list = NULL;
	value_list= NULL;
    }

    if (_NFMdebug_st.NFMSdebug_on)
    {
        MEMprint_buffer( "DATA INFO", data_list, 
			 _NFMdebug_st.NFMSdebug_file );
        MEMprint_buffer( "VALUE INFO", value_list, 
			 _NFMdebug_st.NFMSdebug_file );
    }

    status = NFMSsend_three_buffers( ret_status, attr_list, data_list,
					value_list );
    _NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);

    return (ret_status);
}


