/* -----------------------  macro  -----------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

symbol		* insert_sym (), * find_type ();

void macro ( act )
  actions	  act;
{
  int		  i;
  symbol	* sp;	/** symbol ptr to slimacro strings **/
  symbol	* osp;	/** another symbol ptr to slimacro strings **/
  symbol	* ovsp;	/** symbol ptr to slimacro strings for ovride**/
  static char	  did_defines = 0;

  _verbose(if(do_debug)fprintf(stderr,"macro %d\n",act);)
  switch ( act )
    {
      case _sli_class_name:
	if ( class_sp && outf ) fputs ( class_sp->name, outf );
	if ( ! did_defines )
	  {
	    did_defines = 1;
	    i = 0;
	    /*** go thru the list of parent classes TOP DOWN ***/
	    _COB_rev_for_list ( spp, list, top_syms, symbol )
	      if ( spp->type == _class_word || spp->type == _super_word )
		{
		  /******  GET RID of ACTION #'s -- JAJ:01-18-88  ******
		  if ( spp->type == _class_word ) spp->num = 0;
		  else if ( ! strncmp ( spp->name, "CEO", 3 ))
			spp->num = 0;
		  else  spp->num = ++ i;
		  *****************************************************/
		  define_actions ( spp );
		}
	    _COB_end_for_list
	  }
	break;
      case _sli_super_name:
	i = 0;
	if ( outf )
	  _COB_for_list ( spp, list, top_syms, symbol )
	    if ( spp->type == _super_word && ! spp->inherited )
	      {
		if ( i ++ ) fprintf ( outf, ", " );
		fputs ( spp->name, outf );
	      }
	  _COB_end_for_list /* ( spp ) */
	break;
      case _sli_version:
	sp = find_type ( _version_word );
	if ( ! sp )
	  sp = insert_sym ( "(1:0)", _version_word, 1, "duplicate version");
	if ( sp && outf ) fputs ( sp->name, outf );
	break;
      case _sli_dot_s_decls:
	if ( dot_s_sp && outf ) copy_lines ( outf, dot_s_sp, act );
	break;
      case _sli_dot_i_decls:
	if ( dot_i_sp && outf ) copy_lines ( outf, dot_i_sp, act );
	break;
      case _sli_instance_data:
	sp = find_type ( INSTANCE );
	if ( sp && outf )
	  {
	    fprintf ( outf, "instance " );
	    if ( class_sp ) fputs ( class_sp->name, outf );
	    fprintf ( outf, "\n" );
	    copy_lines ( outf, sp, act );
	  }
	break;
	
      case _sli_msgs:
	sp = find_type ( _sli_message_default );
	osp = find_type ( _sli_message_decl );
	ovsp = find_type ( _sli_override_decl );
	_COB_for_list ( spp, list, class_sp->actions, symbol )

			/*** output if[n]def's -- JAJ:01-22-89 ***/
	  if ( spp->ifdef_name )
	    {
		fprintf ( outf, "#ifdef %s\n", spp->ifdef_name );
	    }
	  else if ( spp->ifndef_name )
	    {
		fprintf ( outf, "#ifndef %s\n", spp->ifndef_name );
	    }

	  if ( ! spp->inherited && spp->defined && outf )
	   {
	    if ( spp->args ) /** if it has a non-std arg list **/
	      {
		if ( osp )
		    put_strs ( osp->strs, outf, spp->name, spp->args );
	      }
	    else   /** it has a std arg list from slimacro.SI **/
	      {
		if ( sp ) put_strs ( sp->strs, outf, spp->name );
	      }
	   }
	  else if ( spp->inherited && spp->defined && outf && ovsp )
	      put_strs ( ovsp->strs, outf, spp->name );

			/*** output endif's -- JAJ:01-22-89 ***/
	  if ( spp->endif_flag )
	    {
		fprintf ( outf, "#endif\n" );
	    }

	_COB_end_for_list /* ( spp ) */
	break;
      case _sli_doti:
	if ( do_doti ) open_file ( & outf, "i.I" );
	else
	  {
	  if(outf != NULL)  fclose ( outf );
	    outf = NULL;
	    flush = 0;
	  }
	/*** open the .T file also, to fix the bug where if you say ***/
	/***   slic -t 		it leaves stuff out of the .I file  ***/
	if ( do_dott ) open_file ( & tblf, ".T" );
	else
	 {
#ifndef NT
	    tblf = fopen ( "/dev/null", "w" );
#else
	    tblf = fopen ( "c:\\temp\\null", "w" );
#endif
	    if ( tblf == NULL ) printf ("macro.C:  Couldn't open tblf as /dev/null\n" );
	 }
	break;
      case _sli_dots:
	if ( do_dots )
	  open_file ( & outf, ".S" );
	else
	  {
	  if (outf != NULL) fclose ( outf );
	    outf = NULL;
	    flush = 0;
	  }
	break;
      case _sli_state_name:
      case _sli_message_default:
      case _sli_message_decl:
      case _sli_override_decl:
      case _sli_method_default:
      case _sli_args_default:
      case _sli_method_decl:
      case _sli_method_top:
      case _sli_method_bottom:
      /*** case _sli_action_top:	***/
      /*** case _sli_action_default:	***/
      /*** case _sli_action_send_up:	***/
      /*** case _sli_action_bottom:	***/
      /*** case _sli_pred_top:		***/
      /*** case _sli_pred_bottom:	***/
      /*** case _sli_case:		***/
      /*** case _sli_break:		***/
      /*** case _sli_send_default:	***/
      /*** case _sli_send_args:		***/
	flush = 1;
	ignore = 1;
	cur_sym = insert_sym ( "", act, 1, "duplicate symbol" );
	big_str [0] = NULL;
	break;
      case _sli_methods:
	define_states ();
	if ( tblf )
	  {
	    table_out ();
	 if(tblf != NULL)   fclose ( tblf );
	    tblf = NULL;
	  }
	sp = find_type ( _sli_method_default );
	osp = find_type ( _sli_method_decl );
	_COB_for_list ( spp, list, class_sp->actions, symbol )

	  if ( spp->type == ACTION && outf )
	    {
		/*** output if[n]def's -- JAJ:01-22-89 ***/
	      if ( spp->ifdef_name )
		{
		    fprintf ( outf, "#ifdef %s\n", spp->ifdef_name );
		}
	      else if ( spp->ifndef_name )
		{
		    fprintf ( outf, "#ifndef %s\n", spp->ifndef_name );
		}

	      if ( spp->defined )	/* action's not "extern"'ed */
		{
		  if ( spp->begin )
		    {
		      if ( spp->args )
			{
			  if ( osp )
			    put_strs ( osp->strs, outf, spp->name, spp->args );
			}
		      else
			if ( sp ) put_strs ( sp->strs, outf, spp->name );

		      copy_lines ( outf, spp, act );
		    }
		}

			/*** output endif's -- JAJ:01-22-89 ***/
	      if ( spp->endif_flag )
		{
			fprintf ( outf, "#endif\n" );
		}
	    }
	_COB_end_for_list /* ( spp ) */
	break;
    }

  return;
} /* macro */
