/* $Id: VDSudp_priv.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSudp_priv.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSudp_priv.h,v $
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

#ifndef VDSudp_priv_include
#define VDSudp_priv_include


	/********************************************************/
	/*							*/
	/* 	private macros used for user defined paths	*/
	/* 							*/
	/********************************************************/


/*
 * 	This file depends on the following files :
 *	
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

extern int VDSauto_name __((	int index,
				struct constr_path *to_name,
				int const_flag,
				char *name,
				int *named_flag));

extern int VDSgive_exp __((	int main_alloc,
				int search_alloc,
				int *nb_main,
				int *nb_search,
				struct current_path *current,
				struct constr_path *main,
				struct constr_path *search,
				int nb_lines,
				char **lines));

extern int VDSname_exp __((	char *pathname,
				int const_flag,
				char *exp_name,
				char *exp_value,
				int *found,
				int nb_lines,
				char **lines));

extern int VDSsymb_to_text __((	struct txt_symb *txt_symb,
				char *exp_symb));

extern int VDSgive_symb __((	struct GRsymbology *symbology,
				struct txt_symb *txt_symb));

extern int VDStext_to_symb __((	struct txt_symb *txt_symb,
				char *exp_symb));

extern int VDSpath_in_list __((	char *in_path,
				int *out_index,
				char *out_name,
				struct constr_path *list,
				int nb_elts,
				struct txt_symb *symb,
				int *found));

extern int VDSname_in_list __((	char *in_name,
				int *out_index,
				char *out_path,
				struct constr_path *list,
				int nb_elts,
				struct txt_symb *symb,
				int *found));

extern int VDSextract_part_exp __(( char *exp,	  
				    char *before, 
				    char *after, 
				    char sep_char));

extern int VDSextract_all_part_exp __((
				int nb_returned,
				char *expression,
				int *nb_part,
				char **part_exp,
				char sep_char));

extern int VDSpath_name __((	char *in_path,
				char *out_path));

extern int VDSremove_user_path __((void));

extern int VDSinit_list_form __((char *form_ptr));

extern int VDSset_symbology __((struct txt_symb *text_symb,
				char *symb_ptr));

extern int VDSout_path __((	char *in_path,
				char *ref_path,
				char *out_path));

extern int VDSupdate_path __((	char *form_ptr,
				struct current_path *current,
				struct constr_path *main,
				struct constr_path *search,
				int nb_main,
				int nb_search));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$auto_name( 	index,
			to_name, 
			const_flag = MAIN_PATH,
			name 	   = NULL,
			named_flag)

  ABSTRACT
	This macro is used to give a name to the given path. The name is
	path "index" for MAIN_PATH and search"index" for SEARCH_PATH.

  ARGUMENTS

	data type	argument	I/O description

 	struct  constr_path *to_name	I : path to be auto_named
	int		index		I : index of the name
	int		const_flag	I : MAIN_PATH or SEARCH_PATH	
	char		*name		O : name given to the path 
 	int		*named_flag	O : 1 = name has been given

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef vds$auto_name( 	index,
			to_name, 
			const_flag = MAIN_PATH,
			name 	   = (char *) NULL,
			named_flag)
  
	VDSauto_name( (index),(to_name), (const_flag), (name), (named_flag))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$give_exp( 	main_alloc   = 0,
     			search_alloc = 0,
     			nb_main      = NULL, 
     			nb_search    = NULL, 
     			current      = NULL, 
     			main         = NULL, 
     			search       = NULL,
     			nb_lines     = 0,
			lines        = NULL )
	
  ABSTRACT
	This macro is used to read the expressions in user_path directory
	and return the contend of it

  ARGUMENTS

	data type	argument	I/O description

	int		main_alloc	I : nb elts allocated for main
	int		search_alloc	I : nb elts allocated for search	
	int		*nb_main	O : nb elts returned in main
	int		*nb_search	O : nb elts returned in search
	struct current_path *current	O : active paths returned  	
	struct constr_path *main	O : array of main structures returned. 
					    Should be allocated as an array of 
					    main_alloc pointer of struct
					    constr_path
	struct constr_path *search	O : array of search structures returned 
					    Should be allocated as an array of 
					    search_alloc pointer of struct 
					    constr_path.
	int		nb_lines	I : nb_lines entered (0 if NULL) 
	char		**lines 	I : lines
	    
  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$give_exp( 	main_alloc   = 0,
     			search_alloc = 0,
     			nb_main      = (int *) NULL, 
     			nb_search    = (int *) NULL, 
     			current      = (struct current_path *) NULL, 
     			main         = (struct constr_path *) NULL, 
     			search       = (struct constr_path *) NULL,
     			nb_lines     = 0,
			lines        = (char **) NULL)	

	VDSgive_exp((main_alloc),(search_alloc),(nb_main),(nb_search),
			(current),(main),(search),(nb_lines),(lines))
#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$name_exp( 	pathname , 
			const_flag = MAIN_PATH,
			exp_name   = NULL,
			exp_value  = NULL,
			found	   = NULL,
     			nb_lines   = 0,
			lines      = NULL)

  ABSTRACT
	This macro is used to read in directory user_path and return if the 
	given name exist. If exist returns the expression name.(doesn't search 
	in active path since active path must also be in the list).
	The user must specify if he wants to search the name in the main or 
	search path list.

  ARGUMENTS

	data type	argument	I/O description

	char		*pathname	I : name of path to find
	int		const_flag	I : MAIN_PATH, SEARCH_PATH	
	char		*exp_name	O : returned exp name 
	char		*exp_value	O : returned exp value 
	int		*found		O : 1 = name has been found
	int     	nb_lines 	I : nb_lines entered (0 if NULL) 
	char    	**lines 	I : lines	


  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$name_exp( 	pathname , 
			const_flag	= MAIN_PATH,
			exp_name	= (char *) NULL,
			exp_value	= (char *) NULL,
			found		= (int *) NULL,
     			nb_lines	= 0,
			lines		= (char **) NULL)
		
	VDSname_exp((pathname), (const_flag), (exp_name), (exp_value),
			(found), (nb_lines), (lines))
#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$symb_to_text(	txt_symb,
				exp_symb = NULL )

  ABSTRACT
	This macro is used to return the color, layer,weight, style given by 
	the symbology expression.

  ARGUMENTS

	data type	argument	I/O description

	struct txt_symb	*txt_symb	O : returned text symbology
	char 		*exp_symb	I : value of symbology expression 

  REMARKS
	if exp_symb == NULL return the active symbology

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$symb_to_text(	txt_symb,
				exp_symb = (char *) NULL )

	VDSsymb_to_text((txt_symb),(exp_symb))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$give_symb(	symbology,
			txt_symb )

  ABSTRACT
	This macro is used to return the symbology given by the txt_symb
	structure

  ARGUMENTS

	data type	argument	I/O description

 	struct GRsymbology *symbology	O : return symbology 
	char 		*txt_symb	I : text symbology

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$give_symb(symbology, txt_symb)

	VDSgive_symb((symbology),(txt_symb))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$text_to_symb(txt_symb = NULL, exp_symb )

  ABSTRACT
	This macro is used to return the expression of the symbology given
	the color, weight, style, layer.

  ARGUMENTS

	data type	argument	I/O description

	struct txt_symb	*txt_symb	I : text symbology
	char 		*exp_symb	O : returned symbology expression 

  REMARKS
	if txt_symb == NULL return the expression for active symbology

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$text_to_symb(	txt_symb = (struct txt_symb *)NULL,
				exp_symb )

	VDStext_to_symb((txt_symb),(exp_symb))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$path_in_list(	in_path,
				out_index = NULL,
				out_name  = NULL,
				list,
				nb_elts,
				symb = NULL,
				found )
   
  ABSTRACT
	This macro is used to return if the given path is in the given list
	or not. 
	nb_list = nb elts in the input list.
	If the path is found, found = 1 and the macro can return the name 
	of the path, its index in the list and the symbology associated to it.

  ARGUMENTS

	data type	argument	I/O description

	char		*in_path	I : path  search in the list   
	DIint		*out_index	O : index of path in the list  
	char		*out_name	O : name of path in the list  
	struct constr_path *list	I : list where to search
        int		nb_elts		I : nb elts in the input list
        struct txt_symb *symb		O : symbology associated with path
	int		*found		O : 1 = found 0 = not found   

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$path_in_list(in_path ,
			 out_index	= (DIint *) NULL,
			 out_name	= (char *) NULL,
			 list,
			 nb_elts,
			 symb		= (struct txt_symb *) NULL,
			 found)
 
	VDSpath_in_list((in_path),(out_index),(out_name),(list),(nb_elts),
			(symb), (found))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$name_in_list(	in_name,
				out_index = NULL,
				out_path  = NULL,
				list,
				nb_elts,
				symb = NULL,
				found )
   
  ABSTRACT
	This macro is used to return if the given name is in the given 
	list or not. 
	nb_list = nb elts in the input list.
	If the name is found, found = 1 and the macro can return the path,
	its index in the list and the symbology associated to it.

  ARGUMENTS

	data type	argument	I/O description

	char		*in_name	I : name  search in the list   
	DIint		*out_index	O : index of path in the list  
	char		*out_path	O : path in the list  	   
	struct constr_path *list	I : list where to search
        int		nb_elts		I : nb elts in the input list
        struct txt_symb *symb		O : symbology associated with path
	int		*found		O : 1 = found 0 = not found   

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$name_in_list(in_name,
			 out_index	= (DIint *) NULL,
			 out_path	= (char *) NULL,
			 list,
			 nb_elts,
			 symb		= (struct txt_symb *) NULL,
			 found)
 
	VDSname_in_list((in_name),(out_index),(out_path),(list),(nb_elts),
			(symb), (found))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$extract_all_part_exp(nb_returned = 0,
     				expression, 
     				nb_part     = NULL, 
     				part_exp    = NULL, 
     				sep_char    = ',')	
	
  ABSTRACT
	This macro is used to extract of an expression all the part separated
	by a given char.

  ARGUMENTS

	data type	argument	I/O description

	int		nb_returned	I : nb elts allocated for part_exp	
	char		*expression	I : expression to partition 	
	int		*nb_part	O : nb part returned		
	char		**part_exp	O : array of exp returned.
					    Should be allocated as an array 
					    of nb_returned pointer of
					    char (MY_MAX)
	char		sep_char	I : separate char		
 
  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$extract_all_part_exp(nb_returned = 0,
     				expression, 
     				nb_part     = (int *) NULL, 
     				part_exp    = (char **) NULL, 
     				sep_char    = ',')	
		
	VDSextract_all_part_exp((nb_returned),(expression),(nb_part),
				(part_exp),(sep_char))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$path_name(	in_path = ".",
     			out_path )

  ABSTRACT
	This macro is used to return the relative path if the path is
	not absolute (relative is regard to the ref path)

  ARGUMENTS

	data type	argument	I/O description

 	char 		*in_path	I : input path 
 	char		*out_path	O : path to use in the dir system

  REMARKS
	also return the current dir if path is .

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef 	vds$path_name(	in_path = ".",
     			out_path )

	VDSpath_name((in_path),(out_path))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$remove_user_path()

  ABSTRACT
	This macro is used to remove all the expressions in the user_path
	directory

  ARGUMENTS

	data type	argument	I/O description

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$remove_user_path()

	VDSremove_user_path()

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$init_list_form( form_ptr )

  ABSTRACT
	This macro is used to  initialise the path list form

  ARGUMENTS

	data type	argument	I/O description

 	char		*form_ptr	I : form pointer

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$init_list_form(form_ptr)

	VDSinit_list_form((form_ptr))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$set_symbology(	text_symb,
				symb_ptr )
   
  ABSTRACT
	This macro is used to set the gadget of the symbology form and 
	fill the fields with the given symbology

  ARGUMENTS

	data type	argument	I/O description

	struct txt_symb *text_symb	I : symbology to set
	char		*symb_ptr	I : form pointer

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef  vds$set_symbology(text_symb,symb_ptr)
   
	VDSset_symbology((text_symb),(symb_ptr))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$out_path(	in_path = ".",
         		ref_path,
     			out_path )

  ABSTRACT
	This macro is used to return the relative path if the path is
	not absolute (relative is regard to the ref path). 
	Same as vds$path_name but works on instances and not on expressions

  ARGUMENTS

	data type	argument	I/O description

 	char 		*in_path	I : input path 
        char		*ref_path	I : ref_path.
 	char 		*out_path	O : path relative to reference given.

  REMARKS
	also returns the current dir if path is .

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$out_path(	in_path	= ".",
         		ref_path,
     			out_path )

	VDSout_path((in_path),(ref_path),(out_path))

#endomdef

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
  
  MACRO
	vds$update_path(form_ptr,
			current   = NULL,
		      	main      = NULL,
		      	search    = NULL,
		      	nb_main   = 0,
		      	nb_search = 0)

  ABSTRACT
	This macro is used to update the User_Path forms

  ARGUMENTS

	data type		argument	I/O description

	char			*form_ptr;
	struct current_path 	*current;	I : input path to set 
	struct constr_path	*main;
	struct constr_path 	*search;
	int			nb_main;
	int			nb_search;

  REMARKS

  EXAMPLE

  ---------------------------------------------------------------------------*/

#omdef	vds$update_path(form_ptr,
		       	current   = (struct current_path *) NULL,
		      	main      = (struct constr_path *) NULL,
		      	search    = (struct constr_path *) NULL,
		      	nb_main   = 0,
		      	nb_search = 0)

	VDSupdate_path((form_ptr),(current),(main),(search),
			(nb_main),(nb_search))

#endomdef

/*---------------------------------------------------------------------------*/
#endif


