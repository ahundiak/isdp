#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro/nci_macroi.I */
extern int get_conn_surf __((struct GRid solid, OM_S_OBJID *surf_list_id, short *surf_list_os));
extern int get_surf_at_index __((struct GRid solid, int ix, struct GRid *surf_id));
extern int get_index_of_surf __((struct GRid solid, int *ix, struct GRid surf_id));

#if defined(__cplusplus)
}
#endif


#undef __
