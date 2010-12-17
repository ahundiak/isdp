/* $Revision: 1.1 $ */
//
//      Description:   Class CDMWindow Specification
//      Author:        T. F. Ezell
//      Date:          26-Feb-94
//

#include <afxwin.h>
#include "v_grid.h"

class CDMFrame : public CMDIFrameWnd
{

public:

    CDMFrame(HWND frame, HWND mdi_client);
};


class CDMWindow : public CMDIChildWnd
{

public:

    CDMWindow(CMDIFrameWnd* parent, int left, int top, int width, int height);
    CDMWindow(HWND frame, HWND client, int left, int top, int width, int height);
    
    CGrid *m_grid;
    CDMFrame *m_frame;
    int m_tree;
    double m_g_percentage;
    double m_h_percentage;    
    
    void GetGrid(CGrid *grid);
    void SetGrid(CGrid *grid);
    void SetTree(int label);
    void GetTree(int *label);
//
//      Overrides of the CMDIChildWnd class member functions
//
    void OnPaint();
    void OnSize(UINT nType, int cx, int cy);
     
    DECLARE_MESSAGE_MAP()
};

class CDMApp : public CWinApp
{

public:

    CDMApp();
    CDMFrame *m_frame;
};

