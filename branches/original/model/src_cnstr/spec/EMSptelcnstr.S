/*
  DESCRIPTION

    This is an instantiable class which constraints an EMSparampt to
    a GRvg element.

  HISTORY

    SS  :  06/30/91  :  Creation
    jhw :  07/26/91  :  Added GRgetobjinfo override.
*/

class specification EMSptelcnstr (2:0) of EMSimpcnstr;

override 
  EMinit, EMgetgeomlocus;

end specification EMSptelcnstr;
