#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/raster/RSstubs.c */
extern int RSstroke __((void));
extern int GRrsloadctb __((int *sts, GRobjid *objectid, GRspacenum *osnum));
extern int RSget_tc_vlt __((void));
extern int RSstub_file __((void));
extern int RSis_true_color __((void));
extern int COcvigdsige_COcvigdsige_cvt_type8788_method __((void));

#if defined(__cplusplus)
}
#endif


#undef __
