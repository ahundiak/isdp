/*
  DESCRIPTION

    This command locates an EMScompsurf object and checks it for any
    "slivers".

  HISTORY

    SS  :  07/28/93
*/

class specification ECchksliver (2:4) of ECelements;

instance ECchksliver
  {
  IGRint num_samplepts;
  IGRdouble xyztol;
  };

override execute, get_locate_criteria;

end specification ECchksliver;
