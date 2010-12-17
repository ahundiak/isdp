
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFutility.h"

/*****************************************************************************
 *                                                                           *
 *   This function is used to process the backup of flagged items.           *
 *                                                                           *
 *****************************************************************************/

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFbackup_flagged_items ()
  {
    long    status;
    char    title[NFF_MAX_MESSAGE];
    NFFutil_ptr    ptr;         /*  Pointer to the utility structure  */

    static  char *fname = "_NFFbackup_flagged_items";

    _NFIdebug ((fname, " Function entered\n"));

    /* Malloc memory for the utility ptr */

    if ((ptr = (NFFutil_ptr) malloc (sizeof (struct NFFutility_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFutility_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFutility_st));
        NFFglobal.status = NFI_E_MALLOC;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    ptr->type = BACKUP_FLAGGED_ITEMS;
    ptr->done = FALSE;
    ptr->utility = 0;
    strcpy (ptr->label, "");
    ptr->sa_list = NULL;
    ptr->item_list = NULL;
    ptr->label_list = NULL;

    NFFglobal.NFMRfunction[0] = NFMRbackup_files;

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /* Call the NFMRquery_backup function to get the information */

    status = NFMRquery_backup (&(ptr->sa_list),
                               &(ptr->item_list), &(ptr->label_list));
    if (status != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, " NFMRquery_backup : status = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_utility (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (ptr->item_list == NULL)
     {
        status = NFI_W_NO_ITEMS_FLAGGED_B;
        _NFIdebug ((fname, "No items flagged : status = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_utility (NULL, ptr);
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    if ((ptr->item_list)->rows <= 0)
     {
        status = NFI_W_NO_ITEMS_FLAGGED_B;
        _NFIdebug ((fname, "No items flagged : status = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_utility (NULL, ptr);
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if ((status = MEMbuild_array (ptr->sa_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_utility (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (ptr->item_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_utility (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (ptr->label_list)
     {
         if ((status = MEMbuild_array (ptr->label_list)) != MEM_S_SUCCESS)
          {
             _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
             NFFerase_message ();
             _NFFfree_utility (NULL, ptr);
             ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MEM);
          }
     }

    /*  Load in the utility form  */

    if ((status = (long) FIf_new (AB_UTILITY_LABEL, AB_UTILITY_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_utility (NULL, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data from the file_list into the UTI_SA_LIST mcf. */

    status = _NFFgeneric_load_data (NFFglobal.current_form, UTI_SA_LIST, 
                                    ptr->sa_list); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFgeneric_load_data = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_utility (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Load the data from the label_list into the UTI_LABEL_LIST scf. */

    status = _NFFgeneric_load_data (NFFglobal.current_form, UTI_LABEL_LIST, 
                                    ptr->label_list); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFgeneric_load_data = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_utility (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Load the data from the item_list, into the UTI_ITEM_LIST. */

    status = _NFFutil_load_item_data (NFFglobal.current_form, UTI_ITEM_LIST, 
                                    ptr->item_list); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFutil_load_item_data = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_utility (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_utility (&NFFglobal.current_form, ptr);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    FIfld_set_max_num_chars (NFFglobal.current_form, UTI_LABEL_FIELD, 6);

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_utility (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum (title, NFT_P_BACKUP_FLAGGED_ITEMS,
                                      NULL)) != UMS_S_SUCCESS)
     {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Backup Flagged Items");
     }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, UTILITY_TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_utility (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    status = _NFFerase_label_gadgets (NFFglobal.current_form) ;
    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "Failure : status = <0x%.8x>\n", status));
        _NFFfree_utility (&NFFglobal.current_form, ptr);
	return (status) ;
      }
    

/*    
    FIg_disable (NFFglobal.current_form, UTI_LABEL_LIST);
    FIg_disable (NFFglobal.current_form, UTI_LABEL_FIELD);
*/
    /*  Display the form  */

    if ((status = (long) FIf_display
        (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_utility (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

