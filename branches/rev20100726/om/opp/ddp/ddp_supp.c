/*
------------------------------------------------------------------------------

	Name:			ddp_supp.c
	Author:			R. Eade
	Creation Date:		December, 1987
	Abstract:
			Support routines to manage the class information.

	Revision History:


------------------------------------------------------------------------------
*/
#include <stdio.h>
#include <sys/types.h> 
#include <dirent.h>
  
#include "ddp_info.h"
#include "ddp_error.h"
#include "ddp_defns.h"

/*-----------------------------------------------------------------------------
   DDP_free_version_list

   Used to free the memory allocated by DDP_get_class_version_list
-----------------------------------------------------------------------------*/
void DDP_free_version_list(pp_list)
struct class_info **pp_list;
{
   struct class_info *tmp;

   if (!pp_list)
      return;

   tmp = *pp_list;
   while(tmp)
   {
      *pp_list = (*pp_list)->next;
      free(tmp);
      tmp = *pp_list;
   }
 
   *pp_list = 0;
}



/*-----------------------------------------------------------------------------
   DDP_get_class_version_list

   Searches the specified directory for a "version file" for this class.
   Returns a pointer to a linked list containing all the version information
   for this class.  The first entry in this list is the "latest version" of
   this class.  
-----------------------------------------------------------------------------*/
struct class_info *DDP_get_class_version_list(classname, dirname)
char              *classname;
char              *dirname;
{
   char *vfilename;
   FILE *fptr;
   struct class_info *p_list;

   /* create the version filename */

   vfilename = (char *)malloc(strlen(dirname)+strlen(classname)+3+1);
   strcpy(vfilename, dirname);
   strcat(vfilename, "/v.");
   strcat(vfilename, classname);

   /* attempt to read the file and build version list */
           
   p_list = 0;

   if (NULL != (fptr = (FILE *)fopen(vfilename,"r")))
   {
      int                num; /* number of items read from the version file */
      struct class_info *p_class_info;
      struct class_info  tmp_class_info;

      while ( (EOF != (num = fscanf(fptr,"%d %hd %hd %hd %s",
                                 &(tmp_class_info.instance_size),
                                 &(tmp_class_info.major_version_num),
                                 &(tmp_class_info.minor_version_num),
                                 &(tmp_class_info.dynamic_flag),
                                 tmp_class_info.sequence_num)))
                           &&
               (5 == num) )
      {
         p_class_info = (struct class_info *)
                           calloc(1,sizeof(struct class_info));
         *p_class_info = tmp_class_info;

         p_class_info->next = p_list;
         p_list = p_class_info;

      }/* while more versions of this class */

      /* free the list if an error occurred */

      if ( (EOF != num) &&  (p_list) )
      {
         DDP_free_version_list(&p_list);
         error(FATAL, "invalid version file \"%s\"\n",vfilename);
      }
      fclose(fptr);
   }/* if file was opened */

   free(vfilename);
   return (p_list);
}

/*--------------------------------------------------------------------------
   reverse_version_list

   Reverses the order of the links in a version list.  This list is
   expected to be in the form returned by DDP_get_version_list.
---------------------------------------------------------------------------*/
static struct class_info *reverse_version_list(p_list)
struct class_info *p_list;
{
   struct class_info *p_new_list;

   p_new_list = 0;

   while (p_list)
   {
      struct class_info *p_tmp = p_list->next;
      p_list->next = p_new_list;
      p_new_list = p_list;
      p_list = p_tmp;
   }
  
   return p_new_list;
} 

/*-----------------------------------------------------------------------------
   DDP_write_class_version_list

   Writes the version file for the specified class.
-----------------------------------------------------------------------------*/
void DDP_write_class_version_list(classname, dirname, p_version_list)
char              *classname;
char              *dirname;
struct class_info *p_version_list;
{
   char *vfilename;
   FILE *fptr;

   /* create the version filename */

   vfilename = (char *)malloc(strlen(dirname)+strlen(classname)+3+1);
   strcpy(vfilename, dirname);
   strcat(vfilename, "/v.");
   strcat(vfilename, classname);

   /*  write the version list to the file.  The list is currently in  */
   /*  reverse order.                                                 */
           
   p_version_list = reverse_version_list(p_version_list);

   if (NULL != (fptr = (FILE *)fopen(vfilename,"w")))
   {
      while (p_version_list)
      {
         fprintf(fptr,"%d %d %d %d %s\n",
                 p_version_list->instance_size,
                 p_version_list->major_version_num,
                 p_version_list->minor_version_num,
                 p_version_list->dynamic_flag,
                 p_version_list->sequence_num);

         p_version_list = p_version_list->next;
      }/* while more versions of this class */

      fclose(fptr);
   }/* if file was opened */
   else
      error(FATAL, "unable to create a file in %s\n",dirname);

   free(vfilename);
   return;
}

/*----------------------------------------------------------------------------
   DDP_get_next_sequence_num

   Given a base 64 ascii string, it will increment and return the value.
   The digits used for the base 64 string are ., _, 0-9, A-Z and a-z .
   NOTE: In the UNIX utilities for managing base 64 numbers, the / is
   used as digit.  Since this sequence number will be used as part of
   a filename, the / has been replaced by an _.
-----------------------------------------------------------------------------*/
int DDP_get_next_sequence_num(p_old, p_new)
char *p_old;	/* pointer to the starting number */
char *p_new;	/* place to put the result.  should have room for
                   3 characters. */
{
   char tmp[3];
   long ii;

   long a64l();
   char *l64a();

   /*--------------------------------------------------------------------*/
   /*  make a copy of the original string changing all underscores to    */
   /*  slashes.  This makes the string compatable with the UNIX base 64  */
   /*  routines.                                                         */
   /*--------------------------------------------------------------------*/

   for (ii=0; ii <= strlen(p_old); ++ii)
      tmp[ii] = ((p_old[ii] == '_')?'/':p_old[ii]);

   /*----------------------------------------------------------------*/
   /*  Convert the string to numeric form, increment it and convert  */
   /*  it back to base 64 changing all slashes to underscores.       */
   /*----------------------------------------------------------------*/

   ii = a64l(tmp);

   if (++ii > MAX_NUM_VERSIONS)
      return (0);

   p_old = l64a(ii);

   for (ii=0; ii <= strlen(p_old); ++ii)
      p_new[ii] = ((p_old[ii] == '/')?'_':p_old[ii]);

   return (1);
}

/*----------------------------------------------------------------------------
   DDP_list_classes

   Prints a list of all classes that are represented in the specified
   directory.
----------------------------------------------------------------------------*/
void DDP_list_classes(dirname)
char *dirname;
{
   DIR  *p_dirfile;
   
   if (NULL != (p_dirfile = opendir(dirname)))
   {
      struct dirent *p_dirent;
      int first = 1;

      while (NULL != (p_dirent = readdir(p_dirfile)))
      {
         if (! strncmp(p_dirent->d_name,"v.",2))
         {
            struct class_info *p_list, *tmp;

            p_list = DDP_get_class_version_list(&p_dirent->d_name[2], dirname);

            if (p_list)
            {
               if (first)
               {
                  error(INFO, "\tClass versions in '%s':\n",dirname);
                  first = 0;
               }

               error(INFO,"\t\tclass %s",&p_dirent->d_name[2]);
               for (tmp=p_list; tmp; tmp=tmp->next)
               {
                  error(INFO,", (%d:%d)", p_list->major_version_num,
                                          p_list->minor_version_num);
               }

               error(INFO,"\n");
               DDP_free_version_list(&p_list);

            }/* if able to read the version file */
         }/* if this is a version filename */
      }/* while more entries in this directory */

      if (first)
         error(WARNING,"no classes found in '%s'\n",dirname);

      closedir(p_dirfile);

   }/* if directory file was opened */
   else
      error(FATAL,"cannot open directory '%s'\n",dirname);

   return;
}
