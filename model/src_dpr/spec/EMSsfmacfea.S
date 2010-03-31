/*
  ABSTRACT

  This is a class which represents surface macro feature objects of 
  local modification.


  HISTORY

  BL  06/21/90	Creation Date.
*/

class specification EMSsfmacfea (1:0) of EMSfeature, EMSsfmacro;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override 
  GRgetobjinfo,
  EMgetsolidclass;

#endif

end specification EMSsfmacfea;


