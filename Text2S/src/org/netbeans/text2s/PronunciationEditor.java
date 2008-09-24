/*
 * PronunciationEditor.java
 *
 * Created on September 24, 2008, 9:12 PM
 */

package org.netbeans.text2s;

/**
 *
 * @author  karekar
 */
public class PronunciationEditor extends javax.swing.JFrame {

    /** Creates new form PronunciationEditor */
    public PronunciationEditor() {
        initComponents();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
 /*   @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        jTable1 = new javax.swing.JTable();
        WordL = new javax.swing.JLabel();
        PronunciationL = new javax.swing.JLabel();
        SynonymusL = new javax.swing.JLabel();
        WordT = new javax.swing.JTextField();
        PronunciationT = new javax.swing.JTextField();
        SynT = new javax.swing.JTextField();
        jButton1 = new javax.swing.JButton();
        jButton2 = new javax.swing.JButton();
        jButton3 = new javax.swing.JButton();
        jButton4 = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);

        jTable1.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        jTable1.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {
                "Title 1", "Title 2"
            }
        ));
        jScrollPane1.setViewportView(jTable1);

        WordL.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        WordL.setText(org.openide.util.NbBundle.getMessage(PronunciationEditor.class, "PronunciationEditor.WordL.text")); // NOI18N

        PronunciationL.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        PronunciationL.setText(org.openide.util.NbBundle.getMessage(PronunciationEditor.class, "PronunciationEditor.PronunciationL.text")); // NOI18N

        SynonymusL.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        SynonymusL.setText(org.openide.util.NbBundle.getMessage(PronunciationEditor.class, "PronunciationEditor.SynonymusL.text")); // NOI18N

        SynT.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                SynTActionPerformed(evt);
            }
        });

        jButton1.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        jButton1.setText(org.openide.util.NbBundle.getMessage(PronunciationEditor.class, "PronunciationEditor.jButton1.text")); // NOI18N

        jButton2.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        jButton2.setText(org.openide.util.NbBundle.getMessage(PronunciationEditor.class, "PronunciationEditor.jButton2.text")); // NOI18N

        jButton3.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        jButton3.setText(org.openide.util.NbBundle.getMessage(PronunciationEditor.class, "PronunciationEditor.jButton3.text")); // NOI18N

        jButton4.setFont(new java.awt.Font("Monotype Corsiva", 1, 18)); // NOI18N
        jButton4.setText(org.openide.util.NbBundle.getMessage(PronunciationEditor.class, "PronunciationEditor.jButton4.text")); // NOI18N

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 177, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(26, 26, 26)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(WordL, javax.swing.GroupLayout.PREFERRED_SIZE, 86, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(PronunciationL)
                    .addComponent(SynonymusL))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(WordT, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 66, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(SynT, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 62, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(PronunciationT, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 106, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap())
            .addGroup(layout.createSequentialGroup()
                .addGap(166, 166, 166)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jButton1)
                    .addComponent(jButton3))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 40, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jButton4)
                    .addComponent(jButton2))
                .addGap(56, 56, 56))
        );

        layout.linkSize(javax.swing.SwingConstants.HORIZONTAL, new java.awt.Component[] {PronunciationT, SynT, WordT});

        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addGap(20, 20, 20)
                        .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 147, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addGap(30, 30, 30)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(WordL)
                            .addComponent(WordT, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(31, 31, 31)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(PronunciationL)
                            .addComponent(PronunciationT, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(32, 32, 32)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(SynonymusL)
                            .addComponent(SynT, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addGap(39, 39, 39)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jButton1)
                    .addComponent(jButton2))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 25, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jButton3)
                    .addComponent(jButton4))
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents
*/
private void SynTActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_SynTActionPerformed
// TODO add your handling code here:
}//GEN-LAST:event_SynTActionPerformed

    /**
    * @param args the command line arguments
    */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new PronunciationEditor().setVisible(true);
            }
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel PronunciationL;
    private javax.swing.JTextField PronunciationT;
    private javax.swing.JTextField SynT;
    private javax.swing.JLabel SynonymusL;
    private javax.swing.JLabel WordL;
    private javax.swing.JTextField WordT;
    private javax.swing.JButton jButton1;
    private javax.swing.JButton jButton2;
    private javax.swing.JButton jButton3;
    private javax.swing.JButton jButton4;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JTable jTable1;
    // End of variables declaration//GEN-END:variables

    private void initComponents() {
        throw new UnsupportedOperationException("Not yet implemented");
    }

}