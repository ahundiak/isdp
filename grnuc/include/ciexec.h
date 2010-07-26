/*
 * Macros to load, run and delete CI object from a PPL file.
 * GARDELLA Dominique. ISDC, Paris.
 * History:
 *	08/26/88: Implementation of super CI feature.
 *	 A new macro is proposed, "ci$delete" and a new argument, "load" is
 *	 added to the macro "ci$load()". It is the same argument already
 *	 requested by the macros "ci$run()" and "ci$exec()", but with some
 *	 additionnal meaning.
 *	09/26/88: Addition of two macros that inquire the lists maintained
 *	 by the CI super object.
 * NOTES
 * - CI objects will ALWAYS be created in the Transient Object Space. Therefore
 *  the argument "file_os" has been removed form the macros ci$load(), ci$run()
 *  and ci$exec().
 * - if defined in the PPL file, the function "init()" will be run at load time.
 *
 * File dependency: ciminimum.h
 *		    ciexecdef.h (automatically included).
 */

#ifndef CIEXEC_INCLUDE
#	define CIEXEC_INCLUDE

#ifndef CIEXECDEF_INCLUDE
#	include "ciexecdef.h"
#endif

/* Avoids the inclusion of "cierrordef.h" for favorable cases ! */
#ifndef CI_S_SUCCESS
#	define CI_S_SUCCESS	1
#endif

GRobj 	M_fileid;


/*******************  ci$exec,  ci$load,  ci$run  *****************************/
/*
 ARGUMENTS
 The three macros use a subset of the following argument list:
 char	*file_name	I	PPL source file name, with or without the suffix
				".u", with an absolute or a relative path.
 GRobj	*file_id	I/O	INPUT if load = NO_LOAD, else OUTPUT.
				Id of the related CI object.
 char	*entry		I	Name of the entry function ( default "main" )
 int	load		I	Requested action. Cf. examples.
 int	run		I	TRUE: runs file, FALSE: no.
 int	delete		I	TRUE: deletes file after execution , FALSE:no.
 int	stackable	I	TRUE: execution of file can be interrupted by
				another command object, FALSE: no.
 void	*retval		O	Pointer to memory to store returned value of
 				"entry" (CI_NULL if not needed).
 int	retsize		I	Size of returned value of entry (0 if not
				needed).
 int	*stat		O	Return code.

 RETURN CODE ( In "*stat" . Return codes defined in cierrordef.h )
CI_S_SUCCESS	1	OK
CI_E_FATAL_ERROR	KO
CI_E_NO_SUCHFILE	Neither the source file, nor the compiled file exists
CI_E_ACCCOMPILED	the system failed to give info. on the compiled file
CI_E_CLON_FAILED	An error occured while cloning for the new CI object
CI_E_LOAD_FAILED	An error occured while loading the new CI object
CI_E_DB_OVERFLOW	the object has been created but cannot be registered
			in the database
CI_E_MODELNOTFND	No model object found
CI_E_INVALIDARGS	Invalid arguments
CI_W_NO_SUCH_FUN	The object has been successfully loaded/cloned/retrieved
			but the entry point doesn't exist.
 EXAMPLES
 1/ to load an object as we used to before:
	load = LOAD_UNCOND
 2/ to load a command object:
	load = DUP
 3/ to get the id of an existing CI object or to load (and initialize) a new
    CI object if it doesn't exist yet:
	load = LOAD
 4/ to retrieve the id of an existing CI object:
	load = RETRIEVE
 5/ (10/20/88) to retrieve the id of an existing CI object when you guarantee
    the ".e" file hasn't changed in the meantime:
	load = RETRIEVE | NO_DATE


 The following flow-chart explains in details the impact of "load": 

 IF (load == LOAD_UNCOND)
    A new CI object is loaded unconditionally. Its object id is stored in the
      DataBase and assigned to *file_id.
 ELSE
    Look for a model object in the DataBase (i.e. a CI object that is running
     the current version of the PPL file).
    IF a model object has been found
	IF (load == RETRIEVE || load == LOAD)
	    *file_id <-- the model object id.
	    Return CI_S_SUCCESS
	ELSE		// DUP
	    The model object is cloned.
	    *file_id <-- the newly created object id.
	ENDIF
    ELSE		// No model found
	IF  (load == RETRIEVE)
	    Return CI_E_NOMODEL
	ELSE
	    Load a new CI object: O1.
	    *file_id <-- O1.
	    IF (load == DUP)
		O1 is stored in the DB.
		Clone O1 to built a new object O2.
		*file_id <-- O2.
	    ENDIF
	ENDIF
    ENDIF
 ENDIF
 IF (delete == 0)
    Store *file_id in the DataBase

 NOTES
   It is valuable here to make clear the meaning of the word "model". In the
 DataBase, an objid is associated with the last modification date of the
 ".e" file. For a given file name, a loaded object is a model if and only if:
  -1/ The source file doesn't exist OR doesn't need to be recompiled.
  -2/ The ".e" file exists AND is not newer than the date stored in the DB.
   Therefore a model object can be cloned to get a new CI object sharing the
 same intruction segment.
*/

/*******************            ci$exec           *****************************/
#omdef ci$exec(	file_name 	= CI_NULL,
		file_id		= &M_fileid,
		entry		= "main",
		load		= LOAD_UNCOND,
		run		= 1,
		delete		= 1,
		stackable 	= 1,
		retval		= CI_NULL,
		retsize		= 0,
		stat		= CI_NULL )

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "ci$exec: 'file_name' AND 'file_id' not specified"
#endif
	CIexec(	(file_name),
		(file_id),
		(entry),
		(load),
		(run),
		(delete),
		(stackable),
		(retval),
		(retsize),
		(stat) )
#endomdef


/*******************            ci$run            *****************************/
#omdef ci$run(	file_name 	= CI_NULL,
		file_id		= &M_fileid,
		entry		= "main",
		load		= NO_LOAD,
		delete		= 0,
		stackable 	= 1,
		retval		= CI_NULL,
		retsize		= 0,
		stat		= CI_NULL )

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "ci$run: 'file_name' AND 'file_id' not specified"
#endif

#if om$specified(file_name) && !om$specified(file_id) && !om$specified(load)
CIexec( (file_name),		/* file name */
	(file_id),		/* file id. */
	(entry),		/* entry */
	(LOAD),			/* load key */
	1,			/* run flag */
	(delete),		/* delete flag */
	(stackable),		/* stackable flag */
	(retval),
	(retsize),
	(stat) )
#else
CIexec( (file_name),		/* file name */
	(file_id),		/* file id. */
	(entry),		/* entry */
	(load),			/* load key */
	1,			/* run flag */
	(delete),		/* delete flag */
	(stackable),		/* stackable flag */
	(retval),
	(retsize),
	(stat) )
#endif

#endomdef


/*******************            ci$load           *****************************/
#omdef ci$load(	file_name	= CI_NULL,
		load		= LOAD_UNCOND,
		file_id		= &M_fileid,
		stat		= CI_NULL )

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "ci$load: 'file_name' AND 'file_id' not specified"
#endif

CIexec( (file_name),		/* file name */
	(file_id),		/* file id. */
	"main",			/* entry */
	(load),			/* load key */
	0,			/* run flag */
	0,			/* delete flag */
	1,			/* stackable flag */
	CI_NULL,		/* returned value */
	0,			/* size of returned value */
	(stat) )

#endomdef

/******************************************************************************/
/*******************            ci$delete         *****************************/
/*
 Deletes one or many CI objects with a DataBase update.
 ARGUMENTS:
 char	*filename:  I   Name of the file. Optional but increases system
			performance when specified.
 GRobj	fileid	 :  I	Object id of the CI object. Optional. If not specified,
 			all the CI objects running the corresponding PPL file
 			are deleted and the entry in the DataBase is removed. If
 			specified, only one object is deleted and the list is
			maintained.
 At least one argument must be specified.
*/
#omdef ci$delete(	file_name	= CI_NULL,
		 	file_id		= NULL_OBJID )

#if !om$specified(file_name) && !om$specified(file_id)
#	omerror "`file_name' AND/OR `file_id' not specified"
#endif

SCIdelete(	(file_name),	/* file name */
		(file_id) )	/* file id. */
#endomdef


/*******************            ci$inq_files        ***************************/
/*
   Inquires the CI super object to get the list of PPL files that it knows
   something about.
 ARGUMENTS
 int	*count		I/O	INPUT: max. # of elements to be returned (i.e.
				  the number of elements for which memory has
				  been allocated by the user).
				OUTPUT: # of returned elements in 'names' if the
				  initial value is not NULL, the total number
				  of elements otherwise.
 char	*names[]	O	The list of PPL files the CI super object knows
 				something about.

 RETURN CODE		( Return codes defined in cierrordef.h 0
CI_S_SUCCESS		OK
CI_E_INVALIDARGS	invalid arguments

 NOTE
   The pointers pointed to by 'names' are merely redirected. This avoids the
 'strcpy' function call and exempts the user from allocating more memory. BUT,
 users are invited not to mess up the internal DATA that may be accessed in
 this manner.
*/
#omdef ci$inq_files(	count,
			names	= CI_NULL )
SCIinq_files(	(count),
		(names) )
#endomdef


/*******************            ci$inq_objects       **************************/
/*
   Inquires the CI super object to get the list of CI objects loaded with a
 given PPL file.
 ARGUMENTS
 char	*file_name	I	The specified PPL file name.
 int	*count		I/O	INPUT: max. # of elements to be returned (i.e.
				  the number of elements for which memory has
				  been allocated by the user).
				OUTPUT: # of returned elts in 'objids' if the
				  initial value is not null, the total number
				  of elements otherwise.
 GRobj	*objids		O	The list of CI objects loaded with the specified
				  PPL file.

 RETURN CODE		( Return codes defined in cierrordef.h )
CI_S_SUCCESS		OK
CI_E_NO_SUCHFILE	Neither the source file, nor the compiled file exists
CI_E_INVALIDARGS	Invalid arguments
*/
#omdef ci$inq_objects(
		file_name,
		count,
		objids	= CI_NULL)
SCIinq_objects(	(file_name),
		(count),
		(objids) )
#endomdef


/******************************************************************************/
/* -- Macro to set a global variable of a loaded PPL file.
      ARGUMENTS:
 	IN  : name   : name of variable to set.
 	    : p_val  : pointer to value to assign.
	    : size   : size of variable to set.
	    : file   : object id of CI object loaded with the PPL file.
	OUT : stat   : pointer to completion code ( CI_NULL if not needed ).

   VALUES OF *stat:	( Return codes defined in cierrordef.h )
   
   		CI_S_SUCCESS	 : operation sucessfully completed.
   		CI_E_OBJCT_EMPTY : object not loaded with a PPL file.
   		CI_W_NO_SUCH_VAR : variable "name" not found.

   RETURNS : 1 if sucessful, an OM error code if failure ( OM error codes are
   	     defined in OMerrordef.h ).
   -- */
#omdef ci$set_value(	name		,
			p_val		,
			size	= -1	,
			file		,
			stat	= CI_NULL  )
#if om$equal( size, -1 )
  ci$send( msg		= message ci.set_value(	(stat),
  						(name),
						(char *) (p_val),
						sizeof( *(p_val) ) ),
  	   targetid	= (file),
  	   targetos	= my_os() )
#else
  ci$send( msg		= message ci.set_value(	(stat),
						(name),
  						(char *) (p_val),
  						(size) ),
  	   targetid	= (file),
  	   targetos	= my_os() )
#endif
#endomdef
			
/* -- Macro to get a global variable of a loaded PPL file.
      ARGUMENTS:
 	IN  : name   : name of variable of which the value is requested.
 	    : p_val  : pointer to buffer to store value.
	    : size   : size of variable to get.
	    : file   : object id of CI object loaded with the PPL file.
	OUT : stat   : pointer to completion code ( CI_NULL if not needed ).

   VALUES OF *stat:	( Return codes defined in cierrordef.h )

   		CI_S_SUCCESS	 : operation sucessfully completed.
   		CI_E_OBJCT_EMPTY : object not loaded with a PPL file.
   		CI_W_NO_SUCH_VAR : variable "name" not found.

   RETURNS : 1 if sucessful, an OM error code if failure ( OM error codes are
   	     defined in OMerrordef.h ).
   -- */
#omdef ci$get_value(	name		,
			p_val		,
			size	= -1	,
			file		,
			stat	= CI_NULL  )
#if om$equal( size, -1 )
  ci$send( msg		= message ci.get_value(	(stat),
  						(name),
  						(char *) (p_val),
  						sizeof( *(p_val) ) ),
  	   targetid	= (file),
  	   targetos	= my_os() )
#else
  ci$send( msg		= message ci.get_value(	(stat),
						(name),
  						(char *) (p_val),
  						(size) ),
  	   targetid	= (file),
  	   targetos	= my_os() )
#endif
#endomdef

/* -- Macro to execute a function of a PPL file loaded in a CI object.
   IN  : entry	: name of function to execute.
       : retsize: size of value returned by the function ( 0 if not needed )
   OUT : retval	: pointer to value returned by function ( NULL if not needed )
       : stat	: pointer to completion code.

   VALUES OF *stat:	( Return codes defined in cierrordef.h )

   		CI_S_SUCCESS	 : operation sucessfully completed.
   		CI_E_OBJCT_EMPTY : object not loaded with a file.
   		CI_W_NO_SUCH_FUN : entry point not found.
   		CI_E_FATAL_ERROR : OM error during transaction.

   RETURNS : 1 if sucessful, an OM error code if failure ( OM error codes are
   	     defined in OMerrordef.h ).

   NOTE: the function may not be interrupted by an event.
   -- */
#omdef ci$f_execute(	file 		,
			entry		,
			retval	= NULL	,
			retsize	= 0	,
			stat		)
  ci$send( msg		= message ci.f_execute( (stat),
						(entry),
						(retval),
						(retsize) ),
  	   targetid	= (file),
  	   targetos	= my_os() )
#endomdef

#omdef ci$exec_fun(	file 		,
			entry		,
			name 		,
			p_val		,
			retval	= NULL	,
			retsize	= 0	,
			size	= -1	,
			action		)
#if om$equal( size, -1 )
  ci$send( msg		= message ci.exec_fun(	(action),
						(entry)	,
						(name)	,
						(p_val)	,
						sizeof (*(p_val)),
						(retval),
						(retsize) ),
  	   targetid	= (file),
  	   targetos	= my_os() )
#else
  ci$send( msg		= message ci.exec_fun(	(action),
						(entry)	,
						(name)	,
						(p_val)	,
						(size)	,
						(retval),
						(retsize) ),
  	   targetid	= (file),
  	   targetos	= my_os() )
#endif
#endomdef

#endif

