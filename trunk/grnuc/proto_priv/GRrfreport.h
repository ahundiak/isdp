#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRrfreport.I */
extern IGRint GRreffile_reports __((IGRlong *msg, struct GRmd_env *env, IGRuint report_mask, struct GRreport_info *report_info, IGRboolean pass));
extern IGRint GRreffile_report __((IGRlong *msg, struct GRinquire_list *requests, struct GRreport_info *report_info, IGRint *nest));
extern IGRint GRreffile_report_output __((IGRint *msg, IGRint num, IGRint depth, struct GRinquire_list *requests, FILE **fp));

#if defined(__cplusplus)
}
#endif


#undef __
