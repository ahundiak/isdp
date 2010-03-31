/* ###################   APOGEE COMPILED   ################## */
class implementation SKvalvar;

#include <stdio.h>

method debug()
{
  fprintf (stderr, "Value variable:\n");
  fprintf (stderr, "  Id: %d\n", my_id);

  return (OM_S_SUCCESS);
}

end implementation SKvalvar;
