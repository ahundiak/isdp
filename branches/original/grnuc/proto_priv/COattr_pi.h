#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/attrib/COattr_pi.I */
extern int COattr_router __((int form_label, int label, double value, char *form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
