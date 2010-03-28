#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/CObuildpt.C */
extern IGRlong CObuild_button __((IGRlong *msg, IGRdouble x, IGRdouble y, IGRdouble z, IGRlong window, OM_S_OBJID objid, uword osnum, IGRshort numb, IGRshort clicks, IGRshort button_down, struct EX_button *button));

#if defined(__cplusplus)
}
#endif


#undef __
