#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/GRvar_sp.c */
extern int GRvar_OMPORT_GRvar __((int classid, char *ME, struct GRvar_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
