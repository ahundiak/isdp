#include "machine.h"
#include "QUI.h"
#include "NFMerrordef.h"

long _QUIload_catalog_attributes (form, label, catalog_no)
  Form      form;
  int       label;
  short     catalog_no;
  {
    auto    int     i, row;
    auto    int     fields;
    auto    char    **data;
    static  char    *fname = "_QUIload_catalog_attributes";

    _NFIdebug ((fname, "catalog_no = <%d>\n", catalog_no));

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
    fields = QUIglobal.attributes[catalog_no]->rows *
             QUIglobal.attributes[catalog_no]->columns;

    /*  Put all synonyms into this associated list  */

    for (i = 0, row = 0; i < fields;
        i += QUIglobal.attributes[catalog_no]->columns, ++row)
      {
        if ((strcmp (data[i + 2], "")) != 0)
            FIfld_set_list_text (form, label, row, 0, data[i + 2], FALSE);
        else
            FIfld_set_list_text (form, label, row, 0, data[i], FALSE);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
