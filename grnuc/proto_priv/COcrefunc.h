#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COcrefunc.I */
extern IGRint COcreate_plotfile __((IGRlong *msg, IGRint filetype, struct GRmd_env *mod, IGRchar *dbtype, IGRdouble *range, struct GRid *window, struct IGRcv_prism *cvprism, IGRchar *filename, IGRchar *seedfile, IGRchar *color_table, IGRint color_index, IGRint (*filter_function )(), IGRchar *filter_data, IGRchar *buffer));
extern IGRint COplot_get_window_range __((IGRlong *msg, struct GRevent *event, struct GRid *window, IGRdouble *world, IGRdouble *view));

#if defined(__cplusplus)
}
#endif


#undef __
