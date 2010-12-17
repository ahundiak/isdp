#include "machine.h"
#include "QUI.h"

long QUI_delete(form,gadget_index)

Form form;
long gadget_index;

{
  static  char    *fname = "QUI_delete";
  long status=QUI_S_SUCCESS;
  long    trio_ctr;

  _NFIdebug ((fname, "entering ...\n"));

   FIg_set_state_off(form,CHECKBOX1+gadget_index);

   QUIdisplay_checkboxes(form, 0);

   if (gadget_index<QUIglobal.QUI_numofattr)
   {
     for (trio_ctr=gadget_index+QUIglobal.QUI_offset+1;
          trio_ctr<QUIglobal.QUI_numofattr;trio_ctr++)
     {
       status = QUI_swap(trio_ctr-1,trio_ctr);
     }

     QUIglobal.QUI_numofattr--;

     free(QUI_attrib_displayed[QUIglobal.QUI_numofattr].value);

     /*  Close the value list buffer  */

     if (QUIglobal.values[QUIglobal.QUI_numofattr] != (MEMptr) -1)
       {
         MEMclose (&QUIglobal.values[QUIglobal.QUI_numofattr]);
         QUIglobal.values[QUIglobal.QUI_numofattr] = (MEMptr) -1;
       }

     status = QUI_initialize_structure(QUIglobal.QUI_numofattr);
     status = QUIset_values(form,(double)QUIglobal.QUI_offset);
   }
   else
   {
     ERRload_struct (NFI, QUI_E_NOROWSTODEL, 0);
     return(QUI_E_FAILURE);
   }
  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}
