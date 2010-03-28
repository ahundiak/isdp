#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/GRtext_sp.c */
extern int GRtext_OMPORT_GRtext __((int classid, char *ME, struct GRtext_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
