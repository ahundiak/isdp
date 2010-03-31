/*
  ABSTRACT

  This is an abstract class which represents feature objects.

 
  HISTORY

  BL    06/15/90    Creation Date.
*/

class specification EMSfeature (1:0) of EMScomposite;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

reject
  GRcopy,
  GRxform,
  GRdelete,
  GRdisyourself,
  GRdisplay;

#endif
	
end specification EMSfeature;

