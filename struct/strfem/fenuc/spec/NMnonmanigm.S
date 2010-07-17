/*
This class represents non manifold global operations - union,
intersection and split.
History
	SM	18-Apr-91	Genesis.
*/

class specification NMnonmanigm (1:0) of EMScreator, NMnonmani;

#include "nm.h"

instance NMnonmanigm
{
 enum NMbooltype bool_type;
 IGRushort nmprops;

 IGRint	num_sfs, num_nmop, num_nmedges, num_vtx;

 variable struct GRid sfid[];	/* per sfs */
 variable IGRint num[];  /* storage order - num_flps, num_vtxuses, num_edges, 
			    num_edges_rev, num_edges_out, num_edges_in, 
			    numvtxusechg, numvtxusetr, numedcon, numeddiscon
			 */
 variable GRobjid ids[]; /* storage order - flps, vtxuses, edges, edges_rev, 
			    edges_out, edges_in, vtxusechg,
			    origedges, repledges, vtxusetr, origvtx, replvtx, 
			    edcon, nmedgescon, eddiscon, nmedgesdiscon, 
			    nmedges, vtx.
			 */
};

from NMassoc inherit delete;


/* Reject the EMSassoc instance data. 
*/
override EMSassoc;

/****************** Get ignore - implementation from NMnonmani.
reject
	EMput_info, 
	EMget_info;
*******************/
	
override
	GRaddwrng, 	/* Send down and to vtx */
	GRremwrng, 	/* Send down and to vtx */
	GRget_number_components, /* Stop at EMScomposite */
	GRget_components, /* Stop at EMScomposite */
	GRcopy, 
	NDdelete, 	/* Send GRdrop to self. */
	EMinit_associative, 	/* Always set option EMS_no_const_assoc
				   and EMSinit_dont_store_recomp_info.
				*/
	GRlocate, 	/* locate only if active */
	GRlocate_owner, /* locate only active owner */
	GRgetobjinfo, 
	GRdrop, 	/* Put all NMinters parents in the delete batch, 
			   Make components active and then wrt parent.
			*/
	GRdelete, 	/* Delete save state info and send wrt parent*/
	NDupdate, 
	debug, 
	EMtranslate_id_key, 
	GRxform, 	/* Xform the vertex objects */
	GRdelete_owner; /*Send NDmove_to_root to children and then wrt parent*/

message NMput_SSI(IGRlong *EMmsg; struct NMgmSSI *ssi);

message NMSSI_action(IGRlong *EMmsg; IGRushort options;
                    struct GRmd_env *env; struct NMgmSSI *ssi);

message NMreexecute(IGRlong *EMmsg; struct GRvg_construct *construct;
		    IGRushort reex_options);

message NMperform_boolean(IGRlong *EMmsg; IGRlong error_codes[];
                          struct GRvg_construct *construct;
			  struct GRid vol_op; struct GRmd_env *volenv;
			  IGRint num_nmop;
			  struct GRid *nm_op; struct GRmd_env nmop_env[];
			  enum NMbooltype bool_type;
			  IGRushort boolopt;
			  IGRchar *status_str; GRobjid *intobj, *auxobj);


message NMget_SSI(IGRlong *EMmsg; struct NMgmSSI *ssi;
		  IGRushort options);


message NMprop(IGRlong *EMmsg; IGRushort options, *props);


message NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options);

message NMappend_SSI(IGRlong *EMmsg; struct NMgmSSI *ssi; 
		    IGRushort options);

/* This will get leaves. It is different than the implementation of its
   GR.. counterpart in that it will go down even EMScomposites and stop
   at EMSsubbs. 
*/
message NMget_components(IGRlong *EMmsg; struct GRmd_env *env;
                        struct GRid objects[]; IGRint number_objects;
                        IGRint *count; IGRint from_obj; IGRint to_obj);

message NMget_number_components(IGRlong *EMmsg; IGRint *count);

end specification NMnonmanigm;
