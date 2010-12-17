#include "machine.h"
#include "QUI.h"
#include "NFMerrordef.h"

long QUIload_value_list (form, gadget_index)
  Form    form;
  long    gadget_index;
  {
    auto    int     i;
    auto    int     label;
    auto    long    status;
    auto    char    **data;
    auto    char    s[512];
    auto    char    catalog[NFM_CATALOGNAME + 1];
    auto    char    attribute[NFM_NAME + 1];
    static  char    *fname = "QUIload_value_list";

    _NFIdebug ((fname, "gadget_index = <%d>\n", gadget_index));

    /*  See if the query has already been done  */

    if (QUIglobal.values[gadget_index] == (MEMptr) -1)
      {
        _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
        return (QUI_S_SUCCESS);
      }

    label = VALUE_FIELD1 + gadget_index - QUIglobal.QUI_offset;

    /*  Check to see if the value list for this attribute is here already  */

    if (QUIglobal.values[gadget_index] == NULL)
      {
        if ((status = QUIget_catalog_from_number
            (QUI_attrib_displayed[gadget_index].catalog_no,
            catalog)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "QUIget_catalog_from_number = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }

        if ((status = QUIget_attribute_from_number
            (QUI_attrib_displayed[gadget_index].catalog_no,
            QUI_attrib_displayed[gadget_index].attrib_no,
            attribute)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "QUIget_attribute_from_number = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }

        /*  Get the values (1st column only) from the nfmlists table  */

        sprintf (s, "SELECT n_value FROM nfmlists WHERE n_listno = \
(SELECT n_listno FROM nfmvalues WHERE n_type = 'C' AND n_attrno = \
(SELECT n_attrno FROM nfmattributes WHERE n_name = '%s' AND n_tableno = \
(SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s')))",
            attribute, catalog);

        if ((status = NFMRsqlquery
            (s, "512", &QUIglobal.values[gadget_index])) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMRsqlquery = <0x%.8x>\n", status));
            MEMclose (&QUIglobal.values[gadget_index]);
            QUIglobal.values[gadget_index] = (MEMptr) -1;
            FIfld_set_list_num_rows (form, label, 0, 0);

            /*  See if there were any values defined  */

            if (status == SQL_I_NO_ROWS_FOUND)
              {
                status = QUI_S_SUCCESS;
                ERRreset_struct ();
              }

            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }

        if ((status = MEMbuild_array
            (QUIglobal.values[gadget_index])) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            MEMclose (&QUIglobal.values[gadget_index]);
            ERRload_struct (NFI, QUI_E_MEM, "%s%x", "MEMbuild_array", status);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
      }

    data = (char **) QUIglobal.values[gadget_index]->data_ptr;

    /*  Put the values in the associated list  */

    for (i = 0; i < QUIglobal.values[gadget_index]->rows; ++i)
      {
        _NFIdebug ((fname, "setting <%s> in row %d\n", data[i], i));
        FIfld_set_list_text (form, label, i, 0, data[i], FALSE);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
