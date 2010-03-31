/*
This class represents a NM node which transmigrates with the model (including
the NM operations in a model). Its purpose is -

 o To keep track of NM topology (NMedges, NMvertex_uses and NMvertices) that 
   was created for some application. This includes deleting, updating this
   topology as required.
 o Offer itself as the creator for indirection in associativity.

 Objects of this class are non locatable, non displayable. Although they
 have GRflxown in their parentage (by virtue of being subclassed off 
 NMnonmanigm) they never own any part of the model.

 Objects of this class are transmigrators (always occur at the top of the
 model in steady state).

History
	SM	29-Oct-91	Creation.
*/
class specification NMnonmanitp (1:0) of NMnonmanigm;

/* Reject the EMSassoc instance data.
*/
override EMSassoc;

reject
	NMperform_boolean, 
	GRflexconn, 
	GRdisconn;

/* Inherit following messages from NDnodein to avoid flexible ownership.
*/
from NDnodein inherit NDconnect, NDdisconnect;

override
	NMreexecute;

message NMpass_model(IGRlong *EMmsg; OM_S_MESSAGE *messg; 
		     struct GRid *modelid);

end specification NMnonmanitp;
