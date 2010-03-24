#include <exsysdep.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <EXproduct.h>
#include <OMmacros.h>

extern char          *getenv();
extern char	     *stralloc();
extern char          *getenv();

char  EX_proddata_file[MAXPATHLEN];  /* product_data file name */
struct EX_prod_def   *EX_product_list = NULL;


int EX_read_product_data()
{
   FILE                 *fp;
   struct EX_prod_def   **prodDef;
   char                 *pdata, *ptr, *eol,
                        *fname = NULL;
   char                 *sep = " \t";   /* seperator string for strtok */
   char                 buff[MAXPATHLEN];
   char                 *ingrhome;
   int                  nbytes;
#if defined(CLIX)
   struct statl         statbuf;
#elif defined(SUNOS) || defined (IRIX)
   struct stat          statbuf;
#else
#error OS does not define stat structure
#endif

   /* See if user has specified an alternate product_data file */

   if (EX_proddata_file[0] != '\0')
   {
      strncpy(&buff[0],EX_proddata_file,MAXPATHLEN);/*input from command line*/
      buff[MAXPATHLEN - 1] = 0;
   }
   else if(ingrhome = getenv("INGRHOME"))
   {
      nbytes = MAXPATHLEN - 14;  /* Leave room in buff for /product_data\0 */
      strncpy(&buff[0],ingrhome, nbytes);
      buff[nbytes] = '\0';
      strcat(buff,"/product_data");
   }
   else
      strcpy(&buff[0], "/usr/ip32/product_data");  /* Default file name */
   fname = &buff[0];
#if defined(CLIX)
   if (statl(fname, &statbuf) == -1)
#elif defined(SUNOS) || defined (IRIX)
   if (stat(fname, &statbuf) == -1)
#else
#error OS does not define stat routine
#endif
   {
      fprintf(stderr, "EX_read_product_data: stat system call failed for <%s>\n",
         fname);
      perror("");
      return(0);
   }
   if (!(fp = (FILE *) fopen(fname, "r")))
   {
      fprintf(stderr, "EX_read_product_data: could not open <%s>\n", fname);
      perror("");
      return(0);
   }
   if (!(pdata = (char *) om$malloc(size = statbuf.st_size + 1)))
   {
      fprintf(stderr, "EX_read_product_data: could not allocate %d bytes for product info.\n",
         statbuf.st_size + 1);
      fclose(fp);
      return(0);
   }

   /* Read all of the product_data file */

   if (fread(pdata, 1, statbuf.st_size, fp) != statbuf.st_size)
   {
      fprintf(stderr, "EX_read_product_data: could not read <%s>.\n", fname);
      fclose(fp);
      return(0);
   }
   fclose(fp);
   pdata[statbuf.st_size] = '\0';  /* To halt runaway strchr calls */

   prodDef = &EX_product_list;
   for (ptr = pdata; eol = strchr (ptr, '\n'); ptr = eol + 1) {
     *eol = '\0';
     if (*ptr == '#')
       continue;

     if (ptr = strchr (ptr, '"')) {
       char *run_name    = strtok (++ptr, "\"");
       char *logo        = strtok (0, sep);
       char *module      = strtok (0, sep);
       char *srch_path   = strtok (0, sep);
       char *config_path = strtok (0, sep);
       char *prod_path   = strtok (0, sep);

       if (run_name && logo && module && srch_path && config_path) {

         /* allocate a node */

         if (!((*prodDef) = (struct EX_prod_def *)
                      om$calloc(size = sizeof(struct EX_prod_def), num = 1))) {
           fprintf(stderr, "EX_read_product_data: Could not allocate product definition structure\n");
           return(0);
         }
         (*prodDef)->next = NULL;

         /* fill in info */

         if (config_path[strlen (config_path) - 1] != '/') {
           strcpy (buff, config_path);
           strcat (config_path = buff, "/");
         }
         if ( !((*prodDef)->run_name    = stralloc (run_name))    ||
              !((*prodDef)->logo        = stralloc (logo))        ||
              !((*prodDef)->module      = stralloc (module))      ||
              !((*prodDef)->srch_path   = stralloc (srch_path))   ||
              !((*prodDef)->config_path = stralloc (config_path))    ) {
           fprintf(stderr, "EX_read_product_data: Could not allocate a string.\n");
           return(0);
         }
         if (!prod_path)
           (*prodDef)->product_path = (*prodDef)->config_path;
         else if (prod_path[strlen (prod_path) - 1] != '/') {
           strcpy (buff, prod_path);
           strcat (buff, "/");
           (*prodDef)->product_path = stralloc (buff);
         }

         /* point to next */

         prodDef= &(*prodDef)->next;
       }
     }
   }

   om$dealloc(ptr = pdata);  /* Unverified copy of product_data file */

   return(1);
}


int EX_get_prod_def(prodDef, path, run_name, logo)
struct EX_prod_def   **prodDef;
char                 *path, *run_name, *logo;
{
   int                  offset;
   char                 *pattern;
   struct EX_prod_def   *def;

   def = EX_product_list;
   if (path)
   {
      /* NOTE: More than one /usr/ip32/product_data entry may
       * use the same config path.  This routine will return
       * the first product it finds using that config path.
       */
      pattern = path;
      offset = (int) &def->product_path - (int) def;
   }
   else if (run_name)
   {
      pattern = run_name;
      offset = (int) &def->run_name - (int) def;
   }
   else if (logo)
   {
      pattern = logo;
      offset = (int) &def->logo - (int) def;
   }
   else
   {
      *prodDef = NULL;
      return(0);
   }
   while (def)
   {
      if (!strcmp(pattern, *(char **) ((int) def + offset)))
      {
         *prodDef = def;
         return(1);
      }
      def = def->next;
   }
   return(0);
}


/* This routine returns information from a product's EX_prod_def
 * structure.  It was added for Dale Gross (NC product) Summer, 1992.
 */

EX_get_prod_info(product, code, pstring)
char  *product;
int   code;
char  **pstring;
{
   struct EX_prod_def   *prodDef;

   /* Caller will have given us either the product run name or the logo */

   if (1 & code)  /* Odd code = run name */
   {
      if (!EX_get_prod_def(&prodDef, (char *) NULL, product, (char *) NULL))
         return(0);
   }
   else           /* Even code = logo */
      if (!EX_get_prod_def(&prodDef, (char *) NULL, (char *) NULL, product))
         return(0);
   switch (code)
   {
      case EXPROD_GET_RUNNAME_BY_LOGO:
         strcpy(*pstring, prodDef->run_name);
         break;
      case EXPROD_GET_LOGO_BY_RUNNAME:
         strcpy(*pstring, prodDef->logo);
         break;
      default:
         strcpy(*pstring, prodDef->config_path);
         break;
   }
   return(1);
}


EX_get_prod_flag(product, code, flag)
char  *product;
int   code, flag;
{
   struct EX_prod_def   *prodDef;

   /* Caller will have given us either the product run name or the logo */

   if (1 & code)  /* Odd code = run name */
   {
      if (!EX_get_prod_def(&prodDef, (char *) NULL, product, (char *) NULL))
         return(0);
   }
   else           /* Even code = logo */
   {
      if (!EX_get_prod_def(&prodDef, (char *) NULL, (char *) NULL, product))
         return(0);
   }
   if (flag)      /* Test forced dload flag */
   {
      if (prodDef->flags & EXPROD_FORCE_DLOADED)
         return(1);
      else
         return(0);
   }
   else
   {
      if (prodDef->flags & EXPROD_DLOADED)
         return(1);
      else
         return(0);
   }
}


/* Routine to return all requested info from an EX_prod_def structure
   given either the product run name or the product logo.  If neither
   the run name or the logo is specified, the routine uses the index; if
   both are specified, run name is used.  If a non-null pointer to
   pointer is passed for any of the named fields of the structure, that
   field of the structure is stralloced to where the pointer points.  This
   routine is likely being called via the ex$get_product_data macro.
 */

EX_get_product_data(char *runnameIn, char *logoIn, int index,
   char **runnameOut, char **logoOut, char **module, char **dependency,
   char **configPath, char **productPath, int *flags)
{
   struct EX_prod_def   *prodDef;

   /* Caller will have given us either the product run name or the logo
    * or the index of the product_data entry.
    */

   if (runnameIn)
   {
      if (!EX_get_prod_def(&prodDef, (char *) NULL, runnameIn, (char *) NULL))
         return(0);
   }
   else if (logoIn)
   {
      if (!EX_get_prod_def(&prodDef, (char *) NULL, (char *) NULL, logoIn))
         return(0);
   }
   else if (index)
   {
      /* Products from the product_data file were stored in EX_product_list
       * in the same order they occurred in the file.  If user specified
       * index 0, then he wants the first entry in the linked list.  If
       * index goes beyond the end of the linked list, return 0.
       */

      if (!(prodDef = EX_product_list))
         return(0);
      while (--index)
      {
         if (!(prodDef = prodDef->next))
            return(0);
      }
   }
   else
      return(0);
   if (runnameOut && !(*runnameOut = stralloc(prodDef->run_name)))
      return(OM_E_NODYNMEM);
   if (logoOut && !(*logoOut = stralloc(prodDef->logo)))
      return(OM_E_NODYNMEM);
   if (module && !(*module = stralloc(prodDef->module)))
      return(OM_E_NODYNMEM);
   if (dependency && !(*dependency = stralloc(prodDef->srch_path)))
      return(OM_E_NODYNMEM);
   if (configPath && !(*configPath = stralloc(prodDef->config_path)))
      return(OM_E_NODYNMEM);
   if (productPath && !(*productPath = stralloc(prodDef->product_path)))
      return(OM_E_NODYNMEM);
   if (flags)
      *flags = prodDef->flags;
   return(1);
}

