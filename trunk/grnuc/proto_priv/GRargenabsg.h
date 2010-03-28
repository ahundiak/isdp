#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRargenabsg.c */
extern IGRboolean GRargenabsg __((IGRlong *msg, IGRshort *matrix_type, IGRmatrix matrix, GRobjid *my_id, struct IGRarc *arc, IGRchar **absgptr));

#if defined(__cplusplus)
}
#endif


#undef __
