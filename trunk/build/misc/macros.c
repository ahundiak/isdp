/* 
 * Test out values of predefined macros
 * cc -Xc -o macros macros.c
 * man -s 1 cc to get list
 */

#include <stdio.h>
#include <stdlib.h>
#include <values.h>

int main(int argc, char** argv)
{
#ifdef unix
  printf("unix    == defined YES\n");
#else
  printf("unix    == defined NO\n");
#endif

#ifdef __unix
  printf("__unix    == defined YES\n");
#else
  printf("__unix    == defined NO\n");
#endif

#ifdef __i386
  printf("__i386    == defined YES\n");
#else
  printf("__i386    == defined NO\n");
#endif

#ifdef sun
  printf("sun     == defined YES\n");
#else
  printf("sun     == defined NO\n");
#endif

#ifdef sparc
  printf("sparc   == defined YES\n");
#else
  printf("sparc   == defined NO\n");
#endif

#ifdef __BUILTIN_VA_ARG_INCR
  printf("__BUILTIN_VA_ARG_INCR == defined YES\n");
#else
  printf("__BUILTIN_VA_ARG_INCR == defined NO\n");
#endif

#ifdef __SUNPRO_C
  printf("__SUNPRO_C == defined YES\n");
#else
  printf("__SUNPRO_C == defined NO\n");
#endif

#ifdef __SVR4
  printf("__SVR4  == defined YES\n");
#else
  printf("__SVR4  == defined NO\n");
#endif

#ifdef __amd64
  printf("__amd64  == defined YES\n");
#else
  printf("__amd64  == defined NO\n");
#endif

#ifdef __x86_64
  printf("__x86_64  == defined YES\n");
#else
  printf("__x86_64  == defined NO\n");
#endif

#ifdef __sun
  printf("__sun   == defined YES\n");
#else
  printf("__sun   == defined NO\n");
#endif

#ifdef SUNOS
  printf("SUNOS   == defined YES\n");
#else
  printf("SUNOS   == defined NO\n");
#endif

#ifdef __STDC__
  printf("__STDC__ value %d\n",__STDC__);
#else
  printf("__STDC__ Not defined\n");
#endif

#ifdef X11
  printf("X11 value %d\n",X11);
#else
  printf("X11 Not defined\n");
#endif

printf("MAXINT %ld %ld\n",HIBITI,MAXINT);
  
  /*

 __RESTRICT -Xa and -Xt
 __PRAGMA_REDEFINE_EXTNAME

   */
  return (EXIT_SUCCESS);
}

