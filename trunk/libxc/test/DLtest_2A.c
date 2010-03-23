#include <stdio.h>

static char buffer[40];

char *Main_redef1 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = (arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7) / 2;

  sprintf (buffer, "The NEW answer is %d", ans);
  return buffer;
}
