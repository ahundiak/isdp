/*
  DESCRIPTION

    This is an instantiable class which stands for a fully defined
    vector which is perpendicular to the plane of an object or perpendicular
    to a line-segment in a given plane.

  HISTORY

    SS  :  10/23/91  :  Creation
*/

class specification EMSpervcnstr (2:0) of EMSimpcnstr;

override 
  EMinit, EMgetgeomlocus;

/* Following message will validate the 'reversed' flag stored as a property
   in this cnstr, by using the paren't normal again. If the parent's normal
   calculation algorithm changes, and if the possibility exists of the normal
   now being computed in the reversed direction, the cnstr can be validated
   using this message.
*/
message EMvalidate_direction(IGRlong *EMmsg; struct GRmd_env *md_env);

end specification EMSpervcnstr;
