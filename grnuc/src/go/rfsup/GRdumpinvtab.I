class implementation GRgraphics;

#include "exdef.h"

extern struct EX_invisible_module *invisible_table;

void GRdumpinvtab()
{
  int i;

  for ( i = 0; i < 50; i++)
    if ((om$is_objid_valid ( osnum = invisible_table [i].obj_space_num,
        objid = 0 ) == OM_S_SUCCESS) && (invisible_table [i].obj_space_num))
    {
      printf("entry number %d\n",i);
      printf(" osnum = %d\n",invisible_table[i].obj_space_num);
      printf("mod_id = %d\n",invisible_table[i].module_my_id);
      printf("num_of_opens = %d\n",invisible_table[i].numof_opens);
    }
}


end implementation GRgraphics;
