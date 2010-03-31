/*
 * HISTORY
 * 
 * Rajiv Agrawal :  6/20/92 :  Added option to print out the decomposition.
 */
class implementation SKmgr;

#include <stdio.h>
#include <alloca.h>

extern GRclassid OPP_SKptvar_class_id;

method debug()
{
  char                keyin;
  long                i, j, k, msg_loc;
  OMuint	      num;
  int		      num_vars, num_constrs;
  OMuword             varclass;
  struct SKvarinfo    *varinfo;
  struct SKsolvevars  *varlist, *pvar;
  struct SKconstrinfo *constrs;
  struct SKsolvepath  solvepath;
  struct GRid         profile, refpln_grid;
  OM_S_CHANSELECT     chan, chan_to_parent;
  OM_p_OBJECT_LINKAGE objlist;
  FILE		      *datfile;
  char		      filename[20];
  extern void         SKgetsolvepath5();
  extern int          SKdbgspath();

  fprintf (stderr, "\n\tSKmgr : %d\n", my_id);
  printf ("\nEnter filename (<CR> for screen) : ");
  gets (filename);
  if (strlen(filename))
    datfile = fopen (filename, "w");
  else
    datfile = stderr;
  if (!datfile)
    return 0;
  
  fprintf (datfile, "\n\tSKmgr : %d\n", my_id);
  fprintf (datfile, "\tGraphics props = 0x%x, Level = %d\n",
           ME.GRgraphics->properties, ME.GRgraphics->level);
  fprintf (datfile, "\tSKmgr Props = 0x%x\n", ME.SKmgr->props);
  EMmake_chanselect (NDfather_father, &chan_to_parent);
  refpln_grid.objid = NULL_OBJID;
  om$get_objid_at_index (object = me, p_chanselect = &chan_to_parent,
                         index = 0, objidaddr = &refpln_grid.objid, 
                         osnumaddr = &refpln_grid.osnum);
  fprintf (datfile, "\tReference plane id = %d\n", refpln_grid.objid);
  fprintf (datfile, "\tOrigin = [%lf, %lf, %lf]\n", ME.SKmgr->origin[0],
           ME.SKmgr->origin[1], ME.SKmgr->origin[2]);
  fprintf (datfile, "\tZ-axis = [%lf, %lf, %lf]\n", ME.SKmgr->normal[0],
           ME.SKmgr->normal[1], ME.SKmgr->normal[2]);
  fprintf (datfile, "\tX-axis = [%lf, %lf, %lf]\n", ME.SKmgr->x_axis[0],
           ME.SKmgr->x_axis[1], ME.SKmgr->x_axis[2]);

  /*
   * The old state of the profile is stored in 3 chunks.
   * First we have the dimension values, next the variable values,
   * and finally the new constraints that were added.
   */
  fprintf (datfile, "\tSave state :\n");
  varinfo = ME.SKmgr->oldvars;
  i = 0;
  for (j=0; j<3; j++)
  {
    k = 0;
    if (j == 0)
      fprintf (datfile, "\t Old dim vals :\n");
    else if (j == 1)
      fprintf (datfile, "\t Old var vals :\n");
    else
      fprintf (datfile, "\t New constraints added :\n");
    while (varinfo[i].varobj != NULL_OBJID)
    {
      fprintf (datfile, "\t %d) Id %d", k, varinfo[i].varobj);

      if (j != 2)
        fprintf (datfile, ", Var [%lf", varinfo[i].var[0]);

      if (j == 1)
      {
        om$get_classid (objid = varinfo[i].varobj, p_classid = &varclass);
        if (varclass == OPP_SKptvar_class_id)
          fprintf (datfile, ", %lf", varinfo[i].var[1]);
      }
      
      if (j == 0 || j == 1)
        fprintf (datfile, "]");
      fprintf (datfile, "\n");
      i++;
      k++;
    }
    i++;
  }

  for (i=0; i<2; i++)
  {
    if (i == 0)
      EMmake_chanselect (SKmgr_to_vars, &chan);
    else
      EMmake_chanselect (SKmgr_to_constrs, &chan);
    num = 0;
    om$get_channel_count (object = me, p_chanselect = &chan, count = &num);
    if (i == 0)
      fprintf (datfile, "\tNum vars on chan: %d\n", num);
    else
      fprintf (datfile, "\tNum constraints on chan: %d\n", num);
    if (num)
    {
      objlist = (OM_p_OBJECT_LINKAGE) alloca (num *
                 sizeof (OM_S_OBJECT_LINKAGE));
      om$get_channel_objects (object = me, p_chanselect = &chan, count = &num,
                               size = num, list = objlist);
      for (j=0; j<num; j++)
        fprintf (datfile, "\t %d) %d\n", j, objlist[j].S_objid);
    }
  }

  fprintf (stderr, "\nOutput logical list of variables y/n [n]");
  keyin = getchar();
  if (toupper (keyin) == 'Y') 
  {
    varlist = NULL;
    om$send (msg = message SKmgr.SKgetvarconstrs 
                   (&msg_loc, SK_GETVR_COMPRESSED, &varlist, NULL, NULL), 
             targetid = my_id);
    if (varlist) 
    {
      fprintf (datfile, "\n");
      SKdbgvars(varlist, datfile);
      SKfreevarlist (varlist, MAXINT);
      varlist = NULL;
    }
  }

  fprintf (stderr, "\nOutput logical list of constraints y/n [n]");
  keyin = getchar();
  if (toupper (keyin) == 'Y') 
  {
    constrs = NULL;
    om$send (msg = message SKmgr.SKgetvarconstrs 
                   (&msg_loc, NULL, NULL, &num_constrs, &constrs), 
             targetid = my_id);
    if (constrs) 
    {
      fprintf (datfile, "\n");
      SKdbgconstrs (num_constrs, constrs, datfile);
      om$dealloc (ptr = constrs);
      constrs = NULL;
    }
  }
  
  fprintf (stderr, "\nOutput graph decomposition y/n [n]");
  keyin = getchar();
  if (toupper (keyin) == 'Y')
  {
    varlist = NULL;
    constrs = NULL;
    num_vars = 0;
    num_constrs = 0;
    om$send (msg = message SKmgr.SKgetvarconstrs 
                   (&msg_loc, NULL, &varlist, &num_constrs, &constrs), 
             targetid = my_id);
    /* count the number of variables */
    for (pvar = varlist; pvar; pvar = pvar->next)
      num_vars++;
    fprintf (datfile, "\nNumber of constraints = %d\n", num_constrs);
    fprintf (datfile, "Number of variables = %d\n", num_vars);
    if (varlist && constrs) 
    {
      profile.objid = my_id;
      profile.osnum = OM_Gw_current_OS;
      solvepath.action = NULL;
      solvepath.constrs = NULL;
      SKgetsolvepath5 ( &msg_loc, varlist, num_constrs, &constrs, profile,
                        &solvepath);

      if (!(msg_loc & 1))
        fprintf(stderr,"Decomposition unsuccessful due to structural singularity \n");
      else
        SKdbgspath(&solvepath, datfile);
      SKfreevarlist (varlist, MAXINT);
      om$dealloc (ptr = constrs);
      if (solvepath.constrs)
        om$dealloc ( ptr = solvepath.constrs );
      if (solvepath.action)
        om$dealloc ( ptr = solvepath.action );
    }
  }

  if (datfile != stderr)
    fclose (datfile);
  
  return (OM_S_SUCCESS);
}

end implementation SKmgr;

