#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRretcellib.C */
extern IGRint GRretrieve_cell_library __((IGRchar filename[], IGRint *file_no, IGRint fstat, IGRint flag, IGRint *file_access, GRspacenum *mod_osnum));
extern IGRint GRclose_cell_library __((IGRint file_no, IGRint flag));
extern IGRint GRsave_cell_library __((IGRint file_no));

#if defined(__cplusplus)
}
#endif


#undef __
