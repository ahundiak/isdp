#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRcreadp.C */
extern IGRint GRcreate_adp __((IGRlong *msg, IGRint create, Form *form_ptr));
extern IGRint GRdelete_adp __((void));

#if defined(__cplusplus)
}
#endif


#undef __
