/*
  ABSTRACT

  Recorder of operations inserted in the tree.


  HISTORY

  DLB 10/9/87  creation
*/

class specification EMSsfhist (1:0) of EMSsfdpr;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

reject 
  EMadd;  

override
  EMdeactivateState,
  EMcheckOverlap,
  EMcanRecompute,
  EMgettreepath,
  EMislm,
  EMgetsolidclass,
  EMputSSI,
  EMgetactiveid,
  EMintcopy,
  EMundo,
  EMredo,
  EMgetSSIbuffer,
  EMgetSSI;

#endif

end specification EMSsfhist;
