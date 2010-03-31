#include "EMS.h"
# include <stdio.h>
# include <math.h>
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "msdef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "emssfint.h"
# include "EMSerrnumdef.h"
# include "EMSerrordef.h"

int prtintobjs (num, intobj)
int num;
struct EMSintobj *intobj;
{
  IGRint prtdatapts, prtmoreinfo;
  IGRchar filename[20];
  IGRint i;
  GRobjid objid;
  GRspacenum osnum;
  FILE *datfile;

  printf ("filename _: ");
  scanf ("%s", filename);
  datfile = fopen (filename, "w");

  printf ("Print data points (1/0) _: ");
  scanf ("%d", &prtdatapts);
  
  printf ("Print more info points (1/0) _: ");
  scanf ("%d", &prtmoreinfo);
  
  for (i=0; i<num; i++)
    {
    if (intobj)
      {
      fprintf (datfile, "\t Intersection %d, address 0x%x\n",
       i, intobj);
      fprintf (datfile, "\t Reversed %d\n\t Props 0x%x \n",
       intobj->reversed, intobj->props);
      if (intobj->other_intobj_node)
        {
        objid = intobj->other_intobj_node->this_obj_node->this_obj.objid;
        osnum = intobj->other_intobj_node->this_obj_node->this_obj.osnum;
        fprintf (datfile, "\t Other object [%d, %d], other node 0x%x\n",
         objid, osnum, intobj->other_intobj_node);
        }
      fprintf (datfile, "\t xyz:\n");
      prtdat (datfile, &intobj->this_xyzintobj, FALSE, prtdatapts, NULL, NULL);
      fprintf (datfile, "\t uv:\n");
      prtdat (datfile, &intobj->this_uvintobj, FALSE, prtdatapts, NULL, NULL);

      if (prtmoreinfo)
        {
        fprintf (datfile, "\t more:\n");
        prtsfintedpar (datfile, intobj->more_info);
        }
      fprintf (datfile, "\n");
      intobj = intobj->next; 
      }
    }

  fclose (datfile);
  return(1);
}

  
