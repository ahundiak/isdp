#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dppystrk.C */
extern IGRboolean DPpystrk __((
   IGRint *message,
    struct IGRpolyline *line_str,
    struct IGResps *ele_attr,
    struct IGRdisplay *dis_attr,
    IGRint gpipe_id,
    IGRint flags,
    IGRint disp_flags,
    IGRint blend,
    int draw_opt ));

#if defined(__cplusplus)
}
#endif


#undef __
