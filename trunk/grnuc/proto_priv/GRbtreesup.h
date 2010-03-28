#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRbtreesup.I */
extern IGRint GRbtreeadd __((IGRlong *msg, IGRint num_spaces, GRspacenum *p_OSNUMS, IGRchar *btreename, IGRchar *objectname, GRobjid *objid));
extern IGRint GRbtreeremove __((IGRlong *msg, IGRint num_spaces, GRspacenum *p_OSNUMS, IGRchar *btreename, IGRchar *objectname, GRobjid *objid));
extern IGRint GRbtreelocate __((IGRlong *msg, IGRint num_spaces, GRspacenum *p_OSNUMS, IGRchar *btreename, IGRchar *objectname, OM_S_OBJARRAY *objarray, GRspacenum *loc_OS));
extern IGRint GRbtreelocate_all __((IGRlong *msg, GRspacenum osnum, IGRchar *btreename, OM_p_BTREE_CONTENTS objects, IGRint start, IGRint size, IGRint *count));
extern IGRint GRbtreecount __((IGRlong *msg, GRspacenum osnum, IGRchar *btreename, IGRint *count));
extern IGRint GRget_btree __((IGRlong *msg, IGRchar btreename[], GRspacenum osnum, GRobjid *btree_objid));

#if defined(__cplusplus)
}
#endif


#undef __
