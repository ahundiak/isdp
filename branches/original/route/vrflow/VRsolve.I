/* $Id: VRsolve.I,v 1.1.1.1 2001/01/04 21:12:51 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflow / VRsolve.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRsolve.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/05  18:08:10  pinnacle
# Replaced: vrflow/VRsolve.I for:  by hverstee for route240
#
# Revision 1.3  1996/04/04  23:10:46  pinnacle
# Replaced: vrflow/VRsolve.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  23:56:02  pinnacle
# Replaced: vrflow/VRsolve.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *************************************************************************/
class implementation ASnode;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "GM.h"
#include "ACrg_collect.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "VRsize.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRattr_def.h"
#include "VRparamdef.h"
#include "VRstructs.h"
#include "madef.h"
#include "HV_param.h"
#include "GMndg.h"

#include "VDmem.h"

#include "vrflow_pto.h"
#include "vrconstr_pto.h"

#define AS_DEBUG


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function VRwrite_equation                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRwrite_equation(
  	IGRshort        index,       /* IN     Index of the connection point */
  	char            *attr_name,  /* IN     Attribute name                */
	double          value,       /* IN     Value to update               */
  	struct GRid     *p_object,   /* IN     Object containing the equation*/
  	char            equation[])  /* OUT    Equation found */
  /*
  Description : Given the index of a connection point, and the attribute,
                returns the corresponding equation, stored in the parameter
                box. Example: index=0, attr_name=width => depth_1 = 4.
  Constraint  : None.
  */ 
  /*.VRwrite_equation*/
  {
  int            status;       /* Status returned by the om                   */
  char syntax[VRMAX_FORMULA];  /* Syntax of the foot name                     */
  char tmp_equa[VRMAX_FORMULA];/* String to store temporary the equation      */

  /*" Get the values of index: %d\n",index */

  sprintf(syntax, VRCPT_FORMAT, index);
  strcat(syntax, attr_name);
  status = VRgive_formula(p_object, syntax, tmp_equa, VRMAX_FORMULA);
  /*gm$status();*/ status = OM_S_SUCCESS;
 
  sprintf(equation,"%s=%lf;",tmp_equa,value);

  /*" %d.%d : %s -> %s\n",p_object->objid,p_object->osnum,syntax,equation*/

  return(status);
}/* VRwrite_equation */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function VRsplit_equation                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRsplit_equation(equation, identifier, p_value)

  char            equation[];  /* IN     Equation used to update the equation */
  char            identifier[];/* OUT    Identifier name                      */
  double          *p_value;    /* OUT    Pointer to the value                 */
  /*
  Description : Given a constant equation and an object, split this one. 
                if you give:
                equation = "width_1 = 2" --> "width_1",2.0
  Constraint  : None.
  */ 
  /*.VRsplit_equation*/
  {
  char             *pos;       /* Position of a char in a string              */
  double           atof();     /* Function converting (string --> double)     */
  char             *strchr();  /* Function to find a char in a string         */
  char tmp_equa[VRMAX_FORMULA];/* Temporary equation                          */

  strcpy(tmp_equa, equation);
  pos = strchr(tmp_equa,';');
  *pos = '\0';
  pos = strchr(tmp_equa,'=');
  *pos = '\0';
  if(identifier) strncpy(identifier, tmp_equa, pos-tmp_equa+1);
  pos++;
  if(p_value) *p_value = atof(pos);
  return(OM_S_SUCCESS);
}/* VRsplit_equation */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function VRsolve_equation                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRsolve_equation(nb_maxunkn, nb_equa, l_equa, p_nb_unkn)

  int             nb_maxunkn;  /* IN     Maximum number of unknowns           */
  int             nb_equa;     /* IN     Number of equations to solve simult. */
  char            *l_equa[];   /* IN/OUT List of equations                    */
  int             *p_nb_unkn;  /* OUT    Number of unknowns in the set of eq. */
  /*
  Description : Solve a set of simultaneous equations using the simplex func.
                (only for resizing).
  Constraint  : The equations must be linear.
  */ 
  /*.VRsolve_equation*/
  {
  int              status;     /* Status returned by the om                   */
  int              index;      /* Index for a loop                            */
  int              index2;     /* Index for the matrix                        */
  struct VRslv_inf solver;     /* Solver used                                 */
  char equation[VRMAX_FORMULA];/* Temporary equation                          */
  struct VRind_name *p_pair;   /* Pointer to a pair (name <->index)           */
  struct GMlist    *p_list;    /* Pointer to the list of pairs                */

  /*| Initialize the solver */

  status = VRinit_solver(nb_maxunkn, nb_equa, &solver);

  /*| Get the number of unknowns */

  for(index=0; index < nb_equa; index++)
    {
    solver.cur_constr = index;
    status = VRparse_linear(l_equa[index],&solver);
    gm$status();
  }/* end for */

  /*| Init the solver */

  *p_nb_unkn = GMl_count(&solver.list);
  status = VRupdate_solver(*p_nb_unkn, nb_equa, &solver);
  gm$status();

  /*| Parse the equations */

  for(index=0; index < nb_equa; index++)
    {
    solver.cur_constr = index;
    /*" Parse the equation: %s",l_equa[index]*/
      
    status = VRparse_linear(l_equa[index],&solver);
    gm$status();
  }/* end for */

  /*| Initialize Inequalities and weigths */

  index2 = nb_equa*(*p_nb_unkn);
  for(index=0; index < *p_nb_unkn; index++) solver.matrix[index2+index] = 1.;
  for(index=0; index < nb_equa; index++) solver.vector[nb_equa+index] = 1.;

  /*| Solve the system */

/*^
int size_mat = (nb_equa+1)*(*p_nb_unkn+2);
printf("nb_equa = %d\n",nb_equa);
printf("nb_unkn = %d\n",*p_nb_unkn);
for(index=0; index < size_mat; index++)
printf("matrix[%d]=%lf\n",index,solver.matrix[index]);
*/
  status = VRsimplex(*p_nb_unkn, nb_equa, solver.matrix, solver.vector);
  gm$status();

  /*| Rewrite the equations */

  p_list = &solver.list;
  for(GMl_first(p_list); !GMl_at_end(p_list); GMl_next(p_list))
    {
    p_pair = (struct VRind_name *)GMl_current(p_list);
    sprintf(equation,"%s=%lf;",p_pair->name,solver.matrix[p_pair->index]);

    if(strlen(l_equa[p_pair->index]) < strlen(equation))
    {
      _FREE(l_equa[p_pair->index]);
      l_equa[p_pair->index] = _MALLOC (strlen(equation) + 1, char);
    }

    strcpy(l_equa[p_pair->index],equation);
    /*" result[%d]: %s\n",p_pair->index,l_equa[p_pair->index]*/
  }/* end for */
  
exception:
  VRfree_solver(&solver);

  return(status);
}/* VRsolve_equation */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function VRinit_solver                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRinit_solver(nb_unkn, nb_equa, p_solver)

  int             nb_unkn;     /* IN     Number of unknowns in the set of eq. */
  int             nb_equa;     /* IN     Number of equations to solve simult. */
  struct VRslv_inf *p_solver;  /* IN/OUT Solver to initialize                 */
  /*
  Description : Initialize a VRslv_inf structure.
  Constraint  : none.
  */ 
  /*.VRinit_solver*/
  {
  int              index;     /* Index for a loop                             */
  int              size_mat;  /* Size of the matrix                           */
  
  /*| Initialize the list (name <--> index) */
 
  size_mat = (nb_equa+1)*(nb_unkn+2);
  p_solver->nb_unkn    = nb_unkn;
  p_solver->nb_constr  = nb_equa;
  p_solver->cur_constr = 0;
  p_solver->matrix     = _MALLOC (size_mat, double);
  if(!(p_solver->matrix)) return GM_E_NODYNMEM;
  p_solver->vector     = &p_solver->matrix[(nb_equa+1)*nb_unkn];

  for(index=0; index < size_mat; index++) p_solver->matrix[index] = 0.;
    
  return GMl_activate(VR_MAX_DIM,VR_MAX_DIM,sizeof(struct VRind_name),
             VRcmp_name,NULL,NULL,&p_solver->list);
}/* VRinit_solver */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function VRupdate_solver                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRupdate_solver(nb_unkn, nb_equa, p_solver)

  int             nb_unkn;     /* IN     Number of unknowns in the set of eq. */
  int             nb_equa;     /* IN     Number of equations to solve simult. */
  struct VRslv_inf *p_solver;  /* IN/OUT Solver to update                     */
  /*
  Description : update a VRslv_inf structure.
  Constraint  : none.
  */ 
  /*.VRupdate_solver*/
  {
  int              index;     /* Index for a loop                             */
  int              size_mat;  /* Size of the matrix                           */
  
  /*| update the list (name <--> index) */
 
  size_mat = (p_solver->nb_constr+1)*(p_solver->nb_unkn+2);
  p_solver->nb_unkn    = nb_unkn;
  p_solver->nb_constr  = nb_equa;
  p_solver->cur_constr = 0;

  if((p_solver->nb_constr+1)*(p_solver->nb_unkn+2) > size_mat)
    {
    _FREE(p_solver->matrix);
    p_solver->matrix     = _MALLOC (size_mat, double);
    if(!(p_solver->matrix)) return GM_E_NODYNMEM;
    p_solver->vector     = &p_solver->matrix[(nb_equa+1)*nb_unkn];
    size_mat = (p_solver->nb_constr+1)*(p_solver->nb_unkn+2);
  }/* end if */
  for(index=0; index < size_mat; index++) p_solver->matrix[index] = 0.;
   
  return GMl_clear(&p_solver->list); 
}/* VRupdate_solver */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function VRfree_solver                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRfree_solver(p_solver)

  struct VRslv_inf *p_solver;  /* IN/OUT Solver to free                       */
  /*
  Description : free all the memory used by the solver.
  Constraint  : The solver must be initialized before, using VRinit_solver
                function.
  */ 
  /*.VRfree_solver*/
  {
  if(p_solver->matrix)
    {
    _FREE(p_solver->matrix);
  }/* end if */
  return GMl_disactivate(&p_solver->list);
}/* VRfree_solver */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function VRgive_index                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRgive_index(name, p_solver, p_index)

  char             name[];     /* IN     Name of the identifier               */
  struct VRslv_inf *p_solver;  /* IN/OUT Solver containing the information    */
  int              *p_index;   /* OUT    Pointer to the corresponding index   */
  /*
  Description : Given an Identifier, returns its column index in the matrix
                (simplex matrix).
  Constraint  : none.
  */ 
  /*.VRgive_index*/
  {
  struct VRind_name attr;      /* attribute to add in the simplex             */
  int status = OM_S_SUCCESS;   /* Status returned by the function             */

  strcpy(attr.name,name);

  if(!GMl_select(&attr, &p_solver->list))
    {
    /*" Add %s in the list\n",name*/

    attr.index = p_solver->list.nb_elmt;
    status = GMl_add(&attr, &p_solver->list);
  }/* end if */
  *p_index = p_solver->list.current_ind;
 
  /*" name = %s <-> index = %d\n",name,*p_index*/ 
  return(status);
}/* end VRgive_index*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function VRadd_in_mat                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRadd_in_mat(value, p_solver, index)

  double           value;      /* IN     Value to add in the solver           */
  int              index;      /* IN     Column index to add the value        */
  struct VRslv_inf *p_solver;  /* IN/OUT Solver containing the information    */
  /*
  Description : Add a value in the simplex matrix of a solver at indexes:
                p_solver->cur_constr for the row,
                index for the column.
  Constraint  : none.
  */ 
  {
  p_solver->matrix[p_solver->cur_constr*p_solver->nb_unkn+index] = value;
  return(OM_S_SUCCESS);
}/* end VRadd_in_mat*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                               function VRnumber                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRnumber(string)

  char             string[];   /* IN     String to test                       */
  /*
  Description : return 0 if the string is not a number
  Constraint  : none.
  */ 
  {
  char             test_str[2];/* String to test                              */
  char             *strpbrk(); /* Function to find chars in a string          */

  test_str[0] = string[0];
  test_str[1] = '\0';
  return (int)strpbrk(test_str,".0123456789");
}/* end VRnumber*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function VRconst_formula                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRconst_formula(formula)

  char          formula[];      /* IN     Formula to test                     */
  /*
  Description : Return TRUE if the formula is a constant expression
  Constraint  : none
  */ 
  /*.VRconst_formula*/
  {
  return (strpbrk(formula,"+-/*") == 0);
}/* VRconst_formula */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function VRparse_linear                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRparse_linear(equa, p_solver)

  char             equa[];     /* IN     String to parse                      */
  struct VRslv_inf *p_solver;  /* IN/OUT Solver containing the information    */
  /*
  Description : Add all the coefficients of a linear equation in the solver.
  Constraint  : none.
  */ 
  {
  char             *pos;       /* Position of a char in a string              */
  char             *cur;       /* Current position in the string              */
  int              len;        /* Length of a temporary string                */
  char             *pos2;      /* Position of a char in a string              */
  char             *cur2;      /* Current position in the string              */
  int              len2;       /* Length of a temporary string                */
  double           atof();     /* Function converting (string --> double)     */
  int              t_minus=0;  /* Token for Unary minus operator              */
  double           t_coeff;    /* Contain the coefficient value               */
  char  t_ident[VRMAX_FORMULA];/* Temporary identifier                        */
  char  string[VRMAX_FORMULA]; /* Temporary storage for a string              */
  char             operator;   /* Operator to apply to coefficients           */
  int              idt_ind;    /* Indentifier index                           */

  /* Clean the string */

  VRclean_string(equa,"( )");

  /* Analyse the first linear part */
  
  cur=equa;
  pos=strpbrk(cur,"+-=");
  do
    {
    len = (pos-cur);
    t_coeff = 1.0;

    if(!len)
      {
      /* Load the sign of the coefficient */

      if((*pos) == '-'){ t_minus = 1;}
      else if((*pos) == '+')t_minus = 0;
      else return(OM_W_ABORT);
      cur++;
      pos=strpbrk(cur,"+-=");
      len = pos - cur;
    }/*if(!len)*/

    strncpy(string, cur,len);
    string[len] = '\0';
    for(cur2=string,pos2=strpbrk(cur2,"*/"); ; pos2=strpbrk(cur2,"*/"))
      {
      /* Analyse the string %s\n",cur2*/

      if(pos2)
        {
        len2 = pos2 - cur2;
        operator = *pos2;
        }
      else len2 = strlen(cur2);

      if(len2)
        {
        cur2[len2] = '\0';
        if(VRnumber(cur2))
          {
          switch(operator)
            {
            case '*': {t_coeff *=atof(cur2);break;}
            case '/': {t_coeff /=atof(cur2);break;}
            default: printf("default\n");
          }/* end switch */
          }
        else strcpy(t_ident, cur2);
      }/* end if(len2)*/

      if(!pos2) break;
      else cur2 = pos2+1;
    }/* end for*/
    if(t_minus) t_coeff *= -1;

    /*" Update coeff %lf at index: %s\n",t_coeff,t_ident*/

    VRgive_index(t_ident, p_solver, &idt_ind);
    VRadd_in_mat(t_coeff, p_solver, idt_ind);
    cur = pos;
    pos=strpbrk(cur,"+-=");
  }while((*pos) != '=');

  /*" Load the second term of %s\n",equa */

  cur = strchr(pos,'=');
  cur++;
  len = strchr(cur,';') - cur;
  strncpy(string, cur, len);
  string[len] = '\0';

  /*" b[%d] = %lf\n",p_solver->cur_constr,string*/
  p_solver->vector[p_solver->cur_constr] = atof(string);

  return(OM_S_SUCCESS);
}/* end VRparse_linear*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function VRclean_string                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRclean_string(string, l_char)

  char             string[];   /* IN     String to test                       */
  char             l_char[];   /* IN     List of char to remove               */
  /*
  Description : remove all the instances of several chars form a string
  Constraint  : none.
  */ 
  {
  char             *pos;       /* Position of a char in a string              */
  int              len;        /* Length of the string                        */
  int              index;      /* Index for a loop                            */

  for(pos = strpbrk(string,l_char); pos; pos = strpbrk(string,l_char))
    {
    len = strlen(string);
    for(index = pos - string; index < len; index++)
      string[index] = string[index+1];
  }/* end for */

  return (1);
}/* end VRclean_string*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       INTERNAL function VRcmp_name                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRcmp_name(p_ext_key, p_int_key)

  struct VRind_name *p_ext_key;/* IN     Key of the external elmt to compare  */
  struct VRind_name *p_int_key;/* IN     Key of the internal elmt to compare  */
  {
  return(strcmp(p_ext_key->name,p_int_key->name));
}/* end VRcmp_name*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASnode;

