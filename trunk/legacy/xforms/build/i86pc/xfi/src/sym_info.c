
#include "FImin.h"
#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


int FI_inq_symbol_attr (char  *symbol_file,
                        int    index,
                        int   *total_width,
                        int   *total_height,
                        int   *xoff,
                        int   *yoff,
                        int   *sym_width,
                        int   *sym_height)
{
int symbol_id;
int status;

   status = FI_find_symbol_path_and_id (FI_data, symbol_file, &symbol_id);

   if (status != FI_SUCCESS)
      return (FI_INVALID_SYMBOL_FILE);

   if ((index > 255) || (index < 0))
      return (FI_INVALID_SYMBOL_INDEX);

   if (_FI_symbols[symbol_id].sym_slot[index].sym_width == 0)
      return (FI_INVALID_SYMBOL_INDEX);

   *total_width = _FI_symbols[symbol_id].sym_slot[index].total_width;
   *total_height = _FI_symbols[symbol_id].sym_slot[index].total_height;
   *xoff = _FI_symbols[symbol_id].sym_slot[index].xoff;
   *yoff = _FI_symbols[symbol_id].sym_slot[index].yoff;
   *sym_width = _FI_symbols[symbol_id].sym_slot[index].sym_width;
   *sym_height = _FI_symbols[symbol_id].sym_slot[index].sym_height;

   return (FI_SUCCESS);
}
