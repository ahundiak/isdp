#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/COcvtype5lv3.I */
extern IGRint COcvt_type5lv3 __((IGRlong *msg, struct IGDS_saved_view *view, IGRint *db_type, IGRdouble *scale_factor, struct GRid *object_info));

#if defined(__cplusplus)
}
#endif


#undef __
