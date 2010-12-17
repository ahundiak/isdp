#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSquery_add_set_attributes
 
 Abstract:
     This function will query for the attributes needed to add a set.

 */
 
long NFMSquery_add_set_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_add_set_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog_name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_add_set_attributes (user_id, data_ptr[1],
                                    &attr_list, &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_add_set_attributes <0x%.8x>\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list,
		value_list );
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


long NFMSquery_set_members (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long level;
long type;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSquery_set_members";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog  : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "set name : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "set rev  : <%s>\n", data_ptr[3]));
_NFMSdebug(( fname, "level    : <%s>\n", data_ptr[4]));
_NFMSdebug(( fname, "type     : <%s>\n", data_ptr[5]));

user_id = atol (data_ptr[0]);
level = atol (data_ptr[4]);
type = atol (data_ptr[5]);

ret_status = NFMquery_set_members (user_id, data_ptr[1], data_ptr[2],
                                   data_ptr[3], level, type, &attr_list,
                                   &data_list);
_NFMSdebug(( fname, "NFMquery_set_members <0x%.8x>\n", ret_status ));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    attr_list = NULL;
    data_list = NULL;
    }

status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

return (ret_status);

}


long NFMSqry_set_members (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSqry_set_members";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog  : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "set name : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "set rev  : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);
/*
ret_status = NFMqry_set_members (user_id, data_ptr[1], data_ptr[2],
                                   data_ptr[3], &attr_list, &data_list);

if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    attr_list = NULL;
    data_list = NULL;
    }
*/
status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status));

MEMclose (&attr_list);
MEMclose (&data_list);

return (ret_status);

}

long NFMSget_members (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr member_list = NULL;

static char *fname = "NFMSget_members";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog name  : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog num   : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "set name      : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "set rev       : <%s>\n", data_ptr[3]));
_NFMSdebug(( fname, "set num       : <%s>\n", data_ptr[4]));
_NFMSdebug(( fname, "depth         : <%s>\n", data_ptr[5]));

ret_status = NFMget_members (data_ptr[0], atol(data_ptr[1]), data_ptr[2],
                  data_ptr[3], atol(data_ptr[4]), atol(data_ptr[5]),
                  &member_list);
_NFMSdebug(( fname, "NFMget_members <0x%.8x>\n", ret_status ));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&member_list);
    member_list = NULL;
    }

status = NFMSsend_one_buffer( ret_status, member_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose (&member_list);

return (ret_status);

}

