#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cifiget.I */
static int CIform_id __((char *name, Form *id));
extern int CIgetform __((long *stat, char *form, struct FI_data_st *data));

#if defined(__cplusplus)
}
#endif


#undef __
