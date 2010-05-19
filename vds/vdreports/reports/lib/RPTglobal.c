#include <sqlfm.h>
char *_FMfirst_form;
#include <sqlhdr.h>
static _SQCURSOR _SQ8, _SQ7, _SQ6, _SQ5, _SQ4, _SQ3, _SQ2, _SQ1;

#include <decimal.h>
#include <locator.h>
#include <datetime.h>
#include <stdio.h>
#include <fglrep.h>
extern struct
  {
    long sqlcode;
    char sqlerrm[72];
    char sqlerrp[8];
    long sqlerrd[6];
    char sqlawarn[8];
  }  sqlca;
extern int status;
extern int efcode;
extern int _expcode;
extern short _anyerr;
extern int int_flag;
extern int quit_flag;
short drawing_flag;
short eq_unit_flag;
char joker[3];
char errorlog_msg[133];
char nsts_err_msg[81];
char underline[81];
char q_stmt[10001];
char s_stmt[2001];
char f_stmt[2001];
char w_stmt[5001];
char g_stmt[2001];
char o_stmt[2001];
char w_reg[5001];
char f_reg[1001];
struct
  {
    char prj_number[17];
    char prj_name[41];
    char prj_location[41];
    short prj_units_set;
    short prj_no;
  }  p_vds;
char rpt_req[4];
char rpt_dsc1[41];
char rpt_dsc2[41];
double def_vcog;
double def_lcog;
double def_tcog;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_bm;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_bm;
struct
  {
    char f_part_num[31];
    char material[13];
    char grade[13];
    long grp_num;
    float grp_len;
    float grp_srf;
    float grp_vol;
    char short_txt[9];
    float density;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_bmb;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_rev[13];
    char item_no[13];
    long comp_seqno;
  }  p_bmd1[5000];
struct
  {
    char f_part_num[31];
    char material[13];
    char grade[13];
    long grp_num;
    float grp_len;
    float grp_srf;
    float grp_vol;
    char short_txt[9];
    float density;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
    char end0[16];
    char end1[16];
  }  p_bmd2;
struct
  {
    char material[13];
    char grade[13];
    float volume;
    char f_part_num[31];
    char constr_stat[9];
    short chg_no;
    char long_txt[81];
    float density;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_bmn;
struct
  {
    short chg_no;
    long comp_seqno;
    short weight_grp;
    char f_part_num[31];
    float bm_len;
    float bm_vol;
    double cog_x;
    double cog_y;
    double cog_z;
    char material[13];
    char grade[13];
    char long_txt[81];
    float density;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_bmw;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_eq;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_eq;
struct
  {
    char eqp_type[13];
    char eqp_number[21];
    char eqp_descr[41];
    char eqp_partno[31];
  }  p_eqb;
struct
  {
    short chg_no;
    char eqp_number[21];
    char eqp_partno[31];
    char eqp_descr[41];
    float wet_weight;
    char long_txt[81];
  }  p_eqn;
struct
  {
    short chg_no;
    short weight_grp;
    long comp_seqno;
    char eqp_number[21];
    char eqp_partno[31];
    char eqp_descr[41];
    float dry_weight;
    float wet_weight;
    double cog_x;
    double cog_y;
    double cog_z;
    char long_txt[81];
  }  p_eqw;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_hv;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_hv;
struct
  {
    char comp_descr[21];
    short comp_rptcat;
    char comp_code[7];
    float depth_g;
    float depth_r;
    float duct_length;
    char material[13];
    float duct_thk;
    float width_g;
    float width_r;
    short shape_code;
    char system_name[13];
    char category_desc[81];
    char shape_desc[81];
    long item_num;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_hvb;
struct
  {
    char spec_name[9];
    char system_name[13];
    char comp_code[7];
    float width_g;
    float depth_g;
    float width_r;
    float depth_r;
    short shape_code;
    double loc_x;
    double loc_y;
    double loc_z;
    char err_cmp_flg[2];
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_hve;
struct
  {
    char ship_alt[81];
    char shape_desc[81];
    char short_code[7];
    char material[13];
    char constr_stat[9];
    char spec_name[9];
    short chg_no;
    char comp_code[7];
    long comp_seqno;
    float depth_g;
    float depth_r;
    float duct_thk;
    float insul_thk;
    short shape_code;
    float surf_area;
    short weight_grp;
    float width_g;
    float width_r;
    float d_thk;
    float mtl_density;
    float weight_mult;
  }  p_hvn;
struct
  {
    char ship_alt[81];
    char shape_desc[81];
    char short_code[7];
    short chg_no;
    char comp_code[7];
    long comp_seqno;
    float depth_g;
    float depth_r;
    float duct_thk;
    float insul_thk;
    double loc_x;
    double loc_y;
    double loc_z;
    short shape_code;
    float surf_area;
    short weight_grp;
    float width_g;
    float width_r;
    float d_thk;
    float mtl_density;
    float weight_mult;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_hvw;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_nz;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_nz;
struct
  {
    char eqp_number[21];
    char tag_number[9];
    float npd_g;
    char rating_g[9];
    char prep_g[9];
    char seq_number[9];
    char spec_name[9];
    char insul_type[5];
    float insul_thk;
    char tracing_code[5];
    char paint_code[5];
    float op_temp;
    float op_press;
    float dgn_temp;
    float dgn_press;
    float spec_grav;
    char apprv_stat[9];
    char constr_stat[9];
  }  p_nzn;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_pl;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_pl;
struct
  {
    char material[13];
    char grade[13];
    float pl_vol;
    float pl_len;
    float pl_wid;
    float pl_thk;
    float pl_srf;
    long sum_item;
    float sum_srf;
    float sum_vol;
    char short_txt[9];
    float density;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_plb;
struct
  {
    char material[13];
    char grade[13];
    float pl_vol;
    float pl_len;
    float pl_wid;
    float pl_thk;
    char constr_stat[9];
    short chg_no;
    char long_txt[81];
    float density;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_pln;
struct
  {
    short chg_no;
    long comp_seqno;
    short weight_grp;
    float pl_thk;
    float pl_srf;
    float pl_vol;
    double cog_x;
    double cog_y;
    double cog_z;
    char material[13];
    char grade[13];
    char long_txt[81];
    float density;
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_plw;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_pp;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_pp;
struct
  {
    double bend_sweep;
    float npd_g;
    float npd_r;
    float pipe_length;
    char sch_thk_ovr[9];
    char seq_number[9];
    char commodity[21];
    char comp_code[7];
    short geom_std;
    short material;
    short prep_g;
    short prep_r;
    char rating_g[9];
    char sch_thk_g[9];
    char sch_thk_r[9];
    short spec_no;
    short comp_cat;
    char comp_descr[21];
    char end_prep_desc[81];
    char material_desc[81];
    char geom_std_desc[81];
    char category_desc[81];
    long item_num;
  }  p_ppb;
struct
  {
    float dgn_press;
    float dgn_temp;
    char fluid_code[5];
    char insul_type[5];
    float insul_thk;
    float op_press;
    float op_temp;
    char paint_code[5];
    float spec_grav;
    char spec_name[9];
    char seq_number[9];
    char tracing_code[5];
  }  p_ppd1[5000];
struct
  {
    char comp_descr[21];
    char comp_code[7];
    char comp_note[31];
    float dgn_press;
    float dgn_temp;
    char fluid_code[5];
    char insul_type[5];
    float insul_thk;
    double loc_x;
    double loc_y;
    double loc_z;
    float npd_g;
    float npd_r;
    float op_press;
    float op_temp;
    short opt_code;
    char paint_code[5];
    char sch_thk_ovr[9];
    float spec_grav;
    char spec_name[9];
    char seq_number[9];
    char tag_number[21];
    char tracing_code[5];
  }  p_ppd2;
struct
  {
    char spec_name[9];
    char seq_number[9];
    char comp_code[7];
    float npd_g;
    float npd_r;
    short opt_code;
    double loc_x;
    double loc_y;
    double loc_z;
    char err_cmp_flg[2];
  }  p_ppe;
struct
  {
    char ship_alt[81];
    char prep_desc_g[81];
    char prep_desc_r[81];
    short material;
    char family_name[13];
    char part_no_prfx[31];
    short prep_g;
    short prep_r;
    char sch_thk_g[9];
    char sch_thk_r[9];
    char short_code[7];
    short spec_no;
    short comp_cat;
    short comp_numcp;
    char constr_stat[9];
    char spec_name[9];
    double bend_sweep;
    short chg_no;
    long comp_seqno;
    char comp_code[7];
    float insul_thk;
    float npd_g;
    float npd_r;
    float pipe_length;
    char sch_thk_ovr[9];
    float spec_grav;
    short weight_grp;
    char tag_number[21];
    float weight;
  }  p_ppn;
struct
  {
    char seq_number[9];
    float npd_g;
    float npd_r;
    char comp_note[31];
    char short_code[7];
    short prep_g;
    char rating_g[9];
    char commodity[21];
    char comp_code[7];
    char comp_descr[21];
    char long_txt[81];
  }  p_ppv;
struct
  {
    char ship_alt[81];
    char prep_desc_g[81];
    char prep_desc_r[81];
    char family_name[13];
    char part_no_prfx[31];
    short prep_g;
    short prep_r;
    char sch_thk_g[9];
    char sch_thk_r[9];
    char short_code[7];
    short spec_no;
    short comp_cat;
    short comp_numcp;
    double bend_sweep;
    short chg_no;
    long comp_seqno;
    char comp_code[7];
    float insul_thk;
    double loc_x;
    double loc_y;
    double loc_z;
    float npd_g;
    float npd_r;
    float pipe_length;
    char sch_thk_ovr[9];
    float spec_grav;
    short weight_grp;
    char tag_number[21];
    float weight;
  }  p_ppw;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_rw;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_rw;
struct
  {
    char comp_descr[21];
    short comp_rptcat;
    char comp_code[7];
    float depth_g;
    float depth_r;
    char material[13];
    char spec_name[9];
    float duct_length;
    float width_g;
    float width_r;
    char system_name[13];
    long item_num;
    char category[81];
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_rwb;
struct
  {
    char spec_name[9];
    char system_name[13];
    char comp_code[7];
    float width_g;
    float depth_g;
    float width_r;
    float depth_r;
    short rway_type;
    double loc_x;
    double loc_y;
    double loc_z;
    char err_cmp_flg[2];
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_rwe;
struct
  {
    char comp_descr[21];
    float unit_wt;
    char d_material[13];
    short chg_no;
    char comp_code[7];
    char constr_stat[9];
    float depth_g;
    float depth_r;
    float duct_length;
    short weight_grp;
    float width_g;
    float width_r;
    char ship_alt[81];
  }  p_rwn;
struct
  {
    char comp_descr[21];
    char short_code[7];
    float unit_wt;
    float addl_weight;
    short chg_no;
    char comp_code[7];
    long comp_seqno;
    float depth_g;
    float depth_r;
    double loc_x;
    double loc_y;
    double loc_z;
    float duct_length;
    short weight_grp;
    float width_g;
    float width_r;
    char ship_alt[81];
    double cnvr_fctr;
    double cnvr_offset;
    double rndoff_fctr;
  }  p_rww;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone[81];
  }  p_cm;
struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone[81];
  }  q_cm;
struct
  {
    char name[81];
    char descript[81];
    char space_class[81];
    double floor_area;
    double volume;
  }  p_cmb;
struct
  {
    char dwg_cat[21];
    char dwg_nam[31];
    char dwg_rev[13];
  }  p_bp;
struct
  {
    char dwg_cat[21];
    char dwg_nam[31];
    char dwg_rev[13];
  }  q_bp;
long p_pce;
double p_len;
double p_srf;
double p_vol;
double p_wgt;
double p_vmm;
double p_lmm;
double p_tmm;
long g_pce;
double g_srf;
double g_vol;
double g_wgt;
double g_vmm;
double g_lmm;
double g_tmm;
struct
  {
    char rpt_req[4];
    char rpt_dsc1[41];
    char rpt_dsc2[41];
    double def_lcog;
    double def_tcog;
    double def_vcog;
  }  p_frm0;
struct
  {
    char bm_cat[21];
    char bm_nam[31];
    char bm_ver[13];
    char bm_zn[5];
    char bm_as[9];
    char bm_cs[9];
    char pl_cat[21];
    char pl_nam[31];
    char pl_ver[13];
    char pl_zn[5];
    char pl_as[9];
    char pl_cs[9];
  }  p_frm1;
struct
  {
    char hv_cat[21];
    char hv_nam[31];
    char hv_ver[13];
    char hv_sn[13];
    char hv_zn[5];
    char hv_as[9];
    char hv_cs[9];
    char rw_cat[21];
    char rw_nam[31];
    char rw_ver[13];
    char rw_sn[13];
    char rw_zn[5];
    char rw_as[9];
    char rw_cs[9];
  }  p_frm2;
struct
  {
    char pp_cat[21];
    char pp_nam[31];
    char pp_ver[13];
    char pp_sn[13];
    char pp_zn[5];
    char pp_as[9];
    char pp_cs[9];
    char eq_cat[21];
    char eq_nam[31];
    char eq_ver[13];
    char eq_zn[5];
    char eq_as[9];
    char eq_cs[9];
  }  p_frm3;
struct
  {
    char prj_no[21];
    short comp_seqno;
    short weight_grp;
    char ship_alt[21];
    char discipline[21];
    char descript[41];
    float total_wgt;
    float vcg;
    float lcg;
    float tcg;
    float vmom;
    float lmom;
    float tmom;
  }  p_over;
struct
  {
    char spec_name[9];
    char comp_code[7];
    short opt_code;
  }  p_form3;
struct
  {
    char spec_name[9];
    short s_spec_no;
    short npd_tblno;
    short c_spec_no;
    char family_name[13];
    char part_no_prfx[31];
    char comp_code[7];
    short opt_code;
    char short_code[7];
    float size_g_low;
    float size_g_high;
    float size_r_low;
    float size_r_high;
    char sch_thk_g[9];
    char sch_thk_r[9];
  }  compstr;
float npd_grn;
float npd_red;
char size1[21], size2[21], size3[21], size4[21];
char msg[301];
static char *fgl_modname = "../lib/RPTglobal.4gl";
nsts_error (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
du0: _anyerr = 0;
pushquote( ">>> Database has to be set in imperial units <<<" , 48);
popquote(nsts_err_msg,81);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
null_to_joker (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
char str[81];
du1: _anyerr = 0;
popquote(str,81);
pushquote( "%" , 1);
popquote(joker,3);
pushquote(str,80);
isnull();
pushquote(str,80);
pushquote( "" , 0);
_doopeq();
_doorop();
pushquote(str,80);
pushquote( " " , 1);
_doopeq();
_doorop();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushquote(joker,2);
doretalloc(1);
if (1) return(1);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du2: _anyerr = 0;
pushquote(str,80);
doretalloc(1);
if (1) return(1);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du3: _anyerr = 0;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
rptform_input (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
short product;
short form_type;
du4: _anyerr = 0;
popshort(&form_type);
popshort(&product);

/*
 * $  clear screen;
 */
 {
 _efcscrn();
 }
status = efcode;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(product);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du6: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du8: _anyerr = 0;

/*
 * $  open form first_form from "BMB";
 */
 {
 _efopen(&_FMfirst_form, "BMB");
 }
status = efcode;
goto ll7;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du9: _anyerr = 0;

/*
 * $  open form first_form from "BMN";
 */
 {
 _efopen(&_FMfirst_form, "BMN");
 }
status = efcode;
goto ll7;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du10: _anyerr = 0;

/*
 * $  open form first_form from "BMWimp";
 */
 {
 _efopen(&_FMfirst_form, "BMWimp");
 }
status = efcode;
goto ll7;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(6);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du11: _anyerr = 0;

/*
 * $  open form first_form from "BMG";
 */
 {
 _efopen(&_FMfirst_form, "BMG");
 }
status = efcode;
goto ll7;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll7:;
du12: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(1);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du13: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du15: _anyerr = 0;

/*
 * $  open form first_form from "EQB";
 */
 {
 _efopen(&_FMfirst_form, "EQB");
 }
status = efcode;
goto ll14;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du16: _anyerr = 0;

/*
 * $  open form first_form from "EQN";
 */
 {
 _efopen(&_FMfirst_form, "EQN");
 }
status = efcode;
goto ll14;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du17: _anyerr = 0;

/*
 * $  open form first_form from "EQWimp";
 */
 {
 _efopen(&_FMfirst_form, "EQWimp");
 }
status = efcode;
goto ll14;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll14:;
du18: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du19: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du21: _anyerr = 0;

/*
 * $  open form first_form from "HVB";
 */
 {
 _efopen(&_FMfirst_form, "HVB");
 }
status = efcode;
goto ll20;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du22: _anyerr = 0;

/*
 * $  open form first_form from "HVE";
 */
 {
 _efopen(&_FMfirst_form, "HVE");
 }
status = efcode;
goto ll20;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du23: _anyerr = 0;

/*
 * $  open form first_form from "HVN";
 */
 {
 _efopen(&_FMfirst_form, "HVN");
 }
status = efcode;
goto ll20;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du24: _anyerr = 0;

/*
 * $  open form first_form from "HVWimp";
 */
 {
 _efopen(&_FMfirst_form, "HVWimp");
 }
status = efcode;
goto ll20;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll20:;
du25: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du26: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du28: _anyerr = 0;

/*
 * $  open form first_form from "NZB";
 */
 {
 _efopen(&_FMfirst_form, "NZB");
 }
status = efcode;
goto ll27;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll27:;
du29: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du30: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du32: _anyerr = 0;

/*
 * $  open form first_form from "PLB";
 */
 {
 _efopen(&_FMfirst_form, "PLB");
 }
status = efcode;
goto ll31;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du33: _anyerr = 0;

/*
 * $  open form first_form from "PLN";
 */
 {
 _efopen(&_FMfirst_form, "PLN");
 }
status = efcode;
goto ll31;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du34: _anyerr = 0;

/*
 * $  open form first_form from "PLWimp";
 */
 {
 _efopen(&_FMfirst_form, "PLWimp");
 }
status = efcode;
goto ll31;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll31:;
du35: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(6);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du36: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du38: _anyerr = 0;

/*
 * $  open form first_form from "PPB";
 */
 {
 _efopen(&_FMfirst_form, "PPB");
 }
status = efcode;
goto ll37;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(1);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du39: _anyerr = 0;

/*
 * $  open form first_form from "PPD";
 */
 {
 _efopen(&_FMfirst_form, "PPD");
 }
status = efcode;
goto ll37;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du40: _anyerr = 0;

/*
 * $  open form first_form from "PPE";
 */
 {
 _efopen(&_FMfirst_form, "PPE");
 }
status = efcode;
goto ll37;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du41: _anyerr = 0;

/*
 * $  open form first_form from "PPN";
 */
 {
 _efopen(&_FMfirst_form, "PPN");
 }
status = efcode;
goto ll37;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(4);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du42: _anyerr = 0;

/*
 * $  open form first_form from "PPV";
 */
 {
 _efopen(&_FMfirst_form, "PPV");
 }
status = efcode;
goto ll37;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du43: _anyerr = 0;

/*
 * $  open form first_form from "PPWimp";
 */
 {
 _efopen(&_FMfirst_form, "PPWimp");
 }
status = efcode;
goto ll37;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(7);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du44: _anyerr = 0;

/*
 * $  open form first_form from "PPR";
 */
 {
 _efopen(&_FMfirst_form, "PPR");
 }
status = efcode;
goto ll37;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll37:;
du45: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(7);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du46: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du48: _anyerr = 0;

/*
 * $  open form first_form from "RWB";
 */
 {
 _efopen(&_FMfirst_form, "RWB");
 }
status = efcode;
goto ll47;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du49: _anyerr = 0;

/*
 * $  open form first_form from "RWE";
 */
 {
 _efopen(&_FMfirst_form, "RWE");
 }
status = efcode;
goto ll47;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du50: _anyerr = 0;

/*
 * $  open form first_form from "RWN";
 */
 {
 _efopen(&_FMfirst_form, "RWN");
 }
status = efcode;
goto ll47;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du51: _anyerr = 0;

/*
 * $  open form first_form from "RWWimp";
 */
 {
 _efopen(&_FMfirst_form, "RWWimp");
 }
status = efcode;
goto ll47;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll47:;
du52: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(8);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du53: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(6);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du55: _anyerr = 0;

/*
 * $  open form first_form from "BPG";
 */
 {
 _efopen(&_FMfirst_form, "BPG");
 }
status = efcode;
goto ll54;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll54:;
du56: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(10);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du57: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(form_type);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du59: _anyerr = 0;

/*
 * $  open form first_form from "CMB";
 */
 {
 _efopen(&_FMfirst_form, "CMB");
 }
status = efcode;
goto ll58;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll58:;
du60: _anyerr = 0;
goto ll5;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll5:;
du61: _anyerr = 0;

/*
 * $  display form first_form;
 */
 {
 _efdfrm(_FMfirst_form, (long)-1);
 }
status = efcode;
pushshort(product);
pushint(6);
_doopeq();
pushshort(form_type);
pushint(7);
_doopeq();
_doandop();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
goto decadix;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du62: _anyerr = 0;

/*
 * $  input $rpt_req from sc_form . rpt_request;
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{"sc_form.rpt_request", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(rpt_req)}, 
	};
_sqobind[0].sqldata =(rpt_req);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef1exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef1exit;
}
{
_ef1continue:;
_finput(1, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef1exit:;
_efipclean(&_sqicb, _sqfldlst, 1);
}
status = efcode;
du63: _anyerr = 0;

/*
 * $  input $rpt_dsc1 from sc_form . rpt_descript1;
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{"sc_form.rpt_descript1", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(rpt_dsc1)}, 
	};
_sqobind[0].sqldata =(rpt_dsc1);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef2exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef2exit;
}
{
_ef2continue:;
_finput(1, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef2exit:;
_efipclean(&_sqicb, _sqfldlst, 1);
}
status = efcode;
du64: _anyerr = 0;

/*
 * $  input $rpt_dsc2 from sc_form . rpt_descript2;
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{"sc_form.rpt_descript2", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(rpt_dsc2)}, 
	};
_sqobind[0].sqldata =(rpt_dsc2);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef3exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef3exit;
}
{
_ef3continue:;
_finput(1, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef3exit:;
_efipclean(&_sqicb, _sqfldlst, 1);
}
status = efcode;
du65: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du66: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(product);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du68: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_bm.assembly_cat , $p_bm.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".zone_number", 0},
	{".apprv_stat", 0},
	{".constr_stat", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_bm.assembly_cat)}, 
	{100, sizeof(p_bm.assembly_nam)}, 
	{100, sizeof(p_bm.assembly_ver)}, 
	{100, sizeof(p_bm.zone_number)}, 
	{100, sizeof(p_bm.apprv_stat)}, 
	{100, sizeof(p_bm.constr_stat)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_bm.assembly_cat);
_sqobind[2].sqldata =(p_bm.assembly_nam);
_sqobind[3].sqldata =(p_bm.assembly_ver);
_sqobind[4].sqldata =(p_bm.zone_number);
_sqobind[5].sqldata =(p_bm.apprv_stat);
_sqobind[6].sqldata =(p_bm.constr_stat);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef4exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef4exit;
}
{
_ef4continue:;
_finput(7, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef4exit:;
_efipclean(&_sqicb, _sqfldlst, 7);
}
status = efcode;
du69: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bm.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du70: _anyerr = 0;
 ld_quote(0, q_bm.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bm.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du71: _anyerr = 0;
 ld_quote(0, q_bm.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bm.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du72: _anyerr = 0;
 ld_quote(0, q_bm.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bm.zone_number,4);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du73: _anyerr = 0;
 ld_quote(0, q_bm.zone_number, 5) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bm.apprv_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du74: _anyerr = 0;
 ld_quote(0, q_bm.apprv_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bm.constr_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du75: _anyerr = 0;
 ld_quote(0, q_bm.constr_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(1);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du76: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_eq.assembly_cat , $p_eq.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".zone_number", 0},
	{".apprv_stat", 0},
	{".constr_stat", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_eq.assembly_cat)}, 
	{100, sizeof(p_eq.assembly_nam)}, 
	{100, sizeof(p_eq.assembly_ver)}, 
	{100, sizeof(p_eq.zone_number)}, 
	{100, sizeof(p_eq.apprv_stat)}, 
	{100, sizeof(p_eq.constr_stat)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_eq.assembly_cat);
_sqobind[2].sqldata =(p_eq.assembly_nam);
_sqobind[3].sqldata =(p_eq.assembly_ver);
_sqobind[4].sqldata =(p_eq.zone_number);
_sqobind[5].sqldata =(p_eq.apprv_stat);
_sqobind[6].sqldata =(p_eq.constr_stat);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef5exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef5exit;
}
{
_ef5continue:;
_finput(7, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef5exit:;
_efipclean(&_sqicb, _sqfldlst, 7);
}
status = efcode;
du77: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_eq.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du78: _anyerr = 0;
 ld_quote(0, q_eq.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_eq.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du79: _anyerr = 0;
 ld_quote(0, q_eq.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_eq.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du80: _anyerr = 0;
 ld_quote(0, q_eq.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_eq.zone_number,4);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du81: _anyerr = 0;
 ld_quote(0, q_eq.zone_number, 5) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_eq.apprv_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du82: _anyerr = 0;
 ld_quote(0, q_eq.apprv_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_eq.constr_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du83: _anyerr = 0;
 ld_quote(0, q_eq.constr_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du84: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_hv.assembly_cat , $p_hv.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".system_name", 0},
	{".zone_number", 0},
	{".apprv_stat", 0},
	{".constr_stat", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_hv.assembly_cat)}, 
	{100, sizeof(p_hv.assembly_nam)}, 
	{100, sizeof(p_hv.assembly_ver)}, 
	{100, sizeof(p_hv.system_name)}, 
	{100, sizeof(p_hv.zone_number)}, 
	{100, sizeof(p_hv.apprv_stat)}, 
	{100, sizeof(p_hv.constr_stat)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_hv.assembly_cat);
_sqobind[2].sqldata =(p_hv.assembly_nam);
_sqobind[3].sqldata =(p_hv.assembly_ver);
_sqobind[4].sqldata =(p_hv.system_name);
_sqobind[5].sqldata =(p_hv.zone_number);
_sqobind[6].sqldata =(p_hv.apprv_stat);
_sqobind[7].sqldata =(p_hv.constr_stat);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef6exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef6exit;
}
{
_ef6continue:;
_finput(8, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef6exit:;
_efipclean(&_sqicb, _sqfldlst, 8);
}
status = efcode;
du85: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_hv.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du86: _anyerr = 0;
 ld_quote(0, q_hv.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_hv.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du87: _anyerr = 0;
 ld_quote(0, q_hv.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_hv.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du88: _anyerr = 0;
 ld_quote(0, q_hv.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_hv.system_name,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du89: _anyerr = 0;
 ld_quote(0, q_hv.system_name, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_hv.zone_number,4);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du90: _anyerr = 0;
 ld_quote(0, q_hv.zone_number, 5) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_hv.apprv_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du91: _anyerr = 0;
 ld_quote(0, q_hv.apprv_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_hv.constr_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du92: _anyerr = 0;
 ld_quote(0, q_hv.constr_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du93: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_nz.assembly_cat , $p_nz.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".system_name", 0},
	{".zone_number", 0},
	{".apprv_stat", 0},
	{".constr_stat", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_nz.assembly_cat)}, 
	{100, sizeof(p_nz.assembly_nam)}, 
	{100, sizeof(p_nz.assembly_ver)}, 
	{100, sizeof(p_nz.system_name)}, 
	{100, sizeof(p_nz.zone_number)}, 
	{100, sizeof(p_nz.apprv_stat)}, 
	{100, sizeof(p_nz.constr_stat)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_nz.assembly_cat);
_sqobind[2].sqldata =(p_nz.assembly_nam);
_sqobind[3].sqldata =(p_nz.assembly_ver);
_sqobind[4].sqldata =(p_nz.system_name);
_sqobind[5].sqldata =(p_nz.zone_number);
_sqobind[6].sqldata =(p_nz.apprv_stat);
_sqobind[7].sqldata =(p_nz.constr_stat);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef7exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef7exit;
}
{
_ef7continue:;
_finput(8, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef7exit:;
_efipclean(&_sqicb, _sqfldlst, 8);
}
status = efcode;
du94: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_nz.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du95: _anyerr = 0;
 ld_quote(0, q_nz.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_nz.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du96: _anyerr = 0;
 ld_quote(0, q_nz.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_nz.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du97: _anyerr = 0;
 ld_quote(0, q_nz.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_nz.system_name,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du98: _anyerr = 0;
 ld_quote(0, q_nz.system_name, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_nz.zone_number,4);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du99: _anyerr = 0;
 ld_quote(0, q_nz.zone_number, 5) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_nz.apprv_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du100: _anyerr = 0;
 ld_quote(0, q_nz.apprv_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_nz.constr_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du101: _anyerr = 0;
 ld_quote(0, q_nz.constr_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du102: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_pl.assembly_cat , $p_pl.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".zone_number", 0},
	{".apprv_stat", 0},
	{".constr_stat", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_pl.assembly_cat)}, 
	{100, sizeof(p_pl.assembly_nam)}, 
	{100, sizeof(p_pl.assembly_ver)}, 
	{100, sizeof(p_pl.zone_number)}, 
	{100, sizeof(p_pl.apprv_stat)}, 
	{100, sizeof(p_pl.constr_stat)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_pl.assembly_cat);
_sqobind[2].sqldata =(p_pl.assembly_nam);
_sqobind[3].sqldata =(p_pl.assembly_ver);
_sqobind[4].sqldata =(p_pl.zone_number);
_sqobind[5].sqldata =(p_pl.apprv_stat);
_sqobind[6].sqldata =(p_pl.constr_stat);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef8exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef8exit;
}
{
_ef8continue:;
_finput(7, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef8exit:;
_efipclean(&_sqicb, _sqfldlst, 7);
}
status = efcode;
du103: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pl.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du104: _anyerr = 0;
 ld_quote(0, q_pl.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pl.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du105: _anyerr = 0;
 ld_quote(0, q_pl.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pl.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du106: _anyerr = 0;
 ld_quote(0, q_pl.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pl.zone_number,4);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du107: _anyerr = 0;
 ld_quote(0, q_pl.zone_number, 5) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pl.apprv_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du108: _anyerr = 0;
 ld_quote(0, q_pl.apprv_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pl.constr_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du109: _anyerr = 0;
 ld_quote(0, q_pl.constr_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(6);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du110: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_pp.assembly_cat , $p_pp.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".system_name", 0},
	{".zone_number", 0},
	{".apprv_stat", 0},
	{".constr_stat", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_pp.assembly_cat)}, 
	{100, sizeof(p_pp.assembly_nam)}, 
	{100, sizeof(p_pp.assembly_ver)}, 
	{100, sizeof(p_pp.system_name)}, 
	{100, sizeof(p_pp.zone_number)}, 
	{100, sizeof(p_pp.apprv_stat)}, 
	{100, sizeof(p_pp.constr_stat)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_pp.assembly_cat);
_sqobind[2].sqldata =(p_pp.assembly_nam);
_sqobind[3].sqldata =(p_pp.assembly_ver);
_sqobind[4].sqldata =(p_pp.system_name);
_sqobind[5].sqldata =(p_pp.zone_number);
_sqobind[6].sqldata =(p_pp.apprv_stat);
_sqobind[7].sqldata =(p_pp.constr_stat);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef9exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef9exit;
}
{
_ef9continue:;
_finput(8, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef9exit:;
_efipclean(&_sqicb, _sqfldlst, 8);
}
status = efcode;
du111: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pp.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du112: _anyerr = 0;
 ld_quote(0, q_pp.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pp.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du113: _anyerr = 0;
 ld_quote(0, q_pp.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pp.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du114: _anyerr = 0;
 ld_quote(0, q_pp.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pp.system_name,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du115: _anyerr = 0;
 ld_quote(0, q_pp.system_name, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pp.zone_number,4);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du116: _anyerr = 0;
 ld_quote(0, q_pp.zone_number, 5) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pp.apprv_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du117: _anyerr = 0;
 ld_quote(0, q_pp.apprv_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_pp.constr_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du118: _anyerr = 0;
 ld_quote(0, q_pp.constr_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(7);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du119: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_rw.assembly_cat , $p_rw.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".system_name", 0},
	{".zone_number", 0},
	{".apprv_stat", 0},
	{".constr_stat", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_rw.assembly_cat)}, 
	{100, sizeof(p_rw.assembly_nam)}, 
	{100, sizeof(p_rw.assembly_ver)}, 
	{100, sizeof(p_rw.system_name)}, 
	{100, sizeof(p_rw.zone_number)}, 
	{100, sizeof(p_rw.apprv_stat)}, 
	{100, sizeof(p_rw.constr_stat)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_rw.assembly_cat);
_sqobind[2].sqldata =(p_rw.assembly_nam);
_sqobind[3].sqldata =(p_rw.assembly_ver);
_sqobind[4].sqldata =(p_rw.system_name);
_sqobind[5].sqldata =(p_rw.zone_number);
_sqobind[6].sqldata =(p_rw.apprv_stat);
_sqobind[7].sqldata =(p_rw.constr_stat);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef10exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef10exit;
}
{
_ef10continue:;
_finput(8, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef10exit:;
_efipclean(&_sqicb, _sqfldlst, 8);
}
status = efcode;
du120: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_rw.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du121: _anyerr = 0;
 ld_quote(0, q_rw.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_rw.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du122: _anyerr = 0;
 ld_quote(0, q_rw.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_rw.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du123: _anyerr = 0;
 ld_quote(0, q_rw.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_rw.system_name,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du124: _anyerr = 0;
 ld_quote(0, q_rw.system_name, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_rw.zone_number,4);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du125: _anyerr = 0;
 ld_quote(0, q_rw.zone_number, 5) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_rw.apprv_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du126: _anyerr = 0;
 ld_quote(0, q_rw.apprv_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_rw.constr_stat,8);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du127: _anyerr = 0;
 ld_quote(0, q_rw.constr_stat, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(8);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du128: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_bp.dwg_cat , $p_bp.dwg_nam ,
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".dwg_cat", 0},
	{".dwg_nam", 0},
	{".dwg_rev", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_bp.dwg_cat)}, 
	{100, sizeof(p_bp.dwg_nam)}, 
	{100, sizeof(p_bp.dwg_rev)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_bp.dwg_cat);
_sqobind[2].sqldata =(p_bp.dwg_nam);
_sqobind[3].sqldata =(p_bp.dwg_rev);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef11exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef11exit;
}
{
_ef11continue:;
_finput(4, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef11exit:;
_efipclean(&_sqicb, _sqfldlst, 4);
}
status = efcode;
du129: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bp.dwg_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du130: _anyerr = 0;
 ld_quote(0, q_bp.dwg_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bp.dwg_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du131: _anyerr = 0;
 ld_quote(0, q_bp.dwg_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_bp.dwg_rev,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du132: _anyerr = 0;
 ld_quote(0, q_bp.dwg_rev, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(10);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du133: _anyerr = 0;

/*
 * $  input by name $p_vds.prj_number , $p_cm.assembly_cat , $p_cm.assembly_nam
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{".prj_number", 0},
	{".assembly_cat", 0},
	{".assembly_nam", 0},
	{".assembly_ver", 0},
	{".zone", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{100, sizeof(p_vds.prj_number)}, 
	{100, sizeof(p_cm.assembly_cat)}, 
	{100, sizeof(p_cm.assembly_nam)}, 
	{100, sizeof(p_cm.assembly_ver)}, 
	{100, sizeof(p_cm.zone)}, 
	};
_sqobind[0].sqldata =(p_vds.prj_number);
_sqobind[1].sqldata =(p_cm.assembly_cat);
_sqobind[2].sqldata =(p_cm.assembly_nam);
_sqobind[3].sqldata =(p_cm.assembly_ver);
_sqobind[4].sqldata =(p_cm.zone);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef12exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef12exit;
}
{
_ef12continue:;
_finput(5, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef12exit:;
_efipclean(&_sqicb, _sqfldlst, 5);
}
status = efcode;
du134: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_cm.assembly_cat,20);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du135: _anyerr = 0;
 ld_quote(0, q_cm.assembly_cat, 21) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_cm.assembly_nam,30);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du136: _anyerr = 0;
 ld_quote(0, q_cm.assembly_nam, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_cm.assembly_ver,12);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du137: _anyerr = 0;
 ld_quote(0, q_cm.assembly_ver, 13) ;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(p_cm.zone,80);
fgl_nret = null_to_joker(1);
rest_stack(fgl_svstk);
du138: _anyerr = 0;
 ld_quote(0, q_cm.zone, 81) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll67;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll67:;
du139: _anyerr = 0;

/*
 * $  select unique vds_project.prj_number , vds_project.prj_name ,
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select unique vds_project . prj_number , vds_project . prj_name ,",
   " vds_project . prj_location , vds_project . prj_units_set ,",
   " vds_project . prj_no from vds_project where prj_number like ?",
  (char *) 0
  };
 static _SQCURSOR _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 17, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 static struct sqlvar_struct _sqobind[] = 
 {
 {100, 17, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 41, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 41, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {101, sizeof(p_vds.prj_units_set), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {101, sizeof(p_vds.prj_no), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (p_vds.prj_number);
 _sqobind[0].sqldata = (p_vds.prj_number);
 _sqobind[1].sqldata = (p_vds.prj_name);
 _sqobind[2].sqldata = (p_vds.prj_location);
 _sqobind[3].sqldata = (char *) &(p_vds.prj_units_set);
 _sqobind[4].sqldata = (char *) &(p_vds.prj_no);
 _iqslct(&_SQ0, sqlcmdtxt, 1, _sqibind, 5, _sqobind, 0);
 }
status = sqlca.sqlcode;
pushshort(form_type);
pushint(5);
_doopeq();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{

/*
 * $  input $def_lcog from sc_form . def_lcog;
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{"sc_form.def_lcog", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{105, sizeof(double)}, 
	};
_sqobind[0].sqldata =(char *)&(def_lcog);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef13exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef13exit;
}
{
_ef13continue:;
_finput(1, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef13exit:;
_efipclean(&_sqicb, _sqfldlst, 1);
}
status = efcode;
du140: _anyerr = 0;

/*
 * $  input $def_tcog from sc_form . def_tcog;
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{"sc_form.def_tcog", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{105, sizeof(double)}, 
	};
_sqobind[0].sqldata =(char *)&(def_tcog);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef14exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef14exit;
}
{
_ef14continue:;
_finput(1, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef14exit:;
_efipclean(&_sqicb, _sqfldlst, 1);
}
status = efcode;
du141: _anyerr = 0;

/*
 * $  input $def_vcog from sc_form . def_vcog;
 */
{
static _EFICB _sqicb = {0};
static _EFFIELD _sqfldlst[] = {
	{"sc_form.def_vcog", 0},
	{0}};

static struct sqlvar_struct _sqobind[] = {
	{105, sizeof(double)}, 
	};
_sqobind[0].sqldata =(char *)&(def_vcog);
_sqicb._EFflags = ICB_INIT;
_sqicb._EFaction = 0;
_sqicb._EFoattr = -1;
_sqicb._EFiattr = -1;
_sqicb._EFbatab = NULL;
for (;;)
{
switch (_sqicb._EFaction)
{
case -2:	/* error */
goto _ef15exit;
default:

/*
 * $  end input;
 */
break;
case -1: 
goto _ef15exit;
}
{
_ef15continue:;
_finput(1, _sqobind, _sqfldlst, 0, &_sqicb);
}}
_ef15exit:;
_efipclean(&_sqicb, _sqfldlst, 1);
}
status = efcode;
du142: _anyerr = 0;
pushshort(p_vds.prj_units_set);
pushint(1);
_doopeq();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushdub(&def_lcog);
pushstrdec(" 12.0 ");
_dodiv();
popdub(&def_lcog);
pushdub(&def_tcog);
pushstrdec(" 12.0 ");
_dodiv();
popdub(&def_tcog);
pushdub(&def_vcog);
pushstrdec(" 12.0 ");
_dodiv();
popdub(&def_vcog);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du143: _anyerr = 0;
pushdub(&def_lcog);
pushstrdec(" 1000.0 ");
_dodiv();
popdub(&def_lcog);
pushdub(&def_tcog);
pushstrdec(" 1000.0 ");
_dodiv();
popdub(&def_tcog);
pushdub(&def_vcog);
pushstrdec(" 1000.0 ");
_dodiv();
popdub(&def_vcog);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du144: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du145: _anyerr = 0;

/*
 * $  clear screen;
 */
 {
 _efcscrn();
 }
status = efcode;
decadix :;
du146: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(product);
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du148: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
fgl_nret = update_hvac(0);
rest_stack(fgl_svstk);
du149: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll147;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(7);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du150: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
fgl_nret = update_rway(0);
rest_stack(fgl_svstk);
du151: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll147;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll147:;
du152: _anyerr = 0;
pushshort(product);
pushint(1);
_doopeq();
pushshort(form_type);
pushint(6);
_doopeq();
_doandop();
pushshort(product);
pushint(4);
_doopeq();
_doorop();
pushshort(product);
pushint(6);
_doopeq();
pushshort(form_type);
pushint(7);
_doopeq();
_doandop();
_doorop();
pushshort(product);
pushint(8);
_doopeq();
_doorop();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushint(1);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du153: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushshort(product);
fgl_nret = rptdrawing(1);
rest_stack(fgl_svstk);
du154: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushshort(product);
fgl_nret = rptwhere_begin(1);
rest_stack(fgl_svstk);
du155: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du156: _anyerr = 0;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
rptdrawing (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
short product;
struct
  {
    char family_name[21];
    long occ_num;
  }  bm_draw;
struct
  {
    char eqp_family[21];
    long occ_num;
  }  eq_draw;
struct
  {
    char spec_name[9];
    long occ_num;
  }  hv_draw;
struct
  {
    char spec_name[9];
    long occ_num;
  }  nz_draw;
struct
  {
    char family_name[21];
    long occ_num;
  }  pl_draw;
struct
  {
    char spec_name[9];
    long occ_num;
  }  pp_draw;
struct
  {
    char spec_name[9];
    long occ_num;
  }  rw_draw;
du157: _anyerr = 0;
popshort(&product);

/*
 * $  declare bm_curs cursor for select struct_bm_dynamic.family_name , count (
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select struct_bm_dynamic . family_name , count ( * ) from",
   " struct_bm_cit , struct_bm_dynamic where struct_bm_cit . dwg_cat = ?",
   " and struct_bm_cit . dwg_nam = ? and struct_bm_cit . dwg_rev = ? and",
   " struct_bm_cit . assembly_cat = struct_bm_dynamic . assembly_cat and",
   " struct_bm_cit . assembly_nam = struct_bm_dynamic . assembly_nam and",
   " struct_bm_cit . assembly_rev = struct_bm_dynamic . assembly_ver and",
   " struct_bm_cit . comp_seqno = struct_bm_dynamic . comp_seqno group by",
   " struct_bm_dynamic . family_name",
  (char *) 0
  };
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_bm.assembly_cat);
 _sqibind[1].sqldata = (q_bm.assembly_nam);
 _sqibind[2].sqldata = (q_bm.assembly_ver);
 _iqdclcur(&_SQ2, "bm_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;

/*
 * $  declare eq_curs cursor for select equip_dynamic.eqp_family , count ( * )
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select equip_dynamic . eqp_family , count ( * ) from equip_cit ,",
   " equip_dynamic where equip_cit . dwg_cat = ? and equip_cit . dwg_nam =",
   " ? and equip_cit . dwg_rev = ? and equip_cit . assembly_cat =",
   " equip_dynamic . assembly_cat and equip_cit . assembly_nam =",
   " equip_dynamic . assembly_nam and equip_cit . assembly_rev =",
   " equip_dynamic . assembly_ver and equip_cit . comp_seqno =",
   " equip_dynamic . comp_seqno group by equip_dynamic . eqp_family",
  (char *) 0
  };
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_eq.assembly_cat);
 _sqibind[1].sqldata = (q_eq.assembly_nam);
 _sqibind[2].sqldata = (q_eq.assembly_ver);
 _iqdclcur(&_SQ3, "eq_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;

/*
 * $  declare hv_curs cursor for select hvac_dynamic.spec_name , count ( * )
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select hvac_dynamic . spec_name , count ( * ) from hvac_cit ,",
   " hvac_dynamic where hvac_cit . dwg_cat = ? and hvac_cit . dwg_nam = ?",
   " and hvac_cit . dwg_rev = ? and hvac_cit . assembly_cat = hvac_dynamic",
   " . assembly_cat and hvac_cit . assembly_nam = hvac_dynamic .",
   " assembly_nam and hvac_cit . assembly_rev = hvac_dynamic .",
   " assembly_ver and hvac_cit . comp_seqno = hvac_dynamic . comp_seqno",
   " group by hvac_dynamic . spec_name",
  (char *) 0
  };
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_hv.assembly_cat);
 _sqibind[1].sqldata = (q_hv.assembly_nam);
 _sqibind[2].sqldata = (q_hv.assembly_ver);
 _iqdclcur(&_SQ4, "hv_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;

/*
 * $  declare nz_curs cursor for select piping_noz_dynamic.spec_name , count (
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select piping_noz_dynamic . spec_name , count ( * ) from",
   " piping_noz_cit , piping_noz_dynamic where piping_noz_cit . dwg_cat =",
   " ? and piping_noz_cit . dwg_nam = ? and piping_noz_cit . dwg_rev = ?",
   " and piping_noz_cit . assembly_cat = piping_noz_dynamic . assembly_cat",
   " and piping_noz_cit . assembly_nam = piping_noz_dynamic . assembly_nam",
   " and piping_noz_cit . assembly_rev = piping_noz_dynamic . assembly_ver",
   " and piping_noz_cit . comp_seqno = piping_noz_dynamic . comp_seqno",
   " group by piping_noz_dynamic . spec_name",
  (char *) 0
  };
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_nz.assembly_cat);
 _sqibind[1].sqldata = (q_nz.assembly_nam);
 _sqibind[2].sqldata = (q_nz.assembly_ver);
 _iqdclcur(&_SQ5, "nz_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;

/*
 * $  declare pl_curs cursor for select struct_pl_dynamic.family_name , count (
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select struct_pl_dynamic . family_name , count ( * ) from",
   " struct_pl_cit , struct_pl_dynamic where struct_pl_cit . dwg_cat = ?",
   " and struct_pl_cit . dwg_nam = ? and struct_pl_cit . dwg_rev = ? and",
   " struct_pl_cit . assembly_cat = struct_pl_dynamic . assembly_cat and",
   " struct_pl_cit . assembly_nam = struct_pl_dynamic . assembly_nam and",
   " struct_pl_cit . assembly_rev = struct_pl_dynamic . assembly_ver and",
   " struct_pl_cit . comp_seqno = struct_pl_dynamic . comp_seqno group by",
   " struct_pl_dynamic . family_name",
  (char *) 0
  };
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_pl.assembly_cat);
 _sqibind[1].sqldata = (q_pl.assembly_nam);
 _sqibind[2].sqldata = (q_pl.assembly_ver);
 _iqdclcur(&_SQ6, "pl_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;

/*
 * $  declare pp_curs cursor for select piping_dynamic.spec_name , count ( * )
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select piping_dynamic . spec_name , count ( * ) from piping_cit ,",
   " piping_dynamic where piping_cit . dwg_cat = ? and piping_cit .",
   " dwg_nam = ? and piping_cit . dwg_rev = ? and piping_cit .",
   " assembly_cat = piping_dynamic . assembly_cat and piping_cit .",
   " assembly_nam = piping_dynamic . assembly_nam and piping_cit .",
   " assembly_rev = piping_dynamic . assembly_ver and piping_cit .",
   " comp_seqno = piping_dynamic . comp_seqno group by piping_dynamic .",
   " spec_name",
  (char *) 0
  };
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_pp.assembly_cat);
 _sqibind[1].sqldata = (q_pp.assembly_nam);
 _sqibind[2].sqldata = (q_pp.assembly_ver);
 _iqdclcur(&_SQ7, "pp_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;

/*
 * $  declare rw_curs cursor for select rway_dynamic.spec_name , count ( * )
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select rway_dynamic . spec_name , count ( * ) from rway_cit ,",
   " rway_dynamic where rway_cit . dwg_cat = ? and rway_cit . dwg_nam = ?",
   " and rway_cit . dwg_rev = ? and rway_cit . assembly_cat = rway_dynamic",
   " . assembly_cat and rway_cit . assembly_nam = rway_dynamic .",
   " assembly_nam and rway_cit . assembly_rev = rway_dynamic .",
   " assembly_ver and rway_cit . comp_seqno = rway_dynamic . comp_seqno",
   " group by rway_dynamic . spec_name",
  (char *) 0
  };
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_rw.assembly_cat);
 _sqibind[1].sqldata = (q_rw.assembly_nam);
 _sqibind[2].sqldata = (q_rw.assembly_ver);
 _iqdclcur(&_SQ8, "rw_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(product);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du159: _anyerr = 0;
pushquote(q_bm.assembly_cat,20);
pushquote(joker,2);
_doopeq();
pushquote(q_bm.assembly_nam,30);
pushquote(joker,2);
_doopeq();
_doorop();
pushquote(q_bm.assembly_ver,12);
pushquote(joker,2);
_doopeq();
_doorop();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushint(0);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du160: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);

/*
 * $  open bm_curs;
 */
 {
 _iqcopen(&_SQ2, 0, (char *) 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
while (1)

/*
 * SQL SEES BLOCK BEGINNING
 */
{

/*
 * $  fetch bm_curs into $bm_draw.family_name , $bm_draw.occ_num;
 */
 {
 static struct sqlvar_struct _sqobind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {103, sizeof(bm_draw.occ_num), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqobind[0].sqldata = (bm_draw.family_name);
 _sqobind[1].sqldata = (char *) &(bm_draw.occ_num);
 _iqnftch(&_SQ2, 2, _sqobind, (char *) 0, 1, (long) 0, 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
du161: _anyerr = 0;
if (status == 100) break;
pushlong(bm_draw.occ_num);
pushint(0);
_doopne();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushint(1);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du162: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du163: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  close bm_curs;
 */
 {
 _iqclose(&_SQ2);
 }
status = sqlca.sqlcode;
du164: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du165: _anyerr = 0;
goto ll158;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(1);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du166: _anyerr = 0;
pushquote(q_eq.assembly_cat,20);
pushquote(joker,2);
_doopeq();
pushquote(q_eq.assembly_nam,30);
pushquote(joker,2);
_doopeq();
_doorop();
pushquote(q_eq.assembly_ver,12);
pushquote(joker,2);
_doopeq();
_doorop();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushint(0);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du167: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);

/*
 * $  open eq_curs;
 */
 {
 _iqcopen(&_SQ3, 0, (char *) 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
while (1)

/*
 * SQL SEES BLOCK BEGINNING
 */
{

/*
 * $  fetch eq_curs into $eq_draw.eqp_family , $eq_draw.occ_num;
 */
 {
 static struct sqlvar_struct _sqobind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {103, sizeof(eq_draw.occ_num), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqobind[0].sqldata = (eq_draw.eqp_family);
 _sqobind[1].sqldata = (char *) &(eq_draw.occ_num);
 _iqnftch(&_SQ3, 2, _sqobind, (char *) 0, 1, (long) 0, 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
du168: _anyerr = 0;
if (status == 100) break;
pushlong(eq_draw.occ_num);
pushint(0);
_doopne();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushint(1);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du169: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du170: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  close eq_curs;
 */
 {
 _iqclose(&_SQ3);
 }
status = sqlca.sqlcode;
du171: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du172: _anyerr = 0;
goto ll158;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du173: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);
goto ll158;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du174: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);
goto ll158;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du175: _anyerr = 0;
pushquote(q_pl.assembly_cat,20);
pushquote(joker,2);
_doopeq();
pushquote(q_pl.assembly_nam,30);
pushquote(joker,2);
_doopeq();
_doorop();
pushquote(q_pl.assembly_ver,12);
pushquote(joker,2);
_doopeq();
_doorop();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushint(0);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du176: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);

/*
 * $  open pl_curs;
 */
 {
 _iqcopen(&_SQ6, 0, (char *) 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
while (1)

/*
 * SQL SEES BLOCK BEGINNING
 */
{

/*
 * $  fetch pl_curs into $pl_draw.family_name , $pl_draw.occ_num;
 */
 {
 static struct sqlvar_struct _sqobind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {103, sizeof(pl_draw.occ_num), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqobind[0].sqldata = (pl_draw.family_name);
 _sqobind[1].sqldata = (char *) &(pl_draw.occ_num);
 _iqnftch(&_SQ6, 2, _sqobind, (char *) 0, 1, (long) 0, 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
du177: _anyerr = 0;
if (status == 100) break;
pushlong(pl_draw.occ_num);
pushint(0);
_doopne();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushint(1);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du178: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du179: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  close pl_curs;
 */
 {
 _iqclose(&_SQ6);
 }
status = sqlca.sqlcode;
du180: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du181: _anyerr = 0;
goto ll158;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(6);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du182: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);
goto ll158;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(7);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du183: _anyerr = 0;
pushint(0);
popshort(&drawing_flag);
goto ll158;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll158:;
du184: _anyerr = 0;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
rptquery (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
short g_flag;
short o_flag;
du185: _anyerr = 0;
popshort(&o_flag);
popshort(&g_flag);
pushquote( "SELECT " , 7);
pushquote(s_stmt,2000);
_doclip();
pushquote( " \nFROM " , 7);
pushquote(f_stmt,2000);
_doclip();
pushquote( " \nWHERE " , 8);
pushquote(w_stmt,5000);
_doclip();
pushquote(q_stmt,10000);
_doconcat(6,0);
pushshort(g_flag);
pushint(1);
_doopeq();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushquote(q_stmt,10000);
_doclip();
pushquote( " \nGROUP BY " , 11);
pushquote(g_stmt,2000);
_doclip();
pushquote(q_stmt,10000);
_doconcat(3,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du186: _anyerr = 0;
pushshort(o_flag);
pushint(1);
_doopeq();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{
pushquote(q_stmt,10000);
_doclip();
pushquote( " \nORDER BY " , 11);
pushquote(o_stmt,2000);
_doclip();
pushquote(q_stmt,10000);
_doconcat(3,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du187: _anyerr = 0;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
rptwhere_begin (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
short product;
du188: _anyerr = 0;
popshort(&product);
pushshort(drawing_flag);
pushint(0);
_doopeq();


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_if1;
popbool(&fgl_if1);
if (fgl_if1) 

/*
 * SQL SEES BLOCK BEGINNING
 */
{


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(product);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du190: _anyerr = 0;
pushquote( "(struct_bm_dynamic.assembly_cat LIKE '" , 38);
pushquote(q_bm.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.assembly_cat  IS NULL) " , 45);
pushquote( "AND (struct_bm_dynamic.assembly_nam LIKE '" , 42);
pushquote(q_bm.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.assembly_nam  IS NULL) " , 45);
pushquote( "AND (struct_bm_dynamic.assembly_ver LIKE '" , 42);
pushquote(q_bm.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.assembly_ver  IS NULL) " , 45);
pushquote( "AND (struct_bm_dynamic.zone_number  LIKE '" , 42);
pushquote(q_bm.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.zone_number   IS NULL) " , 45);
pushquote( "AND (struct_bm_dynamic.apprv_stat   LIKE '" , 42);
pushquote(q_bm.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.apprv_stat    IS NULL) " , 45);
pushquote( "AND (struct_bm_dynamic.constr_stat  LIKE '" , 42);
pushquote(q_bm.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.constr_stat   IS NULL) " , 45);
pushquote(w_stmt,5000);
_doconcat(24,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(1);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du191: _anyerr = 0;
pushquote( "    (equip_dynamic.assembly_cat LIKE '" , 38);
pushquote(q_eq.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.assembly_cat  IS NULL) " , 41);
pushquote( "AND (equip_dynamic.assembly_nam LIKE '" , 38);
pushquote(q_eq.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.assembly_nam  IS NULL) " , 41);
pushquote( "AND (equip_dynamic.assembly_ver LIKE '" , 38);
pushquote(q_eq.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.assembly_ver  IS NULL) " , 41);
pushquote( "AND (equip_dynamic.zone_number  LIKE '" , 38);
pushquote(q_eq.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.zone_number   IS NULL) " , 41);
pushquote( "AND (equip_dynamic.apprv_stat   LIKE '" , 38);
pushquote(q_eq.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.apprv_stat    IS NULL) " , 41);
pushquote( "AND (equip_dynamic.constr_stat  LIKE '" , 38);
pushquote(q_eq.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.constr_stat   IS NULL) " , 41);
pushquote(w_stmt,5000);
_doconcat(24,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du192: _anyerr = 0;
pushquote( "(hvac_dynamic.assembly_cat LIKE '" , 33);
pushquote(q_hv.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.assembly_cat  IS NULL) " , 40);
pushquote( "AND (hvac_dynamic.assembly_nam LIKE '" , 37);
pushquote(q_hv.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.assembly_nam  IS NULL) " , 40);
pushquote( "AND (hvac_dynamic.assembly_ver LIKE '" , 37);
pushquote(q_hv.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.assembly_ver  IS NULL) " , 40);
pushquote( "AND (hvac_dynamic.system_name  LIKE '" , 37);
pushquote(q_hv.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.system_name   IS NULL) " , 40);
pushquote( "AND (hvac_dynamic.zone_number  LIKE '" , 37);
pushquote(q_hv.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.zone_number   IS NULL) " , 40);
pushquote( "AND (hvac_dynamic.apprv_stat   LIKE '" , 37);
pushquote(q_hv.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.apprv_stat    IS NULL) " , 40);
pushquote( "AND (hvac_dynamic.constr_stat  LIKE '" , 37);
pushquote(q_hv.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.constr_stat   IS NULL) " , 40);
pushquote(w_stmt,5000);
_doconcat(28,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du193: _anyerr = 0;
pushquote( "(piping_noz_dynamic.assembly_cat LIKE '" , 39);
pushquote(q_nz.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.assembly_cat  IS NULL) " , 46);
pushquote( "AND (piping_noz_dynamic.assembly_nam LIKE '" , 43);
pushquote(q_nz.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.assembly_nam  IS NULL) " , 46);
pushquote( "AND (piping_noz_dynamic.assembly_ver LIKE '" , 43);
pushquote(q_nz.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.assembly_ver  IS NULL) " , 46);
pushquote( "AND (piping_noz_dynamic.system_name  LIKE '" , 43);
pushquote(q_nz.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.system_name   IS NULL) " , 46);
pushquote( "AND (piping_noz_dynamic.zone_number  LIKE '" , 43);
pushquote(q_nz.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.zone_number   IS NULL) " , 46);
pushquote( "AND (piping_noz_dynamic.apprv_stat   LIKE '" , 43);
pushquote(q_nz.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.apprv_stat    IS NULL) " , 46);
pushquote( "AND (piping_noz_dynamic.constr_stat  LIKE '" , 43);
pushquote(q_nz.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.constr_stat   IS NULL) " , 46);
pushquote(w_stmt,5000);
_doconcat(28,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du194: _anyerr = 0;
pushquote( "(struct_pl_dynamic.assembly_cat LIKE '" , 38);
pushquote(q_pl.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.assembly_cat  IS NULL) " , 45);
pushquote( "AND (struct_pl_dynamic.assembly_nam LIKE '" , 42);
pushquote(q_pl.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.assembly_nam  IS NULL) " , 45);
pushquote( "AND (struct_pl_dynamic.assembly_ver LIKE '" , 42);
pushquote(q_pl.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.assembly_ver  IS NULL) " , 45);
pushquote( "AND (struct_pl_dynamic.zone_number  LIKE '" , 42);
pushquote(q_pl.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.zone_number   IS NULL) " , 45);
pushquote( "AND (struct_pl_dynamic.apprv_stat   LIKE '" , 42);
pushquote(q_pl.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.apprv_stat    IS NULL) " , 45);
pushquote( "AND (struct_pl_dynamic.constr_stat  LIKE '" , 42);
pushquote(q_pl.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.constr_stat   IS NULL) " , 45);
pushquote(w_stmt,5000);
_doconcat(24,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(6);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du195: _anyerr = 0;
pushquote( "(piping_dynamic.assembly_cat LIKE '" , 35);
pushquote(q_pp.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.assembly_cat  IS NULL) " , 42);
pushquote( "AND (piping_dynamic.assembly_nam LIKE '" , 39);
pushquote(q_pp.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.assembly_nam  IS NULL) " , 42);
pushquote( "AND (piping_dynamic.assembly_ver LIKE '" , 39);
pushquote(q_pp.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.assembly_ver  IS NULL) " , 42);
pushquote( "AND (piping_dynamic.system_name  LIKE '" , 39);
pushquote(q_pp.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.system_name   IS NULL) " , 42);
pushquote( "AND (piping_dynamic.zone_number  LIKE '" , 39);
pushquote(q_pp.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.zone_number   IS NULL) " , 42);
pushquote( "AND (piping_dynamic.apprv_stat   LIKE '" , 39);
pushquote(q_pp.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.apprv_stat    IS NULL) " , 42);
pushquote( "AND (piping_dynamic.constr_stat  LIKE '" , 39);
pushquote(q_pp.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.constr_stat   IS NULL) " , 42);
pushquote(w_stmt,5000);
_doconcat(28,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(7);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du196: _anyerr = 0;
pushquote( "(rway_dynamic.assembly_cat LIKE '" , 33);
pushquote(q_rw.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.assembly_cat  IS NULL) " , 40);
pushquote( "AND (rway_dynamic.assembly_nam LIKE '" , 37);
pushquote(q_rw.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.assembly_nam  IS NULL) " , 40);
pushquote( "AND (rway_dynamic.assembly_ver LIKE '" , 37);
pushquote(q_rw.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.assembly_ver  IS NULL) " , 40);
pushquote( "AND (rway_dynamic.system_name  LIKE '" , 37);
pushquote(q_rw.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.system_name   IS NULL) " , 40);
pushquote( "AND (rway_dynamic.zone_number  LIKE '" , 37);
pushquote(q_rw.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.zone_number   IS NULL) " , 40);
pushquote( "AND (rway_dynamic.apprv_stat   LIKE '" , 37);
pushquote(q_rw.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.apprv_stat    IS NULL) " , 40);
pushquote( "AND (rway_dynamic.constr_stat  LIKE '" , 37);
pushquote(q_rw.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.constr_stat   IS NULL) " , 40);
pushquote(w_stmt,5000);
_doconcat(28,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(10);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du197: _anyerr = 0;
pushquote( "(compart_dynamic.assembly_cat LIKE '" , 36);
pushquote(q_cm.assembly_cat,20);
_doclip();
pushquote( "'" , 1);
pushquote( " OR compart_dynamic.assembly_cat  IS NULL) " , 43);
pushquote( "AND (compart_dynamic.assembly_nam LIKE '" , 40);
pushquote(q_cm.assembly_nam,30);
_doclip();
pushquote( "'" , 1);
pushquote( " OR compart_dynamic.assembly_nam  IS NULL) " , 43);
pushquote( "AND (compart_dynamic.assembly_ver LIKE '" , 40);
pushquote(q_cm.assembly_ver,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR compart_dynamic.assembly_ver  IS NULL) " , 43);
pushquote( "AND (compart_dynamic.zone  LIKE '" , 33);
pushquote(q_cm.zone,80);
_doclip();
pushquote( "'" , 1);
pushquote( " OR compart_dynamic.zone  IS NULL) " , 35);
pushquote(w_stmt,5000);
_doconcat(16,0);
goto ll189;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll189:;
du198: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du199: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_case;
pushshort(product);
pushint(0);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du201: _anyerr = 0;
pushquote( "struct_bm_cit.dwg_cat          LIKE '" , 37);
pushquote(q_bm.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND struct_bm_cit.dwg_nam          LIKE '" , 41);
pushquote(q_bm.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND struct_bm_cit.dwg_rev          LIKE '" , 41);
pushquote(q_bm.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND struct_bm_cit.assembly_cat     = struct_bm_dynamic.assembly_cat "
 , 68);
pushquote( "AND struct_bm_cit.assembly_nam     = struct_bm_dynamic.assembly_nam "
 , 68);
pushquote( "AND struct_bm_cit.assembly_rev     = struct_bm_dynamic.assembly_ver "
 , 68);
pushquote( "AND struct_bm_cit.comp_seqno       = struct_bm_dynamic.comp_seqno "
 , 66);
pushquote( "AND (struct_bm_dynamic.zone_number LIKE '" , 41);
pushquote(q_bm.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.zone_number  IS NULL) " , 44);
pushquote( "AND (struct_bm_dynamic.apprv_stat  LIKE '" , 41);
pushquote(q_bm.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.apprv_stat   IS NULL) " , 44);
pushquote( "AND (struct_bm_dynamic.constr_stat LIKE '" , 41);
pushquote(q_bm.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_bm_dynamic.constr_stat  IS NULL) " , 44);
pushquote(w_stmt,5000);
_doconcat(25,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(1);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du202: _anyerr = 0;
pushquote( "    equip_cit.dwg_cat          LIKE '" , 37);
pushquote(q_eq.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND equip_cit.dwg_nam          LIKE '" , 37);
pushquote(q_eq.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND equip_cit.dwg_rev          LIKE '" , 37);
pushquote(q_eq.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND equip_cit.assembly_cat     = equip_dynamic.assembly_cat "
 , 60);
pushquote( "AND equip_cit.assembly_nam     = equip_dynamic.assembly_nam "
 , 60);
pushquote( "AND equip_cit.assembly_rev     = equip_dynamic.assembly_ver "
 , 60);
pushquote( "AND equip_cit.comp_seqno       = equip_dynamic.comp_seqno "
 , 58);
pushquote( "AND (equip_dynamic.zone_number LIKE '" , 37);
pushquote(q_eq.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.zone_number  IS NULL) " , 40);
pushquote( "AND (equip_dynamic.apprv_stat  LIKE '" , 37);
pushquote(q_eq.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.apprv_stat   IS NULL) " , 40);
pushquote( "AND (equip_dynamic.constr_stat LIKE '" , 37);
pushquote(q_eq.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR equip_dynamic.constr_stat  IS NULL) " , 40);
pushquote(w_stmt,5000);
_doconcat(25,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(2);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du203: _anyerr = 0;
pushquote( "hvac_cit.dwg_cat          LIKE '" , 32);
pushquote(q_hv.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND hvac_cit.dwg_nam          LIKE '" , 36);
pushquote(q_hv.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND hvac_cit.dwg_rev          LIKE '" , 36);
pushquote(q_hv.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND hvac_cit.assembly_cat     = hvac_dynamic.assembly_cat "
 , 58);
pushquote( "AND hvac_cit.assembly_nam     = hvac_dynamic.assembly_nam "
 , 58);
pushquote( "AND hvac_cit.assembly_rev     = hvac_dynamic.assembly_ver "
 , 58);
pushquote( "AND hvac_cit.comp_seqno       = hvac_dynamic.comp_seqno " , 56);
pushquote( "AND (hvac_dynamic.system_name LIKE '" , 36);
pushquote(q_hv.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.system_name  IS NULL) " , 39);
pushquote( "AND (hvac_dynamic.zone_number LIKE '" , 36);
pushquote(q_hv.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.zone_number  IS NULL) " , 39);
pushquote( "AND (hvac_dynamic.apprv_stat  LIKE '" , 36);
pushquote(q_hv.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.apprv_stat   IS NULL) " , 39);
pushquote( "AND (hvac_dynamic.constr_stat LIKE '" , 36);
pushquote(q_hv.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR hvac_dynamic.constr_stat  IS NULL) " , 39);
pushquote(w_stmt,5000);
_doconcat(29,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(3);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du204: _anyerr = 0;
pushquote( "piping_noz_cit.dwg_cat          LIKE '" , 38);
pushquote(q_nz.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND piping_noz_cit.dwg_nam          LIKE '" , 42);
pushquote(q_nz.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND piping_noz_cit.dwg_rev          LIKE '" , 42);
pushquote(q_nz.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND piping_noz_cit.assembly_cat     = piping_noz_dynamic.assembly_cat "
 , 70);
pushquote( "AND piping_noz_cit.assembly_nam     = piping_noz_dynamic.assembly_nam "
 , 70);
pushquote( "AND piping_noz_cit.assembly_rev     = piping_noz_dynamic.assembly_ver "
 , 70);
pushquote( "AND piping_noz_cit.comp_seqno       = piping_noz_dynamic.comp_seqno "
 , 68);
pushquote( "AND (piping_noz_dynamic.system_name LIKE '" , 42);
pushquote(q_nz.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.system_name  IS NULL) " , 45);
pushquote( "AND (piping_noz_dynamic.zone_number LIKE '" , 42);
pushquote(q_nz.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.zone_number  IS NULL) " , 45);
pushquote( "AND (piping_noz_dynamic.apprv_stat  LIKE '" , 42);
pushquote(q_nz.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.apprv_stat   IS NULL) " , 45);
pushquote( "AND (piping_noz_dynamic.constr_stat LIKE '" , 42);
pushquote(q_nz.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_noz_dynamic.constr_stat  IS NULL) " , 45);
pushquote(w_stmt,5000);
_doconcat(29,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(5);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du205: _anyerr = 0;
pushquote( "struct_pl_cit.dwg_cat          LIKE '" , 37);
pushquote(q_pl.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND struct_pl_cit.dwg_nam          LIKE '" , 41);
pushquote(q_pl.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND struct_pl_cit.dwg_rev          LIKE '" , 41);
pushquote(q_pl.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND struct_pl_cit.assembly_cat     = struct_pl_dynamic.assembly_cat "
 , 68);
pushquote( "AND struct_pl_cit.assembly_nam     = struct_pl_dynamic.assembly_nam "
 , 68);
pushquote( "AND struct_pl_cit.assembly_rev     = struct_pl_dynamic.assembly_ver "
 , 68);
pushquote( "AND struct_pl_cit.comp_seqno       = struct_pl_dynamic.comp_seqno "
 , 66);
pushquote( "AND (struct_pl_dynamic.zone_number LIKE '" , 41);
pushquote(q_pl.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.zone_number  IS NULL) " , 44);
pushquote( "AND (struct_pl_dynamic.apprv_stat  LIKE '" , 41);
pushquote(q_pl.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.apprv_stat   IS NULL) " , 44);
pushquote( "AND (struct_pl_dynamic.constr_stat LIKE '" , 41);
pushquote(q_pl.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR struct_pl_dynamic.constr_stat  IS NULL) " , 44);
pushquote(w_stmt,5000);
_doconcat(25,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(6);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du206: _anyerr = 0;
pushquote( "piping_cit.dwg_cat          LIKE '" , 34);
pushquote(q_pp.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND piping_cit.dwg_nam          LIKE '" , 38);
pushquote(q_pp.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND piping_cit.dwg_rev          LIKE '" , 38);
pushquote(q_pp.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND piping_cit.assembly_cat     = piping_dynamic.assembly_cat "
 , 62);
pushquote( "AND piping_cit.assembly_nam     = piping_dynamic.assembly_nam "
 , 62);
pushquote( "AND piping_cit.assembly_rev     = piping_dynamic.assembly_ver "
 , 62);
pushquote( "AND piping_cit.comp_seqno       = piping_dynamic.comp_seqno "
 , 60);
pushquote( "AND (piping_dynamic.system_name LIKE '" , 38);
pushquote(q_pp.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.system_name  IS NULL) " , 41);
pushquote( "AND (piping_dynamic.zone_number LIKE '" , 38);
pushquote(q_pp.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.zone_number  IS NULL) " , 41);
pushquote( "AND (piping_dynamic.apprv_stat  LIKE '" , 38);
pushquote(q_pp.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.apprv_stat   IS NULL) " , 41);
pushquote( "AND (piping_dynamic.constr_stat LIKE '" , 38);
pushquote(q_pp.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR piping_dynamic.constr_stat  IS NULL) " , 41);
pushquote(w_stmt,5000);
_doconcat(29,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(7);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du207: _anyerr = 0;
pushquote( "rway_cit.dwg_cat          LIKE '" , 32);
pushquote(q_rw.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND rway_cit.dwg_nam          LIKE '" , 36);
pushquote(q_rw.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND rway_cit.dwg_rev          LIKE '" , 36);
pushquote(q_rw.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND rway_cit.assembly_cat     = rway_dynamic.assembly_cat "
 , 58);
pushquote( "AND rway_cit.assembly_nam     = rway_dynamic.assembly_nam "
 , 58);
pushquote( "AND rway_cit.assembly_rev     = rway_dynamic.assembly_ver "
 , 58);
pushquote( "AND rway_cit.comp_seqno       = rway_dynamic.comp_seqno " , 56);
pushquote( "AND (rway_dynamic.system_name LIKE '" , 36);
pushquote(q_rw.system_name,12);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.system_name  IS NULL) " , 39);
pushquote( "AND (rway_dynamic.zone_number LIKE '" , 36);
pushquote(q_rw.zone_number,4);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.zone_number  IS NULL) " , 39);
pushquote( "AND (rway_dynamic.apprv_stat  LIKE '" , 36);
pushquote(q_rw.apprv_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.apprv_stat   IS NULL) " , 39);
pushquote( "AND (rway_dynamic.constr_stat LIKE '" , 36);
pushquote(q_rw.constr_stat,8);
_doclip();
pushquote( "'" , 1);
pushquote( " OR rway_dynamic.constr_stat  IS NULL) " , 39);
pushquote(w_stmt,5000);
_doconcat(29,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushint(10);
_doeqnopop();
popbool(&fgl_case);
if (fgl_case)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
popdummy();
du208: _anyerr = 0;
pushquote( "compart_cit.dwg_cat          LIKE '" , 35);
pushquote(q_cm.assembly_cat,20);
_doclip();
pushquote( "' " , 2);
pushquote( "AND compart_cit.dwg_nam          LIKE '" , 39);
pushquote(q_cm.assembly_nam,30);
_doclip();
pushquote( "' " , 2);
pushquote( "AND compart_cit.dwg_rev          LIKE '" , 39);
pushquote(q_cm.assembly_ver,12);
_doclip();
pushquote( "' " , 2);
pushquote( "AND compart_cit.assembly_cat     = compart_dynamic.assembly_cat "
 , 64);
pushquote( "AND compart_cit.assembly_nam     = compart_dynamic.assembly_nam "
 , 64);
pushquote( "AND compart_cit.assembly_rev     = compart_dynamic.assembly_ver "
 , 64);
pushquote( "AND compart_cit.comp_seqno       = compart_dynamic.comp_seqno "
 , 62);
pushquote( "AND (compart_dynamic.zone LIKE '" , 32);
pushquote(q_cm.zone,80);
_doclip();
pushquote( "'" , 1);
pushquote( " OR compart_dynamic.zone IS NULL) " , 34);
pushquote(w_stmt,5000);
_doconcat(17,0);
goto ll200;
;

/*
 * SQL SEES BLOCK ENDING
 */
}
popdummy();

/*
 * SQL SEES BLOCK ENDING
 */
}
ll200:;
du209: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du210: _anyerr = 0;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
