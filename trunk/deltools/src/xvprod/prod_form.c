#include "main.h"
#include "defs.h"

/*************************************************************************/
/* functions contained in this file:                                     */
/*                                                                       */
/* show_prod_note - notification routine                                 */
/* show_fs        - show the products loaded to a filesystem             */
/* show_selected  - show the products selected for a filesystem          */
/* chk_prod_status-                                                      */
/* list_products  - lists the available products                         */
/* list_products_2 - only lists the products' names - no other info      */
/*************************************************************************/


extern	unsigned long	my_arch;
extern	short	show_all_plats;
extern 	struct prodnode header;
extern	struct prodnode loadedheader;
extern  Form show_prod_form, show_sel_form, fsform;
extern 	int curr_fs;
extern  int num_fs;
extern	char *shell;
extern	Form	delform;
extern struct fsdata	fs_table[];

char	cmdname[MAXLINE];


/*ARGSUSED*/
show_prod_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	int	row, pos, len, flag;
	char	prod_number[PRODNUM_LEN];
	char	prod_name[PRODNAME_LEN];
	int	i, sts;
	FILE	*of, *popen();
	char	line[MAXLINE];
	struct prodnode *pptr, *goner;
	int	found = FALSE;

	switch(g_label)
	{
	 case FI_CANCEL:
		FIf_delete(fp);
		show_prod_form = NULL;
		show_sel_form = NULL;
		FIg_set_value(fsform, REVIEW_AVAIL, (double)1);
		break;

	 case PROD_LIST:
		FIfld_set_text(fp, SIZE_FIELD, 0, 0, "", FALSE);
		break;

	 case REMOVE_PROD:
		FIfld_get_active_row(fp, PROD_LIST, &row, &pos);
		FIfld_get_select(fp, PROD_LIST, row, 0, &flag);

		if (!flag)
			return;
		
		FIfld_get_text_length(fp, PROD_LIST, row, 1, &len);
		FIfld_get_text(fp, PROD_LIST, row, 1, len, prod_number, &flag, 
				&len);

		FIfld_get_text_length(fp, PROD_LIST, row, 0, &len);
		FIfld_get_text(fp, PROD_LIST, row, 0, len, prod_name, &flag, 
				&len);

		for (pptr = loadedheader.flink; pptr != &loadedheader; pptr = pptr->flink)
			if (!strcmp(pptr->prodnumber, prod_number) &&
			    !strncmp(pptr->loadeddir, fs_table[curr_fs].name,
				     strlen(fs_table[curr_fs].name)))
			{
				found = TRUE;
				break;
			} /* if */

		if (!found)
			return;

		/* get the size of the product */			
		sprintf(cmdname, "du -s %s", pptr->loadeddir);
		if ((of = popen(cmdname, "r")) == NULL)
			return;

		fgets(line, MAXLINE, of);
		pclose(of);

		i = 0;
		while (line[i++] != '\t') {}
		line[i-1] = '\0';
#ifdef SunOS_4
		/* Have to multiply by 2 since Sun reports usage in 1k blocks */
		FIfld_set_value(fp, SIZE_FIELD, 0, 0, (double)(atoi(line) * 2), FALSE);
#else
		FIfld_set_value(fp, SIZE_FIELD, 0, 0, (double)atoi(line), FALSE);
#endif
		
#ifdef XFORMS
		sprintf(cmdname, 
		"/usr/ip32/deltools/.remove/doit.sh %s %s %s",
		prod_name, pptr->loadeddir, line);
#else
		sprintf(cmdname, 
		"%s /usr/ip32/deltools/.remove/xdoit.sh %s %s %s",
		shell, prod_name, pptr->loadeddir, line);
#endif
		
		chdir("/"); 

		switch (my_arch) {
		case CLIPPER_ARCH:
			putenv("PLATFORM=CLIX");
			break;
		case SUN_ARCH:
			putenv("PLATFORM=SunOS_4");
			break;
		}

		sts = run_shell(cmdname, TRUE, TRUE);  /* run the remove script */
		if (sts == 0)
		{
		    /*
		     * Successful removal.  We need to update the REAL prodnode
                     * and delete the loaded node.
		     */
		    found = FALSE;
		    for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
                        if ((pptr->arch & my_arch) && 
			    !strcmp(pptr->prodnumber, prod_number)) {
                                found = TRUE;
                                break;
                        } /* if */
 
                    if (found) {
			/*
			 * Clear the status and location fields.
			 */
			pptr->loadeddir[0] = '\0';
			pptr->destfs[0] = '\0';
			pptr->pstat &= 0xff00;
			pptr->pstat |= NEW;
		    }

		    for (pptr = loadedheader.flink; pptr != &loadedheader; pptr = pptr->flink)
			if (!strcmp(pptr->flink->prodnumber, prod_number) &&
			    !strncmp(pptr->flink->loadeddir, fs_table[curr_fs].name,
				     strlen(fs_table[curr_fs].name)))
			{
			    goner = pptr->flink;
			    pptr->flink = goner->flink;
			    goner->flink->blink = pptr;
			    free(goner);
			}

		    list_products(delform);

		}
		FIg_get_text(fp, FS_TITLE, cmdname);  /* get the fs name */
		show_fs(fp, cmdname+21);	      /* remake the list */

		show_filesystems(fsform);
		scroll_filesystems(fsform, (100*curr_fs)/num_fs);
		FIg_reset(fp, SIZE_FIELD);	
		break;

	 case SIZE_PROD:
		FIfld_get_active_row(fp, PROD_LIST, &row, &pos);
		FIfld_get_select(fp, PROD_LIST, row, 0, &flag);

		if (!flag)
			return;
		
		FIfld_get_text_length(fp, PROD_LIST, row, 1, &len);
		FIfld_get_text(fp, PROD_LIST, row, 1, len, prod_number, &flag, 
				&len);

		for (pptr = loadedheader.flink; pptr != &loadedheader; pptr = pptr->flink)
			if (!(strcmp(pptr->prodnumber, prod_number)))
			{
				found = TRUE;
				break;
			} /* if */

		if (!found)
			return;
			
		sprintf(cmdname, "du -s %s", pptr->loadeddir);
		if ((of = popen(cmdname, "r")) == NULL)
			return;

		fgets(line, MAXLINE, of);
		pclose(of);

		i = 0;
		while (line[i++] != '\t') {}
		line[i-1] = '\0';

#ifdef SunOS_4
		/* Have to multiply by 2 since Sun reports usage in 1k blocks */
		FIfld_set_value(fp, SIZE_FIELD, 0, 0, (double)(atoi(line) * 2), FALSE);
#else
		FIfld_set_text(fp, SIZE_FIELD, 0, 0, line, FALSE);
#endif
		break;
	} /* switch */
} /* show_prod_note */


show_fs(fp, fs)

Form 	fp;
char	*fs;

/*****************************************************************************/
/* this routine shows the products that exist on the current file system     */
/*****************************************************************************/

{
	FILE	*fptr, *fopen();
	char	line[MAXLINE];
	int	i, j, row;
	char	prod_num[PRODNUM_LEN];
	char	prod_name[PRODNAME_LEN];
	char	descr[TITLE_LEN];
	char	vers[VERSION_LEN];
	char	location[DIR_LEN];
	char	tmp[DIR_LEN];
	char	*status;

	if (NULL == (fptr = fopen("/usr/ip32/ingrconfig", "r")))
	{
		printf("Error: cannot open file /usr/ip32/ingrconfig\n");
		return;
	} /* if */


	FIg_reset(fp, PROD_LIST);

	strcpy(tmp, fs);	
	strcat(tmp, "/");

	row = 0;
	while (fgets(line, MAXLINE, fptr))
	{
		/* format of file */
		/* number#name#descr#version#date#location# */

		i = 0;

		/* get product number */
		j = 0;
		while (line[i] != '#')
		{
			prod_num[j] = line[i];
			j++;
			i++;
		} /* while */
		prod_num[j] = '\0';
		i++;

		/* get product name */
		j = 0;
		while (line[i] != '#')
		{
			prod_name[j] = line[i];
			j++;
			i++;
		} /* while */
		prod_name[j] = '\0';
		i++;

		/* get description */
		j = 0;
		while (line[i] != '#')
		{
			descr[j] = line[i];
			j++;
			i++;
		} /* while */
		descr[j] = '\0';
		i++;

		/* get version */
		j = 0;
		while (line[i] != '#')
		{
			vers[j] = line[i];
			j++;
			i++;
		} /* while */
		vers[j] = '\0';
		i++;

		/* skip date */
		while (line[i++] != '#') {}
		
		/* get location */
		j = 0;
		while (line[i] != '#')
		{
			location[j] = line[i];
			j++;
			i++;
		} /* while */
		location[j] = '\0';
		i++;

		/* is it in this file system ? */
		if (!(strncmp(tmp, location, strlen(tmp))))
		{
			/* acertain product status */
			status = statustext[chk_prod_status(prod_num)];
			FIfld_set_text(fp, PROD_LIST, row, 0, prod_name, FALSE);
			FIfld_set_text(fp, PROD_LIST, row, 1, prod_num, FALSE);
			FIfld_set_text(fp, PROD_LIST, row, 2, descr, FALSE);
			FIfld_set_text(fp, PROD_LIST, row, 3, vers, FALSE);
			FIfld_set_text(fp, PROD_LIST, row, 4, status, FALSE);
			row++;
		} /* if */
	} /* while */

	sprintf(line, "Products existing on %s", fs_table[curr_fs].name);
	FIg_erase(fp, FS_TITLE);
	FIg_set_text(fp, FS_TITLE, line);
	FIg_display(fp, FS_TITLE);
} /* show_fs */



show_selected(fp, fs)

Form	fp;
char	*fs;

/*****************************************************************************/
/* this routine shows the products that are selected for the current fils sys*/
/*****************************************************************************/

{
	struct 	prodnode *pptr;
	int	row;
	char 	blocks[9];
	char	line[MAXLINE];

	FIg_reset(fp, PROD_LIST);

	row = 0;
	for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
	{
		if (! ((pptr->pstat & SELECTED) &&
		      (!(strcmp(pptr->destfs, fs))) ))
			continue;

		FIfld_set_text(fp, PROD_LIST, row, 0, pptr->prodname, FALSE);
		FIfld_set_text(fp, PROD_LIST, row, 1, pptr->prodnumber, FALSE);
		FIfld_set_text(fp, PROD_LIST, row, 2, pptr->prodtitle, FALSE);
		FIfld_set_text(fp, PROD_LIST, row, 3, pptr->prodversion, FALSE);
		sprintf(blocks, "%d", pptr->blocksize);
		FIfld_set_text(fp, PROD_LIST, row, 4, blocks, FALSE);
		row++;
	} /* for */

	sprintf(line, "Products selected for %s", fs_table[curr_fs].name);
	FIg_erase(fp, FS_TITLE);
	FIg_set_text(fp, FS_TITLE, line);
	FIg_display(fp, FS_TITLE);
} /* show_selected */


int
chk_prod_status(prodnum)
char *prodnum;
{
        struct prodnode *curr;
        int i, retstat;

	int found = 0;

        for (curr = header.flink; (!found) && (curr != &header); curr = curr->flink) {
	    if (((curr->arch & my_arch) || show_all_plats) &&
		(strcmp(prodnum, curr->prodnumber) == 0)) {
		found = 1;
		break;
	    }
	}
                       /* find desired entry */

	if (!found)
/*        if (strcmp(prodnum, curr->prodnumber) != 0)*/
        {
            retstat = 9;
        }
        else
        {
            for (i = 0; i < 9; i++)
            {
                if (curr->pstat & (unsigned short)(0x1 << i))
                {
                    retstat = i;
                    break;
                }
            }
        }
        return(retstat);
}


list_products(form)

Form	form;

/************************************************************************/
/* this routine is like show_products except that it lists the products */
/* on the ascii list of available products.                             */
/************************************************************************/

{
	struct prodnode *curr_prod, *last_prod;
	int	i;
	int	row;
	char	*status;
	int	sel_it;
	extern struct prodnode *start, *curr_hdr, *next();
	extern short show_all_plats;
	extern short srcmedia;

	curr_prod = start;
	i = 0;
	row = 0;
	last_prod = NULL;
	
	FIg_reset(form, ASCII_LIST);

	while (curr_prod != &header)
	{
		i++;
		if ((!(curr_prod->arch & my_arch)) && (!show_all_plats))
		{
			curr_prod = next(curr_prod, &header);
			continue;
		}

		if ((NULL != last_prod) && 
		   (!(strcmp(last_prod->prodname, curr_prod->prodname))))
		{
			last_prod->multname = TRUE;
			curr_prod->multname = TRUE;
			FIfld_set_text(form, ASCII_LIST, row-1, 6, "1", TRUE);
			curr_prod = next(curr_prod, &header);
			continue;
		} /* if */


		/* put the product information into the form */

		if ((!(strcmp(curr_prod->destfs, fs_table[curr_fs].name)))
					   && (curr_prod->pstat & SELECTED))
							/* determine if it should */
			sel_it = TRUE;			/* be highlighted or not  */
		else
			sel_it = FALSE;


		if ((srcmedia == CDROM) || (srcmedia == NETCDROM))
		{
			if (curr_prod->attr & ATTR_BOM)  /* this is bom product */
				FIfld_set_text(form, ASCII_LIST, row, 5, "=", sel_it);

			else if (curr_prod->attr & ATTR_INVISIBLE)
				FIfld_set_text(form, ASCII_LIST, row, 5, "~", sel_it);

			else if ((atoi(curr_prod->flags)) && 
			   !(curr_prod->pstat & HAVEKEY)) /* key is needed */
				FIfld_set_text(form, ASCII_LIST, row, 5, " ", sel_it);

			else if (!(atoi(curr_prod->flags))) /* product is free */
				FIfld_set_text(form, ASCII_LIST, row, 5, "*", sel_it);

			else   /* they have the key */
				FIfld_set_text(form, ASCII_LIST, row, 5, ">", sel_it);
		} /* if */
		else

			FIfld_set_text(form, ASCII_LIST, row, 5, " ", sel_it);			


		FIfld_set_text(form, ASCII_LIST, row, 0, curr_prod->prodname, sel_it);
		FIfld_set_text(form, ASCII_LIST, row, 1, curr_prod->prodnumber, sel_it);
		FIfld_set_text(form, ASCII_LIST, row, 2, curr_prod->prodtitle, sel_it);		
		FIfld_set_text(form, ASCII_LIST, row, 3, curr_prod->prodversion, sel_it);
		FIfld_set_text(form, ASCII_LIST, row, 6, "0", sel_it);
		FIfld_set_select(form, ASCII_LIST, row, 6, sel_it);

		/* acertain product status */
                status = statustext[chk_prod_status(curr_prod->prodnumber)];
                FIfld_set_text(form, ASCII_LIST, row++, 4, status, sel_it);

		curr_prod->multname = FALSE;

		last_prod = curr_prod;
		curr_prod = next(curr_prod, &header);
	} /* while */
} /* list_products */




list_products_2(form, gadget)

Form	form;
int	gadget;

/************************************************************************/
/* this routine is like show_products except that it lists the products */
/* on the ascii list of available products.                             */
/************************************************************************/

{
	struct prodnode *curr_prod;
	int	row;
	int	sel_it;
	extern struct prodnode *next();

	row = 0;
	
	FIg_reset(form, gadget);

	for (curr_prod = header.flink; curr_prod != &header; curr_prod = curr_prod->flink)
	{
	    /* put the product information into the form */
	    if (curr_prod->pstat & SELECTED)
		sel_it = TRUE;
	    else
		sel_it = FALSE;

	    FIfld_set_text(form, gadget, row, 0, curr_prod->prodname, sel_it);
	    FIfld_set_text(form, gadget, row++, 1, curr_prod->prodnumber, sel_it);
	} /* while */
} /* list_products_2 */

