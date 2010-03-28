#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/query/sl/QYnames.I */
extern int QYget_class_names __((char ***names, int *count));
static my_strcmp __((char **p_st1, char **p_st2));
extern int QYget_macro_names __((char ***names, int *count));
extern int QYget_feet __((char ***feet_names, int *count, char **names, int mac_count));

#if defined(__cplusplus)
}
#endif


#undef __
