#include "machine.h"
#include "NFMRextern.h"
#include "NFMdef.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRvalidate_project
 
 Abstract:
     This function will validate a project name
     
 */

long NFMRvalidate_project ( project_name )
    char    *project_name;    /* i - the name of the project to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_project";

    _NFMRdebug(( fname, "Project Name : <%s>\n", project_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format (info, "n_projectname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "%d\1", NFM_VALIDATE_PROJECT );
    strcat (str, project_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRvalidate_catalog
 
 Abstract:
     This function will validate a catalog name
     
 */

long NFMRvalidate_catalog ( catalog_name )
    char    *catalog_name;    /* i - the name of the catalog to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];

    static char *fname = "NFMRvalidate_catalog";

    _NFMRdebug(( fname, "Catalog Name : <%s>\n", catalog_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "%d\1", NFM_VALIDATE_CATALOG );
    strcat (str, catalog_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose (&info);
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
 
    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_item
 
 Abstract:
     This function will validate an item 
     
 */

long NFMRvalidate_item ( catalog_name, item_name )
    char    *catalog_name;    /* i - the name of catalog item is in */
    char    *item_name;       /* i - the name of the item to validate */

{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_item";

    _NFMRdebug(( fname, "Catalog Name : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "Item name    : <%s>\n", item_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( str, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "n_itemname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "%d\1", NFM_VALIDATE_ITEM );
    strcat (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose (&info);
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_revision
 
 Abstract:
     This function will validate an item revision
     
 */

long NFMRvalidate_revision ( catalog_name, item_name, item_revision, flag )
    char    *catalog_name;    /* i - the name of catalog item is in */
    char    *item_name;       /* i - the name of the item to validate */
    char    *item_revision;   /* i - specific item revision to validate */
    int	    *flag;	      /* o - 1 if a set item - 0 if not a set item */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    char   **data_ptr;
    static char *fname = "NFMRvalidate_revision";

    _NFMRdebug(( fname, "Catalog Name  : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "Item Name     : <%s>\n", item_name));
    _NFMRdebug(( fname, "Item Revision : <%s>\n", item_revision));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( str, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_catalogname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "n_itemname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "n_itemrev", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_REVISION );
    strcat (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_revision);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
 

    status = MEMbuild_array( info );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    } 
    data_ptr = (char**) info->data_ptr;
    *flag = atoi( data_ptr[0] );
    MEMclose (&info);

    _NFMRdebug(( fname, "Set Indicator : <%d>\n", *flag ));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_search
 
 Abstract:
     This function will validate a search name
     
 */

long NFMRvalidate_search ( search_name, owner )
    char    *search_name;    /* i - the name of the search to validate */
    char    *owner;	     /* o - the owner of the search */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    char   **data_ptr;
    static char *fname = "NFMvalidate_search";

    _NFMRdebug(( fname, "name : <%s>\n", search_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_REPORTNAME );
    status = MEMwrite_format (info, "n_searchname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_SEARCH );
    strcat (str, search_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    status = MEMbuild_array( info );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    } 

    data_ptr = (char**) info->data_ptr;
    strcpy( owner, data_ptr[0] );
    MEMclose (&info);

    _NFMRdebug(( fname, "Search <%s> owned by <%s>\n", search_name, owner));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_sort
 
 Abstract:
     This function will validate a sort name
     
 */

long NFMRvalidate_sort ( sort_name, owner )
    char    *sort_name;    /* i - the name of the sort to validate */
    char    *owner;	   /* o - the owner of the sort */
{
    MEMptr info     = NULL;
    char   **data_ptr;
    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_sort";

    _NFMRdebug(( fname, "name : <%s>\n", sort_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_REPORTNAME );
    status = MEMwrite_format (info, "n_sortname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "%d\1", NFM_VALIDATE_SORT );
    strcat (str, sort_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
 
    status = MEMbuild_array( info );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    } 

    data_ptr = (char**) info->data_ptr;
    strcpy( owner, data_ptr[0] );
    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_working_area

 Abstract:
     This function will validate a working area

 */

long NFMRvalidate_working_area ( wa_name, owner )
    char    *wa_name;    /* i - the name of the working area to validate */
    char    *owner;	 /* o - the owner of the working area */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    char   **data_ptr;
    static char *fname = "NFMRvalidate_working_area";

    _NFMRdebug(( fname, "name : <%s>\n", wa_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_SANAME );
    status = MEMwrite_format (info, "wk_name", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "%d\1", NFM_VALIDATE_WK_AREA );
    strcat (str, wa_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    status = MEMbuild_array( info );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    } 
    data_ptr = (char**) info->data_ptr;
    strcpy( owner, data_ptr[0] );
    MEMclose (&info);

    _NFMRdebug(( fname, "Working area <%s> owned by <%s>\n", wa_name, owner));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_st_area
 
 Abstract:
     This function will validate a st_area name
     
 */

long NFMRvalidate_st_area ( st_area_name )
    char    *st_area_name;    /* i - the name of the st_area to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_st_area";

    _NFMRdebug(( fname, "sa name : <%s>\n", st_area_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_SANAME );
    status = MEMwrite_format (info, "n_saname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_ST_AREA );
    strcat (str, st_area_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_node
 
 Abstract:
     This function will validate a node name

 */

long NFMRvalidate_node ( node_name )
    char    *node_name;    /* i - the name of the node to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_node";

    _NFMRdebug(( fname, "name : <%s>\n", node_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_NODENAME );
    status = MEMwrite_format (info, "n_nodename", str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_NODE );
    strcat (str, node_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
 
    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_set_item
 
 Abstract:
     This function will validate a set item
 */

long NFMRvalidate_set_item ( set_cat_name, set_item_name )
    char    *set_cat_name;    /* i - the name of catalog item is in */
    char    *set_item_name;   /* i - the name of the item to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_set_item";

    _NFMRdebug(( fname, "Set Cat Name  : <%s>\n", set_cat_name));
    _NFMRdebug(( fname, "Set Item Name : <%s>\n", set_item_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_setcatname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "n_setitemname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_SET_ITEM );
    strcat (str, set_cat_name);
    strcat (str, "\1");
    strcat (str, set_item_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_set_rev
 
 Abstract:
     This function will validate an item revision

 */

long NFMRvalidate_set_rev ( set_cat_name, set_item_name, set_item_rev )
    char    *set_cat_name;    /* i - the name of catalog item is in */
    char    *set_item_name;       /* i - the name of the item to validate */
    char    *set_item_rev;   /* i - specific item revision to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_set_rev";

    _NFMRdebug(( fname, "Catalog Name  : <%s>\n", set_cat_name));
    _NFMRdebug(( fname, "Item Name     : <%s>\n", set_item_name));
    _NFMRdebug(( fname, "Item Revision : <%s>\n", set_item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( str, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_setcatname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "n_setitemname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "n_setitemrev", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_SET_REV );
    strcat (str, set_cat_name);
    strcat (str, "\1");
    strcat (str, set_item_name);
    strcat (str, "\1");
    strcat (str, set_item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_wf
 
 Abstract:
     This function will validate a wf name
 */

long NFMRvalidate_workflow ( workflow_name )
    char    *workflow_name;    /* i - the name of the workflow to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_workflow";

    _NFMRdebug(( fname, "wf_name : <%s>\n", workflow_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_WORKFLOWNAME );
    status = MEMwrite_format (info, "n_workflowname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_WORKFLOW );
    strcat (str, workflow_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_acl
 
 Abstract:
     This function will validate an acl name

 */

long NFMRvalidate_acl ( wf_name, acl_name )
    char    *wf_name;     /* i - the name of the workflow containing the acl */
    char    *acl_name;    /* i - the name of the acl to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_acl";

    _NFMRdebug(( fname, "name : <%s>\n", acl_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_WORKFLOWNAME );
    status = MEMwrite_format (info, "n_wfname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_ACLNAME );
    status = MEMwrite_format (info, "n_aclname", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf(str, "%d\1", NFM_VALIDATE_ACL );
    strcat (str, wf_name);
    strcat (str, "\1");
    strcat (str, acl_name );
    strcat (str, "\1" );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
 
    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRvalidate_user
 
 Abstract:
     This function will validate an user name

 */

long NFMRvalidate_user ( user_name )
    char    *user_name;    /* i - the name of the user to validate */
{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    char   str[50];
    static char *fname = "NFMRvalidate_user";

    _NFMRdebug(( fname, "name : <%s>\n", user_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "case", "char(10)");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( str, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format (info, "n_username", str );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf(str, "%d\1", NFM_VALIDATE_USER );
    strcat (str, user_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALIDATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    MEMclose( &info );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}
