#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUbsfuncs.C */
extern IGRlong GUbsp_format __((IGRshort *status, IGRshort *elebuf, IGRshort *ndices, struct GUcontrol_struct *inbuf, int insiz));
static IGRlong GUbsp_format21 __((IGRshort *elebuf, IGRshort *ndices, struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format24 __((IGRshort *elebuf, int ndices, struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format25 __((IGRshort *elebuf, IGRshort *ndices, struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format26 __((IGRshort *elebuf, IGRshort *ndices, struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format27 __((IGRshort *elebuf, IGRshort *ndices, struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format28 __((IGRshort *elebuf, int ndices, struct GUcontrol_struct *inbuf));
extern int GUbsp_i4tor8 __((IGRshort *ndices, IGRshort *i4buf, IGRshort *num_points, IGRdouble r8buf[][3 ]));
static GUbsp_vperiodicexpand __((struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_knotld __((IGRlong *n, IGRshort iknot[], IGRdouble rknot[]));
extern IGRlong GUbsp_bufsize __((IGRshort *elebuf, IGRshort *datflg, IGRlong *size));

#if defined(__cplusplus)
}
#endif


#undef __
