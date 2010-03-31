/*
 * Class :
 *
 *      EMinstance
 *
 * Abstract :
 *
 *      This class defines the behavior for parts in the
 *      assembly modeling system. An instance of this class defines
 *      an occurrence of a part and that occurrence is contained
 *      in a EMcachepart directory which stores occurrences and definition
 *      attributes. There are two types of EMinstances: 1) Reference parts 
 *      whose definition is stored in another file and 2) Graphic parts whose
 *      definition is stored in the assembly file itself.
 *
 * History :
 *
 *      Jay Wallingford     3/25/93  Creation date.
 *      jhw                 7/20/93  Modified for new part classes.
 *      Gang                7/4/94   Override EMupdate_display.
 *
 * Notes :
 *
 * Bugs :
 *
 */
class specification EMinstance (1:1) of NDnodein, EMdescribe, GRowner;

#include "assemdef.h"
#include "assem.h"


instance EMinstance
{
    unsigned int basis;
};

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_part                                                       |
 |                                                                           |
 | This message returns the part definition object for this instance.        |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          struct GRid * part_id   Part id.                                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_part (IGRlong     *  msg; 
                    struct GRid * part_id );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_incident_constr                                            |
 |                                                                           |
 | This message returns the incident constraints on this part instance.      |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          IGRint *pnum_incident_constr  Number of incident constraints.    |
 |          struct GRid incident_constr[] The incident constraints.          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_incident_constr (IGRlong *msg; 
                               IGRint *pnum_incident_constr;
                               struct GRid incident_constr[]);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_reversible_constr                                          |
 |                                                                           |
 | This message returns the reversible constraints on this part instance.    |
 | The reversible constraints are wrt a particular candidate constraint.     |
 |                                                                           |
 | Input :  struct GRid candidate_constr  Candidate constraint under         |
 |                                        under consideration.               |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          IGRint *pnum_reversible_constr  Number of incident constraints.  |
 |          struct GRid reversible_constr[] The reversible constraints.      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_reversible_constr (IGRlong *msg;
                                 struct GRid candidate_constr;
                                 IGRint *pnum_reversible_constr;
                                 struct GRid reversible_constr[]); 



/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMcheckbasis                                                      |
 |                                                                           |
 |  This method checks for the correct basis to position the part.           |
 |                                                                           |
 |  The constraints incident on the part are passed in as                    |
 |  arguments.                                                               |
 |                                                                           |
 |  Inputs:                                                                  |
 |                                                                           |
 |  IGRint num_inc 		                The # of incident constr     |
 |  struct GRid incident_constr[]		The incident constraints     |
 |                                                                           |
 |  Outputs:                                                                 |
 |                                                                           |
 |  IGRlong * msg                               Return code                  |
 |  unsigned int *pbasis_id                     The basis id                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/

message EMcheckbasis(IGRlong *msg;
                     IGRint num_inc;
                     struct GRid incident_constr[];
                     unsigned int *pbasis_id);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMconstr_deleted                                                 |
 |                                                                           |
 | This message is sent by the constraint to be deleted to Part instance     | 
 |                                                                           |
 | Input :  struct GRid deleted_constr  constraint to be deleted             |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/


message EMconstr_deleted(IGRlong *msg; struct GRid deleted_constr);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMchange_part                                                    |
 |                                                                           |
 | This message will change the instance of a part to another part type.     |
 |                                                                           |
 | Input:   struct GRid * new_part      New Part Definition.                 |
 |          struct GRid * new_graphic   New Graphic Definition.              |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 | Note:                                                                     |
 |                                                                           |
 | There is a restriction that a instance can only be change between part    |
 | types which are in the same object space.                                 |
 | History:                                                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMchange_part (IGRlong           * msg;
                       struct GRmd_env   * mod_env;
                       struct GRid       * new_part;
                       struct GRid       * new_graphic);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMlink_part_attr                                                 |
 |                                                                           |
 | This message will create an attribute on the instance object which is     |
 | "linked" to the attribute on that instance's part object with the         |
 | specified name.                                                           |
 |                                                                           |
 | Input:   IGRchar     * name       Name of the attribute to link.          |
 |                                                                           |
 | Output:  IGRlong     * msg        Return code, MSSUC or MSFAIL for now.   |
 |          EMattr      * attr       Attribute constructed.                  |
 |                                                                           |
 | Note: At present an expression object is created which has the part's     |
 |       attribute as a parent. In the future an ACdyn_col may be created    |
 |       and maintained to store the "links" instead of creating a number    |
 |       of expression objects, if this happens the id returned in the       |
 |       EMattr structure will be an ACpretend object's id instead of        |
 |       expression id.                                                      |
 |                                                                           |
 |       The EMget_attr message on EMinstance will return link attributes if |
 |       the EM_LINK_ATTR type is specified.                                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMlink_part_attr  (IGRlong     *  msg;
                           IGRchar     *  name;
                           EMattr      *  attr);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMrelink_part_attr                                               |
 |                                                                           |
 | This message will relink an attribute on the instance object which has    |
 | been linked with the EMlink_part_attr to the cooresponding attribute on   |
 | the instance's new part. This will be used after an instance is changed   |
 | from one part type to another or any time an instance which has a linked  |
 | attribute needs to rebind to it's part's attribute.                       |
 |                                                                           |
 | Input:   IGRchar     * name      Name of the attribute to relink.         |
 |          IGRint        index     Index of attribute to relink.            |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          EMattr      * attr      Attribute constructed.                   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMrelink_part_attr (IGRlong     *  msg; 
                            IGRchar     *  name;
                            IGRint         index;
                            EMattr      *  attr);


/* Given the Featureid return the contextid */
message EMget_feature_context( IGRlong *rc; struct GRid *feature_id; 
					struct GRid *cntxt_id );

message EMgivebasis( IGRlong *rc; IGRuint *basis );

message EMupdatebasis( IGRlong *rc );

message EMcompute_xform_matrix( IGRlong *rc; struct GRid *list; IGRint count;
                                    IGRmatrix matrix );

/* 
 * Root Overrides
 */
override unknown,
         delete,
         debug;

/*
 * Graphic Overrides
 */
override GRgetobjinfo,
         GRgetname,
         GRputname,
         GRchgname,
         GRdelete,
         GRcopy,
         GRcptform;

/*
 * Connector Overrides
 */
override GRflexconn,
         GRrigidconn;

/*
 * Owner Overrides
 */
override GRcomponent_disconnecting,
         GRrigid_connecting,
         GRcomponent_idchanged,
         GRdelete_owner,
         GRcopy_owner,
         GRdrop,
         GRget_channel_type,
         GRget_locate_properties;

/*
 * Describe Overrides
 */
override EMconstruct,
         EMlegal_memb_op,
         EMget_memb_type,
         EMdefault_memb_type,
         EMadd_memb,
         EMrem_memb,
         EMpass,
         EMset_display,
         EMset_behavior,
         EMupdate,
	 EMupdate_display;

/*
 * Associative Overrides
 */
override NDcopy,
         NDdelete,
         NDdisplay,
	 NDcompute_node,
	 NDmove_to_root,
	 NDgive_structure,   /* return other_generic */
	 ASreturn_go;	     /* return myself */

end specification EMinstance;




