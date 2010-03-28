/*

Name
  GRvardel.I

Description
  Contains method GRvardel for deleting variables

Notes
  New headers added for 2.4 build.

 */
/*

Name
  GRvardel

Abstract
  This method removes a variable from the GRvar table.

Synopsis
  method GRvardel( rc, num_alias, alias_list )
  
  IGRlong         * rc           OUT
  IGRshort        * num_alias    IN
  GRIOalias_name  * alias_list   IN   list of aliases to be deleted

Description
  
Return Value

Notes
  IMPORTANT NOTE!  alias_list is actually a pointer to char (a string)
  if *num_alias == 1; if *num_alias > 1, then alias_list is a 
  pointer to a pointer to char (list of strings).  This is BAD 
  programming but it is too late to change that now.

Index

Keywords
  variable,delete

History
  12/03/86 : BMR           : Design Date
  07/15/92 : SCW           : ansi conversion
  08/16/93 : Shelley Heard : Fixed bug where the status and return code from 
			     GRunit.GRunitdel_als() were not checked on 
			     return.  If this message was not successful, a
			     bad index would be used in the subsequent call
			     to access the VLA ME.GRvar->var_list.  That 
			     would cause a segmentation violation.

 */
class implementation GRvar;

#include "grimport.h"
#include "igrmacros.h"
#include "OMmacros.h"

method GRvardel(IGRlong     *rc;
                IGRshort    *num_alias;
                GRIOalias_name  *alias_list)

{
  IGRlong              status = OM_S_SUCCESS;
  IGRshort             i, def_index = 0;
  IGRboolean           modify_flag,last_alias_deleted;
  *rc = MSSUCC;

  modify_flag = FALSE;
  /*
   *  delete alias
   */

  for(i=0; i < *num_alias; i++)
  {
    if(*num_alias == 1)
    {
      status = om$send(msg = message GRunit.GRunitdel_als( rc, 
                                                           alias_list,
                                                          &def_index,
                                                          &last_alias_deleted,
                                                          &modify_flag),
                         targetid = my_id);
    }
    else
    {
      status = om$send( msg = message GRunit.GRunitdel_als(
                                           rc, 
                                           (GRIOalias_name *)alias_list[i],
                                          &def_index,
                                          &last_alias_deleted,
                                          &modify_flag),
                        targetid = my_id);
    }
    if (!(status & *rc &1))
    {
      /* 
       * The alias was not found so we cannot remove it's definition (8/23/93)
       */
      goto quit;
    }

    /*
     * remove definition
     */
    if(last_alias_deleted)
    {
      for(i=def_index; i<(ME.GRvar->num_variables-1); i++)
      {
        ME.GRvar->var_list[i] = ME.GRvar->var_list[i+1];
      }

      ME.GRvar->num_variables--;
      status = OM_SET_DIMENSION(ME.GRvar->var_list,
                                ME.GRvar->num_variables);
    }
  }

quit:
  return( OM_S_SUCCESS );

}

end implementation GRvar;
