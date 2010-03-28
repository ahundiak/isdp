#ifndef asmacros_include
#define asmacros_include
/*
  macro definition used by parametric sub_system
  
  HISTORY :  jla 26-nov-87 design date
	     jla    oct-88 release 1.2

*/

#include <stdio.h>
#include "parametric.h"



#omdef as$make_source(go_grid,
		      mod_env = NULL,
		      context_grid = NULL_GRID,
		      as_os = OM_Gw_current_OS,
		      as_grid,
		      option = 0)
#if (om$specified(mod_env))
ASmake_source_from_env((&go_grid),(mod_env),(as_grid),(option))
#else
ASmake_source((go_grid),(context_grid),(as_os),(as_grid),(option))
#endif
#endomdef

/* ABSTRACT
        Given a graphic object and possibly a context (if the object is in a
   reference file) this macro creates a source object. This source object
   will be connected to the notify channel of the graphic object and 
   used to connect dependent associative objects.

   The GRid of an existing associative object is returned instead of
   creating a new one in the 2 following cases :

   - an associative object is already owner of the graphic object (connection
     via owner channel) and there is no context specified in the call.

   - a source object is on the notification channel of the graphic object with
     same context (or without context if no context specified in call).



       as$make_source(go_grid,
                      context_grid = NULL_GRID,
                      as_os = OM_Gw_current_OS,
                      as_grid)

data type  argument    I/O        description

GRid      go_grid      I : graphic object.
GRid      context_grid I : context object if the graphic object is in a
                           reference file
or
GRmd_env  *mod_env     I : module env info returned by locate
osnum     as_os        I : object space where the source has to be created
*GRid     as_grid      O : source object created or already existing 
                           associative object returned.
int       option       I : reserved for future use

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef as$any_give_structure(go_grid,inst,mod_env = NULL)

ASany_give_struct((go_grid).objid,(go_grid).osnum,(mod_env),(inst))

#endomdef

/*
ABSTRACT
     This macro returns the structure of an object. This structure contains
     the geometrical type of the element and its geometry (or value for
     parameters).
     - If the object is sub class of NDnode, the message NDnode.NDgive_structure
       is send to it.
     - Otherwise, depending upon the class of the object, a GRgetpolyline
       or GRgetarc or GRgetmatrix or GRgenabsg is performed. The result is
       then transformed into a structure of type ret_struct (defined in
       parametric.h)

data type    argument I/O        description

GRid         go_grid IN  : target object
*ret_struct  inst    OUT : returned structure of the object
*GRmd_env    mod_env IN  : module environnement information
			   if not specified, a gr$get_module_env is performed
			   by the function

*/

#omdef as$getabsg( as_grid, index = -1, bc)

ASgetabsg((as_grid),(index),(bc))

#endomdef
/* 
ABSTRACT

This macro returns the b_spline defintion of an associative object
If index = -1 (dafault value) the geometry of the entire element is returned.
Else the element is in fact a composite element. The geoemtry of its index
componant is returned.

The function does the following :
- get the graphic object and its environment (ASreturn_go message)
- send genabsg to this graphic object if index == -1 or to its
  index component.

Warning : index is the index on channel and NOT le leaf_id


data type  argument I/O        description

*GRid     go_grid   I : associative objet
int       context   I : indexing in the graphic object
char      **bc      O : returned geoemtry


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef as$make_contents(ref,contents)
asmake_contents((ref),(contents))
#endomdef


/******************************************************************************

   MACRO USED BY GRAPH PRINTER MECHANISM

*******************************************************************************/

#omdef as$printer_init()

asprinter_init(md_env,str,is_it_a_macro)

/* ABSTRACT 
    This primitive has to be called at the begining of a print graph operation.
    Opens the file. Initialize the array to store the name of the elements.
    Initialze the "current symbology" and "current properties"
*/


#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef as$printer_end()
asprinter_end()
#endomdef

/* ABSTRACT 
    This primitive has to be called at the end of a print graph operation.
    Close the file and free the aray used to store the name of the object.
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef as$printer_set_name(objid = my_id,
			   prefix,
			     name)
asprinter_set_name(objid,prefix,name)
#endomdef

/* ABSTRACT 
   this macro creates, stores and returns the name associated with an objid.
   This name is stored in the graph printer array of name. It begins with a
   prefix and ends with an index (for example ASline1). If a name is already
   associated with the objid, a null string is returned.
   (if objid = NULL_OBJID, this test is skipped).

   ARGUMENTS
OM_S_OBJID objid  I : object to associate a name
*char      prefix I : prefix of the name
*char      name   O : returned name

*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef as$printer_get_name(objid = my_id,
			     name)
asprinter_get_name(objid,name)
#endomdef

/*  ABSTRACT 
   Get the printed name associated to objid. If This name already exist,
   returns it. If does not already exist,it prints the object as a root object
   (call as$printet_print_root) and returns the associated name

   ARGUMENTS
OM_S_OBJID objid  I : object whose name is asked
*char      name   O : returned name
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef as$printer_print_root(objid = my_id,
			     osnum = OM_Gw_current_OS,
			     flag  = AS_PR_WITHOUT_REF)
asprinter_print_root(objid,osnum,flag)
#endomdef

/* ABSTRACT 
    This macro prints an element. Associative relationships are lost except
    for connection to a local coordinate system or plane depending upon
    for flag value. If the element is sub class of NDnode it sends it the
    "NDprint_root" message. If not a default print is provided by the function
    to print points, lines, circle, arc of circles and coordinates system.


   ARGUMENTS
OM_S_OBJID objid  I : object to print
GRspacenum osnum  I : object space of the object
IGRint     flag   I : print or not connection to coordinate system
		      AS_PR_WITHOUT_REF doesn't
		      AS_PR_WITH_REF    does
		
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef as$printer_print_symb(symb = NULL,
			     prop = NULL,
			     objid = my_id,
			     osnum = OM_Gw_current_OS)
asprinter_print_symb(symb,prop,objid,osnum)
#endomdef

/* ABSTRACT 
   This macros prints the symbology changes to pass from the current symbology
   stored in the graph printer to  the symbology and properties pass in
   arguments or to  the symbology and properties of objid 

   ARGUMENTS
*GRsymbology symb  I : new symbology, only used if objid != NULL_OBJID
*IGRshort    prop  I : new properties, only used if objid != NULL_OBJID
OM_S_OBJID   objid I : element whose symbology has to be printer. Or NULL_OBJID
		       to print symbology and properties from argument
GRspacenum osnum  I  : object space of the object
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef as$printer_print_parents(objid = my_id,
				osnum = OM_Gw_current_OS,
				list  = NULL,
				size  = 0,
				count = NULL)
asprinter_print_parents(objid,osnum,list,size,count)
#endomdef

/* ABSTRACT 
   this macro prints the parents of an object and return requested information

   ARGUMENTS 
OM_S_OBJID objid  I  : element whose parents have to be printed
GRspacenum osnum  I  : object space of the element
*GRid      list   O  : returned parents if list != NULL
IGRint     size   I  : size of list
*IGRint    count  O  : total number of parents (can be gretter than size) 
		       returned if count != NULL
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef as$printer_print_dir(dir_name=dir_name)
asprinter_print_dir(dir_name)
#endomdef

/* ABSTRACT 
   This message prints the command to create the directories and subdircetories
   necessary to store dir_name (example dir_name = usr1:applic:expression)

   ARGUMENTS
*char dir_name I : name of element
*/
#endif
