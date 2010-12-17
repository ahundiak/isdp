#include "machine.h"
#include "QUI.h"

long QUI_delete_row(form, g_label)

Form form;
long g_label;

{
  long status=QUI_S_SUCCESS;

  static  char    *fname = "QUI_delete_row";

  _NFIdebug ((fname, "entering ...\n"));
  g_label=g_label;
  if (QUIglobal.QUI_numofattr>0)
    {
      ERRload_struct (NFI,QUI_I_SELROWDEL, 0);
      QUIdisplay_checkboxes (form, 1);
      QUIglobal.QUI_delete_or_reorder = 1;
      status = QUI_I_SELROWDEL;
    }
  else
    {
       ERRload_struct (NFI,QUI_E_NOROWSTODEL, 0);
       status = QUI_E_FAILURE;
    }

  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}
