
/* $Id: VRHDBdef.h,v 1.4 2001/10/15 00:25:23 anand Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRHDBdef.h
 *
 * Description:
 *
 *  Include file for HVAC DB interface
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRHDBdef.h,v $
 *     Revision 1.4  2001/10/15 00:25:23  anand
 *     Rollback of fix JTS TR MP 5586 (will need to redeliver fix
 *     for Pload).
 *
 *     Revision 1.3  2001/09/18 19:10:38  anand
 *     JTS TR MP5586 - Caching of hvac_material_list table to
 *     include caching of cage, mino and descr fields as well.
 *
 *     Revision 1.2  2001/01/12 20:48:40  anand
 *     SP merge
 *
 * Revision 1.1  2000/05/11  21:56:48  pinnacle
 * Created: route/vrinclude/VRHDBdef.h by apazhani for Service Pack
 *
 * Revision 1.4  2000/03/02  16:46:48  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/04/30  20:51:32  pinnacle
 * Replaced: vrinclude/VRHDBdef.h for:  by apazhani for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/08/15  19:31:48  pinnacle
 * Created: vrinclude/VRHDBdef.h by hverstee for route
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/01/97          HV            New
 *      05/30/99          Alwin         Increased the cat_name size to 20.
 *      05/10/00          Alwin         Expanded the VRHDB_insulation structure
 *					accomodate acoustic insulation also.
 *					CR179901312
 *
 * -------------------------------------------------------------------*/

#ifndef VRHDBdef_include

#define VRHDBdef_include

#ifndef VRHDB_EXTERN_DEF
extern
#endif

    struct GRid     VRHDB_id;

/*                        PIPING DB ACCESS OBJECT                           */

#define VRHDB_CHAR_SCHED      10
#define VRHDB_CHAR_CODE        8
#define VRHDB_CHAR_CLASS      10
#define VRHDB_CHAR_PROJ       10
#define VRHDB_CHAR_STXT       10
#define VRHDB_CHAR_LTXT       80
#define VRHDB_CHAR_METH       10
#define VRHDB_CHAR_MATL       14
#define VRHDB_CHAR_FLUID      14

#define VRHDB_CHAR_CRIT      244
#define VRHDB_CHAR_FAM        20
#define VRHDB_CHAR_PFX        30

#define VRHDB_CHAR_PDM        40
#define VRHDB_CHAR_SERV       20
#define VRHDB_CHAR_DESC       22

#define VRHDB_UNDEF           -1

#define VRHDB_SELECT          "*"     /*    always select ALL    */
                            /*    modify specific move if layout changes  */

#define VRHDB_ANG_L45         1
#define VRHDB_ANG_45          2
#define VRHDB_ANG_L90         3
#define VRHDB_ANG_90          4
#define VRHDB_ANG_ALL         0

#define VRHDB_ERR_NOTABLE     2
#define VRHDB_ERR_SELECT      4
#define VRHDB_ERR_NOTFOUND    6

struct VRHDB_cdl
{
  IGRshort    ncode;
  IGRchar     stxt[VRHDB_CHAR_STXT];
  IGRchar     ltxt[VRHDB_CHAR_LTXT];
};

struct VRHDB_ct_key
{
  IGRchar    comp_code[VRHDB_CHAR_CODE];
  IGRchar    sh_code[VRHDB_CHAR_CODE];
};

struct VRHDB_ct_data
{
  IGRshort   ct_topo;
  IGRshort   ct_cat;
  IGRshort   ct_rptc;
  IGRshort   ct_subc;
  IGRshort   ct_nmcp;
  IGRshort   ct_2_cp;
  IGRchar    descr[VRHDB_CHAR_DESC];
};

struct VRHDB_ct
{
  struct VRHDB_ct_key    key;
  struct VRHDB_ct_data   data;
};

struct VRHDB_project
{
  IGRshort     prj_no;
  IGRchar      opt_set_name[VRHDB_CHAR_PROJ];
};

struct VRHDB_spec_key
{
  IGRchar      hvac_class[VRHDB_CHAR_CLASS];
  IGRshort     class_no;
};

struct VRHDB_spec_data
{
  IGRchar      d_serv[VRHDB_CHAR_SERV];
  IGRchar      d_presc[VRHDB_CHAR_CODE];
  IGRchar      dflt_duct[VRHDB_CHAR_CODE];

  IGRshort     tbl_chdir;
  IGRshort     tbl_branch;

  IGRchar      dflt_con[VRHDB_CHAR_CODE];
  IGRchar      dflt_ecc[VRHDB_CHAR_CODE];

  IGRshort     tbl_trans;

  IGRchar      dflt_tws[VRHDB_CHAR_CODE];

  IGRdouble    d_rad;
  IGRdouble    d_ang;
  IGRdouble    d_gap;

  IGRchar      dmeth[VRHDB_CHAR_METH];

  IGRdouble    d_fmax;
  IGRdouble    d_vmax;
  IGRdouble    d_vmin;

  IGRchar      d_matl[VRHDB_CHAR_MATL];

  IGRdouble    d_thk;
  IGRdouble    d_dens;
  IGRdouble    d_wmult;
  IGRdouble    d_rough;

  IGRchar      fl_name[VRHDB_CHAR_FLUID];

  IGRdouble    fl_temp;
  IGRdouble    fl_dens;
  IGRdouble    fl_visc;

  IGRdouble    d_minw;
  IGRdouble    d_maxw;
  IGRdouble    d_mind;
  IGRdouble    d_maxd;

  IGRdouble    duct_inc;

  IGRshort     stdduct;
  IGRshort     altshape;

  IGRdouble    m_vterm;
  IGRdouble    fan_vout;

  IGRshort     units_set;
};

struct VRHDB_spec
{
  struct VRHDB_spec_key     key;
  struct VRHDB_spec_data    data;
};

struct VRHDB_comps_key
{
  IGRshort     shapecode;
  IGRchar      comp_code[VRHDB_CHAR_CODE];
};

struct VRHDB_comps_data
{
  IGRchar      famnam[VRHDB_CHAR_FAM];
  IGRchar      part_pfx[VRHDB_CHAR_PFX];

  IGRshort     famcode;
  IGRshort     partcode;
  IGRchar      sh_code[VRHDB_CHAR_CODE];

  IGRchar      pdm_flag;

  /*** Changing this dimension from 8 -> 20. B'cas the database allowable size
  is 12, and the catalog name could be more than 8 chars.
  IGRchar      cat_name[VRHDB_CHAR_CODE];
  modified this by Alwin for TR17990551 ********/

  IGRchar      cat_name[VRHDB_CHAR_FAM];
  IGRchar      sel_crit[VRHDB_CHAR_CRIT];
};

struct VRHDB_comps
{
  struct VRHDB_comps_key     key;
  struct VRHDB_comps_data    data;
};

/*        These selection tables should be condensed as follows ....  */

struct VRHDB_transn
{
  IGRshort    shapecode;
  IGRshort    transtype;
  IGRdouble   dwlow;
  IGRdouble   dwhig;
  IGRdouble   ddlow;
  IGRdouble   ddhig;
  IGRchar     comp_code[VRHDB_CHAR_CODE];
};

struct VRHDB_bendn
{
  IGRshort    ang_code;
  IGRdouble   dwlow;
  IGRdouble   dwhig;
  IGRdouble   ddlow;
  IGRdouble   ddhig;
  IGRshort    ctype;
  IGRchar     comp_code[VRHDB_CHAR_CODE];
};

struct VRHDB_branchn
{
  IGRshort    ang_code;
  IGRdouble   dwlow1;
  IGRdouble   dwhig1;
  IGRdouble   ddlow1;
  IGRdouble   ddhig1;
  IGRdouble   dwlow2;
  IGRdouble   dwhig2;
  IGRdouble   ddlow2;
  IGRdouble   ddhig2;
  IGRshort    ctype;
  IGRchar     comp_code[VRHDB_CHAR_CODE];
};

/*  ..........   but are currently defined as follows               */

struct VRHDB_bendo
{
  IGRdouble   ang_low;
  IGRdouble   ang_high;
  IGRshort    ctype;
  IGRchar     comp_code[VRHDB_CHAR_CODE];
};

struct VRHDB_brancho
{
  IGRdouble   ang_low;
  IGRdouble   ang_high;
  IGRchar     comp_code[VRHDB_CHAR_CODE];
};

struct VRHDB_transo
{
  IGRshort    shapecode;
  IGRshort    transtype;
  IGRchar     comp_code[VRHDB_CHAR_CODE];
};

struct VRHDB_trans
{
  union 
  {
    struct VRHDB_transo     old;
    struct VRHDB_transn     new;
  } rec;
};

struct VRHDB_branch
{
  union
  {
    struct VRHDB_brancho     old;
    struct VRHDB_branchn     new;
  } rec;
};

struct VRHDB_bend
{
  union 
  {
    struct VRHDB_bendo     old;
    struct VRHDB_bendn     new;
  } rec;
};

/* Added by Alwin for CR179900696 */
struct VRHDB_insulation
{
	IGRchar		insul_type[1];//to distinguish between acoustic & thermal insul.
	IGRchar		insul_class[VRHDB_CHAR_PFX]; /* DB limit is 24 */
	IGRdouble	dInsulThick_met;
	IGRdouble	dInsulThick_imp;
};

struct VRHDB_mat_key
{
	IGRchar		material_class[VRHDB_CHAR_PFX]; /* DB limit is 24 */
};

struct VRHDB_mat_data
{
	IGRdouble	dDuctThick_met;
	IGRdouble	dDuctThick_imp;
	IGRchar		duct_matl[24];
};

struct VRHDB_material
{
  struct VRHDB_mat_key     key;
  struct VRHDB_mat_data    data;
};

#endif
