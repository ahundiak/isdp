#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cipush.C */
extern int CIpush __((int argc, CIpushlist *argv));

#if defined(__cplusplus)
}
#endif


#undef __
