#include "machine.h"
#include "QUI.h"

long QUIattribute(form, g_label)

Form form;
long g_label;

{
  long status=QUI_S_SUCCESS;
  long gadget_index;

  static  char    *fname = "QUIattribute";

  _NFIdebug ((fname, "entering ...\n"));

  QUI_Get_text (form, g_label);
  gadget_index = QUI_attrib_index[g_label] - 1;

  /*  Load the info into the appropriate structure  */

  if ((status = QUIload_attribute_info
      (form, g_label, gadget_index)) != QUI_S_SUCCESS)
    {
      _NFIdebug ((fname, "QUIload_attribute_info = <0x%.8x>\n", status));
    }
  else
    {
      /*  Get the value list for this attribute  */

      if ((status = QUIload_value_list
          (form, gadget_index + QUIglobal.QUI_offset)) != QUI_S_SUCCESS)
          _NFIdebug ((fname, "QUIload_value_list = <0x%.8x>\n", status));
    }

  if (QUI_attrib_displayed[gadget_index + QUIglobal.QUI_offset].attrib_no>=0)
      status = QUI_manipulate_form (form, gadget_index);

  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}
