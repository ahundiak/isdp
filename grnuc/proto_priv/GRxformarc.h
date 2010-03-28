#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRxformarc.c */
extern IGRlong GRxformarc __((IGRlong *msg, IGRshort *type, IGRmatrix matrix, struct IGRarc *arc, struct IGRarc *new_arc));

#if defined(__cplusplus)
}
#endif


#undef __
