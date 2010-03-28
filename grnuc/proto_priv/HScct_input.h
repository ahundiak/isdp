#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cct/HScct_input.I */
extern char *CCTget_text __((Form fp, int g_label));

#if defined(__cplusplus)
}
#endif


#undef __
