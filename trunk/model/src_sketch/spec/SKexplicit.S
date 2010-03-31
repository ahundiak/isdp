/*
  DESCRIPTION

   This is an abstract class which us the super-class of all the classes
   representing dimensional constraints.
*/

class specification SKexplicit (2:0) of expression, SKconstraint;

message SKgetval (IGRlong *msg; IGRdouble *value);

#ifndef BASE_EMS

message SKputval (IGRlong *msg; IGRushort opts;
                  IGRdouble value; IGRchar *rhs);


message SKstoreval (IGRlong *msg; IGRdouble value);

message SKcreate_expression(IGRlong *EMmsg; IGRchar *name; IGRdouble value);

message SKevalpseudoeqn (IGRlong *msg; IGRushort opts;
                         struct SKsolvevars **solvedvars, *tosolvevar;
                         struct SKsolvevars **oversolv_vars, **nosolv_vars);

message SKgetname (IGRlong *msg; IGRushort opts; IGRchar *name);

/*   Method to called by dim code in case of reference file detach/delete 
	--   Satya -- 9th Jan 95 */
message SKexplicit_clean_up(IGRlong *msg; struct GRmd_env *md_env);

/* ****************** PRIVATE MESSAGE **************************** */

message SKmanage_expression_vla(IGRlong *msg; 
                              unsigned int options;
                              IGRint *size;
                              IGRchar *strng);

/* ******************************************************************

 Description
 This message is used to initialise the expression vla instance data.
 It stores the string that is coming in, into the expression vla.

 Arguments
 options : 0x1 : stores the incoming string into the vla.
           0x2 : copies the string stored in the vla into the
                 incoming field.
 size : Size of the string in question.
 strng : Incoming string. If options is 0x2 and this field is NULL then
         only size is returned.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure
 MSINARG : If invalid arguments

History
 Creation : PP :07/30/91
******************************************************************** */


 
                     
override
  GRcopy,
  debug,
  modify,
  NDdisplay, NDget_objects, NDcompute_node,
  GRaddwrng, GRremwrng, GRgetobjinfo,
/*
 * This override will indicate that manager can only participate in
 * a drop macro for now. pp 07/24/91
 */
  ACbecome_macro,
/*
 * Return success since the copy of the same is handled by
 * the manager. pp 07/24/91 
 */
  NDcopy_graph,
/*
 * Copy myself with my dimension, if I am a root element.
 * pp  08/16/91
 */
  ACcopy_to_Groot,
/*
 * Do not copy myself, as the manager copies me.
 * pp 08/16/91
 */
  NDcopy_to_root,
/*
 * Do not copy myself, as the manager copies me.
 * pp 08/16/91
 */
  NDcopy,
/*
 * call parent delete for children in GRdelete       - GMK 11/24/93
 */
  GRdelete,
  NDparent_deleted,
  SKrecompute_yourself, SKcreate_geom, SKgetpseudovarlist;

override 	GRanalyze_element;

#endif

end specification SKexplicit;


