VDS  TR179800594  "GENERATE VOLUME CUTS OBJECTS" 
Author: Ming Dong
Date  : 05/20/98

  Readme:
  -------
	o  "GENERATE VOLUME CUTS OBJECTS"”, TR179800594
	Documentation says you can create a volume cut object on the same
	layer that its parent or original object is on, but you can't.
        	                                         
  Root cause:
  -----------	              
	The default level that the volume cut object is on is overwritten
	in parser by level 1022.

  Solution:
  ---------
	Because the default level is specified in the command form, the
	volume cut object should be placed on this default level if the 
	level is not specified in the set-up file.  The structure of input
	variable inp is modified so that this variable can pass application
	types( visualization, volume cut or symbology) to parser.  In this 
	way, the default level will not be overwritten by level 1022 if the
 	application type is volume cut. 

  Files modified/new:
  -------------------
	o Modified files:
	vds/vddraw/drw/VDdrwexecsct.I
	vds/vddraw/drw/VDdrwexecatt.I
	vds/vddraw/drw/VDdrwgramfcn.C
	vds/include/v_drw.h

  Testing info:
  -------------

