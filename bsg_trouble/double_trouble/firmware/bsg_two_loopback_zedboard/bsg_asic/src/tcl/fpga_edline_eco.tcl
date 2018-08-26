
# Modify routed design using fpga_edline
$FPGA_EDLINE_BIN -p $BSG_TOP_NAME.scr;

# Re-generate static timing report
$TRCE_BIN -intstyle ise -v 3 -s 3 -n 3 -fastpaths -xml $BSG_TOP_NAME.twx $BSG_TOP_NAME.ncd -o $BSG_TOP_NAME.twr $BSG_TOP_NAME.pcf;
