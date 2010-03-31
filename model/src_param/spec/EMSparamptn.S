/*
  DESCRIPTION

    Instantiable class for points that can be flexibly dimensioned or
    constrained in a piece-wise manner, at differing times during the
    modelling proces. This implies that this point may not be fully defined,
    parameterically speaking, at creation time.
 
  HISTORY

    SS  :  03/15/91  :  Creation
*/

class specification EMSparamptn (2:0) of EMSparampt;

override 
  DMsrc,
  GRgraphics;

end specification EMSparamptn;
