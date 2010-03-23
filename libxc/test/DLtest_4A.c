#include <sys/types.h>
#include "objaccess.h"
#include "dloadpvt.h"
extern int __unres1();
extern int __Xarray1[];
void  *data1 = &__Xarray1[0];
void  *data2 = &__Xarray1[1];
void  *data3 = &__Xarray1[5];

int urestest1 (int resolved)
{
  /* check that correct address is assigned to unresolved references */

  if (!resolved) {
    if ((ADDR)__unres1 != (ADDR)UNRESADDR)
      return 0;
    if ((ADDR)data1 != (ADDR)UNRESADDR)
      return 0;
    if ((ADDR)data2 != (ADDR)UNRESADDR + sizeof(int))
      return 0;
    if ((ADDR)data3 != (ADDR)UNRESADDR + 5 * sizeof(int))
      return 0;
    return 1;
  }

  if ((ADDR)__unres1 == (ADDR)UNRESADDR)
    return 0;
  if ((ADDR)data1 == (ADDR)UNRESADDR)
    return 0;
  if ((ADDR)data2 != (ADDR)data1 + sizeof (int))
    return 0;
  if ((ADDR)data3 != (ADDR)data1 + 5 * sizeof (int))
    return 0;
  __unres1 ();
  return 1;
}
