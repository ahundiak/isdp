#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/COdtlrev.I */
extern int COrevref_output __((IGRint *msg, IGRint num, IGRint depth, struct GRinquire_list *requests, struct COform_info *info));
extern int COdetail_review_notify __((int form_label, int gadget_label, double value, Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
