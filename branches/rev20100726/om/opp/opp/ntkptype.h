#define abs_array_dcltr 65536
#define abs_fun_dcltr 65537
#define abs_pointer_dcltr 65538
#define array_access 65539
#define array_dcltr 65540
#define bin_exp 65541
#define break_stmt 65542
#define case_label 65543
#define compound_stmt 65544
#define cond_exp 65545
#define continue_stmt 65546
#define decl_specifier 65547
#define default_label 65548
#define do_stmt 65549
#define e_stmt 65550
#define enum_dcltr 65551
#define enum_dcltr_body 65552
#define enum_dcltr_list 65553
#define enum_specifier 65554
#define for_stmt 65555
#define formal_declaration 65556
#define formal_declaration_list 65557
#define function_call 65558
#define function_dcltr 65559
#define goto_stmt 65560
#define if_stmt 65561
#define init_dcltr 65562
#define init_exp 65563
#define inst_access_exp 65564
#define instance_specifier 65565
#define labeled_stmt 65566
#define list_exp 65567
#define list_init_dcltr 65568
#define list_init_expr 65569
#define list_struct_dcltr 65570
#define list_struct_delcaration 65571
#define local_data_declaration 65572
#define message_buff 65573
#define name_label 65574
#define null_stmt 65575
#define opt_decl_list 65576
#define opt_stmt_list 65577
#define p1_abs_dcltr 65578
#define p1_dcltr 65579
#define paren_exp 65580
#define pointer_dcltr 65581
#define postfix_exp 65582
#define return_stmt 65583
#define sizeof_fun 65584
#define string_constant 65585
#define struct_access 65586
#define struct_dcltr 65587
#define struct_declaration 65588
#define struct_pointer_access 65589
#define struct_specifier 65590
#define switch_stmt 65591
#define type_cast 65592
#define typename_declaration 65593
#define unary_exp 65594
#define union_specifier 65595
#define while_stmt 65596



struct pnode
 {
  int typ;
  struct pnode *l[1];
 };
