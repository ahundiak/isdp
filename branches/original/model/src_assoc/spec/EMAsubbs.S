/*
  DESCRIPTION

  This class provides implementation for common functionality with regards
  to support of associative sub-surfaces. This is an abstract class.

  HISTORY

  Creation               : PP  : 03/02/91
*/

class specification EMAsubbs (2:0) of EMAsurface, EMSsubbs;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMdisplay_geomparam;

#endif

end specification EMAsubbs;
