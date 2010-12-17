
#line 35  "/usr/include/stdio.h"
 typedef unsigned int size_t ;


 typedef int fpos_t ;
#line 55  "/usr/include/stdio.h"
 typedef struct {
 int _cnt ;
 unsigned char * _ptr ;
 unsigned char * _base ;
 unsigned char _flag ;
 unsigned char _file ;
 char _cflag ;
 } FILE ;
#line 106  "/usr/include/stdio.h"
 extern FILE _iob [ 128   ] ;
 extern unsigned char * _bufendtab [ ] ;


 extern FILE  * fopen ( const char * , const char * )                               ;
 extern FILE  * freopen ( const char * , const char * , FILE * )                                       ;
 extern FILE  * tmpfile ( void )         ;
 extern char  * fgets ( char * , int , FILE * )                        ;
 extern char  * gets ( char * )           ;
 extern char  * tmpnam ( char * )           ;
 extern int  fclose ( FILE * )           ;
 extern int  feof ( FILE * )           ;
 extern int  ferror ( FILE * )           ;
 extern int  fflush ( FILE * )           ;
 extern int  fgetc ( FILE * )           ;
 extern int  fgetpos ( FILE * , fpos_t * )                     ;
 extern int  fprintf ( FILE * , const char * , ... )                              ;
 extern int  fputc ( int , FILE * )                ;
 extern int  fputs ( const char * , FILE * )                         ;
 extern int  fscanf ( FILE * , const char * , ... )                              ;
 extern int  fseek ( FILE * , long int , int )                          ;
 extern int  fsetpos ( FILE * , const fpos_t * )                           ;
 extern int  getc ( FILE * )           ;
 extern int  getchar ( void )         ;
 extern int  printf ( const char * , ... )                      ;
 extern int  putc ( int , FILE * )                ;
 extern int  putchar ( int )        ;
 extern int  puts ( const char * )                 ;
 extern int  remove ( const char * )                 ;
 extern int  rename ( const char * , const char * )                               ;
 extern int  scanf ( const char * , ... )                      ;
 extern int  setvbuf ( FILE * , char * , int , size_t )                                ;
 extern int  sprintf ( char * , const char * , ... )                              ;
 extern int  sscanf ( const char * , const char * , ... )                                    ;
 extern int  ungetc ( int , FILE * )                ;
#line 12  "/usr/include/sys/_int_sarg.h"
 typedef struct  {
  char         * arg_ptr ;
  int        * i0 ;
  double       * d0 ;
  int        * i1 ;
  double       * d1 ;
  int          arg_num ;
 } __va_list ;
#line 142  "/usr/include/stdio.h"
 extern int  vfprintf ( FILE * , const char * , __va_list )                                    ;
 extern int  vprintf ( const char * , __va_list )                            ;
 extern int  vsprintf ( char * , const char * , __va_list )                                    ;
 extern long  ftell ( FILE * )           ;
 extern size_t     fread ( void * , size_t , size_t , FILE * )                                   ;
 extern size_t     fwrite ( const void * , size_t , size_t , FILE * )                                         ;
 extern void  clearerr ( FILE * )           ;
 extern void  perror ( const char * )                 ;
 extern void  rewind ( FILE * )           ;
 extern void  setbuf ( FILE * , char * )                   ;
#line 184  "/usr/include/stdio.h"
 extern FILE  * fdopen ( int , const char * )                      ;
 extern char  * ctermid ( char * )           ;
 extern int  fileno ( FILE * )           ;
#line 30  "/usr/include/stdlib.h"
 typedef struct {
    int quot ;
    int rem ;
 } div_t ;

 typedef div_t ldiv_t ;








 typedef char wchar_t ;
#line 62  "/usr/include/stdlib.h"
 extern void    * malloc ( size_t ) ;
 extern void    * calloc ( size_t , size_t ) ;
 extern void    * realloc ( void * , size_t ) ;





 extern void    free ( void * )           ;



 extern void   * bsearch ( const void * , const void * , size_t ,
         size_t , int ( * ) ( const void * ,
         const void * ) ) ;




 extern char   * getenv ( const char * )                 ;
 extern double   atof ( const char * )                 ;
 extern double   strtod ( const char * , char * * )                          ;

 extern int   abs ( int )        ;

 extern int   atexit ( void ( * ) ( void ) )                   ;
 extern int   atoi ( const char * )                 ;
 extern int   rand ( void )         ;
 extern int   system ( const char * )                 ;
 extern long int   atol ( const char * )                 ;
 extern long int   labs ( long )         ;
 extern long int   strtol ( const char * , char * * , int )                               ;
 extern unsigned long int strtoul ( const char * , char * * , int )                               ;
 extern void   abort ( void )         ;
 extern void   exit ( int )        ;
 extern void   qsort ( void * , size_t , size_t , int ( * ) ( const void * , const void * ) )
                                           ;
 extern void   srand ( unsigned int )                 ;



 extern int    mblen ( const char * , size_t )                         ;
 extern int    mbtowc ( wchar_t * , const char * , size_t )                                    ;
 extern int    wctomb ( char * , wchar_t )                    ;
 extern size_t    mbstowcs ( wchar_t * , const char * , size_t )                                    ;
 extern size_t    wcstombs ( char * , const wchar_t * , size_t )                                    ;
#line 128  "/usr/include/stdlib.h"
 extern div_t   div ( int , int )             ;
 extern ldiv_t   ldiv ( long int , long int )                       ;
#line 32  "/usr/include/string.h"
 extern char * strcat ( char * , const char * )                         ;
 extern char * strchr ( const char * s , int )                       ;
 extern char * strcpy ( char * , const char * )                         ;
 extern char * strerror ( int )        ;
 extern char * strncat ( char * , const char * , size_t )                                 ;
 extern char * strncpy ( char * , const char * , size_t )                                 ;
 extern char * strpbrk ( const char * , const char * )                               ;
 extern char * strrchr ( const char * s , int )                       ;
 extern char * strstr ( const char * , const char * )                               ;
 extern char * strtok ( char * , const char * )                         ;
 extern int strcmp ( const char * , const char * )                               ;
 extern int strcoll ( const char * , const char * )                               ;
 extern int strncmp ( const char * , const char * , size_t )                                       ;
 extern size_t strxfrm ( char * , const char * , size_t )                                 ;


 extern size_t strcspn ( const char * , const char * )                               ;
 extern size_t strlen ( const char * s )                  ;
 extern size_t strspn ( const char * , const char * )                               ;
#line 28  "/usr/include/memory.h"
 extern int   memcmp ( const void * , const void * , size_t )                                       ;



 extern void * memchr ( const void * , int , size_t ) ;
 extern void * memcpy ( void * , const void * , size_t ) ;
 extern void * memmove ( void * , const void * , size_t ) ;
 extern void * memset ( void * , int , size_t ) ;
#line 27  "/usr/include/sys/types.h"
 typedef struct { int r [ 1 ] ; } * physadr ;
 typedef long  daddr_t ;
 typedef char *  caddr_t ;
 typedef unsigned char unchar ;
 typedef unsigned short ushort ;
 typedef unsigned int uint ;
 typedef unsigned long ulong ;
 typedef ushort  ino_t ;
 typedef short  cnt_t ;




 typedef long  time_t ;
#line 56  "/usr/include/sys/types.h"
 typedef int  label_t [ 44               ] ;
 typedef short  dev_t ;
 typedef long  off_t ;
 typedef long  paddr_t ;
 typedef int  key_t ;
 typedef unsigned char use_t ;
 typedef short  sysid_t ;
 typedef short  index_t ;
 typedef short  lock_t ;







 typedef ushort  mode_t ;
 typedef short  nlink_t ;
 typedef short  pid_t ;




 typedef long  clock_t ;




 typedef unsigned char   u_char ;
 typedef unsigned short  u_short ;
 typedef unsigned int    u_int ;
 typedef unsigned long   u_long ;
 typedef u_short uid_t ;
 typedef u_short gid_t ;
 typedef struct _quad { long val [ 2 ] ; } quad ;
 typedef long swblk_t ;
#line 104  "/usr/include/sys/types.h"
 typedef struct fd_set {
 long fds_bits [ ( ( ( 256 ) + ( ( ( sizeof ( long ) * 8 ) ) - 1 ) ) / ( ( sizeof ( long ) * 8 ) ) )                           ] ;
 } fd_set ;
#line 17  "/usr/ip32/exnucdp/include/igrtypedef.h"
 typedef short IGRboolean ;
 typedef short  IGRshort ;
 typedef long   IGRlong ;
 typedef int    IGRint ;
 typedef double  IGRdouble ;
 typedef char IGRchar ;
 typedef unsigned char   IGRuchar ;
 typedef unsigned short IGRushort ;
 typedef unsigned int IGRuint ;
 typedef unsigned long IGRulong ;

 typedef  IGRdouble  IGRvector [ 3 ] ;

 typedef  IGRdouble  IGRmatrix [ 16 ] ;

 typedef  IGRdouble  IGRpoint [ 3 ] ;
#line 10  "/usr/ip32/exnucdp/include/exms.h"
 struct MS_sd_msg
 {
    IGRint no_args ;
    IGRlong no_msg ;
    IGRchar     msgname [ 81 ] ;
    IGRchar u_type [ 81 ] ;
    IGRchar for_type [ 81 ] ;
    IGRchar  in_msg [ 512               ] ;
    IGRchar  variables [ 256 ] ;
    IGRchar out_msg [ 512               ] ;
 } ;
#line 22  "/usr/ip32/exnucdp/include/msmacros.h"
 extern void MS_format_message ( struct MS_sd_msg * MS_msg )                             ;

 extern int MS_init ( struct MS_sd_msg * MS_msg , IGRlong msgnumb , IGRchar * msgname , IGRchar * in_buff , IGRint field , IGRint justification )

                                                           ;
 extern int MSget_message ( long msgnumber , char * * buffer , int * nbytes )                                             ;
 extern int EX_create_prompt ( int message_number , int left_prompt_number , int right_prompt_number , char * string , int * response , char * response_data )

                       ;
 extern void MS_file_init ( IGRchar * message_file , IGRchar * msg_file )                                             ;
 extern void MS_fix_type ( struct MS_sd_msg * MS_msg , IGRchar * type )                                            ;
 extern void MS_function ( IGRint status , IGRint ( * function ) ( ) )                                         ;
 extern int MS_onoff ( IGRlong * msg , IGRshort * previous_state , IGRshort new_state , IGRint type )
                                   ;
 extern int MS_out_msg ( struct MS_sd_msg * MS_msg , IGRchar * buff , IGRint field , IGRint justification , IGRint delay_time , IGRint seconds , IGRint buffer_size )

                                     ;
 extern int MSmessage ( IGRint field , IGRlong msgnumb , IGRchar * msgname , IGRint justification , IGRchar * buff , IGRchar * type , IGRchar * var , IGRchar * in_buff , IGRint delay_time , IGRint seconds , IGRint buffer_size )


                                     ;

 extern int MS_return_sizeof_message ( IGRlong msgnumb , IGRchar * msgname , IGRint * nbytes )
                  ;



 extern int MS_retrieve_msg ( struct MS_sd_msg * MS_msg )                             ;


 extern int MS_display_message ( IGRint field , IGRint justification , IGRchar * string , struct MS_sd_msg * MS_msg , IGRint delay_time , int seconds )                                                                                                                  ;
 extern int MSgetfont ( void )         ;
 extern int MS_update_msg_strip ( int field_no , int just , char * string )                                         ;
 extern int MSerrbox ( IGRint field , IGRint justification , IGRchar * string , struct MS_sd_msg * MS_msg )
                                                                     ;
 extern int EX_error_box ( int screen_no , char * msg , char * title )                                          ;
 extern int MS_paint_area ( void )         ;
#line 131  "/usr/include/unistd.h"
 typedef int ssize_t ;








 extern void _exit ( int )        ;
 extern int access ( const char * , int )                      ;
 extern unsigned int alarm ( unsigned int )                 ;
 extern int chdir ( const char * )                 ;
 extern int chown ( const char * , uid_t , gid_t )                               ;
 extern int close ( int )        ;
 extern char * ctermid ( char * )           ;
 extern int dup2 ( int , int )             ;
 extern int dup ( int )        ;
 extern int execl ( const char * , const char * , ... )                                    ;
 extern int execle ( const char * , const char * , ... )                                    ;
 extern int execlp ( const char * , const char * , ... )                                    ;
 extern int execv ( const char * , char * const [ ] )                                 ;
 extern int execve ( const char * , char * const [ ] , char * const [ ] )                                                 ;
 extern int execvp ( const char * , char * const [ ] )                                 ;
 extern pid_t fork ( void )         ;
 extern long fpathconf ( int , int )             ;
 extern char * getcwd ( char * , size_t )                   ;
 extern gid_t getegid ( void )         ;
 extern uid_t geteuid ( void )         ;
 extern gid_t getgid ( void )         ;
 extern int getgroups ( int , gid_t [ ] )                  ;
 extern char * getlogin ( void )         ;
 extern pid_t getpgrp ( void )         ;
 extern pid_t getpid ( void )         ;
 extern pid_t getppid ( void )         ;
 extern uid_t getuid ( void )         ;
 extern int isatty ( int )        ;
 extern int link ( const char * , const char * )                               ;
 extern off_t lseek ( int , off_t , int )                    ;
 extern long pathconf ( const char * , int )                      ;
 extern int pause ( void )         ;
 extern int pipe ( int fildes [ 2 ] )                  ;
 extern ssize_t read ( int , void * , size_t )                        ;
 extern int rmdir ( const char * )                 ;
 extern int setgid ( gid_t )          ;
 extern int setpgid ( pid_t , pid_t )                 ;
 extern pid_t setsid ( void )         ;
 extern int setuid ( uid_t )          ;
 extern unsigned int sleep ( unsigned int )                 ;
 extern long sysconf ( int )        ;
 extern pid_t tcgetpgrp ( int )        ;
 extern int tcsetpgrp ( int , pid_t )               ;
 extern char * ttyname ( int )        ;
 extern int unlink ( const char * )                 ;
 extern ssize_t write ( int , const void * , size_t )                              ;
#line 39  "/usr/include/sys/dirent.h"
 struct dirent
 {
 long  d_ino ;
 off_t  d_off ;
 unsigned short d_reclen ;
 char  d_name [ 14 ] ;
 } ;



 typedef struct
        {
        int     dd_fd ;
        int     dd_loc ;
        int     dd_size ;
        char    * dd_buf ;
        }       DIR ;
#line 43  "/usr/include/dirent.h"
 extern DIR  * opendir ( const char * )                 ;
 extern struct dirent * readdir ( DIR * )          ;
 extern void   rewinddir ( DIR * )          ;
 extern int  closedir ( DIR * )          ;
 extern long  telldir ( DIR * )          ;
 extern void  seekdir ( DIR * , long )                ;
#line 18  "/usr/ip32/forms/include/FI.h"
 typedef char * Form ;
 typedef char * Gadget ;
 typedef char * Group ;
#line 184  "/usr/ip32/grnucdp/include/tools.h"
 struct strm_dig_sample
 {
 int timetag ;
 int x , y ;
 } ;


 struct vlt_slot
 {
 unsigned short v_slot ;
 unsigned short v_red ;
 unsigned short v_green ;
 unsigned short v_blue ;
 } ;





 struct vlt_info
 {
 unsigned short  vlti_vlt_start ;
 unsigned short vlti_vlt_size ;
 unsigned char vlti_max_alloc_vlts ;
 unsigned short vlti_num_planes ;
 unsigned short vlti_num_bytes_per_pixel ;
 unsigned short  vlti_flags ;
 unsigned int pad [ 10 ] ;
 } ;


 struct rgb_color
 {
    unsigned short red ;
    unsigned short green ;
    unsigned short blue ;
 } ;
#line 254  "/usr/ip32/grnucdp/include/tools.h"
 struct scr_info
 { long vsi_0 , vsi_1 , vsi_2 , vsi_3 , vsi_4 , vsi_5 , vsi_6 , vsi_7 ,
      vsi_8 , vsi_9 , vsi_10 , vsi_11 , vsi_12 , vsi_13 , vsi_14 , vsi_15 ,
      vsi_16 , vsi_17 , vsi_18 , vsi_19 , vsi_20 , vsi_21 , vsi_22 , vsi_23 ,
      vsi_24 ;
 } ;



 struct fmn_select_area
 {
 int sel_type ;





 short xlo , ylo ;
 short xhi , yhi ;
 char cmd [ 128 ] ;
 } ;
#line 21  "/usr/ip32/forms/include/FIdyn.h"
 struct standard_st
 {


  unsigned short xlo ;
  unsigned short ylo ;
  unsigned short xhi ;
  unsigned short yhi ;



  long     attr_mask ;


  double    value ;


  float     bodysize ;

  char    * text ;

  char    * help_topic ;
  char    * command ;



  char    * fontname ;



  char   * user_pointer ;





  unsigned char   off_color ;
  unsigned char   on_color ;

  unsigned char   off_color2 ;
  unsigned char   on_color2 ;


  unsigned char   symbol_index ;


  unsigned char   symbol_index2 ;




  unsigned short  next_in_seq ;

 } ;
#line 70  "/usr/ip32/forms/include/FIproto_pub.h"
 extern int ( * FI_activate_help ) ( Form form ) ;

 extern int ( * FI_calc_text ) ( int font_id , char * text , int length ,
         int * height , int * width ,
         int * line_spacing , int font_type ) ;

 extern int ( * FI_draw_text ) ( int window , int font_id , char * text ,
         int length , int xpos , int ypos ,
         int font_height , int * nx , int * ny ,
         int font_type ) ;




 extern int ( * FI_find_font_id ) ( char * fontname , double bodysize ,
     int * font_id , float * actual_bodysize ,
     int gadget_type , int * font_type ) ;

 extern int ( * FI_find_form ) ( char * path , char * form_name ) ;

 extern int ( * FI_find_symbol_path_and_id ) ( char * path ,
          char * symbol_name ,
          int  * symbol_id ) ;

 extern int ( * FI_get_keyboard_data ) ( char * character , int * count ,
          int font_type ) ;

 extern int ( * FI_map_character ) ( unsigned char * character ) ;

 extern int ( * FI_move_index ) ( unsigned char * string , int index ,
          int num_chars , int font_type ) ;

 extern int ( * FI_process_data ) ( int data_type , char * data_string ,
     Form form ) ;

 extern int ( * FI_strlen ) ( char * string , int font_type ) ;

 extern int ( * FI_set_window_attr ) ( int window_number ) ;

 extern int ( * FI_translate_color ) ( int vs , int color ) ;






 extern int FI_append_FSfont_path ( char * FSfont_path ) ;

 extern int FI_append_font_path ( char * font_path ) ;

 extern int FI_append_form_path ( char * form_path ) ;

 extern int FI_append_symbol_path ( char * symbol_path ) ;

 extern int FI_calc_closest_colors ( int vs ,
        struct vlt_slot * current_vlt ,
        int current_vlt_num_slots ) ;

 extern int FI_clear_event ( long event ) ;

 extern int FI_enter ( void ) ;

 extern int FI_forms_active ( void ) ;

 extern int FI_get_FSfont_path ( char font_path [ ] ) ;

 extern int FI_get_FSfont_path_length ( int * font_path_length ) ;

 extern int FI_get_env ( int function_code , int ( * * func_ptr ) ( ) ) ;

 extern int FI_get_font_path ( char font_path [ ] ) ;

 extern int FI_get_font_path_length ( int * font_path_length ) ;

 extern int FI_get_form ( int window , Form * form ) ;

 extern int FI_get_form_by_name ( char * name , Form * form_ptr ) ;

 extern int FI_get_form_menu_type ( Form form_menu ,
       int * form_menu_type ) ;

 extern int FI_get_form_path ( char form_path [ ] ) ;

 extern int FI_get_form_path_length ( int * form_path_length ) ;

 extern int FI_get_graphic_env ( int function_code , int ( * * routine ) ( ) ) ;

 extern int FI_get_keyboard_buffer ( char * * buffer , int * size ) ;

 extern int FI_get_last_notification_type ( int * notify_type ) ;

 extern int FI_get_num_forms_menus ( int * num_forms_menus ) ;

 extern int FI_get_forms_menus ( Form forms_menus_array [ ] ,
    int * num_forms_menus ) ;

 extern int FI_get_quiet_mode ( int * quiet_mode ) ;

 extern int FI_get_record_notification_routine ( void ( * * routine ) ( ) ) ;

 extern int FI_get_symbol_path ( char symbol_path [ ] ) ;

 extern int FI_get_symbol_path_length ( int * symbol_path_length ) ;

 extern int FI_load_font ( char * fontname , int bodysize ,
     int * actual_bodysize ,
     int * font_id ) ;




 extern int FI_message_box  ( int screen , int xpos , int ypos ,
        char * title ,  int title_color ,
        char * title_font ,  double title_bodysize ,
        char * message ,  int message_color ,
       char * message_font , double message_bodysize ,
        int display_mode , int line_length ) ;




 extern int FI_message_box2 ( int screen , int xpos , int ypos ,
        char * title ,  int title_color ,
        char * title_font ,  double title_bodysize ,
        char * message ,  int message_color ,
       char * message_font , double message_bodysize ,
        int display_mode , int line_length ) ;

 extern int FI_modify_env ( int function_code , int ( * func_ptr ) ( ) ) ;

 extern int FI_modify_graphic_env ( int function_code ,
       int ( * routine ) ( ) ) ;

 extern int FI_msg_box ( char * title , int title_color , char * message ,
   int message_color ) ;

 extern int FI_msg_box2 ( char * title , int title_color , char * message ,
   int message_color ) ;

 extern int FI_process_event ( long event_mask ) ;

 extern int FI_process_forms ( void ) ;

 extern int FI_set_FSfont_path ( char * FSfont_path ) ;

 extern int FI_set_font_path ( char * font_path ) ;

 extern int FI_set_form_path ( char * form_path ) ;

 extern int FI_set_form_path ( char * form_path ) ;

 extern int FI_set_keyboard_buffer ( char * buffer , int size ) ;

 extern int FI_set_quiet_mode_off ( void ) ;

 extern int FI_set_quiet_mode_on ( void ) ;

 extern int FI_set_record_notification_routine ( void ( * routine ) ( ) ) ;

 extern int FI_set_symbol_path ( char * symbol_path ) ;

 extern void FI_use_normal_bezel ( ) ;

 extern void FI_use_thin_bezel ( ) ;

 extern int FIbtn_get_auto_pop_up_state ( Form form , int label ,
      int * state ) ;

 extern int FIbtn_get_menu_status ( Form form , int label , int * status ) ;

 extern int FIbtn_get_palette ( Form form , int label , char * pal_name ) ;

 extern int FIbtn_set_auto_pop_up_off ( Form form , int label ) ;

 extern int FIbtn_set_auto_pop_up_on ( Form form , int label ) ;

 extern int FIbtn_set_menu_status ( Form form , int label , int status ) ;

 extern int FIbtn_set_palette ( Form form , int label , char * pal_name ) ;

 extern int FIdial_get_border_style ( Form form , int label ,
         int * border_style ) ;

 extern int FIdial_get_range ( Form form , int label , float * range ) ;

 extern int FIdial_get_zero_location ( Form form , int label ,
          float * zero ) ;

 extern int FIdial_set_border_style ( Form form , int label ,
         int border_style ) ;



 extern int FIdial_set_range ( Form form , int label , double range ) ;



 extern int FIdial_set_zero_location ( Form form , int label ,
          double zero ) ;

 extern int FIf_collapse ( Form form ) ;

 extern int FIf_cvrt_to_perm_win ( Form form ) ;

 extern int FIf_delete ( Form form ) ;

 extern int FIf_display ( Form form ) ;

 extern int FIf_erase ( Form form ) ;

 extern int FIf_find_by_area ( Form form , int group_label ,
         int x1 , int y1 , int x2 , int y2 ,
         int * num_labels , int * * labels ) ;

 extern int FIf_find_by_point ( Form form , int group_label ,
          int xpos , int ypos , int max_dist ,
          int * label , int reset_search_flag ) ;

 extern int FIf_find_gadget ( Form form , int group_label ,
        int xpos , int ypos , int * label ) ;

 extern int FIf_get_SR_vlt ( Form form , struct vlt_slot * SR_vlt ,
       int num_SR_vlt_slots ) ;

 extern int FIf_get_SR_vlt_num_slots ( Form form ,
          int * num_SR_vlt_slots ) ;

 extern int FIf_get_attr ( Form form , long * form_mask ) ;

 extern int FIf_get_button_event_routine ( Form form ,
       int ( * * routine ) ( ) ) ;

 extern int FIf_get_button_intercept_routine ( Form form ,
           int ( * * routine ) ( ) ) ;

 extern int FIf_get_cmd_oid_os ( Form form , unsigned int * cmd_oid ,
    unsigned short * cmd_os ) ;

 extern int FIf_get_collapse_location ( Form form , int * xpos ,
           int * ypos ) ;

 extern int FIf_get_collapse_symbol ( Form form , char symbol_file [ ] ,
         int * symindex ) ;

 extern int FIf_get_color ( Form form , int * color ) ;

 extern int FIf_get_initial_notification_routine ( Form form ,
      int ( * * routine ) ( ) ) ;

 extern int FIf_get_label ( Form form , int * form_label ) ;

 extern int FIf_get_location ( Form form , int * xpos , int * ypos ) ;

 extern int FIf_get_max_size ( Form form , int * max_xsize ,
      int * max_ysize ) ;

 extern int FIf_get_min_size ( Form form , int * min_xsize ,
      int * min_ysize ) ;

 extern int FIf_get_name ( Form form , char * name ) ;

 extern int FIf_get_next_label ( Form form , int * next_label ) ;

 extern int FIf_get_notification_routine ( Form form ,
       int ( * * routine ) ( ) ) ;

 extern int FIf_get_orig_location ( Form form , int * xlo , int * ylo ) ;

 extern int FIf_get_orig_size ( Form form , int * xsize , int * ysize ) ;

 extern int FIf_get_scaling ( Form form , int * scaling_flag ) ;

 extern int FIf_get_screen ( Form form , int * screen ) ;

 extern int FIf_get_seq ( Form form , int * seq_flag ) ;

 extern int FIf_get_size ( Form form , int * xsize , int * ysize ) ;

 extern int FIf_get_start_seq ( Form form , int * gadget_label ) ;

 extern int FIf_get_user_pointer ( Form form , char * * user_pointer ) ;

 extern int FIf_get_window ( Form form , int * window ) ;

 extern int FIf_get_window_event_routine ( Form form ,
       int ( * * routine ) ( ) ) ;

 extern int FIf_get_window_icon_routine ( Form form , int ( * * routine ) ( ) ) ;

 extern int FIf_is_collapsed ( Form form , int * status ) ;

 extern int FIf_is_displayed ( Form form , int * status ) ;

 extern int FIf_is_valid ( Form form ) ;

 extern int FIf_look ( Form form , int group_label , char * string ) ;

 extern int FIf_new ( int label , char * form_name ,
       int ( * notification_routine ) ( ) , Form * form ) ;

 extern int FIf_paint_area ( Form form , int xlo , int ylo ,
           int xhi , int yhi ) ;

 extern int FIf_process_point ( Form form , int xpos , int ypos ,
          int button , int trans , int ttag ) ;

 extern int FIf_reset ( Form form ) ;

 extern int FIf_save ( Form form , char * path ) ;

 extern int FIf_set_SR_vlt ( Form form , struct vlt_slot * SR_vlt ,
       int num_SR_vlt_slots ) ;

 extern int FIf_set_attr ( Form form , int form_mask ) ;

 extern int FIf_set_button_event_routine ( Form form , int ( * routine ) ( ) ) ;

 extern int FIf_set_button_intercept_routine ( Form form ,
           int ( * routine ) ( ) ) ;

 extern int FIf_set_cmd_oid_os ( Form form , unsigned int cmd_oid ,
    unsigned short cmd_os ) ;

 extern int FIf_set_collapse_location ( Form form , int xpos , int ypos ) ;

 extern int FIf_set_collapse_symbol ( Form form , char * symbol_file ,
      int symindex ) ;

 extern int FIf_set_color ( Form form , int color ) ;

 extern int FIf_set_initial_notification_routine ( Form form ,
        int ( * routine ) ( ) ) ;

 extern int FIf_set_label ( Form form , int form_label ) ;

 extern int FIf_set_location ( Form form , int xpos , int ypos ) ;

 extern int FIf_set_max_size ( Form form , int xsize , int ysize ) ;

 extern int FIf_set_min_size ( Form form , int xsize , int ysize ) ;

 extern int FIf_set_notification_routine ( Form form , int ( * routine ) ( ) ) ;

 extern int FIf_set_orig_location ( Form form , int xlo , int ylo ) ;

 extern int FIf_set_orig_size ( Form form , int xsize , int ysize ) ;

 extern int FIf_set_rel_location ( Form form , int xpos , int ypos ,
      Form base_form ) ;

 extern int FIf_set_resize_off ( Form form ) ;

 extern int FIf_set_resize_on ( Form form ) ;

 extern int FIf_set_revert_size_icon_off ( Form form ) ;

 extern int FIf_set_revert_size_icon_on ( Form form ) ;

 extern int FIf_set_scaling_off ( Form form ) ;

 extern int FIf_set_scaling_on ( Form form ) ;

 extern int FIf_set_screen ( Form form , int screen ) ;

 extern int FIf_set_seq_off ( Form form ) ;

 extern int FIf_set_seq_on ( Form form ) ;

 extern int FIf_set_size ( Form form , int xsize , int ysize ) ;

 extern int FIf_set_start_seq ( Form form , int gadget_label ) ;

 extern int FIf_set_user_pointer ( Form form , char * user_pointer ) ;

 extern int FIf_set_window_event_routine ( Form form , int ( * routine ) ( ) ) ;

 extern int FIf_set_window_icon_routine ( Form form , int ( * routine ) ( ) ) ;

 extern int FIf_set_window_level ( Form form , int level ) ;

 extern int FIf_uncollapse ( Form form ) ;

 extern int FIfld_delete_rows ( Form form , int label , int start_row ,
          int num_rows ) ;

 extern int FIfld_erase_cursor ( Form form , int label ) ;

 extern int FIfld_find_row_and_column ( Form form , int gadget ,
    int x , int y , int * row , int * column ) ;

 extern int FIfld_get_active_char ( Form form , int label , int col ,
       int * ch , int * pos ) ;

 extern int FIfld_get_active_row ( Form form , int label ,
      int * row , int * pos ) ;

 extern int FIfld_get_attr ( Form form , int label , int col ,
       long * attr_mask ) ;

 extern int FIfld_get_default_text ( Form form , int label , int row ,
        int col , int num_ch ,
        unsigned char * text , int * sel_flg ) ;

 extern int FIfld_get_default_text_length ( Form form , int label ,
            int row , int col , int * length ) ;

 extern int FIfld_get_format_routine ( Form form , int label , int col ,
          int ( * * routine ) ( ) ) ;

 extern int FIfld_get_format_string ( Form form , int label , int col ,
     unsigned char * format_string ) ;

 extern int FIfld_get_format_string_length ( Form form , int label ,
         int col ,
         int * format_str_length ) ;

 extern int FIfld_get_line_color ( Form form , int label , int row ,
      int col , int * color ) ;

 extern int FIfld_get_list_default_text ( Form form , int label , int row ,
      int col , int num_ch ,
      unsigned char * text ,
      int * sel_flg ) ;

 extern int FIfld_get_list_default_text_length ( Form form , int label ,
      int row , int col ,
      int * length ) ;

 extern int FIfld_get_list_location ( Form form , int label , int col ,
         int * xpos , int * ypos ) ;

 extern int FIfld_get_list_mode ( Form form , int label , int col ,
     int * mode ) ;

 extern int FIfld_get_list_num_rows ( Form form , int label , int col ,
         int * num_rows ) ;

 extern int FIfld_get_list_scroll ( Form form , int label , int * vert_flag ,
       int * horz_flag ) ;

 extern int FIfld_get_list_select ( Form form , int label ,
       int row , int col , int * sel_flg ) ;

 extern int FIfld_get_list_size ( Form form , int label , int col ,
     int * xsize , int * ysize ) ;

 extern int FIfld_get_list_text ( Form form , int label , int row , int col ,
            int num_ch , unsigned char * text ,
     int * sel_flg ) ;

 extern int FIfld_get_list_text_length ( Form form , int label , int row ,
     int col , int * length ) ;

 extern int FIfld_get_max_num_chars ( Form form , int label , int col ,
         int * num_chars ) ;

 extern int FIfld_get_max_num_rows ( Form form , int label ,
        int * num_rows ) ;

 extern int FIfld_get_mode ( Form form , int label , int col , int * mode ) ;

 extern int FIfld_get_notify_info ( int * event , int * event_value ,
     Form * form , int * gad_label ) ;

 extern int FIfld_get_num_rows ( Form form , int label , int * num_rows ) ;

 extern int FIfld_get_num_vis_chars ( Form form , int label , int col ,
         int * num_chars ) ;

 extern int FIfld_get_num_vis_rows ( Form form , int label ,
        int * num_rows ) ;

 extern int FIfld_get_row_height ( Form form , int label ,
      int * row_height ) ;

 extern int FIfld_get_row_offset ( Form form , int label ,
      int * row_offset ) ;

 extern int FIfld_get_select ( Form form , int label , int row , int col ,
         int * sel_flg ) ;

 extern int FIfld_get_text ( Form form , int label , int row , int col ,
       int num_ch , unsigned char * text ,
       int * sel_flg , int * r_pos ) ;

 extern int FIfld_get_text_length ( Form form , int label , int row ,
       int col , int * length ) ;

 extern int FIfld_get_type ( Form form , int label , int col , int * type ) ;

 extern int FIfld_get_value ( Form form , int label , int row , int col ,
        double * value , int * sel_flg , int * r_pos ) ;

 extern int FIfld_get_verify_routine ( Form form , int label , int col ,
          int ( * * routine ) ( ) ) ;

 extern int FIfld_insert_blank_row ( Form form , int label , int row ) ;

 extern int FIfld_pos_cursor ( Form form , int label , int row , int r_pos ,
               int col , int col_pos , int ch , int ch_pos ) ;

 extern int FIfld_set_active_char ( Form form , int label , int col ,
       int ch , int pos ) ;

 extern int FIfld_set_active_row ( Form form , int label , int row ,
      int pos ) ;

 extern int FIfld_set_attr ( Form form , int label , int col ,
       long attr_mask ) ;

 extern int FIfld_set_default_text ( Form form , int label , int row ,
        int col , char * text , int sel_flg ) ;

 extern int FIfld_set_format_routine ( Form form , int label , int col ,
          int ( * routine ) ( ) ) ;

 extern int FIfld_set_format_string ( Form form , int label , int col ,
         char * format_string ) ;

 extern int FIfld_set_line_color ( Form form , int label ,
      int row , int col , int color ) ;

 extern int FIfld_set_list_default_text ( Form form , int label ,
      int row , int col ,
      char * text , int sel_flg ) ;

 extern int FIfld_set_list_location ( Form form , int label , int col ,
         int xpos , int ypos ) ;

 extern int FIfld_set_list_mode ( Form form , int label , int col ,
     int mode ) ;

 extern int FIfld_set_list_num_rows ( Form form , int label , int col ,
         int num_rows ) ;

 extern int FIfld_set_list_scroll ( Form form , int label , int vert_flag ,
       int horz_flag ) ;

 extern int FIfld_set_list_select ( Form form , int label ,
       int row , int col , int sel_flg ) ;

 extern int FIfld_set_list_size ( Form form , int label , int col ,
     int xsize , int ysize ) ;

 extern int FIfld_set_list_text ( Form form , int label , int row , int col ,
     char * text , int sel_flg ) ;

 extern int FIfld_set_max_num_chars ( Form form , int label , int col ,
         int num_chars ) ;

 extern int FIfld_set_max_num_rows ( Form form , int label ,
        int num_rows ) ;

 extern int FIfld_set_mode ( Form form , int label , int col , int mode ) ;

 extern int FIfld_set_num_rows ( Form form , int label , int num_rows ) ;

 extern int FIfld_set_num_vis_chars ( Form form , int label , int col ,
         int num_chars ) ;

 extern int FIfld_set_num_vis_rows ( Form form , int label ,
        int num_rows ) ;

 extern int FIfld_set_select ( Form form , int label , int row , int col ,
         int sel_flg ) ;

 extern int FIfld_set_text ( Form form , int label , int row , int col ,
       char * apptext , int sel_flg ) ;

 extern int FIfld_set_type ( Form form , int label , int col , int type ) ;

 extern int FIfld_set_value ( Form form , int label , int row , int col ,
        double value , int sel_flg ) ;

 extern int FIfld_set_verify_routine ( Form form , int label , int col ,
          int ( * routine ) ( ) ) ;

 extern int FIg_activate ( Form form , int label ) ;

 extern int FIg_add_to_group ( Form form , int gadget_label ,
         int group_label ) ;




 extern int FIg_adjust_size ( Form form , int label , double delta_x ,
        double delta_y ) ;

 extern int FIg_call_notification_routine ( Form form , int label ) ;

 extern int FIg_copy ( Form form , int old_label , int * new_label ,
        int generate_new_label_flag ) ;

 extern int FIg_delete ( Form form , int label ) ;

 extern int FIg_disable ( Form form , int label ) ;

 extern int FIg_display ( Form form , int label ) ;

 extern int FIg_enable ( Form form , int label ) ;

 extern int FIg_erase ( Form form , int label ) ;

 extern int FIg_get_attr ( Form form , int label , int * attr_mask ) ;

 extern int FIg_get_color ( Form form , int label , int * color ) ;

 extern int FIg_get_command ( Form form , int label , char * command ) ;

 extern int FIg_get_command_length ( Form form , int label ,
        int * command_length ) ;

 extern int FIg_get_continuous_routine ( Form form , int label ,
     int ( * * cont_routine ) ( ) ) ;

 extern int FIg_get_default_value ( Form form , int label ,
       double * default_value ) ;

 extern int FIg_get_display ( Form form , int label , int * display_mask ) ;

 extern int FIg_get_dlocation ( Form form , int label , double * xpos ,
          double * ypos ) ;

 extern int FIg_get_dsize ( Form form , int label , double * xsize ,
      double * ysize ) ;

 extern int FIg_get_erase_color ( Form form , int label ,
     int * erase_color ) ;

 extern int FIg_get_font ( Form form , int label , char * fontname ,
     float * bodysize ) ;

 extern int FIg_get_group_label ( Form form , int label ,
     int * group_label ) ;

 extern int FIg_get_help_topic ( Form form , int label ,
    char * help_topic ) ;

 extern int FIg_get_help_topic_length ( Form form , int label ,
           int * help_topic_length ) ;

 extern int FIg_get_high_value ( Form form , int label ,
    double * high_value ) ;

 extern int FIg_get_increment ( Form form , int label , float * increment ) ;

 extern int FIg_get_justification ( Form form , int label , int * just ) ;

 extern int FIg_get_line_depth ( Form form , int label , int * depth ) ;

 extern int FIg_get_line_style ( Form form , int label , int * style ) ;

 extern int FIg_get_line_weight ( Form form , int label , int * wt ) ;

 extern int FIg_get_location ( Form form , int label ,
    int * xpos , int * ypos ) ;

 extern int FIg_get_low_value ( Form form , int label ,
    double * low_value ) ;

 extern int FIg_get_minor_increments ( Form form , int label ,
     int * incrs ) ;

 extern int FIg_get_next_in_seq ( Form form , int label ,
     int * next_label ) ;

 extern int FIg_get_notify ( Form form , int label , int * notify_flag ) ;

 extern int FIg_get_off_color ( Form form , int label , int * off_color ) ;

 extern int FIg_get_off_color2 ( Form form , int label , int * off_color2 ) ;

 extern int FIg_get_off_symbol_index ( Form form , int label ,
     int * sym_index ) ;

 extern int FIg_get_off_text ( Form form , int label , char * text ) ;

 extern int FIg_get_off_text_length ( Form form , int label ,
     int * length ) ;

 extern int FIg_get_on_color ( Form form , int label , int * on_color ) ;

 extern int FIg_get_on_color2 ( Form form , int label , int * on_color2 ) ;

 extern int FIg_get_on_symbol_index ( Form form , int label ,
     int * sym_index ) ;

 extern int FIg_get_on_text ( Form form , int label , char * text ) ;

 extern int FIg_get_on_text_length ( Form form , int label , int * length ) ;

 extern int FIg_get_orientation ( Form form , int label ,
     int * orientation ) ;

 extern int FIg_get_pass_data ( Form form , int label , int * next_label ) ;

 extern int FIg_get_size ( Form form , int label ,
     int * xsize , int * ysize ) ;

 extern int FIg_get_state ( Form form , int label , int * state ) ;

 extern int FIg_get_symbol_file ( Form form , int label ,
     char * symbol_file ) ;

 extern int FIg_get_symbol_index ( Form form , int label ,
      int * sym_index ) ;

 extern int FIg_get_text ( Form form , int label , char * text ) ;

 extern int FIg_get_text_length ( Form form , int label , int * length ) ;

 extern int FIg_get_text_style ( Form form , int label , int * style ) ;

 extern int FIg_get_type ( Form form , int label , int * type ) ;

 extern int FIg_get_user_pointer ( Form form , int label ,
      char * * user_pointer ) ;

 extern int FIg_get_value ( Form form , int label , double * value ) ;

 extern int FIg_get_value_format ( Form form , int label ,
      int * field_width ,
      int * decimal_accuracy ) ;

 extern int FIg_hilite ( Form form , int label ) ;

 extern int FIg_in_group ( Form form , int gadget_label , int group_label ,
     int * in_group ) ;

 extern int FIg_is_displayed ( Form form , int label , int * displayed ) ;

 extern int FIg_is_valid ( Form form , int gadget_label ) ;

 extern int FIg_new ( Form form , int gadget_type , int label ) ;

 extern int FIg_reset ( Form form , int label ) ;

 extern int FIg_set_attr ( Form form , int label , int attr_mask ) ;

 extern int FIg_set_color ( Form form , int label , int color ) ;

 extern int FIg_set_command ( Form form , int label , char * command ) ;

 extern int FIg_set_continuous_routine ( Form form , int label ,
     int ( * cont_routine ) ( ) ) ;

 extern int FIg_set_default_value ( Form form , int label ,
       double default_value ) ;

 extern int FIg_set_display ( Form form , int label , int display_mask ) ;

 extern int FIg_set_erase_color ( Form form , int label ,
     int erase_color ) ;



 extern int FIg_set_font ( Form form , int label , char * fontname ,
     double bodysize ) ;

 extern int FIg_set_help_topic ( Form form , int label ,
    char * help_topic ) ;

 extern int FIg_set_high_value ( Form form , int label ,
    double high_value ) ;



 extern int FIg_set_increment ( Form form , int label , double increment ) ;

 extern int FIg_set_justification ( Form form , int label , int just ) ;

 extern int FIg_set_line_depth ( Form form , int label , int depth ) ;

 extern int FIg_set_line_style ( Form form , int label , int style ) ;

 extern int FIg_set_line_weight ( Form form , int label , int wt ) ;

 extern int FIg_set_location ( Form form , int label ,
    int xpos , int ypos ) ;

 extern int FIg_set_low_value ( Form form , int label , double low_value ) ;

 extern int FIg_set_minor_increments ( Form form , int label , int incrs ) ;

 extern int FIg_set_next_in_seq ( Form form , int label , int next_label ) ;

 extern int FIg_set_notify_off ( Form form , int label ) ;

 extern int FIg_set_notify_on ( Form form , int label ) ;

 extern int FIg_set_off_color ( Form form , int label , int off_color ) ;

 extern int FIg_set_off_color2 ( Form form , int label , int off_color2 ) ;

 extern int FIg_set_off_symbol_index ( Form form , int label ,
          int sym_index ) ;

 extern int FIg_set_off_text ( Form form , int label , char * string ) ;

 extern int FIg_set_on_color ( Form form , int label , int on_color ) ;

 extern int FIg_set_on_color2 ( Form form , int label , int on_color2 ) ;

 extern int FIg_set_on_symbol_index ( Form form , int label ,
         int sym_index ) ;

 extern int FIg_set_on_text ( Form form , int label , char * text ) ;

 extern int FIg_set_orientation ( Form form , int label ,
     int orientation ) ;

 extern int FIg_set_pass_data ( Form form , int label , int next_label ) ;

 extern int FIg_set_size ( Form form , int label , int xsize , int ysize ) ;

 extern int FIg_set_standard_variables ( Form form , int label ,
     struct standard_st * str ) ;

 extern int FIg_set_state ( Form form , int label , int state ) ;

 extern int FIg_set_state_off ( Form form , int label ) ;

 extern int FIg_set_state_on ( Form form , int label ) ;

 extern int FIg_set_symbol_file ( Form form , int label ,
     char * symbol_file ) ;

 extern int FIg_set_symbol_index ( Form form , int label , int sym_index ) ;

 extern int FIg_set_text ( Form form , int label , char * text ) ;

 extern int FIg_set_text_style ( Form form , int label , int style ) ;

 extern int FIg_set_user_pointer ( Form form , int label ,
      char * user_pointer ) ;

 extern int FIg_set_value ( Form form , int label , double value ) ;

 extern int FIg_set_value_format ( Form form , int label , int field_width ,
      int decimal_accuracy ) ;

 extern int FIg_start_seq ( Form form , int label ) ;

 extern int FIg_unhilite ( Form form , int label ) ;

 extern int FIgrp_add_to_group ( Form form , int group_gadget_label ,
    int to_group_label ) ;

 extern int FIgrp_callback ( Form form , int group_label ,
       void ( * callback_routine ) ( ) , int user_arg ) ;

 extern int FIgrp_delete ( Form form , int group_label ) ;

 extern int FIgrp_get_pass ( Form form , int group_label ,
       int * pass_status ) ;

 extern int FIgrp_get_single_select ( Form form , int group_label ,
         int * status ) ;

 extern int FIgrp_set_pass_off ( Form form , int group_label ) ;

 extern int FIgrp_set_pass_on ( Form form , int group_label ) ;

 extern int FIgrp_set_single_select_off ( Form form , int group_label ) ;

 extern int FIgrp_set_single_select_on ( Form form , int group_label ) ;

 extern int FIh_attach_to_parent ( Form form , Form parent_form ) ;

 extern int FIh_callback ( Form form , int mode , int top_flag ,
     void ( * routine ) ( ) , int user_arg ) ;

 extern int FIh_detach_from_parent ( Form form ) ;

 extern int FIh_get_reply_routine ( Form form ,
       void ( * * reply_routine ) ( ) ) ;

 extern int FIh_reply_to_parent ( Form form , int user_arg ) ;

 extern int FIh_set_reply_routine ( Form form , void ( * reply_routine ) ( ) ) ;

 extern int FImcf_delete_col ( Form form , int label , int col ) ;

 extern int FImcf_get_active_col ( Form form , int label ,
      int * col , int * pos ) ;

 extern int FImcf_get_attr ( Form form , int label , long * attr_mask ) ;

 extern int FImcf_get_col_size ( Form form , int label , int col ,
    int * xsize , int * ysize ) ;

 extern int FImcf_get_high_value ( Form form , int label , int col ,
      double * value ) ;

 extern int FImcf_get_justification ( Form form , int label , int col ,
         int * just ) ;

 extern int FImcf_get_low_value ( Form form , int label , int col ,
     double * value ) ;

 extern int FImcf_get_num_cols ( Form form , int label , int * num_col ) ;

 extern int FImcf_get_num_vis_cols ( Form form , int label ,
        int * num_col ) ;

 extern int FImcf_get_scroll_link ( Form form , int master_mcf ,
       int * header_mcf ) ;

 extern int FImcf_get_select ( Form form , int label , int row ,
         int * sel_flg ) ;

 extern int FImcf_get_view_data ( Form form , int label , int * col_offset ,
     int * num_vis_cols ) ;

 extern int FImcf_insert_col ( Form form , int label , int col , int chars ,
         int mode , int Type ) ;

 extern int FImcf_set_active_col ( Form form , int label , int col ,
      int pos ) ;

 extern int FImcf_set_attr ( Form form , int label , long attr_mask ) ;

 extern int FImcf_set_col_size ( Form form , int label , int col ,
    int xsize , int ysize ) ;

 extern int FImcf_set_high_value ( Form form , int label , int col ,
      double value ) ;

 extern int FImcf_set_justification ( Form form , int label , int col ,
         int just ) ;

 extern int FImcf_set_low_value ( Form form , int label , int col ,
     double value ) ;

 extern int FImcf_set_num_cols ( Form form , int label , int num_col ) ;

 extern int FImcf_set_num_vis_cols ( Form form , int label , int num_col ) ;

 extern int FImcf_set_scroll_link ( Form form , int master_mcf ,
       int header_mcf ) ;

 extern int FImcf_set_select ( Form form , int label , int row ,
         int sel_flg ) ;

 extern int FIrect_get_style ( Form form , int label , int * style ) ;

 extern int FIrect_set_style ( Form form , int label , int style ) ;

 extern int FIscrl_get_view ( Form form , int label , double * view ) ;

 extern int FIscrl_set_view ( Form form , int label , double view ) ;






 extern int MI_enter ( void ) ;

 extern int MI_get_menu_move_routine ( void ( * * menu_move_routine ) ( ) ) ;

 extern int MI_get_palette_vert_offset ( int * offset ) ;

 extern int MI_get_tear_off_notification_routine (
     void ( * * tear_off_routine ) ( ) ) ;

 extern int MI_get_window_routine ( void ( * * window_routine ) ( ) ) ;

 extern int MI_pop_up_button ( Form menu , int gadget_label ) ;

 extern int MI_set_menu_move_routine ( void ( * menu_move_routine ) ( ) ) ;

 extern int MI_set_palette_vert_offset ( int offset ) ;

 extern void MI_set_tear_off_menu_modify_routine ( void ( * p_function ) ( ) ) ;

 extern int MI_set_tear_off_notification_routine (
     void ( * tear_off_routine ) ( ) ) ;

 extern int MI_set_window_routine ( void ( * window_routine ) ( ) ) ;

 extern int MIm_display ( Form menu ) ;

 extern int MIm_new ( int menu_type , int menu_label , char * menu_name ,
       int ( * notification_routine ) ( ) , Form * menu ) ;

 extern int MIm_set_move_icon_off ( Form menu ) ;

 extern int MIm_set_move_icon_on ( Form menu ) ;

 extern int MS_delete_menus ( void ) ;

 extern int MS_display_menus ( void ) ;

 extern int MS_enter ( void ) ;

 extern int MS_erase_menus ( void ) ;

 extern int MS_get_startup_file ( char file [ ] ) ;

 extern int MS_init_menus ( void ) ;

 extern int MS_pop_up_last_button ( void ) ;

 extern int MS_process_pocket ( int vs , int xpos , int ypos ) ;

 extern int MS_save_locations ( char * file ) ;

 extern int MS_set_startup_file ( char * file ) ;

 extern int MS_swap_menu ( int menu_type , char * menu_name ) ;

 extern int FI_set_auto_scaling_factors ( double scale_factor_x , double scale_factor_y ) ;
 extern int FI_get_auto_scaling_factors ( double * scale_factor_x , double * scale_factor_y ) ;
#line 15  "/usr/ip32/exnucdp/include/OMtypes.h"
 typedef int    ( * OM_p_FUNCPTR ) ( ) ;
 typedef unsigned int   OMuint ;
 typedef unsigned long int  OMulong ;
 typedef unsigned short int  OMuword ;
 typedef short int   OMword ;
 typedef unsigned char   OMbyte ;

 typedef unsigned short int  uword ;


 typedef unsigned long int OM_S_OBJID ;
 typedef unsigned long int * OM_p_OBJID ;






 typedef struct OM_sd_dlink * OM_p_DLINK ;

 struct OM_sd_dlink
 {
  OM_p_DLINK next ;
  OM_p_DLINK prev ;
 } ;
 typedef struct OM_sd_dlink OM_S_DLINK ;
#line 78  "/usr/ip32/exnucdp/include/OMminimum.h"
 struct OM_sd_objecthdr
 {
  OM_S_OBJID   oid ;
#line 91  "/usr/ip32/exnucdp/include/OMminimum.h"
  OMuint    i_size ;
 } ;
 typedef struct OM_sd_objecthdr  OM_S_OBJECTHDR ;
 typedef struct OM_sd_objecthdr  * OM_p_OBJECTHDR ;

 enum   OM_e_wrt_flag  { OM_e_wrt_object = 25 ,
             OM_e_wrt_ancestor = 26 ,
         OM_e_wrt_message = 26 ,
         OM_e_wrt_parent = 27 } ;






 typedef enum   OM_e_wrt_flag  OM_E_WRT_FLAG ;

 enum OM_e_inc_flag { OM_e_inclusive = 27 ,
    OM_e_exclusive } ;
 typedef enum OM_e_inc_flag OM_E_INC_FLAG ;

 enum OM_e_ovrwrt_flg { OM_e_overwrite = 13 ,
    OM_e_no_ovrwrt ,
                         OM_e_overwrite_rrr } ;
 typedef enum OM_e_ovrwrt_flg OM_e_OVRWRT_FLG ;





 struct OM_sd_neighbor
 {
  OM_S_OBJID  groupid ;
  OMuword  clusterid ;
 } ;
 typedef struct OM_sd_neighbor OM_S_NEIGHBOR ;
 typedef struct OM_sd_neighbor * OM_p_NEIGHBOR ;








 struct OM_sd_methselect
 {
  OMuword  DefClassid ;
  OMuword  ReqClassid ;
  OMuword  FuncIndex ;
 } ;
 typedef struct OM_sd_methselect * OM_p_METHSELECT ;
 typedef struct OM_sd_methselect OM_S_METHSELECT ;





 struct OM_sd_message
 {
  OM_S_METHSELECT select ;
  OMuword  size ;
  char    * p_arglist ;
 } ;
 typedef struct OM_sd_message * OM_p_MESSAGE ;
 typedef struct OM_sd_message OM_S_MESSAGE ;



 struct OM_sd_varlenarr_descr
 {
  int   i_offset ;
  OMuint  i_count ;
 } ;
 typedef struct OM_sd_varlenarr_descr OM_S_VARLENARR_DESCR ;
 typedef struct OM_sd_varlenarr_descr * OM_p_VARLENARR_DESCR ;




 struct OM_sd_channum
 {
  OMuword   classid ;
  OMuword   number ;
 } ;
 typedef struct OM_sd_channum OM_S_CHANNUM ;
 typedef struct OM_sd_channum * OM_p_CHANNUM ;





 struct OM_sd_object_linkage
 {
  OMuword  osnum ;
  OMuword  w_flags ;
  OM_S_CHANNUM  channum ;
  OM_S_OBJID  S_objid ;
 } ;
 typedef struct  OM_sd_object_linkage     * OM_p_OBJECT_LINKAGE ;
 typedef struct  OM_sd_object_linkage     OM_S_OBJECT_LINKAGE ;

 struct OM_sd_channel_hdr
 {

  OMuword flags ;
#line 216  "/usr/ip32/exnucdp/include/OMminimum.h"
 union
    {
    OMuword  count ;
    OMuword  isoindex ;
    } u1 ;

 } ;
 typedef struct OM_sd_channel_hdr OM_S_CHANNEL_HDR ;
 typedef struct OM_sd_channel_hdr * OM_p_CHANNEL_HDR ;

 struct OM_sd_channel_link
 {



  OM_S_CHANNEL_HDR hdr ;
  OM_S_CHANNUM  channum ;
  OM_S_OBJID  objid ;
 } ;
 typedef struct OM_sd_channel_link OM_S_CHANNEL_LINK ;
 typedef struct OM_sd_channel_link * OM_p_CHANNEL_LINK ;

 struct OM_sd_restricted_onechan
 {
  OM_S_CHANNEL_HDR  hdr ;
  OM_S_OBJID   objid ;
 } ;
 typedef struct OM_sd_restricted_onechan OM_S_RESTRICTED_ONECHAN ;
 typedef struct OM_sd_restricted_onechan * OM_p_RESTRICTED_ONECHAN ;

 struct OM_sd_little_tail
 {
  OMuword  collapse_count ;
  OMuword  last_index ;
 } ;
 typedef struct OM_sd_little_tail OM_S_LITTLE_TAIL ;
 typedef struct OM_sd_little_tail * OM_p_LITTLE_TAIL ;

 struct OM_sd_big_tail
 {
  OMuint  collapse_count ;
  OMuint  last_index ;
  OMuint  size ;
 } ;
 typedef struct OM_sd_big_tail OM_S_BIG_TAIL ;
 typedef struct OM_sd_big_tail * OM_p_BIG_TAIL ;



 struct OM_sd_chanselect
 {
  enum   { OM_e_name , OM_e_num , OM_e_addr } type ;
  union
  {
    char         * name ;
    OM_S_CHANNUM number ;
    OM_p_CHANNEL_HDR    * addr ;
  } u_sel ;
 } ;
 typedef struct OM_sd_chanselect OM_S_CHANSELECT ;
 typedef struct OM_sd_chanselect * OM_p_CHANSELECT ;

 typedef struct OM_sd_classdef  * OM_p_CLASSDEF ;
 typedef struct OM_sd_PCD  * OM_p_PCD ;




 struct OM_sd_spamapent
 {
  OM_p_CLASSDEF  p_acld ;
  OMuword  sdi ;
  OMuword  flags ;
#line 305  "/usr/ip32/exnucdp/include/OMminimum.h"
  union OM_sd_spamapent_state
  {
    OM_p_OBJECTHDR object ;

    struct
    {
      OMuword  dummy ;
      OMuword  clusterid ;

    } filed_obj ;

    OM_S_OBJID  freeoid ;
  } state ;
 } ;
 typedef struct OM_sd_spamapent  OM_S_SPAMAPENT ;
 typedef struct OM_sd_spamapent  * OM_p_SPAMAPENT ;



 struct OM_sd_RIP
 {
  OM_p_OBJECTHDR p_object ;
  OM_p_SPAMAPENT p_mapentry ;
 } ;
 typedef struct OM_sd_RIP OM_S_RIP ;
 typedef struct OM_sd_RIP * OM_p_RIP ;




 struct OM_sd_OShole
 {
  OMuint  FilePtr ;
  OMuint  size ;
 } ;
 typedef struct OM_sd_OShole OM_S_OSHOLE ;
 typedef struct OM_sd_OShole * OM_p_OSHOLE ;





 struct OM_sd_GROUP_extent
 {
 OM_S_OBJID beg_oid ;
 OMuint  size ;
 } ;
 typedef struct OM_sd_GROUP_extent OM_S_GROUP_EXTENT ;
 typedef struct OM_sd_GROUP_extent * OM_p_GROUP_EXTENT ;






 typedef struct OM_sd_FREE_CHUNK_DESCR * OM_p_FCD ;

 struct OM_sd_CLUSTER_freehdr
 {

 OM_p_FCD       p_fcd ;
 OMuint  size ;
 } ;

 typedef struct OM_sd_CLUSTER_freehdr OM_S_CLUSTFHDR ;
 typedef struct OM_sd_CLUSTER_freehdr * OM_p_CLUSTFHDR ;


 struct OM_sd_FREE_CHUNK_DESCR
 {
  OM_p_FCD        nextfcd ;
  OM_p_CLUSTFHDR  freehdr ;
  OMuint          size ;
 } ;

 typedef struct OM_sd_FREE_CHUNK_DESCR   OM_S_FCD ;
 typedef struct OM_sd_CLUSTER_composite  * OM_p_LCD ;
 typedef struct OM_sd_CSD  * OM_p_CSD ;

 struct OM_sd_PCD
 {
 OM_S_DLINK   pcdq ;

 OM_S_DLINK   lcfq ;
 OM_p_LCD     p_lcd ;
 OM_p_FCD     p_fcd ;
 OM_p_CSD     p_csd ;
 OMuint       i_totalfree ;
 OMuint       i_numfree_chunks ;
 OMuint       i_totalsize ;
 OMuint       i_cur_num_objects ;
 OMuint       i_cur_num_chunks ;
 OMuint       i_totalWsheap ;
 } ;
 typedef struct OM_sd_PCD OM_S_PCD ;

 typedef struct OM_sd_OSD * OM_p_OSD ;

 struct OM_sd_CLUSTER_composite
 {
 OM_S_DLINK pcdq_lh ;
 OM_p_PCD p_pcd ;


 OM_p_OSD p_osd ;
 OMuint  i_file_ptr ;
 OM_S_OBJID oid ;
 OMuword  w_cluster_num ;
 OMuword  flags ;




 OMuint  i_cur_bytes_allocated ;

 } ;
 typedef struct OM_sd_CLUSTER_composite OM_S_LCD ;

 struct OM_sd_CSD
 {
 OM_S_DLINK lcq ;

 OM_p_PCD p_pcd ;
 char          * p_addr ;
 OMuint  PreSendDepth ;
 OMuint  PostSendDepth ;
 OMuword  flag ;





 OMuword  index ;
 } ;
 typedef struct OM_sd_CSD OM_S_CSD ;






 struct OM_sd_OSCO
 {
   OMuword    w_classid ;
   OMuword    w_child_refcnt ;
   char       s_name [ 32               ] ;
   OMuword    w_oppmaj_version ;
   OMuword    w_oppmin_version ;
   OMuword    w_major_version ;
   OMuword    w_minor_version ;
   OMuint     i_refcnt ;
   OM_S_OBJID OSCO_oid ;
 } ;
 typedef struct OM_sd_OSCO        OM_S_OSCO ;
 typedef struct OM_sd_OSCO       * OM_p_OSCO ;






 struct OM_sd_OSD
 {
  OM_S_DLINK  lcfq_lh ;

  OM_S_OBJID     OSO_Oid ;
  OM_S_OBJID  Group0_Oid ;
  OMuword  OSnum ;
  char   name [ 128               ] ;
  char   InternalName [ 32                   ] ;
  OMbyte  type ;







  OMbyte  flags ;
#line 500  "/usr/ip32/exnucdp/include/OMminimum.h"
  OMuword  * ActToFil ;
  OMuword  * FilToAct ;
  OMuint  MaxOSSize ;
  OMuint  CurSpaceMapSize ;
  OM_p_SPAMAPENT Spacemap ;
  OMuint  ClustersSize ;

  OM_p_LCD  * Clusters ;
  OM_p_OSCO             * OSCO_list ;
  OMuint  OidFreelist ;
 } ;
 typedef struct OM_sd_OSD OM_S_OSD ;




 struct OM_sd_OSstatus
 {
   OMbyte     stattype ;








   union
   {

      struct
      {
         OMbyte     OStype ;

         OMbyte     OSflags ;
         OMuint     num_OMobjects ;
         OMuint     num_UserObjects ;
         char       CreTimeDate [ 16 ] ;
         char       TimeDate [ 16 ] ;


      } misc ;


      struct
      {
         OMuint   total_num ;
         OMuint   num_faulted ;
         OMuint   mem_allocated ;

         OMuint   num_chunks ;
      } cluster ;


      struct
      {
         OMuint   total_num ;
      } group ;
   } stat ;
 } ;

 typedef struct OM_sd_OSstatus   OM_S_OSSTATUS ;
 typedef struct OM_sd_OSstatus  * OM_p_OSSTATUS ;


 struct OM_sd_msgmap
 {
  OM_p_FUNCPTR  * MethTbl ;
  OMuint  offset ;
  OMuword  classid ;
  OMuword  NumChan ;
  struct OM_sd_channel_defn * ChanDefns ;
 } ;
 typedef struct OM_sd_msgmap  OM_S_MSGMAP ;
 typedef struct OM_sd_msgmap  * OM_p_MSGMAP ;


 typedef struct OM_sd_ancestry * OM_p_ANCESTRY ;
 struct OM_sd_ancestry
 {
  OMuword  * p_classid ;
  int   ( * p_create_args ) ( ) ;
  OMuword  MajVer ;
  OMuword  MinVer ;
  OM_p_ANCESTRY  p_sibling ;
  OM_p_CLASSDEF  p_classdef ;
 } ;
 typedef struct OM_sd_ancestry OM_S_ANCESTRY ;





 struct OM_sd_classdef
 {
  OMuword  w_classid ;
  OMuint  i_instance_size ;
  OMuint  NewInstanceSize ;
  OMuword  w_major_version ;
  OMuword  w_minor_version ;
  OMuword  w_oppmaj_version ;
  OMuword  w_oppmin_version ;
  char   s_name [ 32               ] ;
  OMuint         flags ;



  struct OM_sd_varlenarr_defn * p_varlenarr_defns ;
  OMuword  w_num_varlenarrays ;
  OMuword  w_numparents ;
  struct OM_sd_ancestry * A_ancestor_list ;
  struct OM_sd_ancestry  * p_subclass_list ;
  struct OM_sd_channel_defn * ChanDefns ;
  OMuword  w_numchannels ;
  OMuword  w_nummethods ;
  struct OM_sd_methdefn * p_methdefns ;
  struct OM_sd_Dclass * p_instance_def ;
  OMuint  initial_size ;

  OMuint  NumRecClasses ;


  OMuword  w_maxclass ;

  OMuword  w_baseclass ;

  OMbyte  * p_transmap ;



  OMuword  NumMsgClasses ;
  OM_p_MSGMAP  MsgMap ;
 int     * p_createclass_args ;
 } ;
 typedef struct OM_sd_classdef  OM_S_CLASSDEF ;





 struct OM_sd_classlist {
  OMuword w_count ;
  OMuword       w_flags ;







  OMuword * p_classes ;
 } ;
 typedef struct OM_sd_classlist  OM_S_CLASSLIST ;
 typedef struct OM_sd_classlist  * OM_p_CLASSLIST ;





 struct OM_sd_tag_con_info
 {
   OM_S_OBJID         objid ;
   OM_S_CHANNUM       chan ;
   OMuword            index ;
   OMuint             tag ;
   OM_S_CHANNUM       tag_chan ;
   OMuword            tag_index ;
   OMuword            version ;
 } ;
 typedef struct OM_sd_tag_con_info OM_S_TAG_CON_INFO ;
 typedef struct OM_sd_tag_con_info * OM_p_TAG_CON_INFO ;


 typedef struct OM_sd_class_hash_ent * OM_p_CLASS_HASH_ENT ;
 struct OM_sd_class_hash_ent
 {
   OM_p_CLASSDEF        p_acld ;
   OM_p_CLASS_HASH_ENT  next ;
 } ;
 typedef struct OM_sd_class_hash_ent  OM_S_CLASS_HASH_ENT ;





 typedef struct OM_sd_orig_osname * OM_p_ORIGOSNAME ;

 struct OM_sd_orig_osname {
   OMuword osnum ;
   char orig_name [ 128               ] ;
   OM_p_ORIGOSNAME  next ;
 } ;

 typedef struct OM_sd_orig_osname OM_S_ORIGOSNAME ;


 typedef struct OM_sd_dup_intosname * OM_p_DUPINTOS ;

 struct OM_sd_dup_intosname {
   OMuword        osnum ;
   OMuword        num_dup ;
   OMuword       * dup_osnum ;
   char           orig_intname [ 32                   ] ;

   OM_p_DUPINTOS  next ;
   int           * more ;
 } ;
 typedef struct OM_sd_dup_intosname OM_S_DUPINTOS ;






 extern OMuword   OM_Gw_numclasses ;
 extern OMuword   OM_Gw_next_class_index ;
 extern OM_p_CLASSDEF  * OM_GA_active_classes ;
 extern OMuword   * OM_GA_active_to_filed ;
 extern OMuword   * OM_GA_filed_to_active ;
 extern  OMuword   * OM_GA_fa_mapsize ;
 extern OMuint   OM_Gf_consistent ;
 extern OMuint   OM_Gf_consistent_class ;
 extern OMuint   OM_Gf_bugcheck_fatal ;
 extern OMuint   OM_Gf_verbose_warning ;
 extern OMuint   OM_Gf_verbose_error ;
 extern  OMuint                  OM_Gf_tagged_connects ;
 extern OMuword   OM_Gw_current_OS ;
 extern OMuword   OM_Gw_senders_OS ;
 extern OMuword                  OM_Gw_tagged_osnum ;
 extern OM_S_OBJID  OM_GO_current_OS_objid ;
 extern OM_S_OBJID               OM_GO_current_MOSD ;
 extern OM_S_OBJID  NULL_OBJID ;
 extern OM_S_CHANNUM      NULL_CHANNUM ;
 extern OM_p_OSD   * OM_GA_OSDs ;
 extern OM_p_OSD   OM_Gp_CurOSD ;
 extern OM_p_SPAMAPENT  OM_Gp_CurSpaceMap ;
 extern OM_S_OBJID  OM_GO_TransOS_0 ;
 extern OMuword   OM_Gw_TransOSnum_0 ;
 extern OM_S_NEIGHBOR  OM_GS_NULL_NEIGHBOR ;
 extern OM_p_NEIGHBOR  OM_Gp_NULL_NEIGHBOR ;
 extern OM_S_MESSAGE             OM_GS_NULL_MESSAGE ;
 extern OM_p_MESSAGE             OM_Gp_NULL_MESSAGE ;
 extern OM_S_SPAMAPENT  OM_GS_NULL_SPAMAPENT ;
 extern OM_p_SPAMAPENT  OM_Gp_NULL_SPAMAPENT ;
 extern OMuword   OM_Gw_maxOS ;
 extern OMuword                  OM_Gw_RO_OS_count ;
 extern OM_p_OBJID               OM_GA_tag_oids ;
 extern struct OM_sd_tag_hash_entry * * OM_GA_p_tag_hashtable ;
 extern OMuword                  OM_Gw_tagcon_inc ;
 extern struct OM_sd_tagcon_link * * OM_GA_p_tagcon ;
 extern OMuword                  OM_Gw_tag_rec_extendsize ;
 extern OMuword                  OM_Gw_tag_hashtable_size ;
 extern OMuword                  OM_Gw_tag_hash_extendsize ;
 extern OMuint                   OM_Gf_tagging_enabled ;
 extern OM_S_CSD                 * OM_GA_CSDarray ;
 extern OMuint   OM_Gf_errToStdout ;
 extern OMuint   OM_Gf_val_cluster ;
#line 40  "/usr/ip32/exnucdp/include/exfi.h"
 struct EXFI_subform_st
 {
    int label ;
    int x ;
    int y ;
    OM_S_OBJID objid ;
 } ;

 struct EXFI_mouse_st
 {
    int x ;
    int y ;
    short numb ;
    short click ;
    short down ;
 } ;

 struct EXFI_data_st
 {
    int label ;
    int type ;
    int index ;
    int max_index ;
    int select_flag ;




    int sts ;
    union
    {
 OM_S_OBJID objid ;
 char state ;
 int ivalue ;
 double dvalue ;
 char alpha [ 132        ] ;
 struct EXFI_subform_st subform ;
 struct EXFI_mouse_st btn ;
    } value ;
 } ;
#line 37  "/usr/ip32/exnucdp/include/ex.h"
 extern OM_S_OBJID EX_active_module ;
 extern OMuword EX_active_OS_num ;
 extern int active_module_num ;
 extern OMuword OM_Gw_max_modules ;
 extern OMuword OM_Gw_max_ref_files ;

 extern int EX_max_modules ;
 extern int EX_max_ref_files ;



 struct  EX_button
 {
    IGRdouble   x ;
    IGRdouble   y ;
    IGRdouble   z ;
    IGRlong     window ;
    OM_S_OBJID  objid ;
    uword       osnum ;
    IGRshort    numb ;
    IGRshort    clicks ;
    IGRshort    button_down ;
 } ;


 struct EX_mouse
 {
    int window ;
    short x ;
    short y ;
    int wflag ;
 } ;


 struct module_params
 {
  int visible_flag ;
  OM_S_OBJID module_id ;
  char CS_OS_name [ 128               ] ;
 } ;

 struct module_instance_data
 {
  int visible_flag ;
 } ;

 struct EX_visible_module
 {
  uword obj_space_num ;
  OM_S_OBJID module_my_id ;
  OM_S_OBJID filed_id ;
  int        permis_flag ;
  int        no_scn_menu ;

 } ;

 struct EX_invisible_module
 {
  uword obj_space_num ;
  OM_S_OBJID module_my_id ;
  OM_S_OBJID filed_id ;
  int permis_flag ;
  int numof_opens ;
  int ref_flag ;
 } ;

 struct EX_global
 {
    IGRchar   filename [ 128               ] ;



    IGRchar   working_dir [ 128               ] ;

    IGRchar   support_dir [ 128               ] ;

    IGRint    module_type ;
 } ;

 struct EX_var_list
 {
    IGRint    var ;
    IGRchar   * var_value ;
    IGRint    * num_bytes ;




 } ;


 struct EXlstcol
 {
 IGRint stat ;
 OM_S_OBJID oid ;
 IGRchar string [ 256 ] ;
 } ;


 struct EXlstfnt
 {
 IGRint     fontid ;
 IGRdouble   size ;
 IGRdouble   rotation ;
 IGRchar     typeface [ 64 ] ;
 IGRint     len ;
 } ;


 struct EX_form_data_st
 {
    char form_name [ 20 ] ;
    struct EXFI_data_st data ;
 } ;


 struct EX_cmd
 {
    IGRchar * msg_key_ptr ;
    IGRchar * command_name_ptr ;
    int command_nbytes ;
    IGRchar command_key [ 13 ] ;
    IGRchar class_name [ 13 ] ;
    IGRlong type ;
    IGRlong exec_flag ;
    IGRlong immediate_flag ;

    IGRchar * path ;
    IGRchar * input_string ;
    IGRlong invis_cmd ;

    IGRchar * dload_name_ptr ;
 } ;









 struct EX_echo_button
 {
   OM_S_OBJID   objid ;
   OMuword      osnum ;
   int              x ;
   int              y ;
   int          btype ;
   int          state ;
   int        timetag ;
 } ;
 struct EX_funnode
 {
    int isfun ;
    union {
      int  ( * fun ) ( ) ;
      char * cmdkey ;
    } entry ;
    struct EX_funnode * next ;
    struct EX_funnode * prev ;
 } ;
#line 62  "/usr/ip32/exnucdp/include/expriv.h"
 struct EXevent_queue
 {
    struct EXevent_queue * next ;
    struct EXevent_queue * prev ;
    IGRlong     response ;
    IGRlong     byte_count ;
    IGRchar     buffer [ 1 ] ;
 } ;

 struct EX_cmd_ndx
 {
    int    lo ;
    int    hi ;
 } ;


 struct EX_cmd_cntrl
 {
    int no_of_cmd ;
    IGRlong mod_type ;
    IGRshort reference_count ;
    struct EX_cmd_ndx * cmd_ndx ;
    struct EX_cmd     * cmd ;
    struct EX_cmd_cntrl * next ;
 } ;

 struct EX_paper_cmd
 {
    int  x1 ;
    int  y1 ;
    int  x2 ;
    int  y2 ;
    int  resp ;
    char * input_string ;
 } ;

 struct EX_pmenu_entry
 {
   OM_S_OBJID win_id ;
   int  num_of_cmds ;
   struct EX_paper_cmd * p_cmd ;
   char menu_name [ 128 ] ;
 } ;



 struct OM_sd_OS_construct_args
 {
  char                  * s_name ;
  unsigned int          i_initsize ;
  int                   i_extsize ;
  unsigned int          i_init_number_objects ;
  int                   i_extcount ;

  unsigned int          i_number_objs ;

 } ;
 typedef struct  OM_sd_OS_construct_args       OM_S_FILEDOS_CONSTRUCT_ARGS ;

 struct EX_cmd_instring
 {
   char * instring ;
   int  size_avail ;
   struct EX_cmd_instring  * next ;
 } ;

 struct EX_nl
 {
   char name [ 15 ] ;
   struct EX_nl * next ;
   struct EX_nl * prev ;
 } ;


 struct EX_cmd_mode_resp_data
 {
    int   mode ;
    char  string [ 128 ] ;
 } ;
#line 157  "/usr/ip32/exnucdp/include/expriv.h"
 extern int FEI_set_form_icon_path ( void )         ;
 extern int get_modtype_data ( char * run_name , char * logo_ptr , char * module_class , char * srch_path , char * config_path , char * product_path )                                                                                                               ;
 extern int EX_get_dependency ( char * srch_path , struct EX_nl * na )                                      ;
 extern int EX_session_init_cmd ( struct EX_cmd_cntrl * cmd_cntrl )                                   ;
 extern int EX_file_init_cmd ( struct EX_cmd_cntrl * cmd_cntrl )                                   ;
 extern IGRint EX_cmdattach ( IGRlong * msg , IGRlong module_type , struct EX_cmd_cntrl * * cmd_cntrl )                                                                       ;
 extern int EX_file_create_list ( char * * entry , int * num_of_entry )                                    ;
 extern int EX_shutdowncmd ( struct EX_cmd_cntrl * cmd_cntrl )                                   ;
 extern int EX_get_cmd_info ( char * string , int mode , struct EX_cmd * cmdstr )                                                  ;

 extern IGRint EX_cmdinit ( IGRlong module_type , struct EX_cmd_cntrl * * cmd_list )                                                        ;
 extern IGRlong EX_cmdsrch ( IGRlong * msg , struct EX_cmd_cntrl * cmd_cntrl , IGRchar * keyin , struct EX_cmd * cmd , IGRint * response )                                                                                                       ;


 extern int EX_rm_dup_dep ( char * srch_path1 , struct EX_nl * name )                                         ;

 extern int EX_exit_function ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )
                                ;

 extern int EX_exit_function_no_save ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )
                                ;

 extern int EX_retrieve_function ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )
                                ;
 extern int EX_save_function ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )
                                ;
 extern int som_is_om_file ( char * filename , short * p_major , short * p_minor , char * p_mach_type , int * p_file_type )
                                       ;
#line 35  "/usr/ip32/exnucdp/include/wl.h"
 typedef unsigned int  WLuint32 ;
 typedef unsigned short  WLuint16 ;
 typedef unsigned char WLuint8 ;
 typedef int   WLint32 ;
 typedef short   WLint16 ;
 typedef char   WLint8 ;
 typedef WLuint32        WLcolorref ;
#line 55  "/usr/ip32/exnucdp/include/wl.h"
 typedef int         WLhwin_no ;
 typedef void          * WLhandle ;
 typedef void          * WLwndproc ;
 typedef int             WLcursor ;
 typedef int             WLcolormap ;
 typedef int  WLfast_buffer ;
 typedef int             WLfont ;
#line 143  "/usr/ip32/exnucdp/include/wl.h"
 struct WLinit
 {
   int    batch_mode ;

 } ;

 struct WLinit_ret_val
 {
   int   dummy ;
 } ;
#line 183  "/usr/ip32/exnucdp/include/wl.h"
 struct WLnative_info
 {
   int           vs_no ;
   WLhwin_no     base_win ;
   WLcolormap    vlt_no ;
   WLcursor      cursor ;
 } ;
#line 211  "/usr/ip32/exnucdp/include/wl.h"
 struct WLcontext_info
 {
   int           base_cmap_type ;
   int           base_depth ;
   int           hilite_used ;
   int           flags ;
 } ;

 struct WLcontext_interaction
 {
   WLuint32  context_no ;
   int   number ;
   int   num_of_coexists ;
 } ;

 struct WLbounds
 {
   int   x , y ;
   int   width ;
   int   height ;
 } ;

 struct WLcmap_entry
 {
   WLuint16  slot ;
   WLuint16  red , green , blue ;
   WLuint32  flags ;
 } ;









 struct WLraster_data
 {
   int          x , y ;
   WLuint32     width , height ;
   char         * buffer ;
   WLuint16 lras_no ;
 } ;



 struct WLpoint
 {
   short  x , y ;
 } ;
#line 274  "/usr/ip32/exnucdp/include/wl.h"
 struct WLrect
 {
   int   x , y ;
   int   width , height ;
 } ;
#line 428  "/usr/ip32/exnucdp/include/wl.h"
 extern int WLadd_hardware_window ( WLhwin_no hwin_no , WLuint32 context_no , struct WLnative_info * native_info , WLuint32 * lwin_no )



                      ;

 extern int WLset_num_wm_colors ( WLint32 num_wm_colors )
                           ;

 extern int WLset_num_ingr_colors ( WLint32 num_ingr_colors )
                             ;

 extern int WLchange_window_cmap ( WLuint16 lscreen_no , WLuint32 lwin_no , WLuint32 context_no )


                         ;

 extern int WLcreate_context ( WLuint16 lscreen_no , struct WLcontext_info * context , int ( * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * cmap_init ) ( WLuint32 context_no ) , WLuint32 * context_no )
#line 468  "/usr/ip32/exnucdp/include/wl.h"
                         ;

 extern int WLcreate_window ( WLuint16 lscreen_no , char * name , struct WLbounds * bounds , int border_width , WLuint32 context_no , WLuint32 * lwin_no )





                       ;

 extern int WLdelete_context ( WLuint16 lscreen_no , WLuint32 context_no )

                        ;

 extern int WLdelete_window ( WLuint32 lwin_no )
                      ;

 extern int WLinitialize ( struct WLinit * init_struct , struct WLinit_ret_val * init_ret )

                                     ;

 extern int WLflush ( WLuint32 lwin_no )
                      ;

 extern int WLfree ( void * ptr )
               ;

 extern int WLget_active_screen ( WLuint16 * lscreen_no , int * screen_type )

                      ;

 extern int WLget_context_depth ( WLuint32 context_no , int * depth )

                 ;

 extern int WLget_number_of_screens ( int * num_screens , WLuint16 * * list_of_screens )

                                ;

 extern int WLget_logical_screen_from_window ( WLhwin_no hwin_no , WLuint16 * lscreen_no )

                         ;

 extern int WLget_logical_screen_from_screen ( int screen_no , WLuint16 * lscreen_no )

                         ;

 extern int WLget_window_name ( WLuint32 lwin_no , char * * name )

                 ;

 extern int WLget_logical_window ( WLhwin_no hwin_no , WLuint32 * lwin_no )

                      ;

 extern int WLget_native_info ( WLuint32 lwin_no , WLuint32 context_no , struct WLnative_info * native_info )


                                      ;

 extern int WLget_screen_depth ( WLuint16 lscreen_no , int hilite_used , int * depth )


                ;

 extern int WLget_screen_size ( WLuint16 lscreen_no , int * width , int * height )


                 ;

 extern int WLget_window_screen ( WLuint32 lwin_no , WLuint16 * lscreen_no )

                          ;

 extern int WLbell ( WLuint32 lwin_no , int percent )

                 ;

 extern int WLget_user_data ( WLuint32 lwin_no , void * * exnuc_data , void * * data1 )


                 ;

 extern int WLget_collapse_parms ( WLuint32 lwin_no , int * x , int * y )


           ;

 extern int WLset_user_data ( WLuint32 lwin_no , void * * exnuc_data , void * * data1 )


                 ;

 extern int WLset_collapse_parms ( WLuint32 lwin_no , int x , int y , int collapse_state )



                        ;

 extern int WLpack_rgb_colorref ( WLuint32 red , WLuint32 green , WLuint32 blue , WLcolorref * color_ref , WLuint32 physical )




                      ;

 extern int WLpack_index_colorref ( WLuint32 color_index , WLcolorref * color_ref , WLuint32 physical )


                      ;

 extern int WLmap_colorref ( WLuint32 lwin_no , WLcolorref color_ref , WLuint32 * color_index , WLuint32 * red , WLuint32 * green , WLuint32 * blue , WLuint32 * color_flag )






                         ;

 extern int WLset_window_name ( WLuint32 lwin_no , char * new_name )

                    ;

 extern int WLset_active_symbology ( WLuint32 lwin_no , WLcolorref color_ref , int lstyle_no , WLuint16 blend , int weight , int change_mask )





                     ;

 extern int WLset_clip_box ( WLuint32 lwin_no , WLuint32 context_no , int xmin , int ymin , int width , int height )





               ;

 extern int WLread_cmap_entries ( WLuint32 context_no , int num_entries , struct WLcmap_entry * cmap_entries )


                                       ;

 extern int WLget_number_of_contexts_possible ( WLuint16 lscreen_no , WLuint32 context_no , int * num_possible )


                       ;

 extern int WLget_screen_contexts ( WLuint16 lscreen_no , int base_cmap_type , int hilite_used , int * num_contexts , struct WLcontext_info * * contexts )




                                      ;

 extern int WLset_window_bounds ( WLuint32 lwin_no , struct WLbounds * bounds )

                             ;

 extern int WLget_window_bounds ( WLuint32 lwin_no , struct WLbounds * bounds , struct WLbounds * area_bounds )


                                  ;

 extern int WLget_window_contexts ( WLuint32 lwin_no , int * num_contexts , WLuint32 * * context_no , struct WLcontext_info * * contexts )



                                      ;

 extern int WLget_context_info ( WLuint32 context_no , struct WLcontext_info * context_info )

                                        ;

 extern int WLload_cmap_entries ( WLuint32 context_no , int num_entries , struct WLcmap_entry * cmap_entries )


                                       ;

 extern int WLblock_move ( WLuint32 lwin_no , WLuint32 context_no , int src_x , int src_y , int width , int height , int dest_x , int dest_y )







               ;

 extern int WLclear_window ( WLuint32 lwin_no )
                      ;

 extern int WLdisplay_window ( WLuint32 lwin_no )
                      ;

 extern int WLdraw_2D_line_string ( WLuint32 lwin_no , int npoints , struct WLpoint * points )


                            ;

 extern int WLdraw_2D_point_string ( WLuint32 lwin_no , int npoints , struct WLpoint * points )


                            ;

 extern int WLdraw_polygon ( WLuint32 lwin_no , int num_points , struct WLpoint * points , WLuint32 fill )



                  ;

 extern int WLdraw_rectangle ( WLuint32 lwin_no , struct WLrect * rect , WLuint32 fill )


                  ;

 extern int WLget_defined_style ( int lstyle_no , WLuint16 * pattern )

                       ;

 extern int WLget_raster_data ( WLuint32 lwin_no , WLuint32 context_no , struct WLraster_data * image )


                                ;

 extern int WLhide_cursor ( WLuint32 lwin_no , WLuint32 flag )

                   ;

 extern int WLmouse_position ( WLuint32 lwin_no , int * x , int * y , int * in_window , int * key_buttons )




                                    ;

 extern int WLpop_window_to_top ( WLuint32 lwin_no )
                     ;

 extern int WLpop_window_to_bottom ( WLuint32 lwin_no )
                     ;

 extern int WLput_raster_data ( WLuint32 lwin_no , WLuint32 context_no , struct WLraster_data * image )


                                ;

 extern int WLshow_cursor ( WLuint32 lwin_no )
                      ;

 extern int WLdefine_style ( int lstyle_no , WLuint16 pattern )

                      ;



 extern int WLdefine_cursor ( WLuint32 lwin_no , char * data , char * mask , int length , int width , int lfgcolor , int lbgcolor , int x_hot , int y_hot )








              ;


 extern int WLcreate_raster_data ( WLuint32 win_no , WLuint32 context_no , struct WLraster_data * image , int x , int y , int width , int height , int bits_per_pixel , WLuint32 buffer_type , char * buffer )









                 ;

 extern int WLfree_raster_data ( struct WLraster_data * image )
                                ;

 extern int WLcreate_context_native_info ( WLuint16 lscreen_no , struct WLcontext_info * context , int ( * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * cmap_init ) ( WLuint32 context_no ) , struct WLnative_info * native_info , WLuint32 * context_no )
#line 777  "/usr/ip32/exnucdp/include/wl.h"
                         ;

 extern int WLenter_dynamics ( WLuint32 lwin_no )
                     ;

 extern int WLexit_dynamics ( WLuint32 lwin_no )
                     ;

 extern int WLset_event_mask ( WLuint32 lwin_no , WLuint32 event_mask )

                        ;

 extern int WLget_event_mask ( WLuint32 lwin_no , WLuint32 * event_mask )

                         ;

 extern int WLsync_buffers ( WLuint32 lwin_no )
                     ;

 extern int WLenter_db ( WLuint32 lwin_no )
                      ;

 extern int WLexit_db ( WLuint32 lwin_no )
                      ;

 extern int WLdraw_text ( WLuint32 lwin_no , int x , int y , char * text , int length )




                ;

 extern int WLdraw_bitmap ( WLuint32 lwin_no , int x_org , int y_org , int width , int height , unsigned char * bitmap )





                           ;

 extern int WLset_dynamics_drawing_mode ( WLuint32 lwin_no , int mode )

              ;

 extern int WLexit ( void )
          ;

 extern int WLactivate_symbology ( WLuint32 lwin_no , int fill_flag , int force_flag )


                    ;

 extern int WLget_window_base_context ( WLuint32 lwin_no , WLuint32 * base_context_no )

                               ;

 extern int WLchange_context_color_functions ( WLuint32 context_no , int ( * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * cmap_init ) ( WLuint32 context_no ) )
#line 854  "/usr/ip32/exnucdp/include/wl.h"
                              ;

 extern int WLclear_hilite ( WLuint32 lwin_no )
                     ;

 extern int WLget_context_color_functions ( WLuint32 context_no , int ( * * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * * cmap_init ) ( WLuint32 context_no ) )
#line 880  "/usr/ip32/exnucdp/include/wl.h"
                              ;

 extern int WLget_context_interaction ( WLuint16 lscreen_no , WLuint32 context_no , struct WLcontext_interaction * * inter )


                                          ;

 extern int WLget_native_info_from_context ( WLuint16 lscreen_no , WLuint32 context_no , struct WLnative_info * native_info )


                                       ;

 extern int WLget_number_of_color_cells ( WLuint32 context_no , int * num_of_cells )

                       ;

 extern int WLget_wm_colors ( WLuint32 context_no , int * num_entries , struct WLcmap_entry * * cmap_entries , int * ingr_num_entries , struct WLcmap_entry * * ingr_entries )




                                        ;

 extern int WLinstall_cmap ( WLuint32 lwin_no , WLuint32 context_no )

                         ;

 extern int WLset_active_screen ( WLuint16 lscreen_no )
                         ;

 extern int WLset_background ( WLuint32 lwin_no , WLcolorref color_ref )

                          ;

 extern int WLset_blendarea ( WLuint32 lwin_no , WLuint8 area_pattern [ 8 ] , int opaque_flag )


                     ;

 extern int WLmouse_win_position ( WLuint32 * lwin_no , int * x , int * y , int * in_window )



                    ;

 extern int WLset_active_SR_window ( WLhwin_no hwin_no )
                            ;

 extern int WLchange_window_screen ( WLuint32 lwin_no , WLuint32 new_context_no , WLuint16 new_lscreen_no , WLuint32 * new_lwin_no )



                           ;

 extern int WLset_drawing_mode ( WLuint32 lwin_no , int mode )

              ;

 extern int WLget_background ( WLuint32 lwin_no , WLcolorref * color_ref )

                           ;

 extern int WLget_screen_type ( WLuint16 lscreen_no , int * screen_type )

                      ;


 extern int WLset_active_font ( WLuint32 lwin_no , WLfont font_id )

                    ;

 extern int WLload_font ( WLuint16 lscreen_no , char * font_name , WLfont * font_id )


                     ;

 extern int WLget_hardware_screen_number ( WLhwin_no hwin_no , int * screen_no )

                    ;

 extern int WLunload_font ( WLuint16 lscreen_no , WLfont font_id )

                    ;

 extern int WLget_hardware_screen_from_logical ( WLuint16 lscreen_no , int * screen_no )

                         ;

 extern int WLis_region_empty ( WLuint32 lwin_no , int x , int y , int pixels , int * region )




                      ;

 extern int WLwindow_bounds_changed ( WLuint32 lwin_no , struct WLbounds * bounds )

                             ;

 extern int WLinit_default_colormap ( WLuint16 lscreen_no )
                         ;

 extern int WLget_default_colormap_entries ( WLuint32 context_no , int start_slot , int num_entries , int * num_valid_entries , struct WLcmap_entry * default_entries )




                                          ;

 extern int WLset_line_style_factor ( int flag )
              ;
#line 40  "/usr/ip32/exnucdp/include/exproto.h"
 extern int EX_load_button ( long * msg , char * filename )                              ;


 extern int EX_fork ( int num_entry , char * argu [ ] , int wait_flag , int redir_io , int * childpid , int mask , char * np1 , char * np2 , int delete_flag )                                                                                                                             ;


 extern int close_visible ( int save_flag , OM_S_OBJID my_id )                                    ;
 extern int EX_execute_mod ( void )         ;
 extern int EX_start_cmdserver ( int init , int exec )                       ;
 extern int EX_save_backup_file ( char * file_name )                    ;
 extern int EX_stop_auto_backup ( void )         ;
 extern int EX_context_switch_to ( char * exec_name )                    ;
 extern int EX_context_switch_1 ( char * exec_name )                    ;
 extern int EX_set_logo ( char * logo )               ;
 extern int EX_get_mloc_file ( char * file_name , int * have_file )                                    ;
 extern int EX_exit_function ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )                                                                ;



 extern int EX_findmod ( OM_S_OBJID * objid , uword * osnum )                                    ;
 extern int EX_get_exec_id ( OM_S_OBJID * objid , uword * osnum )                                    ;
 extern int EX_conv_pnt ( int window , struct EX_button * pnt1 , int * response )                                                      ;
 extern int EX_get_win_class ( int hw_win_no , char * class_name )                                    ;

 extern int EX_trans_win ( int hw_win , WLuint32 * lwin , OMuword * win_os , OM_S_OBJID * win_oid )
                                                                 ;




 extern int EX_add_win ( int hw_win_no , OM_S_OBJID objid , OMuword osnum )                                                   ;
 extern int EX_set_abs_dig ( int fm )           ;
 extern int EX_clear_abs_dig ( void )         ;
 extern int EX_wait_for_input ( int * response , char * response_data , int mode , int * num_bytes )                                                                 ;
 extern int EX_attach_listener ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_detach_listener ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_attach_generator ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_detach_generator ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_get_NOD ( char * NODname , OM_S_OBJID * pobjid , int create , OM_S_OBJID modid , OMuword mosnum )                                                                                    ;
 extern int EX_get_oid_nodname ( char * NODname , char * objname , OM_S_OBJID * pobjid , OM_S_OBJID modid , OMuword mosnum , int errprint )                                                                                                     ;
 extern int EX_add_name_nodname ( char * NODname , char * objname , OM_S_OBJID objid , OMuword mosnum )                                                                   ;
 extern int EX_remove_name_nodname ( char * NODname , char * objname , OMuword mosnum )                                                 ;
 extern int EX_get_oid_nodid ( OM_S_OBJID NODobjid , char * objname , OM_S_OBJID * pobjid , OM_S_OBJID modid , OMuword mosnum )                                                                                             ;
 extern int EX_add_name_nodid ( OM_S_OBJID NODobjid , char * objname , OM_S_OBJID objid , OMuword mosnum )                                                                         ;
 extern int EX_remove_name_nodid ( OM_S_OBJID NODobjid , char * objname , OMuword mosnum )                                                       ;
 extern int EX_attach_super ( IGRchar * super_class , OM_S_OBJID * super_id , OM_S_OBJID module_id , OMuword module_os , int wakeup_flag )
                                                                        ;
 extern int EX_get_global ( IGRint mode , struct EX_var_list * var , IGRint * which_error )                                                              ;
 extern int EX_inq_global ( struct EX_var_list * var , IGRint * which_error )                                                 ;
 extern int EX_set_global ( struct EX_var_list * var , IGRint * which_error )                                                 ;
 extern int EX_file_status ( OM_S_OBJID modid , uword modos , int * mode )                                             ;
 extern int EX_get_invis_info_by_index ( int index , OMuword * mod_osnum , OM_S_OBJID * mod_id , OM_S_OBJID * filed_id , int * flag , int * num_open , int * mod_type )                                                                                                                     ;
 extern int EX_is_visible ( char * mod_name )                   ;
 extern int EX_is_invis ( OMuword mod_osnum , int * index )                                  ;
 extern int EX_is_driver_exist ( void )         ;
 extern void EX_set_mod_no_scn_menu ( OMuword mod_osnum )                      ;
 extern int EX_is_scn_menu_present ( void )         ;
 extern void EX_print_module_table ( void )         ;
 extern int EX_get_modid_given_osnum ( OMuword mod_osnum , OM_S_OBJID * mod_id )                                          ;
 extern int EX_get_super ( OM_S_OBJID mod_id , OMuword mod_osnum , char * super_name , int create , char * super_classname , OM_S_OBJID * super_id , OMuword * super_osnum , int wakeup_flag )


                                            ;
 extern int EX_mod_info ( OMuword mod_osnum , int mode , char * app , int applen )                                                       ;
 extern int EX_is_help_active ( void )         ;
 extern int EX_help_flag ( int mode , int * flag )                        ;
 extern int EX_help_on ( int * oldflag )                 ;
 extern int EX_help_off ( int * oldflag )                 ;
 extern int EX_disp_flag ( int mode , int * flag )                        ;
 extern int EX_disp_on ( int * oldflag )                 ;
 extern int EX_disp_off ( int * oldflag )                 ;
 extern int EX_is_file_open ( char * filename )                   ;
 extern int EX_get_file_path ( char * env , char * string , char * outfile , int * ftype , int size )                                                                 ;
 extern int EX_check_input ( void )         ;
 extern int EX_check_input ( void )         ;
 extern int EX_set_up_file ( char * filename , char * seedfile , char * firstcmd , int * create )                                                                ;
 extern int EX_get_file_default ( char * filename , char * seedfile , char * firstcmd , int * create )                                                                ;
 extern int EX_call_firstcmd ( void )         ;
 extern int EX_firstcmd_putque ( char * field , int type )                          ;
 extern int EX_build_classlist ( char * classnames [ ] , int size , OM_p_CLASSLIST p_clist )                                                         ;
 extern int EX_get_working_dir ( char * name , int * len )                         ;
 extern int EX_get_support_dir ( char * name , int * len )                         ;



 extern int EX_cmdgetptr ( char * instring , char * * outstring )                                     ;
 extern int EX_cmdfreeptr ( void )         ;


 extern void EX_interrupt_hup ( int signo )              ;
 extern void EX_interrupt_int ( int signo )              ;
 extern void EX_interrupt_quit ( int signo )              ;
 extern void EX_interrupt_iot ( int signo )              ;
 extern void EX_interrupt_emt ( int signo )              ;
 extern void EX_interrupt_fpe ( int signo )              ;
 extern void EX_interrupt_ill ( int signo )              ;
 extern void EX_interrupt_bus ( int signo )              ;
 extern void EX_interrupt_segv ( int signo )              ;
 extern void EX_interrupt_sys ( int signo )              ;
 extern void EX_interrupt_pipe ( int signo )              ;
 extern void EX_interrupt_term ( int signo )              ;


 extern int EX_init_rec_echo ( char * filename )                   ;
 extern int EX_init_record ( char * filename )                   ;
 extern int EX_init_echo ( char * filename )                   ;
 extern int EX_close_rec_echo ( int flag )             ;
 extern int EX_clear_jnl_on_save ( void )         ;
 extern int EX_store_window_on_save ( void )         ;
 extern int EX_clear_command_on_save ( void )         ;
 extern int EX_restart_journal ( void )         ;


 extern int EX_mem_exist ( void )         ;
 extern int EX_add_mem ( char * mem_name , unsigned long int mem_val )                                              ;
 extern int EX_get_mem ( char * mem_name , unsigned long int * mem_val )                                               ;
 extern int EX_del_mem ( char * mem_name )                   ;
 extern void EX_print_mem ( void )         ;
 extern void EX_free_mem ( void )         ;


 extern int EX_mv ( char * source , char * target )                               ;
 extern int EX_cp ( char * source , char * target )                               ;
 extern int EX_rm ( char * file1 )                ;


 extern void EX_add_fun ( struct EX_funnode * * phead , int isfunc , void * f )                                                    ;
 extern void EX_del_fun ( struct EX_funnode * * phead , int ( * f ) ( ) )                                          ;
 extern void EX_empty_fun ( struct EX_funnode * * phead )                              ;
 extern void EX_print_fun ( struct EX_funnode * * phead )                              ;
 extern int EX_add_function ( int ( * fun ) ( ) , int mode )                            ;
 extern int EX_del_function ( int ( * fun ) ( ) , int mode )                            ;
 extern int EX_call_start_func ( void )         ;
 extern int EX_call_end_func ( void )         ;
 extern int EX_add_cmdserver_function ( int ( * fun ) ( ) )                  ;
 extern int EX_del_cmdserver_function ( int ( * fun ) ( ) )                  ;
 extern int EX_call_cmdserver_func ( int mode )             ;
 extern char * EX_get_and_del_first_fun ( struct EX_funnode * * phead )                              ;



 extern int EX_record_new_window ( int window )               ;



 extern int EX_dyn_process_input_event ( int mask )             ;
 extern int EX_wait_for_next ( int mask , int * event )                         ;
 extern int EX_inq_events ( int * event )               ;
 extern int EX_inq_button_data ( int * window , int * x , int * y , int * btype , int * state , int * timetag )                                                                      ;
 extern int EX_get_button_data ( int * window , int * x , int * y , int * btype , int * state , int * timetag )                                                                      ;
 extern int EX_get_refresh_area_data ( int * window , int * vs_no , int * x , int * y , int * x2 , int * y2 , int * ax1 , int * ay1 , int * ax2 , int * ay2 , int * opmask )                                                                                                                   ;
 extern int EX_inq_refresh_area_data ( int * window , int * vs_no , int * x , int * y , int * x2 , int * y2 , int * ax1 , int * ay1 , int * ax2 , int * ay2 , int * opmask )                                                                                                                   ;
 extern int EX_get_collapse_data ( int * window , int * opmask )                             ;
 extern int EX_inq_collapse_data ( int * window , int * opmask )                             ;
 extern int EX_get_delete_data ( int * window )                ;
 extern int EX_inq_delete_data ( int * window )                ;
 extern int EX_set_keyboard_buffer ( char * buffer , int count )                            ;
 extern int EX_get_keyboard_data ( int * count )               ;
 extern int EX_inq_keyboard_data ( int * count )               ;
 extern int EX_dyn_process_input_event ( int mask )             ;


 extern int backup_filenames ( int mod_num , char * nfile , char * file )                                         ;
 extern int module_backup ( OM_S_OBJID my_id )                     ;
 extern int remove_backup ( char * file )               ;


 extern int file_exists ( char * fname , char * env , char * path_dir , char * ret_fname )                                                            ;
 extern int filetest ( void )         ;
 extern int EX_check_file ( char * filename , int print_flag )                                   ;
 extern int EX_is_reg_file ( char * filename )                   ;




 extern void IGEExit ( int status )               ;
 extern int IGE_startup ( int argc , char * argv [ ] , int mode )                                     ;



 extern int IGEEnter ( void )         ;

 extern void EX_set_sync ( void )         ;
 extern void EX_sync_on ( void )         ;
 extern void EX_sync_off ( void )         ;
 extern int EX_is_batch ( void )         ;
 extern int EX_is_interactive ( void )         ;
 extern void EX_clear_timing ( void )         ;
 extern void EX_start_timing ( void )         ;
 extern void EX_end_timing ( char * string )                 ;
 extern void EX_print_timing ( void )         ;







 extern int get_modtype_data  ( char * run_name , char * logo_ptr , char * module_class , char * srch_path , char * config_path , char * product_path )




                                                     ;
 extern int Retrieve_OS ( char * in_filename , int flags , int * file_no , int type , int * msg , char * mount_name )                                                                                     ;
 extern int Retrieve_new_OS ( char * in_filename , int flags , int mod_type , int * file_no , int type , int * msg , char * mount_name )                                                                                                   ;
 extern int Close_OS ( int mod_num , int flag )                          ;
 extern int Save_OS ( int mod_num )                ;
 extern int Save_As_OS ( int mod_num , char * filename )                                ;
 extern int EX_retrieve_os ( char * in_filename , int flag , int mod_type , int * file_no , int f_stat , int type , int * msg , char * mount_name )                                                                                                              ;
 extern int print_invis ( void )         ;



 extern int JNL_init_journal ( char * filename , int excl_flag )                                  ;
 extern int JNL_init_playback ( char * filename , char * runname )                                  ;
 extern int JNL_echo_read_event_func ( void )         ;
 extern int JNL_record_new_window ( int window )               ;
 extern int JNL_echo_event ( int mask , int * event )                         ;
 extern int JNL_process_info_event ( int new_window )                   ;
 extern int JNL_process_del_info_event ( void )         ;
 extern int JNL_record_info_event ( int type , int event_nbytes , char * string )                                             ;
 extern int JNL_record_event ( int event )              ;
 extern int JNL_close_jnl ( void )         ;
 extern int JNL_close_jnl_pbk ( void )         ;
 extern int JNL_close_echo ( void )         ;
 extern int JNL_record_input ( int nbytes , char * buffer )                             ;
 extern int JNL_echo_input ( int nbytes , char * buffer )                             ;
 extern int JNL_adjust_echo ( void )         ;
 extern int JNL_adjust_echo_button ( void )         ;
 extern int JNL_adjust_echo_refresh_button ( void )         ;
 extern int JNL_adjust_echo_collapse_button ( void )         ;
 extern int JNL_adjust_delete_button ( void )         ;
 extern int JNL_wait_for_next ( int mask , int * event )                         ;
 extern int JNL_inq_events ( int * event )               ;
 extern int JNL_inq_button_data ( int * window , int * x , int * y , int * btype , int * state , int * timetag )                                                                      ;
 extern int JNL_get_button_data ( int * window , int * x , int * y , int * btype , int * state , int * timetag )                                                                      ;
 extern int JNL_process_slow_echo ( void )         ;
 extern int JNL_oldwindow_to_window ( int oldwindow , int * window )                               ;
 extern int JNL_get_refresh_area_data ( int * window , int * vs_no , int * x , int * y , int * x2 , int * y2 , int * ax1 , int * ay1 , int * ax2 , int * ay2 , int * opmask )                                                                                                                   ;
 extern int JNL_inq_refresh_area_data ( int * window , int * vs_no , int * x , int * y , int * x2 , int * y2 , int * ax1 , int * ay1 , int * ax2 , int * ay2 , int * opmask )                                                                                                                   ;
 extern int JNL_get_collapse_data ( int * window , int * opmask )                             ;
 extern int JNL_inq_collapse_data ( int * window , int * opmask )                             ;
 extern int JNL_get_delete_data ( int * window )                ;
 extern int JNL_inq_delete_data ( int * window )                ;
 extern int JNL_inq_user_data ( int * user_data )                   ;
 extern int JNL_get_user_data ( int * user_data )                   ;
 extern int JNL_inq_win_user_icon_data ( int * window , int * icon_id )                              ;
 extern int JNL_get_win_user_icon_data ( int * window , int * icon_id )                              ;
 extern int JNL_start_timer ( int delta_time , int repeatflag , int * timer_no )                                                  ;
 extern int JNL_stop_timer ( int timer_no )                 ;
 extern int JNL_get_timer_data ( int * timer_no )                  ;
 extern int JNL_echo_timer_data ( int * timer_no )                  ;
 extern int JNL_record_timer_data ( int * timer_no )                  ;
 extern int JNL_set_keyboard_buffer ( char * buffer , int count )                            ;
 extern int JNL_get_keyboard_data ( int * count )               ;
 extern int JNL_inq_keyboard_data ( int * count )               ;
 extern int JNL_inq_keyboard_buffer ( char * buf_addr [ ] , int * count )                                 ;
 extern int JNL_set_timer_playback ( int mytime )               ;
 extern int JNL_playback ( void )         ;
 extern int JNL_journal ( void )         ;
#line 352  "/usr/ip32/exnucdp/include/exproto.h"
 extern int module_build_path ( char * path_name )                    ;
 extern int module_set_pathname ( char * string )                 ;
 extern int module_set_def_dir ( void )         ;
 extern int fix_directory ( char * string )                 ;
 extern int module_get_def_dir ( int argc , char * argv [ ] )                           ;
 extern int valid_filename ( char * str , char * path )                          ;
 extern int EX_check_stat ( char * path , int * ftype )                           ;
 extern int EX_use_default_dir ( void )         ;
 extern int EX_get_executable_path ( char * path )               ;
 extern int EX_get_user_srch_path ( char * path )               ;


 extern int EX_set_srch_path ( void )         ;
 extern int EX_get_srch_path1 ( char * runname , int flag , char * buff , int * size )                                                   ;
 extern int EX_getpath ( int index , char * path , int len , int type )                                             ;
 extern int EX_get_srch_path ( char * * path , int * num_entry )                                ;
 extern int EX_set_search_path ( char * path )               ;
 extern int EX_restore_search_path ( void )         ;


 extern int EX_is_cmd_stack_empty ( void )         ;
 extern int EX_set_cmdserver_debug ( void )         ;
 extern int EX_help_init ( void )         ;
 extern int EX_blank_msg ( void )         ;
 extern int EX_ci_test_start ( char * filename )                   ;
 extern int EX_ci_test_end ( void )         ;
 extern int EX_set_auto_jump ( void )         ;
 extern int EX_jump ( void )         ;
 extern int EX_is_auto_jump ( void )         ;
 extern int EX_is_auto_test ( void )         ;
 extern int EX_auto_test_print_err ( int signo )              ;
 extern int EX_cmdserver_save_last_cmd ( void )         ;


 extern int EX_print_cmd ( char * file_name )                    ;
 extern int EX_dload_setup ( char * dload_name_ptr , char * * * argv_ptr , int * argc_ptr )                                                          ;
 extern int EX_dload_free ( void )         ;



 extern IGRint EX_cmddetach ( IGRlong * msg , IGRlong module_type )                                      ;



 extern void EX_push_quiet ( int respon )               ;
 extern void EX_pop_quiet ( void )         ;
 extern void EX_swap_quiet ( void )         ;
 extern void EX_clear_quiet ( void )         ;
 extern void EX_print_quiet ( void )         ;


 extern int CSclear_cache ( void )         ;
 extern int CSadd_to_cache ( char * name , int indx )                         ;
 extern int CSget_from_cache ( char * name , int * p_indx )                            ;
 extern int CSdump_cache ( void )         ;



 extern int EX_cmdstrip ( unsigned char * keyin )                         ;


 extern int UI_error ( char * msg )              ;


 extern int EX_get_keyin ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_keyin_no_cmd ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_get_input ( int * response , char * response_data , int mode )                                                 ;



 extern void UI_message ( char * symstr )                 ;
 extern void UI_status ( char * symstr )                 ;
 extern void UI_prompt ( char * symstr )                 ;
 extern void UI_echo ( char * symstr )                 ;


 extern int special_keyin ( int * response , char * response_data )                                       ;


 extern IGRint EXgetq ( IGRlong * return_code , int * response , IGRint * bytes_returned , IGRchar * buffer )                                                                                 ;
 extern IGRint EXputq ( IGRlong * msg , IGRlong position , int * response , IGRlong * byte_count , IGRchar * buffer )                                                                                        ;
 extern IGRint EXputq2 ( IGRlong * msg , IGRlong position , int * response , IGRlong * byte_count , IGRchar * buffer , IGRint mode )                                                                                                     ;
 extern IGRint EXputq_back ( IGRlong * msg , int * response , IGRlong * byte_count , IGRchar * buffer )                                                                      ;
 extern IGRint EXputq_front ( IGRlong * msg , int * response , IGRlong * byte_count , IGRchar * buffer )                                                                      ;
 extern int print_queue ( void )         ;
 extern int EX_flush_event_queue ( void )         ;
 extern int EX_peek_event_queue ( int * resp )              ;


 extern void EX_start_copyright ( void )         ;
 extern int EX_end_copyright ( void )         ;





 extern int EXget_form_decoration ( int * xdecor , int * ydecor )                             ;
 extern int EXget_form_offset ( int * xoffset , int * yoffset )                               ;



 extern int EX_extract_string ( void )         ;
 extern int EX_clean_str ( char * x , int no_space , int lower )                                     ;


 extern void UI_message ( char * symstr )                 ;
 extern void UI_status ( char * symstr )                 ;
 extern void UI_prompt ( char * symstr )                 ;
 extern void UI_echo ( char * symstr )                 ;


 extern int EX_get_keyin ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_keyin_no_cmd ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_get_input ( int * response , char * response_data , int mode )                                                 ;


 extern int EX_init_keyboard ( void )         ;
 extern IGRint EX_load_funckey ( int type , IGRchar * file_name )                                 ;
 extern int EX_update_funcky ( IGRchar * keynam , IGRint response , IGRshort waitf , IGRchar * key_str )                                                                       ;
 extern int pad_escape ( char * buffer , char * outbuffer )                                  ;
 extern int strip_esc_key ( char * response_data )                        ;
 extern int EX_keybd_process_return ( char * response_data , int num_char )                                      ;
 extern int EX_clear_keyin ( void )         ;
 extern int EX_clear_keyin ( void )         ;
 extern int EX_is_logkbd_inactive ( void )         ;
 extern int EX_cut_calc_input ( void )         ;
 extern int EX_paste_calc_input ( void )         ;


 extern int EX_module_construct ( int * msg , uword os_num , OM_S_OBJID filed_id , int new_module , int read_only , int activate , OM_S_OBJID * mod_id )                                                                                                                 ;
 extern int EX_get_seed_file ( char * seedfile , char * temp_file )                                    ;
 extern int EX_retrieve_module ( int * msg , char * inputstring , char * seedfile , int create , int activate , int save , OMuword * osnum , OM_S_OBJID * modid )                                                                                                                       ;
 extern int EX_retrieve_function ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )                                                                ;


 extern int EXupdatable_exist ( void )         ;


 extern int EX_save_module ( int active_module_num , int flag )                                     ;


 extern int EX_is_temp_wakeup ( void )         ;
 extern void EX_init_session ( void )         ;


 extern int EX_close1 ( int * last , int flag )                        ;
 extern int EX_create_prompt ( int message_number , int left_prompt_number , int right_prompt_number , char * string , int * response , char * response_data )

                                     ;
 extern void EX_exit1 ( int save )             ;
 extern int EX_filename1 ( char * result , int len )                          ;
 extern int EX_get_cmd_info ( char * string , int mode , struct EX_cmd * cmdstr )                                                  ;
 extern int EX_save1 ( char * fname )                ;
 extern int EX_saveas1 ( char * string )                 ;
 extern int EXget_file ( char * title , char * startdir , char * in_file , char * pat , int file_type [ ] , char * returned_filename , char * seedfile , int form_type , int * response , char * response_data )


                                     ;
 extern int EX_get_prod_info ( char * product , int code , char * * pstring )                                            ;
 extern int EX_get_prod_flag ( char * logo , int code , int flag )                                   ;
 extern int EX_get_prod_data ( char * runnameIn , char * logoIn , char * runnameOut , char * logoOut , char * module , char * dependency , char * configPath , char * prodPath , int * flags )


                            ;
#line 59  "/usr/ip32/exnucdp/include/igetypedef.h"
   typedef  OM_S_OBJID GRobjid ;
   typedef  OM_S_OBJECT_LINKAGE GRobjlink ;
   typedef  uword GRspacenum ;
   typedef  uword GRclassid ;
   typedef  uword GRchannum ;
   typedef  OM_S_OBJECTHDR GRobjecthdr ;
#line 51  "/usr/ip32/exnucdp/include/igewindow.h"
 struct DPws_flags
 {
     unsigned int display_origin : 1 ;




     unsigned int x_origin       : 1 ;


     unsigned int y_origin       : 1 ;


     unsigned int RFU            : 29 ;

 } ;



 struct win_var_list
 {
    IGRint var ;
    IGRchar * var_ptr ;
    IGRlong num_bytes ;
    IGRlong * bytes_returned ;
 } ;

 struct IGEdit_range
 {
  IGRint xlo ;
  IGRint ylo ;
  IGRint xhi ;
  IGRint yhi ;
 } ;


 struct dyn_flags
 {
   IGRboolean dyn_on ;
   IGRboolean mod_flag ;
 } ;

 struct IGEsrstate
 {
   IGRint count ;
   IGRint win_no ;
   IGRint objid [ 5 ] ;
   unsigned short osnum [ 5 ] ;
 } ;
#line 38  "/usr/ip32/exnucdp/include/igewinmacros.h"
 extern int DPsetinqwindow ( IGRlong * msg , IGRchar inq0_set1 , IGRlong * which_error , struct win_var_list * var_list , GRspacenum osnum , GRobjid window_objid )

                                          ;
 extern void IGEget_num_screens ( IGRint type , IGRint * num_screens )                                     ;
 extern void IGEget_num_screens ( IGRint type , IGRint * num_screens )                                     ;
 extern void IGEinq_term_info ( IGRint screen_no , IGRint * bg_planes , IGRint * hilite_plane , IGRint * vs_no , IGRint * num_of_planes , IGRint * plane_mask , IGRint * vlt_size , IGRint * dac_size , IGRint * x_extent , IGRint * y_extent , IGRint * fixed_vlt_start , IGRint * fixed_vlt_size , IGRint * db_enabled , IGRint * zb_enabled , IGRint * sr_vlt_enabled )




                                              ;
 extern IGRint IGEsractive ( void )         ;
 extern int IGEwin_const ( GRobjid * win_objid , IGRlong * msg , IGRchar * win_class , GRobjid mod_id , GRspacenum mod_osnum , IGRchar * name , int win_type , int screen , IGRboolean dep_indep , IGRdouble min_x , IGRdouble min_y , IGRdouble max_x , IGRdouble max_y , IGRint win_level , IGRshort right_space , IGRshort left_space , IGRshort top_space , IGRshort bottom_space , IGRboolean draw_border , IGRint icon_flags , IGRchar * symbol_name , IGRint symbol_number , IGRint collapse , IGRdouble * collapse_pos , IGRlong * cursor_enable_pattern , IGRlong * cursor_data_pattern , IGRlong * cursor_hot_spot )








                                                          ;
#line 22  "/usr/include/errno.h"
 extern int errno ;
#line 42  "/usr/include/sys/stat.h"
 struct stat {
 dev_t st_dev ;
 ushort st_ino ;
 ushort  st_mode ;
 short   st_nlink ;
 ushort  st_uid ;
 ushort  st_gid ;
 dev_t st_rdev ;
 off_t st_size ;
 time_t st_atime ;
 time_t st_mtime ;
 time_t st_ctime ;
 } ;






 struct statl {
 dev_t st_dev ;
 ulong st_ino ;
 ushort  st_mode ;
 short   st_nlink ;
 ushort  st_uid ;
 ushort  st_gid ;
 dev_t st_rdev ;
 off_t st_size ;
 time_t st_atime ;
 time_t st_mtime ;
 time_t st_ctime ;
 } ;
#line 120  "/usr/include/sys/stat.h"
 extern mode_t umask  ( mode_t cmask )                 ;
 extern int    mkdir  ( const char * path , mode_t mode )                                  ;
 extern int    mkfifo ( const char * path , mode_t mode )                                  ;
 extern int    stat   ( const char * path , struct stat * buf )                                       ;
 extern int    fstat  ( int filedes , struct stat * buf )                                  ;
 extern int    chmod  ( const char * path , mode_t mode )                                  ;
#line 38  "/usr/ip32/exnucdp/include/OMOSfilehdr.h"
 struct OM_sd_OS_filehdr_OM
 {
   short       magic ;
   OMuword     w_major_version ;
   OMuword     w_minor_version ;
   OMuword     w_num_clusters ;
   OMuint      i_size ;
   OMuint      checksum ;
   OMuint      i_num_objs ;
   OMuint      fp_OSO ;
   OMuint      fp_Cluster_instance ;
   OMuint      fp_OSO_instance ;
   OMuint      fp_cluster0 ;
   OMuint      i_spacemap_size ;
   OMuint      fp_appver ;
   OMuint      i_num_appver ;
   OM_S_OBJID  S_OS_object ;
   char        s_OSO_classname [ 64 ] ;
   OMuword     OSOfiledClassid ;
   char        unused [ 12 ] ;
   char        start_time [ 26 ] ;
   char        stop_time [ 26 ] ;
   char        write_msgstr [ 64 ] ;
   union
   {
      char     A_utsname [ 100 ] ;
      struct
      {
         char  sysname [ 9 ] ;
         char  nodename [ 9 ] ;
         char  release [ 9 ] ;
         char  version [ 9 ] ;
         char  machine [ 9 ] ;
         char  blank [ 55 ] ;
      } mach_name ;
   } syst ;
   char        A_unused [ 68 ] ;
   char        image_name [ 20 ] ;
   char        dros_msgstr [ 70 ] ;
   int         os_flags ;
   OMuint      hdr_checksum ;
 } ;
 typedef struct OM_sd_OS_filehdr_OM OM_S_OS_FILEHDR ;
 typedef struct OM_sd_OS_filehdr_OM * OM_p_OS_FILEHDR ;


 struct OM_sd_fileObjHeader
 {
   OMuint      tag ;
   OMuword     version ;
   OMuword     classid ;
   OMuint      oid ;
   OMuint      i_size ;
 } ;
 typedef struct  OM_sd_fileObjHeader    OM_S_FILEOBJHDR ;
 typedef struct  OM_sd_fileObjHeader    * OM_p_FILEOBJHDR ;


 struct OM_sd_lockFileRec
 {
   char        code ;
   char        osnum [ 6 ] ;
   char        pid [ 6 ] ;
   char        node [ 9 ] ;
   char        timestamp [ 22 ] ;
 } ;

 struct OM_sd_lockFiles
 {
   char                    * name ;
   struct OM_sd_lockFiles  * next ;
 } ;






 struct OM_sd_sysInfo {
   int   pageSize ;

   char  nodename [ 64 ] ;





   char  processor [ 9 ] ;
   char  sysname [ 9 ] ;
   char  release [ 9 ] ;
   char  version [ 9 ] ;
 } ;

 typedef struct OM_sd_sysInfo OM_S_SYSINFO ;
#line 58  "EXfile_form.C"
 extern  double  drand48 ( ) ;
#line 105  "EXfile_form.C"
 typedef  char  ENTRY [ 16       ] ;




 static char formname [ 256 ] , form_seedfile [ 256 ] , save_cwd [ 256 ] , * pat_txt ;
 static ENTRY * filnam , * dirnam , * product ;
 static int * formfile_type ;
 static int buf_siz , file_cnt ;
 static Form fp ;
 static int EX_os_filter ;
 static int number_types ;

 extern char * sys_errlist [ ] ;

 static int xmatch ( char * , char * ) ;
 static void List_Files ( Form ) ;
 static int Change_Dir ( char * ) ;
 static int Read_Dir ( Form ) ;
 static int EXgetfil_form_notif ( int , int , double , Form ) ;

 extern int EX_swap_string ( char * , char * , char * , char * ) ;
 extern int EX_qsort_list ( int , int , ENTRY [ ] , ENTRY [ ] ) ;
 extern char * expand_shell_vars ( char * ) ;
 extern int strcmp_ls ( char * , char * ) ;
 extern char * EXgetcwd ( char * , int ) ;

 char * EXgetcwd ( buf , size )
 char * buf ;
 int size ;
 {

 if ( buf  ||  ( buf = ( char * ) malloc ( size ) ) ) {

    register int ret_status , child ;
    int fildes [ 2 ] ;

    if ( pipe ( fildes ) == 0 ) {

 if ( child = vfork ( ) ) {





     if ( child != - 1 ) {
  do {
     ret_status = read ( fildes [ 0 ] , buf , size ) ;
  } while ( ret_status == - 1  &&  errno == 4     ) ;

  close ( fildes [ 0 ] ) ;
  close ( fildes [ 1 ] ) ;
  waitpid ( child , 0 , 0 ) ;
  if ( ret_status != - 1 ) {



      if ( ret_status < size ) buf [ ret_status - 1 ] = '\0' ;

      return ( buf ) ;

    }

        }

        } else {







     close ( ( ( & _iob [ 1 ] ) ) -> _file          ) ;
     dup ( fildes [ 1 ] ) ;
     close ( fildes [ 1 ] ) ;

     execlp ( "pwd" , "pwd" , ( char * ) 0 ) ;
 }
    }



 }
 return ( ( char * ) 0    ) ;
 }

 static int Change_Dir ( todir )
 char * todir ;
 {

  return chdir ( todir ) ;



 }

 static void List_Files ( fp )
 Form fp ;
 {
 register int i , fil_row = 0 ;
 ENTRY  * dp , * pf ;

 FIfld_set_num_rows ( fp , 21      , file_cnt ) ;


 if ( pat_txt [ 0 ] )
 {
   for ( i = 0 , dp = filnam , pf = product ; i < file_cnt ; i ++ , dp ++ , pf ++ )
   if ( strcmp_ls ( ( char * ) dp , pat_txt ) )
            {
     FIfld_set_text ( fp , 21      , fil_row , 0 , ( char * ) dp , 0 ) ;
     FIfld_set_text ( fp , 21      , fil_row ++ , 1 , ( char * ) pf , 0 ) ;
            }
   FIfld_delete_rows ( fp , 21      , fil_row , file_cnt - fil_row ) ;
 }
 else {
   for ( i = 0 , dp = filnam , pf = product ; i < file_cnt ; i ++ , dp ++ , pf ++ )
            {
     FIfld_set_text ( fp , 21      , i , 0 , ( char * ) dp , 0 ) ;
            FIfld_set_text ( fp , 21      , i , 1 , ( char * ) pf , 0 ) ;
            }
 }

 if ( strchr ( pat_txt , '!' ) )
     FIg_set_text ( fp , 10          , " ! not supported in match pattern" ) ;

 return ;
 }


 static int Read_Dir ( fp )

 Form fp ;
 {
 char  cwd [ 1024      ] ;
 int  dir_cnt , i ;

 DIR  * pdir ;
 struct dirent * dent ;

        char * msg_str = 0   ;



 struct stat stat_buf ;



 ENTRY  * dp ;
    FILE * file_p ;
    struct OM_sd_OS_filehdr_OM buffer ;
    int status ;

    status = ( int ) EXgetcwd ( cwd , 1024      ) ;
    if ( ! status )
    {
      FIg_set_text ( fp , 10          , sys_errlist [ errno ] ) ;

      Wait_timer ( 20 ) ;

      return ( 0 ) ;
    }




 dir_cnt = 0 ;
 pdir = ( DIR * ) opendir ( cwd ) ;
    if ( pdir )
     {
         msg_str = ( char * ) PDUtranslate_message ( 0x08709963             ) ;
  FIg_set_text ( fp , 10          , msg_str ) ;
  FIg_set_text ( fp , 14      , cwd ) ;
  FIfld_set_num_rows ( fp , 21      , 0 ) ;

    while ( dent = readdir ( pdir ) ) dir_cnt ++ ;

   if ( dir_cnt > buf_siz )
   {
  buf_siz = dir_cnt ;
  if ( filnam ) free ( filnam ) ;
  filnam = ( ENTRY * ) calloc ( buf_siz , sizeof ( ENTRY ) ) ;
  if ( ! filnam ) return ( 0 ) ;

  if ( product ) free ( product ) ;
  product = ( ENTRY * ) calloc ( buf_siz , sizeof ( ENTRY ) ) ;
  if ( ! product ) return ( 0 ) ;

  if ( dirnam ) free ( dirnam ) ;
  dirnam = ( ENTRY * ) calloc ( buf_siz , sizeof ( ENTRY ) ) ;
  if ( ! dirnam ) return ( 0 ) ;
   }

   dir_cnt = file_cnt = 0 ;
  seekdir ( pdir , 0L )              ;
  dent = readdir ( pdir ) ;

   while ( dent = readdir ( pdir ) )
   {

   stat ( dent -> d_name , & stat_buf ) ;
   if ( ! ( stat_buf . st_mode & 0010000 ) )




    {

  if ( ( stat_buf . st_mode & 0040000      ) )
  {
      strcpy ( dirnam [ dir_cnt ++ ] , dent -> d_name ) ;
  }
  else
  {
            if ( EX_os_filter )
               {
                file_p = ( FILE * ) fopen ( dent -> d_name , "r" ) ;
                if ( file_p )
                 {
                  status = fread ( & buffer , ( sizeof ( struct OM_sd_OS_filehdr_OM ) )
                                           , 1 , file_p ) ;
                  if ( buffer . magic == 0x4d4f  )
                    {

          strncpy ( filnam [ file_cnt ] , dent -> d_name , 14 ) ;





          strncpy ( product [ file_cnt ++ ] , buffer . image_name , 10 ) ;
                    }
                 fclose ( file_p ) ;
                 }
                }
               else
                {

        strncpy ( filnam [ file_cnt ] , dent -> d_name , 14 ) ;




                    file_p = ( FILE * ) fopen ( dent -> d_name , "r" ) ;
                    if ( file_p )
                     {
                      status = fread ( & buffer ,
                                  ( sizeof ( struct OM_sd_OS_filehdr_OM ) )
                                           , 1 , file_p ) ;
                      if ( buffer . magic == 0x4d4f  )
                       {
             strncpy ( product [ file_cnt ++ ] , buffer . image_name , 10 ) ;
                       }
                      else
                       {
                strcpy ( product [ file_cnt ++ ] , " " ) ;
                       }
                     fclose ( file_p ) ;
                     }
                }
  }
      }
 }
 closedir ( pdir ) ;

 EX_qsort_list ( 0 , dir_cnt - 1 , dirnam , 0 ) ;
 EX_qsort_list ( 0 , file_cnt - 1 , filnam , product ) ;

 FIfld_set_num_rows ( fp , 16     , dir_cnt ) ;
 for ( i = 0 , dp = dirnam ; i < dir_cnt ; i ++ , dp ++ )
  FIfld_set_text ( fp , 16     , i , 0 , ( char * ) dp , 0 ) ;

 List_Files ( fp ) ;

 FIg_set_text ( fp , 10          , "" ) ;
 return ( 1 ) ;
   }
  else

   {
    FIg_set_text ( fp , 10          , sys_errlist [ errno ] ) ;

    Wait_timer ( 20 ) ;

    return ( 0 ) ;
   }
 }
 static   int err = 0 ;
 /* ARGSUSED */
 static int EXgetfil_form_notif ( f_label , g_label , value , fp )

  int  f_label ;
  int  g_label ;
  double value ;
  Form  fp ;
 {
  char text_buff [ 1024      ] , * expanded_dir ;
  int sf , rp ;
  long  stat ;
  int   sts ;
  long status ;
  char tmp_file [ 256 ] ;
  char msg [ 512              ] ;
  char * msg_str ;


  FIg_set_text ( fp , 10          , "" ) ;
  switch ( g_label )
  {
  case 15       :
        err = 0 ;
 FIg_get_text ( fp , 15       , formname ) ;
        if ( strlen ( formname ) > ( 128                - 1 ) )
          err = 1 ;

        {
          char * tmp1 ;
          tmp1 = strrchr ( formname , '/' ) ;
          if ( tmp1 )
          {
          tmp1 ++ ;
          if ( strlen ( tmp1 ) > 14 ) err = 2 ;
          }
          else if ( strlen ( formname ) > 14 ) err = 2 ;
        }

       if ( err )
        {
        char msg_buf [ 512              ] ;
        if ( err == 1 )
        {
           { struct MS_sd_msg MS_msg ; if ( MS_init ( ( & MS_msg ) , ( 0x08f7844c ) , ( 0 ) , ( 0 ) , ( 0 ) , ( - 1 ) ) ) { int stat ; MS_fix_type ( ( & MS_msg ) , ( "%s%" ) ) ; sprintf ( ( MS_msg . variables ) , ( MS_msg . for_type ) , "" ) ; stat = MS_out_msg ( ( & MS_msg ) , ( msg_buf ) , ( 0 ) , ( - 1 ) , ( 0 ) , ( 0 ) , ( 0 ) ) ; } }
                                                          ;
        }
        else
        {
           { struct MS_sd_msg MS_msg ; if ( MS_init ( ( & MS_msg ) , ( 0x08f78454 ) , ( 0 ) , ( 0 ) , ( 0 ) , ( - 1 ) ) ) { int stat ; MS_fix_type ( ( & MS_msg ) , ( "%s%" ) ) ; sprintf ( ( MS_msg . variables ) , ( MS_msg . for_type ) , "" ) ; stat = MS_out_msg ( ( & MS_msg ) , ( msg_buf ) , ( 0 ) , ( - 1 ) , ( 0 ) , ( 0 ) , ( 0 ) ) ; } }
                                                          ;
       }

        FIg_set_text ( fp , 10          , msg_buf ) ;
        formname [ 0 ] = 0 ;
        FIg_set_text ( fp , 15       , "" ) ;
        sleep ( 3 ) ;
        err = 0 ;
        }
    break ;

  case 26       :
        err = 0 ;
 FIg_get_text ( fp , 26       , form_seedfile ) ;
        if ( strlen ( form_seedfile ) > ( 128                - 1 ) )
           err = 1 ;

        {
          char * tmp1 ;
          tmp1 = strrchr ( form_seedfile , '/' ) ;
          if ( tmp1 )
          {
          tmp1 ++ ;
          if ( strlen ( tmp1 ) > 14 ) err = 2 ;
          }
          else if ( strlen ( form_seedfile ) > 14 ) err = 2 ;
        }

        if ( err )
        {
        char msg_buf [ 512              ] ;
        if ( err == 1 )
        {
           { struct MS_sd_msg MS_msg ; if ( MS_init ( ( & MS_msg ) , ( 0x08f7844c ) , ( 0 ) , ( 0 ) , ( 0 ) , ( - 1 ) ) ) { int stat ; MS_fix_type ( ( & MS_msg ) , ( "%s%" ) ) ; sprintf ( ( MS_msg . variables ) , ( MS_msg . for_type ) , "" ) ; stat = MS_out_msg ( ( & MS_msg ) , ( msg_buf ) , ( 0 ) , ( - 1 ) , ( 0 ) , ( 0 ) , ( 0 ) ) ; } }
                                                          ;
        }
        else
        {
           { struct MS_sd_msg MS_msg ; if ( MS_init ( ( & MS_msg ) , ( 0x08f78454 ) , ( 0 ) , ( 0 ) , ( 0 ) , ( - 1 ) ) ) { int stat ; MS_fix_type ( ( & MS_msg ) , ( "%s%" ) ) ; sprintf ( ( MS_msg . variables ) , ( MS_msg . for_type ) , "" ) ; stat = MS_out_msg ( ( & MS_msg ) , ( msg_buf ) , ( 0 ) , ( - 1 ) , ( 0 ) , ( 0 ) , ( 0 ) ) ; } }
                                                          ;
       }

        FIg_set_text ( fp , 10          , msg_buf ) ;
        form_seedfile [ 0 ] = 0 ;
        FIg_set_text ( fp , 26       , "" ) ;
        sleep ( 3 ) ;
        err = 0 ;
        }

        else
        {
        sts = EX_get_seed_file ( form_seedfile , tmp_file ) ;
        if ( ! sts )
        {
        MSmessage ( ( 0 ) , ( 0x08f7827c ) , ( 0 ) , ( - 1 ) , ( msg ) , ( 0 ) , ( 0 ) , ( 0 ) , ( 0 ) , ( 0 ) , ( 0 ) ) ;                                               ;
        strcpy ( tmp_file , form_seedfile ) ;
        strcat ( tmp_file , "  " ) ;
        strcat ( tmp_file , msg ) ;
        FIg_set_text ( fp , 10          , tmp_file ) ;
        FIg_set_text ( fp , 26       , " " ) ;
        form_seedfile [ 0 ] = 0 ;
        }
        }
    break ;

  case 20     :
    if ( EX_os_filter )
        EX_os_filter = 0    ;
    else
        EX_os_filter = 1   ;
 FIg_set_text ( fp , 15       , "" ) ;
 Read_Dir ( fp ) ;
    break ;

  case 14      :
 expanded_dir = EXgetcwd ( save_cwd , 1024      ) ;
 FIg_set_text ( fp , 15       , "" ) ;
 FIfld_get_text ( fp , 14      , ( int ) value , 0 , 1024      , ( unsigned char * ) text_buff , & sf , & rp ) ;
 expanded_dir = expand_shell_vars ( text_buff ) ;
 if ( ! Change_Dir ( expanded_dir ) )
        {
          status = Read_Dir ( fp ) ;
          if ( ! status )
           {
           Change_Dir ( save_cwd ) ;
           Read_Dir ( fp ) ;
           }
        }
 else
        {
          FIfld_set_num_rows ( fp , 16     , 0 ) ;
          FIfld_set_num_rows ( fp , 21      , 0 ) ;
   FIg_set_text ( fp , 10          , sys_errlist [ errno ] ) ;
 }
 break ;

  case 16     :
 FIg_set_text ( fp , 15       , "" ) ;
 FIg_get_text ( fp , 14      , text_buff ) ;
    strcpy ( save_cwd , text_buff ) ;
 sprintf ( formname , "%s/" , text_buff ) ;

 FIfld_get_text ( fp , 16     , ( int ) value , 0 , 1024      ,
                       ( unsigned char * ) text_buff , & sf , & rp ) ;
 strcat ( formname , text_buff ) ;

 if ( ! Change_Dir ( formname ) )
        {
          status = Read_Dir ( fp ) ;
          if ( ! status )
          {
            Change_Dir ( save_cwd ) ;
            Read_Dir ( fp ) ;
          }
        }
 else
        {
   FIg_set_text ( fp , 10          , sys_errlist [ errno ] ) ;
        }

 Wait_timer ( 10 ) ;

 FIfld_set_select ( fp , 16     , ( int ) value , 0 , 0 ) ;
 break ;

  case 21      :
 FIfld_get_text ( fp , 21      , ( int ) value , 0 , 1024      , ( unsigned char * ) text_buff , & sf , & rp ) ;
 FIg_set_text ( fp , 15       , text_buff ) ;



 Wait_timer ( 10 ) ;

 FIfld_set_select ( fp , 21      , ( int ) value , 0 , 0 ) ;
 FIfld_set_select ( fp , 21      , ( int ) value , 1 , 0 ) ;
 break ;

  case 22         :
 FIg_get_text ( fp , 22         , text_buff ) ;
 strncpy ( pat_txt , text_buff , 29 ) ;
 List_Files ( fp ) ;
 break ;

  case 1        :

     if ( err ) break ;
    if ( ! PDUprocess_ex_file_form ( fp , g_label ) )
      break ;
 FIg_get_text ( fp , 15       , text_buff ) ;
    if ( text_buff [ 0 ] == 0 )
         {
         formname [ 0 ] = 0 ;
         }
 else
         {
         if ( text_buff [ 0 ] != '/' )
          {
          FIg_get_text ( fp , 14      , formname ) ;
        strcat ( formname , "/" ) ;
           strcat ( formname , text_buff ) ;
           }
          else
           {
           strcpy ( formname , text_buff ) ;
           }
         }
     FIf_delete ( fp ) ;
     { int rsp = 20              ;
      EXputq2 ( ( & stat ) , ( 1 ) , ( & rsp ) , ( 0 ) , ( 0 ) , ( 0 ) )                                      ;
     }


 break ;

  case 4        :
        PDUprocess_ex_file_form ( fp , g_label ) ;
 FIf_delete ( fp ) ;
 formname [ 0 ] = 0 ;

 { int rsp = 20              ;
   EXputq2 ( ( & stat ) , ( 1 ) , ( & rsp ) , ( 0 ) , ( 0 ) , ( 0 ) )                                      ;
 }
 break ;

  case 5                 :
 FIg_erase ( fp , 5                  ) ;
 break ;

  case 37            :
  case 49            :
  case 39            :
  case 50            :
  case 40            :
  case 51            :
  case 42             :
  case 52             :
  case 47            :
  case 48             :
  case 54             :
  case 30              :
  case 34              :
  case 31    :
       PDUprocess_ex_file_form ( fp , g_label ) ;
       break ;

  }
  return 1 ;
 }
#line 666  "EXfile_form.C"
 int EXget_file ( title , startdir , in_file , pat , file_type ,
                       returned_filename , seedfile , form_type ,
                                           response , response_data )
 char * title ;
 char * startdir ;
 char * in_file ;



 char * pat ;
 int file_type [ ] ;
 char    * returned_filename ;
 char * seedfile ;
 int form_type ;
 int * response ;
 char * response_data ;

 {

 char pat_buff [ 30 ] , * old_dir = 0 ;
 int sts ;
 int     num_bytes ;
 char done ;
 int not_done , status ;
    if ( file_type )
     {
     not_done = 1   ;
     while ( not_done )
      {
      if ( file_type [ number_types ] ) number_types ++ ;

      else not_done = 0    ;
      }
     }
 sts = FIf_new ( 0 , "PDMGetFile" , EXgetfil_form_notif , & fp ) ;



 if ( sts != 0         )
 {
  fprintf ( ( & _iob [ 2 ] )     , "FIf_new failed: sts = %d\n" , sts ) ;
 }


 pat_txt = pat_buff ;
 if ( pat ) strncpy ( pat_txt , pat , 29 ) ;
 else pat_txt [ 0 ] = 0 ;



 if ( ( old_dir = EXgetcwd ( ( char * ) 0   , 1024      ) ) == 0   )
        {
   FIg_set_text ( fp , 10          , sys_errlist [ errno ] ) ;
          FIf_delete ( fp ) ;
          return ( 0 ) ;
        }

 if ( startdir )
 {
   if ( ! Change_Dir ( startdir ) )
          {
            FIg_set_text ( fp , 15       , in_file ) ;
          }
   else
   {
     FIg_set_text ( fp , 10          , sys_errlist [ errno ] ) ;
     FIg_set_text ( fp , 15       , "" ) ;
   }
 }

 formfile_type = 0 ;
        filnam = dirnam = product = 0 ;

 buf_siz = 0 ;

    done = 0 ;

        msg_str = ( char * ) PDUtranslate_message ( PDM_I_RETRIEVE_OPT ) ;

 FIg_set_text ( fp , 11        , msg_str ) ;
 FIg_set_text ( fp , 22         , pat_txt ) ;
    if ( form_type != 1                    )
     {

     FIg_erase ( fp , 29       ) ;
     }
    EX_os_filter = 1   ;
    if ( number_types )
          formfile_type = ( int * ) malloc ( number_types * sizeof ( int ) ) ;
    if ( FIf_display ( fp ) == 0          )
 {
     FIg_set_text ( fp , 26       , seedfile ) ;
     strcpy ( form_seedfile , seedfile ) ;
  status = Read_Dir ( fp ) ;
     if ( ! status )
        {
         formname [ 0 ] = 0 ;
         done = 1 ;
        FIf_delete ( fp ) ;
        }
      while ( ! done )
         {

           EX_wait_for_input ( response , response_data ,
                                    8               , & num_bytes ) ;
           if ( * response == 20               )
             {
             done = 1 ;
             }
           else if ( ( * response == 23         ) || ( * response == 8      )
                                   || ( * response == 9         )
                                     || ( * response == 15         ) )
             {
             formname [ 0 ] = 0 ;
             done = 1 ;
            FIf_delete ( fp ) ;
             }
         }

 }




 Change_Dir ( old_dir ) ;

    if ( old_dir ) free ( old_dir ) ;
 if ( filnam ) free ( filnam ) ;
 if ( dirnam ) free ( dirnam ) ;
 if ( product ) free ( product ) ;
    if ( formfile_type ) free ( formfile_type ) ;
    strcpy ( seedfile , form_seedfile ) ;
    strcpy ( returned_filename , formname ) ;
    if ( formname [ 0 ] == 0 )
     return ( 0 ) ;
    else
 return ( 1 ) ;
 }
#line 830  "EXfile_form.C"
 static int xmatch ( name , pattern )
 char * name , * pattern ;
 {
 register char * n , * p ;
 register char nc , pc ;
 char cur ;
 int ok ;
#line 847  "EXfile_form.C"
 n = name ;
 p = pattern ;
 nc = * n ++ ;
 pc = * p ++ ;

 switch ( pc ) {

 case '?' :
  if ( nc == 0 )  return ( 0 ) ;
  return ( xmatch ( n , p ) ) ;

 case '[' :
  ok = 0 ;
  cur = 0 ;
  while ( pc = * p ++ ) {
   if ( pc == ']' ) {
    if ( ! ok )  return ( 0 ) ;
    return ( xmatch ( n , p ) ) ;
   }
   else if ( pc == '-' ) {
    if ( cur <= nc && nc <= * p ++ )  ok = 1 ;
   }
   else {
    if ( pc == nc )  ok = 1 ;
    cur = pc ;
   }
  }
  return ( 0 ) ;

 case '*' :
  if ( * p == 0 )  return ( 1 ) ;
  -- n ;
  while ( * n ) {
   if ( xmatch ( n , p ) ) return ( 1 ) ;
   n ++ ;
  }
  return ( 0 ) ;

 case '\0' :
  return ( nc == '\0' ) ;

 default :
  if ( nc != pc )  return ( 0 ) ;
  return ( xmatch ( n , p ) ) ;
 }
 }

 int strcmp_ls ( name , pattern )
 char * name ;
 char * pattern ;
 {
  if ( name [ 0 ] == '.' && pattern [ 0 ] != '.' )
    return 0 ;
  return ( xmatch ( name , pattern ) ) ;
 }


 char EXnull_test ( ) { return ( 1 ) ; }






 int EX_qsort_list ( lower , upper , list , list2 )
 int lower ;
 int upper ;
 ENTRY list [ ] ;
 ENTRY list2 [ ] ;
 {
 register int i , lastlow ;
 ENTRY * t ;
 int status ;

 if ( upper > lower )
    {
    i = ( int ) ( lower + ( upper - lower ) * drand48 ( ) )                        ;
    if ( list2 )
      EX_swap_string ( list [ lower ] , list [ i ] , list2 [ lower ] , list2 [ i ] ) ;
    else
      EX_swap_string ( list [ lower ] , list [ i ] , 0 , 0 ) ;
    t =  ( ENTRY * ) list [ lower ] ;
    lastlow = lower ;
    for ( i = lower + 1 ; i <= upper ; i ++ )
 {
    status = strcmp ( list [ i ] , ( char * ) t ) ;
 if ( status < 0  )
     {
     lastlow ++ ;
        if ( list2 )
           EX_swap_string ( list [ lastlow ] , list [ i ] , list2 [ lastlow ] , list2 [ i ] ) ;
        else
           EX_swap_string ( list [ lastlow ] , list [ i ] , 0 , 0 ) ;
     }
 }
    if ( list2 )
     EX_swap_string ( list [ lower ] , list [ lastlow ] , list2 [ lower ] , list2 [ lastlow ] ) ;
    else
     EX_swap_string ( list [ lower ] , list [ lastlow ] , 0 , 0 ) ;
    EX_qsort_list ( lower ,  lastlow - 1 , list , list2 ) ;
    EX_qsort_list ( lastlow + 1 , upper , list , list2 ) ;
    }
    return ( 1 ) ;
 }
#line 972  "EXfile_form.C"
 int EX_swap_string ( a , b , aa , bb )
 char * a ;
 char * b ;
 char * aa ;
 char * bb ;
 {
  char temp [ 1024      ] ;
  char temp2 [ 1024      ] ;

  strcpy ( temp , a ) ;
  strcpy ( a , b ) ;
  strcpy ( b , temp ) ;
  if ( aa )
  {
    strcpy ( temp2 , aa ) ;
    strcpy ( aa , bb ) ;
    strcpy ( bb , temp2 ) ;
  }
  return ( 1 ) ;
 }
