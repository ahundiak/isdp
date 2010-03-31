#include "odi.h"
#include <stdio.h>
#include "HPdef.h"

static struct soo_info
   {
   double parms[2];
   unsigned short color;
   unsigned char style;
   unsigned char weight;
   unsigned short type;
   }        soo;


#define if_token(x) if (!strcmp (tok_str, x))

/*---get_soos------------------------------------------------------*/

int get_soos (uint32 * num_points,
                  int *token,
                  char *tok_str,
                  FILE * src_file,
                  FILE * out_file,
                  int *line,
                  int end_token)

   {
   int status;  /* return code from called functions */
   double buffer[6];

   while (*token != end_token && *token != EOF)
      {

      /* ignore word "soo" */

      if_token ("soo")
         {
         }

      /* stop if some other word */

      else if (*token == 'w')
         break;

      /* better be a 4d point, count/write them */

      else
         {
         status = get_doubles (6,
                               buffer,
                               token,
                               tok_str,
                               src_file,
                               NULL,
                               line);

         if (status)
            return HSplot_error;

         if (out_file != NULL)
            {
            soo.parms[0] = buffer[0];
            soo.parms[1] = buffer[1];
            soo.color = (unsigned short) buffer[2];
            soo.style = (unsigned char) buffer[3];
            soo.weight = (unsigned char) buffer[4];
            soo.type = (unsigned short) buffer[5];

            fwrite (&soo.parms[0], sizeof (double), 1, out_file);
            fwrite (&soo.parms[1], sizeof (double), 1, out_file);
            fwrite (&soo.color, sizeof (unsigned short), 1, out_file);
            fwrite (&soo.style, sizeof (unsigned char), 1, out_file);
            fwrite (&soo.weight, sizeof (unsigned char), 1, out_file);
            fwrite (&soo.type, sizeof (unsigned short), 1, out_file);
            }

         if (num_points)
            ++* num_points;
         }

      *token = get_token (tok_str, src_file, line);
      }

   return HSplot_success;
   }
