#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/source/ASsourcei.I */
extern int ASfind_in_del __((struct GRid obj, struct ret_struct *rst));
extern int ASadd_in_del __((struct GRid obj, struct ret_struct *rst));
extern int ASclear_del __((void));

#if defined(__cplusplus)
}
#endif


#undef __
