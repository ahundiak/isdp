#include "dload.h"
#include "test.h"

char Title[] = { "ALLOWURES Option With Incremental Load" };
int main (int testnum)
{
  int  (*urestest)();
  void  *handle;
  char   buffer[16];

  /* check that correct address is assigned to unresolved references */

  sprintf (buffer, "DLtest_%dA." EXT, testnum);
  if (handle = dload (buffer, TEXTREF | DATAREF | ALLOWURES)) {
    struct symdef *symbol;
    if (!dload_symbol_lookup (handle, PFX "urestest2", &symbol))
      return 0;
    urestest = (int (*)())symbol->value;
  }
  else return 0;
  if (!urestest (0))
    return 0;

  /* check that such references get updated if resolved later */

  sprintf (buffer, "DLtest_%dB." EXT, testnum);
  if (!dload (buffer, TEXTREF | DATAREF | INCRLOAD))
    return 0;
  if (!dload_ctrl (LOADCMPL, DLOAD_PEND, 0))
    return 0;
  if (!urestest (1))
    return 0;

  return 1;
}
