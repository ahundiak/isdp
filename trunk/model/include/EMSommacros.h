# ifndef EMSommacros_include
# define EMSommacros_include 1
/*
History

    AIC     17 April 1989   Added nat_edges argument to
                            ems$get_rule_lines.
    AIC     13 March 1988   Modified ems$get_rule_lines to allow
                            mixing of uniform and non-uniform spacing
                            of rule lines.
    AIC     23 March 1988   Modified ems$get_rule_lines to allow
                            for uniformly spaced rule lines.
    AIC              1987   Creation Date
*/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exdef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

void EFgetRuleLineTable2 __((IGRlong *EMmsg, struct IGRbsp_surface *surf,
                             IGRint *u_by_v, struct IGResbs *in_attr,
                             IGRboolean nat_edges, IGRchar *in_buffer,
                             IGRint buffer_size, struct IGResqbs **rlt));

void EFgetMemory __((long *EMmsg, int element_size, int num_elements,
                     char *buffer, int buffer_size, int options, char **ptr)); 

#if defined(__cplusplus)
}
#endif

#undef __

/*
 * ems$get_rule_lines
 *
 * This macro is used to generate the rule line table from the
 * element-specific attributes and the geometry of a surface.
 *
 * Arguments:
 *
 *  IGRlong                 *rc         - return code
 *  struct IGRbsp_surface   *surf       - surface geometry
 *  IGRint                  u_by_v[2]   - default rule line counts
 *  struct IGResbs          *bs_attr    - element-specific attributes
 *                                        (optional)
 *  IGRboolean              nat_edges   - include natural edges ?
 *                                        (optional)
 *  IGRchar                 *in_buffer  - buffer (optional)
 *  IGRint                  buffer_size - size of buffer (required only if
 *                                        in_buffer is specified non-zero)
 *  struct IGResqbs         **rlt       - address of a pointer to the
 *                                        rule line table. (may be
 *                                        allocated or buffer)
 *
 * Note: NULL must be defined as 0.
 */
# omdef ems$get_rule_lines(rc,
                           surf = NULL,
                           u_by_v = NULL,
                           bs_attr = NULL,
                           nat_edges = TRUE,
                           in_buffer = NULL,
                           buffer_size = 0,
                           rlt)

EFgetRuleLineTable2((rc), (surf), (u_by_v), (bs_attr), (nat_edges),
                    (in_buffer), (buffer_size), (rlt));

# endomdef

/*
 * ems$get_memory
 *
 * This macro is used to get memory
 */
# omdef ems$get_memory(rc,
                       element_size = 1,
                       num_elements,
                       buffer = NULL,
                       buffer_size = 0,
                       clear = FALSE,
                       align = FALSE,
                       ptr)

# if om$equal(align, FALSE)

#   if om$equal(clear, FALSE)

    EFgetMemory((rc), (element_size), (num_elements), (buffer),
                (buffer_size), 0, (ptr));

#   else

    EFgetMemory((rc), (element_size), (num_elements), (buffer),
                (buffer_size), 1, (ptr));

#   endif

# else

#   if om$equal(clear, FALSE)

    EFgetMemory((rc), (element_size), (num_elements), (buffer),
                (buffer_size), 2, (ptr));

#   else

    EFgetMemory((rc), (element_size), (num_elements), (buffer),
                (buffer_size), 3, (ptr));

#   endif

# endif

# endomdef

# endif /* EMSommacros_include */
