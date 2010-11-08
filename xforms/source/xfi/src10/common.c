#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


int FIf_set_rel_location (Form  form,
                          int   xpos,
                          int   ypos,
                          Form  rel_form)
{
   int x, y;

   FIf_get_location (rel_form, &x, &y);
   FIf_set_location (form, x + xpos, y + ypos);

   return (FI_SUCCESS);
}
