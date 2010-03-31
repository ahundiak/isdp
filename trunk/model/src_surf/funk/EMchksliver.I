/*
   DESCRIPTION

     This function returns as it's value, the number of surfaces in the
     given EMSsurface object, that contain "slivers". See declaration of 
     EMSsurface.EMchksliver method for explanation. If "outfile" is
     non-NULL, this function writes details to the file pointed to. It
     does NOT fclose the file. Both num_slivers and sliver_edges are
     optional output arguments.

   OPTIONS

     EMS_O_Debug	- This option will write to stderr.
     EMS_O_Display	- This option hi-lites the sliver surfaces
     EMS_O_Incremental  - This option only checks the modified surfaces
*/

class implementation EMSsurface;

#include <stdio.h>

from EMSboundary import EMgetsurface_info;

IGRint EMchksliver (msg, options, mattyp, mat, sfid,
                    xyztol, num_chkpts,
                    num_slivers, sliver_edges, outfile)
IGRlong *msg;
IGRushort options;
IGRshort *mattyp;
IGRmatrix mat;
struct GRid *sfid;
IGRdouble xyztol;
IGRint num_chkpts;
IGRint *num_slivers;
GRobjid (**sliver_edges)[2];
FILE *outfile;
{
  IGRint i, loc_num_slivers=0, num_sliver_sfs;
  IGRlong msg_loc, stat_OM;
  GRobjid sfobj, prev_sfobj, (*loc_sliver_edges)[2]=NULL;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (num_slivers)
    *num_slivers = 0;
  if (sliver_edges)
    *sliver_edges = (GRobjid (*)[]) NULL;
  num_sliver_sfs = 0;

  stat_OM = om$send (msg = message EMSsurface.EMchksliver 
             (&msg_loc, options | EMS_O_Internal, mattyp, mat, xyztol,
              num_chkpts, &loc_num_slivers, &loc_sliver_edges),
             targetid = sfid->objid, targetos = sfid->osnum,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (loc_num_slivers)
    {
    if (options & EMS_O_Debug)
      fprintf (stderr, "Num slivers = %d\n", loc_num_slivers);
    if (outfile)
      fprintf (outfile, "Num slivers = %d\n", loc_num_slivers);

    prev_sfobj = NULL_OBJID;
    for (i=0; i<loc_num_slivers; i++)
      {
      sfobj = NULL_OBJID;
      om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
       &sfobj, NULL), targetid = loc_sliver_edges[i][0], 
       targetos = sfid->osnum, senderid = NULL_OBJID);

      if (options & EMS_O_Debug)
        fprintf (stderr, "%d) Sf: %d, Eds: %d - %d\n", i, sfobj,
         loc_sliver_edges[i][0], loc_sliver_edges[i][1]);
      if (outfile)
        fprintf (outfile, "%d) Sf: %d, Eds: %d - %d\n", i, sfobj,
         loc_sliver_edges[i][0], loc_sliver_edges[i][1]);

      if (sfobj == prev_sfobj)
        continue;
      else
        num_sliver_sfs++;
      prev_sfobj = sfobj;

      if (options & EMS_O_Display)
         EMdbgdisp (sfobj, sfid->osnum, 3);
      }
    }

  if (num_slivers)
    *num_slivers = loc_num_slivers;

  if (sliver_edges && loc_sliver_edges)
    {
    *sliver_edges = loc_sliver_edges;
    loc_sliver_edges = NULL;
    }

ret_end:
  if (loc_sliver_edges)
    om$dealloc (ptr = (IGRchar *) loc_sliver_edges);

  EMWRAPUP (*msg, stat_OM, "EMchksliver");
  return (num_sliver_sfs);
}

end implementation EMSsurface;

