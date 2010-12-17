#include "machine.h"
#include "QUI.h"

long QUI_order_button(form, g_label)

Form form;
long g_label;

{
  long status=QUI_S_SUCCESS;

  static  char    *fname = "QUI_order_button";

  _NFIdebug ((fname, "entering ...\n"));
  g_label=g_label;
  if (QUIglobal.QUI_numofattr>1)
    {
      ERRload_struct (NFI,QUI_I_SELROWFROM, 0);
      QUIdisplay_checkboxes (form, 1);
      QUIglobal.QUI_delete_or_reorder = 2;
      status = QUI_I_SELROWFROM;
    }
  else
    {
      ERRload_struct (NFI,QUI_E_TOOFEWROWS, 0);
      status = QUI_E_FAILURE;
    }

  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}
