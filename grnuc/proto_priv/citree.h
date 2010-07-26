#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/citree.c */
extern void NODreset __((void));
extern void NODinit __((void));
extern int mkNOD __((PCInode *N));
extern int NODwalk __((inode i_root));
extern int NODcheck __((void));
extern void NODprint __((inode n));
extern int NODassign __((tree *asg));
extern int _NODinstr __((void));
extern int NODinstr __((void));

#if defined(__cplusplus)
}
#endif


#undef __
