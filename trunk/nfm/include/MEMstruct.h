#ifndef MEMSTRUCT_H
#define MEMSTRUCT_H
#define MEM_SIZE  512

  typedef struct  MEMbuffer_struct
   {
     int     row_size;         // Size of each row
     int     rows;             // Number of rows
     int     columns;          // Number of columns
     char    *column_ptr;
     char    *format_ptr;      // Used to decode column types, set in MEMformat_list
     char    *data_ptr;        // 2d array for each row/column
     char    *buffer_ptr;
   } *MEMptr;
#endif
