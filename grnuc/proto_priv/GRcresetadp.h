#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRcresetadp.C */
extern IGRint GRcreate_setadp __((IGRlong *msg, IGRint create, Form *form_ptr));
extern IGRint GRdelete_setadp __((void));

#if defined(__cplusplus)
}
#endif


#undef __
