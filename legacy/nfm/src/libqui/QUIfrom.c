#include "machine.h"
#include "QUI.h"

long _QUIparse_from_clause (from_clause)
  char    *from_clause;
  {
    auto    int     i, j, row;
    auto    int     text_pos;
    auto    int     letter_pos;
    auto    int     last_one = 0;
    auto    int     old_alias;
    auto    long    status;
    auto    char    **data;
    auto    char    text[10];
    auto    char    *token = NULL;
    auto    char    alias[10];
    auto    char    used[QUI_MAX_ATTR_NUM][10];
    auto    char    catalog[NFM_CATALOGNAME + 1];
    static  char    aliases[26] = "abcdefghijklmnopqrstuvwxyz";
    static  char    *fname = "_QUIparse_from_clause";

    _NFIdebug ((fname, "from_clause = <%s>\n", from_clause));

    data = (char **) QUIglobal.catalogs->data_ptr;
    token = (char *) strtok (from_clause, " ");
    while (token)
      {
        strcpy (catalog, token);
        _NFIdebug ((fname, "catalog = <%s>\n", catalog));

        token = (char *) strtok (NULL, " ,");
        if (token)
          {
            strcpy (alias, token);
            _NFIdebug ((fname, "alias = <%s>\n", alias));

            /*  Save the alias for comparison later  */

            strcpy (used[last_one++], alias);
          }
        else
          {
            /*  We're at the end of the string  */

            continue;
          }

        if ((strncmp (alias, "f_", 2)) == 0)
          {
            /*  This is a file catalog alias  */

            token = (char *) strtok (NULL, " ");
            continue;
          }

        /*  Find this catalog in the buffer  */

        for (i = 0, row = -1; i < QUIglobal.catalogs->rows; ++i)
          {
            if ((strcmp (data[i * 2], catalog)) == 0)
              {
                row = i;
                break;
              }
          }

        if (row == -1)
          {
            /*  We've got problems; the catalog specified
                in the saved query doesn't exist anymore!!!  */

            _NFIdebug ((fname,
                "catalog <%s> does not exist anymore!!!\n", catalog));
            ERRload_struct (NFI, QUI_E_CATALOG_EXIST, "%s", catalog);
            _NFIdebug ((fname,
                "returning FAILURE <0x%.8x>\n", QUI_E_CATALOG_EXIST));
            return (QUI_E_CATALOG_EXIST);
          }

        /*  Override the application field with alias information  */

        if ((status = MEMwrite_data
            (QUIglobal.catalogs, alias, i + 1, 2)) != MEM_S_SUCCESS)
        if (status != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            ERRload_struct (NFI,
                QUI_E_MEM, "%s%x", "MEMwrite_data", status);
            MEMclose (&QUIglobal.catalogs);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }

        token = (char *) strtok (NULL, " ");
      }

    /*  Generate new aliases for the other catalogs  */

    for (i = 0; i < QUIglobal.catalogs->rows; ++i)
      {
        if ((strcmp (data[(i * 2) + 1], "")) != 0)
          {
            /*  This catalog has an old alias  */

            continue;
          }

        old_alias = FALSE;
        while (old_alias == FALSE)
          {
            /*  Generate an alias for this catalog  */

            text_pos = 0;
            letter_pos = i;
            do
              {
                text[text_pos++] = aliases[letter_pos % strlen (aliases)];
                letter_pos -= strlen (aliases);
              } while (letter_pos >= 0);

            text[text_pos] = NULL;

            /*  Check to see if this alias has already been used  */

            old_alias = TRUE;
            for (j = 0; j < last_one; ++j)
              {
                if ((strcmp (used[j], text)) == 0)
                  {
                    /*  This one has been used; try again  */

                    old_alias = FALSE;
                    break;
                  }
              }
          }

        if ((status = MEMwrite_data
            (QUIglobal.catalogs, text, i + 1, 2)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            ERRload_struct (NFI,
                QUI_E_MEM, "%s%x", "MEMwrite_data", status);
            MEMclose (&QUIglobal.catalogs);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("catalogs",
            QUIglobal.catalogs, _NFMdebug_st.NFIdebug_file);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIsave_from_data (catalog_no, attrib_no)
  short    catalog_no;
  short    attrib_no;
  {
    auto    int    i;
    auto    char   **data;
    auto    short  found = FALSE;
    auto    short  array_column = 0;
    static  char   *fname = "QUIsave_from_data";

    _NFIdebug ((fname, "catalog_no = <%d>\n", catalog_no));
    _NFIdebug ((fname, "attrib_no = <%d>\n", attrib_no));

    if (catalog_no > QUIglobal.catalogs->rows)
      {
        _NFIdebug ((fname, "catalog was not found in the buffer\n"));
        ERRload_struct (NFI, QUI_E_BUFFER, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
      }

    /*  Make sure we're not past the end of the buffer  */

    if (attrib_no >= QUIglobal.attributes[catalog_no]->rows)
      {
        _NFIdebug ((fname, "attribute is outside of buffer range <%d>\n",
            QUIglobal.attributes[catalog_no]->rows));
        ERRload_struct (NFI, QUI_E_BUFFER, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
      }

    /*  See if this is a catalog or f_catalog attribute  */

    data = (char **) QUIglobal.attributes[catalog_no]->data_ptr;

    if ((strncmp (data[(attrib_no * 4) + 3], "f_", 2)) == 0)
      {
        _NFIdebug ((fname, "this is a file catalog attribute\n"));
        array_column = 1;
      }

    /*  Scan the FROM array to see if this catalog exists already  */

    for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
      {
        if (QUIglobal.from_array[i][array_column] == catalog_no)
          {
            _NFIdebug ((fname, "found catalog_no in slot #%d\n", i));
            found = TRUE;
            break;
          }
      }

    if (found == FALSE)
      {
        /*  Put this catalog_no (or f_catalog_no) in the array  */

        for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
          {
            if (QUIglobal.from_array[i][array_column] == -1)
              {
                QUIglobal.from_array[i][array_column] = catalog_no;
                _NFIdebug ((fname,
                    "put catalog_no in slot [%d][%d]\n", i, array_column));
                break;
              }
          }
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIbuild_from_clause (from_clause, where_clause)
  char    *from_clause;
  char    **where_clause;
  {
    auto    int     i;
    auto    char    name[NFM_CATALOGNAME + 1];
    auto    char    alias[10];
    auto    char    join_clause[80];
    static  char    *fname = "QUIbuild_from_clause";

    _NFIdebug ((fname, "where_clause = <%s>\n", *where_clause));

    /*  Initialize the FROM clause  */

    strcpy (from_clause, "");

    /*  Get the catalogs first  */

    for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
      {
        if (QUIglobal.from_array[i][0] == -1)
          {
            _NFIdebug ((fname, "end of FROM array entries for catalogs\n"));
            break;
          }

        QUIget_catalog_from_number (QUIglobal.from_array[i][0], name);

        if ((strcmp (from_clause, "")) != 0)
            strcat (from_clause, ", ");
        strcat (from_clause, name);
        QUIget_alias_from_number
            (QUIglobal.from_array[i][0], (short) -1, alias);
        strcat (from_clause, " ");
        strcat (from_clause, alias);
      }

    /*  Get the f_catalogs next  */

    for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
      {
        if (QUIglobal.from_array[i][1] == -1)
          {
            _NFIdebug ((fname, "end of FROM array entries for f_catalogs\n"));
            break;
          }

        QUIget_catalog_from_number (QUIglobal.from_array[i][1], name);

        if ((strcmp (from_clause, "")) != 0)
            strcat (from_clause, ", ");
        strcat (from_clause, "f_");
        strcat (from_clause, name);
        QUIget_alias_from_number
            (QUIglobal.from_array[i][1], (short) -1, alias);
        strcat (from_clause, " f_");
        strcat (from_clause, alias);
      }

    /*  Initialize the join clause  */

    strcpy (join_clause, "");

    /*  Build the join clause  */

    for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
      {
        if ((QUIglobal.from_array[i][0] == -1) &&
            (QUIglobal.from_array[i][1] == -1))
            break;
/*
        else if (QUIglobal.from_array[i][0] == -1)
            continue;
        else if (QUIglobal.from_array[i][1] == -1)
            continue;
*/
        if (QUIglobal.from_array[i][0] == QUIglobal.from_array[i][1])
          {
            /*  Join the catalog with the f_catalog  */

            QUIget_alias_from_number
                (QUIglobal.from_array[i][0], (short) -1, alias);

            strcat (join_clause, " AND (");
            strcat (join_clause, alias);
            strcat (join_clause, ".n_itemno = f_");
            strcat (join_clause, alias);
            strcat (join_clause, ".n_itemnum)");
          }
      }

    if (strlen (*where_clause) <
       (strlen (*where_clause) + strlen (join_clause)))
      {
        *where_clause = (char *) realloc
            (*where_clause, strlen (*where_clause) + strlen (join_clause) + 1);
      }

    strcat (*where_clause, join_clause);

    /*  Reinitialize the FROM array  */

    for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
      {
        QUIglobal.from_array[i][0] = -1;
        QUIglobal.from_array[i][1] = -1;
      }

    _NFIdebug ((fname, "from_clause = <%s>\n", from_clause));
    _NFIdebug ((fname, "where_clause = <%s>\n", *where_clause));

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
