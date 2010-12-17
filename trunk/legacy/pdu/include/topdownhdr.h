#include "ciminimum.h"
#include "cimacros.h"
#include "OMlimits.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "stdio.h"
#include "refdef.h"
#include "referr.h"
#include "ref.h"
#include "PDUprompt.h"
#include "PDUstr.h"
#include "PDUint.h"
#include "grgsmacros.h"
#include "grmessage.h"
#include "msdef.h"
#include "dp.h"
#include "gr.h"
#include "PDUforms.h"
#include "PDUfile_def.h"
#include "FI.h"
#include "PDUgrpart.h"
#include <grdpbmacros.h>
#include <exmacros.h>
#include <grdpbdef.h>
#include "partdef.h"
#include "partmacros.h"
#include "part.h"
#include <MEMstruct.h>
#include "godef.h"
#include "detaildef.h"
#include "PDUintdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "PDUassy.h"

/*
 * ************************************ BEGIN *************************************
 * PDU 2.4. Changes made for seed file selection interface.
 * 03/sep/93 - raj.
 */

#include	"CIforms.h"

/*
 * PDU 2.4. 03/sep/93 - raj.
 * #include	"part_gadgets.h"
 * The include is causing redefinitions of CATALOG_NAME, REVISION_NAME, e.t.c., in 'partdef.h'
 * file. So I am using just the seed file form related gadgets from 'part_gadgets.h' file.
 */

#define SEED_FILE_TGL               18
#define NFC_PART_GRP                23
#define NFC_SEARCH_BTN              15 
#define NFC_CATALOG_BTN             67
#define NFC_PART_BTN                68
#define NFC_REV_BTN                 69
#define NFC_FILENAME_BTN            13
#define NFC_CATALOG_FLD             34
#define NFC_PART_FLD                35
#define NFC_REV_FLD                 36
#define NFC_FILENAME_FLD            37
#define NFC_DESC_FLD                12

#include	"PDUform_def.h"

extern	ASMSplitPart ();
extern	WaitForEvent ();

extern	PDUtopdown_seed_form_init ();
extern	PDUtopdown_cancel_seedfile_form ();
extern	PDUtopdown_accept_seed_file_form ();
extern	PDUtopdown_seed_file_toggle ();
extern	PDUtopdown_catalog_field ();
extern	PDUtopdown_part_field ();
extern	PDUtopdown_revision_field ();
extern	PDUtopdown_filename_field ();
extern	PDUtopdown_desc_field ();
extern	PDUtopdown_catalog_btn ();
extern	PDUtopdown_part_btn ();
extern	PDUtopdown_revision_btn ();
extern	PDUtopdown_filename_btn ();
extern	PDUtopdown_search_btn ();

extern	ci_notification ();

extern	FIf_new ();
extern	FIf_set_cmd_oid_os();
extern	FIf_display ();
extern	FIg_set_text ();
extern	FIf_delete ();

extern	PDUupdate_parametric_tag ();
extern	PDUincrement_child_no ();
extern	GetMacroHeaderGivenGrid ();
extern	GetOriginalMacroInfo ();
extern	get_acdyncol_temp ();
extern	GetACrgAttribVal ();

/*
 * PDU 2.4. END Changes made for seed file selection interface.
 * 03/sep/93 - raj.
 * ************************************** END *************************************
 */


extern free();
extern PDUget_all_GRpart_ids();
extern PDUget_all_parametric_ids();
extern _pdm_debug();
extern _pdm_status();
extern PDUverify_login();
extern PDUfill_in_string();
extern PDUverify_file();
extern PDUverify_part();
extern PDUverify_catalog();
extern PDUverify_element();
extern PDUtopdown_form();
extern PDUmessage();
extern PDUcatalog_id();
extern PDUretrieve_invis_file();
extern PDUstrcpy();
extern PDUgetcwd();
extern PDUpart_form();
extern PDUdisplay_design_form();
extern PDUsetup_buffer();
extern PDUget_buffer_col();
extern PDUdelete_origins();
extern PDMget_filenames();
extern PDMget_catno_partno();
extern MEMclose();
extern GRdpb_get();
extern GRgsmgr_fun();
extern EX_retrieve_os();
extern EX_get_invis_info_by_index();
extern PDUremove_non_existent_parts_from_assy_struct();
extern PDUgenerate_instance_number();
extern PDUis_usage_unique();
extern Close_OS();
extern sleep();
extern unlink();
extern strncpy();
extern malloc();
#if defined (__sgi) || defined (__Sol2__) || defined (sparc)
#else
extern sprintf();
#endif

extern printf();
extern FIf_erase();
extern print_queue();
extern memset();
extern PDUdelete_PDU_GRpart();
extern delete_prpart();
extern PDUis_parametric_part();

extern PDUis_PDU_part ();

extern COpart_attr_func();
extern PDUcreate_part_pointer();
extern PDUmatrix_to_point();
extern MAinvmx();
extern PDUadd_points();
extern MA3protmx();
extern PDUdump_matrix();
extern PDUattach_ref_to_GRpart();
extern PDUunquote();
extern PDUget_GRpart_all_attrs();
extern COpart_construct_func();
extern PDUadd_assy_struct_from_buffer();
extern DIgive_pathname();
extern PDUmodify_exp();
extern PDUgenerate_tag_no();
extern PDUgenerate_child_no();
extern DImkpath();
extern PDUcreate_exp();
extern PDUstrip_dir_entry();
extern DIstmocpy();
extern PDUget_seed_file();
extern PDUdelete_svview();
extern PDUload_view_info();
extern PDUremove_PDU_file_stamp();
extern PDUupdate_attach_info();
extern PDUextract_dir_value();
extern PDMget_assembly_structure();
extern MEMbuild_array();
extern vfork();
extern execlp();
extern waitpid();
extern DIfind();
extern DImain();
extern PDUrmdir();
extern find_file();
extern PDUcopyOS_file();
/* ************************************ BEGIN ************************************* */
 /*
  * PDU 2.4. Changes made for seed file selection interface.
  * 03/sep/93 - raj.
 */

extern	realloc ();

/* ************************************** END ************************************* */

extern struct PDUrefresh	*refresh;
extern struct PDUpart_node  *PDU_parts_id_list; 
extern IGRint PDM_debug_on;
extern IGRchar *PDU_save_catalog;
extern IGRchar *PDU_save_partid;
extern IGRchar *PDU_save_revision;
extern IGRchar *PDU_save_description;
extern IGRchar *PDU_save_filename;
extern IGRchar *PDU_topdown_flag;
extern IGRint bufr_flag;
extern IGRint PDU_command;
extern IGRshort PDU_attach;
extern IGRshort PDU_design_form_display;
extern IGRdouble PDU_point[3];
extern struct PDUforms forms;
extern struct GRid PDU_invis_newmod;
extern IGRchar  *PDU_viewname;
extern IGRchar  *PDU_filename;
extern IGRchar  *PDU_usage_id;
extern IGRshort  PDU_display_dyn_attr;
extern IGRchar  *PDU_incl_ASM;

/*
 * ************************************ BEGIN *************************************
 * PDU 2.4. Changes made for seed file selection interface.
 * 03/sep/93 - raj.
 */

extern short    PDU_list_filenames;
extern short  PDU_check_file_refresh;
extern Form   PDU_form_id;

extern	int      topdown_seed_form_created;
extern	int      topdown_seed_form_displayed;

IGRchar topdown_seedfile_name[32];
struct  CIform_st form_st;

/*
 * PDU 2.4. END changes made for seed file selection interface.
 * 03/sep/93 - raj.
 * ************************************** END *************************************
 */

IGRint	i;
IGRint  file_col;
IGRint  view_col;
IGRint  stat;
IGRint  index;
IGRint  total_count;
IGRint  grpart_count;
IGRint  parampart_count;
IGRint  instance_no;
IGRint  length;
IGRchar	confirm[5];
IGRchar	answer[5];
IGRchar	option[5];
IGRchar	checkin[5];
IGRchar display[5];
IGRchar attach[5];
IGRchar place[5];
IGRchar	cont[5];
IGRchar	add[5];
IGRchar	input_string[60];
IGRchar filename[60];
IGRchar addname[60];
IGRchar cat_prompt[60];
IGRchar user_msg[80];
IGRchar mount_name[40];
IGRchar instance_string[10];
IGRchar *delete_file;
IGRchar *cwd;
IGRchar *windowname;
IGRchar	*file;
IGRchar **data_row;
IGRchar *usageid;
IGRchar *catno;
IGRchar *itemno;
IGRlong	sts;
IGRlong msg;
IGRlong NumberOfBytes, BytesReceived;
GRobjid osid;
struct  GRmd_env  mod_env;
struct  GRmd_env  active_mod_env;
struct  GRid     newmod;
struct  GRid     coord;
struct  GRid     part_id;
struct  GRid     refobjid;
struct  GRid     cs_id;
struct  GRid     tmprfid;
struct  GRid     dv_refid[1];
struct  PDUpart_node      *parts_ids;
struct  PDUpart_node      *parametric_ids;
struct  PDUpart_node      *head;
IGRchar attr_value[MAX_VALUE];
IGRint  type;
IGRint  selector;
IGRint  id_type[1];
MEMptr  part_asm_bufr;
MEMptr  ret_bufr;
MEMptr  view_buffer;
IGRshort action;
IGRshort props;
IGRchar  catalog[MAX_VALUE];
IGRchar  number[MAX_VALUE];
IGRchar  revision[MAX_VALUE];
IGRchar  part_type[MAX_VALUE];
IGRchar  usage_id[MAX_VALUE];
IGRchar  quantity[MAX_VALUE];
IGRchar  child_no[MAX_VALUE];
IGRchar  tag_no[MAX_VALUE];
IGRchar  serial[MAX_VALUE];
IGRchar  attach_flag[MAX_VALUE];
IGRchar  view_name[MAX_VALUE];
IGRchar  name[MAX_VALUE];
IGRchar  incl_asm[MAX_VALUE];
IGRshort ATTACHED;
IGRshort GRAPHIC;
IGRshort POSITIONED;
IGRshort background;
IGRchar  **attributes;
IGRchar  **values;
IGRint   *attribute_type;
IGRint   attribute_count;
IGRmatrix matrix;
IGRmatrix rot_matrix;
struct GRobj_env GRpart_objects[1];
struct PDUpoint  origin_pt;
struct PDUpoint  x_axis_pt;
struct PDUpoint  y_axis_pt;
IGRpoint         origin;
IGRpoint         x_point;
IGRpoint         y_point;
IGRint           four;
IGRint           num_objects;
IGRint           own_index[1];
struct  GRinquire_list  ref_list[2];
IGRboolean       pass_on;
IGRint           size;
IGRchar          ref_filename[DI_PATH_MAX];
IGRchar          part_dir[DI_PATH_MAX];
IGRchar          assy_path[DI_PATH_MAX];
IGRchar          tag_dir[DI_PATH_MAX];
IGRchar          child_dir[DI_PATH_MAX];
IGRchar          attach_info_dir[DI_PATH_MAX];
IGRchar          part_no[DI_PATH_MAX];
FILE             *pdu_debug_file;
IGRchar          *child_seed;
IGRchar          *tag_seed;
IGRchar          *seed_file;
IGRchar          src_path[DI_PATH_MAX];
IGRchar          dst_path[DI_PATH_MAX];
IGRchar          *copyOS_path;
IGRint           ret_status;
IGRchar          *tag_no_value;
IGRchar          *mac_tag_no_value;
IGRchar          *child_no_value;
IGRint           count;
IGRchar          **entries;
IGRint           found;


IGRdouble	fence1[3],	/* first fence point */
		fence2[3],	/* second fence point */
		maxpnt[3],	/* maximum boundary values of fence */
		minpnt[3],	/* minimum boundary values of fence */
                save_group[3],
		view[3];	/* used for view input */
GRobj		windowid;
GRspacenum	windowos;
GRobj		my_elem;
IGRshort	my_osnum;
IGRdouble	my_point;
IGRshort	store_display;
IGRshort	store_attach;

/* declarations for fence operations */
GRobj		FENCE_ID;
IGRint		world, mode;
IGRdouble	fence_range[6];
struct GRmd_env	module_env;
struct GRid	fence;

/* ********	BEGIN	********
 * PDU 2.4. Testing 'topdown' command through a driver. Some parts of code needs to avoided.
 * Using constant TEST for this purpose.
 */

#define	TEST

/* ********	END	******** */

#define	DispDgnOptsForm()		\
{					\
	PDU_command = 0;		\
	PDUdisplay_design_form();	\
}


#define MyFree(pointer)			\
{					\
	free ((char *) pointer);	\
	pointer = NULL;			\
}	
