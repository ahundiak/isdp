class specification NMlistedge (1:0) of GRlistener, NMedge;


channel edge_channel
{
 (many_to_many, rel_ordered, initial = 1, increment = 1)
 GRnotify.notification;
};

instance NMlistedge
{
 channel edge_channel	to_edges;
};


override EMSassoc;
override GRvg;
override GRconnector;
override GRgraphics;
override NDchildren;


override
	NDconnect, 
	NDdisconnect, 	
	EMinit_associative, 	/* Connect on notification channel */
	NMget_parent_info;	/* Collect info on notification channel */
	

end specification NMlistedge;
