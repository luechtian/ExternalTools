using System.Globalization;
using System.Windows.Forms;
using CappingAssayArgCollector.Properties;

namespace CappingAssayArgCollector
{
// ReSharper disable once InconsistentNaming
    public partial class Metadata : Form
    {
        public string[] Arguments { get; private set; }

        public Metadata(string[] oldArguments)
        {
            InitializeComponent();
            Arguments = oldArguments;
        }


        /// <summary>
        /// "Ok" button click event.  If VerifyArgument() returns true will generate arguments.
        /// </summary>
        private void btnOk_Click(object sender, System.EventArgs e)
        {
            if (VerifyArguments())
            {
                GenerateArguments();
                DialogResult = DialogResult.OK;
            }
        }

        /// <summary>
        /// Run before arguments are generated and can return an error message to
        /// the user.  If it returns true arguments will be generated.
        /// </summary>
        private bool VerifyArguments()
        {
            //if textBoxTest has no length it will error "Text Box must be filled", focus the
            //users cursor on textBoxTest, and return false.
            if (textBoxCal.TextLength == 0)
            {
                MessageBox.Show(Resources.Metadata_VerifyArguments_Text_Box_must_be_filled);
                textBoxCal.Focus();
                return false;
            }
            if (textBoxQC.TextLength == 0)
            {
                MessageBox.Show(Resources.Metadata_VerifyArguments_Text_Box_must_be_filled);
                textBoxQC.Focus();
                return false;
            }
            if (textBoxBlank.TextLength == 0)
            {
                MessageBox.Show(Resources.Metadata_VerifyArguments_Text_Box_must_be_filled);
                textBoxBlank.Focus();
                return false;
            }
            if (textBoxDBlank.TextLength == 0)
            {
                MessageBox.Show(Resources.Metadata_VerifyArguments_Text_Box_must_be_filled);
                textBoxDBlank.Focus();
                return false;
            }
            if (textBoxSolvent.TextLength == 0)
            {
                MessageBox.Show(Resources.Metadata_VerifyArguments_Text_Box_must_be_filled);
                textBoxSolvent.Focus();
                return false;
            }
            if (textBoxFortified.TextLength == 0)
            {
                MessageBox.Show(Resources.Metadata_VerifyArguments_Text_Box_must_be_filled);
                textBoxSolvent.Focus();
                return false;
            }

            return true;
        }

        /// <summary>
        /// Generates an Arguments[] for the values of the user inputs.
        /// Number of Arguments is defined in TestToolUtil.cs
        /// </summary>
        public void GenerateArguments()
        {
            Arguments = new string[Constants.ARGUMENT_COUNT];
            Arguments[(int)ArgumentIndices.text_box_cal] = textBoxCal.Text.ToString(CultureInfo.InvariantCulture);
            Arguments[(int)ArgumentIndices.text_box_qc] = textBoxQC.Text.ToString(CultureInfo.InvariantCulture);
            Arguments[(int)ArgumentIndices.text_box_blank] = textBoxBlank.Text.ToString(CultureInfo.InvariantCulture);
            Arguments[(int)ArgumentIndices.text_box_dblank] = textBoxDBlank.Text.ToString(CultureInfo.InvariantCulture);
            Arguments[(int)ArgumentIndices.text_box_solvent] = textBoxSolvent.Text.ToString(CultureInfo.InvariantCulture);
            Arguments[(int)ArgumentIndices.text_box_for] = textBoxFortified.Text.ToString(CultureInfo.InvariantCulture);
        }

        private void btnCancel_Click(object sender, System.EventArgs e)
        {
            DialogResult = DialogResult.Cancel;

        }

        private void labelTextBoxTest_Click(object sender, System.EventArgs e)
        {

        }
                
        private void label1_Click(object sender, System.EventArgs e)
        {

        }

        private void label1_Click_1(object sender, System.EventArgs e)
        {

        }

        private void textBoxDBlank_TextChanged(object sender, System.EventArgs e)
        {

        }

        private void ExampleToolUI_Load(object sender, System.EventArgs e)
        {

        }
    }

    public class ArgCollector
    {
        public static string[] CollectArgs(IWin32Window parent, string report, string[] oldArgs)
        {

            using (var dlg = new Metadata(oldArgs))
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
