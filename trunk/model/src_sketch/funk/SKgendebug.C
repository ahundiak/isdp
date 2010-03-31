#include "EMS.h"
#include <stdio.h>
#include <string.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpstruct.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"
#include <alloca.h>

void SKdbggeom (geom, file)
struct SKgeomselect *geom;
FILE *file;
{
  IGRboolean error;
  IGRchar str[20];
  IGRdouble *ptr;
  struct SKvector *vec;
  struct SKdistline *distline;
  struct SKline *line;
  struct SKbspcurve *bspcurve;
  enum SKgeomtype type;
  FILE *lfile;

  if (!file)
    lfile = stderr;
  else
    lfile = file;

  type = geom->geomtype;
  if (type == SKvector)
    strcpy (str, "SKvector");
  else if (type == SKline)
    strcpy (str, "SKline");
  else if (type == SKdistline)
    strcpy (str, "SKdistline");
  else if (type == SKbspcurve)
    strcpy (str, "SKbspcurve");
  else if (type == SKnullgeom)
    strcpy (str, "SKnullgeom");
  else
    strcpy (str, "JUNK");
  fprintf (lfile, "\tGeom type= %s\n", str);
  switch (type)
    {
    case SKvector:
      vec = &geom->geom.vector;
      fprintf (lfile, "\tType = %d\n", vec->type);
      fprintf (lfile, "\tVec = [%lf, %lf, %lf]\n",
       vec->vec[0], vec->vec[1], vec->vec[2]);
      break;
    case SKdistline:
      distline = &geom->geom.distline;
      fprintf (lfile, "\tType = %d\n", distline->type);
      fprintf (lfile, "\tDistvec = [%lf, %lf, %lf]\n",
       distline->distvec[0], distline->distvec[1], distline->distvec[2]);
      fprintf (lfile, "\tVecdist = %lf\n", distline->vecdist);
      fprintf (lfile, "\tDirvec = [%lf, %lf, %lf]\n",
       distline->dirvec[0], distline->dirvec[1], distline->dirvec[2]);
      break;
    case SKline:
      line = &geom->geom.line;
      if (line->type == BOUNDED_LINE)
        fprintf (lfile, "\tType = Bounded line\n");
      else if (line->type == SEMIINFI_LINE)
        fprintf (lfile, "\tType = Semi-infinite line\n");
      else if (line->type == INFI_LINE)
        fprintf (lfile, "\tType = Infinite line\n");
      else
        fprintf (lfile, "\tType = JUNK\n");
      if (line->line.point1 != line->pt1)
        fprintf (lfile, "Error in pt1\n");
      else
        fprintf (lfile, "\tPt1 = [%lf, %lf, %lf]\n",
         line->pt1[0], line->pt1[1], line->pt1[2]);
      if (line->line.point2 != line->pt2)
        fprintf (lfile, "Error in pt2\n");
      else
        fprintf (lfile, "\tPt2 = [%lf, %lf, %lf]\n",
         line->pt2[0], line->pt2[1], line->pt2[2]);
      break;
    case SKbspcurve:
      bspcurve = &geom->geom.bspcurve;
      if (bspcurve->type == CIRCLE_CIR)
        {
        fprintf (lfile, "\tType = Circle circle\n");
        ptr = bspcurve->defpts[0];
        fprintf (lfile, "\tCenter = [%lf, %lf, %lf]\n",
         ptr[0], ptr[1], ptr[2]);
        ptr = bspcurve->defpts[1];
        fprintf (lfile, "\tCircum = [%lf, %lf, %lf]\n",
         ptr[0], ptr[1], ptr[2]);
        }
      /*
      else if (bspcurve->type == CIRCLE_ARC)
        {
        fprintf (lfile, "\tType = Circular arc\n");
        ptr = bspcurve->defpts[0];
        fprintf (lfile, "\tCenter = [%lf, %lf, %lf]\n",
         ptr[0], ptr[1], ptr[2]);
        ptr = bspcurve->defpts[1];
        fprintf (lfile, "\tStart = [%lf, %lf, %lf]\n",
         ptr[0], ptr[1], ptr[2]);
        ptr = bspcurve->defpts[2];
        fprintf (lfile, "\tStop = [%lf, %lf, %lf]\n",
         ptr[0], ptr[1], ptr[2]);
        }
      else if (bspcurve->type == FREE_BSP)
        fprintf (lfile, "\tType = Free form B-spline\n");
      */
      else
        fprintf (lfile, "\tType = JUNK\n");
       
      error = FALSE;
      if (bspcurve->curve.poles != (double *) bspcurve->poles)
        {
        fprintf (lfile, "Error in poles\n");
        error = TRUE;
        }
      if (bspcurve->curve.knots != bspcurve->knots)
        {
        fprintf (lfile, "Error in knots\n");
        error = TRUE;
        }
      if (bspcurve->curve.rational)
        {
        if (bspcurve->curve.weights != bspcurve->weights)
          {
          fprintf (lfile, "Error in weights\n");
          error = TRUE;
          }
        }
      if (!error && lfile != stderr)
        prtbspc (&bspcurve->curve);
      break;
    default:
      fprintf (lfile, "\tJunk geom type\n");      
    }
  fprintf (lfile, "\n");
  return;
}

void SKdbgvars (vars, file)
struct SKsolvevars *vars;
FILE 		   *file;
{
  IGRint 	inx;
  FILE 		*datfile;
  
  if (!file)
    datfile = stderr;
  else
    datfile = file;
    
  fprintf (datfile, "\n");
  inx = 0;
  while (vars)
  {
    fprintf (datfile, "%2d) Props = 0x%x\n", inx, vars->props);
    fprintf (datfile, "    Varobj: %d\n", vars->varobj);

    if ((vars->props & VAR_PT) == VAR_PT)
      fprintf (datfile, "    XYZ: [%lf %lf %lf]\n",
       vars->var[0], vars->var[1], vars->var[2]);
    else if (vars->props & VAR_X)
      fprintf (datfile, "    X: [%lf]\n", vars->var[0]);
    else if (vars->props & VAR_Y)
      fprintf (datfile, "    Y: [%lf]\n", vars->var[1]);
    else if (vars->props & VAR_FIRSTDIM)
      fprintf (datfile, "    V: [%lf]\n", vars->var[0]);

    fprintf (datfile, "    Constrids: %d %d\n", vars->constrid1, vars->constrid2);
    if (vars->varname)
      fprintf (datfile, "    Name: %s\n", vars->varname);
    else
      fprintf (datfile, "    Name:\n");

    vars = vars->next;
    inx++;
  }
  fflush (datfile);
  return;
}


void SKdbgconstrs (num_constrs, constrs, file)
IGRint 			num_constrs;
struct SKconstrinfo 	*constrs;
FILE			*file;
{
  IGRint  i;
  FILE    *datfile;
  
  if (!file)
    datfile = stderr;
  else
    datfile = file;

  fprintf (datfile, "\n");
  for (i=0; i<num_constrs; i++)
    {
    fprintf (datfile, "%2d) C-props = 0x%x ", i, constrs[i].cprops);
    fprintf (datfile, "(");
    if (constrs[i].cprops & CONSTR_PSEUDO_EQN)
      fprintf (datfile, "Pseudo-eqn ");
    if (constrs[i].cprops & CONSTR_GRND_X)
      fprintf (datfile, "Ground-X ");
    if (constrs[i].cprops & CONSTR_GRND_Y)
      fprintf (datfile, "Ground-Y ");
    if (constrs[i].cprops & CONSTR_PSEUDO_VAR)
      fprintf (datfile, "Pseudo-var ");
    if (constrs[i].cprops & CONSTR_EQUAL_EQN)
      fprintf (datfile, "Equal-eqn ");
    if (! (constrs[i].cprops & CONSTR_REGULAR))
      fprintf (datfile, "Not regular ");
    fprintf (datfile, ")\n");
    fprintf (datfile, "    Constrid: %d\n", constrs[i].constrid);

    fprintf (datfile, "    V-props = 0x%x", constrs[i].vprops);
    fprintf (datfile, " (");
    if (constrs[i].vprops & VAR_VAL)
      fprintf (datfile, "Var-value ");
    if (constrs[i].vprops & VAR_PSEUDO_VAL)
      fprintf (datfile, "Var-pseudoval ");
    if (constrs[i].vprops & VAR_X)
      fprintf (datfile, "Var-X ");
    if (constrs[i].vprops & VAR_Y)
      fprintf (datfile, "Var-Y ");
    fprintf (datfile, ")\n");
    fprintf (datfile, "    Varid: %d\n", constrs[i].varsolveid);
    }
  fflush (datfile);
  return;
}

void SKdbgmatrix (profile, constrs, varlist, num_constrs)
struct GRid profile;
IGRint num_constrs;
struct SKconstrinfo *constrs;
struct SKsolvevars  *varlist;
{
  IGRchar filename[20];
  IGRint  i,j, index, num_vars;
  FILE    *datfile;
  IGRlong msg;
  struct  SKsolvevars *pvar;
  IGRint  *o_matrix;

  printf("inside SKdbgmatrix\n");

  /* count the number of variables */
  for (pvar = varlist, num_vars = 0; pvar; pvar = pvar->next, num_vars++);

  /* initialize the occurrence matrix to zero */
  o_matrix = (int *)alloca ( num_constrs * num_vars * sizeof ( IGRint ) );
  memset (o_matrix, 0,  num_constrs * num_vars * sizeof ( IGRint ) );

  /* for each constraint, we get the variables it is connected to */
  msg = MSSUCC;
  SKgetadjvars ( &msg, NULL, varlist, num_constrs, constrs, profile.osnum );

  if (msg & 1)
  {
    for (i = 0; i < num_constrs; i++)
    {
      printf ( "%d variables are connected to constraint %d: ", 
               constrs [i].num_adjvars, constrs [i].constrid );
      for (j = 0; j < constrs [i].num_adjvars; j++)
      {
        printf ( "%d", constrs [i].adjvars [j]->varobj );
        if (constrs [i].adjvars [j]->props & VAR_VAL)
          printf ( ".V " );
        else
          if (constrs [i].adjvars [j]->props & VAR_X)
            printf ( ".X " );
          else
            if (constrs [i].adjvars [j]->props & VAR_Y)
              printf ( ".Y " );
            else
              printf ( ".? " );
      }
      printf ( "\n" );

      /* compute the index of each variable */
      for (j = 0; j < constrs [i].num_adjvars; j++)
      {
        for (pvar = varlist, index = 0; pvar; pvar = pvar->next, index++)
          if (constrs [i].adjvars [j] == pvar)
            break;
        if (pvar)
          o_matrix[i*num_vars+index] = 1;
        else
          fprintf ( stderr, "FATAL BUGCHECK in file %s at line %d, variable not in the list\n",
                    __FILE__, __LINE__ );

      }
    }
  }

  printf ("File _: ");
  scanf ("%s", filename);
  if (filename[0] == '.')
    datfile = stderr;
  else
    datfile = fopen (filename, "w");
  if (!datfile)
    return;

  fprintf(datfile, "%d\n", num_vars);
  fprintf(datfile, "%d\n", num_constrs);

  for (i=0; i < num_constrs; i++)
  {
     for (j=0; j < num_vars; j++)
        fprintf(datfile, "%d ", o_matrix[i*num_vars+j]);
     fprintf(datfile,"\n");
  }
  if (datfile != stderr) 
     fclose(datfile);
}
     
SKdbgspath ( path, file )
struct SKsolvepath *path        /* The solution path	  IN */;
FILE		   *file	/* file pointer to print  IN */;
/*
   This function prints a solution path for a profile.
*/
{
  int i, exec_type, num_simul, tot_sc;
  char vp;
  FILE *datfile;
  
  if (!file)
    datfile = stderr;
  else
    datfile = file;
  
  i = 0;
  tot_sc = 0;

  while (i < path->num_constrs)
  {
     exec_type = path->action[i];

     if (exec_type == PATH_EVALCONSTR) 
     {
        num_simul = 1;
        tot_sc++;
     }
     else if (exec_type == PATH_SIMULCONSTR || exec_type == PATH_OSIMULCONSTR)
     {
        tot_sc++;
        num_simul = 0;
        while (path->action[i+num_simul] == exec_type)
           num_simul++;
     }
     
     fprintf(datfile, "\n");
     if (num_simul > 1)
        fprintf(datfile, "\nStrong component with %d equations\n", num_simul);

     while (num_simul > 0)
     {
        switch (path->constrs[i].vprops) {
           case VAR_X:
              vp = 'X';
              break;
           case VAR_Y:
              vp = 'Y';
              break;
           case VAR_VAL:
              vp = 'V';
              break;
           case VAR_PSEUDO_VAL:
              vp = 'P';
              break;
           default:
              vp = '?';
              break;
        }
        
        fprintf ( datfile, "For constraint %lu.%x execute action %s for %d.%c\n",
             path->constrs [i].constrid, path->constrs[i].cprops,
             path->action [i] == PATH_EVALCONSTR ? "PATH_EVALCONSTR"
                                   : path->action [i] == PATH_SIMULCONSTR 
                                     ? "PATH_SIMULCONSTR" 
                                     : "PATH_OSIMULCONSTR",
             path->constrs[i].varsolveid, vp );
        num_simul--;
        i++;
     }
  }
  fprintf(datfile, "\nTotal no. of decomposed blocks = %d\n", tot_sc);
  if (path->num_constrs)
  {
    if (tot_sc > 1)
      fprintf(datfile, "\nDecomposition %%age = %f\n", 100.0*tot_sc/path->num_constrs);
    else
      fprintf(datfile, "\nDecomposition %%age = 0\n");
  }
  return OM_S_SUCCESS;
}


