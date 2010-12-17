#include "machine.h"
#include "QUI.h"

QUI_unhilite(fp,g_label)

Form fp;      /* I - pointer to the form */
long g_label; /* I - label of the gadget */

{
  long sts;
  long row_index;
  long num_rows;

  sts = FIfld_get_list_num_rows(fp, g_label, 0, &num_rows);

  for (row_index=0;row_index<num_rows;row_index++)
  {
    sts = FIfld_set_list_select(fp,g_label,row_index,0,0);
  }
}
