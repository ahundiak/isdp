/*
/*---------------------------------------------------------------------------
/*
/*  ABSTRACT
/*---------------------------------------------------------------------------*/
class specification ACdiowner (0:1) of IGRdir,NDmacro,GRowner;
#include "ACattrib.h"

struct ACattr
  { int  name; /* its name */
    int  index; /* its index on the owner channel */
  };


instance ACdiowner
  {
   int nb_attr; 			    /* nb of attributes               */
   variable struct ACattr  attr_def[1];     /* describtion of the attributes  */
   variable char  attr_name[1];		    /* array to store attribute names */
  };

override unknown;

override ACgive_structure,
         ACreturn_foot; /* return the  attribute with a given name */

override GRget_locate_properties,   /* locate component			    */
	 GRget_channel_type,        /* return flexible 			    */
         GRcomponent_disconnecting; /* update attributes index,             */
				    /* delete ACdiowner and attribute when  */
				    /* last element disconnect ?            */

override GRgetobjinfo;

/* override Directory staff */

override dump,             /* print the attributes in the directory form    */
         translate,	   /* specific implementation 			    */
         add,		   /* does not allow add component by name          */
         delete,           /* to remove the name 			    */
         GRdelete,         /* to remove the name 			    */
	 GRdelete_owner,   /* to remove the name 			    */
	 GRcopy,           /* Get a new name to the clone		    */

         GRgetname,        /* update directory global table                 */
	 GRputname,        
	 GRchgname;



message ACadd_attribute(IGRlong *msg;
			IGRchar *name; IGRchar *syntax);

/* ABSTRACT 
   add an attribute to the owner
   - if the syntax of the attribute can be parsed, the attribute is created
     as a double expression 
   - if not the attribute is created as a text expression.
  
   It only calls ACadd_attribute_by_type with
   type =AC_ATTRIB_TYPE_NOT_DEF

   ARGUMENTS
msg    O : completion code MSSUCC or MSFAIL
name   I : name of the attribute
syntax I : syntax of the attribute

    WARNING
If the attribute already exists, its value is not modified

    NB
The function ACreturn_diowner(go_id,owner)
             struct GRid *go_id,*owner;
returns the ACdiowner of a component, if it exists.
It returns NULL_GRID if not.

*/

message ACadd_attribute_by_type(IGRlong *msg; IGRint type;
			IGRchar *name; IGRchar *syntax);

/* ABSTRACT 
   add an attribute to the owner, specifying the type of the attribut

   ARGUMENTS
same as ACadd_attribute 
+
type  I : possible type of the attribute
		AC_ATTRIB_TEXT         The attribute will be a text 
		AC_ATTRIB_DOUBLE       The attribute will be a double 
				       (if its syntax can be parsed ....)
		AC_ATTRIB_TYPE_NOT_DEF Both will be obtained as explain in the
				       ACadd_attribute message
           
*/

message ACrem_attribute(IGRlong *msg;
			IGRchar *name);

/* ABSTRACT 
   remove an attribute from the owner

   ARGUMENTS
msg    O : completion code MSSUC or MSFAIL
name   I : name of the attribute to remove
    WARNING
When the last attribute is deleted, the diowner is dissolved
*/


message ACmod_attribute(IGRlong *msg;
			IGRchar *name; IGRchar *syntax);

/* ABSTRACT 
   Modify the value of an attribute. This modification maintains the type
   of the attribute (text or double).

   ARGUMENTS
msg    O : completion code MSSUC or MSFAIL
name   I : name of the attribute to remove

    WARNING
If the attribute with the given name does not exist, it is not created.
If the new syntax of a double attribute can not ne parsed, the previous
value is maintained
*/

message ACcreate(IGRlong *msg;
		 IGRchar *name);

/* ABSTRACT
Initialize a diowner and add it in the directory tree.

   ARGUMENTS
msg    O : completion code MSSUC or MSFAIL
name   I : name of the diowner. If a NULL pointer is passed, a default
           name "attrib##" is generated 
*/

message ACadd_component(IGRlong *msg; struct GRid *component);

/* ABSTRACT 

Add a graphic component to a di_owner

ARGUMENTS
msg       O : completion code MSSUC or MSFAIL
component I : GRid of the graphic component
*/


message ACadd_component_with_name(IGRlong *msg; struct GRid *component;
				  IGRchar *name);

/* ABSTRACT 

Add a graphic component to a di_owner. This graphic component has a name that
will be stored by the diowner. ( In fact the component does not need to be
"graphic" as long as it supports the owner protocol).


ARGUMENTS
msg       O : completion code MSSUC or MSFAIL
component I : GRid of the graphic component
name      I : Name of the component
*/

message ACrem_att_at_index(IGRlong *msg;
			   IGRint index);

/* ABTRACT

   PRIVATE MESSAGE

*/

message ACgive_path(IGRlong *msg;
		    struct GRid *go_obj;
		    char *name);

/* ABTRACT

   PRIVATE MESSAGE

*/


end specification ACdiowner;
