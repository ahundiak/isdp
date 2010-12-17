
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFsort.h"
#include "NFFmain_form.h"

/*
   addition [KMM on 10.12.93]:

   NFMporttypes.h defines macros for OS specific typedefs.
*/

#include "NFMporttypes.h"

/* addition ends. */

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

/* User can only add a new criteria to delete one an add and delete must be
   done.  If a user chooses to overwrite an existing criteria he/she need
   only to specify the criteria name and the new attributes in the form. 
   RPS will see that the format file already exist and treat it as a
   modify command instead of an add command.                               */

long NFFdefine_sort_criteria (catalog_name)
  char *catalog_name;
  {
    auto    int     label = REPORT_NAME_FIELD;
    auto    int     x, max_chars = 30;
    auto    long    status;
    auto    char    s[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdefine_sort_criteria";

    NFFsort_ptr entity; 

    _NFIdebug ((fname, "Catalog Name = <%s>\n", catalog_name));

    if (strcmp (catalog_name, "") == 0)
      {
        status = NFI_E_NO_CATALOG;
        _NFIdebug ((fname, "Null catalog name = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, "", NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      } 

    /*  Initialize the sort structure  */

    if ((entity = (NFFsort_ptr) malloc  
        (sizeof (struct NFFsort_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed: size = <%d>\n", sizeof (struct NFFsort_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFsort_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    strcpy (entity->sort_name, "");
    entity->order_list  = NULL;
    entity->num_rows    = 0;   /* number of rows in MCF */
    entity->name_offset = -1;
    entity->syn_offset  = -1;
    entity->attr_list   = NULL;

    NFFglobal.working_no = NFI_I_DEFINE_SORT;

    /*  Put up a message  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Call NFMRquery_table_definition to get the list of attributes  */

    if ((status = NFMRquery_table_definition ((long) 0,
        "catalog", catalog_name, &(entity->attr_list))) != NFM_S_SUCCESS)
      {
         _NFIdebug ((fname,
             "NFMRquery_table_definition = <0x%.8x>\n", status));
         NFFerase_message ();
         _NFFfree_sortptr (entity, NULL);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

    if ((status = MEMbuild_array (entity->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_sortptr (entity, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (entity->attr_list->rows == 0)
      {
        status = NFI_I_NO_DATA;
        _NFIdebug ((fname, "No attributes found = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_sortptr (entity, NULL);
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
      
    /*  Malloc memory for the integer array order_list  */

    if ((entity->order_list = (int *) malloc  
        ((entity->attr_list->rows) * sizeof (int))) == NULL)
      {
        _NFIdebug ((fname, "malloc failed: size = <%d>\n",
            (entity->attr_list->rows) * sizeof (int)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d",
            (entity->attr_list->rows) * sizeof (int));
        _NFIdebug ((fname, " returning FAILURE\n"));
        NFFerase_message ();
        _NFFfree_sortptr (entity, NULL);
        return (NFI_E_MALLOC);
      }

    /* set all the elements in the order_list to -1 */

    for (x = 0; x < entity->attr_list->rows; ++x)
        entity->order_list[x] = -1;

    /*  Load in the form  */

    if ((status = (long) FIf_new
        (DEFINE_SORT_LABEL, SORT_CRITERIA_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        NFFerase_message ();
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFFfree_sortptr (entity, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        NFFerase_message ();
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning %d\n", status));
        _NFFfree_sortptr (entity, &NFFglobal.current_form);
        return (status);
      }

    /*  Put the attributes into the SORT_MCF_FIELD  */

    if ((status = _NFFload_attributes_mcf
        (NFFglobal.current_form, SORT_MCF_FIELD, entity)) != NFI_S_SUCCESS)
      {
        NFFerase_message ();
        _NFIdebug ((fname, "_NFFload_attributes_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning %d\n", status));
        _NFFfree_sortptr (entity, &NFFglobal.current_form);
        return (status);
      }

    /*  Set the title of the form  */

    if ((status = (long) UMSGetByNum
        (s, NFI_P_DEFINE_SORT, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Define a Sort Criteria");
      }

    FIg_set_text (NFFglobal.current_form, TITLE1, s);

    /*  Set the REPORT_NAME_FIELD to allow maximum keyin of 30 chars  */

    FIfld_set_max_num_chars
        (NFFglobal.current_form, REPORT_NAME_FIELD, 0, max_chars);

    /*  Store a pointer to the data in the form  */

    FIf_set_user_pointer (NFFglobal.current_form, (char *) entity);

    /*  Erase the OWNER_TOGGLE if user is not an administrator  */

    if (NFMRglobal.administrator == FALSE)
      {
        FIg_erase (NFFglobal.current_form, OWNER_TITLE);
        FIg_erase (NFFglobal.current_form, OWNER_TOGGLE);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /*  Display the form  */

    FIf_display (NFFglobal.current_form);

    /*  Put the cursor in the REPORT_NAME_FIELD  */

    FIfld_pos_cursor (NFFglobal.current_form, label, 0, 0, 0, 0, NULL, 0);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdefine_sort_criteria_notify (g_label, value, form)
  int       g_label;
  double    value;
  Form      *form;
  {
    auto    int     state, sel, rpos;
    auto    long    status = NFI_S_SUCCESS;
    auto    long    cmd_status = NFM_S_SUCCESS;
    auto    char    username[NFM_USERNAME + 1];
    auto    char    description[NFM_REPORTDESC + 1];
    auto    struct  NFMquery_info query_info;
    auto    NFFsort_ptr entity;
    static  char    *command = NFI_M_DEFINE_SORT_CRITERIA;
    static  char    *fname = "_NFFdefine_sort_criteria_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));
    _NFIdebug ((fname, "value = <%f>\n", value));

    /*  Pull out the pointer to the NFFsort_ptr structure  */

    FIf_get_user_pointer (*form, &entity);

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
/* PS - added Help not available message here */
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

            /*  Free the sort_ptr structure and delete the form  */
                        
            _NFFfree_sortptr (entity, form);

            break;

        case FI_ACCEPT:
        case FI_EXECUTE:

            if ((status = _NFFprocess_sort_input
                (*form, entity, &query_info)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFprocess_sort_input = <0x%.8x>\n", status));
                FIg_set_state_off (*form, g_label);
                break;
              }

            /*  Get the owner  */

            FIg_get_state (*form, OWNER_TOGGLE, &state);
            if (state == 0)
                strcpy (username, NFFglobal.username);
            else
                strcpy (username, "PUBLIC");

            /*  Get the description off the form  */

            FIfld_get_text (*form, DESCRIPTION_FIELD,
                0, 0, sizeof (description), description, &sel, &rpos);

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to load the criteria  */

            _NFIdebug ((fname, "calling NFMRdefine_query ...\n"));
            cmd_status = NFMRdefine_query
                (entity->sort_name, description,
                (short) NFM_ORDER_BY_CLAUSE, "NFM", username, query_info);
            _NFIdebug ((fname, "NFMRdefine_query = <0x%.8x>\n", cmd_status));

            NFMfree_query_struct (&query_info);

            /*  Erase the message  */

            NFFerase_message ();

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if (cmd_status == NFM_S_SUCCESS)
              {
                /*  Set the criteria name in the main form  */

                strcpy (NFFglobal.sort, entity->sort_name);
                FIg_set_text
                    (NFFglobal.forms[MAIN_LABEL], SORT_FIELD, NFFglobal.sort);
              }

            if ((g_label != FI_EXECUTE) && (cmd_status == NFM_S_SUCCESS))
              {
                /*  Free the sort_ptr structure and delete the form  */
                        
                _NFFfree_sortptr (entity, form);
              }

            if (*form != NULL)
              {
                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);
              }

            break;

        case REPORT_NAME_FIELD:
            status = _NFFprocess_sort_name (*form, g_label, entity);
            break;

        case SORT_MCF_FIELD:
            status = _NFFprocess_sort_mcf (*form, g_label, entity);     
            break;

        default:

            /*  Ignore unrecognized g_labels  */

            _NFIdebug ((fname, "Unrecognized gadget label <%d>\n", g_label));
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFprocess_sort_mcf (form, g_label, entity)     
  Form        form;
  int         g_label;
  NFFsort_ptr entity;
 {
    long status = NFI_S_SUCCESS;
    int  sel_flag = FALSE, a_exist;
    int  x, y, i, j;
    char *fname = "_NFFprocess_sort_mcf"; 

    for (x = 0; x < entity->num_rows; ++x)
     {
       _NFIdebug ((fname, " entity->order_list[%d] = %d\n", x, 
                   entity->order_list[x]));
     }

    /* for each selection run through the MCF to see if row is selected/
       unselected and update order_list                               */

    for (x = 0; x < entity->num_rows; ++x)
     {
        status = (long) FIfld_get_select (form, g_label, x, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

         for (y = 0; y < entity->attr_list->rows; ++y)
          {
             if (sel_flag) 
              {
                 if (entity->order_list[y] == -1)
                 { 
                    /* check backwards to see if attr is already in list */

                    a_exist = FALSE;
                    j = y;
                    while (j >= 0)
                     {
                        if (entity->order_list[j] == x)
                         {
                            a_exist = TRUE;
                            break;
                         }  
                        -- j;
                     }

                    if (!a_exist)
                     {
                        entity->order_list[y] = x; 
                        _NFIdebug ((fname, " entity->order_list[%d] = %d\n",
                                    y, entity->order_list[y]));
                        break;
                     }
                 }
              }
             else 
              {
                if (entity->order_list[y] == -1)
                    break;

                if (entity->order_list[y] == x)
                 {
                    _NFIdebug ((fname, " ENTITY->order_list[%d] = %d\n",
                                    y, entity->order_list[y]));

                    /* move all existing elements != -1 up by 1 and set last
                       entry to -1                                          */
                   
                    i = y;
                    while (i < entity->num_rows -1) 
                     {
                        if (entity->order_list[i + 1] == -1)
                           break; 
                        entity->order_list[i] = entity->order_list[i + 1];
                        ++i; 
                     }
                    entity->order_list[i] = -1;
                    break;
                 }  
              }
          } 
     }

    _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
 }

long _NFFprocess_sort_input (form, entity, query_info)
  Form        form;
  NFFsort_ptr entity;
  struct      NFMquery_info *query_info;  /* O : contains the sort string */
  {
    long status = NFI_S_SUCCESS;
    int  length = 0, s_length = 0;
    int  x, y, count;
    int  sel_flag, r_pos;
    char *fname = "_NFFprocess_sort_input"; 
    char **data;
    char *str = NULL;
    char s[1024];  /* there should never be a synonym longer than this */

    _NFIdebug ((fname, " Sort Name = <%s>\n", entity->sort_name));

    /* check to see if the sort name is given */

    if (strcmp (entity->sort_name, "") == 0)
     {
        /* The sort name has not been given, send a warning message to user */ 

        status = NFI_W_MORE_DATA;
        ERRload_struct (NFI, status, "%s", "Criteria Name");
        _NFIdebug ((fname, " User needs to give a value for Sort Name\n"));
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (status);
     } 

    if (entity->order_list[0] == -1)
     {
        /* No attributes have been selected, send a warning message to user */ 

        status = NFI_W_SELECT_SORT;
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname,
            "User needs to at least one attribute for Sort Criteria\n"));
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (status);
     } 

    data = (char **) entity->attr_list->data_ptr;

    /*  determine the length of the sort string and put attribute(s) in it */

    for (x = 0; x < entity->num_rows; ++x)
     {
        _NFIdebug ((fname, " Order_list[%d] = <%d>\n", x,
                    entity->order_list[x]));
        if (entity->order_list[x] == -1)
           break;

        /* get the length of the synonym from the attribute column of the MCF */

        status = (long) FIfld_get_text_length (form, SORT_MCF_FIELD,
                                            entity->order_list[x], 0, &length);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     
        /* get the synonym /n_name from the attribute column of the MCF */
     
        status = (long) FIfld_get_text (form, SORT_MCF_FIELD,
                                        entity->order_list[x],
                                        0, length, s, &sel_flag, &r_pos);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        
        /* find the attributes n_name in the attr_list and get its length */

        for (y = 0; y < entity->attr_list->rows; ++y)
         {
            count = entity->attr_list->columns * y;
            if ((strcmp (s, data[count + entity->syn_offset]) == 0) ||
                (strcmp (s, data[count + entity->name_offset]) == 0))
             {
                if (!s_length)
                 {
                    s_length = strlen (data[count + entity->name_offset]) + 2;
                    str = (char *) malloc (s_length * sizeof (char));
                    if (!str)
                     {
                        _NFIdebug ((fname,
                             "malloc failed: size = <%d>\n", s_length));
                        ERRload_struct (NFI, NFI_E_MALLOC, "%d", s_length);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_MALLOC);
                     } 
                    strcpy (str, data[count + entity->name_offset]);
                 }
                else
                 {
                    s_length = strlen (data[count + entity->name_offset]) + 
                               s_length + 4;
		    /*
		    modification [KMM on 10.12.93]:

		    original:

                    str = (char *) realloc (str, s_length * sizeof (char));

		    */

                    str = (char *) realloc (str,
				   (NFM_SIZE_T)(s_length * sizeof (char)));

		    /* modification ends. */

                    if (!str)
                     {
                        _NFIdebug ((fname,
                             "realloc failed: size = <%d>\n", s_length));
                        ERRload_struct (NFI, NFI_E_MALLOC, "%d", s_length);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_MALLOC);
                     } 
                    sprintf (str, "%s, %s", str,
                             data[count + entity->name_offset]);
                 }
                break;
             } /* if */
         }  /* for y */
     }  /* for x */ 

     _NFIdebug ((fname, " Sort String = <%s>\n", str));

    /*  Fill in the query_info structure  */

    if ((status = NFMwrite_query_struct
        (query_info, "", "", "", str, "")) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMwrite_query_struct = <0x%.8x>\n", status));
        free (str);
        NFMfree_query_struct (query_info);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    free (str);

    _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFload_attributes_mcf (form, g_label, entity) 
  Form        form;
  int         g_label;
  NFFsort_ptr entity;
 {
    long  status = NFI_S_SUCCESS;
    short read_offset = -1;
    short type_offset = -1;
    int   x, y, count;
    auto  num_rows, vis_rows, attr_mask;
    char  *fname = "_NFFload_attributes_mcf"; 
    char  **data;

    /* get the offsets for the attributes from the attr_list. */

    status = _NFFfind_column_offset (entity->attr_list, "n_name",
                                     &(entity->name_offset));
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    status = _NFFfind_column_offset (entity->attr_list, "n_synonym",
                                     &(entity->syn_offset));
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    status = _NFFfind_column_offset (entity->attr_list, "n_read",
                                     &read_offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    status = _NFFfind_column_offset (entity->attr_list, "n_datatype",
                                     &type_offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    _NFIdebug ((fname, "n_name     offset = <%d>\n", entity->name_offset));
    _NFIdebug ((fname, "n_synonym  offset = <%d>\n", entity->syn_offset));
    _NFIdebug ((fname, "n_read     offset = <%d>\n", read_offset));
    _NFIdebug ((fname, "n_datatype offset = <%d>\n", type_offset));

    /* put the data in the MCF */

    data = (char **)  entity->attr_list->data_ptr;

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, g_label, "7x13bold", 15 );
#endif
    x = 0;
    for (y = 0; y < entity->attr_list->rows; ++y)
     {
        count = entity->attr_list->columns * y;
        if ( strcmp (data[count + read_offset], "N") != 0)
         {
            /* if the synonym is not given use the n_name */

            if (strcmp (data[count + entity->syn_offset], "") != 0)
               status = (long) FIfld_set_text (form, g_label, x, 0, 
                                      data[count + entity->syn_offset], FALSE); 
            else
               status = (long) FIfld_set_text (form, g_label, x, 0, 
                                      data[count + entity->name_offset], FALSE);
            if (status != FI_SUCCESS)
             {
               _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
               ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                               status);
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_FORM);
             }

            status = (long) FIfld_set_text (form, g_label, x, 1, 
                                            data[count + type_offset], FALSE); 
            if (status != FI_SUCCESS)
             {
               _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
               ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                               status);
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_FORM);
            }
            ++x;
            ++entity->num_rows; 
         } 
     }

    /*  Enable the scroll bar, if necessary  */

    FIfld_get_num_rows (form, g_label, &num_rows);
    FIfld_get_num_vis_rows (form, g_label, &vis_rows);
    FImcf_get_attr (form, g_label, &attr_mask);
    if (num_rows > vis_rows)
      {
        /*  OR in the vertical scroll bar attribute  */

        attr_mask |= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }
    else
      {
        /*  Take out the vertical scroll bar attribute  */

        if (attr_mask & (FI_VERT_SCROLL | FI_DISPLAY_VSCROLL))
            attr_mask ^= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }

    FImcf_set_attr (form, g_label, attr_mask);

    _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
 }


long _NFFprocess_sort_name (form, g_label, entity)
  Form        form;
  int         g_label;
  NFFsort_ptr entity;
 {
    auto    int    i;
    auto    int    length = 0;
    auto    int    sel_flag = FALSE, r_pos = -1;
    auto    long   status;
    static  char   *fname = "_NFFprocess_sort_name";

    strcpy (entity->sort_name, "");

    status = (long) FIfld_get_text_length (form, g_label, 0, 0, &length);
    /*  Make sure there is no white-space in the name  */
    if (status != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct (NFI,
            NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /* get the user inputed text from the field */
    /* Added temp - SSRS 26 Apr 94 */
    if( length > 21)
        length = 21;

    status = (long) FIfld_get_text (form, g_label, 0, 0, length,
                                   entity->sort_name, &sel_flag, &r_pos);
    if (status != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    for (i = 0; i < strlen (entity->sort_name); ++i)
      {
        if (isspace (entity->sort_name[i]))
            entity->sort_name[i] = '_';
      }

    FIfld_set_text (form, g_label, 0, 0, entity->sort_name, FALSE);

    _NFIdebug ((fname, "sort_name = <%s>\n", entity->sort_name));

    _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
 }


void _NFFfree_sortptr (entity, form)
    NFFsort_ptr entity;
    Form        *form;
 {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

     if (entity)
      {
         if (entity->attr_list)
            MEMclose (&(entity->attr_list));

         if (entity->order_list)
            free ((int *) entity->order_list);

         free ((NFFsort_ptr) entity);
      }

     return;
 }
