# $Id: setup1.vs,v 1.1.1.1 2001/01/04 21:09:36 cvs Exp $
#
# Default setup file for STRUCT components
#

#verbose ;

stiffener : {

	 vis-edges-C [	
                       color = 12,
	               level = 106,
	               style = 0,
                       weight = 1,
                       hidden-weight = 0,
                       hidden-color = 12,
                       hidden-level = 107,
	               hidden-style = 5 ];
}

beam : {
	vis-edges-A [	
                       color = 12,
	               level = 106,
		       style = 0,
                       weight = 1,
                       hidden-weight = 0,
                       hidden-color = 12,
                       hidden-level = 107,
		       hidden-style = 5 ];
}

plate : {
	vis-edges-A [	
                      color = 8,
                      level = 106,
		      style = 0,
                      weight = 1,
                      hidden-weight = 0,
                      hidden-color = 8,
                      hidden-level = 107,
                      hidden-style = 5  ]
}
