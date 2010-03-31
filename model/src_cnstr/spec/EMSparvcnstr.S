/*
  DESCRIPTION

    This is an instantiable class which stands for a fully defined
    vector by virtue of parallelism with an object that yields a vector.

  HISTORY

    SS  :  07/10/91  :  Creation
    jhw :  07/26/91  :  Added GRgetobjinfo override.
*/

class specification EMSparvcnstr (2:0) of EMSimpcnstr;

override 
  EMinit, EMgetgeomlocus;

/* Following message will validate the 'reversed' flag stored as a property
   in this cnstr, by using the paren't normal again. If the parent's normal
   calculation algorithm changes, and if the possibility exists of the normal
   now being computed in the reversed direction, the cnstr can be validated
   using this message.
*/
message EMvalidate_direction(IGRlong *EMmsg; struct GRmd_env *md_env);
end specification EMSparvcnstr;
