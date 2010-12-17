#include "machine.h"
#include "QUI.h"
#include "NFMerrordef.h"

long QUIget_attributes (catalog_no)
  short    catalog_no;
  {
    auto    long    status;
    auto    char    s[512];
    auto    char    **data;
    static  char    *fname = "QUIget_attributes";

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

    /*  See if this catalog's attributes have already been selected  */

    if (QUIglobal.attributes[catalog_no] == NULL)
      {
        data = (char **) QUIglobal.catalogs->data_ptr;

        /*  Get the attributes for this catalog  */

        sprintf (s, "SELECT a.n_name, a.n_datatype, a.n_synonym, \
b.n_tablename FROM nfmattributes a, nfmtables b WHERE a.n_tableno IN \
(SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s' OR \
n_tablename = 'f_%s') AND a.n_tableno = b.n_tableno",
            data[catalog_no * 2], data[catalog_no * 2]);

        if ((status = NFMRsqlquery
           (s, "512", &QUIglobal.attributes[catalog_no])) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMRsqlquery = <0x%.8x>\n", status));
            MEMclose (&QUIglobal.attributes[catalog_no]);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }

        if ((status = MEMbuild_array
            (QUIglobal.attributes[catalog_no])) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            MEMclose (&QUIglobal.attributes[catalog_no]);
            ERRload_struct (NFI, QUI_E_MEM, "%s%x", "MEMbuild_array", status);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }

        if (_NFMdebug_st.NFIdebug_on)
          {
            MEMprint_buffer ("attributes",
                QUIglobal.attributes[catalog_no], _NFMdebug_st.NFIdebug_file);
          }
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
