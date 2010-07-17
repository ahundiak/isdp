
#include <stdio.h>

struct scrap
  {
    char type[5];  /* "TEXT" */
    int  size;     
		   /* 
		     in case of TEXT, the size does not include the
		     terminating null charecter.
		   */ 
    char *data;    /* TEXT data is terminated by a NULL charecter */
  }; 

static struct scrap scrapbuf;


int Clear_scrap_ig()
  {
    int  rc=0;

    if (scrapbuf.data != NULL){
      rc=1;
      free (scrapbuf.data);
    }

    scrapbuf.type[0]='\0';
    scrapbuf.size='\0';
    scrapbuf.data=NULL;
    return rc;
  }



int Get_scrap_ig (type, data, size, index)
  char *type;
  char *data;
  int  *size;
  int  *index;
  {

    if (!strcmp (type, "TEXT"))
      {
        if (!strcmp (type, scrapbuf.type))
	  {
            if (scrapbuf.size > 0)
	      {
	        data = (char *) realloc (data, scrapbuf.size+1);
	        strcpy (data, scrapbuf.data);

	        *size = scrapbuf.size;
	      }
	  }
        return *size;
      }
    else
      printf ("Unknown datatype\n");
  }


int Put_scrap_ig (type, data, size)
  char *type;
  char *data;
  int  size;
  {

    if (!strcmp (type, "TEXT"))
      {
        if (size > 0)
	  {
	    Clear_scrap_ig ();

	    strcpy (scrapbuf.type, type);

	    scrapbuf.data = (char *) malloc (size+1);
	    strcpy (scrapbuf.data, data);

	    scrapbuf.size = size;
	    return size;
	  }
      }
    else
      printf ("Unknown datatype\n");
  }
