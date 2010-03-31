/*
  ABSTRACT

  This class is similar to EMSpartedge in all respects excepts one
  and that is objects of this class are not the result of a split.
  Therefore when a 'real' edge looks up to its partedge owners on 
  the 'to_owners' channel, objects of this class should be
  IGNORED. 
	
  When edges of this class are split they give rise to partedges
  just like any other edge would.
	
  This class has no instance data. It is defined for the
  sole purpose of avoiding duplication of geometry and indicating
  geometrical coincedency. The latter can be concluded topologically
  if the dummy edge is common edge connected to its real edge.
	

  HISTORY

  DLB     07/10/91    Disable tagging.
  SM      19-Oct-87       1.1 Genesis
*/

class specification EMSdumedge (1:1) of EMSpartedge;

/*------------------ INSTANCE DATA SECTION -------------------*/

not_taggable;

override
  GRgraphics;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetedgedef;

#ifndef BASE_EMS

message EMdumedgeinit
(
  IGRlong *EMmsg;
  GRobjid real_edge;
  IGRboolean reverse;
);

override
  EMsend_dummy_edge, 
  debug;
	
#endif
		
end specification EMSdumedge;
