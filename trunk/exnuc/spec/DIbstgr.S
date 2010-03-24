/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).  Note that an empty B-tree do not
   require any space but a pointer and a variable array descriptor.

   The key is a string and the information is a grid (osnum + objid).

   This B-tree may NOT be saved on a file. (Why ? )

   
   HISTORY :
   -------

   03/09/1988 : H. BEQUET - Creation Date.
   04/09/1989 : H. BEQUET - New B-tree design.
*/

class specification DIbstgr (0:0) of DIbst;

  override debug, init, get_type;

end specification DIbstgr;
