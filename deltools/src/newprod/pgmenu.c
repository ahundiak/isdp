#include	<stdlib.h>
#include	<stdio.h>
#include	"defs.h"

/*
 * This routine is called to convert an ASCII product number into an
 * index into the optionlist array. The valid indices are in the range
 * 0..#(products found in the VAX product list). The mapped index
 * is returned upon success. A value of NULL indicates that no match for
 * the passed in ASCII product number was found.

 *
 */
struct prodnode *map_product(str, header, truncmatch)
char	*str;
struct prodnode *header;
int truncmatch;
{
	register struct prodnode *pptr;
	char	*c;

	for (c = str; *c != '\0' && *c != '\n'; c++)
		*c = toupper(*c);
	*c = '\0';

	for (pptr = header->flink; pptr != header; pptr = pptr->flink) {
		if (!strcmp(pptr->prodnumber, str) ||
				!strcmp(pptr->prodname, str))
			return(pptr);	/*a match!!*/

		if (truncmatch && !strncmp(pptr->prodnumber, str, truncmatch))
			return(pptr);
	}

	return((struct prodnode *) 0);		/*no match found*/
}

/*
 * Expand and process all of the products specified on the command line.
 */
int	expand_options(header, option_list, next_opt_ptr, args)
struct prodnode *header, **option_list;
int	*next_opt_ptr;
char	**args;
{
	register int	i, j;
	register struct prodnode *pptr;
	char	*c, fs[STRSIZ];
	extern char	*strchr();
	int	exit_status = 0;

	/*
	 * first search for 'u' option (expand it to include all out-of-date
	 * products.
	 */
	for (i = 0; args[i] != NULL; ++i) {
		if (strcmp(args[i], "u"))
			continue;
		/*
		 * Expand the "u" argument into a list of products. The
		 * The routine steps through the list of existing products
		 * whose start is pointed to by header and sets the according
		 * entry in the option_list array if that particular product
		 * is out of date.
		 */
		for (pptr = header->flink; pptr != header; pptr = pptr->flink) {
			if ((pptr->pstat & 0xf) == NEEDS_UPDATING) {
				/*
				 * skip it if it's already there
				 */
				for (j = 0; j < *next_opt_ptr; ++j)
					if (option_list[j] == pptr)
						break;
				if (j == *next_opt_ptr) {
					option_list[j] = pptr;
					++(*next_opt_ptr);
				}
			}
		}
	}

	/*
	 * now get the other arguments (skipping 'u' options)
	 */
	for (i = 0; args[i] != NULL; ++i) {
		if (!strcmp(args[i], "u"))
			continue;
		/*
		 * !prodname ==> remove the product from the list of products
		 * to load and remove it's structure so other's can't reference
		 * it.
		 */
		if (args[i][0] == '!') {
			/*
			 * remove the structure reference
			 */
			if (pptr = map_product(&args[i][1], header, FALSE)) {
				pptr->blink->flink = pptr->flink;
				pptr->flink->blink = pptr->blink;
				for (j = 0; j < *next_opt_ptr; ++j)
					if (option_list[j] == pptr)
						option_list[j] = NULL;
				free(pptr);
			}
			else {
			    PRINT "No match in product list for product: %s\n", &args[i][1]);
			    exit_status = 1;
			}
		} else if (args[i][0] == '%') {
			/*
			 * add the product only if it's out of date
			 */
			if (pptr = map_product(&args[i][1], header, FALSE)) {
				if ((pptr->pstat & 0xf) != NEEDS_UPDATING)
					continue;
				/*
				 * skip it if it's already there
				 */
				for (j = 0; j < *next_opt_ptr; ++j)
					if (option_list[j] == pptr)
						break;
				if (j == *next_opt_ptr) {
					option_list[j] = pptr;
					++(*next_opt_ptr);
				}
			}
			else {
			    PRINT "No match in product list for product: %s\n", &args[i][1]);
			    exit_status = 1;
			}
		} else if ((c = strchr(args[i], '=')) != NULL) {
		/*
		 * prodname=filesys ==> modify prodname's structure to indicate
		 * where the product is asked to go.
		 */
			*c = '\0';
			sprintf(fs, "%s/", ++c);
			if (pptr = map_product(args[i], header, FALSE)) {
				if (pptr->unixdir[0] != '/') {
					strcat(fs, pptr->unixdir);
					strcpy(pptr->unixdir, fs);
					if (pptr->loadeddir[0])
						strcpy(pptr->loadeddir, fs);
				}
				/*
				 * skip it if it's already there
				 */
				for (j = 0; j < *next_opt_ptr; ++j)
					if (option_list[j] == pptr)
						break;
				if (j == *next_opt_ptr) {
					option_list[j] = pptr;
					++(*next_opt_ptr);
				}
			}
			else {
			    PRINT "No match in product list for product: %s\n", args[i]);
			    exit_status = 1;
			}
		} else {
		/*
		 * prodname ==> just add it if it exists (and not there from
		 * the 'u' arg.)
		 */
			if (pptr = map_product(args[i], header, FALSE)) {
				/*
				 * skip it if it's already there
				 */
				for (j = 0; j < *next_opt_ptr; ++j)
					if (option_list[j] == pptr)
						break;
				if (j == *next_opt_ptr) {
					option_list[j] = pptr;
					++(*next_opt_ptr);
				}
			}
			else {
			    PRINT "No match in product list for product: %s\n", args[i]);
			    exit_status = 1;
			}
		}
	}
	return(exit_status);
}
