#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRcheckref.I */
extern long GRcheckref __((long *msg, short *type, IGRmatrix matrix, GRspacenum *master_osnum, GRspacenum *object_osnum));

#if defined(__cplusplus)
}
#endif


#undef __
