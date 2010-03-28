#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRabsgutil.C */
extern int GRabsg_test __((IGRlong *msg, IGRshort *matrix_type, IGRmatrix matrix, GRspacenum *osnum, GRobjid *objid, IGRchar **absgptr));
extern IGRchar *GRabsg_init __((IGRlong size));
extern IGRboolean GRabsg_del __((IGRchar *absgptr_ptr));
extern IGRboolean GRabsg_del_by_objid __((GRobjid *objid, GRspacenum *osnum));
extern IGRboolean GRabsg_del_all __((void));
extern IGRchar *GRabsg_alloc __((IGRlong *msg, struct GRabsg_hdr *hdr));
static IGRchar *GRget_more_mem __((IGRlong nbytes));

#if defined(__cplusplus)
}
#endif


#undef __
