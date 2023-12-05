namespace CappingAssayArgCollector
{
    partial class Metadata
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Metadata));
            this.btnOk = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.textBoxCal = new System.Windows.Forms.TextBox();
            this.labelTextBoxCal = new System.Windows.Forms.Label();
            this.labelTextBoxQC = new System.Windows.Forms.Label();
            this.textBoxQC = new System.Windows.Forms.TextBox();
            this.labelTextBoxBlank = new System.Windows.Forms.Label();
            this.textBoxBlank = new System.Windows.Forms.TextBox();
            this.labelTextBoxDBlank = new System.Windows.Forms.Label();
            this.textBoxDBlank = new System.Windows.Forms.TextBox();
            this.labelTextBoxSolvent = new System.Windows.Forms.Label();
            this.textBoxSolvent = new System.Windows.Forms.TextBox();
            this.labelRun = new System.Windows.Forms.Label();
            this.textBoxFortified = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // btnOk
            // 
            resources.ApplyResources(this.btnOk, "btnOk");
            this.btnOk.Name = "btnOk";
            this.btnOk.UseVisualStyleBackColor = true;
            this.btnOk.Click += new System.EventHandler(this.btnOk_Click);
            // 
            // btnCancel
            // 
            resources.ApplyResources(this.btnCancel, "btnCancel");
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // textBoxCal
            // 
            resources.ApplyResources(this.textBoxCal, "textBoxCal");
            this.textBoxCal.Name = "textBoxCal";
            // 
            // labelTextBoxCal
            // 
            resources.ApplyResources(this.labelTextBoxCal, "labelTextBoxCal");
            this.labelTextBoxCal.Name = "labelTextBoxCal";
            this.labelTextBoxCal.Click += new System.EventHandler(this.labelTextBoxTest_Click);
            // 
            // labelTextBoxQC
            // 
            resources.ApplyResources(this.labelTextBoxQC, "labelTextBoxQC");
            this.labelTextBoxQC.Name = "labelTextBoxQC";
            // 
            // textBoxQC
            // 
            resources.ApplyResources(this.textBoxQC, "textBoxQC");
            this.textBoxQC.Name = "textBoxQC";
            // 
            // labelTextBoxBlank
            // 
            resources.ApplyResources(this.labelTextBoxBlank, "labelTextBoxBlank");
            this.labelTextBoxBlank.Name = "labelTextBoxBlank";
            // 
            // textBoxBlank
            // 
            resources.ApplyResources(this.textBoxBlank, "textBoxBlank");
            this.textBoxBlank.Name = "textBoxBlank";
            // 
            // labelTextBoxDBlank
            // 
            resources.ApplyResources(this.labelTextBoxDBlank, "labelTextBoxDBlank");
            this.labelTextBoxDBlank.Name = "labelTextBoxDBlank";
            this.labelTextBoxDBlank.Click += new System.EventHandler(this.label1_Click);
            // 
            // textBoxDBlank
            // 
            resources.ApplyResources(this.textBoxDBlank, "textBoxDBlank");
            this.textBoxDBlank.Name = "textBoxDBlank";
            this.textBoxDBlank.TextChanged += new System.EventHandler(this.textBoxDBlank_TextChanged);
            // 
            // labelTextBoxSolvent
            // 
            resources.ApplyResources(this.labelTextBoxSolvent, "labelTextBoxSolvent");
            this.labelTextBoxSolvent.Name = "labelTextBoxSolvent";
            this.labelTextBoxSolvent.Click += new System.EventHandler(this.label1_Click_1);
            // 
            // textBoxSolvent
            // 
            resources.ApplyResources(this.textBoxSolvent, "textBoxSolvent");
            this.textBoxSolvent.Name = "textBoxSolvent";
            // 
            // labelRun
            // 
            resources.ApplyResources(this.labelRun, "labelRun");
            this.labelRun.Name = "labelRun";
            // 
            // textBoxFortified
            // 
            resources.ApplyResources(this.textBoxFortified, "textBoxFortified");
            this.textBoxFortified.Name = "textBoxFortified";
            // 
            // Metadata
            // 
            this.AcceptButton = this.btnOk;
            resources.ApplyResources(this, "$this");
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.Controls.Add(this.textBoxFortified);
            this.Controls.Add(this.labelRun);
            this.Controls.Add(this.textBoxSolvent);
            this.Controls.Add(this.labelTextBoxSolvent);
            this.Controls.Add(this.textBoxDBlank);
            this.Controls.Add(this.labelTextBoxDBlank);
            this.Controls.Add(this.textBoxBlank);
            this.Controls.Add(this.labelTextBoxBlank);
            this.Controls.Add(this.textBoxQC);
            this.Controls.Add(this.labelTextBoxQC);
            this.Controls.Add(this.labelTextBoxCal);
            this.Controls.Add(this.textBoxCal);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOk);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Metadata";
            this.ShowInTaskbar = false;
            this.Load += new System.EventHandler(this.ExampleToolUI_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnOk;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.TextBox textBoxCal;
        private System.Windows.Forms.Label labelTextBoxCal;
        private System.Windows.Forms.Label labelTextBoxQC;
        private System.Windows.Forms.TextBox textBoxQC;
        private System.Windows.Forms.Label labelTextBoxBlank;
        private System.Windows.Forms.TextBox textBoxBlank;
        private System.Windows.Forms.Label labelTextBoxDBlank;
        private System.Windows.Forms.TextBox textBoxDBlank;
        private System.Windows.Forms.Label labelTextBoxSolvent;
        private System.Windows.Forms.TextBox textBoxSolvent;
        private System.Windows.Forms.Label labelRun;
        private System.Windows.Forms.TextBox textBoxFortified;
    }
}

