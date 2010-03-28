#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/vg/GRvgrptout.I */
extern IGRboolean GRreport_output __((IGRlong *msg, IGRchar *report_info, IGRchar *report_file, GRobjid *my_id, IGRint report_list_size, struct GRreport_item *report_list));

#if defined(__cplusplus)
}
#endif


#undef __
