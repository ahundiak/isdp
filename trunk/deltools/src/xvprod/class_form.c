#include <stdio.h>
#include "FI.h"
#include "main.h"
#include "defs.h"

#define ALL_CLASS	"All Products"

/* Externs */
extern int FIg_get_text_length();
extern int FIg_get_text();

extern int	last_active_class;
extern int	curr_fs;
extern char	button_array[2][MAXROW*MAXCOL][MAXPROD];
extern Form	classform;
extern Form	delform;
extern Form	statform;
extern struct prodnode	classheader;
extern struct prodnode	header;
extern struct prodnode	*curr_hdr;
extern struct prodnode	*start;

extern struct prodnode *first(), *next(), *prev(), *last();
extern unsigned long my_arch;
extern int class;
extern short multimenu;

void
show_classes(fp)
Form fp;
{
    /* the classform has already been generated and displayed.
     * We just need to step through the classlist and put the names
     * in the FIELD gadget....
     */
    struct prodnode *curr_prod;
    int	line=0;
    char numavail[7], numsel[7];
    
    sprintf(numsel, "%d", header.pstat);
    sprintf(numavail, "%d", header.blocksize);
    FIfld_set_text(fp, CLASSES, line, 0, ALL_CLASS, FALSE);
    FIfld_set_text(fp, CLASSES, line, 1, numsel, FALSE);
    FIfld_set_text(fp, CLASSES, line, 2, numavail, FALSE);
    line++;

    for (curr_prod = classheader.flink; curr_prod != &classheader;
	    curr_prod = curr_prod->flink) {
	if (curr_prod->blocksize != 0)
	{
		sprintf(numsel, "%d", curr_prod->pstat);
		sprintf(numavail, "%d", curr_prod->blocksize);
		FIfld_set_text(fp, CLASSES, line, 0, curr_prod->prodclass, FALSE);
		FIfld_set_text(fp, CLASSES, line, 1, numsel, FALSE);
		FIfld_set_text(fp, CLASSES, line, 2, numavail, FALSE);
		line++;
	}
    }
}


static int get_class_text ( fp, g_label, text, text_size )
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char ** text;          /* The text contained in the field */
       int   * text_size;     /* The space allocated for the text */
{
    int status;
    int text_len;
    int select_flag;
    int row = 0;
    int pos = 0;


    FIfld_get_active_row ( fp, g_label, &row, &pos );
    FIfld_get_text_length ( fp, g_label, row, 0, &text_len );

    /* Increment text_len because of NULL */
    text_len++;
    if ( * text_size < text_len )
    {
        if ( * text_size > 0 )
        {
           /* Realloc space for larger string */
           * text = realloc ( * text, text_len );
        }
        else
        {
           /* Calloc space for string */
           * text = calloc ( 1, text_len );
        }
        * text_size = text_len;
    }

    if ( ! * text )
    {
      * text_size = 0;
      return ( FI_NO_MEMORY );
    }

    status = FIfld_get_text ( fp, g_label, row, 0, * text_size,
                            * text, &select_flag, &pos );
    return ( status );
}


/*ARGSUSED*/
void class_form_note( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char		* class_name;
  char			deltitle[64], line[MAXLINE];
  static int		text_size = 0;
  struct prodnode	*cptr, *pptr;
  int			status;
  int			found = 0;
  int			row, pos, flag;
  int			auto_cnt, save_curr_fs;
  int			all_classes;

    switch ( g_label )
    {
    case CLASSES:
	/* make sure that it was not UNselected */
	FIfld_get_active_row(fp, g_label, &row, &pos);
	FIfld_get_select(fp, g_label, row, 0, &flag);
	if (!flag)
	{
		FIfld_set_select(fp, g_label, row, 0, TRUE);
		FIfld_set_select(fp, CLASSES, row, 1, TRUE);
		FIfld_set_select(fp, CLASSES, row, 2, TRUE);
		return;
	}

	/* Get the text string */
	status = get_class_text ( fp, g_label, &class_name, &text_size );
	if ( status != FI_SUCCESS )
	{
        /* Code to handle error */
              return;
	}

	/* 
	 * If the "all products" line was selected, then
	 * leave "individual classes" mode and display all
	 * products
	 */

	if (strcmp(class_name, ALL_CLASS) == 0) {
           /* Here we go... */
            class = 0;
            multimenu = 0;
            curr_hdr = &header;
            start = first(curr_hdr, &header);
            strcpy(deltitle, class_name);
            if (strlen(deltitle) > 45) {
                deltitle[45] = '\0';
                strcat(deltitle, "...");
            }
            strcat(deltitle, ":");
            status = FIg_erase(delform, DEL_TITLE);
	    if (status != FI_SUCCESS)
		PRINT "Couldn't erase previous label.");
            FIg_set_text(delform, DEL_TITLE, deltitle);
            FIg_display(delform, DEL_TITLE);
            list_products(delform);
	    break;
	}

	/* "class_name" holds the name of the selected class.
	 * We change the title of the Delivery form to reflect
	 * the products being displayed, find the appropriate product
	 * header node for the class, and display the buttons.
	 */
	for (cptr = classheader.flink; cptr != &classheader; cptr = cptr->flink) {
	    if (strcmp (cptr->prodclass, class_name) == 0) {
		/* Got it! */
		found = 1;
		break;
	    }
	}
	if (!found)  {
	    /* How could this happen? */
	    fprintf(stderr, "Didn't find %s\n", class_name);
	}
	else {
	    /* Here we go... */
	    class = 0;
	    multimenu = 1;
	    curr_hdr = cptr;
	    start = first(curr_hdr, &header);
	    strcpy(deltitle, class_name);
	    if (strlen(deltitle) > 45) {
		deltitle[45] = '\0';
		strcat(deltitle, "...");
	    }
	    strcat(deltitle, ":");
	    status = FIg_erase(delform, DEL_TITLE);
	    if (status != FI_SUCCESS)
		PRINT "Couldn't erase text gadget");

	    FIg_set_text(delform, DEL_TITLE, deltitle);
	    FIg_display(delform, DEL_TITLE);
	    list_products(delform);
	}
	break;

     case AUTOCLASS:   /* select products that need to be updated within the class */
	/* get the name of the highlighted class */
	FIfld_get_active_row(fp, CLASSES, &row, &pos);
	status = get_class_text ( fp, CLASSES, &class_name, &text_size );

	all_classes = (strcmp(class_name, ALL_CLASS) == 0) ;
	

	/* check each product for update status and class */
        auto_cnt = 0;
	save_curr_fs = curr_fs;  /* keep track of the current file sys */

        for (pptr = header.flink; pptr != &header; pptr = pptr->flink) {
		if (pptr->pstat & NEEDS_UPDATING && pptr->arch & my_arch) { 
		    if (!all_classes)
			if (strcmp(class_name, pptr->prodclass))
			    continue;

		    curr_fs = get_fs_number(pptr->loadeddir);
		    set_selected_ascii(delform, pptr->prodname,
                                   pptr->prodnumber, TRUE, TRUE);
		    update_class(pptr);
		    auto_cnt++;
                }
        }

	curr_fs = save_curr_fs;  /* set it back */

	/* print a message if nothing was selected or update the product form */
        if (auto_cnt == 0)
             FIfld_set_text(statform, MESSBOX, 0, 0, "No products need updating.", FALSE);
        else  {
	     sprintf(line, "Products in the \"%s\" class",
		class_name);
	     FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
	     FIfld_set_text(statform, MESSBOX, 1, 0, "that need to be updated have been selected.", FALSE);
             list_products(delform);
	}

	break;

     case UNSELCLASS:  /* unselect all products in the class */
	FIfld_get_active_row(fp, CLASSES, &row, &pos);
	status = get_class_text ( fp, CLASSES, &class_name, &text_size );

	all_classes = (strcmp(class_name, ALL_CLASS) == 0) ;

	for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
		if (pptr->pstat & SELECTED) {
		    if (!all_classes) 
		       if (strcmp(class_name, pptr->prodclass))
			   continue;
			   
		    set_selected_ascii(delform, pptr->prodname,
			    pptr->prodnumber, FALSE, TRUE);
		    update_class(pptr);
		}

	list_products(delform);
        sprintf(line, "All products in the \"%s\" class",
		class_name);
        FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
	FIfld_set_text(statform, MESSBOX, 1, 0, "are unselected.", FALSE);
	break;
    } /* END switch ( g_label ) */
} /* END notification_routine() */




update_class(curr_prod)

/*************************************************************************/
/* this routine updates the line in the CLASSES gadget that represents   */
/* the given product's class                                             */
/*************************************************************************/

struct prodnode *curr_prod;

{
	int	 row, num_rows, len, sel, pos;
	char	 curr_class[TITLE_LEN];
	char	 numsel[7], numavail[7];
	int	 tot_sel = 0;
	int	 tot_avail = 0;
	struct prodnode *tmp_prod;

	for (tmp_prod = classheader.flink; tmp_prod != &classheader;
		 tmp_prod = tmp_prod->flink) {
	     tot_sel += tmp_prod->pstat;
	     tot_avail += tmp_prod->blocksize;
	}
	sprintf(numsel, "%d", tot_sel);
	sprintf(numavail, "%d", tot_avail);
	FIfld_get_text_length(classform, CLASSES, 0, 0, &len);
	FIfld_get_text(classform, CLASSES, 0, 0, len, curr_class,
		    &sel, &pos);
	FIfld_set_text(classform, CLASSES, 0, 1, numsel, sel);
	FIfld_set_text(classform, CLASSES, 0, 2, numavail, sel);

	FIfld_get_num_rows(classform, CLASSES, &num_rows);
	for (row = 1; row < num_rows; row++) {
		FIfld_get_text_length(classform, CLASSES, row, 0, &len);
		FIfld_get_text(classform, CLASSES, row, 0, len, curr_class,
			&sel, &pos);

		if (!strcmp(curr_prod->prodclass, curr_class)) {
			sprintf(numsel, "%d", curr_prod->clink->pstat);
			sprintf(numavail, "%d", curr_prod->clink->blocksize);
			FIfld_set_text(classform, CLASSES, row, 1, numsel, sel);
			FIfld_set_text(classform, CLASSES, row, 2, numavail, sel);
			break;
		} /* if */
	} /* for */

} /* update_class */
