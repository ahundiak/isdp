/* ###################   APOGEE COMPILED   ################## */
/*
  ABSTRACT

    This class represents the object that manages shell-objects on a
    per object-space basis. The primary goal of this class is to provide
    a means of maintaining a limited set of some objects in the data-base.
    These objects are typically used once in a while and which serve only
    to enhance the functionality but not the definition of the database.

    In other words, these are objects that are not intended as permanent
    objects in the database but are used temporarily because their
    functionality is useful to the user at the time. Before returning an
    existing object-id, the manager makes some checks by calling a default
    validating-function or invoking a user-defined validating function, to
    see if the object is still an appropriate candidate as the shell-object.
    If not it is removed from this manager's data-base and stored away in an
    "overflow" object which cleans-up when this data-file is going to be
    saved. The mechanism of clean-up invokes the same function used to verify
    the validity of the shell-object. If the object stored in this "overflow"
    object is found to have become a valid shell, it is deleted by the
    Root.delete message.

    There is one such manager object per object-space. It's object-id may
    be stored in a named-object-directory or obtained by doing a pass on an
    object-space with a message that retrieves the object id.

  NOTES

    The various shell objects that are maintained are given to the
    user based on a last-in-first-out criteria which rotates them around.
    On creation the user is able to specify certain characteristics
    of this management scheme - for example: the watermark level upto
    which new objects of a class will be created. After this level is
    reached the LIFO criteria kicks in and returns object-ids that have
    been previously generated.

    None of the shell objects returned should ever be deleted before removing
    them from this shell manager's data-base. The manager always
    assumes the object-ids stored to be valid.
    
  HISTORY

    SS  :  04/06/88  :  Creation
    SS  :  09/17/88  :  Added the EMSshovflow and EMSshcleaner object's.
*/

class specification EMSshobjmgr (1:1) of EMSobjmgr;

instance EMSshobjmgr
  {
  /*
   * These fields define the characteristics of this
   * manager object.
   */

  IGRint watermark;

  /*
   * The following fields store information about all the
   * shell objects that are being maintained by the manager.
   */

  IGRint numclasses;
  variable IGRchar classnames[][OM_K_MAXCLASS_LEN];
  variable GRclassid classids[];
  variable IGRint numobjclass[];
  
  /*
   * The object-ids are stored in this variable 
   * length array.
   */

  IGRint numobjects;
  variable GRobjid objects[];

  /*
   * A channel is declared to an associated store, that
   * will store away the shell's that are removed on
   * overflow.
   */

  channel {(one_to_many)} to_overflow;
  };

override EMinit, EMwakeup, EMsleep, EMtouchobj, EMvalidate, debug, delete;

message EMgetshobj (IGRlong *msg; GRclassid classid; 
                    IGRushort options; IGRchar *const_args;
                    IGRboolean (*constfunc)(); IGRchar *valid_args;
                    IGRboolean (*validfunc)(); GRobjid *shellobj);

message EMremshobj (IGRlong *msg; GRobjid shellobj);

message EMputshobj (IGRlong *msg; GRobjid shellobj; 
                    IGRboolean (*validator_func)());

message EMputovflow (IGRlong *msg; GRobjid shellobj;
                    IGRboolean (*validator_func)());

message EMgetwatermark (IGRint *watermark);

message EMchgwatermark (IGRint watermark);

end specification EMSshobjmgr;
