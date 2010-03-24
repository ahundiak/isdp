#include "exsysdep.h"
#if defined(CLIX) || defined (SUNOS) || defined (IRIX)
#include <stdio.h>
#include <setjmp.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <dirent.h>
#include <dload.h>
#include "execmsg.h"
#include "msmacros.h"
#include "EXproduct.h"
#include <OMerrordef.h>
#include <OMmacros.h>
#include <exmacros.h>
#include <execmsg.h>
#include <expriv.h>

extern jmp_buf             EX_react_recover;
extern struct EX_prod_def *EX_product_list;

extern char	              EX_runname[];
extern void                   *dload_address_lookup();
extern char                   EX_version[120];
extern char                   EX_date[35];
extern int                    EX_process_unknowns;
extern int                    OM_Gi_number_of_appl_ids;
extern INGR_p_PRODUCT_DEF     OM_GA_appl_version[];
extern struct EX_prod_def     *EX_product_list;

extern char                   *EX_search_path;
extern char                   *EX_dependencies;

/* %%%% */

static INGR_p_PRODUCT_DEF     *Exnuc_appl_version;
extern INGR_S_PRODUCT_DEF     EXNUC_appl_version_id;


#argsused
static void EX_reactive_handler (char *path)
{
  ex$message ( msgnumb = EX_F_LoadFail, type = "%s", var = `path` );
  longjmp (EX_react_recover, 1);
}


int EX_init_dload (void)
{
  char                path[MAXPATHLEN];
  struct EX_prod_def *def;

  dload_ctrl (INITIAL);
  for (def = EX_product_list; def; def = def->next) {
    strcpy (path, def->config_path);
    strcat (path, "config/dload/prod");
    dload_ctrl (ENTERTAG, def->run_name, path, EX_reactive_handler);
  }
  return 1;
}


static char **get_dload_files (directory, argv, argcp)
char  *directory,
      **argv;
int   *argcp;
{
   DIR            *dirp;
   struct dirent  *dp;
   int            len;
   int            nbytes;
   int            argc = *argcp;
   char           buff[MAXPATHLEN];

   if (dirp = opendir (directory))
   {
      strcpy(buff, directory);
      strcat(buff, "/");
      nbytes = strlen(buff);
      while (dp = readdir(dirp))
      {
         len = strlen (dp->d_name);

#if defined(CLIX) || defined(IRIX4)
         if (len >= 2 && 'o' == *(dp->d_name + len-1) && '.' ==
            *(dp->d_name + len-2))
#elif defined(SUNOS) || defined (IRIX5)
         if (len >= 3 && 'o' == *(dp->d_name + len-1) && 's' ==
            *(dp->d_name + len-2) && '.' == *(dp->d_name + len-3))
#else
#error dload files not specified for OS
#endif

         {
            strcpy(&buff[nbytes], dp->d_name);
            if (!(++argc % 20))
               argv = (char **) om$realloc(ptr=((char *) argv),
                  size=(argc + 20) * sizeof (char *));
            strcpy(argv[argc - 1] = (char *)
               om$malloc(size=strlen(buff) + 1), buff);
         }
      }
      closedir(dirp);
   }

   argv[*argcp = argc] = 0;
   return argv;
}


int EX_product_dload()
{
   int                  numProd,
#ifdef BIG_ENDIAN
			saveNumProd,
#endif
                        ii, count, sts,
                        argc,
                        patchArgc,
                        sizebuf,
                        jj = 0;
   char                 **prod_argv,
                        *colon,
                        dloadFlag,
                        *ptr,
#ifdef BIG_ENDIAN
			*sptr,
#endif
                        **patchArgv,
                        **argv,
   			**prod_path_list = 0;
   struct EX_prod_def   **prodArray;
   char                 product[512],
                        dep_list[512];

   sizebuf = 512;
   argc = 0;
   patchArgc = 0;
   dloadFlag = 0;
   if (!(argv = (char **) om$malloc (size=20 * sizeof (char *))))
      return(OM_E_NODYNMEM);
   if (!(patchArgv = (char **) om$malloc (size=20 * sizeof (char *))))
      return(OM_E_NODYNMEM);

   /* %%%% This needs to be taken out if we ever change to deliver
    * our version stamp in a separate .o like the other apps do.
    */

   if (!(Exnuc_appl_version = (INGR_p_PRODUCT_DEF *)
      om$calloc(size=sizeof(INGR_p_PRODUCT_DEF), num=2)))
      return(OM_E_NODYNMEM);

   /* Call routine to return a string containing all the product
    * paths (e.g., /usr/ip32/ems:/usr/ip32/model:, etc) of products
    * required by this process, separated by colons and the number
    * of products represented in the string.  The first product in
    * the path is the product specified by the user; the rest are
    * that product's dependencies, so you could say the list of
    * products is in reverse order of activation.
    */

   if (!EX_get_srch_path(&ptr, &numProd)) /* Get number of prods */
      return(0);
#ifdef BIG_ENDIAN
   sptr = ptr;
   saveNumProd = numProd;
#endif
   while (numProd--)
   {
      if (ex$get_path (index = numProd, path = product, len = sizeof (product)))
      {
         int patchIndex;

         strcat (product, "config/dload/init");
         patchIndex = strlen(product) - 4;  /* Back up to before 'init' */
         argv = get_dload_files (product, argv, &argc);
         strcpy((char *) &product[patchIndex], "patch");
         patchArgv = get_dload_files (product, patchArgv, &patchArgc);
      }
   }

   if (!EX_get_srch_path1(EX_runname, 0, &product[0], &sizebuf))/* Get prod names */
      return(0);
   if (!(EX_dependencies = (char *) om$malloc(size = strlen(product) + 1)))
      return OM_E_NODYNMEM;
   strcpy(EX_dependencies, product);
   if (argc)
   {
      /* Reverse the order of the product dependency list from highest-
       * to-lowest to lowest-to-highest.
       */
      dep_list[0] = '\0';
      product[strlen(&product[0])-1] = '\0';
      numProd = 1;
      while (ptr = strrchr(product, ':'))
      {
         numProd++;
         strcat(&dep_list[0], ++ptr);
         strcat(&dep_list[0], ":");
         *(ptr - 1) = '\0';
      }
      strcat(&dep_list[0], &product[0]);
      strcat(&dep_list[0], ":"); /* dep_list now lists prods lowest to highest */

      if (!(prodArray = (struct EX_prod_def **) om$calloc(size = 4, num = numProd)))
      {
         fprintf(stderr, "IGE_startup: could not allocate %d bytes.\n",
            numProd * 4);
         return(OM_E_NODYNMEM);
      }
      if (!(prod_argv = (char **)
         om$malloc(size=(numProd + 1) * sizeof(char *))))
         return(OM_E_NODYNMEM);

#ifdef BIG_ENDIAN
      if (!(prod_path_list = (char **)
         om$malloc(size=(numProd + 1) * sizeof(char *))))
         return(OM_E_NODYNMEM);
#endif

      for (ptr=dep_list, ii=jj=0; ii<numProd; ii++)
      {
         colon = (char *) strchr(ptr, ':');
         strncpy(product, ptr, colon - ptr);
         product[colon - ptr] = '\0';
         ptr = colon + 1;
      
         if (!EX_get_prod_def(&prodArray[ii], (char *) NULL, product,
            (char *) NULL))   /* Pass the prod name, get back the product_def */
         {
            /* Dependency is not in product_data file (for
             * cases like dignuc & pdu, which aren't always
             * on systems running Ems).
             */
            continue;
         }
         if (access(prodArray[ii]->config_path, 0))
         {
            prodArray[ii] = NULL;
            continue;
         }
         if (prodArray[ii]->flags & EXPROD_DLOADED)
         {
            if (prodArray[ii]->flags & EXPROD_FORCE_DLOADED)
            {
               /* Product has already been dloaded & we can continue EXCEPT
                * since he was force_dloaded, we have to make sure his
                * appl version stamp is in the global appl ver array.
                * It may still be in memory but have been deleted from the
                * array when the file that caused it to be force dloaded
                * was closed.  Trust me.
                */

               int   pp, found, index, prevEmptyIndex = -1;
               INGR_p_PRODUCT_DEF   *appArray;

               if (appArray = prodArray[ii]->ingr)
               {
                  pp = 0;
                  for (; appArray[pp]; pp++)
                  {
                     for (found=index=count=0; (index<MAXNUMAPPVER) &&
                        (count<OM_Gi_number_of_appl_ids); index++)
                     {
                        if (!OM_GA_appl_version[index])
                        {
                           prevEmptyIndex = index;
                           continue;
                        }
                        count++;
                        if (OM_GA_appl_version[index] == appArray[pp])
                        {
                           found = 1;
                           break;
                        }
                     }
                     if (!found)
                     {
                        if (prevEmptyIndex == -1)
                           index = prevEmptyIndex;
                        else
                           index = count;
                        OM_GA_appl_version[index] = appArray[pp];
                        OM_Gi_number_of_appl_ids++;
                     }
                  }
               }     /* if (appArray = prodArray[ii]->ingr) */
            }     /* if (flags & FORCE_DLOADED) */
            continue;   /* This product has already been dloaded */
         }

#ifdef BIG_ENDIAN
	 prod_path_list[jj] = prodArray[ii]->config_path;
#endif

         prod_argv[jj++] = prodArray[ii]->run_name;
         prodArray[ii]->flags |= EXPROD_PREDLOADED;
      }     /* End of for */

#ifdef BIG_ENDIAN
      prod_path_list[jj] = NULL;
#endif

      prod_argv[jj] = NULL;

      if (!(1&(sts = som_dload_class(argv, prod_argv, prod_path_list))))
      {
         for (ii=0; ii<numProd; ii++)
            if (prodArray[ii])
               prodArray[ii]->flags &= ~EXPROD_PREDLOADED;
         return(sts);
      }

      if (patchArgc)
         if (!(1&(sts = som_dload_class(patchArgv, NULL, NULL))))
            return(sts);

      if (numProd)
         EX_dependencies[0] = '\0';
      for (ii = numProd-1; ii >= 0; ii--)
      {
         /* Print the version stamp of the highest-level application
          * that we dloaded.
          */

         if (prodArray[ii])
         {
            INGR_p_PRODUCT_DEF   p;

            strcat(EX_dependencies, prodArray[ii]->run_name);
            strcat(EX_dependencies, ":");
            if (prodArray[ii]->flags & EXPROD_PREDLOADED)
            {
              prodArray[ii]->flags |= EXPROD_DLOADED;
              prodArray[ii]->flags &= ~EXPROD_PREDLOADED;
            }
/* %%%% */
            if (!strcmp("Exnuc", prodArray[ii]->run_name))
            {
               prodArray[ii]->ingr = Exnuc_appl_version;
               prodArray[ii]->ingr[0] = &EXNUC_appl_version_id;
            }
            else
            {
#if defined (IRIX) || defined (SUNOS5)
               sprintf(product, "%s_appl_version", prodArray[ii]->run_name);
#elif defined (CLIX) || defined (SUNOS4)
               sprintf(product, "_%s_appl_version", prodArray[ii]->run_name);
#else
#error Undefined OS
#endif
               prodArray[ii]->ingr = (INGR_p_PRODUCT_DEF *)
                  dload_address_lookup(product);
            }
            if (ptr = (char *) strchr(prodArray[ii]->logo, '/'))
               ptr++;
            else
               ptr = prodArray[ii]->logo;         
#if defined (IRIX) || defined (SUNOS5)
            sprintf(product, "%s_appl_version_id", ptr);
#elif defined (CLIX) || defined (SUNOS4)
            sprintf(product, "_%s_appl_version_id", ptr);
#else
#error Undefined OS
#endif
            if (p = (INGR_p_PRODUCT_DEF) dload_address_lookup(product))
            {
               if (!dloadFlag && (prodArray[ii]->flags & EXPROD_DLOADED))
               {
                 if (p->appl_specifics &&
                     (p->appl_specifics != (char *) 0xabadaba) &&
                     p->appl_specifics[0])
                  {
                     strcpy(EX_version, prodArray[ii]->logo);
                     for (jj=0; EX_version[jj]; jj++)
                        if (EX_version[jj] == '_')
                           EX_version[jj] = ' ';
                     EX_version[jj++] = ' ';
                     EX_version[jj] = '\0';
                     strcat(EX_version, p->appl_specifics);
                     fprintf(stderr, "\n %s\n\n", EX_version);
                  }
                  else
                  {
                     fprintf(stderr, "\n %s\n\n", p->curr_version);
                     strcpy(EX_version, p->curr_version);
                  }
                  dloadFlag = 1;
               }
            }
         }
      }

      while (argc--)
         om$dealloc(ptr=argv[argc]);
      while (patchArgc--)
         om$dealloc(ptr=patchArgv[patchArgc]);
      om$dealloc(ptr=prod_argv);
      om$dealloc(ptr=prodArray);
      if (prod_path_list)
	om$dealloc(ptr=prod_path_list);
   }

#ifdef BIG_ENDIAN
   else while (saveNumProd--)
   {
	/*
	 *	We need to load the dictionary info even if the product
	 *	has no dloaded components.
	 */

	char	prod[MAXPATHLEN];

	if (ex$get_path(index=saveNumProd, path=prod, len=sizeof(prod)))
	{
		char	path[MAXPATHLEN];

		strcpy(path, prod);
		strcat(path, "config/class_defns");
		if (!(1&(sts = som_load_dictionary(path))))
			return sts;
		strcpy(path, prod);
		strcat(path, "config/dload/port");
		if (!(1&(sts = som_dload_conversion_functions(path))))
			return sts;
	}
   }
#endif

   if (!dloadFlag)
   {
      EX_get_version();
      fprintf(stderr, "\n %s %s\n\n", EX_version, EX_date);
   }
   if (argv)
      om$dealloc(ptr=argv);
   return(1);
}


/* This routine is called when a new file is retrieved and the
 * EX_process_unknowns flag is set (meaning "process, or dload and
 * set up, any non-dloaded products that have an appl version stamp
 * in the appl ver stamp array in order to avoid having to deal with
 * unknown objects".  If there's an appl ver stamp in the file,
 * there are probably objects of that appl in the file also.
 * Dale Gross (NC) wanted these appl's automatically dloaded at
 * retrieve time so his customers would never encounter unknown
 * objects.  NC's start-up script sets the EX_process_unknowns flag.
 *
 * A side effect of this routine is that the global search path
 * and product dependency list are deliberately convoluted so
 * that they may not show the same heirarchy that the product_data
 * file shows.  The product currently in EX_runname will stay the
 * first product in the dependency list even if we dload products
 * that depend on it.  This is because NC wanted the appl's objects
 * brought into memory, but did not want to change the look and
 * feel of the currently running appl, so the search path order
 * must stay as it was.
 *
 * This routine returns a count of appls that it dloaded in 'count'.
 */

int EX_force_product_dload(int *count)
{
   int                  ii, nn;
   char                 colon[2];

   *count = 0;    /* Counter of how many products we dload here */
   strcpy(colon, ":");

   /* Loop through the array of application version stamps (a sparse
    * array) looking for version stamps that were read into memory
    * from a file rather than loaded into memory with a product.
    * Get the product info for that version stamp, and its product's
    * dependency list.  For each product in its dep list, jam the
    * product into the global dependency list and search path.  If
    * the product hasn't been dloaded, dload it.
    */

   for (ii=nn=0; (ii<MAXNUMAPPVER) && (nn<OM_Gi_number_of_appl_ids); ii++)
   {
      struct EX_prod_def   *prodDef,
                           **forceArray,
                           **prodArray;
      int                  sts, jj, kk,
                           numProd;
      char                 *p, *p2,
                           *sptr,
                           *dptr;
      char                 buf[1024],
                           product[1024],
                           searchBuf[1024],
                           depBuf[1024],
                           found;

      if (!OM_GA_appl_version[ii])
         continue;
      nn++;          /* Counter of valid entries */
      if (OM_GA_appl_version[ii]->appl_specifics != (char *) 0xabadaba)
         continue;

      strcpy(product, OM_GA_appl_version[ii]->curr_version);   /* Logo */
      * ((char *) (strchr(product, ' '))) = '\0';
      if (!EX_get_prod_def(&prodDef, (char *) NULL, (char *) NULL,
         product))
         continue;      /* MAY NEED TO DO SOMETHING MORE HERE --
                           FOUND AN APPL VER STAMP IN FILE THAT
                           ISN'T IN PRODUCT_DATA FILE */

      /* Found an appl version stamp for a product that may not have
       * been dloaded yet.  Get its dependencies and add them all to
       * search path and dependency list and dload them.
       */

      found = 0;
      strcpy(&buf[0], EX_dependencies);
      if (!(prodArray = (struct EX_prod_def **) om$calloc(
         num=4 * OM_Gi_number_of_appl_ids, size=sizeof(struct EX_prod_def *))))
         return(OM_E_NODYNMEM);

      p = &buf[0];
      sts = 0;
      kk = 0;
      while (p2 = strtok(p, colon))
      {
         EX_get_prod_def(&prodArray[sts++], (char *) NULL, p2, (char *) NULL);
         if (!strcmp(prodDef->run_name, p2))
         {
            found = 1;
            break;
         }
         p = NULL;
      }
      if (found)  /* Product already in dependency list - all done */
      {
         om$dealloc(ptr=prodArray);
         continue;
      }

      /* 'Product' has to be forced into search path and dependency list
       * and dloaded if not already.  'prodDef' describes 'product'.
       * 'prodArray' contains an entry for every product in the global
       * dependency list and in the same order.
       */

      if (!(forceArray = (struct EX_prod_def **) om$calloc(
         num=4*OM_Gi_number_of_appl_ids, size=sizeof(struct EX_prod_def *))))
         return(OM_E_NODYNMEM);
      forceArray[0] = prodDef;      
      searchBuf[0] = '\0';
      depBuf[0] = '\0';
      strcpy(buf, EX_search_path);
      p = buf;

      /* Copy the EX_runname info to the dependency list and search path,
       * as this guy always will be first.
       */

      strcat(depBuf, prodArray[0]->run_name);
      strcat(depBuf, colon);
      sptr = strtok(p, colon);
      strcat(searchBuf, sptr);
      strcat(searchBuf, colon);
      p = NULL;
      if (strcmp(sptr, prodArray[0]->config_path))
      {
         /* The first path doesn't match the running product's
          * search path, so we assume the user specified -S <path>
          * on the command line.  Copy the next search path entry,
          * which should be the running product's entry.
          */

         sptr = strtok(p, colon);
         strcat(searchBuf, sptr);
         strcat(searchBuf, colon);
         p = NULL;

         if (strcmp(sptr, prodArray[0]->config_path))
         {
            /* Still don't match -- error condition */

            fprintf(stderr, "EX_force_product_dload: Error in adjusting search path for product %s.\n", product);
            om$dealloc(ptr=prodArray);
            om$dealloc(ptr=forceArray);
            continue;
         }
      }

      /* Determine where to insert this product and his dependencies.
       * Look through all products for first occurrence of GRSwPr file
       * and insert forced-in products right after that point, followed
       * by remainder of already-loaded products.
       */

      jj = 0;
      found = 0;
      for (; prodArray[jj]; jj++)
      {
         sprintf(product, "%s%s",
            prodArray[jj]->config_path, "config/english/palettes/GRSwPr");
         if (!access(product, 0))
         {
            found = 1;
            break;
         }
      }
      kk = 1;
      if (found)
      {
         /* Copy EX_search_path and EX_dependencies down to the product
          * insertion point.
          */

         for (; kk<=jj; kk++)
         {
            strcat(depBuf, prodArray[kk]->run_name);
            strcat(depBuf, colon);
            sptr = strtok(p, colon);
            strcat(searchBuf, sptr);
            strcat(searchBuf, colon);
            p = NULL;
         }
      }
      sptr += strlen(sptr) + 1;

      /* 'sptr' points to the insertion point of EX_search_path;
       * 'kk' points to the next product to add to EX_dependencies.
       * For each product in our guy's dependency list, if he's
       * not already in the global lists, then add him.  If he's
       * also not dloaded, store his EX_prod_def structure in the
       * forceArray.
       */

      EX_get_srch_path1(forceArray[0]->run_name, 0, &product[0], &sts);
      p2 = product;
      dptr = strtok(p2, colon);
      p2 = NULL;
      strcat(depBuf, dptr);
      strcat(depBuf, colon);
      strcat(searchBuf, forceArray[0]->config_path);
      strcat(searchBuf, colon);
      numProd = 1;
      while (dptr = strtok(p2, colon))
      {
         p2 = NULL;
         jj = 0;
         found = 0;
         while (prodArray[jj])
         {
            if (!strcmp(prodArray[jj]->run_name, dptr))
            {
               found = 1;
               break;
            }
            jj++;
         }
         if (!found)
         {
            if (EX_get_prod_def(&prodDef, (char *) NULL,
               dptr, (char *) NULL) && !access(prodDef->config_path, 0))
            {
               forceArray[numProd] = prodDef;
               strcat(depBuf, dptr);
               strcat(depBuf, colon);
               strcat(searchBuf, forceArray[numProd]->config_path);
               strcat(searchBuf, colon);
               if (forceArray[numProd]->flags & EXPROD_DLOADED)
                  forceArray[numProd] = NULL;
               else
                  numProd++;
            }
         }
      }
      strcat(searchBuf, sptr);
      while(prodArray[kk])
      {
         strcat(depBuf, prodArray[kk++]->run_name);
         strcat(depBuf, colon);
      }
      om$dealloc(ptr=EX_dependencies);
      om$dealloc(ptr=EX_search_path);
      if (!(EX_dependencies = (char *) om$malloc(size=strlen(depBuf)+1)))
         return(OM_E_NODYNMEM);
      if (!(EX_search_path = (char *) om$malloc(size=strlen(searchBuf)+1)))
         return(OM_E_NODYNMEM);
      strcpy(EX_dependencies, depBuf);
      strcpy(EX_search_path, searchBuf);

#ifdef DEBUG
printf("EX_force_product_dload: EX_search_path: %s\nEX_dependencies: %s\n",
EX_search_path, EX_dependencies);
#endif

      if (numProd)   /* Products to dload */
      {
         int	argc=0;
         int    patchArgc=0;
         char   **argv,
                **prod_argv,
                **patchArgv,
                **prod_path_list=NULL;

         if (!(argv = (char **) om$calloc(num=4*OM_Gi_number_of_appl_ids,
            size=sizeof (char *))))
            return(OM_E_NODYNMEM);
         if (!(patchArgv = (char **) om$calloc(num=4*OM_Gi_number_of_appl_ids,
            size=20 * sizeof (char *))))
            return(OM_E_NODYNMEM);

         for (jj=numProd-1; jj>=0; jj--) /* Get files to dload in reverse order */
         {
            sprintf(product, "%s%s", forceArray[jj]->config_path,
               "config/dload/init");
            kk = strlen(product) - 4;  /* Back up to before 'init' */
            argv = get_dload_files (product, argv, &argc);

            strcpy(&product[kk], "patch");
            patchArgv = get_dload_files (product, patchArgv, &patchArgc);
         }

         if (argc)
         {
#ifdef BIG_ENDIAN
            if (!(prod_path_list = (char **)
               om$malloc(size=(numProd + 1) * sizeof(char *))))
               return(OM_E_NODYNMEM);
#endif

            if (!(prod_argv = (char **)
               om$malloc(size=(numProd + 1) * sizeof(char *))))
               return(OM_E_NODYNMEM);
   
            for (kk=0, jj=numProd-1; jj>=0; jj--)
            {
               if (forceArray[jj]->flags & EXPROD_DLOADED)
                  continue;
         
#ifdef BIG_ENDIAN
               prod_path_list[kk] = forceArray[jj]->config_path;
#endif

               prod_argv[kk++] = forceArray[jj]->run_name;
               forceArray[jj]->flags |= EXPROD_PREDLOADED;
               (*count)++;
            }

#ifdef BIG_ENDIAN
            prod_path_list[kk] = NULL;
#endif

            prod_argv[kk] = NULL;
   
            if (!(1&(sts = som_dload_class(argv, prod_argv, prod_path_list))))
            {
               for (jj=0; jj<numProd; jj++)
                  forceArray[jj]->flags &= ~EXPROD_PREDLOADED;
               return(sts);
            }
            if (patchArgc)
               if (!(1&(sts = som_dload_class(patchArgv, NULL, NULL))))
                  return(sts);
   
            for (jj = numProd-1; jj >= 0; jj--)
            {
               INGR_p_PRODUCT_DEF   *appArray;
               int                  aa;

               if (forceArray[jj]->flags & EXPROD_PREDLOADED)
               {
                  forceArray[jj]->flags &= ~EXPROD_PREDLOADED;
                  forceArray[jj]->flags |= EXPROD_DLOADED | EXPROD_FORCE_DLOADED;
               }
               else
                  continue;
               sprintf(product, "_%s_appl_version", forceArray[jj]->run_name);

               if (appArray = (forceArray[jj]->ingr = (INGR_p_PRODUCT_DEF *)
                  dload_address_lookup(product)))
               {
                  for (aa=0; appArray[aa]; aa++)
                     appArray[aa]->appl_specifics = (char *) 0xabadaba;
               }

#ifdef BIG_ENDIAN
               strcpy(product, forceArray[jj]->config_path);
               strcat(product, "config/class_defns");
               if (!(1&(sts = som_load_dictionary(product))))
                  return sts;
               strcpy(product, forceArray[jj]->config_path);
               strcat(product, "config/dload/port");
               if (!(1&(sts = som_dload_conversion_functions(product))))
                  return sts;
#endif

            }

            while (argc--)
               om$dealloc(ptr=argv[argc]);
            while (patchArgc--)
               om$dealloc(ptr=patchArgv[patchArgc]);
            om$dealloc(ptr=prod_argv);
            if (prod_path_list)
               om$dealloc(ptr=prod_path_list);
         }
         if (argv)
            om$dealloc(ptr=argv);
      }
      if (forceArray)
         om$dealloc(ptr=forceArray);
   }

#ifdef DEBUG
{
   int i, j, k;
   INGR_p_PRODUCT_DEF   *appArray;
   struct EX_prod_def   *pDef;

   printf("\nEX_force_product_dload: Number of version stamps: %d\n", OM_Gi_number_of_appl_ids);
   for(i=j=0; (i<MAXNUMAPPVER) && (j<OM_Gi_number_of_appl_ids); i++)
   {
      if (!OM_GA_appl_version[i])
      {
         printf("[%d]:NULL\n", i);
         continue;
      }
      j++;
      printf("[%d]:%s  0x%x\n",
         i,
         OM_GA_appl_version[i]->curr_version,
         OM_GA_appl_version[i]->appl_specifics);
   }
   pDef = EX_product_list;
   while(pDef)
   {
      printf("\n%s   Flags: 0x%x\n", pDef->run_name, pDef->flags);
      if (appArray = pDef->ingr)
      {
         for (k=0; appArray[k]; k++)
            printf("%s   Stamp type: 0x%x\n\n",
               appArray[k]->curr_version, appArray[k]->appl_specifics);
      }
      else
         printf("No version stamp\n\n");
      pDef = pDef->next;
   }
}
#endif
   return(1);
}

#endif
