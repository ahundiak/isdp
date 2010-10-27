/*---------------------------------------------------------------------------
*  VDpretendin
*
*  ABSTRACT
*    pretend objects  with owner channel
---------------------------------------------------------------------------*/
class specification VDpretendin (0:0) of ACpretendin, ACpl_hold;

override NDsleep;
override NDparent_deleted;
override NDcompute_node;

end specification VDpretendin;
