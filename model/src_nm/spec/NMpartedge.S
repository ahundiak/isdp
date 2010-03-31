class specification NMpartedge (1:0) of EMSpartedge;


instance NMpartedge
{
 unsigned char nmprops;
};

override 
	EMget_top_part_edges, 	/* Ignore myself to be transparent to EMS 
				   operations.*/
	EMgettopedge, 		/* As above */
	delete;			/* Consider NMpartedge owners in deletable
				   criterion, unlike the EMSpartedge
				   override.
				*/
message NMget_region_edge(IGRlong *EMmsg; GRobjid *region_edge, *region_loop);
message NMprop(IGRlong *EMmsg; unsigned char options, *props);

end specification NMpartedge;
