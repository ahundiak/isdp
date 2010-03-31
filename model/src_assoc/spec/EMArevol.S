/*
  DESCRIPTION

  This is an instantiable class defining associative general surface
  of revolution.


  HISTORY

  pp      6/7/91     creation date
*/

class specification EMArevol (2:0) of EMAsubbs, EMSrevol;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSrevol inherit 
  EMget_params;

#endif

end specification EMArevol;
