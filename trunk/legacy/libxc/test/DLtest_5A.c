#include <sys/types.h>
#include "objaccess.h"
#include "dloadpvt.h"
extern int __unres2();
extern int __Xarray2[];
static void *data1 = &__Xarray2[0];
static void *data2 = &__Xarray2[1];
static void *data3 = &__Xarray2[5];

int urestest2 (int resolved)
{
  /* check that correct address is assigned to unresolved references */

  if (!resolved) {
    if ((ADDR)__unres2 != (ADDR)UNRESADDR)
      return 0;
    if ((ADDR)data1 != (ADDR)UNRESADDR)
      return 0;
    if ((ADDR)data2 != (ADDR)UNRESADDR + sizeof(int))
      return 0;
    if ((ADDR)data3 != (ADDR)UNRESADDR + 5 * sizeof(int))
      return 0;
    return 1;
  }

  if ((ADDR)__unres2 == (ADDR)UNRESADDR)
    return 0;
  if ((ADDR)data1 == (ADDR)UNRESADDR)
    return 0;
  if ((ADDR)data2 != (ADDR)data1 + sizeof (int))
    return 0;
  if ((ADDR)data3 != (ADDR)data1 + 5 * sizeof (int))
    return 0;
  __unres2 ();
  return 1;
}
