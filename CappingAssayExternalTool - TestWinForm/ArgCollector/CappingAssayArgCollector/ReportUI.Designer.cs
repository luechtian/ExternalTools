namespace CappingAssayArgCollector
{
    partial class ReportUI
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
            this.components = new System.ComponentModel.Container();
            this.btnOk = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.labelRunPathResultsTemp = new System.Windows.Forms.Label();
            this.labelRunPathSampleInfo = new System.Windows.Forms.Label();
            this.btnBrowseResultsTemp = new System.Windows.Forms.Button();
            this.textBoxPathResultsTemp = new System.Windows.Forms.TextBox();
            this.textBoxPathSampleInfo = new System.Windows.Forms.TextBox();
            this.btnBrowseSampleInfo = new System.Windows.Forms.Button();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.SuspendLayout();
            // 
            // btnOk
            // 
            this.btnOk.Location = new System.Drawing.Point(115, 121);
            this.btnOk.Name = "btnOk";
            this.btnOk.Size = new System.Drawing.Size(75, 23);
            this.btnOk.TabIndex = 0;
            this.btnOk.Text = "Ok";
            this.btnOk.UseVisualStyleBackColor = true;
            this.btnOk.Click += new System.EventHandler(this.button1_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Location = new System.Drawing.Point(242, 121);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 6;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // labelRunPathResultsTemp
            // 
            this.labelRunPathResultsTemp.AutoSize = true;
            this.labelRunPathResultsTemp.Location = new System.Drawing.Point(12, 65);
            this.labelRunPathResultsTemp.Name = "labelRunPathResultsTemp";
            this.labelRunPathResultsTemp.Size = new System.Drawing.Size(148, 13);
            this.labelRunPathResultsTemp.TabIndex = 27;
            this.labelRunPathResultsTemp.Text = "Upload Results Exceltemplate";
            // 
            // labelRunPathSampleInfo
            // 
            this.labelRunPathSampleInfo.AutoSize = true;
            this.labelRunPathSampleInfo.Location = new System.Drawing.Point(12, 7);
            this.labelRunPathSampleInfo.Name = "labelRunPathSampleInfo";
            this.labelRunPathSampleInfo.Size = new System.Drawing.Size(131, 13);
            this.labelRunPathSampleInfo.TabIndex = 26;
            this.labelRunPathSampleInfo.Text = "Upload sample information";
            // 
            // btnBrowseResultsTemp
            // 
            this.btnBrowseResultsTemp.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.btnBrowseResultsTemp.Location = new System.Drawing.Point(12, 81);
            this.btnBrowseResultsTemp.Name = "btnBrowseResultsTemp";
            this.btnBrowseResultsTemp.Size = new System.Drawing.Size(58, 23);
            this.btnBrowseResultsTemp.TabIndex = 25;
            this.btnBrowseResultsTemp.Text = "Browse";
            this.btnBrowseResultsTemp.UseVisualStyleBackColor = true;
            this.btnBrowseResultsTemp.Click += new System.EventHandler(this.btnBrowseResultsTemp_Click_1);
            // 
            // textBoxPathResultsTemp
            // 
            this.textBoxPathResultsTemp.Location = new System.Drawing.Point(76, 81);
            this.textBoxPathResultsTemp.Name = "textBoxPathResultsTemp";
            this.textBoxPathResultsTemp.Size = new System.Drawing.Size(338, 20);
            this.textBoxPathResultsTemp.TabIndex = 24;
            // 
            // textBoxPathSampleInfo
            // 
            this.textBoxPathSampleInfo.Location = new System.Drawing.Point(76, 23);
            this.textBoxPathSampleInfo.Name = "textBoxPathSampleInfo";
            this.textBoxPathSampleInfo.Size = new System.Drawing.Size(338, 20);
            this.textBoxPathSampleInfo.TabIndex = 22;
            // 
            // btnBrowseSampleInfo
            // 
            this.btnBrowseSampleInfo.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.btnBrowseSampleInfo.Location = new System.Drawing.Point(12, 23);
            this.btnBrowseSampleInfo.Name = "btnBrowseSampleInfo";
            this.btnBrowseSampleInfo.Size = new System.Drawing.Size(58, 23);
            this.btnBrowseSampleInfo.TabIndex = 23;
            this.btnBrowseSampleInfo.Text = "Browse";
            this.btnBrowseSampleInfo.UseVisualStyleBackColor = true;
            this.btnBrowseSampleInfo.Click += new System.EventHandler(this.btnBrowseSampleInfo_Click_1);
            // 
            // ReportUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(433, 156);
            this.Controls.Add(this.labelRunPathResultsTemp);
            this.Controls.Add(this.labelRunPathSampleInfo);
            this.Controls.Add(this.btnBrowseResultsTemp);
            this.Controls.Add(this.textBoxPathResultsTemp);
            this.Controls.Add(this.textBoxPathSampleInfo);
            this.Controls.Add(this.btnBrowseSampleInfo);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOk);
            this.MinimumSize = new System.Drawing.Size(449, 195);
            this.Name = "ReportUI";
            this.Text = "Capping Assay Report";
            this.toolTip1.SetToolTip(this, "Sample information can be found in SampleList-Excelsheet. It is important, that e" +
        "very Sample has a cap type!");
            this.Load += new System.EventHandler(this.ReportUI_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnOk;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label labelRunPathResultsTemp;
        private System.Windows.Forms.Label labelRunPathSampleInfo;
        private System.Windows.Forms.Button btnBrowseResultsTemp;
        private System.Windows.Forms.TextBox textBoxPathResultsTemp;
        private System.Windows.Forms.TextBox textBoxPathSampleInfo;
        private System.Windows.Forms.Button btnBrowseSampleInfo;
        private System.Windows.Forms.ToolTip toolTip1;
    }
}