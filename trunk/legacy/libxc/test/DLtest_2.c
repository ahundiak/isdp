#include "dload.h"
#include "test.h"
extern char *Main_redef1 ();

char Title[] = { "Redefinition of function in MAIN" };
int main (int testnum)
{
  char *answer;
  char  buffer[16];

  answer = Main_redef1 (1, 2, 3, 4, 5, 6, 7);
  if (0 != strcmp (answer, "The answer is 28"))
    return 0;
  sprintf (buffer, "DLtest_%dA." EXT, testnum);
  if (!dload (buffer, TEXTREF | DATAREF | TEXTREDEF))
    return 0;
  answer = Main_redef1 (1, 2, 3, 4, 5, 6, 7);
  if (0 != strcmp (answer, "The NEW answer is 14"))
    return 0;
  return 1;
}
