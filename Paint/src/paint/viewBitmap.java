package paint;

import java.awt.*;
import java.awt.Toolkit.*;
import java.awt.Image.*;
import java.awt.image.*;

/** This class enables image to be viewed in full screen mode.
 *
 * It should work with all operating systems and hardware.
 * There are no variances and no security constraints.
 *
 * @author Paint
 * @version 2.0
 */
public class viewBitmap extends javax.swing.JWindow {
//public class viewBitmap extends javax.swing.JDialog {

    /** Main image (never used).
     */
    BufferedImage main_image;
    /** Underlying Paint object.
     */
    Paint Parent;

    /** Creates new form viewBitmap, initializes components, set screen size.
     * @param parent underlying Paint object reference
     * @param modal modal flag
     */
    public viewBitmap(java.awt.Frame parent, boolean modal) {
        Parent = (Paint) parent;
        initComponents();
        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        this.setSize((int) (screenSize.getWidth()), (int) (screenSize.getHeight()));
    }

    /** Paints the image.
     * @param g Graphic object
     */
    @Override
    public void paint(Graphics g) {
        BufferedImage im = Parent.center.getBufferedImage();
        int x = (this.getWidth() - im.getWidth()) / 2;
        int y = (this.getHeight() - im.getHeight()) / 2;
        Graphics2D g2d = (Graphics2D) g;
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2d.drawImage(im, x, y, im.getWidth(), im.getHeight(), null);
        im.flush();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    public void initComponents() {

        //setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        //setName("view");
        //setResizable(false);
        addMouseListener(new java.awt.event.MouseAdapter() {

            public void mouseClicked(java.awt.event.MouseEvent evt) {
                formMouseClicked(evt);
            }
        });

        addWindowListener(new java.awt.event.WindowAdapter() {

            public void windowClosing(java.awt.event.WindowEvent evt) {
                closeDialog(evt);
            }
        });

        pack();
    }

    /** Makes image in full screen mode by disposing GUI components.
     * @param evt mouse event
     */
    public void formMouseClicked(java.awt.event.MouseEvent evt) {
        setVisible(false);
        dispose();
    }
    /*
    private void closeDialog(java.awt.event.WindowEvent evt) {
    setVisible(false);
    dispose();
    }
     */

    /** Not implemented yet.
     * @param evt WindowEvent
     */
    public void closeDialog(java.awt.event.WindowEvent evt) {
    }

    /** For debugging.
     * @param args the command line arguments
     */
    public static void main(String args[]) {
    }
    // Variables declaration - do not modify
    // End of variables declaration
}