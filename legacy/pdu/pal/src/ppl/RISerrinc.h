RIS_box( err_code )
int err_code ;

{
      int msgnumb ;
      char err_buff[80] ;

      switch( err_code ) {
   
               case -1 :
                        msgnumb = PDR_E_InvldIDat ;
                        break;
 
               case -2 :
                        msgnumb = PDR_E_InvldODat ;
                        break ;
 
               default :
                        msgnumb = PDR_E_RisErr ;
                        break;
       }

       ex$message ( msgnumb = msgnumb ,
                    buff    = err_buff );

       warn_box( err_buff );
}

