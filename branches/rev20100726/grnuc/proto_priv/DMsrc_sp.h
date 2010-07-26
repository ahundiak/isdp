#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/DMsrc_sp.c */
extern int DMsrc_OMPORT_DMsrc __((int classid, char *ME, struct DMsrc_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
