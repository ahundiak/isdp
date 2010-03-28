#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGRdir/src/DIstring.C */
extern int DIstmcpy __((int va_alist));
extern int DIstmcat __((int va_alist));
extern int DIstmocpy __((int va_alist));

#if defined(__cplusplus)
}
#endif


#undef __
