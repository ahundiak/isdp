
/* $Id: VRPDBdef.h,v 1.1.1.1 2001/01/04 21:12:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRPDBdef.h
 *
 * Description:
 *
 *  Include file for piping DB interface
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRPDBdef.h,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:53  cvs
 *     Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1998/04/06  18:07:50  pinnacle
 * Replaced: vrinclude/VRPDBdef.h for:  by lawaddel for route
 *
 * Revision 1.1  1997/08/15  19:32:04  pinnacle
 * Created: vrinclude/VRPDBdef.h by hverstee for route
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/01/97          HV            New
 *
 * -------------------------------------------------------------------*/

#ifndef VRPDBdef_include

#define VRPDBdef_include

#ifndef VRPDB_EXTERN_DEF
extern
#endif

    struct GRid     VRPDB_id;

/*                        PIPING DB ACCESS OBJECT                           */

#define VRPDB_CHAR_SCHED      10
#define VRPDB_CHAR_CODE        8
#define VRPDB_CHAR_SPEC       10
#define VRPDB_CHAR_PROJ       10
#define VRPDB_CHAR_STXT       80     /**** law 04/02/98 ******/
#define VRPDB_CHAR_COMMOD     24
#define VRPDB_CHAR_PDM        40
#define VRPDB_CHAR_SERV       80
#define VRPDB_CHAR_LTXT       80
#define VRPDB_CHAR_FAM        20
#define VRPDB_CHAR_DESC       22
#define VRPDB_CHAR_PFX        30

#define VRPDB_UNDEF           -1

#define VRPDB_SELECT          "*"     /*    always select ALL    */
                            /*    modify specific move if layout changes  */

#define VRPDB_ANG_L45         1
#define VRPDB_ANG_45          2
#define VRPDB_ANG_L90         3
#define VRPDB_ANG_90          4
#define VRPDB_ANG_ALL         0

#define VRPDB_ERR_NOTABLE     2
#define VRPDB_ERR_SELECT      4
#define VRPDB_ERR_NOTFOUND    6

struct VRPDB_cdl
{
  IGRshort    ncode;
  IGRchar     stxt[VRPDB_CHAR_STXT];
  IGRchar     ltxt[VRPDB_CHAR_LTXT];
};

struct VRPDB_sch_thk
{
  IGRshort   end_std;
  IGRshort   gentyp;
  IGRchar    sched[VRPDB_CHAR_SCHED];
  IGRdouble  dia;
  IGRdouble  thick;
  IGRshort   thk_units;
};

struct VRPDB_ct_key
{
  IGRchar    comp_code[VRPDB_CHAR_CODE];
  IGRchar    sh_code[VRPDB_CHAR_CODE];
};

struct VRPDB_ct_data
{
  IGRshort   ct_topo;
  IGRshort   ct_cat;
  IGRshort   ct_rptc;
  IGRshort   ct_nmcp;
  IGRshort   ct_2_cp;
  IGRchar    descr[VRPDB_CHAR_DESC];
};

struct VRPDB_ct
{
  struct VRPDB_ct_key    key;
  struct VRPDB_ct_data   data;
};

struct VRPDB_commod
{
  IGRchar      si_comm_code[VRPDB_CHAR_COMMOD];
  IGRdouble    dia1;
  IGRdouble    dia2;
  IGRchar      sch_t_g[VRPDB_CHAR_SCHED];
  IGRchar      sch_t_r[VRPDB_CHAR_SCHED];
  IGRchar      sd_comm_code[VRPDB_CHAR_COMMOD];
  IGRchar      pdm_part[VRPDB_CHAR_PDM];
};

struct VRPDB_project
{
  IGRshort     prj_no;
  IGRchar      prj_name[VRPDB_CHAR_PROJ];
  IGRshort     npd_tbl;
  IGRshort     npd_eqflag;
  IGRshort     prj_units;
};

struct VRPDB_npd
{
  IGRdouble    npd;
  IGRdouble    npd_eq;
};

struct VRPDB_spec_key
{
  IGRchar      spec_name[VRPDB_CHAR_SPEC];
  IGRshort     spec_no;
};

struct VRPDB_spec_data
{
  IGRchar      serv[VRPDB_CHAR_SERV];
  IGRchar      d_mtl[VRPDB_CHAR_COMMOD];
  IGRchar      d_fld[VRPDB_CHAR_CODE];
  IGRchar      dflt_pipe[VRPDB_CHAR_CODE];

  IGRshort     tbl_chdir;
  IGRshort     tbl_branch;

  IGRchar      dflt_con[VRPDB_CHAR_CODE];
  IGRchar      dflt_ecc[VRPDB_CHAR_CODE];

  IGRshort     tbl_adapt;
  IGRshort     tbl_compat;
  IGRshort     tbl_minlen;
  IGRshort     tbl_gskgap;
  IGRshort     tbl_npd;
  IGRshort     tbl_tplim;
  IGRshort     tbl_mtl;
  IGRshort     tbl_tap;
  IGRshort     eqn_wall;

  IGRchar      vds_assm[VRPDB_CHAR_CODE];

  IGRdouble    corr_allow;
  IGRdouble    gask_sep;

  IGRshort     note_a;
  IGRshort     note_b;
  IGRshort     units;
};

struct VRPDB_spec
{
  struct VRPDB_spec_key     key;
  struct VRPDB_spec_data    data;
};

struct VRPDB_comps_key
{
  IGRshort     option;
  IGRchar      comp_code[VRPDB_CHAR_CODE];
};

struct VRPDB_ranges
{
  IGRdouble    dia1_h;
  IGRdouble    dia1_l;
  IGRdouble    dia2_h;
  IGRdouble    dia2_l;
};

struct VRPDB_comps_data
{
  IGRchar      famnam[VRPDB_CHAR_FAM];
  IGRchar      part_pfx[VRPDB_CHAR_PFX];

  IGRshort     famcode;
  IGRshort     partcode;
  IGRshort     wtdata;

  IGRshort     end_tbl_g;
  IGRshort     end_idx_g;
  IGRshort     end_tbl_r;
  IGRshort     end_idx_r;

  IGRshort     subfam;
  IGRshort     subpart;

  IGRchar      sh_code[VRPDB_CHAR_CODE];

  IGRdouble    maxtemp;

  IGRshort     prep_g;
  IGRshort     prep_r;

  IGRchar      rating_g[VRPDB_CHAR_SCHED];
  IGRchar      rating_r[VRPDB_CHAR_SCHED];
  IGRchar      sch_thk_g[VRPDB_CHAR_SCHED];
  IGRchar      sch_thk_r[VRPDB_CHAR_SCHED];

  IGRshort     geom_std;
  IGRshort     end_std_g;
  IGRshort     end_std_r;

  IGRdouble    modifier;
  IGRshort     material;

  IGRchar      commodity[VRPDB_CHAR_COMMOD];

  IGRshort     fabcat;
  IGRshort     wt_fctr;
  IGRshort     note_a;
  IGRshort     note_b;
};

struct VRPDB_comps
{
  struct VRPDB_comps_key     key;
  struct VRPDB_ranges        dia;
  struct VRPDB_comps_data    data;
};

/*        These selection tables should be condensed as follows ....  */

struct VRPDB_bendn
{
  IGRshort    ang_code;
  IGRdouble   npd1;
  IGRdouble   npd2;
  IGRshort    type;
  IGRchar     comp_code[VRPDB_CHAR_CODE];
};

struct VRPDB_branchn
{
  IGRshort                   ang_code;
  struct VRPDB_ranges        dia;
  IGRshort                   type;
  IGRchar                    comp_code[VRPDB_CHAR_CODE];
};

/*  ..........   but are currently defined as follows               */

struct VRPDB_bendo
{
  IGRdouble   ang_low;
  IGRdouble   ang_high;
  IGRshort    type;
  IGRchar     comp_code[VRPDB_CHAR_CODE];
};

struct VRPDB_brancho
{
  IGRdouble   npd_high;
  IGRdouble   npd_low;
  IGRdouble   ang_low;
  IGRdouble   ang_high;
  IGRshort    type;
  IGRchar     comp_code[VRPDB_CHAR_CODE];
};


struct VRPDB_branch
{
  union
  {
    struct VRPDB_brancho     old;
    struct VRPDB_branchn     new;
  } rec;
};

struct VRPDB_bend
{
  union 
  {
    struct VRPDB_bendo     old;
    struct VRPDB_bendn     new;
  } rec;
};


#endif

