#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMitemfiles.h"

/* 
 Doc: NFMSget_keywords_for_files
 
 Abstract:
     This function will query for keywords for this item/set.
 */
 
long NFMSget_keywords_for_files (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long ptype;
char **data_ptr;
MEMptr filesBuffer = NULL;
MEMptr keyBuffer = NULL;

static char *fname = "NFMSget_keywords_for_files";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog_name : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "item_name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item_rev : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "type : <%s>\n", data_ptr[3]));

if (strcmp(data_ptr[3], "0")== 0)
   ptype = NFM_ITEM;
else
   ptype = NFM_SET;

ret_status = NFMget_keywords_for_files (data_ptr[0],data_ptr[1],
	       data_ptr[2], ptype,  &filesBuffer, &keyBuffer);
_NFMSdebug(( fname, "NFMget_keywords_for_files <0x%.8x>\n", ret_status ));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&filesBuffer);
    MEMclose (&keyBuffer);
    filesBuffer = NULL;
    keyBuffer = NULL;
    }

status = NFMSsend_two_buffers( ret_status, filesBuffer, keyBuffer);
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

MEMclose (&filesBuffer);
MEMclose (&keyBuffer);
  
return (ret_status);

}
/* 
 Doc: NFMSget_highlighting_for_files
 
 Abstract:
     This function will get highlighting for files
 */
 
long NFMSget_highlighting_for_files (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long ptype;
char **data_ptr;
MEMptr filesBuffer = NULL;
MEMptr posBuffer = NULL;

static char *fname = "NFMSget_highlighting_for_files";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog_name : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "item_name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item_rev : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "type : <%s>\n", data_ptr[3]));
_NFMSdebug(( fname, "ftr search : <%s>\n", data_ptr[4]));

if (strcmp(data_ptr[3], "0")== 0)
   ptype = NFM_ITEM;
else
   ptype = NFM_SET;

ret_status = NFMget_highlighting_for_files (data_ptr[0],data_ptr[1],
	       data_ptr[2], ptype, data_ptr[4], &filesBuffer, &posBuffer);
_NFMSdebug(( fname, "NFMget_highlighting_for_files <0x%.8x>\n", ret_status ));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&filesBuffer);
    MEMclose (&posBuffer);
    filesBuffer = NULL;
    posBuffer = NULL;
    }

status = NFMSsend_two_buffers( ret_status, filesBuffer, posBuffer);
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

MEMclose (&filesBuffer);
MEMclose (&posBuffer);
  
return (ret_status);

}

/* 
 Doc: NFMSget_thesaurus
 
 Abstract:
     This function will get FTR thesaurus files
 */
 
long NFMSget_thesaurus (in_list)

MEMptr in_list;

{
long status;
long ret_status;
MEMptr theBuffer = NULL;

static char *fname = "NFMSget_thesaurus";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

ret_status = NFMget_thesaurus (&theBuffer);

_NFMSdebug(( fname, "NFMget_thesaurus <0x%.8x>\n", ret_status ));

status = NFMSsend_one_buffer( ret_status, theBuffer);
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose (&theBuffer);
  
return (ret_status);

}
/* 
 Doc: NFMSget_verdveal
 
 Abstract:
     This function will return verds to be used for a verdveal.
 */
 
long NFMSget_verdveal (in_list)

MEMptr in_list;

{
int  i;
long status;
long ret_status;
char **data_ptr;
MEMptr other_list = NULL;
MEMptr verdsBuffer = NULL;

static char *fname = "NFMSget_verdveal";

    _NFMSdebug(( fname, "%s\n", "Entering ..."));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    data_ptr = (char**)in_list->data_ptr;

    for( i=0; i<(in_list->rows*in_list->columns); i+=in_list->columns )
        _NFMSdebug(( fname, "Catalog <%s>\n", data_ptr[i] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &other_list, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&other_list);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (status);
        }
    }

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose (&other_list);
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMbuild_array (other_list);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&other_list);
        _NFMSdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (status);
    }
    data_ptr = (char **) other_list->data_ptr;

    _NFMSdebug(( fname, "start : <%s>\n", data_ptr[0]));
    _NFMSdebug(( fname, "count : <%s>\n", data_ptr[1]));

    ret_status = NFMget_word_wheel ( in_list, data_ptr[0], atol(data_ptr[1]),
	       &verdsBuffer);
    _NFMSdebug(( fname, "NFMget_word_wheel <0x%.8x>\n", ret_status ));
    MEMclose (&other_list);
    if (ret_status != NFM_S_SUCCESS)
    {
        MEMclose (&verdsBuffer);
        verdsBuffer = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, verdsBuffer);
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose (&verdsBuffer);
  
    return (ret_status);

}
/* 
 Doc: NFMSget_preview
 
 Abstract:
     This function will get a list of 'HITS' for FTR .
 */
 
long NFMSget_preview (in_list)

MEMptr in_list;

{
int  i;
long status;
long ret_status;
char **data_ptr;
MEMptr hitBuffer = NULL;
MEMptr other_list = NULL;

static char *fname = "NFMSget_preview";

    _NFMSdebug(( fname, "%s\n", "Entering ..."));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    data_ptr = (char**)in_list->data_ptr;

    for( i=0; i<(in_list->rows*in_list->columns); i+=in_list->columns )
        _NFMSdebug(( fname, "Catalog <%s>\n", data_ptr[i] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &other_list, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&other_list);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (status);
        }
    }

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose (&other_list);
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMbuild_array (other_list);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&other_list);
        _NFMSdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (status);
    }

    data_ptr = (char **) other_list->data_ptr;

    _NFMSdebug(( fname, "search : <%s>\n", data_ptr[0]));

    ret_status = NFMget_preview (in_list, data_ptr[0], &hitBuffer);
    _NFMSdebug(( fname, "NFMget_preview <0x%.8x>\n", ret_status ));
    MEMclose (&other_list);
    if (ret_status != NFM_S_SUCCESS)
    {
        MEMclose (&hitBuffer);
        hitBuffer = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, hitBuffer);
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose (&hitBuffer);

    return (ret_status);

}
