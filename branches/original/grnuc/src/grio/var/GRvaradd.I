/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
    CLASS  NAME:  GRvar

    METHOD NAME:  GRvaradd

     Design Date:     BMR  2/24/87     
     ansi conversion  scw 07/15/92
----*/
/* EH */

class implementation GRvar;

#include "grimport.h"
#include "igrmacros.h"
#include "OMmacros.h"

method GRvaradd(IGRlong         *rc;
                GRIOalias_name      *input_alias;
                struct GRIOvar_def  *input_variable)

{
  IGRlong              status;
  IGRshort             num_alias;
  IGRboolean           located,modify_flag,alias_added;
  IGRshort             index;          /* index into definition array   */
  IGRint               len;
  
  *rc = MSSUCC;
  status = OM_S_SUCCESS;
  modify_flag = TRUE;
  num_alias = 1;
  
  /*
   *  load alias
   */
  status = om$send(msg = message GRunit.GRunitfin_als(rc, 
						      input_alias,
						      &index,
						      &located),
		   targetid = my_id);
  
  if(located)
    {
      status = om$send(msg = message GRvar.GRvardel(rc, 
						    &num_alias,
						     input_alias),
		       targetid = my_id);
      
    }

  index = (IGRshort) ME.GRvar->num_variables;
  status = om$send(msg = message GRunit.GRunitadd_als(rc, 
   					              &index,
						      &modify_flag,
						      &alias_added,
						      &num_alias,
						      input_alias),
                    targetid = my_id);
  _m_check2q(status,*rc);
  
  /*
   * load definitions
   */
  if(alias_added)
    {
      ME.GRvar->num_variables++;
      status = OM_SET_DIMENSION(ME.GRvar->var_list,
				ME.GRvar->num_variables);
      if(input_variable->type == GRIO_VAR_STRING)
	{
	  ME.GRvar->var_list[ME.GRvar->num_variables-1].type = 
	    input_variable->type;
	  len = strlen(input_variable->contents.string);
          if(len >= 40)
	    {
	      strncpy(
 	         ME.GRvar->var_list[ME.GRvar->num_variables-1].contents.string,
                 input_variable->contents.string,39);
          ME.GRvar->var_list[ME.GRvar->num_variables-1].contents.string[39]=0;
                 *rc = GRIO_W_DATA_TRUNC;
	    }
	  else
	    {
	      strcpy(
		 ME.GRvar->var_list[ME.GRvar->num_variables-1].contents.string,
                 input_variable->contents.string);
	    }
	}
      else
	{
	  if (ME.GRvar->num_variables > 0)
	  {
	    ME.GRvar->var_list[ME.GRvar->num_variables-1] = *input_variable;
	  }
	  else
	  {
	    ME.GRvar->num_variables = 0;
            goto quit;
	  }
	}
    }
 quit: 
  return( OM_S_SUCCESS );
}  

end implementation GRvar;
