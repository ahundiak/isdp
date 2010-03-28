#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/GRdpb_sp.c */
extern int GRdpb_OMPORT_GRdpb __((int classid, char *ME, struct GRdpb_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
