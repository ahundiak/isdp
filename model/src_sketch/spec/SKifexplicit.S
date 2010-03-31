/*
  DESCRIPTION

    This is an abstract class for all explicit interface constraints.
*/

class specification SKifexplicit (2:0) of SKinterface, SKexplicit;

from SKinterface inherit
  SKgetconstrs, SKintcopy;

#ifndef BASE_EMS

override
  modify,
  NDupdate,
  GRdelete,
  SKinit, SKgetpseudovarlist, SKputval, SKstoreval, SKgetval;

#endif

end specification SKifexplicit;

