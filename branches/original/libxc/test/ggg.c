#include <stdlib.h>

main(argc, argv)
int   argc;
char *argv[];
{
   int i, count=10, size=1024*1024;
   char *p[10], *p1[10], *pp;

   for (i=0; i<count; ++i) {
      p[i] = (char*)malloc(size);
      printf ("Large Pointer value %5d is : 0x%8x\n",i,p[i]);
      pp = (char*)malloc(size/20);
   }

   for (i=0; i<count; ++i)
      free(p[i]);

   for (i=0; i<count; ++i) {
      p1[i] = (char*)malloc(size/10);
      printf ("Small Pointer value %5d is : 0x%8x\n",i,p1[i]);
   }

   for (i=0; i<count; ++i) {
      p[i] = (char*)malloc(size);
      printf ("Large Pointer value %5d is : 0x%8x\n",i,p[i]);
   }

}
