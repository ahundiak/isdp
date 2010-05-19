VDS  TR179900956  "SELECT SIDE OF PLATE" 
Author: Ad Zuurhout
Date  : 01/29/00

  Readme:
  -------
	o  "SELECT SIDE OF PLATE", TR179900956
	The plate was indicating the invalid solid face as being the 'offset'
	surface of the plate.

        	                                         
  Root cause:
  -----------	              
	The getSupport routine is retrieving the initial parent surface 
	which is non-planar, but the direct parent surface (after the
	splitting process) is planar.

  Solution:
  ---------
	In stead of using the initial support, we retrieve the first face
	of the plate to evaluate the shape of the plate. This surface
	reflects a better inidication of the plate geometry.

  Files modified/new:
  -------------------
	o Modified files:
	  vsplate/VSpltopbotmp.I
	
  Testing info:
  -------------

