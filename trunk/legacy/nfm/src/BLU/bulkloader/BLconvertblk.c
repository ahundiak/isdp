#include <stdio.h>
#include <string.h>
#include "BLdefs.h"

#define  MAX_CATS      50
#define  MAX_ATTS     150


/******************************************************************************

Doc:    BLconvert_blk

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLconvertblk.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module converts from an old bulkload format to the newest.
        It takes a file pointer (the old file) and a file name (the new file)
          as input.  It will create the new file itself.
        Currently converts the following formats to the newest version:
              1)  2.0.0.3
              2)  2.2.0.3
        The original file is not harmed in the conversion attempt.

Examples:
          status = BLconvert_blk(old_file_ptr,
                                 new_file_name);

Return Status:
          0             -if new file was written
          1             -if error occurred.

History:
     09/03/91  wrw  -added standard header and converted externs to .h

******************************************************************************/
  

long BLconvert_blk (old,new_name)
FILE *old;                      /* I - file pointer to old .blk to convert */
char *new_name;                 /* I - name of the new .blk to create */
{
FILE  *fp;
char   fn[30];
long   i,status;
long   this_version;
char  version[133];
long   old_versions=2;             /* number of old versions that exist */
char  version_numbers[2][10];     /* old version numbers, loaded below */

extern int  getpid();
extern long from_2_0_0_3(); 
extern long from_2_2_0_3(); 

   strcpy(version_numbers[0],"2.0.0.3");
   strcpy(version_numbers[1],"2.2.0.3");
  
   rewind(old);
   fgets(version,132,old);
   if (strlen(version)<131)
      strcpy(strchr(version,'\n'),"\0");
   else
      version[132]=0;
     

   this_version = -1;
   for (i=0;i<old_versions;i++)
       if (!strcmp(version,version_numbers[i])) {
          this_version = i;
          break;
          }

   switch (this_version) {
      case   -1          :return(1);

      case    0          :sprintf(fn,"/usr/tmp/CON%s.blk",getpid());
                          status=from_2_0_0_3(old,fn);
                          if (status) return (status);
                          fp=fopen(fn,"r");
                          if (!fp) return(1);
                          status=from_2_2_0_3(fp,new_name);
                          fclose(fp); unlink(fn);
                          return(status);

      case    1          :return(from_2_2_0_3(old,new_name));
      }

   return(1);
} /* end BLconvert_blk */


/******************************************************************************

Doc:    from_2_0_0_3

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLconvertblk.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function converts a .blk file from the version 2.0.0.3 format to
          the version 2.2.0.3 format.
        It expects a file pointer to old file and the name of the new file to 
           create.

Examples:
          status = from_2_0_0_3(old_file_ptr,
                                 new_file_name);

Return Status:
          0             -if new file was written
          1             -if error occurred.

History:
     09/03/91  wrw  -added standard header and converted externs to .h

******************************************************************************/
  

long from_2_0_0_3 (old,new_name) 
FILE *old;
char *new_name;
{
FILE *new;
char  work[133];
char  cat_name[50];
char  cats[MAX_CATS][MAX_ATTS][50];
char  data[MAX_ATTS][200];
char  past[MAX_ATTS][200];
char *colon;
char *comma;
char *tmp;
long   catno;
long   attno[MAX_CATS];
long   i,this;
long   write_new=0;
long   file_name,item_name,item_rev,acl_no;

   new = fopen(new_name,"w");
   if (!new)
      return (1);

   fprintf(new,"2.2.0.3\n");
   fprintf(new,"[:]\n");

/* read configuration section, and write back out. */
   catno = -1;
   while (fgets(work,132,old)) {

      if (!strcmp(work,"\f\n")) {
         break;
         }

      fprintf(new,"%s",work);

      if (!strncmp(work,"#",1))
         continue;

      if ((colon=strrchr(work,':'))==NULL) {
         if (catno==(MAX_CATS-1))
            return(1);
         tmp = work;
         if (!strncmp(work,"~",1))
            tmp++;
         strcpy(cats[++catno][0],tmp);
         attno[catno] = 0;
         }
      else {
         if (attno[catno]==(MAX_ATTS-1))
            return(1);
         for (i=0;i<4;i++) {
            strcpy(colon,"\0");
            if ((colon=strrchr(work,':'))==NULL)
               return(1);
            }
         strcpy(cats[catno][++attno[catno]],++colon);
         }
      } /* end of config section while */

   /* read in the data next */
   for (i=0;i<MAX_ATTS;i++)
      data[i][0] = 0;

   while (fgets(work,132,old)) {
      
      for (i=0;i<MAX_ATTS;i++) {
         strcpy(past[i],data[i]);
         data[i][0] = 0;
         }

      if (!strncmp(work,"#",1)) {
         fprintf(new,"%s",work);
         continue;
         }

      this = -1;
      tmp=work;
      if (!strncmp(work,"~",1))
         tmp++;
      if (strlen(work)<131) 
         strcpy(strchr(work,'\n'),"\0");
      else
         strcpy(&work[132],"\0");
      for (i=0;i<=catno;i++) {
         if (!strncmp(tmp,cats[i][0],strlen(tmp))) {
            this = i;
            break;
            }
         comma = cats[i][0];
         while ((comma=strchr(comma,','))!=NULL) {
            if (!strncmp(++comma,"~",1))
               comma++;
            if (!strncmp(tmp,comma,strlen(comma))) {
               this = i;
               break;
               }
            }
         if (this >= 0)
            break;
         }
      if (this < 0)
         return(1);

      strcpy(cat_name,tmp);
     
      item_name = item_rev = acl_no = file_name = -1;
      for (i=1;i<=attno[this];i++) {
         if ((fgets(data[i],132,old))==NULL)
            return(1);

         write_new = 1;
 
         if (strlen(data[i])<131) 
            strcpy(strchr(data[i],'\n'),"\0");
         else
            strcpy(&data[i][132],"\0");
 
         if (!strcmp(cats[this][i],P_ITEM_NAME)) {
            item_name = i;
            if (!strcmp(data[i],past[i]))
               write_new = 0;
            }
         else if (!strcmp(cats[this][i],P_ITEM_REV)) {
            item_rev = i;
            }
         else if (!strcmp(cats[this][i],P_CO_FILE)) {
            file_name = i;
            }
         else if (!strcmp(cats[this][i],P_ACL_NO)) {
            acl_no = i;
            }
         }
 
     if ((fgets(work,132,old)==NULL)||(strncmp(work,"$",1)))
        return(1);

     if (write_new) {
        fprintf(new,"%s\n",RECORD_DELIMIT);
        fprintf(new,"%s:%s\n",OP_CATALOG,cat_name);
        if (item_name>=0) {
           if (item_rev<0 || acl_no<0)
              return(1);
           fprintf(new,"%s:%s:%s:%s\n",OP_ADD,data[item_name],data[item_rev]
                                     ,data[acl_no]);
           if (file_name>=0 && strcmp(data[file_name],"\n"))
              fprintf(new,"%s\n",OP_CHECKIN);
           }
        else {
           fprintf(new,"%s\n",OP_RISINSERT);
           }
        fprintf(new,"%s\n",DIVISION_DELIMIT);
        if (file_name >= 0)
           fprintf(new,"%s:%s\n",cats[this][file_name],data[file_name]);
        }
     else {
        tmp = strrchr(data[file_name],'.');
        if ((tmp) && (!strcmp(tmp,".rt4"))) {
           tmp = strrchr(past[file_name],'.');
           if ((tmp) && (!strcmp(tmp,".tg4"))) 
              fprintf(new,"%c%s:%s\n",RR_KEY,cats[this][file_name]
                                     ,data[file_name]);
           else
              fprintf(new,"%s:%s\n",cats[this][file_name],data[file_name]);
           }
        else if ((tmp) && (!strcmp(tmp,".r29"))) {
           tmp = strrchr(past[file_name],'.');
           if ((tmp) && (!strcmp(tmp,".t29"))) 
              fprintf(new,"%c%s:%s\n",RR_KEY,cats[this][file_name]
                                     ,data[file_name]);
           else
              fprintf(new,"%s:%s\n",cats[this][file_name],data[file_name]);
           }
        else
           fprintf(new,"%s:%s\n",cats[this][file_name],data[file_name]);
        }

     for (i=1;i<=attno[this];i++) 
        if (i != file_name)
           fprintf(new,"%s:%s\n",cats[this][i],data[i]);
     }
      
   fclose(new);
   return(0);
} /* end from_2_0_0_3() */


/******************************************************************************

Doc:    from_2_2_0_3

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLconvertblk.c

Author: Rob Whitesell

Date:   February 1, 1992

Description:
        This function converts a .blk file from the version 2.2.0.3 format to
          the version 3.0.0.0 format.
        It expects a file pointer to old file and the name of the new file to 
           create.

Examples:
          status = from_2_2_0_3(old_file_ptr,
                                 new_file_name);

Return Status:
          0             -if new file was written
          1             -if error occurred.

History:
******************************************************************************/
  

long from_2_2_0_3 (old,new_name) 
FILE *old;
char *new_name;
{
FILE *new;
char  work[264];
char  delim;
char *dptr;
int   length,v_type;
char  attr[100],syn[100];

   new = fopen(new_name,"w");
   if (!new)
      return (1);

   fprintf(new,"3.0.0.0\n");

   fgets(work,132,old);
   fprintf(new,"%s",work);
   delim=work[1];

/* read configuration section, write out the add catalog section */
   while (fgets(work,264,old)) {
      if (!strcmp(work,"$\n")) {
         break;
         }
      if (!strncmp(work,"#",1))
         continue;

      if (work[0]=='~')
         memcpy(work,&work[1],strlen(work));

      dptr=strrchr(work,delim);
      if (!dptr) {
         fprintf(new,"%s",work);    /* catalog name */
         continue;
         }

      length=atoi(++dptr);
      *(--dptr)=0;
      if (!(dptr=strrchr(work,delim))) return(1);;
      v_type=atoi(++dptr);
      *(--dptr)=0;
      if (!(dptr=strrchr(work,delim))) return(1);;
      *dptr=0;
      if (!(dptr=strrchr(work,delim))) return(1);;
      strcpy(syn,++dptr);
      *(--dptr)=0;
      if (!(dptr=strrchr(work,delim))) return(1);;
      strcpy(attr,++dptr);

      sprintf(work,"%c%s%c%s%c",delim,attr,delim,syn,delim);
    
      switch (v_type) {
         case  0:   sprintf(attr,"char(%d)\n",length);
                    break;
         case  1:
         case  2:   sprintf(attr,"integer\n");
                    break;
         case  3:
         case  4:   sprintf(attr,"double\n");
                    break;
         }
      strcat(work,attr);
      fprintf(new,"%s",work);
      }

   fprintf(new,"$\n");

   /* the rest of the file did not change */
   while (fgets(work,264,old))
      fprintf(new,"%s",work);
      
   fclose(new);
   return(0);
} /* end from_2_2_0_3() */
