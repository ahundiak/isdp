
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFset_mem.h"


/* addition [KMM on 10.12.93]:

   NFMporttypes.h defines macros for OS specific typedefs.
*/

#include "NFMporttypes.h"

/* addition ends. */

/*****************************************************************************
 *                                                                           *
 *  Tools/Functions used by commands - "Define Project Members"              *
 *                                   - "Define Set Members"                  * 
 *                                                                           *
 *****************************************************************************/

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFload_members_mcf (form, entity, command)
    Form        form;
    NFFset_ptr  entity; 
    char        *command;
 {
    long  status = NFI_S_SUCCESS;
    int   y, count;
    char  **data;

    static char *fname = "_NFFload_members_mcf";

    /* set the MCF to 0 rows */

    status = (long) FIfld_set_num_rows (form, SET_MEMBERS_MCF, 0);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* get the offsets for the attributes from the attr_list. */

    status = _NFFfind_column_offset (entity->data_list, "n_catalogname", 
                                     &(entity->cat_offset)); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n", 
                    status));
        return (status);

     }

    status = _NFFfind_column_offset (entity->data_list, "n_itemname", 
                                     &(entity->item_offset)); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    status = _NFFfind_column_offset (entity->data_list, "n_itemrev",
                                     &(entity->rev_offset)); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    status = _NFFfind_column_offset (entity->data_list, "n_type",
                                     &(entity->type_offset)); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    status = _NFFfind_column_offset (entity->data_list, "n_status",
                                     &(entity->status_offset)); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* the following two columns are only used by NFI_M_ADD_ITEMS_TO_SET */

    if (strcmp (command, NFI_M_ADD_ITEMS_TO_SET) == 0)
     {
        status = _NFFfind_column_offset (entity->data_list, "n_level",
                                         &(entity->level_offset)); 
        if (status != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                        status));
            return (status);
         }

        status = _NFFfind_column_offset (entity->data_list, "n_setindicator",
                                         &(entity->set_offset)); 
        if (status != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                        status));
            return (status);
         }
    }
   else   /* project_offset used only by NFI_M_ADD_ITEMS_TO_PROJECT */ 
    {
        status = _NFFfind_column_offset (entity->data_list, "n_projectname",
                                         &(entity->project_offset)); 
        if (status != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_NFFfind_column_offset : status = <0x%.8x>\n",
                        status));
            return (status);
         }
    }

    _NFIdebug ((fname, "level_offset   = <%d>\n", entity->level_offset)); 
    _NFIdebug ((fname, "cat_offset     = <%d>\n", entity->cat_offset)); 
    _NFIdebug ((fname, "item_offset    = <%d>\n", entity->item_offset)); 
    _NFIdebug ((fname, "rev_offset     = <%d>\n", entity->rev_offset)); 
    _NFIdebug ((fname, "type_offset    = <%d>\n", entity->type_offset)); 
    _NFIdebug ((fname, "status_offset  = <%d>\n", entity->status_offset)); 
    _NFIdebug ((fname, "set_offset     = <%d>\n", entity->set_offset)); 
    _NFIdebug ((fname, "project_offset = <%d>\n", entity->project_offset)); 

    data = (char **) entity->data_list->data_ptr;

    /* put the data from the data_list into the member_list */

    for (y = 0; y < entity->rows; ++y)
     {
        count = entity->data_list->columns * y;
        strcpy (entity->member_list[y].catalog,
                                           data[count + entity->cat_offset]);
        strcpy (entity->member_list[y].item,
                                           data[count + entity->item_offset]);
        strcpy (entity->member_list[y].revision,
                                           data[count + entity->rev_offset]);
        strcpy (entity->member_list[y].type,
                                           data[count + entity->type_offset]);
        strcpy (entity->member_list[y].status, "");
     }

    /* put the data into the multicolumn field */ 
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, SET_MEMBERS_MCF, "7x13bold", 15 );
#endif

    for (y = 0; y < entity->rows; ++y)
     {
        count = entity->columns * y;
       
        /* Load in the catalog name */
        
        status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, y,
                    CATALOG_COLUMN, entity->member_list[y].catalog, FALSE);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        /* Load in the item name */
        
        status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, y,
                    ITEM_COLUMN, entity->member_list[y].item, FALSE);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        /* Load in the revision */
        
        status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, y,
                    REVISION_COLUMN, entity->member_list[y].revision, FALSE);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        /* Load in the type */
        
        status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, y,
                    TYPE_COLUMN, entity->member_list[y].type, FALSE);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }

    _NFIdebug ((fname, "returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
 }

 void _NFFfree_setm (form, entity)
    Form       *form;
    NFFset_ptr entity;
 {
    if (form != NULL)
     {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
     }

     if (entity)
      {
         if (entity->member_list)
           free ((NFFmem_struct) entity->member_list);
         if (entity->attr_list)
            MEMclose (&(entity->attr_list));
         if (entity->data_list)
            MEMclose (&(entity->data_list));
         if (entity->cat_data)
            MEMclose (&(entity->cat_data));
         if (entity->item_data)
            MEMclose (&(entity->item_data));

         free ((NFFset_ptr) entity);
         entity = NULL;
      }

     return;
 }  


 long _NFFadd_set_members_mcf (g_label, form, entity, command)
   int         g_label;
   Form        form;
   NFFset_ptr  entity;
   char        *command;
 {
   long    status;
   int     x, state = -1;
   short   duplicate = FALSE;
   char    catalog_name[256];
   char    item_name[256];
   char    rev_name[256];
   static  char *fname = "_NFFadd_set_members_mcf"; 

   _NFIdebug ((fname, "g_label = <%d>\n", g_label));
   _NFIdebug ((fname, "command = <%s>\n", command));

   strcpy (catalog_name, "");
   strcpy (item_name, "");
   strcpy (rev_name, "");

   status = _NFFget_field_text (CATALOG_FIELD, form, catalog_name);
   if (status != NFI_S_SUCCESS)
    {
       _NFIdebug ((fname, "NFFget_field_text = <0x%.8x>\n", status));
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (status);
    }

   if (strcmp (catalog_name, "") == 0)
    {
       /* Put up a message to the user to select a catalog */ 

        NFFform_message (CURRENT_LABEL, NFI_I_CHOOSE_CATALOG, NULL);

       _NFIdebug ((fname, "Catalog Name is NULL\n"));
       _NFIdebug ((fname, " returning SUCCESS\n"));
       return (NFI_S_SUCCESS);
    }

   status = _NFFget_field_text (ITEM_FIELD, form, item_name);
   if (status != NFI_S_SUCCESS)
    {
       _NFIdebug ((fname, "NFFget_field_text = <0x%.8x>\n", status));
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (status);
    }

   if (strcmp (item_name, "") == 0)
    {
       /* Put up a message to the user to select a catalog */ 

        NFFform_message (CURRENT_LABEL, NFI_I_CHOOSE_ITEM, NULL);

       _NFIdebug ((fname, "Item Name is NULL\n"));
       _NFIdebug ((fname, " returning SUCCESS\n"));
       return (NFI_S_SUCCESS);
    }

   status = _NFFget_field_text (REVISION_FIELD, form, rev_name);
   if (status != NFI_S_SUCCESS)
    {
       _NFIdebug ((fname, "NFFget_field_text = <0x%.8x>\n", status));
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (status);
    }

   if (strcmp (rev_name, "") == 0)
    {
       /* Put up a message to the user to select a revision */ 

        NFFform_message (CURRENT_LABEL, NFI_I_CHOOSE_REVISION, NULL);

       _NFIdebug ((fname, "Revision Name is NULL\n"));
       _NFIdebug ((fname, " returning SUCCESS\n"));
       return (NFI_S_SUCCESS);
    }

   /* Verify that the row does not already exist in the member_list  */

   for (x = 0; x < entity->rows; ++x)
    {
        if ((strcmp (catalog_name, entity->member_list[x].catalog) == 0) && 
            (strcmp (item_name, entity->member_list[x].item) == 0) && 
            (strcmp (rev_name, entity->member_list[x].revision) == 0)) 
         { 
            duplicate = TRUE;
            break;
         }
    }

   if (duplicate)
    {
       /* Put up a message to the user that the value is a duplicate */ 

        if (strcmp (command, NFI_M_ADD_ITEMS_TO_SET) == 0)
           NFFform_message (CURRENT_LABEL, NFI_W_SET_MEMBER_EXISTS, NULL);
        else
           NFFform_message (CURRENT_LABEL, NFI_W_PROJECT_MEMBER_EXISTS, NULL);

       _NFIdebug ((fname, "The set member already exist in the list.\n"));
       _NFIdebug ((fname, " returning SUCCESS\n"));
       return (NFI_S_SUCCESS);
    }

   /* get the type from the type toggle. */

   status = (long) FIg_get_state (form, TYPE_TOGGLE, &state);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   /*  add a new row for the entry in the member_list */

   if (entity->member_list)
    {
       /* modification [KMM on 10.12.93]: */

       entity->member_list =
          (NFFmem_struct) realloc (entity->member_list,
          (NFM_SIZE_T) ((entity->rows + 1) * sizeof (struct NFFmember_struct))); 

       if (entity->member_list == NULL)
        {
           _NFIdebug ((fname,
                "realloc failed: size = <%d>\n", 
                            (entity->rows + 1) * (sizeof (struct NFFset_mem))));
           ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                            (entity->rows + 1) * (sizeof (struct NFFset_mem)));
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_MALLOC);
       } 
    }
   else
    {
       entity->member_list = (NFFmem_struct) malloc
                                           (sizeof (struct NFFmember_struct)); 
       if (entity->member_list == NULL)
        {
           _NFIdebug ((fname,
                "malloc failed: size = <%d>\n", sizeof (struct NFFset_mem)));
           ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                                (sizeof (struct NFFset_mem)));
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_MALLOC);
       } 
    }

   ++entity->rows;

   /* put the data in the last row of the member list. */

   strcpy (entity->member_list[entity->rows -1].catalog, catalog_name);
   strcpy (entity->member_list[entity->rows -1].item, item_name);
   strcpy (entity->member_list[entity->rows -1].revision, rev_name);
   if (state) 
      strcpy (entity->member_list[entity->rows -1].type, entity->on_text);
   else
      strcpy (entity->member_list[entity->rows -1].type, entity->off_text);
   strcpy (entity->member_list[entity->rows -1].status, "ADD");

   /* put the values in the MCF */ 
       
   /* Load in the catalog name */
        
#ifdef OS_SCO_UNIX
   /* work around change - to set font for SCO - SSRS 4 Feb 94 */
   FIg_set_font( form, SET_MEMBERS_MCF, "7x13bold", 15 );
#endif
   status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, entity->rows -1,
                   CATALOG_COLUMN, entity->member_list[entity->rows -1].catalog,
                   FALSE);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   /* Load in the item name */
        
#ifdef OS_SCO_UNIX
   /* work around change - to set font for SCO - SSRS 4 Feb 94 */
   FIg_set_font( form, SET_MEMBERS_MCF, "7x13bold", 15 );
#endif
   status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, entity->rows -1,
               ITEM_COLUMN, entity->member_list[entity->rows -1].item, FALSE);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   /* Load in the revision */
   
#ifdef OS_SCO_UNIX
   /* work around change - to set font for SCO - SSRS 4 Feb 94 */
   FIg_set_font( form, SET_MEMBERS_MCF, "7x13bold", 15 );
#endif
   status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, entity->rows -1,
                REVISION_COLUMN, entity->member_list[entity->rows -1].revision,
                                   FALSE);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   /* Load in the type */
   
#ifdef OS_SCO_UNIX
   /* work around change - to set font for SCO - SSRS 4 Feb 94 */
   FIg_set_font( form, SET_MEMBERS_MCF, "7x13bold", 15 );
#endif
   status = (long) FIfld_set_text (form, SET_MEMBERS_MCF, entity->rows -1,
                TYPE_COLUMN, entity->member_list[entity->rows -1].type, FALSE);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   _NFIdebug ((fname, "returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
 }

long _NFFget_field_text (g_label, form, text)
  int   g_label;
  Form  form;
  char  *text;
 {
   long status;
   int  r_pos = -1, sel_flag = FALSE, length = 0;
   static  char *fname = "_NFFget_field_text"; 
   
  /* get the text length */ 

  status = (long) FIfld_get_text_length (form, g_label, 0, 0, &length); 
  if (status != FI_SUCCESS)
   {
      _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
   }

    strcpy (text, "");
    status = (long) FIfld_get_text (form, g_label, 0, 0, length, text, &sel_flag,
                             &r_pos); 
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }
    _NFIdebug ((fname, "Text = <%s>\n", text));


   _NFIdebug ((fname, "returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
 }


 long _NFFremove_set_members_mcf (g_label, form, entity)
   int         g_label;
   Form        form;
   NFFset_ptr  entity;
 {
   long    status;
   int     x, y, i, warning = FALSE, sel_flag = FALSE, rows;
   static  char *fname = "_NFFremove_set_members_mcf"; 

   /* get the members to be removed from the SET_MEMBERS_MCF field. */

   _NFIdebug ((fname, "entity->rows = <%d>\n", entity->rows));

   if (entity->rows <= 0)
    {
       status = NFI_S_SUCCESS;
       _NFIdebug ((fname, "No rows exist : status = <0x%.8x>\n", status));
       return (status);
    } 

   y = 0;

   for (x = 0; x < entity->rows; ++x) 
    {
       sel_flag = FALSE;
       status = (long) FIfld_get_select (form, g_label, y, entity->columns -1,
                                  &sel_flag); 
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }
        _NFIdebug ((fname, "x = <%d>\n", x));
        _NFIdebug ((fname, "y = <%d>\n", y));
        _NFIdebug ((fname, "FIfld_get_select : sel_flag = <%d>\n", sel_flag));
  
       if (sel_flag)  
        {
           /* delete the row from the MCF */

           if (strcmp (entity->member_list[x].status, "ADD") == 0)
            {
               /* call FIfld_delete_rows to delete the row from MCF */

               status = (long) FIfld_delete_rows (form, g_label, y, 1);
               if (status != FI_SUCCESS)
                {
                   _NFIdebug ((fname, "FIfld_delete_rows = <%d>\n", status));
                   ERRload_struct (NFI, NFI_E_FORM, "%s%d",  
                                   "FIfld_delete_rows", status);
                   _NFIdebug ((fname, " returning FAILURE\n"));
                   return (NFI_E_FORM);
                }
               _NFIdebug ((fname, "FIfld_delete_rows called : row = <%d>\n",
                           x));
               strcpy (entity->member_list[x].status, "DROP");
            }
           else
           {
              warning = TRUE;  
 
              /* unhighlight the row in the MCF */

              status = (long) FIfld_set_select (form, g_label, y, CATALOG_COLUMN,
                                         FALSE); 
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                     "FIfld_set_select", status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }

              status = (long) FIfld_set_select (form, g_label, y, ITEM_COLUMN,
                                         FALSE); 
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                     "FIfld_set_select", status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }

              status = (long) FIfld_set_select (form, g_label, y, REVISION_COLUMN,
                                         FALSE); 
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                     "FIfld_set_select", status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }

              status = (long) FIfld_set_select (form, g_label, y, TYPE_COLUMN,
                                         FALSE); 
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                     "FIfld_set_select", status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }
              ++y;
           }
        } 
       else
        {
           ++y;
        }  
    }

   rows = entity->rows;   

   /* Update the member_list. */

   y = 0;

   for (x = 0; x < entity->rows; ++x)
    {
       if (strcmp (entity->member_list[y].status, "DROP") == 0)
        {
            /* move all entries starting at this location up by 1 */
 
            for (i = y; i < entity->rows -1; ++i)
             {
                entity->member_list[i] = entity->member_list[i + 1];
             }

            --rows;
        } 
        else
         ++y;
    }
    
    if (rows > 0)
     {
        entity->member_list = (NFFmem_struct) realloc
               (entity->member_list, ((rows) * sizeof (struct NFFmember_struct))); 
        if (entity->member_list == NULL)
         {
            _NFIdebug ((fname, "realloc failed: size = <%d>\n", 
                                      (rows) * (sizeof (struct NFFset_mem))));
            ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                                      (rows) * (sizeof (struct NFFset_mem)));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MALLOC);
        } 
    }
   else if (entity->member_list)
     {
        free ((NFFmem_struct) entity->member_list);
        entity->member_list = NULL;
     }
    
   entity->rows = rows;

   if (warning)
      NFFform_message (CURRENT_LABEL, NFI_W_CANNOT_DELETE_MEMBER, NULL);
     
   _NFIdebug ((fname, "returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
 }


 long _NFFprocess_select_scf (g_label, form, entity)
   int         g_label;
   Form        form;
   NFFset_ptr  entity;
 {
   long    status, rstatus;
   int     x, offset = -1, num_rows = 0, sel_flag = FALSE;
   int     count, length = 0, r_vis = 0;
   char    text[256];
   char    **data;
   static  char *fname = "_NFFprocess_select_scf"; 

   /* get the selected value from the list */

   status = (long) FIfld_get_num_rows (form, g_label, &num_rows);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   for (x = 0; x < num_rows; ++x)
    {
       status = (long) FIfld_get_select (form, g_label, x, 0, &sel_flag); 
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }
       if (sel_flag)
       {
          offset = x;
          break;
       }
    }

    if (offset == -1)
     {
        _NFIdebug ((fname, "No rows are selected.\n"));
        _NFIdebug ((fname, "returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    sel_flag = FALSE;
    status = (long) FIfld_get_text_length (form, g_label, offset, 0, &length); 
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    strcpy (text, "");
    status = (long) FIfld_get_text (form, g_label, offset, 0, length, text,
                             &sel_flag, &r_vis); 
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }
    _NFIdebug ((fname, "Text = <%s>\n", text));

   if (entity->cat_displayed == TRUE)
    {
       data = (char **) entity->cat_data->data_ptr;

       if (strcmp (entity->curr_cat, text) != 0) /* get list of items */ 
        {
           /* send retrieving data from server message to screen */

          NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

          /* call _NFFget_list_of_items to get the items from the server. */

          rstatus = _NFFget_list_of_items (form, HIDDEN_SCF, FALSE, entity,
                                           entity->project, text);

          /* clear the message strip */
 
      _NFFclear_msg (form);

          if ((rstatus != NFI_S_SUCCESS) && (rstatus != NFI_I_NO_ITEMS))
           {
              _NFIdebug ((fname, "_NFFget_list_of_items : status = <0x%.8x>\n",
                          rstatus));
              _NFIdebug ((fname, "returning Failure\n"));
          
              /* set the catalog_name field */

#ifdef OS_SCO_UNIX
              /* work around change - to set font for SCO - SSRS 4 Feb 94 */
              FIg_set_font( form, CATALOG_FIELD, "7x13bold", 15 );
#endif
              if ((status = (long) FIfld_set_text
                 (form, CATALOG_FIELD, 0, 0, entity->curr_cat, FALSE)) != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }
              
              /* set the item_name and  revision_name fields back */
    
#ifdef OS_SCO_UNIX
              /* work around change - to set font for SCO - SSRS 4 Feb 94 */
              FIg_set_font( form, ITEM_FIELD, "7x13bold", 15 );
#endif
              if ((status = (long) FIfld_set_text
                 (form, ITEM_FIELD, 0, 0, entity->curr_item, FALSE)) != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }
              
#ifdef OS_SCO_UNIX
              /* work around change - to set font for SCO - SSRS 4 Feb 94 */
              FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
              if ((status = (long) FIfld_set_text
               (form, REVISION_FIELD, 0, 0, entity->curr_rev, FALSE)) != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_default_text = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }
              return (rstatus);
            }

           if (rstatus == NFI_I_NO_ITEMS)
            {
               NFFform_message (CURRENT_LABEL, NFI_I_NO_ITEMS, NULL);
               _NFIdebug ((fname, "Reset Catalog = <%s>\n", entity->curr_cat));

              /* reset the HIDDEN_SCF list to the current catalog */

              entity->cat_displayed = FALSE;
              status = _NFFdisplay_catalogs (form, HIDDEN_SCF, entity);
              if (status != NFI_S_SUCCESS)
               {
                  entity->cat_displayed = TRUE;
                  _NFIdebug ((fname, "_NFFdisplay_catalogs = <0x%.8x>\n",
                              status));
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (status);
               }

              _NFIdebug ((fname, "returning Success\n"));
              return (NFI_S_SUCCESS);
           }
          strcpy (entity->curr_cat, text);
          strcpy (entity->curr_item, "");
          strcpy (entity->curr_rev, "");
          
          /* set the catalog_name field */

#ifdef OS_SCO_UNIX
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
          FIg_set_font( form, CATALOG_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text
             (form, CATALOG_FIELD, 0, 0, entity->curr_cat, FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }
          
          /* set the item_name and  revision_name fields to "" */

#ifdef OS_SCO_UNIX
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
          FIg_set_font( form, ITEM_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text
             (form, ITEM_FIELD, 0, 0, entity->curr_item, FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }
          
#ifdef OS_SCO_UNIX
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
          FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text
           (form, REVISION_FIELD, 0, 0, entity->curr_rev, FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_default_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }
        }

       /*  Position the cursor into the item_name field  */

    }
   else if (entity->item_displayed == TRUE)
    {
       data = (char **) entity->item_data->data_ptr;
       count = entity->item_data->columns * offset + entity->item_name_offset;

       if (strcmp (entity->curr_item, text) != 0)  
        {
           strcpy (entity->curr_item, text);
           strcpy (entity->curr_rev, "");

           /* reset the item field to "" */
          
#ifdef OS_SCO_UNIX
           /* work around change - to set font for SCO - SSRS 4 Feb 94 */
           FIg_set_font( form, ITEM_FIELD, "7x13bold", 15 );
#endif
           if ((status = (long) FIfld_set_text
           (form, ITEM_FIELD, 0, 0, entity->curr_item, FALSE)) != FI_SUCCESS)
            {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
            }

           /* reset the revision field to "" */
          
#ifdef OS_SCO_UNIX
           /* work around change - to set font for SCO - SSRS 4 Feb 94 */
           FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
           if ((status = (long) FIfld_set_text
           (form, REVISION_FIELD, 0, 0, entity->curr_rev, FALSE)) != FI_SUCCESS)
            {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
            }
        }

       /*  Position the cursor into the revision_name field  */
    } 
   else if (entity->rev_displayed == TRUE)
    {
       data = (char **) entity->item_data->data_ptr;
       count = entity->item_data->columns * offset + entity->rev_name_offset;

       if (strcmp (entity->curr_rev, text) != 0)  
        {
           strcpy (entity->curr_rev, text);

           /* reset the revision field */
          
#ifdef OS_SCO_UNIX
           /* work around change - to set font for SCO - SSRS 4 Feb 94 */
           FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
           if ((status = (long) FIfld_set_text
           (form, REVISION_FIELD, 0, 0, entity->curr_rev, FALSE)) != FI_SUCCESS)
            {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
            }
        }

      /* set the type toggle to the default */

      status = (long) FIg_set_state (form, TYPE_TOGGLE, FALSE);
      if (status != FI_SUCCESS)
       {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
       }

       /*  Position the cursor into the catalog_name field  */

    }

   _NFIdebug ((fname, "returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
 }


 long _NFFprocess_field_entry (g_label, form, entity)
   int         g_label;
   Form        form;
   NFFset_ptr  entity;
 {
   long    status;
   int     row = -1;
   int     length = 0, sel_flag = FALSE, r_pos = -1;
   char    text[256];
   static  char *fname = "_NFFprocess_field_entry"; 

   strcpy (text, ""); 

   status = (long) FIfld_get_text_length (form, g_label, 0, 0, &length);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
       ERRload_struct (NFI,
           NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   /* get the user inputed text from the field */

   status = (long) FIfld_get_text (form, g_label, 0, 0, length, text,
       &sel_flag, &r_pos);
   if (status != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (NFI_E_FORM);
    }

   /* validate the value the user inputed in the keyin against the list. */
   
   status = _NFFvalidate_user_data (g_label, text, entity, &row);
   if ((status != NFI_S_SUCCESS) && (status != NFI_E_VALID))
    {
       _NFIdebug ((fname, "_NFFvalidate_user_data = <0x%.8x>\n", status));
       _NFIdebug ((fname, " returning FAILURE\n"));
       return (status);
    }

   /* if the status is NFI_E_VALID send a warning message to the user and
      reset the field to entity->curr value.                              */

   if (status == NFI_E_VALID)
    {
      if (g_label == CATALOG_FIELD) 
       {
          NFFform_message (CURRENT_LABEL, NFI_W_CATALOG, "%s%s", text,
                           entity->curr_cat); 
#ifdef OS_SCO_UNIX
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
          FIg_set_font( form, CATALOG_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text (form, CATALOG_FIELD,
                            0, 0, entity->curr_cat, FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }
       }
      else if (g_label == ITEM_FIELD) 
       {
          NFFform_message (CURRENT_LABEL, NFI_W_ITEM, "%s%s", text,
                           entity->curr_item); 
#ifdef OS_SCO_UNIX
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
          FIg_set_font( form, ITEM_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text (form, ITEM_FIELD,
                            0, 0, entity->curr_item, FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_default_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }
       }
      else  /* g_label == REVISION_FIELD */ 
       {
          NFFform_message (CURRENT_LABEL, NFI_W_REVISION, "%s%s", text,
                           entity->curr_rev); 

#ifdef OS_SCO_UNIX
           /* work around change - to set font for SCO - SSRS 4 Feb 94 */
           FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text (form, REVISION_FIELD,
                            0, 0, entity->curr_rev, FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_default_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }
       }

       /*  Position the cursor back into the selected field  */

       _NFIdebug ((fname, " returning SUCCESS\n"));
       return (NFI_S_SUCCESS);
    }
   
   /* update the entity->curr field. */

   if (g_label == CATALOG_FIELD)
    {
        if (strcmp (entity->curr_cat, text) != 0)
         {
          /* Put up a retrieve message on the form */

          NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

          /* call _NFFget_list_of_items to get the items from the server. */

          status = _NFFget_list_of_items (form, HIDDEN_SCF, FALSE, entity,
                                          entity->project, text);

          /* clear the message strip */
 
      _NFFclear_msg (form);
 
         if ((status != NFI_S_SUCCESS) && (status != NFI_I_NO_ITEMS))
          { 
                _NFIdebug ((fname, "NFFget_list_of_items = <%d>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
          }

         if (status == NFI_I_NO_ITEMS)
          {
            NFFform_message (CURRENT_LABEL, NFI_I_NO_ITEMS, NULL);
            _NFIdebug ((fname, "_NFFget_list_of_items : status = <0x%.8x>\n",
                        status));

              /* reset the HIDDEN_SCF list to the current catalog */

              entity->cat_displayed = FALSE;
              status = _NFFdisplay_catalogs (form, HIDDEN_SCF, entity);
              if (status != NFI_S_SUCCESS)
               {
                  entity->cat_displayed = TRUE;
                  _NFIdebug ((fname, "_NFFdisplay_catalogs = <0x%.8x>\n",
                              status));
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (status);
               }

            _NFIdebug ((fname, "returning Success\n"));
            return (NFI_S_SUCCESS);
         }

         strcpy (entity->curr_cat, text);
         strcpy (entity->curr_item, "");
         strcpy (entity->curr_rev, "");
          
         /* set the item_name and  revision_name fields to "" */

#ifdef OS_SCO_UNIX
         /* work around change - to set font for SCO - SSRS 4 Feb 94 */
         FIg_set_font( form, ITEM_FIELD, "7x13bold", 15 );
#endif
         if ((status = (long) FIfld_set_text
            (form, ITEM_FIELD, 0, 0, entity->curr_item, FALSE)) != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_set_default_text = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          }
         
#ifdef OS_SCO_UNIX
         /* work around change - to set font for SCO - SSRS 4 Feb 94 */
         FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
         if ((status = (long) FIfld_set_text
          (form, REVISION_FIELD, 0, 0, entity->curr_rev, FALSE)) != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_set_default_text = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          }

         /* Display the list of catalogs. */

         status = _NFFdisplay_catalogs (form, HIDDEN_SCF, entity);
         if (status != NFI_S_SUCCESS)
          {
             _NFIdebug ((fname, "_NFFdisplay_catalogs = <0x%.8x>\n", status));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }
       }

       /*  Position the cursor back into the item_name field  */

    }
   else if (g_label == ITEM_FIELD)
    {
      strcpy (entity->curr_item, text);
      strcpy (entity->curr_rev, "");
         
#ifdef OS_SCO_UNIX
      /* work around change - to set font for SCO - SSRS 4 Feb 94 */
      FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
      if ((status = (long) FIfld_set_text
       (form, REVISION_FIELD, 0, 0, entity->curr_rev, FALSE)) != FI_SUCCESS)
       {
          _NFIdebug ((fname, "FIfld_set_default_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_default_text",
                          status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
       }

      if (entity->item_displayed)        /* select the item in the SCF */
       {
#ifdef OS_SCO_UNIX
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
          FIg_set_font( form, HIDDEN_SCF, "7x13bold", 15 );
#endif
          status = (long) FIfld_set_text (form, HIDDEN_SCF, row, 0, 
                                          entity->curr_item, TRUE);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
       }
      else if (entity->rev_displayed)
       {
           /* display the revisions for the item */ 

          status = _NFFdisplay_revisions (form, HIDDEN_SCF, entity);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug((fname, "_NFFdisplay_revisions : status = <0x%.8x>\n",
                         status));
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (status); 
           }
       }

       status = (long) FIg_set_state (form, TYPE_TOGGLE, FALSE); 
       if (status != FI_SUCCESS)
         {
               _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
               ERRload_struct
                       (NFI, NFI_E_FORM, "%s%d", "FIg_set_state", status);
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_FORM);
         }

       /*  Position the cursor into the revision_name field  */

    }
   else
    {
      strcpy (entity->curr_rev, text);
      if (entity->rev_displayed)        /* select the revision in the SCF */
       {
#ifdef OS_SCO_UNIX
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
          FIg_set_font( form, HIDDEN_SCF, "7x13bold", 15 );
#endif
          status = (long) FIfld_set_text (form, HIDDEN_SCF, row, 0, 
                                          entity->curr_rev, TRUE);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
       }

       status = (long) FIg_set_state (form, TYPE_TOGGLE, FALSE); 
       if (status != FI_SUCCESS)
         {
               _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
               ERRload_struct
                       (NFI, NFI_E_FORM, "%s%d", "FIg_set_state", status);
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_FORM);
         }

       /*  Position the cursor into the catalog_name field  */

    }

   _NFIdebug ((fname, " returning Success\n"));
   return (NFI_S_SUCCESS);
 }

long _NFFvalidate_user_data (g_label, text, entity, row)
  int        g_label;
  char       *text;
  NFFset_ptr entity;
  int        *row;
{
   int   x, i, y, count;
   long  status; 
   int   found = FALSE;
   char  **data;
   char  *fname = "_NFFvalidate_user_data";

   if (g_label == CATALOG_FIELD)
   {
      if (!entity->cat_data)
       {
          status = NFI_E_BUFFER;
          _NFIdebug ((fname, "catalog list is NULL.\n"));
          return (status);
       }

      data = (char **) entity->cat_data->data_ptr;
      for (x = 0; x < entity->cat_data->rows; ++x)
       {
          count = entity->cat_data->columns * x + entity->cat_name_offset;
   
          if (strcmp (text, data[count]) == 0)
           {
              found = TRUE;
              *row = x;
              break; 
           }
       }
    }
   else if (g_label == ITEM_FIELD)
   {
      if (entity->item_data)
      {
         data = (char **) entity->item_data->data_ptr;
         for (x = 0; x < entity->item_data->rows; ++x)
          {
             count = entity->item_data->columns * x + entity->item_name_offset;
      
             if (strcmp (text, data[count]) == 0)
              {
                 found = TRUE;
                 *row = x;
                 break; 
              }
          }
       }
    }
   else if (g_label == REVISION_FIELD)
   {
      if (entity->item_data)
      {
         y = 0;
         data = (char **) entity->item_data->data_ptr;
         for (x = 0; x < entity->item_data->rows; ++x)
          {
             count = entity->item_data->columns * x + entity->rev_name_offset;
             i = entity->item_data->columns * x + entity->item_name_offset;
   
             if (strcmp (entity->curr_item, data[i]) == 0) 
              {
                 if (strcmp (text, data[count]) == 0)
                  {
                     found = TRUE;
                     *row = y;
                     break; 
                  }
                 ++y;
              }
          }
       } 
    }

   if (!found)
    {
       status = NFI_E_VALID;
       _NFIdebug ((fname, "Value <%s> not found in data_list.\n", text));
       return (status);
    } 

   _NFIdebug ((fname, " returning Success\n"));
   return (NFI_S_SUCCESS);
}


 long _NFFprocess_type (g_label, form, entity)
   int         g_label;
   Form        form;
   NFFset_ptr  entity;
 {
   long    status = NFI_S_SUCCESS;
   int     state;
   static  char*fname = "_NFFprocess_type"; 

   if (strcmp (entity->curr_rev, "") == 0)
    {  
       _NFIdebug ((fname, "The current revision is NULL"));
       return (status);
    }

   if (strcmp (entity->project, "") != 0)
    {
       /* get the state from the type toggle */

       status = (long) FIg_get_state (form, g_label, &state);
       if (status != FI_SUCCESS)
         {
               _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
               ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                               status);
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_FORM);
         }

       /* check to see if the state is valid for the current item */

       status = _NFFvalidate_item_type (entity->curr_item, entity->curr_rev,
                      state, entity->toggle_offset, entity->item_name_offset,
                      entity->rev_name_offset, entity->item_data); 
       if (status != NFI_S_SUCCESS)
        {
            NFFform_message (CURRENT_LABEL, NFI_W_ITEM_REFERENCE_ONLY, NULL);
            
            /* if it is not valid reset the toggle to the default */

            status = (long) FIg_set_state (form, g_label, FALSE); 
            if (status != FI_SUCCESS)
             {
                 _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
             }
        }
    }

   _NFIdebug ((fname, " Returning Success = <0x%.8x>\n", NFI_S_SUCCESS));
   return (NFI_S_SUCCESS);
 }


 long _NFFvalidate_item_type (char *item_name, char *revision, int state,
                              short type_offset, short item_name_offset,
                              short rev_name_offset, MEMptr data_list)
 {
   long  status;
   int   x, count;
   char  **data;
   char  *fname = "_NFFvalidate_item_type";

   _NFIdebug ((fname, " Item Name = <%s>\n", item_name));
   _NFIdebug ((fname, " Rev  Name = <%s>\n", revision));

   if (!data_list)
    {
       status = NFI_S_SUCCESS;
       _NFIdebug ((fname, " Item data list is NULL : status = <0x%.8x>\n",
                   status));
       return (status);
    }

   data = (char **) data_list->data_ptr;
   for (x = 0; x < data_list->rows; ++x)
    {
        count = data_list->columns * x;
        if ( (strcmp (item_name, data[count + item_name_offset]) == 0) &&
             (strcmp (revision,  data[count + rev_name_offset] ) == 0) ) 
         {
             if ( (state) &&
                  (strcmp (data[count + type_offset], P_OFF_TEXT) == 0) )
              {
                 status = NFI_W_ITEM_REFERENCE_ONLY;
                 _NFIdebug ((fname, " Item is reference only = <0x%.8x>\n",
                             status));
                 return (status);
              }
             break;
         }
    }

   _NFIdebug ((fname, " Returning Success = <0x%.8x>\n", NFI_S_SUCCESS));
   return (NFI_S_SUCCESS);
 }


 long _NFFget_scf_data_list (g_label, form, entity)
   int         g_label;
   Form        form;
   NFFset_ptr  entity;
 {
   long    status;
   static  char*fname = "_NFFget_scf_data_list"; 

   if (g_label == CATALOG_BUTTON)
    {
       if (entity->cat_displayed == FALSE)
       {
          status = _NFFdisplay_catalogs (form, HIDDEN_SCF, entity);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug((fname, "_NFFdisplay_catalogs : status = <0x%.8x>\n",
                         status));
              return (status); 
           }
       }
    }
    else if (g_label == ITEM_BUTTON)
    {
       if (entity->item_displayed == FALSE)
       {
          status = _NFFdisplay_items (form, HIDDEN_SCF, entity);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug((fname, "_NFFdisplay_items : status = <0x%.8x>\n",
                         status));
              return (status); 
           }
       }
    }
    else if (g_label == REVISION_BUTTON)
    {
       if (entity->rev_displayed == FALSE)
       {
          status = _NFFdisplay_revisions (form, HIDDEN_SCF, entity);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug((fname, "_NFFdisplay_revisions : status = <0x%.8x>\n",
                         status));
              return (status); 
           }
       }
    }

   return (NFI_S_SUCCESS);
 }

long _NFFget_list_of_catalogs (cat_data, offset)
  MEMptr *cat_data;
  short  *offset;

  {
        long    status;
        char    search[128];
        MEMptr  buffer = NULL;
        MEMptr  synonym = NULL;

        static  char *fname = "NFFget_list_of_catalogs";

        strcpy (search, "n_catalogname != 'nfmsyscat'");

        _NFIdebug ((fname, "calling NFMRdisplay_catalogs ...\n"));

        if ((status = NFMRdisplay_catalogs ("", "", NFM_SHORT_DISPLAY,
                             &synonym, &buffer)) != NFM_S_SUCCESS)
          {
                _NFIdebug ((fname, "NFMRdisplay_catalogs = <0x%.8x>\n",
                            status));
                MEMclose (&buffer);
                MEMclose (&synonym);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
          }

        _NFIdebug ((fname, "returned from NFMRdisplay_catalogs\n"));
        MEMclose (&synonym);

        if (_NFMdebug_st.NFIdebug_on)
                MEMprint_buffers (fname, buffer, _NFMdebug_st.NFIdebug_file);

        status = MEMsplit_copy_buffer (buffer, cat_data, 0);
        if (status != MEM_S_SUCCESS)
         {
            _NFIdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n",
                        status));
            MEMclose (&buffer);
            MEMclose (cat_data);
            *cat_data = NULL;
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMsplit_copy_buffer",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
         }

        MEMclose (&buffer);

        /* The catalog_name is hardcoded to be the second attr in the buffer */ 

        *offset = 1;  /* column numbers start at 0 */
        _NFIdebug ((fname, "Offset to n_catalogname = <%d>\n", *offset));

        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
  }

  long _NFFmem_set_text (form, g_label, title)
    Form       form;
    int        g_label;
    char       *title;
   {
      long status;
      static  char *fname = "_NFFmem_set_text";
      
      status = (long) FIg_erase (form, g_label);
      if (status != FI_SUCCESS)
       {
         _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }
      
      status = (long) FIg_erase (form, TEXT_RECTANGLE);
      if (status != FI_SUCCESS)
       {
         _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }
      
      status = (long) FIg_set_text (form, g_label, title); 
      if (status != FI_SUCCESS)
       {
         _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }
      
      status = (long) FIg_display (form, TEXT_RECTANGLE); 
      if (status != FI_SUCCESS)
       {
         _NFIdebug ((fname, "FIg_display = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

      status = (long) FIg_display (form, g_label); 
      if (status != FI_SUCCESS)
       {
         _NFIdebug ((fname, "FIg_display = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

      _NFIdebug ((fname, " returning SUCCESS\n"));
      return (NFI_S_SUCCESS);
   }


  long _NFFdisplay_catalogs (form, g_label, entity)
    Form       form;
    int        g_label;
    NFFset_ptr entity;
  {
     long   status;
     int    count, x;
     char   **data;
     char   title[NFF_MAX_MESSAGE];

     static char *fname = "_NFFdisplay_catalogs";

     _NFIdebug ((fname, "Current Catalog = <%s>\n", entity->curr_cat));
     _NFIdebug ((fname, "Offset          = <%d>\n", entity->cat_name_offset));
     _NFIdebug ((fname, "Rows            = <%d>\n", entity->cat_data->rows));

     /* set the number of rows to 0 to wipe out previous data. */

     status = (long) FIfld_set_num_rows (form, g_label, 0); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
         ERRload_struct (NFI,
             NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     /* set the select mode to single_select */

     status = (long) FIfld_set_mode (form, g_label, 0, FI_SINGLE_SELECT); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     data = (char **) entity->cat_data->data_ptr; 

     /* Put the data in the list to display it. */ 

#ifdef OS_SCO_UNIX
     /* work around change - to set font for SCO - SSRS 4 Feb 94 */
     FIg_set_font( form, g_label, "7x13bold", 15 );
#endif

     for (x = 0; x < entity->cat_data->rows; ++x)
      {
        count = entity->cat_data->columns * x + entity->cat_name_offset; 

        if (strcmp (data[count], entity->curr_cat) == 0)
	{
           status = (long) FIfld_set_text (form, g_label, x, 0, data[count],
                                           TRUE);
	}
        else 
	{
           status = (long) FIfld_set_text (form, g_label, x, 0, data[count],
                                           FALSE);
	}
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        _NFIdebug ((fname, "Catalog_name[%d] = <%s>\n", x, data[count]));
      }

     /* put the catalog name in the catalog field */

#ifdef OS_SCO_UNIX
     /* work around change - to set font for SCO - SSRS 4 Feb 94 */
     FIg_set_font( form, CATALOG_FIELD, "7x13bold", 15 );
#endif
     status = (long) FIfld_set_text (form, CATALOG_FIELD, 0, 0, 
                                     entity->curr_cat, FALSE); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     /* set the hidden scf title. */ 

     status = (long) UMSGetByNum (title, NFI_P_LIST_CATALOGS, NULL);
     if (status != UMS_S_SUCCESS)
      {
         _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
         _NFIdebug ((fname, "defaulting title\n"));
         strcpy (title, "List of I/NFM Catalogs");
      }

     if ((status = _NFFmem_set_text (form, TITLE2, title)) != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "_NFFmem_set_text = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     entity->cat_displayed = TRUE;
     entity->item_displayed = FALSE;
     entity->rev_displayed = FALSE;

     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
  } 


long _NFFget_list_of_items (form, g_label, display_values, entity,
                            project_name, catalog_name)
    Form       form;
    int        g_label;
    short      display_values;   /*TRUE = display the values; FALSE Do not */
    NFFset_ptr entity;
    char       *project_name;
    char       *catalog_name;
  {
        long    status;
        short   x;
        char    **column_ptr;
        MEMptr  buffer = NULL;
        MEMptr  synonym = NULL;

        static  char *fname = "NFFget_list_of_items";

        _NFIdebug ((fname, "g_label = <%d>\n", g_label));
        _NFIdebug ((fname, "calling NFMRdisplay_items ...\n"));

        if (strcmp (project_name, "") != 0)
         {
           /* return (NFI_S_SUCCESS); */
           status = NFMRqry_items_in_cat_for_project ((long) 0, project_name,
                                         catalog_name, &(entity->item_data)); 
           if (status != NFM_S_SUCCESS)
             {
                _NFIdebug ((fname,
                  "NFMRqry_items_in_cat_for_project = <0x%.8x>\n", status));
                MEMclose (&buffer);
                if (status == NFM_E_NO_ITEMS_FOUND_IN_CAT)
                 {
                    _NFIdebug ((fname, "No items found in catalog <%s>\n",
                                catalog_name));
                    _NFIdebug ((fname, " returning SUCCESS\n"));
                    return (NFI_I_NO_ITEMS);
                 }
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
             }
         }
        else
         {
           status = NFMRdisplay_items (catalog_name, "", "", NFM_SHORT_DISPLAY,
                                       &synonym, &buffer);
           if (status != NFM_S_SUCCESS)
             {
                   _NFIdebug ((fname, "NFMRdisplay_items = <0x%.8x>\n",
                               status));
                   MEMclose (&buffer);
                   if (status == NFM_E_DISPLAY_ITEMS)
                    {
                       _NFIdebug ((fname, "No items found in catalog <%s>\n",
                                   catalog_name));
                       _NFIdebug ((fname, " returning SUCCESS\n"));
                       return (NFI_I_NO_ITEMS);
                    }
                   _NFIdebug ((fname, " returning FAILURE\n"));
                   return (status);
             }

           MEMclose (&(entity->item_data));
           MEMclose (&synonym);
           entity->item_data = NULL;
   
           _NFIdebug ((fname, "returned from NFMRdisplay_items\n"));
   
           if (_NFMdebug_st.NFIdebug_on)
                  MEMprint_buffers (fname, buffer, _NFMdebug_st.NFIdebug_file);
   
           /*  copy the current data list into the data_list */
   
           status = MEMsplit_copy_buffer (buffer, &(entity->item_data), 0);
           if (status != MEM_S_SUCCESS)
             {
                   _NFIdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n",
                               status));
                MEMclose (&buffer);
                MEMclose (&(entity->item_data));
                entity->item_data = NULL;
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMsplit_copy_buffer",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
          }

          MEMclose (&buffer);
         }

        status = MEMbuild_array (entity->item_data);
        if (status != MEM_S_SUCCESS)
         {
                _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
                MEMclose (&buffer);
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
         }

        entity->item_name_offset = 1;
        entity->rev_name_offset = 2;
        entity->toggle_offset = -1;

        /* find the item_name and revision offsets in the data_list */ 

        column_ptr = (char **) entity->item_data->column_ptr;

        for (x = 0; x < entity->item_data->columns; ++x)
        {
           if (strcmp (column_ptr[x], "n_itemname") == 0)
            {
               entity->item_name_offset = x;
            }
           else if (strcmp (column_ptr[x], "n_itemrev") == 0)
            {
               entity->rev_name_offset = x;
            }
           else if (strcmp (column_ptr[x], "n_type") == 0)
            {
               entity->toggle_offset = x;
            }
        }

        _NFIdebug ((fname, "Offset to n_itemname = <%d>\n",
                    entity->item_name_offset));
        _NFIdebug ((fname, "Offset to n_itemrev  = <%d>\n",
                    entity->rev_name_offset));
        _NFIdebug ((fname, "Offset to n_type     = <%d>\n",
                    entity->toggle_offset));

        if ((entity->item_name_offset < 0) || (entity->rev_name_offset < 0))
        {
           status = NFI_E_BUFFER;
           _NFIdebug ((fname, "Cannot locate attribute in data list \n"));
           ERRload_struct (NFI, NFI_E_MEM, "%s%x", 
                            "Cannot locate attribute in data list", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
        }

        if (display_values == TRUE)
         { 
            status =  _NFFdisplay_items (form, HIDDEN_SCF, entity);
            if (status != NFI_S_SUCCESS)
            {
               _NFIdebug ((fname, "_NFFdisplay_items : status = <0x%.8x>\n",
                           status));
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (status);
            }
         }

        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
  }


  long _NFFdisplay_items (form, g_label, entity)
    Form       form;
    int        g_label;
    NFFset_ptr entity;
  {
     long   status;
     int    count, x;
     char   **data;
     char   title[NFF_MAX_MESSAGE];

     static char *fname = "_NFFdisplay_items";

     if (entity->item_data == NULL)
      {
         /* send a message to the user specifying the catalog has no items */

          NFFform_message (CURRENT_LABEL, NFI_I_NO_ITEMS, NULL);

         _NFIdebug ((fname, "No items found in catalog <%s>\n",
                     entity->curr_cat));
         return (NFI_S_SUCCESS);
      }

     _NFIdebug ((fname, "Current Item    = <%s>\n", entity->curr_item));
     _NFIdebug ((fname, "Item Offset     = <%d>\n", entity->item_name_offset));

     /* set the number of rows to 0 to wipe out previous data. */

     status = (long) FIfld_set_num_rows (form, HIDDEN_SCF, 0);

                                     /*  entity->item_data->rows);  */
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
         ERRload_struct (NFI,
             NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     /* set the select mode to single_select */

     status = (long) FIfld_set_mode (form, HIDDEN_SCF, 0, FI_SINGLE_SELECT); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     data = (char **) entity->item_data->data_ptr; 

     /* Put the data in the list to display it. */ 

#ifdef OS_SCO_UNIX
     /* work around change - to set font for SCO - SSRS 4 Feb 94 */
     FIg_set_font( form, g_label, "7x13bold", 15 );
#endif

     for (x = 0; x < entity->item_data->rows; ++x)
      {
        count = entity->item_data->columns * x + entity->item_name_offset; 

        if (strcmp (data[count], entity->curr_item) == 0)
	{
          status = (long) FIfld_set_text (form, g_label, x, 0, data[count],
                                          TRUE);
	}
        else
	{
          status = (long) FIfld_set_text (form, g_label, x, 0, data[count],
                                          FALSE);
	}
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
      }

     /* put the item name in the item field */

#ifdef OS_SCO_UNIX
     /* work around change - to set font for SCO - SSRS 4 Feb 94 */
     FIg_set_font( form, ITEM_FIELD, "7x13bold", 15 );
#endif
     status = (long) FIfld_set_text (form, ITEM_FIELD, 0, 0, 
                                     entity->curr_item, FALSE); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }


     /* set the hidden scf title. */ 

     status = (long) UMSGetByNum (title, NFI_P_LIST_ITEMS, "%s",  
                                  entity->curr_cat);
     if (status != UMS_S_SUCCESS)
      {
         _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
         _NFIdebug ((fname, "defaulting title\n"));
         sprintf (title, "List of Items in Catalog \"%s\"",
                  entity->curr_cat);
      }
      _NFIdebug ((fname, "Title = <%s>\n", title));

     if ((status = _NFFmem_set_text (form, TITLE2, title)) != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "_NFFmem_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "_NFFmem_set_text", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     entity->item_displayed = TRUE;
     entity->cat_displayed = FALSE;
     entity->rev_displayed = FALSE;
     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
  } 


  long _NFFdisplay_revisions (form, g_label, entity)
    Form       form;
    int        g_label;
    NFFset_ptr entity;
  {
     long   status;
     int    count, x, i, j;
     char   **data;
     char   title[NFF_MAX_MESSAGE];

     static char *fname = "_NFFdisplay_revisions";

     if (entity->item_data == NULL)
      {
         /* send a message to the user specifying the catalog has no items */

          NFFform_message (CURRENT_LABEL, NFI_I_NO_ITEMS, NULL);

         _NFIdebug ((fname, "No items found in catalog <%s>\n",
                     entity->curr_cat));
         return (NFI_S_SUCCESS);
      }

     _NFIdebug ((fname, "Current Revision = <%s>\n", entity->curr_rev));
     _NFIdebug ((fname, "Revision Offset  = <%d>\n", entity->rev_name_offset));

     if ((strcmp (entity->curr_item, "") == 0) || (entity->item_data == NULL))
      {
          /* send a information message stating to choose an item. */

          NFFform_message (CURRENT_LABEL, NFI_I_CHOOSE_ITEM, NULL);
          return (NFI_S_SUCCESS);
      }

     /* set the number of rows to 0. */

     status = (long) FIfld_set_num_rows (form, g_label, 0);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
         ERRload_struct (NFI,
             NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     /* set the select mode to single_select */

     status = (long) FIfld_set_mode (form, g_label, 0, FI_SINGLE_SELECT); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIg_set_mode = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     data = (char **) entity->item_data->data_ptr; 

     i = 0;

     /* find out how many rows will be needed, will have at least 1 row */

     for (x = 0; x < entity->item_data->rows; ++x)
      {
         count = entity->item_data->columns * x + entity->item_name_offset; 

         if (strcmp (data[count], entity->curr_item) == 0) 
            ++i;
      }
      _NFIdebug ((fname, "Number of revisions = <%d>\n", i));

     i = 0; 

     /* Put the data in the list to display it. */ 
#ifdef OS_SCO_UNIX
     /* work around change - to set font for SCO - SSRS 4 Feb 94 */
     FIg_set_font( form, g_label, "7x13bold", 15 );
#endif

     for (x = 0; x < entity->item_data->rows; ++x)
      {
        count = entity->item_data->columns * x + entity->item_name_offset; 
        j     = entity->item_data->columns * x + entity->rev_name_offset; 

        if (strcmp (data[count], entity->curr_item) == 0)/* display revision */
         {
            if (strcmp (data[j], entity->curr_rev) == 0)
	    {	
              status = (long) FIfld_set_text (form, g_label, i, 0,  
                                              data[j], TRUE);
	    }
            else
	    {
              status = (long) FIfld_set_text (form, g_label, i, 0,
                                              data[j], FALSE);
	    }
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
            ++i;
         }
      }
/* put the revision name in the revision field */

#ifdef OS_SCO_UNIX
     /* work around change - to set font for SCO - SSRS 4 Feb 94 */
     FIg_set_font( form, REVISION_FIELD, "7x13bold", 15 );
#endif
     status = (long) FIfld_set_text (form, REVISION_FIELD, 0, 0, 
                                     entity->curr_rev, FALSE); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }


     /* set the hidden scf title. */ 

     status = (long) UMSGetByNum (title, NFI_P_LIST_REVISIONS, "%s",  
                                  entity->curr_item);
     if (status != UMS_S_SUCCESS)
      {
         _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
         _NFIdebug ((fname, "defaulting title\n"));
         sprintf (title,
             "List of Revisions in Item \"%s\"", entity->curr_item);
      }
      _NFIdebug ((fname, "Title = <%s>\n", title));

     if ((status = _NFFmem_set_text (form, TITLE2, title)) != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "_NFFmem_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "_NFFmem_set_text", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     entity->item_displayed = FALSE;
     entity->cat_displayed  = FALSE;
     entity->rev_displayed  = TRUE;

     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
  } 

long _NFFinsert_set_members_in_list (entity, rows, member_list)
    NFFset_ptr entity;
    int        *rows;
    struct     NFMmember_info *member_list[];
 {
     long status;
     int  x, y, num_rows = -1, i = 0;

     char *fname = "_NFFinsert_set_members_in_list";

     _NFIdebug ((fname, "function entered...\n"));

     num_rows = entity->rows - entity->data_list->rows;
     if (num_rows < 1)
      {
          status = NFI_I_NO_MEMBERS_ADDED;
          ERRload_struct (NFI, status, NULL);
          _NFIdebug ((fname, "no rows added by user stat = <0x%.8x>\n",
                      status));
          _NFIdebug ((fname, " returning Failure...\n"))
          return (status);
      }

     _NFIdebug ((fname, "num rows = <%d>\n", num_rows));

     *rows = num_rows;

     /* malloc memory for the member_list */

     if ((*member_list = (struct NFMmember_info *) malloc
                       (num_rows * (sizeof (struct NFMmember_info)))) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n",
                    num_rows * (sizeof (struct NFMmember_info))));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                    num_rows * (sizeof (struct NFMmember_info)));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

     /* sprintf (level, "%d", entity->level); */

     i = 0;
     for (y = entity->data_list->rows; y < entity->rows; ++y) 
      {
         (*member_list)[i].operation = NFM_ADD_MEMBER;
         (*member_list)[i].citno = (long) 0;
         (*member_list)[i].catalog_no = (long) 0;
         (*member_list)[i].item_no = (long) 0;
         for (x = 0; x < entity->data_list->columns; ++x)
          {
             if (x == entity->cat_offset)
                strcpy ((*member_list)[i].catalog_name,  
                                          entity->member_list[y].catalog);
             else if (x == entity->item_offset)
                strcpy ((*member_list)[i].item_name,
                                          entity->member_list[y].item);
             else if (x == entity->rev_offset)
                strcpy ((*member_list)[i].item_rev,
                                          entity->member_list[y].revision);
             else if (x == entity->type_offset)
                strcpy ((*member_list)[i].type,
                                          entity->member_list[y].type);
          }

         ++i;
      }

     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
 }


long _NFFinsert_project_members_in_list (entity)
    NFFset_ptr entity;
 {
     long status;
     int  x, y;
     char s[1024]; 
     char *fname = "_NFFinsert_project_members_in_list";

     _NFIdebug ((fname, "data_list->rows = <%d>\n", entity->data_list->rows));
     _NFIdebug ((fname, "entity->rows    = <%d>\n", entity->rows));

     for (y = entity->data_list->rows; y < entity->rows; ++y) 
      {
         s[0] = 0;
         for (x = 0; x < entity->data_list->columns; ++x)
          {
                  if (x == entity->project_offset)
                     strcat (s, entity->project);
             else if (x == entity->cat_offset)
                     strcat (s, entity->member_list[y].catalog);
             else if (x == entity->item_offset)
                     strcat (s, entity->member_list[y].item);
             else if (x == entity->rev_offset)
                     strcat (s, entity->member_list[y].revision);
             else if (x == entity->type_offset)
                     strcat (s, entity->member_list[y].type);
             else if (x == entity->status_offset)
                     strcat (s, "ADD");
             else 
              {
                  strcat (s, "");
              }
             strcat (s, "\1");
          }
         _NFIdebug ((fname, "s = <%s>\n", s));

         status = MEMwrite (entity->data_list, s);
         if (status != MEM_S_SUCCESS)
          {
             _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
             ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MEM);
          } 

         status = MEMbuild_array (entity->data_list);
         if (status != MEM_S_SUCCESS)
          {
             _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
             ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MEM);
          } 
      }

     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
 }


long _NFFadjust_set_members_form (form)
  Form form;
{
    long    status;

    static    char *fname = "_NFFadjust_set_members_form";

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


long _NFFupdate_set_members_in_list (form, g_label, entity, rows, member_list)
    Form       form;
    int        g_label;
    NFFfitem   entity;
    int        *rows;
    struct     NFMmember_info *member_list[];
 {
     long status;
     int  x, num_rows = -1, i = 0;
     int  sel_flag = FALSE, count = 0; 
     short  cat_offset = -1; 
     short  item_offset = -1; 
     short  rev_offset = -1; 
     short  type_offset = -1; 
     char **data; 

     char *fname = "_NFFupdate_set_members_in_list";

     _NFIdebug ((fname, "g_label = <%d>\n", g_label));

     num_rows = (entity->item_data)->rows - 1;
     if (num_rows < 1)
      {
          status = NFI_I_NO_SET_MEMBERS;
          ERRload_struct (NFI, status, NULL);
          _NFIdebug ((fname, "no set members found = <0x%.8x>\n",
                      status));
          _NFIdebug ((fname, " returning Failure...\n"))
          return (status);
      }

     _NFIdebug ((fname, "num rows = <%d>\n", num_rows));

     /* get the offsets */

     if ((status = _NFFfind_column_offset
        (entity->item_data, "n_catalogname", &cat_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

     if ((status = _NFFfind_column_offset
        (entity->item_data, "n_itemname", &item_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

     if ((status = _NFFfind_column_offset
        (entity->item_data, "n_itemrev", &rev_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

     if ((status = _NFFfind_column_offset
        (entity->item_data, "n_type", &type_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

     /* find out how many rows to delete */

     data = (char **) (entity->item_data)->data_ptr;
     for (x = 0; x < num_rows; ++x)
      {
         /* see if this row is selected */

         status = (long) FIfld_get_select (form, g_label, x, 0, &sel_flag); 
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          }
         
         if (sel_flag)
          {
             ++i;
             if (i == 1)
              {
                 /* malloc memory for the member_list */

                 if ((*member_list = (struct NFMmember_info *) malloc
                      (i * (sizeof (struct NFMmember_info)))) == NULL)
                  {
                    _NFIdebug ((fname, "malloc failed; size = <%d>\n",
                                num_rows * (sizeof (struct NFMmember_info))));
                    ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                num_rows * (sizeof (struct NFMmember_info)));
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_MALLOC);
                  }
              }
             else
              {
                 /* realloc memory for the member_list */

                 if ((*member_list = (struct NFMmember_info *) realloc
                  (*member_list, i * (sizeof (struct NFMmember_info)))) == NULL)
                  {
                    _NFIdebug ((fname, "realloc failed; size = <%d>\n",
                                i * (sizeof (struct NFMmember_info))));
                    ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                    i * (sizeof (struct NFMmember_info)));
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_MALLOC);
                  }
              }
            
             /* Put the row of data into the list */

             count = (entity->item_data)->columns * (x + 1);
             (*member_list)[i - 1].operation = NFM_DROP_MEMBER;
             (*member_list)[i - 1].citno = (long) 0;
             (*member_list)[i - 1].catalog_no = (long) 0;
             (*member_list)[i - 1].item_no = (long) 0;

             strcpy ((*member_list)[i - 1].catalog_name, 
                                   data [count + cat_offset]);
             strcpy ((*member_list)[i - 1].item_name,
                                   data [count + item_offset]);
             strcpy ((*member_list)[i - 1].item_rev,
                                   data [count + rev_offset]);
             strcpy ((*member_list)[i - 1].type,
                                   data [count + type_offset]);
          }
      }

     *rows = i;

     if (i == 0)
      {
          /* No rows have been selected to delete. */

          status = NFI_I_NO_ITEMS_SELECTED;
          ERRload_struct (NFI, status, NULL);
          _NFIdebug ((fname, " returning Failure\n"));
          return (status);
      }

     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
 }


