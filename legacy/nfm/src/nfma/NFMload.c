#include "machine.h"
#include "WF.h"
#include <ctype.h>

 extern struct WFstruct WFinfo;

 long NFMload_workflow (user_id, app_name, file_name)
   long    user_id;
   char    *app_name; 
   char    *file_name;    
   {
   return (WFload_workflow (user_id, app_name, file_name));
   }
