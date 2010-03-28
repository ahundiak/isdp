#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGEcolor/igecolmac.I */
extern IGRint IGEcnctclrtab __((IGRint type, GRobjid app_id, GRspacenum app_osnum, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEchgclrtab __((IGRshort num_colors, IGRchar *colors, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEmodclrtab __((IGRshort start_color, IGRshort num_colors, IGRchar *colors, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEchgresclr __((IGRchar *fg_color, IGRchar *bg_color, IGRchar *hilite_color, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEchgclrnam __((IGRshort num_names, struct IGEcol_names *names, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEdelclrnam __((IGRshort num_names, IGRint *name_indexes, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEreadclrtab __((IGRshort *num_colors, IGRchar *colors, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEreadresclr __((IGRchar *fg_color, IGRchar *bg_color, IGRchar *hilite_color, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEreadclrnam __((IGRshort *num_names, struct IGEcol_names *names, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGErdphytab __((IGRint screen_no, IGRshort *num_slots, struct vlt_slot *vlt_slots, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetnmfrclr __((IGRshort color, IGRchar *name, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetclrfrnm __((IGRchar *name, IGRshort *color, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetabsclrindx __((IGRint screen_no, IGRshort log_color, IGRshort *abs_color, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetrgbvalue __((IGRint screen_no, IGRshort log_color, IGRchar *rgb_value, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetnumactcol __((IGRint screen_no, IGRshort *num_colors, IGRint type));
extern IGRint IGEconclrtab __((GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEget_col_id __((GRobjid modid, GRspacenum modos, GRobjid *clr_id));

#if defined(__cplusplus)
}
#endif


#undef __
