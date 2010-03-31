class implementation SKptvar;

#include <stdio.h>

/*
HISTORY
   RC     05/21/90    Creation Date
   RA     10/06/93    Modified to print the global coordinates.
*/

method debug()
{
  short idmattyp;
  long msg_loc;
  IGRpoint xypt, xyzpt;
  IGRmatrix idmat;
  extern void SKdisppt();

 EMidmatrix (&msg_loc, &idmattyp, idmat);
 
 om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL, NULL, NULL,
                xypt), 
          targetid = my_id);

 om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL, &idmattyp,
                idmat, xyzpt), 
          targetid = my_id);

 fprintf (stderr, "   SKptvar obj %d : [%lf %lf] [%lf %lf %lf]\n", 
                  my_id, xypt[X], xypt[Y], xyzpt[X], xyzpt[Y], xyzpt[Z]);

 fprintf (stderr, "\tProps = 0x%x\n", ME.SKvariable->props);

 SKdisppt (&msg_loc, my_id, NULL, GRbd);

 return OM_S_SUCCESS;
}

end implementation SKptvar;
