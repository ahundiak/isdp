/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRunit

    METHOD NAME:  GRunitchg_def
*/

class implementation GRunit;

#define INPUT  0
#define OUTPUT 1
#define BOTH   2
#include "grimport.h"
#include "codebug.h"


#include "griomacros.h"

method GRunitchg_def(IGRlong        *rc;
                     IGRshort       *flag;
                     IGRshort       *num_defaults;
                     GRIOalias_name *default_units)
{
    IGRshort           i;
    IGRshort           def_index;
    IGRlong            status;
    IGRboolean         located;
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

    /*
     * verify correct number of defaults were sent.
     */
    if((*num_defaults > 0) && (*num_defaults <= 3))
      {
        for(i=0; i<*num_defaults; i++)    /* check all alias */
          {
            if(default_units[i] != NULL)
             {
              status = om$send(msg = message GRunit.GRunitfin_als(
                                   rc, 
                                   (GRIOalias_name *)default_units[i],
                                   &def_index,
                                   &located),
				     targetid = my_id);
                if(!located)  /*  alias not located */
                 {
                  *rc = MSFAIL;
                   goto quit;
                 }
               }
           }
          /*
           * NULL out unused slots
           */
          if(*num_defaults < 3)
           {
             for(i=*num_defaults; i<3; i++)
               {
                 *update_alias[i] = NULL;
               }
            }

          /*
           * add defaults to objects instance data.
           */
          *update_num = *num_defaults;
          for(i=0; i<*num_defaults; i++)
            {
                if(*default_units[i] != NULL)
                 {             /* make sure previous unit defined */
                  if( ((i > 0) && (*update_alias[i-1] != NULL)) || (i==0) )
		    {
		      len = strlen(default_units[i]);
		      if(len >= GRIO_MAX_ALIAS_SIZE) 
			{
			  len = GRIO_MAX_ALIAS_SIZE-1;
			  *rc = GRIO_W_ALIAS_TRUNC;
			}
                      strncpy(update_alias[i],default_units[i],len);
		      update_alias[i][len]=0;
		    }
                 }
            }
       }
    else   /* Invalid number of defaults supplied */
      {
        *rc = MSFAIL;
      }

quit: 
    return( OM_S_SUCCESS );
}  

end implementation GRunit;
