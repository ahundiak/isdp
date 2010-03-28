/*
 Description
    User defined linestyle command object. 

 History
    dhm     7/?/91   Creation date
    dhm     9/18/91  Made the form_init and form_notification methods into
                     functions so it will be more generic
*/

options         "t"
product_name    "$GRNUC"
spec_path       "$GRNUC/spec"
class           COdfls
super_class     CEO
start_state	    terminate


specification



implementation

#include "FI.h"

%safe 
#include "COdlsfunc.h"
%endsafe

action COdfls_sleep
   {
   FIf_erase( me->forms[0].form_ptr );
   }
   
action form_init
{
  *sts = OM_S_SUCCESS;

  dls_form_init(FALSE, &me->forms[0].form_ptr);

}


action form_notification /* ( int form_label; int gadget_label; double value;
                              char *form_ptr );   */
{

  dls_form_notification(form_label, gadget_label, value, form_ptr);

}
