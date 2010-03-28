#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/form_glob.I */
extern int main __((void));
extern int DMkeyin_desc_print __((void));

#if defined(__cplusplus)
}
#endif


#undef __
