#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* src_datum/imp/EFrefpln.I */
extern int EFref_plane_lock __((IGRlong *msg, unsigned int options, 
        IGRint *mode)); 

extern void GRdisplay_refpln_symbol __((int on));

extern int EFconstruction_plane_on __((IGRlong *msg, unsigned int options,
        IGRdouble *inmx)); 

extern int EFref_pln_lock_onoff __((IGRlong *msg, unsigned int options));

#if defined(__cplusplus)
}
#endif


#undef __
