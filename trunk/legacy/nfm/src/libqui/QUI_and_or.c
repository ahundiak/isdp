#include "machine.h"
#include "QUI.h"

long QUI_and_or(form, g_label)

Form form;
long g_label;

{
  long status=QUI_S_SUCCESS;
  long gadget_index;
  long state;

            gadget_index = QUI_attrib_index[g_label] - 1;
            FIg_get_state(form, g_label, &state);
            QUI_attrib_displayed[gadget_index + QUIglobal.QUI_offset].and_or =
                (short) state;
            return(status);
}
