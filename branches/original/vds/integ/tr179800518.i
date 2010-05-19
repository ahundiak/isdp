VDS  TR179800518  "ASSOCIATIVE PLACE ARC BY CENTER" 
Author: Ming Dong
Date  : 07/20/98

  Readme:
  ------------
	o  "ASSOCIATIVE PLACE ARC BY CENTER", TR179800593
	Modifying mocro on an arc breaks the associative contour which
	uses the arc.
        	                                         
  Root cause:
  ----------------	              
	The cn_type is wrong.

  Solution:
  ------------
	Copy the method modify_mocro() in EMS to the file COm_place3.I
        in VDS. Then,correct the cn_type.

  Files modified/new:
  -------------------------
	o Modified files:
	vds/vdassoc/COm_place3.I

  Testing info:
  ----------------

