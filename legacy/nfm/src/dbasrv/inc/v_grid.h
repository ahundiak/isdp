/* $Revision: 1.1 $ */
//
//      Description:   Class CGrid, CCell Specification
//      Author:        T. F. Ezell
//      Date:          26-Feb-94
//

#include <afxwin.h>

class CCell : public CObject
{
public:
   CCell();

   CString m_string;
   CString m_bitmap_name;
   int m_selected;
   int m_current;
   int m_col_width;
   int m_row_height;
   int m_bitmap_index;

   void operator=(const CCell &right);
   
   void DrawInside(CDC *cdc, RECT *rc);   
   void SetString(CString *string);
   void GetString(CString *string);
   void SetBitmap(CString *name);
   void GetBitmap(CString *name);
   void SetSelected(int flag);
   void GetSelected(int *flag);
   void SetColumnWidth(int width);
   void GetColumnWidth(int *width);
   void SetRowHeight(int height);
   void GetRowHeight(int *height);
};

class CGrid : public CWnd
{
public:
    CGrid(CWnd* parent, int label, int left, int top, int width, int height, int num_cols, int num_rows, 
          int num_fixed_cols, int num_fixed_rows, int col_width, int row_height,
          int visible);
 	  
    int m_num_columns;
    int m_num_fixed_columns;
    int m_num_rows;
    int m_num_fixed_rows;
    int m_enabled;
    int m_visible;
    int m_select_flag;
    CString m_font_name;
    double m_font_size;
    int m_font_italic;
    int m_font_bold;
    int m_grid_lines;
    int m_grid_line_width;
    int m_border_style; 
    int m_label;
    CString m_name;
    int m_scrollbars;
    CCell *m_cells;
    CFont *m_font;
    int m_dynamics;
    int m_dynamic_col;
    int m_dynamic_row;
    int m_first;
    int m_lx, m_ly;
    int m_tot_width;
    int m_tot_height;
    int m_painting;
    CPen *m_pen3;
    HCURSOR m_hcur_vert, m_hcur_horz;
    int m_first_col, m_first_row;
    CString m_script;
    void (*m_callback)(HWND,int,int,int,int);
    
    void SetScript(CString *script);
    void SetCallBack(void (*callback)(HWND, int, int, int, int));
    
    void SetWindowSize(int x, int y, int width, int height);
    void GetWindowSize(int *x, int *y, int *width, int *height);
    
    int SetGridSize(int num_rows, int num_cols, int num_fixed_rows, int num_fixed_cols);
    void GetGridSize(int *num_rows, int *num_cols, int *num_fixed_rows, int *num_fixed_cols);
    
    void SetEnabled(int state);
    void SetVisible(int state);

    void SetFont(CString *name, int size, int italic, int bold);
    void GetFont(CString *name, int *size, int *italic, int *bold);    

    void SetGridLines(int state);
    void GetGridLines(int *state);

    void SetBorder(int state);
    void GetBorder(int *state);

    void SetScrollBars(int flag);
    void GetScrollBars(int *flag);

    int FileList(CString *filespec);
    int FileCount(CString *filespec);    
    int select_list(char *select_statement);    
    void Begin(CDC **wcdc, CDC **cdc, CBitmap **cbmp, PAINTSTRUCT *ps);
    void End(CDC *wcdc, CDC *cdc, CBitmap *cbmp);    
//
//      Overrides of the CWnd class member functions
//
    void OnPaint();
    void OnLButtonDblClk(UINT nFlags, CPoint point);
    void OnLButtonDown(UINT nFlags, CPoint point);
    void OnLButtonUp(UINT nFlags, CPoint point); 
    void OnMove(int x, int y);
    void OnSize(UINT nType, int x, int y);
    void OnMouseMove(UINT nFlags, CPoint point);
    void OnHScroll(UINT nSBCode, UINT nPos,
	               CScrollBar * pScrollBar);
    void OnVScroll(UINT nSBCode, UINT nPos,
	               CScrollBar * pScrollBar);

    DECLARE_MESSAGE_MAP()
};
