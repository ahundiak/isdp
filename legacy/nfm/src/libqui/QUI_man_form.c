#include "machine.h"
#include "QUI.h"

long QUI_manipulate_form( form, gadget_index)

Form form;  /* I - the pointer to the form */
long gadget_index; /* I - index of value gadget toggled */

{
  auto    long    status;
  static  char    *fname = "QUI_manipulate_form";

  _NFIdebug ((fname, "entering ...\n"));
  if (gadget_index+QUIglobal.QUI_offset+1>QUIglobal.QUI_numofattr) 
    QUIglobal.QUI_numofattr++;
  if (gadget_index<7)
  {
    FIg_enable(form, CATALOG_FIELD1+gadget_index+1);
    FIg_enable(form, ATTRIBUTE_FIELD1+gadget_index+1);
    FIg_enable(form, OPERATOR_FIELD1+gadget_index+1);
    FIg_enable(form, VALUE_FIELD1+gadget_index+1);
    FIg_enable(form, AND_OR_TOGGLE1+gadget_index);

    /*  Default the catalog to the first one in the list  */

    QUI_attrib_displayed[QUIglobal.QUI_numofattr].catalog_no = 0;

    /*  Load the attributes for this catalog  */

    if ((status = _QUIload_catalog_attributes (form,
        ATTRIBUTE_FIELD1 + gadget_index + 1, (short) 0)) != QUI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "_QUIload_catalog_attributes = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    status = QUI_S_SUCCESS;
  }
  else
  {
    status = QUIset_values(form, -1.0);
  }
  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}
