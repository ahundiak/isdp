/*
 * Macros to load, run and delete CI object from a regular C file.
 * Not to be used form a PPL source file.
 * GARDELLA Dominique. ISDC, Paris.
 * History:
 *	08/26/88: Implementaion of super CI feature.
 *	 A new macro is proposed, "ci$delete" and a new argument, "load" is
 *	 added to the macro "ci$load()". It is the same argument already
 *	 requested by the macros "ci$run()" and "ci$exec()", but with some
 *	 additionnal meaning.
 *	10/20/88: In order to speed up computation, a feature is proposed that
 *	 prevents the date stored with a CI object to be checked against the
 *	 date of the ".e" file. 
 * NOTES
 * - CI objects will ALWAYS be created in the Transient Object Space. Therefore
 *  the argument "file_os" has been removed form the macros ci$load(), ci$run()
 *  and ci$exec().
 * - if defined in the CI file, the function "init()" will be run at load time.
 * 
 * File dependency: ciexecdef.h (automatically included).
 */

#ifndef CIEXECMACROS_INCLUDE
#	define CIEXECMACROS_INCLUDE

#ifndef CIEXECDEF_INCLUDE
#	include "ciexecdef.h"
#endif



static OM_S_OBJID	SCI_fileid;


/* ** PRIVATE INTERFACE MACRO ** */
#omdef ci$e_x_e_c(	file_name	,
			file_id		,
			entry		,
			load_flag	,
			verif_flag	,
			init_flag	,
			run_flag	,
			delete_flag	,
			sender_id	,
			sender_os = OM_Gw_current_OS	,
			retval		,
			retsize		,
			stat		)
ci_exec(	(file_name)	, (file_id)	, (entry)	,
		(load_flag)	, (verif_flag)	, (init_flag)	,
		(run_flag)	, (delete_flag)	, (sender_id)	,
		(sender_os)	, (retval)	, (retsize)	,
		(stat)	)
#endomdef

/*******************  ci$exec,  ci$load,  ci$run  *****************************/
/*
 ARGUMENTS:
 The three macros use a subset of the following argument list:
 char	*file_name:	I	name of the file that must be executed
 OM_S_OBJID *file_id:	I/O	id of this file
				One of the two must be given.
 char	*entry:		I	name of the entry function ( by default "main" )
 int	load:		I	requested action. c.f. examples.
 int	run:		I	1: run  the file, 0: no
 int	delete:		I	1: deletes the file after execution , 0:no
 OM_S_OBJID sender_id:	I	sender id
 int	*stat		O	return status
 RETURNS : TRUE if SUCCESS else FALSE ( error code in "*stat" in this case ).

 RETURN STATUS (in "*stat", defined in cierrordef.h ):
CI_S_SUCCESS		OK
CI_E_FATAL_ERROR	KO
CI_E_NO_SUCHFILE	neither the source file, nor the compiled file exists
CI_E_ACCCOMPILED	the system failed to give info. on the compiled file
CI_E_CLON_FAILED	an error occured while cloning for the new CI object
CI_E_LOAD_FAILED	an error occured while loading the new CI object
CI_E_DB_OVERFLOW	the object has been created but cannot be registered
			in the database
CI_E_MODELNOTFND	no model object found
CI_E_INVALIDARGS	invalid arguments
CI_W_NO_SUCH_FUN	the object has been successfully loaded/cloned/retrieved
			but the entry point doesn't exist.

 EXAMPLES:
 1/ to load an object as we used to before:
	load = LOAD_UNCOND
 2/ to load a command object:
	load = DUP
 3/ to get the id. of an existing CI object or to load (and initialize) a new
    CI object if it doesn't exist yet:
	load = LOAD
 4/ to retrieve the id of an existing CI object:
	load = RETRIEVE
 5/ (10/20/88) to retrieve the id of an existing CI object when you guarantee
    the ".e" file hasn't changed in the meantime:
	load = RETRIEVE | NO_DATE
*/

/*******************            ci$exec           *****************************/
#omdef ci$exec(	file_name 	= NULL,
		file_id		= &SCI_fileid,
		entry		= "main",
		load		= LOAD_UNCOND,
		run		= 1,
		delete		= 1,
		retval		= NULL,
		retsize		= 0,
	  	sender_id	= my_id,
	  	sender_os	= OM_Gw_current_OS,
	  	stat		= NULL )

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "ci$exec: 'file_name' AND 'file_id' not specified"
#endif
ci$e_x_e_c(	file_name	= (file_name)	,
		file_id		= (file_id)	,
		entry		= (entry)	,
		load_flag	= (load)	,
		verif_flag	= 0		,
		init_flag	= 0		,
		run_flag	= (run)		,
		delete_flag	= (delete)	,
		sender_id	= (sender_id)	,
		sender_os	= (sender_os)	,
		retval		= (retval)	,
		retsize		= (retsize)	,
		stat		= (stat)	)
#endomdef
 

/*******************            ci$run            *****************************/
#omdef ci$run(	file_name 	= NULL,
		file_id		= &SCI_fileid,
		entry		= "main",
		load		= NO_LOAD,
		delete		= 0,
		retval		= NULL,
		retsize		= 0,
		sender_id	= my_id,
	  	sender_os	= OM_Gw_current_OS,
		stat		= NULL )

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "ci$run: 'file_name' AND 'file_id' not specified"
#endif

ci$e_x_e_c(	file_name	= (file_name)	,
		file_id		= (file_id)	,
		entry		= (entry)	,
		load_flag	= (load)	,
		verif_flag	= 0		,
		init_flag	= 0		,
		run_flag	= 1		,
		delete_flag	= (delete)	,
		sender_id	= (sender_id)	,
		sender_os	= (sender_os)	,
		retval		= (retval)	,
		retsize		= (retsize)	,
		stat		= (stat)	)
#endomdef

/*******************            ci$load           *****************************/
#omdef ci$load(	file_name	= NULL,
		load		= LOAD_UNCOND,
		file_id		= &SCI_fileid,
		sender_id	= my_id,
	  	sender_os	= OM_Gw_current_OS,
		stat		= NULL )

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "ci$load: 'file_name' AND 'file_id' not specified"
#endif

ci$e_x_e_c(	file_name	= (file_name)	,
		file_id		= (file_id)	,
		entry		= "main"	,
		load_flag	= (load)	,
		verif_flag	= 0		,
		init_flag	= 0		,
		run_flag	= 0		,
		delete_flag	= 0		,
		sender_id	= (sender_id)	,
		sender_os	= (sender_os)	,
		retval		= NULL		,
		retsize		= 0		,
		stat		= (stat)	)
#endomdef


/******************************************************************************/
/*******************            ci$delete         *****************************/
/*
 Delete one or many CI objects with a DataBase update.
 filename: name of the file. Optionnal but increases system performance when
	specified.
 fileid: id. of the CI object. Optionnal. If not specified, all the CI objects
	running the corresponding file are deleted and the entry in the DataBase
	is removed. If specified, only one object is deleted and the linked
	list is maintained.
 At least one argument must be specified.
*/
#omdef ci$delete(file_name	= NULL,
		 file_id	= NULL_OBJID)

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "ci$delete: 'file_name' AND 'file_id' not specified"
#endif

SCIdelete(	(file_name),	/* file name */
		(file_id) )	/* file id. */
#endomdef

/* -- Type of array of arguments for ci$push.
   -- */

typedef struct	{
		void	*addr	;	/* Address of argument to push	*/
		int	size	;	/* Size of argument to push	*/
} CIpushlist ;

/* -- Macro interfaces to public ci messages. See ci.S for arguments.
   -- */
#define ci$opp$import \
  from ci import set_value, get_value, exec_fun, f_execute, is_entry_point

#omdef ci$set_value(	name		,
			p_val		,
			size	= -1	,
			file		,
			senderid= my_id	,
			stat	= NULL	)
#if om$equal( size, -1 )
  om$send( msg		= message ci.set_value(	(stat),
  						(name),
						(char *) (p_val),
						sizeof( *(p_val) ) ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#else
  om$send( msg		= message ci.set_value(	(stat),
						(name),
  						(char *) (p_val),
  						size ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#endif
#endomdef
#omdef ci$get_value(	name		,
			p_val		,
			size	= -1	,
			file		,
			senderid= my_id	,
			stat	= NULL	)
#if om$equal( size, -1 )
  om$send( msg		= message ci.get_value(	(stat),
  						(name),
  						(char *) (p_val),
  						sizeof( *(p_val) ) ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#else
  om$send( msg		= message ci.get_value(	(stat),
						(name),
  						(char *) (p_val),
  						size ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#endif
#endomdef

#omdef ci$f_execute(	file 		,
			entry		,
			retval	= NULL	,
			retsize	= 0	,
			senderid= my_id	,
			action		)
  om$send( msg		= message ci.f_execute( (action),
						(entry),
						(retval),
						(retsize) ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#endomdef

#omdef ci$is_entry_point( stat, file, entry, senderid = my_id )
  om$send( msg		= message ci.is_entry_point( (stat), (entry) ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#endomdef

#omdef ci$exec_fun(	file 		,
			entry		,
			name 		,
			p_val		,
			retval	= NULL	,
			retsize	= 0	,
			size	= -1	,
			senderid= my_id	,
			action		)
#if om$equal( size, -1 )
  om$send( msg		= message ci.exec_fun(	(action),
						(entry)	,
						(name)	,
						(p_val)	,
						sizeof (*(p_val)),
						(retval),
						(retsize) ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#else
  om$send( msg		= message ci.exec_fun(	(action),
						(entry)	,
						(name)	,
						(p_val)	,
						(size)	,	
						(retval),
						(retsize) ),
	   senderid	= (senderid),
  	   targetid	= (file),
  	   targetos	= OM_Gw_TransOSnum_0 )
#endif
#endomdef			
		
/* -- Pushes arguments on the PPL function stack which are to be used by a
      function in a PPL file.
      INPUT : argc, count of arguments.
      	      argv, array of arguments (of type CIpushlist).
      RETURNS: TRUE of FALSE, whether pushing succeeded or not.

      Sample use:

      Let the PPL function "func" in a PPL file "cmd.u" be :

	int func( obj, pnt, env, val )
		struct GRid	obj	;
		IGRpoint	pnt	;
		struct GRmd_env	*env	;
		double		val	; {
			<code>
	}
      To execute "func" form a C-source file with the arguments

	struct GRid Obj, IGRpoint Pnt, struct GRmd_env Env, double Val

      proceed as follow:
      {
      		CIpushlist	arglist[4]	;
      		struct GRmd_env	*pEnv = &Env	; (* "func" expects a pointer *)
		IGRdouble	*ptr  = Pnt	;

      		arglist[0].addr	= &Obj		;
      		arglist[0].size = sizeof Obj	;
      		arglist[1].addr = &ptr		;
      		arglist[1].size = sizeof ptr	;      
      		arglist[2].addr = &pEnv		;
      		arglist[2].size = sizeof pEnv	;      
      		arglist[3].addr = &Val		;
      		arglist[3].size = sizeof Val	;

 		(* "func" called as func( Obj, Pnt, &Env, Val ) *)
 
		ci$push( argc = 4, argv = arglist ) ;

		ci$exec( file_name	= "cmd.u",
			 entry		= "func" ) ;
	}
	Note that the pushed arguments must match in count and type with those
	expected by the function in the PPL file.
    -- */
#omdef ci$push(	argc = 1,
		argv	)

	CIpush( argc, argv )
#endomdef

#endif

