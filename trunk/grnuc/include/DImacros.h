#ifndef DImacros
#define DImacros
/*
---------------------------------------------------------------------------

	Name:			DImacros.h
	Author:			Henry Bequet
	Creation Date:		August-23-1988
	Operating System(s):	Unix SYSV, v2

	Abstract:
        ---------
        	The following DIrectory 0.0 "primitives" are actually "macros"
	which are operated on by the OM pre-processor.  Their purpose,
 	usage, and format are described in more detail in the 
 	"DIrectory 0.0 User Writeup".

		Basically, this file contains macros of the form:

	#omdef di$<function_name> ( <parameters> ) 

      	   ... 
            	
	#endomdef
	
       
        Notes:
        ------

        
	--- Standard names ---
	This list has standard names to use for things
	like object space number (osnum). This will provide an 
    	assurance of a standard interface. It is not complete, and
	should be updated as new names appear in macros.

	class name			classname
	class id			classid
        pointer to classid              p_classid
        pointer to class list           p_classes
	os number			osnum
	os name				osname
	channel	address			chanaddr
	channel name			channame
	channel number			channum
        channel selector                chanselect
        pointer to channel selector     p_chanselect
	object id			objid
        object instance pointer         object
	cluster number			clusternum
	maximum size			maxsize
	extend size			extsize
	extend count			extcount
	maximum number of objects	maxobjs
	send depth			depth
	number				num
	data structure name		structure
	size				size
	pointer	(int *)			ptr

        directory name (char *)         dirname
        path name (char *)              pathname
        directory object id             dirid
        pointer to dirid                p_dirid
        object name (char *)            objname
        previous name (char *)          oldname
        new name (char *)               newname
        pointer to lines of results
                         (char ***)     lines
        flag for message sends          flag
        execution status (long *)       sts
        regular expression (char *)     regexp
        maximum level (int)             max_level
        options (char)                  options
        deep of search (int *)          deep
        result of ls (char [PATH_MAX])
                                        line
        index in list (ls & index)      index
        pointer to index (index)        p_index
        
        osnum + objid			grid
        pointer to grid                 p_grid
        list of grids			grids

        logical				logical name (object space)
        attach_os			attachment object space (ref. file)
        sleep				flag to send a sleep message
                                        to directories
	keep				is not NULL when the B-tree
					has not to be deleted during 
					a sleep
        path                            the search path
        

        Error Codes :
        -------------

        The following error codes are returned by the directory sub-system.
        They are defined in the DIdef.h file.


        Dependance :
        ------------

        This file depends on the following file :

                        DIdef.h
                        DItypedef.h
                        DIglob.h
          

	Revision History:               08/23/1988 - Creation Date
        -----------------               09/20/1988 - Add DIstm stuff
                                        09/21/1988 - Add attach_os in mount_ref

/*---------------------------------------------------------------------------*/
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"




/* This macro is used to locate an object by name.  The function must have
   the following arguments :


	    function ( arg, dirname, basename, grid, ctxt_grid )
		       DIchar *arg	 some arguments ...		IN
		       DIchar *dirname	 the directory name		IN
		       DIchar *basename  the name in the directory	IN
		       DIgrid grid 	 the GRid of the object		IN
		       DIgrid ctxt_grid	 the context of the object
					   (NULL_GRID if none)		IN

   The function will be called for each name that matches the regular
   expression.  The search in the directories will be aborted if the
   function doesn't return DIR_S_SUCCESS.

   return status :
                      DIR_S_SUCCESS        : successful operation
		      DIR_W_NAME_NOT_FOUND : no name matches the
					     regular expression
                      any status returned by the function.


      Argument description :
      --------------------

        DIchar *regexp		: the regular expression   		(IN)
        DIint  (*function) ()	: the function to be called   		(IN)
        DIchar *arg		: the first argument of the function 	(IN)

*/

#omdef di$locate ( regexp = NULL,
		   function,
		   arg    = NULL )
       DIlocate ( (regexp), (function), (arg) )
#endomdef

/*---------------------------------------------------------------------------*/
/* This macro is used to mount a reference file.  If the file is not mounted
with the logical name then di$mount will e called.  The context object will
be connected to the link.

   return status :
                      DIR_S_SUCCESS	: successful operation
                      DIR_E_DIR_DUP	: duplicated name (in mount)
                      DIR_E_OVFLOW  	: overflow error
		      DIR_E_ABORT	: directory error

      Argument description :
      --------------------

        DIspacenum attach_os	: the object space to attach the 
                                  reference file to			(IN)
        DIchar *logical		: the name of the reference file 	(IN)
        			  attachment.  Note that if a full
        			  path name is given, then attach_os
        			  is ignored.
        DIspacenum osnum	: osnum to be mounted			(IN)
        DIgrid context		: the context object to be connected	(IN)
        			  to the attachment
*/

#omdef di$mount_ref( attach_os = OM_Gw_current_OS,
                     logical, osnum, context )
       DImount_ref ( (attach_os), (logical), (osnum), (context) )
#endomdef

/*---------------------------------------------------------------------------*/
/* This macro is used to copy a name into another.  The macro checks for
   the name to have less than PATH_MAX characters. (see strcpy)
   One of the advantages of this macro is that it is independent of the
   character used to represent the root directory (usually ':')

   return status :
                      DIR_S_SUCCESS	: successful operation
                      DIR_E_OVFLOW  	: overflow error
		      DIR_E_ABORT	: directory error

      Argument description :
      --------------------

        DIchar *to	: the name to copy to				(OUT)
        DIchar *from	: the name to copy from				(IN)
*/

#omdef di$strcpy ( to, from )
       DIstrcpy ( to, from )
#endomdef

/*---------------------------------------------------------------------------*/
/* This macro is used to concatenate two names together.  The macro checks for
   the name to have less than PATH_MAX characters. (see strcat)
   One of the advantages of this macro is that it is independent of the
   character used to represent the root directory (usually ':')

   return status :
                      DIR_S_SUCCESS	: successful operation
                      DIR_E_OVFLOW  	: overflow error
		      DIR_E_ABORT	: directory error

      Argument description :
      --------------------

        DIchar *to	: the name to concatenate to			(OUT)
        DIchar *from	: the name to copy from				(IN)
*/

#omdef di$strcat ( to, from )
       DIstrcat ( to, from )
#endomdef

/*---------------------------------------------------------------------------*/


/*
 *  required by di$cvt_name_from_input() and di$cvt_name_for_output()
 */
extern IGRint    GR_G_dir_mode; 

/*

    di$cvt_name_from_input( u_path, s_path )

       synopsis:
          given a name ( in the form that the user perceives 
	  it ), this macro returns a full ( true ) directory 
	  path name as used in calls to the directory subsystem.
          This macro is most useful for converting a name
          entered by the user into the full name which can be
	  translated by the directory subsystem.
  
       arguments:
          *u_path   IGRchar    directory path name as the user  (IN )
			       perceives it
          *s_path   IGRchar    full (true) directory path name  (OUT)

       example:
          status = di$cvt_name_from_input( u_path = ":circles",
                                           s_path = sys_path );

          If the directory mode is USER, sys_path will return 
          containing the string ":<dgn>:usr:circles", where <dgn>
          is the name of the active design file.  If the mode is
          SYSTEM, sys_path will contain ":circles".
       
       returns:
          IGRint 
	     DIR_S_SUCCESS      : successful operation
             DIR_E_OVFLOW       : overflow error
             DIR_E_ABORT        : directory error

       notes:
          s_path should point to character string buffer of size
          PATH_MAX as defined in DIdef.h.

          s_path and u_path may be specified as the same argument;
	  in fact, if only u_path is specified, the result is placed
	  in this same parameter.  
	  For example, 

             di$cvt_name_from_input(u_path = my_path, s_path = my_path);
          
			   --- AND --- 

             di$cvt_name_from_input(u_path = my_path);

	  result in the same code being generated.  Of course the
	  original contents of my_path will be lost.

       caveats:
*/

#omdef di$cvt_name_from_input( u_path, s_path = NULL )
          
#if om$specified ( s_path )
	  CO_xlate_from_user_mode ( GR_G_dir_mode,
				    u_path,
				    s_path )
#else
	  CO_xlate_from_user_mode ( GR_G_dir_mode,
				    u_path,
				    u_path )
#endif
#endomdef


/* 

    di$cvt_name_for_output ( s_path, u_path )

       synopsis:
          given a full ( true ) directory path name, such as 
          :<dgn>:usr:circles:c1, where <dgn> is the name of 
          the active design file, this macro returns a name 
          as the user should see it.

          This macro is most useful for converting an element's
          name before displaying it to the user ( e.g. with
          ex$message ).

       arguments:
          *s_path   IGRchar    full (true) directory path name  (IN )
          *u_path   IGRchar    directory path name as the user  (OUT)
			       perceives it
  
       example:
          status = di$cvt_name_for_output(
                          s_path = ":<dgn>:usr:arcs",
                          u_path = user_path );

          If the directory mode is USER, then user_path will 
          return containing the string ":arcs".  If the mode
          is SYSTEM, user_path will contain ":<dgn>:usr:arcs".
       
       returns:
          IGRint 
	     DIR_S_SUCCESS      : successful operation
             DIR_E_OVFLOW       : overflow error
             DIR_E_ABORT        : directory error
             
       notes:
          u_path should point to character string buffer of size
          PATH_MAX as defined in DIdef.h.

          s_path and u_path may be specified as the same argument;
	  in fact, if only u_path is specified, the result is placed
	  in this same parameter.  
	  For example, 

             di$cvt_name_for_output( s_path = my_path,
				     u_path = my_path );
          
			     --- AND --- 

             di$cvt_name_for_output( s_path = my_path );

	  result in the same code being generated.  Of course the
	  original contents of my_path will be lost.

       caveats:

*/

#omdef di$cvt_name_for_output ( s_path, u_path = NULL )

#if om$specified ( u_path )
	  CO_xlate_to_user_mode ( GR_G_dir_mode,
				  s_path,
				  u_path )
#else
	  CO_xlate_to_user_mode ( GR_G_dir_mode,
				  s_path,
				  s_path )
#endif
#endomdef


/* 
    di$update_dir_form()

       synopsis:
          Updates the directory command form if displayed.

       arguments: none
  
       example:
          status = di$update_dir_form();

       returns:
          IGRint 
	     DIR_S_SUCCESS      : successful operation
             
       notes:
          It does not matter wheather or not the directory command
	  form is displayed or not.  It always succeeds.

       caveats:

*/
#omdef 	di$update_dir_form()
  DIupdate_form()
#endomdef

/*
   This function performs a DIstrcpy with a variable number of arguments.
The minimum number of arguments is 3 (same behaviour as DIstrcpy).  Note
that this primitive offers the advantage of beeing independent of the
character used to represent root.

      Return status :
      -------------
                      DIR_S_SUCCESS : successful operation
                      DIR_E_OVFLOW  : overflow in name

      Argument description :
      --------------------

        DIchar s0 [PATH_MAX] 	: The target string	   		(OUT)
        DIchar *s1		: The first string to copy   		(IN)
        DIchar *s2		: The second string to copy   		(IN)
        ...
	NULL			: Termination of the list		(IN)

      Example :  {
      -------      DIint status;
                   DIchar s1 [PATH_MAX];

                   status = DIstmcpy ( s1, "first", "second", "third", 0 );
                   /* s1 should be "first:second:third" );
                 }

      Caveats and Bugs : Unpredictable results will occur if you omit the
      ----------------   NULL at the end of the list. (Some "extra"
                         arguments may be picked up)
*/

extern DIint DIstmcpy ();

/*------------------------------------------------------------------------*/

/*
   This function performs a DIstrcat with a variable number of arguments.
The minimum number of arguments is 3 (same behaviour as DIstrcat).  Note
that this primitive offers the advantage of beeing independent of the
character used to represent root.

      Return status :
      -------------
                      DIR_S_SUCCESS : successful operation
                      DIR_E_OVFLOW  : overflow in name

      Argument description :
      --------------------

        DIchar s0 [PATH_MAX] 	: The target string	   		(IN/OUT)
        DIchar *s1		: The first string to copy   		(IN)
        DIchar *s2		: The second string to copy   		(IN)
        ...
	NULL			: Termination of the list		(IN)

      Example :  {
      -------      DIint status;
                   DIchar s1 [PATH_MAX];
            
                   strcpy ( s1, "first" );
                   status = DIstmcat ( s1, "second", "third", 0 );
                   /* s1 should be "first:second:third" );
                 }

      Caveats and Bugs : Unpredictable results will occur if you omit the
      ----------------   NULL at the end of the list. (Some "extra"
                         arguments may be picked up)
*/

extern DIint DIstmcat ();

/*------------------------------------------------------------------------*/

/*
   This function performs a DIstrcpy with a variable number of arguments.
Note that this primitive offers the advantage of beeing independent of the
character used to represent root.  The pathname to the specified object
space is added at the beginning of the target string. The minimum number
of arguments is 4.

      Return status :
      -------------
                      DIR_S_SUCCESS : successful operation
                      DIR_E_INVARG  : invalid object space
                      DIR_E_OVFLOW  : overflow in name

      Argument description :
      --------------------

        DIchar s0 [PATH_MAX] 	: The target string	   		(OUT)
        DIchar *s1		: The first string to copy   		(IN)
        DIchar *s2		: The second string to copy   		(IN)
        ...
	NULL			: Termination of the list of strings	(IN)
        DIspacenum osnum	: The object space number		(IN)

      Example :  {
      -------      DIint status;
                   DIchar s1 [PATH_MAX];
            
                   status = DIstmocpy ( s1, "first", "second", "third", 0, 1 );
                   /* s1 should be ":transient:first:second:third" );
                 }

      Caveats and Bugs : Unpredictable results will occur if you omit the
      ----------------   NULL at the end of the list. (Some "extra"
                         arguments may be picked up)
*/

extern DIint DIstmocpy ();

/*--------------------------------------------------------------------------*/

#endif
