/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRvar

    METHOD NAME:  GRvarcvrt

     CHANGE HISTORY: 
      created          BMR  12/03/86
      ansi conversion  scw  07/15/92
----*/

class implementation GRvar;

#include "grimport.h"
#include "OMmacros.h"
#include "OMprimitives.h"

method GRvarcvrt(IGRint              *rc;
                 GRIOalias_name      *input_alias;
                 struct GRIOvar_def  *output_variable)
{
  /* 
   *  Local variable declarations
   */
  IGRshort             index;          /* index into definition array   */
  IGRboolean           located;        /*    was alias located ?????    */
  IGRlong              status;         /*    return status              */
  IGRlong             *msg;


  status = OM_S_SUCCESS;               /* assume success                */
  msg = (IGRlong *)rc;
  *rc = MSSUCC;

  /*
   * make sure alias exist
   */
  status = om$send( msg = message GRunit.GRunitfin_als(
                                     msg, 
                                     input_alias,
                                    &index,
                                    &located),
                    targetid = my_id);
  if(!located)
  {
    *msg = MSFAIL;
    goto quit;
  }

  if ( om$dimension_of ( varray = ME.GRvar->var_list ) > index )
  {
    *output_variable = ME.GRvar->var_list[index];
  }
  else
  {
    /*
     *  There have been cases of files having a valid alias, but no
     *  var_list.  When this happens, it is bad.  What we do is set
     * the dimension of the GRunit alias_list VLA to zero - this is 
     * because it no longer is in sync with the GRvar->var_list VLA.
     * SRH 5/11/93
     */
    *msg = MSFAIL;
    me->num_alias = 0; /* why do we save the size of a VLA?  that's dangerous! */
    om$vla_set_dimension ( varray = ME.GRunit->alias_list, size = 0 );
    
  }

quit: 
  return( status );

}  /* end GRvarcvrt method */

end implementation GRvar;
