/*
  DESCRIPTION

    This is an instantiable class which stands for a dimension between
    two points along a constant vector which was a horizontal or vertical
    at the time of placement w.r.t to the window in which it was placed

  HISTORY

    SS  :  03/14/91  :  Creation
*/

class specification EMSlndmcnstr (2:0) of EMSexpcnstr;

override 
  EMinit, EMgetgeomlocus;

end specification EMSlndmcnstr;
