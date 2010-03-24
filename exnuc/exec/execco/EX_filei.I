class implementation EX_file;

#include "exsysdep.h"
#include <execmsg.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/***********************************************************************/
/****************** EX_file execute method ******************************/
/***********************************************************************/
  extern struct EX_visible_module *module_table;
  extern struct module_params **module_data;

method execute(int *response; char *response_data; int pos)
{

  char file[OM_K_MAXOSNAME_LEN];

    strcpy(file,
      module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);

    ex$message( msgnumb = EX_S_Var1, type="%s",var=file); 
#ifndef NT    
    sleep(3);
#else
    _sleep(3);
#endif
    *response = TERMINATE;
    return(OM_S_SUCCESS);
}



int
EX_filename1( result,len)
char *result;
int  len;
{
      if (len > (int)strlen(module_data[module_table[active_module_num].obj_space_num]->CS_OS_name) )
      {
	strcpy(result,
	  module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
        return(1);
      }
      else
      {
         return(0);
      }
}




end implementation EX_file;
