/*
   ABSTRACT :
   --------

   This abstract class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).  Note that an empty B-tree do not
   require any space but a pointer and a variable array descriptor.

   This class is a private class.

   
   HISTORY :
   -------

   03/07/1988 : H. BEQUET - Creation Date.
*/

class specification DIbtree (0:0) of DIstorage;

#include "DIbtree.h"

  instance DIbtree
  {
     btree *tree		/* The tree descriptor, for run-time 	*/;
     variable DIchar buffer [0]	/* To contain the data			*/;
  };

  override debug, is_empty, close;

end specification DIbtree;
