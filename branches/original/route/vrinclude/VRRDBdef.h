
/* $Id: VRRDBdef.h,v 1.2 2001/01/12 20:48:49 anand Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRRDBdef.h
 *
 * Description:
 *
 *  Include file for RWAY DB interface
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRRDBdef.h,v $
 *     Revision 1.2  2001/01/12 20:48:49  anand
 *     SP merge
 *
 * Revision 1.1  2000/07/10  19:03:00  pinnacle
 * Created: route/vrinclude/VRRDBdef.h by apazhani for Service Pack
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/08/15  19:30:44  pinnacle
 * Created: vrinclude/VRRDBdef.h by hverstee for route
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/01/97          HV            New
 *      07/10/2000        Alwin         Added struct VRRDB_rwaynozz
 *
 * -------------------------------------------------------------------*/

#ifndef VRRDBdef_include

#define VRRDBdef_include

#ifndef VRRDB_EXTERN_DEF
extern
#endif

    struct GRid     VRRDB_id;

/*                        RWAY DB ACCESS OBJECT                           */

#define VRRDB_CHAR_SCHED      10
#define VRRDB_CHAR_CODE        8
#define VRRDB_CHAR_CLASS      10
#define VRRDB_CHAR_PROJ       10
#define VRRDB_CHAR_STXT       10
#define VRRDB_CHAR_LTXT       80
#define VRRDB_CHAR_METH       10
#define VRRDB_CHAR_MATL       14
#define VRRDB_CHAR_FLUID      14

#define VRRDB_CHAR_CRIT      244
#define VRRDB_CHAR_FAM        20
#define VRRDB_CHAR_PFX        30

#define VRRDB_CHAR_PDM        40
#define VRRDB_CHAR_SERV       20
#define VRRDB_CHAR_DESC       22

#define VRRDB_UNDEF           -1

#define VRRDB_SELECT          "*"     /*    always select ALL    */
                            /*    modify specific move if layout changes  */

#define VRRDB_ANG_L45         1
#define VRRDB_ANG_45          2
#define VRRDB_ANG_L90         3
#define VRRDB_ANG_90          4
#define VRRDB_ANG_ALL         0

#define VRRDB_ERR_NOTABLE     2
#define VRRDB_ERR_SELECT      4
#define VRRDB_ERR_NOTFOUND    6

struct VRRDB_cdl
{
  IGRshort    ncode;
  IGRchar     stxt[VRRDB_CHAR_STXT];
  IGRchar     ltxt[VRRDB_CHAR_LTXT];
};

struct VRRDB_ct_key
{
  IGRchar    comp_code[VRRDB_CHAR_CODE];
  IGRchar    sh_code[VRRDB_CHAR_CODE];
  IGRshort   comp_type;
};

struct VRRDB_ct_data
{
  IGRshort   ct_topo;
  IGRshort   ct_cat;
  IGRshort   ct_rptc;
  IGRshort   ct_nmcp;
  IGRshort   ct_2_cp;
  IGRchar    descr[VRRDB_CHAR_DESC];
};

struct VRRDB_ct
{
  struct VRRDB_ct_key    key;
  struct VRRDB_ct_data   data;
};

struct VRRDB_project
{
  IGRshort     prj_no;
  IGRchar      opt_set_name[VRRDB_CHAR_PROJ];
};

struct VRRDB_spec_key
{
  IGRchar      vendor_code[VRRDB_CHAR_CLASS];
  IGRshort     vendor_no;
};

struct VRRDB_spec_data
{
  IGRchar      d_desc[VRRDB_CHAR_SERV];
  IGRchar      dflt_run[VRRDB_CHAR_CODE];

  IGRshort     tbl_chdir;
  IGRshort     tbl_branch;

  IGRchar      dflt_con[VRRDB_CHAR_CODE];
  IGRchar      dflt_ecc[VRRDB_CHAR_CODE];

  IGRchar      d_matl[VRRDB_CHAR_MATL];

  IGRshort     units_set;
};

struct VRRDB_spec
{
  struct VRRDB_spec_key     key;
  struct VRRDB_spec_data    data;
};

struct VRRDB_comps_key
{
  IGRchar      comp_code[VRRDB_CHAR_CODE];
  IGRshort     rType;

};

struct VRRDB_comps_data
{
  IGRdouble    dWid1;
  IGRdouble    dDep1;
  IGRdouble    dWid2;
  IGRdouble    dDep2;

  IGRchar      famnam[VRRDB_CHAR_FAM];
  IGRchar      part_num[VRRDB_CHAR_PFX];

  IGRshort     famcode;
  IGRshort     partcode;
  IGRchar      sh_code[VRRDB_CHAR_CODE];

  IGRchar      commodity[20];

  IGRdouble    unit_wt;

  IGRchar      pdm_flag;
  IGRchar      cat_name[VRRDB_CHAR_CODE];
  IGRchar      sel_crit[VRRDB_CHAR_CRIT];

  IGRdouble    par_1;
  IGRdouble    par_2;
  IGRdouble    par_3;
};

struct VRRDB_comps
{
  struct VRRDB_comps_key     key;
  struct VRRDB_comps_data    data;
};

/*        These selection tables should be condensed as follows ....  */

struct VRRDB_transn
{
  IGRshort    shapecode;
  IGRshort    transtype;
  IGRdouble   dwlow;
  IGRdouble   dwhig;
  IGRdouble   ddlow;
  IGRdouble   ddhig;
  IGRchar     comp_code[VRRDB_CHAR_CODE];
};

struct VRRDB_bendn
{
  IGRshort    ang_code;
  IGRdouble   dwlow;
  IGRdouble   dwhig;
  IGRdouble   ddlow;
  IGRdouble   ddhig;
  IGRshort    ctype;
  IGRchar     comp_code[VRRDB_CHAR_CODE];
};

struct VRRDB_branchn
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
  IGRchar     comp_code[VRRDB_CHAR_CODE];
};

/*  ..........   but are currently defined as follows               */

struct VRRDB_bendo
{
  IGRdouble   ang_low;
  IGRdouble   ang_high;
  IGRshort    ctype;
  IGRchar     comp_code[VRRDB_CHAR_CODE];
};

struct VRRDB_brancho
{
  IGRdouble   ang_low;
  IGRdouble   ang_high;
  IGRshort    ctype;
  IGRchar     comp_code[VRRDB_CHAR_CODE];
};

struct VRRDB_transo
{
  IGRshort    shapecode;
  IGRshort    transtype;
  IGRchar     comp_code[VRRDB_CHAR_CODE];
};

struct VRRDB_trans
{
  union 
  {
    struct VRRDB_transo     old;
    struct VRRDB_transn     new;
  } rec;
};

struct VRRDB_branch
{
  union
  {
    struct VRRDB_brancho     old;
    struct VRRDB_branchn     new;
  } rec;
};

struct VRRDB_bend
{
  union 
  {
    struct VRRDB_bendo     old;
    struct VRRDB_bendn     new;
  } rec;
};


struct VRRDB_rwaynozz
{
  IGRshort	vendor_no;
  IGRshort	shape;
  IGRdouble    	width;
  IGRdouble    	depth;
  IGRshort	units_set;
  IGRdouble    	d1;
  IGRdouble    	t1;
  IGRdouble    	b1;
  IGRdouble    	f1;
  IGRchar	macro_name[20];
};

#endif

