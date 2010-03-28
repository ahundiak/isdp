#ifndef coimport_include
#define coimport_include

/*
Synopsis

	This file was created to support shared libraries. It should not
	be added to any new files.

History

	This file was originally created to support shared libraries.
	Extensive dependencies on the extern declarations evolved.

	25 June 1992 - AIC - Modified for ANSI compliance.

		All extern int and extern void function declarations
		have been commented out because they are of no
		significance.

		All extern global variables have been commented out. Any
		source file accessing these global varaiables must now
		declare them.

		Commented out all declarations of standard C functions
		and added standard C include files to replace the
		explicit declarations.

		Remaining extern function declarations are included only
		when not compiling ANSI. (Prototypes for these need to
		be added.)

		stat() sleep() write() and weight() had macro wrappers,
		which have been removed.
*/

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include <sys/types.h>	/* This is not an ANSI standard include file */
#include "dirent.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "griodef.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "igewindow.h"
#include "bsparameters.h"
#include "DIdef.h"
#include "palgo.h"

/*
These macros are no longer needed.

#define sys_stat() stat()
#define sys_sleep() sleep()
#define sys_write() write()
#define sys_weight() weight()
*/

/*
These are being included through the appropriate include files now.

extern char *strtok();
extern long  strtol();
extern char *realloc();
extern char *strcpy();
extern char *strncpy();
extern char *strcat();
extern char *memcpy();
extern char 	*memset();
extern  double	 sqrt();
extern  double	 floor();
extern double ceil();
extern char *strchr();
extern  double	 fabs();
extern char *strrchr();
extern char *fgets();
extern char *getenv();
extern char *strncat();
extern char	*ctime();
extern char *malloc();
extern long                                   time();
extern char * calloc();
*/

/*

These should be declared in the source files that access them. Most
are provided by OM and were only included in this file because of
shared libraries. In other cases, a syntax error will occur if the
variable is not declared in the source file.

extern OMuword EX_dup_os_occured;
extern struct palette_cmd GRpal_cur_cmd;
extern int (*GRpal_btn_locate_func)();
extern OMuword DIR_G_DIlink_clid;
extern OMuword DIR_G_master_os;
extern GRobjid DIR_G_master_id;
extern OMuword		DIR_G_IGRdir_clid;
extern OMuword OM_Gw_current_OS;
extern OM_p_SPAMAPENT OM_Gp_CurSpaceMap;
extern OM_S_NEIGHBOR OM_GS_NULL_NEIGHBOR;
extern OM_S_OBJID NULL_OBJID;
extern int (*OM_GA_primitives[])();
extern OM_S_CHANNUM NULL_CHANNUM;
extern IGRdouble              BSparameters[BSNUMPARAMETERS];
extern OM_p_MESSAGE                              OM_Gp_NULL_MESSAGE;
extern OMuword OM_Gw_TransOSnum_0;
extern OM_p_CLASSDEF                              *OM_GA_active_classes;
extern OM_S_OBJID OM_GO_current_OS_objid;
extern unsigned char _ctype[];
extern IGRshort                                    COInvisibleColor;
extern OM_S_OBJID EX_active_module;
extern OMuword EX_active_OS_num;
extern int errno;
extern int                                    sys_nerr;
extern char                                   *sys_errlist[];
extern IGRboolean dynamics_in_progress;
extern char                                    DIR_G_cdpath[DI_PATH_MAX];
extern char                                    DIR_G_str_dir[2];
extern char                                    DIR_G_home_name[DI_PATH_MAX];
extern char                                    DIR_G_cur_dir_name[DI_PATH_MAX];
extern char                                    DIR_G_car_dir;
extern int EX_pnt_entry;
extern int EX_pnt_entry_full;
extern struct EX_button EX_recallpnt[];
extern OM_S_OBJID EX_exec_id;
extern OMuword EX_exec_osnum;
extern char * p_CurrentPointForm;
extern char EX_runname[];

*/

#if defined(__STDC__)
/*
The MA, BS, and other prototype include files need to be added here.
*/
#else
/*
When not using prototypes, these are significant, because they conflict
with the default (extern int) that is used if the function is not
declared.
*/

/* MA */
extern IGRboolean MAcpfrlb();
extern IGRboolean MAmulmx();
extern IGRboolean MAtypemx();
extern IGRboolean MApytobc();
extern IGRboolean MAdotvc();
extern IGRboolean MAcsgenhist();
extern IGRboolean MAcspoly();
extern IGRboolean MA2ptdis();
extern IGRboolean MAcstobez();
extern IGRboolean MAbcpyeval();
extern IGRboolean MAcsupdhist();
extern IGRboolean MAbccopy();
extern IGRboolean MAbcconcat();
extern IGRboolean MArotmx();
extern IGRboolean MAeltobc();
extern IGRboolean MAartobc();
extern IGRboolean MAcntobs();
extern IGRboolean MA2pt2dis();
extern IGRboolean MAidmx();
extern IGRboolean MAptsxform();
extern IGRboolean MAang3pt();
extern IGRboolean MAtrnmx();
extern IGRboolean MA3protmx();
extern IGRboolean MAzrotmx();
extern IGRboolean MAtlncbclip();
extern IGRboolean MAptlnproj();
extern IGRboolean MAlnxform();
extern IGRboolean MAoptsxform();
extern IGRboolean MAptplproj();
extern IGRboolean MAang2vc();
extern IGRboolean MAgrotmx();
extern IGRboolean MAlbxform();
extern IGRboolean MApyfrlb();
extern IGRboolean MAcrossvc();
extern IGRboolean MAunitvc();
extern IGRboolean MAlncbclip();
extern IGRboolean MAcubepy();
extern IGRboolean MAscalvc();
extern IGRboolean MArptsxform();
extern IGRboolean MAlpfrln();
extern IGRboolean MAxrotmx();
extern IGRboolean MAgscamx();
extern IGRboolean MAdetplane();
extern IGRboolean MAtrlmx();
extern IGRboolean MAgrefmx();
extern IGRboolean MAsubvc();
extern IGRboolean MAwclsmx();
extern IGRboolean MAinvmx();
extern IGRboolean MAlbextents();
extern IGRboolean MArpextents();
extern IGRboolean MApyextents();
extern IGRboolean MAsincos();
extern IGRboolean MAptln2dis();
extern IGRdouble MAsqrt();
extern IGRdouble MAsin();
extern IGRboolean MAptls2dis();
extern IGRboolean MA2lnisect();
extern IGRdouble  MAdabs();
extern IGRboolean MAbrlnconstr();
extern IGRboolean MA2lnproj();
extern IGRboolean MAdegrad();
extern IGRdouble MAasin();
extern IGRboolean MAptalln();
extern IGRboolean MAaddvc();
extern IGRboolean MAlenvc();
extern IGRboolean MAplpromx();
extern IGRboolean MAang2ln();
extern IGRboolean MAbcendpts();
extern IGRboolean MAang2ptvc();
extern IGRboolean MA2ptrcconstr();
extern IGRboolean MAcrcptconstr();
extern IGRboolean MAraddeg();
extern IGRboolean MApapromx();
extern IGRboolean MAlswcmx();
extern IGRboolean MAlalpt();
extern IGRboolean MAlalnfpt();
extern IGRboolean MAangbis();
extern IGRboolean MA2pttobc();
extern IGRboolean MA3ptrcconstr();
extern IGRboolean MAeasmpsmconstr();
extern IGRboolean MAeasmconstr();
extern IGRboolean MApyfrar();
extern IGRboolean MAutoparms();
extern IGRdouble  MAatan2();
extern IGRboolean MAarendpts();
extern IGRboolean MAptbcproj();
extern IGRdouble MAcos();
extern IGRboolean MAcrrcsconstr();
extern IGRdouble MAatan();
extern IGRboolean MAptpyproj();
extern IGRboolean MAptattparm();

/* BS */
extern short BSpl_cv_int ();
extern  short	 BSavgpts();
extern short BSunwght_p();
extern short BSbx2();
extern IGRboolean BSdistnct2();
extern double BSdmod();
extern IGRboolean BScvoton();
extern IGRboolean BSlngen();
extern IGRboolean BSprj_cv_pl();
extern IGRboolean BSfreecv();
extern IGRboolean BSproj1();

/* Other */
extern IGRboolean GRvertical_ss_move();
extern struct palette * GRpal_create ();
extern struct palette * GRpal_recreate ();
extern IGRboolean 	COvsd_empty();
extern IGRlong                                    GRgetevent();
extern IGRlong                                    GUcreate_IGDSfile();
extern IGRboolean                                    GUget_next_ele();
extern IGRboolean                                    GUrad50_to_ascii();
extern IGRboolean                                    GRbclnextend();
extern IGRboolean                                    GRisitfnt();
extern IGRboolean                                    GRtx_extents();
extern IGRboolean                                    GRjust_string();
extern IGRlong                                    GUbsp_bufsize();
extern IGRlong                                    GUbsp_format();
extern IGRboolean                                GUrangeupdate();
extern IGRlong                                    COexpreval();
extern IGRlong                                    GRput_default_units();
extern IGRlong                                    GRget_default_units();
extern IGRlong COexpression_preprocessor();
extern IGRlong                                    GRcsmake_active();
extern IGRlong                                    COupdate_current_point_form();
extern IGRlong                                    COgetevent();
extern IGRlong                                    GRcsget_mgr();
extern IGRboolean                               GR2objaisect();
extern OMuword EX_get_invis_info_by_index();
extern IGRlong                                    GUplot_IGDS();
extern IGRboolean                                    GUsetmetactb();
extern IGRshort                                  GRchar_pos_info();
extern IGRshort                                  GRfwd_esc_seq();
extern IGRboolean                                    GRedit_text();
extern IGRboolean                                    GRvalid_string();
extern IGRboolean GRwnparam();
extern IGRboolean                                    GRcreate_lbs();
extern IGRboolean                                    GRnum_disp_char();
extern IGRboolean                                    GRstrip_esc_sequences();
extern IGRboolean                                    GRfld_ref_pt();
extern IGRboolean                                    GRgen_fraction();
extern IGRboolean                                    GRjust_field();
extern IGRshort                                    GRbwd_beg_esc_seq();
extern IGRshort                                  GRfwd_beg_esc_seq();
extern IGRboolean                                    GRbwd_disp_char();
extern IGRboolean                                GRlbsplapproj();
extern IGRboolean                                    GRls2pt();
extern IGRboolean                                    GR2objminline();
extern IGRlong                                    GRaddptsutil();
extern IGRboolean                                    GRclorthpg();
extern IGRlong                                    GRcsget_active_info();
extern IGRboolean                                    GR2objisect();
extern IGRboolean                                    GRhvls2pt();
extern IGRboolean                                    GR2objangbis();
extern IGRboolean                                    GRaals2pt();
extern IGRboolean                                    GRorthoseg();
extern IGRboolean                                    GRpladdpts();
extern IGRboolean                                    GRar3pt();
extern IGRboolean                                    GRfillet();
extern IGRboolean                                    GRarcnptang();
extern IGRboolean                                    GReaaxaxpt();
extern IGRboolean                                    GRarcnradpts();
extern IGRboolean                                    GRar2ptrad();
extern IGRboolean                                    GReaaxptax();
extern IGRboolean                               GRelaxaxpt();
extern IGRboolean                                    GRcr3pt();
extern IGRboolean                                    GRcrcnrad();
extern IGRboolean                                    GRelcnaxpt();
extern IGRboolean                                    GRcr2ptrad();
extern IGRboolean                                    GRcrdiam();
extern IGRboolean                               GRbrlnconstr();
extern IGRlong                                    GRcheckref();
extern IGRlong                              GRfindcontext();
extern IGRboolean FEadd_font();
extern IGRboolean IGEgetrgbvalue();
extern double atof();
extern char *mktemp();
extern IGRboolean DEsetinvisible();
extern IGRboolean DEclearinvisible();
extern IGRboolean GRrsloadctb();
extern IGRlong GRaltchgclass();
extern IGRlong GRabsg_del_by_objid();
extern struct dirent *readdir();
#endif

/*
These are insignificant because extern int is the default type for
undeclared functions.

extern int EX_use_default_dir ();
extern int EX_get_global ();
extern int DEref_view_recalled ();
extern int FIfld_set_active_row ();
extern int FIg_set_state ();
extern int GRreffile_reports ();
extern int GRpal_get_cmd_icon ();
extern int GRpal_add_cmd ();
extern int GRpal_del_cmd ();
extern int GRpal_save_file ();
extern int GRpal_delete ();
extern int GRpal_get_paths ();
extern int DIfast_trans();
extern int FIg_set_state_on();
extern int FIfld_get_text();
extern int FIfld_set_text();
extern int fflush();
extern int FIg_get_state();
extern int FIg_set_state_off();
extern int FIg_set_text();
extern int FIf_erase();
extern int FIf_display();
extern int FIf_set_seq_on();
extern int FIg_start_seq();
extern int FIf_set_seq_off();
extern int FIfld_set_num_rows();
extern int FIg_erase();
extern int FIg_display();
extern int FIfld_set_list_num_rows();
extern int FIfld_set_list_text();
extern int DPsi_savvw_name();
extern IGRint GRformdvprism();
extern IGRint IGEsractive();
extern IGRint GRgs_delete_action();
extern int abs();
extern IGRint LClayer();
extern IGRint LC_criteria_on();
extern IGRint LC_criteria_off();
extern IGRint  LCdef_cursor();
extern IGRint  LCmark_locate();
extern IGRint  LCrestore_cursor();
extern IGRint  LCget_parms();
extern IGRint  DIumount();
extern IGRint GRerase_chars();
extern IGRint GRdisplay_chars();
extern int EX_get_cmd_info();
extern int DIstrcmp ();
extern int DIterminator ();
extern IGRint DPchg_vw_names();
extern IGRint GRprism_locate();
extern int DIsend();
extern int		COB_process_EX_button_arg();
extern int 		COB_fetch_first_arg_num();
extern int 		EX_wait_for_input();
extern IGRint   	DIancestry_valid();
extern IGRint 		GRaddvar();
extern IGRint 		GRcvt_to_var();
extern int		DIfind();
extern IGRint		DEselect();
extern IGRint		DElocact();
extern int GRdpb_get();
extern int MSmessage();
extern int MS_init();
extern int MS_fix_type();
extern int sprintf();
extern int MS_out_msg();
extern int open();
extern IGRint                                    GUicheck_igds();
extern int close();
extern int blkmv();
extern IGRint                                    IGEchgresclr();
extern IGRint                                    IGEchgclrtab();
extern IGRint                                    IGEconclrtab();
extern IGRint                                    GRcvt_exp_to_wrk();
extern int fltvax_to_flt32();
extern IGRint                                    GRdpb_put();
extern IGRint                                    GUcreate_views();
extern IGRint                                    GUquat_to_rotmx();
extern int EX_findmod();
extern int EX_get_oid_nodname();
extern int  strlen();
extern IGRint                                    GUitxtjust();
extern IGRint                                    GRsetinq();
extern int                    EX_getpath();
extern IGRint                                    GUicheck_cellib();
extern int UI_status();
extern int UI_prompt();
extern IGRint                                    GRretrieve_cell_library();
extern IGRint                                    GRlslmgr_fun();
extern IGRint                                    GRget_NOD_object();
extern IGRint                                    GRbtreelocate();
extern IGRint                                    GRbtreeremove();
extern IGRint                                    GRsd_locate();
extern IGRint                                    GRbtreeadd();
extern int DImkpath();
extern int                                    EX_add_name_nodname();
extern IGRint                                   IGEcnctclrtab();
extern int                    EX_is_invis();
extern IGRint                                    IGEgetabsclrindx();
extern IGRint                                    IGEgetnumactcol();
extern int Help_topic();
extern IGRint                                    DPlevel_to_number();
extern IGRint                                    IGEgetclrfrnm();
extern IGRint                                    DPlev_num_to_name();
extern IGRint                                    IGEgetnmfrclr();
extern int GRcvt_imp_to_alias();
extern int EXputq2();
extern int fprintf();
extern int  strcmp();
extern int  strncmp();
extern int fclose();
extern IGRint                                    GRgs_fun();
extern int DIuntranslate();
extern IGRint                                    GRgspass();
extern IGRint                                    GRgsdisplay();
extern IGRint                                    DPerase_hilite();
extern IGRint                                    LClocate();
extern IGRint                                    DPsi_gg_name();
extern IGRint                                    GRparse_name_desc();
extern int som_vla_set_dimension();
extern int EX_get_super();
extern IGRint                                    GRgsinit();
extern IGRint                                    GRgs_locate_action();
extern IGRint                                    DPdynflags();
extern IGRint                                    GRgsget_simple_object();
extern IGRint                                    DPdynamics();
extern IGRint                                    GRget_window_matrix();
extern IGRint                                    GRclose_cell_library();
extern IGRint                                    GRformlbsys();
extern IGRint                                    GRplace_text();
extern IGRint                                    GRgsadd_object();
extern int tolower();
extern IGRint                                    GRget_global_mgr_id();
extern int sscanf();
extern IGRint                                    GRactive_owner_fun();
extern int                                    _ds_do();
extern int                                    Wait_timer();
extern IGRint                                    GRcvt_value_to_value();
extern IGRint                                    DPviewvol();
extern int DPsetinqgragad();
extern IGRint                                    LCget_info();
extern IGRint                                    DPdrawcross();
extern IGRint                                    LCdisplay();
extern IGRint                                    UI_echo();
extern IGRint                                    GRgsmgr_fun();
extern IGRint                                    GRbuild_prism_helper();
extern IGRint                                    GRgs_rp_action();
extern IGRint                                    GRgs_symb_action();
extern int module_build_path();
extern int                                    file_exists();
extern int                                    EX_filename1();
extern int                                    EX_saveas1();
extern int EX_retrieve_os();
extern int Close_OS();
extern IGRint                                    GRgslocate();
extern IGRint                                    LCwild_disconnect();
extern IGRint                                    LCconnect();
extern IGRint                                    LCptlocact();
extern IGRint                                  GRgetactenv();
extern IGRint                  GRbuildbuf();
extern IGRint                                    UI_message();
extern int MAarextents();
extern int                                    fstat();
extern int access();
extern int                                    _flsbuf();
extern int	uname();
extern int                                    setpgrp();
extern int read();
extern int                                    alarm();
extern int toupper();
extern int                                    fread();
extern int                                    fseek();
extern int atoi();
extern int printf();
extern IGRint                                    DPgetggid();
extern IGRint                                   EX_cp();
extern IGRint                                 EX_fork();
extern int                                    EX_set_up_file();
extern int                                    EX_get_file_default();
extern int                                    EX_file_create_list();
extern IGRint                                    GRsd_locate_in_all_sl();
extern IGRint                                    GRbtreelocate_all();
extern IGRint                                    GRsd_locate_in_asl();
extern IGRint                                    GRfindmod();
extern IGRint                                    GRgsaction();
extern IGRint                                    GRrf_empty_text_display();
extern int DPdisbyoid();
extern IGRint                                    DPclosestchar();
extern IGRint                                    GRvalid_cursor_position();
extern IGRint                                    GRtext_cursor();
extern IGRint                                    GRtext_fieldbox();
extern int EX_peek_event_queue();
extern int DIsplit();
extern int DItranslate();
extern int                                    DImain();
extern int DIadd_name();
extern IGRint                                    DPtxdynamics();
extern IGRint                                   GRupdate_readout_spec();
extern IGRint                                    DPalignper();
extern IGRint                                    EX_bell();
extern int DPdisbybuf();
extern IGRint                                    DP3Ddatapt();
extern IGRint                                    DPbrlnconstr();
extern IGRint                                    DPsetpersp();
extern IGRint                                    DPunpersp();
extern int                    IGEwin_const();
extern int DPsetinqwindow();
extern int EX_get_NOD();
extern int                    EX_get_oid_nodid();
extern IGRint                                    DPlevel();
extern IGRint                                    DPsavevw_cons();
extern int DPgetvwid();
extern IGRint                                    savedvw_recall();
extern int DPsetinqsavvw();
extern IGRint                                    DPordphigs();
extern IGRint                                    DPphigsord();
extern IGRint                                    DPcalinfo();
extern IGRint                                    DPcvtpersp();
extern IGRint                                    DPchek_clr_tbl();
extern IGRint                                    DPload_clr_tbl();
extern IGRint                                    DPsave_clr_tbl();
extern int                    MS_onoff();
extern IGRint                                    DPsetinq_bell();
extern IGRint                                    IGEstopinit();
extern IGRint                                    DPtotal_num_svw();
extern int                    EX_get_modid_given_osnum();
extern int EXinq_locale();
extern int                                    mouse_position();
extern int fgcolor();
extern int hidecursor();
extern int drawsymbols();
extern int flushbuffer();
extern int Load_symbol_file();
extern IGRint                                    LCget_channel_objects();
extern IGRint                                   GRIO_strprepend();
extern IGRint                                    LCget_channel_count();
extern IGRint                                    GRgs_is_graphics_set();
extern IGRint                                   GRgsremove_fence();
extern IGRint                                   GRgsflatten();
extern IGRint                                    LCrange_disconnect();
extern IGRint                                    GRbuild_cvprism();
extern IGRint                                    LCget_objid_at_index();
extern int                                    DIstrcpy();
extern int                                    DIcd();
extern int                                    DIpwd();
extern int                                    DIstart_find();
extern int                                    DIfetch_find();
extern int DIrename();
extern int                                    DIadd_line();
extern int                                    DIfrees();
extern int                                    DIstrcat();
extern int                                    DIstart_dump();
extern int                                    DIfetch_dump();
extern int                                    DIrmdir();
extern int      DIgive_pathname();
extern int                                    DImkdir();
extern int DIreport_error();
extern int                                    DIexpanse();
extern int     DImount();
extern int     DIunindex();
extern int     DIrm_index();
extern int     DIadd_index();
extern int     DPmacupdate();
extern int                                    rand();
extern int DIclean ();
extern int DIget_choice ();
extern int DInew_trailer ();
extern int DIread_line ();
extern int EX_is_driver_exist ();
extern int DPerasecross();
extern int EX_get_input();
extern EX_translate_funckey();
extern int keybd_bell();
extern int link();
extern int fcntl();
extern int kill();
extern IGRint EX_is_batch();
extern IGRint DPset_view_rot();
extern int get_modtype_data();
extern IGRint LC_check_id();
extern IGRint LCpost_function();
extern int FIf_set_location();
extern int FIg_set_location();
extern int FIfld_set_select();
extern int FIg_set_value();
extern IGRint   IGEmodclrtab();
extern int  FIf_get_cmd_oid_os();
extern int  FIf_get_user_pointer();
extern int FIf_set_max_size();
extern int FIf_set_min_size();
extern int FIf_set_notification_routine();
extern int FIf_set_scaling_off();
extern int FIf_set_size();
extern int FIf_set_user_pointer();
extern int FIg_call_notification_routine();
extern int FIf_new();
extern int FIf_delete();
extern int FIfld_get_list_text();
extern int FIg_reset();
extern int pclose();
extern int UI_error();
extern int fscanf();
extern int FIfld_get_num_rows();
extern int FIg_disable();
extern int GRget_font_info();
extern int DIunall();
extern int FIf_process_point();
extern int EX_is_temp_wakeup();
extern int FIf_set_button_intercept_routine();
extern int EX_clear_command_on_save();
extern int FIf_is_displayed();
extern int FIg_set_line_weight();
extern int FIf_get_attr();
extern int FIf_set_attr();
extern int FIg_add_to_group();
extern int FIg_delete();
extern int FIg_new();
extern int FIg_set_standard_variables();
extern int FIg_set_on_color();
extern int FIg_set_off_color();
extern int FIg_activate();
extern int FIg_set_continuous_routine();
extern int FIfld_get_text_length();
extern int FIfld_get_value();
extern int FIg_set_color();
extern int FIg_set_line_style();
extern int creat();
extern int FIf_get_size();
extern int GRcscvt_coords();
extern int EX_dyn_process_input_event();
extern IGRint  GRsend_to_next_sibling();
extern IGRint GRbtreecount();
extern int FIfld_get_active_row();
extern int FImcf_get_active_col();
extern IGRint GRblock_text();
extern int FIg_get_text();
extern int FIg_get_text_length();
extern int EX_is_help_active();
extern int closedir();
extern int FI_get_form_by_name();
extern int EX_define_input_generator();
extern int FImcf_set_select();
extern int FIf_reset();
extern int FIfld_set_mode();
extern int FImcf_get_attr();
extern int FImcf_set_attr();
extern int FIfld_set_list_default_text();
extern int FImcf_get_select();
extern int FIfld_get_mode();
extern int GRpart_get_default_parts_dir();
extern int DIindex();
extern int GRget_to_comp_info();
extern int GRpart_get_count();
extern int DIpass();
extern int EMunwind_stupid_sets();
extern int DIis_regexp();
extern int system();
extern int FIf_cvrt_to_perm_win();
extern int putenv();
extern int unlink();
extern int BScvarrevc();
extern int EX_add_name_nodid();
extern int EX_remove_name_nodid();
extern int GRcvt_imp_to_wrk();
extern int FIg_enable();


These are insignificant because the caller is not getting any return
value.

extern void                                   (*signal())();
extern void OM_PMS();
extern void		BScvcvint();
extern void                    IGEinq_term_info();
extern void	 BStst_plan();
extern void                                    BSsftstclsd();
extern void                                    Cvrt_clr_index_to_slot_no();
extern void                                    COclear_vsd();
extern void perror();
extern void free();
extern void qsort();
extern void rewind();
extern void BSeqdptscv();
extern void GUinit_map();
extern void BSalloccv();
extern void BSarctnfrcv();
extern void BStstcvdegn();
extern void BScveval();
extern void BSnorvec();
extern void BScomb2cvs();
extern void BSarclnparc();
extern void BSmdstptcv();
extern void BSrgbxplint();
extern void BStstcvfln();
*/
#endif
