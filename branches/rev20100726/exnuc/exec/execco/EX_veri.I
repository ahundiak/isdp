class implementation EX_ver;

#include <exsysdep.h>
#include <execmsg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <exproto.h>

extern char EX_version[];
extern char EX_date[];

/***********************************************************************/
/****************** EX_ver execute method ******************************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
  char result[100];
  int  resp;
  long  no_bytes;
  long  ret;
   switch(ME.super_cmd->mytype)
   {
     case 0:

       sprintf(result,"%s  %s",EX_version,EX_date);
       ex$message(msgnumb = EX_S_Var1, type="%s",var=result,justification=LEFT_JUS); 
#ifndef NT
       sleep(3);
#else
       _sleep(3);       
#endif
       break;

     case 1:      /* dummy command used by place text to process function key */
 
       EX_get_input(response,response_data,0);
       resp = CMD_STRING;
       no_bytes = strlen( response_data ) + 1;
       
       EXputq_back(&ret,&resp,&no_bytes,response_data);
       break;

     default :
	       ;
   }
    *response = TERMINATE;
    return(OM_S_SUCCESS);
}

end implementation EX_ver;
