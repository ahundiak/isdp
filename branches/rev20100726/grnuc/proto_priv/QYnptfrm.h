#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/query/sl/QYnptfrm.I */
extern void KLUDGY_FUNC_TO_PUT_STRING_ON_RECALL_LIST __((char *string));
extern void QYclear_list __((Form fp, int label));
extern int QYis_string_on_list __((Form fp, int label, char *s));

#if defined(__cplusplus)
}
#endif


#undef __
