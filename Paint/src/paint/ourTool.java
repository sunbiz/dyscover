package paint;

import java.awt.event.*;

public interface ourTool {

    /** Called whenever the mouse is clicked.
     * @param mevt holds a MouseEvent
     * @param theCanvas holds a main_canvas
     */
    public void clickAction(MouseEvent mevt, main_canvas theCanvas);

    /** Called for all dragging actions.
     * @param mevt holds a MouseEvent for the dragging action
     * @param theCanvas holds a main_canvas
     */
    public void dragAction(MouseEvent mevt, main_canvas theCanvas);

    /** Called for all mouse releasing actions.
     * @param mevt holds a MouseEvent
     * @param theCanvas holds a main_canvas
     */
    public void mouseReleaseAction(MouseEvent mevt, main_canvas theCanvas);
    // draws the shape on shapes
}

