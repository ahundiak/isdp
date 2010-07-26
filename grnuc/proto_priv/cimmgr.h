#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cimmgr.c */
extern unsigned VARsizeof __((int v));
extern int VARalloc __((int var, Ushort dim));
extern void VARauxsz __((PCItype *T, PCIident V));
static void VARscope __((int *v));
extern void VARforget __((PCIident F));
extern int MKvar __((PCIcontext *C, PCIident V));
extern int VARext __((FILE **xfile, PCIident V));
extern int MKdcl __((PCIcontext *C, PCIident V));
static char *VARtype __((PCItype *T, Uchar sts, char *name));
extern void VARdump __((FILE *F));
extern void VARdebug __((int v));

#if defined(__cplusplus)
}
#endif


#undef __
