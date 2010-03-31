/*
 * 
 * 17 Dec 92  Jack  Created for defines for EFget_analytic_info().
 *                  src_surf/funk/EFgetanalinf.I
 */ 


/*
 * info_bits
 */
#define  ORTHO         0x00000001 /* O: projecting normal to plane of curve */
#define  SF_IS_PLANAR  0x00000002 /* O: surface created is planar */
#define  REPARAM       0x00000004 /* O: should reparameterize curve */
#define  DONT_CONSTR   0x00000008 /* I: don't constr surf, just return type */
#define  REVOLVE       0x00000010 /* I: on-revolution, off-projection */
#define  CV_IS_PLANAR  0x00000020 /* O: input curve is planar */
