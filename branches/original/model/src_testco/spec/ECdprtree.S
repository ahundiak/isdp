/*
  DESCRIPTION

  This command locates a DPR solid (or surface-entities) and performs 
  operations like -- print the tree, undo to a particular id, etc. This
  command object is intended to handle all internal debug/fix-up type
  commands working on feature or DPR trees.
*/

class specification ECdprtree (3:2) of ECelements;

#include "PWminimum.h"
#include "PWgmdata.h"

instance ECdprtree
  {
    char *outfile;
    PWobjid undoid;
  };

override
  execute,
  get_locate_criteria;

end specification ECdprtree;
