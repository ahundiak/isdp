#include "machine.h"
#include "QUI.h"

long QUI_operator (form, g_label)
  Form    form;
  long     g_label;
  {
    auto    long    status = QUI_S_SUCCESS;
    auto    long    gadget_index;
    static  char    *fname = "QUI_operator";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    FIg_get_text (form, g_label, QUIglobal.text);
    gadget_index = QUI_attrib_index[g_label] - 1;

    QUIglobal.text[8] = NULL;

    QUI_attrib_displayed[gadget_index + QUIglobal.QUI_offset].oper =
        (short) QUI_get_op (QUIglobal.text);

    _NFIdebug ((fname, "operator = <%d>\n",
        QUI_attrib_displayed[gadget_index + QUIglobal.QUI_offset].oper));

    QUIglobal.text[0] = NULL;

    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
    return(status);
  }
