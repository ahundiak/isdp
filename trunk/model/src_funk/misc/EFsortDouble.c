/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
void EFsortDouble(double *array, int size)
{
  int       i, j;
  double    temp;

  for(i = 0; i + 1 < size; i ++)
  {
    for(j = i + 1; j < size; j ++)
    {
      if(array[i] > array[j])
      {
        temp = array[i];
        array[i] = array[j];
        array[j] = temp;
      }
    }
  }
}
