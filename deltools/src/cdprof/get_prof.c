#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include "main.h"

#ifdef L_ENDIAN
#define htocl(x)	(x)
#define ctohl(x)	(x)
#define htocs(x)	(x)
#define ctohs(x)	(x)
#else
unsigned long htocl(i)
unsigned long i;
{
    unsigned long s;
    char *bytes;
    char *swbytes;

    bytes = (char *)&i;
    swbytes = (char *)&s;

    swbytes[0] = bytes[3];
    swbytes[1] = bytes[2];
    swbytes[2] = bytes[1];
    swbytes[3] = bytes[0];

    return(s);
}
#define ctohl(x)	htocl(x)

unsigned short htocs(s)
unsigned short s;
{
    unsigned short r;
    char *bytes;
    char *swbytes;

    bytes = (char *)&s;
    swbytes = (char*)&r;

    swbytes[0] = bytes[1];
    swbytes[1] = bytes[0];

    return(r);
}
#define ctohs(x)	htocs(x)
#endif

struct linktype {			/* node for product and key   */
	short	index;			/* product index to the table */
	char	pname[BAS4_PROD_LEN+1]; /* product name               */
	char	key[BAS4_KEY_LEN+1];    /* key                        */
	struct linktype	*next;      	/* pointer to the next link   */
};

struct linktype *head;			/* pointer to start of the list	*/

/*
 * allocates space to a node
 */
struct linktype *lalloc() {
	return((struct linktype *) malloc(sizeof(struct linktype)));
}

extern int total_recs;

/*
 * this function finds all of the keys for the eid and returns them along
 * with the product names in buff
 */
char	*get_profile(fd1, eid)
int	fd1;	/* open file descriptor to the database file */
int	eid;	/* the ethernet ID of the customer */
{
	int	cus, num_eid, found, offset, count, first, last, mid;
	int	ccus, coffset;
	unsigned int	eidlen;
	unsigned int	ceidlen;
	char	magic[MAG_LEN+1];	/* magic number at start of the file */
	char	num[IND_LEN+1];		/* string to read prod index into    */
	char	key[BAS4_KEY_LEN+1];	/* key                               */
	char	release[REL_LEN+1];	/* release prefix                    */
	char	*b, *buff;		/* this is returned with prods & keys*/
	struct linktype *node;		/* pointer to a node                 */
	short	cindex, index;		/* product index                     */
	unsigned short	clen1, ctlen;	/* lengths of tables		     */
	unsigned int	len1, tlen;
	unsigned int	prod_len = OLD_PROD_LEN, key_len = KEY_LEN;
	short	type;			/* type of profile database          */

	/*
	 * look for the magic number
	 */
	read(fd1, magic, MAG_LEN);

	magic[MAG_LEN] = '\0';
	type = 0;
	if (strcmp(magic, "BAS1")) {
	    if (strcmp(magic, "BAS2")) {
		if (strcmp(magic, "BAS3")) {
		    if (strcmp(magic, "BAS4")) {
			return(NULL);
		    }
		    else {
			/*
			 * Product numbers are 15 characters long
			 * (thank you, Mrs. Meadlock)
			 *
			 * Keys are 21 characters long
			 * (thank you, Software Distribution)
			 */
			type = 3;
			prod_len = BAS4_PROD_LEN;
			key_len = BAS4_KEY_LEN;
		    }
		}
		else {
		    /*
		     * Product numbers are 9 characters long
		     *
		     * Keys are 16 characters long
		     * (before 3-character "release" prefix is added)
		     */
		    type = 2;
		    prod_len = PROD_LEN;
		    key_len = KEY_LEN;
		}
	    }
	    else
		type = 1;
	}

        if (type == 1 || type == 0) {
	    /*
	     * Otherwise it's an older database with only
	     * seven character product numbers
	     */
	    prod_len = OLD_PROD_LEN;
	    key_len = KEY_LEN;
	}

	/*
	 * read length of customer id part
	 */
	read(fd1, &clen1, LEN_LEN);
	len1 = ctohs(clen1);


	/*
	 * for BAS1, len1 is a byte length, but in BAS2, len1 is the count of
	 * ethernet addresses (we outgrew the short). Therefore, use eidlen (an
	 * unsigned int) to reflect the actual length.
	 */
	if (type)
		eidlen = HEADER1 + (EID_LEN + OFF_LEN) * len1;
	else
		eidlen = len1;

	/*
	 * read product table length
	 *
	 * For BAS1, BAS2, and BAS3, len2 is a byte length.
	 * For BAS4, len2 is the count of product ids in the
	 * table.  
	 */
	read(fd1, &ctlen, LEN_LEN);
	if (type < 3)
	    tlen = ctohs(ctlen);
	else
	    tlen = ctohs(ctlen) * prod_len;

	/*
	 * determine number of customers
	 */
	num_eid = (eidlen - HEADER1) / CUS_LEN;

	/*
	 * start the binary search for eid
	 */
	found = FALSE;
	first = 0;
	last = num_eid - 1;

	while ((first <= last) && (!found)) {
		mid = (first + last) / 2;

		/*
		 * go to the mid customer eid
		 */
		lseek(fd1, (mid * CUS_LEN) + HEADER1, FROM_START);
		read(fd1, &ccus, EID_LEN);

		cus = ctohl(ccus);

		if (cus == eid)
			found = TRUE;
		else
			/*
			 * reduce search space by half
			 */
			if (cus > eid)
				last = mid - 1;
			else
				first = mid + 1;
	}

	/*
	 * customer eid not in the base
	 */
	if (!found)
		return(NULL);

	/*
	 * get the addr to the keys
	 */
	read(fd1, &coffset, OFF_LEN);
	offset = ctohl(coffset);
	offset = offset + eidlen + tlen;
	lseek(fd1, offset, FROM_START);

	/*
	 * read keys and put in the linked list
	 */
	head = NULL;
	for (;;) {
		if (type) {
			/*
			 * read the key
			 */
			if (!read(fd1, key, key_len)) 
			    break;

			if (key[0] == '$')
			    break;

			/*
			 * read the product number
			 */
			read(fd1, &cindex, IND_LEN);
			index = ctohs(cindex);
		} else {
			if (!read(fd1, &cindex, IND_LEN))
			    break;

			if ((*(char *)&cindex) == '$')
			    break;
			
			index = ctohs(cindex);
			read(fd1, key, key_len);
		}
		key[key_len] = '\0';

		/*
		 * put into the linked list
		 */
		add_node(index, key);
		total_recs++;
	}

	if (!head)
		return(NULL);

	/*
	 * get product names for indexes
	 */

	count = 0;
	for (node = head; node; node = node->next){
		lseek(fd1, (eidlen + ((node->index - 1) * prod_len)),
			FROM_START);
		read(fd1, node->pname, prod_len);
		node->pname[prod_len] = '\0';
		count++;
	}

	/*
	 * go to release
	 */
	lseek(fd1, (eidlen + tlen), FROM_START);
	if (type < 3) {
	    /*
	     * In older CD's , the CD-ROM "release" string
	     * (three characters which represent the six digit
	     * release date) is prepended to every key.
	     */
	    read(fd1, release, REL_LEN);
	    release[REL_LEN] = '\0';

	    buff = (char*)calloc(1, (count * (prod_len + REL_LEN +  KEY_LEN + 2)) + 1);
	    /*
	     * put the product names and keys in buff
	     */
	    buff[0] = '\0';
	    b = buff;
	    for (node = head; node; node = node->next) {
		sprintf(b, "%s %s%s\n", node->pname, release, node->key);
		b += strlen(b);
	    }
	}
	else {
	   /*
	    * With new loadkeys based on a 15-character product
	    * number which includes version number data, adding
	    * a CD-ROM release data in the key is no longer
	    * necessary.
	    * But if the database is still going to have this
	    * information stored in it, we need to read past it.
	    *
	    * read(fd1, release, REL_LEN);
	    * release[0] = '\0';
	    */

	   buff = (char *)calloc(1, (count * (prod_len + key_len + 2)) + 1);

	    /*
	     * put the product names and keys in buff
	     */
	    buff[0] = '\0';
	    b = buff;
	    for (node = head; node; node = node->next) {
		sprintf(b, "%s %s\n", node->pname, node->key);
		b += strlen(b);
	    }
	}

	free_list(head);

	return(buff);
}


/*
 * this procedure adds the index and key pairs to the linked list for the
 * particular eid
 */
add_node(index, key)
short	index;		/* product index */
char	*key;		/* the key */
{
	struct linktype *node;

	if (!head) {
		/*
		 * empty list
		 */
		head = lalloc();
		head->index = index;
		strcpy(head->key, key);
		head->pname[0] =  '\0';
		head->next = NULL; 
	} else {
		/*
		 * add to start of head
		 */
		node = lalloc();
		node->index = index;
		strcpy(node->key, key);
		node->pname[0] = '\0';
		node->next = head;
		head = node;
	}
}


free_list(head)
struct linktype *head;
{
	struct linktype *node;

	while (head) {
	    node = head->next;
	    free(head);
	    head = node;
	}
}
