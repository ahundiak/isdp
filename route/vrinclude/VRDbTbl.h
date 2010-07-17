/* $Id: VRDbTbl.h,v 1.2 2001/01/12 20:48:36 anand Exp $ */
/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRDbTbl.h
 *
 * Description:
 *
 *  This include file defines the database table names used by the interface to
 *  the database
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRDbTbl.h,v $
 *     Revision 1.2  2001/01/12 20:48:36  anand
 *     SP merge
 *
 * Revision 1.1  2000/07/10  19:02:52  pinnacle
 * Created: route/vrinclude/VRDbTbl.h by apazhani for Service Pack
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      07/10/00        Alwin         Added rway_nozzle table
 *
 * -------------------------------------------------------------------*/

#ifndef vrdbtbl_include

#define vrdbtbl_include

/*    SWITCHING OVER TO AUTOMATICALLY CACHING DB ACCESS     */
/*    (temporary to keep both versions)                     */

#define    VRPDB_ACTIVE
#define    VRHDB_ACTIVE
#define    VRRDB_ACTIVE

/*        VDS                 */
/*----------------------------*/

#define     VRDB_VDSPROJ_TBL                "vds_project"
#define     VRDB_VDSUNITS_TBL               "vds_units"
#define     VRDB_VDSCONVERT_TBL             "vds_convert"
#define     VRDB_VDSCODELIST_TBL            "vds_codelist"
#define     VRDB_VDSDYNPARAMS_TBL           "vds_dyn_params"
#define     VRDB_VDSCOLUMNS_TBL             "vds_columns"

/*	PIPING/HVAC/RWAY	*/

#define     VRDB_NOZMACLIST_TBL		    "nozz_macro_list"

/*        PIPING              */
/*----------------------------*/

#define     VRDB_PIPPROJ_TBL                "piping_project"
#define     VRDB_PIPSPEC_TBL                "piping_spec"
#define     VRDB_PIPCOMPS_TBL               "piping_comps"
#define     VRDB_PIPCOMPTYP_TBL             "piping_comp_type"
#define     VRDB_PIPCOMMCOD_TBL             "piping_commod_code"
#define     VRDB_PIPSPECIAL_TBL             "piping_specialties"
#define     VRDB_PIPCODSEL_TBL              "piping_cod_select"
#define     VRDB_PIPBRSEL_TBL               "piping_br_select"
#define     VRDB_PIPADPTSEL_TBL             "piping_adpt_select"
#define     VRDB_PIPCODELIST_TBL            "piping_codelist"
#define     VRDB_PIPINSUL_TBL               "piping_insulation"
#define     VRDB_PIPMATDESCR_TBL            "piping_matl_descr"
#define     VRDB_PIPLABDESCR_TBL            "piping_label_descr"
#define     VRDB_PIPSHDESCR_TBL             "piping_short_descr"
#define     VRDB_PIPSCHTHK_TBL              "piping_sch_thk"
#define     VRDB_PIPNPDALL_TBL              "piping_npd_allowed"
#define     VRDB_PIPNOZZLE                  "nozzle"
#define     VRDB_PIPNOZZLE1                 "nozzle1"      /* cr179528329 */
#define     VRDB_PIPDYNAMIC_TBL             "piping_dynamic"
#define     VRDB_PIPCIT_TBL                 "piping_cit"
#define     VRDB_PIPIMPL_TBL                "piping_implied"
#define     VRDB_PIPSUPDYN_TBL              "piping_sup_dynamic"
#define     VRDB_PIPSUPCIT_TBL              "piping_sup_cit"
#define     VRDB_EQUIPDYN_TBL               "equip_dynamic"
#define     VRDB_EQUIPCIT_TBL               "equip_cit"
#define     VRDB_PIPNOZDYN_TBL              "piping_noz_dynamic"
#define     VRDB_PIPNOZCIT_TBL              "piping_noz_cit"

/*     new tables to faze in for bend/branch selection   */

#define     VRDB_PIPBENDSEL_TBL             "piping_sel_bend"
#define     VRDB_PIPBRANSEL_TBL             "piping_sel_branch"


/*        HVAC                */
/*----------------------------*/


#define     VRDB_HVPROJ_TBL                 "hvac_project"
#define     VRDB_HVSPEC_TBL                 "hvac_spec"
#define     VRDB_HVCOMPS_TBL                "hvac_comps"
#define     VRDB_HVDEVICE_TBL               "hvac_device"
#define     VRDB_HVCOMPTYP_TBL              "hvac_comp_type"
#define     VRDB_HVCOMMCOD_TBL              "hvac_commod_code"
#define     VRDB_HVCODSEL_TBL               "hvac_cod_select"
#define     VRDB_HVBRSEL_TBL                "hvac_br_select"
#define     VRDB_HVTRANSEL_TBL              "hvac_trans_select"
#define     VRDB_HVSTDDUCT_TBL              "hvac_std_duct"
#define     VRDB_HVFITDESCR_TBL             "hvac_fitting_descr"
#define     VRDB_HVDEVICEDESCR_TBL          "hvac_device_descr"
#define     VRDB_HVLABDESCR_TBL             "hvac_label_descr"
#define     VRDB_HVCODELIST_TBL             "hvac_codelist"
#define     VRDB_HVINSUL_TBL                "hvac_insulation"
#define     VRDB_HVDYNAMIC_TBL              "hvac_dynamic"
#define     VRDB_HVCIT_TBL                  "hvac_cit"

/* added for CR179900696. Alwin */
#define     VRDB_HVMATERIAL_TBL             "hvac_material_list"
#define     VRDB_HVINSULATION_TBL           "hvac_insul_list"

/*     new tables to faze in for bend/branch/trans selection   */

#define     VRDB_HVBENDSEL_TBL              "hvac_sel_bend"
#define     VRDB_HVBRANSEL_TBL              "hvac_sel_branch"
#define     VRDB_HVTRA1SEL_TBL              "hvac_sel_trans"


/*        RWAY                */
/*----------------------------*/


#define     VRDB_RWPROJ_TBL                 "rway_project"
#define     VRDB_RWSPEC_TBL                 "rway_spec"
#define     VRDB_RWCOMPS_TBL                "rway_comps"
#define     VRDB_RWCOMPTYP_TBL              "rway_comp_type"
#define     VRDB_RWCODSEL_TBL               "rway_cod_select"
#define     VRDB_RWBRSEL_TBL                "rway_br_select"
#define     VRDB_RWFITDESCR_TBL             "rway_fitting_descr"
#define     VRDB_RWLABDESCR_TBL             "rway_label_descr"
#define     VRDB_RWCODELIST_TBL             "rway_codelist"
#define     VRDB_RWDYNAMIC_TBL              "rway_dynamic"
#define     VRDB_RWCIT_TBL                  "rway_cit"
#define     VRDB_RWNOZZLE_TBL               "rway_nozzle"

/*     new tables to faze in for bend/branch/trans selection   */

#define     VRDB_RWBENDSEL_TBL              "rway_sel_bend"
#define     VRDB_RWBRANSEL_TBL              "rway_sel_branch"
#define     VRDB_RWTRA1SEL_TBL              "rway_sel_trans"


/*        STRUCT              */
/*----------------------------*/


#define     VRDB_STPROJ_TBL                 "struct_project"
#define     VRDB_STGRADE_TBL                "struct_grade"
#define     VRDB_STCODELIST_TBL             "struct_codelist"
#define     VRDB_STBMDYNAMIC_TBL            "struct_bm_dynamic"
#define     VRDB_STBMCIT_TBL                "struct_bm_cit"
#define     VRDB_STPLDYNAMIC_TBL            "struct_pl_dynamic"
#define     VRDB_STPLCIT_TBL                "struct_pl_cit"


/*  RIS DICTIONARY TABLES    */
/*---------------------------*/

#define    VRDB_RISCOLUMNS                  "ris5columns"
#define    VRDB_RISTABLES                   "ris5tables"

/*  PID TABLE    */
/*---------------*/

#define    VRDB_PIDSYM_TBL                  "pid_sym_code"

/*************************************************************************/
/*     THIS OLD CABLING REFERENCE SHOULD DISAPPEAR........               */
/*     TEST FOR COMPILER ERRORS FIRST TO LOCATE SPURIOUS REFERENCES      */
/*************************************************************************/

#define    KEEP_YE_OLDE_CABLING
#ifdef     KEEP_YE_OLDE_CABLING

/*  ELECTRICAL TABLES   */
/*----------------------*/

#define    VRDB_ELECAB_TBL                  "elec_cable"
#define    VRDB_ELECABCONST_TBL             "elec_cable_const"
#define    VRDB_ELECOND_TBL                 "elec_conductor"

#define    VRDB_ELTERM_TBL                  "elec_term"
#define    VRDB_ELTLAYOUT_TBL               "elec_term_layout"
#define    VRDB_ELECPIN_TBL                 "elec_pin"

#define    VRDB_ELMXLAY_TBL                "elec_mxlayout"
#define    VRDB_ELMXGRLAY_TBL              "elec_mxgrlay"
#define    VRDB_ELMODLAY_TBL               "elec_mxmodlay"
#define    VRDB_ELMXSPEC_TBL               "elec_mxspec"
#define    VRDB_ELMXGRSP_TBL               "elec_mxgrsp"

/*  FIBEROPTIC TABLES   */
/*----------------------*/

#define    VRDB_FOCAB_TBL                  "foptic_cable"
#define    VRDB_FOCONST_TBL                "foptic_const"
#define    VRDB_FOCOND_TBL                 "foptic_conductor"

#define    VRDB_FOTERM_TBL                 "foptic_term"
#define    VRDB_FOPIN_TBL                  "foptic_pin"
#define    VRDB_FOTLAY_TBL                 "foptic_term_layout"

#define    VRDB_FOMXLAY_TBL                "foptic_mxlayout"
#define    VRDB_FOMXGRLAY_TBL              "foptic_mxgrlay"
#define    VRDB_FOMODLAY_TBL               "foptic_mxmodlay"
#define    VRDB_FOMXSPEC_TBL               "foptic_mxspec"
#define    VRDB_FOMXGRSP_TBL               "foptic_mxgrsp"
#define    VRDB_FOCON_SEL_TBL              "foptic_consel"
#define    VRDB_FOCONN_TBL                 "foptic_connect"

#define    VRDB_CONDUIT_TBL                "conduit_cable"

/*    electrical/fiberoptic dynamic connectivity tables    */

#define    VRDB_EL_DYN_SCHCONN             "sch_elconn_dynamic"
#define    VRDB_EL_DYN_CONNECT             "elconnect_dynamic"
#define    VRDB_FO_DYN_SCHCONN             "sch_foconn_dynamic"
#define    VRDB_FO_DYN_CONNECT             "foconnect_dynamic"

/**************************************************************************/
/*  NOTE:   for electrical and fiberoptic there exists a simplified
            interface keyed by table numbers defined herein          */

/*  ELECTRICAL TABLE NUMBERS   */
/*-----------------------------*/

#define    VRDB_ELECAB_TBNO              1
#define    VRDB_ELECABCONST_TBNO         2
#define    VRDB_ELECOND_TBNO             3

#define    VRDB_ELTERM_TBNO              4
#define    VRDB_ELTLAYOUT_TBNO           5
#define    VRDB_ELECPIN_TBNO             6

#define    VRDB_ELMXLAY_TBNO             7
#define    VRDB_ELMXGRLAY_TBNO           8
#define    VRDB_ELMODLAY_TBNO            9
#define    VRDB_ELMXSPEC_TBNO           10
#define    VRDB_ELMXGRSP_TBNO           11

/*  FIBEROPTIC TABLE NUMBERS   */
/*-----------------------------*/

#define    VRDB_FOCAB_TBNO              12
#define    VRDB_FOCONST_TBNO            13
#define    VRDB_FOCOND_TBNO             14

#define    VRDB_FOTERM_TBNO             15
#define    VRDB_FOPIN_TBNO              16
#define    VRDB_FOTLAY_TBNO             17

#define    VRDB_FOMXLAY_TBNO            18
#define    VRDB_FOMXGRLAY_TBNO          19
#define    VRDB_FOMODLAY_TBNO           20
#define    VRDB_FOMXSPEC_TBNO           21
#define    VRDB_FOMXGRSP_TBNO           22
#define    VRDB_FOCONSEL_TBNO           23
#define    VRDB_FOCONN_TBNO             24
#define    VRDB_CONDUIT_TBNO            25

#endif

#endif
