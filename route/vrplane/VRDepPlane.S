/*
ABSTRACT
--------

  This class implement route planes deponding of referential plane.

HISTORY
-------

  momo 27-02-92 : Design date
*/

class specification VRDepPlane (0:1) of VRplane;


instance VRDepPlane
{
  int RefPlane;		/* is given in the hexa form ( 0x???? )
			/* the first digit from the left used to specify the
			/*  type of the dependent plane template. 
			/* 0 : template is a plane
			/* 1 : a referential
			/* 2 : a component ( given a cpt number, we consider
			/*     the matrix at this point like a referential )
			/* the second digit is used to specify how construct 
			/* the dependent plane when the template is a
			/* referential or a component
		    	/* 1 : XY ref plane.
			/* 2 : XZ ref plane.
		    	/* 4 : YZ ref plane.
			/* the last two digit indicate the cpt number of a given
			/* component. not used in the other case.
			/**/
};

override GRvg;

override NDplace, NDcompute_node, NDcopy_to_root, NDnotify_disconnect, 
	 NDmove_to_root, GRgetobjinfo;

end specification VRDepPlane;
