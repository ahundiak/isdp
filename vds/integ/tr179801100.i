VDS  TR179801100  "MOVE DRAWING TEXT" 
Author: Ming Dong
Date  : 06/03/98

  Readme:
  -------
	o  "MOVE DRAWING TEXT"”, TR179800595
 	The first time you move the drawing text will result the text in
	the active symbology.
        	                                         
  Root cause:
  -----------	              
	Put active symbology on the text object.

  Solution:
  ---------
	Delete puting active symbology.

  Files modified/new:
  -------------------
	o Modified files:
	vds/smdrwtxt/imp/SMCpTxti.I

  Testing info:
  -------------

