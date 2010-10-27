#include <sqlfm.h>
#include <sqlhdr.h>
static _SQCURSOR _SQ4, _SQ3, _SQ2, _SQ1;

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
extern short drawing_flag;
extern short eq_unit_flag;
extern char joker[3];
extern char errorlog_msg[133];
extern char nsts_err_msg[81];
extern char underline[81];
extern char q_stmt[10001];
extern char s_stmt[2001];
extern char f_stmt[2001];
extern char w_stmt[5001];
extern char g_stmt[2001];
extern char o_stmt[2001];
extern char w_reg[5001];
extern char f_reg[1001];
extern struct
  {
    char prj_number[17];
    char prj_name[41];
    char prj_location[41];
    short prj_units_set;
    short prj_no;
  }  p_vds;
extern char rpt_req[4];
extern char rpt_dsc1[41];
extern char rpt_dsc2[41];
extern double def_vcog;
extern double def_lcog;
extern double def_tcog;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_bm;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_bm;
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_rev[13];
    char item_no[13];
    long comp_seqno;
  }  p_bmd1[5000];
extern struct
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
extern struct
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
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_eq;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_eq;
extern struct
  {
    char eqp_type[13];
    char eqp_number[21];
    char eqp_descr[41];
    char eqp_partno[31];
  }  p_eqb;
extern struct
  {
    short chg_no;
    char eqp_number[21];
    char eqp_partno[31];
    char eqp_descr[41];
    float wet_weight;
    char long_txt[81];
  }  p_eqn;
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_hv;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_hv;
extern struct
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
extern struct
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
extern struct
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
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_nz;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_nz;
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_pl;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_pl;
extern struct
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
extern struct
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
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_pp;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_pp;
extern struct
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
extern struct
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
extern struct
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
extern struct
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
extern struct
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
extern struct
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
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  p_rw;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char system_name[13];
    char zone_number[5];
    char apprv_stat[9];
    char constr_stat[9];
  }  q_rw;
extern struct
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
extern struct
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
extern struct
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
extern struct
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
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone[81];
  }  p_cm;
extern struct
  {
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char zone[81];
  }  q_cm;
extern struct
  {
    char name[81];
    char descript[81];
    char space_class[81];
    double floor_area;
    double volume;
  }  p_cmb;
extern struct
  {
    char dwg_cat[21];
    char dwg_nam[31];
    char dwg_rev[13];
  }  p_bp;
extern struct
  {
    char dwg_cat[21];
    char dwg_nam[31];
    char dwg_rev[13];
  }  q_bp;
extern long p_pce;
extern double p_len;
extern double p_srf;
extern double p_vol;
extern double p_wgt;
extern double p_vmm;
extern double p_lmm;
extern double p_tmm;
extern long g_pce;
extern double g_srf;
extern double g_vol;
extern double g_wgt;
extern double g_vmm;
extern double g_lmm;
extern double g_tmm;
extern struct
  {
    char rpt_req[4];
    char rpt_dsc1[41];
    char rpt_dsc2[41];
    double def_lcog;
    double def_tcog;
    double def_vcog;
  }  p_frm0;
extern struct
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
extern struct
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
extern struct
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
extern struct
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
extern struct
  {
    char spec_name[9];
    char comp_code[7];
    short opt_code;
  }  p_form3;
extern struct
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
extern float npd_grn;
extern float npd_red;
extern char size1[21], size2[21], size3[21], size4[21];
extern char msg[301];
static char *fgl_modname = "../lib/RPTconv.4gl";
foot_and_inch (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
double len;
long foot;
long inch;
du0: _anyerr = 0;
popdub(&len);
pushdub(&len);
pushint(1);
_dodiv();
poplong(&foot);
pushdub(&len);
pushlong(foot);
_dosub();
pushint(12);
_domult();
poplong(&inch);
pushlong(foot);
pushlong(inch);
doretalloc(2);
if (1) return(2);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
element_length (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
double number;
long divider;
long foot;
double inch;
double meter;
char str[11];
char len[14];
du1: _anyerr = 0;
poplong(&divider);
popdub(&number);
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
pushdub(&number);
pushstrdec(" 12.0 ");
_dodiv();
poplong(&foot);
pushdub(&number);
pushlong(foot);
pushstrdec(" 12.0 ");
_domult();
_dosub();
popdub(&inch);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushdub(&inch);
pushlong(divider);
fgl_nret = fraction_format(2);
rest_stack(fgl_svstk);
du2: _anyerr = 0;
 ld_quote(0, str, 11) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushlong(foot);
pushquote( "<<<<&" , 5);
_dousing(0);
pushquote( "\'-" , 2);
pushquote(str,10);
_doclip();
pushquote( "\"" , 1);
pushquote(len,13);
_doconcat(4,0);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du3: _anyerr = 0;
pushdub(&number);
pushstrdec(" 1000.0 ");
_dodiv();
popdub(&meter);
pushdub(&meter);
pushquote( "<<<<&.<<<" , 9);
_dousing(0);
popquote(len,14);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du4: _anyerr = 0;
pushquote(len,13);
doretalloc(1);
if (1) return(1);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
element_size (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
struct
  {
    short e_code;
    char e_desc[81];
    float dg;
    float dr;
    float wg;
    float wr;
  }  f_args;
long green;
long red;
char e_size[31];
char g_size[31];
char r_size[31];
char sign[4];
du5: _anyerr = 0;
_popstack(6);
ld_short(0, &f_args.e_code);
ld_quote(1, f_args.e_desc, 81);
ld_flo(2, &f_args.dg);
ld_flo(3, &f_args.dr);
ld_flo(4, &f_args.wg);
ld_flo(5, &f_args.wr);
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
pushquote( "\"" , 1);
popquote(sign,4);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du6: _anyerr = 0;
pushquote( "" , 0);
popquote(sign,4);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du7: _anyerr = 0;
pushshort(f_args.e_code);
pushint(1);
_doople();


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
pushflo(&f_args.wr);
pushflo(&f_args.wg);
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
pushflo(&f_args.wg);
pushquote( "<<<<&" , 5);
_dousing(0);
pushflo(&f_args.dg);
pushquote( "x<<<<&" , 6);
_dousing(0);
pushquote(sign,3);
_doclip();
pushflo(&f_args.wr);
pushquote( ",<<<<&" , 6);
_dousing(0);
pushflo(&f_args.dr);
pushquote( "x<<<<&" , 6);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(e_size,30);
_doconcat(6,0);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du8: _anyerr = 0;
pushflo(&f_args.wg);
pushquote( "<<<<&" , 5);
_dousing(0);
pushquote( "x" , 1);
pushflo(&f_args.dg);
pushquote( "<<<<&" , 5);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(e_size,30);
_doconcat(4,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du9: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du10: _anyerr = 0;
pushshort(f_args.e_code);
pushint(2);
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
pushflo(&f_args.wr);
pushflo(&f_args.wr);
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
pushflo(&f_args.wg);
pushquote( "<<<<&" , 5);
_dousing(0);
pushflo(&f_args.wr);
pushquote( "x<<<<&" , 6);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(e_size,30);
_doconcat(3,0);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du11: _anyerr = 0;
pushflo(&f_args.wg);
pushquote( "<<<<&" , 5);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(e_size,30);
_doconcat(2,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du12: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du13: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(f_args.e_desc,80);
pushint(1);
pushquote(f_args.e_desc,80);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_nret;;
fgl_nret = length(1);
du14: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
_doadd();
fgl_nret = shape_determination(2);
rest_stack(fgl_svstk);
du15: _anyerr = 0;
 ld_long(0, &green) ;
 ld_long(1, &red) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushlong(green);
pushint(1);
_doople();


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
pushflo(&f_args.wg);
pushquote( "<<<<&" , 5);
_dousing(0);
pushflo(&f_args.dg);
pushquote( "x<<<<&" , 6);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(g_size,30);
_doconcat(3,0);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du16: _anyerr = 0;
pushflo(&f_args.wg);
pushquote( "<<<<&" , 5);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(g_size,30);
_doconcat(2,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du17: _anyerr = 0;
pushflo(&f_args.wg);
pushstrdec(" 0.0 ");
_doopgt();


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
pushlong(red);
pushint(1);
_doople();


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
pushflo(&f_args.wr);
pushquote( "<<<<&" , 5);
_dousing(0);
pushflo(&f_args.dr);
pushquote( "x<<<<&" , 6);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(r_size,30);
_doconcat(3,0);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du18: _anyerr = 0;
pushflo(&f_args.wr);
pushquote( "<<<<&" , 5);
_dousing(0);
pushquote(sign,3);
_doclip();
pushquote(r_size,30);
_doconcat(2,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du19: _anyerr = 0;
pushquote(g_size,30);
_doclip();
pushquote( "," , 1);
pushquote(r_size,30);
_doclip();
pushquote(e_size,30);
_doconcat(3,0);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du20: _anyerr = 0;
pushquote(g_size,30);
_doclip();
popquote(e_size,31);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du21: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du22: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du23: _anyerr = 0;
pushquote(e_size,30);
doretalloc(1);
if (1) return(1);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
size_of_element (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
double green;
double red;
double m_green;
double m_red;
char e_size[31];
char str_g[31];
char str_r[31];
long divider;
du24: _anyerr = 0;
popdub(&red);
popdub(&green);
pushshort(p_vds.prj_units_set);
pushint(20);
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
pushstrdec(" 1.0 ");
_doneg();
popdub(&m_green);
pushstrdec(" 1.0 ");
_doneg();
popdub(&m_red);

/*
 * $  select unique npdg.npd_equiv , npdr.npd_equiv into $m_green , $m_red from
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select unique npdg . npd_equiv , npdr . npd_equiv from",
   " piping_npd_allowed npdg , piping_npd_allowed npdr where ( npdg .",
   " tblno = 0 and npdg . npd = ? ) and ( npdr . tblno = 0 and npdr . npd",
   " = ? )",
  (char *) 0
  };
 static _SQCURSOR _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {105, sizeof(green), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {105, sizeof(red), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 static struct sqlvar_struct _sqobind[] = 
 {
 {105, sizeof(m_green), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {105, sizeof(m_red), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (char *) &(green);
 _sqibind[1].sqldata = (char *) &(red);
 _sqobind[0].sqldata = (char *) &(m_green);
 _sqobind[1].sqldata = (char *) &(m_red);
 _iqslct(&_SQ0, sqlcmdtxt, 2, _sqibind, 2, _sqobind, 0);
 }
status = sqlca.sqlcode;
pushdub(&m_green);
pushstrdec(" 1.0 ");
_doneg();
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
pushdub(&green);
popdub(&m_green);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du25: _anyerr = 0;
pushdub(&m_red);
pushstrdec(" 1.0 ");
_doneg();
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
pushdub(&red);
popdub(&m_red);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du26: _anyerr = 0;
pushdub(&m_red);
pushstrdec(" 0.0 ");
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
pushdub(&m_green);
pushquote( "<<<<&" , 5);
_dousing(0);
popquote(e_size,31);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du27: _anyerr = 0;
pushdub(&m_green);
pushquote( "<<<<&" , 5);
_dousing(0);
pushdub(&m_red);
pushquote( "x<<<<&" , 6);
_dousing(0);
pushquote(e_size,30);
_doconcat(2,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du28: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du29: _anyerr = 0;
pushint(4);
poplong(&divider);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushdub(&green);
pushlong(divider);
fgl_nret = fraction_format(2);
rest_stack(fgl_svstk);
du30: _anyerr = 0;
 ld_quote(0, str_g, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushdub(&red);
pushstrdec(" 0.0 ");
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
pushquote(str_g,30);
_doclip();
pushquote( "\"" , 1);
pushquote(e_size,30);
_doconcat(2,0);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du31: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushdub(&red);
pushlong(divider);
fgl_nret = fraction_format(2);
rest_stack(fgl_svstk);
du32: _anyerr = 0;
 ld_quote(0, str_r, 31) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushquote(str_g,30);
_doclip();
pushquote( "x" , 1);
pushquote(str_r,30);
_doclip();
pushquote( "\"" , 1);
pushquote(e_size,30);
_doconcat(4,0);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du33: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du34: _anyerr = 0;
pushquote(e_size,30);
doretalloc(1);
if (1) return(1);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
update_piping_on (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
du35: _anyerr = 0;

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;

/*
 * $  begin work;
 */
 {
 _iqbeginwork();
 }
status = sqlca.sqlcode;

/*
 * $  update piping_dynamic set npd_r = npd_g where npd_r = 0.00;
 */
 {
 static char *sqlcmdtxt[] =
  {
  " update piping_dynamic set npd_r = npd_g where npd_r = 0.00",
  (char *) 0
  };
 static _SQSTMT _SQ0 = {0};
 _iqstmnt(&_SQ0, sqlcmdtxt, 0, (char *) 0, (char *) 0);
 }
status = sqlca.sqlcode;

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
update_piping_off (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
du36: _anyerr = 0;

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;

/*
 * $  begin work;
 */
 {
 _iqbeginwork();
 }
status = sqlca.sqlcode;

/*
 * $  update piping_dynamic set npd_r = 0.00 where npd_r = npd_g;
 */
 {
 static char *sqlcmdtxt[] =
  {
  " update piping_dynamic set npd_r = 0.00 where npd_r = npd_g",
  (char *) 0
  };
 static _SQSTMT _SQ0 = {0};
 _iqstmnt(&_SQ0, sqlcmdtxt, 0, (char *) 0, (char *) 0);
 }
status = sqlca.sqlcode;

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
update_hvac (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
struct
  {
    float width_g;
    float depth_g;
    float width_r;
    float depth_r;
    long comp_seqno;
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char spec_name[9];
  }  hvac_dyn[5000];
long hv_cnt, i;
char hv_message[81];
char hv_spec[9];
du37: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int _fglidx0;
for (_fglidx0= 0; _fglidx0 < 5000; _fglidx0++)


/*
 * SQL SEES BLOCK BEGINNING
 */
{

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  declare hv_curs cursor for select width_g , depth_g , width_r , depth_r ,
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select width_g , depth_g , width_r , depth_r , comp_seqno ,",
   " assembly_cat , assembly_nam , assembly_ver , spec_name from",
   " hvac_dynamic where assembly_cat like ? and assembly_nam like ? and",
   " assembly_ver like ?",
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
 _iqdclcur(&_SQ1, "hv_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
pushint(1);
poplong(&hv_cnt);

/*
 * $  open hv_curs;
 */
 {
 _iqcopen(&_SQ1, 0, (char *) 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
while (1)

/*
 * SQL SEES BLOCK BEGINNING
 */
{

/*
 * $  fetch hv_curs into $hvac_dyn[(hv_cnt)-1].width_g ,
 */
 {
 static struct sqlvar_struct _sqobind[] = 
 {
 {104, sizeof(hvac_dyn[(hv_cnt)-1].width_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(hvac_dyn[(hv_cnt)-1].depth_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(hvac_dyn[(hv_cnt)-1].width_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(hvac_dyn[(hv_cnt)-1].depth_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {103, sizeof(hvac_dyn[(hv_cnt)-1].comp_seqno), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqobind[0].sqldata = (char *) &(hvac_dyn[(hv_cnt)-1].width_g);
 _sqobind[1].sqldata = (char *) &(hvac_dyn[(hv_cnt)-1].depth_g);
 _sqobind[2].sqldata = (char *) &(hvac_dyn[(hv_cnt)-1].width_r);
 _sqobind[3].sqldata = (char *) &(hvac_dyn[(hv_cnt)-1].depth_r);
 _sqobind[4].sqldata = (char *) &(hvac_dyn[(hv_cnt)-1].comp_seqno);
 _sqobind[5].sqldata = (hvac_dyn[(hv_cnt)-1].assembly_cat);
 _sqobind[6].sqldata = (hvac_dyn[(hv_cnt)-1].assembly_nam);
 _sqobind[7].sqldata = (hvac_dyn[(hv_cnt)-1].assembly_ver);
 _sqobind[8].sqldata = (hvac_dyn[(hv_cnt)-1].spec_name);
 _iqnftch(&_SQ1, 9, _sqobind, (char *) 0, 1, (long) 0, 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
du38: _anyerr = 0;
if (status == 100) break;
pushint(status);
pushint(0);
_dooplt();


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
pushquote( "No rows found in query" , 22);
popquote(hv_message,81);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(hv_message,80);
fgl_nret = errorlog(1);
rest_stack(fgl_svstk);
du39: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  message $hv_message;
 */
{

static struct sqlvar_struct _sqibind[] = {
	{100, sizeof(hv_message)}, 
	};
_sqibind[0].sqldata =(hv_message);
	_efmsg(1,  _sqibind,  (long)-1);
}
status = efcode;
pushint(3);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_tm1;
popint(&fgl_tm1);
sleep((unsigned)fgl_tm1);

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll40;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du41: _anyerr = 0;
pushlong(hv_cnt);
pushint(5000);
_doopgt();


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
pushquote( "Can only update the 5000 first rows" , 35);
popquote(hv_message,81);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(hv_message,80);
fgl_nret = errorlog(1);
rest_stack(fgl_svstk);
du42: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  message $hv_message;
 */
{

static struct sqlvar_struct _sqibind[] = {
	{100, sizeof(hv_message)}, 
	};
_sqibind[0].sqldata =(hv_message);
	_efmsg(1,  _sqibind,  (long)-1);
}
status = efcode;
goto ll40;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du43: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushflo(&hvac_dyn[(hv_cnt)-1].width_g);
pushflo(&hvac_dyn[(hv_cnt)-1].depth_g);
pushflo(&hvac_dyn[(hv_cnt)-1].width_r);
pushflo(&hvac_dyn[(hv_cnt)-1].depth_r);
pushlong(hvac_dyn[(hv_cnt)-1].comp_seqno);
pushquote(hvac_dyn[(hv_cnt)-1].assembly_cat,20);
pushquote(hvac_dyn[(hv_cnt)-1].assembly_nam,30);
pushquote(hvac_dyn[(hv_cnt)-1].assembly_ver,12);
pushquote(hvac_dyn[(hv_cnt)-1].spec_name,8);
fgl_nret = correct_hvcheckin(9);
rest_stack(fgl_svstk);
du44: _anyerr = 0;
 ld_flo(0, &hvac_dyn[(hv_cnt)-1].width_g) ;

 ld_flo(1, &hvac_dyn[(hv_cnt)-1].depth_g) ;

 ld_flo(2, &hvac_dyn[(hv_cnt)-1].width_r) ;

 ld_flo(3, &hvac_dyn[(hv_cnt)-1].depth_r) ;

 ld_long(4, &hvac_dyn[(hv_cnt)-1].comp_seqno) ;

 ld_quote(5, hvac_dyn[(hv_cnt)-1].assembly_cat, 21) ;

 ld_quote(6, hvac_dyn[(hv_cnt)-1].assembly_nam, 31) ;

 ld_quote(7, hvac_dyn[(hv_cnt)-1].assembly_ver, 13) ;

 ld_quote(8, hvac_dyn[(hv_cnt)-1].spec_name, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushlong(hv_cnt);
pushint(1);
_doadd();
poplong(&hv_cnt);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du45: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du46: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
ll40:;

/*
 * $  close hv_curs;
 */
 {
 _iqclose(&_SQ1);
 }
status = sqlca.sqlcode;
du47: _anyerr = 0;
pushlong(hv_cnt);
pushint(1);
_dosub();
poplong(&hv_cnt);
pushquote( "Updating " , 9);
pushlong(hv_cnt);
pushquote( "<<<<" , 4);
_dousing(0);
pushquote( " rows ..." , 9);
pushquote(hv_message,80);
_doconcat(3,0);

/*
 * $  message $hv_message;
 */
{

static struct sqlvar_struct _sqibind[] = {
	{100, sizeof(hv_message)}, 
	};
_sqibind[0].sqldata =(hv_message);
	_efmsg(1,  _sqibind,  (long)-1);
}
status = efcode;
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
pushquote( "SERV1" , 5);
popquote(hv_spec,9);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du48: _anyerr = 0;
pushquote( "SERV2" , 5);
popquote(hv_spec,9);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du49: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
long fgl_fr1, fgl_fr2, fgl_fr3;
pushint(1);
poplong(&fgl_fr1);
i  = fgl_fr1;
while(1)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du50: _anyerr = 0;
pushlong(hv_cnt);
poplong(&fgl_fr2);
fgl_fr3 = 1;
if (fgl_fr3 < 0 && i < fgl_fr2) break;
if (fgl_fr3 >= 0 && i > fgl_fr2) break;
pushquote(hvac_dyn[(i)-1].spec_name,8);
pushquote(hv_spec,8);
_doopne();
pushquote(hvac_dyn[(i)-1].spec_name,8);
isnull();
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

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;

/*
 * $  begin work;
 */
 {
 _iqbeginwork();
 }
status = sqlca.sqlcode;

/*
 * $  update hvac_dynamic set spec_name = $hv_spec , width_g =
 */
 {
 static char *sqlcmdtxt[] =
  {
  " update hvac_dynamic set spec_name = ? , width_g = ? , depth_g = ? ,",
   " width_r = ? , depth_r = ? where comp_seqno = ? and assembly_cat = ?",
   " and assembly_nam = ? and assembly_ver = ?",
  (char *) 0
  };
 static _SQSTMT _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(hvac_dyn[(i)-1].width_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(hvac_dyn[(i)-1].depth_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(hvac_dyn[(i)-1].width_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(hvac_dyn[(i)-1].depth_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {103, sizeof(hvac_dyn[(i)-1].comp_seqno), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (hv_spec);
 _sqibind[1].sqldata = (char *) &(hvac_dyn[(i)-1].width_g);
 _sqibind[2].sqldata = (char *) &(hvac_dyn[(i)-1].depth_g);
 _sqibind[3].sqldata = (char *) &(hvac_dyn[(i)-1].width_r);
 _sqibind[4].sqldata = (char *) &(hvac_dyn[(i)-1].depth_r);
 _sqibind[5].sqldata = (char *) &(hvac_dyn[(i)-1].comp_seqno);
 _sqibind[6].sqldata = (hvac_dyn[(i)-1].assembly_cat);
 _sqibind[7].sqldata = (hvac_dyn[(i)-1].assembly_nam);
 _sqibind[8].sqldata = (hvac_dyn[(i)-1].assembly_ver);
 _iqstmnt(&_SQ0, sqlcmdtxt, 9, _sqibind, (char *) 0);
 }
status = sqlca.sqlcode;

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du51: _anyerr = 0;
i  += fgl_fr3;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du52: _anyerr = 0;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
correct_hvcheckin (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
struct
  {
    float width_g;
    float depth_g;
    float width_r;
    float depth_r;
    long comp_seqno;
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char spec_name[9];
  }  hvac_dyn;
double wg, dg, wr, dr;
du53: _anyerr = 0;
_popstack(9);
ld_flo(0, &hvac_dyn.width_g);
ld_flo(1, &hvac_dyn.depth_g);
ld_flo(2, &hvac_dyn.width_r);
ld_flo(3, &hvac_dyn.depth_r);
ld_long(4, &hvac_dyn.comp_seqno);
ld_quote(5, hvac_dyn.assembly_cat, 21);
ld_quote(6, hvac_dyn.assembly_nam, 31);
ld_quote(7, hvac_dyn.assembly_ver, 13);
ld_quote(8, hvac_dyn.spec_name, 9);
pushflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.depth_g);
_doopge();
pushflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.width_r);
_doopge();
_doandop();
pushflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.depth_r);
_doopge();
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

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du54: _anyerr = 0;
pushflo(&hvac_dyn.depth_g);
pushflo(&hvac_dyn.width_g);
_doopge();
pushflo(&hvac_dyn.depth_g);
pushflo(&hvac_dyn.width_r);
_doopge();
_doandop();
pushflo(&hvac_dyn.depth_g);
pushflo(&hvac_dyn.depth_r);
_doopge();
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
pushflo(&hvac_dyn.depth_g);
popdub(&wg);
pushflo(&hvac_dyn.width_g);
popflo(&hvac_dyn.depth_g);
pushdub(&wg);
popflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.depth_r);
popdub(&wr);
pushflo(&hvac_dyn.width_r);
popflo(&hvac_dyn.depth_r);
pushdub(&wr);
popflo(&hvac_dyn.width_r);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du55: _anyerr = 0;
pushflo(&hvac_dyn.width_r);
pushflo(&hvac_dyn.width_g);
_doopge();
pushflo(&hvac_dyn.width_r);
pushflo(&hvac_dyn.depth_g);
_doopge();
_doandop();
pushflo(&hvac_dyn.width_r);
pushflo(&hvac_dyn.depth_r);
_doopge();
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
pushflo(&hvac_dyn.width_g);
popdub(&wg);
pushflo(&hvac_dyn.depth_g);
popdub(&dg);
pushflo(&hvac_dyn.width_r);
popflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.depth_r);
popflo(&hvac_dyn.depth_g);
pushdub(&wg);
popflo(&hvac_dyn.width_r);
pushdub(&dg);
popflo(&hvac_dyn.depth_r);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du56: _anyerr = 0;
pushflo(&hvac_dyn.width_g);
popdub(&wg);
pushflo(&hvac_dyn.depth_g);
popdub(&dg);
pushflo(&hvac_dyn.depth_r);
popflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.width_r);
popflo(&hvac_dyn.depth_g);
pushdub(&wg);
popflo(&hvac_dyn.width_r);
pushdub(&dg);
popflo(&hvac_dyn.depth_r);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du57: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du58: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du59: _anyerr = 0;
pushflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.width_r);
_doopeq();
pushflo(&hvac_dyn.depth_g);
pushflo(&hvac_dyn.depth_r);
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
pushstrdec(" 0.00 ");
popflo(&hvac_dyn.width_r);
pushstrdec(" 0.00 ");
popflo(&hvac_dyn.depth_r);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du60: _anyerr = 0;
pushflo(&hvac_dyn.width_g);
pushflo(&hvac_dyn.depth_g);
pushflo(&hvac_dyn.width_r);
pushflo(&hvac_dyn.depth_r);
pushlong(hvac_dyn.comp_seqno);
pushquote(hvac_dyn.assembly_cat,20);
pushquote(hvac_dyn.assembly_nam,30);
pushquote(hvac_dyn.assembly_ver,12);
pushquote(hvac_dyn.spec_name,8);
doretalloc(9);
if (1) return(9);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
update_rway (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
struct
  {
    float width_g;
    float depth_g;
    float width_r;
    float depth_r;
    long comp_seqno;
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char spec_name[9];
  }  rway_dyn[5000];
long rw_cnt, i;
char rw_message[81];
char rw_spec[9];
du61: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int _fglidx1;
for (_fglidx1= 0; _fglidx1 < 5000; _fglidx1++)


/*
 * SQL SEES BLOCK BEGINNING
 */
{

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  declare rw_curs cursor for select width_g , depth_g , width_r , depth_r ,
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select width_g , depth_g , width_r , depth_r , comp_seqno ,",
   " assembly_cat , assembly_nam , assembly_ver , spec_name from",
   " rway_dynamic where assembly_cat like ? and assembly_nam like ? and",
   " assembly_ver like ?",
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
 _iqdclcur(&_SQ2, "rw_curs", sqlcmdtxt, 3, _sqibind, 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
pushint(1);
poplong(&rw_cnt);

/*
 * $  open rw_curs;
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
 * $  fetch rw_curs into $rway_dyn[(rw_cnt)-1].width_g ,
 */
 {
 static struct sqlvar_struct _sqobind[] = 
 {
 {104, sizeof(rway_dyn[(rw_cnt)-1].width_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(rway_dyn[(rw_cnt)-1].depth_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(rway_dyn[(rw_cnt)-1].width_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(rway_dyn[(rw_cnt)-1].depth_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {103, sizeof(rway_dyn[(rw_cnt)-1].comp_seqno), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqobind[0].sqldata = (char *) &(rway_dyn[(rw_cnt)-1].width_g);
 _sqobind[1].sqldata = (char *) &(rway_dyn[(rw_cnt)-1].depth_g);
 _sqobind[2].sqldata = (char *) &(rway_dyn[(rw_cnt)-1].width_r);
 _sqobind[3].sqldata = (char *) &(rway_dyn[(rw_cnt)-1].depth_r);
 _sqobind[4].sqldata = (char *) &(rway_dyn[(rw_cnt)-1].comp_seqno);
 _sqobind[5].sqldata = (rway_dyn[(rw_cnt)-1].assembly_cat);
 _sqobind[6].sqldata = (rway_dyn[(rw_cnt)-1].assembly_nam);
 _sqobind[7].sqldata = (rway_dyn[(rw_cnt)-1].assembly_ver);
 _sqobind[8].sqldata = (rway_dyn[(rw_cnt)-1].spec_name);
 _iqnftch(&_SQ2, 9, _sqobind, (char *) 0, 1, (long) 0, 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
du62: _anyerr = 0;
if (status == 100) break;
pushint(status);
pushint(0);
_dooplt();


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
pushquote( "No rows found in query" , 22);
popquote(rw_message,81);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(rw_message,80);
fgl_nret = errorlog(1);
rest_stack(fgl_svstk);
du63: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  message $rw_message;
 */
{

static struct sqlvar_struct _sqibind[] = {
	{100, sizeof(rw_message)}, 
	};
_sqibind[0].sqldata =(rw_message);
	_efmsg(1,  _sqibind,  (long)-1);
}
status = efcode;
pushint(3);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_tm1;
popint(&fgl_tm1);
sleep((unsigned)fgl_tm1);

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll64;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du65: _anyerr = 0;
pushlong(rw_cnt);
pushint(5000);
_doopgt();


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
pushquote( "Can only update the 5000 first rows" , 35);
popquote(rw_message,81);


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushquote(rw_message,80);
fgl_nret = errorlog(1);
rest_stack(fgl_svstk);
du66: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * $  message $rw_message;
 */
{

static struct sqlvar_struct _sqibind[] = {
	{100, sizeof(rw_message)}, 
	};
_sqibind[0].sqldata =(rw_message);
	_efmsg(1,  _sqibind,  (long)-1);
}
status = efcode;
goto ll64;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du67: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushflo(&rway_dyn[(rw_cnt)-1].width_g);
pushflo(&rway_dyn[(rw_cnt)-1].depth_g);
pushflo(&rway_dyn[(rw_cnt)-1].width_r);
pushflo(&rway_dyn[(rw_cnt)-1].depth_r);
pushlong(rway_dyn[(rw_cnt)-1].comp_seqno);
pushquote(rway_dyn[(rw_cnt)-1].assembly_cat,20);
pushquote(rway_dyn[(rw_cnt)-1].assembly_nam,30);
pushquote(rway_dyn[(rw_cnt)-1].assembly_ver,12);
pushquote(rway_dyn[(rw_cnt)-1].spec_name,8);
fgl_nret = correct_rwcheckin(9);
rest_stack(fgl_svstk);
du68: _anyerr = 0;
 ld_flo(0, &rway_dyn[(rw_cnt)-1].width_g) ;

 ld_flo(1, &rway_dyn[(rw_cnt)-1].depth_g) ;

 ld_flo(2, &rway_dyn[(rw_cnt)-1].width_r) ;

 ld_flo(3, &rway_dyn[(rw_cnt)-1].depth_r) ;

 ld_long(4, &rway_dyn[(rw_cnt)-1].comp_seqno) ;

 ld_quote(5, rway_dyn[(rw_cnt)-1].assembly_cat, 21) ;

 ld_quote(6, rway_dyn[(rw_cnt)-1].assembly_nam, 31) ;

 ld_quote(7, rway_dyn[(rw_cnt)-1].assembly_ver, 13) ;

 ld_quote(8, rway_dyn[(rw_cnt)-1].spec_name, 9) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
pushlong(rw_cnt);
pushint(1);
_doadd();
poplong(&rw_cnt);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du69: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du70: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
ll64:;

/*
 * $  close rw_curs;
 */
 {
 _iqclose(&_SQ2);
 }
status = sqlca.sqlcode;
du71: _anyerr = 0;
pushlong(rw_cnt);
pushint(1);
_dosub();
poplong(&rw_cnt);
pushquote( "Updating " , 9);
pushlong(rw_cnt);
pushquote( "<<<<" , 4);
_dousing(0);
pushquote( " rows ..." , 9);
pushquote(rw_message,80);
_doconcat(3,0);

/*
 * $  message $rw_message;
 */
{

static struct sqlvar_struct _sqibind[] = {
	{100, sizeof(rw_message)}, 
	};
_sqibind[0].sqldata =(rw_message);
	_efmsg(1,  _sqibind,  (long)-1);
}
status = efcode;
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
pushquote( "VEND1" , 5);
popquote(rw_spec,9);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du72: _anyerr = 0;
pushquote( "VEND2" , 5);
popquote(rw_spec,9);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du73: _anyerr = 0;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
long fgl_fr1, fgl_fr2, fgl_fr3;
pushint(1);
poplong(&fgl_fr1);
i  = fgl_fr1;
while(1)

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du74: _anyerr = 0;
pushlong(rw_cnt);
poplong(&fgl_fr2);
fgl_fr3 = 1;
if (fgl_fr3 < 0 && i < fgl_fr2) break;
if (fgl_fr3 >= 0 && i > fgl_fr2) break;
pushquote(rway_dyn[(i)-1].spec_name,8);
pushquote(rw_spec,8);
_doopne();
pushquote(rway_dyn[(i)-1].spec_name,8);
isnull();
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

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;

/*
 * $  begin work;
 */
 {
 _iqbeginwork();
 }
status = sqlca.sqlcode;

/*
 * $  update rway_dynamic set spec_name = $rw_spec , width_g =
 */
 {
 static char *sqlcmdtxt[] =
  {
  " update rway_dynamic set spec_name = ? , width_g = ? , depth_g = ? ,",
   " width_r = ? , depth_r = ? where comp_seqno = ? and assembly_cat = ?",
   " and assembly_nam = ? and assembly_ver = ?",
  (char *) 0
  };
 static _SQSTMT _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(rway_dyn[(i)-1].width_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(rway_dyn[(i)-1].depth_g), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(rway_dyn[(i)-1].width_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {104, sizeof(rway_dyn[(i)-1].depth_r), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {103, sizeof(rway_dyn[(i)-1].comp_seqno), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (rw_spec);
 _sqibind[1].sqldata = (char *) &(rway_dyn[(i)-1].width_g);
 _sqibind[2].sqldata = (char *) &(rway_dyn[(i)-1].depth_g);
 _sqibind[3].sqldata = (char *) &(rway_dyn[(i)-1].width_r);
 _sqibind[4].sqldata = (char *) &(rway_dyn[(i)-1].depth_r);
 _sqibind[5].sqldata = (char *) &(rway_dyn[(i)-1].comp_seqno);
 _sqibind[6].sqldata = (rway_dyn[(i)-1].assembly_cat);
 _sqibind[7].sqldata = (rway_dyn[(i)-1].assembly_nam);
 _sqibind[8].sqldata = (rway_dyn[(i)-1].assembly_ver);
 _iqstmnt(&_SQ0, sqlcmdtxt, 9, _sqibind, (char *) 0);
 }
status = sqlca.sqlcode;

/*
 * $  commit work;
 */
 {
 _iqcommit();
 }
status = sqlca.sqlcode;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du75: _anyerr = 0;
i  += fgl_fr3;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du76: _anyerr = 0;
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
correct_rwcheckin (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
struct
  {
    float width_g;
    float depth_g;
    float width_r;
    float depth_r;
    long comp_seqno;
    char assembly_cat[21];
    char assembly_nam[31];
    char assembly_ver[13];
    char spec_name[9];
  }  rway_dyn;
double wg, dg, wr, dr;
du77: _anyerr = 0;
_popstack(9);
ld_flo(0, &rway_dyn.width_g);
ld_flo(1, &rway_dyn.depth_g);
ld_flo(2, &rway_dyn.width_r);
ld_flo(3, &rway_dyn.depth_r);
ld_long(4, &rway_dyn.comp_seqno);
ld_quote(5, rway_dyn.assembly_cat, 21);
ld_quote(6, rway_dyn.assembly_nam, 31);
ld_quote(7, rway_dyn.assembly_ver, 13);
ld_quote(8, rway_dyn.spec_name, 9);
pushflo(&rway_dyn.width_g);
pushflo(&rway_dyn.depth_g);
_doopge();
pushflo(&rway_dyn.width_g);
pushflo(&rway_dyn.width_r);
_doopge();
_doandop();
pushflo(&rway_dyn.width_g);
pushflo(&rway_dyn.depth_r);
_doopge();
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

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du78: _anyerr = 0;
pushflo(&rway_dyn.depth_g);
pushflo(&rway_dyn.width_g);
_doopge();
pushflo(&rway_dyn.depth_g);
pushflo(&rway_dyn.width_r);
_doopge();
_doandop();
pushflo(&rway_dyn.depth_g);
pushflo(&rway_dyn.depth_r);
_doopge();
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
pushflo(&rway_dyn.depth_g);
popdub(&wg);
pushflo(&rway_dyn.width_g);
popflo(&rway_dyn.depth_g);
pushdub(&wg);
popflo(&rway_dyn.width_g);
pushflo(&rway_dyn.depth_r);
popdub(&wr);
pushflo(&rway_dyn.width_r);
popflo(&rway_dyn.depth_r);
pushdub(&wr);
popflo(&rway_dyn.width_r);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du79: _anyerr = 0;
pushflo(&rway_dyn.width_r);
pushflo(&rway_dyn.width_g);
_doopge();
pushflo(&rway_dyn.width_r);
pushflo(&rway_dyn.depth_g);
_doopge();
_doandop();
pushflo(&rway_dyn.width_r);
pushflo(&rway_dyn.depth_r);
_doopge();
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
pushflo(&rway_dyn.width_g);
popdub(&wg);
pushflo(&rway_dyn.depth_g);
popdub(&dg);
pushflo(&rway_dyn.width_r);
popflo(&rway_dyn.width_g);
pushflo(&rway_dyn.depth_r);
popflo(&rway_dyn.depth_g);
pushdub(&wg);
popflo(&rway_dyn.width_r);
pushdub(&dg);
popflo(&rway_dyn.depth_r);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du80: _anyerr = 0;
pushflo(&rway_dyn.width_g);
popdub(&wg);
pushflo(&rway_dyn.depth_g);
popdub(&dg);
pushflo(&rway_dyn.depth_r);
popflo(&rway_dyn.width_g);
pushflo(&rway_dyn.width_r);
popflo(&rway_dyn.depth_g);
pushdub(&wg);
popflo(&rway_dyn.width_r);
pushdub(&dg);
popflo(&rway_dyn.depth_r);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du81: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du82: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du83: _anyerr = 0;
pushflo(&rway_dyn.width_g);
pushflo(&rway_dyn.width_r);
_doopeq();
pushflo(&rway_dyn.depth_g);
pushflo(&rway_dyn.depth_r);
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
pushstrdec(" 0.00 ");
popflo(&rway_dyn.width_r);
pushstrdec(" 0.00 ");
popflo(&rway_dyn.depth_r);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du84: _anyerr = 0;
pushflo(&rway_dyn.width_g);
pushflo(&rway_dyn.depth_g);
pushflo(&rway_dyn.width_r);
pushflo(&rway_dyn.depth_r);
pushlong(rway_dyn.comp_seqno);
pushquote(rway_dyn.assembly_cat,20);
pushquote(rway_dyn.assembly_nam,30);
pushquote(rway_dyn.assembly_ver,12);
pushquote(rway_dyn.spec_name,8);
doretalloc(9);
if (1) return(9);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
routeunits_convert (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
char parameter[21];
char family[13];
char partnum[33];
double value;
short code;
double factor;
double offset;
double roundoff;
char query_str[301];
struct
  {
    char units_set[21];
  }  p_usg;
du85: _anyerr = 0;
popshort(&code);
popdub(&value);
popquote(partnum,33);
popquote(family,13);
popquote(parameter,21);
pushquote( "SELECT UNIQUE units_set FROM " , 29);
pushquote(family,12);
_doclip();
pushquote( " WHERE p_partnum = \'" , 20);
pushquote(partnum,32);
_doclip();
pushquote( "\'" , 1);
pushquote(query_str,300);
_doconcat(5,0);

/*
 * $  prepare usg from $query_str;
 */
 {
 _iqprepare(&_SQ3, query_str);
 }
status = sqlca.sqlcode;

/*
 * $  declare crs cursor for usg;
 */
 {
 _iqddclcur(&_SQ3, "crs", 0);
 }
status = sqlca.sqlcode;

/*
 * $  open crs;
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
 * $  fetch crs into $p_usg.units_set;
 */
 {
 static struct sqlvar_struct _sqobind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqobind[0].sqldata = (p_usg.units_set);
 _iqnftch(&_SQ3, 1, _sqobind, (char *) 0, 1, (long) 0, 0, (char *) 0, (char *) 0, 0);
 }
status = sqlca.sqlcode;
du86: _anyerr = 0;
if (status == 100) break;
pushint(status);
pushint(0);
_dooplt();


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
goto ll87;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du88: _anyerr = 0;

/*
 * $  select vds_convert.cnvr_fctr , vds_convert.cnvr_offset ,
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select vds_convert . cnvr_fctr , vds_convert . cnvr_offset ,",
   " vds_convert . rndoff_fctr from vds_convert , vds_units where (",
   " vds_units . param_name like ? and vds_units . units_set = ? ) and (",
   " vds_convert . units_in = vds_units . units_code ) and ( vds_convert .",
   " units_out = ? )",
  (char *) 0
  };
 static _SQCURSOR _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {101, sizeof(code), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 static struct sqlvar_struct _sqobind[] = 
 {
 {105, sizeof(factor), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {105, sizeof(offset), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {105, sizeof(roundoff), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (parameter);
 _sqibind[1].sqldata = (p_usg.units_set);
 _sqibind[2].sqldata = (char *) &(code);
 _sqobind[0].sqldata = (char *) &(factor);
 _sqobind[1].sqldata = (char *) &(offset);
 _sqobind[2].sqldata = (char *) &(roundoff);
 _iqslct(&_SQ0, sqlcmdtxt, 3, _sqibind, 3, _sqobind, 0);
 }
status = sqlca.sqlcode;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
int fgl_svstk, fgl_nret;
fgl_svstk = mark_stack();
pushdub(&factor);
pushdub(&offset);
pushdub(&roundoff);
pushdub(&value);
fgl_nret = unit_convert(4);
rest_stack(fgl_svstk);
du89: _anyerr = 0;
 ld_dub(0, &value) ;

/*
 * SQL SEES BLOCK ENDING
 */
}
goto ll87;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du90: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}
ll87:;

/*
 * $  close crs;
 */
 {
 _iqclose(&_SQ3);
 }
status = sqlca.sqlcode;
du91: _anyerr = 0;
pushdub(&value);
doretalloc(1);
if (1) return(1);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
unit_convert (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
double factor;
double offset;
double roundoff;
double input_value;
double value_rnd;
double value_out;
long value_int;
du92: _anyerr = 0;
popdub(&input_value);
popdub(&roundoff);
popdub(&offset);
popdub(&factor);
pushdub(&factor);
isnull();
pushdub(&offset);
isnull();
_doorop();
pushdub(&roundoff);
isnull();
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
pushdub(&input_value);
popdub(&value_rnd);
pushdub(&value_rnd);
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
du93: _anyerr = 0;
pushdub(&input_value);
pushdub(&factor);
_domult();
pushdub(&offset);
_doadd();
popdub(&value_out);
pushdub(&roundoff);
pushstrdec(" 0.0 ");
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
pushdub(&value_out);
pushdub(&roundoff);
_dodiv();
popdub(&value_rnd);
pushdub(&value_rnd);
poplong(&value_int);
pushdub(&value_rnd);
pushlong(value_int);
_dosub();
pushstrdec(" 0.5 ");
_dooplt();


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
pushlong(value_int);
popdub(&value_rnd);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du94: _anyerr = 0;
pushlong(value_int);
pushstrdec(" 1.0 ");
_doadd();
popdub(&value_rnd);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du95: _anyerr = 0;
pushdub(&value_rnd);
pushdub(&roundoff);
_domult();
popdub(&value_rnd);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du96: _anyerr = 0;
pushdub(&value_rnd);
doretalloc(1);
if (1) return(1);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
ppunits_set (fgl_pcnt)
int fgl_pcnt;


/*
 * SQL SEES BLOCK BEGINNING
 */
{
char attr_name[81];
short spec_units;
short proj_code;
short spec_code;
short flag;
du97: _anyerr = 0;
popquote(attr_name,81);
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
 * $  select unique units_set into $spec_units from piping_spec ,
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select unique units_set from piping_spec , piping_dynamic where (",
   " piping_dynamic . assembly_cat like ? or piping_dynamic . assembly_cat",
   " is null ) and ( piping_dynamic . assembly_nam like ? or",
   " piping_dynamic . assembly_nam is null ) and ( piping_dynamic .",
   " assembly_ver like ? or piping_dynamic . assembly_ver is null ) and (",
   " piping_dynamic . system_name like ? or piping_dynamic . system_name",
   " is null ) and ( piping_dynamic . zone_number like ? or piping_dynamic",
   " . zone_number is null ) and ( piping_dynamic . apprv_stat like ? or",
   " piping_dynamic . apprv_stat is null ) and ( piping_dynamic .",
   " constr_stat like ? or piping_dynamic . constr_stat is null ) and",
   " piping_dynamic . spec_name = piping_spec . spec_name",
  (char *) 0
  };
 static _SQCURSOR _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 5, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 static struct sqlvar_struct _sqobind[] = 
 {
 {101, sizeof(spec_units), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_pp.assembly_cat);
 _sqibind[1].sqldata = (q_pp.assembly_nam);
 _sqibind[2].sqldata = (q_pp.assembly_ver);
 _sqibind[3].sqldata = (q_pp.system_name);
 _sqibind[4].sqldata = (q_pp.zone_number);
 _sqibind[5].sqldata = (q_pp.apprv_stat);
 _sqibind[6].sqldata = (q_pp.constr_stat);
 _sqobind[0].sqldata = (char *) &(spec_units);
 _iqslct(&_SQ0, sqlcmdtxt, 7, _sqibind, 1, _sqobind, 0);
 }
status = sqlca.sqlcode;

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du98: _anyerr = 0;

/*
 * $  select unique units_set into $spec_units from piping_spec ,
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select unique units_set from piping_spec , piping_dynamic ,",
   " piping_cit where piping_cit . dwg_cat like ? and piping_cit . dwg_nam",
   " like ? and piping_cit . dwg_rev like ? and piping_cit . assembly_cat",
   " = piping_dynamic . assembly_cat and piping_cit . assembly_nam =",
   " piping_dynamic . assembly_nam and piping_cit . assembly_rev =",
   " piping_dynamic . assembly_ver and piping_cit . comp_seqno =",
   " piping_dynamic . comp_seqno and ( piping_dynamic . system_name like ?",
   " or piping_dynamic . system_name is null ) and ( piping_dynamic .",
   " zone_number like ? or piping_dynamic . zone_number is null ) and (",
   " piping_dynamic . apprv_stat like ? or piping_dynamic . apprv_stat is",
   " null ) and ( piping_dynamic . constr_stat like ? or piping_dynamic .",
   " constr_stat is null )",
  (char *) 0
  };
 static _SQCURSOR _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 21, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 31, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 13, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 5, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 9, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 static struct sqlvar_struct _sqobind[] = 
 {
 {101, sizeof(spec_units), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (q_pp.assembly_cat);
 _sqibind[1].sqldata = (q_pp.assembly_nam);
 _sqibind[2].sqldata = (q_pp.assembly_ver);
 _sqibind[3].sqldata = (q_pp.system_name);
 _sqibind[4].sqldata = (q_pp.zone_number);
 _sqibind[5].sqldata = (q_pp.apprv_stat);
 _sqibind[6].sqldata = (q_pp.constr_stat);
 _sqobind[0].sqldata = (char *) &(spec_units);
 _iqslct(&_SQ0, sqlcmdtxt, 7, _sqibind, 1, _sqobind, 0);
 }
status = sqlca.sqlcode;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du99: _anyerr = 0;
pushshort(spec_units);
pushshort(p_vds.prj_units_set);
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
pushint(0);
popshort(&flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du100: _anyerr = 0;

/*
 * $  select unique proj.units_code , spec.units_code into $proj_code ,
 */
 {
 static char *sqlcmdtxt[] =
  {
  " select unique proj . units_code , spec . units_code from vds_units",
   " proj , vds_units spec where ( proj . param_name = ? and proj .",
   " units_set = ? ) and ( spec . param_name = ? and spec . units_set = ?",
   " )",
  (char *) 0
  };
 static _SQCURSOR _SQ0 = {0};
 static struct sqlvar_struct _sqibind[] = 
 {
 {100, 81, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {101, sizeof(p_vds.prj_units_set), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {100, 81, (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {101, sizeof(spec_units), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 static struct sqlvar_struct _sqobind[] = 
 {
 {101, sizeof(proj_code), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},
 {101, sizeof(spec_code), (char *) 0, (short *) 0, (char *) 0, (char *) 0, 0, 0, (char *) 0},

 };
 _sqibind[0].sqldata = (attr_name);
 _sqibind[1].sqldata = (char *) &(p_vds.prj_units_set);
 _sqibind[2].sqldata = (attr_name);
 _sqibind[3].sqldata = (char *) &(spec_units);
 _sqobind[0].sqldata = (char *) &(proj_code);
 _sqobind[1].sqldata = (char *) &(spec_code);
 _iqslct(&_SQ0, sqlcmdtxt, 4, _sqibind, 2, _sqobind, 0);
 }
status = sqlca.sqlcode;
pushshort(proj_code);
pushshort(spec_code);
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
pushint(0);
popshort(&flag);

/*
 * SQL SEES BLOCK ENDING
 */
}
else

/*
 * SQL SEES BLOCK BEGINNING
 */
{
du101: _anyerr = 0;
pushint(1);
popshort(&flag);

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du102: _anyerr = 0;

/*
 * SQL SEES BLOCK ENDING
 */
}

/*
 * SQL SEES BLOCK ENDING
 */
}
du103: _anyerr = 0;
pushshort(flag);
doretalloc(1);
if (1) return(1);
return(0);

/*
 * SQL SEES BLOCK ENDING
 */
}
