/*
 * Module: interrupts
 * Description: This module handles interrupt signal detection and flagging based on rising or falling edges of the input signal.
 *              It includes masking capabilities for both rising and falling edges and provides a mechanism to reset the interrupt flag.
 *
 * Ports:
 * - input clk: Clock signal.
 * - input reset: Asynchronous reset signal. Resets the interrupt flag and internal state when high.
 * - input interrupts_signal: The input signal to monitor for rising or falling edges.
 * - input rising_edge_mask: Mask to enable or disable detection of rising edges on the input signal.
 * - input falling_edge_mask: Mask to enable or disable detection of falling edges on the input signal.
 * - output reg interrupt_flag: Output flag that is set when an interrupt condition is detected.
 * - input interrupt_flag_set_0: Signal to reset the interrupt_flag to 0.
 *
 * Internal Signals:
 * - reg last_interrupts_signal: Stores the previous state of the interrupts_signal for edge detection.
 * - reg last_interrupts_signal_1: Stores the state of last_interrupts_signal from the previous clock cycle.
 * - wire rising_edge: Indicates a rising edge on the interrupts_signal when rising_edge_mask is enabled.
 * - wire falling_edge: Indicates a falling edge on the interrupts_signal when falling_edge_mask is enabled.
 *
 * Functionality:
 * - On reset, the interrupt_flag and internal state registers are cleared.
 * - Rising and falling edges of the interrupts_signal are detected based on the current and previous states of the signal.
 * - The interrupt_flag is set when a rising or falling edge is detected (based on the enabled masks).
 * - The interrupt_flag can be reset to 0 using the interrupt_flag_set_0 signal.
 */
module interrupts(//single one
    input clk,
    input reset,

    input interrupts_signal,

    input rising_edge_mask,
    input falling_edge_mask,

    output reg interrupt_flag,
    input interrupt_flag_set_0
);



always @(negedge clk or posedge reset) begin
    if(reset)begin
        interrupt_flag <= 0;
    end
    else if (rising_edge || falling_edge) begin
        interrupt_flag <= 1;
    end
    else if (interrupt_flag_set_0) begin
        interrupt_flag <= 0;
    end
end

reg last_interrupts_signal, last_interrupts_signal_1;
always @(posedge clk or posedge reset) begin
    if(reset)begin
        last_interrupts_signal <= 0;
        last_interrupts_signal_1 <= 0;
    end
    else begin
        last_interrupts_signal <= interrupts_signal;
        last_interrupts_signal_1 <= last_interrupts_signal;
    end
end

assign rising_edge = rising_edge_mask && last_interrupts_signal && ~last_interrupts_signal_1;
assign falling_edge = falling_edge_mask && ~last_interrupts_signal && last_interrupts_signal_1;

endmodule