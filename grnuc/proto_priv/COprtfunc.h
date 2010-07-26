#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/partco/COprtfunc.I */
extern IGRint COpartslist_get_template __((struct GRid *partslist_id, IGRchar *partslist_dir, struct GRid *line_id, IGRint *line_no, IGRint *template));
extern IGRint COpartslist_get_line_info __((struct GRid *line_id, struct GRid *block, struct GRid *text, IGRint *num_texts, struct GRid *divider, IGRint *num_dividers));
extern IGRint COpartslist_add_line __((IGRint *msg, struct GRmd_env *mod_env, struct GRid *partslist_id, IGRchar *part_number, struct GRid *line_id, IGRint *line_no));
extern IGRint COpartslist_add_info __((IGRint *msg, struct GRmd_env *mod_env, struct GRid *line_id, IGRchar **format, IGRchar **just, IGRchar **value, IGRint num_cols));
extern int COpart_pass_func __((IGRint *msg, OM_p_MESSAGE pass_msg, struct GRmd_env *mod_env, GRobjid senderid, GRspacenum senderos, IGRchar *catalog, IGRchar *number, IGRchar *revision));

#if defined(__cplusplus)
}
#endif


#undef __
