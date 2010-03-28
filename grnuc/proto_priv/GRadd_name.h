#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GRadd_name.C */
extern IGRboolean GRadd_name_to_buf __((IGRlong *msg, IGRboolean *has_name, IGRchar *name, IGRchar *ele_buf));

#if defined(__cplusplus)
}
#endif


#undef __
