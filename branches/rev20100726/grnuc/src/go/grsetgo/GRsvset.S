/*
Name
        GRgrset

Description
        The save set is a union of GRgrset and the GRcmpowner.  This class is
        unioned with the GRcmpowner class so that it may own graphics objects.
        This class defines the module environment and the read_only/ write
        property of a group of located objects.  The "to_sets" channel
        inherited from GRgrset associates this saveset to the intermediate
        object which contains the posted objects.  The "to_owner" channel
        connects the save set to the graphics set.

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

class specification GRsvset (1:1) of GRgrset, GRcmpowner;

taggable;

instance GRsvset
{
   struct GRmd_env path;   /* The module environment for the objects    */
};        

override 
   GSpass,              /* GRgrset     -  pass to graphics objects      */
   GScopy,              /* GRgrset     -  copy the graphics objects     */
   GSdisplay,           /* GRgrset     -  display the graphics objects  */
   GSempty,             /* GRgrset     -  remove the graphics objects   */
   GSadd,               /* GRgrset     -  add the graphics objects      */
   GSstart_transition,  /* GRgrset     -  start a transition            */
   GSend_transition,    /* GRgrset     -  end a transition              */
   GSinqcount,          /* GRgrset     -  get the number of graphics obj*/
   GSdelete,            /* GRgrset     -  delete the graphics objects   */
   GSdissolve,          /* GRgrset     -  delete the save set           */
   GRdisyourself,       /* GRgraphics  -  More efficient displays       */
   GSmerge,             /* GRgrset     -  merge the save sets           */
   GSget_object,        /* GRgrset     -  get the graphics object       */
   GSenv_compare,       /* GRgrset     -  compare the environments      */
   GSobject_add,        /* GRgrset     -  add the graphics object       */
   GSto_cpx,            /* GRgrset     -  connect to the to_owners chan */
   GScriteria_pass,     /* GRgrset     -  check the criteria            */
   GS_and_operation,    /* GRgrset     -  perform an and operation      */
   GSremove_member,     /* GRgrset     -  remove component              */
   GSflatten_owners;    /* GRgrset     -  flatten all owners            */

override
   GS_or_operation;     /* GRgrset     -  perform an or operation       */

override GSupdate_path; /* GRgrset     -  update path (module env info) */

/*\
Name
   GSpost_located_object

Description
   This method is used to add a locatd object to a channel so that the
   located object can check to see if it has been located.

Arguments   
   *msg           IGRlong           o   return code 
   *obj_id        struct GRid       i   Located object.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSpost_located_object (IGRlong *msg; struct GRid *obj_id);

/*\
Name
   GScheck_located_object

Description
   This method is used to check is an object has been added to the
   located objects channel.

Arguments
   *msg           IGRlong           o   return code 
   *obj_id        struct GRid       i   Located object.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GScheck_located_object (IGRlong *msg; struct GRid *obj_id);

/*\
Name
   GSsvinit

Description
   This method initializes a save set.

Arguments
   *msg            IGRlong          o   return code
   *path           struct GRmd_env  i   Structure containing the new module
                                        environment.
   *env_properties IGRint           i   Properties of the environment.
   *preset         IGRint           i   An approximation of the number of
                                        elements that may be added to the
                                        save set channel.    

Note
   The preset variable maybe NULL.
   The path variable maybe NULL.
   The env_properties variable maybe NULL.
   If the preset variable is specified, call the GSunpreset message
   to collapse the channel.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSsvinit (IGRlong *msg; struct GRmd_env *path;
                  IGRint *env_properties; IGRint *preset);

/*\
Name
   GSunpreset

Description
   This method collapses the channel set by the GSsvinit message.

Arguments
   *msg            IGRlong       o   return code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GSunpreset (IGRlong *msg);

end specification GRsvset;
