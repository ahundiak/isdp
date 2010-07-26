
/*

version.h -- Intergraph-specific structure to be used to incorporate
             the version stamp and product id number of an application
             into its executable image.

             A naming convention must be followed.  The trailer of
             _appl_version_id must be used when naming your structure.
             
             Example: 

                   INGR_S_PRODUCT_DEF Ems_appl_version_id =
                   {
                      "Ems     01.04.03.05 11-Apr-1991",
                      0,
                      "SM01041",
                      0
                   };

*/

#ifndef INGR_D_VERSION
#define INGR_D_VERSION  1


struct INGR_sd_product_def {
   char *curr_version;              /* String containing version stamp   */
   int  (*version_check_func)();    /* Application-specific function ptr */
   char *product_id;                /* Application product id            */
   char *appl_specifics;            /* Application-specific string or    */
                                    /*  structure ptr                    */
};

typedef struct INGR_sd_product_def  INGR_S_PRODUCT_DEF;
typedef struct INGR_sd_product_def *INGR_p_PRODUCT_DEF;

#endif
