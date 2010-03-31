/* ###################   APOGEE COMPILED   ################## */
class specification EMSsfeditmgr (1:0) of EMSsfdpr;
/*
Abstract
    This class is the manager object for surface tree editing.

History
    DLB 10/31/88 Creation.
*/

instance EMSsfeditmgr
{
  GRobjid first_freed;    
};

override GRvg;  /*Reject GRvg instance data.*/

/*override;  everything?*/

/*reject;    nothing?*/

message EMinit(IGRlong *EMmsg; GRobjid uneval_id; 
               IGRushort options); 

end specification EMSsfeditmgr;
