#include "machine.h"
/*  QUI - Query User Interface  */

#include "QUI.h"

/*  Global structure  */

struct QUIglobal_st QUIglobal;

long QUIinit_form (catalog, form_title, query_title, active_query,
                   config_mask, font_info, color_info, attribute_source,
                   application, username, notify_routine,
                   field_form, field_label, field_ptr, query_form)
  char   *catalog;             /*  i - Active catalog to define query on  */
  char   *form_title;          /*  i - "Define Search Criteria", etc.     */
  char   *query_title;         /*  i - "Criteria Name", etc.              */
  char   *active_query;        /*  i - Name of active query or ""         */
  long   config_mask;          /*  i - Settings to determine which
                                       gadgets to display                 */
  QFONT  *font_info;           /*  i - Names and body sizes of fonts      */
  QCOLOR *color_info;          /*  i - On and off colors of gadgets       */
  short  attribute_source;     /*  i - Where to get attributes from,
                                       either QFILE or QDB                */
  char   *application;         /*  i - Application defining the query     */
  char   *username;            /*  i - User defining the query            */
  void   (*notify_routine)();  /*  i - Notification routine to call       */
  Form   field_form;           /*  i - I/Forms form pointer where
                                       defined query name will be placed  */
  int    field_label;          /*  i - I/Forms field gadget label where
                                       defined query name will be placed  */
  char   *field_ptr;           /*  o - Output string where defined
                                       query name will be copied into     */
  Form   *query_form;          /*  o - I/Forms form pointer for display   */
  {
    auto    int     i, status;
    auto    int     xpos, ypos;
    auto    int     num_chars;
    static  short   first_time = TRUE;
    static  char    *fname = "QUIinit_form";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Shut the compiler up; most of these arguments are not
        needed anymore because DMANDS is not using this code  */

    catalog = catalog;
    form_title = form_title;
    query_title = query_title;
    active_query = active_query;
    config_mask = config_mask;
    font_info = font_info;
    color_info = color_info;
    attribute_source = attribute_source;
    application = application;
    username = username;
    notify_routine = notify_routine;
    field_form = field_form;
    field_label = field_label;
    field_ptr = field_ptr;
    query_form = query_form;

    /*  If this is the first time, initialize the message file  */

    if (first_time == TRUE)
      {
        first_time = FALSE;

        if ((status = (long) UMSInitMsg
            (QUI_MESSAGE_FILE, UMS_INDEX)) != UMS_S_SUCCESS)
          {
            _NFIdebug ((fname, "UMSInitMsg = <0x%.8x>\n", status));
            first_time = TRUE;
          }
      }

    /*  Initialize the global buffers  */

    QUIglobal.catalogs = NULL;
    for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
      {
        QUIglobal.attributes[i] = NULL;
        QUIglobal.values[i] = NULL;
        QUIglobal.from_array[i][0] = -1;
        QUIglobal.from_array[i][1] = -1;
      }

    /*  Save the appropriate input arguments  */

    QUIglobal.attribute_source = (char) attribute_source;
    QUIglobal.use_lu_table_form =
        (char) (config_mask & USE_LU_TABLE_FORM_MASK);
    QUIglobal.bezel_message_style =
        (char) (config_mask & BEZEL_MESSAGE_STYLE_MASK);

    strncpy (QUIglobal.username, username, sizeof (QUIglobal.username) - 1);
    strncpy (QUIglobal.query_name,
        active_query, sizeof (QUIglobal.query_name) - 1);
    QUIglobal.field_form = field_form;
    QUIglobal.field_label = field_label;
    QUIglobal.field_ptr = field_ptr;

    /*  Load in the form from the file  */

    if ((status = FIf_new (QUI_FORM_LABEL,
        QUI_FORM, notify_routine, query_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, QUI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_FORM));
        return (QUI_E_FORM);
      }

    /*  Initialize all structures, etc.  */

    QUI_initialize_gadgets (*query_form);

    /*  Set the name, font, and color of the query title, field and desc  */

    FIg_set_text (*query_form, QUERY_TITLE, query_title);

    if (config_mask & OWNER_TOGGLE_MASK)
      {
        /*  See if the toggle needs to be moved over  */

        if ((config_mask & USE_CATALOG_FIELD_MASK) == 0)
          {
            FIg_get_location (*query_form, OWNER_TITLE, &xpos, &ypos);
            FIg_set_location (*query_form, OWNER_TITLE, xpos + 20, ypos);
            FIg_get_location (*query_form, OWNER_TOGGLE, &xpos, &ypos);
            FIg_set_location (*query_form, OWNER_TOGGLE, xpos + 20, ypos);
          }

        FIg_display (*query_form, OWNER_TITLE);
        FIg_display (*query_form, OWNER_TOGGLE);
        FIg_set_on_color (*query_form, OWNER_TOGGLE, color_info->checkin_on);
        FIg_set_off_color (*query_form, OWNER_TOGGLE, color_info->checkin_off);
      }
    else
      {
        /*  Erase the owner title and toggle  */

        FIg_erase (*query_form, OWNER_TITLE);
        FIg_erase (*query_form, OWNER_TOGGLE);

        /*  We have more room for the description now  */

        FIfld_get_num_vis_chars (*query_form, DESC_FIELD, 0, &num_chars);
        FIfld_set_num_vis_chars (*query_form, DESC_FIELD, 0, num_chars + 12);
        FIg_display (*query_form, DESC_FIELD);
      }

	/*  Center the form and display it  */

    _QUIcenter_form (*query_form, -1, -1);
    FIf_display (*query_form);
/*
    FIf_save (*query_form, "NFMquiform");
*/
    /*  Get the list of all defined queries for this user  */

    QUIform_message (*query_form, QUI_I_GET_QUERIES, NULL);
    if ((status = _QUIget_queries (*query_form, username)) != QUI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_QUIget_queries = <0x%.8x>\n", status));
        FIf_delete (*query_form);
        *query_form = NULL;
        QUIfree_structs ();
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    /*  Get the catalogs for this application  */

    if ((strcmp (catalog, "")) == 0)
        QUIform_message (*query_form, QUI_I_GET_CATALOGS, NULL);

    if ((status = _QUIload_catalogs
        (*query_form, catalog, application)) != QUI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_QUIload_catalogs = <0x%.8x>\n", status));
        FIf_delete (*query_form);
        *query_form = NULL;
        QUIfree_structs ();
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    FIfld_set_text (*query_form, QUERY_FIELD, 0, 0, active_query, FALSE);

    /*  If there is an active query, retrieve it  */

    if ((strcmp (active_query, "")) != 0)
      {
        if ((status = _QUIquery_field
            (*query_form, QUERY_FIELD)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_QUIquery_field = <0x%.8x>\n", status));
            FIf_delete (*query_form);
            *query_form = NULL;
            QUIfree_structs ();
            _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
            return (status);
          }
      }
    else
      {
        /*  Get the attributes for the catalog  */

        if ((status = QUIget_attributes ((short) 0)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname, "QUIget_attributes = <0x%.8x>\n", status));
            FIf_delete (*query_form);
            *query_form = NULL;
            QUIfree_structs ();
            _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
            return (status);
          }

        if ((status = _QUIload_catalog_attributes
            (*query_form, ATTRIBUTE_FIELD1, (short) 0)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_QUIload_catalog_attributes = <0x%.8x>\n", status));
            FIf_delete (*query_form);
            *query_form = NULL;
            QUIfree_structs ();
            _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
            return (status);
          }
      }

    QUIerase_message (*query_form);
/*  Initializing attribute info of query form -	 MVR 30/03/94 */
    QUIset_values(*query_form,0.0);
    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long _QUInotify (int g_label, double value, Form *form)
  {
    auto    long   status = QUI_S_SUCCESS;
    static  char   *fname = "_QUInotify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));
    _NFIdebug ((fname, "value = <%f>\n", value));

    /*  Erase any previous messages  */

    QUIerase_message (*form);

    /*  Reset the error structure  */

    ERRreset_struct ();

    switch (g_label)
      {
        case FI_HELP:

            /*  This is hard-coded for now  */

              _NFFhelp_topic("NFDfSrCr");
            /*if (status = Help_topic ("NFDfSrCr"))
              {
                _NFIdebug ((fname, "Help_topic = <%d>\n", status));
                ERRload_struct (NFI, QUI_E_HELP, "%s%d", "Help_topic", status);
                status = QUI_E_HELP;
              } */

            break;

        case FI_CANCEL:
            FIf_delete (*form);
            *form = NULL;
            QUIfree_structs ();
            status = QUI_W_COMMAND_CANCELLED;
            ERRload_struct (NFI, status, NULL);
            break;

        case FI_EXECUTE:
        case FI_ACCEPT:

            if ((status = QUIsave_definition (*form)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUIsave_definition = <0x%.8x>\n", status));
                FIg_reset (*form, g_label);
                break;
              }

            if (g_label == FI_ACCEPT)
              {
                /*  We're done with the form  */

                FIf_delete (*form);
                *form = NULL;
                QUIfree_structs ();
              }
            else
              {
                /*  Get new listing of defined queries  */

               _NFIdebug((fname,"Username = <%s>\n", QUIglobal.username));
               if ((status = _QUIget_queries
                   (*form, QUIglobal.username)) != QUI_S_SUCCESS)
                 {
                   _NFIdebug((fname,"_QUIget_queries = <0x%.8x>\n", status));
                   FIg_reset (*form, g_label);
                   break;
                 }
              }

            /*  Place the defined query name in the specified field  */

            if (QUIglobal.field_form != NULL)
              {
                FIfld_set_text (QUIglobal.field_form,
                    QUIglobal.field_label, 0, 0, QUIglobal.query_name, FALSE);
                strcpy (QUIglobal.field_ptr, QUIglobal.query_name);
              }

            break;

        case ORDER_BUTTON:
            if ((status = QUI_order_button(*form,g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_order_button = <0x%.8x>\n", status));
              }

            break;

        case BACKGROUND_LIST_SYM1:
        case BACKGROUND_LIST_SYM2:
        case BACKGROUND_LIST_SYM3:
        case BACKGROUND_LIST_SYM4:
        case BACKGROUND_LIST_SYM5:
        case BACKGROUND_LIST_SYM6:
        case BACKGROUND_LIST_SYM7:
        case BACKGROUND_LIST_SYM8:
        case ASSOC_LIST_SYM1:
        case ASSOC_LIST_SYM2:
        case ASSOC_LIST_SYM3:
        case ASSOC_LIST_SYM4:
        case ASSOC_LIST_SYM5:
        case ASSOC_LIST_SYM6:
        case ASSOC_LIST_SYM7:
        case ASSOC_LIST_SYM8:
        case BORDER_LIST_SYM1:
        case BORDER_LIST_SYM2:
        case BORDER_LIST_SYM3:
        case BORDER_LIST_SYM4:
        case BORDER_LIST_SYM5:
        case BORDER_LIST_SYM6:
        case BORDER_LIST_SYM7:
        case BORDER_LIST_SYM8:
            _NFIdebug ((fname, "symbol was selected\n"));
            break;

        case QUERY_FIELD:
            if ((status = _QUIquery_field (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "_QUIquery_field = <0x%.8x>\n", status));
              }

            break;

        case DESC_FIELD:
             break;
        case DELETE_QUERY_BUTTON:
             break;
        case BROWSE_BUTTON:
             break;
        case DELETE_ROW_BUTTON:
            if ((status = QUI_delete_row (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_delete_row = <0x%.8x>\n", status));
              }

            break;

        case CLEAR_BUTTON:
            if ((status = QUI_clear_values (*form)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_clear_values = <0x%.8x>\n", status));
              }

            break;

        case REVISION_TOGGLE:
            break;
        case CHECKIN_TOGGLE:
            break;
        case OWNER_TOGGLE:
            break;

        case SCROLL_BAR:
            if ((status = QUIset_values (*form, value)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUIset_values = <0x%.8x>\n", status));
              }

            break;

        case CHECKBOX1:
        case CHECKBOX2:
        case CHECKBOX3:
        case CHECKBOX4:
        case CHECKBOX5:
        case CHECKBOX6:
        case CHECKBOX7:
        case CHECKBOX8:
            if ((status = QUIcheckbox (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_and_or = <0x%.8x>\n", status));
              }

            break;

        case AND_OR_TOGGLE1:
        case AND_OR_TOGGLE2:
        case AND_OR_TOGGLE3:
        case AND_OR_TOGGLE4:
        case AND_OR_TOGGLE5:
        case AND_OR_TOGGLE6:
        case AND_OR_TOGGLE7:
            if ((status = QUI_and_or (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_and_or = <0x%.8x>\n", status));
              }

            break;

        case CATALOG_FIELD1:
        case CATALOG_FIELD2:
        case CATALOG_FIELD3:
        case CATALOG_FIELD4:
        case CATALOG_FIELD5:
        case CATALOG_FIELD6:
        case CATALOG_FIELD7:
        case CATALOG_FIELD8:
            if ((status = QUI_catalog (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_catalog = <0x%.8x>\n", status));
              }

            break;

        case ATTRIBUTE_FIELD1:
        case ATTRIBUTE_FIELD2:
        case ATTRIBUTE_FIELD3:
        case ATTRIBUTE_FIELD4:
        case ATTRIBUTE_FIELD5:
        case ATTRIBUTE_FIELD6:
        case ATTRIBUTE_FIELD7:
        case ATTRIBUTE_FIELD8:
            if ((status = QUIattribute (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUIattribute = <0x%.8x>\n", status));
              }

            break;

        case OPERATOR_FIELD1:
        case OPERATOR_FIELD2:
        case OPERATOR_FIELD3:
        case OPERATOR_FIELD4:
        case OPERATOR_FIELD5:
        case OPERATOR_FIELD6:
        case OPERATOR_FIELD7:
        case OPERATOR_FIELD8:
            if ((status = QUI_operator (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_operator = <0x%.8x>\n", status));
              }

            break;

        case VALUE_FIELD1:
        case VALUE_FIELD2:
        case VALUE_FIELD3:
        case VALUE_FIELD4:
        case VALUE_FIELD5:
        case VALUE_FIELD6:
        case VALUE_FIELD7:
        case VALUE_FIELD8:
            if ((status = QUI_value (*form, g_label)) != QUI_S_SUCCESS)
              {
                _NFIdebug ((fname, "QUI_value = <0x%.8x>\n", status));
              }

            break;

        case LEFT_SCROLL_BUTTON:
        case RIGHT_SCROLL_BUTTON:
        case BEZEL_MESSAGE_STRIP:
        case BEZEL_MESSAGE_TEXT:
        case PROMPT_FIELD:
        case ERROR_FIELD:
            break;
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>...\n\n", status));
    return (status);
  }
