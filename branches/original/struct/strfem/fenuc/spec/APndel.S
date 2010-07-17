class specification APndel(1:0) of Rootmsg;

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "OMerrordef.h"
#include "APerrmac.h"
#include "APdef.h"

/*****************************************************************************

   Doc: APndel

   Abstract: This is an abstract class which combines some of the instance
	data for nodes and elems.  It is most useful for providing a
	single channel to the post data descriptor (pdd) which can then
	be restricted on the pdd resulting in significant savings ( 4 bytes
	instead of 12 for each pdd_to_nd/el connection ).  It also allows for
	some functionality at this level instead of at both APnode and APelem.

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      10 Jul 91	msl		Creation
       5 Sep 91	bwh		moved intid instance data up from APnode
				so that elements also have intid
      26 Sep 91	smt		added group_connect method for nodes and elements
      11-04-91	kk	2.0.0	Added intid_map message
      11-14-91	kk	2.0.0	Added dimension argument to get_type

 ****************************************************************************/

channel to_pdd  {(many_to_many,rel_ordered,initial=4,increment=1)
		APpdd.to_ndel; };

instance  APndel
    {
	IGRchar		type;		/* node/elem type ( see APdef.h )*/
	IGRlong		uid;
	IGRlong		intid;
	channel to_pdd	to_pdd;
variable IGRdouble	data[0];	/* data descriptions are defined by
					   the descriptor object (pdd) */
    };

/*
 ----------------------------- get_ids -----------------------------------
 *
 *  This method gets the node/elem uid and GRid and adds them to the list.
 */

message get_ids (	/* gets list of node user ids and objids/osnum	*/
	IGRlong		*msg;		/* o - return message		*/
	IGRlong		uids[];		/* o(opt) - User ID numbers	*/
	IGRlong		intids[];	/* o(opt) - Internal ID numbers	*/
	struct GRid	grids[];	/* o(opt) - Object's objid/osnum*/
	IGRlong		*indx;		/* o - current indx (number of objs)*/
	);

/*
 -------------------------get_grid_by_uid --------------------------------
 *
 *  This method gets the node/elem GRid that corresponds to uid.
 */

message get_grid_by_uid (
	IGRlong		*msg;		/* o - return message		*/
	IGRlong		uid;		/* i - User ID number to match */
	struct GRid	*grid;		/* o - GRid of matching node	*/
	);

message group_connect (
	long		*msg;		/* o - return status		*/
	IGRboolean	opt_flag;	/* i - flag for operations
						== 1 : uid range check
						== 0 : no check 	*/
	long		uid_low;	/* i - lower uid value		*/
	long		uid_high;	/* i - higher uid value		*/
	struct GRid	sv_id;		/* i - the group/set to connect to */
	long		*count;		/* i - lower uid value		*/
	long		max_count;	/* i - higher uid value		*/
	);

message get_type (
	char		*type;		/* o - from instance data: APdef.h*/
					/*     Ignored if NULL		*/
	char		*dimension;	/* o - Derived from type	*/
					/*     Ignored if NULL		*/
	);

message intid_map (
	IGRlong		*msg;		/* o - Return status		*/
	IGRlong		max_nodes;	/* i - Max nodes in map array	*/
	IGRlong		*num_nodes;	/*i/o- Number of nodes 
						(seed with 0)		*/
	IGRlong		map[];		/* o - Node internal ids	*/
);

message set_intid(
	long		*next;		/*i/o- Next internal id		*/
	);

message copy_intid_to_uid(
	long		*msg;		/* o - status return	*/
);

message assign_uid(
	long		*msg;		/* o - return code		*/
	long		start;		/* i - start id			*/
	long		step;		/* i - increment amount		*/
	long		uid_list[];	/* i - list of sorted uid's	*/
					/* i -  present: maintain existing order
						 absent: ignore		*/
	long		num_uids;	/* i - number of entries in uid_list */
	long		*count;		/*i/o- current uids count	*/
);

message assign_intid_to_orphnod(
	long			*max_uid;	/* i/o - current max_uid*/
);

/* This message converts an intid to a uid or vice versa */
message	match_id (
	long		*msg;		/* o - Return status		*/
	long		*uid;		/* i/o - User id		*/
	long		*intid;		/* i/o - Internal id		*/
	) ;

/* Checks if node/elem is on list */
message are_you_on_list (
	long		*msg;		/* o - return status		*/
	struct GRid	el_grids[];	/* i - SORTED list. NULL: on_list = TRUE */
	long		num_els;	/* i - Number of elem in el_grids*/
	long		*on_list;	/* o - TRUE/FALSE		*/
	) ;

message APrnsetintid(
	IGRint		*msg;		/* o - return status		*/
	IGRlong		renum_map[];	/* i - renumbered intids	*/ 
	);

message get_grids_by_sorted_uids (
	IGRlong		uids[];		/* i - User ID numbers to match */
	struct GRid	grids[];	/* o - GRid of matching node/elem */
	long		num_ndel;	/* i - number of entries in uids/grids */
	);

end specification APndel;
