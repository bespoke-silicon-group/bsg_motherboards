
set target $::env(BSG_GATEWAY_TARGET)

source $::env(BSG_FPGA_FIRMWARE_DIR)/common/$target/tcl/common.tcl
# set bsg_top_name bsg_gateway

puts "Start generating fpga_edline script"

# For new tap delay calculation
set tapDelayRatio 0.77
set tapDelayDivider [expr $tapDelayRatio*0.322]
set th01 [expr $tapDelayRatio*(0.0+0.008)/2.0]
set th12 [expr $tapDelayRatio*(0.008+0.04)/2.0]
set th23 [expr $tapDelayRatio*(0.04+0.095)/2.0]
set th34 [expr $tapDelayRatio*(0.095+0.108)/2.0]
set th45 [expr $tapDelayRatio*(0.108+0.171)/2.0]
set th56 [expr $tapDelayRatio*(0.171+0.207)/2.0]
set th67 [expr $tapDelayRatio*(0.207+0.212)/2.0]
set th78 [expr $tapDelayRatio*(0.212+0.322)/2.0]

# Open plain text timing report
set inFileSuffix ".twr"
set inFileName "$bsg_top_name$inFileSuffix"
set inFile [open $inFileName]

# Find the title string of output offset constraints table
while {[gets $inFile line] >=0} {
    if { [regexp {Clock CLK_OSC_N to Pad} $line] } {
        break
    }
}

# Array to store pad delay
array set outputDelayArray {}
array set outputDelayFastArray {}

# Loop through all constraint paths
set counter 0
while {[gets $inFile line]>=0} {

    # Ignore if it is an empty line
     if { [regexp {""} $line] } {
        continue
    }

    # Get the first word of line
    set padName [lindex $line 0]

	# Ignore AID10
	if { [regexp {AID10} $padName] } {
        continue
    }

    # Ignore if it is not a valid pad name
    if { ![regexp {[A-D]I[C-D][0-8]} $padName] } {
        continue
    }

    # Convert string into valid number
    set outputDelay [lindex $line 2]
	set outputDelayFast [lindex $line 5]
    set charCount [string length $outputDelay]
	set charCountFast [string length $outputDelayFast]
    set outputDelay [string replace $outputDelay [expr $charCount-4] [expr $charCount-1] ""]
	set outputDelayFast [string replace $outputDelayFast [expr $charCountFast-4] [expr $charCountFast-1] ""]

    # Store delay value into array
    set outputDelayArray($padName) $outputDelay
	set outputDelayFastArray($padName) $outputDelayFast

    # Terminates when all pad delays are collected
    incr counter
    if {$counter >= 40} {
        break
    }

}

# Close timing report
close $inFile

# Open output file
set outFileSuffix ".scr"
set outFileName "$bsg_top_name$outFileSuffix"
set outFp [open $outFileName w]

# Print out some unchanged scripts
set designFileSuffix ".ncd"
set designFileName "$bsg_top_name$designFileSuffix"

puts $outFp ""
puts $outFp "open design $designFileName -nomd"
puts $outFp ""
puts $outFp {setattr main edit-mode Read-Write}
puts $outFp ""

# Array to store taps
array set outputDelayArray {}

# Calculate taps for all pads and print out
foreach channel {A B C D} {

    set maxDelay 0

    # Retrieve clk delay
    set clkName XIC0
    set clkName [string replace $clkName 0 0 $channel]
    set clkSlowDelay $outputDelayArray($clkName)
	set clkFastDelay $outputDelayFastArray($clkName)
	set clkDelay [expr ($clkSlowDelay + $clkFastDelay)/2]
    if {$clkDelay > $maxDelay} {
        set maxDelay $clkDelay
    }

    # Retrieve data delay
    foreach num {0 1 2 3 4 5 6 7 8} {
        set dataName XID9
        set dataName [string replace $dataName 0 0 $channel]
        set dataName [string replace $dataName 3 3 $num]
		set dataSlowDelay $outputDelayArray($dataName)
		set dataFastDelay $outputDelayFastArray($dataName)
		set dataDelay [expr ($dataSlowDelay + $dataFastDelay)/2]
        if {$dataDelay > $maxDelay} {
            set maxDelay $dataDelay
        }
    }

    # Print out clk tap modification
    if {$channel == {A}} {set clkIndex 0}
    if {$channel == {B}} {set clkIndex 1}
    if {$channel == {C}} {set clkIndex 2}
    if {$channel == {D}} {set clkIndex 3}

    # set clkTap [expr int(floor(($maxDelay-$clkDelay)/$tapUnitDelay))]
	set clk8Tap [expr int(floor(($maxDelay-$clkDelay)/$tapDelayDivider))]
	set clkReminder [expr ($maxDelay-$clkDelay)-($clk8Tap*$tapDelayDivider)]
	if {$clkReminder < $th01} {
		set clkTap [expr int($clk8Tap*8+0)]
	} elseif {$clkReminder < $th12} {
		set clkTap [expr int($clk8Tap*8+1)]
	} elseif {$clkReminder < $th23} {
		set clkTap [expr int($clk8Tap*8+2)]
	} elseif {$clkReminder < $th34} {
		set clkTap [expr int($clk8Tap*8+3)]
	} elseif {$clkReminder < $th45} {
		set clkTap [expr int($clk8Tap*8+4)]
	} elseif {$clkReminder < $th56} {
		set clkTap [expr int($clk8Tap*8+5)]
	} elseif {$clkReminder < $th67} {
		set clkTap [expr int($clk8Tap*8+6)]
	} elseif {$clkReminder < $th78} {
		set clkTap [expr int($clk8Tap*8+7)]
	} else {
		set clkTap [expr int($clk8Tap*8+8)]
	}

    set cellName1 {delay/c0[}
    set cellName2 {].clk_temp/IODELAY2_data}
    set cellName "$cellName1$clkIndex$cellName2"

    set firstPart {setattr comp }
    set secondPart { ODELAY_VALUE "00"}
    set combined "$firstPart$cellName$secondPart"
    set charCount [string length $combined]
    set combined [string replace $combined [expr $charCount-3] [expr $charCount-2] "$clkTap"]
    puts $outFp "$combined"
    puts $outFp "trim -id comp $cellName"
	puts "$clkName, tap $clkTap, cell name $cellName"

    # Print out data tap modification
    if {$channel == {A}} {set dataIndex a}
    if {$channel == {B}} {set dataIndex b}
    if {$channel == {C}} {set dataIndex c}
    if {$channel == {D}} {set dataIndex d}

    foreach num {0 1 2 3 4 5 6 7} {

        set dataName XID9
        set dataName [string replace $dataName 0 0 $channel]
        set dataName [string replace $dataName 3 3 $num]

		set dataSlowDelay $outputDelayArray($dataName)
		set dataFastDelay $outputDelayFastArray($dataName)
		set dataDelay [expr ($dataSlowDelay + $dataFastDelay)/2]

        # set dataTap [expr int(floor(($maxDelay-$dataDelay)/$tapUnitDelay))+0]
		set data8Tap [expr int(floor(($maxDelay-$dataDelay)/$tapDelayDivider))]
		set dataReminder [expr ($maxDelay-$dataDelay)-($data8Tap*$tapDelayDivider)]
		if {$dataReminder < $th01} {
			set dataTap [expr int($data8Tap*8+0)]
		} elseif {$dataReminder < $th12} {
			set dataTap [expr int($data8Tap*8+1)]
		} elseif {$dataReminder < $th23} {
			set dataTap [expr int($data8Tap*8+2)]
		} elseif {$dataReminder < $th34} {
			set dataTap [expr int($data8Tap*8+3)]
		} elseif {$dataReminder < $th45} {
			set dataTap [expr int($data8Tap*8+4)]
		} elseif {$dataReminder < $th56} {
			set dataTap [expr int($data8Tap*8+5)]
		} elseif {$dataReminder < $th67} {
			set dataTap [expr int($data8Tap*8+6)]
		} elseif {$dataReminder < $th78} {
			set dataTap [expr int($data8Tap*8+7)]
		} else {
			set dataTap [expr int($data8Tap*8+8)]
		}

        set cellName1 {delay/c1[}
        set cellName2 {].data_}
        set cellName3 {_temp/IODELAY2_data}
        set cellName "$cellName1$num$cellName2$dataIndex$cellName3"

        set combined "$firstPart$cellName$secondPart"
        set charCount [string length $combined]
        set combined [string replace $combined [expr $charCount-3] [expr $charCount-2] "$dataTap"]
        puts $outFp "$combined"
        puts $outFp "trim -id comp $cellName"
        puts "$dataName, tap $dataTap, cell name $cellName"

    }

    # Print out valid tap modification
    set validName XID8
    set validName [string replace $validName 0 0 $channel]

	set validSlowDelay $outputDelayArray($validName)
	set validFastDelay $outputDelayFastArray($validName)
	set validDelay [expr ($validSlowDelay + $validFastDelay)/2]

    # set validTap [expr int(floor(($maxDelay-$validDelay)/$tapUnitDelay))+0]
	set valid8Tap [expr int(floor(($maxDelay-$validDelay)/$tapDelayDivider))]
	set validReminder [expr ($maxDelay-$validDelay)-($valid8Tap*$tapDelayDivider)]
	if {$validReminder < $th01} {
		set validTap [expr int($valid8Tap*8+0)]
	} elseif {$validReminder < $th12} {
		set validTap [expr int($valid8Tap*8+1)]
	} elseif {$validReminder < $th23} {
		set validTap [expr int($valid8Tap*8+2)]
	} elseif {$validReminder < $th34} {
		set validTap [expr int($valid8Tap*8+3)]
	} elseif {$validReminder < $th45} {
		set validTap [expr int($valid8Tap*8+4)]
	} elseif {$validReminder < $th56} {
		set validTap [expr int($valid8Tap*8+5)]
	} elseif {$validReminder < $th67} {
		set validTap [expr int($valid8Tap*8+6)]
	} elseif {$validReminder < $th78} {
		set validTap [expr int($valid8Tap*8+7)]
	} else {
		set validTap [expr int($valid8Tap*8+8)]
	}

    set cellName1 {delay/c0[}
    set cellName2 {].valid_temp/IODELAY2_data}
    set cellName "$cellName1$clkIndex$cellName2"

    set firstPart {setattr comp }
    set secondPart { ODELAY_VALUE "00"}
    set combined "$firstPart$cellName$secondPart"
    set charCount [string length $combined]
    set combined [string replace $combined [expr $charCount-3] [expr $charCount-2] "$validTap"]
    puts $outFp "$combined"
    puts $outFp "trim -id comp $cellName"
	puts "$validName, tap $validTap, cell name $cellName"

    puts $outFp ""

}

# Print out some unchanged scripts
puts $outFp "exit -s"

# Close output file
close $outFp

puts "Fpga_edline script generated"

