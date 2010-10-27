/* $Id: VDSudp_mac.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSudp_mac.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSudp_mac.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef VDSudp_mac_include
#define VDSudp_mac_include


	/********************************************************/
	/*							*/
	/* 	macros used for user defined paths		*/
	/* 							*/
	/********************************************************/

/*
 * 	This file depends on the following files :
 *	
 *	Version 02.02.00.00	ADZ
 */

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDSinit_path __((	char *ref_path,
				struct constr_path *main_path,
				struct constr_path *search_path,
				char *user_path,
				struct GRid *dir_obj,
				struct GRmd_env *md_env));

extern int VDSget_active_symb __((struct GRsymbology *symbology));

extern int VDSget_path __((	char *return_path,
				char *name_path,
				int const_flag,
				char *in_name,
				struct GRsymbology *symbology,
				int *found,
				int nb_lines,
				char **lines));

extern int VDSget_search_path __((char *in_name,
				int *nb_search,
				char ***search_path,
				char *search_name,
				int *found,
				int nb_lines,
				char **lines,
				int nb_call));

extern int VDSdelete_path __((	char *in_name,
				int const_flag));

extern int VDSadd_path __((	char *in_path,
				char *path_name,
				int const_flag,
				struct GRsymbology *symbology,
				char *out_name));

extern int VDSset_act_path __((	char *path_name,
				int const_flag,
				char *ret_path));

extern int VDStranslate __((	char *objname,
				DIobjid *p_objid,
				DIspacenum *p_osnum,
				int *p_index));

extern int VDSuntranslate __((	char *objname,
				DIobjid objid,
				DIspacenum osnum,
				DIint *p_index));

extern int VDSset_current __((	char *current_dir,
				char *path,
				char *out_path,
				struct GRsymbology *symbology));

extern int VDSsymbology_from_path __((
				char *path,
				struct GRsymbology *symbology));

extern int VDSpath_from_level __((IGRshort level,
				char *path));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$init_path( 	ref_path    = NULL,
			main_path   = NULL,
			search_path = NULL,
               		user_path   = NULL,
               		dir_obj	    = NULL,
               		md_env	    = NULL)

  ABSTRACT
	This macro is used to create or update all the paths and the symbology 

  ARGUMENTS

	data type	   argument	I/O description

 	char 		   *ref_path	I : reference path to set.
 	struct constr_path *main_path	I : main path to set.
 	struct constr_path *search_path	I : search_path to set.
	char 		   *user_path	O : path of the dir expression
	struct GRid 	   *dir_obj	O : object of the dir user_path
	struct GRmd_env    *md_env	O : current mod_env	

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/


#omdef vds$init_path( 	ref_path    = (char *) NULL,
			main_path   = (struct constr_path *) NULL,
			search_path = (struct constr_path *) NULL,
               		user_path   = (char *) NULL,
               		dir_obj	    = (struct GRid *) NULL,
               		md_env	    = (struct GRmd_env *) NULL)
			
	VDSinit_path((ref_path),(main_path),(search_path),(user_path),
			(dir_obj),(md_env))
#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$get_active_symb( (symbology) )

  ABSTRACT
	This macro is used to get the active symbology 

  ARGUMENTS

	data type	   argument	I/O	description

	struct GRsymbology *symbology   O :     returned symbology 

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef  vds$get_active_symb(symbology )
   
	VDSget_active_symb((symbology))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$get_path( 	return_path = NULL,
                	name_path   = NULL,
			const_flag  = MAIN_PATH,
                	in_name	    = "ACTIVE",
			symbology   = NULL,
			found       = NULL,
     			nb_lines    = 0,
			lines       = NULL)
	
  ABSTRACT
	This macro is used to retrieve the reference path or a path of the list.
	except for reference (not named), return the path given by its name,
	or the active one (default) and can give the symbology associated with 
	this path and the name of the path . 

  ARGUMENTS

	data type	   argument	I/O description

	char		   *return_path	O : return path of the directory in the
				  	    User_Path form.  ( absolute path 
					    is returned )
	char		   *name_path	O : name of the path if exist
	int		   const_flag	I : MAIN_PATH for the main construction 
					    path REF_PATH for the reference path
	char	           *in_name	I : name of path to return (ACTIVE by
					    default)	
	struct GRsymbology *symbology	O : return symbology associated with the
					    path in the "User_Path" form.
					    NULL if const_flag = REF_PATH.  
	int		   *found	O : 1 = found 0 = not found	
 	int     	   nb_lines 	I : nb_lines entered (0 if NULL) 
	char    	   **lines 	I : lines			    

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$get_path( 	return_path	= (char *) NULL,
                	name_path	= (char *) NULL,
			const_flag	= MAIN_PATH,
                	in_name		= "ACTIVE",
			symbology	= (struct GRsymbology *) NULL,
			found		= (int *) NULL,
     			nb_lines	= 0,
			lines		= (char **) NULL )
			
	VDSget_path((return_path),(name_path),(const_flag),(in_name),
			(symbology),(found),(nb_lines),(lines))
#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$get_search_path(	in_name     = "ACTIVE",
		   		nb_search   = NULL,
		   		search_path = NULL,
				search_name = NULL,
				found	    = NULL,
     				nb_lines    = 0,
				lines       = NULL,
                                nb_call     = 100)

  ABSTRACT
	This macro is used to retrieve a list of search paths given by the
	user in the User_Path form (and optionnally the name of this list)
	or a list of search path given by its name. search_path is allocated
	in the function as a pointer of nb_search array of char.

  ARGUMENTS

	data type	argument	I/O description

	char		*in_name	I : name of path to return 	
	int		*nb_search 	O : nb of returned elements in
					    search_path list.
					    NULL if you don't need.
	char		***search_path  O : returned list of search_paths.
					    Should be allocated as
					    search_path[nb_search][MY_MAX]
					    return NULL if nb_search is
					    given NULL.
        char		*search_name    O : name of search list	
	int		*found 		O : 1 = found 0 = not found  
	int		nb_lines 	I : nb_lines entered (0 if NULL) 
	char		**lines 	I : lines
        int		nb_call         I : maximum number of recursive call 

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$get_search_path(	in_name		= "ACTIVE",
		   		nb_search	= (char *) NULL,
		   		search_path	= (char ***) NULL,
				search_name	= (char *) NULL,
				found		= (int *) NULL,
     				nb_lines	= 0,
				lines		= (char **) NULL,
                                nb_call		= 100)

	VDSget_search_path((in_name),(nb_search),(search_path),
                   (search_name),(found),(nb_lines),(lines),(nb_call))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$delete_path(	in_name ,
				const_flag = MAIN_PATH)

  ABSTRACT
	This macro is used to delete a path (given by its name) in SEARCH or
	MAIN list. (active path cannot be deleted)

  ARGUMENTS

	data type	argument	I/O description
	
	char		*in_name	I : name of path to delete
	int		const_flag	I : MAIN_PATH or SEARCH_PATH

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$delete_path(	in_name ,
			const_flag = MAIN_PATH)

	VDSdelete_path((in_name),(const_flag))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$add_path(	in_path	   = NULL, 
			path_name  = NULL, 
			const_flag = MAIN_PATH, 
			symbology  = NULL, 
			out_name   = NULL)

  ABSTRACT
	This macro  add a path in the path or search path list
	The user define the path to add, its name (otherwise a default name
	is given, the symbology of path (if not a search path), and what kind
	of path he wants to add (MAIN_PATH or SEARCH_PATH). If a name is given,
	and if that name already exist, the function only modify the definition
	of the path (to avoid duplicate name). If the user really wants to add
	a named path, he can verify with the macro vds$get_path or 
	vds$get_search_path if the name already exist or not.

  ARGUMENTS

	data type	   argument	I/O description

	char		   *in_path	I : path to add		
	char		   *path_name	I : name of the path         
	int		   const_flag	I : MAIN_PATH or SEARCH_PATH 
	struct GRsymbology *symbology	I : symbology of path (NULL if active)
	char		   *out_name	O : name of path given	

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$add_path(	in_path		= (char *) NULL, 
			path_name	= (char *) NULL, 
			const_flag	= MAIN_PATH, 
			symbology	= (struct GRsymbology *) NULL, 
			out_name	= (char *) NULL )

	VDSadd_path((in_path), (path_name), (const_flag), (symbology),
			(out_name))
#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$set_act_path(path_name, 
			const_flag = MAIN_PATH,
                        ret_path   = NULL)


  ABSTRACT
	Macro that set the given path active.
	The user define the path to add by its name and the kind of path the
	user wants to add (MAIN_PATH or SEARCH_PATH). 
	The path must already exist in the list, which can be verified by
	vds$get_path or vds$get_search_path.

  ARGUMENTS

	data type	argument	I/O description

	char		*path_name	I : name of the path         
	int		const_flag	I : MAIN_PATH or SEARCH_PATH 
	char		*ret_path	O : returned path         

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$set_act_path(path_name, 
			const_flag	= MAIN_PATH,
                        ret_path	= (char *) NULL)

	VDSset_act_path((path_name), (const_flag), (ret_path))
#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$translate( 	objname,
	      		p_objid,
             	 	p_osnum = NULL,
             	 	p_index = NULL)

  ABSTRACT
	This macro is used to translate a name from the search paths given 
	in the User_Path form (ie the macro will try to find the name in one 
	of the search paths, and nowhere else)

  ARGUMENTS

	data type	argument	I/O	description

	char		*objname	I : name of the object you want to 
					    translate.
	DIobjid		*p_objid	O : the objid associated with the
					   name.
	DIspacenum	*p_osnum	O : the object space number of the 
					   object.
	int		*p_index	O : index of path in search_list

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$translate( 	objname,
	      		p_objid,
             	 	p_osnum	= (DIspacenum *) NULL,
             	 	p_index	= (int * ) NULL)

	VDStranslate((objname),(p_objid),(p_osnum),(p_index))
#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$untranslate( objname ,
	      		objid,
             	 	osnum   = OM_Gw_current_OS,
             	 	p_index = NULL)

  ABSTRACT
	This macro is used to untranslate a name in the search_paths given 
	in the User_Path form (given the objid and the osnum of an object, 
	find the name in one of the search_path)

  ARGUMENTS

	data type	argument	I/O description

	char		*objname	O : name of the object with its path.
	DIobjid		objid		I : the objid associated with the name.
	DIspacenum	osnum		I : the object space number of the 
					    object.
	DIint		*p_index	O : the index of the name in the 
					    search_path list.

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$untranslate( objname ,
	      		objid,
             	 	osnum	= OM_Gw_current_OS,
             	 	p_index = (DIint *) NULL)

	VDSuntranslate((objname),(objid),(osnum),(p_index))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$set_current( current_dir ,
	      		 path 		= ".",
			 out_path 	= NULL,
			 symbology 	= NULL)

  ABSTRACT
	This macro is used to set the current directory and the current
	symbology; it output the name of the current directory.

  ARGUMENTS

	data type	   argument	I/O description

	char		   *current_dir	I : dir to set active;
	char		   *path	I : relative path 
	char		   *out_path	O : out_path
	struct GRsymbology *symbology	I : symbology to set active

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$set_current( current_dir ,
	      		path 		= ".",
			out_path 	= (char *) NULL,
			symbology 	= (struct GRsymbology *) NULL)

	VDSset_current((current_dir),(path),(out_path),(symbology))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$symbology_from_path( path ,
			 	 symbology )

  ABSTRACT
	This macro is used to return the symbology associated to the given path 
	Path must be given in an absolute way.
	( It returns OM_E_ABORT in case the path is not found in path system)

  ARGUMENTS

	data type	   argument	I/O description

	char		   *path	I : path to retrieve symbology;
	struct GRsymbology *symbology	O : returned symbology 

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef  vds$symbology_from_path( path ,
			 	 symbology )

	VDSsymbology_from_path((path),(symbology))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$path_from_level( 	level,
				path  )

  ABSTRACT
	This macro is used to return the first path found which have
	the given level.
	(It returns OM_E_ABORT in case level is not found in symbology path)

  ARGUMENTS

	data type	argument	I/O description

	char		*path		O : returned path 
	IGRshort	level		I : input level	

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef  vds$path_from_level( 	level,
				path  )

	VDSpath_from_level((level),(path))

#endomdef

/*---------------------------------------------------------------------------*/

#endif


