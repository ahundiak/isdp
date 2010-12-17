#include "machine.h"
#include "QUI.h"

long QUI_catalog(form, g_label)

Form form;
long g_label;

{
  auto    long    status;
  auto    long    gadget_index;
  auto    short   catalog_no;
  static  char    *fname = "QUI_catalog";

  _NFIdebug ((fname, "g_label = <%d>\n", g_label));

  QUI_Get_text (form, g_label);
  gadget_index = QUI_attrib_index[g_label] - 1;

  if ((status = QUIget_number_from_catalog
      (QUIglobal.text, &catalog_no)) != QUI_S_SUCCESS)
    {
      _NFIdebug ((fname, "QUIget_number_from_catalog = <0x%.8x>\n", status));
      _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
      return (status);
    }

  QUI_attrib_displayed[gadget_index +
     QUIglobal.QUI_offset].catalog_no = catalog_no;

  if ((status = QUIget_attributes (catalog_no)) != QUI_S_SUCCESS)
    {
      _NFIdebug ((fname, "QUIget_attributes = <0x%.8x>\n", status));
      _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
      return (status);
    }

  if ((status = _QUIload_catalog_attributes
      (form, g_label, catalog_no)) != QUI_S_SUCCESS)
    {
      _NFIdebug ((fname, "_QUIload_catalog_attributes = <0x%.8x>\n", status));
      _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
      return (status);
    }

  QUI_attrib_displayed[gadget_index + QUIglobal.QUI_offset].query_display = 1;
  QUIglobal.text[0] = NULL;

  _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
  return (QUI_S_SUCCESS);
}
