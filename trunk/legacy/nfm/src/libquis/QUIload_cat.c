#include "machine.h"
#include "QUI.h"
#include "NFMerrordef.h"

long _QUIload_catalogs (form, catalog, application)
  Form    form;
  char    *catalog;
  char    *application;
  {
    auto    int     i, row;
    auto    long    status;
    auto    char    **data;
    auto    char    s[256];
    auto    char    text[5];
    static  char    *fname = "_QUIload_catalogs";

    _NFIdebug ((fname, "catalog = <%s>\n", catalog));
    _NFIdebug ((fname, "application = <%s>\n", application));

    strcpy (s, "SELECT n_catalogname, n_identifier FROM nfmcatalogs WHERE ");

    if ((strcmp (catalog, "")) != 0)
      {
        strcat (s, "n_catalogname = '");
        strcat (s, catalog);
        strcat (s, "'");
      }
    else
      {
        strcat (s, "n_identifier = '");
        strcat (s, application);
        strcat (s, "'");
      }

    if ((status = NFMRsqlquery
       (s, "512", &QUIglobal.catalogs)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRsqlquery = <0x%.8x>\n", status));
        MEMclose (&QUIglobal.catalogs);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    if ((status = MEMbuild_array (QUIglobal.catalogs)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, QUI_E_MEM, "%s%x", "MEMbuild_array", status);
        MEMclose (&QUIglobal.catalogs);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    /*  Put all catalogs into all associated lists  */

    data = (char **) QUIglobal.catalogs->data_ptr;
    for (row = 0; row < NUMBER_OF_ROWS; ++row)
      {
        for (i = 0; i < QUIglobal.catalogs->rows; ++i)
          {
            _NFIdebug ((fname,
                "setting <%s> in list row %d\n", data[i * 2], i));
            FIfld_set_list_text (form,
                CATALOG_FIELD1 + row, i, 0, data[i * 2], FALSE);

            /*  Wipe out the application name in the buffer  */

            if ((strcmp (application, "NFM")) == 0)
                strcpy (text, "a");
            else
                strcpy (text, "");

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
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
