##
##	 EXNUC shared library specification file
##

##ident will be created by the makefile on the fly.  Do not add ident here.

#target	./shlib/libexnucX_s

#address .text 0xf2000000
#address .data 0xf2400000

#branch
	_blkmv                                               1
	_OM_PMS                                              2
	_Close_OS                                            3
	_DPhandle_event                                      4
	_DPsetinqwindow                                      5
	_EX_add_win                                          6
	_EX_attach_generator                                 7
	_EX_attach_listener                                  8
	_EX_attach_super                                     9
	_EX_clear_abs_dig                                    10
	_EX_conv_pnt                                         11
	_EX_cp                                               12
	_EX_define_input_generator                           13
	_EX_detach_generator                                 14
	_EX_detach_listener                                  15
	_EX_file_status                                      16
	_EX_findmod                                          17
	_EX_flush_event_queue                                18
	_EX_fork                                             19
	_EX_get_NOD                                          20
	_EX_get_global                                       21
	_EX_get_invis_info_by_index                          22
	_EX_get_modid_given_osnum                            23
	_EX_get_oid_nodid                                    24
	_EX_get_oid_nodname                                  25
	_EX_get_super                                        26
	_EX_getkey                                           27
	_EX_getpath                                          28
	_EX_init_keyboard                                    29
	_EX_get_cmd_info                                     30
	_EX_is_driver_exist                                  31
	_EX_is_invis                                         32
	_EX_is_visible                                       33
	_EX_keyin_no_cmd                                     34
	_EX_mv                                               35
	_EX_retrieve_os                                      36
	_EX_rm                                               37
	_EX_set_abs_dig                                      38
	_EX_update_funcky                                    39
	_EX_wait_for_input                                   40
	_EXgetq                                              41
	_EXputq                                              42
	_EXputq_back                                         43
	_EXputq_front                                        44
	_IGEgadget_IGEgadget_add_gadget_method               45
	_IGEgadget_IGEgadget_dep_extents_method              46
	_IGEgadget_IGEgadget_indep_extents_method            47
	_IGEgadget_IGEgadget_range_intersect_method          48
	_IGEget_num_screens                                  49
	_IGEingen_IGEingen_generate_method                   50
	_IGEinlisnr_IGEinlisnr_listen_method                 51
	_IGEinq_term_info                                    52
	_IGEwin_const                                        53
	_IGEwindow_IGEgadget_activate_method                 54
	_IGEwindow_IGEgadget_add_gadget_method               55
	_IGEwindow_IGEgadget_clear_method                    56
	_IGEwindow_IGEgadget_convert_pnt_method              57
	_IGEwindow_IGEwindow_collapse_window_method          58
	_IGEwindow_IGEwindow_deactivate_method               59
	_IGEwindow_IGEwindow_passon_method                   60
	_IGEwindow_IGEwindow_pop_window_method               61
	_IGEwindow_IGEwindow_reactivate_method               62
	_IGEwindow_Root_delete_method                        63
	_Retrieve_OS                                         64
	_Retrieve_new_OS                                     65
	_Save_As_OS                                          66
	_Save_OS                                             67
	_UI_echo                                             68
	_UI_error                                            69
	_UI_message                                          70
	_UI_prompt                                           71
	_UI_status                                           72
	_exec_exec_passon_method                             73
	_exec_exec_wait_for_input_method                     74
	_exec_exec_wake_up_method                            75
	_EX_create_prompt                                    76
	_get_modtype_data                                    77
	_global_class_global_class_place_method              78
	_global_class_global_class_sleep_method              79
	_global_class_global_class_super_construct_method    80
	_global_class_global_class_wake_up_method            81
	_module_module_GRmd_add_super_method                 82
	_module_module_GRmod_passon_method                   83
	_module_module_get_chan_cnt_method                   84
	_module_module_get_chan_obj_method                   85
	_print_queue                                         86
	_remove_backup                                       87
	_super_cmd_super_cmd_abort_method                    88
	_super_cmd_super_cmd_cmd_name_method                 89
	_super_cmd_super_cmd_execute_method                  90
	_super_cmd_super_cmd_form_input_method               91
	_super_cmd_super_cmd_help_method                     92
	_super_cmd_super_cmd_help_topic_method               93
	_super_cmd_super_cmd_init_method                     94
	_super_cmd_super_cmd_sleep_method                    95
	_super_cmd_super_cmd_status_disp_method              96
	_super_cmd_super_cmd_undo_method                     97
	_super_cmd_super_cmd_wakeup_method                   98
	_module_module_mod_info_method                       99
	_EX_mod_info                                         100
	_IGEresetstop                                        101
	_IGEstop                                             102
	_IGEsetstop                                          103
	_IGEstopinit                                         104
	_EX_translate_funckey                                105
	_EX_mod_info                                         106
	_EX_is_help_active                                   107
	_EX_help_flag                                        108
	_EX_help_on                                          109
	_EX_help_off                                         110
	_EX_is_file_open                                     111
	_EX_is_temp_wakeup                                   112
	_EX_peek_event_queue                                 113
	_EX_start_timing                                     114
	_EX_end_timing                                       115
	_FEadd_font                                          116
	_FErm_font                                           117
	_FEmap_add_font                                      118
	_FEcheck_rangespec                                   119
	_EX_add_function                                     120
	_EX_del_function                                     121
	_EX_disp_flag                                        122
	_EX_disp_on                                          123
	_EX_disp_off                                         124
	_IGEsractive                                         125
	_EX_get_exec_id                                      126
	_EX_get_file_path                                    127
	_EXputq2                                             128
	_EX_is_batch                                         129
	_EX_is_interactive                                   130
	_MS_init                                             131
	_MS_dis_msg                                          132
	_MS_out_msg                                          133
	_MS_fix_type                                         134
	_MS_format_message                                   135
	_MS_function                                         136
	_MS_init_file                                        137
	_MS_init_files                                       138
	_MS_file_init                                        139
	_MS_retrieve_msg                                     140
	_EXget_file                                          141
	_MSon                                                142
	_MSoff                                               143
	_MSset                                               144
	_MS_onoff                                            145
	_MSerrbox                                            146
	_MS_display_message                                  147
	_MSmessage                                           148
	_MSgetfont                                           149
	_DIbtree_Root_debug_method                           150
	_IGRdir_IGRdir_init_method                           151
	_IGRdir_IGRdir_i_find_method                         152
	_DIstrcat                                            153
	_DIfrees                                             154
	_IGRdir_IGRdir_find_method                           155
	_DIuntranslate                                       156
	_IGRdir_IGRdir_ls_method                             157
	_IGRdir_IGRdir_dump_method                           158
	_DIis_regexp                                         159
	_DIstrcmp                                            160
	_IGRdir_IGRdir_pass_method                           161
	_DIpass                                              162
	_DImove_names                                        163
	_DIfast_trans                                        164
	_IGEactivate_stop_sign                               165
	_IGRdir_IGRdir_unindex_method                        166
	_IGRdir_Root_delete_method                           167
	_DIrectory_DIrectory_untranslate_method              168
	_DIrectory_IGRdir_init_method                        169
	_DIrectory_Root_debug_method                         170
	_DIadd_name                                          171
	_DIfetch_untrans                                     172
	_DItranslate                                         173
	_DIrename                                            174
	_DIlink                                              175
	_DIrmdir                                             176
	_DIterminator                                        177
	_DIexpanse                                           178
	_DImain                                              179
	_DImkdir                                             180
	_DIcreate_dir                                        181
	_DIfind                                              182
	_DIsplit                                             183
	_DIpwd                                               184
	_DIcd                                                185
	_DIgive_pathname                                     186
	_DIfrtcat                                            187
	_DIstart_dump                                        188
	_DIfetch_dump                                        189
	_DIrm_objid                                          190
	_DIrm_index                                          191
	_DIgive_osnum                                        192
	_DIsend                                              193
	_DIunindex                                           194
	_DIreport_error                                      195
	_GRpwg                                               196
	_DIstart_find                                        197
	_DIfetch_find                                        198
	_DIumount                                            199
	_DIindex                                             200
	_DIadd_index                                         201
	_DImkpath                                            202
	_DIdbg_glob                                          203
	_DIdbg_cd                                            204
	_DIdbg_pwd                                           205
	_DIdbg_mkdir                                         206
	_DIdbg_rmdir                                         207
	_DIdbg_ls                                            208
	_DIdbg_dump                                          209
	_DIdbg_find                                          210
	_DIdbg_trans                                         211
	_DIdbg_rm                                            212
	_DIdbg_rename                                        213
	_DIdbg_pwg                                           214
	_DIdbg_cg                                            215
	_DIdbg_mkgroup                                       216
	_GRadd_group                                         217
	_DIdbg_link                                          218
	_EX_is_button_defined                                219
	_IGE_startup                                         220
	_DImulti_parse                                       221
	_EX_close1                                           222
	_DImulti_step                                        223
	_EX_exit1                                            224
	_EX_filename1                                        225
	_EX_is_cmd_stack_empty                               226
	_EX_remove_name_nodid                                227
	_EX_remove_name_nodname                              228
	_EX_add_name_nodname                                 229
	_EX_add_name_nodid                                   230
	_EX_retrieve_module                                  231
	_EX_save1                                            232
	_EX_saveas1                                          233
	_EX_start_cmdserver                                  234
	_IGEdeactivate_stop_sign                             235
	_EX_save_backup_file                                 236
	_EX_stop_auto_backup                                 237
	_EX_get_win_class                                    238
	_EX_del_win                                          239
	_EX_set_up_file                                      240
	_EX_get_file_default                                 241
	_EX_cmdgetptr                                        242
	_EX_file_create_list                                 243
	_EX_cmdfreeptr                                       244
	_EX_get_input                                        245
	_IGEinq_mouse_pos                                    246
	_EX_inq_language                                     247
	Rload                                                248
	_print_invis                                         249
	_EX_error_box                                        250
	_EXset_locale                                        251
	_EXinq_locale                                        252
	_FEread_font                                         253
	_IGEwindow_IGEwindow_change_cusror_def_method        254
	_IGEwindow_IGEwindow_reset_cursor_def_method         255
	_IGEwindow_IGEwindow_display_name_method             256
	_IGEwindow_IGEgadget_change_gadget_size_method       257
	_IGEwindow_IGEwindow_DPinquire_method                258
	_IGEwindow_IGEwindow_DPset_method                    259
	_IGEgadget_IGEgadget_calc_dep_extents_method         260
	_IGEgadget_IGEgadget_calc_indep_extents_method       261
	_IGEgadget_IGEgadget_change_gadget_size_method       262
	_IGEwindow_IGEwindow_set_collapse_pos_method         263
	_IGEwindow_IGEwindow_change_screen_method            264
	_DIstrcpy                                            265
	_DIchstr                                             266
	_DIclean                                             267
	_GRcg                                                268
	_DIload                                              269
	_EXupdatable_exist                                   270
	_cmdserver_OM_class_init                             271
	_exec_OM_class_init                                  272
	_global_class_OM_class_init                          273
	_module_OM_class_init                                274
	_super_cmd_OM_class_init                             275
	_DIinit                                              276
	_IGEingen_OM_class_init                              277
	_DImount                                             278
	_IGEgadget_OM_class_init                             279
	_IGEinlisnr_OM_class_init                            280
	_IGEwindow_OM_class_init                             281
	_module_build_path                                   282
	_IGEwsys_OM_class_init                               283
	_EX_bckup_OM_class_init                              284
	_EX_close_OM_class_init                              285
	_EX_defbut_OM_class_init                             286
	_EX_exit_OM_class_init                               287
	_EX_menuchk_OM_class_init                            288
	_EX_fbackup_OM_class_init                            289
	_EX_file_OM_class_init                               290
	_EX_funcky_OM_class_init                             291
	_EX_pricmd_OM_class_init                             292
	_EX_rclkeyin_OM_class_init                           293
	_EX_retri_OM_class_init                              294
	_EX_save_OM_class_init                               295
	_EX_saveas_OM_class_init                             296
	_EX_swapmenu_OM_class_init                           297
	_EX_ver_OM_class_init                                298
	_file_exists                                         299
	_EX_add_cmdserver_function                           300
	_EX_get_kybd_data                                    301
	_DIancestry_valid                                    302
	_DIadd_line                                          303
	_DIget_choice                                        304
	_DInew_trailer                                       305
	_DIread_line                                         306
	_GRreport_error                                      307
	_GRchange_group                                      308
	_GRvalidate                                          309
	_GRchange_passwd                                     310
	_EX_test_OM_class_init                               311
	_module_build_path                                   312
	_EX_delete_win                                       313
	_IGEExit                                             314
	_EX_get_kbd_input                                    315
	_EX_get_keyin                                        316
	_EX_context_switch_to                                317
	_DIunall                                             318
	_IGRdir_OM_class_init                                319
	_EX_clean_str                                        320
	_EX_print_timing                                     321
	_EX_set_search_path                                  322
	_EX_restore_search_path                              323-323
	_CEO_OM_class_init                                   324
	_EX_use_default_dir                                  325
	_EX_ci_test_start                                    326
	_EX_ci_test_end                                      327
	_EX_clear_timing                                     328
	_EX_get_srch_path1                                   329
	_EX_init_locale                                      330
	_EX_get_user_srch_path                               331
	_OMCluster_OM_class_init                             332
	_Root_OM_class_init                                  333
	_OMFiledOS_OM_class_init                             334
	_OMObjSpace_OM_class_init                            335
	_OMGroup_OM_class_init                               336
	_OMISO_OM_class_init                                 337
	_OMMOSD_OM_class_init                                338
	_OMMOSDOS_OM_class_init                              339
	_OMOSCO_OM_class_init                                340
	_OMSupGroup_OM_class_init                            341
	_OMTag_OM_class_init                                 342
	_OMTagCon_OM_class_init                              343
	_OMTransOS_OM_class_init                             344
	_OMbtree_OM_class_init                               345
	_OMindex_OM_class_init                               346
	_OMlnkbtree_OM_class_init                            347
	_OMrtree_OM_class_init                               348
	_DIlink_OM_class_init                                349
	_GRoups_OM_class_init                                350
	_IGEhlability                                        351
	_EX_build_classlist                                  352
	_EX_get_working_dir                                  353
	_EX_get_support_dir                                  354
	_som_calloc                                          355
	_som_cancel_intercept                                356
	_som_change_class                                    357
	_som_change_os_name                                  358
	_som_change_os_name_by_name                          359
	_som_change_tag_version                              360
	_som_channel_preset                                  361
	_som_channel_unpreset                                362
	_som_checkFileTimeStamp                              363
	_som_construct_and_copy                              364
	_som_construct_object                                365
	_som_construct_os                                    366
	_som_construct_os_by_name                            367
	_som_convert_internal_osname_to_number               368
	_som_convert_number_to_internal_osname               369
	_som_convert_os_name_to_number                       370
	_som_convert_os_number_to_name                       371
	_som_dealloc                                         372
	_som_disable_intercept                               373
	_som_dload_class                                     374
	_som_dynamic_class                                   375
	_som_dynamic_load                                    376
	_som_enough_disk_space                               377
	_som_flagged_tag_connects                            378
	_som_getClusterFromObject                            379
	_som_get_all_parents                                 380
	_som_get_channel_count                               381
	_som_get_channel_name                                382
	_som_get_channel_number                              383
	_som_get_channel_objects                             384
	_som_get_classid                                     385
	_som_get_classname                                   386
	_som_get_index                                       387
	_som_get_intercept                                   388
	_som_get_message_name                                389
	_som_get_objid_at_index                              390
	_som_get_os_senddepth                                391
	_som_get_parent_classid                              392
	_som_get_parent_classname                            393
	_som_get_parent_count                                394
	_som_get_senddepth                                   395
	_som_inquire_os                                      396
	_som_is_ancestry_valid                               397
	_som_is_objid_on_channel                             398
	_som_is_objid_valid                                  399
	_som_make_chanselect                                 400
	_som_make_message                                    401
	_som_make_neighbor                                   402
	_som_malloc                                          403
	_som_move_tag                                        404
	_som_objid_to_tag                                    405
	_som_osnum_to_oso_objid                              406
	_som_parse_channame                                  407
	_som_realloc                                         408
	_som_remove_object_tag                               409
	_som_report_class_version                            410
	_som_report_error                                    411
	_som_report_version                                  412
	_som_rtree_get_op                                    413
	_som_rtree_ops_init                                  414
	_som_runtime_init                                    415
	_som_send_channel                                    416
	_som_send_foreign                                    417
	_som_send_object                                     418
	_som_set_dynamic_defaults                            419
	_som_set_intercept                                   420
	_som_set_tag_os                                      421
	_som_sibling_send                                    422
	_som_sm_calloc                                       423
	_som_sm_dealloc                                      424
	_som_sm_malloc                                       425
	_som_sm_realloc                                      426
	_som_tag_object                                      427
	_som_tag_to_objid                                    428
	_som_test_connection                                 429
	_som_vla_set_dimension                               430
	_som_set_os_type                                     431
	_som_cleanup_cluster                                 432
	_som_coalesce                                        433
	_som_collapse_channel                                434
	_som_connect_add_tail                                435
	_som_connect_build_side                              436
	_som_connect_chan_alloc                              437
	_som_connect_check_classlist                         438
	_som_connect_complete_sides                          439
	_som_connect_disconnect                              440
	_som_connect_doconnect                               441
	_som_connect_get_chent                               442
	_som_connect_if_connected                            443
	_som_connect_insert_rel                              444
	_som_connect_move_check                              445
	_som_connect_pside                                   446
	_som_connect_release_side                            447
	_som_connect_return_chent                            448
	_som_create_class                                    449
	_som_delete_object                                   450
	_som_find_space_in_lcd                               451
	_som_free_space                                      452
	_som_get_any_instance                                453
	_som_get_channel                                     454
	_som_get_class                                       455
	_som_get_instance                                    456
	_som_get_mychan                                      457
	_som_is_oper_equal                                   458
	_som_object_alloc                                    459
	_som_ordered_send                                    460
	_som_recognize_class                                 461
	_som_validate_cluster                                462
	_som_vla_collapse_copy                               463
	_som_vla_find_initial_size                           464
	_som_vla_fixup                                       465
	_som_vla_get_size_of_object                          466
	_som_vla_initialize_offsets                          467
	_som_vla_remove_outriggers                           468
	_som_is_om_file					     469
	_som_get_mem_info				     470
    _JNL_playback                        471
    _JNL_journal                         472
    _JNL_XCreateWindow                   473
    _JNL_XNextEvent                      474
    _JNL_XGrabPointer                    475
    _JNL_XUngrabPointer                  476
    _JNL_XCheckTypedEvent                477
    _JNL_XCheckMaskEvent                 478
    _JNL_XCheckWindowEvent               479
    _JNL_XMaskEvent                      480
    _JNL_XCheckIfEvent                   481
    _JNL_XIfEvent                        482
    _JNL_read_next_event                 483
    _JNL_record_next_event               484
    _JNL_XPeekEvent                      485
    _JNL_XPutBackEvent                   486
    _JNL_record_info_event               487
    _JNL_record_input                    488
    _JNL_echo_input                      489
    _EX_help_init                        490
	_JNL_XWithdrawWindow				491
	_JNL_XUnmapWindow				492
	_JNL_XMapWindow					493
	_JNL_XMapRaised					494
	_JNL_XWindowEvent				495
	_JNL_XPeekIfEvent				496
	_JNL_XPending					497

##objects list is created on the fly by the makefile.  Do not add objects here.
	
##init is created by the makefile on fly.  Do not add it here.
	__exnuc_FIdecode		_FIdecode
	__exnuc_mkdir			_mkdir
	__exnuc_EX_get_version		_EX_get_version
	__exnuc_FSDefCharMap		_FSDefCharMap
	__exnuc_FSDeleteFont		_FSDeleteFont
	__exnuc__FSDrawOutline3D		__FSXDrawOutline3D
	__exnuc_FSDrawChar		_FSXDrawChar
	__exnuc_FSDrawString		_FSXDrawString
	__exnuc_FSDrawText		_FSXDrawText
	__exnuc_FSEnter		_FSEnter
	__exnuc_FSExit		_FSExit
	__exnuc_FSGetBmapCharInfo		_FSGetBmapCharInfo
	__exnuc_FSGetBmapInfo		_FSGetBmapInfo
	__exnuc_FSGetCharVect		_FSGetCharVect
	__exnuc_FSGetOutl3DDrawFunc		_FSGetOutl3DDrawFunc
	__exnuc_FSGetOutlCharInfo		_FSGetOutlCharInfo
	__exnuc_FSGetOutlInfo		_FSGetOutlInfo
	__exnuc_FSGetStringVect		_FSGetStringVect
	__exnuc_FSGetTextVect		_FSGetTextVect
	__exnuc_FSNewFont		_FSNewFont
	__exnuc_FSReadCharMapFile		_FSReadCharMapFile
	__exnuc_FSReadFontFile		_FSReadFontFile
	__exnuc_FSSetOutl3DDrawFunc		_FSSetOutl3DDrawFunc
	__exnuc_GPEnter		_GPEnter
	__exnuc_GPExit		_GPExit
	__exnuc_IPCL_ctl		_IPCL_ctl
	__exnuc_IPCL_get		_IPCL_get
	__exnuc_IPCL_init		_IPCL_init
	__exnuc_OD_init		_OD_init
	__exnuc_OM_GA_appl_version		_OM_GA_appl_version
	__exnuc_OM_GA_class_definitions		_OM_GA_class_definitions
	__exnuc_OM_Gi_number_of_appl_ids		_OM_Gi_number_of_appl_ids
	__exnuc_OM_Gi_number_of_defns		_OM_Gi_number_of_defns
	__exnuc__assert		__assert
	__exnuc__cleanup		__cleanup
	__exnuc__ctype		__ctype
	__exnuc__exit		__exit
	__exnuc__filbuf		__filbuf
	__exnuc__flsbuf		__flsbuf
	__exnuc__iob		__iob
	__exnuc_abs		_abs
	__exnuc_access		_access
	__exnuc_allocsz		_allocsz
	__exnuc_atan2		_atan2
	__exnuc_atof		_atof
	__exnuc_atoi		_atoi
	__exnuc_atol		_atol
	__exnuc_blkalloc		_blkalloc
	__exnuc_blkcalloc		_blkcalloc
	__exnuc_blkfree		_blkfree
	__exnuc_blkrealloc		_blkrealloc
	__exnuc_brk		_brk
	__exnuc_bsearch		_bsearch
	__exnuc_calloc		_calloc
	__exnuc_chmod		_chmod
	__exnuc_close		_close
	__exnuc_cos		_cos
	__exnuc_creat		_creat
	__exnuc_ctime		_ctime
	__exnuc_defineblk		_defineblk
	__exnuc_defineblkopt		_defineblkopt
	__exnuc_crypt		_crypt
	__exnuc_blkinfo			_blkinfo
	__exnuc_dload		_dload
	__exnuc_dload_address_lookup		_dload_address_lookup
	__exnuc_dload_setopt			_dload_setopt
	__exnuc_drand48		_drand48
	__exnuc_environ		_environ
	__exnuc_errno		_errno
	__exnuc_execl		_execl
	__exnuc_execlp		_execlp
	__exnuc_execv		_execv
	__exnuc_execve		_execve
	__exnuc_exit		_exit
	__exnuc_exitadd		_exitadd
	__exnuc_exitdel		_exitdel
	__exnuc_fabs		_fabs
	__exnuc_fclose		_fclose
	__exnuc_fcntl		_fcntl
	__exnuc_fflush		_fflush
	__exnuc_fgets		_fgets
	__exnuc_fopen		_fopen
	__exnuc_fdopen		_fdopen
	__exnuc_fork		_fork
	__exnuc_fprintf		_fprintf
	__exnuc_fread		_fread
	__exnuc_free		_free
	__exnuc_frexp		_frexp
	__exnuc_fscanf		_fscanf
	__exnuc_fseek		_fseek
	__exnuc_ftell		_ftell
	__exnuc_ftok		_ftok
	__exnuc_ftw		_ftw
	__exnuc_fwrite		_fwrite
	__exnuc_getargs		_getargs
	__exnuc_getegid		_getegid
	__exnuc_getenv		_getenv
	__exnuc_geteuid		_geteuid
	__exnuc_getopt		_getopt
	__exnuc_getpid		_getpid
	__exnuc_getppid		_getppid
	__exnuc_growblk		_growblk
	__exnuc_kill		_kill
	__exnuc_localtime		_localtime
	__exnuc_lockf		_lockf
	__exnuc_longjmp		_longjmp
	__exnuc_lseek		_lseek
	__exnuc_malloc		_malloc
	__exnuc_memcpy		_memcpy
	__exnuc_memset		_memset
	__exnuc_memtrap		_memtrap
	__exnuc_msgctl		_msgctl
	__exnuc_msgget		_msgget
	__exnuc_msgrcv		_msgrcv
	__exnuc_msgsnd		_msgsnd
	__exnuc_open		_open
	__exnuc_optarg		_optarg
	__exnuc_optind		_optind
	__exnuc_pclose		_pclose
	__exnuc_perror		_perror
	__exnuc_pipe		_pipe
	__exnuc_popen		_popen
	__exnuc_pow		_pow
	__exnuc_printf		_printf
	__exnuc_putenv		_putenv
	__exnuc_rand		_rand
	__exnuc_read		_read
	__exnuc_realloc		_realloc
	__exnuc_rewind		_rewind
	__exnuc_sbrk		_sbrk
	__exnuc_scanf		_scanf
	__exnuc_semctl		_semctl
	__exnuc_semget		_semget
	__exnuc_semop		_semop
	__exnuc_setjmp		_setjmp
	__exnuc_shmat		_shmat
	__exnuc_shmctl		_shmctl
	__exnuc_shmdt		_shmdt
	__exnuc_shmget		_shmget
	__exnuc_signal		_signal
	__exnuc_sigset		_sigset
	__exnuc_sin		_sin
	__exnuc_sleep		_sleep
	__exnuc_sprintf		_sprintf
	__exnuc_sqrt		_sqrt
	__exnuc_srand		_srand
	__exnuc_sscanf		_sscanf
##	__exnuc_stackalloc		_stackalloc
##	__exnuc_stackfree		_stackfree
	__exnuc_strcat		_strcat
	__exnuc_strtok		_strtok
	__exnuc_strchr		_strchr
	__exnuc_strcmp		_strcmp
	__exnuc_strcpy		_strcpy
	__exnuc_strlen		_strlen
	__exnuc_strncat		_strncat
	__exnuc_strncmp		_strncmp
	__exnuc_strncpy		_strncpy
	__exnuc_strrchr		_strrchr
	__exnuc_strtol		_strtol
	__exnuc_strtoul		_strtoul
	__exnuc_sys_errlist		_sys_errlist
	__exnuc_sys_fstat		_fstat
	__exnuc_sys_fstatl		_fstatl
	__exnuc_sys_link		_link
	__exnuc_sys_nerr		_sys_nerr
	__exnuc_sys_sleep		_sleep
	__exnuc_sys_stat		_stat
	__exnuc_sys_statl		_statl
	__exnuc_sys_statfs		_statfs
	__exnuc_sys_write		_write
	__exnuc_syscli		_syscli
	__exnuc_system		_system
	__exnuc_tdelete		_tdelete
	__exnuc_tempnam		_tempnam
	__exnuc_tfind		_tfind
	__exnuc_sys_time	_time
	__exnuc_times		_times
	__exnuc_tmpnam		_tmpnam
	__exnuc_tolower		_tolower
	__exnuc_toupper		_toupper
	__exnuc_tsearch		_tsearch
	__exnuc_twalk		_twalk
	__exnuc_umask		_umask
	__exnuc_uname		_uname
	__exnuc_unlink		_unlink
	__exnuc_utime		_utime
	__exnuc_vfork		_vfork
	__exnuc_vfprintf		_vfprintf
	__exnuc_vlock		_vlock
	__exnuc_vprintf		_vprintf
	__exnuc_vunlock		_vunlock
	__exnuc_wait		_wait
	__exnuc_syscall		_syscall
	__exnuc_cftime			_cftime
	__exnuc_vsprintf		_vsprintf
	__exnuc_ioctl		_ioctl
	__exnuc_ttyname		_ttyname
	__exnuc_FI_process_event		_FI_process_event
	__exnuc_FEI_enter  		_FEI_enter  
	__exnuc_FIf_get_attr		_FIf_get_attr
	__exnuc_FIf_delete 		_FIf_delete 
	__exnuc_FIf_display 		_FIf_display 
	__exnuc_FIf_erase 		_FIf_erase 
	__exnuc_FIf_get_user_pointer 		_FIf_get_user_pointer 
	__exnuc_FIf_new 		_FIf_new 
	__exnuc_FIf_reset 		_FIf_reset 
	__exnuc_FIf_set_user_pointer		_FIf_set_user_pointer
	__exnuc_FIf_get_cmd_oid_os		_FIf_get_cmd_oid_os
	__exnuc_FIf_set_cmd_oid_os		_FIf_set_cmd_oid_os
	__exnuc_FIf_set_initial_notification_routine		_FIf_set_initial_notification_routine
	__exnuc_FIf_set_location		_FIf_set_location
	__exnuc_RAPFormListener		_RAPFormListener
	__exnuc_FI_is_SR_active      _FI_is_SR_active
	__exnuc_MS_panel_menu	_MS_panel_menu
	__exnuc_MS_bar_menu	_MS_bar_menu
	__exnuc_MS_set_startup_file	_MS_set_startup_file	
	__exnuc_MS_init_menus	_MS_init_menus	
	__exnuc_MS_display_menus 	_MS_display_menus	
	__exnuc_MS_process_pocket 	_MS_process_pocket	
	__exnuc_MS_save_locations 	_MS_save_locations	
	__exnuc_MS_delete_menus 	_MS_delete_menus	
	__exnuc_MS_menus_displayed 	_MS_menus_displayed	
	__exnuc_MS_swap_menu 	_MS_swap_menu	
	__exnuc_MS_dump_menus 	_MS_dump_menus	
	__exnuc_MS_refresh_menus 	_MS_refresh_menus	
	__exnuc_MS_erase_menus 	_MS_erase_menus	
	__exnuc_MS_delete_visible_menus 	_MS_delete_visible_menus 
	__exnuc_chown	_chown
	__exnuc_getpagesize	_getpagesize
	__exnuc_sigrelse	_sigrelse
	__exnuc_getuid		_getuid
        __exnuc_RAP_get_keyboard_data		_RAP_get_keyboard_data
        __exnuc_RAP_get_button_data		_RAP_get_button_data
	__exnuc_FI_manipulate_form		_FI_manipulate_form
        __exnuc_RAP_record_string       _RAP_record_string
        __exnuc_trap_errors             _trap_errors
        __exnuc_sync             _sync
	__exnuc_plif_dload       _plif_dload
	__exnuc_plif_wrapup     _plif_wrapup
	__exnuc_strtod           _strtod		
        __exnuc_FEI_set_form_icon_path		_FEI_set_form_icon_path
        __exnuc_opendir			_opendir
        __exnuc_readdir			_readdir
        __exnuc_closedir		_closedir
	__exnuc_setuid			_setuid
	__exnuc_FIg_set_text	_FIg_set_text
    __exnuc_FIfld_delete_rows  _FIfld_delete_rows
    __exnuc_FIfld_set_text     _FIfld_set_text  
    __exnuc_FIfld_get_text     _FIfld_get_text 
    __exnuc_FIg_set_state_off  _FIg_set_state_off
    __exnuc_FIf_set_screen     _FIf_set_screen  
    __exnuc_FIg_set_off_color  _FIg_set_off_color 
    __exnuc_FIf_set_size       _FIf_set_size
    __exnuc_FIg_set_font       _FIg_set_font
    __exnuc_FIf_get_size       _FIf_get_size
    __exnuc_FIf_get_window     _FIf_get_window
    __exnuc_FIg_erase          _FIg_erase
    __exnuc_FIg_set_location   _FIg_set_location
    __exnuc_FIg_display        _FIg_display
    __exnuc_IGE_find_font_id   _IGE_find_font_id
    __exnuc_IGE_calc_text      _IGE_calc_text
    __exnuc_FI_get_form_by_name  _FI_get_form_by_name
    __exnuc_FIf_get_location   _FIf_get_location
    __exnuc_FIg_set_size       _FIg_set_size
    __exnuc_FI_message_box2     _FI_message_box2
    __exnuc_FIf_set_button_event_routine   _FIf_set_button_event_routine
    __exnuc_FIf_set_window_level   _FIf_set_window_level
    __exnuc_FIf_paint_area      _FIf_paint_area
    __exnuc_FIg_set_erase_color      _FIg_set_erase_color
    __exnuc_FIg_activate      _FIg_activate
    __exnuc_FI_translate_color      _FI_translate_color
    __exnuc_stralloc	_stralloc
    __exnuc_FI_strlen      _FI_strlen
	__exnuc_LowerCase		_LowerCase
	__exnuc_XPutBackEvent		_XPutBackEvent
	__exnuc_XCreatePixmapCursor		_XCreatePixmapCursor
	__exnuc_XWindowEvent		_XWindowEvent
	__exnuc_XCheckTypedWindowEvent		_XCheckTypedWindowEvent
	__exnuc_XInternAtom		_XInternAtom
	__exnuc_XParseColor		_XParseColor
	__exnuc_XFree		_XFree
	__exnuc_XCreateColormap		_XCreateColormap
	__exnuc_XtDispatchEvent		_XtDispatchEvent
	__exnuc_XtAddConverter		_XtAddConverter
	__exnuc_XBell		_XBell
	__exnuc_XSetIOErrorHandler		_XSetIOErrorHandler
	__exnuc_XCreateBitmapFromData		_XCreateBitmapFromData
	__exnuc_XtInitialize		_XtInitialize
	__exnuc_XStoreColors		_XStoreColors
	__exnuc_XLookupString		_XLookupString
	__exnuc_XStoreName		_XStoreName
	__exnuc_XConfigureWindow		_XConfigureWindow
	__exnuc_XLowerWindow		_XLowerWindow
	__exnuc_XtSetValues		_XtSetValues
	__exnuc_XtDatabase		_XtDatabase
	__exnuc_XSetErrorHandler		_XSetErrorHandler
	__exnuc_XQueryPointer		_XQueryPointer
	__exnuc_XQueryColors		_XQueryColors
	__exnuc_XSetWMProtocols		_XSetWMProtocols
	__exnuc_XSetClassHint		_XSetClassHint
	__exnuc_XFreeCursor		_XFreeCursor
	__exnuc_XParseGeometry		_XParseGeometry
	__exnuc_XCheckMaskEvent		_XCheckMaskEvent
	__exnuc_XGetWMHints		_XGetWMHints
	__exnuc_XSynchronize		_XSynchronize
	__exnuc_XtWarningMsg		_XtWarningMsg
	__exnuc_XtWindow		_XtWindow
	__exnuc_XSetWMHints		_XSetWMHints
	__exnuc_XDestroyWindow		_XDestroyWindow
	__exnuc_XGetErrorDatabaseText		_XGetErrorDatabaseText
	__exnuc_XUnmapWindow		_XUnmapWindow
	__exnuc_XWithdrawWindow		_XWithdrawWindow
	__exnuc_XMapRaised		_XMapRaised
	__exnuc_XPeekIfEvent		_XPeekIfEvent
	__exnuc_XSync			_XSync
	__exnuc_XFlush			_XFlush
	__exnuc_XPending		_XPending
	__exnuc_XMapWindow		_XMapWindow
	__exnuc_XSetWMNormalHints		_XSetWMNormalHints
	__exnuc_XtAppNextEvent		_XtAppNextEvent
	__exnuc_XCloseDisplay		_XCloseDisplay
	__exnuc_XCreateGC		_XCreateGC
	__exnuc_XCreateWindow		_XCreateWindow
	__exnuc_XGetAtomName		_XGetAtomName
	__exnuc_XtWidgetToApplicationContext		_XtWidgetToApplicationContext
	__exnuc_XTranslateCoordinates		_XTranslateCoordinates
	__exnuc_XrmGetResource		_XrmGetResource
	__exnuc_XDefineCursor		_XDefineCursor
	__exnuc_XFreePixmap		_XFreePixmap
	__exnuc_XGetErrorText		_XGetErrorText
	__exnuc_IGE_translate_color		_IGE_translate_color
	__exnuc_IGEclosest_match_colors	_IGEclosest_match_colors
	__exnuc_XRaiseWindow		_XRaiseWindow
	__exnuc_XGetWindowAttributes		_XGetWindowAttributes
	__exnuc_execvp		_execvp
	__exnuc_select		_select
	__exnuc_FI_calc_text	_FI_calc_text
	__exnuc_FI_find_font_id	_FI_find_font_id
    __exnuc_chdir          _chdir
    __exnuc_seekdir        _seekdir
    __exnuc_FIg_get_text   _FIg_get_text
    __exnuc_FIfld_set_select _FIfld_set_select
    __exnuc_pipe             _pipe
    __exnuc_dup              _dup 
    __exnuc_UMSInitMsg       _UMSInitMsg
    __exnuc_UMSRetPtrByNum   _UMSRetPtrByNum
    __exnuc__UMSReturnByKey  __UMSReturnByKey
    __exnuc__UMSReturnByNum  __UMSReturnByNum
    __exnuc_FIfld_set_num_rows _FIfld_set_num_rows
	__exnuc_Help_set_Xdisplay	_Help_set_Xdisplay
	__exnuc_Help_document	_Help_document
    __exnuc_XNextEvent _XNextEvent
    __exnuc_XGrabPointer _XGrabPointer
    __exnuc_XUngrabPointer _XUngrabPointer
    __exnuc_XCheckTypedEvent _XCheckTypedEvent
    __exnuc_XCheckWindowEvent _XCheckWindowEvent
    __exnuc_XMaskEvent _XMaskEvent
    __exnuc_XCheckIfEvent _XCheckIfEvent
    __exnuc_XIfEvent _XIfEvent
    __exnuc_XSendEvent _XSendEvent
    __exnuc_XIconifyWindow _XIconifyWindow
    __exnuc_XPeekEvent _XPeekEvent
    __exnuc_XQueryTree _XQueryTree
    __exnuc_XGetGeometry _XGetGeometry
    __exnuc_FIf_get_orig_location _FIf_get_orig_location
    __exnuc_SaveRestoreFormsDisplayed  _SaveRestoreFormsDisplayed
#hide linker *            
#export linker
_CEO$action_method_index
_CEO$arg_name_to_value_method_index
_CEO$display_form_by_label_method_index
_CEO$dynamics_method_index
_CEO$erase_form_by_label_method_index
_CEO$error_box_method_index
_CEO$filter_method_index
_CEO$form_notification_method_index
_CEO$get_form_ptr_method_index
_CEO$initial_form_notification_method_index
_CEO$msg_method_index
_CEO$predicate_method_index
_CEO$prompt_method_index
_CEO$read_t_file_method_index
_CEO$real_execute_method_index
_CEO$status_method_index
_CEO_GSLOCATE_debug
_CEO_LOCATE$disconnect_constructed_method_index
_CEO_LOCATE$display_constructed_method_index
_CEO_LOCATE$display_located_method_index
_CEO_LOCATE_debug
_CEO_debug
_COB_persistent_forms
_COBdebFlag_debug
_COBdebugindentlvl
_COBtrace
_CS_path_name
_DIR_G_DIlink_clid
_DIR_G_DImaster_clid
_DIR_G_DIrectory_clid
_DIR_G_DIroot_clid
_DIR_G_IGRdir_clid
_DIR_G_car_dir
_DIR_G_cdpath
_DIR_G_classlist
_DIR_G_count
_DIR_G_cur_dir_id
_DIR_G_cur_dir_name
_DIR_G_cur_dir_os
_DIR_G_dump_count
_DIR_G_dump_grids
_DIR_G_dump_lines
_DIR_G_find_count
_DIR_G_find_grids
_DIR_G_find_lines
_DIR_G_grids
_DIR_G_home_name
_DIR_G_init
_DIR_G_last_dir
_DIR_G_last_id
_DIR_G_last_name
_DIR_G_last_os
_DIR_G_level
_DIR_G_lines
_DIR_G_master_id
_DIR_G_master_os
_DIR_G_options
_DIR_G_prev_cur_id
_DIR_G_prev_cur_name
_DIR_G_prev_cur_os
_DIR_G_root_id
_DIR_G_root_os
_DIR_G_str_dir
_DIR_G_trailer_ids
_DIR_G_trailer_index
_DIR_G_trailers
_DIR_G_untr_count
_DIR_G_untr_dirnames
_DIR_G_untr_objnames
_DIlink$set_target_method_index
_DImaster$give_pointer_method_index
_DIrectory$untranslate_method_index
_DIroot$identify_method_index
_DIstorage$close_method_index
_DIstorage$get_type_method_index
_DIstorage$init_method_index
_DIstorage$is_empty_method_index
_DIstorage$list_method_index
_DIstorage$remove_info_method_index
_DIstorage$retrieve_info_method_index
_DIstorage$sleep_method_index
_DIstorage$store_info_method_index
_DIstorage$wakeup_method_index
_DPcolor_map
_EX_active_OS_num
_EX_active_module
_EX_batch_mode
_EX_cmdlist_ptr
_EX_cmdserver_id
_EX_create
_EX_date
_EX_disp_quiet
_EX_driver_exist
_EX_echo_flag
_EX_entry
_EX_entry_full
_EX_exec_id
_EX_exec_osnum	
_EX_filename
_EX_firstcmd
_EX_global_gap
_EX_global_var
_EX_help_proc_exist
_EX_help_quiet
_EX_index
_EX_kbd_rd
_EX_kbd_wrt
_EX_keybuff
_EX_keyin_cmd
_EX_linebuffer_flag
_EX_locale
_EX_logkbd
_EX_message_locale
_EX_mod_type
_EX_paper_menu
_EX_pnt_entry
_EX_pnt_entry_full
_EX_recallpnt
_EX_runname
_EX_same_file
_EX_seedfile
_EX_text_locale
_EX_version
_EXmem
_GR_G_root
_GR_cur_gr_id
_GR_cur_gr_ind
_GR_cur_gr_name
_GR_cur_gr_os
_GR_cur_gr_type
_GR_prev_gr_name
_GR_system
_GR_validate
_GRoup$change_passwd_method_index
_GRoup$check_passwd_method_index
_GRoup$get_type_method_index
_GRoup$init_method_index
_GRoups$change_group_method_index
_GRoups$give_group_method_index
_GRoups$init_method_index
_GRoups$validate_method_index
_IGEgadget$activate_method_index
_IGEgadget$add_gadget_method_index
_IGEgadget$calc_dep_extents_method_index
_IGEgadget$calc_indep_extents_method_index
_IGEgadget$change_gadget_size_method_index
_IGEgadget$change_process_from_method_index
_IGEgadget$change_process_to_method_index
_IGEgadget$clear_method_index
_IGEgadget$clpicon_method_index
_IGEgadget$convert_pnt_method_index
_IGEgadget$covicon_method_index
_IGEgadget$delicon_method_index
_IGEgadget$dep_extents_method_index
_IGEgadget$indep_extents_method_index
_IGEgadget$movicon_method_index
_IGEgadget$range_intersect_method_index
_IGEingen$generate_method_index
_IGEinlisnr$listen_method_index
_IGEwindow$DPinquire_method_index
_IGEwindow$DPset_method_index
_IGEwindow$change_cusror_def_method_index
_IGEwindow$change_screen_method_index
_IGEwindow$collapse_window_method_index
_IGEwindow$deactivate_method_index
_IGEwindow$display_name_method_index
_IGEwindow$draw_border_method_index
_IGEwindow$passon_method_index
_IGEwindow$pop_window_method_index
_IGEwindow$reactivate_method_index
_IGEwindow$reset_cursor_def_method_index
_IGEwindow$set_collapse_pos_method_index
_IGEwindow$window_cons_method_index
_IGRdir$add_method_index
_IGRdir$dump_method_index
_IGRdir$find_method_index
_IGRdir$i_find_method_index
_IGRdir$init_method_index
_IGRdir$ls_method_index
_IGRdir$pass_method_index
_IGRdir$remove_method_index
_IGRdir$translate_method_index
_IGRdir$unindex_method_index
_MS_Gs_messages_on
_MS_files
_MS_funckey_exists
_MS_menu_panel_name
_MS_menu_strip_name
_MS_menus
_MS_panel_exists
_MS_panel_win_no
_MS_pocket_exists
_MS_pocket_menu_name
_MS_strip_exists
_MS_strip_win_no
_NULL_CHANNUM
_NULL_OBJID
_OD_init
_OD_GS_oden_status
_OMCluster$adjust_spacemap_method_index
_OMCluster$clwrite_method_index
_OMCluster$fault_method_index
_OMCluster$init_OMCluster_method_index
_OMCluster$merge_method_index
_OMCluster$move_method_index
_OMCluster$remove_method_index
_OMFiledOS$get_freelist_ptr_method_index
_OMFiledOS$init_method_index
_OMFiledOS$set_state_method_index
_OMFiledOS$write_method_index
_OMGroup$get_oid_method_index
_OMGroup$init_OMGroup_method_index
_OMGroup$init_spacemap_method_index
_OMGroup$merge_method_index
_OMGroup$mergeinto_method_index
_OMGroup$my_name_method_index
_OMGroup$my_oid_method_index
_OMGroup$pass_method_index
_OMGroup$remove_method_index
_OMISO$dissolve_yourself_method_index
_OMISO$do_dangles_method_index
_OMISO$fixup_for_write_method_index
_OMISO$get_index_oid_method_index
_OMISO$reset_OSnumber_method_index
_OMISO$resolve_yourself_method_index
_OMISO$set_OSnumber_method_index
_OMISO$unlink_all_method_index
_OMISO$unlink_entry_method_index
_OMMOSD$MOSD_init_method_index
_OMMOSD$add_entry_method_index
_OMMOSD$delete_entry_method_index
_OMMOSD$get_OS_list_method_index
_OMMOSD$modified_OS_wrt_method_index
_OMMOSD$modify_entry_method_index
_OMMOSD$pass_method_index
_OMMOSD$pass_thru_method_index
_OMMOSD$restore_envr_method_index
_OMMOSD$save_envr_method_index
_OMMOSD$translate_entry_method_index
_OMOSCO$add_class_method_index
_OMOSCO$get_res_cnum_method_index
_OMOSCO$initialize_method_index
_OMOSCO$set_up_method_index
_OMObjSpace$add_class_method_index
_OMObjSpace$change_name_method_index
_OMObjSpace$cleanup_method_index
_OMObjSpace$dissolve_ISOs_method_index
_OMObjSpace$execute_method_index
_OMObjSpace$find_iso_method_index
_OMObjSpace$fix_osd_method_index
_OMObjSpace$fixup_for_write_method_index
_OMObjSpace$get_iso_method_index
_OMObjSpace$get_status_method_index
_OMObjSpace$init_OMObjSpace_method_index
_OMObjSpace$make_iso_entry_method_index
_OMObjSpace$pass_method_index
_OMObjSpace$print_isodir_method_index
_OMObjSpace$remove_iso_method_index
_OMObjSpace$resolve_ISOs_method_index
_OMObjSpace$translate_group_name_method_index
_OMObjSpace$update_isodir_method_index
_OMSupGroup$add_member_method_index
_OMSupGroup$find_method_index
_OMSupGroup$init_OMSupGroup_method_index
_OMSupGroup$pass_method_index
_OMSupGroup$remove_member_method_index
_OMSupGroup$verGraph_method_index
_OMTag$get_record_vla_method_index
_OMTag$initialize_method_index
_OMTag$insert_tag_method_index
_OMTag$remove_tag_method_index
_OMTag$set_up_method_index
_OMTagCon$add_method_index
_OMTagCon$identify_yourself_method_index
_OMTagCon$initialize_method_index
_OMTagCon$prep_write_method_index
_OMTagCon$reconnect_method_index
_OMTagCon$remove_method_index
_OMTagCon$set_up_method_index
_OM_GA_CSDarray
_OM_GA_FCDs_AVG
_OM_GA_IntrcptHshTbl
_OM_GA_OSDs
_OM_GA_active_classes
_OM_GA_active_to_filed
_OM_GA_class_hash
_OM_GA_fa_mapsize
_OM_GA_filed_to_active
_OM_GA_known_classes
_OM_GA_p_tag_hashtable
_OM_GA_p_tagcon
_OM_GA_param_defs
_OM_GA_rtree_ops
_OM_GA_shmftok_file
_OM_GA_sig_func
_OM_GA_tag_oids
_OM_GO_TransOS_0
_OM_GO_current_MOSD
_OM_GO_current_OS_objid
_OM_GQ_PCDavail
_OM_GQ_bigCSDavail
_OM_GQ_regCSDavail
_OM_GS_NULL_MESSAGE
_OM_GS_NULL_NEIGHBOR
_OM_GS_NULL_SPAMAPENT
_OM_Gf_ReclustFlag
_OM_Gf_bugcheck_fatal
_OM_Gf_check_chan_dups
_OM_Gf_errToStdout
_OM_Gf_fileLocking
_OM_Gf_getAllStats
_OM_Gf_getClusterStats
_OM_Gf_getStatistics
_OM_Gf_lockingOff
_OM_Gf_makedefTransOS
_OM_Gf_min_caching_send
_OM_Gf_tagged_connects
_OM_Gf_tagging_enabled
_OM_Gf_unk_obj_support
_OM_Gf_useShm
_OM_Gf_val_cluster
_OM_Gf_validate_OS
_OM_Gf_verbose_error
_OM_Gf_verbose_warning
_OM_Gi_CSDarrayNextSlot
_OM_Gi_CSDarraySize
_OM_Gi_FCDs_ALLOCATED
_OM_Gi_FCDs_USED
_OM_Gi_LCFqueueDepth
_OM_Gi_UNIXpageSize
_OM_Gi_defMOSD_extobjs
_OM_Gi_defMOSD_numobjs
_OM_Gi_defchan_ext
_OM_Gi_defchan_size
_OM_Gi_faultinBytes
_OM_Gi_faultinTicks
_OM_Gi_filedOS_extobjs
_OM_Gi_filedOS_numobjs
_OM_Gi_guaranteedSheap
_OM_Gi_initObjMem_alloc
_OM_Gi_maxObjStorage
_OM_Gi_maxShmRegions
_OM_Gi_maxchan_size
_OM_Gi_numFaults
_OM_Gi_numMemRegions
_OM_Gi_numShmRegions
_OM_Gi_objMem_extPercent
_OM_Gi_objMem_extSize
_OM_Gi_ops_count
_OM_Gi_ops_head
_OM_Gi_ops_tail
_OM_Gi_percentAvMem
_OM_Gi_percentSheap
_OM_Gi_percent_extend_chan
_OM_Gi_percent_extend_sm
_OM_Gi_percent_extend_tag
_OM_Gi_record_ops
_OM_Gi_sheapSize
_OM_Gi_slotGrowthFactor
_OM_Gi_tagcon_slot
_OM_Gi_totalObjMem
_OM_Gi_transOS_extobjs
_OM_Gi_transOS_numobjs
_OM_GpA_objStorageBaseAddrs
_OM_GpA_objStorageShmids
_OM_GpA_objStorageSizes
_OM_Gp_CurOSD
_OM_Gp_CurSpaceMap
_OM_Gp_FCD_HEAD
_OM_Gp_NULL_MESSAGE
_OM_Gp_NULL_NEIGHBOR
_OM_Gp_NULL_SPAMAPENT
_OM_Gp_RtreeOids
_OM_Gp_curOMD
_OM_Gp_objStorage
_OM_Gp_objStorageBase
_OM_Gp_orig_osname
_OM_Gp_reclustFName
_OM_Gp_reclustFunc
_OM_Gp_reclustIfile
_OM_Gp_reclustOfile
_OM_Gp_reclustSfile
_OM_Gp_regSlotBottom
_OM_Gp_sheapBase
_OM_Gp_statFile
_OM_Gp_statFileName
_OM_Gp_sysgenPath
_OM_Gw_RO_OS_count
_OM_Gw_TransOSnum_0
_OM_Gw_current_OS
_OM_Gw_defISO_ext
_OM_Gw_defISO_size
_OM_Gw_defISOdir_ext
_OM_Gw_defISOdir_size
_OM_Gw_first_OS_avail
_OM_Gw_known_class_max
_OM_Gw_last_opp_minor_version
_OM_Gw_major_version
_OM_Gw_maxOS
_OM_Gw_min_opp_major_version
_OM_Gw_minor_version
_OM_Gw_next_class_index
_OM_Gw_numclasses
_OM_Gw_senders_OS
_OM_Gw_tag_hash_extendsize
_OM_Gw_tag_hashtable_size
_OM_Gw_tag_rec_extendsize
_OM_Gw_tagcon_inc
_OM_Gw_tagged_osnum
## Ugly OM swapping globaldata that will have to be uncommented-out
## here if we ever build with SWAPPING again
## _OM_Gw_majCCCPVersion
## _OM_Gw_minCCCPVersion
## _OM_GF_prevUSR2func
## _OM_GQ_LockedClusters
## _OM_Gf_getLumpStats
## _OM_Gf_getSwapStats
## _OM_LUMPOP_SEMID
## _OM_Gf_ownAdjustQuota
## _OM_Gf_ownLumpOp
## _OM_Gi_LCQsearchDepth
## _OM_Gi_PinswapBytes
## _OM_Gi_PinswapTicks
## _OM_Gi_PnumInswaps
## _OM_Gi_PnumOutswaps
## _OM_Gi_PoutswapBytes
## _OM_Gi_PoutswapTicks
## _OM_Gi_collapsePercentFull
## _OM_Gi_inswapBytes
## _OM_Gi_inswapTicks
## _OM_Gi_numCollapse
## _OM_Gi_numInswaps
## _OM_Gi_numNoWrtInSwaps
## _OM_Gi_numNoWrtOutSwaps
## _OM_Gi_numOutswaps
## _OM_Gi_outswapBytes
## _OM_Gi_outswapTicks
## _OM_Gi_quotaDesire
## _OM_Gi_quotaPriority
## _OM_Gp_CCB
## _OM_Gp_CCCP
_OMbtree$OMbtree_constr_method_index
_OMbtree$btree_contents_method_index
_OMbtree$btree_dump_method_index
_OMbtree$range_pass_method_index
_OMbtree$seqpass_method_index
_OMindex$add_method_index
_OMindex$neighbor_method_index
_OMindex$pass_method_index
_OMindex$remove_method_index
_OMindex$translate_method_index
_OMrtree$OMrtree_constr_method_index
_OMrtree$control_method_index
_OMrtree$find_and_remove_method_index
_OMrtree$find_key_method_index
_OMrtree$get_stat_method_index
_OMrtree$replace_method_index
_OMrtree$seed_method_index
_OMrtree$skew_pass_method_index
_OMrtree$writeKeys_method_index
_OMtime
_OPP_CEO_class_id
_OPP_DIbst_class_id
_OPP_DIbstgr_class_id
_OPP_DIbstob_class_id
_OPP_DIbtree_class_id
_OPP_DIlink_class_id
_OPP_DImaster_class_id
_OPP_DIrectory_class_id
_OPP_DIroot_class_id
_OPP_DIstorage_class_id
_OPP_EX_bckup_class_id
_OPP_EX_close_class_id
_OPP_EX_defbut_class_id
_OPP_EX_dig_class_id
_OPP_EX_exit_class_id
_OPP_EX_fbackup_class_id
_OPP_EX_file_class_id
_OPP_EX_funcky_class_id
_OPP_EX_hdcpy_class_id
_OPP_EX_menuchk_class_id
_OPP_EX_plot_class_id
_OPP_EX_pricmd_class_id
_OPP_EX_rclkeyin_class_id
_OPP_EX_retri_class_id
_OPP_EX_save_class_id
_OPP_EX_saveas_class_id
_OPP_EX_swapmenu_class_id
_OPP_EX_switch_class_id
_OPP_EX_test_class_id
_OPP_EX_ver_class_id
_OPP_GRoup_class_id
_OPP_GRoups_class_id
_OPP_IGEgadget_class_id
_OPP_IGEingen_class_id
_OPP_IGEinlisnr_class_id
_OPP_IGEwindow_class_id
_OPP_IGEwsys_class_id
_OPP_IGRdir_class_id
_OPP_OMCluster_class_id
_OPP_OMFiledOS_class_id
_OPP_OMGroup_class_id
_OPP_OMISO_class_id
_OPP_OMMOSDOS_class_id
_OPP_OMMOSD_class_id
_OPP_OMOSCO_class_id
_OPP_OMObjSpace_class_id
_OPP_OMSupGroup_class_id
_OPP_OMTagCon_class_id
_OPP_OMTag_class_id
_OPP_OMTransOS_class_id
_OPP_OMbtree_class_id
_OPP_OMindex_class_id
_OPP_OMlnkbtree_class_id
_OPP_OMrtree_class_id
_OPP_Root_class_id
_OPP_cmdserver_class_id
_OPP_exec_class_id
_OPP_global_class_class_id
_OPP_module_class_id
_OPP_super_cmd_class_id
_Root$ARread_method_index
_Root$ARwrite_method_index
_Root$connect_method_index
_Root$copy_chan_method_index
_Root$debug_method_index
_Root$delete_method_index
_Root$disconnect_method_index
_Root$move_chan_method_index
_Root$range_disconnect_method_index
_Root$set_operation_method_index
_Root$unknown_method_index
_Root$wild_disconnect_method_index
_absdig_id
_actions_debug
_active_module_num
_circf
_cmdserver$disconnect_from_stack_method_index
_cmdserver$exec_cs_method_index
_cmdserver$init_cs_method_index
_cmdserver$sleep_cs_method_index
_cmdserver$wakeup_cs_method_index
_dump_debug
_event_queue_back
_event_queue_front
_exec$passon_method_index
_exec$wait_for_input_method_index
_exec$wake_up_method_index
_global_class$place_method_index
_global_class$sleep_method_index
_global_class$super_construct_method_index
_global_class$wake_up_method_index
_invisible_table
_loc1
_loc2
_locs
_module$GRmd_active_method_index
_module$GRmd_add_super_method_index
_module$GRmd_deactive_method_index
_module$GRmod_passon_method_index
_module$execute_mod_method_index
_module$get_chan_cnt_method_index
_module$get_chan_obj_method_index
_module$mod_info_method_index
_module$mod_init_method_index
_module$sleep_method_index
_module$wake_up_method_index
_module_data
_module_table
_nbra
_no_modules
_num_log_colors
_read_debug
_sed
_state_debug
_super_cmd$abort_method_index
_super_cmd$cmd_name_method_index
_super_cmd$execute_method_index
_super_cmd$form_input_method_index
_super_cmd$get_command_info_method_index
_super_cmd$help_method_index
_super_cmd$help_topic_method_index
_super_cmd$init_method_index
_super_cmd$sleep_method_index
_super_cmd$status_disp_method_index
_super_cmd$undo_method_index
_super_cmd$wakeup_method_index
_term_info
_timer_no
_trans_debug
_EX_ACTINV_OS_num
_cmdserver$clear_stack_method_index
_OM_Gw_max_modules
_OM_Gw_max_ref_files
_EX_dup_os_occured
_OM_Gf_dload_unresolved
_EX_Gf_defmsgfont
_EXdisplay
_EXgc
_EXscreen
_EX_win
_EX_scr
_EXweight
_EX_stopproc_id
_EXNUCX_appl_version_id
