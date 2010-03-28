/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdvid_matrix

Description
   This function looks at a matrix and based upon its Z direction 
   determines if the matrix is one of the six principal matrices.

Arguments
   *msg     IGRlong     return code
   matrix   IGRmatrix   matrix
   string   IGRchar     string which contains matrix type

Return Values
   MSSUCC   -  if succesful
   MSFAIL   -  if failure

History
   Gray Winn      06/09/88    Creation Date
   SCW            07/08/92    ANSI conversion
\*/

#include "coimport.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "detaildef.h"

#define ONE          0x1
#define MINUS_ONE    0x2
#define MAETA        1.0e-15

#define RIGHT  ONE                  /*  1  0  0  */
#define LEFT   MINUS_ONE            /* -1  0  0  */
#define BACK   ONE << 2             /*  0  1  0  */
#define FRONT  MINUS_ONE << 2       /*  0 -1  0  */
#define TOP    ONE << 4             /*  0  0  1  */
#define BOTTOM MINUS_ONE << 4       /*  0  0 -1  */

IGRint GRdvid_matrix (msg, matrix, string, osnum)
IGRlong     *msg;
IGRmatrix   matrix;
IGRchar     string[];
OMuword     osnum;
{
IGRint      i,j,len,keys[7],ok;
IGRint      flag,found;
IGRpoint    xvector;
IGRpoint    yvector;
IGRpoint    zvector;
IGRpoint    m_xvector;
IGRpoint    m_yvector;
IGRpoint    m_zvector;
IGRmatrix   m_matrix;
struct var_list   var_list[2];
IGRlong           which_error;
IGRlong           nret;

   *msg = MSSUCC;

   keys[0] = GR_I_Top;
   keys[1] = GR_I_Front;
   keys[2] = GR_I_Left;
   keys[3] = GR_I_Right;
   keys[4] = GR_I_Bottom;
   keys[5] = GR_I_Back;
   keys[6] = GR_I_Iso;

   /*
    *  Unitize the vector z vector.
    */
   MAunitvc(msg, &matrix[8], zvector);

   found = FALSE;
   flag = 0;
   for (i=0; i < 3;  ++i)
   {
      if ((zvector[i] < (1.0  + MAETA)) &&
          (zvector[i] > (1.0  - MAETA)))
      {
         flag |= ONE << i*2;
      }else if ((zvector[i] > (-1.0 - MAETA)) &&
                (zvector[i] < (-1.0 + MAETA)))
      {
         flag |= MINUS_ONE << i*2;
      }else if ((zvector[i] > MAETA) ||
                (zvector[i] < - MAETA))
      {
	 flag = GR_DV_ISO;
         break;
      }
   }

   if ( osnum )
   {
      /*
       * If there are any principle saved views in osnum
       * which match the rotation matrix use that name instead
       * of the default name.
       */
      for (i=0; i<7; i++)
      {
         ex$message(msgnumb = keys[i], buff = string);

         var_list[0].var = VIEW_ROTATION;
         var_list[0].var_ptr = (IGRchar *)m_matrix;
         var_list[0].num_bytes = sizeof(IGRdouble) * 16;
         var_list[0].bytes_returned = &nret;
         var_list[1].var = END_PARAM;

         ok = dp$inq_set_saved_view ( msg = msg,
                                      osnum = osnum,
                                      vw_name = string,
                                      which_error = &which_error,
                                      var_list = var_list );
         if ( !(ok&*msg&1) )
         {
            len = strlen(string);
            for ( j = 0; j < len; ++j )
            {
               string[j] = tolower(string[j]);
            }

            ok = dp$inq_set_saved_view ( msg = msg,
                                         osnum = osnum,
                                         vw_name = string,
                                         which_error = &which_error,
                                         var_list = var_list );
            if ( !(ok&*msg&1) )
            {
               for ( j = 0; j < len; ++j )
               {
                  string[j] = toupper(string[j]);
               }

               ok = dp$inq_set_saved_view ( msg = msg,
                                            osnum = osnum,
                                            vw_name = string,
                                            which_error = &which_error,
                                            var_list = var_list );
            }
         }

         if (ok&*msg&1)
         {

            MAunitvc(msg, &m_matrix[8], m_zvector);
            if ((m_zvector[0] < (zvector[0] + MAETA)) &&
                (m_zvector[0] > (zvector[0] - MAETA)) &&
                (m_zvector[1] < (zvector[1] + MAETA)) &&
                (m_zvector[1] > (zvector[1] - MAETA)) &&
                (m_zvector[2] < (zvector[2] + MAETA)) &&
                (m_zvector[2] > (zvector[2] - MAETA)) )
            {
               MAunitvc(msg, &matrix[0], xvector);
               MAunitvc(msg, &m_matrix[0], m_xvector);
      
               if ((m_xvector[0] < (xvector[0] + MAETA)) &&
                   (m_xvector[0] > (xvector[0] - MAETA)) &&
                   (m_xvector[1] < (xvector[1] + MAETA)) &&
                   (m_xvector[1] > (xvector[1] - MAETA)) &&
                   (m_xvector[2] < (xvector[2] + MAETA)) &&
                   (m_xvector[2] > (xvector[2] - MAETA)) )
               {
                  MAunitvc(msg, &m_matrix[4], m_yvector);
                  MAunitvc(msg, &matrix[4], yvector);
      
                  if ((m_yvector[0] < (yvector[0] + MAETA)) &&
                      (m_yvector[0] > (yvector[0] - MAETA)) &&
                      (m_yvector[1] < (yvector[1] + MAETA)) &&
                      (m_yvector[1] > (yvector[1] - MAETA)) &&
                      (m_yvector[2] < (yvector[2] + MAETA)) &&
                      (m_yvector[2] > (yvector[2] - MAETA)) )
                  {
                     found = TRUE;
                     break;
                  }
               }
            }
         }
      }
   }

   /*
    * If none of osnum's principle saved view rotations matched
    * the view's rotation use the default name for the view.
    */
   if ( !found || !osnum ) 
   {
      switch (flag)
      {
         case TOP:
            i = 0;
            break;

         case FRONT:
            i = 1;
            break;

         case LEFT:
            i = 2;
            break;

         case RIGHT:
            i = 3;
            break;

         case BOTTOM:
            i = 4;
            break;

         case BACK:
            i = 5;
            break;

         case GR_DV_ISO:
            i = 6;
            break;

         default:
            return(0); 
      }

   }

   ex$message(msgnumb = keys[i], buff = string);

   return(1);
}
