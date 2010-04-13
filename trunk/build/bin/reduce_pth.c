#include <string.h>

#define SEPARATOR_C	'/'
#define SEPARATOR_S	"/"

static struct
{
   char n[64];
} fnames[32];

static void unpack (p)
char *p;
{
   int i;      /* fnames index */
   int j;      /* n index */
 
   for (i=0; i<32; i++) fnames[i].n[0]=0;

   if (!p) return;
   if (!(*p)) return;

   i = 0;
   j = 0;
   if ((*p) == SEPARATOR_C)
   {
      fnames[0].n[0] = SEPARATOR_C;
      fnames[0].n[j+1] = 0;
      i = 1;
      j = 0;
      p++;
   }
   while (*p)
   {
      if ((*p) == SEPARATOR_C)
      {
         fnames[i].n[j] = 0;
         i++;
         j = 0;
      }
      else
      {
         fnames[i].n[j] = *p;
         j++;
      }
      p++;
   }
   fnames[i].n[j] = 0;
}


static int previous (i)
int i;
{
   int j;

   j = i-1;
   while (1)
   {
      if (j == -1) return (j);
      if (fnames[j].n[0] != 0) return (j);
      j--;
   }
}


static void reduce ()
{
   int i;
   int j;

   i = 0;
   while (i < 32)
   {
      if (!strcmp(fnames[i].n,".."))
      {
         j = previous (i);
         if (j != -1)
         {
            if (!strcmp(fnames[j].n,".."))
            {
            }
            else if (!strcmp(fnames[j].n,"."))
            {
               fnames[j].n[0] = 0;
            }
            else
            {
               fnames[i].n[0] = 0;
               fnames[j].n[0] = 0;
            }
         }
      }
      else if (!strcmp(fnames[i].n,"."))
      {
/*
      j = previous (i);
      if (j != -1)
*/
         fnames[i].n[0] = 0;
      }
      i++;
   }
}


static void pack (p)
char *p;
{
   int i;

   if (!strcmp(fnames[0].n,SEPARATOR_S))
   {
      strcpy (p,SEPARATOR_S);
      i = 1;
   }
   else
   {
      *p = 0;
      i = 0;
   }
   while (i<32)
   {
      if (fnames[i].n[0] != 0)
      {
         strcat (p,fnames[i].n);
         break;
      }
      i++;
   }
   i++;
   while (i<32)
   {
      if (fnames[i].n[0] != 0)
      {
         strcat (p,SEPARATOR_S);
         strcat (p,fnames[i].n);
      }
      i++;
   }
}


void reduce_pth (p)
char *p;
{
   unpack (p);
   reduce ();
   pack (p);
}
