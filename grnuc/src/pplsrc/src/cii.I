/*
 * cii.I
 *
 * Contains the methods dealing with ci as a command object plus some regarding
 * the execution of a PPL file.
 *
 * Etienne BEEKER
 * creation:27-3-86
 * 
 */
class implementation ci;

%safe
#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <string.h>
#include <malloc.h>
%endsafe

#include "ex.h"
#include "exmacros.h"
#include "cimsg.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "cisetup.h"
#include "msmacros.h"

%safe
OM_S_OBJID	ci_id;			/* Id of currently active ci	*/
struct instance_ci
		*ci_data = NULL;	/* Code of currently active ci	*/
char		**ci_data_varvaltable;	/* Text segment of current ci	*/
char		*ci_data_info;		/* Runtime info of current ci	*/
%endsafe


char errmess[256];

struct CI_FILE_DES	Ci_file_des[MAX_FILE]	;
extern char		CS_path_name[]		;
/*----------------------------------------------------------------------------*/
#argsused
int CIconstruct( msg, cfname, mode, cfid, sender_id, sender_os )

int		*msg ;		/* OUT : Completion code		*/
char		*cfname;	/* IN  : PPL command file name		*/
int             mode ;          /* IN  : Creation mode LOAD, DUP, etc.  */
OM_S_OBJID	*cfid;		/* OUT : CI command file objid		*/
OM_S_OBJID	sender_id ;	/* IN  : id of the calling object	*/
OMuword		sender_os ;	/* IN  : os of the calling object	*/

/*
 * Constructs the CI object and sends the load message to it.
 * RETURNS : TRUE if OK else FALSE with error code in `*msg'.
 */
{
	int			OMsts		;	/* OM return code */
	extern GRclassid	CI_ci_classid	;	/* Classid of ci  */

#ifdef DEBUG
  printf( "CIconstruct : <%s> sender (%d, %u[%d])\n", cfname,
		sender_os, sender_id, sender_id ) ;
  fflush( stdout ) ;
#endif
	*msg = CI_S_SUCCESS ;

	OMsts = om$construct(	osnum    = OM_Gw_TransOSnum_0,
                         	classid  = CI_ci_classid,
                         	p_objid  = cfid,
                         	neighbor = OM_GS_NULL_NEIGHBOR);
	if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts = OMsts,
				text= "CIconstruct -> om$construct" ) ;
		*msg = CI_E_FATAL_ERROR ;
		goto WRAPUP ;
	}    

	/* Send message to load self with PPL file */
	OMsts = om$send( msg      = message ci.load( msg, cfname, mode ),
			 senderid = sender_id,
			 targetid = *cfid,
			 targetos = OM_Gw_TransOSnum_0);

	if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts = OMsts,
				text= "CIconstruct -> ci.load" ) ;
		*msg = CI_E_FATAL_ERROR ;
		goto WRAPUP ;
	}    

	if( *msg != CI_S_SUCCESS ) {
		if( CI_MSG ) {
			ci$report_error( status = *msg,
					 output = CI_ERR_MSGSYS ) ;
		}

		/* Must delete the object, but data are already freed.
		   Send delete wrt message.
		 */
		OMsts = om$send(mode	 = OM_e_wrt_message,
				msg      = message Root.delete(0),
				senderid = sender_id,
                		targetid = *cfid,
				targetos = OM_Gw_TransOSnum_0);
		if( !( OMsts & SUCC ) ) {
			ci$om_failed(	sts = OMsts,
					text= "CIconstruct -> Root.delete" ) ;
			*msg = CI_E_FATAL_ERROR ;
		}    
	}
	WRAPUP :
#ifdef DEBUG
  printf( "CIconstruct: rc %d *msg :\n", *msg == CI_S_SUCCESS ) ;
  ci$report_error( status = *msg, output = CI_ERR_STDOUT ) ;
#endif
	return *msg == CI_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
short CIread_options(tag)
char  *tag;
/*
   Reads options from the tag in the file header.

   Constants defined in cidef.h:
 	CI_QUIET_MODE : suppresses information messages of the Command
 			Interpreter ( such as "Loading...", "Processing..." )
 	CI_NOMSG_MODE : suppresses command file messages.
 	CI_KEEP_MODE  : clones the command file.

 */
{
	char	*s	= tag;
	short	options	= 0;

	if( tag && *tag ) {
		while((s = strchr(s, '<')) != NULL ){
			if( !strncmp( CI_QUIET_STRING, s, CI_TAGOPT_SIZE ) ) 
				options |= CI_QUIET_MODE;
			else
			if( !strncmp( CI_NOMSG_STRING, s, CI_TAGOPT_SIZE ) ) 
				options |= CI_NOMSG_MODE;
			else
			if( !strncmp( CI_KEEP_STRING , s, CI_TAGOPT_SIZE ) ) 
				options |= CI_KEEP_MODE;
			s++;
		}
	}
	return options;
}
/*----------------------------------------------------------------------------*/
method load( int *rc ; char *filename ; int mode )

/*
 * Parses `filename' if need be, then loads the code into the instance data of
 * the object.
 * IN	filename	 : command file name
 *      mode             : LOAD, DUP, etc.
 * OUT  rc		 : pointer to completion code
 * VALUES OF *rc:
 *	CI_S_SUCCESS	 : operation succefully completed.
 *	CI_E_CANT_ACCESS : file not found.
 *	CI_E_FATAL_ERROR : parsing OR link OR OM send failed.
 *	CI_E_ACCCOMPILED : reading compiled file failed.
 *	CI_E_NO_SYM_FILE : symbols file ( ci.X ) not found.
 *	CI_E_CANT_MALLOC : memory allocation failure.
 * 
 * NOTE: `mode' is used to know if an execution of the function `init' in the
 *       PPL file must be performed. If mode is DUP, this means that the model
 *       is going to be loaded to be cloned afterwards (loaded with the "load_s"
 *       method), the model does not need to have the "init" function executed.
 */
{
  int		leng;
  UNIXpath	expanded_name;		/* Full name of PPL file	*/
  int		needs_parsing;		/* PPL needs  reparsing		*/
  int		i;
  char		file_tag[CI_MAXTAG];	/* Tag read from file header	*/
  int		OMsts ;			/* OM return code		*/
  FILE		*file ;
  char		version[CI_MAX_VERSION];/* PPL/CI version read from file*/
  short 	options		;	/* Execution option mask	*/

#ifdef DEBUG
  printf( "ci.load( %s ) ENTER\n", filename ) ; fflush( stdout ) ;
#endif
	/* Get full path-name from user-input name */
	*rc = CIgetname(filename, expanded_name);

	if( !*rc ) { *rc = CI_E_CANT_ACCESS ; goto WRAPUP ; }

	{
		char *base = strrchr (expanded_name, '/');
		base = base ? base + 1 : expanded_name;
		if (strlen (base) > 14)
			base[14] = 0;
	}
	leng = strlen( expanded_name );
	if( ends_with_dot_u(expanded_name) ){
		needs_parsing = 1;
 	} else if( ends_with_dot_e(expanded_name) ){
 		needs_parsing = 0;
 	} else {
		/* should never come here EB 10/26/87 */
		erreur( "ci: file name must end with \".u\" or \".e\"" ) ;
		*rc = CI_E_FATAL_ERROR ;
		goto WRAPUP ;
	}

	if( needs_parsing ) {
		/* AF: modified for message subsystem */
		if( CI_MSG ) {
			ex$message( msgnumb = CI_S_Parsing ) ;
		}

		if( ( ciruncompiler( my_id, expanded_name ) ) == 0 ) {
#ifdef DEBUG
printf("cii.i: *rc = %d\n",*rc );
#endif
			*rc = CI_E_FATAL_ERROR ;
			goto WRAPUP ;
		}
		/* now must end with ".e" */
		expanded_name[leng-1] = 'e';
	}


	/* Read options from tag */
	options = 0 ;
	if( file = fopen( expanded_name, "r" ) ) {
		if( CIreadhdr( file, version, file_tag, &i, rc ) ) {
#ifdef DEBUG
  printf( "ci.load : header <%s> \n", expanded_name ) ; fflush( stdout ) ;
  printf( "ci.load : file_tag <%s>\n", file_tag ) ; fflush( stdout ) ;
#endif
			options = CIread_options(file_tag);
		} else {
			goto WRAPUP ;
		}
		fclose( file ) ;
	}

	if( CI_MSG && !( options & CI_QUIET_MODE ) ) {
		ex$message( msgnumb = CI_S_Loading ) ;
	}
		
#ifdef DEBUG
  printf( "ci.load : recall_parsed <%s> opening\n", expanded_name ) ; fflush( stdout ) ;
#endif
	if( !recall_parsed(	expanded_name, file_tag, 
				&ME.ci->data, &i, rc ) ) {
#ifdef DEBUG
  printf( "recall_parsed FAILED rc = %d\n", *rc ) ; fflush( stdout ) ;
  ci$report_error( status = *rc, output = CI_ERR_STDERR ) ;
#endif
		goto WRAPUP ;
	}

	me^^ci.runparms.options = options ;

	if( i ) {
		/* File contains external symbols, dynamic load performed */
		if( !CIloadsyms() ) {
			*rc = CI_E_NO_SYM_FILE ; 
			goto FREE_DATA ;
		}
		if( !CIdynlink( ME.ci->data,
				expanded_name,
				my_id		) ) {
			*rc = CI_E_FATAL_ERROR ;
			goto FREE_DATA ;
		}
	}

	/* "ME.ci->data" has been allocated in "recall_parsed" */
	/*  Now allocate for info and private data */
	if( !alloc_ci_IGE( &ME.ci->my_info ) ) {
		*rc = CI_E_CANT_MALLOC ;
		FREE_DATA :
			free_ci_data( ME.ci->data, 1 ) ;
			goto WRAPUP ;
	}


	/* Get the index of cnst_list in the var table ( can be -1 ) */
	i = ME.ci->data->i_cnst_list = CIgetvarno( "cnst_list", ME.ci->data);
	if ( i != -1 ){
		/* Initialization of the construction list */
		if( init_cnst_list() == -1 ){
			erreur("problems in init_cnst_list");
		} else {
			/* symbology */
			ciget_symb(ME.ci->data->varvaltable[i]);
			ciget_text_attr(ME.ci->data->varvaltable[i]);
		}
	}

	ME.ci->data->info = ME.ci->my_info;
	((ci_IGE *)(ME.ci->data->info))->sender_id = sender_id;
	((ci_IGE *)(ME.ci->data->info))->sender_os = sender_os;

/* DG 092288 */
	me^^ci.runparms.EX_cmd_mode = 0 ;

	ME.ci->my_varvaltable = ME.ci->data->varvaltable;
	ME.ci->data->nb_clone = 1;

	/* Load the file name; take off suffix */
	strcpy(ME.ci->data->ficcmd, expanded_name);
	ME.ci->data->ficcmd[leng-2] = '\0';

	/* Remember that the file was successfully loaded */
	me^^super_cmd.state	= CI_LOADED_WITH_PPL;

	/* Initialization of prompt and message */
	me^^ci.runparms.msgsys.Prompt	[0] = '\0' ;
	me^^ci.runparms.msgsys.Message	[0] = '\0' ;
	me^^ci.runparms.msgsys.clear_prompt = TRUE ;

	switch( mode ) {
		case DUP : break ;
		default  :
		/* Execute function init, if it exists */
		i = 1;
		OMsts = ci$f_execute(	file	= my_id,
					entry	= "init",
					action	= &i ) ;

		if( !( OMsts & SUCC ) ) {
			ci$om_failed(sts = OMsts,
				     text= "ci.load-> ci.f_execute( `init' )" );
			*rc = CI_E_FATAL_ERROR ;
		}    
		break ;
	}

	if( !( me^^ci.runparms.options & CI_NOMSG_MODE ) ) {
		ex$message(	field	= PROMPT_FIELD	,
				in_buff	= ""		) ;
	}

	WRAPUP :
#ifdef DEBUG
  printf( "ci.load EXIT(%s)\n", filename ) ; fflush( stdout ) ;
  ci$report_error( status = *rc, output = CI_ERR_STDOUT ) ;
#endif
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
int CIgetinstrno( type, xdata, fname)
int type;
struct instance_ci *xdata;
char *fname;
/*
 * returns 
 *   the instruction number corresponding to function name fname if it exists
 *   -1 if it does not exist
 * if type == 0, outputs an error message in function doesn't exist
 */
{
	int i=0;

#ifdef DEBUG
printf("entering CIgetinstrno, fname:%s	no_entries:%d\n",fname,
						xdata->nbf_entries );
fflush(stdout);
#endif

	while( i < xdata->nbf_entries ){
		if( !strcmp(xdata->f_entries[i]->name, fname) )
			break;
		i++;
	}

	if( i >= xdata->nbf_entries ){
		if( type == 0 ){
			ci$report_error(	status = CI_W_NO_SUCH_FUN,
						output = CI_ERR_STDERR ) ;
		}
		return -1;
	} else
		return xdata->f_entries[i]->no_instr;
}
/*----------------------------------------------------------------------------*/
method init(int type; char *fname)

/*
 * Initializes the program counter to no_instr and other stuff
 * type: 0: if fname not found , error
 *       1   "     "           pc set to last instruction
 * fname: name of the entry function 
 */
{
	int i;
#ifdef DEBUG
 printf( "ci.init fname <%s>\n", fname ) ;
 fflush(stdout);
#endif

	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		me^^super_cmd.exec_flag = CI_E_OBJCT_EMPTY ;
		CIprog_error( CI_E_OBJCT_EMPTY, "method ci.init" ) ;
		goto WRAPUP ;
	}

#ifdef DEBUG
printf("entering init %s (%d)\n",ME.ci->data->ficcmd, (int)my_id);
fflush(stdout);
#endif
	/* Program counter and stack.
	   The entry point is given by the name of the function.
	 */ 
	i = CIgetinstrno( type, ME.ci->data, fname);

	if( i == -1 ){
		me^^ci.exec_ctx.pc = ME.ci->data->nbinstr ;
		me^^super_cmd.exec_flag = CI_W_NO_SUCH_FUN ;
		ci$report_error( status = CI_W_NO_SUCH_FUN,
				 output = CI_ERR_STDERR ) ;
				/* nothing will be executed */
	} else {
		me^^ci.exec_ctx.pc = i;
	}
	me^^ci.exec_ctx.istack = 0;

#ifdef DEBUG
  printf( "ci.init EXIT\n" ) ; fflush(stdout);
#endif
	WRAPUP :
	return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/
method delete(int n)

/*
 * Terminates & delete the CI object. The deletion is left to the care of
 * `SCIdelete', which will update its lists of loaded CI objects and will
 * perform the actual memory clean-up and deletion.
 */
{
	SCIdelete(ME.ci->data->ficcmd, my_id);

	return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/
method terminate( int *msg )

/*
 * Runs the user function "delete", if one exists and deallocates the memory.
 */
{
	int OMsts ;	/* OM return code	*/
	int rc;

	*msg = CI_S_SUCCESS ;

	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		CIprog_error( CI_E_OBJCT_EMPTY, "method ci.terminate" ) ;
		*msg = CI_E_OBJCT_EMPTY ;
		return OM_S_SUCCESS;
	}

	/* Execute function `delete' if one exists */
	rc = 1;
	OMsts = ci$f_execute(	file	= my_id,
				entry	= "delete",
				action	= &rc	) ;
	if( OMsts != OM_S_SUCCESS ) {
		ci$om_failed(	sts = OMsts,
				text= "ci.delete-> ci.f_execute( `delete' )" ) ;
	}    

 	free_ci_IGE( ME.ci->my_info ) ;

	/* First free info specific to ci */
	if( ME.ci->data->nb_clone-- > 1 ){
		/* Other brothers are still alive :
		 * delete only my private data
		 */
		if( ME.ci->my_varvaltable[0] != NULL )
			free( ME.ci->my_varvaltable[0]);
		if( ME.ci->my_varvaltable != NULL)
			free( ME.ci->my_varvaltable);
	} else {
		/* I'm the last one of the family */
		ME.ci->data->varvaltable = ME.ci->my_varvaltable;
	        free_ci_data( ME.ci->data, 1 );
		ME.ci->data = NULL;		/* cgp 2/13/90. Note this for
						   restore context */
	}

	return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/
method super_cmd.sleep (IGRint pos)

{
	int stat;
	int rc;

	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		me^^super_cmd.exec_flag = CI_E_OBJCT_EMPTY ;
		CIprog_error( CI_E_OBJCT_EMPTY, "method ci.sleep" ) ;
		goto WRAPUP ;
	}

	/* Execute function `sleep', if one exists */
	rc = 1;
	stat = ci$f_execute(	file	= my_id,
				entry	= "sleep",
				action	= &rc ) ;
	if( stat != OM_S_SUCCESS ) {
		ci$om_failed(	sts = stat,
				text= "ci.delete-> ci.f_execute( `sleep' )" ) ;
	}
	WRAPUP :
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method wakeup (IGRint pos)

{
	int stat;
	int rc;

#ifdef DEBUG
  printf( "ci.wakeup ENTER\n" ) ; fflush(stdout);
#endif
	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		me^^super_cmd.exec_flag = CI_E_OBJCT_EMPTY ;
		CIprog_error( CI_E_OBJCT_EMPTY, "method ci.wakeup" ) ;
		goto WRAPUP ;
	}

	/* Execute function `wakeup', if one exists */
	rc = 1;
	stat = ci$f_execute(	file	= my_id,
				entry	= "wakeup",
				action	= &rc	) ;
	if( stat != OM_S_SUCCESS ) {
		ci$om_failed(	sts = stat,
				text= "ci.delete-> ci.f_execute( `wakeup' )" ) ;
	}    

#ifdef DEBUG
  printf( "ci.wakeup EXIT\n" ) ; fflush(stdout);
#endif
	WRAPUP :
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
cireveil( runenv )

CIruntime *runenv ;

/*
 * reveil=wake_up in french
 * Called in ci.execute and ci$exec after the ci object has been swapped out and
 * then swapped back in, due to a call to a PPL wait-for-event function.
 */
{
#ifdef DEBUG
  printf( "cireveil ENTER\n" ) ; fflush(stdout);
#endif
	/* symbology */
	CI_SYMB("set_symb");
	CI_SYMB("set_text_attr");

	if( !( runenv->options & CI_NOMSG_MODE ) ) {
		COND_message( runenv->msgsys.Message ) ;
		if( !( runenv->options & CI_QUIET_MODE ) ) {
			if( CI_MSG ) {
				ex$message( msgnumb	= CI_S_Process	,
					    type	= "%s"		,
					    var		= `ci_data->ficcmd` ) ;
			}
		}
	}

#ifdef DEBUG
  printf( "cireveil EXIT\n" ) ; fflush(stdout);
#endif
	return TRUE ;
}
/*----------------------------------------------------------------------------*/
method execute(int *response; char *response_data; int pos)

/*
 * Execute the code contained in the instance data. Manages interrupts
 * provoked by wait-for-event PPL functions.
 */
{
  unsigned short	*pc = &me^^ci.exec_ctx.pc;/* Program counter	*/
  struct instance_ci	*previous_ci_data;	/* Code of preceeding CI*/
  OM_S_OBJID		previous_ci_id;		/* Id of preceeding CI	*/
  char			**previous_vrvl;	/* Data of preceeding CI*/
  char			*previous_info;		/* Info of preceeding CI*/
  CIco_resp		coevdata	;	/* Command Object info	*/
  extern short          CIstop_chk;
  short                 save_CIstop_chk;


#ifdef DEBUG
  printf( "ci.execute ENTER(%s)\n", ME.ci->data->ficcmd ) ; fflush( stdout ) ;
#endif
	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		me^^super_cmd.exec_flag = CI_E_OBJCT_EMPTY ;
		CIprog_error( CI_E_OBJCT_EMPTY, "method ci.execute" ) ;
		goto WRAPUP ;
	}

	/* Update the general pointers used in all functions,
	   after saving them.
	*/
	previous_ci_data	= ci_data;
	previous_ci_id		= ci_id;
	previous_vrvl		= ci_data_varvaltable;
	previous_info		= ci_data_info;

	ci_data			= ME.ci->data;
	ci_data_varvaltable	= ME.ci->my_varvaltable;
	ci_data_info		= ME.ci->my_info;
	ci_id			= my_id;

#ifdef DEBUG
  printf( "ci.execute before cireveil\n" ) ; fflush( stdout ) ;
#endif
	cireveil( &me^^ci.runparms );

#if CIREADRTREE
	/* turns read in the rtree on */
/*
	som_rtree_ops_flag(bool1);
 */
#endif

        /* Inhibit IGEstop() if file is automatically kicked off */
        if( ! CI_FILE_KEYED_IN( ME.super_cmd->mytype ) ) {
                save_CIstop_chk = CIstop_chk;
                CIstop_chk = 0;
        }


	if( *pc < ci_data->nbinstr ){
#ifdef DEBUG
  printf( "ci.execute( %s ) before CIexecute\n", ci_data->ficcmd ) ; fflush( stdout ) ;
#endif
		coevdata.response	= response	;
		coevdata.response_data	= response_data	;
		coevdata.pos		= pos		;
		coevdata.ci_id		= my_id		;
		switch( CIexecute(	&me^^super_cmd.exec_flag,
					ME.ci->data->ficcmd,
					&me^^ci.exec_ctx,
					&coevdata	,
					&me^^super_cmd.state,
					&me^^ci.runparms ) ) {
		case CI_EXEC_FINISHED :
		case CI_EXEC_SUSPNDED : break;
		case CI_EXEC_CLEAREVQ :/* Clear the event queue */
			ex$clear_event_queue();

			/* Reset of the switch begincmd/endcmd */
			cidocmd( CI_DOCMD_RESET, NULL, NULL, &me^^ci.runparms );
			break;
		}
	}

        /* Restore IGEstop() if file is automatically kicked off */
        if( ! CI_FILE_KEYED_IN( ME.super_cmd->mytype ) ) {
                CIstop_chk = save_CIstop_chk;
        }

	/* Close files openned for input/output */
	ciclose_all();

	/* Restore the previous values, in case of another ci running on top of
	   this one.
	 */
	ci_id			= previous_ci_id;
	ci_data			= previous_ci_data;
	ci_data_varvaltable	= previous_vrvl;
	ci_data_info		= previous_info;

#if CIREADRTREE
	/* turns read in the rtree off */
/*
	som_rtree_ops_flag(bool0);
 */
#endif
	WRAPUP :
#ifdef DEBUG
  printf( "ci.execute( %s ) EXIT\n", ci_data->ficcmd ) ; fflush( stdout ) ;
#endif
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method set_value( int *rc ; char *vname; char *vvalue; int size )

/*
 * Set the value pointed by `vvalue' in variable of name `vname'.
 * `size' specifies the size ( in bytes ) to be copied.
 * If `size' is set to zero, a default size is taken which is correct for simple
 * types ( int, char, etc .. ) but that may cause errors for structs.
 * VALUES of *rc ( if rc != NULL ) :
 * CI_S_SUCCESS     : Operation successfully completed.
 * CI_E_OBJCT_EMPTY : CI object not loaded with a PPL file.
 * CI_W_NO_SUCH_VAR : Requested global variable inexistent in PPL file.
 * This method is interfaced by the macro "ci$set_value" defined in
 * "ciexecmacros.h".
 */
{
	int i, msg ;

	msg = CI_S_SUCCESS ;

	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		msg = CI_E_OBJCT_EMPTY ;
		goto WRAPUP ;
	}

	if((i=CIgetvarno(vname, ME.ci->data)) == -1){
		msg = CI_W_NO_SUCH_VAR ;
		goto WRAPUP ;
	}

	if ( size == 0 )
		size =  CIsizeof(i, ME.ci->my_varvaltable, ME.ci->data);
	memcpy(ME.ci->my_varvaltable[i], vvalue, size );  

	WRAPUP :
		if( rc != NULL ) *rc = msg ;
	return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/
method get_value( int *rc ; char *vname; char *vvalue; int size)

/*
 * Gets the value of variable of name `vname' and copies its value to the memory
 * pointed to by `vvalue'.
 * See method ci.set_value.
 * VALUES of *rc ( if rc != NULL ) :
 * CI_S_SUCCESS     : Operation successfully completed.
 * CI_E_OBJCT_EMPTY : CI object not loaded with a PPL file.
 * CI_W_NO_SUCH_VAR : Requested global variable inexistent in PPL file.
 * This method is interfaced by the macro "ci$get_value" defined 
 * in "ciexecmacros.h".
 */
{
	int i, msg ;

	msg = CI_S_SUCCESS ;

	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		msg = CI_E_OBJCT_EMPTY ;
		goto WRAPUP ;
	}

	if((i=CIgetvarno(vname, ME.ci->data)) == -1){
		msg = CI_W_NO_SUCH_VAR ;
		goto WRAPUP ;
	}

	if ( size == 0 )
		size =  CIsizeof(i, ME.ci->my_varvaltable, ME.ci->data);
	memcpy( vvalue, ME.ci->my_varvaltable[i], size );  

	WRAPUP :
	if( rc != NULL ) *rc = msg ;
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method save_context( int *rc )

/* PRIVATE METHOD
 * Saves the pc (Program Counter) to be able to the restart execution later.
 */
{
	int st;
	char *putloc = me^^ci.data->save_regs_buff;

	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		CIprog_error( CI_E_OBJCT_EMPTY, "method ci.save_context" ) ;
		*rc = CI_E_OBJCT_EMPTY ;
		goto WRAPUP ;
	}

	*rc = CI_S_SUCCESS ;
	me^^ci.save_ctx.pc = me^^ci.exec_ctx.pc ;
   	st = me^^ci.save_ctx.istack = me^^ci.exec_ctx.istack ;
	while(st-- > 0)
		me^^ci.save_ctx.stack[st] = me^^ci.exec_ctx.stack[st] ;

	/* save registers */
        for (st = 0; me^^ci.data->save_regs_info[st].addr; st++) {
		memcpy (putloc, me^^ci.data->save_regs_info[st].addr,
				me^^ci.data->save_regs_info[st].size);
		putloc += me^^ci.data->save_regs_info[st].size;
        }

	WRAPUP :
	return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/
method restore_context( int *rc )

/*
 * Restores the pc (Program Counter) to be able to restart execution.
 */
{
	int st;
	char *getloc;
/*
	check for null pointer before assignment -GVK 1/14/92
	char *getloc = me^^ci.data->save_regs_buff;
*/

	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		CIprog_error( CI_E_OBJCT_EMPTY, "method ci.restore_context" ) ;
		*rc = CI_E_OBJCT_EMPTY ;
		goto WRAPUP ;
	}

	*rc = CI_S_SUCCESS ;
	if (!me^^ci.data) goto WRAPUP;	/* cgp 2/13/90; somebody lost me while
					   I was gone? */

	/* after null check -GVK */
	getloc = me^^ci.data->save_regs_buff;

   	me^^ci.exec_ctx.pc = me^^ci.save_ctx.pc ;
   	st = me^^ci.exec_ctx.istack = me^^ci.save_ctx.istack  ;
	while(st-- > 0)
		 me^^ci.exec_ctx.stack[st] = me^^ci.save_ctx.stack[st] ;

	/* restore registers */
        for (st = 0; me^^ci.data->save_regs_info[st].addr; st++) {
		memcpy (me^^ci.data->save_regs_info[st].addr, getloc,
				me^^ci.data->save_regs_info[st].size);
		getloc += me^^ci.data->save_regs_info[st].size;
        }

	WRAPUP :
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method f_execute( int *rc; char *entry ; char *retval ; int retsize )

/*
 * Executes only the code in the function `entry'.
 * IN : entry, name of function to execute.
 * IN : retsize, size of value returned by function.
 * OUT: retval, pointer to memory to store returned value.
 * IN : rc, if *rc is 0, output error if function does not exist else don't.
 * OUT: rc, completion code.
 * VALUES OF *rc:
 * 		CI_S_SUCCESS	 : operation sucessfully completed.
 * 		CI_E_OBJCT_EMPTY : object not loaded with a file.
 * 		CI_W_NO_SUCH_FUN : entry point not found.
 * 		CI_E_FATAL_ERROR : OM error during transaction.
 * NB: the code CANNOT be interrupted.
 * If the returned value is not desired, `retsize' must be 0 and `retval' NULL.
 * This method is interfaced by the macro "ci$f_execute" defined in
 * "ciexecmacros.h".
 */
{
	int response;		/* For events in PPL file		*/
	char *response_data;	/* For events in PPL file		*/
	int pos;		/* For events in PPL file		*/
	int rcin = *rc;
	long OMsts ;		/* OM return code			*/


#ifdef DEBUG
  printf( "ci.f_execute: ENTER entry = <%s>\n", entry ) ; fflush( stdout ) ;
#endif
	*rc = CI_S_SUCCESS ;


	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		*rc = CI_E_OBJCT_EMPTY ;
		goto WRAPUP ;
	}

	if( CIgetinstrno( 1, ME.ci->data, entry) == -1 ) {
		/* function entry does not exist */
		*rc = CI_W_NO_SUCH_FUN ;
		goto WRAPUP ;
	}

	/* Save the context */
	OMsts = om$send( msg	  = message ci.save_context( rc ),
	    		 targetid = my_id );

	if( OMsts != OM_S_SUCCESS ) {
		ci$om_failed(	sts = OMsts,
				text= "ci.f_execute -> ci.save_context" ) ;
		*rc = CI_E_FATAL_ERROR ;
		goto WRAPUP ;
	}    

	if( *rc != CI_S_SUCCESS ) goto WRAPUP ;

	/* Set the program counter to function entry */
	/* = init with good parameter */
	OMsts = om$send( msg	  = message ci.init(rcin, entry),
		   	 targetid = my_id );

	if( OMsts != OM_S_SUCCESS ) {
		ci$om_failed(	sts = OMsts,
				text= "ci.f_execute -> ci.init" ) ;
		*rc = CI_E_FATAL_ERROR ;
		goto RESTORE ;
	}    

/* --	`response_data' must be malloc'd to have a correct alignment.
   -- */
	if( ( response_data = malloc( EX_RESPONSE_DATA_SIZE ) ) == NULL ) {
		*rc = CI_E_CANT_MALLOC ;
		goto RESTORE ;
	}
	OMsts = om$send( msg	  = message ci.execute(	&response,
							response_data,
							pos ),
			 targetid = my_id );

	free( response_data ) ;

	if( OMsts != OM_S_SUCCESS ) {
		ci$om_failed(	sts = OMsts,
				text= "ci.f_execute -> ci.execute" ) ;
		*rc = CI_E_FATAL_ERROR ;
		goto RESTORE ;
	}    

	om$send( msg	  = message ci.get_fcn_val( entry, retval, retsize ),
		 targetid = my_id ) ;
RESTORE:
	/* Restore context */
	OMsts = om$send(	msg	 = message ci.restore_context( rc ),
				targetid = my_id );

	if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts = OMsts,
				text= "ci.f_execute -> ci.restore_context" ) ;
		*rc = CI_E_FATAL_ERROR ;
	}    

	WRAPUP :
#ifdef DEBUG
  printf( "ci.f_execute: entry = <%s> EXIT(%d[0x%x])\n", entry, *rc, *rc ) ;
  fflush( stdout ) ;
  ci$report_error( status = *rc, output = CI_ERR_STDOUT ) ;
#endif
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method exec_fun(	int	*rc;
			char	*entry;
			char	*vname;
			char	*vvalue;
			int	size ;
			char	*retval;
			int	retsize )
/*
 * Same as f_execute but the context is not saved,
 * furthermore a pointer is passed to be assigned to a
 * variable ( does a set_value )
 *
 * IN : entry, name of function to execute.
 * IN : retsize, size of value returned by function.
 * IN : vname, name of variable to set.
 * IN : vvalue, pointer to value for `vname'.
 * IN : size, size of `*vvalue'.
 * OUT: retval, pointer to memory to store returned value.
 * IN : rc, if *rc is 0, output error if function does not exist else don't.
 * OUT: rc, completion code.
 * VALUES OF *rc:
 * 		CI_S_SUCCESS	 : operation sucessfully completed.
 * 		CI_E_OBJCT_EMPTY : object not loaded with a file.
 * 		CI_W_NO_SUCH_FUN : entry point not found.
 * 		CI_W_NO_SUCH_VAR : variable "vname" not found.
 * 		CI_E_FATAL_ERROR : OM error during transaction.
 * NB: the code can NOT be interrupted
 * If the returned value is not desired, `retsize' must be 0 and `retval' NULL.
 * If `set_value' is not desired, `vname' and `vvalue' must be NULL.
 * This method is interfaced by the macro "ci$exec_fun" defined in
 * "ciexecmacros.h".
 */
{
	int response;		/* For events in PPL file		*/
	char *response_data ;	/* For events in PPL file		*/
	int i;			/* For events in PPL file		*/
	long OMsts ;		/* OM return code			*/


#ifdef DEBUG
  printf( "ci.exec_fun: ENTER\n" ) ; fflush( stdout ) ;
#endif
	*rc = CI_S_SUCCESS ;


	if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) ) {
		*rc = CI_E_OBJCT_EMPTY ;
		goto WRAPUP ;
	}

	/* Set the program counter to function entry. 
	   What follows is the init code.
	*/
	if( ( me^^ci.exec_ctx.pc = CIgetinstrno( 1, ME.ci->data, entry)) == -1 ){
		/* Function entry does not exist */
		*rc = CI_W_NO_SUCH_FUN ;
		goto WRAPUP ;
	} 
	me^^ci.exec_ctx.istack = 0;

	/* Does the set_value only if pointer is not NULL.
	   Same as for init: for efficiency, code is expanded here.
	 */
	if( vvalue != NULL && vname != NULL ){
		if((i=CIgetvarno(vname, ME.ci->data)) == -1){
			*rc = CI_W_NO_SUCH_VAR ;
			goto WRAPUP ;
		} else {
			if ( size == 0 )
				size = CIsizeof( i, ME.ci->my_varvaltable,
						    ME.ci->data);
			memcpy(ME.ci->my_varvaltable[i], vvalue, size );  
		}
	}

/* --	`response_data' must be malloc'd to have a correct alignment.
   -- */
	if( ( response_data = malloc( EX_RESPONSE_DATA_SIZE ) ) == NULL ) {
		*rc = CI_E_CANT_MALLOC ;
		goto WRAPUP ;
	}
/* --	Execute the code.
   -- */
	OMsts = om$send( msg	  = message ci.execute(	&response,
							response_data,
							i ),
	    		 targetid = my_id );

	free( response_data ) ;

	if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts = OMsts,
				text= "ci.exec_fun -> ci.execute" ) ;
		*rc = CI_E_FATAL_ERROR ;
		goto WRAPUP ;
	}    

#ifdef DEBUG
  printf( "ci.exec_fun: after ci.execute\n" ) ; fflush( stdout ) ;
#endif
	om$send( msg	  = message ci.get_fcn_val( entry, retval, retsize ),
		 targetid = my_id ) ;

	WRAPUP :
#ifdef DEBUG
  printf( "ci.exec_fun: EXIT(%d[0x%x])\n", *rc, *rc ) ; fflush( stdout ) ;
  ci$report_error( status = *rc, output = CI_ERR_STDOUT ) ;
#endif
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method cmd_info(	char	*cmd_name,
				*cmd_key;
			int	*mytype,
				action )
/* -- Inquires or sets for information about the PPL file as a command.
   IN  : action, EX_INQ : inquire, EX_SET : set.
   IN if action = EX_SET and OUT if action EX_INQ :
	- cmd_name : name under which the PPL was invoked.
	- cmd_key  : key corresponding to above command name.
	- type     : type of command as entered in the command table.
   -- */
{
#define MAX_CMD_KEY_LEN 10
#define MAX_CMD_NAM_LEN 52
	register char *p ;

  switch( action ) {
	case EX_INQ	: strcpy(cmd_name, ME.super_cmd->cmd_name);
/* --	Remove underscores put by the Executive.
   -- */
			  for( p = cmd_name ; *p ; p++ )
					if( *p == '_' ) *p = ' ' ;
			  strcpy(cmd_key, ME.super_cmd->cmd_key);
			  *mytype = ME.super_cmd->mytype;
			  break ;

	case EX_SET	: strncpy( ME.super_cmd->cmd_name,
				   cmd_name,
				   MAX_CMD_NAM_LEN )[MAX_CMD_NAM_LEN] ;
			  strncpy( ME.super_cmd->cmd_key ,
				   cmd_key,
				   MAX_CMD_KEY_LEN )[MAX_CMD_KEY_LEN] ;
			  ME.super_cmd->mytype = *mytype;
			  break ;
	}
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/

end implementation  ci;
