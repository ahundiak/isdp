#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/ci_mac_sp.c */
extern int ci_mac_def_OMPORT_ci_mac_def __((int classid, char *ME, struct ci_mac_def_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
