/*
  DESCRIPTION

    This is the instantiable class for all scalar value parameters and sets
    any additional protocols for the same. This excludes 2D variational
    geometric variables.

  HISTORY

    SS  :  03/14/91  :  Creation
    jhw :  06/28/91  :  Added GRdelete and EMparam_delete override.
    Carlos M. Diaz: 07/29/93 : Added GRgetprops override.
*/

class specification EMSparamvl (2:0) of EMSparameter, EMSexpcnstr;

#include "asbox.h"

message EMconstruct (IGRlong *msg; IGRushort opts;
                     IGRdouble val; IGRchar *name);

message EMauto_dimension ( IGRlong              * msg;
                           IGRushort      opts;
                           IGRint                 dim_type; 
                           IGRshort             * mattyp; 
                           IGRmatrix              mat;
                           GRobjid              * dimobj );
/*
  DESCRIPTION

    This message creates the dimension handle for this constraint.
    It also return the object-id of the dimension constructed.

  HISTORY

    SS  :  04/09/91  :  Creation
*/

override
/*
 * Indicate that I am only valid for a drop macro.
 */
  ACbecome_macro,
  GRdelete,
  EMparam_delete,
/*
 * GRlocate_owner override for preventing to delete dimension object
 */ 
  GRlocate_owner,
/*
 * Need to honor the units_convert flag when returning the value of the expression.
 * Rajiv Agrawal  6/7/93
 */
  NDgive_structure,
  NDgive_value,
/*
 * Overriding grgetprops, see TR 119220823
 * Carlos, 7/29/93
 */
  GRgetprops;

end specification EMSparamvl;
