# $Id: visual.vs,v 1.1.1.1 2001/01/04 21:07:24 cvs Exp $
#
# Default setup file for STRUCT components
#

# verbose ;

stiffener : {

	vis-edges-C[	color = "green",
			level = 101,
			style = 0,
			hidden-style = 2  ];
}

plate : {
	vis-edges-B[	color = "yellow",
			style = 3,
			level = 103,
			hidden-style = 1];
}
