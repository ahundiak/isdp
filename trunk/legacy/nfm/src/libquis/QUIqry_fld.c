#include "machine.h"
#include "QUI.h"

long _QUIquery_field (form, label)
  Form    form;
  int     label;
  {
    auto    int     i, num_rows;
    auto    int     sel, rpos;
    auto    long    status;
    auto    char    text[NFM_REPORTNAME + 1];
    auto    short   load_query = FALSE;
    static  char    *fname = "_QUIquery_field";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Get the text out of the name field  */

    FIfld_get_text (form, label, 0, 0,
        sizeof (QUIglobal.query_name) - 1, QUIglobal.query_name, &sel, &rpos);

    /*  Make sure there is no white-space in the name  */

    for (i = 0; i < strlen (QUIglobal.query_name); ++i)
      {
        if (isspace (QUIglobal.query_name[i]))
            QUIglobal.query_name[i] = '_';
      }

    FIfld_set_text (form, label, 0, 0, QUIglobal.query_name, FALSE);

    _NFIdebug ((fname, "query_name = <%s>\n", QUIglobal.query_name));

    /*  Scan the associated list to determine
        if this is a new definition or not  */

    FIfld_get_list_num_rows (form, label, 0, &num_rows);
    for (i = 0; i < num_rows; ++i)
      {
        FIfld_get_list_text (form, label, i, 0, NFM_REPORTNAME, text, &sel);
        if ((strcmp (QUIglobal.query_name, text)) == 0)
          {
            /*  The user wants to load a predefined query  */

            FIfld_set_list_select (form, label, i, 0, TRUE);
            load_query = TRUE;
            break;
          }
      }

    if (load_query == TRUE)
      {
        /*  Get the predefined query from NFM and load it  */

        _NFIdebug ((fname, "loading a predefined query ...\n"));

        if ((status = _QUIload_query (form)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_QUIload_query = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
      }
    else
      {
        /*  This is a new definition; deselect all rows in the list  */

        _NFIdebug ((fname, "new query definition ...\n"));

        for (i = 0; i < num_rows; ++i)
            FIfld_set_list_select (form, label, i, 0, FALSE);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
