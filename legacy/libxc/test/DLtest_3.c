#include "dload.h"
extern char   GBLchar;
extern short  GBLshort;
extern double GBLdouble;
extern int    GBLintarray[];
extern char   GBLchararray[];
static int    STATint;
static char   STATarray[] = { "Static array" };

static void *Sptrs[] = {
	(void *)&GBLchar, (void *)&GBLshort, (void *)&GBLdouble,
	(void *)GBLintarray, (void *)&GBLchararray[5],
	(void *)&STATint, (void *)STATarray, (void *)&STATarray[5]
};
void *Gptrs[] = {
	(void *)&GBLchar, (void *)&GBLshort, (void *)&GBLdouble,
	(void *)GBLintarray, (void *)&GBLchararray[5],
	(void *)&STATint, (void *)STATarray, (void *)&STATarray[5]
};


char Title[] = { "Data initialized with pointers" };
int main (int testnum)
{
  int ndx;

  for (ndx = 0; ndx < 8; ndx++)
    if (Sptrs[ndx] != Gptrs[ndx])
      return 0;
  if (Sptrs[0] != (void *)&GBLchar)         return 0;
  if (Sptrs[1] != (void *)&GBLshort)        return 0;
  if (Sptrs[2] != (void *)&GBLdouble)       return 0;
  if (Sptrs[3] != (void *)GBLintarray)      return 0;
  if (Sptrs[4] != (void *)&GBLchararray[5]) return 0;
  if (Sptrs[5] != (void *)&STATint)         return 0;
  if (Sptrs[6] != (void *)STATarray)        return 0;
  if (Sptrs[7] != (void *)&STATarray[5])    return 0;

  return 1;
}
