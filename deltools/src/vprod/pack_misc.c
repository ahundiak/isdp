#include "main.h"
#include "defs.h"

/*
 * this module contains routines that are used to manipulate the
 * package definition form
 *
 * make_pack     writes package info to the package file
 * show_packages displays the packages in the field gadget
 * get_package  displays the products in a packages
 * put_defaults_in_package  puts the defaults file into the package definition
 * del_pack	 deletes a packages
 * merge_in_defaults  puts the answers from the selected packages together
 */

extern Form packform;
extern Form rem_infoform;
extern	struct prodnode header;

int	total_packs=0;

int
make_pack(name, packagelist, numberlist, total, file)

char	*name;
char	**packagelist;
char	**numberlist;
int	total;
char	*file;

/****************************************************************************/
/* this routine writes the package list with the name to the packages file  */
/****************************************************************************/

{
	int	i, wrote_last_time;
	FILE	*of, *dff, *fopen();
	int	found = FALSE;
	char	line[MAXLINE], cmpline[MAXLINE];

	/* check for the /.vprod directory */
	if (system("test -d /.vprod"))
		mkdir("/.vprod", 0700);

	/* check for duplicate package name */
	if (NULL != (of = fopen("/.vprod/packages", "r")))
	{
		while ((fgets(line, MAXLINE, of)) && (!found))
		{
			line[strlen(line)-1] = '\0';	/* take out CR */
			
			if (!(strcmp(line+strlen("#begin_package")+1, name)))
				found = TRUE;
		} /* while */

		fclose(of);
	} /* if */

	if (found)	/* there was duplicate */
		return(FALSE);

	/* open file and put in package name */
	if (NULL == (of = fopen("/.vprod/packages", "a")))
		return(FALSE);
	chmod("/.vprod/packages", 0600);

	fputs("#begin_package ", of);  /* marks start of package */
	fputs(name, of);
	fputs("\n", of);
	fputs("#begin_products\n", of);

	/* put in product names */
	for (i = 0; i < total; i++)
	{
		fputs(packagelist[i], of);
		fputs(" ", of);
		fputs(numberlist[i], of);
		fputs("\n", of);
	} /* for */

	fputs("#end_products\n", of);


	/* if there is not a defaults file then we are done */
	if (file[0] == '\0') {
		fputs("#end_package\n", of);
		fclose(of);
		total_packs++;
		FIfld_set_value(rem_infoform, INFO_PACK, 0, 0,
			(double)(total_packs), FALSE);
		return (TRUE);
	}


	/* put the defaults file here - only relevant answers */
	/* defaults file format: NAME#question#answer -- question can contain newline */

	for (i = 0; i< total; i++) {
		if (NULL != (dff = fopen(file, "r"))) {
			wrote_last_time = FALSE;
			while (fgets(line, MAXLINE, dff)) {
				sprintf(cmpline, "%s#", packagelist[i]);
				if (!strncmp(cmpline, line, strlen(cmpline))) {
					fputs(line, of);
					wrote_last_time = TRUE;
				} else if ((wrote_last_time) && 
						(!strchr(line, '#'))) {
					fputs(line, of);
				} else if (wrote_last_time) {
					strcpy(cmpline, strchr(line, '#'));
					if (!strchr(cmpline+1, '#')) {
						fputs(line, of);
					} else {
						wrote_last_time = FALSE;
					}
				}
			}
			fclose(dff);
		}
	}
	
	fputs("#end_package\n", of);

	fclose(of);

	total_packs++;
	FIfld_set_value(rem_infoform, INFO_PACK, 0, 0,
		(double)(total_packs), FALSE);
	return (TRUE);
} /* make_pack */


show_packages(fp, gadget)

Form	fp;
int	gadget;

/****************************************************************************/
/* this routine get the names of the packages out of the file and lists them*/
/****************************************************************************/

{
	FILE	*of, *fopen();
	char	line[MAXLINE];
	int	row=0;

	if (NULL == (of = fopen("/.vprod/packages", "r")))
		return;

	FIg_reset(fp, gadget);

	while (fgets(line, MAXLINE, of))
	{
		line[strlen(line)-1] = '\0';	/* take out CR */

		if (!(strncmp(line, "#begin_package", strlen("#begin_package"))))
			FIfld_set_text(fp, gadget, row++, 0, 
				line+strlen("#begin_package")+1, FALSE);

	} /* while */
	total_packs = row;
	fclose(of);
} /* show_packages */


/*ARGSUSED*/
int get_package(fp, gadget, name, reset_first, sel_flag)

Form	fp;
int	gadget;
char	*name;
int	reset_first;
int	sel_flag;

/***************************************************************************/
/* this routine get the list of products in package name and selects them  */
/* if reset_first is true then previously selected products will be        */
/* unselected.  It returns true if the package was found in the list       */
/***************************************************************************/

{
	FILE	*of, *fopen();
	int	found = FALSE, ret_val = FALSE;
	char	line[MAXLINE], number[PRODNUM_LEN];
	int	i;

	if (NULL == (of = fopen("/.vprod/packages", "r")))
		return(FALSE);

	while (fgets(line, MAXLINE, of))
	{
		line[strlen(line)-1] = '\0';	/* take out CR */

		if (!(strncmp(line, "#begin_package", strlen("#begin_package"))))
		{
			if (!(strcmp(line+strlen("#begin_package")+1, name)))
			{
				ret_val = TRUE;
				found = TRUE;
			}
		} /* if */
		else if (found) 
		{
			if (!strncmp(line, "#end_products", strlen("#end_products")))
				break;
	
			if (!strncmp(line, "#begin_products", strlen("#begin_products")))
				continue;

			i = 0;
			while((line[i++] != ' ') && (i < MAXLINE)){}

			if ((strlen(line) - i) <= PRODNUM_LEN)
				strcpy(number, line+i);

			if (i < MAXLINE)
				line[i-1] = '\0';
			else
				line[MAXLINE-1] = '\0';

			set_selected_ascii(fp, line, number, sel_flag, FALSE);
		} /*else if*/
	} /* while */

	fclose(of);
	list_products_2(fp, gadget);
	return(ret_val);
} /* get_package */




int
put_defaults_in_package(name, filename)

char	*name;       /* package name */
char	*filename;   /* the defaults file */

/***************************************************************************/
/* this routine puts the defaults file into the package definition file    */
/***************************************************************************/

{
	FILE	*of1, *of2, *of3, *fopen();
	int	pkg_found = FALSE, place_found=FALSE;
	char	line[MAXLINE], def_line[MAXLINE];

	if (NULL == (of1 = fopen("/.vprod/packages", "r")))
		return(FALSE);

	if (NULL == (of2 = fopen("/.vprod/tmppack", "w")))
	{
		fclose(of1);
		return(FALSE);
	}

	if (NULL == (of3 = fopen(filename, "r")))
	{
		fclose(of1);
		fclose(of2);
		return(FALSE);
	}

	while (fgets(line, MAXLINE, of1))
	{
		line[strlen(line)-1] = '\0';	/* take out CR */

		if (!(strncmp(line, "#begin_package", strlen("#begin_package"))))
			if (!(strcmp(line+strlen("#begin_package")+1, name)))
				pkg_found = TRUE;
			else
				pkg_found = FALSE;
		else if (pkg_found)   /* if found, we're in the package */
		{
			if (!strncmp(line, "#end_products", strlen("#end_products")))
			{
				fputs(line, of2);
				fputs("\n", of2);
				while (fgets(def_line, MAXLINE, of3))
					fputs(def_line, of2);
				place_found = TRUE;
			}
			else if ((place_found) &&
			   (!strncmp(line, "#end_package", strlen("#end_package"))))
				place_found = FALSE;
		} /*else if*/

		if (!place_found)   /* if we are not in the answers part */
		{
			fputs(line, of2);
			fputs("\n", of2);
		}
	} /* while */

	fclose(of1);
	fclose(of2);
	fclose(of3);

	system ("mv /.vprod/tmppack /.vprod/packages");
	return(place_found);
} /* put_defaults_in_package */


/*ARGSUSED*/
del_pack(fp, name, flag)

Form	fp;
char	*name;
int	flag;

/*****************************************************************************/
/* this routine removes a package from the package file. if flag is true then*/
/* the product buttons will be reset.                                        */
/*****************************************************************************/

{
	FILE	*of1, *of2, *fopen();
	int	found = FALSE;
	char	line[MAXLINE];
	struct 	prodnode *pptr;

	if (NULL == (of1 = fopen("/.vprod/packages", "r")))
		return;

	if (NULL == (of2 = fopen("/.vprod/.vpak", "w")))
	{
		fclose(of1);
		return;
	} /* if */
	chmod("/.vprod/.vpak", 0600);

	while (fgets(line, MAXLINE, of1))
	{
		line[strlen(line)-1] = '\0';	/* take out CR */

		if (!(strncmp(line, "#begin_package", strlen("#begin_package"))))
		{
			if (!(strcmp(line+strlen("#begin_package")+1, name)))
				found = TRUE;
			else
			{
				fputs(line, of2);
				fputs("\n", of2);
				found = FALSE;
			} /* else */
		} /* if */
		else
		{
			if (!found)
			{
				fputs(line, of2);
				fputs("\n", of2);
			} /* if */
		} /* else */
	} /* while */

	fclose(of1);
	fclose(of2);

	system("mv /.vprod/.vpak /.vprod/packages");
	chmod("/.vprod/packages", 0600);
	total_packs--;
	FIfld_set_value(rem_infoform, INFO_PACK, 0, 0,
		(double)(total_packs), FALSE);

	if (flag) {	/* if they want the products unselected */
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
			if (pptr->pstat & SELECTED)
				set_selected_ascii(fp, pptr->prodname, pptr->prodnumber,
					FALSE, FALSE);

		list_products_2(fp, PK_PRODLIST);
	}
} /* del_pack*/

int
merge_in_defaults(fp)

Form  fp;

/****************************************************************************/
/* this routine goes through the list of selected packages and put thier    */
/* default answers in the file of                                           */
/****************************************************************************/

{
	int	num_rows, i, sel_flag, len, pos;
	char	pack_name[MAXHOST];
	FILE	*of, *fopen();
	struct stat	sbuf;

	if (NULL == (of = fopen("/.vprod/prod.def", "w")))
		return(0);

	FIfld_get_num_rows(fp, RD_PACKAGES, &num_rows);

	for (i = 0; i < num_rows; i++)
	{
		FIfld_get_select(fp, RD_PACKAGES, i, 0, &sel_flag);

		if (sel_flag)
		{
			FIfld_get_text_length(fp, RD_PACKAGES, i, 0, &len);
			FIfld_get_text(fp, RD_PACKAGES, i, 0, len, pack_name,
				&sel_flag, &pos);
			get_defaults(of, pack_name);			
		} /* if */
	} /* for */
	
	fclose(of);

	/*
	 * Now check what we've got.
	 * If the file doesn't exist, or is zero-length, then return
	 * zero.
	 */
	if (stat("/.vprod/prod.def", &sbuf) < 0) 
	    return(0);
	else {
	    if (sbuf.st_size == 0) {
		unlink("/.vprod/prod.def");
		return(0);
	    }
	    else
		return(1);
	}
} /* merge_in_defaults */



get_defaults(of, pack_name)

FILE *of;
char *pack_name;

{
	FILE *in, *fopen();
	int  pkg_found=FALSE, place_found=FALSE;
	char	line[MAXLINE];

	if (NULL == (in = fopen("/.vprod/packages", "r")))
		return(FALSE);

	while (fgets(line, MAXLINE, in))
	{
		if ((place_found)  && (line[0] != '#'))
			fputs(line, of);

		line[strlen(line)-1] = '\0';	/* take out CR */

		if (!(strncmp(line, "#begin_package", strlen("#begin_package"))))
			if (!(strcmp(line+strlen("#begin_package")+1, pack_name)))
				pkg_found = TRUE;
			else
				pkg_found = FALSE;
		else if (pkg_found)   /* if found, we're in the package */
		{
			if (!strncmp(line, "#end_products", strlen("#end_products")))
				place_found = TRUE;
			else if ((place_found) &&
			   (!strncmp(line, "#end_package", strlen("#end_package"))))
				break;
		} /*else if*/
	} /* while */
} /* get_defaults */
