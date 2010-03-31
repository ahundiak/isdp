/*
  ABSTRACT

  This class represents the topological elements which own the edge.
  The purpose of this class is to provide a channel to connect
  to the edge. A seperate class is required so that both the partedge
  and the loop can use the same channel to own the edge, thus enabling
  the channels to be made restricted (and save space).


  HISTORY

  DLB     07/10/91    Disable tagging.
  SM      15-Oct-87       1.1 Genesis
*/

class specification EMSbd_owner (1:1) of Root;

/*------------------ INSTANCE DATA SECTION -------------------*/

channel components_channel
{
  (rel_ordered,
   many_to_many,
   initial = 4, increment = 1)
  EMSedge.to_owner;
};

not_taggable;

instance EMSbd_owner
{
  channel components_channel to_comps;
};

end specification EMSbd_owner;
