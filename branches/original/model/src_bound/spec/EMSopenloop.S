/* ###################   APOGEE COMPILED   ################## */
class specification EMSopenloop (1:1) of EMSloop;
/*
Abstract

    This class represents a linear ('crack') region on the surface.

Notes

     Data types of the instance data inherited (in order) is -

     short int  - From Root
     short int  - From Root
     int        - From Root
     int        - pointer to 'notification' channel.

History
        DLB     07/10/91    Disable tagging.
	SM	14-Oct-87	1.1 Genesis
*/

not_taggable;

override	GRgraphics;

message EMolpinit(IGRlong *EMmsg;IGRushort props;
		struct EMSpartolbasis *partolbasis;
		IGRboolean make_dummy_edges);
/*
Abstract
	This method initializes an open loop. The properties bit mask should be
 sent to this method.The range box of the loop is updated.The method also
 checks whether the loop is open or closed and sets that property
 accordingly.
	This method DOES NOT set the correct loop type (P or C) of the
 loop. This should be decided by the caller and the apprpriate type passed
 in via the 'props' arguement.
	Also, making the directions of the edges consistent with the loop type
 is NOT this method's goal.

Arguments
	props		input		properties of the loop.
	partolbasis	input		parametric basis tolerance.
	make_dummy_edges input		Boolean flag indicating whether
					dummy edges should be constructed
					for each 'real' edge (except the
					point edge) in order that the loop
					appears 'closed'.
					For all loopset operations it is
					required that the open loop appear
					closed via such dummy edges. Also
					the dummy edges are necessary for
					detecting coincedency wherever
					required. Thus this flag should be
					TRUE unless the construction of dummy
					edges is done external to this
					method.
*/

override
	EMarea, 		/* return 0 and EMS_I_Degenerate */
	EMcloseyourself, 	/* initialize and insert in LS */
	EMlinintgrl, 
	EMpt_location, 
	EMnesting;

reject
	EMlpinit, 
	EMmake_natural_loop, 
	EMmkface_collapse_copy, 
	EMgroup_loops;
	
end specification EMSopenloop;


