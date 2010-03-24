class implementation EX_test;

#include <stdio.h>
#include <exdef.h>
#include <exmacros.h>
#include <OMindex.h>
#include <exsysdep.h>
#include <string.h>
#include <exproto.h>

#define debug 0

extern UI_prompt();
extern struct module_params **module_data;  /*OM_Gw_maxOS];*/
extern struct EX_visible_module *module_table;
extern struct EX_invisible_module *invisible_table;
extern OM_S_OBJID EX_exec_id;

from IGEwsys import clear, activate;

/***********************************************************************/
/************************* EX_test init method ***********************/
/***********************************************************************/

method init(int type;char *str_ptr)
{
    ME.super_cmd->state = 0;
    strcpy(ME.super_cmd->path,str_ptr);
    ME.super_cmd->mytype = type;
    return(OM_S_SUCCESS);
 }

/***********************************************************************/
/************************* EX_test wakeup method *********************/
/***********************************************************************/

method wakeup(int pos)
{
   UI_message("EX TEST");
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_test execute method ********************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
  int not_exit;
  int num_entry;
  char *temp_str;
  
   not_exit = 1;
   while( not_exit )
   {
      switch(ME.super_cmd->mytype)
      {
        case 0:

	     EX_set_cmdserver_debug();
 	     *response = TERMINATE;
	     not_exit = FALSE;
	     break;


       case 11 :
            EX_get_srch_path(&temp_str,&num_entry);
	    printf("num of search_path = <%d>\n",num_entry);
	    printf("search path= <%s>\n",temp_str);
            *response = TERMINATE;
	    not_exit = FALSE;
           break;

          default:
             break;
      }

   }   

   return(OM_S_SUCCESS);

}



end implementation EX_test;

