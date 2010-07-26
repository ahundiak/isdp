/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).  Note that an empty B-tree do not
   require any space but a pointer and a variable array descriptor.

   The key is a string and the information is an objid.

   
   HISTORY :
   -------

   03/07/1988: H. BEQUET - Creation Date.
   03/27/1989: H. BEQUET - New B-tree Design
*/

class specification DIbst (0:0) of DIbtree;

  override store_info, retrieve_info, remove_info, wakeup, sleep, list;

end specification DIbst;
