#include "expriv.h"
extern int  EX_index;
extern char EX_keybuff[];
extern int  EX_entry;
extern int  EX_entry_full;

void GRput_keybuff(str)
   char *str;
{
   UI_echo("");
   strncpy(EX_keybuff,str,257);
   EX_index = strlen(EX_keybuff);
   EX_entry++;
   if(EX_entry >= EX_RCL_MAX_ENTRY)
   {
      EX_entry = 0;
      EX_entry_full = 1;
   }
   UI_echo(str);
}

