
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFcatalog.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFcat_load_catalog_attributes (form, label, catalog)
  Form         form;
  int          label;
  NFFcatalog   catalog;
  {
    int     i, row;
    int     total_fields;
    long    status;
    char    **data_ptr;
    char    attr_name[20];
    short   seqno_offset;
    short   name_offset;
    short   datatype_offset;
    short   syn_offset;

    static  char *fname = "_NFFcat_load_catalog_attributes";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = MEMbuild_array (catalog->cat_attr)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    data_ptr = (char **) (catalog->cat_attr)->data_ptr;

    /*  Find the offsets in the buffer  */

    if (catalog->command == CREATE)
        strcpy (attr_name, "n_name");
    else
        strcpy (attr_name, "new_n_name");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, attr_name, &name_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (catalog->command == CREATE)
        strcpy (attr_name, "n_datatype");
    else
        strcpy (attr_name, "new_n_datatype");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, attr_name, &datatype_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (catalog->command == CREATE)
        strcpy (attr_name, "n_synonym");
    else
        strcpy (attr_name, "new_n_synonym");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, attr_name, &syn_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (catalog->command == CREATE)
        strcpy (attr_name, "n_seqno");
    else
        strcpy (attr_name, "new_n_seqno");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, attr_name, &seqno_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Load the catalog attributes into ATTRIBUTES_MCF  */

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    row = 0;
    total_fields = (catalog->cat_attr)->rows * (catalog->cat_attr)->columns;
    for (i = 0; i < total_fields; i += (catalog->cat_attr)->columns, ++row)
      {
        /*  Load in "n_seqno"  */

        _NFIdebug ((fname, "%d: Setting row %d col %d = <%s>\n", label,
            row, 0, data_ptr[i + seqno_offset]));

        if ((status = (long) FIfld_set_text (form,
            label, row, 0, data_ptr[i + seqno_offset], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Load in "n_name"  */

        _NFIdebug ((fname, "%d: Setting row %d col %d = <%s>\n", label,
            row, 1, data_ptr[i + name_offset]));

        if ((status = (long) FIfld_set_text (form,
            label, row, 1, data_ptr[i + name_offset], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Load in "n_datatype"  */

        _NFIdebug ((fname, "%d: Setting row %d col %d = <%s>\n", label,
            row, 2, data_ptr[i + datatype_offset]));

        if ((status = (long) FIfld_set_text (form, label,
            row, 2, data_ptr[i + datatype_offset], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Load in "n_synonym"  */

        _NFIdebug ((fname, "%d: Setting row %d col %d = <%s>\n", label,
            row, 3, data_ptr[i + syn_offset]));

        if ((status = (long) FIfld_set_text (form,
            label, row, 3, data_ptr[i + syn_offset], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_attributes_mcf (form, label, catalog, row_no)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  int           row_no;
  {
    int     selected;
    long    status;
    char    attr_name[40];
    char    datatype[40];
    short   delete_flag;

    static  char *fname = "_NFFcat_attributes_mcf";

    _NFIdebug ((fname, "row_no = %d\n", row_no));

    if (row_no < 0)
      {
        _NFIdebug ((fname, "rows or columns are scrolling\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Find out if the row was selected or unselected  */

    if ((status = (long) FImcf_get_select
        (form, label, row_no, &selected)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_get_select = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (selected == FALSE)
      {
        _NFIdebug ((fname, "row was unselected\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Toggle the characteristics flags  */

    if ((status = _NFFcat_set_characteristics
        (form, catalog, row_no, &delete_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "_NFFcat_set_characteristics = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Set any defaults for this attribute  */

    if ((status = _NFFcat_set_defaults (form, catalog,
        row_no, attr_name, datatype, delete_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_set_defaults = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Save the active_attribute  */

    catalog->active_attribute = row_no;

    /*  Set any values for this attribute  */

    if ((status = _NFFcat_set_values
        (form, catalog, attr_name)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_set_values = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Modify the type and format string of the range fields  */

    if ((status = _NFFcat_set_range_attr (form, datatype)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_set_range_attr = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Begin the sequence  */

    if ((status = FIg_start_seq (form, ORDER_FIELD)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_start_seq = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_start_seq", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_set_defaults (Form form, NFFcatalog catalog, int attribute,
char *attr_name, char *datatype, short delete_flag)
/*  Form          form;
  NFFcatalog    catalog;
  int           attribute;
  char          *attr_name;    o - name of the active attribute
  char          *datatype;     o - datatype of the active attribute
  short         delete_flag;   i - 1 if attribute is deletable       */
  {
    int     row_offset;
    int     mode;
    int     next_in_seq;
    long    status;
    char    **data_ptr;
    char    col_name[20];
    short   offset, new_attr;
    short   save_command;

    static  char *fname = "_NFFcat_set_defaults";

    _NFIdebug ((fname, "attribute = <%d>\n", attribute));

    /*  Save the current command  */

    save_command = catalog->command;

    data_ptr = (char **) (catalog->cat_attr)->data_ptr;
    row_offset = attribute * (catalog->cat_attr)->columns;

    /*  Set the attribute name  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_name");
    else
        strcpy (col_name, "new_n_name");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find out if this is a new user-defined attribute -
        check to see if there is any value for the attribute name;
        it is assumed here that we are in a CHANGE command;
        if we are not, the command would have already failed
        because the buffers would be corrupted beyond recovery  */

    if ((strcmp (data_ptr[row_offset + offset], "")) == 0)
      {
        catalog->command = CREATE;

        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, "n_name", &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            catalog->command = save_command;
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    _NFIdebug ((fname,
        "Setting <%s> in attribute field\n", data_ptr[row_offset + offset]));

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, ATTRIBUTE_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, ATTRIBUTE_FIELD,
        0, 0, data_ptr[row_offset + offset], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Save the attribute name  */

    strcpy (attr_name, data_ptr[row_offset + offset]);

    /*  Set the order number  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_seqno");
    else
        strcpy (col_name, "new_n_seqno");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname,
        "Setting <%s> in order field\n", data_ptr[row_offset + offset]));

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, ORDER_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, ORDER_FIELD,
        0, 0, data_ptr[row_offset + offset], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the datatype  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_datatype");
    else
        strcpy (col_name, "new_n_datatype");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname,
        "Setting <%s> in datatype field\n", data_ptr[row_offset + offset]));

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, DATATYPE_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, DATATYPE_FIELD,
        0, 0, data_ptr[row_offset + offset], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Save the datatype  */

    strcpy (datatype, data_ptr[row_offset + offset]);

    /*  Set the synonym  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_synonym");
    else
        strcpy (col_name, "new_n_synonym");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname,
        "Setting <%s> in synonym field\n", data_ptr[row_offset + offset]));

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, SYNONYM_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, SYNONYM_FIELD,
        0, 0, data_ptr[row_offset + offset], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the default value (first row in data buffer)  */

    data_ptr = (char **) (catalog->cat_data)->data_ptr;

    _NFIdebug ((fname,
        "Setting <%s> in default value field\n", data_ptr[attribute]));

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, DEFAULT_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, DEFAULT_FIELD,
        0, 0, data_ptr[attribute], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  If the attribute belongs to NFM, or if it is a user-defined
        attribute that was NOT added during this invocation of the
        command, make the attribute name and datatype fields review only  */

    data_ptr = (char **) (catalog->cat_attr)->data_ptr;

    if (catalog->command == CREATE)
        strcpy (col_name, "n_application");
    else
        strcpy (col_name, "new_n_application");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((strcmp (data_ptr[row_offset + offset], "NFM")) == 0)
      {
        _NFIdebug ((fname, "it is an I/NFM attribute\n"));

        /*  It is an NFM attribute  */

        catalog->user_defined = FALSE;

        if ((status = (long) FIfld_set_mode
            (form, ATTRIBUTE_FIELD, 0, FI_REVIEW)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            catalog->command = save_command;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = (long) FIg_display
            (form, ATTRIBUTE_FIELD)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            catalog->command = save_command;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  See if the datatype is 'char'; if it is, allow
            the user to alter the default datatype - Glenn 7/28/92  */

        if ((catalog->command == CREATE) &&
            ((strncmp (datatype, "char", 4)) == 0))
          {
            _NFIdebug ((fname, "enabling the 'char' datatype field\n"));

            if ((status = (long) FIfld_set_mode
                (form, DATATYPE_FIELD, 0, FI_INSERT)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            if ((status = (long) FIg_enable
                (form, DATATYPE_FIELD)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_enable = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_enable", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  Alter the sequencing order  */

            if ((status = (long) FIg_set_next_in_seq
                (form, ORDER_FIELD, DATATYPE_FIELD)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_set_next_in_seq = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_set_next_in_seq", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
        else
          {
            if ((status = (long) FIfld_set_mode
                (form, DATATYPE_FIELD, 0, FI_REVIEW)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            if ((status = (long) FIg_disable
                (form, DATATYPE_FIELD)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  Alter the sequencing order  */

            if ((status = (long) FIg_set_next_in_seq
                (form, ORDER_FIELD, SYNONYM_FIELD)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_set_next_in_seq = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_set_next_in_seq", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }

        /*  Disable the user-defined attributes delete button  */

        if ((status = (long) FIg_disable
            (form, DELETE_USER_DEFINED)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
            catalog->command = save_command;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else
      {
        _NFIdebug ((fname, "it is a user-defined attribute\n"));

        /*  It is a user-defined attribute  */

        catalog->user_defined = TRUE;

        /*  See if this is a user-defined attribute
            added during THIS invocation of the command  */

        if ((status = _NFFcat_attr_new_or_old
            (catalog, attribute, &new_attr)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFcat_attr_new_or_old = <0x%.8x>\n", status));
            catalog->command = save_command;
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        if (new_attr == TRUE)
          {
            mode = FI_INSERT;
	    delete_flag = 1;   /* PS */
            _NFIdebug ((fname, "mode is FI_INSERT\n"));
          }
        else
          {
            mode = FI_REVIEW;
            _NFIdebug ((fname, "mode is FI_REVIEW\n"));
          }

        if ((status = (long) FIfld_set_mode
            (form, ATTRIBUTE_FIELD, 0, mode)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            catalog->command = save_command;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = (long) FIg_display
            (form, ATTRIBUTE_FIELD)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            catalog->command = save_command;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = (long) FIfld_set_mode
            (form, DATATYPE_FIELD, 0, mode)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            catalog->command = save_command;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (new_attr == TRUE)
          {
            _NFIdebug ((fname, "enabling the datatype field\n"));

            if ((status = (long) FIg_enable
                (form, DATATYPE_FIELD)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_enable = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_enable", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
        else
          {
            _NFIdebug ((fname, "disabling the datatype field\n"));

            if ((status = (long) FIg_disable
                (form, DATATYPE_FIELD)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }

        /*  Enable the delete button if this attribute is deletable  */

        if (delete_flag == 1)
          {
            _NFIdebug ((fname, "enabling DELETE button\n"));

            if ((status = (long) FIg_enable
                (form, DELETE_USER_DEFINED)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_enable = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_enable", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
        else
          {
            _NFIdebug ((fname, "disabling DELETE button\n"));

            if ((status = (long) FIg_disable
                (form, DELETE_USER_DEFINED)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
                catalog->command = save_command;
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }

        /*  Alter the sequencing order  */

        if (new_attr == TRUE)
          {
            next_in_seq = ATTRIBUTE_FIELD;
            _NFIdebug ((fname, "next_in_seq is ATTRIBUTE_FIELD\n"));
          }
        else
          {
            next_in_seq = SYNONYM_FIELD;
            _NFIdebug ((fname, "next_in_seq is SYNONYM_FIELD\n"));
          }

        if ((status = (long) FIg_set_next_in_seq
            (form, ORDER_FIELD, next_in_seq)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_next_in_seq = <%d>\n", status));
            catalog->command = save_command;
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_next_in_seq", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Restore the current command  */

    catalog->command = save_command;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_set_characteristics (form, catalog, attribute, delete_flag)
  Form         form;
  NFFcatalog   catalog;
  int          attribute;
  short        *delete_flag;
  {
    int     state;
    int     row_offset;
    long    status;
    char    **data_ptr;
    char    col_name[20];
    char    field_string[40];
    short   offset;
    short   save_command;
    short   first_time = FALSE;

    static  char *fname = "_NFFcat_set_characteristics";

    _NFIdebug ((fname, "attribute = <%d>\n", attribute));
    _NFIdebug ((fname, "catalog->command = <%d>\n", catalog->command));

    /*  Save the current command  */

    save_command = catalog->command;

    data_ptr = (char **) (catalog->cat_attr)->data_ptr;
    row_offset = attribute * (catalog->cat_attr)->columns;

    /*  Set the read flag  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_read");
    else
        strcpy (col_name, "new_n_read");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find out if this is a new user-defined attribute -
        check to see if there is any value for the read flag;
        it is assumed here that we are in a CHANGE command;
        if we are not, the command would have already failed
        because the buffers would be corrupted beyond recovery  */
/* PS */
    _NFIdebug ((fname, "column offset = <%d>\n", offset));
    _NFIdebug ((fname, "column value = <%s>\n", data_ptr[row_offset + offset]));

    if ((strcmp (data_ptr[row_offset + offset], "")) == 0)
      {
        catalog->command = CREATE;
        first_time = TRUE;

        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, "n_read", &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            catalog->command = save_command;
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    if ((strcmp (data_ptr[row_offset + offset], "Y")) == 0)
        state = 1;
    else
        state = 0;

    if ((status = (long) FIg_set_state
        (form, READ_TOGGLE, state)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  Set the write flag  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_write");
    else
        strcpy (col_name, "new_n_write");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((strcmp (data_ptr[row_offset + offset], "Y")) == 0)
        state = 1;
    else
        state = 0;

    if ((status = (long) FIg_set_state
        (form, WRITE_TOGGLE, state)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  Set the update flag  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_update");
    else
        strcpy (col_name, "new_n_update");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((strcmp (data_ptr[row_offset + offset], "Y")) == 0)
        state = 1;
    else
        state = 0;

    if ((status = (long) FIg_set_state
        (form, UPDATE_TOGGLE, state)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  Set the delete flag  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_delete");
    else
        strcpy (col_name, "new_n_delete");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((strcmp (data_ptr[row_offset + offset], "Y")) == 0)
        state = 1;
    else
        state = 0;

    /*  Set the delete flag if this is a
        newly added user-defined attribute  */

/* PS  - if first_time then attributes can be deleted.set delete flag to 1 
   explicitely ; */

    if (first_time == TRUE)
        /*    *delete_flag = state;    */
        *delete_flag = 1;
    else
        *delete_flag = 0;  /* or state - PS */

    if ((status = (long) FIg_set_state
        (form, DELETE_TOGGLE, state)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  Set the nulls flag  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_null");
    else
        strcpy (col_name, "new_n_null");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((strcmp (data_ptr[row_offset + offset], "Y")) == 0)
        state = 1;
    else
        state = 0;

    if ((status = (long) FIg_set_state
        (form, NULLS_TOGGLE, state)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  Set the checkin field  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_checkin");
    else
        strcpy (col_name, "new_n_checkin");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((strcmp (data_ptr[row_offset + offset], "N")) == 0)
        strcpy (field_string, "Do NOT Display");
    else if ((strcmp (data_ptr[row_offset + offset], "Y")) == 0)
        strcpy (field_string, "Display only");
    else
        strcpy (field_string, "Display AND Update");

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, CHECKIN_ROLLTHRU, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text
        (form, CHECKIN_ROLLTHRU, 0, 0, field_string, FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  Set the checkout field  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_checkout");
    else
        strcpy (col_name, "new_n_checkout");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, col_name, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((strcmp (data_ptr[row_offset + offset], "N")) == 0)
        strcpy (field_string, "Do NOT Display");
    else if ((strcmp (data_ptr[row_offset + offset], "Y")) == 0)
        strcpy (field_string, "Display only");
    else
        strcpy (field_string, "Display AND Update");

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, CHECKOUT_ROLLTHRU, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text
        (form, CHECKOUT_ROLLTHRU, 0, 0, field_string, FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        catalog->command = save_command;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  Restore the current command  */

    catalog->command = save_command;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_set_values (form, catalog, attr_name)
  Form          form;
  NFFcatalog    catalog;
  char          *attr_name;  /*  i - name of the active attribute  */
  {
    auto    int     i, fields;
    auto    int     data_offset;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   offset;
    static  char    *fname = "_NFFcat_set_values";

    _NFIdebug ((fname, "attribute name = <%s>\n", attr_name));

    /*  Blank out the advice field  */

    if ((status = FIfld_set_text (form,
        ADVISORY_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Check for advisory information  */

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, "n_advice", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (catalog->cat_attr)->data_ptr;
    data_offset = (catalog->cat_attr->columns * catalog->active_attribute)
        + offset;

    _NFIdebug ((fname,
        "Setting <%s> in advisory field\n", data_ptr[data_offset]));

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, ADVISORY_FIELD, "7x13bold", 15 );
#endif
    if ((status = FIfld_set_text (form,
        ADVISORY_FIELD, 0, 0, data_ptr[data_offset], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((strcmp (data_ptr[data_offset], "")) == 0)
        catalog->advice_exists = FALSE;
    else
        catalog->advice_exists = TRUE;

    /*  Blank out the range fields  */

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, INFO_MIN_FIELD, "7x13bold", 15 );
#endif
    if ((status = FIfld_set_text (form,
        INFO_MIN_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, INFO_MAX_FIELD, "7x13bold", 15 );
#endif
    if ((status = FIfld_set_text (form,
        INFO_MAX_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Blank out the validation list  */

    if ((status = (long) FIfld_set_num_rows
        (form, VALIDATE_LIST_FIELD, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Check for validation data  */

    if ((status = _NFFfind_value_buffer (catalog->cat_attr,
        catalog->cat_value, attr_name, "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname,
            "there is no validation data for this attribute\n"));

        if (status == NFI_I_NO_VALIDATION_ALLOWED)
          {
            /*  Load in an informational status  */

            ERRload_struct (NFI, status, NULL);
          }
        else
          {
            /*  Reset the global structure  */

            ERRload_struct (NFI, NFI_S_SUCCESS, NULL);
          }

        catalog->range_exists = FALSE;
        catalog->list_exists = FALSE;
      }
    else
      {
        data_ptr = (char **) (catalog->cat_value)->data_ptr;

        if ((status = _NFFfind_column_offset
            (catalog->cat_value, "n_input", &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        if ((strcmp (data_ptr[offset], "NFM_RANGE")) == 0)
          {
            /*  Set the minimum value  */

            if ((status = _NFFfind_column_offset
                (catalog->cat_value, "n_minvalue", &offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
            FIg_set_font( form, INFO_MIN_FIELD, "7x13bold", 15 );
#endif
            if ((status = (long) FIfld_set_text (form,
                INFO_MIN_FIELD, 0, 0, data_ptr[offset], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  Set the maximum value  */

            if ((status = _NFFfind_column_offset
                (catalog->cat_value, "n_maxvalue", &offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	    FIg_set_font( form, INFO_MAX_FIELD, "7x13bold", 15 );
#endif
            if ((status = (long) FIfld_set_text (form,
                INFO_MAX_FIELD, 0, 0, data_ptr[offset], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            catalog->range_exists = TRUE;
            catalog->list_exists = FALSE;
          }
        else
          {
            /*  It is a list  */

            if ((status = _NFFfind_column_offset
                (catalog->cat_value, "n_value", &offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            fields = catalog->cat_value->rows * catalog->cat_value->columns;
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
            FIg_set_font( form, VALIDATE_LIST_FIELD, "7x13bold", 15 );
#endif

            for (i = 0; i < fields; i += catalog->cat_value->columns)
              {
                _NFIdebug ((fname,
                    "Setting <%s> in row %d, col 0 in list field\n",
                    data_ptr[i + offset], i / catalog->cat_value->columns));

                if ((status = (long) FIfld_set_text (form,
                    VALIDATE_LIST_FIELD, i / catalog->cat_value->columns,
                    0, data_ptr[i + offset], FALSE)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }

            catalog->list_exists = TRUE;
            catalog->range_exists = FALSE;
          }
      }

    /*  Set the buttons and toggles to reflect the data  */

    if (catalog->range_exists == TRUE)
      {
        /*  Set the validate button on  */

        if ((status = (long) FIg_set_state_on
            (form, VALIDATE_BUTTON)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the advice field  */

        if ((status = (long) FIg_erase
            (form, ADVISORY_FIELD)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the validate toggle  */

        if ((status = (long) FIg_display
            (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the toggle to range  */

        if ((status = (long) FIg_set_state_off
            (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_state_off = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_off", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the list gadgets  */

        if ((status = (long) FIg_erase
            (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the range fields  */

        if ((status = (long) FIg_display
            (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else if (catalog->list_exists == TRUE)
      {
        /*  Set the validate button on  */

        if ((status = (long) FIg_set_state_on
            (form, VALIDATE_BUTTON)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the advice field  */

        if ((status = (long) FIg_erase
            (form, ADVISORY_FIELD)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the validate toggle  */

        if ((status = (long) FIg_display
            (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the toggle to list  */

        if ((status = (long) FIg_set_state_on
            (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the range group  */

        if ((status = (long) FIg_erase
            (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the list gadgets  */

        if ((status = (long) FIg_display
            (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else if (catalog->advice_exists == TRUE)
      {
        /*  Set the advice button on  */

        if ((status = (long) FIg_set_state_on
            (form, ADVISE_BUTTON)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the validate toggle  */

        if ((status = (long) FIg_erase
            (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the range group  */

        if ((status = (long) FIg_erase
            (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the list gadgets  */

        if ((status = (long) FIg_erase
            (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the advice field  */

        if ((status = (long) FIg_display
            (form, ADVISORY_FIELD)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Default display  */

        /*  Set the validate button on  */

        if ((status = (long) FIg_set_state_on
            (form, VALIDATE_BUTTON)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the advice field  */

        if ((status = (long) FIg_erase
            (form, ADVISORY_FIELD)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the toggle to range  */

        if ((status = (long) FIg_set_state_off
            (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_state_off = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_off", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the validate toggle  */

        if ((status = (long) FIg_display
            (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the list gadgets  */

        if ((status = (long) FIg_erase
            (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the range fields  */

        if ((status = (long) FIg_display
            (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Erase the range values  */

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, INFO_MIN_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, INFO_MIN_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, INFO_MAX_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, INFO_MAX_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_advice_button (form)
  Form    form;
  {
    auto    int     status;
    static  char    *fname = "_NFFcat_advice_button";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Erase the validate gadgets  */

    if ((status = FIg_erase (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_erase (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_erase (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Display the advice field  */

    if ((status = FIg_display (form, ADVISORY_FIELD)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_advice_field (form, label, catalog)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  {
    auto    int     pos, sel;
    auto    long    status;
    auto    char    attrname[20];
    auto    char    text[NFM_VALUE + 1];
    auto    char    **data;
    auto    short   offset, data_offset;
    static  char    *fname = "_NFFcat_advice_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Need to take Change Catalog into account here  */

    if (catalog->command == CREATE)
      {
        /*  Always put the data in the first set of columns  */

        strcpy (attrname, "n_advice");
      }
    else
      {
        /*  Find out if this is a new user-defined attribute  */

        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, "new_n_name", &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
            FIg_set_font( form, label, "7x13bold", 15 );
#endif
            FIfld_set_text (form, label, 0, 0, "", FALSE);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
        data = (char **) catalog->cat_attr->data_ptr;
        data_offset =
            (catalog->active_attribute * catalog->cat_attr->columns) + offset;

        _NFIdebug(( fname, "act_attr <%d>\n", catalog->active_attribute));
        _NFIdebug(( fname, "rows <%d>\n", catalog->cat_attr->rows));
 
        if ((strcmp (data[data_offset], "")) == 0)
          {
            /*  This is a new user-defined attribute  */
	    _NFIdebug(( fname, "%s\n", "Me thinks this is a new attr " ));
            strcpy (attrname, "n_advice");
          }
        else
          {
            /*  This is a change to an existing attribute  */
	    _NFIdebug(( fname, "%s\n", "Me thinks this is an old attr " ));
            strcpy (attrname, "new_n_advice");
          }
      }

    _NFIdebug(( fname, "%s\n", "Find columns offset..." ));
    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, attrname, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, "", FALSE);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    FIfld_get_text (form, label, 0, 0, NFM_VALUE + 1, text, &pos, &sel);

    _NFIdebug(( fname, "Write <%s> into field <%d,%d>",
	catalog->active_attribute+1, offset+1 ));
    if ((status = MEMwrite_data (catalog->cat_attr,
        text, catalog->active_attribute + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, "", FALSE);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    catalog->advice_exists = TRUE;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_validate_button (form, catalog)
  Form          form;
  NFFcatalog    catalog;
  {
    int     status;
    int     state;

    static  char *fname = "_NFFcat_validate_button";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Erase the advice field  */

    if ((status = FIg_erase (form, ADVISORY_FIELD)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Display the validate gadgets  */

    if ((status = FIg_display (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_get_state (form, VALIDATE_TOGGLE, &state)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((catalog->list_exists == TRUE) || (state == 1))
      {
        if ((status = FIg_display (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Default to the range group  */

        if ((status = FIg_display (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_validate_toggle (form, state)
  Form   form;
  int    state;
  {
    int     status;

    static  char *fname = "_NFFcat_validate_toggle";

    _NFIdebug ((fname, "state = <%d>\n", state));

    /*  If the toggle is off, display the range group  */

    if (state == 0)
      {
        if ((status = FIg_erase (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = FIg_display (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else
      {
        if ((status = FIg_erase (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = FIg_display (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_add_user_defined (form, label, catalog)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  {
    auto    int     i;
    auto    int     next_highest;
    auto    int     num_vis_rows;
    auto    long    status;
    auto    char    *blank_row;
    auto    short   offset;

    static  char    cols[12][40] = {
        "n_seqno", "n_name", "n_datatype", "n_read",
        "n_write", "n_update", "n_delete", "n_null",
        "n_checkin", "n_checkout", "n_valueno", "n_advice" };

    static  char    vals[12][40] = {
        "0", "attribute_0", "char(20)", "Y",
        "Y", "Y", "Y", "Y", "N", "N", "0", "" };

    static  char    *fname = "_NFFcat_add_user_defined";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if( _NFMdebug_st.NFIdebug_on )
        MEMprint_buffer ( "NFFcat_add_user_defined : cat_attr (entering)",
            catalog->cat_attr, _NFMdebug_st.NFIdebug_file);

    /*  Increment the active attribute  */

    if ((status = _NFFfind_highest_seqno
        (catalog, &next_highest)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_highest_seqno = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    ++next_highest;

    /*  Write a blank row in the attribute buffer  */

    if ((blank_row = (char *) malloc (catalog->cat_attr->columns + 1)) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", catalog->cat_attr->columns + 1));
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", catalog->cat_attr->columns + 1);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    strcpy (blank_row, "");
    for (i = 0; i < catalog->cat_attr->columns; ++i)
        strcat (blank_row, "\1");

    if ((status = MEMwrite (catalog->cat_attr, blank_row)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        if (blank_row) free (blank_row);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (blank_row) free (blank_row);

    if ((status = MEMbuild_array (catalog->cat_attr)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }


    if( _NFMdebug_st.NFIdebug_on )
        MEMprint_buffer ( "NFFcat_add_user_defined : cat_attr (after blank row)", catalog->cat_attr, _NFMdebug_st.NFIdebug_file);

    /*  Write default data into the attribute buffer  */

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, ATTRIBUTES_MCF, "7x13bold", 15 );
#endif

    for (i = 0; i < 12; ++i)
      {
        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, cols[i], &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        switch (i)
          {
            case 0:
                sprintf (vals[i], "%d", next_highest);
                break;

            case 1:
                sprintf (vals[i], "attribute_%d", next_highest);
                break;

            default:
                break;
          }

        _NFIdebug ((fname,
            "writing <%s> into row %d, col %d in attribute buffer\n",
            vals[i], catalog->cat_attr->rows, offset + 1));

        if ((status = MEMwrite_data (catalog->cat_attr,
            vals[i], catalog->cat_attr->rows, offset + 1)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        /*  Put the new attribute data into the ATTRIBUTES_MCF  */

        if (i < 3)
          {
            if ((status = (long) FIfld_set_text (form, ATTRIBUTES_MCF,
                catalog->cat_attr->rows - 1, i, vals[i], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
      }

    /*  Rebuild the data buffer with the new attribute  */

    if ((status = NFMrebuild_data_buffer
        (catalog->cat_attr, &(catalog->cat_data))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMrebuild_data_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (catalog->cat_data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Select the new row and bring into the viewing area  */

    if ((status = (long) FIfld_get_num_vis_rows
        (form, ATTRIBUTES_MCF, &num_vis_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIfld_set_active_row (form, ATTRIBUTES_MCF,
        catalog->cat_attr->rows - 1, num_vis_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Make this attribute the active attribute  */

    if ((status = (long) FImcf_set_select (form,
        ATTRIBUTES_MCF, catalog->active_attribute, FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FImcf_set_select (form, ATTRIBUTES_MCF,
        catalog->cat_attr->rows - 1, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFcat_attributes_mcf (form, ATTRIBUTES_MCF,
        catalog, catalog->cat_attr->rows - 1)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_attributes_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "enabling DELETE button\n"));

    if ((status = (long) FIg_enable
        (form, DELETE_USER_DEFINED)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_enable = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_enable", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
    if( _NFMdebug_st.NFIdebug_on )
        MEMprint_buffer ( "NFFcat_add_user_defined : cat_attr (exiting)",
            catalog->cat_attr, _NFMdebug_st.NFIdebug_file);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_delete_user_defined (form, label, catalog)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  {
    int     i, j, k;
    int     next_row;
    int     column_to_skip;
    int     row_offset;
    long    status;
    char    *row_of_data;
    char    **column_ptr;
    char    **format_ptr;
    char    **data_ptr;
    char    column_name[60];
    char    datatype_name[60];
    short   offset;
    MEMptr  new_attr = NULL;
    MEMptr  new_data = NULL;

    static  char *fname = "_NFFcat_delete_user_defined";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if (catalog->command == CHANGE)
      {
        /*  Find out if this is new user-defined attribute  */

        data_ptr = (char **) (catalog->cat_attr)->data_ptr;
        row_offset = catalog->active_attribute * (catalog->cat_attr)->columns;

        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, "n_name", &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        if ((strcmp (data_ptr[row_offset + offset], "")) == 0)
          {
            /*  This is a new user-defined attribute  */

            ;
          }
      }

    /*  Rebuild the attribute buffer  */

    if ((status = MEMopen (&new_attr, MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    column_ptr = (char **) catalog->cat_attr->column_ptr;
    format_ptr = (char **) catalog->cat_attr->format_ptr;

    /*  Write the columns into the new buffer  */

    for (i = 0; i < catalog->cat_attr->columns; ++i)
      {
        if ((status = MEMwrite_format
            (new_attr, column_ptr[i], format_ptr[i])) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
            MEMclose (&new_attr);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    /*  Allocate space for a row of data  */

    if ((row_of_data = (char *) malloc (catalog->cat_attr->row_size)) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", catalog->cat_attr->row_size));
        MEMclose (&new_attr);
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", catalog->cat_attr->row_size);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    strcpy (row_of_data, "");
    data_ptr = (char **) catalog->cat_attr->data_ptr;

    /*  Build a new data buffer  */

    if ((status = MEMopen (&new_data, MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        MEMclose (&new_attr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Write all rows into the new buffer except the one to be deleted  */

    column_to_skip = -1;
    for (i = 0, k = 0; i < catalog->cat_attr->rows; ++i)
      {
        if (i == catalog->active_attribute)
          {
            k += catalog->cat_attr->columns;
            column_to_skip = i;
            continue;
          }

        for (j = 0; j < catalog->cat_attr->columns; ++j, ++k)
          {
            /*  Build the row of data  */

            strcat (row_of_data, data_ptr[k]);
            strcat (row_of_data, "\1");

            /*  Write the column in the new data buffer  */

            if ((strcmp (column_ptr[j], "n_name")) == 0)
                strcpy (column_name, data_ptr[k]);
            else if ((strcmp (column_ptr[j], "n_datatype")) == 0)
                strcpy (datatype_name, data_ptr[k]);
          }

        /*  Write the data into the buffer  */

        if ((status = MEMwrite (new_attr, row_of_data)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            if (row_of_data) free (row_of_data);
            MEMclose (&new_attr);
            MEMclose (&new_data);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        strcpy (row_of_data, "");

        /*  Write the columns in the data buffer  */

        if ((status = MEMwrite_format
            (new_data, column_name, datatype_name)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
            MEMclose (&new_attr);
            MEMclose (&new_data);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    if (row_of_data) free (row_of_data);

    /*  Allocate space for a row of data  */

    if ((row_of_data = (char *) malloc (catalog->cat_data->row_size)) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", catalog->cat_data->row_size));
        MEMclose (&new_attr);
        MEMclose (&new_data);
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", catalog->cat_data->row_size);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    strcpy (row_of_data, "");
    data_ptr = (char **) catalog->cat_data->data_ptr;

    /*  Copy the data rows into the new data buffer  */

    _NFIdebug ((fname, "column to skip is <%d>\n", column_to_skip));

    for (i = 0, k = 0; i < catalog->cat_data->rows; ++i)
      {
        for (j = 0; j < catalog->cat_data->columns; ++j, ++k)
          {
            if (j == column_to_skip) continue;

            /*  Build the row of data  */

            strcat (row_of_data, data_ptr[k]);
            strcat (row_of_data, "\1");
          }

        /*  Write the data into the buffer  */

        if ((status = MEMwrite (new_data, row_of_data)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            if (row_of_data) free (row_of_data);
            MEMclose (&new_attr);
            MEMclose (&new_data);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        strcpy (row_of_data, "");
      }

    if (row_of_data) free (row_of_data);

    /*  Close the old buffers  */

    MEMclose (&(catalog->cat_attr));
    MEMclose (&(catalog->cat_data));

    /*  Save the new buffers  */

    catalog->cat_attr = new_attr;
    catalog->cat_data = new_data;

    if ((status = MEMbuild_array (catalog->cat_attr)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (catalog->cat_data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Delete the row in the mcf  */

    if ((status = (long) FIfld_delete_rows
        (form, ATTRIBUTES_MCF, catalog->active_attribute, 1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_delete_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_delete_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Make the next row the active attribute  */

    if (catalog->active_attribute == catalog->cat_attr->rows)
        next_row = catalog->active_attribute - 1;
    else
        next_row = catalog->active_attribute;

    if ((status = (long) FImcf_set_select
        (form, ATTRIBUTES_MCF, next_row, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFcat_attributes_mcf
        (form, ATTRIBUTES_MCF, catalog, next_row)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_attributes_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_keyin_field (form, label, catalog, mcf_col)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  int           mcf_col;
  {
    auto    int     length;
    auto    int     pos, selected;
    auto    int     data_offset;
    auto    int     size;
    auto    long    status;
    auto    char    *text;
    auto    char    **data_ptr;
    auto    char    column[20];
    auto    short   offset, app_offset;
    auto    short   new_attr = FALSE, save_command;
    static  char    *fname = "_NFFcat_keyin_field";

    _NFIdebug ((fname, "mcf_col = <%d>\n", mcf_col));

    save_command = catalog->command;

    if (catalog->command == CREATE)
      {
        /*  Use the normal column offsets in the buffer  */

        strcpy (column, "n_");
      }
    else
      {
        /*  See if this attribute was added
            during THIS invocation of the command  */

        if ((status = _NFFcat_attr_new_or_old
            (catalog, catalog->active_attribute, &new_attr)) != NFI_S_SUCCESS)
          {
            /*  There is something wrong in the buffers  */

            _NFIdebug ((fname,
                "_NFFcat_attr_new_or_old = <0x%.8x>\n", status));
            FIfld_set_text (form, label, 0, 0, "", FALSE);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        if (new_attr == TRUE)
          {
            /*  This attribute WAS added during this command  */

            strcpy (column, "n_");
            catalog->command = CREATE;
          }
        else
          {
            /*  This attribute was added PREVIOUSLY  */

            strcpy (column, "new_n_");
          }
      }

    /*  Write the new data into the buffer  */

    switch (mcf_col)
      {
        case 0:
            strcat (column, "seqno");
            break;

        case 1:
            strcat (column, "name");
            break;

        case 2:
            strcat (column, "datatype");
            break;

        case 3:
            strcat (column, "synonym");
            break;
      }

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, column, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        FIfld_set_text (form, label, 0, 0, "", FALSE);
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) catalog->cat_attr->data_ptr;
    data_offset =
        (catalog->active_attribute * catalog->cat_attr->columns) + offset;

    /*  Get the text length  */

    if ((status = (long) FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Make sure that the length will hold an expanded date  */

    if (length < 11) length = 11;

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((status = (long) FIfld_get_text
        (form, label, 0, 0, length, text, &pos, &selected)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        if (text) free (text);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (mcf_col == 2)
      {
        /*  Make sure the user is only altering the length of 'char'
            datatypes if this is an NFM system attribute - Glenn 7/28/92  */

        if (catalog->command == CREATE)
          {
            if ((status = _NFFfind_column_offset (catalog->cat_attr,
               "n_application", &app_offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                catalog->command = save_command;
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            if ((strcmp
                (data_ptr[data_offset - offset + app_offset], "NFM")) == 0)
              {
                _NFIdebug ((fname, "it is an I/NFM attribute\n"));

                if ((strncmp (data_ptr[data_offset], "char", 4)) == 0)
                  {
                    /*  Check the new text  */

                    if ((strncmp (text, "char", 4)) != 0)
                      {
                        /*  They tried to alter the
                            datatype (not just the length)  */

                        _NFIdebug ((fname,
                            "user tried to alter the datatype\n"));
                        _NFIdebug ((fname,
                            "original = <%s>\n", data_ptr[data_offset]));
                        _NFIdebug ((fname, "new = <%s>\n", text));
                        if (text) free (text);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
                        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	                FIg_set_font( form, label, "7x13bold", 15 );
#endif
                        FIfld_set_text
                            (form, label, 0, 0, data_ptr[data_offset], FALSE);
                        catalog->command = save_command;
                        status = NFI_E_ALTER_DATATYPE;
                        ERRload_struct (NFI, status, NULL);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
                      }
                  }
              }
          }

        /*  Validate the datatype  */

        if ((status = _NFFvalidate_datatype (text, &size)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFvalidate_datatype = <0x%.8x>\n", status));
            if (text) free (text);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	    FIg_set_font( form, label, "7x13bold", 15 );
#endif
            FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
            catalog->command = save_command;
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  Modify the type and format string of the range fields  */

        if ((status = _NFFcat_set_range_attr (form, text)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFcat_set_range_attr = <0x%.8x>\n", status));
            if (text) free (text);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	    FIg_set_font( form, label, "7x13bold", 15 );
#endif
            FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
            catalog->command = save_command;
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

/* Making modification to check attribute names    - Jujare */
                                             
    if (mcf_col == 1)
      {
        if  (strncmp(text,"n_",2) == 0)
        {
          ERRload_struct (NFI, NFI_E_INVALID_ATTR_NAME, "%s", text);
         _NFIdebug ((fname, "Invalid NFM Catalog Name \n"));
         _NFIdebug ((fname, "Jujare ->The Catalog Name Starts with n_  <%s> \n", text));
          return(NFI_E_INVALID_ATTR_NAME);
        }
      }

    _NFIdebug ((fname,
        "writing <%s> into row %d, col %d in attribute buffer\n",
        text, catalog->active_attribute + 1, offset + 1));

    if ((status = MEMwrite_data (catalog->cat_attr,
        text, catalog->active_attribute + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        if (text) free (text);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (mcf_col == 1)
      {
        /*  Write the attribute name into the name column  */

        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, "n_name", &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            if (text) free (text);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	    FIg_set_font( form, label, "7x13bold", 15 );
#endif
            FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
            catalog->command = save_command;
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        _NFIdebug ((fname,
            "writing <%s> into row %d, col %d in attribute buffer\n",
            text, catalog->active_attribute + 1, offset + 1));

        if ((status = MEMwrite_data (catalog->cat_attr,
            text, catalog->active_attribute + 1, offset + 1)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            if (text) free (text);
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	    FIg_set_font( form, label, "7x13bold", 15 );
#endif
            FIfld_set_text (form, label, 0, 0, data_ptr[data_offset], FALSE);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
            catalog->command = save_command;
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    /*  Put the new data in the ATTRIBUTES_MCF  */

 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, ATTRIBUTES_MCF, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, ATTRIBUTES_MCF,
        catalog->active_attribute, mcf_col, text, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        if (text) free (text);
        FIfld_set_text (form, ATTRIBUTES_MCF,
            catalog->active_attribute, mcf_col, data_ptr[data_offset], FALSE);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        catalog->command = save_command;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (text) free (text);
    catalog->command = save_command;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_default_field (form, label, catalog)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  {
    auto    int     length;
    auto    int     pos, selected;
    auto    long    status;
    auto    char    *text;
    static  char    *fname = "_NFFcat_default_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Get the text length  */

    if ((status = (long) FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((status = (long) FIfld_get_text
        (form, label, 0, 0, length, text, &pos, &selected)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "writing <%s> into row 1, col %d in data buffer\n",
        text, catalog->active_attribute + 1));

    if ((status = MEMwrite_data (catalog->cat_data,
        text, 1, catalog->active_attribute + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (text) free (text);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_get_characteristics (form, label, column, catalog)
  Form          form;
  int           label;
  char          *column;
  NFFcatalog    catalog;
  {
    auto    int     state;
    auto    long    status;
    auto    char    flag[2];
    auto    char    col_name[20];
    auto    char    **data;
    auto    short   buffer_offset;
    auto    short   offset;
    auto    short   new_attr;
    static  char    *fname = "_NFFcat_get_characteristics";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "column = <%s>\n", column));

    /*  Find the attribute name  */

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, "n_name", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data = (char **) catalog->cat_attr->data_ptr;

    /*  Find out which way the toggle is set  */

    if ((status = (long) FIg_get_state
        (form, label, &state)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }    

    /*  See if this is a deletable NFM attribute  */
/*
    if (catalog->command == CREATE)
        strcpy (col_name, "n_delete");
    else
        strcpy (col_name, "new_n_delete");

    if (((strcmp (column, col_name)) == 0) &&
        (state == 1) && (catalog->user_defined == FALSE))
      {
        _NFIdebug ((fname, "This NFM attribute is not deletable\n"));
        FIg_set_state_off (form, label);
        ERRload_struct (NFI, NFI_I_NOT_DELETABLE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_NOT_DELETABLE);
      }
*/
    /*  See if this is an NFM attribute that is allowed NULL values  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_null");
    else
        strcpy (col_name, "new_n_null");

    buffer_offset = catalog->active_attribute * catalog->cat_attr->columns;

    if (((strcmp (column, col_name)) == 0) && (state == 1) &&
        (((strcmp (data[buffer_offset + offset], "n_itemname")) == 0) ||
        ((strcmp (data[buffer_offset + offset], "n_itemrev")) == 0)))
      {
        _NFIdebug ((fname, "This NFM attribute is not allowed NULL values\n"));
        FIg_set_state_off (form, label);
        ERRload_struct (NFI, NFI_I_NO_NULLS, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_NO_NULLS);
      }

    /*  See if the attribute is deletable  */

    if (catalog->command == CREATE)
        strcpy (col_name, "n_delete");
    else
        strcpy (col_name, "new_n_delete");

    if ((strcmp (column, col_name)) == 0)
      {
        if (catalog->user_defined == TRUE)
          {
            /*  See if this is a user-defined attribute
                added during THIS invocation of the command  */

            if ((status = _NFFcat_attr_new_or_old (catalog,
                catalog->active_attribute, &new_attr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_attr_new_or_old = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            /*  Check the toggle  */

            if ((state == 1) && (new_attr == TRUE))
              {
                /*  Enable the user-defined attributes delete button  */

                if ((status = (long) FIg_enable
                    (form, DELETE_USER_DEFINED)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FIg_enable = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIg_enable", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }
            else
              {
                /*  Disable the user-defined attributes delete button  */

                if ((status = (long) FIg_disable
                    (form, DELETE_USER_DEFINED)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }
          }
        else
          {
            /*  It is an NFM attribute  */

            if ((status = (long) FIg_disable
                (form, DELETE_USER_DEFINED)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
      }

    if (state == 1)
        strcpy (flag, "Y");
    else
        strcpy (flag, "N");

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, column, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "writing <%s> into row %d, col %d in data buffer\n",
        flag, catalog->active_attribute + 1, offset + 1));

    if ((status = MEMwrite_data (catalog->cat_attr,
        flag, catalog->active_attribute + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_rollthru_fields (form, label, row, column, catalog)
  Form          form;
  int           label;
  int           row;
  char          *column;
  NFFcatalog    catalog;
  {
    int     i, length;
    int     pos, selected;
    long    status;
    char    *text, *ptr;
    char    flag[2];
    short   offset;
    short   keep_checking;

    static  char *fname = "_NFFcat_rollthru_fields";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "row = <0x%.8x>\n", row));
    _NFIdebug ((fname, "column = <%s>\n", column));

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, column, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Get the text out of the rollthru field  */

    if ((status = (long) FIfld_get_text_length
        (form, label, row, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((status = (long) FIfld_get_text
        (form, label, row, 0, length, text, &pos, &selected)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Skip any white space, and convert to lower-case  */

    ptr = text;
    for (i = 0, keep_checking = TRUE; i < strlen (text); ++i)
      {
        if ((isspace (text[i])) && (keep_checking == TRUE))
          {
            /*  Increment the pointer over the white space  */

            ptr += sizeof (char);
          }
        else
          {
            /*  Convert text to lower-case  */

            text[i] = tolower (text[i]);
            keep_checking = FALSE;
          }
      }

    /*  Find out what value to write in the buffer  */

    _NFIdebug ((fname, "text = <%s>\n", ptr));

    if ((strcmp (ptr, "do not display")) == 0)
        strcpy (flag, "N");
    else if ((strcmp (ptr, "display only")) == 0)
        strcpy (flag, "Y");
    else
        strcpy (flag, "U");

    if (text) free (text);

    _NFIdebug ((fname, "writing <%s> into row %d, col %d in data buffer\n",
        flag, catalog->active_attribute + 1, offset + 1));

    if ((status = MEMwrite_data (catalog->cat_attr,
        flag, catalog->active_attribute + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_min_field (form, label, catalog)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  {
    long    status;

    static  char *fname = "_NFFcat_min_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = _NFFcat_build_value_buffer (form, label,
        "n_valueno", "n_minvalue", "NFM_RANGE", catalog)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_build_value_buffer = <0x%.8x>\n", status));
 /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, "", FALSE);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Blank out the validation list  */

    if ((status = (long) FIfld_set_num_rows
        (form, VALIDATE_LIST_FIELD, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    catalog->range_exists = TRUE;
    catalog->list_exists = FALSE;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_max_field (form, label, catalog)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  {
    long    status;

    static  char *fname = "_NFFcat_max_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = _NFFcat_build_value_buffer (form, label,
        "n_valueno", "n_maxvalue", "NFM_RANGE", catalog)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_build_value_buffer = <0x%.8x>\n", status));
        FIfld_set_text (form, label, 0, 0, "", FALSE);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Blank out the validation list  */

    if ((status = (long) FIfld_set_num_rows
        (form, VALIDATE_LIST_FIELD, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    catalog->range_exists = TRUE;
    catalog->list_exists = FALSE;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_list_field (form, label, catalog)
  Form          form;
  int           label;
  NFFcatalog    catalog;
  {
    long    status;

    static  char *fname = "_NFFcat_list_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = _NFFcat_build_value_buffer (form, label,
        "n_valueno", "n_value", "NFM_STATIC", catalog)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_build_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Blank out the range fields  */

    if ((status = FIfld_set_text (form,
        INFO_MIN_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIfld_set_text (form,
        INFO_MAX_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    catalog->list_exists = TRUE;
    catalog->range_exists = FALSE;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_validate_accept (catalog)
  NFFcatalog    catalog;
  {
    int     i;
    int     total_fields;
    int     column;
    int     columns;
    long    status;
    char    *attrname;
    char    **data_ptr;
    char    **attr_ptr;
    short   nfm_offset;
    short   write_offset;
    short   null_offset;

    static  char *fname = "_NFFcat_validate_accept";

    _NFIdebug ((fname,
        "loc->data_list->rows = <%d>\n", (catalog->loc->data_list)->rows));

    /*  See if there is any data at all  */

    if ((catalog->loc->data_list)->rows == 0)
      {
        catalog->done = FALSE;
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    if ((status = MEMbuild_array (catalog->loc->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    data_ptr = (char **) (catalog->loc->data_list)->data_ptr;
    attr_ptr = (char **) (catalog->loc->attr_list)->data_ptr;

    /*  Assume that we are finished  */

    catalog->done = TRUE;

    /*  Make sure that there is data for all non-NULL attributes  */

    if ((status = _NFFfind_column_offset
        (catalog->loc->attr_list, "n_name", &nfm_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->done = FALSE;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (catalog->loc->attr_list, "n_write", &write_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->done = FALSE;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (catalog->loc->attr_list, "n_null", &null_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        catalog->done = FALSE;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    column = 0;
    columns = (catalog->loc->attr_list)->columns;
    total_fields = (catalog->loc->attr_list)->rows * columns;
    for (i = 0; i < total_fields; i += columns, ++column)
      {
        /*  Pull out the catalog name  */
/*
        if ((strcmp (attr_ptr[i + nfm_offset], "n_catalogname")) == 0)
          {
            _NFIdebug ((fname, "catalog_name = <%s>\n", data_ptr[column]));
            _NFFmain_set_catalog (data_ptr[column]);
          }
*/
        /*  See if this attribute can be written to  */

        if ((strcmp (attr_ptr[i + write_offset], "Y")) != 0)
          {
            /*  Don't validate  */

            continue;
          }

        /*  See if this attribute can have NULL values  */

        if ((strcmp (attr_ptr[i + null_offset], "Y")) != 0)
          {
            /*  See if this attribute has a value  */

            if ((strcmp (data_ptr[column], "")) == 0)
              {
                /*  Find the attribute name (or synonym if it exists)  */

                _NFFfind_attribute_name
                    (catalog->loc->attr_list, i, &attrname);
                ERRload_struct (NFI, NFI_W_MORE_DATA, "%s", attrname);

                catalog->done = FALSE;

                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_W_MORE_DATA);
              }
          }
      }

    if (catalog->cat_attr != NULL)
      {
        /*  Scan for any single tics (') in the buffers  */

        if ((status = NFMtic_it (catalog->cat_attr)) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMtic_it = <0x%.8x>\n", status));
          }

        if ((status = NFMtic_it (catalog->cat_data)) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMtic_it = <0x%.8x>\n", status));
          }
      }

    if ((status = NFMtic_it (catalog->loc->data_list)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMtic_it = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_attr_new_or_old (catalog, attribute, new_attr)
  NFFcatalog    catalog;
  int           attribute;
  short         *new_attr;
  {
    int     data_offset;
    char    **data_ptr;
    long    status;
    short   offset;

    static  char *fname = "_NFFcat_attr_new_or_old";

    _NFIdebug ((fname, "entering ...\n"));

    if (catalog->command == CREATE)
      {
        _NFIdebug ((fname, "it is a CREATE command\n"));
        *new_attr = TRUE;
        _NFIdebug ((fname, "new_attr = <%d>\n", *new_attr));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  See if this attribute was added
        during THIS invocation of the command  */

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, "new_n_read", &offset)) != NFI_S_SUCCESS)
      {
        /*  There is something wrong in the buffers  */

        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) catalog->cat_attr->data_ptr;
    data_offset = (attribute * catalog->cat_attr->columns) + offset;

    if ((strcmp (data_ptr[data_offset], "")) == 0)
      {
        /*  This attribute WAS added during this command  */

        *new_attr = TRUE;
      }
    else
      {
        /*  This attribute was added PREVIOUSLY  */

        _NFIdebug ((fname, "new read flag = <%s>\n", data_ptr[data_offset]));
        *new_attr = FALSE;
      }

    _NFIdebug ((fname, "new_attr = <%d>\n", *new_attr));

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFfree_catalog (catalog, form)
  NFFcatalog    catalog;
  Form          *form;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    MEMclose (&(catalog->cat_attr));
    MEMclose (&(catalog->cat_data));
    MEMclose (&(catalog->cat_value));
    MEMclose (&(catalog->cat_appl));

    _NFFfree_add (catalog->loc, NULL);

    if (catalog) free (catalog);

    return;
  }
