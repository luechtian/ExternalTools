using CappingAssayArgCollector;

namespace CappingAssayArgCollector
{
    class CappingAssayUtil
    {
    }
    //User define ARGUMENT_COUNT for arguments being sent from UI.  Do not include 
    //arguments in TestArgsCollector.properties
    static class Constants
    {
        public const string TRUE_STRING = "1"; // Not L10N             
        public const string FALSE_STRING = "0"; // Not L10N              
        public const int ARGUMENT_COUNT = 8;
    }
    public enum ArgumentIndices
    {
        text_box_cal,
        text_box_qc,
        text_box_blank,
        text_box_dblank,
        text_box_solvent,
        text_box_for,
        text_box_path_sample_info,
        text_box_path_results_temp

    }
}