package tts1;

import com.melloware.jintellitype.HotkeyListener;
import com.melloware.jintellitype.IntellitypeListener;
import com.melloware.jintellitype.JIntellitype;
import com.sun.java.swing.plaf.windows.WindowsLookAndFeel;
import com.sun.speech.freetts.Voice;
import com.sun.speech.freetts.VoiceManager;

import java.awt.Frame;
import java.awt.GraphicsEnvironment;
import java.awt.Image;
import java.awt.Point;
import java.awt.Rectangle;

import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;

import java.io.IOException;
import java.lang.String;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.ImageIcon;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuItem;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;
import javax.swing.event.UndoableEditEvent;
import javax.swing.event.UndoableEditListener;
import javax.swing.text.Document;
import javax.swing.undo.CannotRedoException;
import javax.swing.undo.CannotUndoException;
import javax.swing.undo.UndoManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class welcomePage1 extends javax.swing.JFrame implements HotkeyListener, IntellitypeListener {

    private static final Log LOG = LogFactory.getLog(welcomePage1.class);
    private static final int ALT_S = 88;
    private static final int ALT_D=90;
    private static String Word;
    private static UndoManager undo;
    static Voice helloVoice;
    static String str,  s1,selected;
    private static String s2 = "";
    //   private Frame frame3;
//    Clipboard cb = frame3.getToolkit().getSystemClipboard();

    /** Creates new form welcomePage1 */
    public welcomePage1() {
        welcomePage1.setDefaultLookAndFeelDecorated(false);
     //   welcomePage1.RIGHT_ALIGNMENT(100.00);
        JIntellitype.getInstance().registerHotKey(ALT_S, JIntellitype.MOD_ALT, (int) 'S');
        JIntellitype.getInstance().registerHotKey(ALT_D,JIntellitype.MOD_ALT,(int)'D');
        JIntellitype.getInstance().addHotKeyListener(this);
        JIntellitype.getInstance().addIntellitypeListener(this);
        try {
            UIManager.setLookAndFeel(new WindowsLookAndFeel());
        } catch (UnsupportedLookAndFeelException ex) {
            Logger.getLogger(welcomePage1.class.getName()).log(Level.SEVERE, null, ex);
        } 
        initComponents();
        LOG.info("Initializing UI");
        this.addWindowListener(new java.awt.event.WindowAdapter() {

            @Override
            public void windowClosing(java.awt.event.WindowEvent evt) {
                LOG.info("Exiting Application");
                // don't forget to clean up any resources before close
                JIntellitype.getInstance().cleanUp();
                System.exit(0);
            }
        });
        undo = new UndoManager();
        Document doc = textArea.getDocument();
        doc.addUndoableEditListener(new UndoableEditListener() {

            public void undoableEditHappened(UndoableEditEvent evt) {
                undo.addEdit(evt.getEdit());
            }
        });
        JMenu Help = new javax.swing.JMenu();
        JMenuItem HelpTopics = new javax.swing.JMenuItem();
        Help.setText("Help");
        HelpTopics.setText("Help Topics");
        HelpTopics.addActionListener(new java.awt.event.ActionListener() {

            public void actionPerformed(java.awt.event.ActionEvent evt) {
                HelpTopicsActionPerformed(evt);
            }
        });
        Help.add(HelpTopics);
        jMenuBar3.add(Help);
     //   playB.setDefaultCapable(true);

    }

    public void HelpTopicsActionPerformed(java.awt.event.ActionEvent evt) {
        //String str = new String( "file:\\" + System.getProperty("user.dir") + "\\" + "help\\TerpPaintHelpTopics.html");
//     String str = new String( "file:\\" + "C:\\Documents and Settings\\wsouh\\Desktop\\2.0\\terppaintfile\\help" + "\\" + "TerpPaintHelpTopics.html");

        //System.out.println("str "+str);

        HelpWindow helpWindow = new HelpWindow(this);
        helpWindow.setVisible(true);


    //   HTMLDisplay helpdisplay = new HTMLDisplay( str, "TerpPaint Help" );
    //	  helpdisplay.setVisible( true );
    // System.out.println("help topics");
    }

    public static void initJIntellitype() {
        try {            // initialize JIntellitype with the frame so all windows commands can
            // be attached to this window
            // output("JIntellitype initialized");

        } catch (RuntimeException ex) {
            //   output("Either you are not on Windows, or there is a problem with the JIntellitype library!");
            LOG.error(ex, ex);
        }
    }

    private static void center(JFrame aFrame) {
        LOG.debug("Centering Window");
        final GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
        final Point centerPoint = ge.getCenterPoint();
        final Rectangle bounds = ge.getMaximumWindowBounds();
        final int w = Math.min(aFrame.getWidth(), bounds.width);
        final int h = Math.min(aFrame.getHeight(), bounds.height);
        final int x = centerPoint.x - (w / 2);
        final int y = centerPoint.y - (h / 2);
        aFrame.setBounds(x, y, w, h);
        if ((w == bounds.width) && (h == bounds.height)) {
            aFrame.setExtendedState(Frame.MAXIMIZED_BOTH);
        }
        aFrame.validate();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        textArea = new javax.swing.JTextArea();
        playB = new javax.swing.JButton();
        clearB = new javax.swing.JButton();
        image = new javax.swing.JLabel();
        jMenuBar3 = new javax.swing.JMenuBar();
        File2 = new javax.swing.JMenu();
        fileOpen = new javax.swing.JMenuItem();
        fileExit = new javax.swing.JMenuItem();
        Edit2 = new javax.swing.JMenu();
        editUndo = new javax.swing.JMenuItem();
        editRedo = new javax.swing.JMenuItem();
        editCut = new javax.swing.JMenuItem();
        editCopy = new javax.swing.JMenuItem();
        editPaste = new javax.swing.JMenuItem();
        editSelectAll = new javax.swing.JMenuItem();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setResizable(false);

        textArea.setBackground(new java.awt.Color(204, 204, 255));
        textArea.setColumns(20);
        textArea.setRows(5);
        textArea.setToolTipText("Enter your text here.");
        jScrollPane1.setViewportView(textArea);

        playB.setText("PLAY");
        playB.setDefaultCapable(false);
        playB.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                playBActionPerformed(evt);
            }
        });

        clearB.setText("CLEAR");
        clearB.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                clearBActionPerformed(evt);
            }
        });

        image.setBackground(new java.awt.Color(153, 0, 153));
        image.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));

        File2.setText("File");
        File2.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                File2FileMouseClicked(evt);
            }
        });
        File2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                File2FileActionPerformed(evt);
            }
        });

        fileOpen.setText("OPEN ");
        fileOpen.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                fileOpenFileOpenActionPerformed(evt);
            }
        });
        File2.add(fileOpen);

        fileExit.setText("Exit");
        fileExit.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                fileExitFileExitMouseClicked(evt);
            }
        });
        fileExit.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                fileExitFileExitActionPerformed(evt);
            }
        });
        File2.add(fileExit);

        jMenuBar3.add(File2);

        Edit2.setText("Edit");

        editUndo.setText("Undo");
        editUndo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editUndoEditUndoActionPerformed(evt);
            }
        });
        Edit2.add(editUndo);

        editRedo.setText("Redo");
        editRedo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editRedoEditRedoActionPerformed(evt);
            }
        });
        Edit2.add(editRedo);

        editCut.setText("Cut");
        editCut.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editCutEditCutActionPerformed(evt);
            }
        });
        Edit2.add(editCut);

        editCopy.setText("Copy");
        editCopy.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editCopyEditCopyActionPerformed(evt);
            }
        });
        Edit2.add(editCopy);

        editPaste.setText("Paste");
        editPaste.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editPasteEditPasteActionPerformed(evt);
            }
        });
        Edit2.add(editPaste);

        editSelectAll.setText("Select All");
        editSelectAll.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editSelectAllEditSelectAllActionPerformed(evt);
            }
        });
        Edit2.add(editSelectAll);

        jMenuBar3.add(Edit2);

        setJMenuBar(jMenuBar3);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(14, 14, 14)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(clearB, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(playB, javax.swing.GroupLayout.DEFAULT_SIZE, 71, Short.MAX_VALUE))
                .addGap(18, 18, 18)
                .addComponent(image, javax.swing.GroupLayout.DEFAULT_SIZE, 164, Short.MAX_VALUE)
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 277, Short.MAX_VALUE)
                    .addGroup(layout.createSequentialGroup()
                        .addGap(47, 47, 47)
                        .addComponent(playB, javax.swing.GroupLayout.PREFERRED_SIZE, 68, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(28, 28, 28)
                        .addComponent(clearB, javax.swing.GroupLayout.PREFERRED_SIZE, 67, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 67, Short.MAX_VALUE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addComponent(image, javax.swing.GroupLayout.PREFERRED_SIZE, 216, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(36, 36, 36)))
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

private void fileOpenFileOpenActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_fileOpenFileOpenActionPerformed
    JFileChooser fd = new JFileChooser();
    String data = "";
    String data1 = "";
    int result = fd.showDialog(null, "OPEN");
    File selectedFile;
    if (result == JFileChooser.APPROVE_OPTION) {
        selectedFile = fd.getSelectedFile();

        String fileName = selectedFile.getName();
        String filePath = selectedFile.getPath();
        try {
            FileInputStream fstream = new FileInputStream(filePath);
            DataInputStream in =
                    new DataInputStream(fstream);
            while (in.available() != 0) {
                data = (in.readLine());
                data1 = data1 + data;
                textArea.setText(data1);
            }
            in.close();
        } catch (Exception e) {
            System.err.println("File input error");
        }
    }
}//GEN-LAST:event_fileOpenFileOpenActionPerformed

private void fileExitFileExitMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_fileExitFileExitMouseClicked
}//GEN-LAST:event_fileExitFileExitMouseClicked

private void fileExitFileExitActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_fileExitFileExitActionPerformed
    System.exit(0);
}//GEN-LAST:event_fileExitFileExitActionPerformed

private void File2FileMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_File2FileMouseClicked
}//GEN-LAST:event_File2FileMouseClicked

private void File2FileActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_File2FileActionPerformed
    JFileChooser fc = new JFileChooser();
    fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY); // TODO add your handling code here:
}//GEN-LAST:event_File2FileActionPerformed

private void editUndoEditUndoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editUndoEditUndoActionPerformed
    try {
        if (undo.canUndo()) {
            undo.undo();
        }
    } catch (CannotUndoException e) {
    }
}//GEN-LAST:event_editUndoEditUndoActionPerformed

private void editRedoEditRedoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editRedoEditRedoActionPerformed
    try {
        if (undo.canRedo()) {
            undo.redo();
        }
    } catch (CannotRedoException e) {
    }
}//GEN-LAST:event_editRedoEditRedoActionPerformed

private void editCutEditCutActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editCutEditCutActionPerformed
    textArea.cut();
}//GEN-LAST:event_editCutEditCutActionPerformed

private void editCopyEditCopyActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editCopyEditCopyActionPerformed
    textArea.copy();
}//GEN-LAST:event_editCopyEditCopyActionPerformed

private void editPasteEditPasteActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editPasteEditPasteActionPerformed
    textArea.paste();
}//GEN-LAST:event_editPasteEditPasteActionPerformed

private void editSelectAllEditSelectAllActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editSelectAllEditSelectAllActionPerformed
    textArea.selectAll();
}//GEN-LAST:event_editSelectAllEditSelectAllActionPerformed

    private void play() {
      //  textArea.setCaretPosition(0);
        s2 = "";
        s1 = playB.getText();

              if (s1.equals("PLAY")) {
            playB.setText("STOP");
            Thread speakThread = new Thread(new Runnable() {

                public void run() {
                    speak();
                }
            });
            speakThread.start();
        } else if (s1.equals("STOP")) {
            playB.setText("PLAY");
            stop();
        }
    }
     private void play1() {
         Toolkit tk = Toolkit.getDefaultToolkit();
        Clipboard cp = tk.getSystemClipboard();
        try {
             selected = (String)cp.getData(DataFlavor.stringFlavor);
         //   System.out.println(str);
        } catch (IOException ioex) {
            ioex.printStackTrace();
        } catch (UnsupportedFlavorException ex) {
            Logger.getLogger(welcomePage1.class.getName()).log(Level.SEVERE, null, ex);
        }
        speak1();
    }
      //  textArea.setCaretPosition(0);
      /*  s2 = "";
        s1 = playB.getText();
        if (s1.equals("PLAY")) {
            playB.setText("STOP");
            Thread speakThread = new Thread(new Runnable() {

                public void run() {
                    speak();
                }
            });
            speakThread.start();
        } else if (s1.equals("STOP")) {
            playB.setText("PLAY");
            stop();
        }*/
    
private void playBActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_playBActionPerformed
    play();
}//GEN-LAST:event_playBActionPerformed

private void clearBActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_clearBActionPerformed
    textArea.setText("");
   // synBox.removeAllItems();
}//GEN-LAST:event_clearBActionPerformed

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {

            public void run() {
                new welcomePage1().setVisible(true);
            }
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JMenu Edit2;
    private javax.swing.JMenu File2;
    private javax.swing.JButton clearB;
    private javax.swing.JMenuItem editCopy;
    private javax.swing.JMenuItem editCut;
    private javax.swing.JMenuItem editPaste;
    private javax.swing.JMenuItem editRedo;
    private javax.swing.JMenuItem editSelectAll;
    private javax.swing.JMenuItem editUndo;
    private javax.swing.JMenuItem fileExit;
    private javax.swing.JMenuItem fileOpen;
    private javax.swing.JLabel image;
    private javax.swing.JMenuBar jMenuBar3;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JButton playB;
    private javax.swing.JTextArea textArea;
    // End of variables declaration//GEN-END:variables

    private void speak() {
        String s = textArea.getText();
        String s5="images\\";
        String s4=".jpeg";
        String obj=s5+s+s4;
        ImageIcon ic1=new ImageIcon(obj);
  Image image1=ic1.getImage().getScaledInstance(image.getWidth(),image.getHeight(),Image.SCALE_AREA_AVERAGING);
 ImageIcon icon1=new ImageIcon(image1);
 image.setIcon(icon1);
        int i = textArea.getCaretPosition();
        int k = s.length();
        for (int j = i; j <= k - 1; j++) {
            char c = s.charAt(j);
            String s3 = Character.toString(c);
            s2 = s2 + s3;
        }
        VoiceManager voiceManager = VoiceManager.getInstance();
        helloVoice = voiceManager.getVoice("kevin16");
        helloVoice.allocate();
        helloVoice.speak(s2);
        helloVoice.deallocate();
        playB.setText("PLAY");
    }

    private void speak1() {
       VoiceManager voiceManager = VoiceManager.getInstance();
        helloVoice = voiceManager.getVoice("kevin16");
        helloVoice.allocate();
        helloVoice.speak(selected);
        helloVoice.deallocate();
        playB.setText("PLAY");
        selected="";
    }

    private void stop() {
        helloVoice.deallocate();
    }

    public void onHotKey(int aIdentifier) {
        output("message received");
       play1();
    }

    public void onIntellitype(int aCommand) {
        switch (aCommand) {
            case 90:
                stop();
                break;
        }
    }

    private void output(String text) {
        if (LOG.isInfoEnabled()) {
            LOG.info(text);
        }
      //  textArea.append(text);
      //  textArea.append("\n");
    }
}
