class implementation Root;

#include <stdio.h>
%safe
#include <math.h>
%endsafe
#include <string.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "emsdattyp.h"
#include "EMSasnuc.h"
#include "EMSrnd.h"

IGRint prtrnded (num, edinfo)
IGRint num;
struct EMSedge_rnd_info *edinfo;
{
  IGRchar filename[20];
  IGRint prtvtx;
  FILE *datfile;
  
  printf ("Filename _: ");
  scanf ("%s", filename);
  if (!strcmp (filename, "."))
    datfile = (FILE *) stderr;
  else
    datfile = (FILE *) fopen (filename, "w");
  if (!datfile)
    {
    fprintf (stderr, "Bad file name\n");
    return (FALSE);
    }

  printf ("Print expanded vertex information (1/0) _: ");
  scanf ("%d", &prtvtx);

  prtrnded_file ((FILE *) datfile, "", prtvtx, num, edinfo);

  if (datfile != (FILE *) stderr)
    fclose (datfile);

  return (TRUE);
}

IGRint prtrndvtx (num, vtxinfo)
IGRint num;
struct EMSvtx_rnd_info *vtxinfo;
{
  IGRchar filename[20];
  IGRint prted;
  FILE *datfile;
  
  printf ("Filename _: ");
  scanf ("%s", filename);
  if (!strcmp (filename, "."))
    datfile = (FILE *) stderr;
  else
    datfile = (FILE *) fopen (filename, "w");
  if (!datfile)
    {
    fprintf (stderr, "Bad file name\n");
    return (FALSE);
    }

  printf ("Print expanded edge info (1/0) _: ");
  scanf ("%d", &prted);

  prtrndvtx_file ((FILE *) datfile, "", prted, num, vtxinfo);
  
  if (datfile != (FILE *) stderr)
    fclose (datfile);
  return (TRUE);
}



int prtrnded_file (datfile, prefix, prtvtx, num, edinfo)
FILE *datfile;
IGRchar *prefix;
IGRint prtvtx;
IGRint num;
struct EMSedge_rnd_info *edinfo;
{
  IGRchar str[80];
  IGRint i;

  for (i=0; i<num; i++)
    {
    fprintf (datfile, "%s%2d) Edge %d, Surface %d, Radius %lf\n",
     prefix, i, edinfo[i].edge_id, edinfo[i].surf_id, edinfo[i].radius);
    fprintf (datfile, "%s    Comm surf %d\n", prefix, edinfo[i].com_surf_id);
    fprintf (datfile, "%s    Fillet surf %d\n", prefix, edinfo[i].fill_id);
    get_ed_config_string (edinfo[i].edge_config, str);
    fprintf (datfile, "%s    Edge config %s\n", prefix, str);
    fprintf (datfile, "%s    Props 0x%x\n", prefix, edinfo[i].props);
    fprintf (datfile, "%s    More info 0x%x\n", prefix, edinfo[i].more_info);
    fprintf (datfile, "%s    Surface 0x%x\n", prefix, edinfo[i].surf);
    fprintf (datfile, "%s    Comm surface 0x%x\n", 
     prefix, edinfo[i].com_surf);
    fprintf (datfile, "%s    Fillet surface 0x%x\n",
     prefix, edinfo[i].fill_surf);
    fprintf (datfile, "%s    Start vtx 0x%x, Stop vtx 0x%x\n", 
     prefix, edinfo[i].start_vtx, edinfo[i].stop_vtx);
    if (prtvtx)
      {
      prtrndvtx_file ((FILE *) datfile, "\t", FALSE, 1, &edinfo[i].start_vtx);
      fprintf (datfile, "\n");
      prtrndvtx_file ((FILE *) datfile, "\t", FALSE, 1, &edinfo[i].stop_vtx);
      }
    }
  return (1);
}

int prtrndvtx_file (datfile, prefix, prted, num, vtxinfo)
FILE *datfile;
IGRchar *prefix;
IGRint prted;
IGRint num;
struct EMSvtx_rnd_info *vtxinfo;
{
  IGRchar str[80];
  IGRint i, j;

  for (i=0; i<num; i++)
    {
    fprintf (datfile, "%s%2d) Num edges %d\n", 
     prefix, i, vtxinfo[i].num_edges);
    for (j=0; j<vtxinfo[i].num_edges; j++)
      {
      get_ed_config_string (vtxinfo[i].edge_configs[j], str);
      fprintf (datfile, "%s\tEdge %d, Stop %d, Config %s, Info %x\n",
       prefix, vtxinfo[i].edge_ids[j], vtxinfo[i].edge_stops[j], str,
       vtxinfo[i].edge_infos[j]);
      if (prted)
        prtrnded_file ((FILE *) datfile, "\t", FALSE, 
         1, (struct EMSedge_rnd_info *) &vtxinfo[i].edge_infos[j]);
      }
    fprintf (datfile, "%s    Vtx point [%lf, %lf, %lf]\n", prefix,
     vtxinfo[i].vtx_pt[0], vtxinfo[i].vtx_pt[1], vtxinfo[i].vtx_pt[2]);
    get_vtx_config_string (vtxinfo[i].vtx_config, str);
    fprintf (datfile, "%s    Vertex config %s\n", prefix, str);
    if (vtxinfo[i].fixed)
      strcpy (str, "fixed");
    else
      strcpy (str, "NOT fixed");
    fprintf (datfile, "%s    Vertex %s\n", prefix, str);
    }
  return (1);
}

int get_ed_config_string (config, str)
enum EMSedge_config config;
IGRchar *str;
{
  if (config == EMSedge_undefined)
    strcpy (str, "EMSedge_undefined");
  else if (config == EMSedge_neutral)
    strcpy (str, "EMSedge_neutral");
  else if (config == EMSedge_neutral_convex)
    strcpy (str, "EMSedge_neutral_convex");
  else if (config == EMSedge_neutral_concave)
    strcpy (str, "EMSedge_neutral_concave");
  else if (config == EMSedge_convex)
    strcpy (str, "EMSedge_convex");
  else if (config == EMSedge_concave)
    strcpy (str, "EMSedge_concave");
  else
    strcpy (str, "UNDEFINED");
  return (1);
}

int get_vtx_config_string (config, str)
enum EMSvertex_config config;
IGRchar *str;
{
  if (config == EMSvertex_spherical_blend)
    strcpy (str, "EMSvertex_spherical_blend");
  else if (config == EMSvertex_3edge_rolling_ball)
    strcpy (str, "EMSvertex_3edge_rolling_ball");
  else if (config == EMSvertex_general_blend)
    strcpy (str, "EMSvertex_general_blend");
  else if (config == EMSvertex_general_trim)
    strcpy (str, "EMSvertex_general_trim");
  else if (config == EMSvertex_single_patch)
    strcpy (str, "EMSvertex_single_patch");
  else if (config == EMSvertex_tangent_trim)
    strcpy (str, "EMSvertex_tangent_trim");
  else if (config == EMSvertex_2edge_cx_1edge_cv)
    strcpy (str, "EMSvertex_2edge_cx_1edge_cv");
  else if (config == EMSvertex_not_implemented)
    strcpy (str, "EMSvertex_not_implemented");
  else
    strcpy (str, "UNDEFINED");
  return (1);
}

end implementation Root;
