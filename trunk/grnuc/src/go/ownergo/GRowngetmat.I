class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"

method GRget_matrix (IGRlong *msg; 
                     IGRshort *matrix_type; 
                     IGRmatrix matrix; 
                     IGRshort *cmp_matrix_type;
                     IGRmatrix cmp_matrix)
{
    IGRint      i;

    *msg = MSSUCC;
    *cmp_matrix_type = *matrix_type;

    for (i=0; i < 16; ++i) cmp_matrix[i] = matrix[i];

    return (OM_S_SUCCESS);
}

method GRget_context (IGRlong *msg; 
                      struct GRmd_env *mod_env;
                      struct GRmd_env *cmp_mod_env)
{
    *msg = MSSUCC;
    *cmp_mod_env = *mod_env;
    return (OM_S_SUCCESS);
}

end implementation GRowner;

