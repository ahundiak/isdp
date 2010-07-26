#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/GRds_sp.c */
extern int GRds_OMPORT_GRds __((int classid, char *ME, struct GRds_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
