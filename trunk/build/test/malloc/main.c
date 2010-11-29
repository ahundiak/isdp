/* ============================================================
 * Do some testing for getting mallocs aligned to 8 bytes
 *
 * As far as I can tell, malloc always returns 8-byte boundary
 * at least under Solaris 10 development system.
 *
 * as does g_malloc
 */
#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int getRandomSize()
{
  int size = 65536;

  while(size > 65535)
  {
    size = rand();
  }
  return size;
}
int main(int argc, char *argv[])
{
  int i,size;
  char *p;

//  for(i = 0; i < 1000000; i++)
  for(i = 1; i < 8000; i++)
  {
    size = getRandomSize();
    size = i;
    p = g_malloc(size);

    if ((unsigned int)p & 0x4) printf("4 Byte boundary, size %d\n",size);
    // printf("Size %d\n",size);
  }
  return 0;
}
