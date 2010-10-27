VDS  TR179800593  "GENERATE VOLUME CUTS OBJECTS" 
Author: Ming Dong
Date  : 05/11/98

  Readme:
  ------------
	o  " GENERATE VOLUME CUTS OBJECTS”, TR179800593
	The brackets in the volume cuts setup file can not be left empty.
        	                                         
  Root cause:
  ----------------	              
	If they are empty, the parser will report errors.

  Solution:
  ------------
 	Modify the parser so that if empty between two brackets exists, 
        the parser will not recognize it as a error.

  Files modified/new:
  -------------------------
	o Modified files:
	vds/vddraw/drw/VDdrwgrammar.y

  Testing info:
  ----------------

