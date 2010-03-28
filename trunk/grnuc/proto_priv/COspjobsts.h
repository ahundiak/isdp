#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COspjobsts.C */
extern int COspjobsts __((char *jobq, char *jobid, char *jobname, char *outbuf));
extern int COspckjobsts __((char *jobq, char *jobid, char *jobname, char *outbuf, char *qtype, char *dset));

#if defined(__cplusplus)
}
#endif


#undef __
