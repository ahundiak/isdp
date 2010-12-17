#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"


void _FB_free (void *pointer)
{
  if ( pointer )
    free ( pointer );
}
