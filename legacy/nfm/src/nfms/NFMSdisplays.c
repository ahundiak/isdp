#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMtypes.h"
#include "NFMapi.h"
#include "ERR.h"

long NFMSdisplay_acls (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;
{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_acls";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Workflow Name  <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Type           <%s>\n", data_ptr[4]));

    status = NFMdisplay_acls( data_ptr[1], data_ptr[2], data_ptr[3],
			      atoi(data_ptr[4]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_aclusers (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_aclusers";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "ACL Name       <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_aclusers( data_ptr[1], data_ptr[2], data_ptr[3],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_archives (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_archives";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_archives( data_ptr[1], data_ptr[2],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_catalog_acl_mapping (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_catalog_acl_mapping";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_catalog_acl_mapping( data_ptr[1], data_ptr[2], 
				data_ptr[3], syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_catalog_sa_mapping (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_catalog_sa_mapping";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_catalog_sa_mapping( data_ptr[1], data_ptr[2], 
				data_ptr[3], syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_catalogs (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_catalogs";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type           <%s>\n", data_ptr[3]));

    status = NFMdisplay_catalogs( data_ptr[1], data_ptr[2], 
		                  atoi(data_ptr[3]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_classes (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_classes";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Workflow Name  <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Type           <%s>\n", data_ptr[4]));

    status = NFMdisplay_classes( data_ptr[1], data_ptr[2], data_ptr[3],
			         atoi(data_ptr[4]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_item_files (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_item_files";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Item	 	<%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Revision	<%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[4]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[5]));

    status = NFMdisplay_item_files( data_ptr[1], data_ptr[2], data_ptr[3],
			  data_ptr[4], data_ptr[5], syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_items (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_items";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Type		<%s>\n", data_ptr[4]));

    status = NFMdisplay_items( data_ptr[1], data_ptr[2], data_ptr[3],
			atoi(data_ptr[4]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_items_partial (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_items_partial";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Type		<%s>\n", data_ptr[4]));
    _NFMSdebug(( fname, "Rows		<%s>\n", data_ptr[5]));

    status = NFMdisplay_items_partial( data_ptr[1], data_ptr[2], data_ptr[3],
		atoi(data_ptr[4]), atol(data_ptr[5]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_items_short (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_items_short";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_items_short( data_ptr[1], data_ptr[2], data_ptr[3],
		syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_items_short_partial (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_items_short_partial";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Rows		<%s>\n", data_ptr[4]));

    status = NFMdisplay_items_short_partial( data_ptr[1], data_ptr[2],
	data_ptr[3], atol(data_ptr[4]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_nodes (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_nodes";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type           <%s>\n", data_ptr[3]));

    status = NFMdisplay_nodes( data_ptr[1], data_ptr[2], atoi(data_ptr[3]),
			      syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_project_acl_mapping (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_project_acl_mapping";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Project        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_project_acl_mapping( data_ptr[1], data_ptr[2], 
				data_ptr[3], syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_project_sa_mapping (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_project_sa_mapping";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Project        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_project_sa_mapping( data_ptr[1], data_ptr[2], 
				data_ptr[3], syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_programs (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_programs";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type		<%s>\n", data_ptr[3]));

    status = NFMdisplay_programs( data_ptr[1], data_ptr[2],atoi(data_ptr[3]), 
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_projects (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_projects";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type		<%s>\n", data_ptr[3]));

    status = NFMdisplay_projects( data_ptr[1], data_ptr[2], atoi(data_ptr[3]),
			syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_project_members (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_project_members";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Project        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_project_members( data_ptr[1], data_ptr[2], data_ptr[3],
			syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_project_members_partial (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_project_members_partial";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Project        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Rows           <%s>\n", data_ptr[4]));

    status = NFMdisplay_project_members_partial( data_ptr[1], data_ptr[2], 
	data_ptr[3], atol(data_ptr[4]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_where_used_project (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_where_used_project";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Item           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Rev 		<%s>\n", data_ptr[3]));

    status = NFMdisplay_where_used_project( data_ptr[1], data_ptr[2], 
		data_ptr[3], syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_querys (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_querys";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Query Type     <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "List Type      <%s>\n", data_ptr[4]));
 
    status = NFMdisplay_querys( data_ptr[1], data_ptr[2], data_ptr[3],
		atoi(data_ptr[4]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_storage_areas (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_storage_areas";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type		<%s>\n", data_ptr[3]));

    status = NFMdisplay_storage_areas( data_ptr[1], data_ptr[2], 
			atoi(data_ptr[3]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_working_areas (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_working_areas";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type		<%s>\n", data_ptr[3]));

    status = NFMdisplay_working_areas( data_ptr[1], data_ptr[2], 
			atoi(data_ptr[3]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_sets (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_sets";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_sets( data_ptr[1], data_ptr[2], data_ptr[3],
			      syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_set_members (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_set_members";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Item           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Rev            <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[4]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[5]));

    status = NFMdisplay_set_members( data_ptr[1], data_ptr[2], data_ptr[3],
			data_ptr[4], data_ptr[5], syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}


long NFMSdisplay_set_members_partial (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_set_members_partial";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Item           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Rev            <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[4]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[5]));
    _NFMSdebug(( fname, "Rows           <%s>\n", data_ptr[6]));

    status = NFMdisplay_set_members_partial( data_ptr[1], data_ptr[2], 
	data_ptr[3],data_ptr[4], data_ptr[5], atol(data_ptr[6]),
	syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_where_used_set (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_where_used_set";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Item           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Rev            <%s>\n", data_ptr[3]));

    status = NFMdisplay_where_used_set( data_ptr[1], data_ptr[2], data_ptr[3],
			      syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_signoff_users (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_signoff_users";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "ACL Name       <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_signoff_users( data_ptr[1], data_ptr[2], data_ptr[3],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_so_on_item (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_so_on_item";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Item           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Revision       <%s>\n", data_ptr[3]));

    status = NFMdisplay_so_on_item( data_ptr[1], data_ptr[2], data_ptr[3],
			syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_so_history (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{
long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_so_history";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Item           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Revision       <%s>\n", data_ptr[3]));

    status = NFMdisplay_so_history( data_ptr[1], data_ptr[2], data_ptr[3],
			syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_transitions (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_transitions";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Workflow Name  <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));
    _NFMSdebug(( fname, "Type           <%s>\n", data_ptr[4]));

    status = NFMdisplay_transitions( data_ptr[1], data_ptr[2], data_ptr[3],
			      atoi(data_ptr[4]), syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_users (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_users";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type           <%s>\n", data_ptr[3]));

    status = NFMdisplay_users( data_ptr[1], data_ptr[2], atoi(data_ptr[3]),
			      syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_workflows (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_workflows";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Type		<%s>\n", data_ptr[3]));

    status = NFMdisplay_workflows( data_ptr[1], data_ptr[2], atoi(data_ptr[3]),
		 syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_archive_flags (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_archive_flags";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_archive_flags( data_ptr[1], data_ptr[2],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_backup_flags (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_backup_flags";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_backup_flags( data_ptr[1], data_ptr[2],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_restore_flags (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_restore_flags";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_restore_flags( data_ptr[1], data_ptr[2],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_delete_flags (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_delete_flags";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_delete_flags( data_ptr[1], data_ptr[2],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_local_files (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_local_files";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Storage        <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3]));

    status = NFMdisplay_local_files( data_ptr[1], data_ptr[2], data_ptr[3],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_savesets (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_savesets";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_savesets( data_ptr[1], data_ptr[2],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_items_on_tape (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_items_on_tape";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_items_on_tape( data_ptr[1], data_ptr[2],
			          syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_labels (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_labels";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[2]));

    status = NFMdisplay_labels( data_ptr[1], data_ptr[2],syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_ris_catalogs (in_list, syn_list, data_list)

MEMptr in_list;
MEMptr *syn_list;
MEMptr *data_list;

{

long   status;
char   **data_ptr;

static char *fname = "NFMSdisplay_ris_catalogs";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[0]));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[1]));

    status = NFMdisplay_ris_catalogs( data_ptr[0], data_ptr[1], 
		                      syn_list, data_list );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    return (NFM_S_SUCCESS);
}

long NFMSdisplay_master (in_list)

MEMptr in_list;

{
long status;
long cmd_status;
long ret_status;
int  display_type;

char **data_ptr;

MEMptr list1 = NULL;
MEMptr list2 = NULL;

static char *fname = "NFMSdisplay_master";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "Report Type : <%s>\n", data_ptr[0]));

display_type = atoi (data_ptr[0]);

switch (display_type)
    {
    case DSP_DISPLAY_ACLS :
        _NFMSdebug(( fname, "DSP_DISPLAY_ACLS = <%d>\n", display_type));
        status = NFMSdisplay_acls (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ACLS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_ACLUSERS :
        _NFMSdebug(( fname, "DSP_DISPLAY_ACLUSERS = <%d>\n", display_type));
        status = NFMSdisplay_aclusers (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ACLUSERS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_SIGNOFF_USERS :
        _NFMSdebug(( fname, "DSP_DISPLAY_SIGNOFF_USERS = <%d>\n", display_type));
        status = NFMSdisplay_signoff_users (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_SIGNOFF_USERS : status = <0x%.8x>\n",status));
        break;

    case DSP_DISPLAY_CATALOGS :
        _NFMSdebug(( fname, "DSP_DISPLAY_CATALOGS = <%d>\n", display_type));
        status = NFMSdisplay_catalogs (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_CATALOGS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_CATALOG_ACL_MAPPING :
        _NFMSdebug(( fname, "DSP_DISPLAY_CAT_ACL_MAP = <%d>\n", display_type));
        status = NFMSdisplay_catalog_acl_mapping (in_list, &list1, 
		 &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_CAT_ACL_MAP : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_CATALOG_SA_MAPPING :
        _NFMSdebug(( fname, "DSP_DISPLAY_CAT_SA_MAP = <%d>\n", display_type));
        status = NFMSdisplay_catalog_sa_mapping (in_list, &list1, 
		 &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_CAT_SA_MAP : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_CLASSES :
        _NFMSdebug(( fname, "DSP_DISPLAY_CLASSES = <%d>\n", display_type));
        status = NFMSdisplay_classes (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_CLASSES : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_ITEM_FILES :
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEM_FILES = <%d>\n", display_type));
        status = NFMSdisplay_item_files (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEM_FILES : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_ITEMS :
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEMS = <%d>\n", display_type));
        status = NFMSdisplay_items (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEMS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_ITEMS_PARTIAL :
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEMS_PARTIAL = <%d>\n", display_type));
        status = NFMSdisplay_items_partial (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEMS_PARTIAL : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_NODES :
        _NFMSdebug(( fname, "DSP_DISPLAY_NODES = <%d>\n", display_type));
        status = NFMSdisplay_nodes (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_NODES : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_PROGRAMS :
        _NFMSdebug(( fname, "DSP_DISPLAY_PROGRAMS = <%d>\n", display_type));
        status = NFMSdisplay_programs (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_PROGRAMS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_PROJECTS :
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJECTS = <%d>\n", display_type));
        status = NFMSdisplay_projects (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJECTS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_PROJECT_ACL_MAPPING :
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJ_ACL_MAP = <%d>\n", display_type));
        status = NFMSdisplay_project_acl_mapping (in_list, &list1, 
		 &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJ_ACL_MAP : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_PROJECT_SA_MAPPING :
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJ_SA_MAP = <%d>\n", display_type));
        status = NFMSdisplay_project_sa_mapping (in_list, &list1, 
		 &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJ_SA_MAP : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_WHERE_USED_PROJECT :
        _NFMSdebug(( fname, "DSP_DISPLAY_WHERE_USED_PROJECT = <%d>\n",
		     display_type));
        status = NFMSdisplay_where_used_project (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_WHERE_USED_PROJECT : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_PROJECT_MEMBERS :
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJECT_MEMBERS = <%d>\n",
		     display_type));
        status = NFMSdisplay_project_members (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJECT_MEMBERS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_PROJECT_MEMBERS_PARTIAL :
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJECT_MEMBERS_PARTIAL = <%d>\n",
		     display_type));
        status = NFMSdisplay_project_members_partial (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_PROJECT_MEMBERS_PARTIAL : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_SETS :
        _NFMSdebug(( fname, "DSP_DISPLAY_SETS = <%d>\n", display_type));
        status = NFMSdisplay_sets (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_SETS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_STORAGE_AREAS :
        _NFMSdebug(( fname, "DSP_DISPLAY_ST_AREAS = <%d>\n", display_type));
        status = NFMSdisplay_storage_areas (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ST_AREAS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_WORKING_AREAS :
        _NFMSdebug(( fname, "DSP_DISPLAY_WORKING_AREAS = <%d>\n", 
		 display_type));
        status = NFMSdisplay_working_areas (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_WORKING_AREAS : status = <0x%.8x>\n",
		 status));
        break;

    case DSP_DISPLAY_TRANSITIONS :
        _NFMSdebug(( fname, "DSP_DISPLAY_TRANS = <%d>\n", display_type));
        status = NFMSdisplay_transitions (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_TRANS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_USERS :
        _NFMSdebug(( fname, "DSP_DISPLAY_USERS = <%d>\n", display_type));
        status = NFMSdisplay_users (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_USERS : status = <0x%.8x>\n", status));
        break;

    case DSP_DISPLAY_WORKFLOWS :
        _NFMSdebug(( fname, "DSP_DISPLAY_WORKFLOW = <%d>\n", display_type));
        status = NFMSdisplay_workflows (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_WORKFLOW : status = <0x%.8x>\n", status));
        break;

      case DSP_DISPLAY_SO_ON_ITEM :
        _NFMSdebug(( fname, "DSP_DISPLAY_SO_ON_ITEM = <%d>\n", display_type));
        status = NFMSdisplay_so_on_item (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_SO_ON_ITEM : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_SO_HISTORY :
        _NFMSdebug(( fname, "DSP_DISPLAY_SO_HISTORY = <%d>\n", display_type));
        status = NFMSdisplay_so_history (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_SO_HISTORY : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_ARCHIVES :
        _NFMSdebug(( fname, "DSP_DISPLAY_ARCHIVES = <%d>\n", display_type));
        status = NFMSdisplay_archives (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ARCHIVES : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_SAVESETS :
        _NFMSdebug(( fname, "DSP_DISPLAY_SAVESETS = <%d>\n", display_type));
        status = NFMSdisplay_savesets (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_SAVESETS : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_ITEMS_ON_TAPE :
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEMS_ON_TAPE=<%d>\n", display_type));
        status = NFMSdisplay_items_on_tape (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ITEMS_ON_TAPE : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_QUERYS :
        _NFMSdebug(( fname, "DSP_DISPLAY_QUERYS = <%d>\n", display_type));
        status = NFMSdisplay_querys (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_QUERYS : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_ARCHIVE_FLAGS :
        _NFMSdebug(( fname, "DSP_DISPLAY_ARCHIVE_FLAGS = <%d>\n", 
			display_type));
        status = NFMSdisplay_archive_flags (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_ARCHIVE_FLAGS : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_BACKUP_FLAGS :
        _NFMSdebug(( fname, "DSP_DISPLAY_BACKUP_FLAGS = <%d>\n",display_type));
        status = NFMSdisplay_backup_flags(in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_BACKUP_FLAGS : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_RESTORE_FLAGS :
        _NFMSdebug(( fname, "DSP_DISPLAY_RESTORE_FLAGS=<%d>\n", display_type));
        status = NFMSdisplay_restore_flags (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_RESTORE_FLAGS : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_DELETE_FLAGS :
        _NFMSdebug(( fname, "DSP_DISPLAY_DELETE_FLAGS = <%d>\n",display_type));
        status = NFMSdisplay_delete_flags (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_DELETE_FLAGS : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_LOCAL_FILES :
        _NFMSdebug(( fname, "DSP_DISPLAY_LOCAL_FILES = <%d>\n",display_type));
        status = NFMSdisplay_local_files (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_LOCAL_FILES : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_SET_MEMBERS :
        _NFMSdebug(( fname, "DSP_DISPLAY_SET_MEMBERS = <%d>\n",display_type));
        status = NFMSdisplay_set_members (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_SET_MEMBERS : status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_SET_MEMBERS_PARTIAL :
        _NFMSdebug(( fname, "DSP_DISPLAY_SET_MEMBERS_PARTIAL = <%d>\n",
		display_type));
        status = NFMSdisplay_set_members_partial (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_SET_MEMBERS_PARTIAL status = <0x%.8x>\n", 
		   status));
        break;

      case DSP_DISPLAY_WHERE_USED_SET :
        _NFMSdebug(( fname, "DSP_DISPLAY_WHERE_USED_SET=<%d>\n",display_type));
        status = NFMSdisplay_where_used_set (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_WHERE_USED_SET : status = <0x%.8x>\n",
			 status));
        break;

      case DSP_DISPLAY_LABELS :
        _NFMSdebug(( fname, "DSP_DISPLAY_LABELS=<%d>\n",display_type));
        status = NFMSdisplay_labels (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_LABELS : status = <0x%.8x>\n",
			 status));
        break;

      case DSP_DISPLAY_RIS_CATALOGS:
        _NFMSdebug(( fname, "DSP_DISPLAY_RIS_CATALOGS=<%d>\n",display_type));
        status = NFMSdisplay_ris_catalogs (in_list, &list1, &list2);
        _NFMSdebug(( fname, "DSP_DISPLAY_RIS_CATALOGS : status = <0x%.8x>\n",
			 status));
        break;

    default :
        _NFMSdebug(( fname, "Bad Display Type : <%d>\n", display_type));
        ERRload_struct( NFM, NFM_E_BAD_COMMAND, NULL, NULL );
        status = NFM_E_BAD_COMMAND;
        break;
    }

    _NFMSdebug(( fname, "Command Status : <0x%.8x>\n", status));
    cmd_status = status;
    ret_status = status;
    MEMclose( &in_list );

    if( (cmd_status != NFM_S_SUCCESS) && (cmd_status != NFM_I_NO_MORE_BUFFERS))
    {
	MEMclose( &list1 );
	MEMclose( &list2 );
	list1 = NULL;
 	list2 = NULL;
    }

    status = NFMSsend_two_buffers( cmd_status, list1, list2 );
    _NFMSdebug((fname, "NFMSsend_two_buffers : <0x%.8x>\n", status));

/* This was causing memory to grow 07/12/94 MRG */

	MEMclose( &list1 );
	MEMclose( &list2 );
	list1 = NULL;
 	list2 = NULL;

    ERRreset_struct();

    return (cmd_status);
}
	 
