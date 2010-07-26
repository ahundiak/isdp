#define ACT (&(active_stream->tok))

#define CPPERROR(A,B)\
 {\
  cpp_error_count++;\
  if (A)\
   fprintf (stderr,"\"%s\", %d:",(A)->filename,(A)->line_no);\
  fprintf (stderr," cpp error - %s\n",B);\
  file_traceback ();\
 }

#define CPPWARN(A,B)\
 {\
  if (cpp_options & CPP_WARN_ON)\
   {\
    if (A)\
     fprintf (stderr,"\"%s\", %d:",(A)->filename,(A)->line_no);\
    fprintf (stderr," cpp warning - %s\n",B);\
   }\
 }

#define CPPINFO(A,B)\
 {\
  if (cpp_options & CPP_INFO_ON)\
   {\
    if (A)\
     fprintf (stderr,"\"%s\", %d:",(A)->filename,(A)->line_no);\
    fprintf (stderr," cpp info - %s\n",B);\
   }\
 }

#define LEXERROR(A)\
 {\
  cpp_error_count++;\
  fprintf (stderr,"\"%s\", %d: lex error - %s\n",\
                  active_stream->cur_filename,\
                  active_stream->cur_linenum,A);\
  }

#define OMDEFERROR(A,B)\
 {\
  cpp_error_count++;\
  if (A)\
   fprintf (stderr,"\"%s\", %d:",(A)->filename,(A)->line_no);\
  fprintf (stderr," omdef error - %s\n",B);\
 }

#define OPPERROR(A,B)\
 {\
  cpp_error_count++;\
  if (A)\
   fprintf (stderr,"\"%s\", %d:",(A)->filename,(A)->line_no);\
  fprintf (stderr," opp error - %s\n",B);\
  file_traceback ();\
 }

#define OPPWARN(A,B)\
 {\
  if (cpp_options & CPP_WARN_ON)\
   {\
    if (A)\
     fprintf (stderr,"\"%s\", %d:",(A)->filename,(A)->line_no);\
    fprintf (stderr," opp warning - %s\n",B);\
    file_traceback ();\
   }\
 }

