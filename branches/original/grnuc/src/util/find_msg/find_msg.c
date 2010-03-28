#include <stdio.h>

int cmpare();
int isblankmsg();
int skip_msg();

#define MAX_STRING 256  /* longest line I'll read from a message file */
#define SCAN_SIZE 20    /* number of messages I'll scan to try to find a dup */
#define MAX_RECORDS 500 /* max # of msgnumbs read from NO_MSG_CHECK file */

struct Filenmsg
{
   char fname[256];
   char msg[MAX_STRING];
   int  linenumber;
};

/* Abstract:  Finds duplicate messages in message files.
 *
 * Quick synopsis:
 *
 *        1. Reads in filenames off command line.
 *        2. Attempts to open each file.
 *        3. reads every line of every file, discarding lines that are
 *             comments (first line a #), contain blank messages, or
 *             are in the file pointed to by the -d switch
 *        4. sort all the messages, ignoring case and whitespace
 *        5. compares each line to the next SCAN_SIZE lines
 *             if a match is found, the match is removed from the list
 *             of messages to be compared.
 *        6. prints out any matches to stdout
 */

main(int argc, char **argv)
{
   int numrecs, *found,num_msg=0,count=0;
   struct Filenmsg *messages;
   char msgnumb[MAX_RECORDS][80];

   if ((argc>1)&&(argv[1][0]=='-')&&(argv[1][1]=='d'))
   {
      FILE *fptr;

      if (fptr = fopen(argv[2],"r"))
      {
         while (fgets(msgnumb[num_msg++], 80, fptr)) 
	    if (num_msg==MAX_RECORDS) break;
         num_msg--;
      }

      count = 2;

      fclose (fptr);
   }

   if (argc == 1) /* No args */
   {
      fprintf(stderr,"\nUsage: %s -d <duplicate_messages> file1 file2 ... filen\n\nThe file after -d should contain message keys that are not to be checked\nOther files should be UMS message source files\n\n",argv[0]);
      exit(0);
   }
   else
   {
      int i,msgcount=0;
      numrecs=1000; 
      messages = (struct Filenmsg *) malloc(numrecs * sizeof(struct Filenmsg));
      if (messages==NULL)
      {
	 fprintf(stderr,"Not enough memory for messages\n");
	 exit(0);
      }

      while (count<argc-1)
      {
	 FILE *stream;
	 int linenum=0;

	 /* Open each file on the command line */
	 
	 if ((stream = fopen(argv[count+1],"r")) == NULL)
	 {
	    fprintf(stderr,"File %s: Cannot open\n",argv[count+1]);
	 }
	 else
	 {
	 while (fgets(messages[msgcount].msg, MAX_STRING, stream))
	 {
	    char tmp_msg[MAX_STRING];

	    /* increment line number count */

	    linenum++;

	    /* 
	     * check if all whitespace or if the line is a comment
	     * or if the messagenumb is in the list of msgnumbs not to
	     * be checked.
	     */

	    if ((messages[msgcount].msg[0] != '#')?
	       (!isblankmsg(messages[msgcount].msg))?
	       (skip_msg(msgnumb, num_msg, 
                         strcpy(tmp_msg,messages[msgcount].msg))):0:0)
	    {
	       /* check if more memory needed */

	       if (msgcount == numrecs-1)
	       {
		  numrecs = numrecs + 1000;
		  messages = (struct Filenmsg *)realloc(messages, numrecs * 
			      sizeof(struct Filenmsg));
		  if (messages == NULL)
		  {
		     /* could be nicer here, and instead of exiting, */
		     /* print out what we've got                     */

		     fprintf(stderr,"realloc failed: out of memory\n");
		     exit(1);
		  }
	       }

	       strcpy(messages[msgcount].fname,argv[count+1]);
	       messages[msgcount].linenumber=linenum;
	       msgcount++;
	    }
	 }
	 }
	 fclose(stream);
	 count++;
      }

      /* Sort all the messages alphabetically, case-insensitive and
	 ignoring whitespace                                         */

      qsort ( (char *)messages,msgcount, sizeof(struct Filenmsg),cmpare);

      /* calloc an array we'll use to cut down on the number of searches */

      found = (int *)calloc(msgcount+1,sizeof(int));

      for(i=0;i<msgcount;i++)
      {
	 int j;
	 static int current=-1;

	 /* if a message has already been found as a duplicate, skip it */
	 
	 while (found[i]) 
	 { 
	    i++;
	 }

	 for(j=i+1;j<(((i+SCAN_SIZE)<msgcount)?(i+SCAN_SIZE):msgcount);j++)
	 {
	    if (found[j]==0)
	    {
	       if (!cmpare(&messages[i],&messages[j]))
	       { 
		  if (current==i)
		     printf("  %s[%i]:\n    %s\n",messages[j].fname,
			    messages[j].linenumber,messages[j].msg);
		  else
		  {
		     printf("The following messages look identical:\n  %s[%i]:\n    %s\n  %s[%i]:\n    %s\n",messages[i].fname,messages[i].linenumber,messages[i].msg,messages[j].fname,messages[j].linenumber,messages[j].msg);
		     current=i;
		  }
		  found[j]=1;
	       }
	    }
	 }
      }
   }
      
return;
}

/*
 * strcpnws(): string copy stripping whitespace (well converting to spaces, 
 * one space between non-whitespace) and converting to lowercase 
 */

void strcpnws(char *s1, char *s2)
{
   char *ptr1, *ptr2;

   ptr2=s2;
   ptr1=s1;

   /* get rid of leading whitespace */

   while (isspace(*ptr2++));

   while (*ptr2)
   {
      *ptr1++=tolower(*ptr2++);
      if (isspace(*ptr2))
      {
 	 *ptr1++=' ';
	 ptr2++;
	 while (isspace(*ptr2)) ptr2++;
      }
   }
   *ptr1='\0';
   return;
}

/*
 * cmpare():  compares two Filenmsg structs, and returns 0 if the 
 * strings are identical (ignoring whitespace and case)
 */ 

int cmpare(struct Filenmsg *element1, struct Filenmsg *element2)
{
   char string1[MAX_STRING],string2[MAX_STRING];
   char *ptr1, *ptr2;

   strcpnws(string1,element1->msg);
   strcpnws(string2,element2->msg);
   ptr1=string1;
   ptr2=string2;

   /* get to the second field (the message field) */

   while (!isspace(*ptr1++));
   while (!isspace(*ptr2++));

   return strcmp(ptr1,ptr2);

}

/*
 * isallws(): returns 0 if string has any non-whitespace, 1 otherwise
 */

int isallws(char *string)
{
   char *ptr;

   ptr=string;

   while (*ptr)
   {
      if (!isspace(*ptr++)) return 0;
   }

   return 1;
}

/*
 * isblankmsg(): checks if a line pulled from a message file contains a
 * blank message.  returns 1 if it is
 */
 
int isblankmsg(char *string)
{
   char *ptr;

   ptr=string;

   while (!isspace(*ptr++));

   if (isallws(ptr))
      return 1;
   else
      return 0;
}

int skip_msg(char msgs[MAX_RECORDS][80], int count, char *msg)
{
   int i=0;
   char delimiters[5]= { ' ', '\n', '\t', ',', '\0'};

   while (i<count)
      if (!strcmp(strtok(msgs[i++],delimiters),strtok(msg,delimiters))) 
	  return 0;
   return 1;
}
