#ifndef  __PALpdmrpro_h
#define __PALpdmrpro_h

#if defined(__STDC__) || defined(__cplusplus)
#define __PDU(s) s
#else
#define __PDU(s) ()
#endif


/* CID.c */
extern int FreeConditionTable __PDU((char **conditions, char **assignments, int no_conds, int no_assigns));
extern int GetCondition __PDU((char *source, char ***conditions, int no_conds));
extern int GetAssignment __PDU((char *source, char ***assignments, int no_assigns, char *LHS, int param_index));
extern int MakeConditionTable __PDU((char *cond_assign_str, char *lhs, char ***conditions, char ***assignments, int *no_conditions));
extern int EvaluateCondition __PDU((char *condition));
extern int GetParamIndex __PDU((char *columnname, int *index));
extern int DLExpression __PDU((int oper_type, char *operator, char *condition, int *retval));
extern int DLStringExpression __PDU((char *operator, char *condition, int *retval));
extern int GetID_N_Compute __PDU((char *catname, char **attrs, char **vals, char **types, int numattrs, char **computed_id, int flag));
extern int GetattrsGivenID __PDU((char *computed_id, char *catname));
extern int GetPartnumberDesc_PDMNORM __PDU((char *catname, char **attr, char **attrtype, char **vals, int numattr, char **partnum_desc));
extern int GetPartnumberDesc __PDU((char *catname, char **attr, char **attrtype, char **vals, int numattr, char **partnum_desc));
extern int PosMarkers __PDU((char *inpattn, char **outpattn, int flg));
/* PDMgetcat.c */
extern int GetDepthofCatalog __PDU((char *catname, int *p_depth));
extern int GetCatPath __PDU((char *catname, int p_depth, char **catpath));
/* PDMgetstat.c */
extern int GetUniqRecord __PDU((char *catalog, char *partid, char *revision, char *attributes[], int no_attributes, char **output));
extern int GetStaticAttribsAddToRgObj __PDU((struct GRid *hdr, char **attribslist, char **attr_types, char **attunits, int no_attributes, struct GRid *rg_grids));
extern int ComputeIDAddToDynCol __PDU((char *catname, struct GRid *rggrid));
extern int getattrs __PDU((char *catname, char *string, char *computed_id));
extern int check_CID __PDU((char *catalogname, struct GRid *acdyncolobj));
/* PDMrsrch.c */
extern int CleanUpSlctdAttribs __PDU((void));
extern int RebuildShortList __PDU((Form fp, int mcf));
extern int UpdateShortList __PDU((Form fp, int glabel, int row, int sel_flg));
extern int ParamSearchOnMultipleCtlgs __PDU((Form fp, int mcf, int row, int col));
extern int do_search __PDU((Form fp, int mcf, char *table_name, int row, int col, char **output_str, char **AttrList, char **AttrSynonym, char **AttrTypes, int NumAttribs, int *total_ent));
extern int where_condition_line __PDU((Form fp, int mcf, char **query_string, int row, char *ordering_type, int *rows_to_retrv, char **AttrList, char **AttrSynonym, char **AttrTypes, int NumAttribs));
extern int search_on_multiple_ctlgs __PDU((Form fp1, int mcf, Form fp2, int cat_field));
extern int do_global_search __PDU((Form fp1, int mcf, Form fp2, char *table_name, MEMptr *data_bufr, char **AttrList, char **AttrSynonym, char **AttrTypes, int NumAttribs));
extern int gen_condition_line __PDU((Form fp, int mcf, char **query_string, char *table_name, char **AttrList, char **AttrSynonym, char **AttrTypes, int NumAttribs));
extern int validate_search_criteria_input __PDU((char *oper, char **str));
extern int PDUgetDefPlcmntName __PDU((char **defname, char *catname));
extern int CnvtOperNCriteriaToCondition __PDU((Form fp, int glabel, int row, int rowfromout, int *rows_to_retrv, char **condition, char *ordering_type, char **AttrTypes, int NumAttribs));
extern int build_and_cond __PDU((char **criteria, int row));
extern int GetTheseGivenThose __PDU((char *catalog, char **these, char ***these_val, int no_these, char **those, char **those_type, char **those_val, int no_those));
extern int format_searchlist_bufr __PDU((MEMptr lcl_bufr));
extern int add_bufr_to_global_buffer __PDU((char *catname, MEMptr lcl_bufr));
extern int pdutimestamp_to_ascii __PDU((char *str));
extern int PALgetPartType __PDU((char *catalog, char *partid, char *revision, char **parttype));
/* PDMsrcatr.c */
extern int search_common_attribs __PDU((Form fp, MEMptr out_buffr));
extern int PALgetcatlist __PDU((Form fp, MEMptr out_bufr, int *numcat, char **catlist, int flag));
extern int GetCatTableNo __PDU((char *cat_name, int *tbl_no, char *viewORtable));
extern int SearchAttribsAcrossCatalogs __PDU((void));
extern int GetCatAttribs __PDU((int table_no, char ***list_of_attr, char ***attr_desc, char ***attr_type, int *no_of_attrs));
extern int GetCatalogDesc __PDU((char *catalog_name, char **catalog_desc));
extern int get_macro_name __PDU((char *macname, char *catname, Form fp, int glabel, int col));
extern int GetMacroName __PDU((Form fp, int glabel, int attr_col, int val_col, char *cat_name, char *mac_name));


#undef __PDU
#endif    /* __PALpdmrpro_h */
