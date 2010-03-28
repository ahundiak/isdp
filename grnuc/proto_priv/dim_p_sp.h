#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/transos/dim_p_sp.c */
extern int dim_param_OMPORT_dim_param __((int classid, char *ME, struct dim_param_instance *me));

#if defined(__cplusplus)
}
#endif


#undef __
