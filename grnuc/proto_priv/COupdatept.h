#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/forms/COupdatept.I */
extern IGRlong COupdate_current_point_form __((IGRlong *ReturnMsg, IGRint Flag));

#if defined(__cplusplus)
}
#endif


#undef __
