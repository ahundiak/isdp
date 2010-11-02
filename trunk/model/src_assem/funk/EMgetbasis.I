/*

Name
  EMgetbasis.I

Description

This file has the routines to determine the basis to position the 
part as a function of the constraints incident on the part and their 
relative angle.

Notes


 */

class implementation EMinstance;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "emsdef.h"
#include "emserr.h"
#include "AS_status.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "assemconstr.h"
#include <values.h>


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_basis()                                                   |
 |                                                                           |
 |   This file has the routines to determine the basis to position the       |
 |   part as a function of the constraints incident on the part and their    |
 |   relative position.                                                      |
 |                                                                           |
 |                                                                           |
 | Input: num_inc		  # of incident constraints                  |
 |        unsigned int constype[] The set of incident constraints            |
 |        double rel_angle[]      The relative angle between constraints     |
 | Output: unsigned int *pbasis_id  The basis id OUT                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/


int EMget_basis(num_inc, constype, rel_angle, pbasis_id)
IGRint num_inc;	                   /* The # of incident constr */
unsigned int constype[];           /* The set of incident constraints */
IGRdouble rel_angle[];                /* The relative angle between constraints */
unsigned int *pbasis_id;           /* The basis id OUT */
{
  unsigned int constr_basis;
  unsigned int ang_basis;  
  int constr_cntr;
  int ang_cntr;

  constr_basis = 0x0000;
  ang_basis = 0x0000;

  *pbasis_id = NULL_BASIS_ID;
  
  for (constr_cntr = 0; constr_cntr < num_inc; constr_cntr++)
     constr_basis | = constype[constr_cntr];

  if (num_inc == 3)
    for (ang_cntr = 0; ang_cntr < num_inc; ang_cntr++)
       if (rel_angle[ang_cntr] == M_PI/2.)
          ang_basis | = ANG_PERP;
       else if ((rel_angle[ang_cntr] == 0) || (rel_angle[ang_cntr] == M_PI))
          ang_basis | = ANG_PAR;
       else 
          ang_basis | = ANG_ACUTE;


  switch (num_inc) 
  {
    case 1:
        if (constr_basis == MATE)
          *pbasis_id = MATE_ONE_CONSTR;    
        else if (constr_basis == ALIGN)
          *pbasis_id = ALIGN_ONE_CONSTR;
        else if (constr_basis == GROUND)
          *pbasis_id = GROUND_ONE_CONSTR;
        break;    

    case 2:  
        if (constr_basis == (MATE | MATE))
        {
          if (rel_angle[0] == M_PI/2.)
            *pbasis_id = MATE_MATE_PERP;
          else if ((rel_angle[0] != 0) && (rel_angle[0] != M_PI))
            *pbasis_id = MATE_MATE_ANG;
        }
        
        else if (constr_basis == (MATE | ALIGN))        
        {        
          if (rel_angle[0] == M_PI/2.)
            *pbasis_id = MATE_ALIGN_PERP;
          else if ((rel_angle[0] == 0) || (rel_angle[0] == M_PI))
            *pbasis_id = MATE_ALIGN_PAR;
          else 
            *pbasis_id = MATE_ALIGN_ANG;
        }
        else if (constr_basis == (ALIGN | ALIGN))        
        {         
          if (rel_angle[0] == M_PI/2.)
            *pbasis_id = ALIGN_ALIGN_PERP;
          else if ((rel_angle[0] == 0) || (rel_angle[0] == M_PI))
            *pbasis_id = ALIGN_ALIGN_PAR;
          else 
            *pbasis_id = ALIGN_ALIGN_ANG;
        }
        break;
  
    case 3:  
        if (constr_basis == (MATE))
        {
          if (ang_basis == (ANG_PERP | ANG_PERP | ANG_PERP))
            *pbasis_id = MATE_MATE_MATE_PERP_PERP_PERP;
          else if (ang_basis == (ANG_PERP | ANG_PERP | ANG_ACUTE))
            *pbasis_id = MATE_MATE_MATE_PERP_PERP_ANG;            
          else if (ang_basis == (ANG_PERP | ANG_ACUTE | ANG_ACUTE))            
            *pbasis_id = MATE_MATE_MATE_PERP_ANG_ANG;            
          else if (ang_basis == (ANG_ACUTE | ANG_ACUTE | ANG_ACUTE))
            *pbasis_id = MATE_MATE_MATE_ANG_ANG_ANG;
        }
        else if (constr_basis == (MATE | ALIGN))
        {        
          int num_mate = 0;
          
          for (constr_cntr = 0; constr_cntr < num_inc; constr_cntr++)
             if (constype[constr_cntr] == MATE) num_mate++;
                  
          if (num_mate == 2)
          {
            int num_par = 0;
        
            for (ang_cntr = 0; ang_cntr < num_inc; ang_cntr++)
               if ((rel_angle[ang_cntr] == 0) || (rel_angle[ang_cntr] == M_PI))
                  num_par++;
                    
            if ((ang_basis == (ANG_PERP | ANG_PAR)) && (num_par == 1))
              if ((((rel_angle[0] == 0) || (rel_angle[0] == M_PI)) && 
                 ((constype[0] | constype[1]) == (MATE | ALIGN)))
                                           ||
                ( ((rel_angle[1] == 0) || (rel_angle[1] == M_PI)) && 
                 ((constype[1] | constype[2]) == (MATE | ALIGN)))
                                           ||
                ( ((rel_angle[2] == 0) || (rel_angle[2] == M_PI)) && 
                 ((constype[2] | constype[0]) == (MATE | ALIGN))))
                  *pbasis_id = MATE_MATE_ALIGN_PERP_PERP_PAR;
          }
          else 
          {        
            if (ang_basis == (ANG_PAR | ANG_PAR | ANG_PAR))
               *pbasis_id = MATE_ALIGN_ALIGN_PAR_PAR_PAR;
          }
        }
        break;
    
    default:
       return (EMS_S_Success);
  }
  return (EMS_S_Success);
}
end implementation EMinstance;


