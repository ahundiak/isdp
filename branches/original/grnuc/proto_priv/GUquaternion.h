#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUquaternion.C */
extern int GUquat_to_rotmx __((IGRdouble quat[], IGRdouble rotmx[]));
extern int GUrotmx_to_quat __((IGRdouble rotmx[], IGRdouble quat[]));

#if defined(__cplusplus)
}
#endif


#undef __
