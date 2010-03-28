/*
Name
        GRgrset

Description
        The Graphic Set class is a subclass of GRgraphics. Subclassing from
        GRgraphics allows for efficient displays of the set members.  This
        class serves as a common point to declare all messages common to the
        graphic sets.

Notes
        This class is used as a temporary grouping object for group generators
        such as "Elements in Fence".  It is *not* intended for use as a
        permanent group, and should never be saved in a file object space.
        Permanent grouping functionality is provided by the graphic group
        class GRgrgrp.

Keywords
        graphic-set

History
        Gray Winn   11/02/86    Design and Coding Date.
        Gray Winn   09/18/87    Changes for 1.1
        mrm         01/27/93    made this a taggable class
*/

class specification GRgrset (1:1) of GRgraphics;

#include "growner.h"

taggable;

instance GRgrset
{
   /*
    *  properties - is used to represent the properties. See
    *               grgsdef.h for definition of properties.
    *  current_sv - is used to represent the current saveset during 
    *               locate.
    *  to_owner   - is a channel that connects the graphics set to
    *               the command_object or the save set to the graphics
    *               set.
    *  to_sets    - is a channel that connects the graphics set to the
    *               save set or the save set to the intermediate object
    *               that contains the posted objects.
    */

   IGRint         properties;
   struct   GRid  current_sv;
   channel 
   {
      (many_to_many,
       rel_ordered,
       initial=1,
       increment=1)
   } to_owners;

   channel 
   {
      (many_to_many,
       rel_ordered,
       initial=1,
       increment=1)
   } to_sets;
};        

/*
 *  The following GRgraphics methods are overriden so that the graphics
 *  set can respond to certain messages from the locate filter in the
 *  same way as a graphics object.
 */

override
   GRgetobjinfo, /* GRgraphics   -  Returns that this is a group.    */
   GRdisplay;    /* GRgraphics   -  Displays the graphics set.       */

/*\
Name
   GSpass

Description
   This method is used for the graphic sets to pass a mesage on to
   all graphics objects that it owns.

Arguments
   *msg           IGRlong              o   return code 
   pass_msg       OM_p_MESSAGE         i   Message to be passed
   *path          struct GRmd_env      i   Pointer to the data within the 
                                           message which contains the 
                                           module environment.

Notes
   The path argument may be NULL which means the message does not
   need the module environment.

Return Values
   MSSUCC   -  if successful.
\*/
message GSpass (IGRlong *msg; OM_p_MESSAGE pass_msg; 
                struct GRmd_env *path);

/*\
Name
   GScopy

Description
   This method is used to make a copy of the original objects.  This 
   method disconnects the original object. The objects are copied to 
   the target_env.  If a matrix is supplied the object will be
   transformed by the matrix after the copy operation.

Arguments
   *msg           IGRlong           o   return code 
   *target_env    struct GRmd_env   i   Environment to copy objects to.
   matrix         IGRmatrix         i   Matrix defining transformation.
   *owner_id      struct GRid       i   Owner object.

Notes
   If matrix is NULL then copy else call copy and transform.
   The owner_id argument may be NULL.  If the argument is NULL then 
   the copies are connected to the graphics set.  If it is not NULL
   it must contain the object id of a save set to which the copied
   objects will be connected.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GScopy (IGRlong *msg; struct GRmd_env *target_env; 
                IGRmatrix matrix; struct GRid *owner_id);

/*\
Name
   GSdisplay

Description
   This method is used to display the objects owned by the graphics set.

Arguments
   *msg         IGRlong          o   return code
   *dpmode      enum GRdpode     i   An enum type representing display mode
   *display_id  struct GRid      i   Object id of the window or module

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSdisplay (IGRlong *msg; enum GRdpmode *dpmode;
                   struct GRid *display_id);

/*\
Name
   GSempty

Description
   This method is used to remove all graphics objects from the 
   graphics set.

Arguments
    *msg           IGRlong          o   return code
    *owner_id      struct GRid      i   Owner object.
    owner_chansel  OM_p_CHANSELECT  i   Channel of the owner object.

Notes
   The owner_chansel and owner_id can be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSempty (IGRlong *msg; struct GRid *owner_id; 
                 OM_p_CHANSELECT owner_chansel);

/*\
Name
   GSadd

Description
   This method is used to add an object to the current graphics set.

Arguments
   *msg         IGRlong       o   return code 
   *obj_id      struct GRid   i   The object id of the object to be
                                  added to the save set.
   *rp_relation IGRint        i   contains the relationship with the
                                  right prism (i.e. inside, outside,
                                  or overlap)
Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSadd (IGRlong *msg; struct GRid *obj_id; IGRint *rp_relation);

/*\
Name
   GSstart_transition

Description
   This method is used to define the start of a different environment.

Arguments
   *msg            IGRlong          o   return code
   *path           struct GRmd_env  i   Structure containing the new module
                                        environment.
   *env_properties IGRint           i   Properties of the environment.
   *cur_sv_id      struct GRid      i   The object id of the previous 
                                        saveset.
   *new_sv_id      struct GRid      o   The object id of the saveset 
                                        initilazed.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSstart_transition (IGRlong *msg; struct GRmd_env *path;
                           IGRint *env_properties; struct GRid *cur_sv_id;
                           struct GRid *new_sv_id);

/*\
Name
   GSend_transition

Description
   This method is used to define the end of an environment and the 
   transition to the previous environment.

Arguments
   *msg         IGRlong          o   return code 
   *sv_id       struct GRid      o   The object id of the current saveset.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSend_transition (IGRlong *msg; struct GRid *sv_id);

/*\
Name
   GSinqcount

Description
   This method is used to return the number of components owned 
   by the graphics set.

Arguments
   *msg         IGRlong       o   return code
   *count       IGRint        o   Number of object owned by set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSinqcount (IGRlong *msg; IGRint *count);

/*\
Name
   GSdelete

Description
   This method is used to delete all the members of the graphics set.

Arguments
   *msg         IGRlong       o   return code 

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSdelete (IGRlong *msg);

/*\
Name
   GSdissolve

Description
   This method is used to disconnect all members from the graphics
   set and then delete the graphics set.

Arguments
   *msg           IGRlong        o   return code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSdissolve (IGRlong *msg);

/*\
Name
   GSpost_processing

Description
   This method is used to do any post processing needed by the 
   graphics set.

Arguments
   *msg         IGRlong          o   return code
   *target_env  struct GRmd_env  i   Environment to copy objects to.
   *owner_id    struct GRid      i   Owner object.
   copy_flag    IGRint           i   Flag if 1 then copy and post process. 

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSpost_processing (IGRlong *msg; struct GRmd_env *target_env; 
                           struct GRid *owner_id; IGRint copy_flag);

/*\
Name
   GSinit

Description
   This method is used to initialize the graphics set.

Arguments
    *msg           IGRlong          o   return code
    *properties    IGRint           i   The properties of the set
    *owner_id      struct GRid      i   Owner object
    owner_chansel  OM_p_CHANSELECT  i   Channel of the owner object

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSinit (IGRlong *msg; IGRint *properties; struct GRid *owner_id; 
                OM_p_CHANSELECT owner_chansel);

/*\
Name
   GSget_object

Description
   This method will return the object and module environment for the
   objects between from_obj and to_obj.

Arguments
   *msg          IGRlong               o   return code
   array[]       struct GRobj_env      o   An array of GRid's and module
                                           environments.
   array_size    IGRint                i   Size of array in BYTES.
   *count        IGRint                o   The number of objects returned.
   from_obj      IGRint                i   The base index
   to_obj        IGRint                i   The high index

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSget_object (IGRlong *msg; struct GRobj_env array[];
                      IGRint  array_size; IGRint *count; IGRint from_obj; 
                      IGRint to_obj);

/*\
Name
   GSmerge

Description
   This method will merge this graphics set into the graphics set
   passed in gs_id.

Arguments
   *msg          IGRlong            o   return code
   *gs_id        struct GRid        i   The object id of the target 
                                        graphics set.
   *owner_id     struct GRid        i   The object id of the owner channel.
   gs_sel        OM_p_CHANSELECT    i   graphics set channel select.
   owners_sel    OM_p_CHANSELECT    i   The owners channel select.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSmerge (IGRlong *msg; struct GRid *gs_id; struct GRid *owners_id;
                OM_p_CHANSELECT gs_sel; OM_p_CHANSELECT owners_sel);

/*\
Name
   GSobject_add

Description
   This method is used to add an object to an existing graphics set.

Arguments
   *msg              IGRlong           o   return code
   *obj_id           struct GRid       i   The object id of object added 
                                           to the save set.
   *path             struct GRmd_env   i   Module environment.
   *env_properties   IGRint            i   environment properties.
   *target_id        struct GRid       i   The object id of the owner.
   target_sel        OM_p_CHANSELECT   i   The owner's channel.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSobject_add (IGRlong *msg; struct GRid *obj_id;
                     struct GRmd_env *path; IGRint *env_properties;
                     struct GRid *target_id; OM_p_CHANSELECT target_sel);

/*\
Name
   GSenv_compare

Description
   This method will compare the module environment and properties
   of a graphics set with another graphics set.

Arguments
   *msg              IGRlong           o   return code
   *mod_env          struct GRmd_env   i   module environment
   *env_properties   IGRint            i   module properties.
   *sv_id            struct GRid       o   the save set with the given env.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSenv_compare (IGRlong *msg; struct GRmd_env *mod_env;
                       IGRint *env_properties; struct GRid *sv_id);

/*\
Name
   GSto_cpx

Description
   This method will connect the graphics objects to_cpx channel to
   the members channel.

Arguments
   *msg          IGRlong            o   return code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSto_cpx (IGRlong *msg);

/*\
Name
   GS_and_operation

Description
   This method will perform a logical AND of this graphics set and the
   graphics set passed in gs_id.  This will become the resulting
   graphics set.

Arguments
   *msg          IGRlong            o   return code
   *gs_id        struct GRid        i   The object id of the graphics set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GS_and_operation (IGRlong *msg; struct GRid *gs_id);


/*\
Name
   GS_or_operation

Description
   This method will perform a logical OR of this graphics set and the
   graphics set passed in gs_id.  This will become the resulting
   graphics set.

Arguments
   *msg          IGRlong            o   return code
   *gs_id        struct GRid        i   The object id of the graphics set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GS_or_operation (IGRlong *msg; struct GRid *gs_id);

/*\
Name
   GScriteria_pass

Description
   This method will check each of its objects for the given criteria
   if the object does not pass the criteria it will be removed from
   the graphics set.  This method will use the same structures
   as locate to define the search criteria.

Arguments
   *msg              IGRlong              o   Return code
   *loc_env          struct GRmd_env      i   The environment for a locate
   *attributes       struct GRlc_locate   i   The attributes describing the
                                              criteria that the object must
                                              pass.
   *classinfo        struct GRlc_classes  i   The classes to be located
   *levels           IGRchar              i   The levels to search.

Notes
   If levels are NULL then elements on all levels will be accepted.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GScriteria_pass (IGRlong *msg; struct GRmd_env *loc_env;
                         struct GRlc_locate *attributes;
                         struct GRlc_classes *classinfo;
                         IGRchar *levels);
/*\
Name
   GSundo_save

Description
   This method is used to set up the global undo object so that the 
   next operation can be undone.  This method requires a function to
   be invoked to undo the operation, its arguments, and the size of
   its arguments.  The owner_id and owner_chansel are passed if the cloned
   version is to be connected to the owner and not to the global
   undo object.

Arguments
   *msg           IGRlong           o   return code
   (*fun)()       IGRint            i   Address of the function to be 
                                        invoked when an operation is undone
   *args          IGRchar           i   The arguments to the undo function.
   *args_size     IGRint            i   The size of the undo arguments.
   *owner_id      struct GRid       i   Owner object id.
   owner_chansel  OM_p_CHANSELECT   i   The address of the owner channel.

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GSundo_save (IGRlong *msg; IGRint (*fun)();
                     IGRchar *args; IGRint *args_size;
                     struct GRid *owner_id; 
                     OM_p_CHANSELECT owner_chansel);


/*\
Name
   GSremove_member

Description
   This method is used to remove a member of the graphics set.  The
   member does not necessarily have to belong to the graphics set.

Arguments
   *msg           IGRlong           o   return code
   *member_id     struct GRid       i   The member id

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GSremove_member (IGRlong *msg; struct GRid *member_id);

/*\
Name
   GSflatten_owners

Description
   This method is used to flatten an owner object into its components.
   A three stage check is performed upon an object to see if it should
   be flattened.  The first check is to see if the object is a subclass
   of GRowner.  If it passes the first check, the object is compared to 
   the list of owner classes to be flattened.  If the owner object is
   not found within the class list, the owner object will be compared 
   against the requested properties (i.e rigid or flexible) to determine
   if it should be flattened.
   
Arguments
   *msg              IGRlong              o   Return code
   *attributes       struct GRlc_locate   i   The attributes describing the
                                              criteria that the object must
                                              pass.
   *eligible_classes OM_S_CLASSLIST       i   The eligible classes
   *owner_classes    OM_S_CLASSLIST       i   The owner classes
   owner_properties  IGRint               i   The owner properties
                                              0 - do not flatten
                                              1 - flatten rigid owners
                                              2 - flatten flexible owners
                                              3 - flatten all owners
   *gs_id            struct GRid          i   The graphics set
   gs_chansel        OM_p_CHANSELECT      i   The graphics set channel
   *command_id       struct GRid          i   The command id
   command_chansel   OM_p_CHANSELECT      i   The command channel
   *object_id        struct GRid          o   The id of new graphics set

Notes
   The owner_classes may be NULL.
   One of the following sets of information must be supplied the other
   sets may be NULL:
      -  The gs_id and gs_chansel
      -  The command_id and the command_chansel
      -  The object_id

   The owner_properties are applied if and only if the object was not
   specifically selected by the owner_classes.  If the owner_classes
   is a list of classes not to be flatted (i.e negation), the locate
   propeties of the classes not listed will be checked against the 
   owner_properties to determine if they should be flattened.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure
\*/
message GSflatten_owners (IGRlong *msg; struct GRlc_locate *attributes;
                          OM_S_CLASSLIST *eligible_classes;
                          OM_S_CLASSLIST *owner_classes;
                          IGRint owner_properties; struct GRid *gs_id;
                          OM_p_CHANSELECT gs_chansel;
                          struct GRid *command_id;
                          OM_p_CHANSELECT command_chansel;
                          struct GRid *object_id);

/*\
Name
   GRchg_properties

Description
   Given a mask, this method adjusts the object's properties by clearing
   or setting the properties with the mask.

Arguments
   *msg           IGRlong     o   completion code
   action         IGRint      i   indictor of whether to set or clear the 
                                  properties 
                                    0     - clear using mask
                                    1     - set with mask
                                    2     - replace with mask
   *mask          IGRint      i   mask used to set/clear properties

Return Values
   MSSUCC  if successful
\*/
message GRchg_properties (IGRlong *msg; IGRint action; IGRint *mask);
 
/*\
Name
   GRget_properties

Description
   This method will return the object's properties.

Arguments
   *msg           IGRlong     o   completion code
   *mask          IGRint      o   mask used to retreive the properties

Return Values
   MSSUCC  if successful
\*/
message GRget_properties (IGRlong *msg; IGRint *properties);

 
/*\
Name
   GSupdate_path

Description
   This method will update the save sets' path (module environment info.).

Arguments
   *msg           IGRlong          o   completion code
   *path          struct GRmd_env  o   new path

Return Values
   MSSUCC  if successful
\*/
message GSupdate_path (IGRlong *msg; struct GRmd_env *path);

end specification GRgrset;
