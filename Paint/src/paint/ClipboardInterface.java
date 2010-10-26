package paint;

import java.awt.image.BufferedImage;

/** This class is the clipboard interface for  Paint.  It interacts with all other Office
 * products.  There is no visible state of this class.	It should work with all
 * operating systems and hardware.  There are no variances and no security constraints.
 * Since this is a clipboard, there are lots of external specifications:
 *
 * You can test which Office application the copy came from by specifying where it
 * was copiedFrom().  Examples include:
 *
 * if( copiedFrom() == ClipboardInterface.CALC )
 * if( copiedFrom() == ClipboardInterface.SPREADSHEET )
 *
 * and others.
 *
 */
public interface ClipboardInterface {
    //these are contants that will be used to identify the source of the object

    /** This field models the  SpreadSheet application which is static at 1.
     */
    static int SPREADSHEET = 1;
    /** This field models the  Pad application which is static at 2.
     */
    static int NOTEPAD = 2;
    /** This field models the  Present application which is static at 3.
     */
    static int OOD = 3;
    /** This field models the  Paint application which is static at 4.
     */
    static int PAINT = 4;
    /** This field models the  Calc application which is static at 5.
     */
    static int CALC = 5;
    /** This field models the  Manager application which is static at 6.
     */
    static int INTEGRATOR = 6;

    /** This string is used to get a string from whichever application.	 Valid
     * applications include  SpreadSheet,  Pad,  Calc, and perhaps  Manager.
     * @return String which is on the clipboard.
     */
    public String getString();

    /** This BufferedImage is used to get an image from the clipboard.	Valid for
     *  Paint and  Present applications.
     * @return BufferedImage from the clipboard.
     */
    public BufferedImage getImage();

    /** This function returns an integer which tells the program which Office
     * application the copy came from.
     *
     * Usage:
     * <CODE>if( copiedFrom() == ClipboardInterface.SPREADSHEET )
     * if( copiedFrom() == ClipboardInterface.NOTEPAD )
     * if( copiedFrom() == ClipboardInterface.OOD )
     * if( copiedFrom() == ClipboardInterface.PAINT )
     * if( copiedFrom() == ClipboardInterface.CALC )
     * if( copiedFrom() == ClipboardInterface.INTEGRATOR )</CODE>
     * @return Returns an integer of one of the static constants of  applications.
     *
     * Spreadsheet = 1, Notepad = 2, Object-Oriented Drawing = 3, Paint = 4,
     * Calculator = 5, and Integrator = 6.
     */
    public int copiedFrom();  //returns one of the static constants
    //(usage ex.  if(copiedFrom() == ClipboardInterface.SPREADSHEET)

}
