#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/DYcspoint.I */
extern IGRint DYrbcspt __((struct IGRdisplay *display, struct GRmd_env *md_env));
extern IGRint DYcspt __((struct cs_point_header *info_para, struct EX_button *point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
