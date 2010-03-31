/*

Name
  EMconstr.S

Description
  This file has the class definition for the Assembly Constraint instance.

Notes

History
 04/09/93 : Kapil Singh (KS): created
 09/11/93 : Krishna kumar (KK): added get_offset, set_offset
 */


class specification EMconstr (0:1) of NDnodein;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "emsdef.h"
#include "emserr.h"
#include "AS_status.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"


#include "assemdef.h"
#include "assem.h"
#include "assemconstr.h"
#include "assemmacros.h"



  instance EMconstr 
  {
    IGRboolean is_visited;        /* Has the constraint been visited during rectification */        
    unsigned short error_flags;   /* flags for error in evaluation of constraints */
    unsigned int attr_flags;      /* For FUTURE use */
    FEATURE_ID feature_one;       /* 1st of the two features on which the constraint acts */
    FEATURE_ID feature_two;       /* 2nd of the two features on which the constraint acts */
  }; 


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMinit_constraint                                                |
 |                                                                           |
 | This message initiliazes the constraint instance.                         | 
 |                                                                           |
 | Input: struct GRid part_one    1st part to which the constr is attached   |
 |        struct GRid part_two    2nd part to which the constr is attached   |
 |        FEATURE_INFO feature_one 1st feature on which constraint applies    |
 |        FEATURE_INFO feature_two 2nd feature on which constraint applies    |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
 
message EMinit_constraint(IGRlong *msg;
                           struct GRid part_one;
                           struct GRid part_two; 
                           FEATURE_INFO feature_one;
                           FEATURE_INFO feature_two);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMmark_visited                                                   |
 |                                                                           |
 | This message marks a constraint as visited during mating graph traversal. | 
 |                                                                           |
 | Input:   IGRboolean do_mark    TRUE to mark constr                        |
 |                                FALSE to unmark constr                     |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
                      

message EMmark_visited (IGRlong *msg; IGRboolean do_mark);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMis_constr_visited                                            |
 |                                                                           |
 | This message determines if a constraint has been visited during mating    |
 | graph traversal.                                                          | 
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRboolean *ptr_is_visited  TRUE if constr has been visited      |
 |                                                                           |
 +---------------------------------------------------------------------------*/


message EMis_constr_visited (IGRlong *msg; IGRboolean *ptr_is_visited);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMreverse_direction                                              |
 |                                                                           |
 | This message toggles direction of the constraint      		     |
 |                                                                           |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/

message EMreverse_direction (IGRlong *msg);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMgetpart                                                      |
 |                                                                           |
 | This message gets one of the part grids to which the constraint is        |
 | attached. If "is_incident" is TRUE, ==> the part on which the constraint  |
 | is incident is to be returned.                                            |
 |                                                                           |
 | Input:   IGRboolean is_incident  if TRUE return part on which the         |
 |                                  constraint is incident                   |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          struct GRid *ppart_grid the part attached to the constraint.     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

message EMgetpart (IGRlong *msg; IGRboolean is_incident; struct GRid  *ppart_grid);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_feature                                                    |
 |                                                                           |
 | This message gets one of the features on which the constraint applies.    |
 | If "is_incident" is TRUE, ==> the feature on which the constraint         |
 | is incident is to be returned.                                            |
 |                                                                           |
 | Input:   IGRboolean is_incident  if TRUE return feature on which the      |
 |                                  constraint is incident                   |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          struct GRid *pfeature_grid the feature id.                       |
 |                                                                           |
 +---------------------------------------------------------------------------*/

message EMget_feature (IGRlong *msg; IGRboolean is_incident; 
                       struct GRid *pfeature_grid);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMprocess_constr_addition                                        |
 |                                                                           |
 | This message is called to process the addition of an assembly constraint. |
 | A check is done for overconstrained assembly.                             |
 |                                                                           |
 | Input:                  	                                             |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRint *pnum_conflconstr  If overconstrained, the number of      |
 |                                     conflicting constrs                   |
 |          struct GRid **ppconflconstr_grid  If overconstrained, conflicting|
 |                                            constrs                        |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/

message EMprocess_constr_addition(IGRlong *msg; IGRint *pnum_conflconstr;
                                  struct GRid **ppconflconstr_grid);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMfind_overconstr                                                |
 |                                                                           |
 | This message tries to find a path to underconstrained assembly. If such   |
 | a path cannot be found, it identifies the subset of assembly which is     |
 | overconstrained.                                                          | 
 |                                                                           |
 | Input:   IGRboolean first_direction Is it the first search direction.     |
 |                                                                           |
 | Output:  IGRlong *msg                Return code, MSSUC or MSFAIL for now |
 |          IGRint  *pnum_level	        # of search levels                   |
 |          IGRint  level_list[]	list of search levels                |
 |          IGRint  *pnum_constr	# of candidate constrs               |
 |          struct candidate_constr constr_list[] list of candidate cnstrs   |
 |          IGRboolean *pisunderconstr TRUE if path to underconstrained assem|
 |                                                                           |
 +---------------------------------------------------------------------------*/

message EMfind_overconstr (
		   IGRlong             *msg;    	 /* The return message OUT */
		   IGRboolean	       first_direction;  /* is it 1st search direction? IN */
                   IGRint	       *pnum_level;	/* # of search levels OUT */
                   IGRint	       level_list[];	/* list of search levels OUT */
                   IGRint              *pnum_constr;	/* # of candidate constrs OUT */
                   struct candidate_constr constr_list[];/* list of candidate cnstrs OUT */
		   IGRboolean	       *pisunderconstr); /* TRUE if path to underconstrained assem */


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_constraint_attrs                                           |
 |                                                                           |
 | This message will set the attributes of the constraint object.            |
 |                                                                           |
 | Input :  IGRuint       attrs       Attributes of object                   |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_constraint_attrs (IGRlong * msg; IGRuint  attrs);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_constraint_attrs                                           |
 |                                                                           |
 | This message will get the attributes of the constraint object.            |
 |                                                                           |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRuint *     attrs       Attributes of object                   |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_constraint_attrs (IGRlong * msg; IGRuint  * attrs);

message EMget_offset( IGRlong *msg; double *offset; struct GRid *expid );

message EMset_offset( IGRlong *msg; IGRchar *offset );

/*
 * Returns the two features on which the constraint is acting, along with
 * their enviroments.
 */
message EMget_ftrs_with_env( IGRlong *msg; struct GRid *fea_ids; 
                                        struct GRmd_env *environs );




override NDcompute_node,
	 NDmove_to_root,
         NDdisplay,
	 NDgive_structure,   /* return other_generic */
	 ASreturn_go;	     /* return myself */


end specification EMconstr;

