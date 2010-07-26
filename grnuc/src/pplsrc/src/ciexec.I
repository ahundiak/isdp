/*
 *	 Etienne Beeker
 *	 OCTOBER '87
 *
 *	 Management of the execution of a command file
 *	 from within another command file.
 */
class implementation ci;

#include <malloc.h>
#include "cierrordef.h"
#include "cierrmacros.h"
#include "ciexecmacros.h"

extern char		errmess[];
extern struct instance_ci *ci_data;
extern char		**ci_data_varvaltable;
extern char		*ci_data_info;

int CIexec(func, exevdata, runparms, state )
struct ci_instruction	*func	  ;
CIco_resp		*exevdata ;
CIruntime		*runparms ;
short			*state	  ;

/*
 * Implements PPL library function "CIexec".
 * Referenced in the following PPL macros: ci$exec, ci$run and ci$load.
 * RETURNS: ISUCCESS (event if user call went badly).
            ISTACK   Execution is interrupted by an event.
 */
{

	int		rc,
			retcode,	/* Buffer for ret code if not set */
			*p_retcode,	/* Pointer to return code	  */
			retsize ;	/* Size for returned value	  */
	OM_S_OBJID	*p_file_id ;	/* Address of id of CI		  */
	char		*file_name,	/* Name of PPL file		  */
			*entry ;	/* Name of function to execute	  */
	void		*p_retval ;	/* Pointer to memory to store
					    value returned by funcion	  */
	int		load,		/* Load flag			  */
			run,		/* Run flag			  */
			delete,		/* Delete flag			  */
			stackable ;	/* If TRUE file is interruptible  */
	register short	*pm ;


	enum CIexec_args	{
		CIEXECRC	=  0, FILE_NAME	=  1, P_FILE_ID	=  2,
		ENTRY		=  3, LOAD_FLAG	=  4, RUN_FLAG	=  5,
		DELETE_FLAG	=  6, STACKABLE	=  7, P_RETVAL	=  8,
		RETSIZE		=  9, P_RETCODE	= 10
	} ;

	pm = func->paramlist ;

	file_name = st_cival( pm[FILE_NAME  ] );
	p_file_id = (OM_S_OBJID *)st_cival( pm[P_FILE_ID  ] );
	entry     = st_cival( pm[ENTRY      ] );
	load      = i_cival ( pm[LOAD_FLAG  ] );
	run       = i_cival ( pm[RUN_FLAG   ] );
	delete    = i_cival ( pm[DELETE_FLAG] );
	stackable = i_cival ( pm[STACKABLE  ] );
	p_retval  = st_cival( pm[P_RETVAL   ] );
	retsize   = i_cival ( pm[RETSIZE    ] );
	p_retcode = (int *)st_cival( pm[P_RETCODE  ] ); /* AF proper ret. code */

	if( p_retcode == NULL ) {
		p_retcode = &retcode ;
	}
#ifdef DEBUG
printf("CIexec: p_file_id=%d\n", *p_file_id);
if(file_name != NULL)
	printf("CIexec: file_name=(%u)  %s\n", file_name,file_name);
printf("CIexec: entry	=%s\n",entry);
printf("CIexec: load	=%d\n",load);
printf("CIexec: run	=%d\n",run);
printf("CIexec: delete	=%d\n",delete);
printf("CIexec: stackable=%d\n",stackable);
printf("CIexec: ci_stacked=%d\n", ci_stacked( *state ) != 0 );
#endif

	/* load */
	if (!ci_stacked( *state ))
	{
#ifdef DEBUG
  printf( "CIexec: loading <%s>\n", file_name ) ;
#endif
	    /* Retrieve, load or clone the CI object if possible
	       and requested
	     */
	    rc = SCIload(	file_name,
				p_file_id,
				load,
				exevdata->ci_id,
				OM_Gw_TransOSnum_0 );
	    if ( (rc != CI_S_SUCCESS) && (rc != CI_E_DB_OVERFLOW) ) {
		*p_retcode = rc ;
		i_cival( pm[CIEXECRC] ) = FALSE;
		return ISUCCESS ;
	    }

#ifdef DEBUG
  printf( "CIexec: run = %d\n", run ) ;
#endif
	    if( run ) {
		/* verif and init */
		if( !ci$e_x_e_c(	file_name	= NULL,
					file_id		= p_file_id,
					entry		= entry,
					load_flag	= NO_LOAD,
					verif_flag	= TRUE,
					init_flag	= TRUE,
					run_flag	= FALSE,
					delete_flag	= FALSE,
					sender_id	= exevdata->ci_id,
					sender_os	= OM_Gw_TransOSnum_0,
					retval		= p_retval,
					retsize		= retsize,
					stat		= p_retcode ) ) {
		
		    i_cival( pm[CIEXECRC] ) = FALSE ;
		    return ISUCCESS ;
		}
	     }
	} /* if( ! ci_stacked ... */

#ifdef DEBUG
  printf( "CIexec: run = %d\n", run ) ;
#endif
 	if( run ) {
		*exevdata->response = RESET;	/* nothing special */
#ifdef DEBUG
printf( "CIexec: B4 execute, ci_id = %d p_file_id = %d\n", exevdata->ci_id, *p_file_id );
#endif
		rc = om$send(	mode	 = OM_e_wrt_object,
				msg	 = message ci.execute(
						exevdata->response,
						exevdata->response_data,
						exevdata->pos ),
				senderid = exevdata->ci_id,
				targetid = *p_file_id,
				targetos = OM_Gw_TransOSnum_0);
#ifdef DEBUG
printf( "CIexec: after execute, ci_id = %d p_file_id = %d\n", exevdata->ci_id, *p_file_id );
#endif
		if( rc != OM_S_SUCCESS ) {
		  ci$om_failed(	sts = rc,
				text= "CIexec -> ci.execute" ) ;
				/* unstacked the file if stacked */
				ci_unstack( *state );
			*p_retcode = CI_E_FATAL_ERROR ;
		    	i_cival( pm[CIEXECRC] ) = FALSE ;
			return ISUCCESS ;
		}
		if( *exevdata->response == CMD_STRING
		  ||*exevdata->response == D_COMMAND
		  ||*exevdata->response == EX_POCKET
		  ||*exevdata->response == EX_CMD_KEY
		  ||*exevdata->response == EX_CMD_M_KEY
		  ||*exevdata->response == EX_CMD_M_STR
		  ||*exevdata->response == TOGGLE_COMMAND){
			if( stackable){
				ci_stack( *state );
				return ISTACK;
			} else
				erreur("ci$exec: variable stackable not set, execution stopped");
		}
		om$send( msg	  = message ci.get_fcn_val(	entry,
								p_retval,
								retsize ),
			 senderid = exevdata->ci_id,
			 targetid = *p_file_id,
			 targetos = OM_Gw_TransOSnum_0 ) ;
	}

	ci_unstack( *state );	/* unstacked the file if stacked */

	/* delete */
	
		if( !ci$e_x_e_c(	file_name	= NULL,
					file_id		= p_file_id,
					entry		= entry,
					load_flag	= 0,
					verif_flag	= FALSE,
					init_flag	= FALSE,
					run_flag	= FALSE,
					delete_flag	= delete,
					sender_id	= exevdata->ci_id,
					sender_os	= OM_Gw_TransOSnum_0,
					retval		= p_retval,
					retsize		= retsize,
					stat		= p_retcode ) ) {
		*p_retcode = CI_E_FATAL_ERROR ;
		i_cival( pm[CIEXECRC] ) = FALSE ;
		return ISUCCESS ;
	}

	/* reinit some stuff */
	cireveil( runparms );

	i_cival( pm[CIEXECRC] ) = TRUE ;

	if( *exevdata->response == CLEAR_STACK ||
/* EB May 03, 88
/* on TERMINATE, all stacked CIs will be popped and terminated */
 	    *exevdata->response == TERMINATE )
		return ISTACK;

	return ISUCCESS ;
}
/*----------------------------------------------------------------------------*/
int ci_exec(	file_name,
		p_file_id,
		entry, 
		load,
		verif,
		init,
		run,
		delete,
		sender_id,
		sender_os,
		retval,
		retsize,
		retcode )

char		*file_name ;	/* IN : PPL file name			*/
OM_S_OBJID	*p_file_id ;	/* IO : Id of CI loaded with PPL file	*/
char		*entry ;	/* IN : Name of function to execute	*/
int		load,		/* IN : If TRUE load file		*/
		verif,		/* IN : If TRUE check classid of
					*p_file_id			*/
		init,		/* IN : If TRUE perform `init'		*/
		run,		/* IN : If TRUE run file		*/
		delete ;	/* IN : If TRUE delete CI loaded with
					file				*/
OM_S_OBJID	sender_id ;	/* IN : Object id of caller		*/
OMuword		sender_os ;	/* IN : Object space of caller		*/
void		*retval ;	/* OUT: Pointer to memory to store
				        value returned by `entry'	*/
int		retsize,	/* IN : Size of value returned by
					`entry'				*/
		*retcode ;	/* OUT: Completion code			*/
/*
 * Execution of a PPL file.
 * Function called from C code.
 *
 * The numerous parameters are used to perform only certain actions.
 * Full execution corresponds to all actions.
 * This function is interfaced by the private macro ci$e_x_e_c in ciexecmacros.h.
 * Referenced in the following macros: ci$exec, ci$run and ci$load via
 * ci$e_x_e_c.
 */
{
	int	response;	/* For PPL function handling events	*/
	char	*response_data;	/* For PPL function handling events	*/
	int	pos;		/* For PPL function handling events	*/
	int	OMsts, CIsts ;

	CIsts = CI_S_SUCCESS ;

#ifdef DEBUG
  printf( "ci_exec: ENTER, load = %u\n", load ) ; fflush( stdout ) ;
  printf( "ci_exec: <%s> sender (%d, %u[%d])\n", file_name,
		sender_os, sender_id, sender_id ) ;
#endif
	/* Retrieve, load or clone the CI object if possible and requested */
	if ( (load & ~NO_DATE) != NO_LOAD )
	{
#ifdef DEBUG
  printf( "ci_exec: call SCIload\n" ) ; fflush( stdout ) ;
#endif
	    CIsts = SCIload(	file_name,
				p_file_id,
				load,
				sender_id,
				sender_os ) ;
#ifdef DEBUG
  printf( "ci_exec: SCIload rc: " ) ;
  ci$report_error( status = CIsts, output = CI_ERR_STDOUT ) ;
#endif
	    if ( (CIsts != CI_S_SUCCESS) && (CIsts != CI_E_DB_OVERFLOW) ) {
#ifdef DEBUG
  printf( "ci_exec: SCIload FAILED\n" ) ; fflush( stdout ) ;
#endif
		goto WRAPUP	;
	    }
	}
	else	/* NO_LOAD */
	{
	    if ( p_file_id == NULL )
            {
                erreur("ci_exec: 'objid' not specified");
                CIsts = CI_E_INVALIDARGS ;
                goto WRAPUP ;
            }
	    verif = 1;
	}

	if( run ){
		verif = 1;
		init = 1;
	}
	    
	if( verif ){
		extern GRclassid	CI_ci_classid;
		GRclassid		v_classid;

		/* security */
	 	/* the object exists, is it of class ci */
		om$get_classid (objid = *p_file_id,
				osnum = OM_Gw_TransOSnum_0,
				p_classid = &v_classid);
		if(om$is_ancestry_valid( subclassid = v_classid,
      	  			         superclassid = CI_ci_classid )
	      	  	 	!= OM_S_SUCCESS ){
			sprintf(errmess,"ci_exec: bad class for p_file_id (%d), abort", (int)*p_file_id);
			erreur(errmess);
			CIsts = CI_E_INVALIDARGS ;
	  		goto WRAPUP ;
		}
	}

	if( init ){
		/* Does entry point exist ? */
		ci$is_entry_point(	stat	= &CIsts,
					file	= *p_file_id,
					senderid= sender_id,
					entry	= entry ) ;
		if( CIsts != CI_S_SUCCESS ) {
			goto WRAPUP	;
		}
    		/* Initialize the CI object (its program counter) */
		OMsts = om$send(msg	 = message ci.init(0, entry),
		    		senderid = sender_id,
		        	targetid = *p_file_id,
        	        	targetos = OM_Gw_TransOSnum_0);

		if( OMsts != OM_S_SUCCESS ) {
			ci$om_failed(	sts = OMsts,
					text= "ci_exec -> ci.init" ) ;
			CIsts = CI_E_FATAL_ERROR ;
		    	goto WRAPUP ;
		}
	}

	if( run ){
		/* execution du code */
/* --		`response_data' must be malloc'd to have a correct alignment.
   -- */
		if( ( response_data = malloc( EX_RESPONSE_DATA_SIZE ) ) == NULL ) {
			CIsts = CI_E_CANT_MALLOC ;
			goto WRAPUP ;
		}
		OMsts = om$send(msg	 = message ci.execute(	&response,
								response_data,
								pos ),
		    		senderid = sender_id,
       		    		targetid = *p_file_id,
        	    		targetos = OM_Gw_TransOSnum_0);

		free( response_data ) ;

		if( OMsts != OM_S_SUCCESS ) {
			ci$om_failed(	sts = OMsts,
					text= "ci_exec -> ci.execute" ) ;
			CIsts = CI_E_FATAL_ERROR ;
		    	goto WRAPUP ;
		}
		om$send( msg	  = message ci.get_fcn_val(	entry,
								retval,
								retsize ),
			 senderid = sender_id,
			 targetid = *p_file_id,
			 targetos = OM_Gw_TransOSnum_0 ) ;
	}

	if(delete){
		/* delete the object ci */
		OMsts = om$send(msg	 = message ci.delete(0),
		        	senderid = sender_id,
				targetid = *p_file_id,
        	    		targetos = OM_Gw_TransOSnum_0);
		if( OMsts != OM_S_SUCCESS ) {
			ci$om_failed(	sts = OMsts,
					text= "ci_exec -> ci.delete" ) ;
			CIsts = CI_E_FATAL_ERROR ;
		    	goto WRAPUP ;
		}
	}

	WRAPUP :
		if( retcode != NULL ) *retcode = CIsts ;
#ifdef DEBUG
  printf( "ci_exec: EXIT(%d)\n", CIsts == CI_S_SUCCESS ) ; fflush( stdout ) ;
#endif
		return CIsts == CI_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
int ciSCIdelete(func)
struct ci_instruction	*func;
/*
 * Deletes the CI object and removes it from the DataBase
 * Function called from CI code.
 * Referenced in the macro: ci$delete
 */
{
    i_cival(func->paramlist[0]) = SCIdelete(st_cival(func->paramlist[1]),
						o_cival(func->paramlist[2]));
    return ISUCCESS;
}

int ciSCIinq_files(func)
struct ci_instruction	*func;
/*
 *  Inquire the CI super object to get the list of CI files that it knows
 * smthing about.
 * Referenced in the macro: ci$inq_files
 */
{
    int i2 = func->paramlist[2];
    i_cival(func->paramlist[0]) = SCIinq_files(
		st_cival(func->paramlist[1]),
		(ci_data->vardimtable[i2] == 0? p_cival(i2): cival(i2)) );
    return ISUCCESS;
}

int ciSCIinq_objects(func)
struct ci_instruction	*func;
/*
 *  Inquire the CI super object to get the list of CI objects loaded with a
 * given CI file.
 * Referenced in the macro: ci$inq_objects
 */
{
    i_cival(func->paramlist[0]) = SCIinq_objects(
		st_cival(func->paramlist[1]),
		st_cival(func->paramlist[2]),
		st_cival(func->paramlist[3]) );
    return ISUCCESS;
}

end implementation  ci;

