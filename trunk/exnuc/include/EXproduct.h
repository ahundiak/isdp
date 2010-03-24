/* EXproduct.h
 *
 * The following structure defines a node on the EX_product_list
 * linked list.  There will be one node in the list for every
 * valid entry in the product_data file.  This linked list is
 * used hold information pertaining to the products in the
 * product_data file, such as the file system path to the product.
 */

#include <version.h>

/* Flag defs */

#define  EXPROD_DLOADED       0x01  /* som_dload_class has been called
                                       successfully for this product's files */
#define  EXPROD_FORCE_DLOADED 0x02  /* product was dloaded via
                                       EX_force_dload_prod.  If this flag is
                                       set, EXPROD_DLOADED is set also */
#define  EXPROD_PREDLOADED    0x04  /* Product is awaiting status from
                                       som_dload_class call */

/* Codes used by EX_get_prod_info.  Even codes say user gave us the
 * product logo; odd codes say user gave us the product run name.
 */

#define EXPROD_GET_FLAG_BY_LOGO        0
#define EXPROD_GET_FLAG_BY_RUNNAME     1
#define EXPROD_GET_RUNNAME_BY_LOGO     2
#define EXPROD_GET_LOGO_BY_RUNNAME     3
#define EXPROD_GET_CONFIG_BY_LOGO      4
#define EXPROD_GET_CONFIG_BY_RUNNAME   5


struct EX_prod_def
{
   char              	*run_name;
   char              	*logo;
   char              	*module;
   char              	*srch_path;
   char              	*config_path;
   char              	*product_path;
   int               	license;    /* Returned from get_license() */
   int               	status;     /* Status of get_license call */
   int               	flags;
   INGR_p_PRODUCT_DEF   *ingr;      /* Structures defined in version.h */
   struct EX_prod_def	*next;
};

#define EX_saveOnClose  0x01     /* Tells close visible whether to write file */
#define EX_exitOnClose  0x02     /* Tells close visible if about to exit */
