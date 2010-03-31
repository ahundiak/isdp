/*
  DESCRIPTION

    This is an abstract class for all implicit interface constraints.
*/

class specification SKifimplicit (2:0) of SKinterface, SKimplicit;

from SKinterface inherit 
  SKgetconstrs, SKgetpseudovarlist, SKintcopy;

#ifndef BASE_EMS

override
  GRgetobjinfo;

#endif

end specification SKifimplicit;

