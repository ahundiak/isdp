#ifndef DIprims
#define DIprims
/*
---------------------------------------------------------------------------

	Name:			DIprims.h
	Author:			Henry Bequet
	Creation Date:		March-19-1987
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
        result of ls (char [DI_PATH_MAX])
                                        line
        index in list (ls & index)      index
        pointer to index (index)        p_index
        
        osnum + objid			grid
        pointer to grid                 p_grid
        list of grids			grids

        logical				logical name (object space)
        sleep				flag to send a sleep message
                                        to directories
	keep				is not NULL when the B-tree
					has not to be deleted during 
					a sleep
        path                            the search path
        synpath	(int)                   flag that determines if synonyms
				         are considered in linear search 
				         path specifications.
        

        Error Codes :
        -------------

        The following error codes are returned by the directory sub-system.
        They are defined in the DIdef.h file.


        Dependance :
        ------------

        This file depends on the following file :

                        DItypedef.h
                        DIdef.h
                        DIglob.h
                                  

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#include <stdio.h>
#ifdef NT
#include <malloc.h>
#endif

extern int DIBinit __(());
extern int DIadd_grid __((DIgrid **grid, DIint count, DIgrid info));
extern int DIadd_grid_line __((DIchar ***lines, DIgrid **grids,
		DIchar *full_path, DIgrid grid, DIint count));
extern int DIadd_index __((DIchar *dirname, DIchar *path, DIint synpath,
		DIint *p_index, DIobjid objid, DIspacenum *p_osnum));
extern int DIadd_line __((DIchar ***lines, DIint count, DIchar *info));
extern int DIadd_pwd __((DIchar *base));
extern int DIancestry_valid __((DIspacenum osnum, DIobjid objid,
                DIclassid class_id));
extern int DIback_su __((DIchar *group));
extern int DIboot __(());
extern void DIbuild_mod __(());
extern int DIcd __((DIchar *dirname1, DIspacenum osnum, DIobjid *p_dirid,
		DIspacenum *p_osnum, DIchar *path, DIint synpath));
extern DIint DIcheck_class __((OM_p_CLASSLIST class_list, DIspacenum osnum,
                DIobjid objid));
extern int DIchstr __((DIchar *string, DIchar *old, DIchar *new));
extern int DIclean __((DIchar *string));
extern DIobjid DIconstruct __((DIchar *classname, DIspacenum osnum));
extern int DIcreate_dir __((DIchar *classname, DIchar fullname[],
		DIchar basename[], DIgrid parent, DIgrid *dir));
extern int DIcreate_untree __((DIspacenum os ));
extern int DIdbg_cd __((char *dirname));
extern int DIdbg_cg __((char *groupname));
extern int DIdbg_dump __((char *reg_exp));
extern int DIdbg_find __((char *reg_exp));
extern int DIdbg_link __((char *objname));
extern int DIdbg_ls __((char *reg_exp));
extern int DIdbg_mkdir __((char *dirname));
extern int DIdbg_mkgroup __((char *groupname));
extern int DIdbg_pwd __(());
extern int DIdbg_pwg __(());
extern int DIdbg_rename __((char *objname));
extern int DIdbg_rm __((char *objname));
extern int DIdbg_rmdir __((char *dirname));
extern int DIdbg_trans __((char *objname));
extern int DIdelete_untree __((DIspacenum os));
extern int DIexec_config __((FILE *fet));
extern int DIexpand __((DIchar *str));
extern int DIexpanse __((DIchar *dir_name1, DIchar *dir_name2));
extern int DIfast_trans __((DIchar *name, DIobjid *p_objid,
		DIspacenum *p_osnum));
extern int DIfetch_dump __((DIchar line[DI_PATH_MAX ], DIgrid *p_grid,
		DIint index));
extern int DIfetch_find __((DIchar *line, DIgrid *grid, DIint index));
extern int DIfetch_untrans __((DIchar objname[DI_PATH_MAX ], DIint *p_index,
		DIint index));
extern int DIfind __((DIchar *start_dir, DIchar *reg_exp, DIchar ***lines,
		DIgrid **grids, DIint *count, DIint max_level, DIint *deep,
		DIchar options));
extern int DIfind_dir __((DIchar *dirname, DIspacenum *p_osnum,
		DIobjid *p_objid, DIchar *name, DIchar *path));
extern void DIfind_root __((DIspacenum osnum, DIobjid *p_objid));
extern void DIfrees __((DIchar **arg_list, DIint arg_num));
extern int DIfrtcat __((DIchar *name1, DIchar *name2));
extern int DIget_choice __((DIchar *line));
extern int DIget_level __((DIchar *path_name));
extern int DIget_trailer __((DIchar *obj_name, DIchar *trailer));
extern int DIget_trailer_with_id __((DIspacenum osnum, DIobjid objid,
                DIchar *trailer));
extern int DIgive_osnum __((DIchar *pathname, DIspacenum *p_osnum));
extern int DIgive_pathname __((DIspacenum osnum, DIchar *pathname));
extern int DIindex __((DIchar *dirname, DIchar *path, DIint synpath,
		DIint index, DIchar *name, DIspacenum *p_osnum,
		DIobjid *p_objid));
extern int DIinit __((DIchar sep, DIchar current, DIchar home, DIchar back));
extern int DIInvestigatePath __((DIchar *path, DIgrid grid, DIchar *current_path,
                DIchar ***lines, DIgrid **grids, DIint *count));
extern int DIis_regexp __((DIchar *string));
extern int DIlink2 __((DIchar *obj_name1, DIchar *path, DIint synpath,
		DIspacenum osnum1, DIobjid objid1, DIchar *new_name));
extern int DIlink_down __((DIchar *old_name, DIspacenum osnum, DIobjid objid,
		DIchar *new_name, DIint add));
extern int DIload __((DIchar *file_name, DIspacenum *p_osnum,
                DIobjid *p_objid, DIchar *logical_name));
extern int DIls_driver __((DIchar type, DIchar *p_id, DIchar *name));
extern int DImain __((DIchar *path, DIint synpath, OM_p_CLASSLIST classes,
		DIint (*basic )(), DIint number, DIchar *name, DIspacenum osnum,
		DIobjid objid, DIchar *new_name, DIobjid *p_objid,
		DIspacenum *p_osnum, DIchar ***lines, DIgrid **grids,
		DIint *ptr, DIchar options, DIchar translate,
		DIspacenum targetos));
extern int DImasterDump __((DIint *status, DIchar *reg_exp, OM_p_CLASSLIST
                classlist, DIchar ***lines, DIgrid **grids, DIint *count,
                DIchar options));
extern int DImasterRetrieve __((DIint *status, DIchar *key, DIint index,
                DIchar *info, DIchar *name, DIint *p_index));
extern int DImkpath __((DIobjid objid, DIchar *pathname, DIspacenum *p_osnum));
extern int DImount __((DIchar *name, DIspacenum osnum, DIchar *classname));
extern int DImove_names __((DIchar *old_name, DIobjid old_objid,
		DIchar *new_name, DIobjid new_objid));
extern int DImulti_parse __((char *line, char ***buffers, int *count));
extern int DImulti_step __((char *key, char **buffers, int count));
extern int DInew_trailer __((DIchar *line));
extern int DIparse_dir __((DIchar *dir_name, DIchar ***arg, DIint *arg_num));
extern int DIpass __((OM_E_WRT_FLAG flag, OM_p_MESSAGE msg, DIchar *regexp,
		OM_p_CLASSLIST classes));
extern int DIpwd __((DIchar *dirname, DIobjid *p_dirid, DIspacenum *p_osnum));
extern int DIquick_delete_untree __((DIspacenum os));
extern char DIread_line __((FILE *fet, DIchar *line));
extern int DIreport_error __((DIint status, DIchar *comment, DIchar *out_s));
extern int DIrm_index __((DIchar *dirname, DIchar *path, DIint synpath,
		DIint index));
extern int DIrm_objid __((DIobjid objid, DIspacenum osnum));
extern int DIsend __((DIchar *path, DIint synpath, OM_E_WRT_FLAG mode,
		DIobjid senderid, DIspacenum targetos, DIchar *targetname,
		OM_p_MESSAGE msg));
extern int DIsplit __((DIchar *pathname, DIchar *dirname, DIchar *name));
extern int DIstart_dump __((DIchar ls, OM_p_CLASSLIST classes,
		DIchar *reg_exp, DIint *count, DIchar options));
extern int DIstart_find __((DIchar *start, DIchar *reg, DIint *ptr, DIint max,
		DIint *deep, DIchar options));
extern int DIstrcat __((DIchar *name1, DIchar *name2));
extern int DIstrcmp __((DIchar *name1, DIchar *name2));
extern int DIstrcpy __((DIchar *name1, DIchar *name2));
extern int DIsu __((DIchar *group));
extern int DIterminator __((DIchar *string));
extern int DIumount __((DIchar *dirname1, DIint sleep, DIint keep));
extern int DIunall __((DIspacenum os, DIobjid objid, DIchar *dirname,
                DIchar *objname, DIint delete, DIunode *p_unode, DIint *del));
extern int DIundebug __((DIspacenum os));
extern int DIunindex __((DIchar *dirname, DIchar *path, DIint synpath,
		DIint *p_index, DIchar *name, DIobjid objid));
extern int DIuntranslate __((DIchar *objname, DIint *p_index, DIint index,
		DIint *count, DIobjid objid, DIspacenum osnum, DIchar *path));

#if defined(__cplusplus)
}
#endif

#undef __
/*---------------------------------------------------------------------------*/


/* This macro is used to display an error message corresponding to
   the specified status.

   return status :
                      DIR_S_SUCCESS : successful operation

      Argument description :
      --------------------

        DIint  sts       : the status					(IN)
        DIchar *comment  : a comment to be printed with   		(IN)
                           the error message
        DIchar *string   : a string to put the result in; if the string	(OUT)
                           is specified, then no output is written to
                           stderr;
*/

#omdef di$report_error ( sts, comment = NULL, string = NULL )
       DIreport_error ( (sts), (comment), (string) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to add a name in the directory sub-system 

   return status :
                      DIR_S_SUCCESS 	   : successful operation
                      DIR_W_NAME_NOT_FOUND : (directory) name NOT found
                      DIR_E_NAME_DUP	   : name duplicated
                      DIR_E_OVFLOW  	   : overflow error
                      DIR_E_SYNTAX  	   : syntax error
                      DIR_E_ABORT   	   : directory error

      Argument description :
      --------------------

        DIchar *objname         : the name of the object       		(IN)
        
        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.

        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

        DIspacenum osnum	: the osnum (a path name to the os	(IN)
                                  will be added to objname if not
                                  a full path name)

        DIobjid objid           : the objid to be added         	(IN)
        
        DIspacenum *p_osnum	: the object space number       	(OUT)
                                   of the directory where the
                                   object will be added
*/

#omdef di$add_name ( objname, 
                     path    = NULL,
		     synpath = 0,
		     osnum   = 0,
                     objid,
                     p_osnum = NULL )
#if defined(__STDC__)
       DImain ( (path), (synpath ), NULL, (DIint(*)())DIadd_name, -1, (objname), 0,
#else
       DImain ( (path), (synpath ), NULL, DIadd_name, -1, (objname), 0,
#endif
		(objid), NULL, NULL, (p_osnum), NULL, NULL, NULL, OPT_ALL,
		0, (osnum) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to link two names in the directory sub-system 

   return status :
                      DIR_S_SUCCESS : successful operation
                      DIR_E_NAME_DUP: name duplicated
                      DIR_E_OVFLOW  : overflow error
                      DIR_E_SYNTAX  : syntax error
                      DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *objname         : the name of the object       		(IN)

        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.
 
        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

        DIobjid objid           : the objid of the object         	(IN)

        DIspacenum osnum	: the object space number       	(IN)

        DIchar *newname         : the name of the link			(IN)
*/

#omdef di$link ( objname = NULL, 
                 path    = NULL,
		 synpath = 0,
                 osnum   = OM_Gw_current_OS,
                 objid   = NULL_OBJID,
                 newname )
       DIlink2 ( (objname), (path), (synpath), (osnum), (objid), (newname) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to translate a dirname + name + index 
   from the directory sub-system (-> (osnum, objid))

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : (directory) name NOT found
                   DIR_W_NO_NAME        : the object is in the directory
                                          but has no name (this value is
                                          returned when name is specified)
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_SYNTAX         : syntax error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *dirname         : the name of the directory		(IN)

        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.
                                  
        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

        DIint index		: the index of the object in the	(IN)
                                  directory
                                  
        DIchar *name		: the object name			(OUT)

        DIobjid *p_objid        : the objid associated with     	(OUT)
			 	  the name + index
			 	  
        DIspacenum *p_osnum	: the object space number of    	(OUT)
                                  the object + index
*/


#omdef di$index ( dirname = NULL,
                  path    = NULL,
		  synpath = 0,
                  index,
                  name    = NULL,
                  p_objid = NULL,
                  p_osnum = NULL )
       DIindex ( (dirname), (path), (synpath), (index), (name), 
		 (p_osnum), (p_objid) )
#endomdef

/*---------------------------------------------------------------------------*/

/* This macro is used to add an entry (by index) to a directory.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_SYNTAX         : syntax error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *dirname         : the name of the directory		(IN)

        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.
                                  
        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

        DIint *p_index		: the index of the object in the	(OUT)
                                  directory
                                  
        DIobjid *p_objid        : the objid associated with     	(OUT)
			 	  the name + index
			 	  
        DIspacenum *p_osnum	: the object space number of    	(OUT)
                                  the object + index
*/

#omdef di$add_index ( dirname = NULL,
                      path    = NULL,
		      synpath = 0,
                      p_index = NULL,
                      objid,
                      p_osnum = NULL )
       DIadd_index ( (dirname), (path), (synpath), (p_index), (objid),
		     (p_osnum) )
#endomdef

/*---------------------------------------------------------------------------*/

/* This macro is used to remove an entry from a directory using an index.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_SYNTAX         : syntax error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *dirname         : the name of the directory		(IN)

        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.
                                  
        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

        DIint index		: the index of the object in the	(IN)
                                  directory
*/

#omdef di$rm_index ( dirname = NULL,
                     path    = NULL,
		     synpath = 0,
                     index )
       DIrm_index ( (dirname), (path), (synpath), (index) )
#endomdef

/*---------------------------------------------------------------------------*/


/* This macro is used to translate a dirname + a name (or objid) into an index.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_SYNTAX         : syntax error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *dirname         : the name of the directory		(IN)

        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.
                                  
        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

        DIint *p_index		: pointer to the index of the object 	(OUT)
                                  in the directory
                                  
        DIchar *name		: the object name			(IN)

        DIobjid objid		: the object identifier			(IN)
*/

#omdef di$unindex ( dirname = NULL,
                    path    = NULL,
		    synpath = 0,
                    p_index,
                    name    = NULL,
                    objid   = NULL_OBJID )
       DIunindex ( (dirname), (path), (synpath), (p_index), (name), (objid) )
#endomdef

/*---------------------------------------------------------------------------*/


/* This macro is used to translate a name from the directory sub-system

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_SYNTAX         : syntax error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *objname         : the name of the object 		(IN)

        DIspacenum osnum        : the osnum (a path name to the os	(IN)
                                  will be added to objname if not
                                  a full path name)

        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.

        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

        DIobjid *p_objid        : the objid associated with     	(OUT)
			 	  the name
			 	  
        DIspacenum *p_osnum	: the object space number of    	(OUT)
                                  the object
*/

#omdef di$translate ( objname ^ regexp,
		      osnum   = 0,
                      path    = NULL,
		      synpath = 0,
                      p_objid,
                      p_osnum = NULL )

#if om$specified(path)  || om$specified(regexp) || om$specified(osnum) || om$specified(synpath)

#if om$specified(regexp)
#if defined(__STDC__)
     DImain ( (path), (synpath), NULL, (DIint(*)())DItranslate, 1,
#else
     DImain ( (path), (synpath), NULL, DItranslate, 1,
#endif
	      (regexp), 0, NULL_OBJID,
	      NULL, (p_objid), (p_osnum), NULL,
	      NULL, NULL, OPT_ALL, 1, (osnum) )
#else
#if defined(__STDC__)
     DImain ( (path), (synpath), NULL, (DIint(*)())DItranslate, 1,
#else
     DImain ( (path), (synpath), NULL, DItranslate, 1,
#endif
	      (objname), 0, NULL_OBJID,
	      NULL, (p_objid), (p_osnum), NULL,
	      NULL, NULL, OPT_ALL, 1, (osnum) )
#endif
#else
    DIfast_trans ( (objname), (p_objid), (p_osnum) )
#endif

#endomdef

/*---------------------------------------------------------------------------*/


/* This macro is used to untranslate a name from the directory sub-system.
   Untranslates means : knowing the osnum and the objid, finding the name.
   Since synonyms (more than one name for one object) are supported, the
   untranslate macro supports an index and a counter.  The counter gives
   the number of synonyms and the index specifies the index (starting at
   0) of the name that is returned in objname.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_W_NO_NAME        : the object is in the directory
                                          but has no name (objname contains
                                          the directory name)
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_INVARG  	: the specified object does not exist
                                          (bad osnum and/or bad objid )
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *objname        : the name of the object (this		(OUT)
			         array must contain at least
			         DI_PATH_MAX characters).

        DIobjid objid          : the objid associated with		(IN)
			 	 the name.
				 
        DIspacenum osnum       : the object space number of the 	(IN)
				 object.

        DIint index	       : the index of the name in the		(IN)
                                 synonym list.

        DIint p_index	       : the index of the name in the		(OUT)
                                 directory.

        DIint *ptr	       : the number of synonyms			(OUT)

	DIchar *path           : the path specification to limit        (IN)
				 the results of the untranslate
*/

#omdef di$untranslate ( objname = NULL,
                        p_index = NULL,
                        index   = 0,
                        ptr     = NULL,
			path    = NULL,
                        objid,
                        osnum = OM_Gw_current_OS )
       DIuntranslate ( (objname), (p_index), (index),
                       (ptr), (objid), (osnum), (path) )
#endomdef


/*---------------------------------------------------------------------------*/

/* This macro is used to untranslate a name from the directory sub-system.
   Untranslates means : knowing the osnum and the objid, finding the name.
   This macro doesn't return the result.  The object name (full pathname)
   is returned by di$fetch_untrans.  This macro is suitable to deal with
   synonyms.  The counter gives the number of synonyms.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_INVARG  	: the specified object does not exist
                                          (bad osnum and/or bad objid )
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIobjid objid          : the objid associated with		(IN)
			 	 the name.
				 
        DIspacenum osnum       : the object space number of the 	(IN)
				 object.

        DIint index	       : the index of the name in the		(IN)
                                 synonym list.

        DIint *ptr	       : the number of synonyms			(OUT)

	DIchar *path           : the path specification to limit        (IN)
				 the results of the untranslate
*/

#omdef di$start_untrans ( ptr   = NULL,
                          objid,
			  path  = NULL,
                          osnum = OM_Gw_current_OS )
       DIuntranslate ( NULL, NULL, 0, (ptr), (objid), (osnum), (path) )
#endomdef

/*---------------------------------------------------------------------------*/

/* This macro is used to get the result of a di$start_untrans.
   The index specifies the index (starting at 0) of the name that is
   returned in objname.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_W_NO_NAME        : the object is in the directory
                                          but has no name (objname contains
                                          the directory name)
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *objname        : the name of the object (this		(OUT)
			         array must contain at least
			         DI_PATH_MAX characters).

        DIint index	       : the index of the name in the		(IN)
                                 synonym list.

        DIint *p_index         : the index of the object in the		(OUT)
                                 directory.
*/

#omdef di$fetch_untrans ( objname,
                          p_index = NULL,
                          index   = 0 )
       DIfetch_untrans ( (objname), (p_index), (index) )
#endomdef


/*---------------------------------------------------------------------------*/

/* This macro is used to remove a name from the directory sub-system.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_E_SYNTAX         : syntax error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *regexp          : the name (regular expression)  	(IN)
                                  to be removed
                                  
        DIint number		: maximum number of names to be		(IN)
                                  removed

        DIchar *path		: the search path;  it is not		(IN)
                                  taken into account if an
                                  absolute name is given.

        DIint   synpath		: flag; if non-zero synonyms are 	(IN)
                                  considered in linear search path 
				  specifications.

*/

#omdef di$rm_name ( regexp,
                    number  = 1,
                    path    = NULL, 
                    synpath = 0,
                    osnum   = 0 )
#if defined(__STDC__)
       DImain ( (path), (synpath), NULL, (DIint(*)())DIrename, (number),
#else
       DImain ( (path), (synpath), NULL, DIrename, (number),
#endif
		(regexp), 0, 
		NULL_OBJID, NULL, NULL, NULL, NULL, NULL, NULL,
		OPT_ALL, 1, (osnum) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to remove an entry from the directory sub-system.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIobjid objid           : the objid to be removed       	(IN)

        DIspacenum osnum        : the object space number       	(IN)
                                  of the object
*/

#omdef di$rm_objid ( objid, osnum = OM_Gw_current_OS )
       DIrm_objid ( (objid), (osnum) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro renames a previously named object.

   return status :
                   DIR_S_SUCCESS        : successful operation
                   DIR_W_NAME_NOT_FOUND : name NOT found (oldname)
                   DIR_E_NAME_DUP       : name duplicated (newname)
                   DIR_E_OVFLOW         : overflow error
                   DIR_E_SYNTAX         : syntax error
                   DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar *oldname       : the name to be changed			(IN)

        DIspacenum osnum      : the osnum (a path name to the os	(IN)
                                will be added to oldname and newname
                                if not a full path name)

        DIchar *path	      : the search path;  it is not		(IN)
                                taken into account if an
                                absolute name is given.

        DIint   synpath	      : flag; if non-zero synonyms are 		(IN)
                                considered in linear search path 
				specifications.

        DIchar *newname       : the new name				(IN)
*/

#omdef di$rename ( oldname,
		   osnum   = 0,
                   path    = NULL,
		   synpath = 0,
                   newname = NULL )
#if defined(__STDC__)
       DImain ( (path), (synpath), NULL, (DIint(*)())DIrename, 1, (oldname), 0, 
#else
       DImain ( (path), (synpath), NULL, DIrename, 1, (oldname), 0, 
#endif
		NULL_OBJID, (newname), NULL, NULL, NULL, NULL, NULL,
		OPT_ALL, 1, (osnum) )
#endomdef
 

/*---------------------------------------------------------------------------*/


/*
   The following commands have functionalities quite close to the UNIX commands
*/


/* This macro returns the current directory.  The name is retruned in 
   dirname, the objid in p_dirid and the osnum in p_osnum.  Note that
   each argument may be NULL if no value has to be returned.

   return status :
                   DIR_S_SUCCESS : successful operation
                   DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *dirname      : the name of the current			(OUT)
		               directory

        DIobjid *p_dirid     : the current directory objid		(OUT)
        
        DIspacenum *p_osnum  : the current directory object		(OUT)
                               space number
*/ 

#omdef di$pwd ( p_dirid = NULL,
                p_osnum = NULL,
                dirname = NULL )
       DIpwd ( (dirname), (p_dirid), (p_osnum) )

#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to change the current directory.  It may
   return the osnum and objid of the new current directory.

   return status :
                   DIR_S_SUCCESS : successful operation
                   DIR_E_SYNTAX  : syntax error
                   DIR_E_OVFLOW  : overflow error
                   DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *dirname      : the name of the directory to be  	(IN)
		               the current one
		               
        DIspacenum osnum     : the object space number			(IN)

        DIchar *path	     : the search path;  it is not		(IN)
                               taken into account if an
                               absolute name is given.

        DIint  synpath	     : flag; if non-zero synonyms are 		(IN)
                               considered in linear search path 
			       specifications.

        DIobjid *p_dirid     : the new current directory objid		(OUT)
        
        DIspacenum *p_osnum  : the object space number of the   	(OUT)
                               new current directory
*/

#omdef di$cd ( dirname,
               osnum   = 0,
               path    = NULL,
	       synpath = 0,
               p_dirid = NULL,
               p_osnum = NULL )
       DIcd ( (dirname), (osnum), (p_dirid), (p_osnum), (path), (synpath) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to create a new directory.

   return status :
                   DIR_S_SUCCESS   : successful operation
                   DIR_E_DIR_DUP   : directory name duplicated
                   DIR_E_SYNTAX    : syntax error
                   DIR_E_OVFLOW    : overflow error
                   DIR_E_ABORT     : directory error

      Argument description :
      --------------------

        DIchar *dirname      : the name of the directory 		(IN)
			       to be created
			       
        DIspacenum osnum     : the osnum (a path name to the os	        (IN)
                               will be added to dirname if not a
                               full path name)

        DIchar *classname    : the name of the class to be created	(IN)

        DIobjid *p_dirid     : the created directory objid		(OUT)
        
        DIspacenum *p_osnum  : the object space number of the   	(OUT)
                               created directory
*/

#omdef di$mkdir ( dirname,
		  osnum     = 0,
                  p_dirid   = NULL,
                  p_osnum   = NULL,
                  classname = NULL )
#if defined(__STDC__)
       DImain ( NULL, 0, NULL, (DIint(*)())DImkdir, -1, (dirname), 0,
#else
       DImain ( NULL, 0, NULL, DImkdir, -1, (dirname), 0,
#endif
		NULL_OBJID, (classname),
                (p_dirid), (p_osnum), NULL, NULL, NULL, OPT_ALL, 1, (osnum) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro removes an existing directory.

   return status :
                   DIR_S_SUCCESS   : successful operation
                   DIR_E_SYNTAX    : syntax error
                   DIR_E_OVFLOW    : overflow error
                   DIR_E_ABORT     : directory error

      Argument description :
      --------------------

        DIchar *dirname     : the name of the directory to be		(IN)
			      deleted

        DIspacenum osnum    : the osnum (a path name to the os	        (IN)
                              will be added to dirname if not a
                              full path name)

        DIchar *path	    : the search path;  it is not		(IN)
                              taken into account if an
                              absolute name is given.

        DIint  synpath      : flag that determines if synonyms		(IN)
		              are considered in linear search 
			      path specifications.

*/

#omdef di$rmdir ( dirname,
		  osnum = 0,
                  path  = NULL,
		  synpath = 0 )
#if defined(__STDC__)
       DImain ( (path), (synpath), NULL, (DIint(*)())DIrmdir, -1, (dirname), 0, 
#else
       DImain ( (path), (synpath), NULL, DIrmdir, -1, (dirname), 0, 
#endif
		NULL_OBJID, NULL, NULL, NULL, NULL, NULL, NULL, OPT_ALL, 
		1, (osnum) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to send a message to all the objects that match
   the regular expression.

   return status :
                   DIR_S_SUCCESS   : successful operation
                   DIR_E_OVFLOW    : overflow error
                   DIR_E_ABORT     : directory error

      Argument description :
      --------------------

        DIchar *regexp           : if specified, only the names		(IN)
				   that match this regular
				   expression are given.

        OM_p_MESSAGE msg         : the message to be sent		(IN)

        OM_E_WRT_FLAG flag       : the mode to be used to send		(IN)
				   the message

        OM_p_CLASSLIST p_classes : a list of class ids to            	(IN)
                                   restrict the choice.
*/

#omdef di$pass ( flag = OM_e_wrt_object,
                 msg,
                 regexp = "*",
                 p_classes = NULL )
       DIpass ( (flag), (msg), (regexp), (p_classes) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to split a full pathname into the dirname and the
    name within the directory.

    return status :
                   DIR_S_SUCCESS   : successful operation

      Argument description :
      --------------------

        DIchar *pathname   : the pathname to be split			(IN)
      
        DIchar *dirname    : the directory name				(OUT)
      
        DIchar *name       : the object name				(OUT)
*/

#omdef di$split ( pathname,
                  dirname = NULL,
                  name = NULL )
       DIsplit ( (pathname), (dirname), (name) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to test if string is regular expression that can
    match more than one name.

    return status :
                    DIR_S_SUCCESS   : the argument is a regular expression
                                      that can match more than one name
                    NULL            : the argument is not a regular expression

      Argument description :
      --------------------

         DIchar *regexp : the name to be checked			(IN)
*/

#omdef di$is_regexp ( regexp )
       DIis_regexp ( (regexp) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to find the names that match the regular expression.
    If lines is specified (DIchar ***), it is filled out with the results.

        o  options may be OPT_TRAILER, OPT_LEVEL, OPT_TRAILER | OPT_LEVEL
           or NULL.
        o  deep returns the maximum layer number 
        o  max_level may be used to restrict the deep of the search (-1 means
           no restriction)

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *start_dir       : the directory where the 		(IN)
				  find should start. A regular expres-
                                  sion may be specified.

        DIchar *regexp          : only the names that match this 	(IN)
				  regular expression are given.

        DIchar ***lines         : if specified, the entries are 	(OUT)
		                  listed in this array
			          
        DIgrid **grids          : the grids of the listed entries	(OUT)

        DIint *ptr              : the number of listed entry;		(OUT)

        DIint  max_level        : the maximum level of search 		(IN)
				  (< 0 means no limit)

        DIint  *deep            : the effective deep of the 		(OUT)
				  search (<= max_level)

        DIchar options          : two options are valid,		(IN)
                                       o OPT_LEVEL   : the display is indented
                                                       to reflect the directory
                                                       structure

                                       o OPT_TRAILER : the names are displayed
                                                       with a trailer depending
                                                       upon the class
*/

#omdef di$find ( start_dir = ".", 
                 regexp = "*",
                 lines = NULL,
                 grids = NULL,
                 ptr, 
                 max_level = -1,
                 deep = NULL,
                 options = OPT_TRAILER )
       DIfind ( (start_dir), (regexp), (lines), (grids), (ptr), 
                (max_level), (deep), (char) (options) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to find for names that match the regular expression.
   The result may be retrieved using the di$fetch_find macro.

        o  options may be OPT_TRAILER, OPT_LEVEL, OPT_TRAILER | OPT_LEVEL
           or NULL.
        o  deep returns the maximum layer number 
        o  max_level may be used to restrict the deep of the search (-1 means
           no restriction)
        o  the result must be fetched using the di$fetch_find macro

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *start_dir       : the directory where the       	(IN)
				  find should start. A regular expres-
                                  sion may be specified.

        DIchar *regexp          : on the names that match this 		(IN)
				  regular expression are given.

        DIint *ptr              : the number of listed entry;		(OUT)

        DIint  max_level        : the maximum level of search 		(IN)
				  (< 0 means no limit)

        DIint  *deep            : the effective deep of the 		(OUT)
				  search (<= max_level)

        DIchar options          : two options are valid,		(IN)
                                       o OPT_LEVEL   : the display is indented
                                                        to reflect the directory
                                                        structure

                                       o OPT_TRAILER : the names are displayed
                                                        with a trailer depending
                                                        upon the class
*/

#omdef di$start_find ( start_dir = ".", 
                       regexp    = "*",
                       ptr, 
                       max_level = -1,
                       deep      = NULL,
                       options   = OPT_TRAILER )
       DIstart_find ( (start_dir), (regexp), (ptr), 
                      (max_level), (deep), (char) (options) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used get the result of a di$start_find.  The index determines
   the number of the line that should be fetched out.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar line []          : the array to put the result in	(OUT)

        DIgrid *p_grid		: the grid of the line			(OUT)
				   
        DIint  index            : the index of the line to be		(IN)
   			          fetched; this index must be
				  in [0, count[, where count
                                  is returned by start_find
*/
   
#omdef di$fetch_find ( p_grid = NULL, line = NULL, index )
       DIfetch_find ( (line), (p_grid), (index) )
#endomdef


/*---------------------------------------------------------------------------*/

 
/* This macro is used to list the names that match the regular expression.
   If lines is specified (DIchar ***), it is filled out with the results.

        o  options may be OPT_TRAILER or NULL.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *regexp             : if not NULL, only the names	(IN)
				     that match this regular 
				     expression are given.
				   
        DIchar ***lines            : if not NULL, the entries are	(OUT)
				     listed in this array

        DIint *ptr                 : the number of listed entry         (OUT)

        DIchar options             : one option is valid,		(IN)
                                       o OPT_TRAILER : the names are displayed
                                                        with a trailer depending
                                                        upon the class
*/

#omdef di$ls ( regexp       = "*", 
               lines        = NULL, 
               ptr, 
               options      = OPT_TRAILER )
       DImain ( NULL, 0, NULL, NULL, -1, (regexp), 0, NULL_OBJID, NULL,
                NULL, NULL, (lines), NULL, (ptr), (options), 1, 0 )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to initiate an ls.  This macro doesn't give the
   result to the user, rather it allows the user to get the entries
   one by one using the di$fetch_ls macro.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *regexp             : if not NULL, only the names	(IN)
				     that match this regular 
				     expression are given.

        DIint *ptr                 : the number of listed entry         (OUT)

        DIchar options             : one option is valid,		(IN)
                                       o OPT_TRAILER : the names are displayed
                                                        with a trailer depending
                                                        upon the class
*/

#omdef di$start_ls ( regexp       = "*", 
                     ptr, 
                     options      = OPT_TRAILER )
       DIstart_dump ( (1), (NULL), (regexp), (ptr), (char) (options) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used get the result of a di$start_ls.  The index determines
   the number of the line that should be fetched out.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar line []          : the array to put the result in  	(OUT)
				   
        DIint  index            : the index of the line to be	  	(IN)
				  fetched; this index must be
				  in [0, count[, where count
                                  is returned by start_ls
*/
   
#omdef di$fetch_ls ( line, p_grid = NULL, index )
       DIfetch_dump ( (line), (p_grid), (index) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to list the names that match the regular expression.
   If lines is specified (DIchar ***), it is filled out with the results.

        o  options may be OPT_TRAILER, OPT_ALL, OPT_ALL | OPT_TRAILER or NULL.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *regexp             : if not NULL, only the names	(IN)
				     that match this regular 
				     expression are given.
				   
        OM_p_CLASSLIST p_classes   : a list of class ids to            	(IN)
                                     restrict the choice.

        DIchar ***lines            : if not NULL, the entries are	(OUT)
				     listed in this array

        DIgrid **grids             : if not NULL, the grid entries 	(OUT)
				     are listed in this array

        DIint *ptr                 : the number of listed entry   	(OUT)

        DIchar options             : one option is valid,		(IN)
                                       o OPT_TRAILER : the names are displayed
                                                        with a trailer depending
                                                        upon the class
*/

#omdef di$dump ( regexp    = "*", 
                 p_classes = NULL,
                 lines     = NULL, 
                 grids     = NULL, 
                 ptr, 
                 options   = OPT_TRAILER )
       DImain ( NULL, 0, (p_classes), NULL, -1, (regexp), 0, NULL_OBJID,
                NULL, NULL, NULL, (lines), (grids), (ptr), (options), 1, 0 )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to initiate a dump.  This macro doesn't give the
   result to the user, rather it allows the user to get the entries
   one by one using the di$fetch_dump macro.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *regexp             : if not NULL, only the names	(IN)
				     that match this regular 
				     expression are given.

        OM_p_CLASSLIST p_classes   : a list of class ids to             (IN)
                                     restrict the choice.
 
        DIint *ptr                 : the number of listed entry         (OUT)

        DIchar options             : one option is valid,		(IN)
                                       o OPT_TRAILER : the names are displayed
                                                        with a trailer depending
                                                        upon the class
*/

#omdef di$start_dump ( regexp    = "*", 
                       p_classes = NULL,
                       ptr, 
                       options   = OPT_TRAILER )
       DIstart_dump ( (0), (p_classes), (regexp),
                      (ptr), (char) (options) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to get the result of a di$start_dump.  The index determines
   the number of the line that should be fetched out.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar line []          : the array to put the result in   	(OUT)
				   
        DIgrid  *p_grid         : the grid corresponding to        	(OUT)
                                  the line
				   
        DIint  index            : the index of the line to be	   	(IN)
				  fetched; this index must be
				  in [0, count[, where count
                                  is returned by start_dump
*/
   
#omdef di$fetch_dump ( line = NULL, p_grid = NULL, index )
       DIfetch_dump ( (line), (p_grid), (index) )
#endomdef
/*---------------------------------------------------------------------------*/


/*
   This macro is used to mount an object space.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar     logical []	: the object space logical name 	(IN)

        DIspacenum osnum	: object space to be mounted		(IN)
        
        DIchar     *classname	: class name of the link directory	(IN)
*/
   
#omdef di$mount ( logical, osnum, classname = NULL )
       DImount ( (logical), (osnum), (classname) )
#endomdef

/*---------------------------------------------------------------------------*/

/*
   This macro is used to unmount an object space.  The


    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_INVARG  : the specified directory is NOT the
                                    root directory of an objects space
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar     dirname	: directory to be unmounted		(IN)

        DIint      sleep	: if not NULL, the directories will 	(IN)
        			  receive a IGRdir.sleep message.  It
        			  must be the case before saving the
        			  directories to the disk.

        DIint      keep		: if not NULL, the directories will 	(IN)
				  keep the B-tree structure.  It is
				  used to avoid B-tree destruction and
				  re-construction when a non-final save
				  is performed.  If sleep is NULL, this
				  argument is ignored.
*/
   
#omdef di$umount ( dirname, sleep = 0, keep = 0 )
       DIumount ( (dirname), (sleep), (keep) )
#endomdef

/*---------------------------------------------------------------------------*/

/* This macro adds an entry in a directory and creates any directories
   in the entry's path spec that do not already exist.  

   return status :

          DIR_S_SUCCESS  : successful (directories and entry created)
          DIR_E_NAME_DUP : entry name duplicated ( cannot overwrite entry )
          DIR_E_SYNTAX   : syntax error ( badly formatted path )
	  DIR_E_ABORT    : general failure



      Argument description :
      --------------------

        DIobjid   objid       : object id of newly created entry  	(IN)
				in directory 


        DIchar *full_pathname : the full path name of the new     	(IN)
				entry to by added:  for example, 
				:usr1:line:l1.  



        DIspacenum *p_osnum   : the object space number of the    	(OUT)
				directory where the entry was made

    Caveats

       If the code  fails while creating directories in the full pathname
       or when adding the name to last directory, then any directories 
       created by the command will remain!  Code to cleanup the directories
       will be added at a later date.  In the meantime, be very carefull
       about the use of this routine.

       08/31/88 -  if pathname ends with the directory separator character,
       then di$add_name is NOT called and all directories are made ( the 
       last of which is empty ).  If pathname is a directory name and objid
       is not NULL_OBJID ( default ), then DIR_E_INVARG is returned and no 
       directories are created.

 */
#omdef  di$mkpath( objid = NULL_OBJID,   pathname,   p_osnum = NULL )
        DImkpath( (objid), (pathname), (p_osnum) )
#endomdef

/*---------------------------------------------------------------------------*/

/*
   This macro is used to initialize the directory sub-system.  This macro
   MUST be called before any other one.


    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_INVARG  : the specified arguments are not valid
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar separator	: the directory separator		(IN)
                                  default is ':'
                                  
        DIchar current		: the character representing the	(IN)
                                  current directory
                                  default is '.'
                                  
        DIchar home		: the character representing the home	(IN)
                                  directory
                                  default is '~'
                                  
        DIchar back		: the character representing the 	(IN)
                                  previous current directory
                                  default is '-'
*/
   
#omdef di$init ( separator = 0, current = 0, home = 0, back = 0 )
       DIinit ( (separator), (current), (home), (back) )
#endomdef

/*---------------------------------------------------------------------------*/

/*
   This macro is used to free memory allocated by di$ls, di$find or di$dump.

    return status : void

      Argument description :
      --------------------

        DIchar  **lines		: lines to be freed			(IN)

        DIint   count		: number of lines			(IN)

*/
   
#omdef di$free ( lines, count )
       DIfrees ( (lines), (count) )
#endomdef
/*---------------------------------------------------------------------------*/

/*
   This macro is used to find one object space associated with a pathname.

    return status :
                    DIR_S_SUCCESS        : successful operation
                    DIR_E_SYNTAX         : syntax error
                    DIR_W_NAME_NOT_FOUND : name NOT found
                    DIR_E_ABORT          : directory error

      Argument description :
      --------------------

        DIchar  	*pathname	: pathname to be analyzed	(IN)

        DIspacenum   	*p_osnum	: object space number 		(OUT)
                                          associated with the pathname

*/
   
#omdef di$give_osnum ( pathname, p_osnum )
       DIgive_osnum ( (pathname), (p_osnum) )
#endomdef

/*---------------------------------------------------------------------------*/

/*
   This macro is used to find one path name associated with an object space.

    return status :
                    DIR_S_SUCCESS        : successful operation
                    DIR_E_SYNTAX         : syntax error
                    DIR_W_NAME_NOT_FOUND : name NOT found
                    DIR_E_INVARG  	 : the specified osnum has not been
                                           mounted.
                    DIR_E_ABORT          : directory error


      Argument description :
      --------------------

        DIspacenum   	osnum		: object space number 		(IN)

        DIchar  	*pathname	: pathname to be returned 	(OUT)

*/
   
#omdef di$give_pathname ( osnum, pathname )
       DIgive_pathname ( (osnum), (pathname) )
#endomdef

/*---------------------------------------------------------------------------*/

/*
   This macro is used to send a message to a named object (see also om$send).

    return status :
                    DIR_S_SUCCESS        : successful operation (for IGRdir)
                    DIR_E_SYNTAX         : syntax error
                    DIR_W_NAME_NOT_FOUND : name NOT found
                    DIR_E_ABORT          : directory error

                    any OM or application related status

      Argument description (for IGRdir) :
      ---------------------------------

        DIspacenum   	targetos	: object space number 		(IN)
        
        DIchar          *path           : the search path		(IN)

        DIchar  	*targetname	: target object name	 	(IN)

*/
   
#omdef di$send ( mode     = OM_e_wrt_object,
                 path     = NULL,
		 synpath = 0,
                 msg,
                 senderid = my_id,
                 targetos = 0,
                 targetname )
       DIsend ( (path), (synpath), (mode), (senderid), (targetos), (targetname), (msg) )
#endomdef

/*---------------------------------------------------------------------------*/
/*
   This macro is used to move all the names
   from one   object ( old_name or old_objid )
   to another object ( new_name or new_objid ).

    return status :
                    DIR_S_SUCCESS        : successful operation (for IGRdir)
                    DIR_E_ABORT          : directory error

      Argument description (for IGRdir) :
      ---------------------------------

        DIchar          *old_name           : the name of the object	(IN)
					      to move the names from

        DIchar          *new_name           : the name of the object	(IN)
					      to move the names to

        DIobjid         *old_objid          : the objid of the object	(IN)
					      to move the names from

        DIobjid         *new_objid          : the objid of the object	(IN)
					      to move the names to

*/
   
#omdef di$move_names ( old_name = NULL ^ old_objid = NULL_OBJID,
                       new_name = NULL ^ new_objid = NULL_OBJID  )

       DImove_names ( (old_name), (old_objid), (new_name), (new_objid) )

#endomdef

/*---------------------------------------------------------------------------*/

#endif
