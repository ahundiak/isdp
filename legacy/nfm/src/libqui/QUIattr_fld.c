#include "machine.h"
#include "QUI.h"

long QUIload_attribute_info (form, label, gadget_index)
  Form    form;
  int     label;
  long    gadget_index;
  {
    auto    int     i, row, sel;
    auto    int     num_rows;
    auto    int     data_offset;
    auto    int     struct_offset;
    auto    char    **data;
    auto    char    synonym[NFM_SYNONYM + 1];
    auto    short   data_type;
    auto    short   data_length;
    auto    short   catalog_no;
    static  char    *fname = "QUIload_attribute_info";

    _NFIdebug ((fname, "gadget_index = <%d>\n", gadget_index));

    struct_offset = gadget_index + QUIglobal.QUI_offset;
    catalog_no = QUI_attrib_displayed[struct_offset].catalog_no;
    QUI_attrib_displayed[struct_offset].query_display = 1;

    /*  Find out which row in the associate list was selected  */

    FIfld_get_list_num_rows (form, label, 0, &num_rows);
    for (i = 0, row = -1; i < num_rows; ++i)
      {
        FIfld_get_list_select (form, label, i, 0, &sel);
        if (sel == TRUE)
          {
            row = i;
            break;
          }
      }

    if (row == -1)
      {
        _NFIdebug ((fname, "no row was selected in associated list\n"));
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_FAILURE));
        return (QUI_E_FAILURE);
      }

    data = (char **) QUIglobal.attributes[catalog_no]->data_ptr;
    data_offset = row * QUIglobal.attributes[catalog_no]->columns;

    _NFIdebug ((fname, "attribute = <%s>\n", data[data_offset]));

    /*  See if there is a synonym defined  */

    if ((strcmp (QUIglobal.text, "")) == 0)
        strcpy (synonym, data[data_offset]);
    else
        strcpy (synonym, QUIglobal.text);

    _NFIdebug ((fname, "synonym = <%s>\n", synonym));

    QUI_attrib_displayed[struct_offset].attrib_no = row;

    /*  Find the datatype for this attribute  */

    data_offset = (row * QUIglobal.attributes[catalog_no]->columns) + 1;

    _NFIdebug ((fname, "datatype = <%s>\n", data[data_offset]));

    QUIget_type (data[data_offset], &data_type, &data_length);
    QUI_attrib_displayed[struct_offset].data_type = data_type;

    /*  Initialize the values list pointer  */

    QUIglobal.values[struct_offset] = NULL;

    QUIglobal.text[0] = NULL;

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
