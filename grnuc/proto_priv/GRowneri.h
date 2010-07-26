#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ownergo/GRowneri.I */
extern int IGRboolean __((*eligfunc));
static IGRboolean elig_chk __((GRobjid my_id, GRspacenum my_os, OM_p_CLASSLIST yes_classes, OM_p_CLASSLIST no_classes, IGRboolean (*eligfunc )(), IGRchar *eligfunc_args));
extern IGRboolean GRclass_eligible __((GRclassid classid, OM_p_CLASSLIST classlist));

#if defined(__cplusplus)
}
#endif


#undef __
