#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cichannel.C */
extern int CIget_channel_objects __((struct ci_instruction *func, int *response, char *response_data, int pos));

#if defined(__cplusplus)
}
#endif


#undef __
