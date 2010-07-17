// -----------------------------------------------------------------------------
//      Class    :      VLjunction.S
//
//      Abstract :      graphic object with an attribute collection.
//
//      History  :      Created 21-Mar-1995     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLjunction(0:0) of ACrg_collect, VLabstract;

/* Class construction method */
override	ACconstruct_feet;

/* Class <collect> private methods */
message		VLreturn_collect ( IGRlong *msg; struct GRid *collect);
override	ACshow_data;

/* Class graphic public method */
message		VLreturn_graphic ( 		IGRlong		*msg;
					struct	GRmd_env	*Env;
					struct	GRobj_env	*graphic );

/* Class collection public methods */
override	AClist_attribute;
override	ACget_named_attribute;
override	ACget_attribute_at_index;
override	ACadd_list_attribute;
override	ACmod_list_attribute;
override	ACset_list_attribute;
override	ACget_prop_mgr;
override	ACchg_prop_mgr;
override	ACadd_attribute_by_type;
override	ACrem_attribute;
override	ACrem_att_at_index;
override	ACmod_attribute;

override        VDgetObjDef;

end specification VLjunction;
