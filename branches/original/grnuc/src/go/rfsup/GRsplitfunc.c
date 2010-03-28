#include <stdio.h>

#define TRUE 1
#define FALSE 0

  /* This file contains the support functions for the splitpart */

static int   ASMsplitpart = FALSE;
static int   ASMpartdata = FALSE;

ASMget_splitpart()
{
  return ASMsplitpart;
}

ASMset_splitpart()
{
   ASMsplitpart = TRUE;
   
   return(1);
}

ASMreset_splitpart()
{
   ASMsplitpart = FALSE;
  
   return(1);
}

ASMget_reading_partdata()
{
   return ASMpartdata;
}

ASMset_reading_partdata()
{
    ASMpartdata = TRUE;
}

ASMreset_reading_partdata()
{
   ASMpartdata = FALSE;
}
