#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* LocateByName.I */
IGRboolean LBNcheckInput __((IGRchar *string, IGRint length, IGRchar *txtset));
IGRboolean LBNexpandInput __((IGRchar *string, IGRchar ***yLst, IGRuint *yMax, IGRchar ***nLst, IGRuint *nMax, IGRlong *msg));
void LBNdealloc __((IGRuint cnt, IGRchar ***buf));
IGRboolean LBNfindAttach __((IGRchar *event, IGRchar *attach, struct GRmd_env *Env, struct GRid *object));
IGRlong LBNlocateObject __((IGRchar *event, struct GRmd_env *Env, IGRchar *Path, IGRchar *attach, IGRint *count, IGRint *number, struct GRobj_env **object, IGRlong *msg));
IGRlong LBNconstructList __((IGRuint Pnum, IGRchar **Plst, IGRuint Enum, IGRchar **Elst, IGRuint Snum, IGRchar **Slst, struct GRmd_env *Env, IGRchar *Path, IGRchar *attach, IGRint *number, struct GRobj_env **object, IGRlong *msg));
IGRlong VDlocate_by_name __((IGRlong *msg, IGRchar *prefix, IGRchar *select, IGRchar *suffix, IGRchar *attach, IGRint *number, struct GRobj_env **object));

/* VdsQuery.I */
IGRlong VDQbuildQuery __((IGRlong *msg, IGRint where, IGRchar *types, IGRchar *condition, struct GRid *query));
IGRboolean VDQvalidate __((struct GRid *obj));
void VDQscanObjectSpace __((struct GRmd_env *Env, IGRint *numObj, struct GRobj_env **Obj));
void VDQreferenceFiles __((struct GRmd_env *Env, OM_S_CHANSELECT Channel, IGRint *numObj, struct GRobj_env **Obj));
IGRlong VDQeligibleList __((struct GRmd_env *CurEnv, IGRboolean ref_search, IGRint *numObj, struct GRobj_env **Obj));
IGRlong VDvds_query __((IGRlong *msg, IGRchar *types, IGRint where, IGRchar *condition, IGRboolean ref_search, IGRint *number, struct GRobj_env **object));

#if defined(__cplusplus)
}
#endif

