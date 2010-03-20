#target /usr/shlib/libXFI_s

#address .text 0x86400000
#address .data 0x86800000

#branch
	_FI_append_form_path			  1
	_FI_append_symbol_path			  2
	_FI_enter				  3
	_FI_forms_active			  4
	_FI_get_auto_scaling_factors		  5
	_FI_get_env				  6
	_FI_get_form				  7
	_FI_get_form_by_name			  8
	_FI_get_form_path			  9
	_FI_get_form_path_length		 10
	_FI_get_last_paint_area			 11
	_FI_get_quiet_mode			 12
	_FI_get_record_notification_routine	 13
	_FI_get_symbol_path			 14
	_FI_get_symbol_path_length		 15
	_FI_get_transition			 16
	_FI_inq_symbol_attr			 17
	_FI_load_FSfont				 18
	_FI_load_font				 19
	_FI_message_box				 20
	_FI_message_box2			 21
	_FI_modify_env				 22
	_FI_msg_box				 23
	_FI_msg_box2				 24
	_FI_process_event			 25
	_FI_process_forms			 26
	_FI_read_double				 27
	_FI_read_float				 28
	_FI_read_int				 29
	_FI_read_short				 30
	_FI_set_FSfont_path			 31
	_FI_set_auto_scaling_factors		 32
	_FI_set_charmap_path			 33
	_FI_set_font_path			 34
	_FI_set_form_path			 35
	_FI_set_keyboard_buffer			 36
	_FI_set_quiet_mode_off			 37
	_FI_set_quiet_mode_on			 38
	_FI_set_record_notification_routine	 39
	_FI_set_symbol_path			 40
	_FI_write_double			 41
	_FI_write_float				 42
	_FI_write_int				 43
	_FI_write_short				 44
	_FIbtn_get_auto_pop_up_state		 45
	_FIbtn_get_menu_status			 46
	_FIbtn_get_palette			 47
	_FIbtn_set_auto_pop_up_off		 48
	_FIbtn_set_auto_pop_up_on		 49
	_FIbtn_set_menu_status			 50
	_FIbtn_set_palette			 51
	_FIdecode				 52
	_FIdial_get_border_style		 53
	_FIdial_get_range			 54
	_FIdial_get_zero_location		 55
	_FIdial_set_border_style		 56
	_FIdial_set_range			 57
	_FIdial_set_zero_location		 58
	_FIf_collapse				 59
	_FIf_cvrt_to_perm_win			 60
	_FIf_delete				 61
	_FIf_display				 62
	_FIf_erase				 63
	_FIf_find_by_area			 64
	_FIf_find_by_point			 65
	_FIf_find_gadget			 66
	_FIf_get_GC				 67
	_FIf_get_attr				 68
	_FIf_get_button_event_routine		 69
	_FIf_get_button_intercept_routine	 70
	_FIf_get_cmd_oid_os			 71
	_FIf_get_collapse_location		 72
	_FIf_get_collapse_symbol		 73
	_FIf_get_color				 74
	_FIf_get_initial_notification_routine	 75
	_FIf_get_label				 76
	_FIf_get_location			 77
	_FIf_get_max_size			 78
	_FIf_get_min_size			 79
	_FIf_get_name				 80
	_FIf_get_next_label			 81
	_FIf_get_notification_routine		 82
	_FIf_get_orig_location			 83
	_FIf_get_orig_size			 84
	_FIf_get_scaling			 85
	_FIf_get_screen				 86
	_FIf_get_seq				 87
	_FIf_get_size				 88
	_FIf_get_start_seq			 89
	_FIf_get_user_pointer			 90
	_FIf_get_window				 91
	_FIf_get_window_event_routine		 92
	_FIf_is_collapsed			 93
	_FIf_is_displayed			 94
	_FIf_is_valid				 95
	_FIf_look				 96
	_FIf_new				 97
	_FIf_paint_area				 98
	_FIf_process_point			 99
	_FIf_reset				100
	_FIf_save				101
	_FIf_set_attr				102
	_FIf_set_button_event_routine		103
	_FIf_set_button_intercept_routine	104
	_FIf_set_cmd_oid_os			105
	_FIf_set_collapse_location		106
	_FIf_set_collapse_symbol		107
	_FIf_set_color				108
	_FIf_set_initial_notification_routine	109
	_FIf_set_label				110
	_FIf_set_location			111
	_FIf_set_max_size			112
	_FIf_set_min_size			113
	_FIf_set_notification_routine		114
	_MS_swap_menu				115
	_FIf_set_orig_location			116
	_FIf_set_orig_size			117
	_FIf_set_rel_location			118
	_FIf_set_resize_off			119
	_FIf_set_resize_on			120
	_FIf_set_scaling_off			121
	_FIf_set_scaling_on			122
	_FIf_set_screen				123
	_FIf_set_seq_off			124
	_FIf_set_seq_on				125
	_FIf_set_size				126
	_FIf_set_start_seq			127
	_FIf_set_user_pointer			128
	_FIf_set_window_event_routine		129
	_FIf_set_window_icon_routine		130
	_FIf_set_window_level			131
	_FIf_uncollapse				132
	_FIfld_delete_rows			133
	_FIfld_erase_cursor			134
	_FIfld_find_row_and_column		135
	_FIfld_get_active_char			136
	_FIfld_get_active_row			137
	_FIfld_get_attr				138
	_FIfld_get_default_text			139
	_FIfld_get_default_text_length		140
	_FIfld_get_format_routine		141
	_FIfld_get_format_string		142
	_FIfld_get_format_string_length		143
	_FIfld_get_line_color			144
	_FIfld_get_list_default_text		145
	_FIfld_get_list_default_text_length	146
	_FIfld_get_list_location		147
	_FIfld_get_list_mode			148
	_FIfld_get_list_num_rows		149
	_FIfld_get_list_scroll			150
	_FIfld_get_list_select			151
	_FIfld_get_list_size			152
	_FIfld_get_list_text			153
	_FIfld_get_list_text_length		154
	_FIfld_get_max_num_chars		155
	_FIfld_get_max_num_rows			156
	_FIfld_get_mode				157
	_FIfld_get_num_rows			158
	_FIfld_get_num_vis_chars		159
	_FIfld_get_num_vis_rows			160
	_FIfld_get_row_height			161
	_FIfld_get_row_offset			162
	_FIfld_get_select			163
	_FIfld_get_text				164
	_FIfld_get_text_length			165
	_FIfld_get_type				166
	_FIfld_get_value			167
	_FIfld_get_verify_routine		168
	_FIfld_insert_blank_row			169
	_FIfld_pos_cursor			170
	_FIfld_set_active_char			171
	_FIfld_set_active_row			172
	_FIfld_set_attr				173
	_FIfld_set_default_text			174
	_FIfld_set_format_routine		175
	_FIfld_set_format_string		176
	_FIfld_set_line_color			177
	_FIfld_set_list_default_text		178
	_FIfld_set_list_location		179
	_FIfld_set_list_mode			180
	_FIfld_set_list_num_rows		181
	_FIfld_set_list_scroll			182
	_FIfld_set_list_select			183
	_FIfld_set_list_size			184
	_FIfld_set_list_text			185
	_FIfld_set_max_num_chars		186
	_FIfld_set_max_num_rows			187
	_FIfld_set_mode				188
	_FIfld_set_num_rows			189
	_FIfld_set_num_vis_chars		190
	_FIfld_set_num_vis_rows			191
	_FIfld_set_select			192
	_FIfld_set_text				193
	_FIfld_set_type				194
	_FIfld_set_value			195
	_FIfld_set_verify_routine		196
	_FIg_activate				197
	_FIg_add_to_group			198
	_FIg_adjust_size			199
	_FIg_call_notification_routine		200
	_FIg_copy				201
	_FIg_delete				202
	_FIg_disable				203
	_FIg_display				204
	_FIg_enable				205
	_FIg_erase				206
	_FIg_get_attr				207
	_FIg_get_color				208
	_FIg_get_command			209
	_FIg_get_command_length			210
	_FIg_get_continuous_routine		211
	_FIg_get_default_value			212
	_FIg_get_display			213
	_FIg_get_dlocation			214
	_FIg_get_dsize				215
	_FIg_get_erase_color			216
	_FIg_get_font				217
	_FIg_get_group_label			218
	_FIg_get_help_topic			219
	_FIg_get_help_topic_length		220
	_FIg_get_high_value			221
	_FIg_get_increment			222
	_FIg_get_justification			223
	_FIg_get_line_depth			224
	_FIg_get_line_style			225
	_FIg_get_line_weight			226
	_FIg_get_location			227
	_FIg_get_low_value			228
	_FIg_get_minor_increments		229
	_FIg_get_next_in_seq			230
	_FIg_get_notify				231
	_FIg_get_off_color			232
	_FIg_get_off_color2			233
	_FIg_get_off_symbol_index		234
	_FIg_get_off_text			235
	_FIg_get_off_text_length		236
	_FIg_get_on_color			237
	_FIg_get_on_color2			238
	_FIg_get_on_symbol_index		239
	_FIg_get_on_text			240
	_FIg_get_on_text_length			241
	_FIg_get_orientation			242
	_FIg_get_pass_data			243
	_FIg_get_size				244
	_FIg_get_state				245
	_FIg_get_symbol_file			246
	_FIg_get_symbol_index			247
	_FIg_get_text				248
	_FIg_get_text_length			249
	_FIg_get_text_style			250
	_FIg_get_type				251
	_FIg_get_user_pointer			252
	_FIg_get_value				253
	_FIg_get_value_format			254
	_FIg_hilite				255
	_FIg_in_group				256
	_FIg_is_valid				257
	_FIg_new				258
	_FIg_reset				259
	_FIg_set_attr				260
	_FIg_set_color				261
	_FIg_set_command			262
	_FIg_set_continuous_routine		263
	_FIg_set_default_value			264
	_FIg_set_display			265
	_FIg_set_erase_color			266
	_FIg_set_font				267
	_FIg_set_help_topic			268
	_FIg_set_high_value			269
	_FIg_set_increment			270
	_FIg_set_justification			271
	_FIg_set_line_depth			272
	_FIg_set_line_style			273
	_FIg_set_line_weight			274
	_FIg_set_location			275
	_FIg_set_low_value			276
	_FIg_set_minor_increments		277
	_FIg_set_next_in_seq			278
	_FIg_set_notify_off			279
	_FIg_set_notify_on			280
	_FIg_set_off_color			281
	_FIg_set_off_symbol_index		282
	_FIg_set_off_text			283
	_FIg_set_on_color			284
	_FIg_set_on_symbol_index		285
	_FIg_set_on_text			286
	_FIg_set_orientation			287
	_FIg_set_pass_data			288
	_FIg_set_size				289
	_FIg_set_standard_variables		290
	_FIg_set_state				291
	_FIg_set_state_off			292
	_FIg_set_state_on			293
	_FIg_set_symbol_file			294
	_FIg_set_symbol_index			295
	_FIg_set_text				296
	_FIg_set_text_style			297
	_FIg_set_user_pointer			298
	_FIg_set_value				299
	_FIg_set_value_format			300
	_FIg_start_seq				301
	_FIg_unhilite				302
	_FIgrp_add_to_group			303
	_FIgrp_callback				304
	_FIgrp_delete				305
	_FIgrp_get_pass				306
	_FIgrp_get_single_select		307
	_FIgrp_set_pass_off			308
	_FIgrp_set_pass_on			309
	_FIgrp_set_single_select_off		310
	_FIgrp_set_single_select_on		311
	_FIh_attach_to_parent			312
	_FIh_callback				313
	_FIh_detach_from_parent			314
	_FIh_get_reply_routine			315
	_FIh_reply_to_parent			316
	_FIh_set_reply_routine			317
	_FImcf_delete_col			318
	_FImcf_get_active_col			319
	_FImcf_get_attr				320
	_FImcf_get_col_size			321
	_FImcf_get_high_value			322
	_FImcf_get_justification		323
	_FImcf_get_low_value			324
	_FImcf_get_num_cols			325
	_FImcf_get_num_vis_cols			326
	_FImcf_get_scroll_link			327
	_FImcf_get_select			328
	_FImcf_get_view_data			329
	_FImcf_insert_col			330
	_FImcf_set_active_col			331
	_FImcf_set_attr				332
	_FImcf_set_col_size			333
	_FImcf_set_high_value			334
	_FImcf_set_justification		335
	_FImcf_set_low_value			336
	_FImcf_set_num_cols			337
	_FImcf_set_num_vis_cols			338
	_FImcf_set_scroll_link			339
	_FImcf_set_select			340
	_FIrect_get_style			341
	_FIrect_set_style			342
	_FIscrl_get_view			343
	_FIscrl_set_view			344
	_MS_set_startup_file			345
	_MI_enter				346
	_MI_get_menu_move_routine		347
	_MI_get_palette_vert_offset		348
	_MI_get_tear_off_notification_routine	349
	_MI_get_window_routine			350
	_MI_pop_up_button			351
	_MI_set_menu_move_routine		352
	_MI_set_palette_vert_offset		353
	_MI_set_tear_off_notification_routine	354
	_MI_set_window_routine			355
	_MIm_display				356
	_MIm_new				357
	_MS_delete_menus			358
	_MS_display_menus			359
	_MS_enter				360
	_MS_erase_menus				361
	_MS_get_startup_file			362
	_MS_init_menus				363
	_MS_pop_up_last_button			364
	_MS_process_pocket			365
	_MS_save_locations			366
##  GMD 1/14/92   Added new functions
	_FI_set_graphic_env			367
	_FI_get_graphic_env			368
        _FI_set_select_button                   369
        _FI_get_select_button                   370
##  JAJ 01/20/92   Added new functions
	_FI_get_last_notification_type		371
	_FI_get_form_menu_type			372
	_FI_get_num_forms_menus			373
	_FI_get_forms_menus			374
##  JAJ 02/12/92   Added new functions
	_FIf_set_Xscreen			375
	_FIf_get_Xscreen			376
##  GMD 4/20/92
    _FI_set_SR_lockout          377
    _FI_get_save_restore_form   378
    _FI_get_form_by_window      379
##  DMB 10/01/92 Added new functions
	_FIf_set_cmd_oid_os_ANSI	380
    _FIg_get_font_ANSI          381
    _FI_write_float_ANSI        382
    _FI_write_short_ANSI        383
##	sml:01-29-93	Add new function
	_MI_set_menu_button_creation_routine 384
##	sml:07-02-93 widest character functions
	_FI_define_widest_char			385
	_FI_define_widest_wchar			386
##	sml:07-02-93	X font first strategy functions
	_FI_select_X_fonts_first		387	
	_FI_select_FS_fonts_first		388
##  sml:07-08-93	Add color2 functions
	_FIg_set_on_color2				389
	_FIg_set_off_color2				390
##	sml:09-24-93	add this one
	_MI_set_tear_off_menu_modify_routine 391
	_FIg_is_displayed				392
##  sml:11-10-93 add some more
	_FIfld_get_notify_info			393
	_FI_use_normal_bezel			394
	_FI_use_thin_bezel			395
## IMPORTANT: Any new .o's added go at end of list

#objects
##
## Form Objects
##
	glob.o
	import.o
## All new .o files must be inserted after this point
	setup.o
	memory.o
	load.o
	form.o
	gad_disp.o
	gad_mem.o
	gad_loc.o
	gad_sym.o
	gad_util.o
	gad_text.o
	gad_load.o
	group.o
	Xevent.o
	fei.o
	scale.o
	text.o
	bezel.o
	symbol.o
        toggle.o
	button.o
	mepi.o
	line.o
	rect.o
	cklst.o
	dial.o
	gauge.o
	slider.o
	common.o
	seq.o
	pass.o
	fpi.o
	efpi.o
	generic.o
	gpi.o
	egpi.o
	egpi2.o
	copy.o
	grppi.o
	scroll.o
	field.o		
	field2.o	
	fieldTrack.o	
	fieldAdd.o	
	fieldDel.o	
	fieldWrap.o	
	fieldMove.o	
	fieldScrl.o	
	fldpi.o		
	fldpi2.o	
	fldpiRow.o	
	listpi.o	
	listpi2.o	
	mcf.o		
	mcfScrlTrk.o	
	mcfpi.o		
	cmd_oid.o
	dump.o
	save.o
	modify.o
	hm.o
	find.o
	fs.o
	load_sym.o
	16stuff.o
	SS.o
	sym_info.o
##
## Menu Interface Objects
##
	panel.o
	bar.o
	icon.o
	palette.o
	pocket.o
##	window.o
	miset.o
	mpi.o
##
## Menu Subsystem Objects
##
	menusub.o
##
## Tools Objects
##
	message.o
##
## Debug Objects
##
	look.o
##
## Other Objects
##
## sml:11-10-93 added this one
drawbezel.o

##	init.o
##	shmap.o


#objects noload
	-lX11_s
	-lXFS_s
##	-lc_s


#init	import.o

	_libxfi_errno		_errno
	_libxfi__ctype		__ctype
	_libxfi__iob		__iob

	_libxfi_access		_access
	_libxfi_atoi		_atoi
	_libxfi_atof		_atof
	_libxfi_close		_close
	_libxfi_fclose		_fclose
	_libxfi_fopen		_fopen
	_libxfi_fprintf		_fprintf
	_libxfi_fread		_fread
	_libxfi_fscanf		_fscanf
	_libxfi_fseek		_fseek
	_libxfi_fwrite		_fwrite
	_libxfi_getlogin	_getlogin
	_libxfi_longjmp		_longjmp
	_libxfi_memcpy		_memcpy
	_libxfi_memset		_memset
	_libxfi_open		_open
	_libxfi_printf		_printf
	_libxfi_read		_read
	_libxfi_setjmp		_setjmp
	_libxfi_sprintf		_sprintf
	_libxfi_sscanf		_sscanf
	_libxfi_strcat		_strcat
	_libxfi_strchr		_strchr
	_libxfi_strcmp		_strcmp
	_libxfi_strcpy		_strcpy
	_libxfi_strlen		_strlen
	_libxfi_strncmp		_strncmp
	_libxfi_strncpy		_strncpy
	_libxfi_strrchr		_strrchr
	_libxfi_time		_time
	_libxfi_tolower		_tolower
	_libxfi_toupper		_toupper
	_libxfi_uname		_uname

	_libxfi_atan2		_atan2
	_libxfi_cos 		_cos
	_libxfi_pow 		_pow
	_libxfi_sin		_sin
	_libxfi_sqrt		_sqrt

	_libxfi_calloc		_calloc
	_libxfi_free 		_free
	_libxfi_malloc 		_malloc
	_libxfi_realloc		_realloc

	_libxfi_select		_select


#######################################################
## Use these dummy pointers for future import variables
#######################################################

	_libxfi_getenv		_getenv
	_libxfi_dummy1		_calloc
	_libxfi_dummy2		_calloc
	_libxfi_dummy3		_calloc
	_libxfi_dummy4		_calloc
	_libxfi_dummy5		_calloc
	_libxfi_dummy6		_calloc
	_libxfi_dummy7		_calloc
	_libxfi_dummy8		_calloc
	_libxfi_dummy9		_calloc
	_libxfi_dummy10		_calloc
	_libxfi_dummy11		_calloc
	_libxfi_dummy12		_calloc
	_libxfi_dummy13		_calloc
	_libxfi_dummy14		_calloc
	_libxfi_dummy15		_calloc
	_libxfi_dummy16		_calloc
	_libxfi_dummy17		_calloc
	_libxfi_dummy18		_calloc
	_libxfi_dummy19		_calloc
	_libxfi_dummy20		_calloc
	_libxfi_dummy21		_calloc
	_libxfi_dummy22		_calloc
	_libxfi_dummy23		_calloc
	_libxfi_dummy24		_calloc
	_libxfi_dummy25		_calloc
	_libxfi_dummy26		_calloc
	_libxfi_dummy27		_calloc
	_libxfi_dummy28		_calloc
	_libxfi_dummy29		_calloc
	_libxfi_dummy30		_calloc
	_libxfi_dummy31		_calloc
	_libxfi_dummy32		_calloc
	_libxfi_dummy33		_calloc
	_libxfi_dummy34		_calloc
	_libxfi_dummy35		_calloc
	_libxfi_dummy36		_calloc
	_libxfi_dummy37		_calloc
	_libxfi_dummy38		_calloc
	_libxfi_dummy39		_calloc
	_libxfi_dummy40		_calloc
	_libxfi_dummy41		_calloc
	_libxfi_dummy42		_calloc
	_libxfi_dummy43		_calloc
	_libxfi_dummy44		_calloc
	_libxfi_dummy45		_calloc
	_libxfi_dummy46		_calloc
	_libxfi_dummy47		_calloc
	_libxfi_dummy48		_calloc
	_libxfi_dummy49		_calloc
	_libxfi_dummy50		_calloc
	_libxfi_dummy51		_calloc
	_libxfi_dummy52		_calloc
	_libxfi_dummy53		_calloc
	_libxfi_dummy54		_calloc
	_libxfi_dummy55		_calloc
	_libxfi_dummy56		_calloc
	_libxfi_dummy57		_calloc
	_libxfi_dummy58		_calloc
	_libxfi_dummy59		_calloc
	_libxfi_dummy60		_calloc
	_libxfi_dummy61		_calloc
	_libxfi_dummy62		_calloc
	_libxfi_dummy63		_calloc
	_libxfi_dummy64		_calloc
	_libxfi_dummy65		_calloc
	_libxfi_dummy66		_calloc
	_libxfi_dummy67		_calloc
	_libxfi_dummy68		_calloc
	_libxfi_dummy69		_calloc
	_libxfi_dummy70		_calloc
	_libxfi_dummy71		_calloc
	_libxfi_dummy72		_calloc
	_libxfi_dummy73		_calloc
	_libxfi_dummy74		_calloc
	_libxfi_dummy75		_calloc
	_libxfi_dummy76		_calloc
	_libxfi_dummy77		_calloc
	_libxfi_dummy78		_calloc
	_libxfi_dummy79		_calloc
	_libxfi_dummy80		_calloc
	_libxfi_dummy81		_calloc
	_libxfi_dummy82		_calloc
	_libxfi_dummy83		_calloc
	_libxfi_dummy84		_calloc
	_libxfi_dummy85		_calloc
	_libxfi_dummy86		_calloc
	_libxfi_dummy87		_calloc
	_libxfi_dummy88		_calloc
	_libxfi_dummy89		_calloc
	_libxfi_dummy90		_calloc
	_libxfi_dummy91		_calloc
	_libxfi_dummy92		_calloc
	_libxfi_dummy93		_calloc
	_libxfi_dummy94		_calloc
	_libxfi_dummy95		_calloc
	_libxfi_dummy96		_calloc
	_libxfi_dummy97		_calloc
	_libxfi_dummy98		_calloc
	_libxfi_dummy99		_calloc
	_libxfi_dummy100	_calloc
	_libxfi_dummy101	_calloc
	_libxfi_dummy102	_calloc
	_libxfi_dummy103	_calloc
	_libxfi_dummy104	_calloc
	_libxfi_dummy105	_calloc
	_libxfi_dummy106	_calloc
	_libxfi_dummy107	_calloc
	_libxfi_dummy108	_calloc
	_libxfi_dummy109	_calloc
	_libxfi_dummy110	_calloc
	_libxfi_dummy111	_calloc
	_libxfi_dummy112	_calloc
	_libxfi_dummy113	_calloc
	_libxfi_dummy114	_calloc
	_libxfi_dummy115	_calloc
	_libxfi_dummy116	_calloc
	_libxfi_dummy117	_calloc
	_libxfi_dummy118	_calloc
	_libxfi_dummy119	_calloc
	_libxfi_dummy120	_calloc
	_libxfi_dummy121	_calloc
	_libxfi_dummy122	_calloc
	_libxfi_dummy123	_calloc
	_libxfi_dummy124	_calloc
	_libxfi_dummy125	_calloc
	_libxfi_dummy126	_calloc
	_libxfi_dummy127	_calloc
	_libxfi_dummy128	_calloc
	_libxfi_dummy129	_calloc
	_libxfi_dummy130	_calloc
	_libxfi_dummy131	_calloc
	_libxfi_dummy132	_calloc
	_libxfi_dummy133	_calloc
	_libxfi_dummy134	_calloc
	_libxfi_dummy135	_calloc
	_libxfi_dummy136	_calloc
	_libxfi_dummy137	_calloc
	_libxfi_dummy138	_calloc
	_libxfi_dummy139	_calloc
	_libxfi_dummy140	_calloc
	_libxfi_dummy141	_calloc
	_libxfi_dummy142	_calloc
	_libxfi_dummy143	_calloc
	_libxfi_dummy144	_calloc
	_libxfi_dummy145	_calloc
	_libxfi_dummy146	_calloc
	_libxfi_dummy147	_calloc
	_libxfi_dummy148	_calloc
	_libxfi_dummy149	_calloc
	_libxfi_dummy150	_calloc
	_libxfi_dummy151	_calloc
	_libxfi_dummy152	_calloc
	_libxfi_dummy153	_calloc
	_libxfi_dummy154	_calloc
	_libxfi_dummy155	_calloc
	_libxfi_dummy156	_calloc
	_libxfi_dummy157	_calloc
	_libxfi_dummy158	_calloc
	_libxfi_dummy159	_calloc
	_libxfi_dummy160	_calloc
	_libxfi_dummy161	_calloc
	_libxfi_dummy162	_calloc
	_libxfi_dummy163	_calloc
	_libxfi_dummy164	_calloc
	_libxfi_dummy165	_calloc
	_libxfi_dummy166	_calloc
	_libxfi_dummy167	_calloc
	_libxfi_dummy168	_calloc
	_libxfi_dummy169	_calloc
	_libxfi_dummy170	_calloc
	_libxfi_dummy171	_calloc
	_libxfi_dummy172	_calloc
	_libxfi_dummy173	_calloc
	_libxfi_dummy174	_calloc
	_libxfi_dummy175	_calloc
	_libxfi_dummy176	_calloc
	_libxfi_dummy177	_calloc
	_libxfi_dummy178	_calloc
	_libxfi_dummy179	_calloc
	_libxfi_dummy180	_calloc
	_libxfi_dummy181	_calloc
	_libxfi_dummy182	_calloc
	_libxfi_dummy183	_calloc
	_libxfi_dummy184	_calloc
	_libxfi_dummy185	_calloc
	_libxfi_dummy186	_calloc
	_libxfi_dummy187	_calloc
	_libxfi_dummy188	_calloc
	_libxfi_dummy189	_calloc
	_libxfi_dummy190	_calloc
	_libxfi_dummy191	_calloc
	_libxfi_dummy192	_calloc
	_libxfi_dummy193	_calloc
	_libxfi_dummy194	_calloc
	_libxfi_dummy195	_calloc
	_libxfi_dummy196	_calloc
	_libxfi_dummy197	_calloc
	_libxfi_dummy198	_calloc
	_libxfi_dummy199	_calloc
	_libxfi_dummy200	_calloc
	_libxfi_dummy201	_calloc
	_libxfi_dummy202	_calloc
	_libxfi_dummy203	_calloc
	_libxfi_dummy204	_calloc
	_libxfi_dummy205	_calloc
	_libxfi_dummy206	_calloc
	_libxfi_dummy207	_calloc
	_libxfi_dummy208	_calloc
	_libxfi_dummy209	_calloc
	_libxfi_dummy210	_calloc
	_libxfi_dummy211	_calloc
	_libxfi_dummy212	_calloc
	_libxfi_dummy213	_calloc
	_libxfi_dummy214	_calloc
	_libxfi_dummy215	_calloc
	_libxfi_dummy216	_calloc
	_libxfi_dummy217	_calloc
	_libxfi_dummy218	_calloc
	_libxfi_dummy219	_calloc
	_libxfi_dummy220	_calloc
	_libxfi_dummy221	_calloc
	_libxfi_dummy222	_calloc
	_libxfi_dummy223	_calloc
	_libxfi_dummy224	_calloc
	_libxfi_dummy225	_calloc
	_libxfi_dummy226	_calloc
	_libxfi_dummy227	_calloc
	_libxfi_dummy228	_calloc
	_libxfi_dummy229	_calloc
	_libxfi_dummy230	_calloc
	_libxfi_dummy231	_calloc
	_libxfi_dummy232	_calloc
	_libxfi_dummy233	_calloc
	_libxfi_dummy234	_calloc
	_libxfi_dummy235	_calloc
	_libxfi_dummy236	_calloc
	_libxfi_dummy237	_calloc
	_libxfi_dummy238	_calloc
	_libxfi_dummy239	_calloc
	_libxfi_dummy240	_calloc
	_libxfi_dummy241	_calloc
	_libxfi_dummy242	_calloc
	_libxfi_dummy243	_calloc
	_libxfi_dummy244	_calloc
	_libxfi_dummy245	_calloc
	_libxfi_dummy246	_calloc
	_libxfi_dummy247	_calloc
	_libxfi_dummy248	_calloc
	_libxfi_dummy249	_calloc
	_libxfi_dummy250	_calloc
	_libxfi_dummy251	_calloc
	_libxfi_dummy252	_calloc
	_libxfi_dummy253	_calloc
	_libxfi_dummy254	_calloc
	_libxfi_dummy255	_calloc
	_libxfi_dummy256	_calloc
	_libxfi_dummy257	_calloc
	_libxfi_dummy258	_calloc
	_libxfi_dummy259	_calloc
	_libxfi_dummy260	_calloc
	_libxfi_dummy261	_calloc
	_libxfi_dummy262	_calloc
	_libxfi_dummy263	_calloc
	_libxfi_dummy264	_calloc
	_libxfi_dummy265	_calloc
	_libxfi_dummy266	_calloc
	_libxfi_dummy267	_calloc
	_libxfi_dummy268	_calloc
	_libxfi_dummy269	_calloc
	_libxfi_dummy270	_calloc
	_libxfi_dummy271	_calloc
	_libxfi_dummy272	_calloc
	_libxfi_dummy273	_calloc
	_libxfi_dummy274	_calloc
	_libxfi_dummy275	_calloc
	_libxfi_dummy276	_calloc
	_libxfi_dummy277	_calloc
	_libxfi_dummy278	_calloc
	_libxfi_dummy279	_calloc
	_libxfi_dummy280	_calloc
	_libxfi_dummy281	_calloc
	_libxfi_dummy282	_calloc
	_libxfi_dummy283	_calloc
	_libxfi_dummy284	_calloc
	_libxfi_dummy285	_calloc
	_libxfi_dummy286	_calloc
	_libxfi_dummy287	_calloc
	_libxfi_dummy288	_calloc
	_libxfi_dummy289	_calloc
	_libxfi_dummy290	_calloc
	_libxfi_dummy291	_calloc
	_libxfi_dummy292	_calloc
	_libxfi_dummy293	_calloc
	_libxfi_dummy294	_calloc
	_libxfi_dummy295	_calloc
	_libxfi_dummy296	_calloc
	_libxfi_dummy297	_calloc
	_libxfi_dummy298	_calloc
	_libxfi_dummy299	_calloc
	_libxfi_dummy300	_calloc
	_libxfi_dummy301	_calloc
	_libxfi_dummy302	_calloc
	_libxfi_dummy303	_calloc
	_libxfi_dummy304	_calloc
	_libxfi_dummy305	_calloc
	_libxfi_dummy306	_calloc
	_libxfi_dummy307	_calloc
	_libxfi_dummy308	_calloc
	_libxfi_dummy309	_calloc
	_libxfi_dummy310	_calloc
	_libxfi_dummy311	_calloc
	_libxfi_dummy312	_calloc
	_libxfi_dummy313	_calloc
	_libxfi_dummy314	_calloc
	_libxfi_dummy315	_calloc
	_libxfi_dummy316	_calloc
	_libxfi_dummy317	_calloc
	_libxfi_dummy318	_calloc
	_libxfi_dummy319	_calloc
	_libxfi_dummy320	_calloc
	_libxfi_dummy321	_calloc
	_libxfi_dummy322	_calloc
	_libxfi_dummy323	_calloc
	_libxfi_dummy324	_calloc
	_libxfi_dummy325	_calloc
	_libxfi_dummy326	_calloc
	_libxfi_dummy327	_calloc
	_libxfi_dummy328	_calloc
	_libxfi_dummy329	_calloc
	_libxfi_dummy330	_calloc
	_libxfi_dummy331	_calloc
	_libxfi_dummy332	_calloc
	_libxfi_dummy333	_calloc
	_libxfi_dummy334	_calloc
	_libxfi_dummy335	_calloc
	_libxfi_dummy336	_calloc
	_libxfi_dummy337	_calloc
	_libxfi_dummy338	_calloc
	_libxfi_dummy339	_calloc
	_libxfi_dummy340	_calloc
	_libxfi_dummy341	_calloc
	_libxfi_dummy342	_calloc
	_libxfi_dummy343	_calloc
	_libxfi_dummy344	_calloc
	_libxfi_dummy345	_calloc
	_libxfi_dummy346	_calloc
	_libxfi_dummy347	_calloc
	_libxfi_dummy348	_calloc
	_libxfi_dummy349	_calloc
	_libxfi_dummy350	_calloc
	_libxfi_dummy351	_calloc
	_libxfi_dummy352	_calloc
	_libxfi_dummy353	_calloc
	_libxfi_dummy354	_calloc
	_libxfi_dummy355	_calloc
	_libxfi_dummy356	_calloc
	_libxfi_dummy357	_calloc
	_libxfi_dummy358	_calloc
	_libxfi_dummy359	_calloc
	_libxfi_dummy360	_calloc
	_libxfi_dummy361	_calloc
	_libxfi_dummy362	_calloc
	_libxfi_dummy363	_calloc
	_libxfi_dummy364	_calloc
	_libxfi_dummy365	_calloc
	_libxfi_dummy366	_calloc
	_libxfi_dummy367	_calloc
	_libxfi_dummy368	_calloc
	_libxfi_dummy369	_calloc
	_libxfi_dummy370	_calloc
	_libxfi_dummy371	_calloc
	_libxfi_dummy372	_calloc
	_libxfi_dummy373	_calloc
	_libxfi_dummy374	_calloc
	_libxfi_dummy375	_calloc
	_libxfi_dummy376	_calloc
	_libxfi_dummy377	_calloc
	_libxfi_dummy378	_calloc
	_libxfi_dummy379	_calloc
	_libxfi_dummy380	_calloc
	_libxfi_dummy381	_calloc
	_libxfi_dummy382	_calloc
	_libxfi_dummy383	_calloc
	_libxfi_dummy384	_calloc
	_libxfi_dummy385	_calloc
	_libxfi_dummy386	_calloc
	_libxfi_dummy387	_calloc
	_libxfi_dummy388	_calloc
	_libxfi_dummy389	_calloc
	_libxfi_dummy390	_calloc
	_libxfi_dummy391	_calloc
	_libxfi_dummy392	_calloc
	_libxfi_dummy393	_calloc
	_libxfi_dummy394	_calloc
	_libxfi_dummy395	_calloc
	_libxfi_dummy396	_calloc
	_libxfi_dummy397	_calloc
	_libxfi_dummy398	_calloc
	_libxfi_dummy399	_calloc
	_libxfi_dummy400	_calloc
	_libxfi_dummy401	_calloc
	_libxfi_dummy402	_calloc
	_libxfi_dummy403	_calloc
	_libxfi_dummy404	_calloc
	_libxfi_dummy405	_calloc
	_libxfi_dummy406	_calloc
	_libxfi_dummy407	_calloc
	_libxfi_dummy408	_calloc
	_libxfi_dummy409	_calloc
	_libxfi_dummy410	_calloc
	_libxfi_dummy411	_calloc
	_libxfi_dummy412	_calloc
	_libxfi_dummy413	_calloc
	_libxfi_dummy414	_calloc
	_libxfi_dummy415	_calloc
	_libxfi_dummy416	_calloc
	_libxfi_dummy417	_calloc
	_libxfi_dummy418	_calloc
	_libxfi_dummy419	_calloc
	_libxfi_dummy420	_calloc
	_libxfi_dummy421	_calloc
	_libxfi_dummy422	_calloc
	_libxfi_dummy423	_calloc
	_libxfi_dummy424	_calloc
	_libxfi_dummy425	_calloc
	_libxfi_dummy426	_calloc
	_libxfi_dummy427	_calloc
	_libxfi_dummy428	_calloc
	_libxfi_dummy429	_calloc
	_libxfi_dummy430	_calloc
	_libxfi_dummy431	_calloc
	_libxfi_dummy432	_calloc
	_libxfi_dummy433	_calloc
	_libxfi_dummy434	_calloc
	_libxfi_dummy435	_calloc
	_libxfi_dummy436	_calloc
	_libxfi_dummy437	_calloc
	_libxfi_dummy438	_calloc
	_libxfi_dummy439	_calloc
	_libxfi_dummy440	_calloc
	_libxfi_dummy441	_calloc
	_libxfi_dummy442	_calloc
	_libxfi_dummy443	_calloc
	_libxfi_dummy444	_calloc
	_libxfi_dummy445	_calloc
	_libxfi_dummy446	_calloc
	_libxfi_dummy447	_calloc
	_libxfi_dummy448	_calloc
	_libxfi_dummy449	_calloc
	_libxfi_dummy450	_calloc
	_libxfi_dummy451	_calloc
	_libxfi_dummy452	_calloc
	_libxfi_dummy453	_calloc
	_libxfi_dummy454	_calloc
	_libxfi_dummy455	_calloc
	_libxfi_dummy456	_calloc
	_libxfi_dummy457	_calloc
	_libxfi_dummy458	_calloc
	_libxfi_dummy459	_calloc
	_libxfi_dummy460	_calloc
	_libxfi_dummy461	_calloc
	_libxfi_dummy462	_calloc
	_libxfi_dummy463	_calloc
	_libxfi_dummy464	_calloc
	_libxfi_dummy465	_calloc
	_libxfi_dummy466	_calloc
	_libxfi_dummy467	_calloc
	_libxfi_dummy468	_calloc
	_libxfi_dummy469	_calloc
	_libxfi_dummy470	_calloc
	_libxfi_dummy471	_calloc
	_libxfi_dummy472	_calloc
	_libxfi_dummy473	_calloc
	_libxfi_dummy474	_calloc
	_libxfi_dummy475	_calloc
	_libxfi_dummy476	_calloc
	_libxfi_dummy477	_calloc
	_libxfi_dummy478	_calloc
	_libxfi_dummy479	_calloc
	_libxfi_dummy480	_calloc
	_libxfi_dummy481	_calloc
	_libxfi_dummy482	_calloc
	_libxfi_dummy483	_calloc
	_libxfi_dummy484	_calloc
	_libxfi_dummy485	_calloc
	_libxfi_dummy486	_calloc
	_libxfi_dummy487	_calloc
	_libxfi_dummy488	_calloc
	_libxfi_dummy489	_calloc
	_libxfi_dummy490	_calloc
	_libxfi_dummy491	_calloc
	_libxfi_dummy492	_calloc
	_libxfi_dummy493	_calloc
	_libxfi_dummy494	_calloc
	_libxfi_dummy495	_calloc
	_libxfi_dummy496	_calloc
	_libxfi_dummy497	_calloc
	_libxfi_dummy498	_calloc
	_libxfi_dummy499	_calloc


#hide linker

##
## Hide local malloc calls
##
##	_calloc
##	_free
##	_malloc
##	_realloc
##
## Hide local C calls
##
##	_access
##	_atof
##	_fclose
##	_fopen
##	_fprintf
##	_fread
##	_fscanf
##	_fseek
##	_fwrite
##	_getlogin
##	_longjmp
##	_memcpy
##	_memset
##	_open
##	_read
##	_setjmp
##	_sprintf
##	_sscanf
##	_strcat
##	_strcmp
##	_strchr
##	_strcpy
##	_strlen
##	_strncmp
##	_strncpy
##	_strrchr
##	_time
##	_tolower
##	_toupper
##	_uname
##
## Hide local math calls
##
##	_atan2
##	_cos
##	_pow
##	_sin
##	_sqrt
##
## Hide local X11 calls
##
	_XAllocColor        
	_XAllocWMHints      
	_XChangeGC          
	_XChangeWindowAttributes
	_XCheckIfEvent      
	_XCheckMaskEvent    
	_XConfigureWindow   
	_XCopyGC            
	_XCopyPlane         
	_XCreateBitmapFromData
	_XCreateGC          
	_XCreatePixmapCursor
	_XCreateWindow      
	_XDefineCursor      
	_XDestroyWindow     
	_XDrawLine          
	_XDrawLines         
	_XDrawRectangle     
	_XDrawRectangles    
	_XDrawSegments      
	_XDrawString        
	_XFillPolygon       
	_XFillRectangle     
	_XFillRectangles    
	_XFlush             
	_XFree              
	_XFreeFontNames     
	_XFreeGC            
	_XFreePixmap        
	_XGetInputFocus     
	_XGetNormalHints    
##	_XGetVisualInfo     
	_XGetWMHints        
	_XGetWindowAttributes
	_XGetZoomHints      
	_XGrabPointer       
	_XIconifyWindow     
	_XIfEvent           
	_XListFonts         
	_XLoadFont          
	_XLookupString      
	_XMapRaised         
	_XMapWindow         
	_XMaskEvent         
	_XNextEvent         
	_XParseColor        
	_XPutBackEvent      
	_XQueryBestStipple  
	_XQueryColors       
	_XQueryPointer      
	_XQueryTextExtents  
	_XSelectInput       
	_XSendEvent         
	_XSetBackground     
	_XSetClassHint      
	_XSetClipMask       
	_XSetClipRectangles 
	_XSetDashes         
	_XSetFillStyle      
	_XSetFont           
	_XSetForeground     
	_XSetIconName       
	_XSetInputFocus     
	_XSetLineAttributes 
	_XSetNormalHints    
	_XSetWMHints        
	_XSetWMNormalHints  
	_XSetZoomHints      
	_XStoreName         
	_XSync              
	_XTranslateCoordinates
	_XUngrabPointer     
	_XUnmapWindow       
	_XWithdrawWindow
##
## Hide local XFontServer calls
##
	_FSGetBmapInfo      
	_FSGetTextVect      
	_FSNewFont          
	_FSReadCharMapFile  
	_FSXDrawChar        
	_FSXDrawText        
