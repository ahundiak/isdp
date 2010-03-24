/* actions/do_it_a.I -- must be in a .I file for om$send to work */
class implementation Root;

#include <stdio.h>
#include <OMerrordef.h>
#include <ODE.h>
#include <COBstructs.h>
#include <ctype.h>	/*** need this for isdigit ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#endif


_debug(extern int COBtrace;)
_debug(extern int actions_debug;)
#define TFLAG ( COBtrace  ||  actions_debug )
#define ACT_TRANS  ( actions_debug )

from CEO import arg_name_to_value;

void COB_arg_value_pack();
%safe
static int COB_actions_eval_cond();
%endsafe

COBactions_do_it ( action_ptr, cmd_oid, sts )
  struct COBaction	* action_ptr;
  OM_S_OBJID	 	  cmd_oid;	/* oid of cmd object */
  int			* sts;
{
  int	  value_type;	   /* type of arg value returned from	      */
			   /*   CEO.arg_name_to_value()		      */
  int	  values_addr = 0; /* index into me->values the values	      */
			   /*   ALSO == byte size of arg list	      */
  COB_arg_union data;	   /* the actual value of me->args[ii]	      */
  int	  ii, status;
  OM_S_MESSAGE msg;	   /* msg struct built by om$make_message ()  */
  char	* arg_ch;
  int	  arg_mode;	   /* _COB_address, _COB_indirect, etc.       */

  _bugprint(bflag=TFLAG, str =
	"+COBactions_do_it:  action_ptr=(0x)%x, cmd_oid=%d\n",
	var = `action_ptr, cmd_oid` )

  /*** *sts = OM_S_SUCCESS; DON'T reset this here ***/

	/*** pack the values array with the value of each argument ***/
  for ( ii = 0; ii < action_ptr->num_args ; ii++ )
    {
      if ( action_ptr->args_index[ii] == -1 )
	  action_ptr->args_index[ii] = values_addr;
      else
	  values_addr = action_ptr->args_index[ii];

      if ( ! action_ptr->is_const[ii] )
	{
	  /*** if there is no arglist ( the empty string ),	***/
	  /***   then don't evaluate it ever -- JAJ:05-27-88	***/
	  if ( ! strcmp ( action_ptr->args[ii], "" ) )
	    {
		action_ptr->is_const[ii] = 1;
		break;
	    }

	  arg_ch = action_ptr->args[ii];

  	  arg_mode = _COB_regular;

	  _bugprint(bflag=ACT_TRANS, str =
	      "Calling COB_actions_eval_cond ( arg='%s', cmd_oid=%d,\n",
	      var = `arg_ch, cmd_oid` )
	  _bugprint(bflag=ACT_TRANS, str =
	      "\t\t&is_const[%d], arg_mode=%d )\n",
	      var = `ii, arg_mode` )

	  status = COB_actions_eval_cond ( &arg_ch, & data, &value_type,
		      cmd_oid, & action_ptr->is_const[ii], & arg_mode );
	  _bugprint(bflag=ACT_TRANS, str =
		"After COB_actions_eval_cond(arg='%s',\n",
		var =`arg_ch`)
#ifdef DEBUG
	  if ( value_type == _COB_arg_f )
	    {
	      _bugprint(bflag=ACT_TRANS, str =
			"\t\t data.f = %f,\n", var =`data.f`)
	    }
	  else if ( value_type == _COB_arg_d )
	    {
	      _bugprint(bflag=ACT_TRANS, str =
			"\t\t data.d = %lf,\n", var =`data.d`)
	    }
	  else if ( value_type == _COB_arg_s  || 
		    value_type == _COB_arg_us    )
	    {
	      _bugprint(bflag=ACT_TRANS, str =
			"\t\t data.s = %hd,\n", var =`data.s`)
	    }
	  else if ( value_type == _COB_arg_p )
	    {
	      _bugprint(bflag=ACT_TRANS, str =
			"\t\t data.p = 0x%x,\n", var =`data.p`)
	    }
	  else
	    {
	      _bugprint(bflag=ACT_TRANS, str =
			"\t\t data.l = %d,\n", var =`data.l`)
	    }
#endif
	  _bugprint(bflag=ACT_TRANS, str =
		"\t\ttype=%d, is_const[%d]=%hd, arg_mode=%d )\n",
		var =`value_type, ii, action_ptr->is_const[ii], arg_mode`)

	      /*** See if the argument string got translated ok ***/
	  if ( ! ( status & 1) )
	    {
	      *sts = COB_E_ARG_NOT_FOUND;
	      status = OM_I_STOP_SENDING;
	      goto quit;
	    }

	  /*** Actually pack the data->__ value into the right spot ***/
	  /***   (based on the size alignment) into the msg_arglist ***/
	  COB_arg_value_pack ( action_ptr->values, &data,
					value_type, &values_addr);

	} /* end of if ( ! action_ptr->is_const[ii] ) */

  } /* end for loop */

      /*** Construct the message structure ***/
      status = om$make_message (
			classname = action_ptr->class_name,
			methodname = action_ptr->message_name,
			size = values_addr,  /*** OM ignores this ***/
			p_arglist = action_ptr->values,
			p_msg = & msg );
      _bugprint(bflag=ACT_TRANS, str =
	    "After om$make_msg(msg='%s.%s', size/addr=%d): status=%d\n",
	    var=`action_ptr->class_name,action_ptr->message_name,values_addr,status`);
      if ( ! (status&1) )
	{
	  fprintf(stderr,
	   "\nCOBactions_do_it():  om$make_message (%s.%s) failed: status = %d.\n\n",
	   action_ptr->class_name, action_ptr->message_name, status );
	  goto quit;
	}

      /*** Actually send the message ***/
      status = om$send ( senderid = cmd_oid,
			 targetid = cmd_oid,
			 msg = & msg );
      _bugprint(bflag=ACT_TRANS, str =
	    "After om$send(msg='%s.%s',targetid=%d): status = %d\n",
	    var = `action_ptr->class_name, action_ptr->message_name, cmd_oid, status` );
      if ( ! (status&1) )
	{
	  fprintf(stderr,
		   "\nCOBactions_do_it():  om$send (%s.%s) failed.\n",
		   action_ptr->class_name, action_ptr->message_name );
	  om$report_error ( sts = status );
	  goto quit;
	}

quit:
  _bugprint(bflag=TFLAG, str =
	"-COBactions_do_it:  ret status=%d, *sts = %d\n",
	var = `status, *sts` )
  return status;	/*** DON'T return OM_S_SUCCESS here !!! ***/
}	/*** end of COBactions_do_it() ***/



/*--------------------------------------------------------------------*/
void COB_actions_cast_arg_type ( arg_str, cast_type )
  char ** arg_str;
  int	* cast_type;
{
#define TEMP_CAST_DIM 30
  int	ii;
  char	temp_cast[TEMP_CAST_DIM];
  char  * ch;

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_cast_arg_type():  arg_str='%s', *cast_type=%d\n",
	 var = `*arg_str, *cast_type` )

  *cast_type = -1;

  if ( ** arg_str == '(' )
    {
      for ( ii=0, ch = *arg_str + 1;
		 ii < TEMP_CAST_DIM  &&  *ch  &&  *ch != ')';
							ch++, ii++ )
	{
	  temp_cast[ii] = *ch;
	}

      if ( *ch == ')' )
	{
	  temp_cast[ii] = '\0';

	  _bugprint(bflag=ACT_TRANS, str =
		"temp_cast='%s'\n", var = temp_cast )

	  if ( *(ch -1) == '*' )
	    *cast_type = _COB_arg_p;
	  else if ( ! strcmp ( temp_cast, "char" ) )
  	    *cast_type = _COB_arg_c;
	  else if ( ! strcmp ( temp_cast, "short" )	||
		/*** CEO.read_t_file strips off spaces separating ***/
		/***   things like "short int" 			  ***/
	  	    ! strcmp ( temp_cast, "shortint" ) )
  	    *cast_type = _COB_arg_s;
	  else if ( ! strcmp ( temp_cast, "int" ) )
	    *cast_type = _COB_arg_i;
	  else if ( ! strcmp ( temp_cast, "long" )	||
	  	    ! strcmp ( temp_cast, "longint" ) )
	    *cast_type = _COB_arg_l;
	  else if ( ! strcmp ( temp_cast, "unsignedchar" ) )
	    *cast_type = _COB_arg_uc;
	  else if ( ! strcmp ( temp_cast, "unsignedshort" ) ||
	  	    ! strcmp ( temp_cast, "unsignedshortint" ) )
	    *cast_type = _COB_arg_us;
	  else if ( ! strcmp ( temp_cast, "unsigned" )	||
	  	    ! strcmp ( temp_cast, "unsignedint" ) )
	    *cast_type = _COB_arg_ui;
	  else if ( ! strcmp ( temp_cast, "unsignedlong" ) ||
	  	    ! strcmp ( temp_cast, "unsignedlongint" ) )
	    *cast_type = _COB_arg_ul;
	  else if ( ! strcmp ( temp_cast, "float" ) )
	    *cast_type = _COB_arg_f;
	  else if ( ! strcmp ( temp_cast, "double" ) )
	    *cast_type = _COB_arg_d;
	  else if ( ! strcmp ( temp_cast, "OM_S_OBJID" ) )
	    *cast_type = _COB_arg_oid;
	  else
	      /*** this is a parenthetical expression, not a cast ***/
	    goto quit;

	  ch++;	/*** skip the closing ')' ***/
	  * arg_str = ch;   /*** advance arg_str itself ***/
	}

    } /*** end of if **arg_str[0] == '(' ***/

quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_cast_arg_type():  new arg_str='%s', *cast_type=%d\n",
	 var = `*arg_str, *cast_type` );
}	/*** end of function COB_actions_cast_arg_type() ***/



/*--------------------------------------------------------------------*/
COB_actions_cast_arg ( data, value_type, cast_type )
  COB_arg_union * data;
  int		* value_type;
  int		  cast_type;
{
  char *   Warning_Unknown	  = "\nWarning:  Unknown ";
  char *   In_Arg_In_State_Table  = " in argument in command's state table.\n\n";

  _bugprint(bflag=ACT_TRANS, str =
	"+COB_actions_cast_arg():  data->l=%ld, *value_type=%d, cast_type=%d\n",
	 var = `data->l, *value_type, cast_type` )

  if ( *value_type == cast_type )
    goto quit;	/*** they're already the same type ***/


#define CAST_IT(dd,cc) \
	{ \
	  switch ( *value_type ) \
	    { case _COB_arg_c : dd = ( cc ) data->c  ; break; \
	      case _COB_arg_uc: dd = ( cc ) data->uc ; break; \
	      case _COB_arg_s : dd = ( cc ) data->s  ; break; \
	      case _COB_arg_us: dd = ( cc ) data->us ; break; \
	      case _COB_arg_i :\
	      case _COB_arg_l : dd = ( cc ) data->l  ; break; \
	      case _COB_arg_ui :\
	      case _COB_arg_ul :\
	      case _COB_arg_oid:dd = ( cc ) data->ul ; break; \
	      case _COB_arg_p : dd = ( cc ) data->p  ; break; \
	      case _COB_arg_f : dd = ( cc ) (int) data->f  ; break; \
	      case _COB_arg_d : dd = ( cc ) (int) data->d  ; break; \
	      default: fprintf ( stderr, \
				"%svalue type %d%s", \
				Warning_Unknown, *value_type, \
				In_Arg_In_State_Table );\
			break; }\
	} /*** end CAST_IT ***/

#define CAST_IT_FD(dd,cc) \
	{ /*** must use this for casting to floats and doubles ***/\
	  switch ( *value_type ) \
	    { case _COB_arg_c : dd = ( cc ) data->c  ; break; \
	      case _COB_arg_uc: dd = ( cc ) data->uc ; break; \
	      case _COB_arg_s : dd = ( cc ) data->s  ; break; \
	      case _COB_arg_us: dd = ( cc ) data->us ; break; \
	      case _COB_arg_i :\
	      case _COB_arg_l : dd = ( cc ) data->l  ; break; \
	      case _COB_arg_ui :\
	      case _COB_arg_ul :\
	      case _COB_arg_oid:dd = ( cc ) data->ul ; break; \
	      case _COB_arg_p : fprintf ( stderr, \
		    "\nWarning:  Can't type cast (char *) to (%s)%s", \
		    (cast_type == _COB_arg_f) ? "float" : "double", \
		    In_Arg_In_State_Table ); \
		 break; \
	      case _COB_arg_f : dd = ( cc ) data->f  ; break; \
	      case _COB_arg_d : dd = ( cc ) data->d  ; break; \
	      default:	fprintf ( stderr, \
				"%svalue type %d", \
				Warning_Unknown, *value_type, \
				In_Arg_In_State_Table ); \
			 break; }\
	} /*** end CAST_IT_FD ***/


  switch ( cast_type )
    {
      case _COB_arg_c:
	CAST_IT ( data->c, char )
	break;

      case _COB_arg_s:
	CAST_IT ( data->s, short )
	break;

      case _COB_arg_i:
      case _COB_arg_l:
	CAST_IT ( data->l, long )
	break;

      case _COB_arg_uc:
	CAST_IT ( data->uc, unsigned char )
	break;

      case _COB_arg_us:
	CAST_IT ( data->us, unsigned short )
	break;

      case _COB_arg_ui:
      case _COB_arg_ul:
      case _COB_arg_oid:
	CAST_IT ( data->ul, unsigned long )
	break;

      case _COB_arg_f:
	CAST_IT_FD ( data->f, float )
	break;

      case _COB_arg_d:
	CAST_IT_FD ( data->d, double )
	break;

      case _COB_arg_p:
	CAST_IT ( data->p, char * )
	break;

      default:
	fprintf ( stderr,
		    "%stype casting '%d'",
		    Warning_Unknown, cast_type, In_Arg_In_State_Table );
	return _COB_UNKNOWN_ARG;
	/*break;*/
    } /*** end switch (cast_type) ***/

  * value_type = cast_type;

quit:
  _bugprint(bflag=ACT_TRANS, str =
	"-COB_actions_cast_arg():  *value_type=%d, cast_type=%d\n",
	 var = `*value_type, cast_type` )
  return OM_S_SUCCESS;
}	/*** end of function COB_actions_cast_arg() ***/



/*--------------------------------------------------------------------*/
/*  Examine the given argument string ( already chopped up into an    */
/*    individual string from the entire argument string ) and see if  */
/*    it's a constant						      */
COB_actions_const_arg ( arg_str, data, value_type )
  char		* arg_str;
  COB_arg_union * data;
  int		* value_type;
{
  int	 is_const = 1;
  char * ch;
  char	 could_be_float = 0;
  char	 could_be_octal = 0;

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_const_arg():  arg_str='%s', data, *value_type=%d\n",
	 var = `arg_str, *value_type` )

  if ( arg_str[0] == '"' )	/* it's a character string */
    {
	data->p = &arg_str[1];
	if ( data->p[ strlen( data->p ) -1 ] == '"' )
	    data->p[ strlen( data->p ) -1 ] = '\0';
	* value_type = _COB_arg_p;
	_bugprint(bflag=ACT_TRANS, str =
	    "[string] data->p=(0x)%x  =?=  &arg_str[1]=(0x)%x\n",
	    var = `data->p, &arg_str[1]` )
    }
  else if ( arg_str[0] == '\'' ) /* it's a single character */
    {
	data->c = arg_str[1];
	* value_type = _COB_arg_c;
	_bugprint(bflag=ACT_TRANS, str =
	    "[char] data->c='%c'  =?=  arg_str[1]='%c'\n",
	    var = `data->c, arg_str[1]` )
    }
  else if ( ! strncmp ( arg_str, "0x", 2 ) ) /* it's a hex constant */
    {
	sscanf ( arg_str, "0x%x", & data->l );
	* value_type = _COB_arg_l;
	_bugprint(bflag=ACT_TRANS, str =
	    "[hex long] data->l=(0x)%x  =?=  sscanf(arg_str='%s')\n",
	    var = `data->l, arg_str` )
    }
  else	/* maybe it's an decimal int, octal int, or floating constant */
    {
      if ( arg_str[0] == '0' )
	could_be_octal = 1;

      for ( ch = arg_str; *ch ; ch++ )
	{
	  if ( * ch == '.' )
	    {
	      could_be_float = 1;
	      could_be_octal = 0;
	    }
	  else if ( ! isdigit(*ch) )
	    {
	      /*
		could_be_float = 0;
		could_be_octal = 0;
	      */
	      is_const = 0;
	      break;
	    }
	  else if ( *ch == '8' || *ch == '9' )
	    could_be_octal = 0;
	} /* end for */

      if ( is_const )
	{
	  if ( could_be_float )
	    {
	      sscanf ( arg_str, "%lf", & data->d );
	      * value_type = _COB_arg_d;
	      _bugprint(bflag=ACT_TRANS, str =
		  "[double] data->d=%lf  =?=  sscanf(arg_str='%s')\n",
		  var = `data->d, arg_str` )
	    }
	  else if ( could_be_octal )
	    {
	      sscanf ( arg_str, "%lo", & data->l );
	      * value_type = _COB_arg_l;
	      _bugprint(bflag=ACT_TRANS, str =
		  "[octal long] data->l=%lo  =?=  sscanf(arg_str='%s')\n",
		  var = `data->l, arg_str` )
	    }
	  else /*** it must be a decimal integer ***/
	    {
	      sscanf ( arg_str, "%ld", & data->l );
	      * value_type = _COB_arg_l;
	      _bugprint(bflag=ACT_TRANS, str =
		  "[long] data->l=%ld  =?=  sscanf(arg_str='%s')\n",
		  var = `data->l, arg_str` )
	    }
	}
    }

  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_const_arg(data->l=%d,*value_type=%d): ret (is_const) = %d\n",
	 var = `data->l, *value_type, is_const` )

  return is_const;
}	/*** end of function COB_actions_const_arg() ***/



/*--------------------------------------------------------------------*/
void COB_arg_value_pack( values, data, value_type, values_addr)
  char		  values[];
  COB_arg_union	* data;
  int		  value_type;
  int		* values_addr;	/* next empty space ( may or may not )*/
				/*   be on a type boundary	      */
{ 
#ifdef DEBUG
  char		* debug_c;
  unsigned char	* debug_uc;
  short		* debug_s;
  unsigned short *debug_us;
  long   	* debug_l;
  unsigned long	* debug_ul;
  float  	* debug_f;
  double 	* debug_d;
  int   	* debug_ptr;
#endif

  _bugprint(bflag=ACT_TRANS, str =
	"+COB_arg_value_pack(type=%d, *addr(size)=%d)\n",
	 var = `value_type, *values_addr` )

  /*** General idea here:	 ***/
  /* if ( size > 1 )		   */
  /*	  values_addr = ( values_addr + size - 1 ) & ( - size ) ; */
  /* values [ values_addr ] = data */
  /* values_addr += size ;	   */

  switch ( value_type )
    {
      case _COB_arg_c:
	values[ (*values_addr)++ ] = data->c ;
#ifdef DEBUG
	debug_c = (char *) & values [ (*values_addr) - 1 ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(char) '%c'  =?=  data->c= '%c'\n",
	     var = `(*values_addr)-1, * debug_c, data->c` )
	break;

      case _COB_arg_uc:
	values[ (*values_addr)++ ] = data->uc ;
#ifdef DEBUG
	debug_uc = (unsigned char *) & values [ (*values_addr) - 1 ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(uc) '%c'  =?=  data->uc= '%c'\n",
	     var = `(*values_addr)-1, * debug_uc, data->uc` )
	break;

      case _COB_arg_s:
	*values_addr = (*values_addr + sizeof ( short ) - 1 )
				 & ( - sizeof ( short ) ) ;
	memcpy ( &(values[*values_addr]), &(data->s), sizeof( short ));
#ifdef DEBUG
	debug_s = (short *) & values [ *values_addr ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(short) %hd  =?=  data->s= %hd\n",
	     var = `*values_addr, * debug_s, data->s` )
	(*values_addr) += sizeof ( short );
	break;

      case _COB_arg_us:
	*values_addr = (*values_addr + sizeof ( unsigned short ) - 1 )
				 & ( - sizeof ( unsigned short ) ) ;
	memcpy ( &(values[*values_addr]), &(data->us),
					sizeof( unsigned short ));
#ifdef DEBUG
	debug_us = (unsigned short *) & values [ *values_addr ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(us) %hd  =?=  data->us= %hd\n",
	     var = `*values_addr, * debug_us, data->us` )
	(*values_addr) += sizeof ( unsigned short );
	break;

      case _COB_arg_i:
      case _COB_arg_l:
	*values_addr = (*values_addr + sizeof ( long ) - 1 )
				 & ( - sizeof ( long ) ) ;
	memcpy ( &(values[*values_addr]), &(data->l), sizeof( long ));
#ifdef DEBUG
	debug_l = (long *) & values [ *values_addr ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(l) %ld  =?=  data->l= %ld\n",
	     var = `*values_addr, *debug_l, data->l` )
	(*values_addr) += sizeof ( long );
	break;

      case _COB_arg_ui:
      case _COB_arg_ul:
      case _COB_arg_oid:
	*values_addr = (*values_addr + sizeof ( unsigned long ) - 1 )
				 & ( - sizeof ( unsigned long ) ) ;
	memcpy ( &(values[*values_addr]), &(data->ul),
					sizeof( unsigned long ));
#ifdef DEBUG
	debug_ul = (unsigned long *) & values [ *values_addr ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(ul) %ld  =?=  data->ul= %ld\n",
	     var = `*values_addr, *debug_ul, data->ul` )
	(*values_addr) += sizeof ( unsigned long );
	break;

      case _COB_arg_f:
	*values_addr = (*values_addr + sizeof ( float ) - 1 )
				 & ( - sizeof ( float ) ) ;
	memcpy ( &(values[*values_addr]), &(data->f), sizeof( float ));
#ifdef DEBUG
	debug_f = (float *) & values [ *values_addr ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(float) %f  =?=  data->f= %f\n",
	     var = `*values_addr, * debug_f, data->f`)
	(*values_addr) += sizeof ( float );
	break;

      case _COB_arg_d:
	*values_addr = (*values_addr + sizeof ( double ) - 1 )
				 & ( - sizeof ( double ) ) ;
	_bugprint(bflag=ACT_TRANS, str =
	  "BEFORE MEMCPY: &values[%d]=0x%x ; data->d=%lf; &data->d=0x%x\n",
	  var = `*values_addr, &(values[*values_addr]), data->d, &(data->d)`)

	memcpy ( &(values[*values_addr]), &(data->d), sizeof( double ));

#ifdef DEBUG
	debug_d = (double *) & values [ *values_addr ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]=(double) %lf  =?=  data->d= %lf\n",
	     var = `*values_addr, * debug_d, data->d`)
	(*values_addr) += sizeof ( double );
	break;

      case _COB_arg_p:
	*values_addr = (*values_addr + sizeof ( char * ) - 1 )
				 & ( - sizeof ( char * ) ) ;
	memcpy ( &(values[*values_addr]), &(data->p), sizeof( char * ));
#ifdef DEBUG
	debug_ptr = (int *) & values [ *values_addr ] ;
#endif
	_bugprint(bflag=ACT_TRANS, str =
	    "values[%d]= (0x)%x  =?=  data->p= (0x)%x\n",
	     var = `*values_addr, * debug_ptr, data->p`)
	(*values_addr) += sizeof ( char * );
	break;

      default:	/* this should NEVER HAPPEN */
	fprintf ( stderr,
	  "\nWarning(COBactions_do_it):  Unknown argument type %d in om$make_msg\n\n",
	  value_type );
	break;
    } /* end switch (value_type) */

  _bugprint(bflag=ACT_TRANS, str =
	"-COB_arg_value_pack(type=%d, *addr(size)=%d)\n",
	 var = `value_type, *values_addr` )
  _bugprint(bflag=ACT_TRANS, str = "\n" )

}	/*** end of function COB_arg_value_pack() ***/


/*** take the argument string and chop off the first individual ***/
/***   "isolated" argument					***/
/*** NOTE:  Never call this with an arg string of the form	***/
/***	    "xxx" or 'x', as you will get back the address of a ***/
/***	    local variable string, and not the address of the	***/
/***	    real character constant string			***/
static COB_actions_isolate_arg_str ( isolated_arg, arg_str )
  char  * isolated_arg;
  char ** arg_str;
{
  int	 ii;
  char   found_end_of_arg;

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_isolate_arg_str( arg_str='%s' ):\n", var = `*arg_str`)

  for ( ii = 0, found_end_of_arg = 0 ;
		 ** arg_str && ! found_end_of_arg ; ii++, (*arg_str)++ )
    {
      isolated_arg[ii] = **arg_str;

      if ( isspace( ** arg_str )   ||  ** arg_str == '|'  ||
		** arg_str == '&'  ||  ** arg_str == '^'  ||
		** arg_str == '('  ||  ** arg_str == ')'  ||
		** arg_str == '~'  ||  ** arg_str == '!'  ||
		** arg_str == '*'  ||
	   ( **arg_str == '-' &&	/*** JAJ:10-03-88 ***/
		( *(*arg_str+1) ? *(*arg_str+1) != '>' : 1 ) )
	    ||	** arg_str == '+'  ||  ** arg_str == '?'  ||
		** arg_str == ':'  )
	{
	  found_end_of_arg = 1;
	  break;	/*** don't advance ii and *arg_str ***/
	}
    }

  isolated_arg[ii] = '\0';


  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_isolate_arg_str( arg_str='%s', isolated_arg='%s' )\n",
	 var = `*arg_str, isolated_arg` );
}


/* --------------------- */
static long COB_actions_eval_primary ( arg_str, arg_val, arg_mode,
			       arg_type, class_name, cmd_oid, is_const )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_mode;
  int		 * arg_type;
  char		 * class_name;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
{
  char		isolated_arg[515];
  int		status = OM_S_SUCCESS;
  char		char_is_const;

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_primary( arg_str='%s', class='%s', arg_mode=%d, cmd_oid=%d ):\n",
	 var = `*arg_str, class_name, *arg_mode, cmd_oid` )

	/*** clear out isolated_arg ***/
  isolated_arg[0] = '\0';

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  if ( ** arg_str == '(' )	/*** enter another level of ()'s ***/
    {
      ++ * arg_str;
      status = COB_actions_eval_cond ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode );
      if ( ! ( 1 & status ) )
	goto quit;

      if ( ** arg_str == ')' ) ++ * arg_str;
    }
  else
    {

      if ( ! class_name[0] ) /*** previously found a "me->" unary operator ***/
	{
	  if ( **arg_str == '"'  || **arg_str == '\'' )
	    {
	 	/*** at this point, we definitely have a char const ***/
	      * is_const = COB_actions_const_arg ( *arg_str,
					    arg_val, arg_type );

		/*** advance arg_str to the end ***/
	      ** arg_str = NULL;
	    }
	  else
	    { /*** "isolate" the next individual argument from the ***/
	      /***   argument expression; also, advance * arg_str  ***/
	      COB_actions_isolate_arg_str ( isolated_arg, arg_str );

	      /*** figure out if the arg was constant and not a var ***/
	      * is_const = COB_actions_const_arg ( isolated_arg,
					    arg_val, arg_type );
	    }
	}

      if ( ! *is_const )
	{
	  if ( ! isolated_arg[0] )
	    {
	      /*** "isolate" the next individual argument from the ***/
	      /***   argument expression; also, advance * arg_str  ***/
	      COB_actions_isolate_arg_str ( isolated_arg, arg_str );
	    }

	  _bugprint(bflag=ACT_TRANS, str =
		  "Sending CEO.arg_name_to_value(arg_mode=%d,class_name='%s',arg='%s')\n",
		  var = `*arg_mode, class_name, isolated_arg` )
	  status = om$send ( senderid = cmd_oid, targetid = cmd_oid,
			msg = message CEO.arg_name_to_value ( *arg_mode,
				class_name, isolated_arg,
			      arg_val, arg_type, &char_is_const ) );
	  *is_const = char_is_const;	/*** JAJ:11-29-88 ***/
	  _bugprint(bflag=ACT_TRANS, str =
		"Sent CEO.arg_name_to_value(arg='%s', arg_val->l=%ld, type=%d, *is_const=%hd )\n",
	       var =`isolated_arg, arg_val->l, *arg_type, *is_const`)

	  /*** See if the argument string got translated ok ***/
	  if ( * arg_type == _COB_UNKNOWN_ARG )
	    {
	      fprintf ( stderr,
		   "\nWarning:  Unknown argument '%s' in command's state table\n\n", isolated_arg );
	      status = COB_E_ARG_NOT_FOUND;
	      goto quit;
	    }
	  else if ( ! ( status & 1 ) )
	    {
	      goto quit;
	    }

	} /* end if ! is_const */

    } /*** else no ()'s ***/

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_eval_primary( arg_str='%s', arg_val->l=%ld, *arg_type=%d ): status = %d\n",
	 var = `*arg_str, arg_val->l, *arg_type, status` );
  return status;

} /* COB_actions_eval_primary */



/* --------------------- */
static long COB_actions_eval_unary_ME ( arg_str, arg_val, arg_mode,
			       arg_type, cmd_oid, is_const )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_mode;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
{
  char	  class_name[50];  /* ==> me->arg[ii] ==		      */
			   /*		  "me[class_name]->something" */
  int		jj, status = OM_S_SUCCESS;

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_unary_ME( arg_str='%s', arg_mode=%d, cmd_oid=%d ):\n",
	 var = `*arg_str, *arg_mode, cmd_oid` )

	/*** default it to not be instance data ***/
  class_name[0] = '\0';

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

      /*****************************************************/
      /*** see if there was a "me[class]->" of some kind ***/
      /*****************************************************/
  if ( ! strncmp ( * arg_str, "me->", 4 ) )
    {
      * arg_str += 4;

      status = om$get_classname ( objid = cmd_oid,
			      classname = class_name );
      if ( ! ( status & 1 ) )
	{
	  fprintf(stderr,
		"\nWarning(COBactions_do_it):  Couldn't get class name for state table argument '%s'\nfor command obj oid %d; status = (0x)%x\n\n",
		*arg_str, cmd_oid, status );
	  status = OM_E_BADCLASSNAME;
	  goto quit;
	}
    }
  else if ( ! strncmp ( * arg_str, "me^^", 4 ) )
    {
      * arg_str += 4;
	  /* copy the given  "me^^<classname>.xxx" into the   */
	  /*   argument for the send of CEO.arg_name_to_value */
      for ( jj = 0;  ** arg_str && **arg_str != '.' ; jj++, (*arg_str)++ )
	{
	  class_name[jj] = ** arg_str;
	}
      class_name[jj] = '\0';

      if ( ** arg_str == '.' )
	{
	  (*arg_str)++;	/*** advance past the '.' ***/
	}
      else
	{		/********   ERROR  **********/
	  fprintf(stderr,
		"\nWarning(COBactions.do_it):  Malformed class name in command's state table action argument '%s'\n\n",
		class_name );
	  status = OM_E_BADCLASSNAME;
	  goto quit;
	}
    }
  else if ( ! strncmp ( * arg_str, "ME.", 3 ) )
    {
      * arg_str += 3;
	  /* copy the given  "ME.<classname>->xxx" into the   */
	  /*   argument for the send of CEO.arg_name_to_value */
      for ( jj = 0; **arg_str && **arg_str != '-' ; jj++, (*arg_str)++ )
	{
	  class_name[jj] = **arg_str;
	}
      class_name[jj] = '\0';

      if ( ** arg_str == '-' && *(*arg_str + 1) == '>' )
	{
	  * arg_str += 2;	/*** advance past the "->" ***/
	}
      else
	{		/********   ERROR  **********/
	  fprintf(stderr,
		"\nWarning(COBactions.do_it):  Malformed class name in command's state table action argument '%s'\n\n",
		class_name );
	  status = OM_E_BADCLASSNAME;
	  goto quit;
	}
    }
  _bugprint(bflag=ACT_TRANS, str =
    "Calling eval_primary (class_name = '%s')\n", var = `class_name` )

  status = COB_actions_eval_primary ( arg_str, arg_val, arg_mode,
		       arg_type, class_name, cmd_oid, is_const );
  /*** if ( ! ( status & 1 ) ) goto quit; ***/

quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_eval_unary_ME( arg_str='%s', arg_val->l=%ld, *arg_type=%d, mode=%d ): status = %d\n",
	 var = `*arg_str, arg_val->l, *arg_type, *arg_mode, status` )

  return status;
} /* COB_actions_eval_unary_ME */



/* --------------------- */
static long COB_actions_eval_unary ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  int		   cast_type;
  int		   status = OM_S_SUCCESS;

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_unary( arg_str='%s', cmd_oid=%d, mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  /*** figure out if there was an explicit "cast" operator;  ***/
  /***   if not, set * arg_type = -1			     ***/
  COB_actions_cast_arg_type ( arg_str, & cast_type );

  if ( cast_type != -1 )
    {
	/*** it DID have a "(xxx)" cast operator on the front ***/
    }
  /**** figure out if there was a '*' or '&' on the front ****/
  else if ( ** arg_str == '*' )
    {
      * arg_mode = _COB_indirect;
      (*arg_str)++;

	/*** eat blanks ***/
      while ( isspace ( ** arg_str )) ++ * arg_str;

      if ( ** arg_str == '*' )		/*** JAJ:05-31-88 ***/
	{
	  * arg_mode = _COB_indirect2;
	  (*arg_str)++;
	}
    }
  else if ( ** arg_str == '&' )
    {
      * arg_mode = _COB_address;
      (*arg_str)++;
    }

  status = COB_actions_eval_unary_ME ( arg_str, arg_val, arg_mode,
				       arg_type, cmd_oid, is_const );
  if ( ! ( status & 1) )
    goto quit;


	/*** see if the value just found needs to be type cast ***/
  if ( cast_type != -1 ) /*** an explicit type cast was given ***/
    {
      status = COB_actions_cast_arg ( arg_val, arg_type, cast_type );

      /*** if ( ! ( status & 1) )
	goto quit; *** It's gonna go there anyway ... ***/
    }

quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_eval_unary( arg_str='%s', arg_val->l=%ld, *arg_type=%d, mode=%d ): status = %d\n",
	 var = `*arg_str, arg_val->l, *arg_type, *arg_mode, status` )
  return status;
} /* COB_actions_eval_unary */



/* --------------------- */
static long COB_actions_eval_unary_minus ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  int		   status = OM_S_SUCCESS;
  char		   op_mode = 0;
  char *   	   Warning	  = "\nWarning:  ";
  char *   	   In_State_Table  = " in command's state table.\n\n";

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_unary_minus( arg_str='%s', cmd_oid=%d, mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  /**** figure out if there was a '-' or '!' or '~' on the front ****/
  if ( ** arg_str == '-' )
    {
      op_mode = '-';
      (*arg_str)++;
    }
  else if ( ** arg_str == '!' )
    {
      op_mode = '!';
      (*arg_str)++;
    }
  else if ( ** arg_str == '~' )	/*** one's complement ***/
    {
      op_mode = '~';
      (*arg_str)++;
    }

  status = COB_actions_eval_unary ( arg_str, arg_val,
			       arg_type, cmd_oid, is_const, arg_mode );
  if ( ! ( status & 1) )
    goto quit;


	/*** see if the value just found needs to be adjusted ***/
  if ( op_mode == '-' )
    {
      switch ( * arg_type ) \
	{
	  case _COB_arg_c : arg_val->c = - arg_val->c; break;
	  case _COB_arg_uc: arg_val->uc = - arg_val->uc; break;
	  case _COB_arg_s : arg_val->s = - arg_val->s; break;
	  case _COB_arg_us: arg_val->us = - arg_val->us; break;
	  case _COB_arg_i :
	  case _COB_arg_l : arg_val->l = - arg_val->l; break;
	  case _COB_arg_ui :
	  case _COB_arg_ul :
	  case _COB_arg_oid: arg_val->ui = - arg_val->ui; break;
	  case _COB_arg_f : arg_val->f = - arg_val->f; break;
	  case _COB_arg_d : arg_val->d = - arg_val->d; break;
	  case _COB_arg_p :
		fprintf ( stderr,
		    "%sCan't use pointer as operand for unary -%s",
		    Warning, In_State_Table );
		status = _COB_UNKNOWN_ARG;
		goto quit; /* break; */
	  default: fprintf ( stderr,
			"%sUnknown value type %d in argument%s",
			Warning, * arg_type, In_State_Table );
		   break; 
	} /*** end switch ***/
    }	/*** end of '-' ***/
  else if ( op_mode == '!' )
    {
      switch ( * arg_type ) \
	{
	  case _COB_arg_c : arg_val->c = ! arg_val->c; break;
	  case _COB_arg_uc: arg_val->uc = ! arg_val->uc; break;
	  case _COB_arg_s : arg_val->s = ! arg_val->s; break;
	  case _COB_arg_us: arg_val->us = ! arg_val->us; break;
	  case _COB_arg_i :
	  case _COB_arg_l : arg_val->l = ! arg_val->l; break;
	  case _COB_arg_ui :
	  case _COB_arg_ul :
	  case _COB_arg_oid: arg_val->ui = ! arg_val->ui; break;
	  case _COB_arg_f : arg_val->f = ! arg_val->f; break;
	  case _COB_arg_d : arg_val->d = ! arg_val->d; break;
	  case _COB_arg_p :
		fprintf ( stderr,
			"%sCan't use pointer as operand for unary !%s",
			Warning, In_State_Table );
		status = _COB_UNKNOWN_ARG;
		goto quit; /*break;*/
	  default:
		fprintf ( stderr,
			"%sUnknown value type %d in argument%s",
			Warning, * arg_type, In_State_Table );
		break; 
	} /*** end switch ***/
    }	/*** end of '!' ***/
  else if ( op_mode == '~' )
    {
      switch ( * arg_type ) \
	{
	  case _COB_arg_c : arg_val->c = ~ arg_val->c; break;
	  case _COB_arg_uc: arg_val->uc = ~ arg_val->uc; break;
	  case _COB_arg_s : arg_val->s = ~ arg_val->s; break;
	  case _COB_arg_us: arg_val->us = ~ arg_val->us; break;
	  case _COB_arg_i :
	  case _COB_arg_l : arg_val->l = ~ arg_val->l; break;
	  case _COB_arg_ui :
	  case _COB_arg_ul :
	  case _COB_arg_oid: arg_val->ui = ~ arg_val->ui; break;
	  case _COB_arg_f :
	  case _COB_arg_d :
	  case _COB_arg_p :
		fprintf ( stderr,
			"%sCan't use %s as operand for unary ~%s",
			Warning,
			*arg_type == _COB_arg_p ? "pointer" : "REAL",
			In_State_Table  );
		status = _COB_UNKNOWN_ARG;
		goto quit; /*break;*/
	  default:
		fprintf ( stderr,
			"%sUnknown value type %d in argument%s",
			Warning, * arg_type, In_State_Table  );
		break; 
	} /*** end switch ***/
    }	/*** end of '~' ***/


quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_eval_unary_minus( arg_str='%s', arg_val->l=%ld, *arg_type=%d, mode=%d ): status = %d\n",
	 var = `*arg_str, arg_val->l, *arg_type, *arg_mode, status` )
  return status;
} /* COB_actions_eval_unary_minus */



#define OPERATE_BIT(operand1,op,operand2,op2_type) \
  { \
   switch ( op2_type ) \
    { case _COB_arg_c : operand1 op operand2 .c  ; break; \
      case _COB_arg_uc: operand1 op operand2 .uc ; break; \
      case _COB_arg_s : operand1 op operand2 .s  ; break; \
      case _COB_arg_us: operand1 op operand2 .us ; break; \
      case _COB_arg_i :\
      case _COB_arg_l : operand1 op operand2 .l  ; break; \
      case _COB_arg_ui :\
      case _COB_arg_ul :\
      case _COB_arg_oid:operand1 op operand2 .ul ; break; \
      case _COB_arg_f :\
      case _COB_arg_d :\
	    fprintf ( stderr,\
		"%sCan't use REAL as operand for &, ^, or |%s", \
		 Warning, In_State_Table );\
	    status = _COB_UNKNOWN_ARG; goto quit; /*break;*/ \
      case _COB_arg_p :\
	    fprintf ( stderr,\
		"%sCan't use pointer as operand for &, ^, or |%s", \
		 Warning, In_State_Table );\
	    status = _COB_UNKNOWN_ARG; goto quit; /*break;*/ \
      default: fprintf ( stderr, \
		    "%sUnknown value type %d in argument%s", \
		    Warning, op2_type, In_State_Table ); break; }\
  } /*** end OPERATE_BIT ***/


#define OPERATE_BOOLE(operand1,op,operand2,op2_type) \
  { \
   switch ( op2_type ) \
    { case _COB_arg_c : operand1 op operand2 .c  ; break; \
      case _COB_arg_uc: operand1 op operand2 .uc ; break; \
      case _COB_arg_s : operand1 op operand2 .s  ; break; \
      case _COB_arg_us: operand1 op operand2 .us ; break; \
      case _COB_arg_i :\
      case _COB_arg_l : operand1 op operand2 .l  ; break; \
      case _COB_arg_ui :\
      case _COB_arg_ul :\
      case _COB_arg_oid:operand1 op operand2 .ul ; break; \
      case _COB_arg_f :operand1 op operand2 .f ; break; \
      case _COB_arg_d :operand1 op operand2 .d ; break; \
      case _COB_arg_p :\
	    fprintf ( stderr,\
		"%sCan't use pointer as operand for && or ||%s", \
		Warning, In_State_Table );\
	    status = _COB_UNKNOWN_ARG; goto quit; /*break;*/ \
      default: fprintf ( stderr, \
		    "%sUnknown value type %d in argument%s", \
		    Warning, op2_type, In_State_Table ); break; }\
  } /*** end OPERATE_BOOLE ***/

/* --------------------- */
static long COB_actions_bigger_type ( type1, type2 )
  int type1, type2;
{
  if ( type1 == _COB_arg_d  || type2 == _COB_arg_d )
    return _COB_arg_d;
  else if ( type1 == _COB_arg_f  || type2 == _COB_arg_f )
    return _COB_arg_f;
  else if ( type1 == _COB_arg_i  || type1 == _COB_arg_l  ||
	    type2 == _COB_arg_i  || type2 == _COB_arg_l )
    return _COB_arg_l;
  else if ( type1 == _COB_arg_ui  || type1 == _COB_arg_ul  ||
	    type2 == _COB_arg_ui  || type2 == _COB_arg_ul  ||
	    type1 == _COB_arg_oid || type2 == _COB_arg_oid )
    return _COB_arg_ul;
  else if ( type1 == _COB_arg_s  || type2 == _COB_arg_s )
    return _COB_arg_s;
  else if ( type1 == _COB_arg_us || type2 == _COB_arg_us )
    return _COB_arg_us;
  else if ( type1 == _COB_arg_c  || type2 == _COB_arg_c )
    return _COB_arg_c;
  else
    return _COB_arg_uc;
}


/* --------------------- */
static long COB_actions_eval_bit_and (	arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  COB_arg_union	   operand2;
  int		   operand2_type;
  short		   operand2_is_const = 0;
  int		   operand2_arg_mode = _COB_regular;
  int		   status = OM_S_SUCCESS;
  char		 * Warning	  = "\nWarning:  ";
  char		 * In_State_Table = " in command's state table.\n\n";

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_bit_and( arg_str='%s', cmd_oid=%d, mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  status = COB_actions_eval_unary_minus ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode );
  if ( ! ( status & 1) )
    goto quit;

  while ( ** arg_str == '&' )
    {
      (*arg_str) ++;
      if ( **arg_str == '&' ) /*** found a boolean and ***/
	{
	  (*arg_str)--;
	  break;
	}

      status = COB_actions_eval_unary_minus ( arg_str, &operand2,
			       &operand2_type, cmd_oid,
			       &operand2_is_const, &operand2_arg_mode );
      if ( ! ( status & 1) )
	goto quit;

      * is_const = * is_const && operand2_is_const;

      switch ( * arg_type )
	{
	  case _COB_arg_c:
	    OPERATE_BIT ( arg_val->c, &=, operand2, operand2_type )
	    break;

	  case _COB_arg_s:
	    OPERATE_BIT ( arg_val->s, &=, operand2, operand2_type )
	    break;

	  case _COB_arg_i:
	  case _COB_arg_l:
	    OPERATE_BIT ( arg_val->l, &=, operand2, operand2_type )
	    break;

	  case _COB_arg_uc:
	    OPERATE_BIT ( arg_val->uc, &=, operand2, operand2_type )
	    break;

	  case _COB_arg_us:
	    OPERATE_BIT ( arg_val->us, &=, operand2, operand2_type )
	    break;

	  case _COB_arg_ui:
	  case _COB_arg_ul:
	  case _COB_arg_oid:
	    OPERATE_BIT ( arg_val->ul, &=, operand2, operand2_type )
	    break;

	  case _COB_arg_f:
	  case _COB_arg_d:
	    fprintf ( stderr, "%sCan't bit-and REAL operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  case _COB_arg_p:
	    fprintf ( stderr, "%sCan't bit-and (char *) operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  default:
	    fprintf ( stderr,
			"%sUnknown type casting '%d' in argument%s",
			Warning, * arg_type, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/
	} /*** end switch (cast_type) ***/

	* arg_type = COB_actions_bigger_type ( *arg_type, operand2_type );
    }

quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_eval_bit_and( arg_str='%s', arg_val->l=%ld, *arg_type=%d, mode=%d ): status = %d\n",
	 var = `*arg_str, arg_val->l, *arg_type, *arg_mode, status` )
  return status;
} /* COB_actions_eval_bit_and */




/* --------------------- */
static long COB_actions_eval_bit_xor (	arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  COB_arg_union	   operand2;
  int		   operand2_type;
  short		   operand2_is_const = 0;
  int		   operand2_arg_mode = _COB_regular;
  int		   status = OM_S_SUCCESS;
  char		 * Warning	  = "\nWarning:  ";
  char		 * In_State_Table = " in command's state table.\n\n";

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_bit_xor( arg_str='%s', cmd_oid=%d, mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  status = COB_actions_eval_bit_and ( arg_str, arg_val,
				        arg_type, cmd_oid,
					is_const, arg_mode );
  if ( ! ( status & 1) )
    goto quit;

  while ( ** arg_str == '^' )
    {
      (*arg_str) ++;

      status = COB_actions_eval_bit_and ( arg_str, &operand2,
				&operand2_type, cmd_oid,
			       &operand2_is_const, &operand2_arg_mode );
      if ( ! ( status & 1) )
	goto quit;

      * is_const = * is_const && operand2_is_const;

      switch ( * arg_type )
	{
	  case _COB_arg_c:
	    OPERATE_BIT ( arg_val->c, ^=, operand2, operand2_type )
	    break;

	  case _COB_arg_s:
	    OPERATE_BIT ( arg_val->s, ^=, operand2, operand2_type )
	    break;

	  case _COB_arg_i:
	  case _COB_arg_l:
	    OPERATE_BIT ( arg_val->l, ^=, operand2, operand2_type )
	    break;

	  case _COB_arg_uc:
	    OPERATE_BIT ( arg_val->uc, ^=, operand2, operand2_type )
	    break;

	  case _COB_arg_us:
	    OPERATE_BIT ( arg_val->us, ^=, operand2, operand2_type )
	    break;

	  case _COB_arg_ui:
	  case _COB_arg_ul:
	  case _COB_arg_oid:
	    OPERATE_BIT ( arg_val->ul, ^=, operand2, operand2_type )
	    break;

	  case _COB_arg_f:
	  case _COB_arg_d:
	    fprintf ( stderr, "%sCan't bit-xor REAL operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  case _COB_arg_p:
	    fprintf ( stderr, "%sCan't bit-xor (char *) operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  default:
	    fprintf ( stderr,
			"%sUnknown type casting '%d' in argument%s",
			Warning, * arg_type, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/
	} /*** end switch (cast_type) ***/

	* arg_type = COB_actions_bigger_type ( *arg_type, operand2_type );
    }

quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_eval_bit_xor( arg_str='%s', arg_val->l=%ld, *arg_type=%d, mode=%d ): status = %d\n",
	 var = `*arg_str, arg_val->l, *arg_type, *arg_mode, status` )
  return status;
} /* COB_actions_eval_bit_xor */



/* --------------------- */
static long COB_actions_eval_bit_or ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  COB_arg_union	   operand2;
  int		   operand2_type;
  short		   operand2_is_const = 0;
  int		   operand2_arg_mode = _COB_regular;
  int		   status = OM_S_SUCCESS;
  char		 * Warning	  = "\nWarning:  ";
  char		 * In_State_Table = " in command's state table.\n\n";

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_bit_or( arg_str='%s', cmd_oid=%d, mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  status = COB_actions_eval_bit_xor ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode );
  if ( ! ( status & 1) )
    goto quit;

  while ( ** arg_str == '|' )
    {
      (*arg_str) ++;
      if ( **arg_str == '|' ) /*** found a boolean or ***/
	{
	  (*arg_str)--;
	  break;
	}

      status = COB_actions_eval_bit_xor ( arg_str, &operand2,
			       &operand2_type, cmd_oid,
			       &operand2_is_const, &operand2_arg_mode );
      if ( ! ( status & 1) )
	goto quit;

      * is_const = * is_const && operand2_is_const;

      switch ( * arg_type )
	{
	  case _COB_arg_c:
	    OPERATE_BIT ( arg_val->c, |=, operand2, operand2_type )
	    break;

	  case _COB_arg_s:
	    OPERATE_BIT ( arg_val->s, |=, operand2, operand2_type )
	    break;

	  case _COB_arg_i:
	  case _COB_arg_l:
	    OPERATE_BIT ( arg_val->l, |=, operand2, operand2_type )
	    break;

	  case _COB_arg_uc:
	    OPERATE_BIT ( arg_val->uc, |=, operand2, operand2_type )
	    break;

	  case _COB_arg_us:
	    OPERATE_BIT ( arg_val->us, |=, operand2, operand2_type )
	    break;

	  case _COB_arg_ui:
	  case _COB_arg_ul:
	  case _COB_arg_oid:
	    OPERATE_BIT ( arg_val->ul, |=, operand2, operand2_type )
	    break;

	  case _COB_arg_f:
	  case _COB_arg_d:
	    fprintf ( stderr, "%sCan't bit-or REAL operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  case _COB_arg_p:
	    fprintf ( stderr, "%sCan't bit-or (char *) operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  default:
	    fprintf ( stderr,
			"%sUnknown type casting '%d' in argument%s",
			Warning, * arg_type, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/
	} /*** end switch (cast_type) ***/

	* arg_type = COB_actions_bigger_type ( *arg_type, operand2_type );
    }

quit:
  _bugprint(bflag=ACT_TRANS, str =
	"-COB_actions_eval_bit_or( arg_str='%s', arg_val->l=%ld,\n",
	 var = `*arg_str, arg_val->l` )
  _bugprint(bflag=ACT_TRANS, str =
	"\t\t*arg_type=%d, mode=%d ): status = %d\n",
	 var = `*arg_type, *arg_mode, status` )
  return status;
} /* COB_actions_eval_bit_or */



/* --------------------- */
static long COB_actions_eval_boole_and ( arg_str, arg_val,
			      		 arg_type, cmd_oid,
					 is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  COB_arg_union	   operand2;
  int		   operand2_type;
  short		   operand2_is_const = 0;
  int		   operand2_arg_mode = _COB_regular;
  int		   status = OM_S_SUCCESS;
  char		 * Warning	  = "\nWarning:  ";
  char		 * In_State_Table = " in command's state table.\n\n";

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_boole_and( arg_str='%s', cmd_oid=%d, mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  status = COB_actions_eval_bit_or ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode );
  if ( ! ( status & 1) )
    goto quit;

  while ( ! strncmp ( * arg_str, "&&", 2 ) )
    {
      (*arg_str) += 2;

      status = COB_actions_eval_bit_or ( arg_str, &operand2,
				&operand2_type, cmd_oid,
			       &operand2_is_const, &operand2_arg_mode );
      if ( ! ( status & 1) )
	goto quit;

      * is_const = * is_const && operand2_is_const;

      switch ( * arg_type )
	{
	  case _COB_arg_c:
	    OPERATE_BOOLE ( arg_val->c, = arg_val->c && , operand2, operand2_type )
	    break;

	  case _COB_arg_s:
	    OPERATE_BOOLE ( arg_val->s, = arg_val->s &&,  operand2, operand2_type )
	    break;

	  case _COB_arg_i:
	  case _COB_arg_l:
	    OPERATE_BOOLE ( arg_val->l, = arg_val->l &&,  operand2, operand2_type )
	    break;

	  case _COB_arg_uc:
	    OPERATE_BOOLE ( arg_val->uc, = arg_val->uc &&,  operand2, operand2_type )
	    break;

	  case _COB_arg_us:
	    OPERATE_BOOLE ( arg_val->us, = arg_val->us &&,  operand2, operand2_type )
	    break;

	  case _COB_arg_ui:
	  case _COB_arg_ul:
	  case _COB_arg_oid:
	    OPERATE_BOOLE ( arg_val->ul, = arg_val->ul &&,  operand2, operand2_type )
	    break;

	  case _COB_arg_f:
	    OPERATE_BOOLE ( arg_val->f, = arg_val->f &&,  operand2, operand2_type )
	    break;

	  case _COB_arg_d:
	    OPERATE_BOOLE ( arg_val->d, = arg_val->d &&,  operand2, operand2_type )
	    break;

	  case _COB_arg_p:
	    fprintf ( stderr, "%sCan't && (char *) operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  default:
	    fprintf ( stderr,
		"%sUnknown type casting '%d' in argument%s",
		Warning, * arg_type, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/
	} /*** end switch (cast_type) ***/

	* arg_type = COB_actions_bigger_type ( *arg_type, operand2_type );
    }

quit:
  _bugprint(bflag=ACT_TRANS, str =
	"-COB_actions_eval_boole_and( arg_str='%s', arg_val->l=%ld,\n",
	 var = `*arg_str, arg_val->l` )
  _bugprint(bflag=ACT_TRANS, str =
	"\t\t*arg_type=%d, *arg_mode=%d ): status = %d\n",
	 var = `*arg_type, *arg_mode, status` )
  return status;
} /* COB_actions_eval_boole_and */



/* --------------------- */
static long COB_actions_eval_boole_or ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  COB_arg_union	   operand2;
  int		   operand2_type;
  short		   operand2_is_const = 0;
  int		   operand2_arg_mode = _COB_regular;
  int		   status = OM_S_SUCCESS;
  char		 * Warning	  = "\nWarning:  ";
  char		 * In_State_Table = " in command's state table.\n\n";

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_boole_or( arg_str='%s', cmd_oid=%d, *arg_mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  status = COB_actions_eval_boole_and ( arg_str, arg_val,
					arg_type, cmd_oid,
					is_const, arg_mode );
  if ( ! ( status & 1) )
    goto quit;

  while ( ! strncmp ( * arg_str, "||", 2 ) )
    {
      (*arg_str) += 2;

      status = COB_actions_eval_boole_and ( arg_str, &operand2,
			   &operand2_type, cmd_oid,
			   &operand2_is_const, &operand2_arg_mode );
      if ( ! ( status & 1) )
	goto quit;

      * is_const = * is_const && operand2_is_const;

      switch ( * arg_type )
	{
	  case _COB_arg_c:
	    OPERATE_BOOLE ( arg_val->c, = arg_val->c ||, operand2, operand2_type )
	    break;

	  case _COB_arg_s:
	    OPERATE_BOOLE ( arg_val->s, = arg_val->s ||,  operand2, operand2_type )
	    break;

	  case _COB_arg_i:
	  case _COB_arg_l:
	    OPERATE_BOOLE ( arg_val->l, = arg_val->l ||,  operand2, operand2_type )
	    break;

	  case _COB_arg_uc:
	    OPERATE_BOOLE ( arg_val->uc, = arg_val->uc ||,  operand2, operand2_type )
	    break;

	  case _COB_arg_us:
	    OPERATE_BOOLE ( arg_val->us, = arg_val->us ||,  operand2, operand2_type )
	    break;

	  case _COB_arg_ui:
	  case _COB_arg_ul:
	  case _COB_arg_oid:
	    OPERATE_BOOLE ( arg_val->ul, = arg_val->ul ||,  operand2, operand2_type )
	    break;

	  case _COB_arg_f:
	    OPERATE_BOOLE ( arg_val->f, = arg_val->f ||,  operand2, operand2_type )
	    break;

	  case _COB_arg_d:
	    OPERATE_BOOLE ( arg_val->d, = arg_val->d ||,  operand2, operand2_type )
	    break;

	  case _COB_arg_p:
	    fprintf ( stderr, "%sCan't || (char *) operator%s",
				 Warning, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/

	  default:
	    fprintf ( stderr,
		"%sUnknown type casting '%d' in argument%s",
		Warning, * arg_type, In_State_Table );
	    status = _COB_UNKNOWN_ARG;
	    goto quit;
	    /*break;*/
	} /*** end switch (cast_type) ***/

	* arg_type = COB_actions_bigger_type ( *arg_type, operand2_type );
    }

quit:
  _bugprint(bflag=ACT_TRANS, str =
    "-COB_actions_eval_boole_or( arg_str='%s', arg_val->l=%ld, *arg_type=%d ): status = %d\n",
	 var = `*arg_str, arg_val->l, *arg_type, status` )
  return status;
} /* COB_actions_eval_boole_or */



/* --------------------- */
static int COB_actions_eval_cond ( arg_str, arg_val,
				    arg_type, cmd_oid,
				    is_const, arg_mode )
  char		** arg_str;
  COB_arg_union  * arg_val;
  int		 * arg_type;
  OM_S_OBJID	   cmd_oid;
  short		 * is_const;
  int		 * arg_mode;	/* JAJ:02/03/89 */
{
  COB_arg_union	   operand2, operand3;
  int		   operand2_type, operand3_type;
  short		   operand2_is_const = 0, operand3_is_const=0;
  int		   operand2_arg_mode = _COB_regular;
  int		   operand3_arg_mode = _COB_regular;
  int		   status = OM_S_SUCCESS;

  _bugprint(bflag=ACT_TRANS, str =
    "+COB_actions_eval_cond( arg_str='%s', cmd_oid=%d, *arg_mode=%d ):\n",
	 var = `*arg_str, cmd_oid, *arg_mode` );

	/*** eat blanks ***/
  while ( isspace ( ** arg_str )) ++ * arg_str;

  status = COB_actions_eval_boole_or ( arg_str, arg_val,
				       arg_type, cmd_oid,
				       is_const, arg_mode );
  if ( ! ( status & 1) )
    goto quit;

  if ( **arg_str == '?' )
    {
      (*arg_str)++;

      status = COB_actions_eval_cond ( arg_str, &operand2,
				&operand2_type, cmd_oid,
				&operand2_is_const, &operand2_arg_mode);
      if ( ! ( status & 1 ) )
	goto quit;

      if ( **arg_str == ':' )
	{
	  status = COB_actions_eval_cond ( arg_str, &operand3,
				&operand3_type, cmd_oid,
				&operand3_is_const, &operand3_arg_mode);
	  if ( ! ( status & 1) )
	    goto quit;

	  * is_const = * is_const && operand2_is_const && operand3_is_const;

#define COND(op1) \
  if ( op1 ) { memcpy ( arg_val, &operand2, sizeof(COB_arg_union) );\
		 * arg_type = operand2_type; } \
  else { memcpy ( arg_val, &operand3, sizeof(COB_arg_union) );\
		 * arg_type = operand3_type; }

	  switch ( * arg_type )
	    {
	      case _COB_arg_c:
		COND ( arg_val->c )
		break;

	      case _COB_arg_s:
		COND ( arg_val->s )
		break;

	      case _COB_arg_i:
	      case _COB_arg_l:
		COND ( arg_val->l )
		break;

	      case _COB_arg_uc:
		COND ( arg_val->uc )
		break;

	      case _COB_arg_us:
		COND ( arg_val->us )
		break;

	      case _COB_arg_ui:
	      case _COB_arg_ul:
	      case _COB_arg_oid:
		COND ( arg_val->ul )
		break;

	      case _COB_arg_f:
		COND ( arg_val->f )
		break;

	      case _COB_arg_d:
		COND ( arg_val->d )
		break;

	      case _COB_arg_p:
		COND ( arg_val->p )
		break;

	      default:
		fprintf ( stderr,
		"\nWarning:  Unknown type casting '%d' in argument in command's state table\n\n",
		* arg_type );
		status = _COB_UNKNOWN_ARG;
		goto quit;
		/*break;*/
	    } /*** end switch ( *arg_type ) ***/

	}
      else
	{
	  fprintf ( stderr,
		"\nWarning:  Command's state table conditional construct '?'\n\thas no matching ':'\n\n" );
	  status = _COB_UNKNOWN_ARG;
	  goto quit;
	}
    }

quit:
  _bugprint(bflag=ACT_TRANS, str =
	"-COB_actions_eval_cond( arg_str='%s', arg_val->l=%ld\n",
	 var = `*arg_str, arg_val->l` )
  _bugprint(bflag=ACT_TRANS, str =
	"\t\t*arg_type=%d, *arg_mode =%d ): status = %d\n",
	 var = `*arg_type, *arg_mode, status` )
  return status;
} /* COB_actions_eval_cond */



/*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/
/*  COBactions_dump gets included only if DEBUG set  -- JAJ:11-06-87 */
/*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/

#ifdef DEBUG

COBactions_dump ( action_ptr, state_action, fp )
  struct COBaction    * action_ptr;
  char			state_action;
  FILE		      * fp;
{
  int			ii;

  _bugprint(bflag=TFLAG, str =
	"+COBactions_dump:  action_ptr=(0x)%x, state_action = '%c'\n",
	var = `action_ptr, state_action` )

  fprintf ( fp, "%sa(%s,%s",
		state_action ? "      " : "	  " ,
		action_ptr->class_name,
		action_ptr->message_name );

  for ( ii = 0 ; ii < action_ptr->num_args ; ii++ )
    {
      fprintf ( fp, ",%s", action_ptr->args[ii] );
    }

  fprintf ( fp, ")\n" );
  
quit:
   _bugprint(bflag=TFLAG, str = "-COBactions.dump:\n" );

  ;	/*** need the ; for compiling w/o DEBUG set ***/
}  /*** end of COBactions_dump () ***/

#endif

end implementation Root;
