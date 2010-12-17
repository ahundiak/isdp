#include "machine.h"
#include "QUI.h"

long QUIget_catalog_from_alias (alias, catalog_no)
  char    *alias;       /*  i - Catalog alias from parsed trio  */
  short   *catalog_no;  /*  o - Position in catalog buffer      */
  {
    auto    int   i;
    auto    char  **data;
    static  char  *fname = "QUIget_catalog_from_alias";

    _NFIdebug ((fname, "alias = <%s>\n", alias));

    /*  Initialize the catalog_no  */

    *catalog_no = -1;

    data = (char **) QUIglobal.catalogs->data_ptr;
    for (i = 0; i < QUIglobal.catalogs->rows; ++i)
      {
        if ((strcmp (data[(i * 2) + 1], alias)) == 0)
          {
            *catalog_no = (short) i;
            break;
          }
      }

    if (*catalog_no == -1)
      {
        _NFIdebug ((fname, "alias was not found in the catalog buffer\n"));
        _NFIdebug ((fname, "defaulting catalog_no to 0\n"));
        *catalog_no = 0;
/*
        ERRload_struct (NFI, QUI_E_BUFFER, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
*/
      }

    _NFIdebug ((fname, "catalog_no = <%d>\n", *catalog_no));

    _NFIdebug ((fname, "returning SUCCESS\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIget_number_from_catalog (catalog_name, catalog_no)
  char    *catalog_name; /*  i - Catalog name from user selection  */
  short   *catalog_no;   /*  o - Position in catalog buffer        */
  {
    auto    int   i;
    auto    char  **data;
    static  char  *fname = "QUIget_number_from_catalog";

    _NFIdebug ((fname, "catalog_name = <%s>\n", catalog_name));

    /*  Initialize the catalog_no  */

    *catalog_no = -1;

    data = (char **) QUIglobal.catalogs->data_ptr;
    for (i = 0; i < QUIglobal.catalogs->rows; ++i)
      {
        if ((strcmp (data[i * 2], catalog_name)) == 0)
          {
            *catalog_no = (short) i;
            break;
          }
      }

    if (*catalog_no == -1)
      {
        _NFIdebug ((fname, "catalog was not found in the buffer\n"));
        _NFIdebug ((fname, "defaulting catalog_no to 0\n"));
        *catalog_no = 0;
/*
        ERRload_struct (NFI, QUI_E_BUFFER, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
*/
      }

    _NFIdebug ((fname, "catalog_no = <%d>\n", *catalog_no));

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIget_catalog_from_number (catalog_no, catalog_name)
  short   catalog_no;    /*  i - Position in catalog buffer     */
  char    *catalog_name; /*  o - Catalog name for user display  */
  {
    auto    char  **data;
    static  char  *fname = "QUIget_catalog_from_number";

    /*  This is hardcoded now  */

    catalog_no = 0;

    _NFIdebug ((fname, "catalog_no = <%d>\n", catalog_no));

    if (catalog_no > QUIglobal.catalogs->rows)
      {
        _NFIdebug ((fname, "catalog was not found in the buffer\n"));
        ERRload_struct (NFI, QUI_E_BUFFER, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
      }

    /*  Initialize the catalog  */

    strcpy (catalog_name, "");

    data = (char **) QUIglobal.catalogs->data_ptr;
    strcpy (catalog_name, data[catalog_no * 2]);

    _NFIdebug ((fname, "catalog_name = <%s>\n", catalog_name));

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIget_alias_from_number (catalog_no, attrib_no, alias)
  short   catalog_no;    /*  i - Position in catalog buffer     */
  short   attrib_no;     /*  i - Position in attribute buffer   */
  char    *alias;        /*  o - Catalog alias for definition   */
  {
    auto    char   **data;
    static  char   *fname = "QUIget_alias_from_number";

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

    /*  Initialize the alias  */

    strcpy (alias, "");

    /*  Don't check for f_catalog if it's -1  */

    if (attrib_no != -1)
      {
        /*  See if this is a catalog or f_catalog attribute  */

        data = (char **) QUIglobal.attributes[catalog_no]->data_ptr;

        if ((strncmp (data[(attrib_no * 4) + 3], "f_", 2)) == 0)
          {
            _NFIdebug ((fname, "this is a file catalog attribute\n"));
            strcpy (alias, "f_");
          }
      }

    /*  Finish building the alias  */

    data = (char **) QUIglobal.catalogs->data_ptr;
    strcat (alias, data[(catalog_no * 2) + 1]);

    _NFIdebug ((fname, "alias = <%s>\n", alias));

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIget_attribute_from_number (catalog_no, attrib_no, attribute)
  short    catalog_no;
  short    attrib_no;
  char     *attribute;
  {
    auto    char    **data;
    static  char    *fname = "QUIget_attribute_from_number";

    _NFIdebug ((fname, "catalog_no = <%d>\n", catalog_no));
    _NFIdebug ((fname, "attrib_no = <%d>\n", attrib_no));

    if (catalog_no >= QUI_MAX_ATTR_NUM)
      {
        _NFIdebug ((fname,
            "too many catalogs; only %d are supported at this time\n",
            QUI_MAX_ATTR_NUM));
        ERRload_struct (NFI, QUI_E_TOO_MANY_CATALOGS, "%d", QUI_MAX_ATTR_NUM);
        _NFIdebug ((fname,
            "returning FAILURE <0x%.8x>\n", QUI_E_TOO_MANY_CATALOGS));
        return (QUI_E_TOO_MANY_CATALOGS);
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
    else if (attrib_no < 0)
      {
        _NFIdebug ((fname, "attribute number is invalid <%d>\n", attrib_no));
        ERRload_struct (NFI, QUI_E_BUFFER, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
      }

    /*  Initialize the attribute  */

    strcpy (attribute, "");

    data = (char **) QUIglobal.attributes[catalog_no]->data_ptr;

    strcpy (attribute, data[attrib_no * 4]);

    _NFIdebug ((fname, "attribute = <%s>\n", attribute));

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIget_number_from_attribute (catalog_no, attribute, attrib_no)
  short    catalog_no;
  char     *attribute;
  short    *attrib_no;
  {
    auto    int     i;
    auto    char    **data;
    static  char    *fname = "QUIget_number_from_attribute";

    _NFIdebug ((fname, "catalog_no = <%d>\n", catalog_no));
    _NFIdebug ((fname, "attribute = <%s>\n", attribute));

    if (catalog_no >= QUI_MAX_ATTR_NUM)
      {
        _NFIdebug ((fname,
            "too many catalogs; only %d are supported at this time\n",
            QUI_MAX_ATTR_NUM));
        ERRload_struct (NFI, QUI_E_TOO_MANY_CATALOGS, "%d", QUI_MAX_ATTR_NUM);
        _NFIdebug ((fname,
            "returning FAILURE <0x%.8x>\n", QUI_E_TOO_MANY_CATALOGS));
        return (QUI_E_TOO_MANY_CATALOGS);
      }

    data = (char **) QUIglobal.attributes[catalog_no]->data_ptr;

    for (i = 0, *attrib_no = -1;
        i < QUIglobal.attributes[catalog_no]->rows; ++i)
      {
        if ((strcmp (data[i * 4], attribute)) == 0)
          {
            *attrib_no = i;
            break;
          }
      }

    if (*attrib_no == -1)
      {
        _NFIdebug ((fname, "attribute was not found in buffer\n"));
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
      }

    _NFIdebug ((fname, "attrib_no = <%d>\n", *attrib_no));

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }


long QUIget_synonym (catalog_no, attrib_no, synonym)
  short   catalog_no;
  short   attrib_no;
  char    *synonym;
  {
    auto    char    **data;
    static  char    *fname = "QUIget_synonym";

    _NFIdebug ((fname, "catalog_no = <%d>\n", catalog_no));
    _NFIdebug ((fname, "attrib_no = <%d>\n", attrib_no));

    if (catalog_no >= QUI_MAX_ATTR_NUM)
      {
        _NFIdebug ((fname,
            "too many catalogs; only %d are supported at this time\n",
            QUI_MAX_ATTR_NUM));
        ERRload_struct (NFI, QUI_E_TOO_MANY_CATALOGS, "%d", QUI_MAX_ATTR_NUM);
        _NFIdebug ((fname,
            "returning FAILURE <0x%.8x>\n", QUI_E_TOO_MANY_CATALOGS));
        return (QUI_E_TOO_MANY_CATALOGS);
      }

    /*  Initialize the synonym  */

    strcpy (synonym, "");

    /*  Make sure we're not past the end of the buffer  */

    if (attrib_no >= QUIglobal.attributes[catalog_no]->rows)
      {
        _NFIdebug ((fname, "attribute is outside of buffer range <%d>\n",
            QUIglobal.attributes[catalog_no]->rows));
        ERRload_struct (NFI, QUI_E_BUFFER, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_BUFFER));
        return (QUI_E_BUFFER);
      }

    data = (char **) QUIglobal.attributes[catalog_no]->data_ptr;

    strcpy (synonym, data[(attrib_no * 4) + 2]);

    _NFIdebug ((fname, "synonym = <%s>\n", synonym));

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
