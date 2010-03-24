
#include  <stdio.h>
#include  <string.h>
#include  <sys/types.h>
#include  <sys/stat.h>

#include  "OMminimum.h"
#include  "igetypedef.h"
#include  "wl.h"
#include  "exsysdep.h"
#include  "igrtypedef.h"
#include  "OMmacros.h"
#include  "exmacros.h"
#include  "OMprimitives.h"
#include  "OMspecify.h"
#include  "OMparameters.h"
#include  "msdef.h"
#include  "igecolor.h"
#include  "igecolordef.h"
#include  "igecolmacros.h"
#include  "igewinmacros.h"

/* include this file when a prototype naming convention is arrived at */
/*#include  "DPcolors.h" -> prototype for creation file */


#define   IGENOT_ENOUGH_MEM   2

IGRint DPchek_clr_tbl(IGRchar  file_nme[])
{
   FILE   *fp1;

   IGRchar   path[80];
   IGRint   status;
   IGRint   pathno;
   struct stat buf;
   int     st;

   fp1 = NULL;
   if(!(fp1 = fopen(file_nme,"r")))
   {
      status = TRUE;
      for(pathno = 0; (status); pathno++)
      {
         if(status = ex$get_path(index = pathno,path=path,len=80))
         {
            strcat(path,"config/"); 
            strcat(path,file_nme); 
            if((fp1 = fopen(path,"r")))
            {
               break;
            }
         }
      }
      st = stat(path,&buf);
   }
   else
   {
      st = stat(file_nme,&buf);
   }

   /*Checking to see if the specified file is a directory */
   if (S_ISDIR(buf.st_mode))
   {
   	return(0);
   }
   if(!fp1)
   {
#ifdef DEBUG_CL
      printf("\n Error opening the file ..DPload_clr_tbl ");
#endif
      return(0);
   }
   else
   {
      fclose(fp1);
      return(1);   
   }
}

IGRint DPload_clr_tbl(
   IGRchar  file_nme[],
   IGRint   *file_type)
{
   IGRint     status = TRUE;
   IGRint    bg_color;
   IGRint    fg_color;
   IGRint    hl_color;
   IGRshort  no_clrs;
   IGRshort  no_names;

   IGRint  colors[DEFAULT_NUM_BG_LOG_HL];
   IGRint  *clrs_ptr;
   IGRint  mem_malloced = FALSE;
   IGRint  nam_malloced = FALSE;
   IGRint  msg;

   struct  IGEcol_names  names[DEFAULT_NUM_BG_LOG_HL],*name_ptr;

   no_clrs = DEFAULT_NUM_BG_LOG_HL;
   no_names = DEFAULT_NUM_BG_LOG_HL;

   clrs_ptr = colors;
   name_ptr = names;
   
   status = DPret_clr_tbl(&msg,file_nme,file_type,&bg_color,&fg_color,&hl_color,
         &no_clrs,clrs_ptr,&no_names,name_ptr);

   if (!(1 & status))
   {
      if (msg != IGENOT_ENOUGH_MEM)
      {
         goto quit1;
      }
      
      if (no_clrs > DEFAULT_NUM_BG_LOG_HL)
      {
         if(!(clrs_ptr = (IGRint *) om$malloc(size=no_clrs * sizeof(IGRint))))
         {
#ifdef DEBUG_CL
            printf("\n Error in DPload_clr_tbl .. Can't allocate memory");
#endif
            status = FALSE;
            goto quit1;
         }
         mem_malloced = TRUE;
      }
      else
      {
         clrs_ptr = colors;
      }
      
      if (no_names > DEFAULT_NUM_BG_LOG_HL)
      {
         if(!(name_ptr = (struct IGEcol_names *) om$malloc(size=no_names * sizeof(struct IGEcol_names))))
         {
#ifdef DEBUG_CL
            printf("\n Error in DPload_clr_tbl .. Can't allocate memory");
#endif
            status = FALSE;
            goto quit1;
         }
         nam_malloced = TRUE;
      }
      else
      {
         name_ptr = names;
      }

      status = DPret_clr_tbl(&msg,file_nme,file_type,&bg_color,&fg_color,&hl_color,
         &no_clrs,clrs_ptr,&no_names,name_ptr);

   }

   /* Load the Color Table Info    */

   if(!ige$change_color_table(num_colors = no_clrs, flags = PACKED_COLORS, colors = clrs_ptr))
   {
#ifdef DEBUG_CL
      printf("\n Error in ige$change_color_table .. DPload_clr_tbl ");
#endif
      status = FALSE;
      goto quit1;
   }

   if (!ige$change_reserved_colors(fgcolor = &fg_color,
      flags = PACKED_COLORS, bgcolor = &bg_color, hilite_color = &hl_color))
   {
#ifdef DEBUG_CL
      printf("\n Error in ige$change_reserved_colors .. DPload_clr_tbl");
#endif
      status = FALSE;
      goto quit1;
   }

   if(!ige$change_color_names(num_names = no_names, names = name_ptr))
   {
#ifdef DEBUG_CL
      printf("\n Error in ige$change_color_names .. DPload_clr_tbl");
#endif
      status = FALSE;
      goto quit1;
   }

   quit1:
   if (mem_malloced)
   {
      om$dealloc(ptr=clrs_ptr);
   }

   if (nam_malloced)
   {
      om$dealloc(ptr=name_ptr);
   }
      
   return(status);

}

/* DPsave_clr_tbl -

   fwrite calls have been modified to DPcnv_write  for
   sun, as color table files needs to saved in clipper
   format.
*/
IGRint DPsave_clr_tbl(
   char      file_nme[])
{
   FILE   *fp1;

   IGRint     version;
   IGRint     bg_clr;
   IGRint     fg_clr;
   IGRint     hl_clr;
   IGRshort   no_clrs;
   IGRshort   no_nms;
   IGRint     i,j,new_str;

   IGRint   colors[DEFAULT_NUM_BG_LOG_HL];
   IGRint   *clrs_ptr;
   IGRint   size_str;

   struct IGEcol_names  names[DEFAULT_NUM_BG_LOG_HL];
   struct IGEcol_names  *names_ptr;

   IGRint mem_alloc_for_names, mem_alloc_for_clrs;

   mem_alloc_for_clrs = FALSE;
   mem_alloc_for_names = FALSE;

   /*  inquire color table info    */   

   if (!ige$read_reserved_colors(bgcolor = &bg_clr, fgcolor = &fg_clr,
      hilite_color = &hl_clr, flags = PACKED_COLORS))
   {
#ifdef DEBUG_CL
      printf("\n Error in ige$read_reserved_colors1 .. DPsave_clr_tbl");
#endif
      goto quit1;
   }
   
   no_clrs = DEFAULT_NUM_BG_LOG_HL;

   clrs_ptr=colors;
   size_str = sizeof(IGRint);

   if (!ige$read_color_table(num_colors = &no_clrs, flags = PACKED_COLORS, colors = clrs_ptr))
   {
      /* returns unsuccessful if no_clrs not large enough and returns number of
         colors in no_clrs */
      size_str = size_str * no_clrs;

      if(!(clrs_ptr = (IGRint *) om$malloc(size=size_str)))
      {
#ifdef DEBUG_CL
         printf("\n Error in DPsave_clr_tbl .. Can't allocate memory");
#endif
         goto quit1;
      }
      mem_alloc_for_clrs = TRUE;
      if (!ige$read_color_table(num_colors = &no_clrs, flags = PACKED_COLORS, colors = clrs_ptr))
      {
#ifdef DEBUG_CL
         printf("\n Error in ige$read_colors_table1 .. DPsave_clr_tbl");
#endif
         goto quit1;
      }
   }

   no_nms = DEFAULT_NUM_BG_LOG_HL;
   names_ptr = names;

   if(!ige$read_color_names(num_names = &no_nms, names = names_ptr))
   {
      size_str = sizeof(struct IGEcol_names)*no_nms;

      if(!(names_ptr = (struct IGEcol_names *) om$malloc(size=size_str))) 
      {
#ifdef DEBUG_CL
         printf("\n Error in DPsave_clr_tbl .. Can't allocate memory");
#endif
         goto quit1;
      }
      mem_alloc_for_names = TRUE;
      if (!ige$read_color_names(num_names = &no_nms, names = names_ptr))
      {
#ifdef DEBUG_CL
         printf("\n Error in ige$read_color_names .. DPsave_clr_tbl");
#endif
         goto quit1;
      }
   }
   fp1 = NULL;
   fp1 = fopen(file_nme,"w");
   if(!fp1)     
   {
#ifdef DEBUG_CL
      printf("\n Error opening the specified file");
#endif
      goto quit1;
   }
   
   /* write the color information in the specified file  */
   
   version = 1;
   size_str = sizeof(IGRint);
   DPconv_write((char *)&version,size_str,1,fp1);
   DPconv_write((char *)&bg_clr,size_str,1,fp1);
   DPconv_write((char *)&fg_clr,size_str,1,fp1);
   DPconv_write((char *)&hl_clr,size_str,1,fp1);
   DPconv_write((char *)&no_clrs,sizeof(IGRshort),1,fp1);
   
   DPconv_write((char *)clrs_ptr,size_str,no_clrs,fp1);
        
   /* write the names with only one '/0' at the end of the each name  */

   for(i=0;i<no_nms;i++)
   {
      j = 0;
      new_str = TRUE;
      while(new_str)
      {
         if(names_ptr->name[j] != '\0')
         {
            putc(names_ptr->name[j],fp1);
         }
         else 
         {
            if(names_ptr->name[j] == '\0')
            {
               putc(names_ptr->name[j],fp1);
               DPconv_write((char *)&names_ptr->index,sizeof(IGRshort),1,fp1);
               names_ptr++;
               new_str = FALSE;
            }
         }
         j++;
      }
   }
   fclose(fp1);

   if(mem_alloc_for_clrs)
   {
      om$dealloc(ptr=clrs_ptr);
   }

   if(mem_alloc_for_names)
   {
      om$dealloc(ptr=names_ptr);
   }
   return(1);

quit1:
   return(0);
}

/* DPret_clr_tbl - 

   Calls to fread have been replaced by DPconv_read for
   sun , as color table files are going to be delivered in 
   clipper format.
*/

IGRint DPret_clr_tbl(
   IGRint   *msg,
   IGRchar  file_nme[],
   IGRint   *file_type,
   IGRint    *bg_color,
   IGRint    *fg_color,
   IGRint   *hl_color,
   IGRshort *num_colors,
   IGRint    *colors,
   IGRshort *num_names,
   struct  IGEcol_names  *names)
{
   FILE   *fp1;

   IGRchar   path[80];
   IGRchar   t_char;

   IGRint   tmp_int;
   IGRint   pathno;
   IGRint     sts = TRUE;
   IGRint     status = TRUE;
   IGRint    version;

   IGRint  i,end_of_file;
   IGRint  size_str;
   IGRshort no_clrs;
   IGRshort no_names;
   struct  IGEcol_names  temp_name,*name_ptr;
   struct  IGEvlt   tmp_col;

   struct  vlt_entry1
   {
      IGRuchar   red, green, blue;
   }  vlt1;

   *msg = 1;
   fp1 = NULL;
   if (!(fp1 = fopen(file_nme,"r")))
   {
      for(pathno = 0; (sts) ; pathno++)
      {
         if (sts = ex$get_path(index = pathno,path=path,len=80))
         {
            strcat(path,"config/"); 
            strcat(path,file_nme); 
            if((fp1 = fopen(path,"r")))
            {
               break;
            }
         }
      }
   }
   if(!fp1)
   {
#ifdef DEBUG_CL
      printf("\n Error openinig the file ..DPload_clr_tbl ");
#endif
      status = FALSE;
      *msg = MSFAIL;
      goto quit1;
   }

   size_str = sizeof(IGRint);

   switch(*file_type)
   {
      case IGE_COLORS:

         DPconv_read((char *)&version,size_str,1,fp1);
         if (version != 1)
         {
            status = FALSE;
            *msg = MSFAIL;
            break;
         }
         DPconv_read((char *)bg_color,size_str,1,fp1);
         DPconv_read((char *)fg_color,size_str,1,fp1);
         DPconv_read((char *)hl_color,size_str,1,fp1);
         DPconv_read((char *)&no_clrs,sizeof(IGRshort),1,fp1);

         if (no_clrs > *num_colors)
         {
            *num_colors = no_clrs;
            *msg = IGENOT_ENOUGH_MEM;
            status = FALSE;
#if defined ( DEBUG_CL )
            printf("DPret_clr_tbl: no_clrs in file %d > num_colors allocated %d\n",no_clrs,*num_colors);
#endif
            for (i=0; i< no_clrs; i++)
            {
               DPconv_read((char *)&tmp_int,size_str,1,fp1);
            }
         }
         else
         {
            *num_colors = no_clrs;
            DPconv_read((char *)colors,size_str,no_clrs,fp1);
         }
         
   
         i = 0;
         no_names = 0;
         name_ptr = names;
         end_of_file = FALSE;
      
         while (!end_of_file)
         {
            t_char = getc(fp1);
            if (t_char != '\0' && t_char != EOF)
            {
               name_ptr->name[i++]=t_char;
            }
            else 
            {
               if ((t_char == '\0') || (i == 23))
               {
                  name_ptr->name[i]='\0';
                  DPconv_read((char *)&name_ptr->index,sizeof(IGRshort),1,fp1);
                  i = 0;
      
                  no_names++;
                  if (no_names >= *num_names)
                  {
                     name_ptr = &temp_name;
                  }
                  else
                  {
                     name_ptr++;
                  }
               }
               else 
               {
                  if (t_char == EOF)
                  {
                     end_of_file = TRUE;
                  }
               }
            }
         }
      
         if (no_names > *num_names)
         {
            *msg = IGENOT_ENOUGH_MEM;
            status = FALSE;
         }
      
         *num_names = no_names;
      
         break;
      
      case  IGDS_COLORS  :
         
         no_clrs = 0; 
      
         while( no_clrs < 256 && fread(&vlt1,sizeof(vlt1),1,fp1))
         {
            tmp_col.red = vlt1.red << 8;
            tmp_col.green = vlt1.green << 8;
            tmp_col.blue = vlt1.blue << 8;
            if (no_clrs != 0)
            {
               colors[no_clrs - 1] = CLpack_colors(tmp_col.red,tmp_col.green,tmp_col.blue);
            }
            else
            {
               *bg_color = CLpack_colors(tmp_col.red,tmp_col.green,tmp_col.blue);
            }
            no_clrs++;
         }
      
         *hl_color = colors[no_clrs - 2];
         *fg_color = colors[no_clrs - 2];
      
         *num_colors = no_clrs - 1;
         *num_names = 0;
         break;
      
      default :
      
         break;
   }  /* end of switch  */
      
      
quit1:
   if(fp1)
   {
      fclose(fp1);
   }
            
   return(status);
}

void DPcnv_short(char *s)
{
   char t;

   t = s[0];
   s[0] = s[1];
   s[1] = t;
}

void DPcnv_int(char *s)
{
   char t[2];

   t[0] = s[2];
   t[1] = s[3];
   s[2] = s[1];
   s[3] = s[0];
   s[0] = t[1];
   s[1] = t[0];
}

/* DPconv_read - 
   Function to convert the int/shorts to  clipper format
   before fwrite
*/
DPconv_read(
   char *s,
   int n,
   int l,
   FILE *fp1)
{
#ifdef BIG_ENDIAN
   int i;
#endif

   fread(s,n,l,fp1);

#ifdef BIG_ENDIAN
   for( i = 0; i < l ; i++)
   {
      if (n == sizeof(int)) 
      {
         DPcnv_int(s);
      }
      else 
      {
         if (n == sizeof(IGRshort)) 
         {
            DPcnv_short(s);
         }
      }
      s+=n;
   }
#endif
}

/* DPconv_write - 
   Function to convert the int/shorts to  clipper format
   before fwrite
*/
DPconv_write(
   char *s,
   int n,
   int l,
   FILE *fp1)
{
#ifdef BIG_ENDIAN
   int i;
   char *p;
   int a;
   short b;

   p =s;
   for( i = 0; i < l ; i++)
   {
      if (n == sizeof(int))
      {
         memcpy(&a,p,n);
         DPcnv_int((char *)&a);
         fwrite(&a,n,1,fp1);
      }
      else 
      {
         if (n == sizeof(IGRshort)) 
         {
            memcpy(&b,p,n);
            DPcnv_short((char *)&b);
            fwrite(&b,n,1,fp1);
         }
      }
      p+=n;
   }
#else
   fwrite(s,n,l,fp1);
#endif

}
