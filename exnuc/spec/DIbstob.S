/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).  Note that an empty B-tree do not
   require any space but a pointer and a variable array descriptor.

   The key is a string and the information is an objid.
*/

class specification DIbstob (0:0) of DIbst;

  override debug, init, get_type;

end specification DIbstob;
