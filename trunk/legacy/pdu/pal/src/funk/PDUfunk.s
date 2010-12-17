	.file	"PDUfunk.s"
#
# Begin stubs for:  GRpuldwnlst.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 112, 97, 108, 47, 115, 114
	.byte	99, 47, 102, 117, 110, 107, 0
	.align	4
.F1:	.long	0x00000700
	.byte	71, 82, 112, 117, 108, 100, 119, 110, 108, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_SGcreate_pull_down_list
_SGcreate_pull_down_list:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_SGcreate_pull_down_list
#
# Begin stubs for:  PDMClsCats.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 67, 108, 115, 67, 97, 116, 115
	.byte	46, 111, 0
	.text

	.globl	_DispClsAndCtlgs
_DispClsAndCtlgs:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_DispClsAndCtlgs
#
# Begin stubs for:  PDMpdmparams.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 112, 100, 109, 112, 97, 114, 97
	.byte	109, 115, 46, 111, 0
	.text

	.globl	_GetStatAndDynAttribs
_GetStatAndDynAttribs:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_GetStatAndDynAttribs
#
# Begin stubs for:  PLM_functs.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 76, 77, 95, 102, 117, 110, 99, 116, 115
	.byte	46, 111, 0
	.text

	.globl	_init_forms
_init_forms:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_init_forms

	.globl	_exp_list_notification
_exp_list_notification:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_exp_list_notification

	.globl	_add_to_puldwn_list
_add_to_puldwn_list:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_add_to_puldwn_list

	.globl	_display_few
_display_few:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_display_few

	.globl	_set_table_field
_set_table_field:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_set_table_field

	.globl	_GetSelectedRow
_GetSelectedRow:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_GetSelectedRow

	.globl	_get_row_from_mcf
_get_row_from_mcf:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_get_row_from_mcf

	.globl	_set_active_form_ptr
_set_active_form_ptr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_set_active_form_ptr

	.globl	_get_active_form_ptr
_get_active_form_ptr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_get_active_form_ptr

	.globl	_set_sub_form_params
_set_sub_form_params:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_set_sub_form_params

	.globl	_reset_forms
_reset_forms:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_reset_forms

	.globl	_display_attribs
_display_attribs:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_display_attribs

	.globl	_remove_path
_remove_path:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_remove_path

	.globl	_from_cat_to_work_units
_from_cat_to_work_units:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_from_cat_to_work_units

	.globl	_get_conv_factor
_get_conv_factor:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_get_conv_factor

	.globl	_from_work_to_cat_units
_from_work_to_cat_units:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_from_work_to_cat_units

	.globl	_define_Aoperator
_define_Aoperator:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_define_Aoperator

	.globl	_define_Foperator
_define_Foperator:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_define_Foperator

	.globl	_input_operator
_input_operator:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_input_operator

	.globl	_warn_box
_warn_box:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_warn_box

	.globl	_warn_notification
_warn_notification:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_warn_notification

	.globl	_AddToPuldwnList
_AddToPuldwnList:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_AddToPuldwnList

	.globl	_copy_and_load_macro_lib
_copy_and_load_macro_lib:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_copy_and_load_macro_lib

	.globl	_IsLocalFileDeleted
_IsLocalFileDeleted:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_IsLocalFileDeleted

	.globl	_GetValsForAttribs
_GetValsForAttribs:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_GetValsForAttribs

	.globl	_SetCatAttribs
_SetCatAttribs:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_SetCatAttribs

	.globl	_puldwn_menu
_puldwn_menu:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_puldwn_menu

	.globl	_gname_notif
_gname_notif:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_gname_notif

	.globl	_set_sub_form_params_for_union
_set_sub_form_params_for_union:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_set_sub_form_params_for_union

	.globl	_set_table_field_for_union_or_format
_set_table_field_for_union_or_format:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_set_table_field_for_union_or_format

	.globl	_PDUcreate_dynamic_data_bufr
_PDUcreate_dynamic_data_bufr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcreate_dynamic_data_bufr

	.globl	_PDUwrite_dynamic_data_bufr
_PDUwrite_dynamic_data_bufr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUwrite_dynamic_data_bufr
#
# Begin stubs for:  parsit.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	112, 97, 114, 115, 105, 116, 46, 111, 0
	.text

	.globl	_hash
_hash:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_hash

	.globl	__lookup
__lookup:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	__lookup

	.globl	_install
_install:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_install

	.globl	_free_ptrs
_free_ptrs:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_free_ptrs

	.globl	_parse_all_expr
_parse_all_expr:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_parse_all_expr

	.globl	_parse_expr
_parse_expr:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_parse_expr

	.globl	_parsetok
_parsetok:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_parsetok
#
# Begin stubs for:  PALmodsplatr.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 65, 76, 109, 111, 100, 115, 112, 108, 97
	.byte	116, 114, 46, 111, 0
	.text

	.globl	_PALretrieve_dyn_info
_PALretrieve_dyn_info:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PALretrieve_dyn_info

	.globl	_PALset_attribute_type
_PALset_attribute_type:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PALset_attribute_type

	.globl	_PALget_coresp_col_indx
_PALget_coresp_col_indx:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PALget_coresp_col_indx

	.globl	_process_dyn_attrs_mcf
_process_dyn_attrs_mcf:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_process_dyn_attrs_mcf

	.globl	_PALall_blanks
_PALall_blanks:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PALall_blanks
#
# Begin stubs for:  PALmacintf.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 65, 76, 109, 97, 99, 105, 110, 116, 102
	.byte	46, 111, 0
	.text

	.globl	_PlprtThruMacro
_PlprtThruMacro:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PlprtThruMacro

	.globl	_AddDynattrsToColl
_AddDynattrsToColl:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_AddDynattrsToColl
#
# Begin stubs for:  PALgetfmt.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 65, 76, 103, 101, 116, 102, 109, 116, 46
	.byte	111, 0
	.text

	.globl	_search_format_notification_routine
_search_format_notification_routine:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_search_format_notification_routine

	.globl	_PALget_format
_PALget_format:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PALget_format
#
# Begin stubs for:  MOlocate.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	77, 79, 108, 111, 99, 97, 116, 101, 46, 111
	.byte	0
	.text

	.globl	_spl_highlight
_spl_highlight:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_spl_highlight

	.globl	_highlight_obj
_highlight_obj:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_highlight_obj

	.globl	_set_weight_of_plane
_set_weight_of_plane:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_set_weight_of_plane

	.globl	_plane_locate
_plane_locate:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_plane_locate
#
# Begin stubs for:  PDMchekin.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 99, 104, 101, 107, 105, 110, 46
	.byte	111, 0
	.text

	.globl	_PALchekin
_PALchekin:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PALchekin

	.globl	_get_nblines_in_dir
_get_nblines_in_dir:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_get_nblines_in_dir

	.globl	_update_part_list_bufr
_update_part_list_bufr:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_update_part_list_bufr

	.globl	_GetACrgAttribVal
_GetACrgAttribVal:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_GetACrgAttribVal

	.globl	_Process_feet_of_assbly
_Process_feet_of_assbly:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_Process_feet_of_assbly

	.globl	_GetFeetObjects
_GetFeetObjects:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_GetFeetObjects

	.globl	_UpdateGrandChild
_UpdateGrandChild:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_UpdateGrandChild

	.globl	_add_data_togrand_child
_add_data_togrand_child:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_add_data_togrand_child

	.globl	_GetFeetDesc
_GetFeetDesc:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_GetFeetDesc

	.globl	_FormatAttrBuffer
_FormatAttrBuffer:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_FormatAttrBuffer
#
# Begin stubs for:  PDMdynpar.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 77, 100, 121, 110, 112, 97, 114, 46
	.byte	111, 0
	.text

	.globl	_plane_dyn_pars
_plane_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_plane_dyn_pars

	.globl	_graph_dyn_pars
_graph_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_graph_dyn_pars

	.globl	_ref_cs_dyn_pars
_ref_cs_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_ref_cs_dyn_pars

	.globl	_get_object
_get_object:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_get_object

	.globl	_solid_dyn_pars
_solid_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_solid_dyn_pars

	.globl	_line_dyn_pars
_line_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_line_dyn_pars

	.globl	_conic_dyn_pars
_conic_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_conic_dyn_pars

	.globl	_gr_dyn_pars
_gr_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_gr_dyn_pars

	.globl	_macro_dyn_pars
_macro_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_macro_dyn_pars

	.globl	_ref_or_ci_dyn_pars
_ref_or_ci_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_ref_or_ci_dyn_pars

	.globl	_point_dyn_pars
_point_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_point_dyn_pars

	.globl	_lbs_dyn_pars
_lbs_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_lbs_dyn_pars

	.globl	_surf_dyn_pars
_surf_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_surf_dyn_pars

	.globl	_curve_dyn_pars
_curve_dyn_pars:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_curve_dyn_pars

	.globl	_locate_object
_locate_object:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_locate_object

	.globl	_PALlocate_by_keyin
_PALlocate_by_keyin:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PALlocate_by_keyin

	.globl	_PALlocate_by_datapt
_PALlocate_by_datapt:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PALlocate_by_datapt
#
# Begin stubs for:  PDMgetrle.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 77, 103, 101, 116, 114, 108, 101, 46
	.byte	111, 0
	.text

	.globl	_display_fig
_display_fig:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_display_fig

	.globl	_GetRleFileName
_GetRleFileName:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_GetRleFileName

	.globl	_copy_rlefile
_copy_rlefile:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_copy_rlefile

	.globl	_show_macro_view
_show_macro_view:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_show_macro_view

	.globl	_delete_window
_delete_window:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_delete_window

	.globl	_WaitForEvent
_WaitForEvent:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_WaitForEvent

	.globl	_PALgetcsid
_PALgetcsid:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PALgetcsid

	.globl	_PALcritfile
_PALcritfile:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PALcritfile

	.globl	_PALis_grraster
_PALis_grraster:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PALis_grraster

	.globl	_PALget_path
_PALget_path:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PALget_path
#
# Begin stubs for:  PDMplprt.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 77, 112, 108, 112, 114, 116, 46, 111
	.byte	0
	.text

	.globl	_PDUcreat_rgbox
_PDUcreat_rgbox:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUcreat_rgbox

	.globl	_add_static_attributes
_add_static_attributes:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_add_static_attributes

	.globl	_PDUis_macro_edited
_PDUis_macro_edited:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUis_macro_edited

	.globl	_PDUedit_macro
_PDUedit_macro:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUedit_macro

	.globl	_GetMacroHeaderGivenName
_GetMacroHeaderGivenName:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_GetMacroHeaderGivenName

	.globl	_change_symbology
_change_symbology:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_change_symbology

	.globl	_GetMacroType
_GetMacroType:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_GetMacroType

	.globl	_do_clean_up
_do_clean_up:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_do_clean_up

	.globl	_place_macro
_place_macro:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_place_macro

	.globl	_set_feet_symbology
_set_feet_symbology:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_set_feet_symbology

	.globl	_get_mod_info
_get_mod_info:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_get_mod_info

	.globl	_FlashMessage
_FlashMessage:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_FlashMessage

	.globl	_PALstatus_msg
_PALstatus_msg:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PALstatus_msg

	.globl	_check_obj_class
_check_obj_class:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_check_obj_class

	.globl	_define_temp_to_ACdyncol
_define_temp_to_ACdyncol:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_define_temp_to_ACdyncol

	.globl	_selection_temp_to_ACdyncol
_selection_temp_to_ACdyncol:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_selection_temp_to_ACdyncol

	.globl	_create_expression
_create_expression:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_create_expression

	.globl	_attach_macro_lib
_attach_macro_lib:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_attach_macro_lib
#
# Begin stubs for:  SelMacUtil.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	83, 101, 108, 77, 97, 99, 85, 116, 105, 108
	.byte	46, 111, 0
	.text

	.globl	_change_text_to_index
_change_text_to_index:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_change_text_to_index

	.globl	_change_index_to_text
_change_index_to_text:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_change_index_to_text

	.globl	_get_pretends_name
_get_pretends_name:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_get_pretends_name
#
# Begin stubs for:  parse_fun.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	112, 97, 114, 115, 101, 95, 102, 117, 110, 46
	.byte	111, 0
	.text

	.globl	_OLD_parse_exp_and_get_value
_OLD_parse_exp_and_get_value:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_OLD_parse_exp_and_get_value

	.globl	_remove_quotes
_remove_quotes:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_remove_quotes

	.globl	_clear_mem
_clear_mem:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_clear_mem

	.globl	_parse_exp_and_get_value
_parse_exp_and_get_value:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_parse_exp_and_get_value

	.globl	_PALevaluate_syntax
_PALevaluate_syntax:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PALevaluate_syntax

	.globl	_get_exp_objid_list
_get_exp_objid_list:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_get_exp_objid_list

	.globl	_set_directory
_set_directory:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_set_directory

	.globl	_reset_directory
_reset_directory:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_reset_directory

	.globl	_get_text_exp_value
_get_text_exp_value:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_get_text_exp_value

	.globl	_GetDefaultPlacementName
_GetDefaultPlacementName:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_GetDefaultPlacementName

	.globl	_PALusage_id_unique
_PALusage_id_unique:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PALusage_id_unique

	.globl	_PALis_expression_defined
_PALis_expression_defined:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PALis_expression_defined

	.globl	_PALis_value
_PALis_value:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PALis_value
#
# Begin stubs for:  PDMattach.o
#
	.data
	.align	4
.F16:	.long	0x00000700
	.byte	80, 68, 77, 97, 116, 116, 97, 99, 104, 46
	.byte	111, 0
	.text

	.globl	_PDMattach
_PDMattach:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMattach

	.globl	_attach_macro_libraries
_attach_macro_libraries:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_attach_macro_libraries
#
# Begin stubs for:  feet_depend.o
#
	.data
	.align	4
.F17:	.long	0x00000700
	.byte	102, 101, 101, 116, 95, 100, 101, 112, 101, 110
	.byte	100, 46, 111, 0
	.text

	.globl	_ACindex_template
_ACindex_template:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_ACindex_template

	.globl	_ACname_template
_ACname_template:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_ACname_template
#
# Begin stubs for:  PDMmodprt.o
#
	.data
	.align	4
.F18:	.long	0x00000700
	.byte	80, 68, 77, 109, 111, 100, 112, 114, 116, 46
	.byte	111, 0
	.text

	.globl	_ModifyPart
_ModifyPart:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_ModifyPart

	.globl	_memset_mac
_memset_mac:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_memset_mac

	.globl	_PALstack_events
_PALstack_events:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PALstack_events

	.globl	_PALmodprt
_PALmodprt:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PALmodprt

	.globl	_grpart_update
_grpart_update:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_grpart_update

	.globl	_GetMacroHeaderGivenGrid
_GetMacroHeaderGivenGrid:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetMacroHeaderGivenGrid

	.globl	_GetAllTheAttributes
_GetAllTheAttributes:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetAllTheAttributes

	.globl	_GetACrgAttribList
_GetACrgAttribList:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetACrgAttribList

	.globl	_ExtractDynamicAttributes
_ExtractDynamicAttributes:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_ExtractDynamicAttributes

	.globl	_mdprt_notification
_mdprt_notification:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_mdprt_notification

	.globl	_ProcessData
_ProcessData:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_ProcessData

	.globl	_Terminate
_Terminate:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_Terminate

	.globl	_set_gadgets
_set_gadgets:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_set_gadgets

	.globl	_FreeMem
_FreeMem:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_FreeMem

	.globl	_set_dynnames
_set_dynnames:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_set_dynnames

	.globl	_set_stddyn_attrval
_set_stddyn_attrval:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_set_stddyn_attrval

	.globl	_update_dynnames
_update_dynnames:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_update_dynnames

	.globl	_NewMacroSelected
_NewMacroSelected:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_NewMacroSelected

	.globl	_ProcessNewCat
_ProcessNewCat:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_ProcessNewCat

	.globl	_CreateExpForm
_CreateExpForm:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_CreateExpForm

	.globl	_InitModify
_InitModify:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_InitModify

	.globl	_GetTemp_N_AttrValues
_GetTemp_N_AttrValues:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetTemp_N_AttrValues

	.globl	_GetACdyncolExpTempls
_GetACdyncolExpTempls:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetACdyncolExpTempls

	.globl	_IsDfntMacroSelected
_IsDfntMacroSelected:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_IsDfntMacroSelected

	.globl	_GetDynAttrValsOnForm
_GetDynAttrValsOnForm:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetDynAttrValsOnForm

	.globl	_GetChildNumber
_GetChildNumber:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetChildNumber

	.globl	_CreateDynTemps
_CreateDynTemps:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_CreateDynTemps

	.globl	_GetCatAttrCriteriaAndFormat
_GetCatAttrCriteriaAndFormat:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetCatAttrCriteriaAndFormat

	.globl	_CreateTemplatesToACdyncol
_CreateTemplatesToACdyncol:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_CreateTemplatesToACdyncol

	.globl	_GetCatalogTemplateValue
_GetCatalogTemplateValue:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetCatalogTemplateValue

	.globl	_get_obj_name
_get_obj_name:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_get_obj_name

	.globl	_get_loc_obj
_get_loc_obj:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_get_loc_obj

	.globl	_HiLiteObject
_HiLiteObject:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_HiLiteObject

	.globl	_set_new_obj
_set_new_obj:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_set_new_obj

	.globl	_get_exp_name
_get_exp_name:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_get_exp_name

	.globl	_plane_dyn_params
_plane_dyn_params:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_plane_dyn_params

	.globl	_update_cat_val
_update_cat_val:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_update_cat_val

	.globl	_MODsleep
_MODsleep:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_MODsleep

	.globl	_SetActionUponAccept
_SetActionUponAccept:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_SetActionUponAccept

	.globl	_delete_grpart
_delete_grpart:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_delete_grpart

	.globl	_free_omac
_free_omac:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_free_omac

	.globl	_get_val_from_formula
_get_val_from_formula:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_get_val_from_formula

	.globl	_processgrpart
_processgrpart:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_processgrpart

	.globl	_CheckACrgAttribVal
_CheckACrgAttribVal:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_CheckACrgAttribVal

	.globl	_get_parameter_values
_get_parameter_values:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_get_parameter_values

	.globl	_GetCollsList
_GetCollsList:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_GetCollsList

	.globl	_remove_dynatr
_remove_dynatr:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_remove_dynatr

	.globl	_remove_dynval
_remove_dynval:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_remove_dynval
#
# Begin stubs for:  PDMdyncmp.o
#
	.data
	.align	4
.F19:	.long	0x00000700
	.byte	80, 68, 77, 100, 121, 110, 99, 109, 112, 46
	.byte	111, 0
	.text

	.globl	_add_attribute
_add_attribute:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_add_attribute

	.globl	_mod_attribute
_mod_attribute:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_mod_attribute

	.globl	_normal_cmpt
_normal_cmpt:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_normal_cmpt

	.globl	_stdstatic_cmpt
_stdstatic_cmpt:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_stdstatic_cmpt

	.globl	_selection_place
_selection_place:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_selection_place

	.globl	_dummy_place
_dummy_place:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_dummy_place

	.globl	_selection_compute
_selection_compute:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_selection_compute

	.globl	_GetCriteria
_GetCriteria:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_GetCriteria

	.globl	_init_select_form
_init_select_form:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_init_select_form

	.globl	_SELacc_datadata
_SELacc_datadata:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_SELacc_datadata

	.globl	_DYNdelete_form
_DYNdelete_form:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_DYNdelete_form

	.globl	_f_notification
_f_notification:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_f_notification

	.globl	_clear_ptrs
_clear_ptrs:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_clear_ptrs

	.globl	_ReadAtrsFromCols
_ReadAtrsFromCols:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_ReadAtrsFromCols

	.globl	_compute_dependents
_compute_dependents:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_compute_dependents
#
# Begin stubs for:  PDMcpyprt.o
#
	.data
	.align	4
.F20:	.long	0x00000700
	.byte	80, 68, 77, 99, 112, 121, 112, 114, 116, 46
	.byte	111, 0
	.text

	.globl	_PALcopy_part
_PALcopy_part:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PALcopy_part

	.globl	_copy_prpart
_copy_prpart:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_copy_prpart

	.globl	_copy_attribute
_copy_attribute:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_copy_attribute

	.globl	_GetNumCollections
_GetNumCollections:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_GetNumCollections

	.globl	_Make_copy
_Make_copy:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_Make_copy

	.globl	_get_acdyncol_temp
_get_acdyncol_temp:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_get_acdyncol_temp

	.globl	_GetAttrCollAndFillCollList
_GetAttrCollAndFillCollList:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_GetAttrCollAndFillCollList

	.globl	_GetMacroNameFromInstance
_GetMacroNameFromInstance:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_GetMacroNameFromInstance

	.globl	_Copy_ppart
_Copy_ppart:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_Copy_ppart

	.globl	_PALdel_part
_PALdel_part:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PALdel_part

	.globl	_delete_prpart_old
_delete_prpart_old:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_delete_prpart_old

	.globl	_delete_prpart
_delete_prpart:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_delete_prpart

	.globl	_create_newdyncol
_create_newdyncol:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_create_newdyncol
#
# Begin stubs for:  PDMmapcoll.o
#
	.data
	.align	4
.F21:	.long	0x00000700
	.byte	80, 68, 77, 109, 97, 112, 99, 111, 108, 108
	.byte	46, 111, 0
	.text

	.globl	_CreateCollections
_CreateCollections:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_CreateCollections

	.globl	_GetDyncolIndx
_GetDyncolIndx:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_GetDyncolIndx

	.globl	_GetNamedAttribValue
_GetNamedAttribValue:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_GetNamedAttribValue

	.globl	_get_temp_index
_get_temp_index:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_get_temp_index

	.globl	_GetMacroTempDesc
_GetMacroTempDesc:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_GetMacroTempDesc

	.globl	_GetNumLocatable
_GetNumLocatable:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_GetNumLocatable

	.globl	_GetOriginalMacroInfo
_GetOriginalMacroInfo:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_GetOriginalMacroInfo
#
# Begin stubs for:  ismacdef.o
#
	.data
	.align	4
.F22:	.long	0x00000700
	.byte	105, 115, 109, 97, 99, 100, 101, 102, 46, 111
	.byte	0
	.text

	.globl	_PALget_hdrs
_PALget_hdrs:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PALget_hdrs

	.globl	_PALis_mac_def_attached
_PALis_mac_def_attached:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PALis_mac_def_attached

	.comm	_def_window,8
	.comm	_dyn_attr_val,4
	.comm	_PALrlefname,20
	.comm	_PALnotification_flag,4
	.comm	_PALsortfname,40
	.comm	_cur_form_f,4
	.comm	_param_val,4
	.comm	_lmod_env,144
	.comm	_conv_factor,8
	.comm	_palresponse,4
	.comm	_cnst_list,72
	.comm	_ModifyPartForm,4
	.comm	_def_gragad,8
	.comm	_no_of_param_vals,4
	.comm	_PDM_old_dir,1023
	.comm	_lcl_dup,4
	.comm	_def_id,8
	.comm	_warning_f,4
	.comm	_def_hdr,8
	.globl	_get_acdyncol_temp
	.globl	_PDU_incl_BOM
	.globl	_OPP_OMObjSpace_class_id
	.globl	_exp_list_notification
	.globl	_ACpretend_OPP_ACfind_parent_method_index
	.globl	_PDUmacro_lib_list
	.globl	_PDUincrement_child_no
	.globl	_PALset_attribute_type
	.globl	_Help_topic
	.globl	_copy_and_load_macro_lib
	.globl	_StatAttribs
	.globl	_remove_quotes
	.globl	_FIf_erase
	.globl	_OPP_ACcpx_defn_class_id
	.globl	_FIf_set_button_intercept_routine
	.globl	_som_construct_object
	.globl	_ACpretdef_OPP_ACsconnect_method_index
	.globl	_do_global_search
	.globl	_DImkpath
	.globl	_multiple_parts
	.globl	_NDnode_OPP_NDconnect_method_index
	.globl	_PDU_default_style
	.globl	_GRvg_OPP_GRchgstyle_method_index
	.globl	_PALis_grraster
	.globl	_MacroDisplayed
	.globl	_ACdiowner_OPP_ACadd_attribute_method_index
	.globl	_FIfld_set_value
	.globl	_delete_window
	.globl	_MEMopen
	.globl	_PALgetassocpos
	.globl	_PDU_default_layer
	.globl	_format_column
	.globl	_MS_init
	.globl	_OPP_ACpretend_class_id
	.globl	_GetCatAttribs
	.globl	_OPP_GRgraphics_class_id
	.globl	_PDU_default_weight
	.globl	_GetACdyncolExpTempls
	.globl	_DynAttribTypes
	.globl	_strcpy
	.globl	_ProcessMCF
	.globl	_FIf_set_size
	.globl	_sel_row
	.globl	_user
	.globl	_get_mac_hdr
	.globl	_get_mod_info
	.globl	_PDUprepare_queue
	.globl	_FIg_set_standard_variables
	.globl	_expression_OPP_create_method_index
	.globl	_search_on_multiple_ctlgs_with_union
	.globl	_ACrg_collect_OPP_ACmod_list_attribute_method_index
	.globl	_NDnode_OPP_ASreturn_go_method_index
	.globl	_GetRleFileName
	.globl	_OPP_ACdyn_col_class_id
	.globl	_BreakupAndAddToList
	.globl	_DIpwd
	.globl	_PDU_cat_selected
	.globl	_FIf_set_location
	.globl	_grid_list
	.globl	_FImcf_get_select
	.globl	_AddStatAttrsToQuery
	.globl	_NDwait_batch
	.globl	_GetCatalogDesc
	.globl	_PDM_debug_on
	.globl	_Num_Dyn
	.globl	_PDUlist_report_buffer
	.globl	_GRgraphics_OPP_GRdisplay_method_index
	.globl	_strncpy
	.globl	_DIuntranslate
	.globl	_DynAttribs
	.globl	_NDexec_batch
	.globl	_ACrg_collect_OPP_AClist_attribute_method_index
	.globl	_FIg_get_size
	.globl	_PDU_func_buffer
	.globl	_FIg_set_state_off
	.globl	_search_list_format_attribs
	.globl	_PDU_form_id
	.globl	_get_row_from_mcf
	.globl	_EXP_create
	.globl	_GRgraphics_OPP_GRfunction_method_index
	.globl	_PDU_display_buffer
	.globl	_GetMacroHeaderGivenName
	.globl	_NDmacro_OPP_ACreturn_foot_method_index
	.globl	_GetCatTableNo
	.globl	_malloc
	.globl	_EXP_modify_by_objid
	.globl	_ASmake_source
	.globl	_DIcd
	.globl	_NULL_CHANNUM
	.globl	_FIfld_set_max_num_rows
	.globl	_PDU_auto_part_selection
	.globl	_ReadStatAttribsonForm
	.globl	_free
	.globl	_FImcf_get_active_col
	.globl	_MEMwrite
	.globl	_GRproc_pull_down_list
	.globl	_ci_macro_OPP_init_method_index
	.globl	_FIg_get_font
	.globl	_som_get_classid
	.globl	_OPP_ACci_header_class_id
	.globl	_OPP_Gexp_class_id
	.globl	_OM_GS_NULL_NEIGHBOR
	.globl	_CatNameList
	.globl	_warn_box
	.globl	_GRgraphics_OPP_GRdelete_method_index
	.globl	_expression_OPP_give_formula_method_index
	.globl	_PALMacintf
	.globl	_PALgfname
	.globl	_FImcf_get_col_size
	.globl	_PDMquery_catalog_type
	.globl	_define_Foperator
	.globl	_define_Aoperator
	.globl	_PDU_search_format_displayed
	.globl	_mdprt_notification
	.globl	_ACmacro_defn_OPP_ACtake_feet_method_index
	.globl	_ci_exec
	.globl	_DIstmocpy
	.globl	_PDUfind_attr_in_buffer
	.globl	_input_operator
	.globl	_UpdateRefreshStr
	.globl	_FIfld_set_num_vis_chars
	.globl	_PALgetcatlist
	.globl	_strtok
	.globl	_PrintRefreshInfo
	.globl	_FIg_display
	.globl	_MS_fix_type
	.globl	_FIf_new
	.globl	_ACerase_macro
	.globl	_ND_father
	.globl	_remove_brackets
	.globl	_search_union_attribs
	.globl	_som_report_error
	.globl	_update_catalog
	.globl	_PDU_activate_delete
	.globl	_FIf_reset
	.globl	_set_sub_form_params
	.globl	_stat
	.globl	_PDMquery_dynamic_attrs
	.globl	_GetNumLocatable
	.globl	_display_all
	.globl	_PDUcreat_rgbox
	.globl	_define_temp_to_ACdyncol
	.globl	__iob
	.globl	_DYNA_GRID_LIST
	.globl	_AS_to_comp
	.globl	_new_exp_Parse
	.globl	_ACcpx_defn_OPP_ACgive_temp_desc_method_index
	.globl	_PDMcr_para_ass_bufr
	.globl	_PDU_value_pulldown
	.globl	_NDnode_OPP_NDplace_method_index
	.globl	_ACindex_template
	.globl	_NDget_mod_batch
	.globl	_StatUnits
	.globl	_PDUextract_GRpart_modify_info
	.globl	_NewCatalogSelected
	.globl	_MEMwrite_format
	.globl	_RISquery
	.globl	_MAC_temp_desc
	.globl	_NDnode_OPP_NDchange_connect_method_index
	.globl	_display_fig
	.globl	_PDU_placement_type
	.globl	_PDUgetDefPlcmntName
	.globl	_PDU_part_id
	.globl	_OM_Gp_NULL_MESSAGE
	.globl	_GRvg_OPP_GRchgcolor_method_index
	.globl	_GRchange_pull_down_text
	.globl	_lab
	.globl	_PDU_DEBUG_FILE
	.globl	_PDMdebug_on
	.globl	_som_get_index
	.globl	_PDUinitialize_help
	.globl	_ViewOrTblList
	.globl	_PDU_command
	.globl	_strncmp
	.globl	_GetStatAndDynAttribs
	.globl	_storage
	.globl	_attach_macro_lib
	.globl	_OPP_ACrg_collect_class_id
	.globl	_AttrTypes
	.globl	_som_send_foreign
	.globl	_PDU_param_buffer
	.globl	_rest_on_cat_selection
	.globl	_FIg_set_state_on
	.globl	_PDUcheck_for_function
	.globl	_GRcvt_exp_to_wrk
	.globl	_FIfld_get_num_vis_chars
	.globl	_GetID_N_Compute
	.globl	_PDUep_proj_btn
	.globl	_PDUadd_buffer_string
	.globl	_MSmessage
	.globl	_PDUget_buffer_col
	.globl	_change_text_to_index
	.globl	_FIf_cvrt_to_perm_win
	.globl	_strlen
	.globl	_PDU_calling_form
	.globl	_search_on_multiple_ctlgs
	.globl	_OM_GO_current_OS_objid
	.globl	_compute_dependents
	.globl	_strcat
	.globl	_PDU_incl_ASM
	.globl	_GRdelete_pull_down_list
	.globl	__ctype
	.globl	_ACcpx_OPP_find_macro_method_index
	.globl	_ACcpx_OPP_ACattach_method_index
	.globl	_plane_locate
	.globl	_ACcpx_defn_OPP_ACgive_feet_desc_method_index
	.globl	_FIfld_set_mode
	.globl	_PDU_dyn_attr_bufr
	.globl	_LCcselect
	.globl	_GetCriteria
	.globl	_PDUvalidate_value
	.globl	_OPP_expression_class_id
	.globl	__pdm_status
	.globl	_FIfld_set_attr
	.globl	_reset_forms
	.globl	_NumAttribs
	.globl	_pull_down
	.globl	_som_make_chanselect
	.globl	_PDMquery_classification
	.globl	_PDU_replace_all_occur
	.globl	_strcmp
	.globl	_GetMacroHeaderGivenGrid
	.globl	_pdmoDeletePartOccurrence
	.globl	_SelectCatalog
	.globl	_MS_onoff
	.globl	_COm_get_option_grid
	.globl	_realloc
	.globl	_PDU_attr_value
	.globl	_set_active_form_ptr
	.globl	_PDUput_queue
	.globl	_remove_path
	.globl	_forms
	.globl	_PALRestoreRefreshInfo
	.globl	_Parse_eqn
	.globl	_NumCatalogs
	.globl	_ReadAtrsFromCols
	.globl	_PDUvalid_number
	.globl	_init_forms
	.globl	_PDU_ComputedID
	.globl	_OPP_GRgencs_class_id
	.globl	_FIg_disable
	.globl	_access
	.globl	_parse_expr
	.globl	_OPP_ACpretdef_class_id
	.globl	_NDput_mod_batch
	.globl	_OPP_GRvg_class_id
	.globl	_AttrSynonym
	.globl	_PALSaveRefreshInfo
	.globl	_memset
	.globl	_free_ptrs
	.globl	_UpdateCatPath
	.globl	_EXPsubstitute
	.globl	_PALretrieve_dyn_info
	.globl	_strchr
	.globl	_OPP_EMSsurface_class_id
	.globl	_remove_blanks
	.globl	_ACrg_collect_OPP_ACget_named_attribute_method_index
	.globl	_FIf_set_window_event_routine
	.globl	_selprt_notification
	.globl	_select_project
	.globl	_NDnode_OPP_NDget_objects_method_index
	.globl	_check_obj_class
	.globl	_ACmacro_defn_OPP_ACtake_template_method_index
	.globl	_FIg_set_text
	.globl	_process_dyn_attrs_mcf
	.globl	_RIS_box
	.globl	_FIg_erase
	.globl	_OPP_ACmacro_defn_class_id
	.globl	_fclose
	.globl	_ACmacro_defn_OPP_ACgive_upscan_method_index
	.globl	_NULL_GRID
	.globl	_s_text
	.globl	_add_attribute
	.globl	_strpbrk
	.globl	_WaitForEvent
	.globl	_OPP_ACcomplex_class_id
	.globl	_atoi
	.globl	_atof
	.globl	_GetOriginalMacroInfo
	.globl	_EXP_delete_by_name
	.globl	_ACdiowner_OPP_ACcreate_method_index
	.globl	_GetACrgAttribVal
	.globl	_som_osnum_to_oso_objid
	.globl	_create_expression
	.globl	_GetNamedAttribValue
	.globl	_sscanf
	.globl	_PDUupdate_copy_macro_lib_bufr
	.globl	_PDU_value_list
	.globl	_PDUget_parttype
	.globl	_EXP_translate_exp
	.globl	_PDU_usage_id
	.globl	_PDU_desrev_fp
	.globl	_max_rows_rtvd
	.globl	_check_CID
	.globl	_OPP_ACconst_class_id
	.globl	_PDUvalidate_dyn_data_value
	.globl	_PDUchild_dyn_buffer
	.globl	_som_get_channel_objects
	.globl	_FIfld_set_type
	.globl	_get_temp_index
	.globl	_PDU_search_format
	.globl	_switch_off_gdgs
	.globl	_to_lower
	.globl	_GRgraphics_OPP_GRgetname_method_index
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_NDnode_OPP_NDgive_structure_method_index
	.globl	_pull_main
	.globl	_FIf_delete
	.globl	_get_macro_name
	.globl	_PALlist_notify_routine
	.globl	_MEMclose
	.globl	_OM_Gw_current_OS
	.globl	_SaveCriteria
	.globl	_PDU_comm_attribs
	.globl	_OPP_NDnode_class_id
	.globl	_PDU_search_format_created
	.globl	_PDMlist_reports
	.globl	_FIf_get_size
	.globl	_calloc
	.globl	_LClocate
	.globl	_ACdisplay_macro
	.globl	_PDUget_default_usage_id
	.globl	_fprintf
	.globl	_PDUdesign_options_form
	.globl	_MS_out_msg
	.globl	_mystrcpy
	.globl	_DIfrees
	.globl	_search_common_attribs
	.globl	_COm_get_options
	.globl	_AddStdAttribsToColl
	.globl	_ACconstruct_path
	.globl	_is_a_new_entry
	.globl	_OPP_ACcpx_class_id
	.globl	_OPP_Root_class_id
	.globl	_FIfld_set_num_vis_rows
	.globl	_PALsavecrit
	.globl	_row_num
	.globl	_refresh
	.globl	_PALstatus_msg
	.globl	_ACdiowner_OPP_ACadd_attribute_by_type_method_index
	.globl	_GetMacroType
	.globl	_som_is_ancestry_valid
	.globl	_FIfld_get_text
	.globl	_OPP_ci_macro_class_id
	.globl	_PDU_dyn_data_bufr
	.globl	_UpdatePartType
	.globl	__pdm_debug
	.globl	_FIg_get_state
	.globl	_sprintf
	.globl	_OPP_nci_macro_class_id
	.globl	_GetMacroName
	.globl	_ACcpx_defn_OPP_ACgive_name_method_index
	.globl	_OPP_ACheader_class_id
	.globl	_mystrncpy
	.globl	_FIg_enable
	.globl	_ACcreate_window
	.globl	_AS_to_owner
	.globl	_FImcf_set_select
	.globl	_NULL_OBJID
	.globl	_DImain
	.globl	_parse_all_expr
	.globl	_PDUsetup_buffer
	.globl	_memcpy
	.globl	_ComputeIDAddToDynCol
	.globl	_PALchild_no
	.globl	_PDU_default_color
	.globl	_DImkdir
	.globl	_PDUverify_file
	.globl	_PDUprocess_function
	.globl	_OMObjSpace_OPP_pass_method_index
	.globl	_PALget_format
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_DItranslate
	.globl	_GRcreate_pull_down_list
	.globl	_strrchr
	.globl	_GetCollsList
	.globl	_FIg_activate
	.globl	_MAC_num_temp
	.globl	_PDU_refresh_gadgets
	.globl	_FI_msg_box
	.globl	_OPP_NDmacro_class_id
	.globl	_PDUmessage
	.globl	_FIf_display
	.globl	_PDUgenerate_child_no
	.globl	_PDUformat_buffer
	.globl	_som_get_channel_count
	.globl	_GetDyncolIndx
	.globl	_FIg_new
	.globl	_PDMcopy
	.globl	_GRgraphics_OPP_GRchgname_method_index
	.globl	_Root_OPP_delete_method_index
	.globl	_PALasfmbntevent
	.globl	_PDUtranslate_message
	.globl	_PALasfmwinevent
	.globl	_OPP_ACncpx_class_id
	.globl	_change_index_to_text
	.globl	_FIg_reset
	.globl	_validate_search_criteria_input
	.globl	_StatTypes
	.globl	_MEMprint_buffer
	.globl	_GRdpb_get
	.globl	_MEMprint_buffers
	.globl	_fgets
	.globl	_PDUsort_form
	.globl	_PALis_sort_selected
	.globl	_AttrList
	.globl	_printf
	.globl	_FIfld_set_text
	.globl	_ACpretend_OPP_ACgive_downscan_method_index
	.globl	_DPdisbyoid
	.globl	_place_macro
	.globl	_FIf_get_notification_routine
	.globl	_PDU_dyn_index
	.globl	_OPP_ACdiowner_class_id
	.globl	_insert_additional_columns
	.globl	_ACncpx_OPP_ACmplace_from_def_method_index
	.globl	_FreeArrayPtr
	.globl	_FIf_get_screen
	.globl	_NDnode_OPP_NDchg_state_method_index
	.globl	_som_get_classname
	.globl	_ACncpx_OPP_ACmplace_method_index
	.globl	_getenv
	.globl	_RestoreCriteria
	.globl	_cur_form_f
	.globl	_som_send_object
	.globl	_GRvg_OPP_GRchgweight_method_index
	.globl	_lmod_env
	.globl	_NDnode_OPP_NDdisplay_method_index
	.globl	_PDU_child_buffer
	.globl	_som_get_objid_at_index
	.globl	_Num_Stat
	.globl	_PDMmove_functions
	.globl	_GetUniqRecord
	.globl	_PDUget_param_data
	.globl	_FIf_set_attr
	.globl	_search_on_multiple_ctlgs_for_format
	.globl	_PDU_dyn_value_bufr
	.globl	_PDU_active_button
	.globl	_Get_text
	.globl	_FImcf_set_scroll_link
	.globl	_fopen
	.globl	_FIf_get_window_event_routine
	.globl	_DynAttribDesc
	.globl	_DIfast_trans
	.globl	_GetStaticAttribsAddToRgObj
	.globl	_PDMget_list_buffer
	.globl	_GRvg_OPP_GRchglevel_method_index
	.globl	_ACcomplex_OPP_ACget_other_method_index
	.globl	_display_attribs
	.globl	_MEMappend
	.globl	_PDMexec
	.globl	_selection_temp_to_ACdyncol
	.globl	_StatDesc
	.globl	_OPP_text_exp_class_id
	.globl	_DIreport_error
	.globl	_GRvg_OPP_GRgetsymb_method_index
	.globl	_Restore_save_load_buttons
