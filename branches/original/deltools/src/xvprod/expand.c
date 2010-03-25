#include  "main.h"
#include  "defs.h"

#define LONGLINE 2048

extern struct prodnode header;
extern struct group_node *group_header;
extern struct remote_node *ralloc();
extern	char	*my_decrypt();
extern char host[], acctnm[], pass[];  /* given with connection */
extern short srcmedia;

extern char *cpu_types[];

extern Form statform;

extern max_simul_del;  /* max simultaneous deliveries - MAX keyword */


struct prodnode *palloc()
{
	return((struct prodnode *) malloc(sizeof(struct prodnode)));
}

struct	remote_node	*expanded_head = NULL;


expand()

/****************************************************************************/
/* sigh.  this routine takes the selected remote machines and the selected  */
/* products and links them up so that each selected remote points to a list */
/* of products to be delivered to that remote and the file system to deliver*/
/* that product to.                                                         */
/****************************************************************************/

{
	struct  prodnode    *curr_prod;
	struct	group_node  *curr_group;
	struct	remote_node *curr_remote, *curr_exp;
	struct	prodnode    *sel_head, *curr_sel;
	int	dble;

	/* first -- make a list of products to be delivered */
	sel_head = NULL;

	curr_prod = header.flink;
	while (curr_prod != &header)
	{
		if (curr_prod->pstat & SELECTED) 
		{
			if (sel_head == NULL)
			{
				sel_head = palloc();
				curr_sel = sel_head;
			} /* if */
			else
			{
				curr_sel->flink = palloc();
				curr_sel = curr_sel->flink;
			} /* else */

			strcpy(curr_sel->prodnumber, curr_prod->prodnumber);
			strcpy(curr_sel->prodname, curr_prod->prodname);
			curr_sel->arch = curr_prod->arch;
			curr_sel->pstat |= SELECTED;
			curr_sel->flink = NULL;
		} /* if */
				
		curr_prod = curr_prod->flink;
	} /* while */

	/* make sure that some products were selected */
	if (sel_head == NULL)
		return(1);
	
	/* second -- make the list of selected remote nodes */

	curr_group = group_header;
	while (curr_group != NULL)
	{
	    curr_remote = curr_group->members;
	    while (curr_remote != NULL)
	    {
		if (curr_remote->selected == TRUE)
		{
		    dble = FALSE;
		    if (expanded_head == NULL)
		    {
			expanded_head = ralloc();
			curr_exp = expanded_head;
		    } /* if */
		    else
		    {
			/* make sure this node is not
			 * already on this list  
			 */
			curr_exp = expanded_head;
			while (TRUE)
			{
			    if (!(strcmp(curr_exp->nodename,
				    curr_remote->nodename)))
			    {
				dble = TRUE; 
				break;
			    }
			    if (curr_exp->next != NULL)
				curr_exp = curr_exp->next;
			    else
				break;
			} /* while */

			if (!dble)
			{
			    curr_exp->next = ralloc();
			    curr_exp = curr_exp->next;
			}
		    } /* else */
		
		    if (!dble)
		    {
			strcpy(curr_exp->nodename, curr_remote->nodename);
			curr_exp->prodptr = sel_head;
			curr_exp->next = NULL;
		    } /* if */
		} /* if */
		curr_remote = curr_remote->next;
	    } /* while */
	    curr_group = curr_group->next;
	} /* while */

	/* make sure that some remote machines were selected */
	if (expanded_head == NULL)
		return(2);

	return(0);
} /* expand */



make_rm_list(fp, tmp_file)

Form	fp;
char	*tmp_file;

/***************************************************************************/
/* this routine prints out the structure created above into a file of      */
/* remote machines and newprod command lines                               */
/* tmp_file is the file that will be created                               */
/***************************************************************************/

{
	FILE	*of, *out, *fopen();
	char	line[LONGLINE], cmpline[512], eline[LONGLINE];
	int	i;
	struct	remote_node *curr_node;
	struct	prodnode    *curr_prod;
	char	deffs[MAXLINE], passwd[LONGLINE], platform[MAXLINE];
	int	found;

	curr_node = expanded_head;

	if (NULL == (of = fopen("/.vprod/machines", "r")))
		return(-1);

	if (NULL == (out = fopen(tmp_file, "w")))
	{
		fclose(of);
		return(-1);
	} /* if */
	chmod(tmp_file, 0600);

	/* write the server keyword */

	if ((host[0] == '\0') || (acctnm[0] == '\0'))
	{
	    FIg_reset(statform, MESSBOX);
	    FIfld_set_text(statform, MESSBOX, 0, 0, 
		    "Error connection account has not been defined.", FALSE);
	    return(-1);
	}

	sprintf(line, "SERVER %s.%s.%s\n", host, acctnm, pass);
	fputs(line, out);

	/* write the media keyword */
	if ((srcmedia == CDROM) || (srcmedia == NETCDROM))
	    sprintf(line, "MEDIA CDROM\n");
	else if ((srcmedia == TCPIP) || (srcmedia == VAX) ||
	     (srcmedia == WORKSTATION) || (srcmedia == LOCAL_DIR))
	    sprintf(line, "MEDIA DISK\n");
	fputs(line, out);

	/* write the MODEL keyword */
	if (merge_in_defaults(fp))
	{
	    sprintf(line, "MODEL /.vprod/prod.def\n");
	    fputs(line, out);
	}

	/* write the MAX keyword */
	sprintf(line, "MAX %d\n", max_simul_del);
	fputs(line, out);

	fputs("#\n", out);

	while (curr_node != NULL)
	{
	    curr_prod = curr_node->prodptr;
	    
	    while (fgets(line, LONGLINE, of))
	    {
		sprintf(cmpline, "NODENAME=%s", curr_node->nodename);
		if(!(strncmp(line, cmpline, strlen(cmpline))))
		    break;
	    } /* while */

	    /* read the default_fs line */
	    if (!(fgets(line, LONGLINE, of)))
		return;
	    if (!(strncmp(line, "DEFAULT_FS", strlen("DEFAULT_FS"))))
	    {
		line[strlen(line) -1] = '\0';
		strcpy(deffs, line+11);
	    } /* if */
	    
	    /* read the password line */
	    if (!(fgets(line, LONGLINE, of)))
		return;
	    if (!(strncmp(line, "RPW", strlen("RPW"))))
	    {
		line[strlen(line) -1] = '\0';
		strcpy(passwd, line+4);
	    } /* if */

	    /* read the platformline */
	    if (!(fgets(line, LONGLINE, of)))
		return;
	    if (!(strncmp(line, "PLATFORM", strlen("PLATFORM"))))
	    {
		line[strlen(line) -1] = '\0';
		strcpy(platform, line+9);
	    } /* if */

	    sprintf(line, "FILESYSTEM %s\n", deffs);
	    fputs(line, out);

	    fputs("PRODUCTS", out);

	    while (fgets(line, LONGLINE, of)) {
		if (!(strncmp(line, "EXCEPTION", strlen("EXCEPTION")))) {
		    line[strlen(line) - 1] = '\0';  /* get rid of CR */

		    i = 0;
		    while (line[i++] != ' ') {}
	    
		    strcpy(cmpline, line+i);   /* get product */

		    i = 0;
		    while (cmpline[i++] != '=') {}

		    strcpy(line, cmpline+i);   /* get file system */
		    cmpline[i-1] = '\0';
		
		    /* see if the exception product is in the list of
		     * products to be deliverd. if it is, print it
		     * and unselect the product in the list
		     */

		    found = FALSE;
		    curr_prod = curr_node->prodptr;
		    while ((curr_prod != NULL) && (!found)) {
			if ((!(strcmp(cmpline, curr_prod->prodname))) ||
			    (!(strcmp(cmpline, curr_prod->prodnumber)))) {
			    sprintf(eline, " %s=%s", curr_prod->prodnumber, line);
			    fputs(eline, out);
			    curr_prod->pstat &= ~SELECTED;
			    found = TRUE;
			} /* if */
			curr_prod = curr_prod->flink;
		    } /* while */
		} /* if */
		else if (!(strncmp(line, "NODENAME", strlen("NODENAME"))))
		    break;
		
	    } /* while */

	    curr_prod = curr_node->prodptr;

	    while (curr_prod != NULL)
	    {
		if (curr_prod->pstat & SELECTED)
		{
		    for (i = 0; (i < NUM_ARCH && cpu_types[i]); i++)
		    {
			if ((curr_prod->arch & (1L << i)) &&
				(strcmp(platform, cpu_types[i]) == 0))
			{
			    sprintf(line," %s",curr_prod->prodnumber);
			    fputs(line, out);
			}
		    }
#ifdef old
		    if (((!(strcmp(platform, "CLIPPER"))) && 
		       (curr_prod->arch & CLIPPER_ARCH))  ||
		       ((!(strcmp(platform, "SUN"))) &&
		       (curr_prod->arch & SUN_ARCH)))
		    {
			sprintf(line," %s",curr_prod->prodnumber);
			fputs(line, out);
		    }
#endif
		} /* if */
		curr_prod->pstat |= SELECTED;  /* set it back */
		curr_prod = curr_prod->flink;
	    } /* while */

	    if (passwd[0] == '\0')
		    sprintf(line, "\nTARGET %s.root\n", curr_node->nodename);
	    else
		    sprintf(line, "\nTARGET %s.root.%s\n", curr_node->nodename, 
				passwd);
	    fputs(line, out);

	    fputs("#\n", out);
	    rewind(of);
	    curr_node = curr_node->next;
	} /* while */

	fclose(of);
	fclose(out);
	expanded_head = NULL;
} /* make_rm_list */
