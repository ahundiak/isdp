#include "machine.h"
#include "QUI.h"

long QUIcheckbox(form, g_label)

Form form;
long g_label;

{
  long status=QUI_S_SUCCESS;
  long gadget_index;
  static  char    *fname = "QUIcheckbox";

  _NFIdebug ((fname, "entering ...\n"));

  gadget_index = QUI_attrib_index[g_label] - 1;

  if (QUIglobal.QUI_delete_or_reorder==1)
      status = QUI_delete(form,gadget_index);
  else 
      if (QUIglobal.QUI_delete_or_reorder==2)
        { 
          if (gadget_index<QUIglobal.QUI_numofattr)
            {
              QUIglobal.QUI_delete_or_reorder =
                  -(gadget_index + QUIglobal.QUI_offset);
              ERRload_struct  (NFI,QUI_I_SELROWTO, "%d",
                  gadget_index + 1 + QUIglobal.QUI_offset);
              status = QUI_I_SELROWTO;
            }
          else
            {
              QUIdisplay_checkboxes (form, 1);
              QUIglobal.QUI_delete_or_reorder = 0;
              ERRload_struct (NFI,QUI_E_CANTSWAPROW, "%d",
                  gadget_index + 1 + QUIglobal.QUI_offset);
              return(QUI_E_FAILURE);
            }
        }
      else
        {
          status = QUI_reorder(form,gadget_index);
        }

  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}


long QUIdisplay_checkboxes (form, on_or_off)
  Form      form;
  int       on_or_off;
  {
    auto    int  i;
    auto    int  sel, rpos;
    auto    char s[2];

    for (i = 0; i < NUMBER_OF_ROWS; ++i)
      {
        if (on_or_off)
          {
            FIfld_get_text (form,
                ATTRIBUTE_FIELD1 + i, 0, 0, 2, s, &sel, &rpos);
            if ((strcmp (s, "")) != 0)
              {
                FIg_display (form, CHECKBOX1 + i);
                FIg_enable  (form, CHECKBOX1 + i);
              }
          }
        else
          {
            FIg_erase (form, CHECKBOX1 + i);
            FIg_disable (form, CHECKBOX1 + i);
          }
      }

    return (QUI_S_SUCCESS);
  }
