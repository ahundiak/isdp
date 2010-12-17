#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

/* 
 Doc: NFMSquery_add_item_attributes
 
 Abstract:
     This function will query for the attributes needed to add an item.
     
 */
 
long NFMSquery_add_item_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
static char *fname = "NFMSquery_add_item_attributes";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog_name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_add_item_attributes (user_id, data_ptr[1],
                                          &attr_list, &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_add_item_attributes <0x%.8x>\n", ret_status ));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);
  
return (ret_status);

}


/* 
 Doc: NFMSquery_item_attributes
 
 Abstract:
     This function will query for an item's attributes.
     
 */
 
long NFMSquery_item_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
static char *fname = "NFMSquery_item_attributes";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_item_attributes (user_id, data_ptr[1], data_ptr[2],
                                       data_ptr[3], &attr_list, &data_list,
                                       &value_list);
_NFMSdebug(( fname, "NFMquery_item_attributes <0x%.8x>\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}

/* 
 Doc: NFMSget_item_attr_for_copy 
 
 Abstract:
     This function will query for the attributes needed to copy an item
     
 */
 
long NFMSget_item_attr_for_copy (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr attr_f_list = NULL;
MEMptr data_f_list = NULL;
MEMptr value_f_list = NULL;

static char *fname = "NFMSget_item_attr_for_copy";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "MEMbuild : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog_name : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "item_name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item_rev : <%s>\n", data_ptr[2]));

ret_status = NFMget_item_attr_for_copy (data_ptr[0], data_ptr[1], data_ptr[2],
				&attr_list, &data_list, &value_list,
				&attr_f_list, &data_f_list, &value_f_list);
_NFMSdebug(( fname, "NFMget_item_attr_for_copy <0x%.8x>\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&attr_f_list);
    MEMclose (&data_f_list) ;
    MEMclose (&value_f_list) ;
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    attr_f_list = NULL;
    data_f_list = NULL;
    value_f_list= NULL;
    }

status = NFMSsend_six_buffers( ret_status, attr_list, data_list, value_list,
			attr_f_list, data_f_list, value_f_list);
_NFMSdebug(( fname, "NFMSsend_six_buffers <0x%.8x>\n", status ));


if( _NFMdebug_st.NFMSdebug_on )
{
  MEMprint_buffers ("CATALOG ATTR LIST", attr_list, _NFMdebug_st.NFMSdebug_file);
  MEMprint_buffers ("CATALOG DATA LIST", data_list, _NFMdebug_st.NFMSdebug_file);
  MEMprint_buffers ("CATALOG VALUE LIST", value_list, _NFMdebug_st.NFMSdebug_file);
  MEMprint_buffers ("F_CATALOG ATTR LIST", attr_f_list, _NFMdebug_st.NFMSdebug_file);
  MEMprint_buffers ("F_CATALOG DATA LIST", data_f_list, _NFMdebug_st.NFMSdebug_file);
  MEMprint_buffers ("F_CATALOG VALUE LIST", value_f_list,_NFMdebug_st.NFMSdebug_file);
}
MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);
MEMclose (&attr_f_list);
MEMclose (&data_f_list) ;
MEMclose (&value_f_list) ;
  
return (ret_status);

}
