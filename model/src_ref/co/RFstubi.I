class implementation RFstub;

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "FI.h"


#define RANDOM_RANGE ((1 << 15) - 1)
#define ENTSIZE 7L
#define METACHAR '%'
#define YES 1
#define NO 0
#define MAX_STR 120
#define FIELD1        11
#define CHECKLIST1    15

%safe
static IGRboolean dont_show = TRUE;
%endsafe

extern long lseek(), time();
extern int rand();

method execute(int *response; char *response_data; int pos)
{
    Form my_form;
    IGRboolean file_exists;
    IGRint status,i;
    IGRchar path[256], path1[256];
    int RFstub_form();

    if (dont_show) 
    {
      *response = TERMINATE;
      return (OM_S_SUCCESS);
    }

    status = FIf_new(0, "RFStub", RFstub_form, &my_form);
    if (status != FI_SUCCESS)
    {
       /*|create_form: FIf_new failed*/
       return(OM_E_ABORT);
    }

    status = 1;
    file_exists = FALSE;

    for (i = 0; (1 & status); i++)
    {
       if (status = ex$get_path(index = i,path = path,len = sizeof(path)))
       {
           strcat(path,"config/english/");
           strcpy(path1,path);
           strcat(path1,"tip.hash");
           if (access(path1, F_OK))
           {
               continue;
           }
           else
           {
               file_exists = TRUE;
               break;
           }
       }
    }

    if (file_exists == TRUE)
    {
        PutTip(path, my_form);
        FIf_display(my_form);
    }

    *response = TERMINATE;

    return(0);
}


int RFstub_form(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
  int is_on;

  switch(gadget_label)
  {
    case CHECKLIST1:
         FIg_get_state(form_ptr, &is_on);
         if (is_on) dont_show = TRUE;
         break;

    case FI_ACCEPT:

         FIf_erase ( form_ptr );
         FIf_delete(form_ptr);
         break;
  }
  return(1);
}


int really_random(my_range)
int my_range;
{
	int max_multiple, rnum;

	max_multiple = RANDOM_RANGE / my_range;
	max_multiple *= my_range;
	while ((rnum = rand()) >= max_multiple)
		continue;
	return(rnum % my_range);
}

int PutTip(char *path, Form form)
{
	int nentries, oneiwant;
	FILE *hashf, *tipf;
	long tippos;
    char path2[1024];
    char curr_line[MAX_STR];
    int num_lines = 0, status;

	/* open the tip file for read */
    strcpy(path2, path);
    strcat(path2,"tip.tips");
	if ((tipf = fopen(path2,"r")) == NULL)
	{
		return(0);
	}

	/* open the hash file for read */
    strcpy(path2, path);
    strcat(path2,"tip.hash");
	if ((hashf = fopen(path2,"r")) == NULL)
	{
        fclose(tipf);
		return(0);
	}

	/* compute number of tip addresses in the hash file by
	 * dividing the file length by the size of a tip address
	 */
	if (fseek(hashf,0L,2) != 0)
	{
        fclose(tipf);
        fclose(hashf);
		return(0);
	}
	nentries = ftell(hashf) / 7L;

	/* seed the random number generator with time in seconds plus
	 * the program's process ID - it yields a pretty good seed
	 * again
	 */
	srand(getpid() + time(NULL));

	/* generate a not really random number */
	oneiwant = really_random(nentries);

	/* locate the one I want in the hash file and read the
	 * address found there
	 */
	fseek(hashf,(long)oneiwant * ENTSIZE, 0);
	fscanf(hashf,"%lx",&tippos);

	/* seek tip file to tip starting at address read from hash */
	fseek(tipf,tippos,0);

    
    while (fgets(curr_line,MAX_STR,tipf) != NULL)
	{
        if (curr_line[0] == '%' && curr_line[1] == '%') break;
        status = FIfld_set_num_rows(form,FIELD1,num_lines);
        FIfld_set_text(form,FIELD1,num_lines,0,curr_line,FALSE);
        num_lines++;
	}
 
    fclose(tipf);
    fclose(hashf);
	return(1);
}


end implementation RFstub;
