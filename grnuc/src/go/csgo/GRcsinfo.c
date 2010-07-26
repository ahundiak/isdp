/*
Name
        GRcsinfo

Description
        This file contains data pulled from cspriv.h, along with
        function to return pointers to that data.  The data was pulled
        into this file to prevent unnecessary duplication of the data in
        the executable file.

History
        mrm     12/31/92    creation
*/

#include "igrtypedef.h"
#include "griodef.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "cspriv.h"
#include "grmessage.h"

/*
 *  This table is an array of NUM_CS_TYPES GRcstype_info structures.  The
 *  first field is the coordinate system type, the second field is the
 *  number of user inputs for this coordinate system type, and the third
 *  field is an index into a table containing appropriate prompts and
 *  masks for this coordinate system type.
 */

static struct GRcstype_info CSTYPES [NUM_CS_TYPES] = 
{
    /*     cs type      #inputs      index  */

    {   "rectangular",     3,          0    },
    {   "spherical",       3,          3    },
    {   "cylindrical",     3,          6    }
};

/*
 *  This table is an array of NUM_INPUT_INFO GRcsquery_info structures.
 *  The first field is an absolute (XY) prompt key, the second field is a
 *  delta (DL) prompt key, and the third field is the unit type needed.
 */

static struct GRcsquery_info QUERYINFO [NUM_INPUT_INFO] = 
{
  /*    
        XY PROMPT         DL PROMPT            UNIT TYPE    
     ---------------    ---------------    -----------------
    
                 * * *    RECTANGULAR   * * *                  
                                                                     
  */
    { GR_P_EntXVal,      GR_P_EntXDeltaVal, "UOM_DISTANCE" },
    { GR_P_EntYVal,      GR_P_EntYDeltaVal, "UOM_DISTANCE" },
    { GR_P_EntZVal,      GR_P_EntZDelValVw, "UOM_DISTANCE" },
  /*
                 * * *    SPHERICAL     * * *                  
  */
    { GR_P_EntRadMag,    GR_P_EntRadMagDlt, "UOM_DISTANCE" },
    { GR_P_EntThetaVal,  GR_P_EntThetaDlt,  "UOM_ANGLE"    },
    { GR_P_EntPhiVal,    GR_P_EntPhiDlt,    "UOM_ANGLE"    },
  /*
                 * * *    CYLINDRICAL   * * *                  
  */
    { GR_P_EntRhoVal,    GR_P_EntRhoDlt,    "UOM_DISTANCE" },
    { GR_P_EntPhiVal,    GR_P_EntPhiDlt,    "UOM_ANGLE"    },
    { GR_P_EntZMagVal,   GR_P_EntZMagDlt,   "UOM_DISTANCE" },
};

struct GRcstype_info *GRget_cstype_info()
{
    return(CSTYPES);
}

struct GRcsquery_info *GRget_csquery_info()
{
    return(QUERYINFO);
}
