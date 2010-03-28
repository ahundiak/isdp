/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     GRmodule          GRmodule class
        METHOD NAME:    GRadd_fnt_tbl   Add new font table for new OS

        Abstract: This method will call the non-object side to create
                  a font table for a particular OS and will put the 
                  fast font into the table.

-----
%SC%

        value = GRadd_fnt_tbl (msg,fst_char_fnt,fst_frac_fnt,fst_16bit_fnt)


-----
%EN%

        ON ENTRY:

        NAME            DATA TYPE               DESCRIPTION
       ------           -----------             ----------------------------
       fst_char_fnt     IGRshort                the virtual font number of
                                                the fast character font

       fst_frac_fnt     IGRshort                the virtual font number of
                                                the fast fraction font

       fst_16bit_fnt    IGRshort                the virtual font number of
                                                the fast 16-bit font
       
-----
%EX%

        ON EXIT:

        NAME    DATA TYPE       DESCRIPTION
       ------  -----------    ----------------------------
       *msg     IGRlong         return status
                                  MSSUCC - successfully completed
                                  MSFAIL - unsuccessfully completed


-----
%MD%

        MODULES AND METHODS INVOKED:

          Methods:

             none

          Modules:

             DPcreate_fnt_tbl   - Create font table for new OS
             DPchg_fst_fnt      - Change fast font numbers


-----
%RL%

        RELATIONS REFERENCED:

           none

-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

        AET  01/30/86   : Design date.
	AET  12/11/87	: Changed to correspond to new font structure
			  using the font server
	AET  06/20/88	: Changed to include fast 16-bit font

-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
 --------------------------------------------------------------------
        
        This method calls a non-object routine to create a font
        table for a particulare object space.  The fast font is then
        added to the font table. 
        
----*/
/*EH*/

   

        class implementation GRmodule;

#include "dpfont.h"
#include "dpdef.h"

#include "dpcrefntbl.h"
#include "dpchgfstfnt.h"

%safe


static struct DPfnt_os_tbl *fnt_os_tbl_ptr = 0;
%endsafe

struct dpset_struct
{
  IGRlong   *msg;
  IGRlong   *which_error;
  struct  var_list   *wn_font_ptr;
};

from IGEwindow import passon;

            method GRadd_fnt_tbl (IGRlong *msg;  IGRshort fst_char_fnt;
				  IGRshort fst_frac_fnt; 
				  IGRshort fst_16bit_fnt)


        {

  struct  var_list   wn_font_ptr[2];
          IGRlong which_error;
          IGRlong bytes_returned;
          IGRint sts;
          IGRint i;
          struct dpset_struct set_struct;
          OM_S_MESSAGE          msg_struct;
          OM_S_CHANSELECT    chandef;
        
          *msg = MSSUCC;





  /* if memory for the font table has not been allocated, allocte it  */

          if (!fnt_os_tbl_ptr)
          {
             ME.GRmodule->fnt_os_tbl_ptr = (struct DPfnt_os_tbl *) 
                   om$sm_malloc(size = sizeof(struct DPfnt_os_tbl));



	     fnt_os_tbl_ptr = ME.GRmodule->fnt_os_tbl_ptr;


             if (!ME.GRmodule->fnt_os_tbl_ptr)
             {
#ifdef DEBUG
                printf("\nERROR: no virtual memory to allocate ");
                printf("font OS table\n");
#endif
                *msg = MSFAIL;
                goto wrapup;
             }
             else 
             {

        /* initialize object space numbers to -1     */

                for (i=0; i < 33; i++)
                {
                   ME.GRmodule->fnt_os_tbl_ptr->fnt_os_tbl[i].os_num = -1;
                }

                ME.GRmodule->fnt_os_tbl_ptr->next = NULL;
             }
          }

	  if (!ME.GRmodule->fnt_os_tbl_ptr)
	  {
	     ME.GRmodule->fnt_os_tbl_ptr = fnt_os_tbl_ptr;
	  }

          if (!(sts = DPcreate_fnt_tbl(msg,ME.GRmodule->fnt_os_tbl_ptr,
                                        OM_Gw_current_OS)))
          {
             goto wrapup;
          }

          DPchg_fst_fnt(msg,ME.GRmodule->fnt_os_tbl_ptr,OM_Gw_current_OS,
			fst_char_fnt,fst_frac_fnt,fst_16bit_fnt);

          /*
           *    Send to all windows to update the font_table_pointer
           */

          wn_font_ptr[0].var = FONT_OS_PTR;
          wn_font_ptr[0].var_ptr = (char *) ME.GRmodule->fnt_os_tbl_ptr;
          wn_font_ptr[0].num_bytes = 4;
          wn_font_ptr[0].bytes_returned = &bytes_returned;

          wn_font_ptr[1].var = END_PARAM;

          chandef.type = OM_e_name;
          chandef.u_sel.name = "windows";

          set_struct.msg = msg;        
          set_struct.which_error = &which_error;        
          set_struct.wn_font_ptr = wn_font_ptr;


        
            sts = om$make_message (  classname = "IGEgragad", 
                                        methodname = "DPset", 
                                        size = sizeof(struct dpset_struct), 
                                        p_arglist = &set_struct, 
                                        p_msg = &msg_struct);



          if (!(1&sts))
          {
#ifdef DEBUG
                printf("\nGRaddfntbl -- DPset\n");
                om$report_error(sts = sts);
#endif
                return (OM_W_ABORT);
          }
                                        
            sts = om$send(mode = OM_e_wrt_object,
                             msg = message IGEwindow.passon(&msg_struct, 
                                        "to_children", NULL, NULL),
                             senderid = my_id,
                             p_chanselect = &chandef);                        


          if (!(1&sts))
          {
#ifdef DEBUG
                printf("\nGRaddfntbl -- DPset\n");
                om$report_error(sts = sts);
#endif
                return (OM_W_ABORT);
          }



wrapup:
          return(OM_S_SUCCESS);


        }
        end implementation GRmodule;
