
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFfiles.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdelete_files_from_item (catalog, item, revision)
    char    *catalog;
    char    *item;
    char    *revision;
  {
    long    status;
    int     i, j, count;
    char    **data_ptr, **column_ptr, **format_ptr;
    char    **data;
    char    str[1024];  /* attr_list is fixed */
    MEMptr  attr_list = NULL;
    NFFcopy_ptr  ptr;     /*  Pointer to the item/file structure  */

    static  char *fname = "NFFdelete_files_from_item";

    _NFIdebug ((fname, "catalog = <%s>\n", catalog));
    _NFIdebug ((fname, "item = <%s>\n", item));
    _NFIdebug ((fname, "revision = <%s>\n", revision));

    if (strcmp (catalog, "") == 0)
     {
        status = NFI_E_NO_CATALOG;
        _NFIdebug ((fname, "Null catalog name : status = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if (strcmp (item, "") == 0)
     {
        status = NFI_E_NO_ITEM;
        _NFIdebug ((fname, "Null item name : status = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    
    if (strcmp (revision, "") == 0)
     {
        status = NFI_E_NO_REV;
        _NFIdebug ((fname, "Null item revision : status = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /* Malloc memory for the ptr */

    if ((ptr = (NFFcopy_ptr) malloc
        (sizeof (struct NFFcopy_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFcopy_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFcopy_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      } 

    /*  Initialize the structure  */

    ptr->command = NFI_F_DELETE;
    strcpy (ptr->catalog, catalog);
    strcpy (ptr->item, item);
    strcpy (ptr->revision, revision);
    ptr->label   = ADD_FILE_LABEL;
    ptr->act_row = 0;
    ptr->act_col = 0;
    ptr->add_ptr     = NULL;
    ptr->file_ptr    = NULL;
    ptr->temp_list   = NULL;

    if ((ptr->file_ptr = (NFFadd_ptr) malloc
        (sizeof (struct NFFadd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        NFFfree_copy (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    (ptr->file_ptr)->done = FALSE;
    (ptr->file_ptr)->command = 0;
    (ptr->file_ptr)->rows = NULL;
    (ptr->file_ptr)->active_attribute = -1;
    (ptr->file_ptr)->validate_row = -1;
    (ptr->file_ptr)->attr_list = NULL;
    (ptr->file_ptr)->data_list = NULL;
    (ptr->file_ptr)->value_list = NULL;
    strcpy ((ptr->file_ptr)->entity, catalog); 

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMRget_file_information function ...\n"));

    status = NFMRget_file_information (catalog, item, revision,
                                (long) NFM_DELETE_FILE_FROM_ITEM, &attr_list,
                 &((ptr->file_ptr)->data_list), &((ptr->file_ptr)->value_list));

    _NFIdebug ((fname, "returned from NFMRget_file_information function\n"));

    if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        _NFIdebug ((fname, "NFMRget_file_information function = <0x%.8x>\n",
                    status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    
    if ((status = MEMbuild_array (attr_list)) != MEM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array ((ptr->file_ptr)->data_list)) != MEM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }
  
    if (ptr->file_ptr->value_list)
     {
        if ((status = MEMbuild_array ((ptr->file_ptr)->value_list)) != MEM_S_SUCCESS
)
         {
            MEMclose (&attr_list);
            NFMRreset_file_information (catalog, item, revision);
            _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            NFFerase_message ();
            NFFfree_copy (NULL, ptr);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
         }
     }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list", attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", (ptr->file_ptr)->data_list,
                         _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers("value_list", (ptr->file_ptr)->value_list,
                         _NFMdebug_st.NFIdebug_file);
      } 

    /* Modify the attr_list to put in the needed attributes */
    /* Put in the following attributes "n_write", "n_datatype", "n_nfmname",
       In order to use the existing tools code for files */

    data_ptr = (char **) attr_list->data_ptr; 
    format_ptr = (char **) attr_list->format_ptr; 
    column_ptr = (char **) attr_list->column_ptr; 

    /* open the attr_list */

    status = MEMopen (&((ptr->file_ptr)->attr_list),   
             (attr_list->row_size * attr_list->rows) + (attr_list->rows * 128));
    if (status != MEM_S_SUCCESS)
     {
        MEMclose (&attr_list);
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     } 

    /* write all the existing columns into the attr_list */

    for (i = 0; i < attr_list->columns; ++i)
     {
        status = MEMwrite_format ((ptr->file_ptr)->attr_list,
                                  column_ptr[i], format_ptr[i]);
        if (status != MEM_S_SUCCESS)
         {
            MEMclose (&attr_list);
            NFMRreset_file_information (catalog, item, revision);
            _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
            NFFerase_message ();
            NFFfree_copy (NULL, ptr);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
         } 
      }  

    /* write the needed attributes to the attribute list */
 
    status = MEMwrite_format ((ptr->file_ptr)->attr_list,
                              "n_datatype", "char(11)");
    if (status != MEM_S_SUCCESS)
     {
        MEMclose (&attr_list);
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     } 
 
    status = MEMwrite_format ((ptr->file_ptr)->attr_list,
                              "n_write", "char(1)");
    if (status != MEM_S_SUCCESS)
     {
        MEMclose (&attr_list);
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     } 
 
    status = MEMwrite_format ((ptr->file_ptr)->attr_list,
                              "n_name", "char(48)");
    if (status != MEM_S_SUCCESS)
     {
        MEMclose (&attr_list);
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     } 

    data = (char **) (ptr->file_ptr->data_list)->format_ptr;

    /* put the data into the attr_list */

    for (i = 0; i < attr_list->rows; ++i) 
     {
        str[0] = 0;
        for (j = 0; j < attr_list->columns; ++j)
         {
            count = attr_list->columns * i + j;
            strcat (str, data_ptr[count]);
            strcat (str, "\1");
         }

        /* write the three additional attributes to the str */

        strcat (str, data[i]);   /* n_datatype */
        strcat (str, "\1");
        strcat (str, "Y");       /* n_write */
        strcat (str, "\1");
        strcat (str, data_ptr[attr_list->columns * i]);   /* n_name */
        strcat (str, "\1");
 
        status = MEMwrite ((ptr->file_ptr)->attr_list, str);
        if (status != MEM_S_SUCCESS)
         {
            MEMclose (&attr_list);
            NFMRreset_file_information (catalog, item, revision);
            _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            NFFerase_message ();
            NFFfree_copy (NULL, ptr);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
         } 
     }

    MEMclose (&attr_list); 
 
    status = MEMbuild_array ((ptr->file_ptr)->attr_list);
    if (status != MEM_S_SUCCESS)
     {
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     } 

    /* get all the readableable columns */

    status = _NFFinit_rows ((ptr->file_ptr)->attr_list, "n_read",
                             &((ptr->file_ptr)->rows));
    if (status != NFI_S_SUCCESS)
     {
        NFMRreset_file_information (catalog, item, revision);
        NFFfree_copy (NULL, ptr);
        NFFerase_message ();
        _NFIdebug ((fname, "_NFFinit_rows = <%d>\n", status));
        if (status == MEM_E_NULL_BUFFER)
            ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    _NFIdebug ((fname, "_NFFinit_rows returned sucessfully\n"));

    /* Call _NFFprocess_item_files to process the form */

    status = _NFFprocess_item_files (ptr);
    if (status != NFI_S_SUCCESS)
      {
        NFMRreset_file_information (catalog, item, revision);
        _NFIdebug ((fname, "_NFFprocess_item_files = <0x%.8x>\n", status));
        NFFfree_copy (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


