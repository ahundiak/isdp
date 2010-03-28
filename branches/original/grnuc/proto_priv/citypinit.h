#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/citypinit.c */
extern int TYIfind __((PCItype *T));
extern int TYIfindthis __((PCItype *T));
extern int mkTYI __((PCItype *T));
extern int TYIbegin __((void));
extern int TYIend __((void));
extern int mkTYIarg __((PCIcontext *C, PCIident A));
extern int TYIisarg __((PCIident A));
extern int TYIcall __((int t, PCIlist *argv));
extern void TYIfree __((void));
extern void TYIdump __((FILE *F));

#if defined(__cplusplus)
}
#endif


#undef __
