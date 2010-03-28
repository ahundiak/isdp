
#ifndef acmacros_include
#define acmacros_include


#omdef ac$find_macro_defn( action, macro_name, p_macro_defn_id)
ACfind_macro_defn((action), 0, (macro_name), 0, 
		(p_macro_defn_id));
#endomdef

/*
ABSTRACT 
 From the name of a macro definition, returns it's objid.

 The name could be 
 - just the macro name :  The first macro definition with this name found in 
   the loaded macro library is returned
 - the full path name for the macro, including the macro libary name.
   (:design_file_name:constructs_lib:macro_lib_name:constructs:macro_name)
   The macro definition is only searched in this library. 
   

ARGUMENTS

data type  argument    I/O        description

int 	    action	  I : typedef in macro.h
			     ACfind_no_load - only search for the macro in 
				 the loaded macro lib
			     ACfind_load    - if not found in dynamic loading by
				 executing the ppl file macro_name.e which 
				 should define in its main funtion the macro
				 definition
				  
char 	    *macro_name	  I : name of the macro to find or load

struct GRid *p_macro_defn O : GRid of the definition found or loaded

   RETURN CODE 

0 : FAILURE to find or to load
1 : SUCCESS
*/

#omdef ac$add_macro_name(macro_name, osnum=0, macro_defn_id)
ACadd_macro_name((macro_name), (osnum), (macro_defn_id));
#endomdef


/*
ABSTRACT
 Name the macro definition in the directory reserved for macro naming. If the 
 global ACauto_save save option is set, write the macro library to file.

   ARGUMENTS

data type  argument    I/O        description
char      *macro_name     I       name of the macro definition
ushort    osnum		  I       osnum of the macro definition
OM_S_OBJID  macro_defn_id I       objid of the macro defintion

   RETURN CODE 

0 : FAILURE to find or to load
1 : SUCCESS

*/



#omdef ac$construct_path (mode = AC_INQ,
                          name = NULL,
	                  path = NULL,
                       	  path_size = 0,
 			  path_len = NULL)
ACconstruct_path((mode),(name),(path),(path_size),(path_len))
#endomdef


/* ABSTRACT 
   This macro defines or inquires about search path for macro definitions.
   This search path is used when the user places an ocurence of a macro.

   ARGUMENTS

data type  argument  I/O        description

IGRint   mode         I : type of request
			   AC_SET sets the path to name
                           AC_INQ returns the active path
			   AC_ADD_PATH adds name to active path
			   AC_REM_PATH removes name from active path

IGRchar  *name        I : depending upon mode
			   AC_ADD : name to add to the active path
			   AC_REM : name to remove from active path
			   AC_SET : path name in the format file1,file2

IGRchar  *path        O : obtained path returned if mode & ND_INQ  is true
			           	     and if path_size >= path_len+1

IGRint   path_size    I : size of the array path

IGRint   *path_len    O : actual length of path

   STATUS RETURNS

OM_S_SUCESS : Success
OM_W_ABORT  : Failure

*/

#omdef ac$lib_name(osnum,
		   name_size = 0,
		   name = NULL,
		   name_len = NULL)
AClib_name((osnum),(name_size),(name),(name_len))
#endomdef

/* ABSTRACT 
   This macro returns the name of a macro library corresponding to a 
   give osnum

   ARGUMENTS

data type  argument  I/O        description

GRspacenum  osnum     I : osnum of the macro library

int         name_size I : size of the array name

char        *name     O : name of the macro library truncated to name_size
			  (not returned if name = NULL)

int	    *name_len O : length of name (including \0 ....)
			  (not returned if name_len = NULL)

   STATUS RETURNS

OM_S_SUCESS : Success
OM_W_ABORT  : Failure, this osnum is not a macro library 

*/

#omdef ac$lib_dir(name , dir)

AClib_dir((name),(dir))
#endomdef

/* ABSTRACT 
   This macro returns the grid of the directory containing macro definition
   for a given macro library name

   ARGUMENTS

data type  argument  I/O        description

char       *name     I : name of the macro library 

GRid       *dir      O : Grid of the directory containing macro definition

   STATUS RETURNS

OM_S_SUCESS : Success
OM_W_ABORT  : Failure, this name  is not a macro library 
*/


#omdef ac$construct_wd (mode = AC_INQ,
		        name = NULL,
		        dir  = NULL,
		        name_size = 0,
			name_len = NULL)
ACconstruct_wd((mode),(name),(dir),(name_size),(name_len))


#endomdef

/* ABSTRACT

This macro defines/inquires the filename and directory GRid where new macro
definitions will be created ("working directory")

   ARGUMENTS

data type  argument  I/O        description

IGRint   mode        I : type of request
                            AC_SET modifies the current working directory 
                            AC_INQ returns the current working directoy


IGRchar   *name       I : requested filename if request = AC_SET
                      O : current   filename if request = AC_INQ .

struct GRid *dir      O : GRid of the directory where the name of the
			  construction are stored

IGRint  name_size     I : size of name (only used when name is used in output,
			  mode = AC_INQ).

IGRint  *name_len     O : size of name (only used when name is used in output,
			  mode = AC_INQ).

   STATUS RETURNS

OM_S_SUCESS : Success
OM_W_ABORT  : Failure

*/

#omdef ac$save_wd ()
ACconstruct_save(NULL)
#endomdef

/* 
 ABSTRACT

This macro saves to file the current working macro library that has been 
defined by the macro ac$construct_wd. It only works if this working library
is not the current object space ( wd != ".").

 NO ARGUMENTS
 
 STATUS RETURNS

OM_S_SUCESS : Success
OM_W_ABORT  : Failure
*/


#omdef ac$create_def_temp(search_option = 0,
			   search_path = NULL,
			   symbology   = 0,
			   hdr_type = HDR_CONS,
			   hdr_scroll = FULL_SCROLL, 
			   macro,
			   temp_val = NULL,
			   temp_grid = NULL,
			   feet_grid = NULL,
			   def_col,
			   def_occ = NULL)

ACcreate_def_temp((search_option),(search_path),(symbology),
		  (hdr_type),(hdr_scroll),
		  (macro),(temp_val),(temp_grid),(feet_grid),
		  (def_col),(def_occ))
#endomdef

/* ABSTRACT 
  Creates a default template and initialize placement option that will be
  used by the command object "place macro".

ARGUMENTS

int  search_option     I
char *search_path      I
int  symbology         I
int  hdr_type          I
int  hdr_scroll        I
struct GRid *macro     I
struct ret_struct *temp_val I
struct GRid *temp_grid I
struct GRid *feet_grid I
struct GRid *def_occ   O
struct GRid *def_col   O created collection with placement option

 DOC TO BE FINISHED
*/

#omdef ac$set_def_interface(	rc		= NULL,
				def_name,
				form_name,
				nb_att		= 0,
				list_att	= NULL )

ACset_def_interface( (rc), (def_name), (form_name), (nb_att), (list_att) )
#endomdef


/* ABSTRACT 
	Set the informations used to modify the generic interface to
	place/modify occurence of the macro.


ARGUMENTS

IGRlong	*rc		O	return code.
IGRchar	*def_name	I	name of the working definition.
IGRchar	*form_name	I	name of the form use to place macro.
				if( form_name == NULL ) use generic form
				if( form_name == '\0' ) use generic form
					but index in template list is modified.
				else	use the given form.
IGRint	nb_att		I	number of template override in the list.

struct	ACrg_coll *list_att I	list set with template name and index in the 
				coresponding form.

*/

#omdef ac$get_def_interface(	rc		= NULL,
				def_name,
				generic_inter,
				form_name	= NULL,
 				len_list	= 0,
				list_att	= NULL,
				count_att )

ACget_def_interface( (rc), (def_name), (generic_inter), 
			(form_name), (len_list), (list_att), (count_att) )
#endomdef


/* ABSTRACT 
	This macro allow to retrieve informations on the place/mofify 
	user form interface.

ARGUMENTS

IGRlong	*rc		    O	return code.
IGRchar	*def_name	    I	name of the working definition.
IGRint	*generic_inter	    O	flag to determine if we use the generic interface.
				if( *generic_inter ) then the following
				arguments have no sens.

IGRchar	*form_name	    O	Name of the form define by user
				form_name == '\0' --> generic form
				else use define form.
IGRint	len_list	    I	length of the attribute list.
struct	ACrg_coll *list_att O	support list for user attributes
IGRint	*count_att	    O   total number of user attributes.

*/

#endif
