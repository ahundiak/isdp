#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GUprocessplo.I */
extern IGRint GUprocessplot __((IGRlong *msg, struct GRid *graphics_object, IGRchar *func_info));
extern int GUgetfunc_info __((IGRlong *msg, IGRchar **ptr));

#if defined(__cplusplus)
}
#endif


#undef __
