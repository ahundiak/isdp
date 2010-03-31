/*
  DESCRIPTION

    This is an instantiable class which stands for a angular dimension between
    two line segments at the time of placement w.r.t to a dimensioning
    plane. The dimension drives the second line segments orientation.

  HISTORY

    SS  :  07/14/91  :  Creation
*/

class specification EMSangcnstr (2:0) of EMSexpcnstr;

override
  EMinit, EMgetgeomlocus;

end specification EMSangcnstr;
