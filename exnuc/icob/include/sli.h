




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                          < 1986, 1987, 1988 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/* sli.h */

#include <stdio.h>
#include <ctype.h>
#include "COBlist_tool.h"
#include "ode_export.h"

#ifdef DEBUG
#define _debug(x) x
#else
#define _debug(x)
#endif

#ifdef VERBOSE
#define _verbose(x) x
#else
#define _verbose(x)
#endif

typedef struct str_rec
  {
    struct str_rec	* owner;
    _COB_list ( struct str_rec, list );
    char		  str [1];
  } str_rec;

typedef struct action_rec
  {
    struct action_rec	* owner; /* for _sli_response, this is ptr to list of */
				 /*   actions/trans to do when trans "fires"  */
    _COB_list ( struct action_rec, list );
    struct action_rec	* trans_or_list; /* for _sli_do_response, this is     */
					 /*   the list of "OR"ed trans	      */
    int			  act;	 /*  Either _sli_do_act   => ACTION,	      */
				 /*  or     _sli_response => TRANS	      */
    char		* str;   /*  "filter", "EX_DATA", etc.		      */
    char		* class; /*	<class>.action			      */
    char		* args;  /*  args for actions in state table	      */
    int			  type;  /*  _ceo_noop, etc.			      */
  } action_rec;

typedef struct symbol		 /*	STATE		    ACTIONS		CLASS			SLIMACROs/KEYWORDS	    */
  {				 /*	-----		    -------		-----			------------------	    */
    struct symbol	* owner; /*			ptr to class where							    */
    				 /*			action is defined							    */
    _COB_list(struct symbol, list);  /*  next and prev pointers to other symbol records in linked list				    */
    char		* name;  /* <state_name> or				class name					    */
				 /*   "all states"										    */
				 /*   "at iwsde"										    */
    int			  offset;/* <state_num> or	    Formerly, action #							    */
				 /*   -990 state *	      (10000 series)							    */
				 /*   -991..-994 "at iwsde"									    */
/*  int			  num;						Formerly, multiplier for action #'s			    */
    int			  begin; /*			pos in file of '{'							    */
    int			  end;	 /*			pos in file of '}'							    */
    short		  type;  /*     STATE		    ACTION		_class_word	       _sli_xxxx (#define/enum)     */
    char		  defined;/* 1 = defined, 0 = not yet defined								    */
    char		  inherited;/*			1=inherited action							    */
    char		* args;	 /*			declared args for this action						    */
    struct symbol	* actions;/*					    all actions defined on class			    */
    action_rec		* acts;	 /*   <action_list>	    Not Used								    */
    str_rec		* strs;  /*								slimacro strings (one str_rec/line) */
    char	* ifdef_name;	 /*    Not Used		"#ifdef <name>"		Not Used		Not Used		    */
    char	* ifndef_name;   /*    Not Used		"#ifndef <name>"	Not Used		Not Used		    */
    char	  endif_flag;	 /*    Not Used     1 =>"#endif" after action	Not Used		Not Used		    */
} symbol;

typedef struct list_rec
  {
    char		* val;
    _COB_list ( struct list_rec , list );
  } list_rec;

/***** these guys must correspond to the keywords in slimacro.SI *****/
/*****	( the "w" words immediately after the message section )  *****/
typedef enum
  {
    _words_offset = 500,
    _cmd_string_word,
    _synonym_word,
    _product_name_word,
    _class_word,
    _super_word,
    _version_word,
    _form_word,
    _start_word,
    _path_word,
    _status_display_word,
    _spec_path_word,
    _options_word,
    _extern_word,
    _output_name_word,
    _spath_word,
    _ipath_word,
    _command_table_word
  } words;

typedef enum
  {
/* actions from .y parse */
    _sli_response = 1,
    _sli_sub_response,
    _sli_do_act,
    _sli_do_class,
    _sli_next,
/* used in sli macro stuff */
    _sli_state_name,
    _sli_message_default,
    _sli_message_decl,
    _sli_method_default,
    _sli_args_default,
    _sli_method_decl,
    _sli_method_top,
    _sli_method_bottom,
    _sli_dots,
    _sli_dot_s_decls,
    _sli_doti,
    _sli_dot_i_decls,
    _sli_class_name,
    _sli_super_name,
    _sli_version,
    _sli_instance_data,
    _sli_override_decl,
    _sli_msgs,
    _sli_methods
  } actions;

#ifdef _is_main
#define _global(var,val) var = val;
#else
#define _global(var,val) extern var;
#endif

_global ( char	* file_name, NULL )	/* .sl input file name */
_global ( char	* temptfile, NULL )	/* temp output ".t" file name */
_global ( int	  line_num, 1 )		/* line counter */
_global ( int	  char_num, 0 )		/* char counter within line */
_global ( int	  errors, 0 )		/* fatal error counter, 0 => no error */
_global ( int	  flush, 0 )		/* counter: 0:not c stuff, +: c stuff */
_global ( int	  arg_list, 0 )		/* flag: f:normal, t:get () line */
_global ( int	  word_val, 0 )		/* current word value */
_global ( char	  flush_char, 0 )	/* char to flush to */
_global ( char	  ignore, 0 )		/* flag: f:compile, t:ignore in lex */
_global ( char	  do_dots, 1 )		/* flag: output .S file */
_global ( char	  do_doti, 1 )		/* flag: output .I file */
_global ( char	  do_dott, 1 )		/* flag: output .T file */
_global ( char	  do_cmd_table, 0 )	/* flag: output cmd_table file*/
_global ( char	  do_print, 0 )		/* flag: print messages */
_global ( char	  do_debug, 0 )		/* flag: debug messages */
_global ( char	  need_actions, 1 )	/* flag: need to scan parent .S files */
_global ( char	* big_str, NULL )	/* a big string for accumulation */
_global ( char	* rm_temp_str, NULL )	/* a string for holding call */
					/*   to remove temp .T file  */
_global ( FILE	* outf, NULL )		/* output file */
_global ( FILE	* tblf, NULL )		/* output table file */
_global ( char	* sym_stack, NULL )	/* really ptrs to stack records */
_global ( char	* act_stack, NULL )
_global ( char	* cob_env, NULL )
_global ( char	* ige_env, NULL )
_global ( char	* draft_env, NULL )
_global ( symbol	* cur_sym, NULL )  /* current active symbol */
_global ( symbol	* all_sp, NULL )   /* state '*' act/trans list*/
_global ( symbol	* class_sp, NULL )
_global ( symbol	* super_sp, NULL )
_global ( symbol	* dot_s_sp, NULL )
_global ( symbol	* dot_i_sp, NULL )
_global ( symbol	* dot_t_sp, NULL )
_global ( symbol	* state_name_sp, NULL )
_global ( symbol	* start_sp, NULL )
_global ( symbol	* prev_sp, NULL )
_global ( symbol	* path_sp, NULL )
_global ( symbol	* spath_sp, NULL )
_global ( symbol	* ipath_sp, NULL )
_global ( symbol	* command_table_sp, NULL )
_global ( symbol	* top_syms, NULL )	/* top level syms */
_global ( symbol	* keywords, NULL )	/* keywords */
_global ( symbol	* var_words, NULL )	/* variable words */
_global ( symbol	* messages, NULL )	/* messages to user */
_global ( char		* level, NULL )		/* output indentation level */
_global ( symbol       ** cur_syms, NULL )	/* ptr to current symbol tbl */
_global ( action_rec   ** cur_act_list, NULL )	/* ptr to current actions lst */
_global ( char		  trans_or_flag, 0 )	/* =1 iff doing ON x OR y */
_global ( action_rec   ** trans_or_ptr, NULL)   /* ptr to ORed trans rec */
