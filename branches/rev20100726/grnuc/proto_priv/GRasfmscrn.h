#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/palgo/GRasfmscrn.C */
extern IGRint GRassign_form_screen __((Form existing_form, Form form_to_assign));

#if defined(__cplusplus)
}
#endif


#undef __
