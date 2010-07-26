/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRunit

    METHOD NAME:  GRunitget_def
     
----*/


class implementation GRunit;

#define INPUT  0
#define OUTPUT 1
#ifndef NT
#include <sys/time.h>
#endif
#include <time.h>
#include "grimport.h"

method GRunitget_def(IGRlong        *rc;
                     IGRshort       *flag;
                     IGRshort       *num_defaults;
                     GRIOalias_name *default_units)
 {
   IGRshort           i;
   IGRshort          *update_num;
   GRIOalias_name    *update_alias;
   IGRint             len;

   *rc = MSSUCC;
   
   if(*flag == INPUT)       /*  update input values  */
     {
       update_alias = ME.GRunit->default_alias_in;
       update_num = &ME.GRunit->num_defs_in;
     }
   else if(*flag == OUTPUT) /*  update output values */
     {
       update_alias = ME.GRunit->default_alias_out;
       update_num = &ME.GRunit->num_defs_out;
     }
   else                   /* bad flag passed       */
     {
       *rc = MSFAIL;
       goto quit;
     }
   
   *num_defaults = *update_num;
   for(i=0; i<*update_num; i++)
     {
       len = strlen(update_alias[i]); 
       if(len >= GRIO_MAX_ALIAS_SIZE) 
	 {
	   len = GRIO_MAX_ALIAS_SIZE-1;
	   *rc = GRIO_W_ALIAS_TRUNC;
	 }
       strncpy(default_units[i],update_alias[i],len);
       default_units[i][len]=0;
     }
   
 quit: 
   return( OM_S_SUCCESS );
 }  
     
end implementation GRunit;
     
     
