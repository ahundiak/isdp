#include "regexp.h"

char *__loc1;


char *regex (expr, match)

regexp *expr;
char   *match;
{
  if (regexec (expr, match)) {
    __loc1 = expr->startp[0];
    return expr->endp[0];
  }
  return __loc1 = 0;
}


char *regcmp (pat)

char *pat;
{
  return (char *)regcomp (pat);
}


