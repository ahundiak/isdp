VDS  TR179901064  ASSEMBLY MANAGER 
Author: Art Hundiak
Date  : 02/15/00

  Readme:
  ------------
	o  "ASSEMBLY MANAGER", TR179901064
	Description 
	Unit 3130 production file crashes as soon as Assembly Manager is started
        	                                         
  Root cause:
  ----------------	              
	Using global array OM_GA_OSDs to obtain the name of an os,
	Example: strcpy(refName,OM_GA_OSDs[osnum]->name);
        Can result in core dumps.  Don't know why.  There can be two almost
        identical files, one crashes, one does not.

  Solution:
  ------------
	Replace the use of OM_GA_OSDs with calls to either di$give_pathname or 
	om$os_number_to_name

  Files modified/new:
  -------------------------
	o vdat/imp/VDatMgr.I
          vdat/cmd/VDatMgr.I
          vdat/set/VDatLeaf.I
          vdat/post/VDatPdm.I

  Testing info:
  ----------------
          Activate test cases, run Assembly Manager

