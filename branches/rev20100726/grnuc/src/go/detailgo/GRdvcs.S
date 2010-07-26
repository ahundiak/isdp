/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class represents the drawing view coordinate system.

History
   Gray Winn   07/11/88    Design and Coding Date.
\*/

class specification GRdvcs (1:0) of GRgencs;

override GRdelete;


/*\
Name
   GRset_active_cs

Description
   This method makes the coordinate system active.

Arguments
   *msg           IGRlong              o   completion code 
   *mod_env       struct GRmd_env      i   module environment

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRset_active_cs (IGRlong *msg; struct GRmd_env *mod_env);

end specification GRdvcs;
