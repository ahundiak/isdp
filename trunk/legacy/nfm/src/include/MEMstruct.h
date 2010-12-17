#ifndef MEMSTRUCT_H
#define MEMSTRUCT_H
#define MEM_SIZE  512

  typedef struct  MEMbuffer_struct
   {
     int     row_size;
     int     rows;
     int     columns;
     char    *column_ptr;
     char    *format_ptr;
     char    *data_ptr;
     char    *buffer_ptr;
   } *MEMptr;
#endif
