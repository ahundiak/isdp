/*
  ABSTRACT

  This class represents classes that request help from other objects.

  HISTORY

  09 December 87  AIC     Creation Date
*/

class specification EMSrequester (1:0) of Root;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSrequester
{
  channel
  {
    (rel_ordered, many_to_many, initial = 0, increment = 1)
    EMShelper.to_requesters;
  } to_helpers;
};

end specification EMSrequester;
