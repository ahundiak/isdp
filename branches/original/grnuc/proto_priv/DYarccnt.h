#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/arc/DYarccnt.I */
extern int DYarccnt __((struct dyn_arc *arc_info, struct EX_button *pt, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers));
extern IGRlong DYrbarccnt __((struct GRevent *Events[], struct IGRdisplay *dis_attr));

#if defined(__cplusplus)
}
#endif


#undef __
