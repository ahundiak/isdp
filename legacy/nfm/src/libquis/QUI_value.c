#include "machine.h"
#include "QUI.h"

long QUI_value(form, g_label)

Form form;
long g_label;

{
  long status=QUI_S_SUCCESS;
  long gadget_index;
  long size;

  static  char    *fname = "QUI_value";

  _NFIdebug ((fname, "entering ...\n"));
            QUI_Get_text (form, g_label);
            size = QUIglobal.text_size+1;
            gadget_index = QUI_attrib_index[g_label] - 1;
            if (size > QUI_MIN_VALUE_LEN)
              {
                QUI_attrib_displayed[gadget_index +
                    QUIglobal.QUI_offset].value = (char *) realloc
                    (QUI_attrib_displayed[gadget_index +
                    QUIglobal.QUI_offset].value, size);
              }

            strcpy (QUI_attrib_displayed[gadget_index +
                QUIglobal.QUI_offset].value, QUIglobal.text);

  _NFIdebug ((fname, "exiting ...\n"));
            return(status);
}
