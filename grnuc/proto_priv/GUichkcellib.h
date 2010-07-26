#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUichkcellib.C */
extern IGRint GUicheck_cellib __((IGRint *msg, IGRint *file_des));

#if defined(__cplusplus)
}
#endif


#undef __
