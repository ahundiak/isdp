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

/* VLrpDataFunk.I */
IGRlong VLfillBalanceData __((IGRint num, struct GRobj_env List[], struct VLsortTpl **Sort, IGRlong *msg));
IGRlong VLfillPinjig1 __((struct GRobj_env *Lst, IGRint *npin, IGRint *ncrn, VLpinCorn **Corn, IGRint *npnl, VLpinCorn **Panl, struct ACrg_coll **Data, IGRpoint H1V1, IGRlong *msg));
IGRlong VLfillPinjig2 __((struct GRobj_env *Lst, IGRint idx, IGRpoint H1V1, struct ACrg_coll *Data, IGRlong *msg));
IGRlong VLfillChtTemplateData __((struct GRobj_env *List, IGRint *nobj, VLpltTpl **Reg, VLpltTpl **Spi, IGRlong *msg));
IGRlong VLfillHeiTemplateData1 __((struct GRobj_env *List, IGRint *ntpl, VLpltTpl **Tpl, IGRlong *msg));
IGRlong VLfillHeiTemplateData2 __((struct GRobj_env *List, IGRdouble step, VLpltTpl *Tpl, IGRint *nval, IGRdouble **Val, IGRlong *msg));
IGRlong VLcomputeTemplateHeights __((struct GRid *Tpl, struct GRmd_env *Env, IGRdouble step, IGRint *nval, IGRdouble *Val[], IGRlong *msg));
IGRlong VLcomputeBendLineHeights __((struct GRobj_env *Lin, struct GRobj_env *List, IGRdouble step, IGRint *nval, IGRdouble *Val[], IGRlong *msg));
IGRlong VLfillSteelBand __((struct GRobj_env *Lst, VLsteelBandInfo *Info, VLsteelBandData **Data, IGRlong *msg));
IGRdouble KLgetDistance __((struct GRid *foot, IGRchar *name));
IGRchar *KLgetName __((struct GRid *foot, IGRchar *name));
IGRint VLsortKLdata __((VLkeyLineData *a, VLkeyLineData *b));
IGRboolean VLcompKLdata __((VLkeyLineData *a, VLkeyLineData *b));
void VLcopyKLdata __((VLkeyLineData *to, VLkeyLineData *fr));
IGRboolean VLduplicateKLdata __((IGRint *n, VLkeyLineData **D));
IGRlong VLgetKLinfo __((struct GRobj_env *Lst, VLkeyLineInfo *Info, IGRlong *msg));
IGRlong VLfillKeyLine __((struct GRobj_env *Lst, VLkeyLineInfo *Info, VLkeyLineData **Tran, VLkeyLineData **Long, VLkeyLineData **Diag, IGRlong *msg));
void VLsprintfKLmatrix __((VLkeyLineInfo *Info, IGRchar **Matrix, IGRint nRow, IGRint nCol, IGRchar *FileName, IGRint idx, IGRchar *TableName));

/* VLrpExecFunk.I */
IGRint VLvl_report_LoadKeyWords __((void));
IGRlong VLexecBalanceList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecPinjigList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecChtTemplateList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecHeiTemplateList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecHeiBendStfnrList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecStrechValList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecSteelBandList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecKeyLineList __((IGRint num, struct GRobj_env List[], struct GRmd_env *Env, VSfileFormInfo file, IGRchar *setup, IGRlong *msg));
IGRlong VLexecKeyLineMatrix __((IGRint num, struct GRobj_env Lst[], IGRlong *msg));

/* VLrpToolFunk.I */
IGRdouble VLgetFootValue __((struct GRid *oobject, IGRchar Footname[]));
IGRlong VLgetHeights __((struct GRmd_env *Env, struct GRid *Crv, IGRdouble *spt, IGRdouble *ept, IGRdouble step, IGRdouble *dir, IGRdouble *ort, struct IGRbsp_curve *crv, IGRint *nhei, IGRdouble *Hei[], IGRlong *msg));
IGRlong VLextractBendedLines __((struct GRobj_env *Occ, IGRint *nlin, struct GRobj_env *Lin[], IGRlong *msg));
IGRlong VLgetSteelBandInformation __((struct GRobj_env *Occ, IGRchar *band, IGRchar *unit, IGRchar *desc, IGRchar *jobN, IGRdouble *stock, IGRdouble *endstock, IGRlong *msg));
IGRlong VLgetSteelBandAttributes __((struct GRobj_env *Occ, IGRint idx, IGRint *index, IGRchar *name, IGRdouble *distance, IGRlong *msg));

/* VLrpUserFunk.I */
int IMPLEMENT_FUNCTION __((int VL, int print));
int IMPLEMENT_FUNCTION __((int VL, int skip));
int IMPLEMENT_FUNCTION __((int VL, int getBidx));
int IMPLEMENT_FUNCTION __((int VL, int getBnam));
int IMPLEMENT_FUNCTION __((int VL, int getBxan));
int IMPLEMENT_FUNCTION __((int VL, int getByan));
int IMPLEMENT_FUNCTION __((int VL, int getBzan));
int IMPLEMENT_FUNCTION __((int VL, int getBnum));
int IMPLEMENT_FUNCTION __((int VL, int getPnam));
int IMPLEMENT_FUNCTION __((int VL, int getPpin));
int IMPLEMENT_FUNCTION __((int VL, int getPcrn));
int IMPLEMENT_FUNCTION __((int VL, int getCnam));
int IMPLEMENT_FUNCTION __((int VL, int getCxpt));
int IMPLEMENT_FUNCTION __((int VL, int getCypt));
int IMPLEMENT_FUNCTION __((int VL, int getChei));
int IMPLEMENT_FUNCTION __((int VL, int getCpin));
int IMPLEMENT_FUNCTION __((int VL, int getJcol));
int IMPLEMENT_FUNCTION __((int VL, int getJlin));
int IMPLEMENT_FUNCTION __((int VL, int getJxpt));
int IMPLEMENT_FUNCTION __((int VL, int getJypt));
int IMPLEMENT_FUNCTION __((int VL, int getJzpt));
int IMPLEMENT_FUNCTION __((int VL, int getJhei));
int IMPLEMENT_FUNCTION __((int VL, int getJang));
int IMPLEMENT_FUNCTION __((int VL, int getJidx));
int IMPLEMENT_FUNCTION __((int VL, int getJnam));
int IMPLEMENT_FUNCTION __((int VL, int getTnam));
int IMPLEMENT_FUNCTION __((int VL, int getTcht));
int IMPLEMENT_FUNCTION __((int VL, int getTang));
int IMPLEMENT_FUNCTION __((int VL, int getTlea));
int IMPLEMENT_FUNCTION __((int VL, int getThei));
int IMPLEMENT_FUNCTION __((int VL, int getSnam));
int IMPLEMENT_FUNCTION __((int VL, int getSfra));
int IMPLEMENT_FUNCTION __((int VL, int getScht));
int IMPLEMENT_FUNCTION __((int VL, int getShei));
int IMPLEMENT_FUNCTION __((int VL, int setHstp));
int IMPLEMENT_FUNCTION __((int VL, int getHocc));
int IMPLEMENT_FUNCTION __((int VL, int getHsub));
int IMPLEMENT_FUNCTION __((int VL, int getHstp));
int IMPLEMENT_FUNCTION __((int VL, int getHhei));
int IMPLEMENT_FUNCTION __((int VL, int getU));
int IMPLEMENT_FUNCTION __((int VL, int getV));
int IMPLEMENT_FUNCTION __((int VL, int getStrVal));
int IMPLEMENT_FUNCTION __((int VL, int getChamf));
int IMPLEMENT_FUNCTION __((int VL, int getSBband));
int IMPLEMENT_FUNCTION __((int VL, int getSBunit));
int IMPLEMENT_FUNCTION __((int VL, int getSBdesc));
int IMPLEMENT_FUNCTION __((int VL, int getSBjobN));
int IMPLEMENT_FUNCTION __((int VL, int getSBnumP));
int IMPLEMENT_FUNCTION __((int VL, int getSBidx));
int IMPLEMENT_FUNCTION __((int VL, int getSBnam));
int IMPLEMENT_FUNCTION __((int VL, int getSBdst));
int IMPLEMENT_FUNCTION __((int VL, int getKLunit));
int IMPLEMENT_FUNCTION __((int VL, int getKLjobN));
int IMPLEMENT_FUNCTION __((int VL, int getKLpro));
int IMPLEMENT_FUNCTION __((int VL, int getKLlin));
int IMPLEMENT_FUNCTION __((int VL, int getKLnam));
int IMPLEMENT_FUNCTION __((int VL, int getKLdst));

#if defined(__cplusplus)
}
#endif

