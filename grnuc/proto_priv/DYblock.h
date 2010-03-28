#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/poly/DYblock.I */
extern IGRint DYblock __((struct block_st *block_data, struct EX_button *pnt2, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *dummy1, IGRchar *dummy2, IGRchar *dummy3, IGRchar **dummy4, IGRchar **dummy5, IGRchar **dummy6));
extern IGRlong DYrbblock __((struct GRevent *Events[], struct IGRdisplay *dis_attr));

#if defined(__cplusplus)
}
#endif


#undef __
