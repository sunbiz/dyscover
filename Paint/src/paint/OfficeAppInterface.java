package paint;

import java.io.*;

/** Office application interface, specifies three methods to be implemented.
 */
public interface OfficeAppInterface {

    /** Closes the application.
     */
    public void close();

    /** Launches the specified file.
     * @param file the file to be launched
     */
    public void launch(File file);

    /** Determines if the application is still alive.
     * @return boolean flag
     */
    public boolean alive();
}

