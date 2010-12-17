	.file	"PDUcatalogs.s"
#
# Begin stubs for:  PDUcopy_cat.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 99, 97, 116, 97, 108, 111
	.byte	103, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 99, 111, 112, 121, 95, 99, 97
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUcreate_like_catalog
_PDUcreate_like_catalog:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUcreate_like_catalog

	.globl	_PDUmerge_copycat_buffers
_PDUmerge_copycat_buffers:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUmerge_copycat_buffers
#
# Begin stubs for:  PDUcreat_cat.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 99, 114, 101, 97, 116, 95, 99
	.byte	97, 116, 46, 111, 0
	.text

	.globl	_PDUcreate_catalog
_PDUcreate_catalog:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUcreate_catalog
#
# Begin stubs for:  PDUdel_cat.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 108, 95, 99, 97, 116
	.byte	46, 111, 0
	.text

	.globl	_PDUdelete_catalog
_PDUdelete_catalog:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUdelete_catalog
#
# Begin stubs for:  PDUdyn_attr.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 100, 121, 110, 95, 97, 116, 116
	.byte	114, 46, 111, 0
	.text

	.globl	_PDUcreate_dynamic_attr_buffr
_PDUcreate_dynamic_attr_buffr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcreate_dynamic_attr_buffr

	.globl	_PDUcreate_new_dynamic_attr_buffr
_PDUcreate_new_dynamic_attr_buffr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcreate_new_dynamic_attr_buffr
#
# Begin stubs for:  PDUmod_cat.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 109, 111, 100, 95, 99, 97, 116
	.byte	46, 111, 0
	.text

	.globl	_PDUmodify_catalog
_PDUmodify_catalog:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUmodify_catalog
#
# Begin stubs for:  PDUcat_name.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 85, 99, 97, 116, 95, 110, 97, 109
	.byte	101, 46, 111, 0
	.text

	.globl	_cat_name_notification_routine
_cat_name_notification_routine:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_cat_name_notification_routine

	.globl	_PDUcheck_catalog_char
_PDUcheck_catalog_char:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_catalog_char

	.globl	_PDUfill_in_class
_PDUfill_in_class:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUfill_in_class

	.globl	_PDUget_classification_scheme
_PDUget_classification_scheme:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUget_classification_scheme

	.globl	_PDUload_classification
_PDUload_classification:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUload_classification

	.globl	_PDUprocess_selected_pulldown_value
_PDUprocess_selected_pulldown_value:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUprocess_selected_pulldown_value

	.globl	_PDUcheck_catalog_template
_PDUcheck_catalog_template:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_catalog_template

	.globl	_cat_name_form
_cat_name_form:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_cat_name_form

	.globl	_PDUcatalog_name_form
_PDUcatalog_name_form:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcatalog_name_form

	.globl	_PDUcheck_catalog_commands
_PDUcheck_catalog_commands:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_catalog_commands

	.globl	_PDUcheck_for_class
_PDUcheck_for_class:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_for_class

	.globl	_PDUget_classification_for_listing
_PDUget_classification_for_listing:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUget_classification_for_listing
#
# Begin stubs for:  PDUcat_attr.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 85, 99, 97, 116, 95, 97, 116, 116
	.byte	114, 46, 111, 0
	.text

	.globl	_cat_attr_notification_routine
_cat_attr_notification_routine:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_cat_attr_notification_routine

	.globl	_PDUcheck_if_datatype
_PDUcheck_if_datatype:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUcheck_if_datatype

	.globl	_PDUvalidate_default_in_range
_PDUvalidate_default_in_range:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUvalidate_default_in_range

	.globl	_PDUvalidate_default_in_list
_PDUvalidate_default_in_list:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUvalidate_default_in_list

	.globl	_PDUfill_in_mcf
_PDUfill_in_mcf:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUfill_in_mcf

	.globl	_PDUupdate_attr_buffer
_PDUupdate_attr_buffer:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUupdate_attr_buffer

	.globl	_PDUupdate_attr_form
_PDUupdate_attr_form:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUupdate_attr_form

	.globl	_PDUadd_attribute
_PDUadd_attribute:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUadd_attribute

	.globl	_PDUchange_attribute
_PDUchange_attribute:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUchange_attribute

	.globl	_catalog_attr_form
_catalog_attr_form:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_catalog_attr_form

	.globl	_PDUload_search_dyntable_bufr
_PDUload_search_dyntable_bufr:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUload_search_dyntable_bufr

	.globl	_PDUcatalog_attr_form
_PDUcatalog_attr_form:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUcatalog_attr_form
#
# Begin stubs for:  PDUvalidate.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 85, 118, 97, 108, 105, 100, 97, 116
	.byte	101, 46, 111, 0
	.text

	.globl	_PDUvalidate_value
_PDUvalidate_value:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUvalidate_value

	.globl	_PDUvalidate_dyn_value
_PDUvalidate_dyn_value:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUvalidate_dyn_value

	.globl	_PDUcheck_if_change_toggles
_PDUcheck_if_change_toggles:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUcheck_if_change_toggles

	.globl	_PDUcheck_if_change_datatype
_PDUcheck_if_change_datatype:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUcheck_if_change_datatype
#
# Begin stubs for:  PDUbuff.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 85, 98, 117, 102, 102, 46, 111, 0
	.text

	.globl	_PDUformat_list_buffer
_PDUformat_list_buffer:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_list_buffer

	.globl	_PDUfind_attr_by_synonym
_PDUfind_attr_by_synonym:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUfind_attr_by_synonym

	.globl	_PDUfind_dyn_attr_by_synonym
_PDUfind_dyn_attr_by_synonym:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUfind_dyn_attr_by_synonym

	.globl	_PDUformat_classification_buffer
_PDUformat_classification_buffer:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_classification_buffer

	.globl	_PDUformat_cat_class_bufr
_PDUformat_cat_class_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_cat_class_bufr

	.globl	_PDUformat_parameter_buffer
_PDUformat_parameter_buffer:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_parameter_buffer

	.globl	_PDUformat_macro_buffer
_PDUformat_macro_buffer:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_macro_buffer

	.globl	_PDUformat_search_dyntable_bufr
_PDUformat_search_dyntable_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_search_dyntable_bufr

	.globl	_PDUformat_delete_part_bufr
_PDUformat_delete_part_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_delete_part_bufr

	.globl	_PDUformat_status_bufr
_PDUformat_status_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_status_bufr

	.globl	_PDUformat_macro_bufr
_PDUformat_macro_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_macro_bufr

	.globl	_PDUformat_macrolib_copy_bufr
_PDUformat_macrolib_copy_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_macrolib_copy_bufr

	.globl	_PDUformat_os_parts_bufr
_PDUformat_os_parts_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_os_parts_bufr

	.globl	_PDUformat_function_bufr
_PDUformat_function_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_function_bufr

	.globl	_PDUformat_catalog_list_bufr
_PDUformat_catalog_list_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_catalog_list_bufr

	.globl	_PDUformat_define_support_lib_bufr
_PDUformat_define_support_lib_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_define_support_lib_bufr

	.globl	_PDUformat_update_parm_parts_bufr
_PDUformat_update_parm_parts_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUformat_update_parm_parts_bufr
#
# Begin stubs for:  PDUcommands.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 85, 99, 111, 109, 109, 97, 110, 100
	.byte	115, 46, 111, 0
	.text

	.globl	_PDUvalidate_access
_PDUvalidate_access:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUvalidate_access
#
# Begin stubs for:  PDUfrm_tools.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 85, 102, 114, 109, 95, 116, 111, 111
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_PDUget_catalog_buffers
_PDUget_catalog_buffers:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUget_catalog_buffers

	.globl	_PDUsort_by_order
_PDUsort_by_order:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUsort_by_order

	.globl	_PDUcheck_if_attribute_already_created
_PDUcheck_if_attribute_already_created:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcheck_if_attribute_already_created

	.globl	_PDUconvert_parametric_datatype
_PDUconvert_parametric_datatype:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUconvert_parametric_datatype

	.globl	_PDUconvert_to_iotype
_PDUconvert_to_iotype:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUconvert_to_iotype

	.globl	_PDUget_catalog_description
_PDUget_catalog_description:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUget_catalog_description

	.globl	_PDUcreate_class_and_catalog_bufr
_PDUcreate_class_and_catalog_bufr:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcreate_class_and_catalog_bufr

	.globl	_PDUcreate_list_of_cat_attributes
_PDUcreate_list_of_cat_attributes:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcreate_list_of_cat_attributes

	.globl	_PDUget_filename_for_part
_PDUget_filename_for_part:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUget_filename_for_part

	.globl	_PDUget_parttype
_PDUget_parttype:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUget_parttype

	.globl	_PDUcreate_dynamic_arrays
_PDUcreate_dynamic_arrays:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcreate_dynamic_arrays

	.globl	_PDUcleanup_refresh
_PDUcleanup_refresh:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcleanup_refresh
#
# Begin stubs for:  PDUparm_form.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 109, 95, 102, 111
	.byte	114, 109, 46, 111, 0
	.text

	.globl	_parm_cat_notification_routine
_parm_cat_notification_routine:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_parm_cat_notification_routine

	.globl	_PDUload_parametric_catalog_form
_PDUload_parametric_catalog_form:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUload_parametric_catalog_form

	.globl	_PDUchange_parameters
_PDUchange_parameters:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUchange_parameters

	.globl	_parametric_catalog_form
_parametric_catalog_form:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_parametric_catalog_form

	.globl	_PDUparametric_catalog_form
_PDUparametric_catalog_form:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUparametric_catalog_form

	.globl	_PDUload_parametric_attributes
_PDUload_parametric_attributes:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUload_parametric_attributes

	.globl	_PDUload_macro_parameters
_PDUload_macro_parameters:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUload_macro_parameters

	.globl	_PDUload_map_buffer
_PDUload_map_buffer:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUload_map_buffer

	.globl	_PDUupdate_parametric_catalog_form
_PDUupdate_parametric_catalog_form:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUupdate_parametric_catalog_form

	.globl	_PDUmodify_parametric_synonym
_PDUmodify_parametric_synonym:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUmodify_parametric_synonym
#
# Begin stubs for:  PDUparm_part.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 109, 95, 112, 97
	.byte	114, 116, 46, 111, 0
	.text

	.globl	_parm_part_notification_routine
_parm_part_notification_routine:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_parm_part_notification_routine

	.globl	_PDUupdate_class_buffer
_PDUupdate_class_buffer:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUupdate_class_buffer

	.globl	_PDUload_data_into_mcf
_PDUload_data_into_mcf:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUload_data_into_mcf

	.globl	_PDUget_parametric_part_attributes
_PDUget_parametric_part_attributes:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUget_parametric_part_attributes

	.globl	_PDUprocess_move_to_next_state
_PDUprocess_move_to_next_state:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUprocess_move_to_next_state

	.globl	_PDUload_parametric_part_bufr
_PDUload_parametric_part_bufr:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUload_parametric_part_bufr

	.globl	_PDUcheck_all_parametric_parts_exist
_PDUcheck_all_parametric_parts_exist:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUcheck_all_parametric_parts_exist

	.globl	_PDUcheck_all_parametric_parts_dup
_PDUcheck_all_parametric_parts_dup:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUcheck_all_parametric_parts_dup

	.globl	_PDUload_mod_parametric_part_bufr
_PDUload_mod_parametric_part_bufr:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUload_mod_parametric_part_bufr

	.globl	_PDUextract_refresh_from_mcf
_PDUextract_refresh_from_mcf:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUextract_refresh_from_mcf

	.globl	_PDUdisplay_where_used
_PDUdisplay_where_used:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUdisplay_where_used

	.globl	_PDUload_deleted_parts
_PDUload_deleted_parts:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUload_deleted_parts

	.globl	_PDUadd_row_with_defaults
_PDUadd_row_with_defaults:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUadd_row_with_defaults

	.globl	_PDUcheck_if_catalog
_PDUcheck_if_catalog:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUcheck_if_catalog

	.globl	_PDUprocess_class_pulldown
_PDUprocess_class_pulldown:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUprocess_class_pulldown

	.globl	_parametric_part_form
_parametric_part_form:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_parametric_part_form

	.globl	_PDUparametric_part_form
_PDUparametric_part_form:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUparametric_part_form

	.globl	_PDUload_delete_parts_bufr
_PDUload_delete_parts_bufr:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUload_delete_parts_bufr

	.globl	_PDUload_parametric_parts_after_select
_PDUload_parametric_parts_after_select:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUload_parametric_parts_after_select

	.globl	_PDUfinish_parametric_move_to_next_state
_PDUfinish_parametric_move_to_next_state:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUfinish_parametric_move_to_next_state

	.globl	_PDUupdate_parmpart_function_value
_PDUupdate_parmpart_function_value:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUupdate_parmpart_function_value
#
# Begin stubs for:  PDUdef_lib.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 102, 95, 108, 105, 98
	.byte	46, 111, 0
	.text

	.globl	_define_lib_notification_routine
_define_lib_notification_routine:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_define_lib_notification_routine

	.globl	_PDUload_support_lib_bufr
_PDUload_support_lib_bufr:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUload_support_lib_bufr

	.globl	_PDUcheck_for_mcf_select
_PDUcheck_for_mcf_select:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUcheck_for_mcf_select

	.globl	_PDUadd_define_library
_PDUadd_define_library:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUadd_define_library

	.globl	_PDUload_define_support_library_mcf
_PDUload_define_support_library_mcf:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUload_define_support_library_mcf

	.globl	_PDUdelete_support_library
_PDUdelete_support_library:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdelete_support_library

	.globl	_define_lib_form
_define_lib_form:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_define_lib_form

	.globl	_PDUdefine_library_form
_PDUdefine_library_form:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdefine_library_form

	.globl	_PDUdefine_support_update
_PDUdefine_support_update:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdefine_support_update
#
# Begin stubs for:  PDUcat_list.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	80, 68, 85, 99, 97, 116, 95, 108, 105, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_cat_list_notification_routine
_cat_list_notification_routine:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_cat_list_notification_routine

	.globl	_PDUclass_cat_list_form
_PDUclass_cat_list_form:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUclass_cat_list_form
#
# Begin stubs for:  PDUcatapi.o
#
	.data
	.align	4
.F16:	.long	0x00000700
	.byte	80, 68, 85, 99, 97, 116, 97, 112, 105, 46
	.byte	111, 0
	.text

	.globl	_PDUcheck_for_reserved_words
_PDUcheck_for_reserved_words:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUcheck_for_reserved_words

	.globl	_PDUprepare_load_attribute_structure
_PDUprepare_load_attribute_structure:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUprepare_load_attribute_structure

	.globl	_PDUprepare_free_attribute_structure
_PDUprepare_free_attribute_structure:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUprepare_free_attribute_structure

	.globl	_PDUadd_static_attributes
_PDUadd_static_attributes:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUadd_static_attributes

	.globl	_PDUadd_dynamic_attributes
_PDUadd_dynamic_attributes:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUadd_dynamic_attributes

	.globl	_PDUmadd_attribute_defaults
_PDUmadd_attribute_defaults:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUmadd_attribute_defaults
#
# Begin stubs for:  PMapi_cat.o
#
	.data
	.align	4
.F17:	.long	0x00000700
	.byte	80, 77, 97, 112, 105, 95, 99, 97, 116, 46
	.byte	111, 0
	.text

	.globl	_pdmoCreateCatalog
_pdmoCreateCatalog:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_pdmoCreateCatalog

	.globl	_PDUsort_by_order
	.globl	_PDU_attr_name
	.globl	_Help_topic
	.globl	_pdu_ep_stg_bufr_flag
	.globl	_PDUdefine_library_form
	.globl	_end_np_parttype_btn_flag
	.globl	_FIf_erase
	.globl	_PDU_parm_cat
	.globl	_PDUconvert_to_iotype
	.globl	_PDMcheck_for_view
	.globl	_PDU_datatype
	.globl	_PDU_active_list
	.globl	_PDUvalid_timestamp
	.globl	_pdu_hold_stg_bufr_flag
	.globl	_PDUexternal
	.globl	_PDUmcf_list_form
	.globl	_PDU_view
	.globl	_end_ep_desc_btn_flag
	.globl	_PDUcheck_if_change_toggles
	.globl	_PDMrdelete_catalog
	.globl	_end_ep_desc_fld_flag
	.globl	_MEMopen
	.globl	_PDUprint_PDUattr_list
	.globl	_strcpy
	.globl	_PDU_dynamic_table
	.globl	_PDU_save_attr_bufr
	.globl	_user
	.globl	_bufr_flag
	.globl	_PDU_required_attr
	.globl	_PDU_cat_description
	.globl	_PDUprepare_queue
	.globl	_PDMmove_parametric_parts_to_next_state
	.globl	_PDUvalid_part_type
	.globl	_FIf_set_location
	.globl	_PDUep_proj_fld
	.globl	_PDM_debug_on
	.globl	_PDMprepare_change_view_catalog
	.globl	_PDUvalid_catalog
	.globl	_PDU_cat_name_display
	.globl	_PDMcreate_parametric_catalog
	.globl	_SelectOrPlacePart
	.globl	_PDU_sketch_file
	.globl	_PDMdelete_parametric_catalog
	.globl	_PDU_func_buffer
	.globl	_PDMcreate_catalog
	.globl	_FIg_set_state_off
	.globl	_PDMget_pt_desc
	.globl	_FIfld_get_mode
	.globl	_PDUvalidate_data_value
	.globl	_PDUprocess_pulldown_list
	.globl	_states_bufr
	.globl	_PDU_cat_attr_display
	.globl	_PDU_form_id
	.globl	_PDMvalidate_user_access
	.globl	_PDMadd_parametric_part
	.globl	_FIg_get_location
	.globl	_PDUupdate_data_buffer
	.globl	_PDUvalid_attr
	.globl	_PDUformat_macro_buffer
	.globl	_PDUformat_cat_class_bufr
	.globl	_PDUformat_delete_part_bufr
	.globl	_malloc
	.globl	_PDMget_assembly_structure
	.globl	_PDU_dyn_attr
	.globl	_PDU_loc_attr
	.globl	_FIfld_set_max_num_rows
	.globl	_PDUget_catalog_buffers
	.globl	_free
	.globl	_FIfld_delete_rows
	.globl	_min_value
	.globl	_FImcf_get_active_col
	.globl	_MEMwrite
	.globl	_GRproc_pull_down_list
	.globl	_PDUadd_dynamic_attributes
	.globl	_PDUsetup_buffer_list
	.globl	_PDU_macro_dyn_list
	.globl	_PDU_cat_func_bufr
	.globl	_PDUcreate_class_and_catalog_bufr
	.globl	_PDU_local_perm_window
	.globl	_FIfld_get_select
	.globl	_PDUbufr_to_form
	.globl	_end_ep_rev_btn_flag
	.globl	_pdu_hold_acl_bufr_flag
	.globl	_PDMvalidate_parametric_part
	.globl	_PDUvalidate_function
	.globl	_PDUfind_col_in_buffer
	.globl	_PDUvalidate_access
	.globl	_PDUtranslate_UMS_message
	.globl	_PDMquery_catalog_type
	.globl	_PDUcheck_if_change_datatype
	.globl	_PDMquery_lower_case_catalogname
	.globl	_PDUfind_attr_in_buffer
	.globl	_PDMget_trans
	.globl	_PDUsetup_struct_fields
	.globl	_PDMparts_listing
	.globl	_FIg_display
	.globl	_PDUload_parametric_attributes
	.globl	_FImcf_get_num_cols
	.globl	_PDU_cat_attr_create
	.globl	_FIf_new
	.globl	_PDMdefine_support_libraries
	.globl	_PDU_cat_list_created
	.globl	_PDUmessage_trans
	.globl	_PDU_cat_name_create
	.globl	_PDUvalidate_synonym_is_unique
	.globl	_PDU_value_pulldown
	.globl	_PDU_selected_rows
	.globl	_max_value
	.globl	_PDU_cat_class_bufr
	.globl	_PDUvalid_synonym
	.globl	_PDUvalidate_dyn_attr_uniqueness
	.globl	_PDMget_dynamic_attributes
	.globl	_end_ep_part_fld_flag
	.globl	_PDMget_class_of_cat
	.globl	_PDUbufr_to_mcf
	.globl	_MEMwrite_format
	.globl	_PDMrcreate_catalog
	.globl	_PDU_cat_list
	.globl	_PDMget_filenames
	.globl	_PDU_store_catalog
	.globl	_PDMcreate_view_catalog
	.globl	_PDU_synonym
	.globl	_PDMget_list_for_modify
	.globl	_GRchange_pull_down_text
	.globl	_PDMdebug_on
	.globl	_PDU_DEBUG_FILE
	.globl	_PDUinitialize_help
	.globl	_PDU_command
	.globl	_PDMget_table_attributes
	.globl	_PDUget_catalog_description
	.globl	_strncmp
	.globl	_storage
	.globl	_PDU_list_size
	.globl	_PDU_cat_list_displayed
	.globl	_PDUload_macro_parameters
	.globl	_PDUvalid_datatype
	.globl	_PDU_macro_buffer
	.globl	_PDMget_macro_parameters
	.globl	_PDUget_col_number
	.globl	_NFMRtic_it
	.globl	_FIg_set_state_on
	.globl	_PDUcheck_for_function
	.globl	_PDMchange_view_catalog
	.globl	_PDMprepare_change_parametric_catalog
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUep_proj_btn
	.globl	_FImcf_insert_col
	.globl	_PDUadd_buffer_string
	.globl	_PDU_cat_data
	.globl	_MEMreset_buffer_no
	.globl	_PDU_dyn_list
	.globl	_end_np_part_btn_flag
	.globl	_PDUget_buffer_col
	.globl	_FIf_cvrt_to_perm_win
	.globl	_strlen
	.globl	_PDMcatalog_acls
	.globl	_end_np_cat_btn_flag
	.globl	_PDUclass_cat_list_form
	.globl	_PDUcatalog_attr_form
	.globl	_PDU_tempcat_pulldown
	.globl	_GRdelete_pull_down_list
	.globl	_FIfld_set_mode
	.globl	_PDU_parm_attr_bufr
	.globl	_PDU_num_temp
	.globl	_PDUformat_search_dyntable_bufr
	.globl	_PDUvalidate_value
	.globl	__pdm_status
	.globl	_FIfld_set_attr
	.globl	_PDUsingle_list_form
	.globl	_PDMdelete_parametric_parts
	.globl	_PDMquery_classification
	.globl	_PDUep_cat_btn
	.globl	_PDMshow_catalog_acls
	.globl	_PDMupdate_parametric_parts
	.globl	_strcmp
	.globl	_UI_prompt
	.globl	_PDMquery_dynamic_table_information
	.globl	_FIfld_set_active_row
	.globl	_forms
	.globl	_PDU_macro_catalog
	.globl	_FIf_set_orig_coord
	.globl	_PDU_assy_catalog
	.globl	_PDUvalid_number
	.globl	_PDUdismiss_subforms
	.globl	_FIg_disable
	.globl	_PDUformat_catalog_list_bufr
	.globl	_FIfld_get_max_num_rows
	.globl	_PDMrmodify_catalog
	.globl	_memset
	.globl	_PDUformat_function_bufr
	.globl	_FIfld_pos_cursor
	.globl	_PDU_macro_name
	.globl	_PDMquery_part_type
	.globl	_PDUsetup_popup_list
	.globl	_PDMmap_attribute_functions
	.globl	_PDMchange_parametric_catalog
	.globl	_sort_data
	.globl	_strchr
	.globl	_PDUmerge_copycat_buffers
	.globl	_end_move_to_state_btn_flag
	.globl	_FIg_set_text
	.globl	_FIfld_get_num_rows
	.globl	_PDMget_usageid_cat
	.globl	_FIg_erase
	.globl	_PDU_main_form_cat
	.globl	_PDUsetup_single_buffer
	.globl	_PDMprepare_view_catalog_creation
	.globl	_PDU_validate_access
	.globl	_PDU_popup_list_type
	.globl	_PDUparametric_catalog_form
	.globl	_pdu_ep_acl_bufr_flag
	.globl	_PDMdelete_view_catalog
	.globl	_PDUvalid_dynamic_attr
	.globl	_FIfld_get_attr
	.globl	_PDUcreate_dynamic_attr_buffr
	.globl	_PDUload_exec_structure
	.globl	_PDMdebug
	.globl	_sscanf
	.globl	_PDUcatalog_name_form
	.globl	_PDUcheck_catalog_commands
	.globl	_PDU_ep_stg_bufr
	.globl	_PDMsget_table_attributes
	.globl	_PDU_value_list
	.globl	_PDU_gadget_labels
	.globl	_PDU_catalog_pulldown
	.globl	_PDMsget_table_data
	.globl	_PDU_states_bufr
	.globl	_PDUcheck_for_class
	.globl	_PDUcheck_if_attribute_already_created
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_pull_main
	.globl	_FIf_delete
	.globl	_FImcf_delete_col
	.globl	_PDUformat_classification_buffer
	.globl	_PDU_cat_atr
	.globl	_PDUbufr_to_form_fields
	.globl	_scanf
	.globl	_MEMclose
	.globl	_PDUfind_attr_by_synonym
	.globl	_PDMquery_attribute_functions
	.globl	_PDMset_to_state
	.globl	_PDU_parm_data_bufr
	.globl	_PDU_loc_data
	.globl	_PDUedit_macro_library
	.globl	_PDMstore_parameters
	.globl	_PDUcheck_for_reserved_words
	.globl	_FIfld_set_num_rows
	.globl	_PDU_macro_dyn_num
	.globl	_PDUformat_list_buffer
	.globl	_PDU_load_assy
	.globl	_PDU_default_usageid
	.globl	_FIfld_insert_blank_row
	.globl	_PDU_extadmin
	.globl	_PDU_class_level
	.globl	_PDUadd_static_attributes
	.globl	_refresh
	.globl	_PDU_change_param_mode
	.globl	_PDU_perm_window
	.globl	_PDU_parameter_buffer
	.globl	_order_no
	.globl	_PDU_ret_bufr
	.globl	_FIfld_get_text
	.globl	_PDU_loc_list
	.globl	_PDU_template_catalog
	.globl	_PDU_cat_aclno
	.globl	_PDUfree_string_array
	.globl	_PDU_new_param_mode
	.globl	_PDU_macro_library
	.globl	_PDUmodify_parametric_synonym
	.globl	_PDUvalid_smallint
	.globl	_PDMmap_catalog_macro
	.globl	__pdm_debug
	.globl	_MEMwrite_data
	.globl	_FIg_get_state
	.globl	_sprintf
	.globl	_PDU_mcf_list_created
	.globl	_PDMverify_catalog
	.globl	_PDUformat_update_parm_parts_bufr
	.globl	_FIg_enable
	.globl	_PDMpopulate_attribute_info
	.globl	_PDUsetup_buffer
	.globl	_PDMstore_classification
	.globl	_PDUget_keyin
	.globl	_end_ep_cat_btn_flag
	.globl	_PDUverify_file
	.globl	_PDUcheck_char
	.globl	_PDU_parm_list_bufr
	.globl	_PDUmadd_attribute_defaults
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_GRcreate_pull_down_list
	.globl	_PDU_check_file_refresh
	.globl	_PDU_topdown_perm_window
	.globl	_PDUload_map_buffer
	.globl	_PDU_refresh_gadgets
	.globl	_PDU_query_class_bufr
	.globl	_FI_msg_box
	.globl	_PDU_hold_stg_bufr
	.globl	_PDUmessage
	.globl	_FIf_display
	.globl	_PDUformat_define_support_lib_bufr
	.globl	_PDUtranslate_message
	.globl	_FIg_reset
	.globl	_PDUvalid_string
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_PDU_update_struct
	.globl	_PDU_where_used_perm_window
	.globl	_PDUformat_parameter_buffer
	.globl	_printf
	.globl	_FIfld_set_text
	.globl	_PDU_list_cat
	.globl	_FImcf_set_active_col
	.globl	_MEMno_buffers
	.globl	_FIfld_set_select
	.globl	_PDMsearch_parts_in_catalog
	.globl	_PDU_message
	.globl	_PDUis_maclib_writable
	.globl	_PDMmove_functions
	.globl	_PDU_active_button
	.globl	_PDUsearch_part_list
	.globl	_FImcf_set_scroll_link
	.globl	_PDU_cat_aclname
	.globl	_end_ep_proj_btn_flag
	.globl	_acl_bufr
	.globl	_PDMdyntable_for_catalog
	.globl	_PDMshow_catalogs
	.globl	_PDUconvert_parametric_datatype
	.globl	_PDMget_table_data
	.globl	_PDU_macro_partrev
	.globl	_PDUupdate_parm_data_buffer
	.globl	_PDUrefresh_local_files_form
	.globl	_end_ep_part_btn_flag
	.globl	_PDUsetup_form_fields
	.globl	_MEMappend
	.globl	_PDU_checkin_lib
	.globl	_PDU_dyn_data
	.globl	_PDU_default_value
	.globl	_PDUget_classification_for_listing
	.globl	_sort_attr
	.globl	_PDU_macro_partid
