#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/ACroot_sp.C */
extern int ACroot_OMPORT_ACroot __((int classid, char *ME, struct ACroot_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
