#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/GRlnterm_sp.c */
extern int GRlnterm_OMPORT_GRlnterm __((int classid, char *ME, struct GRlnterm_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
