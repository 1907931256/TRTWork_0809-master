using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using System.Windows.Input;
using WW.Actions;
using WW.Cad.Drawing;
using WW.Cad.Drawing.GDI;
using WW.Cad.Model;
using WW.Cad.Model.Entities;
using WW.Drawing;
using WW.Math;
using WW.Math.Geometry;
using WW.Windows;
using WW.Cad.Actions;
using MotionCardSoftware;
using System.IO;
using System.IO.Ports;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WW.Cad.Model;
using DxfViewExample;

namespace DxfViewExample {
    /// <summary>
    /// This is a control that shows a DxfModel.
    /// Dragging with the mouse pans the drawing.
    /// Clicking on the drawing selects the closest entity and
    /// shows it in the property grid.
    /// Using the scroll wheel zooms in on the mouse position.
    /// </summary>
    public partial class ViewControl : UserControl {
        private DxfModel model;
        private GDIGraphics3D gdiGraphics3D;
        private WireframeGraphicsCache graphicsCache;
        private GraphicsHelper graphicsHelper;
        private Bounds3D bounds;
        private Matrix4D from2DTransform;
        private Point mouseClickLocation;
        private bool mouseDown;

        private ArgbColor highlightColor = ArgbColors.Magenta;
        private ArgbColor secondaryHighlightColor = ArgbColors.Cyan;

        #region zooming and panning
        private SimpleTransformationProvider3D transformationProvider;
        private SimplePanInteractor panInteractor;
        private SimpleRectZoomInteractor rectZoomInteractor;
        private SimpleZoomWheelInteractor zoomWheelInteractor;
        private IInteractorWinFormsDrawable rectZoomInteractorDrawable;
        private IInteractorWinFormsDrawable currentInteractorDrawable;
        #endregion

        private GDIGraphics3D dynamicGdiGraphics3D;
        private Matrix4D modelTransform = Matrix4D.Identity;
        private Vector3D translation = Vector3D.Zero;
        private Point lastMouseLocation;
        private double scaleFactor = 1d;
        private IInteractor interactor;

        public event EventHandler<EntityEventArgs> EntitySelected;
        private IInteractorWinFormsDrawable interactorDrawable;


        //��λ�����ƹؼ�����Ϣ
        private string BsplineDrawPathInf = Directory.GetCurrentDirectory() + "\\BsplineDrawPathInf.txt";
        //���ڽ���ʾ�̵���Ϣ
        private string RecieveTeachingPathInf = Directory.GetCurrentDirectory() + "\\RecieveTeachingPathInf.txt";
        //���ڽ���ʵ�ʸ�����Ϣ
        private string RecieveRealPointInf = Directory.GetCurrentDirectory() + "\\RecieveRealPointInf.txt";
        //�ٶ���Ϣ
        private string VelInf = Directory.GetCurrentDirectory() + "\\VelInformation.txt";
        //�������ùؼ�����Ϣ
        private string PathAllInf = Directory.GetCurrentDirectory() + "\\PathAllInf.txt";
        //�����ٶ�txt�ļ�
        private string SpeedReplanInfo = Directory.GetCurrentDirectory() + "\\speedReplan.txt";


        public ViewControl() {
            InitializeComponent();
            SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            SetStyle(ControlStyles.DoubleBuffer, true);
            SetStyle(ControlStyles.UserPaint, true);
            GraphicsConfig graphicsConfig = new GraphicsConfig();
            graphicsConfig.BackColor = BackColor;
            graphicsConfig.CorrectColorForBackgroundColor = true;
            gdiGraphics3D = new GDIGraphics3D(graphicsConfig);
            gdiGraphics3D.EnableDrawablesUpdate();
            graphicsCache = new WireframeGraphicsCache(false, true);
            graphicsCache.Config = graphicsConfig;
            graphicsHelper = new GraphicsHelper(System.Drawing.Color.Blue);
            bounds = new Bounds3D();

            transformationProvider = new SimpleTransformationProvider3D();
            transformationProvider.TransformsChanged += new EventHandler(transformationProvider_TransformsChanged);
            panInteractor = new SimplePanInteractor(transformationProvider);
            rectZoomInteractor = new SimpleRectZoomInteractor(transformationProvider);
            zoomWheelInteractor = new SimpleZoomWheelInteractor(transformationProvider);
            rectZoomInteractorDrawable = new SimpleRectZoomInteractor.WinFormsDrawable(rectZoomInteractor);
        }

        public DxfModel Model {
            get { 
                return model; 
            }
            set { 
                model = value;
                if (model != null) {

                    graphicsCache.CreateDrawables(model);

                    gdiGraphics3D.Clear();

                    graphicsCache.Draw(gdiGraphics3D.CreateGraphicsFactory());

                    gdiGraphics3D.BoundingBox(bounds, Matrix4D.Identity);

                    transformationProvider.ResetTransforms(bounds);
                    // Uncomment for rotation example.
                    //transformationProvider.ModelOrientation = QuaternionD.FromAxisAngle(Vector3D.ZAxis, 30d * Math.PI / 180d);
                    CalculateTo2DTransform();

                    Invalidate();
                }
            }
        }


        //��form�������ת��Ϊ��������
        public Point2D GetModelSpaceCoordinates(Point2D screenSpaceCoordinates) {
            return from2DTransform.TransformTo2D(screenSpaceCoordinates);
        }


        //����ԭ��ƫ����
        static protected float offsetX;
        static protected float offsetY;

        //ͼ��Ŵ�ϵ��
        static protected float zoom = 0.0f;

        //�������˳�������ת��Ϊ�������ꡣ�зŴ�ϵ��zoom�������������ֹ���ʱ�����仯
        //����,����(0,0),ʵ�����ص�����ȷ��(280,200)
        static public PointF GetPanelAxes(float x, float y)
        {
            PointF realAxes = new PointF();
            realAxes.X = (x - offsetX) / zoom;
            realAxes.Y = (-y + offsetY) / zoom;
            return realAxes;
        }


        //����������ת��Ϊ�����˳�������
        static public PointF GetRealAxes(float x, float y)
        {
            PointF realAxes = new PointF();
            realAxes.X = x * zoom + offsetX;
            realAxes.Y = -y * zoom + offsetY;
            return realAxes;
        }


        static public PointF GetPanelAxes2(float x, float y)
        {
            PointF realAxes = new PointF();
            realAxes.X = x - offsetX / zoom;
            realAxes.Y = -y + offsetY / zoom;
            return realAxes;
        }


        //ͼ����ʾ
        protected override void OnPaint(PaintEventArgs e) {
            Graphics gr = e.Graphics;
            Pen myPen = new Pen(System.Drawing.Color.White, 1);

            gdiGraphics3D.Draw(e.Graphics, ClientRectangle);


            PointF a = new PointF();
            PointF c = new PointF();
            a = from2DTransform.TransformToPointF(new Point2D(ClientRectangle.Left, ClientRectangle.Top));//����
            c = from2DTransform.TransformToPointF(new Point2D(ClientRectangle.Right, ClientRectangle.Top));//����
            zoom = (c.X - a.X) / (ClientRectangle.Right - ClientRectangle.Left);
            offsetX = a.X;
            offsetY = a.Y;

            myPen.EndCap = LineCap.ArrowAnchor;

            //��������ϵ����
            AdjustableArrowCap myLineCap = new AdjustableArrowCap(3, 3, true);
            myPen.CustomEndCap = myLineCap;
            gr.DrawLine(myPen, GetPanelAxes2(0, 0).X, GetPanelAxes2(0, 0).Y, GetPanelAxes2(30, 0).X, GetPanelAxes2(30, 0).Y);
            gr.DrawLine(myPen, GetPanelAxes2(0, 0).X, GetPanelAxes2(0, 0).Y, GetPanelAxes2(0, 30).X, GetPanelAxes2(0, 30).Y);


            if (MotionControlPlatform.PathClear == "����·��")
            {
                //���ƹؼ���
                BsplineReview(BsplineDrawPathInf,gr);
            }
            else if (MotionControlPlatform.PathClear == "ʾ��·��")
            {
                BsplineReviewWithDir(RecieveTeachingPathInf,gr);
            }
                
        }

        //����������ʾ
        private void BsplineReview(string dataPath,Graphics gr)
        {
            //���ݶ�ȡ
            StreamReader pathFile = File.OpenText(dataPath);

            List<string> tempString = new List<string>();

            while (!pathFile.EndOfStream)
            {
                tempString.Add(pathFile.ReadLine());
            }

            pathFile.Close();


            //�������С��2�����ܹ滮���켣
            if (tempString.Count() < 2) return;

            List<PointF> tempPnts = new List<PointF>();

            Pen myPen = new Pen(System.Drawing.Color.Yellow, 1);

            foreach (string str in tempString)
            {
                string[] sArray = str.Split(',');
                PointF pnt;
                tempPnts.Add(new PointF(float.Parse(sArray[0]), float.Parse(sArray[1])));
                pnt = ViewControl.GetPanelAxes(float.Parse(sArray[0]), float.Parse(sArray[1]));
                gr.DrawEllipse(myPen, pnt.X, pnt.Y, 3, 3);
            }

            System.Drawing.PointF[] tempPoint = tempPnts.ToArray();

            myPen.Color = System.Drawing.Color.Yellow;

            Bspline.DrawBspline1(tempPnts.Count(), gr, myPen, tempPoint);
        }


        //����������ʾ
        private void BsplineReviewWithDir(string dataPath, Graphics gr)
        {
            //���ݶ�ȡ
            StreamReader pathFile = File.OpenText(dataPath);

            List<string> tempString = new List<string>();

            while (!pathFile.EndOfStream)
            {
                tempString.Add(pathFile.ReadLine());
            }

            pathFile.Close();


            //�������С��2�����ܹ滮���켣
            if (tempString.Count() < 2) return;

            Pen myPen = new Pen(System.Drawing.Color.Yellow, 1);

            PointF pntOld = new PointF();
            PointF pntNow = new PointF();
            float dirOld = 0.0f;
            float dirNow = 0.0f;
            int tempFlag = 0;
            foreach (string str in tempString)
            {
                string[] sArray = str.Split(',');
                PointF pnt;
                pntNow.X = float.Parse(sArray[0]);
                pntNow.Y = float.Parse(sArray[1]);
                dirNow = float.Parse(sArray[2]);
                pnt = ViewControl.GetPanelAxes(float.Parse(sArray[0]), float.Parse(sArray[1]));
                gr.DrawEllipse(myPen, pnt.X, pnt.Y, 3, 3);


                if (tempFlag == 0)
                {
                    pntOld = pntNow;
                    dirOld = dirNow;
                    tempFlag = 1;
                    continue;
                }

                Bspline.DrawBspline2(gr, pntOld, pntNow, dirOld, dirNow);

                pntOld = pntNow;
                dirOld = dirNow;

            }

        }




        protected override void OnMouseDown(MouseEventArgs e) {
                base.OnMouseDown(e);
                mouseClickLocation = e.Location;
                mouseDown = true;


                panInteractor.Activate();

                panInteractor.ProcessMouseButtonDown(new CanonicalMouseEventArgs(e), GetInteractionContext());
        }

        protected override void OnMouseMove(MouseEventArgs e) {
                base.OnMouseMove(e);
                if (mouseDown == true)
                {
                    if (MotionControlPlatform.DRAW_INF != "���ڻ���")
                    {
                        panInteractor.ProcessMouseMove(new CanonicalMouseEventArgs(e), GetInteractionContext());
                        Invalidate();
                    }
                }
        }



        protected override void OnMouseUp(MouseEventArgs e) {

                base.OnMouseUp(e);
                mouseDown = false;

        }

        protected override void OnMouseWheel(MouseEventArgs e) {

                base.OnMouseWheel(e);

                if (MotionControlPlatform.DRAW_INF != "���ڻ���")
                {
                zoomWheelInteractor.Activate();
                zoomWheelInteractor.ProcessMouseWheel(new CanonicalMouseEventArgs(e), GetInteractionContext());
                zoomWheelInteractor.Deactivate();


                    Invalidate();
                }
        }




        //���Դ�
        public void StartInteraction(IInteractor interactor, IInteractorWinFormsDrawable interactorDrawable)
        {
            if (interactor != null)
            {
                this.interactor = interactor;
                this.interactorDrawable = interactorDrawable;
                interactor.Deactivated += interactor_Deactivated;
                interactor.Activate();
            }
        }


        //���Դ�
        protected virtual void OnEntitySelected(EntityEventArgs e)
        {
            if (EntitySelected != null)
            {
                EntitySelected(this, e);
            }
        }



        //���Դ�
        private void interactor_Deactivated(object sender, EventArgs e)
        {
            if (interactor != null)
            {
                interactor.Deactivated -= new EventHandler(interactor_Deactivated);
                interactor = null;

                gdiGraphics3D.Clear();
                gdiGraphics3D.CreateDrawables(model);
                dynamicGdiGraphics3D.Clear();
                Invalidate();
            }
        }
        //���Դ�
        public GDIGraphics3D GdiGraphics3D
        {
            get { return gdiGraphics3D; }
        }
        //���Դ�
        public GDIGraphics3D DynamicGdiGraphics3D
        {
            get { return dynamicGdiGraphics3D; }
        }
        //���Դ�
        private Matrix4D CalculateTo2DTransform() {
            transformationProvider.ViewWindow = GetClientRectangle2D();
            Matrix4D to2DTransform = Matrix4D.Identity;
            if (model != null && bounds != null) {
                to2DTransform = transformationProvider.CompleteTransform;
            }
            gdiGraphics3D.To2DTransform = to2DTransform;
            from2DTransform = gdiGraphics3D.To2DTransform.GetInverse();
            return to2DTransform;
        }

        //���Դ�
        private Rectangle2D GetClientRectangle2D()
        {
            return new Rectangle2D(
                ClientRectangle.Left,
                ClientRectangle.Top,
                ClientRectangle.Right,
                ClientRectangle.Bottom
            );
        }

        //���Դ�
        private void transformationProvider_TransformsChanged(object sender, EventArgs e) {
            CalculateTo2DTransform();
            Invalidate();
        }

        //���Դ�
        private InteractionContext GetInteractionContext() {
            return new InteractionContext(
                new Rectangle2D(ClientRectangle.Left, ClientRectangle.Top, ClientRectangle.Right, ClientRectangle.Bottom), 
                transformationProvider.CompleteTransform, 
                true,
                BackColor
            );
        }

    }
}
