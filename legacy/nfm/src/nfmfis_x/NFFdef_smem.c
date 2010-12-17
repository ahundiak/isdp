
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFset_mem.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdefine_members (project, catalog_name, set_name, revision, command)
  char    *project;      /* I : Used if command is Define PROJECT members */
  char    *catalog_name; /* I : Used if command is Define SET members     */
  char    *set_name;     /* I : Used if command is Define SET members     */
  char    *revision;     /* I : Used if command is Define SET members     */
  char    *command;      /* I                                             */
  {
    long    status;
    long    type;
    int     error_message = 0;
    char    **data;
    char    s[NFF_MAX_MESSAGE];

    static  char *fname = "NFFdefine_members";

    /*  Pointer to the item structure  */

    NFFset_ptr    entity;

    _NFIdebug ((fname, "Project Name = <%s>\n", project));
    _NFIdebug ((fname, "Catalog Name = <%s>\n", catalog_name));
    _NFIdebug ((fname, "Set Name     = <%s>\n", set_name));
    _NFIdebug ((fname, "Revision     = <%s>\n", revision));
    _NFIdebug ((fname, "Command      = <%s>\n", command));

    if (strcmp (command, NFI_M_ADD_ITEMS_TO_SET) == 0)
     {
        if (strcmp (catalog_name, "") == 0)
         {
            status = NFI_E_NO_CATALOG; 
            _NFIdebug ((fname, "Null Catalog : status = <0x%.8x>\n", status));
            ERRload_struct (NFI, status, NULL);  
            return (status);
         }
   
        if (strcmp (set_name, "") == 0)
         {
            status = NFI_E_NO_SET; 
            _NFIdebug ((fname, "Null Set Name : status = <0x%.8x>\n", status));
            ERRload_struct (NFI, status, NULL);  
            return (status);
         }
    
        error_message = NFI_E_ADD_SET_MEMBERS;
     }
    else if (strcmp (command, NFI_M_ADD_ITEMS_TO_PROJECT) == 0)
     {
        if (strcmp (project, "") == 0)
         {
            status = NFI_E_NO_PROJECT; 
            _NFIdebug ((fname, "Null Project : status = <0x%.8x>\n", status));
            ERRload_struct (NFI, status, NULL);  
            return (status);
         }
 
        error_message = NFI_E_ADD_PROJECT_MEMBERS;
     }
    else
     {
        status = NFI_E_BAD_COMMAND; 
        _NFIdebug ((fname, "Invalid command : status = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, NULL);  
        return (status);
     }

    /*  Initialize the item structure  */

    if ((entity = (NFFset_ptr) malloc (sizeof (struct NFFset_mem))) == NULL)
     {
        _NFIdebug ((fname,
             "malloc failed: size = <%d>\n", sizeof (struct NFFset_mem)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFset_mem));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
     }

    entity->done       = FALSE;
    entity->level      = 1;
    entity->command    = 0;
    entity->rows       = 0;
    entity->vis_rows   = 0;
    entity->columns    = 4;
    entity->active_row = -1;
    entity->project_offset = -1;
    entity->cat_offset = -1;
    entity->item_offset = -1;
    entity->rev_offset  = -1;
    entity->type_offset = -1;
    entity->level_offset = -1;
    entity->status_offset = -1;
    entity->set_offset = -1;
    entity->cat_name_offset = -1;
    entity->item_name_offset = -1;
    entity->rev_name_offset = -1;
    entity->toggle_offset   = -1;
    entity->cat_displayed   = FALSE;
    entity->item_displayed  = FALSE;
    entity->rev_displayed   = FALSE;
    strcpy (entity->curr_cat, catalog_name); 
    strcpy (entity->curr_item, ""); 
    strcpy (entity->curr_rev, ""); 
    entity->attr_list  = NULL;
    entity->data_list  = NULL;
    entity->cat_data   = NULL;
    entity->item_data  = NULL;
    entity->member_list = NULL;

    if (strcmp (command, NFI_M_ADD_ITEMS_TO_SET) == 0)
     {
        entity->type = 1;
        strcpy (entity->project,  ""); 
        strcpy (entity->on_text,  S_ON_TEXT); 
        strcpy (entity->off_text, S_OFF_TEXT); 
     } 
    else
     {
        entity->type = 0;
        strcpy (entity->project,  project); 
        strcpy (entity->on_text,  P_ON_TEXT); 
        strcpy (entity->off_text, P_OFF_TEXT); 
     } 

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    /*  level -

        -1:  parent and all children,
         0:  parent only,
        >0:  parent and >0 levels deep of children

        type -

         0:  all instances of an entity member
         1:  only unique instances of an entity member  */

    type = 0;

    if (strcmp (command, NFI_M_ADD_ITEMS_TO_SET) == 0)
     {
        status = (long) NFMRquery_set_members ((long) 0, catalog_name, set_name,
                         revision, (long) entity->level, (long) type,
                         &(entity->attr_list), &(entity->data_list));
        if (status != NFM_S_SUCCESS)
         {
           _NFIdebug ((fname, "NFMRquery_set_members = <0x%.8x>\n", status));
           NFFerase_message ();
           _NFFfree_setm (NULL, entity);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (status);
         }
     }
    else
     {
        status = (long) NFMRquery_project_members ((long) 0, project,
                                    &(entity->attr_list), &(entity->data_list));
        if (status != NFM_S_SUCCESS)
         {
            _NFIdebug ((fname, "NFMRquery_project_members = <0x%.8x>\n",  
                            status));
            NFFerase_message ();
            _NFFfree_setm (NULL, entity);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
         }
     } 

    if ((status = MEMbuild_array (entity->attr_list)) != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();

        /*  Set the global command status  */

        NFFglobal.status = status;

        /*  Set the next state  */

        NFFset_to_state ();
        _NFFfree_setm (NULL, entity);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    if ((status = MEMbuild_array (entity->data_list)) != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        
        /*  Set the global command status  */

        NFFglobal.status = status;

        /*  Set the next state  */

        NFFset_to_state ();
        _NFFfree_setm (NULL, entity);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    entity->rows = entity->data_list->rows;

    /* Malloc memory for the member_list if rows > 0 */

    if (entity->rows > 0)
     {
       entity->member_list = (NFFmem_struct) malloc 
                (entity->rows * sizeof (struct NFFmember_struct));  
       if (entity->member_list == NULL)
        {
          status = NFI_E_MALLOC;
  
          _NFIdebug ((fname, "malloc failed; size = <%d>\n", 
                      (entity->rows * sizeof (struct NFFmember_struct))));
          ERRload_struct (NFI, status, "%d", 
                         (entity->rows * sizeof (struct NFFmember_struct)));
          _NFFfree_setm (NULL, entity);
          NFFset_to_state ();
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (status);
        }
     }

    if (_NFMdebug_st.NFIdebug_on)
     {
        MEMprint_buffer ("attr_list", entity->attr_list,  
                         _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", entity->data_list, 
                         _NFMdebug_st.NFIdebug_file);
     }

    /*  Load in the form  */

    if (strcmp (command, NFI_M_ADD_ITEMS_TO_SET) == 0)
        status = (long) FIf_new (ADD_SET_MEMBERS_LABEL, DEFINE_MEMBER_FORM,
                                 _NFFnotify, &(NFFglobal.current_form));
    else
        status = (long) FIf_new (ADD_PROJECT_MEMBERS_LABEL, DEFINE_MEMBER_FORM,
                                 _NFFnotify, &(NFFglobal.current_form));

    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();

        /*  Set the global command status  */

        NFFglobal.status = NFI_E_FORM;

        /*  Set the next state  */

        NFFset_to_state ();
        _NFFfree_setm (NULL, entity);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }
        
    /*  Load the data in the Information MCF field  */

    if ((status = _NFFload_members_mcf
        (NFFglobal.current_form, entity, command)) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFload_members_mcf %d\n", status));
        NFFerase_message ();
        
        /*  Set the global command status  */
        
        NFFglobal.status = status;
        
        /*  Set the next state  */
        
        NFFset_to_state ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /* get the short list of catalogs */

    status = _NFFget_list_of_catalogs (&(entity->cat_data),
                                       &(entity->cat_name_offset));
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "NFFget_list_of_catalogs = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning FAILURE\n"));
            NFFset_to_state ();
        return (status);
     }
    _NFIdebug ((fname, "Offset to n_catalogname = <%d>\n", 
                entity->cat_name_offset));

    if (strcmp (command, NFI_M_ADD_ITEMS_TO_PROJECT) == 0)
     {
        if (entity->data_list->rows > 0)
         {
            data = (char **) entity->data_list->data_ptr;
            strcpy (entity->curr_cat, data[entity->cat_offset]);
         }
        else if (strcmp (catalog_name, "") == 0)
         {
            data = (char **) entity->cat_data->data_ptr;
            strcpy (entity->curr_cat, data[entity->cat_name_offset]);
         } 
     }

    status = _NFFget_list_of_items (NFFglobal.current_form, HIDDEN_SCF,
                                    FALSE, entity, entity->project,
                                    entity->curr_cat);
    if ((status != NFI_S_SUCCESS) && (status != NFI_I_NO_ITEMS))
     {
        _NFIdebug ((fname, "NFFget_list_of_items = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning FAILURE\n"));
            NFFset_to_state ();
        return (status);
     }
         
    if (status == NFI_I_NO_ITEMS)
        entity->item_data = NULL;
 
    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) entity)) != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
         NFFerase_message ();

         /*  Set the global command status  */

         NFFglobal.status = NFI_E_FORM;

         /*  Set the next state  */

         NFFset_to_state ();
         _NFFfree_setm (&NFFglobal.current_form, entity);
         ERRload_struct  
                    (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
     }

    /*  Erase the message  */

    NFFerase_message ();

    /* Set the title of the form */

    if (strcmp (command, NFI_M_ADD_ITEMS_TO_SET) == 0)
     {
        if ((status = (long) UMSGetByNum (s, NFI_P_ADD_SET_MEM, "%s%s",
                                     set_name, revision)) != UMS_S_SUCCESS)
         {
            _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
            _NFIdebug ((fname, "defaulting title\n"));
            sprintf (s, "Add Items to Set \"%s\" Revision \"%s\"",
                    set_name, revision);
         }
      }
    else
     {
        if ((status = (long) UMSGetByNum (s, NFI_P_ADD_PRJ_MEM, "%s",
                                          project)) != UMS_S_SUCCESS)
         {
            _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
            _NFIdebug ((fname, "defaulting title\n"));
            sprintf (s, "Add Items to Project \"%s\"", project);
         }
     }

    if ((status = (long) FIg_set_text
            (NFFglobal.current_form, TITLE1, s)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        NFFset_to_state ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* set the toggle on and off text. */

    status = (long) FIg_set_on_text (NFFglobal.current_form, TYPE_TOGGLE, 
                                     entity->on_text);
    if (status != FI_SUCCESS) 
     {
        _NFIdebug ((fname, "FIg_set_on_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_on_text", status);
        NFFset_to_state ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    status = (long) FIg_set_off_text (NFFglobal.current_form, TYPE_TOGGLE, 
                                      entity->off_text);
    if (status != FI_SUCCESS) 
     {
        _NFIdebug ((fname, "FIg_set_off_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_off_text",
                        status);
        NFFset_to_state ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    status = _NFFdisplay_catalogs (NFFglobal.current_form, HIDDEN_SCF, entity);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFdisplay_catalogs = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, NULL);
        _NFFfree_setm (&NFFglobal.current_form, entity);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* adjust and center the form */

    status = _NFFadjust_members_form (NFFglobal.current_form);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFadjust_members_form = <0x%.8x>\n", status));

        /*  Set the global command status  */

        NFFglobal.status = NFI_E_FORM;

        /*  Set the next state  */

        NFFset_to_state ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
     }

    /*  Display the form  */

    if ((status = (long) FIf_display(NFFglobal.current_form)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));

        /*  Set the global command status  */

        NFFglobal.status = NFI_E_FORM;

        /*  Set the next state  */

        NFFset_to_state ();
        _NFFfree_setm (&NFFglobal.current_form, entity);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Position the cursor into the item_name field  */

/*
        status = FIfld_pos_cursor (NFFglobal.current_form, ITEM_FIELD,
                                   0, 0, 0, 0, 0, 0);
        if (status != FI_SUCCESS)
          {
                _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
                error_message = NFI_E_FORM;
                ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d",
                                              "FIfld_pos_cursor", status);
                _NFFfree_setm (&NFFglobal.current_form, entity);
                NFFset_to_state ();
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
          }
*/
 
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdefine_set_members_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    long    status = NFI_S_SUCCESS;
    int     working_message;
    int     i, rows = -1;
    char    *text = "Set Name";
    char    command[15];
    struct  NFMmember_info *member_list = NULL;

    static  char *fname = "_NFFdefine_set_members_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFset_ptr    entity;

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    strcpy (command, NFI_M_ADD_ITEMS_TO_SET);

    /*  Pull out the pointer to all of the buffers  */

    status = (long) FIf_get_user_pointer (*form, (char *) &entity);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
     }
    
    /* Clear out the message strip */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    working_message = NFI_I_ADD_SET_MEMBERS;

    switch (g_label)
     {
       case FI_HELP:

          strcpy (command, NFI_M_ADD_ITEMS_TO_SET);

          if (status = _NFFhelp_topic (command))
           {
              _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic",
                                  status);
              status = NFI_E_HELP;
           }

       break;

       case FI_CANCEL:

          /*  Load the global error structure  */

          ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

          /*  Set the next state  */

          if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

          /*  Close all allocated buffers and delete the form  */

          _NFFfree_setm (form, entity);

       break;

       case FI_ACCEPT:

          if (entity->data_list->rows >= entity->rows)
           {
              /* The user has not added any members.  Send message to the
                 user to cancel this form to exit.     */

              NFFform_message (CURRENT_LABEL, NFI_I_NO_MEMBERS_ADDED, NULL);

              FIg_set_state_off (*form, FI_ACCEPT);
              break;
           }

          status = _NFFinsert_set_members_in_list (entity, &rows, &member_list);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug ((fname,
                    "_NFFinsert_set_members_in_list = <0x%.8x>\n", status));
              FIg_set_state_off (*form, FI_ACCEPT);
              if (member_list)
                  free (member_list); 
              return (status);
            }
           _NFIdebug ((fname, " num_members to add = <%d>\n", rows));

          for (i = 0; i < rows; ++i)
           {
              _NFIdebug ((fname, " member [%d]\n", i));
              _NFIdebug ((fname, "member.operation = <%d>\n",
                          member_list[i].operation));
              _NFIdebug ((fname, "member.citno = <%d>\n",
                          member_list[i].citno));
              _NFIdebug ((fname, "member.catalog_name = <%s>\n",
                          member_list[i].catalog_name));
              _NFIdebug ((fname, "member.catalog_no = <%d>\n",
                          member_list[i].catalog_no));
              _NFIdebug ((fname, "member.item_name = <%s>\n",
                          member_list[i].item_name));
              _NFIdebug ((fname, "member.item_rev = <%s>\n",
                          member_list[i].item_rev));
              _NFIdebug ((fname, "member.item_no = <%d>\n",
                          member_list[i].item_no));
              _NFIdebug ((fname, "member.type = <%s>\n",
                          member_list[i].type));
           }

          /*  Put up a message  */

          NFFform_message (CURRENT_LABEL, working_message, NULL);

          /*  Call NFMR to add the members to the set */

          status = NFMRdefine_set_information  (NFFglobal.catalog, (long) 0,
                      NFFglobal.item, NFFglobal.revision, NFM_FILE_STATUS_CHECK,
                      (long) rows, member_list);
          _NFIdebug ((fname,"NFMRdefine_set_information = <0x%.8x>\n", status));

          free (member_list); 

          /*  Erase the message  */

          NFFerase_message ();

          /*  Save the return status  */

          NFFglobal.status = status;

          if (status == NFM_S_SUCCESS)
           {
              ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
              _NFFalter_item_text_label (text);
              strcpy (NFFglobal.set_indicator, "Y");
           }

          /*  Set the next state  */

          if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));


          /*  Close all allocated buffers and delete the form  */

          _NFFfree_setm (form, entity);

       break;

       case DELETE_BUTTON:

          status = _NFFremove_set_members_mcf (SET_MEMBERS_MCF, *form, entity);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFremove_set_members_mcf = <0x%.8x>\n",
                             status));

       break;

       case ADD_BUTTON:

          status = _NFFadd_set_members_mcf (g_label, *form, entity, command);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFadd_set_members_mcf = <0x%.8x>\n", status));

       break;

       case HIDDEN_SCF:

          status = _NFFprocess_select_scf (g_label, *form, entity);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFprocess_select_scf = <0x%.8x>\n", status));

       break;

       case CATALOG_FIELD:
       case ITEM_FIELD:
       case REVISION_FIELD:

          status = _NFFprocess_field_entry (g_label, *form, entity);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFprocess_field_entry = <0x%.8x>\n", status));

       break;

       case TYPE_TOGGLE:

          status = _NFFprocess_type (g_label, *form, entity);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFprocess_type = <0x%.8x>\n", status));

       break;

       case CATALOG_BUTTON:
       case ITEM_BUTTON:
       case REVISION_BUTTON:

          status = _NFFget_scf_data_list (g_label, *form, entity);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFget_scf_data_list = <0x%.8x>\n", status));

          FIg_set_state (*form, g_label, FALSE);

       break;
        }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFdefine_project_members_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    long    status = NFI_S_SUCCESS;
    int     working_message;
    char    command[15];

    static  char *fname = "_NFFdefine_project_members_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFset_ptr    entity;

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    strcpy (command, NFI_M_ADD_ITEMS_TO_PROJECT);

    /*  Pull out the pointer to all of the buffers  */

    status = (long) FIf_get_user_pointer (*form, (char *) &entity);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
     }

    working_message = NFI_I_ADD_PROJECT_MEMBERS;

    /* Clear out the message strip */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (g_label)
     {
       case FI_HELP:

          strcpy (command, NFI_M_ADD_ITEMS_TO_PROJECT);

          if (status = _NFFhelp_topic (command))
           {
              _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic",
                                  status);
              status = NFI_E_HELP;
           }

       break;

       case FI_CANCEL:

          /*  Load the global error structure  */

          ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

          /*  Set the next state  */

          if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

          /*  Close all allocated buffers and delete the form  */

          _NFFfree_setm (form, entity);

       break;

       case FI_ACCEPT:

          if (entity->data_list->rows >= entity->rows)
           {
              /* The user has not added any members.  Send message to the
                 user to cancel this form to exit.     */

              NFFform_message (CURRENT_LABEL, NFI_I_NO_MEMBERS_ADDED, NULL);

              FIg_set_state_off (*form, FI_ACCEPT);
              break;
               }  

              status = _NFFinsert_project_members_in_list (entity);
              if (status != NFI_S_SUCCESS)
               {
                  _NFIdebug ((fname,
                        "_NFFinsert_set_members_in_list = <0x%.8x>\n", status));
              FIg_set_state_off (*form, FI_ACCEPT);
                  return (status);
               }

          if (_NFMdebug_st.NFIdebug_on)
           {
              MEMprint_buffer ("attr_list", entity->attr_list,
                           _NFMdebug_st.NFIdebug_file);
              MEMprint_buffer ("data_list", entity->data_list,
                           _NFMdebug_st.NFIdebug_file);
           }

          /*  Put up a message  */

          NFFform_message (CURRENT_LABEL, working_message, NULL);

          /*  Call NFMR to add the members to the set */

          status = NFMRupdate_project_members
             ((long) 0, entity->attr_list, entity->data_list);

          _NFIdebug ((fname,"NFMRupdate_project_members = <0x%.8x>\n",
                          status));

          /*  Erase the message  */

          NFFerase_message ();

          /*  Save the return status  */

          NFFglobal.status = status;

          if (status == NFM_S_SUCCESS)
             ERRload_struct (NFM, NFM_S_SUCCESS, NULL);

          /*  Set the next state  */

          if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));


          /*  Close all allocated buffers and delete the form  */

          _NFFfree_setm (form, entity);

       break;

       case DELETE_BUTTON:

          status = _NFFremove_set_members_mcf (SET_MEMBERS_MCF, *form, entity);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFremove_set_members_mcf = <0x%.8x>\n",
                             status));

       break;

       case ADD_BUTTON:

          status = _NFFadd_set_members_mcf (g_label, *form, entity, command);
          if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFadd_set_members_mcf = <0x%.8x>\n",
                             status));

       break;

       case HIDDEN_SCF:

           status = _NFFprocess_select_scf (g_label, *form, entity);
           if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFprocess_select_scf = <0x%.8x>\n", status));

       break;

       case CATALOG_FIELD:
       case ITEM_FIELD:
       case REVISION_FIELD:

           status = _NFFprocess_field_entry (g_label, *form, entity);
           if (status != NFI_S_SUCCESS)
              _NFIdebug ((fname, "NFFprocess_field_entry = <0x%.8x>\n",
                             status));

       break;

       case TYPE_TOGGLE:

           status = _NFFprocess_type (g_label, *form, entity);
           if (status != NFI_S_SUCCESS)
             _NFIdebug ((fname, "NFFprocess_type = <0x%.8x>\n", status));

       break;

       case CATALOG_BUTTON:
       case ITEM_BUTTON:
       case REVISION_BUTTON:

           status = _NFFget_scf_data_list (g_label, *form, entity);
           if (status != NFI_S_SUCCESS)
              _NFIdebug ((fname, "NFFget_scf_data_list = <0x%.8x>\n", status));

            FIg_set_state (*form, g_label, FALSE);

       break;
     }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFadjust_members_form (form)
  Form form;
{
    long    status;

    static  char *fname = "_NFFadjust_members_form";

    if ((status = _NFFcenter_gadget (form, TITLE1)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_gadget (form, ERROR_BEZEL)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_form (form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
}

