

/*----              wfi.c
change history:

   ht 10/14/86 change EX_wait_for_input as messages under exec in exwfi.I

-----*/
#include <exproto.h>


extern char  EX_keybuff[257];

int EX_extract_string()
{
   int i;
   for( i = 0; (EX_keybuff[i] != 015) && (i < 257); i++)  ;
   EX_keybuff[i] = '\0';
   return(1);
}

