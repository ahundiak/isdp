
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFfiles.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFcopy_item (catalog, item, revision)
  char   *catalog; 
  char   *item; 
  char   *revision; 
  {
    long    status;

    static  char *fname = "NFFcopy_item";

    /*  Pointer to the item structure  */

    NFFcopy_ptr    ptr;

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

    /*  Initialize the structure  */

    if ((ptr = (NFFcopy_ptr) malloc
        (sizeof (struct NFFcopy_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFcopy_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFcopy_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    ptr->command = NFI_F_COPY;
    strcpy (ptr->catalog, catalog);
    strcpy (ptr->item, item);
    strcpy (ptr->revision, revision);
/*
    ptr->label   = COPY_FILE_LABEL;
*/
    ptr->label   = ADD_FILE_LABEL;  /* change to "PROCESS_FILE_LABEL */
    ptr->act_row = 0;
    ptr->act_col = 0;
    ptr->add_ptr     = NULL;
    ptr->file_ptr    = NULL;
    ptr->temp_list   = NULL;

    /*  Initialize the add structure  */

    if ((ptr->add_ptr = (NFFadd_ptr) malloc
        (sizeof (struct NFFadd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        NFFfree_copy (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    (ptr->add_ptr)->done = FALSE;
    (ptr->add_ptr)->command = COPY_ITEM;
    (ptr->add_ptr)->rows = NULL;
    (ptr->add_ptr)->active_attribute = -1;
    (ptr->add_ptr)->validate_row = -1;
    (ptr->add_ptr)->attr_list = NULL;
    (ptr->add_ptr)->data_list = NULL;
    (ptr->add_ptr)->value_list = NULL;
    strcpy ((ptr->add_ptr)->entity, catalog);

    /*  Initialize the file structure  */

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
    (ptr->file_ptr)->command = COPY_ITEM;
    (ptr->file_ptr)->rows = NULL;
    (ptr->file_ptr)->active_attribute = -1;
    (ptr->file_ptr)->validate_row = -1;
    (ptr->file_ptr)->attr_list = NULL;
    (ptr->file_ptr)->data_list = NULL;
    (ptr->file_ptr)->value_list = NULL;
    strcpy ((ptr->file_ptr)->entity, catalog);

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "calling NFMRget_item_attr_for_copy function ...\n"));

    status = NFMRget_item_attr_for_copy (catalog, item, revision,
                 &((ptr->add_ptr)->attr_list),  &((ptr->add_ptr)->data_list),
                 &((ptr->add_ptr)->value_list), &((ptr->file_ptr)->attr_list),
                 &((ptr->file_ptr)->data_list), &((ptr->file_ptr)->value_list));

    _NFIdebug ((fname, "returned from NFMRget_item_attr_for_copy function\n"));


    if (status != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRget_item_attr_for_copy function = <0x%.8x>\n",
                    status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array ((ptr->add_ptr)->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array ((ptr->add_ptr)->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array ((ptr->add_ptr)->value_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }  

    if ((status = MEMbuild_array ((ptr->file_ptr)->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array ((ptr->file_ptr)->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array ((ptr->file_ptr)->value_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list", (ptr->add_ptr)->attr_list,
                         _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", (ptr->add_ptr)->data_list,
                         _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers("value_list", (ptr->add_ptr)->value_list,
                         _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("attr_list", (ptr->file_ptr)->attr_list,  
                         _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", (ptr->file_ptr)->data_list,
                         _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers("value_list", (ptr->file_ptr)->value_list,
                         _NFMdebug_st.NFIdebug_file);
      }

    /*  get the n_itemname and n_itemrev offsets.  If they are not found in 
        the list, assume that the user turned them off in the attribute
        subsystem and there values will be the defaults in the attribute
        subsystem.                                                       */  

    /* get all the writable columns */

    status = _NFFinit_rows ((ptr->file_ptr)->attr_list, "n_write", 
                             &((ptr->file_ptr)->rows));
    if (status != NFI_S_SUCCESS)
     {
        NFFfree_copy (NULL, ptr);
        NFFerase_message ();
        _NFIdebug ((fname, "_NFFinit_rows = <%d>\n", status));
        if (status == MEM_E_NULL_BUFFER)
            ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    _NFIdebug ((fname, "_NFFinit_rows returned sucessfully\n"));

    /*  Erase the message  */

    NFFerase_message ();

    /* Call _NFFcopy_item to process the copy item forms */

    status = _NFFcopy_item (ptr);
    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcopy_item = <0x%.8x>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


