#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/DYarc_p.I */
extern int DYarc_p __((struct dyn_arc *arc_info, struct EX_button *point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern IGRint DYrbarc_p __((struct ret_struct *pt1, struct ret_struct *pt2, struct ret_struct *pt3, IGRboolean cntr_clk, IGRdouble view[], struct IGRdisplay *sym));
extern int ASarc_para_param __((struct ret_struct *point1, struct ret_struct *point2, struct ret_struct *point3, IGRboolean cntr_clk, IGRdouble *point, IGRdouble *view_vect, IGRdouble *first_view_vector, IGRdouble *snap, IGRdouble *param_val));

#if defined(__cplusplus)
}
#endif


#undef __
