#ifndef grimport_include
#define grimport_include

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
*/

#include <stdio.h>
#include <sys/types.h>	/* This is not an ANSI standard include file */
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#ifndef NT
#include "dirent.h"
#endif /* NT */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ex.h"
#include "bsparameters.h"

/*
These are being included through the appropriate include files now.

extern char * realloc();
extern char * calloc();
extern char * strtok();
extern char *strcat();
extern char *memcpy();
extern char *strcpy();
extern char *strncpy();
extern void free();
extern char *malloc();
extern char *strchr();
extern  double	 fabs();
extern  double	 cos();
extern double ceil();
extern char *strrchr();
extern char *strncat();
extern long time();
extern double atof();
extern char *bsearch();
extern double modf();
*/

/*

These should be declared in the source files that access them. Most
are provided by OM and were only included in this file because of
shared libraries. In other cases, a syntax error will occur if the
variable is not declared in the source file.

extern OMuword EX_dup_os_occured;
extern char EX_version[];
extern int CODrawviewActive;
extern OM_p_SPAMAPENT  OM_Gp_CurSpaceMap;
extern int GR_G_dir_mode;
extern int (*OM_GA_primitives[])();
extern OM_S_CHANNUM NULL_CHANNUM;
extern OM_S_OBJID NULL_OBJID;
extern OMuword OM_Gw_current_OS;
extern OM_S_NEIGHBOR OM_GS_NULL_NEIGHBOR;
extern OM_S_OBJID EX_active_module;
extern OMuword EX_active_OS_num;
extern OM_S_OBJID EX_exec_id;
extern OMuword EX_exec_osnum;
extern OMuword OM_Gw_TransOSnum_0;
extern OM_p_CLASSDEF  *OM_GA_active_classes;
extern int CSfont_descr;
extern OM_p_MESSAGE OM_Gp_NULL_MESSAGE;
extern unsigned int OM_Gf_alternate_mode;
extern IGRshort               DPcolor_map[2][512];
extern IGRdouble              BSparameters[BSNUMPARAMETERS];
extern OMuint  OM_Gf_tagged_connects;
extern OMuint  OM_Gf_tagging_enabled;
extern struct EX_visible_module *module_table;
extern struct EX_invisible_module *invisible_table;
extern unsigned char _ctype[];
extern OMuword EX_ACTINV_OS_num;
extern char *  p_CurrentPointForm;
extern OMuword OM_Gw_max_ref_files;
extern OMuword OM_Gw_max_modules;
extern char DIR_G_car_dir;
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
extern IGRboolean MAraddeg();
extern IGRboolean MAptinpg();
extern IGRboolean    MA2ln2dis();
extern IGRboolean    MA2lndis();
extern IGRboolean   MA2lnisect();
extern IGRboolean   MA2lnproj();
extern IGRboolean   MA2pt2dis();
extern IGRboolean   MA2ptdis();
extern IGRboolean   MA2pttobc();
extern IGRboolean   MA3protmx();
extern IGRboolean   MAaddvc();
extern IGRboolean   MAang2vc();
extern IGRboolean   MAangtou();
extern IGRboolean   MAar3ptconstr();
extern IGRboolean   MAarcptangconstr();
extern IGRboolean   MAarcsmptconstr();
extern IGRboolean   MAarendpts();
extern IGRboolean   MAarextents();
extern IGRboolean   MAarr2ptconstr();
extern IGRboolean   MAarr3ptconstr();
extern IGRboolean   MAartobc();
extern IGRboolean   MAarxform();
extern IGRboolean   MAat3bc();
extern IGRdouble   MAatan();
extern IGRdouble   MAatan2();
extern IGRboolean   MAbcarclen();
extern IGRboolean   MAbcconcat();
extern IGRboolean   MAbccopy();
extern IGRboolean   MAbcelprops();
extern IGRboolean   MAbcendpts();
extern IGRboolean   MAbcinpl();
extern IGRboolean   MAbcmidpt();
extern IGRboolean   MAbcrevparm();
extern IGRboolean   MAbctoar();
extern IGRboolean   MAbctotlen();
extern IGRboolean   MAbcu1derivative();
extern IGRboolean   MAbcueval();
extern IGRboolean    MAbcukexpand();
extern IGRboolean    MAbcukunexpand();
extern IGRboolean    MAbcupexpand();
extern IGRboolean    MAbcupunexpand();
extern IGRboolean   MAbcusplit();
extern IGRboolean    MAbcuuniform();
extern IGRboolean   MAbrlnconstr();
extern IGRboolean    MAbssize();
extern IGRdouble   MAcos();
extern IGRboolean    MAcpextents();
extern IGRboolean    MAcpfrlb();
extern IGRboolean    MAcpxform();
extern IGRboolean   MAcr3ptconstr();
extern IGRboolean   MAcrcptconstr();
extern IGRboolean   MAcrdconstr();
extern IGRboolean   MAcrossvc();
extern IGRboolean   MAcrr2ptconstr();
extern IGRboolean   MAcrrcconstr();
extern IGRboolean   MAct2bc();
extern IGRboolean   MAct3bc();
extern IGRboolean   MAcubepy();
extern IGRboolean    MAcylrec();
extern IGRdouble   MAdabs();
extern IGRboolean   MAdetplane();
extern IGRboolean   MAdotvc();
extern IGRboolean   MAeasmconstr();
extern IGRboolean   MAeasmpsmconstr();
extern IGRboolean   MAelarea();
extern IGRboolean   MAelcsmconstr();
extern IGRboolean   MAelsmconstr();
extern IGRboolean   MAeltobc();
extern IGRboolean    MAgrmscht();
extern IGRboolean   MAgrotmx();
extern IGRboolean   MAgscamx();
extern IGRboolean   MAidmx();
extern IGRboolean   MAinvmx();
extern IGRboolean   MAinvscmx();
extern IGRboolean   MAlalnfpt();
extern IGRboolean   MAlalnlfpt();
extern IGRboolean   MAlbextents();
extern IGRboolean    MAlbinpl();
extern IGRboolean   MAlbxform();
extern IGRboolean   MAlnarproj();
extern IGRboolean   MAlnbcproj();
extern IGRboolean   MAlncbclip();
extern IGRboolean   MAlnlb2dis();
extern IGRboolean   MAlnlbproj();
extern IGRboolean   MAlnlsproj();
extern IGRboolean    MAlnoffset();
extern IGRboolean   MAlnplisect();
extern IGRboolean   MAlnplproj();
extern IGRboolean   MAlnpsproj();
extern IGRdouble    MAlog();
extern IGRboolean   MAlpfrbc();
extern IGRboolean   MAlpfrln();
extern IGRboolean   MAlstobc();
extern IGRboolean   MAlswcmx();
extern IGRboolean   MAltfrbc();
extern IGRboolean   MAmulmx();
extern IGRboolean   MAoptsxform();
extern IGRboolean   MApapromx();
extern IGRboolean    MApllbrel();
extern IGRboolean   MAplpromx();
extern IGRboolean   MAplpytobc();
extern IGRdouble    MApower();
extern IGRboolean   MAptarproj();
extern IGRboolean   MAptattparm();
extern IGRboolean   MAptbcproj();
extern IGRboolean   MAptelproj();
extern IGRboolean   MAptinlb();
extern IGRboolean   MAptlbproj();
extern IGRboolean   MAptln2dis();
extern IGRboolean   MAptlnproj();
extern IGRboolean   MAptls2dis();
extern IGRboolean   MAptlsproj();
extern IGRboolean    MAptonvc();
extern IGRboolean   MAptplproj();
extern IGRboolean   MAptpsproj();
extern IGRboolean   MAptscentroid();
extern IGRboolean   MAptsxform();
extern IGRboolean   MAptwcangel();
extern IGRboolean   MApyarea();
extern IGRboolean   MApyextents();
extern IGRboolean    MApyfrar();
extern IGRboolean   MApyfrlb();
extern IGRboolean   MApytobc();
extern IGRboolean    MAreccyl();
extern IGRboolean    MArecsph();
extern IGRboolean   MArotmx();
extern IGRboolean   MArpextents();
extern IGRboolean   MArptsxform();
extern IGRboolean    MArtrnmx();
extern IGRboolean   MAscalvc();
extern IGRdouble   MAsin();
extern IGRboolean   MAsincos();
extern IGRboolean    MAsphrec();
extern IGRdouble   MAsqrt();
extern IGRboolean   MAsubvc();
extern IGRboolean   MAtlncbclip();
extern IGRboolean   MAtrlmx();
extern IGRboolean   MAtrnmx();
extern IGRboolean   MAtypemx();
extern IGRboolean   MAulabcabc();
extern IGRboolean   MAulatobc();
extern IGRboolean   MAulp2bc();
extern IGRboolean   MAulpbcabc();
extern IGRboolean   MAulptobc();
extern IGRboolean   MAult2bc();
extern IGRboolean   MAultbcabc();
extern IGRboolean   MAultbcpbc();
extern IGRboolean   MAulttobc();
extern IGRboolean   MAunitvc();
extern IGRboolean   MAutoparms();
extern IGRboolean   MAuvcnrbc();
extern IGRboolean   MAuvctnbc();
extern IGRboolean   MAwclsmx();
extern IGRboolean   MAxrotmx();
extern IGRboolean   MAyrotmx();
extern IGRboolean   MAzrotmx();
extern IGRboolean  MAscalmx();
extern IGRboolean MAdegrad();
extern IGRdouble MAasin();

/* BS */
extern IGRboolean BSlnpttncv();
extern IGRboolean BSlntn2cvs();
extern IGRboolean BSnorcvpt();
extern IGRboolean BSlntncvncv();
extern IGRboolean BSlnn2cvs();
extern short BSarccen();
extern  short	 BSfreecv();
extern  short	 BSactivsplt();
extern IGRboolean BSprptoncv();
extern  short	 BSchangepar();
extern IGRboolean BSrdcencrcv();
extern IGRboolean BSxtractpar();
extern IGRboolean BSptsdlcv();
extern IGRboolean BScncxttpt();
extern IGRboolean BScvcv_int();
extern IGRboolean BScv_sf_int();
extern IGRboolean BSfillet();
extern IGRboolean BSequalspcs();
extern IGRboolean BScvcoplan();
extern IGRboolean BSfillettr1();
extern IGRboolean BSfillettr2();
extern IGRboolean BSfilletatr();

/* Other */
extern OMuword EX_get_invis_info_by_index();
extern long RAP_get_keyboard_data();
extern IGRboolean RScalccalib();
extern IGRboolean BSlngen();
extern char *AA_config_path();

/*
These are insignificant because extern int is the default type for
undeclared functions.

extern int FIf_set_orig_coord ();
extern int EX_clear_command_on_save();
extern int FIf_display();
extern int FIf_get_color();
extern int FIf_is_collapsed();
extern int FIf_get_location();
extern int FIf_get_size();
extern int FIg_get_on_color();
extern int FIg_get_off_color();
extern int FIg_get_attr();
extern int FIf_erase();
extern int FIg_get_size();
extern int FIf_process_point();
extern int FIf_set_collapse_location();
extern int getenv();
extern int access();
extern int FIf_get_window();
extern int Create_win_user_icon();
extern int Set_win_user_icon();
extern int Update_win_icon();
extern int FIf_new();
extern int FIf_set_attr();
extern int FIf_set_color();
extern int FIf_set_size();
extern int FIf_set_location();
extern int FIf_set_window_level();
extern int FIf_set_window_icon_routine();
extern int FIf_set_button_intercept_routine();
extern int FIg_new();
extern int FIgrp_set_single_select_on();
extern int FIg_set_standard_variables();
extern int FIg_add_to_group();
extern int FIg_set_attr();
extern int FIg_set_command();
extern int FIg_set_symbol_file();
extern int FIg_set_justification();
extern int FIg_set_font();
extern int FIg_activate();
extern int FIg_get_command();
extern int FIg_get_symbol_file();
extern int FIg_get_off_symbol_index();
extern int FIg_get_text();
extern int FIf_delete();
extern IGRint EX_inq_events();
extern int FSGetCharVect();
extern int EX_filename1();
extern int GRangle_grid();
extern int CO_xlate_from_user_mode();
extern IGRint IGEgetnumactcol();
extern int CO_xlate_to_user_mode();
extern int EX_add_cmdserver_function();
extern int	DIstmcpy();
extern int	DIstmcat();
extern int	GRcg();
extern int	DImkpath();
extern int  strlen();
extern int                    EX_getpath();
extern int open();
extern int close();
extern int blkmv();
extern int fltvax_to_flt32();
extern int IGEreadclrtab();
extern int IGEreadresclr();
extern int read();
extern int  strcmp();
extern int  strncmp();
extern int EX_findmod();
extern int EX_get_oid_nodname();
extern int  FSGetTextVect();
extern int                    IGEwin_const();
extern int DPsetinqwindow();
extern int MSmessage();
extern int EX_peek_event_queue();
extern int EXputq2();
extern int pushattributes();
extern int hidecursor();
extern int defcursor();
extern int showcursor();
extern int flushbuffer();
extern int popattributes();
extern int DIis_regexp();
extern int DIpass();
extern int DIreport_error();
extern int MS_init();
extern int MS_fix_type();
extern int MS_out_msg();
extern int EX_get_cmd_info();
extern int                    EX_get_modid_given_osnum();
extern int EX_get_super();
extern int drawsymbols();
extern int DIuntranslate();
extern int DIsplit();
extern int Load_symbol_file();
extern int DItranslate();
extern int DImain();
extern int som_vla_set_dimension();
extern int DIrm_objid();
extern int GRsmplace();
extern int EX_add_name_nodid();
extern int EX_get_NOD();
extern int                    EX_get_oid_nodid();
extern int EX_retrieve_os();
extern int EX_mod_info();
extern int Close_OS();
extern int Save_OS();
extern int FSGetOutlCharInfo();
extern int EXinq_locale();
extern int EX_is_temp_wakeup();
extern int FSGetOutlInfo();
extern int EX_same_file;
extern int DIstrcpy();
extern int DIstrcat();
extern int                    GPDelete();
extern int                    GPCreateWin();
extern int                    GPBsplineMaxPnts();
extern int enableplane();
extern int                    blendarea();
extern int                    texture();
extern int      DIgive_pathname();
extern int                    EX_is_batch();
extern int fgcolor();
extern int move();
extern int draw();
extern int                    EXputq_back();
extern int                    EX_disp_flag();
extern int blendline();
extern int                    IGEstop();
extern int linestyle();
extern int                    Set_win_buffer_size();
extern int Set_win_name();
extern int Error_box();
extern int                    Mouse_win_position();
extern int                    enter_db();
extern int rectf();
extern int                    exit_db();
extern int                    GPLinestr3D();
extern int                    GPCreateFB();
extern int                    GPBsplineTol();
extern int DIstart_dump();
extern int DIfetch_dump();
extern int DIpwd();
extern int DIcd();
extern int DIstart_find();
extern int DIrename();
extern int DImkdir();
extern int DIadd_name();
extern int Inq_displayed_vs();
extern int Inq_events();
extern int EX_get_kybd_data();
extern int                    pnt();
extern int                    GPPutViewport();
extern int                    GPSetZclip();
extern int                    GPPutMatrix();
extern int                    GPCharMatrix();
extern int                    GPBsplineCurve();
extern int                    GPPassthruFB();
extern int                    GPResetFB();
extern int                    GPBsplineSurface();
extern int GPPolyFill3D();
extern int                    RSstroke();
extern int                    FSGetOutl3DDrawFunc();
extern int                    FSSetOutl3DDrawFunc();
extern int                    GPGetMatrix();
extern int                    FSDrawText();
extern int                    Inq_button_data();
extern int Get_button_data();
extern int keybd_bell();
extern int IGEcnctclrtab();
extern int IGEgetrgbvalue();
extern int                    EX_is_invis();
extern IGRint                  GRupdate_adp_forms();
extern int module_build_path();
extern int DIstmocpy();
extern int DImount_ref();
extern int EX_is_file_open();
extern int EX_file_status();
extern int EX_add_name_nodname();
extern int     COexpr_yyparse();
extern int tolower();
extern int UI_status();
extern int toupper();
extern int EX_wait_for_input();
extern int EX_inq_language();
extern IGRint EX_inq_button_data();
extern IGRint EX_is_button_defined();
extern IGRint EX_get_button_data();
extern IGRint IGEsractive();
extern int DIfetch_untrans();
extern int FIg_set_text();
extern int FIg_set_symbol_index ();
extern int GPPointstr3D();
extern int GRset_inq_gs_flag();
extern int DIfast_trans();
extern int FIg_erase();
extern int FIg_display();
extern int DIrmdir();
extern int write();
extern int EX_dyn_process_input_event();
extern int EX_clean_str();
extern IGRint RSloadvlt();
extern IGRint DPset_load_vlt_ptr();
extern IGRint IGEconclrtab();
extern IGRint Set_win_button_mode();
extern int FSGetTFInfo();
extern int atoi();
extern int GPResetMatrix();
extern int FSGetKernMode();
extern int blockrestore();
extern int blocksave();
extern int JNL_playback();
extern int FIf_find_gadget();
extern int BSmkvec();
extern int BSnorvec();
extern int DIindex();
extern int DIunlink_dir();
extern int FSGetBmapDrawFunc();
extern int FSSetBmapDrawFunc();
extern int FSGetBmapCharInfo();
extern int drawbitmap();
extern int FIf_set_collapse_symbol();
extern IGRint DIlink();
extern int Inq_win_vs();
extern int COConstructObject();
extern int CLAA_get_answer_ptrs();
extern int CLAA_answer_complete();
extern int AA_need_to_flush_answers();
extern int AA_really_busy();
extern int CLAA_get_request_ptrs();
extern int CLAA_request_complete();
extern int AA_allocate();
extern int linestring();


These are insignificant because the caller is not getting any return
value.

extern void BSxtlntcvbx();
extern void BSint2lns();
extern void BSlnangptcv();
extern void	GRreport_error();
extern void                    IGEinq_term_info();
extern void BSsubdivcv();
extern void BSeigvec3x3();
extern void BSeqdptscv();
extern void                   IGEget_num_screens();
extern void                    BSchgdeppar();
extern void BSarcofpts();
extern void BScv_clp_sp();
extern void BScv_clpsp2();
extern void BScvoffsetd();
extern void BScv_in_fnc();
extern void BScvincvfnc();
extern void BSsplitcv();
extern void BSpolincfnc();
extern void BSpol_infnc();
extern void BScncxtdst();
extern void BSlbs_infnc();
extern void BSlbsincfnc();
extern void BSrefvwclp();
extern void BSarcptrdcv();
extern void BSac2ptctvc();
extern void BSactncvept();
extern void BSsfarrevn();
extern void BSptperpsfa();
extern void BSmdistcvcv();
extern void BSmdistcvsf();
extern void BSmdistsfsf();
extern void BSsplitcv2();
extern void BScveval();
extern void BSlocrefvwl();
extern void BSlocrefvwp();
extern void qsort();
extern void BSangarctou();
extern void  DIfrees();
extern void BSarclnparc();
extern void swab();
extern void BScvarrev0();
extern void BScvcvint();
extern void DIexpanse();
*/

#endif
#endif
