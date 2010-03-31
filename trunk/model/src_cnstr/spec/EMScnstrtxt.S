/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This is an instantiable class which serves as the text handle
    for geometric constraints.

  HISTORY

    jhw  :  07/25/91  :  Creation
*/

class specification EMScnstrtxt (2:0) of NDnodein, GR3dtext;

override 
/*
 * Return the type as other_generic
 */
  NDgive_structure,
/*
 * Return success.
 */
  NDupdate,
/*
 * Return that I am only valid for drop macro.
 */
  ACbecome_macro,
/*
 * Copy myself and add to the rtree
 */
  NDcopy,
/*
 * Return myself.
 */
  ASreturn_go,
/*
 * Override to display myself
 */
  NDdisplay,
/*
 * Copy myself nonassociatively
 */
  ACcopy_to_Groot;

end specification EMScnstrtxt;
