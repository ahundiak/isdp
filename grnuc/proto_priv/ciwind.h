#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/ciwind.C */
extern int CIcreate_wind __((char *title));
extern int CIwrite_wind __((int nl, char *txt));
extern int CIescape_win __((void));

#if defined(__cplusplus)
}
#endif


#undef __
