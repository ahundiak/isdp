/*
 * Command interpreter (ci) macro file.
 * This macros are highly private.
 */
#ifndef CIMACROS_INCLUDE
#	define CIMACROS_INCLUDE

/* -- Macros giving access to the value of the variable at index "i", according
      to its type.
   -- */

#	ifndef CCI

#	define cival(i)		(ci_data_varvaltable[i])
#	define d_cival(i)	(*((double *)ci_data_varvaltable[i]))
#	define i_cival(i)	(*((int *)ci_data_varvaltable[i]))
#	define s_cival(i)	(*((short *)ci_data_varvaltable[i]))
#	define o_cival(i)	(*((OM_S_OBJID *)ci_data_varvaltable[i]))
#	define c_cival(i)	(*(ci_data_varvaltable[i]))
#	define p_cival(i)	(*((char **)ci_data_varvaltable[i]))
#	define st_cival(i)	(ci_data->vartypetable[i]&PTR?p_cival(i):cival(i))

#	define COND_prompt(s)	if( vsd_and_queue_empty ) \
		ex$message( field = PROMPT_FIELD, in_buff = (s) )
#	define COND_message(s)	if( vsd_and_queue_empty ) \
		ex$message( field = MESSAGE_FIELD, in_buff = (s) )
#	define COND_status(s)	if( vsd_and_queue_empty ) \
		ex$message( field = ERROR_FIELD, in_buff = (s) )
#	define CI_MSG	(vsd_and_queue_empty)
#	define CI_IGE   ( (ci_IGE *) ci_data_info )


/* -- Macros to manage the stacking of the called PPL file
      ci_data->options is indeed used.
   -- */
/*
#define ci_stacked(xdata)	( (xdata->options) & 0x80 )
#define ci_stack(xdata)		(xdata)->options |= 0x80
#define ci_unstack(xdata)	(xdata)->options &= 0x7f
*/
#define ci_stacked( state )	( (state) & CI_STACKED_AS_A_CO )
#define ci_stack( state )	(state) |= CI_STACKED_AS_A_CO
#define ci_unstack( state )	(state) &= ~CI_STACKED_AS_A_CO

#ifdef OM_D_PRIMITIVES
#omdef ci$om_failed( sts, text )
	printf( "FILE %s, LINE %d: %s\n", __FILE__, __LINE__, (text) ) ;
	om$report_error( sts = (sts) ) ;
	fflush( stdout ) ;
#endomdef
#endif

/* -- File name entered via "CI=<filename>" at the Select Command prompt (1)
      or via the command table (test on type passed to COci.init method ).
   -- */
#define CI_FILE_KEYED_IN( flag ) ( (flag) == 1 )


#else

#	define cival(i)		(ci_data->varvaltable[i])
#	define d_cival(i)	(*((double *)ci_data->varvaltable[i]))
#	define i_cival(i)	(*((int *)ci_data->varvaltable[i]))
#	define s_cival(i)	(*((short *)ci_data->varvaltable[i]))
#	define o_cival(i)	(*((OM_S_OBJID *)ci_data->varvaltable[i]))
#	define c_cival(i)	(*(ci_data->varvaltable[i]))
#	define p_cival(i)	(*((char **)ci_data->varvaltable[i]))
#	define st_cival(i)	(ci_data->vartypetable[i]&PTR?p_cival(i):cival(i))

#endif
#endif


