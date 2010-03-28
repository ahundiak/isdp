#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/ACpreroot_sp.C */
extern int ACpreroot_OMPORT_ACpreroot __((int classid, char *ME, struct ACpreroot_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
