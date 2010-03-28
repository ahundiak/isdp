/* #######################    APOGEE COMPILED   ######################## */
#include <string.h>

#include "igrtypedef.h"

#include "DPpattern.h"  /* defining prototype file */

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPpattern( unsigned short  pattern,
                         IGRchar  *buff )
#else
IGRint DPpattern(pattern, buff)

unsigned short  pattern;
IGRchar  *buff;
#endif

{
  IGRshort ind;
  IGRchar  *tmp_buff;
  unsigned short  shift_pattern;

  tmp_buff = buff;
  shift_pattern = pattern;

  for (ind = 0; ind < 16; ind++)
  {
    if ( 0x8000 & shift_pattern)
    {
      if (ind == 0)
        strcpy(tmp_buff, "_");
      else
        strcat(tmp_buff, "_");
    }
    else
    {
      if (ind == 0)
        strcpy(tmp_buff, " ");
      else
        strcat(tmp_buff, " ");
    }
    shift_pattern <<= 1;
  }

  return(1);
}
