
#include <stdio.h>
#include <ieeefp.h>
 
fp_rnd fpsetround ( fp_rnd arg_fake )
{
  printf ("fpsetround: This function will never be hit\n");
}

int ieee_flags ( const char *action, const char *mode, 
                 const char *in, const char **out )
{
  printf ("ieee_flags: This function will never be hit\n");
}
