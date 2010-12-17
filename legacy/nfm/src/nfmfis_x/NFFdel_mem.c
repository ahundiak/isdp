
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFdel_mem.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;


long NFFdelete_set_members (catalog, set_name, revision)
  char    *catalog;
  char    *set_name;
  char    *revision;
  {
    long    status;
    char    title[NFF_MAX_MESSAGE];

    static  char *fname = "NFFdelete_set_members";

    if ((status = (long) UMSGetByNum (title,
        NFI_P_DEL_SET_MEM, "%s%s", set_name, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title, "Delete Items from Set \"%s\" Revision \"%s\"",
            set_name, revision);
      }

    NFFglobal.working_no = NFI_I_DELETE_SET_MEMBERS;
    NFFglobal.status = NFI_E_DELETE_SET_MEMBERS;

    if ((status = _NFFdefine_members (catalog,
        set_name, revision, title, DELETE_SET_MEMBERS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFdefine_members = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFdelete_project_members (project)
  char    *project;
  {
    long    status;
    char    title[NFF_MAX_MESSAGE];

    static  char *fname = "NFFdelete_project_members";

    if ((status = (long) UMSGetByNum (title,
        NFI_P_DEL_PROJ_ITEMS, "%s", project)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title, "Delete Items from Project \"%s\"", project);
      }

    NFFglobal.working_no = NFI_I_DELETE_PROJECT_MEMBERS;
    NFFglobal.status = NFI_E_DELETE_PROJECT_MEMBERS;

    if ((status = _NFFdefine_members
        (project, "", "", title, DELETE_PROJECT_MEMBERS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFdefine_members = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdefine_members (entity_name, set_name, revision, title, command)
  char    *entity_name; /*  i - either catalog_name or project_name        */
  char    *set_name;    /*  i - "" if project                              */
  char    *revision;    /*  i - "" if project                              */
  char    *title;       /*  i - title of form                              */
  int     command;      /*  i - either DELETE_SET_MEMBERS, or              */
                        /*      DELETE_PROJECT_MEMBERS                     */
  {
    long    status;
    long    level;
    long    type;

    static  char *fname = "_NFFdefine_members";

    /*  Pointer to the item structure  */

    NFFfitem    entity;

    switch (command)
      {
        case DELETE_SET_MEMBERS:

            NFFglobal.NFMRfunction[0] = NFMRquery_set_members;
            NFFglobal.NFMRfunction[1] = NFMRdefine_set_information;

            /*  Put the input arguments in the global structure  */

            strncpy (NFFglobal.catalog, entity_name,
                (sizeof (NFFglobal.catalog)) - 1);
            strncpy (NFFglobal.item, set_name,
                (sizeof (NFFglobal.item)) - 1);
            strncpy (NFFglobal.revision, revision,
                (sizeof (NFFglobal.revision)) - 1);

            break;

        case DELETE_PROJECT_MEMBERS:

            NFFglobal.NFMRfunction[0] = NFMRquery_project_members;
            NFFglobal.NFMRfunction[1] = NFMRupdate_project_members;

            /*  Put the input arguments in the global structure  */

            strncpy (NFFglobal.project, entity_name,
                (sizeof (NFFglobal.project)) - 1);

            break;

        default:

            _NFIdebug ((fname, "invalid command <%d>", command));
            NFFglobal.status = NFI_E_INVALID_INPUT;
            ERRload_struct (NFI, NFI_E_INVALID_INPUT, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_INVALID_INPUT);
      }

    /*  Initialize the item structure  */

    if ((entity = (NFFfitem) malloc
        (sizeof (struct NFFfitem_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFfitem_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFfitem_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    entity->type = 0;
    entity->done = FALSE;
    entity->command = command;
    entity->columns = NULL;
    entity->item_attr = NULL;
    entity->item_data = NULL;

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

    level = 1;
    type = 0;

    switch (command)
      {
        case DELETE_SET_MEMBERS:

            if ((status = (long) NFFglobal.NFMRfunction[0]
                ((long) 0, entity_name, set_name,
                revision, level, type, &(entity->item_attr),
                &(entity->item_data))) != NFM_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "NFMR query function = <0x%.8x>\n", status));
                NFFglobal.status = status;
                NFFerase_message ();
                NFFfree_fitem (NULL, entity);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            if ((entity->item_data)->rows <= 1)  /* Meeiling returns the set */
             {
                status = NFI_I_NO_SET_MEMBERS;
                NFFglobal.status = status;
                _NFIdebug ((fname,
                     "The set has no members : status = <0x%.8x>\n", status));
                NFFerase_message ();
                ERRload_struct (NFI, status, NULL);
                NFFfree_fitem (NULL, entity);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
             }
            break;

        case DELETE_PROJECT_MEMBERS:

            if ((status = (long) NFFglobal.NFMRfunction[0]
                ((long) 0, entity_name, &(entity->item_attr),
                &(entity->item_data))) != NFM_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "NFMR query function = <0x%.8x>\n", status));
                NFFglobal.status = status;
                NFFerase_message ();
                NFFfree_fitem (NULL, entity);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            if ((entity->item_data)->rows <= 0)
             {
                status = NFI_I_NO_PROJECT_MEMBERS;
                NFFglobal.status = status;
                _NFIdebug ((fname,
                   "The project has no members : status = <0x%.8x>\n", status));
                NFFerase_message ();
                ERRload_struct (NFI, status, NULL);
                NFFfree_fitem (NULL, entity);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
             }
            break;
      }

    if ((status = MEMbuild_array (entity->item_attr)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();

        /*  Set the global command status  */

        NFFglobal.status = status;

        /*  Set the next state  */

        NFFset_to_state ();
        NFFfree_fitem (NULL, entity);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (entity->item_data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();

        /*  Set the global command status  */

        NFFglobal.status = status;

        /*  Set the next state  */

        NFFset_to_state ();
        NFFfree_fitem (NULL, entity);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("item_attr", entity->item_attr, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("item_data", entity->item_data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the form  */

    if ((status = (long) FIf_new (DELETE_MEMBERS_LABEL, DELETE_MEMBERS_FORM,
                         _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();

        /*  Set the global command status  */

        NFFglobal.status = NFI_E_FORM;

        /*  Set the next state  */

        NFFset_to_state ();
        NFFfree_fitem (NULL, entity);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the MCF and Load the data in the attributes field  */

    if ((status = _NFFfcreate_list_mcfs (NFFglobal.current_form, MEM_TOP_MCF,
                        MEM_BOTTOM_MCF, FI_MULTI_SELECT, "n_read",
                        entity->item_attr, entity->item_data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfcreate_list_mcfs = %d\n", status));
        NFFerase_message ();

        /*  Set the global command status  */

        NFFglobal.status = status;

        /*  Set the next state  */

        NFFset_to_state ();
        NFFfree_fitem (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

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
        NFFfree_fitem (&NFFglobal.current_form, entity);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /*  Clear out the error message strip  */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));

        /*  Set the global command status  */

        NFFglobal.status = status;

        /*  Set the next state  */

        NFFset_to_state ();
        NFFfree_fitem (&NFFglobal.current_form, entity);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    FIg_set_text (NFFglobal.current_form, TITLE, title);

    /* If this command is DELETE_SET_MEMBERS th parent is returned and should
       be removed from the MCF.                                              */

    if (entity->command == DELETE_SET_MEMBERS)
     {
        FIfld_delete_rows (NFFglobal.current_form, MEM_BOTTOM_MCF, 0, 1);
        if ((entity->item_data)->rows == 1)
           FIfld_set_num_rows (NFFglobal.current_form, MEM_BOTTOM_MCF, 0);
     }

    /*  Display the form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));

        /*  Set the global command status  */

        NFFglobal.status = NFI_E_FORM;

        /*  Set the next state  */

        NFFset_to_state ();
        NFFfree_fitem (&NFFglobal.current_form, entity);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdefine_members_notify (g_label, value, form)
  int       g_label;
  double    value;
  Form      *form;
  {
    long    status = NFI_S_SUCCESS;
    int     i, rows = -1;
    char    *text = "Item Name";
    char    command[15];
    struct  NFMmember_info *member_list = NULL;

    static  char *fname = "_NFFdefine_members_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFfitem    entity;

    _NFIdebug ((fname, "g_label = %d\n", g_label));
    _NFIdebug ((fname, "value = %f\n", value));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, (char *) &entity);

    /*  Clear out the error message strip  */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (g_label)
      {
        case FI_HELP:

            switch (entity->command)
              {
                case DELETE_SET_MEMBERS:
                    strcpy (command, NFI_M_DELETE_ITEMS_FROM_SET);
                    break;

                case DELETE_PROJECT_MEMBERS:
                    strcpy (command, NFI_M_DELETE_ITEMS_FROM_PROJECT);
                    break;
              }

            if (status = _NFFhelp_topic (command))
             {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
                status = NFI_E_HELP;
             }

            break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
            NFFglobal.status = NFI_W_COMMAND_CANCELLED;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            NFFfree_fitem (form, entity);

            break;

        case FI_ACCEPT:

            if (entity->command == DELETE_PROJECT_MEMBERS)
               status = _NFFdefine_members_write_keyword
                       (*form, entity->item_data, entity->command, "DROP");
            else
               status = _NFFupdate_set_members_in_list  
                       (*form, MEM_BOTTOM_MCF, entity, &rows, &member_list);

            if (status == NFI_S_SUCCESS)
                entity->done = TRUE;

            if (entity->done == FALSE)
              {
                if (member_list)
                   free (member_list);
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("item_attr", entity->item_attr,
                    _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("item_data", entity->item_data,
                    _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to add/delete the members  */

            if (entity->command == DELETE_PROJECT_MEMBERS)
                status = (long) NFFglobal.NFMRfunction[1]
                    ((long) 0, entity->item_attr, entity->item_data);
            else
             {
                _NFIdebug ((fname, " num_members to delete = <%d>\n", rows));

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

                status = NFMRdefine_set_information  (NFFglobal.catalog, 
                               (long) 0, NFFglobal.item, NFFglobal.revision,
                               NFM_FILE_STATUS_CHECK, (long) rows, member_list);

                _NFIdebug ((fname,"NFMRdefine_set_information = <0x%.8x>\n",
                            status));
                free (member_list);

                if ((status == NFM_S_SUCCESS) &&
                    (rows == ((entity->item_data)->rows - 1)))
                 {
                    /* ALL the members have been deleted.  The set should now
                       become an item.                                        */

                    ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
                    _NFFalter_item_text_label (text);
                    strcpy (NFFglobal.set_indicator, ""); 
                 }
             }

            _NFIdebug ((fname, "NFMR update function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            NFFfree_fitem (form, entity);

            break;

        case MEM_BOTTOM_MCF:

            _NFIdebug ((fname, "User selecting or unselecting members.\n"));

            /* status = _NFFmap_bottom_mcf (*form, g_label, (int) value); */

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFdefine_members_write_keyword (form, data_list, command, keyword)
  Form      form;
  MEMptr    data_list;
  int       command;
  char      *keyword;
  {
    int     i;
    int     selected;
    int     row_offset;
    long    status;
    short   offset;

    int     label = MEM_BOTTOM_MCF;

    static  char *fname = "_NFFdefine_members_write_keyword";

    _NFIdebug ((fname, "keyword = <%s>\n", keyword));

    if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = _NFFfind_column_offset
        (data_list, "n_status", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  For project commands, the mcf matches the buffer  */

    switch (command) 
      {
        case DELETE_PROJECT_MEMBERS:
            row_offset = 0;
            break;

        default:
            row_offset = 1;
            break;
      }

    /*  Scan the mcf for all selected rows  */

    for (i = 0; i < data_list->rows - row_offset; ++i)
      {
        if ((status = (long) FIfld_get_select
            (form, label, i, 0, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE) continue;

        _NFIdebug ((fname, "Writing <%s> into row %d, col %d in data_list\n",
            keyword, i + 1 + row_offset, (int) offset + 1));

        if ((status = MEMwrite_data (data_list,
            keyword, i + 1 + row_offset, (int) offset + 1)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void NFFfree_fitem (form, item)
  Form        *form;
  NFFfitem    item;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (item)
     {
        if (item->columns)
           free (item->columns);
        MEMclose (&(item->item_attr));
        MEMclose (&(item->item_data));
        free (item);
     }
    item = NULL;

    return;
  }

