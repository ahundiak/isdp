/* =========================================================
 * Compile with -Xc and nothing else
 *  ccx -Xc -### main.c
 */
// #include <stdio.h>

/*
export ISDP_C_PREDEFINED="-D__STDC__=1 -D__sun=1 -D__unix=1 -D__SUNPRO_C=0x580 -D__i386=1 -D__BUILTIN_VA_ARG_INCR=1 __SVR4=1
# sun unix sparc i386
*/
int main(int argc, char *argv[])
{
  printf(
    "PREDEFINED __STDC__=%d, __sun=%d, __unix=%d, __SUNPRO_C=%x, __i386=%d, __SVR4=%d, "
    "__SunOS=%d, __SunOS_5_10=%d,\n"
    "__C99FEATURES__=%d, __BUILTIN_VA_ARG_INCR=%d, __PRAGMA_REDEFINE_EXTNAME=%d, __FLT_EVAL_METHOD__=%d, \n",
    __STDC__,__sun,__unix, __SUNPRO_C,__i386,__SVR4,
    __SunOS,__SunOS_5_10,
    __C99FEATURES__,__BUILTIN_VA_ARG_INCR,__PRAGMA_REDEFINE_EXTNAME,__FLT_EVAL_METHOD__);

/* Without the -Xc option, sun,unix and i386 will be defined and __STDC__ will be 0 */
#ifdef sun
  printf("sun defined\n");
#endif
#ifdef unix
  printf("unix defined\n");
#endif
#ifdef sparc
  printf("sparc defined\n");
#endif
#ifdef i386
  printf("i386 defined\n");
#endif
#ifdef __RESTRICT
  printf("__RESTRICT defined\n");
#endif

/* =====================================
 * This is defined regardless of mode but not in documentation?
 */
#ifdef __C99FEATURES__
//  printf(" __C99FEATURES__ defined\n");
#endif


  return 0;
}
