#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/COgensetf.I */
extern IGRint COall __((IGRchar *string));
extern IGRint COlykytomask __((IGRint *msg, struct GRmd_env *mod, IGRchar *keyin, IGRint *mask));
extern IGRint COgenset_init_form __((Form form));
extern IGRint COpositionform __((Form form, Form subform));
extern IGRint COactgad __((IGRchar *buf, Form form, IGRuchar *mask, IGRint mask_size, IGRint symb, IGRint lo, IGRint hi, OMuword osnum, IGRint form_label, IGRint first_label, IGRint last_label));
extern IGRint COgadtostr __((Form form, IGRint form_label, IGRint first_label, IGRint last_label, IGRchar *buf));

#if defined(__cplusplus)
}
#endif


#undef __
