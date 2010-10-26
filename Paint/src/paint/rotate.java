package paint;

import java.awt.Toolkit.*;
import java.awt.Image.*;
import java.util.*;
import java.awt.datatransfer.Clipboard.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.geom.*;

/** A rotate object is a dialogue box that allows the user to rotate and flip the entire image about its very center. The user can then edit the options in the dialog box, and apply the changes to the image. Dialog box is terminated by clicking on the 'OK' or 'Cancel' buttons. OK will instantiated the changes, Cancel will do nothing to the original image.
 * The user can rotate the image by a variable degree amount or set intervals of 90 degrees.
 * There are no OS/Hardware dependencies and no variances.  There is no need for any
 * security constraints and no references to external specifications.
 */
public class rotate extends javax.swing.JDialog {

    /** Constructor initializes the rotate dialog box and displays it and waits for user input.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param parent JFrame
     * @param modal boolean which must be true
     */
    public rotate(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initComponents();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     */
    public void initComponents() {
        //  ok_action = false;
        outterButtons = new javax.swing.ButtonGroup();
        degrees = new javax.swing.ButtonGroup();
        ok_cancel = new javax.swing.JPanel();
        ok = new javax.swing.JButton();
        cancel = new javax.swing.JButton();
        choices = new javax.swing.JPanel();
        flipHorizontal = new javax.swing.JRadioButton();
        flipVertical = new javax.swing.JRadioButton();
        quarterTurn = new javax.swing.JRadioButton();
        halfTurn = new javax.swing.JRadioButton();
        threeQuarters = new javax.swing.JRadioButton();
        rotate = new javax.swing.JRadioButton();


        addWindowListener(new java.awt.event.WindowAdapter() {

            public void windowClosing(java.awt.event.WindowEvent evt) {
                closeDialog(evt);
            }
        });

        ok_cancel.setLayout(new java.awt.GridBagLayout());
        java.awt.GridBagConstraints gridBagConstraints1;

        ok.setText("OK");
        ok.addActionListener(new java.awt.event.ActionListener() {

            public void actionPerformed(java.awt.event.ActionEvent evt) {
                okActionPerformed(evt);
            }
        });

        gridBagConstraints1 = new java.awt.GridBagConstraints();
        gridBagConstraints1.anchor = java.awt.GridBagConstraints.WEST;
        ok_cancel.add(ok, gridBagConstraints1);

        cancel.setText("CANCEL");
        cancel.addActionListener(new java.awt.event.ActionListener() {

            public void actionPerformed(java.awt.event.ActionEvent evt) {
                cancelActionPerformed(evt);
            }
        });
        gridBagConstraints1 = new java.awt.GridBagConstraints();
        gridBagConstraints1.gridx = 0;
        gridBagConstraints1.gridy = 1;
        gridBagConstraints1.anchor = java.awt.GridBagConstraints.WEST;
        ok_cancel.add(cancel, gridBagConstraints1);

        getContentPane().add(ok_cancel, java.awt.BorderLayout.EAST);

        choices.setLayout(new java.awt.GridBagLayout());
        java.awt.GridBagConstraints gridBagConstraints2;

        flipHorizontal.setSelected(true);
        flipHorizontal.setText("Flip Horizontal");
        outterButtons.add(flipHorizontal);
        flipHorizontal.addActionListener(new java.awt.event.ActionListener() {

            public void actionPerformed(java.awt.event.ActionEvent evt) {
                flipHorizontalActionPerformed(evt);
            }
        });

        gridBagConstraints2 = new java.awt.GridBagConstraints();
        gridBagConstraints2.anchor = java.awt.GridBagConstraints.WEST;
        choices.add(flipHorizontal, gridBagConstraints2);

        flipVertical.setText("Flip Vertical");
        outterButtons.add(flipVertical);
        flipVertical.addActionListener(new java.awt.event.ActionListener() {

            public void actionPerformed(java.awt.event.ActionEvent evt) {
                flipVerticalActionPerformed(evt);
            }
        });

        gridBagConstraints2 = new java.awt.GridBagConstraints();
        gridBagConstraints2.gridx = 0;
        gridBagConstraints2.gridy = 1;
        gridBagConstraints2.anchor = java.awt.GridBagConstraints.WEST;
        choices.add(flipVertical, gridBagConstraints2);

        quarterTurn.setSelected(true);
        quarterTurn.setText("90");
        degrees.add(quarterTurn);
        quarterTurn.setEnabled(false);
        gridBagConstraints2 = new java.awt.GridBagConstraints();
        gridBagConstraints2.gridx = 0;
        gridBagConstraints2.gridy = 3;
        gridBagConstraints2.insets = new java.awt.Insets(0, 50, 0, 0);
        gridBagConstraints2.anchor = java.awt.GridBagConstraints.WEST;
        choices.add(quarterTurn, gridBagConstraints2);

        halfTurn.setText("180");
        degrees.add(halfTurn);
        halfTurn.setEnabled(false);
        gridBagConstraints2 = new java.awt.GridBagConstraints();
        gridBagConstraints2.gridx = 0;
        gridBagConstraints2.gridy = 4;
        gridBagConstraints2.insets = new java.awt.Insets(0, 50, 0, 0);
        gridBagConstraints2.anchor = java.awt.GridBagConstraints.WEST;
        choices.add(halfTurn, gridBagConstraints2);

        threeQuarters.setText("270");
        degrees.add(threeQuarters);
        threeQuarters.setEnabled(false);
        gridBagConstraints2 = new java.awt.GridBagConstraints();
        gridBagConstraints2.gridx = 0;
        gridBagConstraints2.gridy = 5;
        gridBagConstraints2.insets = new java.awt.Insets(0, 50, 0, 0);
        gridBagConstraints2.anchor = java.awt.GridBagConstraints.WEST;
        choices.add(threeQuarters, gridBagConstraints2);

        rotate.setText("Rotate by angle");
        outterButtons.add(rotate);
        rotate.addActionListener(new java.awt.event.ActionListener() {

            public void actionPerformed(java.awt.event.ActionEvent evt) {
                rotateActionPerformed(evt);
            }
        });

        gridBagConstraints2 = new java.awt.GridBagConstraints();
        gridBagConstraints2.gridx = 0;
        gridBagConstraints2.gridy = 2;
        gridBagConstraints2.anchor = java.awt.GridBagConstraints.WEST;
        choices.add(rotate, gridBagConstraints2);

        getContentPane().add(choices, java.awt.BorderLayout.CENTER);

        pack();
    }

    /** This method is done by mouse event to rotate the image.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param evt is performed by mouse action event.
     */
    public void okActionPerformed(java.awt.event.ActionEvent evt) {
        // Add your handling code here:
        BufferedImage im = ((Paint) this.getParent()).center.getBufferedImage();
        BufferedImage cp = new BufferedImage(im.getWidth(), im.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = cp.createGraphics();
        g2d.drawImage(im, 0, 0, im.getWidth(), im.getHeight(), 0, 0, im.getWidth(), im.getHeight(), this);
        g2d = im.createGraphics();

        //at.setToTranslation((rect.width-im.getWidth())/2,(rect.height-im.getHeight())/2);

        if (flipHorizontal.isSelected()) {
            int w = im.getWidth();
            int h = im.getHeight();


            System.out.println("I'm going to flip horizontal");
            System.out.println("width = " + im.getWidth() + " height = " + im.getHeight());
            g2d.drawImage(cp, im.getWidth(), 0, 0, im.getHeight(), 0, 0, im.getWidth(), im.getHeight(), this);

            cp.flush();

            // ming 4.26
            int cur_layer = ((Paint) this.getParent()).center.currentLayer;
            LinkedList cur_action_list = (LinkedList) (((Paint) this.getParent()).action_list.get(cur_layer));
            LinkedList cur_redo_list = (LinkedList) (((Paint) this.getParent()).redo_list.get(cur_layer));

            int temp1 = cur_redo_list.size();
            for (int i = 0; i < temp1; i++) {
                cur_redo_list.removeLast();
            }
            cur_action_list.add("Flip horizontal");

            // ming 4.26 end

            ((Paint) this.getParent()).updateUndoList();
            ((Paint) this.getParent()).center.setBufferedImage(im);
        } else {
            if (flipVertical.isSelected()) {
                System.out.println("I'm going to flip vertical");
                g2d.drawImage(cp, 0, im.getHeight(), im.getWidth(), 0, 0, 0, im.getWidth(), im.getHeight(), this);
                // ming 4.26
                cp.flush();
                int cur_layer = ((Paint) this.getParent()).center.currentLayer;
                LinkedList cur_action_list = (LinkedList) (((Paint) this.getParent()).action_list.get(cur_layer));
                LinkedList cur_redo_list = (LinkedList) (((Paint) this.getParent()).redo_list.get(cur_layer));

                int temp1 = cur_redo_list.size();
                for (int i = 0; i < temp1; i++) {
                    cur_redo_list.removeLast();
                }
                cur_action_list.add("Flip vertical");

                // ming 4.26 end

                ((Paint) this.getParent()).updateUndoList();
                ((Paint) this.getParent()).center.setBufferedImage(im);
            } else {
                double theta = 0;
                int rotateFlag = 0;

                if (quarterTurn.isSelected()) {
                    theta = 1 * (Math.PI / 2);
                    rotateFlag = 1;
                } else {
                    if (halfTurn.isSelected()) {
                        theta = (Math.PI);
                    } else {
                        theta = -1 * (Math.PI / 2);
                        rotateFlag = 2;
                    }
                }

                //have to make this so that it creates a new image in case it's not a square
                System.out.println("I'm going to rotate " + theta + " degrees");
                AffineTransform at = new AffineTransform();

                if ((im.getWidth() != im.getHeight()) && (rotateFlag == 1)) {
                    //the demensions have to be inverted, and this is 90 degrees

                    flip90(im);
                //((Paint)this.getParent()).action_list.add("Rotate 90 degree");
                // ((Paint)this.getParent()).updateUndoList();
                } else {
                    if ((im.getWidth() != im.getHeight()) && (rotateFlag == 2)) {
                        //the demensions have to be inverted, and this is 270 degrees
                        flip90(im);
                        im = ((Paint) this.getParent()).center.getBufferedImage();
                        flip90(im);
                        im = ((Paint) this.getParent()).center.getBufferedImage();
                        flip90(im);
                    /*	  flip270(im);
                     *	 at.rotate(theta,(im.getWidth()/2),(im.getHeight()/2));
                    at.rotate((Math.PI)/2,(im.getWidth()/2),(im.getHeight()/2));
                    g2d.drawImage(im,at,null);
                    ((Paint)this.getParent()).action_list.add("Rotate 270 degree");
                    ((Paint)this.getParent()).updateUndoList();
                    //		  ((Paint)this.getParent()).center.setBufferedImage(im);*/
                    } else {
                        //the demensions are fine
                        at.rotate(theta, (im.getWidth() / 2), (im.getHeight() / 2));
                        g2d.drawImage(im, at, null);
                        // ming 4.26
                        int cur_layer = ((Paint) this.getParent()).center.currentLayer;
                        LinkedList cur_action_list = (LinkedList) (((Paint) this.getParent()).action_list.get(cur_layer));
                        LinkedList cur_redo_list = (LinkedList) (((Paint) this.getParent()).redo_list.get(cur_layer));

                        int temp1 = cur_redo_list.size();
                        for (int i = 0; i < temp1; i++) {
                            cur_redo_list.removeLast();
                        }
                        cur_action_list.add("Rotate 180 degree");

                        // ming 4.26 end

                        ((Paint) this.getParent()).updateUndoList();
                        ((Paint) this.getParent()).center.setBufferedImage(im);
                    }
                }
            }
        }
        //((Paint)this.getParent()).ourCanvas.setBufferedImage(im);

        this.closeDialog(new java.awt.event.WindowEvent(this, 0));
        //	  ok_action = true;
        im.flush();
    }

    /** This method flips the image with 90 degrees.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param im BufferedImage object to be fliped
     */
    public void flip90(BufferedImage im) {
        BufferedImage temp = new BufferedImage(im.getHeight(), im.getWidth(), im.getType());
        Graphics2D g = temp.createGraphics();
        AffineTransform at = new AffineTransform();


        at.rotate((Math.PI) / 2, (((double) im.getHeight()) / 2),
                (((double) im.getHeight()) / 2));


        g.drawImage(im, at, null);
        ((Paint) this.getParent()).center.setBufferedImage(temp);
        // ming 4.26
        int cur_layer = ((Paint) this.getParent()).center.currentLayer;
        LinkedList cur_action_list = (LinkedList) (((Paint) this.getParent()).action_list.get(cur_layer));
        LinkedList cur_redo_list = (LinkedList) (((Paint) this.getParent()).redo_list.get(cur_layer));

        int temp1 = cur_redo_list.size();
        for (int i = 0; i < temp1; i++) {
            cur_redo_list.removeLast();
        }
        cur_action_list.add("Rotate 90 degree clockwise");

        // ming 4.26 end

        ((Paint) this.getParent()).updateUndoList();
        temp.flush();
    }

    /*  public void flip270(BufferedImage im)
    {
    BufferedImage temp = new BufferedImage(im.getHeight(),im.getWidth(),im.getType());
    Graphics2D g = temp.createGraphics();
    AffineTransform at = new AffineTransform();
    
    at.rotate(-1.0*(Math.PI),(((double)im.getHeight())/2),(((double)im.getHeight())/2 ) ) ;
    //at.rotate((Math.PI)/2,(((double)im.getHeight())/2),
    //(((double)im.getHeight())/2 ) ) ;
    
    
    g.drawImage(im,at,null);
    ((Paint)this.getParent()).center.setBufferedImage(temp);
    }*/
    /** This methods flips the image vertically.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param evt performed by mouse action
     */
    public void flipVerticalActionPerformed(java.awt.event.ActionEvent evt) {
        // Add your handling code here:
        quarterTurn.setEnabled(false);
        halfTurn.setEnabled(false);
        threeQuarters.setEnabled(false);
    }

    /** This method displays the rotated the image on main canvas by mouse clicking.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param evt performed by mouse action
     */
    public void rotateActionPerformed(java.awt.event.ActionEvent evt) {
        // Add your handling code here:
        quarterTurn.setEnabled(true);
        halfTurn.setEnabled(true);
        threeQuarters.setEnabled(true);
    }

    /** This method flips the image horizontally.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param evt performed by mouse action
     */
    public void flipHorizontalActionPerformed(java.awt.event.ActionEvent evt) {
        // Add your handling code here:
        quarterTurn.setEnabled(false);
        halfTurn.setEnabled(false);
        threeQuarters.setEnabled(false);
    }

    /** Closes the dialog.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param evt performed by mouse event
     */
    public void closeDialog(java.awt.event.WindowEvent evt) {
        setVisible(false);
        dispose();
    }

    /** This method cancels rotating the image.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param evt performed by mouse event
     */
    public void cancelActionPerformed(java.awt.event.ActionEvent evt) {
        setVisible(false);
        dispose();
    }

    /** Creates a new rotate object.
     * There are no OS/Hardware dependencies and no variances.	There is no need for any
     * security constraints and no references to external specifications.
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        new rotate(new javax.swing.JFrame(), true).show();
    }
    // Variables declaration - do not modify
    /** java swing GUI depicting the button group called outterButtons.*/
    private javax.swing.ButtonGroup outterButtons;
    /** java swing GUI depicting the button group called degrees.*/
    private javax.swing.ButtonGroup degrees;
    /** java swing GUI depicting the JPanel called ok_cancel.*/
    private javax.swing.JPanel ok_cancel;
    /** java swing GUI depicting the Jbutton called ok.*/
    private javax.swing.JButton ok;
    /** java swing GUI depicting the Jbutton called cancel.*/
    private javax.swing.JButton cancel;
    /** java swing GUI depicting the JPanel called choices.*/
    private javax.swing.JPanel choices;
    /** java swing GUI depicting the JRadioButton called flipHorizontal.*/
    private javax.swing.JRadioButton flipHorizontal;
    /** java swing GUI depicting the JRadioButton called flipVertical.*/
    private javax.swing.JRadioButton flipVertical;
    /** java swing GUI depicting the JRadioButton called quarterTurn.*/
    private javax.swing.JRadioButton quarterTurn;
    /** java swing GUI depicting the JRadioButton called halfTurn.*/
    private javax.swing.JRadioButton halfTurn;
    /** java swing GUI depicting the JRadioButton called threeQuarters.*/
    private javax.swing.JRadioButton threeQuarters;
    /** java swing GUI depicting the JRadioButton called rotate.*/
    private javax.swing.JRadioButton rotate;
    /** The dialog is closed by OK
     */
    //  public boolean ok_action;

    // End of variables declaration
}