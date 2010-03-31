/* ###################   APOGEE COMPILED   ################## */
class implementation SKasvlgrnd;

#include <stdio.h>

method debug()
{
  fprintf (stderr, "Value Ground:\n");
  fprintf (stderr, "  Props = 0x%x \n", ME.SKconstraint->props);

  return OM_S_SUCCESS;
}

end implementation SKasvlgrnd;

