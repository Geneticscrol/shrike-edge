(* top *)
module top (
    (* iopad_external_pin, clkbuf_inhibit *) input  clk,
    (* iopad_external_pin *) output clk_en,
    (* iopad_external_pin *) input  sck,
    (* iopad_external_pin *) input  cs_n,
    (* iopad_external_pin *) input  mosi,
    (* iopad_external_pin *) output miso,
    (* iopad_external_pin *) output miso_oe,
    (* iopad_external_pin *) output irq,
    (* iopad_external_pin *) output irq_oe,
    (* iopad_external_pin *) input  trig,
    (* iopad_external_pin *) output pwm_out,
    (* iopad_external_pin *) output pwm_oe,
    (* iopad_external_pin *) output uart_tx,
    (* iopad_external_pin *) output uart_tx_oe,
    (* iopad_external_pin *) input  uart_rx,
    (* iopad_external_pin *) input  smp_in,
    (* iopad_external_pin *) output led,
    (* iopad_external_pin *) output led_oe
);
    assign clk_en=1'b1; assign irq_oe=1'b1; assign pwm_oe=1'b1;
    assign uart_tx_oe=1'b1; assign led_oe=1'b1;
    reg [7:0] por = 8'd0;
    wire rst_n = por[7];
    always @(posedge clk) if (por != 8'hFF) por <= {por[6:0], 1'b1};
    wire wr_stb, rd_stb, core_en, led_force, pwm_en, uart_en, smp_en;
    wire [6:0] addr;
    wire [7:0] wdata, rdata, uart_tx_data, uart_rx_data, irq_mask, status;
    wire [15:0] pwm_period, pwm_duty, uart_div, smp_width, smp_period;
    wire uart_tx_start, uart_rx_clr, smp_arm_reg, smp_rst, smp_ready_clr;
    wire uart_rx_ready, uart_tx_busy, uart_rx_overrun, smp_ready, smp_armed;
    wire pwm_q, tx_q, trig_s, trig_rise;
    sync2 u_trig (.clk(clk), .rst_n(rst_n), .din(trig), .dout(trig_s));
    reg trig_d;
    always @(posedge clk or negedge rst_n) if (!rst_n) trig_d<=0; else trig_d<=trig_s;
    assign trig_rise = trig_s & ~trig_d;
    link6_spi_slave u_spi (.clk(clk), .rst_n(rst_n), .sck(sck), .cs_n(cs_n), .mosi(mosi),
        .miso(miso), .miso_oe(miso_oe), .wr_stb(wr_stb), .rd_stb(rd_stb),
        .addr(addr), .wdata(wdata), .rdata(rdata));
    regs u_regs (.clk(clk), .rst_n(rst_n), .wr_stb(wr_stb), .rd_stb(rd_stb),
        .addr(addr), .wdata(wdata), .rdata(rdata),
        .uart_rx_ready(uart_rx_ready), .uart_tx_busy(uart_tx_busy),
        .uart_rx_overrun(uart_rx_overrun), .smp_ready(smp_ready), .smp_armed(smp_armed),
        .uart_rx_data(uart_rx_data), .smp_width(smp_width), .smp_period(smp_period),
        .core_en(core_en), .led_force(led_force), .pwm_en(pwm_en), .uart_en(uart_en),
        .smp_en(smp_en), .pwm_period(pwm_period), .pwm_duty(pwm_duty), .uart_div(uart_div),
        .uart_tx_start(uart_tx_start), .uart_tx_data(uart_tx_data), .uart_rx_clr(uart_rx_clr),
        .smp_arm(smp_arm_reg), .smp_rst(smp_rst), .smp_ready_clr(smp_ready_clr),
        .irq_mask(irq_mask), .status(status));
    pwm_ch u_pwm (.clk(clk), .rst_n(rst_n), .en(core_en & pwm_en), .period(pwm_period), .duty(pwm_duty), .pwm(pwm_q));
    uart_tx u_tx (.clk(clk), .rst_n(rst_n), .en(core_en & uart_en), .div(uart_div),
        .start(uart_tx_start), .data(uart_tx_data), .busy(uart_tx_busy), .tx(tx_q));
    uart_rx u_rx (.clk(clk), .rst_n(rst_n), .en(core_en & uart_en), .div(uart_div),
        .rx(uart_rx), .data(uart_rx_data), .ready(uart_rx_ready), .overrun(uart_rx_overrun), .ready_clr(uart_rx_clr));
    pulse_sampler u_smp (.clk(clk), .rst_n(rst_n), .en(core_en & smp_en), .din(smp_in),
        .arm(smp_arm_reg | trig_rise), .soft_rst(smp_rst | smp_ready_clr),
        .armed(smp_armed), .ready(smp_ready), .width(smp_width), .period(smp_period));
    assign pwm_out = pwm_q;
    assign uart_tx = tx_q;
    assign irq = |(status & irq_mask);
    assign led = led_force | pwm_q;
endmodule
