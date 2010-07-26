#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotxtesc.I */
extern IGRchar GUotxtesc __((IGRboolean *initial_call, IGRboolean *convert, struct GRmd_env *md_env, IGRchar **text_string, IGRmatrix matrix, struct IGRestx *text_attr, struct vfont_entry *fontinfo, struct GRsymbology *symbology, IGRdouble *igds_origin, GRrange igds_range, IGRchar **igds_string));

#if defined(__cplusplus)
}
#endif


#undef __
