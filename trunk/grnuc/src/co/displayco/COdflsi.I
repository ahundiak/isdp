class implementation COdfls;



#include "FI.h"

%safe 
#include "COdlsfunc.h"
%endsafe



method COdfls_sleep ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   FIf_erase( me->forms[0].form_ptr );
   quit:
  return OM_S_SUCCESS;
}

method form_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  *sts = OM_S_SUCCESS;

  dls_form_init(FALSE, &me->forms[0].form_ptr);

quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;


  dls_form_notification(form_label, gadget_label, value, form_ptr);

quit:
  return OM_S_SUCCESS;
}

end implementation COdfls;
