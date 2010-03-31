/*
Common hook for transmigrating dependents.
*/
class specification NMassoctrans (1:0) of EMSmigrator, NMassoc;

instance NMassoctrans
{
 variable IGRboolean transmigrate[];
 variable struct GRid base_state[];
};

override
	EMparent_owned, 	/* Go into the batch */
	EMparent_disowned, 	/* Go into the batch */
	NDmove_to_root, 	/* Transmigration */
	debug, 		        /* Output transmigration information */
	NDget_objects, 		/* Transmigration, then wrt msg */
	NDparent_deleted;	/* Mark base states in inst. data as NULL_OBJID
				   if they are being deleted. Then wrt message
				   NDnode.NDparent_deleted.
				*/

message NMinit_associative (IGRlong *EMmsg;
                            IGRushort options, nm_options;
                            IGRint num_parents;
                            struct EMSobject_info *list;
			    IGRint num_base_states;
			    IGRboolean *transmigrate;
			    struct GRid *base_state;
                            IGRint type;
                            IGRuint size;
                            IGRchar *recomp_data;
                            struct GRvg_construct *construct_list);

message NMtransmigrate(IGRlong *EMmsg; IGRint (**actid_f)(); 
		       IGRchar **actid_f_args; IGRushort options);

message NMget_actid_funcs(IGRlong *EMmsg; IGRint (***f)(); IGRchar ***args);
message NMfree_actid_funcs(IGRlong *EMmsg; IGRint (***f)(); IGRchar ***args);

message NMget_trans_info(IGRlong *EMmsg; IGRboolean **transmigrate;
			 struct GRid **base_state; IGRint *num_states);

end specification NMassoctrans;
