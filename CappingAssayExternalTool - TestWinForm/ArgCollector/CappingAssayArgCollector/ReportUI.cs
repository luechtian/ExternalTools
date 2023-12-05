using System;
using System.Globalization;
using System.Windows.Forms;
using CappingAssayArgCollector.Properties;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace CappingAssayArgCollector
{
    public partial class ReportUI : Form
    {
        public string[] Arguments { get; private set; }
        public ReportUI(string[] oldArguments)
        {
            InitializeComponent();
            Arguments = oldArguments;
        }

        private void button1_Click(object sender, System.EventArgs e)
        {
            GenerateArguments();
            DialogResult = DialogResult.OK;
        }
        private void btnCancel_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
        }


        public void GenerateArguments()
        {
            Arguments = new string[Constants.ARGUMENT_COUNT];
            Arguments[(int)ArgumentIndices.text_box_path_sample_info] = textBoxPathSampleInfo.Text.ToString(CultureInfo.InvariantCulture);
            Arguments[(int)ArgumentIndices.text_box_path_results_temp] = textBoxPathResultsTemp.Text.ToString(CultureInfo.InvariantCulture);
        }

        private void ReportUI_Load(object sender, EventArgs e)
        {

        }

        private void btnBrowseSampleInfo_Click_1(object sender, EventArgs e)
        {
            OpenFileDialog v1 = new OpenFileDialog();
            v1.Filter = "Excel files (*.xlsx)|*.xlsx|All files (*.*)|*.*";

            if (v1.ShowDialog() == DialogResult.OK)
            {
                textBoxPathSampleInfo.Text = v1.FileName;
            }
        }

        private void btnBrowseResultsTemp_Click_1(object sender, EventArgs e)
        {
            OpenFileDialog v1 = new OpenFileDialog();
            v1.Filter = "Excel files (*.xlsx)|*.xlsx|All files (*.*)|*.*";

            if (v1.ShowDialog() == DialogResult.OK)
            {
                textBoxPathResultsTemp.Text = v1.FileName;
            }
        }
    }

    public class ArgCollectorReport
    {
        public static string[] CollectArgs(IWin32Window parent, string report, string[] oldArgs)
        {

            using (var dlg = new ReportUI(oldArgs))
            {
                if (parent != null)
                {
                    return (dlg.ShowDialog(parent) == DialogResult.OK) ? dlg.Arguments : null;
                }
                dlg.StartPosition = FormStartPosition.WindowsDefaultLocation;
                return (dlg.ShowDialog() == DialogResult.OK) ? dlg.Arguments : null;
            }
        }
    }
}

