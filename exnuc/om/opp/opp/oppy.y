/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* oppy.y - yacc code for opp parser					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global Functions :							*/
/*	yyparse  - called to parse an opp program			*/
/*									*/
/* Global Variables :							*/
/*	active_class - points to class definition struture for the	*/
/*		       class or .I being compiled.			*/
/*									*/
/* As of this writing:							*/
/*	5  shift-reduce conflicts					*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

/* All token names are in upper case.  Non-terminals in lower case. */
%{
#define YYMAXDEPTH 2000
#include <stdio.h>
#include <cppout.h>
#include <malloc.h>

#include "oppydefs.h"
#include "opp.h"
#include "dcltrs.h"
#include "dumpmessage.h"
#include "lex3.h"
#include "typeinfo.h"
#include "carriers.h"
#include "class.h"
#include "cpp.h"
#include "quefree.h"
#include "exsysdep.h"
#include "kutil.h"
#include "fio.h"
#include "lexinput.h"
#include "oppface.h"
#include "relations.h"

/* this stuff was added for ptrees ********/
#include "k.h"
#include "../opp/kptype.h"
static char is_typedef[100]=
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
static int iti=0;
static int is_extern = 0;
static int *p_inline_send = 0;
static int inline_send = 0;

/******************************************/

/* Global Variable Definitions */
struct opp_class_def *active_class = NULL;

/* Module Global Variables */
static identifier_ptr class_from_which_importing;
static int active_chan_init, active_chan_incr, active_chan_att;
static char *active_chan_other_chan;
#define default_chan_att CHAN_ATT_MM

%}
%union
{
 int i;
 identifier_ptr sym;
 carrier_ptr carry;
 struct Type_Info type_info;
}

/*
   Once IDENTIFIERS have been entered into the symbol table they are
   transformed into other token types which are returned when they
   are encountered later in the text.  The tok field in the symbol
   table record is used to determine this.  Thus, IDENTIFIER is only used
   when a previously undefined name is to appear.  In other cases,
   a symbol which has been defined as a certain kind of thing is expected.
*/

%token <i> NULL_TOKEN

/* Tokens and types for channels */

%token <i> INCREMENT INITIAL REL_ORDERED ABS_ORDERED
%token <i> ONE_TO_ONE ONE_TO_MANY MANY_TO_ONE MANY_TO_MANY

%type <carry> parent_class_list
%type <sym> channel_header
%type <sym> class_list opt_class_list 
%type <i>   opt_chan_attributes sidedness orderedness
%type <i> function_body

/* Tokens and types for classes */
%token <sym> IDENTIFIER CHANNEL_NAME TYPEDEF_NAME STRUCT_NAME ENUM_TAG ENUM_NAME
%token <sym> VAR_NAME UNION_NAME CLASS_NAME FIELD_NAME MESSAGE_NAME
%token <type_info> AUTO STATIC EXTERN REGISTER TYPEDEF VARIABLE
%token <i> DEC_INT 
%token <type_info> CHAR FLOAT DOUBLE INT SHORT LONG SIGNED UNSIGNED NOMOD PRIVATE VOID

%token <i> SPECIFICATION IMPLEMENTATION OF INSTANCE END CHANNEL
%token <i> MESSAGE METHOD IS 
%token <i> FROM IMPORT OVERRIDE

%token <i> ME BIG_ME SQOINTER

/* C tokens */

%token <i> AND_AND AND_EQUAL BREAK CASE CHAR_CONST STR_CONST CONTINUE CONST
%token <i> DEFAULT DIV_EQUAL DO ELSE ENUM EQ ELLIPSIS
%token <i> FLOAT_CONST FOR GEQ GOTO HEX_INT IF LEFT_SHIFT
%token <i> LEQ LSHIFT_EQUAL MINUS_EQUAL MINUS_MINUS MOD_EQUAL NOT_EQ OCT_INT
%token <i> OR_EQUAL OR_OR PLUS_EQUAL PLUS_PLUS POINTER
%token <i> RETURN RIGHT_SHIFT RSHIFT_EQUAL SIZEOF
%token <i> STRUCT SWITCH TIMES_EQUAL UNION VOLATILE
%token <i> WHILE XOR_EQUAL 

%token <i> ';' '+' '-' '\\' '/' ':' '[' ']' '{' '}' '(' ')'
%token <i> '*' '&' '|' '^' '%' '!' '~' '=' '.' ',' '?' '<' '>'

/* end of C tokens */

%token <i> INHERIT REJECT SAFEBLOCK TAGGABLE NOT_TAGGABLE

%type <type_info> std_class tc_specifier size_spec type_qualifier
%type <type_info> type_specifier opt_decl_specifier decl_specifier
%type <sym> p2_fun_dcltr_header
%type <type_info> std_type enum_specifier
%type <sym> opt_str_tag dcltr func_arg_dcltr p4_abs_dcltr
%type <sym> p1_abs_dcltr p2_abs_dcltr p3_abs_dcltr e_abs_dcltr abs_dcltr
%type <type_info> struct_header union_header struct_specifier
%type <sym> struct_declaration list_struct_dcltr struct_dcltr
%type <sym> formals_declaration formals_decl
%type <sym> m_arg_list m_arg instance_decl func_arg
%type <sym> list_struct_declaration opt_list_init_dcltr
%type <sym> message_decl message_header
%type <sym> import_message_name override_message_name qualident
%type <sym> enum_6 enum_7 en_tag_dcltr name_dcltr init_dcltr list_init_dcltr
%type <sym> p1_dcltr p2_dcltr spec_header spec_file impl_file impl_file0
%type <sym> program new_import_class spec_header_1 spec_header_0 identifier
%type <sym> impl_header instance_header maybe_identifier declared_symbol
%type <sym> list_inst_declaration inst_declaration import_list import_header
%type <sym> class_name method_head function_header parent_class_name
%type <sym> reject_list_decl override_list_decl override_list list_dcltr
%type <sym> parameter_decl_list parameter_declaration
%type <sym> inherit_header reject_message_name reject_list taggable_decl not_taggable_decl

%type <i> literal paren_exp primary_p1_exp primary_exp postfix_exp
%type <i> prefix_exp cast_exp unary_oper_exp mult_oper_exp
%type <i> add_oper_exp shift_oper_exp rel_oper_exp equ_oper_exp
%type <i> bitand_oper_exp bitxor_oper_exp bitor_oper_exp and_oper_exp
%type <i> or_oper_exp cond_exp exp list_exp 

/* hello and welcome to the demo */

%type <i> p_abs_dcltr p_add_op p_add_oper_exp p_and_oper_exp
%type <i> p_asgn_op p_assign_exp p_bitand_oper_exp p_bitor_oper_exp
%type <i> p_bitxor_oper_exp p_break_stmt p_case_label p_cast_exp
%type <i> p_compound_stmt p_cond_exp p_continue_stmt
%type <i> p_dcltr p_decl_specifier p_default_label p_do_stmt
%type <i> p_e_abs_dcltr p_e_stmt p_en_tag_dcltr p_enum_dcltr
%type <i> p_enum_dcltr_body p_enum_dcltr_list p_enum_name p_enum_specifier
%type <i> p_equ_op p_equ_oper_exp p_exp p_field_name p_for_stmt
%type <i> p_formal_declaration p_formal_declaration_list p_formals_declaration
%type <i> p_goto_stmt p_id_name p_if_stmt p_ifelse_stmt p_init_dcltr
%type <i> p_init_exp p_inst_access_exp p_label p_label_name p_list_exp
%type <i> p_list_init_dcltr p_list_init_exp p_list_struct_dcltr
%type <i> p_list_struct_declaration p_literal p_local_data_declaration
%type <i> p_message_buff p_mult_op p_mult_oper_exp p_string_constant
%type <i> p_name_dcltr p_name_label p_negate_op p_null_stmt p_opt_decl_list
%type <i> p_opt_list_exp p_opt_stmt_list
%type <i> p_or_oper_exp p_p1_abs_dcltr p_p1_dcltr p_p2_abs_dcltr
%type <i> p_p2_dcltr p_p3_abs_dcltr p_p3_dcltr p_paren_exp p_postfix_exp
%type <i> p_postfix_op p_prefix_exp p_prefix_op p_primary_exp p_primary_p1_exp
%type <i> p_primary_p2_exp p_rel_op p_rel_oper_exp p_return_stmt
%type <i> p_shift_op p_shift_oper_exp p_std_class p_std_type p_stmt
%type <i> p_stmt_a p_str_tag_dcltr p_struct_dcltr p_struct_declaration
%type <i> p_struct_name p_struct_specifier p_switch_stmt p_tc_specifier
%type <i> p_type_specifier p_typedef_name p_typename_declaration
%type <i> p_type_qualifier p_p4_abs_dcltr p_formal_dcltr
%type <i> p_un_tag_dcltr p_unary_oper_exp p_union_name p_while_stmt

%%

program :
	  spec_file
          {
	   $1->classdef->component_count =
            find_components ($1, &$1->classdef->component_list);
          }
	| impl_file
	; /* program */

identifier :
	  IDENTIFIER
	| declared_symbol
	;

maybe_identifier :
	  IDENTIFIER
	| declared_symbol
	 {
          identifier_ptr p;
 	  symtab_ptr tab;

	  switch ($1->s.tok)
	   {
            case STRUCT_NAME :
	    case UNION_NAME :
	    case ENUM_NAME : tab = tag_table; break;

	    default : tab = sym_table;
	   }

          p = (identifier_ptr)lookup_local_symbol (tab, $1->s.s.name);

  	  if (p == $1 && !p->field_link && 
	      (p->s.tok == STRUCT_NAME || p->s.tok == UNION_NAME))
           $$ = p;
	  else
	   {
	    $$ = new_identifier ($1->s.s.name);

	    if (p != $1)
	     enter_symbol (tab, $$);
	    else
	     {
#if defined(SUNOS)
	       $$->copy_of_me = $1;
#elif defined(CLIX) || defined(IRIX) || defined(NT)
	      if ($1->type_info.std_class == extern_class || is_extern ||
	           $1->type_info.std_class == noclass)
	       $$->copy_of_me = $1;
	      else
	       {
	        printerr (1);
	        fprintf (stderr, "illegal redeclaration of %s\n", $1->s.s.name);
	  	file_traceback ();
	       }
#else
#error Unknown OS
#endif
	     }
	   }
	 }

declared_symbol :
	  CHANNEL_NAME
	| STRUCT_NAME
	| ENUM_NAME
	| ENUM_TAG
	| VAR_NAME
	| UNION_NAME
	| CLASS_NAME
	| FIELD_NAME
	| MESSAGE_NAME
	;

spec_file :
	 spec_header spec_body END SPECIFICATION identifier ';'
	 {
	   if (strcmp($1->s.s.name,$5->s.s.name))
	    {
	     printerr (1);
	     fprintf (stderr, " ending class name \"%s\" missmatch.\n",
	    	      $5->s.s.name);
	     file_traceback ();
	    }

	   reverse_fields (&$1->classdef->messages);
	   $1->link = $1->classdef->messages;
 	   $1->index = $1->classdef->message_count;
	 }  
	; /* spec_file */

spec_header_0 :
	  IDENTIFIER SPECIFICATION identifier
	  {
           if (strcmp("class", $1->s.s.name))
            {
	     printerr (1);
	     fprintf (stderr, " expected \"class\", got \"%s\"\n", $1->s.s.name);
	     file_traceback ();
            }
	   /* remove class from symbol table */
	   remove_symbol(sym_table, $1);
	   $$ = $3;
	   if ($3->s.tok != CLASS_NAME)
	    {
	     printerr (1);
	     fprintf (stderr, " Class name must be same as file name.\n");
	     file_traceback ();
	    }
  	   else
            $3->index = 0;
	  }
	;

spec_header_1 :
	  spec_header_0
	  {
	   printerr (0);
	   fprintf (stderr, " no version specified for class %s.\n", $1->s.s.name);
	   file_traceback ();
	   $1->classdef->major_version = 0;
	   $1->classdef->minor_version = 0;
	  }
	| spec_header_0 '(' exp ':' exp ')'
	  {
	   $1->classdef->major_version = $3;
	   $1->classdef->minor_version = $5;
	  }
	;

class_name :
	  maybe_identifier
	;

class_list :
	  class_name { $1->link = 0; $1->flags |= F_IDENTIFIER_MARKED; }
	| class_list ',' class_name
	  {
	   if ($3->flags & F_IDENTIFIER_MARKED)
	    {
	     printerr (1);
	     fprintf (stderr, " redeclaration of %s ignored.\n",$3->s.s.name);
	     file_traceback ();
	    }
	   else
	    {
	     $$ = $3;
	     $3->link = $1;
	     $3->flags |= F_IDENTIFIER_MARKED;
	    }
	  }
	;

opt_class_list :
	  {$$ = NULL; }/* empty */
	| class_list ';'
	| class_name '.' maybe_identifier ';'
	  {
	   $1->link = 0;
	   $1->flags |= F_IDENTIFIER_MARKED;
	   active_chan_att |= CHAN_ATT_RES;
	   active_chan_other_chan = $3->s.s.name;
	  }
	;

parent_class_name :
	  IDENTIFIER
	| CLASS_NAME
	;

parent_class_list :
	  parent_class_name
	  {
	   if (!strcmp ($1->s.s.name, active_class->name))
	    $$ = 0;
	   else
	    {
	     $$ = carrier_node ($1);
	     $$->next = 0;
	    }
	  }
	| parent_class_list ',' parent_class_name
	  {
	   if (strcmp($3->s.s.name, active_class->name))
	    {
	     $$ = carrier_node ($3);
	     $$->next = $1;
	    }
	  }
	;

spec_header :
	 spec_header_1 OF parent_class_list ';'
	 { 
           hook_up_parents ($1->classdef, $3); 
	 }
	; /* spec_header */

spec_body :
	  /* empty */
	| spec_body spec_decl
	; /* spec_body */

spec_decl :
	  spec_data_declaration
	| override_list_decl
	| reject_list_decl
	| message_decl
	| inherit_list_decl
	| taggable_decl
	| not_taggable_decl
	;

taggable_decl :
	  TAGGABLE ';'
	  {
	   if (active_class->flags & F_CLASS_NOT_TAGGABLE)
	    {
	     printerr(1);
	     fprintf(stderr, " class already set not_taggable.\n");
	     file_traceback();
	    }
           else
	    active_class->flags |= F_CLASS_TAGGABLE;
	  }
	;

not_taggable_decl :
	  NOT_TAGGABLE ';'
	  {
	   if (active_class->flags & F_CLASS_TAGGABLE)
	    {
	     printerr(1);
	     fprintf(stderr, " class already set taggable.\n");
	     file_traceback();
	    }
           else
 	    active_class->flags |= F_CLASS_NOT_TAGGABLE;
	  }
	;

inherit_list_decl :
	  inherit_header inherit_list ';'
	  {
	   sym_table = active_class->sym_tab;
	  }
	;

inherit_header :
	 FROM CLASS_NAME INHERIT 
	  {
           class_from_which_importing = $2;
	   $$ = $2;
	   sym_table = $2->classdef->sym_tab;
	  }
	;

inherit_message_name :
	  identifier
	  {
	   verify_inherited_message ($1, class_from_which_importing);
	  }
	;

inherit_list :
	  inherit_message_name
	| inherit_list ',' inherit_message_name
	;

reject_message_name :
	  qualident
	  {
 	   if ($1->s.tok == MESSAGE_NAME)
	    {
	     carrier_ptr cp = carrier_node ($1);

	     cp->next = active_class->reject_list;
	     active_class->reject_list = cp;
	    }
 	   else
 	    {
             $$ = NULL;
 	     printerr (1);
 	     fprintf (stderr, " %s is not a message name.\n",$1->s.s.name);
	     file_traceback ();
	    }
	  }
	;

reject_list :
	  reject_message_name
	| reject_list ',' reject_message_name
	;

reject_list_decl :
	 REJECT reject_list ';'
	  { $$ = $2; }
	;

override_list_decl :
	 OVERRIDE override_list ';'
	  { $$ = $2; }
	;

qualident :
	  identifier
	| CLASS_NAME '.'
	  {
	   sym_table = $1->classdef->sym_tab;
	  }
	  identifier
	  {
	   sym_table = active_class->sym_tab;
	   $$ = $4;
	  }
	;

override_message_name :
	  qualident
	  {
 	   if ($1->s.tok == MESSAGE_NAME || $1->s.tok == CLASS_NAME)
	    {
	     carrier_ptr cp = carrier_node ($1);

	     cp->next = active_class->override_list;
	     active_class->override_list = cp;
	    }
 	   else
 	    {
             $$ = NULL;
 	     printerr (1);
 	     fprintf (stderr, " %s is not a message name.\n",$1->s.s.name);
	     file_traceback ();
	    }
	  }
	;

override_list :
	  override_message_name
	| override_list ',' override_message_name
	;

instance_header :
	  INSTANCE CLASS_NAME '{' 
	  {
	   $$ = $2;
           increment_symbol_level(sym_table);
	  }
	;

instance_decl :
	  instance_header list_inst_declaration '}' 
          {
   	   if ($1->field_link)
	    {
	     printerr(0);
	     fprintf (stderr, "redeclaration of instance %s.\n",$1->s.s.name);
	     file_traceback ();
	    }
	   else
	    {
	     reverse_fields (&$2);
	     $1->field_link = $1->classdef->instance_fields = $2;
	    }
	   decrement_symbol_level (sym_table, NULL);
	  }
	;
	
message_decl :
	  message_header m_arg_list ')' ';'
	  {
 	   messagefy_dcltrs ($2);
	   $1->field_link = $2;
	   $1->classdef = active_class;
  	   $1->link = active_class->messages;
	   active_class->messages = $1;
	   reverse_fields (&($1->field_link));
	   decrement_symbol_level (sym_table, 0);
	  } 
	;

message_header :
	  MESSAGE maybe_identifier '('
	  {
	   increment_symbol_level(sym_table);
	   $$ = $2;
	   $2->s.tok = MESSAGE_NAME;
	   $2->index = active_class->message_count++; /* method selector */
	  }
	;

m_arg_list :
	  m_arg
	| m_arg_list ';' m_arg { $$ = append_fields ($1, $3); }
	; /* m_arg_list */

m_arg	:
	  { $$ = NULL; }/* empty */
	|
	  decl_specifier list_struct_dcltr 
	  {
	    $$ = $2;
	    setlisttype ($2, $1, FIELD_NAME);
	  }
	; /* m_arg */

impl_file0 :
	 impl_header 
	 {
	  dump_total_instance ($1);
	  dump_known_msg_structs ($1);
	 }
	; /* impl_file */

impl_file :
	 impl_file0 impl_body END IMPLEMENTATION CLASS_NAME ';'
	 {
	   if (strcmp($1->s.s.name,$5->s.s.name))
	    {
	     printerr (1);
	     fprintf (stderr, " ending class name \"%s\" missmatch.\n",
	    	      $5->s.s.name);
	     file_traceback ();
	    }
	 }
	; /* impl_file */

impl_header :
	 IDENTIFIER IMPLEMENTATION IDENTIFIER ';'
	 {
	  struct opp_class_def *my_class;

           if (strcmp("class", $1->s.s.name))
            {
	     printerr (1);
	     fprintf (stderr, " expected \"class\", got \"%s\"\n", $1->s.s.name);
	     file_traceback ();
            }
	   /* remove class from symbol table */
	  remove_symbol(sym_table, $1);

	  $$ = $3;
	  ++cur_out_line;
	  $3->s.tok = CLASS_NAME;
	  active_class = $3->classdef = new_class ($3->s.s.name);
	  active_class->member_of_build = 1;
	  active_class->sym_tab = sym_table;
          active_class->tag_tab = tag_table;
	  active_class->omdef_tab = active_stream->omdef_table;
	  active_class->define_tab = active_stream->define_table;
 	  active_class->filename_tab = active_stream->file_table;
	  
	  /* setup to read spec for this class */
	  lookup_class ($3->s.s.name, &my_class);
	  $3->field_link = my_class->instance_fields;
	  dump_inherited_types (my_class, 0);
	  
	  attach_tables (active_class, my_class);

	  $3->classdef->override_list = my_class->override_list;
	  $3->classdef->parent_count = my_class->parent_count;
	  $3->classdef->A_parents = my_class->A_parents;
	  $3->classdef->messages = my_class->messages;
	  $3->classdef->instance_fields = my_class->instance_fields;
	  $3->classdef->component_list = my_class->component_list;
	  $3->classdef->component_count = my_class->component_count;
	  Ideclare_component_ids ($3);
	 }
	;

impl_body :
	  /* empty */
	| impl_body impl_declaration 
	;

impl_declaration :
	  top_level_declaration
	| import_declaration
	| method_declaration
	;

method_declaration :
	  method_head m_arg_list ')'
	  {
           inline_send = 0;
	   reverse_fields (&($2));
 	   messagefy_dcltrs ($2);
	   decrement_symbol_level (sym_table, que_free);
	   decrement_symbol_level (tag_table, process_purged_identifier);
	   verify_method (&($1), &($2));
	   building_ptree = 1;
           p_inline_send = &inline_send;
	  }
          p_compound_stmt
          {
           ptree_meth_body ((struct pnode *)$5,&($1),&($2),inline_send);
	   free_que();
	   building_ptree = 0;
	   p_inline_send = 0;
           inline_send = 0;
          }
	;

method_head :
	  METHOD qualident '('
	  {
	   increment_symbol_level(sym_table);
           increment_symbol_level(tag_table);
	   $$ = $2;
	  }
	;

import_declaration :
	  import_header import_list ';'
	  {
	   sym_table = active_class->sym_tab;
	  }
	;

new_import_class:
	  FROM IDENTIFIER IMPORT 
	  {
	   $$ = $2;
	   $2->flags |= F_IDENTIFIER_IMPORTED;
	   $2->s.tok = CLASS_NAME;
	   lookup_class ($2->s.s.name, &$2->classdef);
	   declare_component_ids ($2);
	   sym_table = $2->classdef->sym_tab;
	  }
	; 

import_header :
	  new_import_class  { class_from_which_importing = $1; }
	| FROM CLASS_NAME IMPORT 
	  {
           class_from_which_importing = $2;
	   $$ = $2;
	   if (!($2->flags & F_IDENTIFIER_IMPORTED))
	    {
	     printerr (1);
	     fprintf (stderr, " importing from ancestor is not allowed.\n");
	     file_traceback ();
	    }
	   sym_table = $2->classdef->sym_tab;
	  }
	;

import_message_name :
	  identifier
	  {
	   verify_imported_message ($1, class_from_which_importing);
	  }
	;

import_list :
	  import_message_name
	| import_list ',' import_message_name
	;

top_level_declaration :
	  top_level_data_declaration
	{ is_extern = 0; }
	| top_level_function_declaration
	;

opt_list_init_dcltr :
	  /* empty */ { $$ = 0; }
	| list_init_dcltr
	;

spec_data_declaration :
	  opt_decl_specifier opt_list_init_dcltr ';'
   	  {
	   setlisttype ($2, $1,
            ($1.std_class == typedef_class) ? TYPEDEF_NAME : VAR_NAME);
	  }
	;

top_level_data_declaration :
	  opt_decl_specifier opt_list_init_dcltr ';'
   	  {
           identifier_ptr typ = $1.type_link;

	   setlisttype ($2, $1,
            ($1.std_class == typedef_class) ? TYPEDEF_NAME : VAR_NAME);
	   
	   /* if type is struct, union or enum, dump to output file. */
	   if (typ && !(typ->flags & F_IDENTIFIER_WRITTEN) &&
	       typ->field_link &&
	       (typ->s.tok == STRUCT_NAME ||
	        typ->s.tok == ENUM_TAG ||
	        typ->s.tok == UNION_NAME))
	    {
	     dump_struct (typ);
   	    }
           if (!$2 || !local_processed_name($2))
   	    cur_out_line += print_declaration_list (oppout, $2, "");
	  }
	;

top_level_function_declaration :
	  function_header /* eating compound_statement */
          {
	   end_function($1);
	  }
	;

function_header :
	  opt_decl_specifier dcltr parameter_decl_list '{'
	  {
	   /* save the value of link because it is needed by verify
		function in the case where a parameter has the same name
		as the function.  Setlisttype expects it to be null. */

	   identifier_ptr tmp = $2->link;

           $2->link = 0;
	   $$ = $2;
	   setlisttype ($2, $1, VAR_NAME);
	   $2->link = tmp;
	   verify_function (&($2), &($3));
           $2->link = 0;
	   building_ptree = 1;
	   ptree_push(); iti++;
	  }
         function_body
          {
           $$ = $2;
	   ptree_meth_body ((struct pnode *)$6,0,0,inline_send);
	   building_ptree = 0;
	  } ;

function_body
	: p_opt_decl_list p_opt_stmt_list '}'
	 {
	  ptree_pop(); iti--;
	  $$ = new_pnode (compound_stmt,0,$1,$2,$3,-1);
	 }
	;

parameter_decl_list :
	  {
	   increment_symbol_level(sym_table);
	   increment_symbol_level(tag_table);
	   $$ = NULL;
          } /* empty */
	| parameter_decl_list parameter_declaration
   	  {
	   $$ = append_fields ($1, $2);
	  }
	;

parameter_declaration :
	  decl_specifier ';' {$$ = NULL; }
	| decl_specifier list_dcltr ';'
          {
           $$ = $2;
	   declaring_function_parameter ($1, $2);
	  }
	;

list_inst_declaration :
	  {$$ = NULL; }/* empty */
	| list_inst_declaration inst_declaration
   	  {
	   $$ = append_fields ($1, $2);
	  }
	;

inst_declaration :
	  struct_declaration
	| VARIABLE decl_specifier list_struct_dcltr ';'
	   {
	    struct Type_Info ti;
	    ti = empty_type;
	    ti.std_class = variable_class;
	    ti = merge_type_info ($2, ti, 0);
	    reverse_fields (&$3);
	    setlisttype ($3, ti, FIELD_NAME);
     	    reverse_fields (&$3);
	    $$ = $3;
	  }
	;

struct_declaration :
	  decl_specifier list_struct_dcltr ';'
	  {
	    $$ = $2;
	    setlisttype ($2, $1, FIELD_NAME);
	  }
	;

list_struct_declaration :
	  {$$ = NULL; }/* empty */
	| list_struct_declaration struct_declaration
   	  {
	   $$ = append_fields ($1, $2);
	  }
	;

formals_declaration :
	  /* empty */ { $$ = NULL; }
	| formals_decl
	;

formals_decl :
	  func_arg
	| formals_decl ',' func_arg
 	  {
           if ($3)
	    {
	     $3->link = $1;
	     $3->s.tok = VAR_NAME;
	    }
	   $$ = $3;
	  }
	;

func_arg :
	  maybe_identifier
	  { $1->s.tok = VAR_NAME; }
	| decl_specifier func_arg_dcltr
	  { 
	   $$ = $2;
	   setlisttype($2, $1, VAR_NAME);
	  }
	| ELLIPSIS
	  {
           identifier_ptr p;

	   p = (identifier_ptr)lookup_local_symbol (sym_table, "...");
	   if (!p)
	    p = new_identifier("...");

	   $$ = p;
	  }
	;

func_arg_dcltr :
	  abs_dcltr
	| dcltr
	;

p1_abs_dcltr :
	  '(' p3_abs_dcltr ')'
	  { $$ = $2; }
	;

p2_abs_dcltr :
	  p1_abs_dcltr
	| p2_abs_dcltr '('
	  {
	    increment_symbol_level(sym_table);
	  }
	  formals_declaration ')'
	  {
    	   decrement_symbol_level (sym_table, NULL);
	   $1->type_info.dcltr_link =
	    append_function_dcltr ($1->type_info.dcltr_link, $4);
	  }
	| '(' ')'
	  {
           identifier_ptr p;

	   p = (identifier_ptr)lookup_local_symbol (sym_table, "");
	   if (!p)
	    p = new_identifier("");

	   $$ = p;
	   $$->type_info.dcltr_link =
	    append_function_dcltr ($$->type_info.dcltr_link, 0);
	  }
	| p2_abs_dcltr '[' ']'
	  {
	   $1->type_info.dcltr_link = 
	    append_array_dcltr ($1->type_info.dcltr_link, 0);
	  }
	| p2_abs_dcltr '[' exp ']'
	  {
	   $1->type_info.dcltr_link = 
	    append_array_dcltr ($1->type_info.dcltr_link, $3);
	  }
	| e_abs_dcltr '[' ']'
	  {
	   $1->type_info.dcltr_link = 
	    append_array_dcltr ($1->type_info.dcltr_link, 0);
	  }
	| e_abs_dcltr '[' exp ']'
	  {
	   $1->type_info.dcltr_link = 
	    append_array_dcltr ($1->type_info.dcltr_link, $3);
	  }
	;

p3_abs_dcltr :
	  p2_abs_dcltr
	| '*' p4_abs_dcltr
          {
 	   $$ = $2;
	   $2->type_info.dcltr_link =
	    append_pointer_dcltr ($2->type_info.dcltr_link);
	  }
	| '*' CONST p4_abs_dcltr
	  { 
 	   $$ = $3;
	   $3->type_info.dcltr_link =
	    append_const_dcltr ($3->type_info.dcltr_link);
	   $3->type_info.dcltr_link =
	    append_pointer_dcltr ($3->type_info.dcltr_link);
	  }
	| '*' VOLATILE p4_abs_dcltr
	  { 
 	   $$ = $3;
	   $3->type_info.dcltr_link =
	    append_volatile_dcltr ($3->type_info.dcltr_link);
	   $3->type_info.dcltr_link =
	    append_pointer_dcltr ($3->type_info.dcltr_link);
	  }
	| '*' CONST VOLATILE p4_abs_dcltr
	  { 
 	   $$ = $4;
	   $4->type_info.dcltr_link =
	    append_volatile_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_const_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_pointer_dcltr ($4->type_info.dcltr_link);
	  }
	| '*' VOLATILE CONST p4_abs_dcltr
	  { 
 	   $$ = $4;
	   $4->type_info.dcltr_link =
	    append_const_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_volatile_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_pointer_dcltr ($4->type_info.dcltr_link);
	  }
	;

p4_abs_dcltr :
	  p3_abs_dcltr
	| e_abs_dcltr
	;

e_abs_dcltr :
	  {/* empty */
           identifier_ptr p;

	   p = (identifier_ptr)lookup_local_symbol (sym_table, "");
	   if (!p)
	    p = new_identifier("");

	   $$ = p;
	  }
	;

abs_dcltr :
	  p3_abs_dcltr
	| e_abs_dcltr
	;

opt_decl_specifier :
	  { $$ = empty_type; $$.std_type = int_type;}
	| decl_specifier
	;

type_qualifier :
	  CONST		{ $$ = empty_type; $$.const_attribute = 1; }
	| VOLATILE	{ $$ = empty_type; $$.volatile_attribute = 1; }
	;

tc_specifier :
	  std_class
	| type_specifier
	| type_qualifier
	;

decl_specifier :
	  tc_specifier
	| decl_specifier tc_specifier
         {
	   $$ = merge_type_info ($1, $2, 0);
         }
	;

std_class :
	  AUTO	   { $$ = empty_type; $$.std_class = auto_class; }
	| STATIC   { $$ = empty_type; $$.std_class = static_class; }
	| EXTERN   { $$ = empty_type; $$.std_class = extern_class; is_extern = 1; }
	| REGISTER { $$ = empty_type; $$.std_class = register_class; }
	| TYPEDEF  { $$ = empty_type; $$.std_class = typedef_class; }
	;

type_specifier :
	  TYPEDEF_NAME
	 { 
	   extern int opping_for_discos;

	   if (!opping_for_discos) /* This causes opp not to expand typedefs. */
	    {
	     $$ = empty_type;
	     $$.typedefName = carrier_node($1);
	    }
	   else /* ddp requires typedefs done the old way. */
	    $$ = $1->type_info;

	   $$.std_class = noclass;
	 }
	| std_type
        | size_spec
	| UNSIGNED {$$ = empty_type; $$.unsigned_attribute = 1; }
	| SIGNED   {$$ = empty_type; $$.signed_attribute = 1; }
	| PRIVATE  {$$ = empty_type; $$.private_attribute = 1; }
	| NOMOD    {$$ = empty_type; $$.nomod_attribute = 1; }
	| struct_specifier
	| enum_specifier
	;

std_type :
	  CHAR	 {$$ = empty_type; $$.std_type = char_type;}
	| INT	 {$$ = empty_type; $$.std_type = int_type;}
	| FLOAT  {$$ = empty_type; $$.std_type = float_type;}
	| DOUBLE {$$ = empty_type; $$.std_type = float_type;
		  $$.std_size = long_size; }
	| VOID   {$$ = empty_type; $$.std_type = void_type;}
	;

size_spec :
	  SHORT  {$$ = empty_type; $$.std_size = short_size;}
	| LONG	 {$$ = empty_type; $$.std_size = long_size;}
	;

struct_header :
	  STRUCT opt_str_tag '{'
	  {
	   $$ = empty_type;
	   $$.type_link = $2;
	   $2->s.tok = STRUCT_NAME;
	   increment_symbol_level(sym_table);
	  }
	;

union_header :
	 UNION opt_str_tag '{'
	 {
	  $$ = empty_type;
	  $$.type_link = $2;
	  $2->s.tok = UNION_NAME;
	  increment_symbol_level(sym_table);
	 }
 	;

struct_specifier :
	  instance_decl { $$ = empty_type; $$.type_link = $1; }
	| INSTANCE identifier
           {
	    if ($2->s.tok != CLASS_NAME)
	     {
	      printerr (1);
	      fprintf (stderr, " \"%s\" is not a class name.\n", $2->s.s.name);
	      file_traceback ();
	     }
	    else
	     { $$ = empty_type; $$.type_link = $2; }
	   }
	| STRUCT STRUCT_NAME { $$ = empty_type; $$.type_link = $2; }
	| UNION UNION_NAME { $$ = empty_type; $$.type_link = $2; }
	| CHANNEL identifier
	   {
	    if ($2->s.tok != CHANNEL_NAME)
	     {
	      printerr (1);
	      fprintf (stderr, " channel type \"%s\" has not been declared.\n",
		       $2->s.s.name);
	      file_traceback ();
	     }
	    else
 	     { $$ = empty_type; $$.type_link = $2; }
	   }
	| STRUCT IDENTIFIER
	  {
	   $$ = empty_type;
	   $$.type_link = $2;
	   $2->s.tok = STRUCT_NAME; /* semi-kludge */
	  } /* forward*/
	| UNION IDENTIFIER
	  {
	   $$ = empty_type;
	   $$.type_link = $2;
	   $2->s.tok = UNION_NAME; /* semi-kludge */
	  }/* forward */
	| struct_header list_struct_declaration '}'
	  {
	   reverse_fields (&($2));
	   $1.type_link->field_link = $2;
	   end_struct_def ($1.type_link);
	  }
	| union_header list_struct_declaration '}'
	  {
	   reverse_fields (&($2));
	   $1.type_link->field_link = $2;
	   end_struct_def ($1.type_link);
	  }
        | channel_header opt_chan_attributes opt_class_list '}'
	  {
	   $$ = empty_type;
	   $$.type_link = $1;
	   $1->s.tok = CHANNEL_NAME;
	   end_channel_def ($1, active_chan_att, $3, active_chan_init,
			    active_chan_incr, active_chan_other_chan);
	   decrement_symbol_level (sym_table, free);
	  }
	;

channel_header :
	  CHANNEL opt_str_tag '{'
	  {
	   $$ = $2;
	   active_chan_init = active_chan_incr = -1;
	   active_chan_att = 0;
	   increment_symbol_level(sym_table);
	  }
	;

sidedness :
 	  ONE_TO_ONE   { $$ = CHAN_ATT_OO; }
	| ONE_TO_MANY  { $$ = CHAN_ATT_OM; }
	| MANY_TO_ONE  { $$ = CHAN_ATT_MO; }
	| MANY_TO_MANY { $$ = CHAN_ATT_MM; }
	;

orderedness :
	  ABS_ORDERED { $$ = CHAN_ATT_ABS; }
	| REL_ORDERED { $$ = CHAN_ATT_REL; }
	;

chan_attribute :
	  sidedness
	  {
	   if (active_chan_att & CHAN_ATT_SIDES)
	    {
	     printerr (1);
	     fprintf (stderr, " Multiple sidedness on channel declaration\n");
	     file_traceback ();
	    }
	   else
	    active_chan_att |= $1;
	  }
	| orderedness
	  {
	   if (active_chan_att & (CHAN_ATT_ABS | CHAN_ATT_REL))
	    {
	     printerr (1);
	     fprintf (stderr, " Multiple channel order attributes\n");
	     file_traceback ();
	    }
	   active_chan_att |= $1;
	  }
	| INITIAL '=' exp
	  {
	   if (active_chan_att & CHAN_ATT_INIT)
	    {
	     printerr (1);
	     fprintf (stderr, "Initial count already specified.\n");
	     file_traceback ();
	    }
	   active_chan_att |= CHAN_ATT_INIT;
	   active_chan_init = $3;
	  }
	| INCREMENT '=' exp
	  {
	   if (active_chan_att & CHAN_ATT_INCR)
	    {
	     printerr (1);
	     fprintf (stderr, "Increment count already specified.\n");
	     file_traceback ();
	    }
	   active_chan_att |= CHAN_ATT_INCR;
	   active_chan_incr = $3;	
	  }
	;
	
chan_attributes :
	  chan_attribute
	| chan_attributes ',' chan_attribute
	;

opt_chan_attributes :
	  /* empty */ { $$ = active_chan_att = default_chan_att; }
	| '(' chan_attributes ')'
	  {
	   if (!(active_chan_att & CHAN_ATT_SIDES))
	    active_chan_att |= CHAN_ATT_MM;
	   if ((active_chan_att & (CHAN_ATT_OO | CHAN_ATT_MO)) &&
	       (active_chan_att & (CHAN_ATT_REL | CHAN_ATT_ABS)))
	    {
             printerr (0);
	     fprintf (stderr, " ordered attribute ignored;\n");
	     fprintf (stderr, " - channel connects to single object.\n");
	     file_traceback ();
	     active_chan_att &= ~(CHAN_ATT_REL | CHAN_ATT_ABS);
	    }
	   $$ = active_chan_att;
	  }
	;

opt_str_tag :
	  /* empty */
         {
          $$ = new_phantom_identifier (active_class);
          enter_symbol (tag_table, $$);
         }
	| maybe_identifier
	;

struct_dcltr :
	  dcltr
	| ':' exp
	  {
	   $$ = new_phantom_identifier (active_class);
	   enter_symbol (sym_table, $$);
	   $$->type_info.dcltr_link = append_bitfield_dcltr (NULL, $2);
	  }
	| dcltr ':' exp
	  {
	   $1->type_info.dcltr_link = 
            append_bitfield_dcltr ($1->type_info.dcltr_link, $3);
	  }
	;

enum_6 :
	  name_dcltr
	  { $1->link = 0; $1->flags |= F_IDENTIFIER_MARKED; $1->index = 0; }
	| enum_6 ',' name_dcltr
	  {
	   if ($3->flags & F_IDENTIFIER_MARKED)
	    {
	     printerr (1);
	     fprintf (stderr, " redeclaration of %s ignored.\n",$3->s.s.name);
	     file_traceback ();
	    }
	   else
	    {
             $3->index = $1->index + 1;
	     $$ = $3;
	     $3->link = $1;
	     $3->flags |= F_IDENTIFIER_MARKED;
	    }
	  }
	| name_dcltr '=' exp
	  { $1->link = 0; $1->flags |= F_IDENTIFIER_MARKED; $1->index = $3; }
	| enum_6 ',' name_dcltr '=' exp
	  {
	   if ($3->flags & F_IDENTIFIER_MARKED)
	    {
	     printerr (1);
	     fprintf (stderr, " redeclaration of %s ignored.\n",$3->s.s.name);
	     file_traceback ();
	    }
	   else
	    {
             $3->index = $5;
	     $$ = $3;
	     $3->link = $1;
	     $3->flags |= F_IDENTIFIER_MARKED;
	    }
	  }
	;

enum_7 :
	  '{' enum_6 '}' { $$ = $2; }
	| '{' enum_6 ',' '}' { $$ = $2; }
	;

enum_specifier :
	  ENUM ENUM_TAG { $$ = empty_type; $$.type_link = $2; }
	| ENUM en_tag_dcltr enum_7
	  {
	   $$ = empty_type;
	   reverse_fields (&$3);
	   $2->field_link = $3;
	   setlisttype ($3, $$, ENUM_NAME);
	   $$.type_link = $2;
	   end_struct_def ($2);
	  }
	;

name_dcltr :
	maybe_identifier
	;

en_tag_dcltr :
	  maybe_identifier { $1->s.tok = ENUM_TAG; }
	| {
	   $$ = new_phantom_identifier(active_class);
	   enter_symbol (tag_table, $$);
	   $$->s.tok = ENUM_TAG;
	  }
	;

p1_dcltr :
	  name_dcltr
	| '(' dcltr ')' { $$ = $2; }
	;

p2_fun_dcltr_header :
	  p2_dcltr '(' 
	  {
	   increment_symbol_level(sym_table);
	  }
	;

p2_dcltr :
	  p1_dcltr
	| p2_fun_dcltr_header formals_declaration ')'
	  {
    	   decrement_symbol_level (sym_table, NULL);
	   $1->type_info.dcltr_link =
	    append_function_dcltr ($1->type_info.dcltr_link, $2);
	  }
	| p2_dcltr '[' ']'
	  {
	   $1->type_info.dcltr_link = 
	    append_array_dcltr ($1->type_info.dcltr_link, 0);
	  }
	| p2_dcltr '[' exp/*list_exp*/ ']'
          {
	   $1->type_info.dcltr_link = 
	    append_array_dcltr ($1->type_info.dcltr_link, $3);
	  }
	;

dcltr :
	  p2_dcltr
	| '*' dcltr
          {
 	   $$ = $2;
	   $2->type_info.dcltr_link =
	    append_pointer_dcltr ($2->type_info.dcltr_link);
	  }
	| '*' CONST p2_dcltr
	  { 
 	   $$ = $3;
	   $3->type_info.dcltr_link =
	    append_const_dcltr ($3->type_info.dcltr_link);
	   $3->type_info.dcltr_link =
	    append_pointer_dcltr ($3->type_info.dcltr_link);
	  }
	| '*' VOLATILE p2_dcltr
	  { 
 	   $$ = $3;
	   $3->type_info.dcltr_link =
	    append_volatile_dcltr ($3->type_info.dcltr_link);
	   $3->type_info.dcltr_link =
	    append_pointer_dcltr ($3->type_info.dcltr_link);
	  }
	| '*' CONST VOLATILE p2_dcltr
	  { 
 	   $$ = $4;
	   $4->type_info.dcltr_link =
	    append_volatile_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_const_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_pointer_dcltr ($4->type_info.dcltr_link);
	  }
	| '*' VOLATILE CONST p2_dcltr
	  { 
 	   $$ = $4;
	   $4->type_info.dcltr_link =
	    append_const_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_volatile_dcltr ($4->type_info.dcltr_link);
	   $4->type_info.dcltr_link =
	    append_pointer_dcltr ($4->type_info.dcltr_link);
	  }
	;

init_dcltr :
	  dcltr
	| dcltr '=' init_exp
	  {
	   printerr(1);
	   fprintf (stderr, "initializers not supported, use %%safe.\n");
	   file_traceback ();
          }
	;

init_exp_9 :
	  init_exp
	| init_exp_9 ',' init_exp
	;

init_exp :
	  exp
	| '{' init_exp_9 '}'
	| '{' init_exp_9 ',' '}'
	;

list_init_dcltr :
	  init_dcltr { $1->link = 0; $1->flags |= F_IDENTIFIER_MARKED; }
	| list_init_dcltr ',' init_dcltr
	  {
	   if ($3->flags & F_IDENTIFIER_MARKED)
	    {
	     $$ = $1;
	     printerr (1);
	     fprintf (stderr, " redeclaration of %s ignored.\n",$3->s.s.name);
	     file_traceback ();
	    }
	   else
	    {
	     $$ = $3;
	     $3->link = $1;
	     $3->flags |= F_IDENTIFIER_MARKED;
	    }
	  }
	;

list_struct_dcltr :
	  struct_dcltr { $1->link = 0; $1->flags |= F_IDENTIFIER_MARKED; }
	| list_struct_dcltr ',' struct_dcltr
	  {
	   if ($3->flags & F_IDENTIFIER_MARKED)
	    {
	     printerr (1);
	     fprintf (stderr, " redeclaration of %s ignored.\n",$3->s.s.name);
	     file_traceback ();
	    }
	   else
	    {
	     $$ = $3;
	     $3->link = $1;
	     $3->flags |= F_IDENTIFIER_MARKED;
	    }
	  }
	;

list_dcltr :
	  dcltr { $1->link = 0; $1->flags |= F_IDENTIFIER_MARKED; }
	| list_dcltr ',' dcltr
	  {
	   if ($3->flags & F_IDENTIFIER_MARKED)
	    {
	     printerr (1);
	     fprintf (stderr, " redeclaration of %s ignored.\n",$3->s.s.name);
	     file_traceback ();
	    }
	   else
	    {
	     $$ = $3;
	     $3->link = $1;
	     $3->flags |= F_IDENTIFIER_MARKED;
	    }
	  }
	;

literal	:
	  DEC_INT
	;

paren_exp :
	  '(' list_exp ')'
	  { $$ = $2; }
	;

primary_p1_exp :
	  literal
	| paren_exp
	| SIZEOF '(' type_specifier ')'
	   { $$ = do_the_sizeof($3); }
	;

primary_exp :
	  primary_p1_exp
	;

postfix_exp :
	  primary_exp
	;

prefix_exp :
	  '-' cast_exp
	  { $$ = (-$2); }
	| '!' cast_exp
	  { $$ = (!$2); }
	| '~' cast_exp
	  { $$ = (~$2); }
	| postfix_exp
	;

cast_exp :
	  prefix_exp
	;

unary_oper_exp :
	  cast_exp
	;

mult_oper_exp :
	  unary_oper_exp
	| mult_oper_exp '*' unary_oper_exp
	  { $$ = $1 * $3; }
	| mult_oper_exp '/' unary_oper_exp
	  { $$ = $1 / $3; }
	| mult_oper_exp '%' unary_oper_exp
	  { $$ = $1 % $3; }
	;

add_oper_exp :
	  mult_oper_exp
	| add_oper_exp '+' mult_oper_exp
	  { $$ = $1 + $3; }
	| add_oper_exp '-' mult_oper_exp
	  { $$ = $1 - $3; }
	;

shift_oper_exp :
	  add_oper_exp
	| shift_oper_exp LEFT_SHIFT add_oper_exp
	  { $$ = $1 << $3; }
	| shift_oper_exp RIGHT_SHIFT add_oper_exp
	  { $$ = $1 >> $3; }
	;

rel_oper_exp :
	  shift_oper_exp
	| rel_oper_exp '<' shift_oper_exp
	  { $$ = $1 < $3; }
	| rel_oper_exp '>' shift_oper_exp
	  { $$ = $1 > $3; }
	| rel_oper_exp LEQ shift_oper_exp
	  { $$ = $1 <= $3; }
	| rel_oper_exp GEQ shift_oper_exp
	  { $$ = $1 >= $3; }
	;

equ_oper_exp :
	  rel_oper_exp
	| equ_oper_exp EQ rel_oper_exp
	  { $$ = $1 == $3; }
	| equ_oper_exp NOT_EQ rel_oper_exp
	  { $$ = $1 != $3; }
	;

bitand_oper_exp :
	  equ_oper_exp
	| bitand_oper_exp '&' equ_oper_exp
	  { $$ = $1 & $3; }
	;

bitxor_oper_exp :
	  bitand_oper_exp
	| bitxor_oper_exp '^' bitand_oper_exp
	  { $$ = $1 ^ $3; }
	;

bitor_oper_exp :
	  bitxor_oper_exp
	| bitor_oper_exp '|' bitxor_oper_exp
	  { $$ = $1 | $3; }
	;

and_oper_exp :
	  bitor_oper_exp
	| and_oper_exp AND_AND bitor_oper_exp
	  { $$ = $1 && $3; }
	;

or_oper_exp :
	  and_oper_exp
	| or_oper_exp OR_OR and_oper_exp
	  { $$ = $1 || $3; }
	;

cond_exp :
	  or_oper_exp
	| or_oper_exp '?' list_exp ':' cond_exp
	  { $$ = $1 ? $3 : $5; }
	;

exp :
	cond_exp
	;

list_exp :
	  exp
	| list_exp ',' exp
	  { $$ = $3; }
	;


/*

	The reader might wonder, How come?
	that the code trailing this looks so dumb?
	at the time of composing
	the author was dozing
	and stuck it together with gum.

*/


p_local_data_declaration
	: p_decl_specifier ';'
	 {
	  $$ = new_pnode (local_data_declaration,$1,0,$2,-1);
	  if (is_typedef[iti]) ptree_work_typedef ((struct pnode *)$$);
	  is_typedef[iti]=0;
	 }
	| p_decl_specifier p_list_init_dcltr ';'
	 {
	  $$ = new_pnode (local_data_declaration,$1,$2,$3,-1);
	  if (is_typedef[iti]) ptree_work_typedef ((struct pnode *)$$);
	  is_typedef[iti]=0;
	 }
        | SAFEBLOCK
         {
          $$ = $1;
         }
	;

p_typename_declaration
	: p_decl_specifier p_abs_dcltr
	 {
	  $$ = new_pnode(typename_declaration,$1,$2,-1);
	  if (is_typedef[iti]) ptree_work_typedef ((struct pnode *)$$);
	  is_typedef[iti]=0;
	 }
	;

p_list_struct_declaration 
	:
	 { $$ = 0; }
	| p_list_struct_declaration p_struct_declaration
	 { $$ = new_pnode(list_struct_delcaration,$1,$2,-1); }
	;

p_formal_declaration_list
	: p_formal_declaration
	 { $$ = $1; }
	| p_formal_declaration_list ',' p_formal_declaration 
	 { $$ = new_pnode(formal_declaration_list,$1,$2,$3,-1); }
	;

p_formals_declaration
	:
	 { $$ = 0; }
	| p_formal_declaration_list
	;

p_formal_declaration
	: p_decl_specifier p_formal_dcltr
	 {
	  $$=new_pnode(formal_declaration,$1,$2,-1);
	  if (is_typedef[iti]) ptree_work_typedef ((struct pnode *)$$);
	  is_typedef[iti]=0;
	 }
	| ELLIPSIS
	| p_name_dcltr
	;

p_formal_dcltr
	: p_dcltr
	| p_abs_dcltr
	;

p_decl_specifier
	: p_tc_specifier
	 { $$ = $1; }
	| p_decl_specifier p_tc_specifier
	 { $$ = new_pnode (decl_specifier,$1,$2,-1); }
	;

p_tc_specifier
	: p_std_class
	 { $$ = $1; }
	| p_type_specifier
	 { $$ = $1; }
	| p_type_qualifier
	 { $$ = $1; }
	;

p_type_qualifier
	: CONST
	 { $$ = $1; }
	| VOLATILE
	 { $$ = $1; }
	;

p_std_class
	: AUTO
	 { $$ = (int)($1.type_link); }
	| STATIC
	 { $$ = (int)($1.type_link); }
	| EXTERN
	 { $$ = (int)($1.type_link); is_extern = 1; }
	| REGISTER
	 { $$ = (int)($1.type_link); }
	| TYPEDEF
	 {
	  $$ = (int)($1.type_link);
	  is_typedef[iti] = 1;
	 }
	;

p_type_specifier
	: p_std_type
	| p_typedef_name
	| p_struct_specifier
	| p_enum_specifier
	;

p_std_type
	: CHAR
	 { $$ = (int)($1.type_link); }
	| FLOAT
	 { $$ = (int)($1.type_link); }
	| INT
	 { $$ = (int)($1.type_link); }
	| DOUBLE
	 { $$ = (int)($1.type_link); }
	| SHORT
	 { $$ = (int)($1.type_link); }
	| LONG
	 { $$ = (int)($1.type_link); }
	| UNSIGNED
	 { $$ = (int)($1.type_link); }
	| SIGNED
	 { $$ = (int)($1.type_link); }
	| VOID
	 { $$ = (int)($1.type_link); }
	;

p_struct_specifier
	: STRUCT p_struct_name 
	 { $$ = new_pnode (struct_specifier,$1,$2,0,0,0,-1); }
	| STRUCT '{' {iti++;} p_list_struct_declaration '}'
	 {
	  $$ = new_pnode (struct_specifier,$1,0,$2,$4,$5,-1);
	  iti--;
	 }
	| STRUCT p_str_tag_dcltr '{' {iti++;} p_list_struct_declaration '}' 
	 { $$ = new_pnode (struct_specifier,$1,$2,$3,$5,$6,-1); iti--; }
	| UNION p_union_name
	 { $$ = new_pnode (union_specifier,$1,$2,0,0,0,-1); }
	| UNION '{' {iti++;} p_list_struct_declaration '}' 
	 { $$ = new_pnode (union_specifier,$1,0,$2,$4,$5,-1); iti--; }
	| UNION p_un_tag_dcltr '{' {iti++;} p_list_struct_declaration '}'
	 { $$ = new_pnode (union_specifier,$1,$2,$3,$5,$6,-1); iti--; }
	| INSTANCE CLASS_NAME
	 { $$ = new_pnode (instance_specifier,$1,$2,-1); }
	;

p_struct_declaration
	: p_decl_specifier p_list_struct_dcltr ';'
	 {
	  $$=new_pnode(struct_declaration,$1,$2,$3,-1);
	  if (is_typedef[iti]) ptree_work_typedef((struct pnode *)$$);
	  is_typedef[iti]=0;
	 }
	;

p_list_struct_dcltr
	: p_struct_dcltr
	 { $$ = $1; }
	| p_list_struct_dcltr ',' p_struct_dcltr
	 { $$=new_pnode(list_struct_dcltr,$1,$2,$3,-1); }
	;

p_struct_dcltr
	: p_dcltr
	 { $$=new_pnode(struct_dcltr,$1,0,0,-1); }
	| ':' p_exp
	 { $$=new_pnode(struct_dcltr,0,$1,$2,-1); }
	| p_dcltr ':' p_exp
	 { $$=new_pnode(struct_dcltr,$1,$2,$3,-1); }
	;

p_enum_dcltr_list
	: p_enum_dcltr
	 { $$ = $1; }
	| p_enum_dcltr_list ',' p_enum_dcltr
	 { $$=new_pnode(enum_dcltr_list,$1,$2,$3,-1); }
	;

p_enum_dcltr_body
	: '{' p_enum_dcltr_list '}'
	 { $$ = new_pnode(enum_dcltr_body,$1,$2,0,$3,-1); }
	| '{' p_enum_dcltr_list ',' '}'
	 { $$ = new_pnode(enum_dcltr_body,$1,$2,$4,$3,-1); }
	;

p_enum_specifier
	: ENUM p_enum_name
	 { $$=new_pnode(enum_specifier,$1,$2,0,-1); }
	| ENUM p_enum_dcltr_body
	 { $$=new_pnode(enum_specifier,$1,0,$2,-1); }
	| ENUM p_en_tag_dcltr p_enum_dcltr_body
	 { $$=new_pnode(enum_specifier,$1,$2,$3,-1); }
	;

p_enum_dcltr
	: p_name_dcltr
	 { $$=new_pnode(enum_dcltr,$1,0,0,-1); }
	| p_name_dcltr '=' p_exp
	 { $$=new_pnode(enum_dcltr,$1,$2,$3,-1); }
	;

p_name_dcltr
	: identifier
	 { $$ = (int)$1; }
	;

p_str_tag_dcltr
	: identifier
	 { $$ = (int)$1; }
	;

p_un_tag_dcltr
	: identifier
	 { $$ = (int)$1; }
	;

p_en_tag_dcltr
	: identifier
	 { $$ = (int)$1; }
	;

p_p1_dcltr
	: p_name_dcltr
	 { $$ = $1; }
	| '(' p_dcltr ')'
	 { $$ = new_pnode(p1_dcltr,$1,$2,$3,-1); }
	;

p_p2_dcltr
	: p_p1_dcltr
	 { $$ = $1; }
	| p_p2_dcltr '(' {iti++;} p_formals_declaration {iti--;} ')' 
	 { $$ = new_pnode(function_dcltr,$1,$2,$4,$6,-1); }
	| p_p2_dcltr '[' ']'
	 { $$ = new_pnode(array_dcltr,$1,$2,0,$3,-1); }
	| p_p2_dcltr '[' p_exp ']'
	 { $$ = new_pnode(array_dcltr,$1,$2,$3,$4,-1); }
	;

p_p3_dcltr
	: p_p2_dcltr
	 { $$ = $1; }
	| '*' p_p3_dcltr
	 { $$=new_pnode(pointer_dcltr,$1,$2,-1); }
	| '*' p_type_qualifier p_p3_dcltr
	 { $$=new_pnode(pointer_dcltr,$1,$2,$3,-1); }
	| '*' p_type_qualifier p_type_qualifier p_p3_dcltr
	 { $$=new_pnode(pointer_dcltr,$1,$2,$3,$4,-1); }
	;

p_dcltr
	: p_p3_dcltr
	 { $$ = $1; }
	;

p_init_dcltr
	: p_dcltr
	 { $$ = new_pnode (init_dcltr,$1,0,0,-1); }
	| p_dcltr '=' p_init_exp
	 { $$ = new_pnode (init_dcltr,$1,$2,$3,-1); }
	;

p_list_init_exp
	: p_init_exp
	 { $$ = $1; }
	| p_list_init_exp ',' p_init_exp
	 { $$ = new_pnode (list_init_expr,$1,$2,$3,-1); }
	;

p_init_exp
	: p_exp
	 { $$ = $1; }
	| '{' p_list_init_exp '}'
	 { $$ = new_pnode (init_exp,$1,$2,0,$3,-1); }
	| '{' p_list_init_exp ',' '}'
	 { $$ = new_pnode (init_exp,$1,$2,$3,$4,-1); }
	;

p_p1_abs_dcltr
	: '(' p_p3_abs_dcltr ')'
	 { $$ = new_pnode (p1_abs_dcltr,$1,$2,$3,-1); }
	;

p_p2_abs_dcltr
	: p_p1_abs_dcltr
	 { $$ = $1; }
	| p_p2_abs_dcltr '(' {iti++;} p_formals_declaration {iti--;} ')'
	 { $$ = new_pnode (abs_fun_dcltr,$1,$2,$4,$6,-1); }
	| '(' ')'
	 { $$ = new_pnode (abs_fun_dcltr,0,$1,$2,-1); }

	| p_p2_abs_dcltr '[' ']'
	 { $$ = new_pnode (abs_array_dcltr,$1,$2,0,$3,-1); }
	| p_p2_abs_dcltr '[' p_exp ']'
	 { $$ = new_pnode (abs_array_dcltr,$1,$2,$3,$4,-1); }
	| p_e_abs_dcltr '[' ']'
	 { $$ = new_pnode (abs_array_dcltr,$1,$2,0,$3,-1); }
	| p_e_abs_dcltr '[' p_exp ']'
	 { $$ = new_pnode (abs_array_dcltr,$1,$2,$3,$4,-1); }
	;


p_p3_abs_dcltr
	: p_p2_abs_dcltr
	 { $$ = $1; }
	| '*' p_p4_abs_dcltr
	 { $$ = new_pnode (abs_pointer_dcltr,$1,$2,-1); }
	| '*' p_type_qualifier p_p4_abs_dcltr
	 { $$ = new_pnode (abs_pointer_dcltr,$1,$2,$3,-1); }
	| '*' p_type_qualifier p_type_qualifier p_p4_abs_dcltr
	 { $$ = new_pnode (abs_pointer_dcltr,$1,$2,$3,$4,-1); }
	;

p_p4_abs_dcltr
	: p_p3_abs_dcltr
	| p_e_abs_dcltr
	;

p_e_abs_dcltr
	:
	 { $$ = 0; }
	;


p_abs_dcltr
	: p_p3_abs_dcltr
	 { $$ = $1; }
	| p_e_abs_dcltr
	 { $$ = $1; }
	;


p_list_init_dcltr
	: p_init_dcltr
	 { $$ = $1; }
	| p_list_init_dcltr ',' p_init_dcltr
	 { $$ = new_pnode (list_init_dcltr,$1,$2,$3,-1); }
	;


p_compound_stmt
	: '{' {ptree_push(); iti++; } p_opt_decl_list p_opt_stmt_list '}'
	 {
	  ptree_pop();
	  iti--;
	  $$ = new_pnode (compound_stmt,$1,$3,$4,$5,-1);
	 }
	;


p_opt_decl_list
	:
	 { $$ = 0; }
	| p_opt_decl_list p_local_data_declaration
	 { $$ = new_pnode (opt_decl_list,$1,$2,-1); }
	;

p_opt_stmt_list
	:
	 { $$ = 0; }
	| p_opt_stmt_list p_stmt
	 { $$ = new_pnode(opt_stmt_list,$1,$2,-1); }
	;
	
p_stmt
	: p_stmt_a
	 { $$ = $1; }
	| p_if_stmt
	 { $$ = $1; }
	| SAFEBLOCK
	 { $$ = $1; }
	;

p_stmt_a
	: p_e_stmt
	| p_compound_stmt
	| p_while_stmt
	| p_do_stmt
	| p_break_stmt
	| p_continue_stmt
	| p_return_stmt
	| p_goto_stmt
	| p_null_stmt
	| p_for_stmt
	| p_ifelse_stmt
	| p_switch_stmt
	| p_label p_stmt
	  { $$ = new_pnode(labeled_stmt,$1,$2,-1); }
	;

p_ifelse_stmt
	: IF '(' p_list_exp ')' p_stmt_a ELSE p_stmt
	 { $$ = new_pnode(if_stmt,$1,$2,$3,$4,$5,$6,$7,-1); }

p_if_stmt
	: IF '(' p_list_exp ')' p_stmt
	 { $$ = new_pnode(if_stmt,$1,$2,$3,$4,$5,-1); }
	;

p_e_stmt
	: p_list_exp ';'
	 { $$ = new_pnode(e_stmt,$1,$2,-1); }
	;

p_while_stmt
	: WHILE '(' p_list_exp ')' p_stmt
	 { $$ = new_pnode (while_stmt,$1,$2,$3,$4,$5,-1); }
	;
	
p_do_stmt
	: DO p_stmt WHILE '(' p_list_exp ')' ';'
	 { $$ = new_pnode (do_stmt,$1,$2,$3,$4,$5,$6,$7,-1); }
	;

p_opt_list_exp
	:
	 { $$ = 0; }
	| p_list_exp
	;
	 

p_for_stmt
	: FOR '(' p_opt_list_exp ';' p_opt_list_exp ';' p_opt_list_exp ')'
	   p_stmt
	 { $$ = new_pnode (for_stmt,$1,$2,$3,$4,$5,$6,$7,$8,$9,-1); }
	;

p_switch_stmt
	: SWITCH '(' p_list_exp ')' p_stmt
	 { $$ = new_pnode (switch_stmt,$1,$2,$3,$4,$5,-1); }
	;

p_break_stmt
	: BREAK ';'
	 { $$ = new_pnode (break_stmt,$1,$2,-1); }
	;

p_continue_stmt
	: CONTINUE ';'
	 { $$ = new_pnode (continue_stmt,$1,$2,-1); }
	;

p_return_stmt
	: RETURN ';'
	 { $$ = new_pnode (return_stmt,$1,0,$2,-1); }
	| RETURN p_list_exp ';'
	 { $$ = new_pnode (return_stmt,$1,$2,$3,-1); }
	;

p_goto_stmt
	: GOTO p_label_name ';'
	 { $$ = new_pnode (goto_stmt,$1,$2,$3,-1); }
	;

p_null_stmt
	: ';'
	 { $$ = new_pnode (null_stmt,$1,-1); }
	;

p_label
	: p_name_label
	| p_case_label
	| p_default_label ;

p_name_label
	: IDENTIFIER ':'
	 { $$ = new_pnode(name_label,$1,$2,-1); }
	;

p_case_label
	: CASE p_exp ':'
	 { $$ = new_pnode(case_label,$1,$2,$3,-1); }
	;

p_default_label
	: DEFAULT ':'
	 { $$ = new_pnode(default_label,$1,$2,-1); }
	;

p_message_buff
	: MESSAGE identifier '.' identifier '(' ')'
	 { $$ = new_pnode(message_buff,$1,$2,$3,$4,$5,0,$6,0,-1); }
	| MESSAGE identifier '.' identifier '(' p_list_exp ')'
	 { $$ = new_pnode(message_buff,$1,$2,$3,$4,$5,$6,$7,0,-1); }
	| MESSAGE error
         { $$ = 0; fprintf (stderr," -- invalid message invocation \n"); }
	;


p_string_constant 
	: STR_CONST
	 { $$ = $1; }
	| STR_CONST p_string_constant
	 { $$ = new_pnode(string_constant,$1,$2,-1); }
	;

p_literal
	: DEC_INT
	 { $$ = $1; }
	| FLOAT_CONST
	 { $$ = $1; }
	| CHAR_CONST
	 { $$ = $1; }
	| p_string_constant
	 { $$ = $1; }
	| p_message_buff
	;

p_typedef_name
	: TYPEDEF_NAME
	 { $$ = (int)$1; }
	;

p_id_name
	: identifier
	 { $$ = (int)$1; }
	;

p_struct_name
	: identifier
	 { $$ = (int)$1; }
	;

p_union_name
	: identifier
	 { $$ = (int)$1; }
	;

p_enum_name
	: identifier
	 { $$ = (int)$1; }
	;

p_label_name
	: identifier
	 { $$ = (int)$1; }
	;

p_field_name
	: identifier
	 { $$ = (int)$1; }
	;

p_paren_exp
	: '(' p_list_exp ')'
	 { $$ = new_pnode (paren_exp,$1,$2,$3,-1); }
	;


p_inst_access_exp
	: ME POINTER identifier
	 { $$ = new_pnode (inst_access_exp,$1,$2,0,0,0,$3,0,-1); }
	| ME SQOINTER identifier '.' identifier
	 { $$ = new_pnode (inst_access_exp,$1,$2,0,$3,$4,$5,0,-1); }
	| ME 
 	| BIG_ME '.' identifier
 	 { $$ = new_pnode (inst_access_exp,$1,0,0,$3,$2,0,0,-1); }
	| BIG_ME '.' identifier POINTER identifier
	 { $$ = new_pnode (inst_access_exp,$1,$4,0,$3,$2,$5,0,-1); }
	;


p_primary_p1_exp
	: p_id_name
	| p_literal
	| p_paren_exp
	| SIZEOF '(' p_typename_declaration ')'
	 { $$ = new_pnode (sizeof_fun,$1,$2,$3,$4,-1); }
	| p_inst_access_exp
	;

p_primary_p2_exp
	: p_primary_p1_exp
	 { $$ = $1; }
	| p_primary_p2_exp '[' p_list_exp ']'
	 { $$ = new_pnode (array_access,$1,$2,$3,$4,-1); }
	| p_primary_p2_exp '(' ')' 
	 { $$ = new_pnode (function_call,$1,$2,0,$3,-1); }
	| p_primary_p2_exp '(' p_list_exp ')'
	 { $$ = new_pnode (function_call,$1,$2,$3,$4,-1); }
	| p_primary_p2_exp '.' identifier 
	 { $$ = new_pnode (struct_access,$1,$2,$3,-1); }
	| p_primary_p2_exp POINTER p_field_name
	 { $$ = new_pnode (struct_pointer_access,$1,$2,$3,-1); }
	;

p_primary_exp
	: p_primary_p2_exp ;

p_postfix_exp
	: p_primary_exp
	| p_postfix_exp p_postfix_op
	 { $$ = new_pnode(postfix_exp,$1,$2,-1); }
	;

p_postfix_op
	: PLUS_PLUS
	 { $$ = $1; }
	| MINUS_MINUS
	 { $$ = $1; }
	;

p_prefix_exp
	: p_postfix_exp
	| SIZEOF p_prefix_exp
	 { $$ = new_pnode(unary_exp,$1,$2,-1); }
	| p_prefix_op p_cast_exp
	 { $$ = new_pnode(unary_exp,$1,$2,-1); }
	| '*' p_cast_exp
	 { $$ = new_pnode(unary_exp,$1,$2,-1); }
	| '&' p_cast_exp
	 { $$ = new_pnode(unary_exp,$1,$2,-1); }
	| p_negate_op p_cast_exp
	 { $$ = new_pnode(unary_exp,$1,$2,-1); }
	;

p_prefix_op
	: PLUS_PLUS
	 { $$ = $1; }
	| MINUS_MINUS
	 { $$ = $1; }
	;

p_negate_op
	: '-'
	 { $$ = $1; }
	| '!'
	 { $$ = $1; }
	| '~'
	 { $$ = $1; }
	;

p_cast_exp
	: p_prefix_exp
	| '(' p_typename_declaration ')' p_cast_exp
	 { $$=new_pnode (type_cast,$1,$2,$3,$4,-1); }
	;

p_unary_oper_exp
	: p_cast_exp ;

p_mult_oper_exp
	: p_unary_oper_exp
	| p_mult_oper_exp p_mult_op p_unary_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_mult_op
	: '*'
	 { $$ = $1; }
	| '/'
	 { $$ = $1; }
	| '%'
	 { $$ = $1; }
	;

p_add_oper_exp
	: p_mult_oper_exp
	| p_add_oper_exp p_add_op p_mult_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_add_op
	: '+'
	 { $$ = $1; }
	| '-'
	 { $$ = $1; }
	;

p_shift_oper_exp
	: p_add_oper_exp
	| p_shift_oper_exp p_shift_op p_add_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_shift_op
	: LEFT_SHIFT
	 { $$ = $1; }
	| RIGHT_SHIFT
	 { $$ = $1; }
	;

p_rel_oper_exp
	: p_shift_oper_exp
	| p_rel_oper_exp p_rel_op p_shift_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_rel_op
	: '<'
	 { $$ = $1; }
	| LEQ
	 { $$ = $1; }
	| GEQ
	 { $$ = $1; }
	| '>'
	 { $$ = $1; }
	;

p_equ_oper_exp
	: p_rel_oper_exp
	| p_equ_oper_exp p_equ_op p_rel_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_equ_op
	: EQ
	 { $$ = $1; }
	| NOT_EQ
	 { $$ = $1; }
	;

p_bitand_oper_exp
	: p_equ_oper_exp
	| p_bitand_oper_exp '&' p_equ_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_bitxor_oper_exp
	: p_bitand_oper_exp
	| p_bitxor_oper_exp '^' p_bitand_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_bitor_oper_exp
	: p_bitxor_oper_exp
	| p_bitor_oper_exp '|' p_bitxor_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_and_oper_exp
	: p_bitor_oper_exp
	| p_and_oper_exp AND_AND p_bitor_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_or_oper_exp
	: p_and_oper_exp
	| p_or_oper_exp OR_OR p_and_oper_exp
	 { $$=new_pnode (bin_exp,$1,$2,$3,-1); }
	;

p_cond_exp
	: p_or_oper_exp
	| p_or_oper_exp '?' p_list_exp ':' p_cond_exp
	 { $$=new_pnode (cond_exp,$1,$2,$3,$4,$5,-1); }
	;

p_assign_exp
	: p_cond_exp
	| p_cond_exp p_asgn_op p_exp
	 {
	   $$=new_pnode (bin_exp,$1,$2,$3,-1);
	   if (p_inline_send && !*p_inline_send)
		*p_inline_send = find_inline_send((struct pnode_bin_exp *)$$);
	 }
	;

p_asgn_op
	: '='
	 { $$ = $1; }
	| PLUS_EQUAL
	 { $$ = $1; }
	| MINUS_EQUAL
	 { $$ = $1; }
	| TIMES_EQUAL
	 { $$ = $1; }
	| DIV_EQUAL
	 { $$ = $1; }
	| MOD_EQUAL
	 { $$ = $1; }
	| RSHIFT_EQUAL
	 { $$ = $1; }
	| LSHIFT_EQUAL
	 { $$ = $1; }
	| AND_EQUAL
	 { $$ = $1; }
	| XOR_EQUAL
	 { $$ = $1; }
	| OR_EQUAL
	 { $$ = $1; }
	;

p_exp
	: p_assign_exp
	;

p_list_exp
	: p_exp
	 { $$ = new_pnode (list_exp,0,0,$1,-1); }
	| p_list_exp ',' p_exp
	 { $$ = new_pnode (list_exp,$1,$2,$3,-1); }
	;
