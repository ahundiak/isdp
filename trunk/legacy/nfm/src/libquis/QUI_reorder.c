#include "machine.h"
#include "QUI.h"

long QUI_reorder(form,gadget_index)

Form form;
long gadget_index;

{
  static  char    *fname = "QUI_reorder";
  long status=QUI_S_SUCCESS;

  _NFIdebug ((fname, "entering ...\n"));

   QUIerase_message(form);

   FIg_set_state_off(form,CHECKBOX1+gadget_index);

   QUIdisplay_checkboxes(form, 0);

   if (gadget_index<QUIglobal.QUI_numofattr)
   {
     if (-QUIglobal.QUI_delete_or_reorder<QUIglobal.QUI_numofattr)
     {
       status = QUI_swap (gadget_index + QUIglobal.QUI_offset,
           -QUIglobal.QUI_delete_or_reorder);

       status = QUIset_values(form,(double)QUIglobal.QUI_offset);
     }
     else
     {
       QUIglobal.QUI_delete_or_reorder=0;
       ERRload_struct 
           (NFI,QUI_E_CANTSWAPROW, "%d", -QUIglobal.QUI_delete_or_reorder+1);
       return(QUI_E_FAILURE);
     }
   }
   else
   {
     QUIglobal.QUI_delete_or_reorder=0;
     ERRload_struct 
         (NFI,QUI_E_CANTSWAPROW, "%d", gadget_index+1);
     return(QUI_E_FAILURE);
   }
  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}
