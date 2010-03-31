/*
   This function prints constraint basis of the part.
*/


class implementation EMinstance;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "assemconstr.h"
#include <alloca.h>


/*---------------------------------------------------------------------------+
 |                                                                           |
 | ‚Function: EMprintbasis                                                   |
 |                                                                           |
 | This function prints the basis of the part.                               |
 |                                                                           |
 | Input :  unsigned int basis_id       the basis id                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMprintbasis (basis_id)
unsigned int basis_id;
{
    char basis_text[1024];

    switch( basis_id )
    {
        case NULL_BASIS_ID:
          strcpy(basis_text, "NULL_BASIS_ID");
          break;
        case GROUND_ONE_CONSTR:
          strcpy(basis_text, "GROUND_ONE_CONSTR");
          break;
        case MATE_ONE_CONSTR:
          strcpy(basis_text, "MATE_ONE_CONSTR");
          break;
        case ALIGN_ONE_CONSTR:
          strcpy(basis_text, "ALIGN_ONE_CONSTR");
          break;
        case MATE_MATE_PERP: 
          strcpy(basis_text, "MATE_MATE_PERP");
          break;
        case MATE_MATE_ANG:  
          strcpy(basis_text, "MATE_MATE_ANG");
          break;
        case MATE_ALIGN_PERP:
          strcpy(basis_text, "MATE_ALIGN_PERP");
          break;
        case MATE_ALIGN_PAR: 
          strcpy(basis_text, "MATE_ALIGN_PAR");
          break;
        case ALIGN_ALIGN_PAR:
          strcpy(basis_text, "ALIGN_ALIGN_PAR");
          break;
        case ALIGN_ALIGN_PERP:
          strcpy(basis_text, "ALIGN_ALIGN_PERP");
          break;
        case MATE_ALIGN_ANG:	
          strcpy(basis_text, "MATE_ALIGN_ANG");
          break;
        case ALIGN_ALIGN_ANG:	
          strcpy(basis_text, "ALIGN_ALIGN_ANG");
          break;
        case MATE_MATE_MATE_PERP_PERP_PERP:
          strcpy(basis_text, "MATE_MATE_MATE_PERP_PERP_PERP");
          break;
        case MATE_MATE_MATE_PERP_PERP_ANG:
          strcpy(basis_text, "MATE_MATE_MATE_PERP_PERP_ANG");
          break;
        case MATE_MATE_MATE_PERP_ANG_ANG:
          strcpy(basis_text, "MATE_MATE_MATE_PERP_ANG_ANG");
          break;
        case MATE_MATE_MATE_ANG_ANG_ANG:
          strcpy(basis_text, "MATE_MATE_MATE_ANG_ANG_ANG");
          break;
        case MATE_MATE_ALIGN_PERP_PERP_PAR:
          strcpy(basis_text, "MATE_MATE_ALIGN_PERP_PERP_PAR");
          break;
        case MATE_ALIGN_ALIGN_PAR_PAR_PAR:
          strcpy(basis_text, "MATE_ALIGN_ALIGN_PAR_PAR_PAR");
          break;
        default:
          strcpy(basis_text, "Unknown Basis");          
          break;
    }
    return(1);
}


end implementation EMinstance;

