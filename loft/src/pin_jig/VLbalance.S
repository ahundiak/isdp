// -----------------------------------------------------------------------------
//      Class    :      VLbalance.S
//
//      Abstract :      Store data corresponding to a I/LOFT balancement.
//
//      History  :      Created 27-SEP-1993     Marc FOURNIER
//                      Updated 11-APR-1994     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLbalance(0:0) of VLabstract;

override	ACconstruct_feet;

override	VDgetObjDef;

message		convert( IGRlong *msg );

end specification VLbalance;
